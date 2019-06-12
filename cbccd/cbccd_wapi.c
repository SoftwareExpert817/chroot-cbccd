
#include "cbccd.h"

static void *cbccd_wapi_io(void *p);

// initialize cbccd wapi manager
int cbccd_wapi_mgr_init(struct _cbccd_ctx *c)
{
	cbccd_wapi_mgr_t *wapi_mgr = &c->wapi_mgr;
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "WAPI: Initializing CBCCD WAPI manager.");
	
	// create notify socket
	wapi_mgr->wapi_sock = create_socket();
	if (wapi_mgr->wapi_sock < 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "WAPI: Could not create socket for WAIPI due to %s", strerror(errno));
		return -1;
	}
	
	// set socket as non-blocking mode
	set_non_blocking_sock(wapi_mgr->wapi_sock);
	
	// set listen mode
	if (set_listen_mode(wapi_mgr->wapi_sock, true, CBCCD_WAPI_LISTEN_PORT) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "WAPI: Could not set socket as listen mode due to %s", strerror(errno));
		close(wapi_mgr->wapi_sock);
		
		return -1;
	}
	
	// create thread for notification process
	if (pthread_create(&wapi_mgr->pt_wapi, NULL, cbccd_wapi_io, (void *) wapi_mgr) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "WAPI: Could not create thread for notification due to %s", strerror(errno));
		close(wapi_mgr->wapi_sock);
		
		return -1;
	}
	
	// initialize mutex
	pthread_mutex_init(&wapi_mgr->mt, NULL);
	
	wapi_mgr->c = c;
	wapi_mgr->init_flag = true;
	
	return 0;
}

// finalize cbccd notify manager
void cbccd_wapi_mgr_finalize(cbccd_wapi_mgr_t *wapi_mgr)
{
	// check init flag
	if (!wapi_mgr->init_flag)
		return;
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "WAPI: Finalizing CBCCD WAPI manager.");
	
	// set end flag
	wapi_mgr->end_flag = true;
	
	// wait until I/O thread has finished
	pthread_join(wapi_mgr->pt_wapi, NULL);
	
	// destroy mutex
	pthread_mutex_destroy(&wapi_mgr->mt);
	
	// close notify socket
	close(wapi_mgr->wapi_sock);
	
	return;
}

// process WAPI add request
static int process_wapi_add_req(cbccd_wapi_mgr_t *wapi_mgr, cbccd_wapi_request_t *wapi_req, char **resp_data, bool is_object)
{
	char guid[CBCC_MAX_GUID_LEN];
	char obj_guid[CBCC_MAX_GUID_LEN];

	int ret;

	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_HIGH, "WAPI: Processing adding request '%s' into '%s'", wapi_req->data, wapi_req->type);

	// get table index from type
	wapi_req->tbl_idx = cbccd_pgsql_get_tbl_idx(wapi_req->type);
	if (wapi_req->tbl_idx < 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "WAPI: Unknown WAPI request table name '%s'", wapi_req->type);
		return CBCC_RESP_UNKNOWN_TBL;
	}

	// parse guid
	cbcc_json_object_t wapi_data_jobjs[] =
	{
		{
			.key = "guid",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.must_specify = true,
			.data.str_val = guid,
			.data_size = sizeof(guid)
		}
	};

	if (cbcc_json_parse_from_buffer(wapi_req->data, wapi_data_jobjs, CBCC_JOBJS_COUNT(wapi_data_jobjs)) != 0)
	{
		// create random guid
		create_random_guid(guid, sizeof(guid));
		// CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "WAPI: Could not get guid field from get request '%s'", wapi_req->data);
		// return CBCC_RESP_JSON_INVALID;
	}

	// if config object is added, then make object guid
	if (is_object)
	{
		snprintf(obj_guid, sizeof(obj_guid), "REF_%s", guid);
		ret = cbccd_config_add_object(&wapi_mgr->c->conf_mgr, obj_guid, wapi_req->type, wapi_req->data);
		if (ret != CBCC_RESP_OK)
			return ret;
	}
	else
	{
		// add data into table
		if (cbccd_pgsql_set_guid_tbl_data(&wapi_mgr->c->pgsql_mgr, CBCC_DB_CONN_TYPE_MAIN,
					 wapi_req->type, is_object ? obj_guid : guid, wapi_req->data) != 0)
		{
			CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "WAPI: Could not add data into database");
			return CBCC_RESP_DB_OPER_FAILED;
		}
	}

	// build resp data with created guid
	cbcc_json_object_t resp_jobjs[] =
	{
		{
			.key = "guid",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val_set = is_object ? obj_guid : guid,
		}
	};

	cbcc_json_build(resp_jobjs, CBCC_JOBJS_COUNT(resp_jobjs), resp_data);

	return CBCC_RESP_OK;
}

