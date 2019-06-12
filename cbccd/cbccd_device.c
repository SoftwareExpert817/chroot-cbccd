
#include "cbccd.h"

// registration status
static const char *dev_reg_status[] =
{
	CBCCD_DEVICE_REG_STATUS_CONFIRMED_STR,
	CBCCD_DEVICE_REG_STATUS_BLACKLISTED_STR,
	NULL
};

static enum CBCCD_DEVICE_REG_STATUS get_device_reg_status(const char *reg_status_str)
{
	for (unsigned int i = 0; i < CBCCD_DEVICE_REG_STATUS_UNKNOWN; i++)
	{
		if (dev_reg_status[i] == NULL)
			break;

		if (strcmp(reg_status_str, dev_reg_status[i]) == 0)
			return i;
	}
	
	return CBCCD_DEVICE_REG_STATUS_UNKNOWN;
}

// mutex lock
void cbccd_device_mutex_lock(cbccd_device_mgr_t *device_mgr)
{
	pthread_mutex_lock(&device_mgr->mt);
}

// mutex unlock
void cbccd_device_mutex_unlock(cbccd_device_mgr_t *device_mgr)
{
	pthread_mutex_unlock(&device_mgr->mt);
}

// get device info by socket
cbccd_device_info_t *cbccd_device_get_info_by_sock(cbccd_device_mgr_t *device_mgr, int sock)
{
	cbccd_device_info_t *p = device_mgr->device_list.dev_infos;
	while (p)
	{
		if (p->sock == sock)
			return p;
		
		p = p->next;
	}
	
	return NULL;
}

// add device info
static void add_device_info(cbccd_device_mgr_t *device_mgr, cbccd_device_info_t *dev_info)
{
	// add device info to list
	if (device_mgr->device_list.num_of_devices == 0)
	{
		device_mgr->device_list.dev_infos = dev_info;
	}
	else
	{
		cbccd_device_info_t *p = device_mgr->device_list.dev_infos;
		while (p->next)
			p = p->next;
		
		p->next = dev_info;
		dev_info->prev = p;
	}
	
	// increate count of devices
	device_mgr->device_list.num_of_devices++;
	
	return;
}

// parse device info from json string
static int parse_device_reg_info(const char *dev_info_jstr, cbccd_device_info_t *dev_info)
{
	char reg_status[CBCC_MAX_REG_STATUS_LEN];
	
	// parsing registration status
	cbcc_json_object_t dev_info_jobjs[] =
	{
		{
			.key = "registration",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.parent_key = "status",
			.data.str_val = reg_status,
			.data_size = sizeof(reg_status)
		}
	};
	
	if (cbcc_json_parse_from_buffer(dev_info_jstr, dev_info_jobjs, CBCC_JOBJS_COUNT(dev_info_jobjs)) != 0)
		return -1;
	
	// set registration status
	dev_info->reg_status = get_device_reg_status(reg_status);
	if (dev_info->reg_status == CBCCD_DEVICE_REG_STATUS_UNKNOWN)
		dev_info->reg_status = CBCCD_DEVICE_REG_STATUS_CONFIRMED;
	
	return 0;
}

// add device info by device guid
cbccd_device_info_t *add_device_info_by_guid(cbccd_device_mgr_t *device_mgr, const char *dev_guid, const char *dev_info_jstr)
{
	cbccd_device_info_t *device_info;

	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_HIGH, "DEVICE: Adding device info by device guid '%s'", dev_guid);
	
	// allocate memory for device info and set guid
	device_info = (cbccd_device_info_t *) malloc(sizeof(cbccd_device_info_t));
	memset(device_info, 0, sizeof(cbccd_device_info_t));
	
	strcpy(device_info->guid, dev_guid);
	
	// parse device info
	if (parse_device_reg_info(dev_info_jstr, device_info) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "DEVICE: Could not parse device info json string '%s'", dev_info_jstr);
		free(device_info);

		return NULL;
	}
	
	// add device info into list
	add_device_info(device_mgr, device_info);
	
	return device_info;
}

// remove device info
static void remove_device_info(cbccd_device_mgr_t *device_mgr, cbccd_device_info_t *p)
{
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_HIGH, "DEVICE: Removing device '%s'", p->guid);
	
	// check device info is root
	if (device_mgr->device_list.dev_infos == p)
	{
		device_mgr->device_list.dev_infos = p->next;
		
		if (p->next)
			p->next->prev = NULL;
	}
	else
	{
		// set next info pointer
		if (p->prev)
			p->prev->next = p->next;
		if (p->next)
			p->next->prev = p->prev;
	}
	
	// free device info
	free(p);
	
	// decrease count of devices
	device_mgr->device_list.num_of_devices--;
	if (device_mgr->device_list.num_of_devices == 0)
		device_mgr->device_list.dev_infos = NULL;
	
	return;
}

