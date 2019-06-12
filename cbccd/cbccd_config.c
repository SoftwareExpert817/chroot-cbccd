
#include "cbccd.h"

// config object type strings
static const char *config_obj_types[] =
{
	CBCC_CONFIG_OBJECT_TYPE_NET_GROUP_STR,
	CBCC_CONFIG_OBJECT_TYPE_HOST_STR,
	CBCC_CONFIG_OBJECT_TYPE_NETWORK_STR,
	CBCC_CONFIG_OBJECT_TYPE_SWITCH_STR,
	CBCC_CONFIG_OBJECT_TYPE_MULTICAST_STR,
	CBCC_CONFIG_OBJECT_TYPE_SERVICE_AH_STR,
	CBCC_CONFIG_OBJECT_TYPE_SERVICE_ESP_STR,
	CBCC_CONFIG_OBJECT_TYPE_SERVICE_ICMP_STR,
	CBCC_CONFIG_OBJECT_TYPE_SERVICE_IP_STR,
	CBCC_CONFIG_OBJECT_TYPE_SERVICE_TCP_STR,
	CBCC_CONFIG_OBJECT_TYPE_SERVICE_UDP_STR,
	CBCC_CONFIG_OBJECT_TYPE_SERVICE_TCPUDP_STR,
	CBCC_CONFIG_OBJECT_TYPE_SERVICE_GROUP_STR,
	CBCC_CONFIG_OBJECT_TYPE_TIME_RECURRING_STR,
	CBCC_CONFIG_OBJECT_TYPE_TIME_SINGLE_STR,
	CBCC_CONFIG_OBJECT_TYPE_FW_STR,
	NULL
};

// free object reference
static void free_obj_ref(cbcc_config_ref_t *ref)
{
	if (!ref)
		return;

	// free next
	if (ref->next)
		free_obj_ref(ref->next);

	// free self
	free(ref);

	return;
}

static void free_obj_ref_list(cbcc_config_object_t *conf_obj)
{
	// check ref object count
	if (conf_obj->ref_count == 0)
		return;

	free_obj_ref(conf_obj->ref_objs);
	conf_obj->ref_count = 0;

	return;
}

// free config object
static void free_conf_obj(cbcc_config_object_t *conf_obj)
{
	if (!conf_obj)
		return;
	
	// free next
	if (conf_obj->next)
		free_conf_obj(conf_obj->next);

	// free refs
	free_obj_ref_list(conf_obj);
	
	// free self
	free(conf_obj);
	
	return;
}

// free config object list
static void free_conf_objs_list(cbcc_config_object_list_t *conf_objs_list)
{
	if (conf_objs_list->obj_count == 0)
		return;
	
	free_conf_obj(conf_objs_list->conf_objs);
	
	conf_objs_list->obj_count = 0;
	conf_objs_list->conf_objs = NULL;
	
	return;
}

// free ou info
static void free_ou_info(cbcc_config_ou_info_t *ou_info)
{
	if (!ou_info)
		return;
	
	// free next OU info
	if (ou_info->next)
		free_ou_info(ou_info->next);
	
	// free config object list
	free_conf_objs_list(&ou_info->conf_obj_list);
	
	// free self
	free(ou_info);
	
	return;
}

// free ou list
static void free_ou_list(cbcc_config_ou_list_t *ou_list)
{
	// check OU info count
	if (ou_list->count == 0)
		return;
	
	free_ou_info(ou_list->ou_infos);
	
	ou_list->count = 0;
	ou_list->ou_infos = NULL;
	
	return;
}

// add object reference
static void add_obj_ref(cbcc_config_object_t *obj, cbcc_config_object_t *ref_obj)
{
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_HIGH, "CONFIG: Setting object reference for '%s' with %s", obj->obj_guid, ref_obj->obj_guid);

	cbcc_config_ref_t *ref = (cbcc_config_ref_t *) malloc(sizeof(cbcc_config_ref_t));

	memset(ref, 0, sizeof(cbcc_config_ref_t));
	if (obj->ref_count == 0)
	{
		// set head
		obj->ref_objs = ref;
	}
	else
	{
		cbcc_config_ref_t *p = obj->ref_objs;
		while (p->next)
			p = p->next;

		p->next = ref;
	}

	// set config object pointer
	ref->conf_obj = ref_obj;

	// increase reference count
	obj->ref_count++;

	return;
}

// get config object from OU list
static cbcc_config_object_t *get_config_obj(cbcc_config_ou_list_t *ou_list, const char *obj_guid)
{
	cbcc_config_ou_info_t *ou_info = ou_list->ou_infos;
	while (ou_info)
	{
		cbcc_config_object_t *conf_obj = ou_info->conf_obj_list.conf_objs;
		while (conf_obj)
		{
			if (strcmp(conf_obj->obj_guid, obj_guid) == 0)
				return conf_obj;
			
			conf_obj = conf_obj->next;
		}
		
		ou_info = ou_info->next;
	}
	
	return NULL;
}

// set config object from database
static void set_config_objs(cbccd_config_mgr_t *conf_mgr, enum CBCC_CONFIG_OBJECT_TYPE obj_type, const char *obj_tbl_name)
{
	cbccd_pgsql_mgr_t *pgsql_mgr = &conf_mgr->c->pgsql_mgr;
	cbccd_tbl_row_t *tbl_data = NULL;

	cbcc_config_ou_list_t *ou_list = &conf_mgr->ou_list;
	
	// get object list from given table
	int tbl_idx = cbccd_pgsql_get_tbl_idx(obj_tbl_name);
	int count = cbccd_pgsql_cache_get_tbl_rows(pgsql_mgr, tbl_idx, &tbl_data);
	if ( count <= 0)
		return;
	
	for (int i = 0; i < count; i++)
	{
		// get configuration object
		cbcc_config_object_t *conf_obj = get_config_obj(ou_list, tbl_data[i].guid);
		if (!conf_obj)
		{
			CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "CONFIG: Could not found config object with guid '%s' from OU list", tbl_data[i].guid);
			continue;
		}
		
		CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_VERBOSE, "CONFIG: Found config object '%s' from OU info '%s'", tbl_data[i].guid, conf_obj->ou_info->ou_guid);
		
		// set type and data
		conf_obj->obj_type = obj_type;
		strcpy(conf_obj->obj_data, tbl_data[i].data);

		conf_obj->is_set = true;
	}
	
	free(tbl_data);
	
	return;
}

