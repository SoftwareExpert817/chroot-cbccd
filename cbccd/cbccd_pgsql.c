
#include "cbccd.h"

// all table names
static const char *cbccd_tbl_names[] =
{
	CBCCD_TBL_NAME_ACTION_INFO,
	CBCCD_TBL_NAME_AGENT_INFO,
	CBCCD_TBL_NAME_AUTO_BACKUP,
	CBCCD_TBL_NAME_CONFD_DATA,
	CBCCD_TBL_NAME_CONFIG_COMMON,
	CBCCD_TBL_NAME_CONFIG_DEVICE,
	CBCCD_TBL_NAME_DEVICE_BACKUP,
	CBCCD_TBL_NAME_DEVICE_INFO,
	CBCCD_TBL_NAME_DEVICE_INVENTORY,
	CBCCD_TBL_NAME_LOCATION,
	CBCCD_TBL_NAME_DEVICE_OU,
	CBCCD_TBL_NAME_DEVICE_PRODUCT,
	CBCCD_TBL_NAME_NET_DNS_GRP,
	CBCCD_TBL_NAME_NET_DNS_GRP_OU,
	CBCCD_TBL_NAME_NET_GRP,
	CBCCD_TBL_NAME_NET_GRP_OU,
	CBCCD_TBL_NAME_NET_HOST,
	CBCCD_TBL_NAME_NET_HOST_OU,
	CBCCD_TBL_NAME_NET_NET,
	CBCCD_TBL_NAME_NET_NET_OU,
	CBCCD_TBL_NAME_NET_SWITCH,
	CBCCD_TBL_NAME_NET_SWITCH_OU,
	CBCCD_TBL_NAME_NET_MULTI,
	CBCCD_TBL_NAME_NET_MULTI_OU,
	CBCCD_TBL_NAME_OBJ_NET_DNS_GRP,
	CBCCD_TBL_NAME_OBJ_NET_DNS_HOST,
	CBCCD_TBL_NAME_OBJ_NET_GRP,
	CBCCD_TBL_NAME_OBJ_NET_HOST,
	CBCCD_TBL_NAME_OBJ_NET_NET,
	CBCCD_TBL_NAME_OBJ_NET_MULTI,
	CBCCD_TBL_NAME_OBJ_PF_PF,
	CBCCD_TBL_NAME_OBJ_SRV_AH,
	CBCCD_TBL_NAME_OBJ_SRV_ESP,
	CBCCD_TBL_NAME_OBJ_SRV_GRP,
	CBCCD_TBL_NAME_OBJ_SRV_ICMP,
	CBCCD_TBL_NAME_OBJ_SRV_IP,
	CBCCD_TBL_NAME_OBJ_SRV_TCP,
	CBCCD_TBL_NAME_OBJ_SRV_TCPUDP,
	CBCCD_TBL_NAME_OBJ_SRV_UDP,
	CBCCD_TBL_NAME_OBJ_TM_REC,
	CBCCD_TBL_NAME_OBJ_TM_SINGLE,
	CBCCD_TBL_NAME_PF_PF,
	CBCCD_TBL_NAME_PF_PF_OU,
	CBCCD_TBL_NAME_SRV_AH,
	CBCCD_TBL_NAME_SRV_AH_OU,
	CBCCD_TBL_NAME_SRV_ESP,
	CBCCD_TBL_NAME_SRV_ESP_OU,
	CBCCD_TBL_NAME_SRV_GRP,
	CBCCD_TBL_NAME_SRV_GRP_OU,
	CBCCD_TBL_NAME_SRV_ICMP,
	CBCCD_TBL_NAME_SRV_ICMP_OU,
	CBCCD_TBL_NAME_SRV_IP,
	CBCCD_TBL_NAME_SRV_IP_OU,
	CBCCD_TBL_NAME_SRV_TCP,
	CBCCD_TBL_NAME_SRV_TCP_OU,
	CBCCD_TBL_NAME_SRV_TCPUDP,
	CBCCD_TBL_NAME_SRV_TCPUDP_OU,
	CBCCD_TBL_NAME_SRV_UDP,
	CBCCD_TBL_NAME_SRV_UDP_OU,
	CBCCD_TBL_NAME_TM_REC,
	CBCCD_TBL_NAME_TM_REC_OU,
	CBCCD_TBL_NAME_TM_SINGLE,
	CBCCD_TBL_NAME_TM_SINGLE_OU,
	CBCCD_TBL_NAME_MON_AVAIL,
	CBCCD_TBL_NAME_MON_DASH,
	CBCCD_TBL_NAME_MON_HW,
	CBCCD_TBL_NAME_MON_LIC,
	CBCCD_TBL_NAME_MON_NET,
	CBCCD_TBL_NAME_MON_RES,
	CBCCD_TBL_NAME_MON_SRV,
	CBCCD_TBL_NAME_NON_THREAT,
	CBCCD_TBL_NAME_MON_VER,
	CBCCD_TBL_NAME_OU_DEFAULT,
	CBCCD_TBL_NAME_OU_INFO,
	CBCCD_TBL_NAME_REPORT_HW,
	CBCCD_TBL_NAME_REPORT_NET,
	CBCCD_TBL_NAME_REPORT_SEC,
	NULL
};