// process WAPI delete request
static int process_wapi_delete_req(cbccd_wapi_mgr_t *wapi_mgr, cbccd_wapi_request_t *wapi_req, bool is_object)
{
	char guid[CBCC_MAX_GUID_LEN];
	int ret = CBCC_RESP_OK;
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_HIGH, "WAPI: Processing deleting request '%s' from '%s'", wapi_req->data, wapi_req->type);

	// parse guid
	cbcc_json_object_t wapi_data_jobjs[] =
	{
		{
			.key = "guid",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.must_specify = true,
			.data.str_val = guid,
			.data_size = sizeof(guid)
		}
	};

	if (cbcc_json_parse_from_buffer(wapi_req->data, wapi_data_jobjs, CBCC_JOBJS_COUNT(wapi_data_jobjs)) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "WAPI: Could not get guid field from get request '%s'", wapi_req->data);
		return CBCC_RESP_JSON_INVALID;
	}

	// check dependencies when deleting config object
	if (is_object)
	{
		ret = cbccd_config_delete_object(&wapi_mgr->c->conf_mgr, guid, wapi_req->type);
	}
	else
	{
		// remove guid data from db
		cbccd_pgsql_rm_guid_tbl_data(&wapi_mgr->c->pgsql_mgr, CBCC_DB_CONN_TYPE_MAIN, wapi_req->type, guid);
	}

	return ret;
}

// process WAPI edit request
static int process_wapi_edit_req(cbccd_wapi_mgr_t *wapi_mgr, cbccd_wapi_request_t *wapi_req, bool is_object)
{
	char guid[CBCC_MAX_GUID_LEN];
	char data[CBCC_MAX_COL_DATA_LEN];
	
	char *tmp_data;

	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_HIGH, "WAPI: Processing edit request '%s' in '%s'", wapi_req->data, wapi_req->type);

	// get table index from type
	wapi_req->tbl_idx = cbccd_pgsql_get_tbl_idx(wapi_req->type);
	if (wapi_req->tbl_idx < 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "WAPI: Unknown WAPI request table name '%s'", wapi_req->type);
		return CBCC_RESP_UNKNOWN_TBL;
	}

	// parse guid
	cbcc_json_object_t wapi_data_jobjs[] =
	{
		{
			.key = "guid",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.must_specify = true,
			.data.str_val = guid,
			.data_size = sizeof(guid)
		},
		{
			.key = "data",
			.type = CBCC_JSON_DATA_TYPE_OBJECT,
			.obj_exist_data = true,
			.must_specify = true,
			.data.str_val = data,
			.data_size = sizeof(data)
		}
	};

	if (cbcc_json_parse_from_buffer(wapi_req->data, wapi_data_jobjs, CBCC_JOBJS_COUNT(wapi_data_jobjs)) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "WAPI: Could not get guid field from get request '%s'", wapi_req->data);
		return CBCC_RESP_JSON_INVALID;
	}

	if (!is_object)
	{
		// check such guid is exist
		if (cbccd_pgsql_cache_get_tbl_data(&wapi_mgr->c->pgsql_mgr, wapi_req->tbl_idx, guid, &tmp_data) != 0)
		{
			CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "WAPI: Could not found guid '%s' in table '%s'", guid, wapi_req->type);
			return CBCC_RESP_NOT_FOUND_GUID;
		}

		// free data
		free(tmp_data);
		
		// set guid table
		if (cbccd_pgsql_set_guid_tbl_data(&wapi_mgr->c->pgsql_mgr, CBCC_DB_CONN_TYPE_MAIN, wapi_req->type, guid, data) != 0)
		{
			CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "WAPI: Could not add data into database");
			return CBCC_RESP_DB_OPER_FAILED;
		}
	}
	else
	{
		return cbccd_config_edit_object(&wapi_mgr->c->conf_mgr, guid, wapi_req->type, data);
	}

	return CBCC_RESP_OK;
}