// add config object into config OU info
static cbcc_config_object_t *add_config_obj(cbcc_config_ou_info_t *ou_info, const char *obj_guid)
{
	cbcc_config_object_list_t *conf_objs = &ou_info->conf_obj_list;

	// allocate memory for configuration object info
	cbcc_config_object_t *obj = (cbcc_config_object_t *) malloc(sizeof(cbcc_config_object_t));
	
	// initialize config object
	memset(obj, 0, sizeof(cbcc_config_object_t));
	
	if (conf_objs->obj_count == 0)
	{
		conf_objs->conf_objs = obj;
	}
	else
	{
		cbcc_config_object_t *tmp = conf_objs->conf_objs;
		while (tmp->next)
			tmp = tmp->next;
		
		tmp->next = obj;
		obj->prev = tmp;
	}
	
	// set object guid and OU info
	strcpy(obj->obj_guid, obj_guid);
	obj->ou_info = ou_info;
	
	conf_objs->obj_count++;
	
	return obj;
}

// delete configuration object
static void delete_config_obj(cbcc_config_object_t *obj)
{
	cbcc_config_ou_info_t *ou_info = obj->ou_info;
	if (ou_info->conf_obj_list.conf_objs == obj)
	{
		ou_info->conf_obj_list.conf_objs = obj->next;
		if (obj->next)
			obj->next->prev = NULL;
	}
	else
	{
		if (obj->next)
			obj->next->prev = obj->prev;
		if (obj->prev)
			obj->prev->next = obj->next;
	}

	// decrease config object count of OU info
	obj->ou_info->conf_obj_list.obj_count--;

	// free refs
	free_obj_ref_list(obj);

	// free object
	free(obj);

	return;
}

// remove OU info
static void remove_ou_info(cbcc_config_ou_list_t *ou_list, cbcc_config_ou_info_t *ou_info)
{
	// check removed OU info is root
	if (ou_info == ou_list->ou_infos)
	{
		ou_list->ou_infos = ou_info->next;
		if (ou_info->next)
			ou_info->next->prev = NULL;
	}
	else
	{
		if (ou_info->next)
			ou_info->next->prev = ou_info->prev;
		if (ou_info->prev)
			ou_info->prev->next = ou_info->next;
	}

	// free config object list
	free_conf_objs_list(&ou_info->conf_obj_list);

	// free OU info
	free(ou_info);

	return;
}

// get configuration OU info by OU guid
static cbcc_config_ou_info_t *get_ou_info(cbcc_config_ou_list_t *ou_list, const char *ou_guid)
{
	cbcc_config_ou_info_t *p = ou_list->ou_infos;
	
	// check count of OU infos
	if (ou_list->count == 0)
		return NULL;
	
	while (p)
	{
		if (strcmp(p->ou_guid, ou_guid) == 0)
			return p;
		
		p = p->next;
	}
	
	return NULL;
}

// add configuration OU info
static cbcc_config_ou_info_t *add_ou_info(cbcc_config_ou_list_t *ou_list, const char *ou_guid, const char *ou_name)
{
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_HIGH, "CONFIG: Adding new OU '%s'", ou_guid);

	// create new OU info
	cbcc_config_ou_info_t *p = (cbcc_config_ou_info_t *) malloc(sizeof(cbcc_config_ou_info_t));
			
	memset(p, 0, sizeof(cbcc_config_ou_info_t));
	if (ou_list->count == 0)
	{
		ou_list->ou_infos = p;
	}
	else
	{
		cbcc_config_ou_info_t *tmp = ou_list->ou_infos;
		while (tmp->next)
			tmp = tmp->next;
				
		tmp->next = p;
		p->prev = tmp;
	}
			
	// set guid
	strcpy(p->ou_guid, ou_guid);
	strcpy(p->ou_name, ou_name);

	ou_list->count++;

	return p;
}

// set OU info into database
static void set_ou_info_into_db(cbccd_config_mgr_t *conf_mgr, const char *ou_guid, const char *ou_name, const char *comment)
{
	char *ou_data = NULL;

	// build OU data
	cbcc_json_object_t ou_data_jobjs[] =
	{
		{
			.key = "name",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val_set = ou_name,
		},
		{
			.key = "comment",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val_set = comment
		}
	};

	cbcc_json_build(ou_data_jobjs, CBCC_JOBJS_COUNT(ou_data_jobjs), &ou_data);

	// add OU info into database
	cbccd_pgsql_set_guid_tbl_data(&conf_mgr->c->pgsql_mgr, CBCC_DB_CONN_TYPE_CONFIG, CBCCD_TBL_NAME_OU_INFO, ou_guid, ou_data);

	// free ou_data
	free(ou_data);

	return;
}

// add configuration OU info
static void add_config_ou_info(cbccd_config_mgr_t *conf_mgr, const char *conf_ou_tbl_name)
{
	cbccd_pgsql_mgr_t *pgsql_mgr = &conf_mgr->c->pgsql_mgr;
	cbccd_tbl_row_t *tbl_data = NULL;

	cbcc_config_ou_list_t *ou_list = &conf_mgr->ou_list;
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_VERBOSE, "CONFIG: Adding configuration OU info from database '%s'", conf_ou_tbl_name);
	
	// read config ou list from database
	int tbl_idx = cbccd_pgsql_get_tbl_idx(conf_ou_tbl_name);
	int count = cbccd_pgsql_cache_get_tbl_rows(pgsql_mgr, tbl_idx, &tbl_data);
	if (count <= 0)
		return;
	
	for (int i = 0; i < count; i++)
	{
		char ou_guid[CBCC_MAX_GUID_LEN];
		
		// parse OU guid
		cbcc_json_object_t ou_guid_jobjs[] =
		{
			{
				.key = "ou",
				.type = CBCC_JSON_DATA_TYPE_STRING,
				.data.str_val = ou_guid,
				.data_size = sizeof(ou_guid)
			}
		};
		
		if (cbcc_json_parse_from_buffer(tbl_data[i].data, ou_guid_jobjs, CBCC_JOBJS_COUNT(ou_guid_jobjs)) != 0)
		{
			CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "CONFIG: Could not parse OU guid from '%s' from table '%s'", tbl_data[i].data, conf_ou_tbl_name);
			continue;
		}
		
		CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_VERBOSE, "CONFIG: Adding OU '%s' with object '%s'", ou_guid, tbl_data[i].guid);
		
		// get config OU info by OU guid
		cbcc_config_ou_info_t *p = get_ou_info(ou_list, ou_guid);
		if (!p)
		{
			CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "CONFIG: Could not get OU info by guid '%s'", ou_guid);
			continue;
		}
		
		// create config object for OU
		add_config_obj(p, tbl_data[i].guid);
	}
	
	// free table data
	free(tbl_data);
	
	return;
}

