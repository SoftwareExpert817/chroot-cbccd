
#include "cbccd.h"

// build backup command
static void build_backup_cmd(bool auto_backup, const char *guid, const char *comment, const char *user, char **backup_cmd)
{
	// build backup command
	cbcc_json_object_t backup_cmd_jobjs[] =
	{
		{
			.key = "cmd",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val_set = CBCC_CMD_CREATE_BACKUP
		},
		{
			.key = "data",
			.type = CBCC_JSON_DATA_TYPE_OBJECT,
		},
		{
			.key = "backup.objects",
			.type = CBCC_JSON_DATA_TYPE_OBJECT,
			.parent_key = "data",
		},
		{
			.key = "guid",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.parent_key = "backup.objects",
			.data.str_val_set = guid,
		},
		{
			.key = "auto_backup",
			.type = CBCC_JSON_DATA_TYPE_BOOLEAN,
			.parent_key = "backup.objects",
			.data.int_val_set = auto_backup ? 1 : 0,
		},
		{
			.key = "comment",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.parent_key = "backup.objects",
			.data.str_val_set = comment,
		},
		{
			.key = "user",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.parent_key = "backup.objects",
			.data.str_val_set = user,
		},
	};
	
	cbcc_json_build(backup_cmd_jobjs, CBCC_JOBJS_COUNT(backup_cmd_jobjs), backup_cmd);
	
	return;
}

// create backup
int cbccd_admin_send_create_backup_cmd(struct _cbccd_ctx *c, const char *backup_guid, const char *dev_guid,
						 const char *comment, const char *user)
{
	int ret = CBCC_RESP_OK;
	char *backup_cmd;
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Processing create.backup command.");

	// build backup command
	build_backup_cmd(false, backup_guid, comment, user, &backup_cmd);
	
	// lock device manager
	cbccd_device_mutex_lock(&c->device_mgr);
	
	// get device info
	cbccd_device_info_t *p = cbccd_device_get_info_by_guid(&c->device_mgr, dev_guid);
	if (!p)
	{
		CBCC_DEBUG_WARN(CBCC_DEBUG_LEVEL_NOR, "ADMIN: The device '%s' isn't exist in list", dev_guid);
		ret = CBCC_RESP_NOT_CONNECTED;
	}
	else
	{
		// check device has logined
		if (!p->is_logined)
		{
			CBCC_DEBUG_WARN(CBCC_DEBUG_LEVEL_NOR, "ADMIN: The device '%s' isn't logined yet", dev_guid);
			ret = CBCC_RESP_NOT_LOGINED;
		}

		CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Sending '%s' command to device '%s'", CBCC_CMD_CREATE_BACKUP, dev_guid);
			
		// send command
		if (cbccd_cmd_send(&c->cmd_mgr, p->sock, backup_cmd) < 0)
		{
			CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Could not send backup command to '%s'.", dev_guid);
			ret = CBCC_RESP_SEND_FAILED;
		}
	}
		
	// unlock device manager
	cbccd_device_mutex_unlock(&c->device_mgr);
	
	// free backup command
	free(backup_cmd);
	
	return ret;
}

// create backup file
static int create_backup_file(cbccd_ctx_t *c, int clnt_sock, cbccd_backup_info_t *backup_info)
{
	char dir_path[CBCC_MAX_PATH];
	char md5sum[CBCC_MD5SUM_LEN * 2 + 1];
	
	// get device info by socket
	cbccd_device_info_t *dev_info = cbccd_device_get_info_by_sock(&c->device_mgr, clnt_sock);
	if (!dev_info)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Could not found device info by socket '%d'", clnt_sock);
		return -1;
	}
	
	// check device is logined
	if (!dev_info->is_logined)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Device from socket '%d' isn't logined", clnt_sock);
		return -1;
	}
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Creating backup info for device '%s'", dev_info->guid);

	// check base64 encoded data is valid
	if (!backup_info->base64_encoded)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Base64 encoded data is invalid.");
		return -1;
	}
	
	// set backup file path
	backup_info->timestamp = time(NULL);
	snprintf(backup_info->file_name, sizeof(backup_info->file_name), "cfg_%lu", backup_info->timestamp);
	snprintf(dir_path, sizeof(dir_path), "%s/%s", CBCCD_BACKUP_DIR_PATH, dev_info->guid);
	snprintf(backup_info->file_path, sizeof(backup_info->file_path), "%s/%s", dir_path, backup_info->file_name);
	
	// create directory
	mkdir(dir_path, 0777);
	
	// decode base64 encoded data and write into file
	if (decode_base64_to_file(backup_info->base64_encoded, backup_info->file_path) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Base64 encoded data is invalid.");
		return -1;
	}
	
	// check md5sum
	if (get_md5sum_of_file(backup_info->file_path, 1, md5sum, sizeof(md5sum)) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Checking MD5Sum has failed.");
		return -1;
	}
	
	if (strcmp(md5sum, backup_info->md5sum) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Mismatched md5sum.");
		return -1;
	}
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_HIGH, "ADMIN: Backup file has created successfully with guid '%s'", backup_info->guid);
	
	return 0;
}

// add backup info into database
static int add_backup_info_into_db(cbccd_ctx_t *c, int clnt_sock, cbccd_backup_info_t *backup_info)
{
	char *backup_info_jstr = NULL;
	char *tbl_data = NULL;
	
	// get device info by socket
	cbccd_device_info_t *dev_info = cbccd_device_get_info_by_sock(&c->device_mgr, clnt_sock);
	if (!dev_info)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Could not found device info by socket '%d'", clnt_sock);
		return -1;
	}
	
	// check device has logined
	if (!dev_info->is_logined)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Device from socket '%d' isn't logined", clnt_sock);
		return -1;
	}
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Adding backup info for device '%s' into database", dev_info->guid);
	
	// build backup info json string
	cbcc_json_object_t backup_info_jobjs[] =
	{
		{
			.key = backup_info->guid,
			.type = CBCC_JSON_DATA_TYPE_OBJECT,
		},
		{
			.key = "auto_backup",
			.type = CBCC_JSON_DATA_TYPE_BOOLEAN,
			.parent_key = backup_info->guid,
			.data.int_val_set = backup_info->auto_backup ? 1 : 0,
		},
		{
			.key = "comment",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.parent_key = backup_info->guid,
			.data.str_val_set = backup_info->comment,
		},
		{
			.key = "filesize",
			.type = CBCC_JSON_DATA_TYPE_INT,
			.parent_key = backup_info->guid,
			.data.int_val_set = backup_info->file_size,
		},
		{
			.key = "md5",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.parent_key = backup_info->guid,
			.data.str_val_set = backup_info->md5sum,
		},
		{
			.key = "name",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.parent_key = backup_info->guid,
			.data.str_val_set = backup_info->file_name,
		},
		{
			.key = "timestamp",
			.type = CBCC_JSON_DATA_TYPE_INT,
			.parent_key = backup_info->guid,
			.data.int_val_set = time(NULL),
		},
		{
			.key = "user",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.parent_key = backup_info->guid,
			.data.str_val_set = backup_info->user,
		},
		{
			.key = "version",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.parent_key = backup_info->guid,
			.data.str_val_set = backup_info->version,
		},
	};
	
	// get table data for guid
	int tbl_idx = cbccd_pgsql_get_tbl_idx(CBCCD_TBL_NAME_DEVICE_BACKUP);
	if (cbccd_pgsql_cache_get_tbl_data(&c->pgsql_mgr, tbl_idx, dev_info->guid, &tbl_data) == 0)
	{
		if (cbcc_json_add(tbl_data, backup_info_jobjs, CBCC_JOBJS_COUNT(backup_info_jobjs), &backup_info_jstr) != 0)
		{
			CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Could not add backup info into database");
		}
	}
	else
	{
		cbcc_json_build(backup_info_jobjs, CBCC_JOBJS_COUNT(backup_info_jobjs), &backup_info_jstr);
	}
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_HIGH, "ADMIN: Setting create.backup info '%s' into database", backup_info_jstr);
	
	if (backup_info_jstr)
	{
		cbccd_pgsql_set_guid_tbl_data(&c->pgsql_mgr, CBCC_DB_CONN_TYPE_ADMIN, CBCCD_TBL_NAME_DEVICE_BACKUP, dev_info->guid, backup_info_jstr);
		free(backup_info_jstr);
	}

	// free table data
	if (tbl_data)
		free(tbl_data);
	
	return 0;
}