// free all table rows
static void free_tbl_rows(cbccd_tbl_row_t *rows)
{
	// check NULL pointer
	if (!rows)
		return;

	// free next row
	if (rows->next)
		free_tbl_rows(rows->next);

	// free self
	free(rows);

	return;
}

// free all table contents
static void free_all_db_caches(cbccd_tbl_info_t *tbl_infos)
{
	for (int i = 0; i < CBCCD_MAX_TBL_NUM; i++)
	{
		// free old table data
		if (tbl_infos[i].rows_count == 0)
			continue;

		free_tbl_rows(tbl_infos[i].rows);
		tbl_infos[i].rows_count = 0;
	}

	return;
}

// remove table row
static void remove_tbl_row(cbccd_tbl_info_t *tbl_info, cbccd_tbl_row_t *row)
{
	// check given row is head
	if (tbl_info->rows == row)
	{
		tbl_info->rows = row->next;
		if (row->next)
			row->next->prev = NULL;
	}
	else
	{
		// set prev and next pointer
		if (row->prev)
			row->prev->next = row->next;
		if (row->next)
			row->next->prev = row->prev;
	}

	// free row info
	free(row);

	// decrease count of rows
	tbl_info->rows_count--;

	if (tbl_info->rows_count == 0)
		tbl_info->rows = NULL;

	return;
}

// add table row
static void add_tbl_row(cbccd_tbl_info_t *tbl_info, const char *guid, const char *data)
{
	// allocate new memory for table row
	cbccd_tbl_row_t *row = (cbccd_tbl_row_t *) malloc(sizeof(cbccd_tbl_row_t));
	memset(row, 0, sizeof(cbccd_tbl_row_t));

	// set guid and data
	strcpy(row->guid, guid);
	strcpy(row->data, data);

	// set first row
	if (tbl_info->rows_count == 0)
	{
		tbl_info->rows = row;

		//set count
		tbl_info->rows_count++;

		return;
	}

	// set row info
	cbccd_tbl_row_t *p = tbl_info->rows;
	while (p->next)
		p = p->next;

	p->next = row;
	row->prev = p;

	// increase count
	tbl_info->rows_count++;
	//revision up:each&total
	tbl_info->total_rev++;
	row->rev = tbl_info->total_rev;

	return;
}

// get table row
static cbccd_tbl_row_t *get_tbl_row(cbccd_tbl_info_t *tbl_info, const char *guid)
{
	cbccd_tbl_row_t *row = tbl_info->rows;
	while (row)
	{
		// check guid
		if (strcmp(row->guid, guid) == 0)
			return row;

		row = row->next;
	}

	return NULL;
}