// check config object has firewall reference
static bool check_obj_fw_ref(cbcc_config_object_t *conf_obj, const char *ou_guid)
{
	cbcc_config_ref_t *ref = conf_obj->ref_objs;
	while (ref)
	{
		cbcc_config_object_t *ref_obj = ref->conf_obj;

		// recursive call
		if (check_obj_fw_ref(ref_obj, ou_guid) == true)
			return true;

		// check reference object is firewall
		if (ref_obj->obj_type == CBCC_CONFIG_OBJECT_TYPE_FW)
		{
			// check referred firewall guid is same with one of given OU
			if (strcmp(ref_obj->ou_info->ou_guid, ou_guid) == 0)
				return true;
		}

		ref = ref->next;
	}

	return false;
}

// make configuration files for each OU
static void make_config_list_for_ou(cbcc_config_ou_list_t *ou_list, cbcc_config_ou_info_t *ou_info)
{
	cbcc_json_array_t *conf_obj_arr = &ou_info->conf_obj_arr;
	char *conf_obj_arr_jstr = NULL;
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_HIGH, "CONFIG: Making config json list for OU '%s', object count is '%d'", ou_info->ou_guid, ou_info->conf_obj_list.obj_count);
	
	// initialize config object array
	memset(conf_obj_arr, 0, sizeof(cbcc_json_array_t));
	
	// set configuration object
	cbcc_config_ou_info_t *p = ou_list->ou_infos;
	while (p)
	{
		cbcc_config_object_t *conf_obj = p->conf_obj_list.conf_objs;
		while (conf_obj)
		{
			char *conf_obj_jstr = NULL;
			char obj_type[CBCC_MAX_TBL_NAME_LEN];
			
			// set config object was set
			if (!conf_obj->is_set)
			{
				conf_obj = conf_obj->next;
				continue;
			}

			// check if object is in other OU, then check object has reference to firewall object in given OU
			if (strcmp(p->ou_guid, ou_info->ou_guid) != 0)
			{
				if (conf_obj->obj_type != CBCC_CONFIG_OBJECT_TYPE_FW)
				{
					conf_obj = conf_obj->next;
					continue;
				}
				else
				{
					if (!check_obj_fw_ref(conf_obj, ou_info->ou_guid))
					{
						conf_obj = conf_obj->next;
						continue;
					}
				}
			}

			CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_VERBOSE, "CONFIG: Adding config object with guid '%s', type '%s', data '%s'",
						    conf_obj->obj_guid, config_obj_types[conf_obj->obj_type], conf_obj->obj_data);

			// get object type
			get_objtype_by_tblname(config_obj_types[conf_obj->obj_type], obj_type, sizeof(obj_type));
			
			// build json string for configuration object
			cbcc_json_object_t conf_obj_jobjs[] =
			{
				{
					.key = "guid",
					.type = CBCC_JSON_DATA_TYPE_STRING,
					.data.str_val_set = conf_obj->obj_guid,
				},
				{
					.key = "type",
					.type = CBCC_JSON_DATA_TYPE_STRING,
					.data.str_val_set = obj_type
				},
				{
					.key = "data",
					.type = CBCC_JSON_DATA_TYPE_OBJECT,
					.obj_exist_data = true,
					.data.str_val_set = conf_obj->obj_data,
				}
			};

			cbcc_json_build(conf_obj_jobjs, CBCC_JOBJS_COUNT(conf_obj_jobjs), &conf_obj_jstr);
			
			// set array data
			strcpy(conf_obj_arr->data.str_vals[conf_obj_arr->arr_len++], conf_obj_jstr);
			
			// free config object json string
			free(conf_obj_jstr);
			
			conf_obj = conf_obj->next;
		}
	
		p = p->next;
	}

	// build json string for whole objects
	cbcc_json_object_t conf_arr_jobjs[] =
	{
		{
			.key = "deploy.objects",
			.type = CBCC_JSON_DATA_TYPE_OBJ_ARRAY,
			.data.arr_val = conf_obj_arr,
		}
	};
	
	cbcc_json_build(conf_arr_jobjs, CBCC_JOBJS_COUNT(conf_arr_jobjs), &conf_obj_arr_jstr);
	
	// set md5sum
	get_md5sum_of_buffer(conf_obj_arr_jstr, ou_info->conf_md5sum, sizeof(ou_info->conf_md5sum));
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_HIGH, "CONFIG: md5sum of config for OU '%s' is '%s'", ou_info->ou_guid, ou_info->conf_md5sum);
	
	// free json string
	free(conf_obj_arr_jstr);
	
	return;
}

// set group object references
static void set_grp_objs_refs(cbcc_config_ou_list_t *ou_list, cbcc_config_object_t *obj_info)
{
	cbcc_json_array_t ref_objs;

	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_HIGH, "CONFIG: Setting group object reference for '%s'", obj_info->obj_guid);

	// parse reference config objects
	cbcc_json_object_t ref_jobjs[] =
	{
		{
			.key = "members",
			.type = CBCC_JSON_DATA_TYPE_STR_ARRAY,
			.must_specify = true,
			.data.arr_val = &ref_objs,
		}
	};

	if (cbcc_json_parse_from_buffer(obj_info->obj_data, ref_jobjs, CBCC_JOBJS_COUNT(ref_jobjs)) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "CONFIG: Unknown 'member' type in configuration data '%s'", obj_info->obj_data);
		return;
	}

	// set reference objects into each object
	for (int arr_idx = 0; arr_idx < ref_objs.arr_len; arr_idx++)
	{
		const char *ref_guid = ref_objs.data.str_vals[arr_idx];

		// get object by guid
		cbcc_config_object_t *ref_obj = get_config_obj(ou_list, ref_guid);
		if (!ref_guid)
		{
			CBCC_DEBUG_WARN(CBCC_DEBUG_LEVEL_NOR, "CONFIG: Could not get reference object by guid '%s'", ref_guid);
			continue;
		}

		add_obj_ref(ref_obj, obj_info);
	}

	return;
}

// set fw object references
static void set_fw_objs_refs(cbcc_config_ou_list_t *ou_list, cbcc_config_object_t *obj_info)
{
	char obj_guids[4][CBCC_MAX_GUID_LEN];

	// parse reference object guids
	cbcc_json_object_t ref_jobjs[] =
	{
		{
			.key = "destination",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val = obj_guids[0],
			.data_size = sizeof(obj_guids[0]),
		},
		{
			.key = "source",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val = obj_guids[1],
			.data_size = sizeof(obj_guids[1]),
		},
		{
			.key = "service",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val = obj_guids[2],
			.data_size = sizeof(obj_guids[2]),
		},
		{
			.key = "time",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val = obj_guids[3],
			.data_size = sizeof(obj_guids[3]),
		},
	};

	if (cbcc_json_parse_from_buffer(obj_info->obj_data, ref_jobjs, CBCC_JOBJS_COUNT(ref_jobjs)) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "CONFIG: Unknown 'member' type in configuration data '%s'", obj_info->obj_data);
		return;
	}

	// set reference objects into each object
	for (int i = 0; i < 4; i++)
	{
		// get object by guid
		cbcc_config_object_t *ref_obj = get_config_obj(ou_list, obj_guids[i]);
		if (!ref_obj)
		{
			CBCC_DEBUG_WARN(CBCC_DEBUG_LEVEL_NOR, "CONFIG: Could not get reference object by guid '%s'", obj_guids[i]);
			continue;
		}

		add_obj_ref(ref_obj, obj_info);
	}

	return;
}