// process WAPI get request
static int process_wapi_get_req(cbccd_wapi_mgr_t *wapi_mgr, cbccd_wapi_request_t *wapi_req, char **resp_data)
{
	char guid[CBCC_MAX_GUID_LEN];
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_VERBOSE, "WAPI: Processing getting request '%s' from '%s'", wapi_req->data, wapi_req->type);

	// get table index from type
	wapi_req->tbl_idx = cbccd_pgsql_get_tbl_idx(wapi_req->type);
	if (wapi_req->tbl_idx < 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "WAPI: Unknown WAPI request table name '%s'", wapi_req->type);
		return CBCC_RESP_UNKNOWN_TBL;
	}

	// parse guid
	cbcc_json_object_t wapi_data_jobjs[] =
	{
		{
			.key = "guid",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.must_specify = true,
			.data.str_val = guid,
			.data_size = sizeof(guid)
		}
	};

	if (cbcc_json_parse_from_buffer(wapi_req->data, wapi_data_jobjs, CBCC_JOBJS_COUNT(wapi_data_jobjs)) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "WAPI: Could not get guid field from get request '%s'", wapi_req->data);
		return CBCC_RESP_JSON_INVALID;
	}

	// get data by table name and guid
	if (cbccd_pgsql_cache_get_tbl_data(&wapi_mgr->c->pgsql_mgr, wapi_req->tbl_idx, guid, resp_data) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_VERBOSE, "WAPI: Could not get data from table '%s' by guid '%s'", wapi_req->type, guid);
		return CBCC_RESP_NOT_FOUND_GUID;
	}

	return CBCC_RESP_OK;
}

// process WAPI list request
static int process_wapi_list_req(cbccd_wapi_mgr_t *wapi_mgr, cbccd_wapi_request_t *wapi_req, char **resp_data)
{
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_HIGH, "WAPI: Processing list request in '%s'", wapi_req->type);

	// get table index from type
	wapi_req->tbl_idx = cbccd_pgsql_get_tbl_idx(wapi_req->type);
	if (wapi_req->tbl_idx < 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "WAPI: Unknown WAPI request table name '%s'", wapi_req->type);
		return CBCC_RESP_UNKNOWN_TBL;
	}

	// get list by table name
	cbccd_pgsql_cache_get_tbl_list(&wapi_mgr->c->pgsql_mgr, wapi_req->tbl_idx, resp_data);

	return CBCC_RESP_OK;
}

// process WAPI system action request
static int process_wapi_sysact_req(cbccd_wapi_mgr_t *wapi_mgr, cbccd_wapi_request_t *wapi_req)
{
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_HIGH, "WAPI: Processing sys.action request '%s' for '%s'", wapi_req->data, wapi_req->action);

	// send action command into device with given guid
	return cbccd_admin_send_action_cmd(wapi_mgr->c, wapi_req->action, wapi_req->data);
}

// process WAPI create backup request
static int process_wapi_create_backup_req(cbccd_wapi_mgr_t *wapi_mgr, cbccd_wapi_request_t *wapi_req, char **resp_data)
{
	char dev_guid[CBCC_MAX_GUID_LEN];
	char comment[CBCC_MAX_COMMENT_LEN];
	char user[CBCC_MAX_UNAME_LEN];

	char backup_guid[CBCC_MAX_GUID_LEN];

	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_HIGH, "WAPI: Processing create.backup request '%s'", wapi_req->data);

	// parse create.backup info
	cbcc_json_object_t create_backup_jobjs[] =
	{
		{
			.key = "dev_guid",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val = dev_guid,
			.data_size = sizeof(dev_guid)
		},
		{
			.key = "comment",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val = comment,
			.data_size = sizeof(comment)
		},
		{
			.key = "user",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val = user,
			.data_size = sizeof(user)
		}
	};

	if (cbcc_json_parse_from_buffer(wapi_req->data, create_backup_jobjs, CBCC_JOBJS_COUNT(create_backup_jobjs)) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "WAPI: Parsing create.backup info '%s' has failed.", wapi_req->data);
		return CBCC_RESP_JSON_INVALID;
	}

	// create random guid
	create_random_guid(backup_guid, sizeof(backup_guid));

	// send create.backup command to device
	int ret = cbccd_admin_send_create_backup_cmd(wapi_mgr->c, backup_guid, dev_guid, comment, user);
	if (ret == CBCC_RESP_OK)
	{
		// build json string with backup guid
		cbcc_json_object_t backup_guid_jobjs[] =
		{
			{
				.key = "guid",
				.type = CBCC_JSON_DATA_TYPE_STRING,
				.data.str_val_set = backup_guid,
			}
		};

		cbcc_json_build(backup_guid_jobjs, CBCC_JOBJS_COUNT(backup_guid_jobjs), resp_data);
	}

	return ret;
}