// set created backup info
int cbccd_admin_set_create_backup_info(struct _cbccd_ctx *c, int clnt_sock, const char *obj_data)
{
	cbccd_backup_info_t backup_info;
	int ret = CBCC_RESP_OK;
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Processing create.backup result");
	
	// parse backup info from command data
	memset(&backup_info, 0, sizeof(backup_info));
	cbcc_json_object_t backup_info_jobjs[] =
	{
		{
			.key = "auto_backup",
			.type = CBCC_JSON_DATA_TYPE_INT,
			.data.int_val = &backup_info.auto_backup
		},
		{
			.key = "guid",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val = backup_info.guid,
			.data_size = sizeof(backup_info.guid)
		},
		{
			.key = "comment",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val = backup_info.comment,
			.data_size = sizeof(backup_info.comment)
		},
		{
			.key = "filesize",
			.type = CBCC_JSON_DATA_TYPE_INT,
			.data.int_val = &backup_info.file_size,
		},
		{
			.key = "md5sum",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val = backup_info.md5sum,
			.data_size = sizeof(backup_info.md5sum)
		},
		{
			.key = "base64_encoded",
			.type = CBCC_JSON_DATA_TYPE_STRING_BIG,
			.data.str_val_big = &backup_info.base64_encoded,
		},
		{
			.key = "version",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val = backup_info.version,
			.data_size = sizeof(backup_info.version)
		},
		{
			.key = "user",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val = backup_info.user,
			.data_size = sizeof(backup_info.user)
		}
	};
	
	if (cbcc_json_parse_from_buffer(obj_data, backup_info_jobjs, CBCC_JOBJS_COUNT(backup_info_jobjs)) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Could not parse JSON buffer for setting backup info '%s'", obj_data);
		ret = CBCC_RESP_JSON_INVALID;
		
		goto end;
	}
	
	// create backup file
	if (create_backup_file(c, clnt_sock, &backup_info) != 0)
	{
		ret = CBCC_RESP_CREATE_BACKUP_FAILED;
		goto end;
	}
	
	// add backup info into database
	if (add_backup_info_into_db(c, clnt_sock, &backup_info) != 0)
	{
		ret = CBCC_RESP_DB_OPER_FAILED;
	}

end:
	if (backup_info.base64_encoded)
		free(backup_info.base64_encoded);
	
	return ret;
}

// get backup info with given guid from database
static int get_backup_info_from_db(cbccd_ctx_t *c, const char *guid, cbccd_backup_info_t *backup_info)
{
	char *tbl_data = NULL;
	int ret = 0;
	
	// get table data by guid
	int tbl_idx = cbccd_pgsql_get_tbl_idx(CBCCD_TBL_NAME_DEVICE_BACKUP);
	if (cbccd_pgsql_cache_get_tbl_data(&c->pgsql_mgr, tbl_idx, guid, &tbl_data) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Could not get backup info by guid '%s'", guid);
		return -1;
	}
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_VERBOSE, "ADMIN: Backup info for guid '%s' is '%s'", backup_info->guid, tbl_data);
	
	// parse backup info json string
	cbcc_json_object_t backup_info_jobjs[] =
	{
		{
			.key = backup_info->guid,
			.type = CBCC_JSON_DATA_TYPE_OBJECT,
		},
		{
			.key = "comment",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.parent_key = backup_info->guid,
			.data.str_val = backup_info->comment,
			.data_size = sizeof(backup_info->comment)
		},
		{
			.key = "name",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.parent_key = backup_info->guid,
			.data.str_val = backup_info->file_name,
			.data_size = sizeof(backup_info->file_name)
		},
		{
			.key = "md5",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.parent_key = backup_info->guid,
			.data.str_val = backup_info->md5sum,
			.data_size = sizeof(backup_info->md5sum)
		},
		{
			.key = "version",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.parent_key = backup_info->guid,
			.data.str_val = backup_info->version,
			.data_size = sizeof(backup_info->version)
		},
		{
			.key = "user",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.parent_key = backup_info->guid,
			.data.str_val = backup_info->user,
			.data_size = sizeof(backup_info->user)
		}
	};
	
	if (cbcc_json_parse_from_buffer(tbl_data, backup_info_jobjs, CBCC_JOBJS_COUNT(backup_info_jobjs)) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Could not parse JSON buffer for restore.backup by guid '%s'", backup_info->guid);
		ret = -1;
	}

	// free table data
	if (tbl_data)
		free(tbl_data);
	
	return ret;
}

// set backup file contents
static int set_backup_file_contents(const char *dev_guid, cbccd_backup_info_t *backup_info)
{
	char backup_fpath[CBCC_MAX_PATH];
	char md5sum[CBCC_MD5SUM_LEN * 2 + 1];
	
	// get file path of backup file
	snprintf(backup_fpath, sizeof(backup_fpath), "%s/%s/%s", CBCCD_BACKUP_DIR_PATH, dev_guid, backup_info->file_name);
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_HIGH, "ADMIN: Setting backup file contents from '%s'", backup_fpath);
	
	// get md5 sum of file and compare with one from database
	if (get_md5sum_of_file(backup_fpath, 1, md5sum, sizeof(md5sum)) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_HIGH, "ADMIN: Could not get md5sum of file '%s'", backup_fpath);
		return -1;
	}
	
	if (strcmp(md5sum, backup_info->md5sum) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_HIGH, "ADMIN: MD5Sum is mismatched.");
		return -1;
	}
	
	// encode as base64
	if (get_base64_encoded_from_file(backup_fpath, &backup_info->base64_encoded) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_HIGH, "ADMIN: Could not encode as base64 for file '%s'", backup_fpath);
		return -1;
	}
	
	return 0;
}