// set configuration object reference
static void set_obj_refs(cbcc_config_ou_list_t *ou_list, cbcc_config_object_t *obj)
{
	// check types
	if (obj->obj_type == CBCC_CONFIG_OBJECT_TYPE_NET_GROUP || obj->obj_type == CBCC_CONFIG_OBJECT_TYPE_SERVICE_GROUP)
	{
		set_grp_objs_refs(ou_list, obj);
	}
	else if (obj->obj_type == CBCC_CONFIG_OBJECT_TYPE_FW)
	{
		set_fw_objs_refs(ou_list, obj);
	}

	return;
}

// set references between configuration objects
static void set_config_objs_refs(cbcc_config_ou_list_t *ou_list)
{
	cbcc_config_ou_info_t *ou_info = ou_list->ou_infos;
	while (ou_info)
	{
		cbcc_config_object_t *obj_info = ou_info->conf_obj_list.conf_objs;
		while (obj_info)
		{
			// check set status
			if (!obj_info->is_set)
			{
				obj_info = obj_info->next;
				continue;
			}

			// free object refs
			free_obj_ref_list(obj_info);

			// set object references
			set_obj_refs(ou_list, obj_info);

			obj_info = obj_info->next;
		}

		ou_info = ou_info->next;
	}
}

// make config list for whole OU
static void make_config_list(cbcc_config_ou_list_t *ou_list)
{
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "CONFIG: Making configuration list for all OU");

	cbcc_config_ou_info_t *ou_info = ou_list->ou_infos;
	while (ou_info)
	{
		make_config_list_for_ou(ou_list, ou_info);
		ou_info = ou_info->next;
	}

	return;
}

// read configuration from database cache
static void read_config_objects(cbccd_config_mgr_t *conf_mgr)
{
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_HIGH, "CONFIG: Reading configurations objects.");
	
	// read config ou info and configuration objects from database
	for (int i = 0; i < CBCC_CONFIG_OBJECT_TYPE_UNKNOWN; i++)
	{
		char conf_ou_tbl_name[CBCC_MAX_TBL_NAME_LEN];
		
		// set config ou table name
		snprintf(conf_ou_tbl_name, sizeof(conf_ou_tbl_name), "%s_ou", config_obj_types[i]);
		
		// add ou config info by each object type
		add_config_ou_info(conf_mgr, conf_ou_tbl_name);
		
		// set config objects
		set_config_objs(conf_mgr, i, config_obj_types[i]);
	}

	// set references between objects
	set_config_objs_refs(&conf_mgr->ou_list);

	// make config list
	make_config_list(&conf_mgr->ou_list);

	return;
}

// read OU list
static void read_ou_list(cbccd_config_mgr_t *conf_mgr)
{
	cbccd_tbl_row_t *ou_list_rows = NULL;
	int rows_count;

	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "Reading OU list");

	// get ou list from ou_info table
	int tbl_idx = cbccd_pgsql_get_tbl_idx(CBCCD_TBL_NAME_OU_INFO);
	rows_count = cbccd_pgsql_cache_get_tbl_rows(&conf_mgr->c->pgsql_mgr, tbl_idx, &ou_list_rows);
	if (rows_count == 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "CONFIG: Empty OU list");
		return;
	}

	// add OU info
	for (int ou_idx = 0; ou_idx < rows_count; ou_idx++)
	{
		char ou_name[CBCC_MAX_OU_NAME_LEN];

		// parse OU name
		cbcc_json_object_t ou_info_jobjs[] =
		{
			{
				.key = "name",
				.type = CBCC_JSON_DATA_TYPE_STRING,
				.data.str_val = ou_name,
				.must_specify = true,
				.data_size = sizeof(ou_name)
			}
		};

		if (cbcc_json_parse_from_buffer(ou_list_rows[ou_idx].data, ou_info_jobjs, CBCC_JOBJS_COUNT(ou_info_jobjs)) != 0)
		{
			CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "CONFIG: Could not get OU name from '%s' for OU guid '%s'", ou_list_rows[ou_idx].guid);
			continue;
		}

		// add OU info
		add_ou_info(&conf_mgr->ou_list, ou_list_rows[ou_idx].guid, ou_name);
	}

	// free ou list rows
	free(ou_list_rows);

	return;
}

// read default OU
static void read_default_ou(cbccd_config_mgr_t *conf_mgr)
{
	char default_ou_guid[CBCC_MAX_OU_NAME_LEN];
	char *default_ou_jstr = NULL;

	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_HIGH, "CONFIG: Reading default OU info");

	// read OU info from ou_default table
	int tbl_idx = cbccd_pgsql_get_tbl_idx(CBCCD_TBL_NAME_OU_DEFAULT);
	if (cbccd_pgsql_cache_get_tbl_data(&conf_mgr->c->pgsql_mgr, tbl_idx, "1", &default_ou_jstr) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "CONFIG: Could not get default OU name");
		return;
	}

	// parse default OU guid
	cbcc_json_object_t default_ou_jobjs[] =
	{
		{
			.key = "default",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.must_specify = true,
			.data.str_val = default_ou_guid,
			.data_size = sizeof(default_ou_guid)
		}
	};

	if (cbcc_json_parse_from_buffer(default_ou_jstr, default_ou_jobjs, CBCC_JOBJS_COUNT(default_ou_jobjs)) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_HIGH, "CONFIG: Could not parse default OU from '%s'", default_ou_jstr);
		free(default_ou_jstr);

		return;
	}

	// set default OU info
	cbcc_config_ou_info_t *ou_info = get_ou_info(&conf_mgr->ou_list, default_ou_guid);
	if (!ou_info)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "CONFIG: Could not found OU info by default guid '%s'", default_ou_guid);
	}
	else
	{
		// set default flag
		ou_info->is_default = true;
		conf_mgr->ou_list.default_ou_info = ou_info;
	}

	// free default OU json buffer
	free(default_ou_jstr);

	return;
}