// process WAPI restore backup request
static int process_wapi_restore_backup_req(cbccd_wapi_mgr_t *wapi_mgr, cbccd_wapi_request_t *wapi_req)
{
	char dev_guid[CBCC_MAX_GUID_LEN];
	char backup_guid[CBCC_MAX_GUID_LEN];

	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_HIGH, "WAPI: Processing restore.backup request '%s'", wapi_req->data);

	// parse restore.backup info
	cbcc_json_object_t restore_backup_jobjs[] =
	{
		{
			.key = "dev_guid",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.must_specify = true,
			.data.str_val = dev_guid,
			.data_size = sizeof(dev_guid)
		},
		{
			.key = "backup_guid",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.must_specify = true,
			.data.str_val = backup_guid,
			.data_size = sizeof(backup_guid)
		}
	};

	if (cbcc_json_parse_from_buffer(wapi_req->data, restore_backup_jobjs, CBCC_JOBJS_COUNT(restore_backup_jobjs)) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "WAPI: Parsing restore.backup info '%s' has failed.", wapi_req->data);
		return CBCC_RESP_JSON_INVALID;
	}

	// send restore.backup command to device
	return cbccd_admin_send_restore_backup_cmd(wapi_mgr->c, dev_guid, backup_guid);
}

// process WAPI delete backup request
static int process_wapi_delete_backup_req(cbccd_wapi_mgr_t *wapi_mgr, cbccd_wapi_request_t *wapi_req)
{
	char dev_guid[CBCC_MAX_GUID_LEN];
	char backup_guid[CBCC_MAX_GUID_LEN];

	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_HIGH, "WAPI: Processing delete.backup request '%s'", wapi_req->data);

	// parse delete.backup info
	cbcc_json_object_t delete_backup_jobjs[] =
	{
		{
			.key = "dev_guid",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.must_specify = true,
			.data.str_val = dev_guid,
			.data_size = sizeof(dev_guid)
		},
		{
			.key = "backup_guid",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.must_specify = true,
			.data.str_val = backup_guid,
			.data_size = sizeof(backup_guid)
		}
	};

	if (cbcc_json_parse_from_buffer(wapi_req->data, delete_backup_jobjs, CBCC_JOBJS_COUNT(delete_backup_jobjs)) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "WAPI: Parsing delete.backup info '%s' has failed.", wapi_req->data);
		return CBCC_RESP_JSON_INVALID;
	}

	// delete backup
	cbccd_admin_delete_backup(wapi_mgr->c, backup_guid, dev_guid);

	return CBCC_RESP_OK;
}

// process WAPI list cache request
static int process_wapi_get_cache_req(cbccd_wapi_mgr_t *wapi_mgr, cbccd_wapi_request_t *wapi_req, char **data)
{
	int read_rev;

	//parse revision number
	cbcc_json_object_t rev_num_jobjs[] =
	{
		{
			.key = "rev",
			.type = CBCC_JSON_DATA_TYPE_INT,
			.data.int_val = &read_rev
		}
	};

	if (cbcc_json_parse_from_buffer(wapi_req->data, rev_num_jobjs, CBCC_JOBJS_COUNT(rev_num_jobjs)) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "WAPI: Parsing set_cache info '%s' has failed.", wapi_req->data);
		return CBCC_RESP_JSON_INVALID;
	}

	cbccd_pgsql_get_cache(&wapi_mgr->c->pgsql_mgr, read_rev, data);

	return CBCC_RESP_OK;
}

static int pocess_wapi_get_cache_rev_req(cbccd_wapi_mgr_t *wapi_mgr, char **data)
{
	cbccd_pgsql_get_cache_rev(&wapi_mgr->c->pgsql_mgr, data);
	return CBCC_RESP_OK;
}

// process WAPI create OU request
static int process_wapi_create_ou_req(cbccd_wapi_mgr_t *wapi_mgr, cbccd_wapi_request_t *wapi_req, char **resp_data)
{
	char ou_guid[CBCC_MAX_GUID_LEN];
	char ou_name[CBCC_MAX_OU_NAME_LEN];
	char comment[CBCC_MAX_COMMENT_LEN];

	cbcc_json_array_t dev_guids;

	int ret;

	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_HIGH, "WAPI: Processing create.ou request '%s'", wapi_req->data);

	// parse request data
	cbcc_json_object_t create_ou_jobjs[] =
	{
		{
			.key = "ou_name",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val = ou_name,
			.data_size = sizeof(ou_name)
		},
		{
			.key = "comment",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val = comment,
			.data_size = sizeof(comment)
		},
		{
			.key = "dev_guids",
			.type = CBCC_JSON_DATA_TYPE_STR_ARRAY,
			.data.arr_val = &dev_guids,
		}
	};

	if (cbcc_json_parse_from_buffer(wapi_req->data, create_ou_jobjs, CBCC_JOBJS_COUNT(create_ou_jobjs)) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "WAPI: Could not parse create_ou json object from '%s'", wapi_req->data);
		return CBCC_RESP_JSON_INVALID;
	}

	// create random guid for OU
	create_random_guid(ou_guid, sizeof(ou_guid));

	// create new OU with devices
	ret = cbccd_config_create_ou(&wapi_mgr->c->conf_mgr, ou_guid, ou_name, comment, &dev_guids);
	if (ret == CBCC_RESP_OK)
	{
		// build response data with OU guid
		cbcc_json_object_t resp_jobjs[] =
		{
			{
				.key = "guid",
				.type = CBCC_JSON_DATA_TYPE_STRING,
				.data.str_val_set = ou_guid,
			}
		};

		cbcc_json_build(resp_jobjs, CBCC_JOBJS_COUNT(resp_jobjs), resp_data);
	}

	return ret;
}