// free device info
static void free_device_info(cbccd_device_info_t *p)
{
	if (!p)
		return;
	
	// free next info
	if (p->next)
		free_device_info(p->next);
		
	// free self
	free(p);
	
	return;
}

// free all device infos
static void free_all_device_infos(cbccd_device_mgr_t *device_mgr)
{
	// check count
	if (device_mgr->device_list.num_of_devices == 0)
		return;
	
	cbccd_device_mutex_lock(device_mgr);
	
	// free device list
	free_device_info(device_mgr->device_list.dev_infos);
	device_mgr->device_list.dev_infos = NULL;
	
	cbccd_device_mutex_unlock(device_mgr);
	
	return;
}

// set OU info for device into database
void set_dev_ou_info(cbccd_device_mgr_t *device_mgr, const char *ou_guid, const char *dev_guid)
{
	char *dev_ou_jstr = NULL;

	// build device OU info json string
	cbcc_json_object_t dev_ou_jobjs[] =
	{
		{
			.key = "ou",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val_set = ou_guid,
		}
	};

	cbcc_json_build(dev_ou_jobjs, CBCC_JOBJS_COUNT(dev_ou_jobjs), &dev_ou_jstr);

	// set device OU info into database
	cbccd_pgsql_set_guid_tbl_data(&device_mgr->c->pgsql_mgr, CBCC_DB_CONN_TYPE_MAIN, CBCCD_TBL_NAME_DEVICE_OU, dev_guid, dev_ou_jstr);

	// free json string
	free(dev_ou_jstr);

	return;
}

// create log objects info
void create_log_objects_info(cbccd_device_mgr_t *device_mgr, const char *guid, const char *dev_info_jstr)
{
	char hname[CBCC_MAX_HNAME_LEN];
	char *log_objdata_jstr;
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "DEVICE: Adding device info with guid '%s' into log_objects table.", guid);
	
	// parse device name json string
	cbcc_json_object_t dev_info_jobjs[] =
	{
		{
			.key = "name",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val = hname,
			.data_size = sizeof(hname)
		}
	};
	
	if (cbcc_json_parse_from_buffer(dev_info_jstr, dev_info_jobjs, CBCC_JOBJS_COUNT(dev_info_jobjs)) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "DEVICE: Could not get hostname from device info json string '%s'", dev_info_jstr);
		return;
	}
	
	// build json string to be added
	cbcc_json_object_t log_objdata_jobjs[] =
	{
		{
			.key = "show",
			.type = CBCC_JSON_DATA_TYPE_INT,
			.data.int_val_set = 1,
		},
		{
			.key = "comment",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val_set = hname,
		},
		{
			.key = "ref",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val_set = guid,
		},
		{
			.key = "name",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val_set = hname,
		},
		{
			.key = "class",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val_set = "devices",
		},
		{
			.key = "type",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val_set = "UTM"
		}
	};
	
	cbcc_json_build(log_objdata_jobjs, CBCC_JOBJS_COUNT(log_objdata_jobjs), &log_objdata_jstr);
	
	// add log object data into log_objects table
	cbccd_pgsql_set_cache(&device_mgr->c->pgsql_mgr, guid, log_objdata_jstr);
	
	// free log object data json string
	free(log_objdata_jstr);
	
	return;
}

// read confd data from confd_data table
static int read_confd_data_from_db(cbccd_device_mgr_t *device_mgr)
{
	cbccd_confd_info_t *confd_info = &device_mgr->confd_info;
	char *confd_data = NULL;
	
	int ret = 0;
	
	// get confd data from cache
	int tbl_idx = cbccd_pgsql_get_tbl_idx(CBCCD_TBL_NAME_CONFD_DATA);
	if (cbccd_pgsql_cache_get_tbl_data(&device_mgr->c->pgsql_mgr, tbl_idx, NULL, &confd_data) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_HIGH, "DEVICE: Could not read confd data from database.");
		return -1;
	}
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_VERBOSE, "DEVICE: confd_data is %s", confd_data);
	
	// parse secret info
	cbcc_json_object_t cbcc_confd_data[] =
	{
		{
			.key = "secret",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val = confd_info->secret_key,
			.data_size = sizeof(confd_info->secret_key)
		},
	};
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_HIGH, "DEVICE: Reading confd_data form database");
	
	// parse confd data
	if (cbcc_json_parse_from_buffer(confd_data, cbcc_confd_data, CBCC_JOBJS_COUNT(cbcc_confd_data)) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_HIGH, "DEVICE: Could not parse confd data.");
		ret = -1;
	}
	
	// free confd data
	if (confd_data)
		free(confd_data);
	
	return ret;
}

