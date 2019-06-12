
#include "cbccd.h"

static const char *report_tbl_names[] =
{
	CBCC_REPORT_HW_TBL_NAME,
	CBCC_REPORT_NET_TBL_NAME,
	CBCC_REPORT_SEC_TBL_NAME,
	NULL
};

// set report info into database
static void set_report_info_into_db(cbccd_ctx_t *c, const char *guid, const char *report_info)
{
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_VERBOSE, "REPORT: Setting report info '%s' for guid '%s'", report_info, guid);
	
	for (int i = CBCC_REPORT_TYPE_HW; i < CBCC_REPORT_TYPE_NUM; i++)
	{
		char *tbl_data = NULL;

		if (report_tbl_names[i] == NULL)
			break;
			
		// parsing report info for each type
		cbcc_json_object_t report_tbl_jobjs[] =
		{
			{
				.key = report_tbl_names[i],
				.type = CBCC_JSON_DATA_TYPE_OBJECT_BIG,
				.data.str_val_big = &tbl_data,
			}
		};
		
		if (cbcc_json_parse_from_buffer(report_info, report_tbl_jobjs, CBCC_JOBJS_COUNT(report_tbl_jobjs)) != 0)
		{
			CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "REPORT: Could not found reporting data for '%s'", report_tbl_names[i]);
			cbcc_json_mem_free(report_tbl_jobjs, CBCC_JOBJS_COUNT(report_tbl_jobjs));
			
			continue;
		}
		
		CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_VERBOSE, "REPORT: Setting report info '%s' for %s", tbl_data, report_tbl_names[i]);
		
		// set reporting info into database
		cbccd_pgsql_set_guid_tbl_data(&c->pgsql_mgr, CBCC_DB_CONN_TYPE_REPORT, report_tbl_names[i], guid, tbl_data);
		
		// free reporting info
		if (tbl_data)
			free(tbl_data);
	}
	
	return;
}

// set reporting pngs into logging directory
static void set_report_pngs_into_dir(cbccd_ctx_t *c, const char *guid, const char *png_data)
{
	char png_archive_dir[CBCC_MAX_PATH], png_archive_fpath[CBCC_MAX_PATH];
	
	snprintf(png_archive_dir, sizeof(png_archive_dir), "%s/%s", CBCCD_REPORT_DIR_PATH, guid);
	snprintf(png_archive_fpath, sizeof(png_archive_fpath), "%s/imags.tar.gz", png_archive_dir);

	// make direcoty
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_HIGH, "REPORT: Making directory '%s'", png_archive_dir);

	rmdir(png_archive_dir);

	mkdir(png_archive_dir, 0777);
	chmod(png_archive_dir, S_IRUSR | S_IWUSR | S_IXUSR | S_IRGRP | S_IXGRP | S_IROTH | S_IXOTH);
	
	// decode base64 encoded into archive file
	if (decode_base64_to_file(png_data, png_archive_fpath) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "REPORT: Could not decode png archives into file '%s'", png_archive_fpath);
		return;
	}
	
	char unzip_cmd[CBCC_MAX_CMD_LEN];
	snprintf(unzip_cmd, sizeof(unzip_cmd), "/bin/tar xvzf %s -C %s >/dev/null", png_archive_fpath, png_archive_dir);
	system(unzip_cmd);

	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "REPORT: Unzipping command '%s' has succeeded.", unzip_cmd);
	
	return;
}

// set reporting data into database
int cbccd_report_set_data(struct _cbccd_ctx *c, int clnt_sock, const char *report_data)
{
	char *report_info = NULL;
	char *report_png_data = NULL;
	
	int ret = 0;
	
	// getting client guid
	cbccd_device_info_t *dev_info = cbccd_device_get_info_by_sock(&c->device_mgr, clnt_sock);
	if (!dev_info)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "REPORT: Could not found device guid by socket '%d'", clnt_sock);
		return -1;
	}
	
	// check device is logined
	if (!dev_info->is_logined)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "REPORT: Device from socket '%d' isn't logined", clnt_sock);
		return -1;
	}
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "REPORT: Setting reporting info from device '%s'", dev_info->guid);
	
	// parsing reporting data
	cbcc_json_object_t report_data_jobjs[] =
	{
		{
			.key = "report_info",
			.type = CBCC_JSON_DATA_TYPE_OBJECT_BIG,
			.must_specify = true,
			.data.str_val_big = &report_info,
		},
		{
			.key = "png_contents",
			.type = CBCC_JSON_DATA_TYPE_STRING_BIG,
			.must_specify = true,
			.data.str_val_big = &report_png_data,
		}
	};
	
	if (cbcc_json_parse_from_buffer(report_data, report_data_jobjs, CBCC_JOBJS_COUNT(report_data_jobjs)) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "REPORT: Parsing reporting data from device '%s' has failed.", dev_info->guid);
		ret = -1;
		
		goto end;
	}
	
	// set report info into database
	set_report_info_into_db(c, dev_info->guid, report_info);
	
	// set report png into logging directory
	set_report_pngs_into_dir(c, dev_info->guid, report_png_data);
	
end:
	if (report_info)
		free(report_info);
	
	if (report_png_data)
		free(report_png_data);
	
	return ret;
}

// delete all reporting data for device
void cbccd_report_delete_data(struct _cbccd_ctx *c, const char *dev_guid)
{
	char png_archive_dir[CBCC_MAX_PATH];
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "REPORT: Deleting all reporting data for device '%s'", dev_guid);

	// delete reporting info from database
	for (int i = 0; i < CBCC_REPORT_TYPE_NUM; i++)
	{
		cbccd_pgsql_rm_guid_tbl_data(&c->pgsql_mgr, CBCC_DB_CONN_TYPE_REPORT, report_tbl_names[i], dev_guid);
	}

	// delete reporting files
	snprintf(png_archive_dir, sizeof(png_archive_dir), "%s/%s", CBCCD_REPORT_DIR_PATH, dev_guid);
	remove(png_archive_dir);

	return;
}