// process WAPI edit OU request
static int process_wapi_edit_ou_req(cbccd_wapi_mgr_t *wapi_mgr, cbccd_wapi_request_t *wapi_req)
{
	char ou_guid[CBCC_MAX_GUID_LEN];
	char ou_name[CBCC_MAX_OU_NAME_LEN];
	char comment[CBCC_MAX_COMMENT_LEN];

	cbcc_json_array_t dev_guids;

	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_HIGH, "WAPI: Processing edit.ou request '%s'", wapi_req->data);

	// parse request data
	cbcc_json_object_t edit_ou_jobjs[] =
	{
		{
			.key = "ou_guid",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val = ou_guid,
			.data_size = sizeof(ou_guid)
		},
		{
			.key = "ou_name",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val = ou_name,
			.data_size = sizeof(ou_name)
		},
		{
			.key = "comment",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val = comment,
			.data_size = sizeof(comment)
		},
		{
			.key = "dev_guids",
			.type = CBCC_JSON_DATA_TYPE_STR_ARRAY,
			.data.arr_val = &dev_guids,
		}
	};

	if (cbcc_json_parse_from_buffer(wapi_req->data, edit_ou_jobjs, CBCC_JOBJS_COUNT(edit_ou_jobjs)) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "WAPI: Could not parse edit_ou json object from '%s'", wapi_req->data);
		return CBCC_RESP_JSON_INVALID;
	}

	// create new OU with devices
	return cbccd_config_edit_ou(&wapi_mgr->c->conf_mgr, ou_guid, ou_name, comment, &dev_guids);
}

// process WAPI delete OU request
static int process_wapi_delete_ou_req(cbccd_wapi_mgr_t *wapi_mgr, cbccd_wapi_request_t *wapi_req)
{
	char ou_guid[CBCC_MAX_GUID_LEN];

	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_HIGH, "WAPI: Processing delete.ou request '%s'", wapi_req->data);

	// parse request data
	cbcc_json_object_t delete_ou_jobjs[] =
	{
		{
			.key = "ou_guid",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val = ou_guid,
			.data_size = sizeof(ou_guid)
		},
	};

	if (cbcc_json_parse_from_buffer(wapi_req->data, delete_ou_jobjs, CBCC_JOBJS_COUNT(delete_ou_jobjs)) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "WAPI: Could not parse delete_ou json object from '%s'", wapi_req->data);
		return CBCC_RESP_JSON_INVALID;
	}

	// delete OU
	cbccd_config_delete_ou(&wapi_mgr->c->conf_mgr, ou_guid);

	return CBCC_RESP_OK;
}

// process WAPI set_default_ou request
static int process_wapi_set_default_ou_req(cbccd_wapi_mgr_t *wapi_mgr, cbccd_wapi_request_t *wapi_req)
{
	char ou_guid[CBCC_MAX_GUID_LEN];

	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_HIGH, "WAPI: Processing set_default_ou request '%s'", wapi_req->data);

	// parse request data
	cbcc_json_object_t default_ou_jobjs[] =
	{
		{
			.key = "ou_guid",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val = ou_guid,
			.data_size = sizeof(ou_guid)
		},
	};

	if (cbcc_json_parse_from_buffer(wapi_req->data, default_ou_jobjs, CBCC_JOBJS_COUNT(default_ou_jobjs)) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "WAPI: Could not parse set_default_ou json object from '%s'", wapi_req->data);
		return CBCC_RESP_JSON_INVALID;
	}

	// set OU as default
	return cbccd_config_set_default_ou(&wapi_mgr->c->conf_mgr, ou_guid);
}

// process WAPI disable device request
static int process_wapi_disable_dev_req(cbccd_wapi_mgr_t *wapi_mgr, bool deny, cbccd_wapi_request_t *wapi_req)
{
	char dev_guid[CBCC_MAX_GUID_LEN];

	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_HIGH, "WAPI: Processing disable.dev(deny:%s) request '%s'", deny ? "yes" : "no", wapi_req->data);

	// parse request data
	cbcc_json_object_t delete_dev_jobjs[] =
	{
		{
			.key = "dev_guid",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val = dev_guid,
			.data_size = sizeof(dev_guid)
		},
	};

	if (cbcc_json_parse_from_buffer(wapi_req->data, delete_dev_jobjs, CBCC_JOBJS_COUNT(delete_dev_jobjs)) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "WAPI: Could not parse delete_dev json object from '%s'", wapi_req->data);
		return CBCC_RESP_JSON_INVALID;
	}

	// disable device
	cbccd_device_agent_disable(&wapi_mgr->c->device_mgr, deny, dev_guid);

	return CBCC_RESP_OK;
}