// get role type
static int get_role_type(const char *dev_info_jstr)
{
	cbcc_json_array_t arr_roles;
	int role_type = 0;
	
	// get role types from device info
	cbcc_json_object_t roles_obj[] =
	{
		{
			.key = "roles",
			.type = CBCC_JSON_DATA_TYPE_STR_ARRAY,
			.data.arr_val = &arr_roles,
		}
	};
	
	if (cbcc_json_parse_from_buffer(dev_info_jstr, roles_obj, CBCC_JOBJS_COUNT(roles_obj)) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "DEVICE: Could not get roles object from device.info");
		return 0;
	}
	
	// set device role
	for (int i = 0; i < arr_roles.arr_len; i++)
	{
		if (strcmp(arr_roles.data.str_vals[i], CBCCD_DEVICE_ROLE_ADMIN_STR) == 0)
			role_type |= CBCCD_DEVICE_ROLE_ADMIN;
		else if (strcmp(arr_roles.data.str_vals[i], CBCCD_DEVICE_ROLE_REPORT_STR) == 0)
			role_type |= CBCCD_DEVICE_ROLE_REPORT;
		else if (strcmp(arr_roles.data.str_vals[i], CBCCD_DEVICE_ROLE_CONFIG_STR) == 0)
			role_type |= CBCCD_DEVICE_ROLE_CONFIG;
		else if (strcmp(arr_roles.data.str_vals[i], CBCCD_DEVICE_ROLE_MONITOR_STR) == 0)
			role_type |= CBCCD_DEVICE_ROLE_MONITOR;
	}
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_VERBOSE, "DEVICE: The role of device '%d'", role_type);
	
	return role_type;
}

// set device status
static void set_device_status(cbccd_device_mgr_t *device_mgr, cbccd_device_info_t *device_info,  const char *dev_info_jstr)
{
	char updated_str[CBCC_MAX_COL_DATA_LEN];
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "DEVICE: Setting device status with guid '%s' into ONLINE", device_info->guid);

	char *pre_info_jstr = NULL;
	int tbl_idx = cbccd_pgsql_get_tbl_idx(CBCCD_TBL_NAME_DEVICE_INFO);
	if (cbccd_pgsql_cache_get_tbl_data(&device_mgr->c->pgsql_mgr, tbl_idx, device_info->guid, &pre_info_jstr) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "DEVICE: Could not get device info from database by guid %s", device_info->guid);
		cbccd_pgsql_set_guid_tbl_data(&device_mgr->c->pgsql_mgr, CBCC_DB_CONN_TYPE_MAIN, CBCCD_TBL_NAME_DEVICE_INFO, device_info->guid, dev_info_jstr);
		return;
	}

	// update device status into online
	cbcc_json_object_t status_objs[] =
	{
		{
			.key = "ipv4_public",
			.parent_key = "address",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val_set = device_info->device_ipaddr,
		},
		{
			.key = "connection",
			.parent_key = "status",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val_set = CBCCD_DEVICE_CONN_STATUS_ONLINE_STR,
		},
		{
			.key = "registration",
			.parent_key = "status",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val_set = CBCCD_DEVICE_REG_STATUS_CONFIRMED_STR,
		},
		{
			.key = "device",
			.parent_key = "status",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val_set = "PINGABLE",
		},
		{
			.key = "timestamp",
			.parent_key = "status",
			.type = CBCC_JSON_DATA_TYPE_INT,
			.data.int_val_set = time(NULL),
		},
	};
	
	if (cbcc_json_update(pre_info_jstr, status_objs, CBCC_JOBJS_COUNT(status_objs), updated_str, sizeof(updated_str)) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_HIGH, "DEVICE: Could not update device status JSON string.");
		return;
	}

	cbccd_pgsql_set_guid_tbl_data(&device_mgr->c->pgsql_mgr, CBCC_DB_CONN_TYPE_MAIN, CBCCD_TBL_NAME_DEVICE_INFO, device_info->guid, updated_str);
	
	return;
}