// build restore.backup command
static void build_restore_backup_cmd(cbccd_backup_info_t *backup_info, char **cmd)
{
	// build command data
	cbcc_json_object_t backup_jobjs[] =
	{
		{
			.key = "cmd",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val_set = CBCC_CMD_RESTORE_BACKUP
		},
		{
			.key = "data",
			.type = CBCC_JSON_DATA_TYPE_OBJECT,
		},
		{
			.key = "auto_backup",
			.type = CBCC_JSON_DATA_TYPE_INT,
			.parent_key = "data",
			.data.int_val_set = backup_info->auto_backup
		},
		{
			.key = "guid",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.parent_key = "data",
			.data.str_val_set = backup_info->guid,
		},
		{
			.key = "comment",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.parent_key = "data",
			.data.str_val_set = backup_info->comment,
		},
		{
			.key = "filesize",
			.type = CBCC_JSON_DATA_TYPE_INT,
			.parent_key = "data",
			.data.int_val_set = backup_info->file_size,
		},
		{
			.key = "md5sum",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.parent_key = "data",
			.data.str_val_set = backup_info->md5sum,
		},
		{
			.key = "base64_encoded",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.parent_key = "data",
			.data.str_val_set = backup_info->base64_encoded,
		},
		{
			.key = "version",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.parent_key = "data",
			.data.str_val_set = backup_info->version,
		},
		{
			.key = "user",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.parent_key = "data",
			.data.str_val_set = backup_info->user,
		}
	};
	
	cbcc_json_build(backup_jobjs, CBCC_JOBJS_COUNT(backup_jobjs), cmd);
	
	return;
}

// set restore result into database
static void set_restore_result_into_db(struct _cbccd_ctx *c, const char *dev_guid, const char *backup_guid)
{
	char *tbl_data = NULL;
	char *res_jstr = NULL;
	
	// get table data by device guid
	int tbl_idx = cbccd_pgsql_get_tbl_idx(CBCCD_TBL_NAME_DEVICE_BACKUP);
	if (cbccd_pgsql_cache_get_tbl_data(&c->pgsql_mgr, tbl_idx, dev_guid, &tbl_data) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Could not get backup info by guid '%s'", dev_guid);
		return;
	}

	// build restore result json buffer
	cbcc_json_object_t restore_res_jobjs[] =
	{
		{
			.key = "last_restore",
			.type = CBCC_JSON_DATA_TYPE_OBJECT,
		},
		{
			.key = "backup",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.parent_key = "last_restore",
			.data.str_val_set = backup_guid,
		},
		{
			.key = "timestamp",
			.type = CBCC_JSON_DATA_TYPE_INT,
			.parent_key = "last_restore",
			.data.int_val_set = time(NULL),
		}
	};

	cbcc_json_add(tbl_data, restore_res_jobjs, CBCC_JOBJS_COUNT(restore_res_jobjs), &res_jstr);

	// update table data
	cbccd_pgsql_set_guid_tbl_data(&c->pgsql_mgr, CBCC_DB_CONN_TYPE_ADMIN, CBCCD_TBL_NAME_DEVICE_BACKUP, dev_guid, res_jstr);

	// free json buffers
	free(tbl_data);
	free(res_jstr);

	return;
}

// restore backup
int cbccd_admin_send_restore_backup_cmd(struct _cbccd_ctx *c, const char *dev_guid, const char *backup_guid)
{
	cbccd_backup_info_t backup_info;
	char *backup_cmd = NULL;

	int ret = CBCC_RESP_OK;
	
	// initialize backup info
	memset(&backup_info, 0, sizeof(backup_info));

	strcpy(backup_info.guid, backup_guid);
	
	// get backup info from table
	if (get_backup_info_from_db(c, dev_guid, &backup_info) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Could not get backup info with guid '%s' from database", dev_guid);
		ret = CBCC_RESP_NO_EXIST_BACKUP;
		
		goto end;
	}
	
	// set backup file contents
	if (set_backup_file_contents(dev_guid, &backup_info) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Setting backup file contents has failed.");
		ret = CBCC_RESP_NO_VALID_BACKUP;
		
		goto end;
	}
	
	// build restore.backup command
	build_restore_backup_cmd(&backup_info, &backup_cmd);

	// send command to each device
	cbccd_device_mutex_lock(&c->device_mgr);
	
	cbccd_device_info_t *p = cbccd_device_get_info_by_guid(&c->device_mgr, dev_guid);
	if (!p)
	{
		CBCC_DEBUG_WARN(CBCC_DEBUG_LEVEL_NOR, "ADMIN: The device '%s' isn't exist in list", dev_guid);
		ret = CBCC_RESP_NOT_CONNECTED;
	}
	else
	{
		// check device has logined
		if (!p->is_logined)
		{
			CBCC_DEBUG_WARN(CBCC_DEBUG_LEVEL_NOR, "ADMIN: The device '%s' isn't logined yet", dev_guid);
			ret = CBCC_RESP_NOT_LOGINED;
		}
		else
		{
			CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Sending '%s' command to device '%s'", CBCC_CMD_RESTORE_BACKUP, dev_guid);
				
			// send command
			if (cbccd_cmd_send(&c->cmd_mgr, p->sock, backup_cmd) < 0)
			{
				CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Could not send restore.backup command to '%s'.", dev_guid);
				ret = CBCC_RESP_SEND_FAILED;
			}
		}
	}
	
	cbccd_device_mutex_unlock(&c->device_mgr);

	// if sending command has succeded, then set restore result into database
	if (ret == CBCC_RESP_OK)
	{
		set_restore_result_into_db(c, dev_guid, backup_guid);
	}

end:
	if (backup_cmd)
		free(backup_cmd);
	
	if (backup_info.base64_encoded)
		free(backup_info.base64_encoded);
		
	return ret;
}

// delete backup info from database
static void delete_backup_info_from_db(cbccd_ctx_t *c, const char *dev_guid, const char *backup_guid)
{
	char *old_backup_info = NULL;
	char *new_backup_info = NULL;

	char backup_fname[CBCC_MAX_PATH];
	char backup_fpath[CBCC_MAX_PATH];
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_HIGH, "ADMIN: Deleting backup info by device guid '%s', backup guid '%s'", dev_guid, backup_guid);
	
	// get old backup info
	int tbl_idx = cbccd_pgsql_get_tbl_idx(CBCCD_TBL_NAME_DEVICE_BACKUP);
	if (cbccd_pgsql_cache_get_tbl_data(&c->pgsql_mgr, tbl_idx, dev_guid, &old_backup_info) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Could not get data by guid '%s' from table '%s'", dev_guid, CBCCD_TBL_NAME_DEVICE_BACKUP);
		return;
	}
	
	// get filename
	cbcc_json_object_t backup_info_jobjs[] =
	{
		{
			.key = "name",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.parent_key = backup_guid,
			.data.str_val = backup_fname,
			.data_size = sizeof(backup_fname)
		},
	};
	
	if (cbcc_json_parse_from_buffer(old_backup_info, backup_info_jobjs, CBCC_JOBJS_COUNT(backup_info_jobjs)) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Could not get filename from backup info '%s'", old_backup_info);

		if (old_backup_info)
			free(old_backup_info);

		return;
	}

	// remove file
	snprintf(backup_fpath, sizeof(backup_fpath), "%s/%s/%s", CBCCD_BACKUP_DIR_PATH, dev_guid, backup_fname);
	remove(backup_fpath);
	
	// delete backup info
	cbcc_json_object_t backup_rm_jobjs[] =
	{
		{
			.key = backup_guid,
			.type = CBCC_JSON_DATA_TYPE_OBJECT,
		}
	};
	
	cbcc_json_remove(old_backup_info, backup_rm_jobjs, CBCC_JOBJS_COUNT(backup_rm_jobjs), &new_backup_info);
	
	// set backup info
	cbccd_pgsql_set_guid_tbl_data(&c->pgsql_mgr, CBCC_DB_CONN_TYPE_ADMIN, CBCCD_TBL_NAME_DEVICE_BACKUP,
				dev_guid, new_backup_info);
	
	free(old_backup_info);
	free(new_backup_info);
	
	return;
}