// process WAPI allow device request
static int process_wapi_allow_dev_req(cbccd_wapi_mgr_t *wapi_mgr, cbccd_wapi_request_t *wapi_req)
{
	char dev_guid[CBCC_MAX_GUID_LEN];

	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_HIGH, "WAPI: Processing allow.dev request '%s'", wapi_req->data);

	// parse request data
	cbcc_json_object_t allow_dev_jobjs[] =
	{
		{
			.key = "dev_guid",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val = dev_guid,
			.data_size = sizeof(dev_guid)
		},
	};

	if (cbcc_json_parse_from_buffer(wapi_req->data, allow_dev_jobjs, CBCC_JOBJS_COUNT(allow_dev_jobjs)) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "WAPI: Could not parse delete_dev json object from '%s'", wapi_req->data);
		return CBCC_RESP_JSON_INVALID;
	}

	// allow device
	cbccd_device_agent_allow(&wapi_mgr->c->device_mgr, dev_guid);

	return CBCC_RESP_OK;
}

// process WAPI get web credential request
static int process_wapi_get_web_cred(cbccd_wapi_mgr_t *wapi_mgr, cbccd_wapi_request_t *wapi_req, char **resp_data)
{
	char dev_guid[CBCC_MAX_GUID_LEN];
	int ret;

	char web_cred[CBCC_MAX_HASH_LEN];

	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_HIGH, "WAPI: Processing get_web_cred request '%s'", wapi_req->data);

	// parse request data
	cbcc_json_object_t dev_jobjs[] =
	{
		{
			.key = "dev_guid",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val = dev_guid,
			.data_size = sizeof(dev_guid)
		},
	};

	if (cbcc_json_parse_from_buffer(wapi_req->data, dev_jobjs, CBCC_JOBJS_COUNT(dev_jobjs)) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "WAPI: Could not parse delete_dev json object from '%s'", wapi_req->data);
		return CBCC_RESP_JSON_INVALID;
	}

	// allow device
	ret = cbccd_device_get_webcred(&wapi_mgr->c->device_mgr, dev_guid, web_cred, sizeof(web_cred));
	if (ret == CBCC_RESP_OK)
	{
		// build response data with OU guid
		cbcc_json_object_t resp_jobjs[] =
		{
			{
				.key = "credential",
				.type = CBCC_JSON_DATA_TYPE_STRING,
				.data.str_val_set = web_cred,
			}
		};

		cbcc_json_build(resp_jobjs, CBCC_JOBJS_COUNT(resp_jobjs), resp_data);
	}

	return ret;
}

// send WAPI response
static void send_wapi_response(int sock, int resp_code, const char *resp_data)
{
	char *resp;
	int resp_len;

	// build json string for response
	cbcc_json_object_t resp_jobjs[] =
	{
		{
			.key = "code",
			.type = CBCC_JSON_DATA_TYPE_INT,
			.data.int_val_set = resp_code,
		},
		{
			.key = "data",
			.type = CBCC_JSON_DATA_TYPE_OBJECT,
			.obj_exist_data = resp_data ? true : false,
			.data.str_val_set = resp_data,
		}
	};

	cbcc_json_build(resp_jobjs, CBCC_JOBJS_COUNT(resp_jobjs), &resp);
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_VERBOSE, "WAPI: Sending response '%s'", resp);

	// append '\n'
	resp_len = strlen(resp);
	resp = (char *) realloc(resp, resp_len + 2);
	resp[resp_len] = '\n';
	resp[resp_len + 1] = '\0';

	// send response to client
	if (send(sock, resp, strlen(resp), 0) < 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "WAPI: Could not send response due to '%s'", strerror(errno));
	}
	
	// free response
	free(resp);

	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_VERBOSE, "WAPI: Sent response");

	return;
}

// get WAPI action type
static const char *act_type_strs[] =
{
	"add",
	"delete",
	"edit",
	"get",
	"list",

	"reboot_device",
	"shutdown_device",
	"prefetch_update",
	"install_firmware",
	"install_pattern",

	"create_backup",
	"delete_backup",
	"restore_backup",

	"add_object",
	"delete_object",
	"edit_object",

	"get_cache",
	"get_cache_rev",

	"create_ou",
	"edit_ou",
	"delete_ou",
	"set_default_ou",

	"delete_dev",
	"deny_dev",
	"allow_dev",

	"get_web_cred",

	NULL
};