// client login proc
int cbccd_device_login(cbccd_device_mgr_t *device_mgr, int sock, const char *login_cmd_buffer)
{
	char guid[CBCC_MAX_GUID_LEN];
	char secret_key[CBCC_MAX_SECRET_LEN];
	char web_login_cred[CBCC_MAX_HASH_LEN];
	
	char dev_info_jstr[CBCC_MAX_JSON_DATA_LEN];
	
	const char *device_ipaddr = cbccd_cmd_get_ipaddr_by_sock(&device_mgr->c->cmd_mgr, sock);
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "DEVICE: Checking login info from device with IP address '%s' from buffer '%s'",
						device_ipaddr, login_cmd_buffer);
	
	cbcc_json_object_t cbcc_login_objs[] =
	{
		{
			.key = "guid",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val = guid,
			.data_size = sizeof(guid)
		},
		{
			.key = "secret",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val = secret_key,
			.data_size = sizeof(secret_key)
		},
		{
			.key = "password",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val = web_login_cred,
			.data_size = sizeof(web_login_cred)
		},
		{
			.key = "device.info",
			.type = CBCC_JSON_DATA_TYPE_OBJECT,
			.data.str_val = dev_info_jstr,
			.data_size = sizeof(dev_info_jstr)
		},
	};
	
	// parse login command buffer
	if (cbcc_json_parse_from_buffer(login_cmd_buffer, cbcc_login_objs, CBCC_JOBJS_COUNT(cbcc_login_objs)) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "DEVICE: Parsing login buffer '%s' has failed.", login_cmd_buffer);
		return CBCC_RESP_JSON_INVALID;
	}
	
	// check secret key
	if (strcmp(secret_key, device_mgr->confd_info.secret_key) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "DEVICE: Authentication with secret key has failed.");
		return CBCC_RESP_SECRET_MISMATCHED;
	}
	
	// get device info by guid
	cbccd_device_info_t *device_info = cbccd_device_get_info_by_guid(device_mgr, guid);
	if (device_info)
	{
		// set socket descriptor
		device_info->sock = sock;
	
		// check device is in blacklist
		if (device_info->reg_status == CBCCD_DEVICE_REG_STATUS_BLACKLISTED)
		{
			CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "DEVICE: The device '%s' is in blacklist. Login will be dropped", guid);
			return CBCC_RESP_DEVICE_IN_BLACKLIST;
		}
	}
	else
	{
		// mutex lock
		cbccd_device_mutex_lock(device_mgr);
		device_info = add_device_info_by_guid(device_mgr, guid, dev_info_jstr);
		cbccd_device_mutex_unlock(device_mgr);

		if (!device_info)
		{
			CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "DEVICE: Could not add device info by guid '%s'", guid);
			return CBCC_RESP_JSON_INVALID;
		}
		
		// create info into log_objects table
		create_log_objects_info(device_mgr, guid, dev_info_jstr);

		// set socket descriptor
		device_info->sock = sock;

		// create OU info for device
		cbcc_config_ou_info_t *default_ou = cbccd_config_get_default_ou(&device_mgr->c->conf_mgr);
		if (default_ou)
		{
			set_dev_ou_info(device_mgr, default_ou->ou_guid, guid);
		}
	}

	// set ip address
	snprintf(device_info->device_ipaddr, sizeof(device_info->device_ipaddr), "%s", device_ipaddr);
	
	// set web login credential info
	snprintf(device_info->web_login_cred, sizeof(device_info->web_login_cred), "%s", web_login_cred);

	// get role type of device
	device_info->role_type = get_role_type(dev_info_jstr);
	
	// set device info
	set_device_status(device_mgr, device_info, dev_info_jstr);
	
	// set login flag
	device_info->updated_tm = time(NULL);
	device_info->conn_status = CBCCD_DEVICE_CONN_STATUS_ONLINE;
	device_info->is_logined = true;
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "DEVICE: Device with guid '%s' has logined successfully", guid);
	
	return CBCC_RESP_OK;
}

// update device status
void cbccd_device_update_status(cbccd_device_mgr_t *device_mgr, int sock)
{
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_VERBOSE, "DEVICE: Updating device timestamp from socket '%d'", sock);
	
	// get device info by socket
	cbccd_device_info_t *dev_info = cbccd_device_get_info_by_sock(device_mgr, sock);
	if (!dev_info)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "DEVICE: Could not get device info by socket '%d'", sock);
		return;
	}
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_VERBOSE, "DEVICE: Updating status of device '%s'", dev_info->guid);
	
	dev_info->updated_tm = time(NULL);
	return;
}