// set default OU info
static void set_default_ou(cbccd_config_mgr_t *conf_mgr, cbcc_config_ou_info_t *ou_info)
{
	char *default_ou_jstr;

	// set OU as default
	conf_mgr->ou_list.default_ou_info->is_default = false;
	conf_mgr->ou_list.default_ou_info = ou_info;
	ou_info->is_default = true;

	// set default OU into database
	cbcc_json_object_t default_ou_jobjs[] =
	{
		{
			.key = "default",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val_set = ou_info->ou_guid,
		}
	};

	cbcc_json_build(default_ou_jobjs, CBCC_JOBJS_COUNT(default_ou_jobjs), &default_ou_jstr);

	// set json string into database
	cbccd_pgsql_set_guid_tbl_data(&conf_mgr->c->pgsql_mgr, CBCC_DB_CONN_TYPE_CONFIG, CBCCD_TBL_NAME_OU_DEFAULT, "1", default_ou_jstr);

	// free default OU json string
	free(default_ou_jstr);

	return;
}

// initialize cbccd configuration manager
int cbccd_config_mgr_init(cbccd_ctx_t *c)
{
	cbccd_config_mgr_t *conf_mgr = &c->conf_mgr;
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "CONFIG: Initializing configuration manager.");

	// set context object
	conf_mgr->c = c;

	// initiailze mutex
	pthread_mutex_init(&conf_mgr->conf_mt, NULL);

	// read OU list
	read_ou_list(conf_mgr);

	// read default OU info
	read_default_ou(conf_mgr);
	
	// read configurations from cache
	read_config_objects(conf_mgr);

	// set init flag
	conf_mgr->init_flag = true;
	
	return 0;
}

// finalize configuration manager
void cbccd_config_mgr_finalize(cbccd_config_mgr_t *conf_mgr)
{
	// check init flag
	if (!conf_mgr->init_flag)
		return;
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "CONFIG: Finalizing configuration manager.");
	
	// finalize mutex
	pthread_mutex_destroy(&conf_mgr->conf_mt);
	
	// free OU info list
	free_ou_list(&conf_mgr->ou_list);
	
	return;
}

// send deploy.config command to agent
static int send_deploy_config_cmd(cbccd_config_mgr_t *conf_mgr, int clnt_sock, cbcc_config_ou_info_t *ou_info)
{
	int ret;
	char *cmd;
	
	// build command
	cbcc_json_object_t deploy_cmd_jobjs[] =
	{
		{
			.key = "cmd",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val_set = CBCC_CMD_DEPLOY,
		},
		{
			.key = "data",
			.type = CBCC_JSON_DATA_TYPE_OBJECT,
		},
		{
			.key = "deploy.objects",
			.type = CBCC_JSON_DATA_TYPE_OBJ_ARRAY,
			.parent_key = "data",
			.data.arr_val = ou_info ? &ou_info->conf_obj_arr : NULL,
		},
	};
	
	cbcc_json_build(deploy_cmd_jobjs, CBCC_JOBJS_COUNT(deploy_cmd_jobjs), &cmd);
	
	// send command
	ret = cbccd_cmd_send(&conf_mgr->c->cmd_mgr, clnt_sock, cmd);
	
	// free command buffer
	free(cmd);
	
	return ret;
}

// init deploy status
static void add_deploy_status(bool init, char *old_jstr, const char *obj_guid, char **new_jstr)
{
	// build init status json string
	if (init)
	{
		cbcc_json_object_t init_st_jobjs[] =
		{
			{
				.key = "status",
				.type = CBCC_JSON_DATA_TYPE_OBJECT,
			}
		};

		cbcc_json_build(init_st_jobjs, CBCC_JOBJS_COUNT(init_st_jobjs), new_jstr);
	}
	else
	{
		cbcc_json_object_t add_st_jobjs[] =
		{
			{
				.key = obj_guid,
				.type = CBCC_JSON_DATA_TYPE_STRING,
				.parent_key = "status",
				.data.str_val_set = "success",
			}
		};
		
		cbcc_json_add(old_jstr, add_st_jobjs, CBCC_JOBJS_COUNT(add_st_jobjs), new_jstr);
	}
	
	return;
}

// set deploy status
static const char *deploy_st_tbl_names[] =
{
	CBCCD_TBL_NAME_OBJ_NET_GRP,
	CBCCD_TBL_NAME_OBJ_NET_HOST,
	CBCCD_TBL_NAME_OBJ_NET_NET,
	CBCCD_TBL_NAME_OBJ_SRV_AH,
	CBCCD_TBL_NAME_OBJ_SRV_ESP,
	CBCCD_TBL_NAME_OBJ_SRV_ICMP,
	CBCCD_TBL_NAME_OBJ_SRV_IP,
	CBCCD_TBL_NAME_OBJ_SRV_TCP,
	CBCCD_TBL_NAME_OBJ_SRV_UDP,
	CBCCD_TBL_NAME_OBJ_SRV_TCPUDP,
	CBCCD_TBL_NAME_OBJ_SRV_GRP,
	CBCCD_TBL_NAME_OBJ_TM_REC,
	CBCCD_TBL_NAME_OBJ_TM_SINGLE,
	CBCCD_TBL_NAME_OBJ_PF_PF,
};

static void set_deploy_status(cbccd_config_mgr_t *conf_mgr, const char *dev_guid, cbcc_config_ou_info_t *ou_info)
{
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "CONFIG: Setting deploying status for device '%s'", dev_guid);
	
	for (int i = 0; i < CBCC_CONFIG_OBJECT_TYPE_UNKNOWN; i++)
	{
		char *st_jstr = NULL;
		
		// init deploy status
		add_deploy_status(true, NULL, NULL, &st_jstr);
		if (ou_info)
		{
			cbcc_config_object_t *conf_obj = ou_info->conf_obj_list.conf_objs;
			while (conf_obj)
			{
				char *new_st_jstr;
				
				// check object type and set flag
				if (conf_obj->obj_type != i || !conf_obj->is_set)
				{
					conf_obj = conf_obj->next;
					continue;
				}
				
				// add deploy status
				add_deploy_status(false, st_jstr, conf_obj->obj_guid, &new_st_jstr);
				
				// free old json string and set new val
				free(st_jstr);
				st_jstr = new_st_jstr;
				
				conf_obj = conf_obj->next;
			}
		}
		
		// set status into database
		cbccd_pgsql_set_guid_tbl_data(&conf_mgr->c->pgsql_mgr, CBCC_DB_CONN_TYPE_CONFIG, deploy_st_tbl_names[i], dev_guid, st_jstr);
		
		// free status json string
		free(st_jstr);
	}
	
	return;
}