// delete backup
int cbccd_admin_delete_backup(struct _cbccd_ctx *c, const char *backup_guid, const char *dev_guid)
{
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Processing delete.backup notification");
	
	delete_backup_info_from_db(c, dev_guid, backup_guid);
	return CBCC_RESP_OK;
}

// delete all backup infos by device guid
void cbccd_admin_delete_all_backups(struct _cbccd_ctx *c, const char *dev_guid)
{
	char backup_dir_path[CBCC_MAX_PATH];

	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Deleting all backup infos for device '%s'", dev_guid);

	// remove backup infos from database
	cbccd_pgsql_rm_guid_tbl_data(&c->pgsql_mgr, CBCC_DB_CONN_TYPE_ADMIN, CBCCD_TBL_NAME_DEVICE_BACKUP, dev_guid);

	// remove backup directory for given device
	snprintf(backup_dir_path, sizeof(backup_dir_path), "%s/%s", CBCCD_BACKUP_DIR_PATH, dev_guid);
	remove(backup_dir_path);

	return;
}


// auto backup interval strings
static const char *ba_interval_strs[] =
{
	CBCC_AUTO_BA_INTERVAL_TYPE_DAILY_STR,
	CBCC_AUTO_BA_INTERVAL_TYPE_WEEKLY_STR,
	CBCC_AUTO_BA_INTERVAL_TYPE_MONTHLY_STR,
	NULL,
};

static enum CBCC_AUTO_BA_INTERVAL_TYPE get_ba_interval_type(const char *ba_interval_str)
{
	for (int i = 0; i < CBCC_AUTO_BA_INTERVAL_TYPE_UNKNOWN; i++)
	{
		if (ba_interval_strs[i] == NULL)
			break;
		
		if (strcmp(ba_interval_str, ba_interval_strs[i]) == 0)
			return i;
	}
	
	return CBCC_AUTO_BA_INTERVAL_TYPE_UNKNOWN;
}

// update auto backup info
static void update_auto_backup_info(cbccd_ctx_t *c, cbccd_auto_backup_info_t *auto_ba_info)
{
	char *ba_info_jstr;
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Updating auto-backup info");
	
	// build auto backup info
	cbcc_json_object_t auto_backup_jobjs[] = 
	{
		{
			.key = "ba_interval",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val_set = ba_interval_strs[auto_ba_info->interval_type],
		},
		{
			.key = "status",
			.type = CBCC_JSON_DATA_TYPE_INT,
			.data.int_val_set = auto_ba_info->status,
		},
		{
			.key = "ba_max",
			.type = CBCC_JSON_DATA_TYPE_INT,
			.data.int_val_set = auto_ba_info->max_keep_backups,
		},
		{
			.key = "enqueued_starttime",
			.type = CBCC_JSON_DATA_TYPE_INT,
			.data.int_val_set = auto_ba_info->enqueued_starttime,
		},
		{
			.key = "next_starttime",
			.type = CBCC_JSON_DATA_TYPE_INT,
			.data.int_val_set = auto_ba_info->next_starttime,
		}
	};
	
	cbcc_json_build(auto_backup_jobjs, CBCC_JOBJS_COUNT(auto_backup_jobjs), &ba_info_jstr);
	
	// update auto backup info in database
	cbccd_pgsql_set_guid_tbl_data(&c->pgsql_mgr, CBCC_DB_CONN_TYPE_ADMIN, CBCCD_TBL_NAME_AUTO_BACKUP, "1", ba_info_jstr);
	
	// free json string
	free(ba_info_jstr);
	
	return;
}

// parse auto backup info from database
static int parse_auto_backup_info_from_db(cbccd_ctx_t *c, cbccd_auto_backup_info_t *auto_ba_info)
{
	char *auto_backup_info = NULL;
	char interval[CBCC_MAX_INTERVALS_LEN];
	
	time_t curr_tt = time(NULL);

	int ret = 0;
	
	// parse auto_backup_info table data
	int tbl_idx = cbccd_pgsql_get_tbl_idx(CBCCD_TBL_NAME_AUTO_BACKUP);
	if (cbccd_pgsql_cache_get_tbl_data(&c->pgsql_mgr, tbl_idx, "1", &auto_backup_info) != 0)
		return -1;

	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_HIGH, "ADMIN: Parsing auto backup info '%s'", auto_backup_info);
	
	// parse auto backup info jsong string
	cbcc_json_object_t auto_backup_jobjs[] =
	{
		{
			.key = "ba_interval",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val = interval,
			.data_size = sizeof(interval)
		},
		{
			.key = "status",
			.type = CBCC_JSON_DATA_TYPE_INT,
			.data.int_val = &auto_ba_info->status,
		},
		{
			.key = "ba_max",
			.type = CBCC_JSON_DATA_TYPE_INT,
			.data.int_val = &auto_ba_info->max_keep_backups,
		},
		{
			.key = "enqueued_starttime",
			.type = CBCC_JSON_DATA_TYPE_INT,
			.data.int_val = &auto_ba_info->enqueued_starttime,
		},
		{
			.key = "next_starttime",
			.type = CBCC_JSON_DATA_TYPE_INT,
			.data.int_val = &auto_ba_info->next_starttime,
		}
	};
	
	if (cbcc_json_parse_from_buffer(auto_backup_info, auto_backup_jobjs, CBCC_JOBJS_COUNT(auto_backup_jobjs)) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Could not parse auto backup info '%s'", auto_backup_info);
		ret = -1;
		goto end;
	}
	
	// check status field
	if (!auto_ba_info->status)
		goto end;
	
	// set interval
	auto_ba_info->interval_type = get_ba_interval_type(interval);
	if (auto_ba_info->interval_type == CBCC_AUTO_BA_INTERVAL_TYPE_UNKNOWN)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Unknown auto backup interval type '%s'", interval);
		ret = -1;
		goto end;
	}
	
	// check starttime
	if (curr_tt > auto_ba_info->enqueued_starttime && curr_tt < auto_ba_info->next_starttime)
	{
		auto_ba_info->take_backup = true;
		
		// set enqueeued start time
		auto_ba_info->enqueued_starttime = auto_ba_info->next_starttime;
		
		// set next start time
		if (auto_ba_info->interval_type == CBCC_AUTO_BA_INTERVAL_TYPE_DAILY)
			auto_ba_info->next_starttime += 60 * 60 * 24;
		else if (auto_ba_info->interval_type == CBCC_AUTO_BA_INTERVAL_TYPE_WEEKLY)
			auto_ba_info->next_starttime += 60 * 60 * 24 * 7;
		else if (auto_ba_info->interval_type == CBCC_AUTO_BA_INTERVAL_TYPE_MONTHLY)
			auto_ba_info->next_starttime += 60 * 60 * 24 * 30;
	}

