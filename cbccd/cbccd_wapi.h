#ifndef __CBCCD_WEBAPI_H__
#define __CBCCD_WEBAPI_H__

// WAPI ACTION types
enum CBCC_WAPI_ACT_TYPE
{
	CBCC_WAPI_ACT_ADD = 0,
	CBCC_WAPI_ACT_DELETE,
	CBCC_WAPI_ACT_EDIT,
	CBCC_WAPI_ACT_GET,
	CBCC_WAPI_ACT_LIST,

	CBCC_WAPI_ACT_REBOOT,
	CBCC_WAPI_ACT_SHUTDOWN,
	CBCC_WAPI_ACT_PREFETCH,
	CBCC_WAPI_ACT_FIRMWARE,
	CBCC_WAPI_ACT_PATTERN,

	CBCC_WAPI_ACT_CREATE_BACKUP,
	CBCC_WAPI_ACT_DELETE_BACKUP,
	CBCC_WAPI_ACT_RESTORE_BACKUP,

	CBCC_WAPI_ACT_ADD_OBJ,
	CBCC_WAPI_ACT_DELETE_OBJ,
	CBCC_WAPI_ACT_EDIT_OBJ,

	CBCC_WAPI_ACT_GET_CACHE,
	CBCC_WAPI_ACT_GET_CACHE_REV,

	CBCC_WAPI_ACT_CREATE_OU,
	CBCC_WAPI_ACT_EDIT_OU,
	CBCC_WAPI_ACT_DELETE_OU,
	CBCC_WAPI_ACT_SET_DEFAULT_OU,

	CBCC_WAPI_ACT_DELETE_DEV,
	CBCC_WAPI_ACT_DENY_DEV,
	CBCC_WAPI_ACT_ALLOW_DEV,

	CBCC_WAPI_GET_WEB_CRED,

	CBCC_WAPI_ACT_UNKNOWN,
};

// cbccd wapi request structure
typedef struct _cbccd_wapi_request {
	char action[CBCC_MAX_WAPI_ACT_LEN];
	char type[CBCC_MAX_TBL_NAME_LEN];
	int tbl_idx;
	char *data;
} cbccd_wapi_request_t;

// cbccd web api manager structure
typedef struct _cbccd_wapi_mgr
{
	bool init_flag;
	bool end_flag;
	
	int wapi_sock;
	pthread_t pt_wapi;
	
	pthread_mutex_t mt;
	
	struct _cbccd_ctx *c;
} cbccd_wapi_mgr_t;

// cbccd web api management API
int cbccd_wapi_mgr_init(struct _cbccd_ctx *c);
void cbccd_wapi_mgr_finalize(cbccd_wapi_mgr_t *wapi_mgr);



#endif		// __CBCCD_WEBAPI_H__