// set table row
static void set_tbl_row(cbccd_tbl_row_t *row, const char *guid, const char *data)
{
	// initialize row info
	memset(row, 0, sizeof(cbccd_tbl_row_t));

	// set row info
	strcpy(row->guid, guid);
	strcpy(row->data, data);

	return;
}

// get table data from given table
static int get_all_tbl_data(cbccd_pgsql_mgr_t *pgsql_mgr, enum CBCC_DB_CONN_TYPES conn_type,
					 const char *tbl_name, cbccd_tbl_row_t **tbl_data)
{
	PGresult *res;
	char sql[CBCC_MAX_SQL_LEN];
	
	int col_counts;

	PGconn *conn = pgsql_mgr->db_conns[conn_type];
	
	// make sql string
	snprintf(sql, sizeof(sql), "SELECT * FROM %s", tbl_name);
	
	// run sql
	res = PQexec(conn, sql);
	if (PQresultStatus(res) != PGRES_TUPLES_OK)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_HIGH, "DB: Could not execute SQL due to '%s'", PQerrorMessage(conn));

		PQclear(res);
		return 0;
	}
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_VERBOSE, "DB: Executing sql '%s' has succeeded.", sql);
	
	// get column index
	col_counts = PQntuples(res);
	if (col_counts < 1)
	{
		PQclear(res);
		return 0;
	}
	
	cbccd_tbl_row_t *p = (cbccd_tbl_row_t *) malloc(col_counts * sizeof(cbccd_tbl_row_t));
	if (!p)
	{
		PQclear(res);
		return 0;
	}
	
	memset(p, 0, col_counts * sizeof(cbccd_tbl_row_t));
	
	for (int i = 0; i < col_counts; i++)
	{
		strcpy(p[i].guid, PQgetvalue(res, i, 0));
		strcpy(p[i].data, PQgetvalue(res, i, 1));
	}
	
	// clear PQ execution result
	PQclear(res);
	
	// set table data
	*tbl_data = p;
	
	return col_counts;
}

// read all table contents from database
static void read_all_db_contents(cbccd_pgsql_mgr_t *pgsql_mgr)
{
	// free all db contents
	free_all_db_caches(pgsql_mgr->tbl_infos);

	// read all db contents
	for (int i = 0; i < CBCCD_MAX_TBL_NUM; i++)
	{
		cbccd_tbl_info_t *tbl_info = &pgsql_mgr->tbl_infos[i];
		cbccd_tbl_row_t *rows = NULL;

		// check table name is NULL
		if (cbccd_tbl_names[i] == NULL)
			break;

		// set table name
		if (strlen(tbl_info->tbl_name) == 0)
			strcpy(tbl_info->tbl_name, cbccd_tbl_names[i]);

		// get table rows
		int rows_count = get_all_tbl_data(pgsql_mgr, CBCC_DB_CONN_TYPE_MAIN, cbccd_tbl_names[i], &rows);
		for (int rows_idx = 0; rows_idx < rows_count; rows_idx++)
		{
			add_tbl_row(tbl_info, rows[rows_idx].guid, rows[rows_idx].data);
		}
		
		// free rows
		if (rows)
		    free(rows);
	}

	return;
}

// update db changelog info
static void set_changlog_info(cbccd_pgsql_mgr_t *pgsql_mgr, const char *tbl_name, const char *guid, const char *data, const char *changelog_type)
{
	cbccd_tbl_info_t *cache_info = &pgsql_mgr->changelog_info;
	
	// allocate new memory for table row
	cbccd_tbl_row_t *row = (cbccd_tbl_row_t *) malloc(sizeof(cbccd_tbl_row_t));
	memset(row, 0, sizeof(cbccd_tbl_row_t));

	// set guid and data and changed type and revision
	strcpy(row->guid, guid);
	strcpy(row->data, data);
	strcpy(row->changelog_type, changelog_type);

	strcpy(cache_info->tbl_name, tbl_name);

	row->rev = cache_info->total_rev + 1;

	// set first row
	if (cache_info->rows_count == 0)
	{
		cache_info->rows = row;

		//set count
		cache_info->rows_count++;

		//set revision
		cache_info->total_rev++;

		return;
	}

	// set row info
	cbccd_tbl_row_t *p = cache_info->rows;
	while (p->next)
		p = p->next;

	p->next = row;
	row->prev = p;

	//increase revision
	cache_info->total_rev++;

	// increase count
	cache_info->rows_count++;

	return;
}