end:
	if (auto_backup_info)
		free(auto_backup_info);	

	return ret;
}

// send backup command to all devices
static void send_backup_cmd_to_devices(cbccd_ctx_t *c)
{
	char guid[CBCC_MAX_GUID_LEN];
	char *backup_cmd;
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Sending auto-backup command to all devices.");

	// create random guid
	create_random_guid(guid, sizeof(guid));
	
	// build backup command
	build_backup_cmd(true, guid, CBCC_AUTO_BA_COMMENT, CBCC_AUTO_BA_USER, &backup_cmd);
	
	// send command to each device
	cbccd_device_mutex_lock(&c->device_mgr);
	
	cbccd_device_info_t *p = c->device_mgr.device_list.dev_infos;
	while (p)
	{
		// check device has logined
		if (!p->is_logined)
		{
			CBCC_DEBUG_WARN(CBCC_DEBUG_LEVEL_NOR, "ADMIN: The device '%s' isn't logined yet", p->guid);
			
			p = p->next;
			continue;
		}

		CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_HIGH, "ADMIN: Sending '%s(auto)' command to device '%s'", CBCC_CMD_CREATE_BACKUP, p->guid);
		
		// send command
		if (cbccd_cmd_send(&c->cmd_mgr, p->sock, backup_cmd) < 0)
		{
			CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Could not send auto-backup command to '%s'.", p->guid);
			
			p = p->next;
			continue;
		}
		
		p = p->next;
	}

	cbccd_device_mutex_unlock(&c->device_mgr);
	
	// free backup command
	free(backup_cmd);
	
	return;
}

// get auto backup infos
static int get_auto_backup_infos(const char *backup_info_jstr, cbccd_backup_info_t **backup_infos)
{
	cbcc_json_pairs_t ba_infos;
	int auto_ba_infos_num = 0;
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_VERBOSE, "ADMIN: Getting auto backup infos from '%s'", backup_info_jstr);
	
	// initialize backup infos
	memset(&ba_infos, 0, sizeof(ba_infos));
	
	// parse backup info json string
	cbcc_json_object_t ba_info_jobjs[] =
	{
		{
			.is_root = true,
			.type = CBCC_JSON_DATA_TYPE_OBJ_PAIRS,
			.data.pairs = &ba_infos
		}
	};
	
	if (cbcc_json_parse_from_buffer(backup_info_jstr, ba_info_jobjs, CBCC_JOBJS_COUNT(ba_info_jobjs)) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Could not parse backup info '%s'", backup_info_jstr);
		
		cbcc_json_free_pairs(&ba_infos);
		return -1;
	}
	
	if (ba_infos.count == 0)
		return 0;
	
	// allocate memory for backup infos
	cbccd_backup_info_t *p = (cbccd_backup_info_t *) malloc(ba_infos.count * sizeof(cbccd_backup_info_t));
	if (!p)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Out of memory!");
		cbcc_json_free_pairs(&ba_infos);
		
		return -1;
	}
	
	memset(p, 0, ba_infos.count * sizeof(cbccd_backup_info_t));
	
	cbcc_json_pair_t *pair = ba_infos.pairs;
	while (pair)
	{
		bool auto_backup = false;
		int timestamp;
		
		// parse each backup info
		cbcc_json_object_t ba_each_info_jobjs[] =
		{
			{
				.key = "auto_backup",
				.type = CBCC_JSON_DATA_TYPE_BOOLEAN,
				.data.bool_val = &auto_backup,
			},
			{
				.key = "timestamp",
				.type = CBCC_JSON_DATA_TYPE_INT,
				.data.int_val = &timestamp,
			},
		};
		
		if (cbcc_json_parse_from_buffer(pair->data, ba_each_info_jobjs, CBCC_JOBJS_COUNT(ba_each_info_jobjs)) != 0)
		{
			CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Parsing backup info '%s' has failed", pair->data);
			
			pair = pair->next;
			continue;
		}
		
		// check auto backup flag
		if (!auto_backup)
		{
			pair = pair->next;
			continue;
		}
		
		// set backup info
		strcpy(p[auto_ba_infos_num].guid, pair->key);
		p[auto_ba_infos_num].timestamp = timestamp;
		
		// increase count of auto backup infos
		auto_ba_infos_num++;
		
		pair = pair->next;
	}
	
	// free json pairs
	cbcc_json_free_pairs(&ba_infos);
	
	// set backup infos
	*backup_infos = p;
	
	return auto_ba_infos_num;
}

// get index of timstamp info with minimum value
static int get_lower_val_idx(cbccd_backup_ts_info_t *ts_infos, int count)
{
	int lower_val = ts_infos[0].timestamp;
	int lower_idx = 0;
	
	for (int i = 1; i < count; i++)
	{
		if (lower_val > ts_infos[i].timestamp)
		{
			lower_idx = i;
			lower_val = ts_infos[i].timestamp;
		}
	}
	
	return lower_idx;
}

// remove old auto backup infos
static void remove_old_auto_backup_infos(cbccd_ctx_t *c, const char *dev_guid, cbccd_backup_info_t *backup_infos, int count, int max_keep_backups)
{
	// allocate and initialize ts infos
	cbccd_backup_ts_info_t *ts_infos = (cbccd_backup_ts_info_t *) malloc(max_keep_backups * sizeof(cbccd_backup_ts_info_t));
	memset(ts_infos, 0, max_keep_backups * sizeof(cbccd_backup_ts_info_t));
	
	for (int i = 0; i < count; i++)
	{
		cbccd_backup_info_t *p = &backup_infos[i];
		int lower_ts_idx;
		
		// get index with lower timestamp, i.e. old backup
		lower_ts_idx = get_lower_val_idx(ts_infos, max_keep_backups);
		if (ts_infos[lower_ts_idx].timestamp < p->timestamp)
		{
			// remove backup info
			if (ts_infos[lower_ts_idx].timestamp > 0)
			{
				CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Removing auto backup info '%s' from device '%s' by maximum keep count",
							ts_infos[lower_ts_idx].guid, dev_guid);
				delete_backup_info_from_db(c, dev_guid, ts_infos[lower_ts_idx].guid);
			}
			
			ts_infos[lower_ts_idx].guid = p->guid;
			ts_infos[lower_ts_idx].timestamp = p->timestamp;
		}
		else
		{
			CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Removing auto backup info '%s' from device '%s' by maximum keep count",
							p->guid, dev_guid);
			delete_backup_info_from_db(c, dev_guid, p->guid);
		}
	}
	
	// free timestamps
	free(ts_infos);
	
	return;
}