int get_wapi_act_type(const char *act_str)
{
	for (int i = 0; i < CBCC_WAPI_ACT_UNKNOWN; i++)
	{
		if (act_type_strs[i] == NULL)
			break;

		if (strcmp(act_str, act_type_strs[i]) == 0)
			return i;
	}

	return CBCC_WAPI_ACT_UNKNOWN;
}

// process WAPI requests
static void cbccd_process_wapi_request(cbccd_wapi_mgr_t *wapi_mgr, int sock, const char *wapi_buf)
{
	cbccd_wapi_request_t wapi_req;
	int resp = CBCC_RESP_OK;

	int act_type;
	char *resp_data = NULL;

	// initialize wapi request
	memset(&wapi_req, 0, sizeof(wapi_req));
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_VERBOSE, "WAPI: Received request '%s'", wapi_buf);

	// parse wapi request
	cbcc_json_object_t wapi_req_jobjs[] =
	{
		{
			.key = "action",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val = wapi_req.action,
			.data_size = sizeof(wapi_req.action)
		},
		{
			.key = "type",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val = wapi_req.type,
			.data_size = sizeof(wapi_req.type)
		},
		{
			.key = "data",
			.type = CBCC_JSON_DATA_TYPE_OBJECT_BIG,
			.data.str_val_big = &wapi_req.data,
		}
	};

	if (cbcc_json_parse_from_buffer(wapi_buf, wapi_req_jobjs, CBCC_JOBJS_COUNT(wapi_req_jobjs)) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "WAPI: Unknown WAPI request '%s'", wapi_buf);
		resp = CBCC_RESP_JSON_INVALID;
		goto end;
	}

	// get action type
	act_type = get_wapi_act_type(wapi_req.action);
	if (act_type == CBCC_WAPI_ACT_UNKNOWN)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "WAPI: Unknown WAPI request action '%s'", wapi_req.action);
		resp = CBCC_RESP_UNKNOWN_ACT;
		goto end;
	}

	// process request
	switch (act_type)
	{
		case CBCC_WAPI_ACT_ADD:
			resp = process_wapi_add_req(wapi_mgr, &wapi_req, &resp_data, false);
			break;

		case CBCC_WAPI_ACT_DELETE:
			resp = process_wapi_delete_req(wapi_mgr, &wapi_req, false);
			break;

		case CBCC_WAPI_ACT_EDIT:
			resp = process_wapi_edit_req(wapi_mgr, &wapi_req, false);
			break;

		case CBCC_WAPI_ACT_GET:
			resp = process_wapi_get_req(wapi_mgr, &wapi_req, &resp_data);
			break;

		case CBCC_WAPI_ACT_LIST:
			resp = process_wapi_list_req(wapi_mgr, &wapi_req, &resp_data);
			break;

		case CBCC_WAPI_ACT_REBOOT:
		case CBCC_WAPI_ACT_SHUTDOWN:
		case CBCC_WAPI_ACT_PREFETCH:
		case CBCC_WAPI_ACT_FIRMWARE:
		case CBCC_WAPI_ACT_PATTERN:
			resp = process_wapi_sysact_req(wapi_mgr, &wapi_req);
			break;

		case CBCC_WAPI_ACT_CREATE_BACKUP:
			resp = process_wapi_create_backup_req(wapi_mgr, &wapi_req, &resp_data);
			break;

		case CBCC_WAPI_ACT_DELETE_BACKUP:
			resp = process_wapi_delete_backup_req(wapi_mgr, &wapi_req);
			break;

		case CBCC_WAPI_ACT_RESTORE_BACKUP:
			resp = process_wapi_restore_backup_req(wapi_mgr, &wapi_req);
			break;

		case CBCC_WAPI_ACT_ADD_OBJ:
			resp = process_wapi_add_req(wapi_mgr, &wapi_req, &resp_data, true);
			break;

		case CBCC_WAPI_ACT_DELETE_OBJ:
			resp = process_wapi_delete_req(wapi_mgr, &wapi_req, true);
			break;

		case CBCC_WAPI_ACT_EDIT_OBJ:
			resp = process_wapi_edit_req(wapi_mgr, &wapi_req, true);
			break;

		case CBCC_WAPI_ACT_GET_CACHE:
			resp = process_wapi_get_cache_req(wapi_mgr, &wapi_req, &resp_data);
			break;

		case CBCC_WAPI_ACT_GET_CACHE_REV:
			resp = pocess_wapi_get_cache_rev_req(wapi_mgr, &resp_data);
			break;

		case CBCC_WAPI_ACT_CREATE_OU:
			resp = process_wapi_create_ou_req(wapi_mgr, &wapi_req, &resp_data);
			break;

		case CBCC_WAPI_ACT_EDIT_OU:
			resp = process_wapi_edit_ou_req(wapi_mgr, &wapi_req);
			break;

		case CBCC_WAPI_ACT_DELETE_OU:
			resp = process_wapi_delete_ou_req(wapi_mgr, &wapi_req);
			break;

		case CBCC_WAPI_ACT_SET_DEFAULT_OU:
			resp = process_wapi_set_default_ou_req(wapi_mgr, &wapi_req);
			break;

		case CBCC_WAPI_ACT_DELETE_DEV:
			resp = process_wapi_disable_dev_req(wapi_mgr, false, &wapi_req);
			break;

		case CBCC_WAPI_ACT_DENY_DEV:
			resp = process_wapi_disable_dev_req(wapi_mgr, true, &wapi_req);
			break;

		case CBCC_WAPI_ACT_ALLOW_DEV:
			resp = process_wapi_allow_dev_req(wapi_mgr, &wapi_req);
			break;

		case CBCC_WAPI_GET_WEB_CRED:
			resp = process_wapi_get_web_cred(wapi_mgr, &wapi_req, &resp_data);
			break;

		default:
			break;
	}