// send configuration data
int cbccd_config_send_data(cbccd_config_mgr_t *conf_mgr, int clnt_sock, const char *cmd_data)
{
	char *ou_info_jstr = NULL;
	char ou_guid[CBCC_MAX_OU_NAME_LEN];
	
	char md5sum[CBCC_MD5SUM_LEN * 2 + 1];
	
	// get device guid by client socket
	cbccd_device_info_t *dev_info = cbccd_device_get_info_by_sock(&conf_mgr->c->device_mgr, clnt_sock);
	if (!dev_info)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "CONFIG: Could not get device guid by socket '%d'", clnt_sock);
		return -1;
	}
	
	// check device has logined
	if (!dev_info->is_logined)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "CONFIG: Device from socket '%d' isn't logined");
		return -1;
	}
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_HIGH, "CONFIG: Processing deploy.objects command from device '%s'", dev_info->guid);
	
	// get md5sum
	cbcc_json_object_t cmd_data_jobjs[] =
	{
		{
			.key = "md5sum",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val = md5sum,
			.data_size = sizeof(md5sum)
		}
	};
	
	if (cbcc_json_parse_from_buffer(cmd_data, cmd_data_jobjs, CBCC_JOBJS_COUNT(cmd_data_jobjs)) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "CONFIG: Could not parse deploy.objects command data '%s' from device '%s'", cmd_data, dev_info->guid);
		return -1;
	}
	
	// check which OU includes given device
	int tbl_idx = cbccd_pgsql_get_tbl_idx(CBCCD_TBL_NAME_DEVICE_OU);
	if (cbccd_pgsql_cache_get_tbl_data(&conf_mgr->c->pgsql_mgr, tbl_idx, dev_info->guid, &ou_info_jstr) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "CONFIG: Could not get device OU for device '%s' from table '%s'", dev_info->guid, CBCCD_TBL_NAME_DEVICE_OU);
		return -1;
	}
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_VERBOSE, "CONFIG: Device OU info json string is '%s'", ou_info_jstr);
	
	// get OU info
	cbcc_json_object_t ou_info_jobjs[] =
	{
		{
			.key = "ou",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val = ou_guid,
			.data_size = sizeof(ou_guid)
		}
	};
	
	if (cbcc_json_parse_from_buffer(ou_info_jstr, ou_info_jobjs, CBCC_JOBJS_COUNT(ou_info_jobjs)) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "CONFIG: Could not parse OU info '%s' for device guid '%s'", ou_info_jstr, dev_info->guid);
	}
	else
	{
		// get configuration OU info
		pthread_mutex_lock(&conf_mgr->conf_mt);
		cbcc_config_ou_info_t *ou_info = get_ou_info(&conf_mgr->ou_list, ou_guid);
		if (!ou_info)
		{
			if (strcmp(md5sum, "") != 0)
			{
				CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "CONFIG: Detected deploy.config status for device '%s'", dev_info->guid);
				if (send_deploy_config_cmd(conf_mgr, clnt_sock, NULL) == 0)
					set_deploy_status(conf_mgr, dev_info->guid, NULL);
			}
		}
		else
		{
			// check md5sum of configuration
			if (strcmp(ou_info->conf_md5sum, md5sum) != 0)
			{
				CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "CONFIG: Detected deploy.config status for device '%s'", dev_info->guid);
				if (send_deploy_config_cmd(conf_mgr, clnt_sock, ou_info) == 0)
					set_deploy_status(conf_mgr, dev_info->guid, ou_info);
			}
		}
		
		pthread_mutex_unlock(&conf_mgr->conf_mt);
	}
	
	// free ou info json buffer
	if (ou_info_jstr)
		free(ou_info_jstr);
	
	return 0;
}

// send deploy configuration command
static int send_check_config_cmd(cbccd_config_mgr_t *conf_mgr)
{
	char *cmd = NULL;
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "CONFIG: Sending deploy configuration command");
	
	// build command
	cbcc_json_object_t chk_conf_jobjs[] =
	{
		{
			.key = "cmd",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val_set = CBCC_CMD_CHECK_CONFIG,
		}
	};
	
	cbcc_json_build(chk_conf_jobjs, CBCC_JOBJS_COUNT(chk_conf_jobjs), &cmd);
	
	// send configuration to all devices
	cbccd_device_mutex_lock(&conf_mgr->c->device_mgr);
	
	cbccd_device_info_t *p = conf_mgr->c->device_mgr.device_list.dev_infos;
	while (p)
	{
		// check login flag
		if (!p->is_logined)
		{
			p = p->next;
			continue;
		}
		
		CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "CONFIG: Sending '%s' command to device '%s'", CBCC_CMD_CHECK_CONFIG, p->guid);
		cbccd_cmd_send(&conf_mgr->c->cmd_mgr, p->sock, cmd);
		
		p = p->next;
	}
	
	cbccd_device_mutex_unlock(&conf_mgr->c->device_mgr);
	
	// free command
	free(cmd);
	
	return 0;
}

// get object type
enum CBCC_CONFIG_OBJECT_TYPE get_obj_type(const char *obj_type_str)
{
	for (unsigned int i = 0; i < CBCC_CONFIG_OBJECT_TYPE_UNKNOWN; i++)
	{
		if (strcmp(obj_type_str, config_obj_types[i]) == 0)
			return i;
	}

	return CBCC_CONFIG_OBJECT_TYPE_UNKNOWN;
}

// set OU table data
static void set_ou_tbl_data(cbccd_config_mgr_t *conf_mgr, const char *ou_guid, const char *obj_guid, const char *obj_tbl_name, bool add)
{
	char obj_ou_tbl_name[CBCC_MAX_TBL_NAME_LEN];
	char *ou_info_jstr;

	// make object OU table name
	snprintf(obj_ou_tbl_name, sizeof(obj_ou_tbl_name), "%s_ou", obj_tbl_name);

	if (add)
	{
		// build OU info json string
		cbcc_json_object_t ou_info_jobjs[] =
		{
			{
				.key = "ou",
				.type = CBCC_JSON_DATA_TYPE_STRING,
				.data.str_val_set = ou_guid,
			}
		};

		cbcc_json_build(ou_info_jobjs, CBCC_JOBJS_COUNT(ou_info_jobjs), &ou_info_jstr);

		// set OU info into database
		cbccd_pgsql_set_guid_tbl_data(&conf_mgr->c->pgsql_mgr, CBCC_DB_CONN_TYPE_CONFIG, obj_ou_tbl_name, obj_guid, ou_info_jstr);

		free(ou_info_jstr);
	}
	else
	{
		cbccd_pgsql_rm_guid_tbl_data(&conf_mgr->c->pgsql_mgr, CBCC_DB_CONN_TYPE_CONFIG, obj_ou_tbl_name, obj_guid);
	}

	return;	
}