// remove auto backup infos from backup_info table
static void remove_auto_backup_infos(cbccd_ctx_t *c, int max_keep_backups)
{
	cbccd_tbl_row_t *backup_infos;
	int count;
	
	// get backup_info table data
	int tbl_idx = cbccd_pgsql_get_tbl_idx(CBCCD_TBL_NAME_DEVICE_BACKUP);
	count = cbccd_pgsql_cache_get_tbl_rows(&c->pgsql_mgr, tbl_idx, &backup_infos);
	if (count == 0)
		return;
	
	for (int i = 0; i < count; i++)
	{
		cbccd_backup_info_t *auto_backup_infos = NULL;
		int backup_count;
		
		// get backup infos for device
		backup_count = get_auto_backup_infos(backup_infos[i].data, &auto_backup_infos);
		if (backup_count <= max_keep_backups)
		{
			if (auto_backup_infos)
				free(auto_backup_infos);

			continue;
		}
		
		// remove old backup infos
		remove_old_auto_backup_infos(c, backup_infos[i].guid, auto_backup_infos, backup_count, max_keep_backups);
		
		// free backup infos
		free(auto_backup_infos);
	}
	
	return;
}

// process auto backup
static void *cbccd_admin_auto_backup_proc(void *p)
{
	cbccd_admin_mgr_t *adm_mgr = (cbccd_admin_mgr_t *) p;

	bool first_time = true;
	time_t fetched_tm = time(NULL);
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Starting thread to process auto backup");
	
	while (!adm_mgr->end_flag)
	{
		cbccd_auto_backup_info_t info;
		
		bool must_fetch = false;
		time_t curr_tm = time(NULL);
		
		// check first time
		if (first_time)
			must_fetch = true;
		else
		{
			if ((curr_tm - fetched_tm) > CBCC_ADMIN_DB_FETCH_INTERVAL)
				must_fetch = true;
		}
		
		if (must_fetch)
		{
			first_time = false;
			fetched_tm = curr_tm;
		}
		else
		{
			sleep(1);
			continue;
		}

		// parse auto backup info from database
		memset(&info, 0, sizeof(info));
		if (parse_auto_backup_info_from_db(adm_mgr->c, &info) != 0)
		{
			sleep(1);
			continue;
		}

		// check if auto backup should be taked
		if (!info.take_backup)
		{
			sleep(1);
			continue;
		}
		
		CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Auto backup should be take.");
		
		// send backup command to all devices
		send_backup_cmd_to_devices(adm_mgr->c);
		
		// update auto backup info into database
		update_auto_backup_info(adm_mgr->c, &info);
		
		// remove backup infos by max_keep_backups
		remove_auto_backup_infos(adm_mgr->c, info.max_keep_backups);
		
		sleep(1);
	}
	
	return 0;
}

// check action start time
static void check_act_start_time(cbccd_admin_action_info_t *act_info)
{
	time_t curr_tm = time(NULL);
	
	if (act_info->exec_type == CBCC_EXEC_TYPE_ONCE)
	{
		if (curr_tm > act_info->start_time && curr_tm < (act_info->start_time + CBCC_ADMIN_DB_FETCH_INTERVAL))
		{
			act_info->take_action = true;
			return;
		}
	}
	else
	{
		// get current wday
		struct tm *tm = localtime(&curr_tm);
		for (int i = 0; i < act_info->days.arr_len; i++)
		{
			char date_str[CBCC_MAX_DATE_LEN];
			struct tm tm_day_start;
			
			// check day is hit
			if (tm->tm_wday != act_info->days.data.int_vals[i])
				continue;
			
			// check start time of day is hit
			strftime(date_str, sizeof(date_str), "%Y-%m-%d 00:00:00", tm);
			strptime(date_str, "%Y-%m-%d %H:%M:%S", &tm_day_start);
			
			time_t start = mktime(tm) - mktime(&tm_day_start);
			if (start > act_info->start && start < (act_info->start + CBCC_ADMIN_DB_FETCH_INTERVAL))
			{
				act_info->take_action = true;
				return;
			}
		}
	}
	
	return;
}

// pasre action info
static const char *exec_type_strs[] =
{
	CBCC_EXEC_TYPE_ONCE_STR,
	CBCC_EXEC_TYPE_DAILY_STR,
	NULL
};

static const char *action_type_strs[] =
{
	CBCC_ACTION_TYPE_REBOOT_STR,
	CBCC_ACTION_TYPE_SHUTDOWN_STR,
	CBCC_ACTION_TYPE_PREFETCH_STR,
	CBCC_ACTION_TYPE_FIRMWARE_STR,
	CBCC_ACTION_TYPE_PATTERN_STR,
	NULL
};

static const char *act_status_strs[] =
{
	CBCC_ACT_STATUS_SCHED_STR,
	CBCC_ACT_STATUS_PENDING_STR,
	CBCC_ACT_STATUS_FAILURE_STR,
	CBCC_ACT_STATUS_SUCCESS_STR,
	CBCC_ACT_STATUS_FINISHED_STR,
	NULL
};

static int get_action_status(const char *status)
{
	int i = 0;
	while (act_status_strs[i] != NULL)
	{
		if (strcmp(act_status_strs[i], status) == 0)
			return i;
		
		i++;
	}
	
	return CBCC_ACT_STATUS_UNKNOWN;
}

enum CBCC_EXEC_TYPE get_exec_type(const char *exec_type_str)
{
	int i = 0;
	while (exec_type_strs[i] != NULL)
	{
		if (strcmp(exec_type_strs[i], exec_type_str) == 0)
			return i;
		
		i++;
	}
	
	return CBCC_EXEC_TYPE_UNKNOWN;
}

enum CBCC_ACTION_TYPE get_action_type(const char *act_type_str)
{
	int i = 0;
	while (action_type_strs[i] != NULL)
	{
		if (strcmp(action_type_strs[i], act_type_str) == 0)
			return i;
		
		i++;
	}
	
	return CBCC_ACTION_TYPE_UNKNOWN;
}