// update db contents
static void update_db_cache(cbccd_pgsql_mgr_t *pgsql_mgr, const char *tbl_name, const char *guid, const char *data)
{
	for (int i = 0; i < CBCCD_MAX_TBL_NUM; i++)
	{
		cbccd_tbl_info_t *tbl_info = &pgsql_mgr->tbl_infos[i];
		cbccd_tbl_row_t *p = tbl_info->rows;

		// check table name
		if (strcmp(tbl_name, tbl_info->tbl_name) != 0)
			continue;

		// update data if exist
		while (p)
		{
			// check guid is same
			if (strcmp(p->guid, guid) == 0)
			{
				//to set the changed row into cache_info 
				cbccd_tbl_row_t *nextrow = p->next;
				cbccd_tbl_row_t *prevrow = p->prev;

				set_tbl_row(p, guid, data);
		
				//setting the changed row into cache_info
				p->next = nextrow;
				p->prev = prevrow;
				return;
			}

			p = p->next;
		}

		add_tbl_row(tbl_info, guid, data);
		break;
	}

	return;
}

// remove table row
static void remove_db_cache(cbccd_pgsql_mgr_t *pgsql_mgr, const char *tbl_name, const char *guid)
{
	for (int i = 0; i < CBCCD_MAX_TBL_NUM; i++)
	{
		cbccd_tbl_info_t *tbl_info = &pgsql_mgr->tbl_infos[i];

		// check table name
		if (strcmp(tbl_info->tbl_name, tbl_name) != 0)
			continue;

		// remove row from table list
		cbccd_tbl_row_t *row = tbl_info->rows;
		while (row)
		{
			// check guid
			if (strcmp(row->guid, guid) == 0)
			{
				remove_tbl_row(tbl_info, row);
				return;
			}

			row = row->next;
		}

		break;
	}

	return;		
}

// free all DB connections
static void cbccd_free_all_db_conns(cbccd_pgsql_mgr_t *pgsql_mgr)
{
	// finish all DB connections
	for (int i = 0; i < CBCC_DB_CONN_TYPE_NUM; i++)
	{
		PGconn *conn = pgsql_mgr->db_conns[i];
		if (!conn)
			continue;
		
		PQfinish(conn);
	}
	
	// free DB connection object
	free(pgsql_mgr->db_conns);
	
	return;
}

// initialize postgresql manager
int cbccd_pgsql_mgr_init(struct _cbccd_ctx *c)
{
	cbccd_pgsql_mgr_t *pgsql_mgr = &c->pgsql_mgr;
	char pgsql_conn_string[CBCC_MAX_PGSQL_CONNSTR_LEN];
	
	int i;
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "DB: Initializing PostgreSQL manager.");
	
	// set connection string
	snprintf(pgsql_conn_string, sizeof(pgsql_conn_string), "dbname = %s user = %s password = %s", 
				CBCC_POSTGRE_DB_NAME, CBCC_POSTGRE_DB_USERNAME, CBCC_POSTGRE_DB_PASSWD);
				
	// allocate memory for DB conn info
	pgsql_mgr->db_conns = (PGconn **) malloc(CBCC_DB_CONN_TYPE_NUM * sizeof(PGconn *));
	if (!pgsql_mgr->db_conns)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "DB: Out of memory!");
		return -1;
	}
	
	memset(pgsql_mgr->db_conns, 0, CBCC_DB_CONN_TYPE_NUM * sizeof(PGconn *));
	
	// connect to database
	for (i = 0; i < CBCC_DB_CONN_TYPE_NUM; i++)
	{
		pgsql_mgr->db_conns[i] = PQconnectdb(pgsql_conn_string);
		if (PQstatus(pgsql_mgr->db_conns[i]) != CONNECTION_OK)
		{
			CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "DB: Could not connect to PostgreSQL database due to '%s'", PQerrorMessage(pgsql_mgr->db_conns[i]));
			cbccd_free_all_db_conns(pgsql_mgr);
			
			return -1;
		}
	}

	// initialize mutex
	pthread_mutex_init(&pgsql_mgr->mutex, NULL);
	
	// read all database contents
	read_all_db_contents(pgsql_mgr);
	
	// set context object
	pgsql_mgr->c = c;
	pgsql_mgr->init_flag = true;
	
	return 0;
}

