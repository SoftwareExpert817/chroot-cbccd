
#include "cbccd.h"

// cbccd device monitoring json objects
static const char *device_monitor_objs[] =
{
	"config.common",
	"device.inventory",
	"device.product",
	"monitoring.availability",
	"monitoring.dashboard",
	"monitoring.license",
	"monitoring.resource",
	"monitoring.service",
	"monitoring.threat",
	"monitoring.version",
};

// get monitoring object data by object name
static int get_monitor_obj_data(const char *cmd_data, const char *obj_name, char *mon_obj_data, size_t data_s)
{
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_VERBOSE, "MON: Parsing monitoring JSON data for object '%s'", obj_name);
	
	cbcc_json_object_t mon_obj[] =
	{
		{
			.key = obj_name,
			.type = CBCC_JSON_DATA_TYPE_OBJECT,
			.must_specify = true,
			.data.str_val = mon_obj_data,
			.data_size = data_s
		},
	};
	
	// get object data
	if (cbcc_json_parse_from_buffer(cmd_data, mon_obj, CBCC_JOBJS_COUNT(mon_obj)) != 0)
	{
		CBCC_DEBUG_WARN(CBCC_DEBUG_LEVEL_HIGH, "MON: Could not parse json object for '%s'", obj_name);
		return -1;
	}
	
	return 0;
}

// set monitoring object data into DB
static int set_monitor_obj_data(cbccd_pgsql_mgr_t *pgsql_mgr, const char *obj_name, const char *guid, const char *obj_data)
{
	char tbl_name[CBCC_MAX_TBL_NAME_LEN];
	
	// convert object name to table name
	get_tblname_by_objname(obj_name, tbl_name, sizeof(tbl_name));
	
	// set monitoring data into database
	return cbccd_pgsql_set_guid_tbl_data(pgsql_mgr, CBCC_DB_CONN_TYPE_MON, tbl_name, guid, obj_data);
}

// process device monitoring data from client
int cbccd_mon_set_data(cbccd_ctx_t *c, int clnt_sock, const char *cmd_data)
{
	cbccd_device_info_t *dev_info;
	unsigned int i;
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_VERBOSE, "MON: Setting monitoring data '%s'", cmd_data);
	
	// get guid by socket
	dev_info = cbccd_device_get_info_by_sock(&c->device_mgr, clnt_sock);
	if (!dev_info)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "Device from socket '%d' isn't yet connected", clnt_sock);
		return CBCC_RESP_NOT_CONNECTED;
	}
	
	// check device has logined
	if (!dev_info->is_logined)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "Device from socket '%d' isn't yet logined", clnt_sock);
		return CBCC_RESP_NOT_LOGINED;
	}

	for (i = 0; i < sizeof(device_monitor_objs) / sizeof(char *); i++)
	{
		char mon_obj_data[CBCC_MAX_COL_DATA_LEN];
		
		// get data by object name
		if (get_monitor_obj_data(cmd_data, device_monitor_objs[i], mon_obj_data, sizeof(mon_obj_data)) != 0)
			continue;
		
		// set monitoring data into DB
		if (set_monitor_obj_data(&c->pgsql_mgr, device_monitor_objs[i], dev_info->guid, mon_obj_data) != 0)
			continue;
	}
	
	return 0;
}

// remove monitoring data by device guid
void cbccd_mon_remove_data(struct _cbccd_ctx *c, const char *dev_guid)
{
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_HIGH, "MON: Deleting monitoring data for device '%s'", dev_guid);
	
	for (int i = 0; i < sizeof(device_monitor_objs) / sizeof(char *); i++)
	{
		cbccd_pgsql_rm_guid_tbl_data(&c->pgsql_mgr, CBCC_DB_CONN_TYPE_MON, device_monitor_objs[i], dev_guid);
	}

	return;
}
