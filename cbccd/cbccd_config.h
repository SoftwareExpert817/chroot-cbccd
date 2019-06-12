#ifndef __CBCCD_CONFIG_H__
#define __CBCCD_CONFIG_H__

// configuration object types
enum CBCC_CONFIG_OBJECT_TYPE
{
	CBCC_CONFIG_OBJECT_TYPE_NET_GROUP = 0,
	CBCC_CONFIG_OBJECT_TYPE_HOST,
	CBCC_CONFIG_OBJECT_TYPE_NETWORK,
	CBCC_CONFIG_OBJECT_TYPE_SWITCH,
	CBCC_CONFIG_OBJECT_TYPE_MULTICAST,
	CBCC_CONFIG_OBJECT_TYPE_SERVICE_AH,
	CBCC_CONFIG_OBJECT_TYPE_SERVICE_ESP,
	CBCC_CONFIG_OBJECT_TYPE_SERVICE_ICMP,
	CBCC_CONFIG_OBJECT_TYPE_SERVICE_IP,
	CBCC_CONFIG_OBJECT_TYPE_SERVICE_TCP,
	CBCC_CONFIG_OBJECT_TYPE_SERVICE_UDP,
	CBCC_CONFIG_OBJECT_TYPE_SERVICE_TCPUDP,
	CBCC_CONFIG_OBJECT_TYPE_SERVICE_GROUP,
	CBCC_CONFIG_OBJECT_TYPE_TIME_RECURRING,
	CBCC_CONFIG_OBJECT_TYPE_TIME_SINGLE,
	CBCC_CONFIG_OBJECT_TYPE_FW,
	
	CBCC_CONFIG_OBJECT_TYPE_UNKNOWN
};

// configuration object type strings
#define CBCC_CONFIG_OBJECT_TYPE_NET_GROUP_STR			"global_network_group"
#define CBCC_CONFIG_OBJECT_TYPE_HOST_STR				"global_network_host"
#define CBCC_CONFIG_OBJECT_TYPE_NETWORK_STR				"global_network_network"
#define CBCC_CONFIG_OBJECT_TYPE_SWITCH_STR				"global_network_switch"
#define	CBCC_CONFIG_OBJECT_TYPE_MULTICAST_STR			"global_network_multicast"
#define CBCC_CONFIG_OBJECT_TYPE_SERVICE_AH_STR			"global_service_ah"
#define CBCC_CONFIG_OBJECT_TYPE_SERVICE_ESP_STR			"global_service_esp"
#define CBCC_CONFIG_OBJECT_TYPE_SERVICE_ICMP_STR		"global_service_icmp"
#define CBCC_CONFIG_OBJECT_TYPE_SERVICE_IP_STR			"global_service_ip"
#define CBCC_CONFIG_OBJECT_TYPE_SERVICE_TCP_STR			"global_service_tcp"
#define CBCC_CONFIG_OBJECT_TYPE_SERVICE_UDP_STR			"global_service_udp"
#define CBCC_CONFIG_OBJECT_TYPE_SERVICE_TCPUDP_STR		"global_service_tcpudp"
#define CBCC_CONFIG_OBJECT_TYPE_SERVICE_GROUP_STR		"global_service_group"
#define CBCC_CONFIG_OBJECT_TYPE_TIME_RECURRING_STR		"global_time_recurring"
#define CBCC_CONFIG_OBJECT_TYPE_TIME_SINGLE_STR			"global_time_single"
#define CBCC_CONFIG_OBJECT_TYPE_FW_STR					"global_packetfilter_packetfilter"

struct _cbcc_config_ou_info;
struct _cbcc_config_object;

// config object references
typedef struct _cbcc_config_ref
{
	struct _cbcc_config_object *conf_obj;
	struct _cbcc_config_ref *next;
} cbcc_config_ref_t;

// config object structure
typedef struct _cbcc_config_object
{
	enum CBCC_CONFIG_OBJECT_TYPE obj_type;
	
	char obj_guid[CBCC_MAX_GUID_LEN];
	char obj_data[CBCC_MAX_COL_DATA_LEN];
	
	bool is_set;
	
	struct _cbcc_config_ou_info *ou_info;

	int ref_count;
	cbcc_config_ref_t *ref_objs;
	
	struct _cbcc_config_object *next;
	struct _cbcc_config_object *prev;
} cbcc_config_object_t;

// configuration object list
typedef struct _cbcc_config_object_list
{
	int obj_count;
	cbcc_config_object_t *conf_objs;
} cbcc_config_object_list_t;

// configuration OU info
typedef struct _cbcc_config_ou_info
{
	char ou_guid[CBCC_MAX_GUID_LEN];					// OU guid
	char ou_name[CBCC_MAX_OU_NAME_LEN];					// OU name

	bool is_default;									// default OU flag
	
	cbcc_config_object_list_t conf_obj_list;			// config object list

	cbcc_json_array_t conf_obj_arr;						// config object json array
	char conf_md5sum[CBCC_MD5SUM_LEN * 2 + 1];			// md5sum of config list
	
	struct _cbcc_config_ou_info *next;
	struct _cbcc_config_ou_info *prev;
} cbcc_config_ou_info_t;

// configuration OU list
typedef struct _cbcc_config_ou_list
{
	int count;

	cbcc_config_ou_info_t *default_ou_info;					// pointer to default OU info
	cbcc_config_ou_info_t *ou_infos;						// list of OU infos
} cbcc_config_ou_list_t;

// cbccd configuration manager structure
typedef struct _cbccd_config_mgr
{
	bool init_flag;
	bool end_flag;
	
	cbcc_config_ou_list_t ou_list;
	pthread_mutex_t conf_mt;
	
	struct _cbccd_ctx *c;
} cbccd_config_mgr_t;

// send configuration data
int cbccd_config_send_data(cbccd_config_mgr_t *conf_mgr, int clnt_sock, const char *cmd_data);

// add configuration object
int cbccd_config_add_object(cbccd_config_mgr_t *conf_mgr, const char *obj_guid, const char *obj_type, const char *obj_data);
int cbccd_config_delete_object(cbccd_config_mgr_t *conf_mgr, const char *obj_guid, const char *obj_type);
int cbccd_config_edit_object(cbccd_config_mgr_t *conf_mgr, const char *obj_guid, const char *obj_type, const char *obj_data);

// OU management APIs
int cbccd_config_create_ou(cbccd_config_mgr_t *conf_mgr, const char *ou_guid, const char *ou_name, const char *comment, cbcc_json_array_t *dev_guids);
int cbccd_config_edit_ou(cbccd_config_mgr_t *conf_mgr, const char *ou_guid, const char *ou_name, const char *comment, cbcc_json_array_t *dev_guids);
void cbccd_config_delete_ou(cbccd_config_mgr_t *conf_mgr, const char *ou_guid);
int cbccd_config_set_default_ou(cbccd_config_mgr_t *conf_mgr, const char *ou_guid);

cbcc_config_ou_info_t *cbccd_config_get_ou_by_guid(cbccd_config_mgr_t *conf_mgr, const char *ou_guid);
cbcc_config_ou_info_t *cbccd_config_get_default_ou(cbccd_config_mgr_t *conf_mgr);

// initialize and finalize cbccd configuration manager
int cbccd_config_mgr_init(struct _cbccd_ctx *c);
void cbccd_config_mgr_finalize(cbccd_config_mgr_t *conf_mgr);

#endif			// __CBCCD_CONFIG_H__