// finalize postgressql manager
void cbccd_pgsql_mgr_finalize(cbccd_pgsql_mgr_t *pgsql_mgr)
{
	// check init flag
	if (!pgsql_mgr->init_flag)
		return;
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "DB: Finalizing PostgreSQL manager.");
	
	// finalize mutexs
	pthread_mutex_destroy(&pgsql_mgr->mutex);

	// free all db contents
	free_all_db_caches(pgsql_mgr->tbl_infos);
	
	// free cache info
	free_tbl_rows(pgsql_mgr->changelog_info.rows);
	
	// finalize connection
	cbccd_free_all_db_conns(pgsql_mgr);
	
	return;
}

// set monitoring table data
int cbccd_pgsql_set_guid_tbl_data(cbccd_pgsql_mgr_t *pgsql_mgr, enum CBCC_DB_CONN_TYPES conn_type, const char *tbl_name, const char *guid, const char *data)
{
	// get device info by guid
	cbccd_device_info_t *device_info = cbccd_device_get_info_by_guid(&pgsql_mgr->c->device_mgr, guid);
	// if (device_info)
	// {
	// 	// set socket descriptor
	// 	// device_info->sock = sock;
	
	// 	// check device is in blacklist
	// 	if (device_info->reg_status == CBCCD_DEVICE_REG_STATUS_BLACKLISTED)
	// 	{
	// 		CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "DEVICE: The device '%s' is in blacklist. Login will be dropped", guid);
	// 		return CBCC_RESP_DEVICE_IN_BLACKLIST;
	// 	}
	// }
	// else
	// char dev_info_jstr[CBCC_MAX_JSON_DATA_LEN];
	if (!device_info)
	{
		// mutex lock
		cbccd_device_mutex_lock(&pgsql_mgr->c->device_mgr);
		device_info = add_device_info_by_guid(&pgsql_mgr->c->device_mgr, guid, data);
		cbccd_device_mutex_unlock(&pgsql_mgr->c->device_mgr);

		if (!device_info)
		{
			CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "DEVICE: Could not add device info by guid '%s'", guid);
			return CBCC_RESP_JSON_INVALID;
		}
		
		// create info into log_objects table
		create_log_objects_info(&pgsql_mgr->c->device_mgr, guid, data);

		// set socket descriptor
		// device_info->sock = sock;

		// create OU info for device
		cbcc_config_ou_info_t *default_ou = cbccd_config_get_default_ou(&pgsql_mgr->c->conf_mgr);
		if (default_ou)
		{
			set_dev_ou_info(&pgsql_mgr->c->device_mgr, default_ou->ou_guid, guid);
		}
	}
	
	PGresult *res;
	
	char sql[CBCC_MAX_SQL_LEN];
	
	pthread_mutex_lock(&pgsql_mgr->mutex);
	
	// get connection by type
	PGconn *conn = pgsql_mgr->db_conns[conn_type];
	
	// make sql string
	snprintf(sql, sizeof(sql), "SELECT * FROM %s WHERE guid='%s'", tbl_name, guid);
	
	// run sql
	res = PQexec(conn, sql);
	if (PQresultStatus(res) != PGRES_TUPLES_OK)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_HIGH, "DB: Could not execute SQL due to '%s'", PQerrorMessage(conn));
	
		PQclear(res);
		pthread_mutex_unlock(&pgsql_mgr->mutex);
		
		return -1;
	}
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_VERBOSE, "DB: Executing sql '%s' has succeeded.", sql);
	
	const char *changelog_type;

	if (PQntuples(res) > 0)
	{
		snprintf(sql, sizeof(sql), "UPDATE %s SET data = '%s' WHERE guid = '%s'", tbl_name, data, guid);
		changelog_type = "update";
	}
	else
	{
		snprintf(sql, sizeof(sql), "INSERT INTO %s VALUES ('%s','%s')", tbl_name, guid, data);
		changelog_type = "insert";
	}
	
	// clear execution result
	PQclear(res);
	
	// run sql
	res = PQexec(conn, sql);
	if (PQresultStatus(res) != PGRES_COMMAND_OK)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_HIGH, "DB: Could not execute SQL due to '%s'", PQerrorMessage(conn));

		PQclear(res);
		pthread_mutex_unlock(&pgsql_mgr->mutex);

		return -1;
	}
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_VERBOSE, "DB: Executing sql '%s' has succeeded.", sql);

	// update database caching
	update_db_cache(pgsql_mgr, tbl_name, guid, data);

	// set database changlog information
	set_changlog_info(pgsql_mgr, tbl_name, guid, data, changelog_type);
	
	PQclear(res);
	pthread_mutex_unlock(&pgsql_mgr->mutex);
	
	return 0;
}