// set device status into offline
void cbccd_device_set_offline(cbccd_device_mgr_t *device_mgr, int sock, bool expired)
{
	char *device_info_jstr = NULL;
	char updated_info_jstr[CBCC_MAX_COL_DATA_LEN];

	// get device info by socket
	cbccd_device_info_t *device_info = cbccd_device_get_info_by_sock(device_mgr, sock);
	if (!device_info)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "DEVICE: Could not found device info by socket '%d'", sock);
		return;
	}
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "DEVICE: Setting the status of device '%s' into OFFLINE", device_info->guid);
	
	// set connection state
	device_info->sock = -1;
	
	device_info->conn_status = CBCCD_DEVICE_CONN_STATUS_OFFLINE;
	device_info->is_logined = false;
	
	// get device info json string from database
	int tbl_idx = cbccd_pgsql_get_tbl_idx(CBCCD_TBL_NAME_DEVICE_INFO);
	if (cbccd_pgsql_cache_get_tbl_data(&device_mgr->c->pgsql_mgr, tbl_idx, device_info->guid, &device_info_jstr) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "DEVICE: Could not get device info from database by guid %s", device_info->guid);
		return;
	}
	
	// set status into offline
	cbcc_json_object_t dev_status_jobjs[] =
	{
		{
			.key = "connection",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.parent_key = "status",
			.data.str_val_set = CBCCD_DEVICE_CONN_STATUS_OFFLINE_STR,
		},
		{
			.key = "timestamp",
			.type = CBCC_JSON_DATA_TYPE_INT,
			.parent_key = "status",
			.data.int_val_set = expired ? device_info->updated_tm : time(NULL),
		}
	};
	
	if (cbcc_json_update(device_info_jstr, dev_status_jobjs, CBCC_JOBJS_COUNT(dev_status_jobjs), updated_info_jstr, sizeof(updated_info_jstr)) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "DEVICE: Could not device status into OFFLINE by guid '%s'", device_info->guid);
	}
	else
	{
		// update database
		cbccd_pgsql_set_guid_tbl_data(&device_mgr->c->pgsql_mgr, CBCC_DB_CONN_TYPE_MAIN, CBCCD_TBL_NAME_DEVICE_INFO, device_info->guid, updated_info_jstr);
	}
	
	// free device info buffer
	if (device_info_jstr)
		free(device_info_jstr);
	
	return;
}

// get device info by guid
cbccd_device_info_t *cbccd_device_get_info_by_guid(cbccd_device_mgr_t *device_mgr, const char *guid)
{
	cbccd_device_info_t *p = device_mgr->device_list.dev_infos;
	while (p)
	{
		if (strcmp(p->guid, guid) == 0)
		{
			return p;
		}
		
		p = p->next;
	}
	
	return NULL;
}

// get web credential info
int cbccd_device_get_webcred(cbccd_device_mgr_t *device_mgr, const char *dev_guid, char *web_cred, size_t s)
{
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "DEVICE: Getting web login credential of device '%s'", dev_guid);

	// lock device manager
	cbccd_device_mutex_lock(device_mgr);
	
	// get device info by guid
	cbccd_device_info_t *dev = cbccd_device_get_info_by_guid(device_mgr, dev_guid);
	if (!dev)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "DEVICE: Could not get device info by guid '%s'", dev_guid);
		cbccd_device_mutex_unlock(device_mgr);
		return CBCC_RESP_NOT_CONNECTED;
	}
	
	// check login flag
	if (!dev->is_logined)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "DEVICE: Device '%s' isn't yet logined", dev_guid);
		cbccd_device_mutex_unlock(device_mgr);
		return CBCC_RESP_NOT_LOGINED;
	}
	
	// set credential info as response data
	snprintf(web_cred, s, "%s", dev->web_login_cred);

	// unlock device manager
	cbccd_device_mutex_unlock(device_mgr);
	
	return CBCC_RESP_OK;
}

// read device infos from database
static void read_device_infos_from_db(cbccd_device_mgr_t *device_mgr)
{
	cbccd_tbl_row_t *device_infos;
	int device_infos_count;
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "DEVICE: Reading device infos from database.");
	
	// get device infos from device_info table
	int tbl_idx = cbccd_pgsql_get_tbl_idx(CBCCD_TBL_NAME_DEVICE_INFO);
	device_infos_count = cbccd_pgsql_cache_get_tbl_rows(&device_mgr->c->pgsql_mgr, tbl_idx, &device_infos);
	if (device_infos_count == 0)
		return;
	
	// add device info by guid
	for (int i = 0; i < device_infos_count; i++)
	{
		char updated_data[CBCC_MAX_COL_DATA_LEN];
		
		cbccd_tbl_row_t *p = &device_infos[i];
		if (!add_device_info_by_guid(device_mgr, p->guid, p->data))
		{
			CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "DEVICE: Could not add device info by device guid'%s'", p->guid);
		}
		
		// set offline status
		cbcc_json_object_t dev_status_jobjs[] =
		{
			{
				.key = "connection",
				.type = CBCC_JSON_DATA_TYPE_STRING,
				.parent_key = "status",
				.data.str_val_set = CBCCD_DEVICE_CONN_STATUS_OFFLINE_STR,
			}
		};
		
		cbcc_json_update(p->data, dev_status_jobjs, CBCC_JOBJS_COUNT(dev_status_jobjs), updated_data, sizeof(updated_data));
		
		// set device info into db
		cbccd_pgsql_set_guid_tbl_data(&device_mgr->c->pgsql_mgr, CBCC_DB_CONN_TYPE_MAIN, CBCCD_TBL_NAME_DEVICE_INFO, p->guid, updated_data);
	}
	
	// free device info
	free(device_infos);
	
	return;
}