// add configuration object
int cbccd_config_add_object(cbccd_config_mgr_t *conf_mgr, const char *obj_guid, const char *obj_type_str, const char *obj_data)
{
	char ou_guid[CBCC_MAX_GUID_LEN];
	enum CBCC_CONFIG_OBJECT_TYPE obj_type;

	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_HIGH, "CONFIG: Adding object with guid '%s', type '%s', data '%s'", obj_guid, obj_type_str, obj_data);

	// parse OU guid
	cbcc_json_object_t obj_data_jobjs[] =
	{
		{
			.key = "ou",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.must_specify = true,
			.data.str_val = ou_guid,
			.data_size = sizeof(ou_guid)
		}
	};

	if (cbcc_json_parse_from_buffer(obj_data, obj_data_jobjs, CBCC_JOBJS_COUNT(obj_data_jobjs)) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "CONFIG: Could not get OU guid from configuration object data '%s'", obj_data);
		return CBCC_RESP_JSON_INVALID;
	}

	// lock config list
	pthread_mutex_lock(&conf_mgr->conf_mt);

	// check OU guid is exist
	cbcc_config_ou_info_t *ou_info = get_ou_info(&conf_mgr->ou_list, ou_guid);
	if (!ou_info)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "CONFIG: Could not found OU info by OU guid '%s'", ou_info);

		// unlock config list
		pthread_mutex_unlock(&conf_mgr->conf_mt);
		return CBCC_RESP_NOT_FOUND_OU;
	}

	// check object type
	obj_type = get_obj_type(obj_type_str);
	if (obj_type == CBCC_CONFIG_OBJECT_TYPE_UNKNOWN)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "CONFIG: Unknow object type '%s'", obj_type_str);

		// unlock config list
		pthread_mutex_unlock(&conf_mgr->conf_mt);
		return CBCC_RESP_UNKNOWN_OBJ_TYPE;
	}

	// add object into OU
	cbcc_config_object_t *obj = add_config_obj(ou_info, obj_guid);

	// set object fields
	strcpy(obj->obj_guid, obj_guid);
	strcpy(obj->obj_data, obj_data);
	obj->obj_type = obj_type;
	obj->is_set = true;

	// set object references
	set_config_objs_refs(&conf_mgr->ou_list);

	// make config list
	make_config_list(&conf_mgr->ou_list);

	// unlock config list
	pthread_mutex_unlock(&conf_mgr->conf_mt);

	// set object into database
	cbccd_pgsql_set_guid_tbl_data(&conf_mgr->c->pgsql_mgr, CBCC_DB_CONN_TYPE_CONFIG, obj_type_str, obj_guid, obj_data);

	// set object OU info into database
	set_ou_tbl_data(conf_mgr, ou_guid, obj_guid, obj_type_str, true);
	
	// send check.config command
	send_check_config_cmd(conf_mgr);

	return CBCC_RESP_OK;
}

// delete configuration object
int cbccd_config_delete_object(cbccd_config_mgr_t *conf_mgr, const char *obj_guid, const char *obj_type)
{
	int ret = CBCC_RESP_OK;
	char ou_guid[CBCC_MAX_GUID_LEN];

	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_HIGH, "CONFIG: Deleting object '%s' with type '%s'", obj_guid, obj_type);

	// lock mutex
	pthread_mutex_lock(&conf_mgr->conf_mt);

	// get configuration object from list
	cbcc_config_object_t *obj = get_config_obj(&conf_mgr->ou_list, obj_guid);
	if (!obj)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "CONFIG: Could not delete object by guid '%s'", obj_guid);
		ret = CBCC_RESP_NOT_FOUND_GUID;
		goto end;
	}

	// check object has any reference
	if (obj->ref_count > 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "CONFIG: Could not delete object due to object is using by another");
		ret = CBCC_RESP_OBJ_IS_USING;
		goto end;
	}

	// set OU guid
	memset(ou_guid, 0, sizeof(ou_guid));
	strcpy(ou_guid, obj->ou_info->ou_guid);

	// delete object
	delete_config_obj(obj);

	// set references between objects
	set_config_objs_refs(&conf_mgr->ou_list);

	// make config list
	make_config_list(&conf_mgr->ou_list);

end:
	// unlock mutex
	pthread_mutex_unlock(&conf_mgr->conf_mt);

	if (ret == CBCC_RESP_OK)
	{
		// remove object from database
		cbccd_pgsql_rm_guid_tbl_data(&conf_mgr->c->pgsql_mgr, CBCC_DB_CONN_TYPE_CONFIG, obj_type, obj_guid);

		// remove object OU info
		set_ou_tbl_data(conf_mgr, ou_guid, obj_guid, obj_type, false);

		// send check.config command
		send_check_config_cmd(conf_mgr);
	}

	return ret;
}

// edit configuration object
int cbccd_config_edit_object(cbccd_config_mgr_t *conf_mgr, const char *obj_guid, const char *obj_type, const char *obj_data)
{
	int ret = CBCC_RESP_OK;

	// lock mutex
	pthread_mutex_lock(&conf_mgr->conf_mt);

	// get configuration object from list
	cbcc_config_object_t *obj = get_config_obj(&conf_mgr->ou_list, obj_guid);
	if (!obj)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "CONFIG: Could not edit object by guid '%s'", obj_guid);
		ret = CBCC_RESP_NOT_FOUND_GUID;
		goto end;
	}

	// set object data
	strcpy(obj->obj_data, obj_data);
	obj->obj_data[strlen(obj_data)] = '\0';

	// set references between objects
	set_config_objs_refs(&conf_mgr->ou_list);

	// make config list
	make_config_list(&conf_mgr->ou_list);

end:
	// unlock mutex
	pthread_mutex_unlock(&conf_mgr->conf_mt);

	// set object in database and send check.config command
	if (ret == CBCC_RESP_OK)
	{
		// set object into database
		cbccd_pgsql_set_guid_tbl_data(&conf_mgr->c->pgsql_mgr, CBCC_DB_CONN_TYPE_CONFIG, obj_type, obj_guid, obj_data);
	
		// send check.config command
		send_check_config_cmd(conf_mgr);
	}

	return ret;
}

// create OU with devices
int cbccd_config_create_ou(cbccd_config_mgr_t *conf_mgr, const char *ou_guid, const char *ou_name, const char *comment, cbcc_json_array_t *dev_guids)
{
	cbcc_config_ou_info_t *ou_info = conf_mgr->ou_list.ou_infos;

	// lock mutex
	pthread_mutex_lock(&conf_mgr->conf_mt);

	// check OU name has duplicated
	while (ou_info)
	{
		// check OU name is same
		if (strcmp(ou_name, ou_info->ou_name) == 0)
		{
			CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "CONIG: Duplicated OU name '%s'", ou_name);

			// unlock mutex
			pthread_mutex_unlock(&conf_mgr->conf_mt);

			return CBCC_RESP_OU_NAME_DUPLICATE;
		}

		ou_info = ou_info->next;
	}

	// add OU info
	ou_info = add_ou_info(&conf_mgr->ou_list, ou_guid, ou_name);

	// set OU info into database
	set_ou_info_into_db(conf_mgr, ou_guid, ou_name, comment);

	// lock mutex for device manager
	cbccd_device_mutex_lock(&conf_mgr->c->device_mgr);

	// set devices into OU group
	for (int dev_idx = 0; dev_idx < dev_guids->arr_len; dev_idx++)
	{
		const char *dev_guid = dev_guids->data.str_vals[dev_idx];

		// get device info by guid
		cbccd_device_set_ou_info(&conf_mgr->c->device_mgr, dev_guid, ou_info);
	}

	// unlock mutex for device manager
	cbccd_device_mutex_unlock(&conf_mgr->c->device_mgr);

	// unlock mutex
	pthread_mutex_unlock(&conf_mgr->conf_mt);

	return 0;
}

