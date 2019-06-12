#ifndef __CBCCD_ADMIN_H__
#define __CBCCD_ADMIN_H__

// backup info structure
typedef struct _cbccd_backup_info
{
	int auto_backup;
	
	time_t timestamp;

	char guid[CBCC_MAX_GUID_LEN];
	char comment[CBCC_MAX_COMMENT_LEN];

	char file_path[CBCC_MAX_PATH];
	char file_name[CBCC_MAX_PATH];
	int file_size;
	char md5sum[CBCC_MD5SUM_LEN * 2 + 1];
	
	char *base64_encoded;

	char version[CBCC_MAX_VER_LEN];
	char user[CBCC_MAX_UNAME_LEN];
} cbccd_backup_info_t;

// action state
enum CBCC_ACT_STATUS
{
	CBCC_ACT_STATUS_SCHED,
	CBCC_ACT_STATUS_PENDING,
	CBCC_ACT_STATUS_FAILURE,
	CBCC_ACT_STATUS_SUCCESS,
	CBCC_ACT_STATUS_FINISHED,
	CBCC_ACT_STATUS_UNKNOWN,
};

#define CBCC_ACT_STATUS_SCHED_STR			"scheduled"
#define CBCC_ACT_STATUS_PENDING_STR			"pending"
#define CBCC_ACT_STATUS_FAILURE_STR			"failure"
#define CBCC_ACT_STATUS_SUCCESS_STR			"success"
#define CBCC_ACT_STATUS_FINISHED_STR			"finished"

// auto backup interval type
enum CBCC_AUTO_BA_INTERVAL_TYPE
{
	CBCC_AUTO_BA_INTERVAL_TYPE_DAILY,
	CBCC_AUTO_BA_INTERVAL_TYPE_WEEKLY,
	CBCC_AUTO_BA_INTERVAL_TYPE_MONTHLY,
	CBCC_AUTO_BA_INTERVAL_TYPE_UNKNOWN,
};

#define CBCC_AUTO_BA_INTERVAL_TYPE_DAILY_STR		"daily"
#define CBCC_AUTO_BA_INTERVAL_TYPE_WEEKLY_STR		"weekly"
#define CBCC_AUTO_BA_INTERVAL_TYPE_MONTHLY_STR		"monthly"

#define CBCC_AUTO_BA_COMMENT				"Auto Backup"
#define CBCC_AUTO_BA_USER				"admin"

// backup timestamp info
typedef struct _cbccd_backup_ts_info
{
	int timestamp;
	const char *guid;
} cbccd_backup_ts_info_t;

// auto backup info
typedef struct _cbccd_auto_backup_info
{
	int status;

	enum CBCC_AUTO_BA_INTERVAL_TYPE interval_type;
	int max_keep_backups;

	int enqueued_starttime;
	int next_starttime;

	bool take_backup;
} cbccd_auto_backup_info_t;

// action execution type
enum CBCC_EXEC_TYPE
{
	CBCC_EXEC_TYPE_ONCE = 0,
	CBCC_EXEC_TYPE_DAILY,
	CBCC_EXEC_TYPE_UNKNOWN,
};

#define CBCC_EXEC_TYPE_ONCE_STR			"once"
#define CBCC_EXEC_TYPE_DAILY_STR		"daily"

// cbccd admin action info structure
typedef struct _cbccd_admin_action_info
{
	enum CBCC_ACTION_TYPE act_type;
	enum CBCC_EXEC_TYPE exec_type;
	enum CBCC_ACTION_TYPE status_type;

	cbcc_json_pairs_t dev_guids;
	cbcc_json_array_t days;					// days when execution type is daily
	
	time_t start;						// action start time
	time_t start_time;
	
	bool take_action;					// flag whether take action
} cbccd_admin_action_info_t;

// cbccd admin structure
typedef struct _cbccd_admin_mgr
{
	bool init_flag;
	bool end_flag;
	
	int interval;
	
	pthread_t pt_sched_act;
	pthread_t pt_auto_backup;
	
	struct _cbccd_ctx *c;
} cbccd_admin_mgr_t;

// send create backup
int cbccd_admin_send_create_backup_cmd(struct _cbccd_ctx *c, const char *backup_guid, const char *dev_guid,
							 const char *comment, const char *user);

// set create backup info
int cbccd_admin_set_create_backup_info(struct _cbccd_ctx *c, int clnt_sock, const char *obj_data);

// restore backup
int cbccd_admin_send_restore_backup_cmd(struct _cbccd_ctx *c, const char *dev_guid, const char *backup_guid);

// delete backup
int cbccd_admin_delete_backup(struct _cbccd_ctx *c, const char *backup_guid, const char *dev_guid);

// delete all backup infos by device guid
void cbccd_admin_delete_all_backups(struct _cbccd_ctx *c, const char *dev_guid);

// action command
int cbccd_admin_send_action_cmd(struct _cbccd_ctx *c, const char *act_str, const char *data);

// init and finalize admin manager
int cbccd_admin_mgr_init(struct _cbccd_ctx *c);
void cbccd_admin_mgr_finalize(cbccd_admin_mgr_t *adm_mgr);

#endif			// __CBCCD_ADMIN_H__