// read device OU infos from database
static void read_device_ou_infos_from_db(cbccd_device_mgr_t *device_mgr)
{
	cbccd_tbl_row_t *dev_ou_rows = NULL;
	int rows_count;

	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "DEVICE: Reading device OU infos from database");

	// read device OU infos from database
	int tbl_idx = cbccd_pgsql_get_tbl_idx(CBCCD_TBL_NAME_DEVICE_OU);
	rows_count = cbccd_pgsql_cache_get_tbl_rows(&device_mgr->c->pgsql_mgr, tbl_idx, &dev_ou_rows);
	if (rows_count < 1)
		return;

	for (int dev_ou_idx = 0; dev_ou_idx < rows_count; dev_ou_idx++)
	{
		char ou_guid[CBCC_MAX_GUID_LEN];

		// parse device OU info
		cbcc_json_object_t dev_ou_jobjs[] =
		{
			{
				.key = "ou",
				.type = CBCC_JSON_DATA_TYPE_STRING,
				.must_specify = true,
				.data.str_val = ou_guid,
				.data_size = sizeof(ou_guid)
			}
		};

		if (cbcc_json_parse_from_buffer(dev_ou_rows[dev_ou_idx].data, dev_ou_jobjs, CBCC_JOBJS_COUNT(dev_ou_jobjs)) != 0)
		{
			CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "DEVICE: Could not parse device OU info '%s'", dev_ou_rows[dev_ou_idx].data);
			continue;
		}

		// get device info by guid
		cbccd_device_info_t *dev_info = cbccd_device_get_info_by_guid(device_mgr, dev_ou_rows[dev_ou_idx].guid);
		if (!dev_info)
		{
			CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "DEVICE: Could not get device info by device guid '%s'", dev_ou_rows[dev_ou_idx].guid);
			continue;
		}

		// get OU info by OU guid
		cbcc_config_ou_info_t *ou_info = cbccd_config_get_ou_by_guid(&device_mgr->c->conf_mgr, ou_guid);
		if (!ou_info)
		{
			CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "DEVICE: Could not get OU info by OU guid '%s'", ou_guid);
			continue;
		}

		CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "DEVICE: Adding device '%s' into OU '%s'", dev_info->guid, ou_info->ou_guid);

		// set ou info
		dev_info->ou_info = ou_info;
	}

	// free device OU rows
	free(dev_ou_rows);

	return;
}

// set registration status into database
static void set_reg_status_into_db(cbccd_device_mgr_t *device_mgr, cbccd_device_info_t *device_info)
{
	char *dev_info_jstr = NULL;
	char updated_info_jstr[CBCC_MAX_COL_DATA_LEN];
	
	// get device info data
	int tbl_idx = cbccd_pgsql_get_tbl_idx(CBCCD_TBL_NAME_DEVICE_INFO);
	if (cbccd_pgsql_cache_get_tbl_data(&device_mgr->c->pgsql_mgr, tbl_idx, device_info->guid, &dev_info_jstr) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "DEVICE: Could not get device info by guid '%s' from database", device_info->guid);
		return;
	}
	
	// update json object
	cbcc_json_object_t reg_status_jobjs[] =
	{
		{
			.key = "registration",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.parent_key = "status",
			.data.str_val_set = (device_info->reg_status == CBCCD_DEVICE_REG_STATUS_BLACKLISTED) ? CBCCD_DEVICE_REG_STATUS_BLACKLISTED_STR :
						CBCCD_DEVICE_REG_STATUS_CONFIRMED_STR,
		}
	};
	
	cbcc_json_update(dev_info_jstr, reg_status_jobjs, CBCC_JOBJS_COUNT(reg_status_jobjs), updated_info_jstr, sizeof(updated_info_jstr));
	
	// set device info
	cbccd_pgsql_set_guid_tbl_data(&device_mgr->c->pgsql_mgr, CBCC_DB_CONN_TYPE_MAIN, CBCCD_TBL_NAME_DEVICE_INFO, device_info->guid, updated_info_jstr);
	
	// free device info buffer
	free(dev_info_jstr);
	
	return;
}