// edit OU
int cbccd_config_edit_ou(cbccd_config_mgr_t *conf_mgr, const char *ou_guid, const char *ou_name, const char *comment, cbcc_json_array_t *dev_guids)
{
	cbcc_config_ou_info_t *ou_info;

	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "CONFIG: Editing OU info '%s'", ou_guid);

	// lock mutex
	pthread_mutex_lock(&conf_mgr->conf_mt);

	// get ou info by guid
	ou_info = get_ou_info(&conf_mgr->ou_list, ou_guid);
	if (!ou_info)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "CONFIG: Could not found OU info by OU guid '%s'", ou_guid);

		// unlock mutex
		pthread_mutex_unlock(&conf_mgr->conf_mt);
		return CBCC_RESP_NOT_FOUND_OU;
	}

	// check edited OU name is duplicated
	if (strcmp(ou_name, ou_info->ou_name) != 0)
	{
		cbcc_config_ou_info_t *p = conf_mgr->ou_list.ou_infos;
		while (p)
		{
			// check OU name is same
			if (strcmp(ou_guid, p->ou_guid) != 0 && strcmp(ou_name, p->ou_name) == 0)
			{
				CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "CONIG: Duplicated OU name '%s'", ou_name);

				// unlock mutex
				pthread_mutex_unlock(&conf_mgr->conf_mt);
				return CBCC_RESP_OU_NAME_DUPLICATE;
			}

			p = p->next;
		}
	}

	// set OU name
	strcpy(ou_info->ou_name, ou_name);
	ou_info->ou_name[strlen(ou_name)] = '\0';

	// set OU info into database
	set_ou_info_into_db(conf_mgr, ou_info->ou_guid, ou_name, comment);

	// lock mutex for device manager
	cbccd_device_mutex_lock(&conf_mgr->c->device_mgr);

	cbccd_device_info_t *dev_info = conf_mgr->c->device_mgr.device_list.dev_infos;
	while (dev_info)
	{
		bool exist_in_list = false;

		// check device is in new list
		for (int dev_idx = 0; dev_idx < dev_guids->arr_len; dev_idx++)
		{
			const char *dev_guid = dev_guids->data.str_vals[dev_idx];
			if (strcmp(dev_info->guid, dev_guid) == 0)
			{
				exist_in_list = true;
				break;
			}
		}

		if (!exist_in_list)
		{
			// set device ou info into default if it was in old list
			if (dev_info->ou_info == ou_info)
				cbccd_device_set_ou_info(&conf_mgr->c->device_mgr, dev_info->guid, conf_mgr->ou_list.default_ou_info);
		}
		else
		{
			// check device is in old list
			if (dev_info->ou_info != ou_info)
			{
				// add device info into new
				cbccd_device_set_ou_info(&conf_mgr->c->device_mgr, dev_info->guid, ou_info);
			}
		}

		dev_info = dev_info->next;
	}

	// unlock mutex for device manager
	cbccd_device_mutex_unlock(&conf_mgr->c->device_mgr);

	// unlock mutex
	pthread_mutex_unlock(&conf_mgr->conf_mt);

	return 0;
}

// delete OU
void cbccd_config_delete_ou(cbccd_config_mgr_t *conf_mgr, const char *ou_guid)
{
	cbcc_config_ou_info_t *ou_info;

	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "CONFIG: Delete OU info '%s'", ou_guid);

	// lock config manager
	pthread_mutex_lock(&conf_mgr->conf_mt);

	// get OU info by guid
	ou_info = get_ou_info(&conf_mgr->ou_list, ou_guid);
	if (!ou_info)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "CONFIG: Could not found OU info '%s'", ou_guid);

		// unlock config manager
		pthread_mutex_unlock(&conf_mgr->conf_mt);
		return;
	}

	// lock device manager
	cbccd_device_mutex_lock(&conf_mgr->c->device_mgr);

	cbccd_device_info_t *dev_info = conf_mgr->c->device_mgr.device_list.dev_infos;
	while (dev_info)
	{
		// check if device has OU which deleted and set OU as default
		if (dev_info->ou_info == ou_info)
			cbccd_device_set_ou_info(&conf_mgr->c->device_mgr, dev_info->guid, conf_mgr->ou_list.default_ou_info);

		dev_info = dev_info->next;
	}

	// unlock device manager
	cbccd_device_mutex_unlock(&conf_mgr->c->device_mgr);

	// remove configuration list
	remove_ou_info(&conf_mgr->ou_list, ou_info);

	// unlock config manager
	pthread_mutex_unlock(&conf_mgr->conf_mt);

	// remove OU info
	cbccd_pgsql_rm_guid_tbl_data(&conf_mgr->c->pgsql_mgr, CBCC_DB_CONN_TYPE_CONFIG, CBCCD_TBL_NAME_OU_INFO, ou_guid);

	return;
}

// set OU as default
int cbccd_config_set_default_ou(cbccd_config_mgr_t *conf_mgr, const char *ou_guid)
{
	cbcc_config_ou_info_t *ou_info;

	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_HIGH, "CONFIG: Setting OU info '%s' as default", ou_guid);

	// lock config manager
	pthread_mutex_lock(&conf_mgr->conf_mt);

	// get OU info by guid
	ou_info = get_ou_info(&conf_mgr->ou_list, ou_guid);
	if (!ou_info)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "CONFIG: Could not found OU info '%s'", ou_guid);

		// unlock config manager
		pthread_mutex_unlock(&conf_mgr->conf_mt);
		return CBCC_RESP_NOT_FOUND_OU;
	}

	// set default OU info into database
	set_default_ou(conf_mgr, ou_info);

	// unlock config manager
	pthread_mutex_unlock(&conf_mgr->conf_mt);

	return CBCC_RESP_OK;
}

// get default OU info
cbcc_config_ou_info_t *cbccd_config_get_default_ou(cbccd_config_mgr_t *conf_mgr)
{
	return conf_mgr->ou_list.default_ou_info;
}

// get OU info by OU guid
cbcc_config_ou_info_t *cbccd_config_get_ou_by_guid(cbccd_config_mgr_t *conf_mgr, const char *ou_guid)
{
	return get_ou_info(&conf_mgr->ou_list, ou_guid);
}
