#ifndef __CBCCD_DEVICE_H__
#define __CBCCD_DEVICE_H__

// device role flags
#define CBCCD_DEVICE_ROLE_ADMIN			0x0001
#define CBCCD_DEVICE_ROLE_REPORT		0x0002
#define CBCCD_DEVICE_ROLE_MONITOR		0x0004
#define CBCCD_DEVICE_ROLE_CONFIG		0x0008

#define CBCCD_DEVICE_ROLE_ADMIN_STR		"device.admin"
#define CBCCD_DEVICE_ROLE_REPORT_STR		"device.report"
#define CBCCD_DEVICE_ROLE_MONITOR_STR		"device.monitor"
#define CBCCD_DEVICE_ROLE_CONFIG_STR		"device.config"

// device registration status
enum CBCCD_DEVICE_REG_STATUS
{
	CBCCD_DEVICE_REG_STATUS_CONFIRMED,
	CBCCD_DEVICE_REG_STATUS_BLACKLISTED,
	CBCCD_DEVICE_REG_STATUS_UNKNOWN,
};

#define CBCCD_DEVICE_REG_STATUS_CONFIRMED_STR			"CONFIRMED"
#define CBCCD_DEVICE_REG_STATUS_BLACKLISTED_STR			"BLACKLISTED"

// device connection status
enum CBCCD_DEVICE_CONN_STATUS
{
	CBCCD_DEVICE_CONN_STATUS_ONLINE,
	CBCCD_DEVICE_CONN_STATUS_OFFLINE,
	CBCCD_DEVICE_CONN_STATUS_UNKNOWN,
};

#define CBCCD_DEVICE_CONN_STATUS_ONLINE_STR			"ONLINE"
#define CBCCD_DEVICE_CONN_STATUS_OFFLINE_STR			"OFFLINE"

// cbccd device info
typedef struct _cbccd_device_info
{
	int sock;
	
	bool is_logined;
	
	enum CBCCD_DEVICE_CONN_STATUS conn_status;
	enum CBCCD_DEVICE_REG_STATUS reg_status;

	char guid[CBCC_MAX_GUID_LEN];
	char device_ipaddr[CBCC_MAX_IPADDR_LEN];

	cbcc_config_ou_info_t *ou_info;

	int role_type;

	char web_login_cred[CBCC_MAX_HASH_LEN];
	
	time_t updated_tm;
	time_t send_monitor_tm;
	
	struct _cbccd_device_info *next;
	struct _cbccd_device_info *prev;
} cbccd_device_info_t;

// cbccd device info list
typedef struct _cbccd_device_list
{
	int num_of_devices;
	cbccd_device_info_t *dev_infos;
} cbccd_device_list_t;

// confd info
typedef struct _cbccd_confd_info
{
	char secret_key[CBCC_MAX_SECRET_LEN];
} cbccd_confd_info_t;

// device managemnt structure
typedef struct _cbccd_device_mgr
{
	bool init_flag;
	bool end_flag;
	
	cbccd_device_list_t device_list;

	cbccd_confd_info_t confd_info;
	char default_ou[CBCC_MAX_OUNAME_LEN];
	
	pthread_t pt_keepalive;
	
	pthread_mutex_t mt;
	
	struct _cbccd_ctx *c;
} cbccd_device_mgr_t;

// initialize and finalize device manager
int cbccd_device_mgr_init(struct _cbccd_ctx *c);
void cbccd_device_mgr_finalize(cbccd_device_mgr_t *device_mgr);

// mutex lock/unlock function
void cbccd_device_mutex_lock(cbccd_device_mgr_t *device_mgr);
void cbccd_device_mutex_unlock(cbccd_device_mgr_t *device_mgr);

// device login proc
int cbccd_device_login(cbccd_device_mgr_t *device_mgr, int sock, const char *login_cmd_buffer);

// update device status
void cbccd_device_update_status(cbccd_device_mgr_t *device_mgr, int sock);

// set device status into offline
void cbccd_device_set_offline(cbccd_device_mgr_t *device_mgr, int sock, bool expired);

// get device info by socket
cbccd_device_info_t *cbccd_device_get_info_by_sock(cbccd_device_mgr_t *device_mgr, int sock);

// get device info by guid
cbccd_device_info_t *cbccd_device_get_info_by_guid(cbccd_device_mgr_t *device_mgr, const char *guid);

// get web credential info
int cbccd_device_get_webcred(cbccd_device_mgr_t *device_mgr, const char *dev_guid, char *web_cred, size_t s);

// disable agent
int cbccd_device_agent_disable(cbccd_device_mgr_t *device_mgr, bool deny, const char *dev_guid);

// allow agent
int cbccd_device_agent_allow(cbccd_device_mgr_t *device_mgr, const char *dev_guid);

// set OU info
void cbccd_device_set_ou_info(cbccd_device_mgr_t *device_mgr, const char *dev_guid, cbcc_config_ou_info_t *ou_info);

cbccd_device_info_t *add_device_info_by_guid(cbccd_device_mgr_t *device_mgr, const char *dev_guid, const char *dev_info_jstr);
void create_log_objects_info(cbccd_device_mgr_t *device_mgr, const char *guid, const char *dev_info_jstr);
void set_dev_ou_info(cbccd_device_mgr_t *device_mgr, const char *ou_guid, const char *dev_guid);

#endif		// __CBCCD_DEVICE_H__