// disable agent
int cbccd_device_agent_disable(cbccd_device_mgr_t *device_mgr, bool deny, const char *dev_guid)
{
	cbccd_device_info_t *device_info;

	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "DEVICE: %s device '%s'", deny ? "Deny" : "Delete", dev_guid);
	
	// lock device manager
	cbccd_device_mutex_lock(device_mgr);
	// get agent info
	device_info = cbccd_device_get_info_by_guid(device_mgr, dev_guid);
	if (!device_info)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "DEVICE: Could not found device info by guid '%s'", dev_guid);

		cbccd_device_mutex_unlock(device_mgr);
		return CBCC_RESP_NOT_CONNECTED;
	}

	// deny or remove device
	if (deny)
	{
		// check login status
		if (device_info->is_logined)
		{
			char *cmd = NULL;
			
			// build command
			cbcc_json_object_t cmd_jobjs[] =
			{
				{
					.key = "cmd",
					.type = CBCC_JSON_DATA_TYPE_STRING,
					.data.str_val_set = CBCC_CMD_AGENT_DISABLE,
				}
			};
			
			cbcc_json_build(cmd_jobjs, CBCC_JOBJS_COUNT(cmd_jobjs), &cmd);
	
			// send command to agent if device will be denied
			CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "DEVICE: Sending command '%s' to device '%s'", CBCC_CMD_AGENT_DISABLE, device_info->guid);
			
			cbccd_cmd_send(&device_mgr->c->cmd_mgr, device_info->sock, cmd);
			
			// free command buffer
			free(cmd);
		}
		
		// set registration status
		device_info->reg_status = CBCCD_DEVICE_REG_STATUS_BLACKLISTED;
			
		// set registration status into database
		set_reg_status_into_db(device_mgr, device_info);
	}
	else
	{
		// remove device info from database
		cbccd_pgsql_rm_guid_tbl_data(&device_mgr->c->pgsql_mgr, CBCC_DB_CONN_TYPE_MAIN, CBCCD_TBL_NAME_DEVICE_INFO, device_info->guid);
		// free client socket
		cbccd_cmd_free_socket(&device_mgr->c->cmd_mgr, device_info->sock);
		// remove device info
		remove_device_info(device_mgr, device_info);
		// remove device monitoring info
		cbccd_mon_remove_data(device_mgr->c, dev_guid);
		// remove device OU info
		cbccd_pgsql_rm_guid_tbl_data(&device_mgr->c->pgsql_mgr, CBCC_DB_CONN_TYPE_MAIN, CBCCD_TBL_NAME_DEVICE_OU, dev_guid);
		cbccd_pgsql_rm_guid_tbl_data(&device_mgr->c->pgsql_mgr, CBCC_DB_CONN_TYPE_MAIN, CBCCD_TBL_NAME_MON_DASH, dev_guid);
		cbccd_pgsql_rm_guid_tbl_data(&device_mgr->c->pgsql_mgr, CBCC_DB_CONN_TYPE_MAIN, CBCCD_TBL_NAME_MON_AVAIL, dev_guid);
		cbccd_pgsql_rm_guid_tbl_data(&device_mgr->c->pgsql_mgr, CBCC_DB_CONN_TYPE_MAIN, CBCCD_TBL_NAME_MON_HW, dev_guid);
		cbccd_pgsql_rm_guid_tbl_data(&device_mgr->c->pgsql_mgr, CBCC_DB_CONN_TYPE_MAIN, CBCCD_TBL_NAME_MON_LIC, dev_guid);
		cbccd_pgsql_rm_guid_tbl_data(&device_mgr->c->pgsql_mgr, CBCC_DB_CONN_TYPE_MAIN, CBCCD_TBL_NAME_MON_NET, dev_guid);
		cbccd_pgsql_rm_guid_tbl_data(&device_mgr->c->pgsql_mgr, CBCC_DB_CONN_TYPE_MAIN, CBCCD_TBL_NAME_MON_RES, dev_guid);
		cbccd_pgsql_rm_guid_tbl_data(&device_mgr->c->pgsql_mgr, CBCC_DB_CONN_TYPE_MAIN, CBCCD_TBL_NAME_NON_THREAT, dev_guid);
		cbccd_pgsql_rm_guid_tbl_data(&device_mgr->c->pgsql_mgr, CBCC_DB_CONN_TYPE_MAIN, CBCCD_TBL_NAME_MON_VER, dev_guid);
		cbccd_pgsql_rm_guid_tbl_data(&device_mgr->c->pgsql_mgr, CBCC_DB_CONN_TYPE_MAIN, CBCCD_TBL_NAME_MON_SRV, dev_guid);
		cbccd_pgsql_rm_guid_tbl_data(&device_mgr->c->pgsql_mgr, CBCC_DB_CONN_TYPE_MAIN, CBCCD_TBL_NAME_CONFIG_COMMON, dev_guid);
		cbccd_pgsql_rm_guid_tbl_data(&device_mgr->c->pgsql_mgr, CBCC_DB_CONN_TYPE_MAIN, CBCCD_TBL_NAME_DEVICE_INVENTORY, dev_guid);
		cbccd_pgsql_rm_guid_tbl_data(&device_mgr->c->pgsql_mgr, CBCC_DB_CONN_TYPE_MAIN, CBCCD_TBL_NAME_DEVICE_PRODUCT, dev_guid);
		// delete device backup info
		cbccd_admin_delete_all_backups(device_mgr->c, dev_guid);
		// delete reporting info
		cbccd_report_delete_data(device_mgr->c, dev_guid);
	}

	// unlock device manager
	cbccd_device_mutex_unlock(device_mgr);

	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "DEVICE: %s device '%s' has succeeded", deny ? "Deny" : "Delete", dev_guid);

	return CBCC_RESP_OK;
}