// remove guid table data
void cbccd_pgsql_rm_guid_tbl_data(cbccd_pgsql_mgr_t *pgsql_mgr, enum CBCC_DB_CONN_TYPES conn_type, const char *tbl_name, const char *guid)
{
	PGresult *res;
	char sql[CBCC_MAX_SQL_LEN];
	
	pthread_mutex_lock(&pgsql_mgr->mutex);
	
	PGconn *conn = pgsql_mgr->db_conns[conn_type];

	// make sql string
	snprintf(sql, sizeof(sql), "DELETE FROM %s WHERE guid='%s'", tbl_name, guid);
	
	// run sql
	res = PQexec(conn, sql);
	if (PQresultStatus(res) != PGRES_COMMAND_OK)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_HIGH, "DB: Could not execute SQL '%s' due to '%s'", sql, PQerrorMessage(conn));

		PQclear(res);
		pthread_mutex_unlock(&pgsql_mgr->mutex);
		
		return;
	}
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_VERBOSE, "DB: Executing sql '%s' has succeeded.", sql);
	
	const char *changelog_type = "delete";

	// remove row from cache
	remove_db_cache(pgsql_mgr, tbl_name, guid);

	// set database changlog information
	set_changlog_info(pgsql_mgr, tbl_name, guid, "data is deleted,so no data", changelog_type);
	
	// clear PQ execution result
	PQclear(res);

	pthread_mutex_unlock(&pgsql_mgr->mutex);
	
	return;
}

// get table index
int cbccd_pgsql_get_tbl_idx(const char *tbl_name)
{
	for (int i = 0; i < CBCCD_MAX_TBL_NUM; i++)
	{
		// check table list is reached
		if (cbccd_tbl_names[i] == NULL)
			break;

		// check table name
		if (strcmp(tbl_name, cbccd_tbl_names[i]) == 0)
			return i;
	}

	return -1;
}