end:
	// send response
	send_wapi_response(sock, resp, resp_data);

	// free wapi response data
	if (resp_data)
		free(resp_data);

	return;
}

// remove client socket from list
static void remove_clnt_sock_from_list(int clnt_sock, fd_set *fds, int *max_fd)
{
	// remove socket from list
	FD_CLR(clnt_sock, fds);

	// close socket
	close(clnt_sock);

	// set max socket value
	if (clnt_sock == *max_fd)
		*max_fd = get_max_fd(*max_fd, fds);

	return;
}

// cbccd notify I/O thread
static void *cbccd_wapi_io(void *p)
{
	cbccd_wapi_mgr_t *wapi_mgr = (cbccd_wapi_mgr_t *) p;
	
	fd_set fds;
	int max_fd = wapi_mgr->wapi_sock;
	
	struct timeval tv;
	
	// init socket set
	FD_ZERO(&fds);
	FD_SET(max_fd, &fds);
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "WAPI: Starting CBCCD WAPI I/O thread.");
	
	while (!wapi_mgr->end_flag)
	{
		int i, ret;
		fd_set tmp_fds;
		
		// set timeout value
		tv.tv_sec = 0;
		tv.tv_usec = 50 * 1000;
		
		// copy socket set
		memcpy(&tmp_fds, &fds, sizeof(fd_set));
		
		// async select call
		ret = select(max_fd + 1, &tmp_fds, NULL, NULL, &tv);
		if (ret < 0)
		{
			CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "WAPI: WAIP proc async call failed due to %s", strerror(errno));
			exit(1);
		}
		
		for (i = 0; i <= max_fd; i++)
		{
			if (!FD_ISSET(i, &tmp_fds))
				continue;

			if (i == wapi_mgr->wapi_sock)			// accept call
			{
				int clnt_sock = -1;
				do
				{
					// accept client connection
					clnt_sock = accept(wapi_mgr->wapi_sock, NULL, 0);
					if (clnt_sock < 0 && errno != EWOULDBLOCK)
						break;
					
					// set client socket to fd set
					if (clnt_sock > 0)
					{
						FD_SET(clnt_sock, &fds);
						if (clnt_sock > max_fd)
							max_fd = clnt_sock;
					}
				}
				while (clnt_sock == -1);
			}
			else						// request from clients
			{
				do
				{
					char wapi_buf[CBCC_MAX_CMD_LEN];
					bool failed = false;
					
					// get command buffer from client
					memset(wapi_buf, 0, sizeof(wapi_buf));
					ret = recv(i, wapi_buf, sizeof(wapi_buf), 0);
					if (ret > 0)
					{
						// process command
						cbccd_process_wapi_request(wapi_mgr, i, wapi_buf);

						// close client socket and remove from list
						remove_clnt_sock_from_list(i, &fds, &max_fd);
						
						break;
					}
					else if (ret == 0)				// client disconnected
					{
						failed = true;
					}
					else
					{
						if (errno != EWOULDBLOCK)
							failed = true;
					}
					
					// modify fd set if client has been disconnected
					if (failed)
					{
						// close client socket and remove from list
						remove_clnt_sock_from_list(i, &fds, &max_fd);
						
						break;
					}
				}
				while (1);
			}
		}
	}
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "CMD: Stopped CBCCD WAPI I/O thread.");
	
	return 0;
}