// allow agent
int cbccd_device_agent_allow(cbccd_device_mgr_t *device_mgr, const char *dev_guid)
{
	cbccd_device_info_t *device_info;

	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "DEVICE: Allow device '%s'.", dev_guid);

	// lock device manager
	cbccd_device_mutex_lock(device_mgr);
	
	// get agent info
	device_info = cbccd_device_get_info_by_guid(device_mgr, dev_guid);
	if (!device_info)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "DEVICE: Could not found device info by guid '%s'", dev_guid);

		cbccd_device_mutex_unlock(device_mgr);
		return CBCC_RESP_NOT_CONNECTED;
	}
		
	// set registration status
	device_info->reg_status = CBCCD_DEVICE_REG_STATUS_CONFIRMED;
			
	// set registration status into database
	set_reg_status_into_db(device_mgr, device_info);

	// unlock device manager
	cbccd_device_mutex_unlock(device_mgr);
	
	return CBCC_RESP_OK;
}

// set OU info
void cbccd_device_set_ou_info(cbccd_device_mgr_t *device_mgr, const char *dev_guid, cbcc_config_ou_info_t *ou_info)
{
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "DEVICE: Adding device '%s' into OU '%s'", dev_guid, ou_info->ou_name);

	// get device info by guid
	cbccd_device_info_t *dev_info = cbccd_device_get_info_by_guid(device_mgr, dev_guid);
	if (!dev_info)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "DEVICE: Could not found device info by guid '%s'", dev_guid);
		return;
	}

	// set OU info
	dev_info->ou_info = ou_info;

	// set ou info into database
	set_dev_ou_info(device_mgr, ou_info->ou_guid, dev_info->guid);

	return;
}

// send keepalive command
static void check_keepalive_status(cbccd_device_mgr_t *device_mgr, time_t curr_tm)
{
	cbccd_device_mutex_lock(device_mgr);
	
	cbccd_device_info_t *dev_info = device_mgr->device_list.dev_infos;
	while (dev_info)
	{
		// check login flag
		if (!dev_info->is_logined)
		{
			dev_info = dev_info->next;
			continue;
		}
		
		// check updated time is expired
		if ((curr_tm - dev_info->updated_tm) > (CBCC_KEEPALIVE_INTERVAL + 5))
		{
			CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "DEVICE: Updated status of device '%s' is expired.", dev_info->guid);
			
			// free client socket
			cbccd_cmd_free_socket(&device_mgr->c->cmd_mgr, dev_info->sock);
			
			// set device status into offline
			cbccd_device_set_offline(device_mgr, dev_info->sock, true);
		}
		
		dev_info = dev_info->next;
	}
	
	cbccd_device_mutex_unlock(device_mgr);
	
	return;
}

// keepalive proc
static void *keepalive_check_proc(void *p)
{
	cbccd_device_mgr_t *device_mgr = (cbccd_device_mgr_t *) p;
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "DEVICE: Started checking keepalive status proc");
	
	while (!device_mgr->end_flag)
	{
		time_t curr_tm = time(NULL);
		
		check_keepalive_status(device_mgr, curr_tm);
		sleep(5);
	}
	
	CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "DEVICE: Stopped keepalive proc");
	
	return 0;
}

// initialize device manager
int cbccd_device_mgr_init(struct _cbccd_ctx *c)
{
	cbccd_device_mgr_t *device_mgr = &c->device_mgr;
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "DEVICE: Initializing device manager.");
	
	// set context info
	device_mgr->c = c;
	
	// initialize mutex for device manager
	pthread_mutex_init(&device_mgr->mt, NULL);
	
	// read confd data from database
	read_confd_data_from_db(device_mgr);
	
	// read device info from database
	read_device_infos_from_db(device_mgr);

	// read device OU infos from database
	read_device_ou_infos_from_db(device_mgr);

	// create thread to check keepalive status
	if (pthread_create(&device_mgr->pt_keepalive, NULL, keepalive_check_proc, (void *) device_mgr) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "DEVICE: Could not create thread to check keepalive status");
		free_all_device_infos(device_mgr);

		return -1;
	}
	
	// set init flag
	device_mgr->init_flag = true;
	
	return 0;
}

// finalize device manager
void cbccd_device_mgr_finalize(cbccd_device_mgr_t *device_mgr)
{
	// check init flag
	if (!device_mgr->init_flag)
		return;
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "CLIENT: Finalizing client manager.");
	
	// set end flag
	device_mgr->end_flag = true;
	
	// wait until keepalive proc has finished
	pthread_join(device_mgr->pt_keepalive, NULL);
	
	// free all device infos
	free_all_device_infos(device_mgr);
	
	// destroy mutex
	pthread_mutex_destroy(&device_mgr->mt);
	
	return;
}