// get table data by guid from database cache
int cbccd_pgsql_cache_get_tbl_data(cbccd_pgsql_mgr_t *pgsql_mgr, int tbl_idx, const char *guid, char **data)
{
	cbccd_tbl_info_t *tbl_info = &pgsql_mgr->tbl_infos[tbl_idx];
	int ret = -1;
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_VERBOSE, "DB: Getting table data from cache '%s' by guid '%s'", tbl_info->tbl_name, guid);

	// lock cache
	// pthread_mutex_lock(&pgsql_mgr->mutex);
	cbccd_tbl_row_t *p = tbl_info->rows;
	while (p)
	{
		// if guid is NULL, then return first row data
		// otherwise, check guid is same
		if (!guid || strcmp(p->guid, guid) == 0)
		{
			// allocate memory for data
			char *buf = (char *) malloc(strlen(p->data) + 1);
			if (!buf)
				break;
			// set table data
			strcpy(buf, p->data);
			buf[strlen(p->data)] = '\0';
			*data = buf;
			CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_VERBOSE, "DB: Found data '%s' from cache", buf);

			ret = 0;
			break;
		}
		p = p->next;
	}
	// unlock cache
	// pthread_mutex_unlock(&pgsql_mgr->mutex);

	return ret;
}

// get all table rows from database cache
int cbccd_pgsql_cache_get_tbl_rows(cbccd_pgsql_mgr_t *pgsql_mgr, int tbl_idx, cbccd_tbl_row_t **rows)
{
	cbccd_tbl_info_t *tbl_info = &pgsql_mgr->tbl_infos[tbl_idx];
	int count = tbl_info->rows_count;

	int row_idx = 0;

	// check count
	if (count == 0)
		return 0;

	// lock cache
	pthread_mutex_lock(&pgsql_mgr->mutex);

	// allocate memory for returned rows
	cbccd_tbl_row_t *p = (cbccd_tbl_row_t *) malloc(count * sizeof(cbccd_tbl_row_t));
	memset(p, 0, sizeof(count * sizeof(cbccd_tbl_row_t)));

	cbccd_tbl_row_t *row = tbl_info->rows;
	while (row)
	{
		// set guid and data
		strcpy(p[row_idx].guid, row->guid);
		strcpy(p[row_idx].data, row->data);

		row = row->next;
		row_idx++;
	}

	*rows = p;

	// unlock cache
	pthread_mutex_unlock(&pgsql_mgr->mutex);

	return count;
}

// get table data list from database cache
void cbccd_pgsql_cache_get_tbl_list(cbccd_pgsql_mgr_t *pgsql_mgr, int tbl_idx, char **data)
{
	cbccd_tbl_info_t *tbl_info = &pgsql_mgr->tbl_infos[tbl_idx];
	cbcc_json_array_t tbl_data_arr;
	
	int arr_idx = 0;

	// initialize json array data
	memset(&tbl_data_arr, 0, sizeof(tbl_data_arr));
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_VERBOSE, "DB: Listing all data in table '%s'", cbccd_tbl_names[tbl_idx]);

	// lock cache
	pthread_mutex_lock(&pgsql_mgr->mutex);

	// set count
	tbl_data_arr.arr_len = tbl_info->rows_count;
	cbccd_tbl_row_t *p = tbl_info->rows;
	while (p)
	{
		char *row_jstr;
		
		CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_VERBOSE, "DB: Adding row with guid '%s', data '%s' into list", p->guid, p->data);

		// build json object with one row
		cbcc_json_object_t row_data_jobjs[] =
		{
			{
				.key = "guid",
				.type = CBCC_JSON_DATA_TYPE_STRING,
				.data.str_val_set = p->guid,
			},
			{
				.key = "data",
				.type = CBCC_JSON_DATA_TYPE_OBJECT,
				.obj_exist_data = true,
				.data.str_val_set = p->data,
			}
		};

		cbcc_json_build(row_data_jobjs, CBCC_JOBJS_COUNT(row_data_jobjs), &row_jstr);

		// set json string into array
		strcpy(tbl_data_arr.data.str_vals[arr_idx], row_jstr);

		// free json string
		free(row_jstr);

		p = p->next;
		arr_idx++;
	}

	// unlock cache
	pthread_mutex_unlock(&pgsql_mgr->mutex);

	// build response data
	cbcc_json_object_t resp_data_jobjs[] =
	{
		{
			.key = "list",
			.type = CBCC_JSON_DATA_TYPE_OBJ_ARRAY,
			.data.arr_val = &tbl_data_arr,
		}
	};

	cbcc_json_build(resp_data_jobjs, CBCC_JOBJS_COUNT(resp_data_jobjs), data);

	return;
}