static int parse_act_info(const char *act_data, cbccd_admin_action_info_t *act_info)
{
	char act_type_str[CBCC_MAX_ACT_TYPE_LEN];
	char exec_type_str[CBCC_MAX_EXEC_TYPE_LEN];
	
	char status_str[CBCC_MAX_STATUS_LEN];
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_VERBOSE, "ADMIN: Parsing action info '%s'", act_data);
	
	// parse action row
	cbcc_json_object_t act_info_jobjs[] =
	{
		{
			.key = "action",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val = act_type_str,
			.data_size = sizeof(act_type_str)
		},
		{
			.key = "devices",
			.type = CBCC_JSON_DATA_TYPE_OBJ_PAIRS,
			.data.pairs = &act_info->dev_guids,
		},
		{
			.key = "exec",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.parent_key = "schedule",
			.data.str_val = exec_type_str,
			.data_size = sizeof(exec_type_str)
		},
		{
			.key = "days",
			.type = CBCC_JSON_DATA_TYPE_INT_ARRAY,
			.parent_key = "schedule",
			.data.arr_val = &act_info->days,
		},
		{
			.key = "start",
			.type = CBCC_JSON_DATA_TYPE_INT,
			.parent_key = "schedule",
			.data.int_val = &act_info->start,
		},
		{
			.key = "starttime",
			.type = CBCC_JSON_DATA_TYPE_INT,
			.data.int_val = &act_info->start_time,
		},
		{
			.key = "status",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val = status_str,
			.data_size = sizeof(status_str)
		}
	};
	
	if (cbcc_json_parse_from_buffer(act_data, act_info_jobjs, CBCC_JOBJS_COUNT(act_info_jobjs)) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_HIGH, "ADMIN: Could not parse action info '%s'", act_data);
		return -1;
	}

	// get status
	act_info->status_type = get_action_status(status_str);
	if (act_info->status_type == CBCC_ACT_STATUS_UNKNOWN)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Unknown action status '%s'", status_str);
		return -1;
	}
	
	if (act_info->status_type == CBCC_ACT_STATUS_FINISHED)
		return 0;

	// get action type
	act_info->act_type = get_action_type(act_type_str);
	if (act_info->act_type == CBCC_ACTION_TYPE_UNKNOWN)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_HIGH, "ADMIN: Unknown action type '%s'", act_type_str);
		return -1;
	}

	// get exec type
	act_info->exec_type = get_exec_type(exec_type_str);
	if (act_info->exec_type == CBCC_EXEC_TYPE_UNKNOWN)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_HIGH, "ADMIN: Unknown exec type '%s'", exec_type_str);
		return -1;
	}

	// check start time
	check_act_start_time(act_info);
	
	return 0;
}

// set action state into database
static void set_act_status(cbccd_ctx_t *c, const char *act_guid, const char *dev_guid, enum CBCC_ACT_STATUS status)
{
	char *act_json_str = NULL;
	char updated_json_str[CBCC_MAX_COL_DATA_LEN];

	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Setting action status for device '%s' into '%s' with action guid '%s'",
					dev_guid, act_status_strs[status], act_guid);
	
	// get action json string from database by action guid
	int tbl_idx = cbccd_pgsql_get_tbl_idx(CBCCD_TBL_NAME_ACTION_INFO);
	if (cbccd_pgsql_cache_get_tbl_data(&c->pgsql_mgr, tbl_idx, act_guid, &act_json_str) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Could not get action info by action guid '%s'", act_guid);
		return;
	}
	
	// update status for action info
	cbcc_json_object_t act_status_jobjs[] =
	{
		{
			.key = dev_guid,
			.type = CBCC_JSON_DATA_TYPE_OBJECT,
		},
		{
			.key = "status",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.parent_key = dev_guid,
			.data.str_val_set = act_status_strs[status]
		}
	};
	
	if (cbcc_json_update(act_json_str, act_status_jobjs, CBCC_JOBJS_COUNT(act_status_jobjs), updated_json_str, sizeof(updated_json_str)) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Could not update action info '%s'", act_json_str);
	}
	else
	{
		// update database
		cbccd_pgsql_set_guid_tbl_data(&c->pgsql_mgr, CBCC_DB_CONN_TYPE_ADMIN, CBCCD_TBL_NAME_ACTION_INFO, act_guid, updated_json_str);
	}

	// free action string
	if (act_json_str)
		free(act_json_str);
	
	return;
}

// set action final status into database
static void set_act_final_status(cbccd_ctx_t *c, const char *act_guid, enum CBCC_ACT_STATUS status)
{
	char *act_json_str = NULL;
	char updated_json_str[CBCC_MAX_COL_DATA_LEN];
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Setting action final status into '%s' with action guid '%s'", act_status_strs[status], act_guid);
	
	// get action json string from database by action guid
	int tbl_idx = cbccd_pgsql_get_tbl_idx(CBCCD_TBL_NAME_ACTION_INFO);
	if (cbccd_pgsql_cache_get_tbl_data(&c->pgsql_mgr, tbl_idx, act_guid, &act_json_str) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Could not get action info by action guid '%s'", act_guid);
		return;
	}
	
	// update status for action info
	cbcc_json_object_t act_status_jobjs[] =
	{
		{
			.key = "status",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val_set = act_status_strs[status]
		}
	};
	
	if (cbcc_json_update(act_json_str, act_status_jobjs, CBCC_JOBJS_COUNT(act_status_jobjs), updated_json_str, sizeof(updated_json_str)) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Could not update action info");
	}
	else
	{
		// update database
		cbccd_pgsql_set_guid_tbl_data(&c->pgsql_mgr, CBCC_DB_CONN_TYPE_ADMIN, CBCCD_TBL_NAME_ACTION_INFO, act_guid, updated_json_str);
	}

	// free action json string
	if (act_json_str)
		free(act_json_str);
	
	return;
}