// set cache data
void cbccd_pgsql_set_cache(cbccd_pgsql_mgr_t *pgsql_mgr, const char *guid, const char *data)
{
	// lock mutex
	pthread_mutex_lock(&pgsql_mgr->mutex);
	
	cbccd_tbl_info_t *changelog_info = &pgsql_mgr->changelog_info;

	// get row info by guid
	cbccd_tbl_row_t *row = get_tbl_row(changelog_info, guid);

	if (!row)
		add_tbl_row(changelog_info, guid, data);
	else
	{
		//to set the changed row into cache_info 
		cbccd_tbl_row_t *nextrow = row->next;
		cbccd_tbl_row_t *prevrow = row->prev;

		set_tbl_row(row, guid, data);
		
		//setting the changed row into cache_info
		row->next = nextrow;
		row->prev = prevrow;

		//revision up:each&total
		changelog_info->total_rev++;
		row->rev = changelog_info->total_rev;
	}

	// unlock mutex
	pthread_mutex_unlock(&pgsql_mgr->mutex);

	return;
}

// list cache data
void cbccd_pgsql_get_cache(cbccd_pgsql_mgr_t *pgsql_mgr, int read_rev, char **data)
{
	cbccd_tbl_info_t *cache_info = &pgsql_mgr->changelog_info;
	
	// lock mutex
	pthread_mutex_lock(&pgsql_mgr->mutex);

	cbccd_tbl_row_t *p = cache_info->rows;

	//for (int i = 0; i < rev_num; i++)
	//	p = p->next;

	while (p)
	{
		if (p->rev != read_rev)
		{
			p = p->next;
			continue;
		}

		// build json object with one row
		cbcc_json_object_t row_data_jobjs[] =
		{
			{
				.key = "guid",
				.type = CBCC_JSON_DATA_TYPE_STRING,
				.data.str_val_set = p->guid,
			},
			{
				.key = "data",
				.type = CBCC_JSON_DATA_TYPE_OBJECT,
				.obj_exist_data = true,
				.data.str_val_set = p->data,
			},
			{
				.key = "changed type",
				.type = CBCC_JSON_DATA_TYPE_STRING,
				.data.str_val_set = p->changelog_type
			},
			{
				.key = "table name",
				.type = CBCC_JSON_DATA_TYPE_STRING,
				.data.str_val_set = cache_info->tbl_name
			}
		};

		cbcc_json_build(row_data_jobjs, CBCC_JOBJS_COUNT(row_data_jobjs), data);

		break;
	}
	// unlock mutex
	pthread_mutex_unlock(&pgsql_mgr->mutex);

	return;
}

void cbccd_pgsql_get_cache_rev(cbccd_pgsql_mgr_t *pgsql_mgr, char **data)
{
	cbccd_tbl_info_t *changelog_info = &pgsql_mgr->changelog_info;

	//lock mutex
	pthread_mutex_lock(&pgsql_mgr->mutex);

	cbcc_json_object_t rev_jobjs[] =
	{
		{
			.key = "revision",
			.type = CBCC_JSON_DATA_TYPE_INT,
			.data.int_val_set = changelog_info->total_rev,
		},
		{
			.key = "rows count",
			.type = CBCC_JSON_DATA_TYPE_INT,
			.data.int_val_set = changelog_info->rows_count
		}
	};

	cbcc_json_build(rev_jobjs, CBCC_JOBJS_COUNT(rev_jobjs), data);

	//unlock mutex
	pthread_mutex_unlock(&pgsql_mgr->mutex);

	return;
}