// send action command to device
static int send_act_cmd(cbccd_ctx_t *c, const char *dev_guid, const char *act_type_str, const char *act_guid, cbccd_admin_action_info_t *act_info)
{
	char *act_cmd = NULL;
	char act_rand_guid[CBCC_MAX_GUID_LEN];
	
	int ret = CBCC_RESP_OK;
	
	// if action guid is NULL, then create random guid for action
	if (!act_guid)
		create_random_guid(act_rand_guid, sizeof(act_rand_guid));
	
	// build command
	cbcc_json_object_t action_cmd_jobjs[] =
	{
		{
			.key = "cmd",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val_set = CBCC_CMD_ACTION,
		},
		{
			.key = "data",
			.type = CBCC_JSON_DATA_TYPE_OBJECT,
		},
		{
			.key = "guid",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.parent_key = "data",
			.data.str_val_set = act_guid ? act_guid : act_rand_guid,
		},
		{
			.key = "action.types",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.parent_key = "data",
			.data.str_val_set = act_type_str ? act_type_str : action_type_strs[act_info->act_type],
		}
	};
	
	cbcc_json_build(action_cmd_jobjs, CBCC_JOBJS_COUNT(action_cmd_jobjs), &act_cmd);
	
	// send command to each device
	cbccd_device_mutex_lock(&c->device_mgr);
	
	if (dev_guid)
	{
		CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Sending action command to device '%s'", dev_guid);
	
		cbccd_device_info_t *dev = cbccd_device_get_info_by_guid(&c->device_mgr, dev_guid);
		if (!dev)
		{
			CBCC_DEBUG_WARN(CBCC_DEBUG_LEVEL_NOR, "ADMIN: The device '%s' isn't exist in list", dev_guid);
			ret = CBCC_RESP_NOT_CONNECTED;
			goto end;
		}
		
		if (!dev->is_logined)
		{
			CBCC_DEBUG_WARN(CBCC_DEBUG_LEVEL_NOR, "ADMIN: The device '%s' isn't logined yet", dev_guid);
			ret = CBCC_RESP_NOT_LOGINED;
			goto end;
		}
		
		if (cbccd_cmd_send(&c->cmd_mgr, dev->sock, act_cmd) < 0)
		{
			CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Could not send action command to '%s'.", dev_guid);
			ret = CBCC_RESP_SEND_FAILED;
			goto end;
		}
	}
	else
	{
		CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Processing scheduled actions");
	
		cbcc_json_pair_t *p = act_info->dev_guids.pairs;
		while (p)
		{
			cbccd_device_info_t *dev = cbccd_device_get_info_by_guid(&c->device_mgr, p->key);
			if (!dev)
			{
				CBCC_DEBUG_WARN(CBCC_DEBUG_LEVEL_NOR, "ADMIN: The device '%s' isn't exist in list", p->key);
				set_act_status(c, act_guid, p->key, CBCC_ACT_STATUS_FAILURE);
			
				p = p->next;
			
				continue;
			}
		
			// check device has logined
			if (!dev->is_logined)
			{
				CBCC_DEBUG_WARN(CBCC_DEBUG_LEVEL_NOR, "ADMIN: The device '%s' isn't logined yet", p->key);
				set_act_status(c, act_guid, p->key, CBCC_ACT_STATUS_FAILURE);
			
				p = p->next;
			
				continue;
			}

			CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_HIGH, "ADMIN: Sending '%s' command to device '%s'", CBCC_CMD_ACTION, p->key);
		
			// send command
			if (cbccd_cmd_send(&c->cmd_mgr, dev->sock, act_cmd) < 0)
			{
				CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Could not send backup command to '%s'.", p->key);
				set_act_status(c, act_guid, p->key, CBCC_ACT_STATUS_FAILURE);
			}
			else
			{
				set_act_status(c, act_guid, p->key, CBCC_ACT_STATUS_SUCCESS);
			}
		
			p = p->next;
		}
		
		if (act_info->exec_type == CBCC_EXEC_TYPE_ONCE)
			set_act_final_status(c, act_guid, CBCC_ACT_STATUS_FINISHED);
	}
	
end:
	cbccd_device_mutex_unlock(&c->device_mgr);

	// free action command
	free(act_cmd);
	
	return ret;
}

// fetch administrative infos from database
static void admin_fetch_actions_from_db(cbccd_admin_mgr_t *adm_mgr)
{
	cbccd_tbl_row_t *tbl_data = NULL;
	int act_infos_count;
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_VERBOSE, "ADMIN: Fetching action infos from database.");
	
	// get table data from database for administration
	int tbl_idx = cbccd_pgsql_get_tbl_idx(CBCCD_TBL_NAME_ACTION_INFO);
	if ((act_infos_count = cbccd_pgsql_cache_get_tbl_rows(&adm_mgr->c->pgsql_mgr, tbl_idx, &tbl_data)) < 1)
		return;
	
	for (int i = 0; i < act_infos_count; i++)
	{
		cbccd_admin_action_info_t act_info;
		
		// parse action info
		memset(&act_info, 0, sizeof(act_info));
		if (parse_act_info(tbl_data[i].data, &act_info) != 0)
		{
			cbcc_json_free_pairs(&act_info.dev_guids);
			continue;
		}
		
		// check action should be take
		if (!act_info.take_action)
		{
			cbcc_json_free_pairs(&act_info.dev_guids);
			continue;
		}
		
		CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_VERBOSE, "ADMIN: Action '%s' should be taked", tbl_data[i].guid);
		
		// send command to devices
		send_act_cmd(adm_mgr->c, NULL, NULL, tbl_data[i].guid, &act_info);
		
		// free pairs
		cbcc_json_free_pairs(&act_info.dev_guids);
	}
	
	// free table data
	free(tbl_data);
	
	return;
}

// CBCC device administration thread
static void *cbccd_admin_scheduled_proc(void *p)
{
	cbccd_admin_mgr_t *adm_mgr = (cbccd_admin_mgr_t *) p; 

	bool first_time = true;
	time_t fetched_tm = time(NULL);
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Starting scheduled operation thread.");
	
	while (!adm_mgr->end_flag)
	{
		bool must_fetch = false;
		time_t curr_tm = time(NULL);
		
		// check first time
		if (first_time)
		{
			must_fetch = true;
		}
		else
		{
			if ((curr_tm - fetched_tm) > CBCC_ADMIN_DB_FETCH_INTERVAL)
				must_fetch = true;
		}
		
		if (must_fetch)
		{
			first_time = false;
			fetched_tm = curr_tm;
		}
		else
		{
			sleep(1);
			continue;
		}
		
		// fetch administrative info from database
		admin_fetch_actions_from_db(adm_mgr);
	}

	return 0;
}

// action command
int cbccd_admin_send_action_cmd(struct _cbccd_ctx *c, const char *act_str, const char *data)
{
	char guid[CBCC_MAX_GUID_LEN];
	int ret;
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Processing action command");
	
	// parse guid
	cbcc_json_object_t guid_jobjs[] =
	{
		{
			.key = "guid",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.must_specify = true,
			.data.str_val = guid,
			.data_size = sizeof(guid)
		},
	};
	
	if (cbcc_json_parse_from_buffer(data, guid_jobjs, CBCC_JOBJS_COUNT(guid_jobjs)) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Could not parse guid from '%s'", data);
		return CBCC_RESP_JSON_INVALID;
	}
	
	// build action command
	ret = send_act_cmd(c, guid, act_str, NULL, NULL);
	
	return ret;
}

// admin init function
int cbccd_admin_mgr_init(cbccd_ctx_t *c)
{
	cbccd_admin_mgr_t *adm_mgr = &c->admin_mgr;
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Initializing Admin manager");
	
	// set database monitoring interval
	adm_mgr->interval = CBCC_ADMIN_DB_FETCH_INTERVAL;
	
	// set context object
	adm_mgr->c = c;
	
	// create thread to process scheduled actions
	if (pthread_create(&adm_mgr->pt_sched_act, NULL, cbccd_admin_scheduled_proc, (void *) adm_mgr) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Could not start thread to process scheduled operations");
		return -1;
	}

	// create thread to process auto backup
	if (pthread_create(&adm_mgr->pt_auto_backup, NULL, cbccd_admin_auto_backup_proc, (void *) adm_mgr) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Could not start thread to process auto backup");
		return -1;
	}
	
	adm_mgr->init_flag = true;
	
	return 0;
}

// admin finalize function
void cbccd_admin_mgr_finalize(cbccd_admin_mgr_t *adm_mgr)
{
	// check init flag
	if (!adm_mgr->init_flag)
		return;
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "ADMIN: Finalizing admin manager");
	
	// set end flag
	adm_mgr->end_flag = true;
	
	// wait until scheduled operation has finished
	pthread_join(adm_mgr->pt_sched_act, NULL);

	// wait until auto backup processing has finished
	pthread_join(adm_mgr->pt_auto_backup, NULL);
	
	return;
}
