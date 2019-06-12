#ifndef __CBCCD_PGSQL_H__
#define __CBCCD_PGSQL_H__

// PostgreSQL database credential
#define CBCC_POSTGRE_DB_NAME			"cbcc"
#define CBCC_POSTGRE_DB_USERNAME		"cbcc"
#define CBCC_POSTGRE_DB_PASSWD			"cbccdbpw"

// PostgreSQL table names
#define CBCCD_TBL_NAME_ACTION_INFO				"action_info"
#define CBCCD_TBL_NAME_AGENT_INFO				"agent_info"
#define CBCCD_TBL_NAME_AUTO_BACKUP				"auto_backup_info"
#define CBCCD_TBL_NAME_CONFD_DATA				"confd_data"
#define CBCCD_TBL_NAME_CONFIG_COMMON			"config_common"
#define CBCCD_TBL_NAME_CONFIG_DEVICE			"config_device"
#define CBCCD_TBL_NAME_DEVICE_BACKUP			"device_backup"
#define CBCCD_TBL_NAME_DEVICE_INFO				"device_info"
#define CBCCD_TBL_NAME_DEVICE_INVENTORY			"device_inventory"
#define CBCCD_TBL_NAME_LOCATION					"device_location"
#define CBCCD_TBL_NAME_DEVICE_OU				"device_ou"
#define CBCCD_TBL_NAME_DEVICE_PRODUCT			"device_product"
#define CBCCD_TBL_NAME_NET_DNS_GRP				"global_network_dns_group"
#define CBCCD_TBL_NAME_NET_DNS_GRP_OU			"global_network_dns_group_ou"
#define CBCCD_TBL_NAME_NET_GRP 					"global_network_group"
#define CBCCD_TBL_NAME_NET_GRP_OU 				"global_network_group_ou"
#define CBCCD_TBL_NAME_NET_HOST					"global_network_host"
#define CBCCD_TBL_NAME_NET_HOST_OU				"global_network_host_ou"
#define CBCCD_TBL_NAME_NET_NET					"global_network_network"
#define CBCCD_TBL_NAME_NET_NET_OU				"global_network_network_ou"
#define CBCCD_TBL_NAME_NET_SWITCH				"global_network_switch"
#define CBCCD_TBL_NAME_NET_SWITCH_OU			"global_network_switch_ou"
#define CBCCD_TBL_NAME_NET_MULTI				"global_network_multicast"
#define CBCCD_TBL_NAME_NET_MULTI_OU				"global_network_multicast_ou"
#define CBCCD_TBL_NAME_OBJ_NET_DNS_GRP			"global_object_network_dns_group"
#define CBCCD_TBL_NAME_OBJ_NET_DNS_HOST			"global_object_network_dns_host"
#define CBCCD_TBL_NAME_OBJ_NET_GRP 				"global_object_network_group"
#define CBCCD_TBL_NAME_OBJ_NET_HOST 			"global_object_network_host"
#define CBCCD_TBL_NAME_OBJ_NET_NET				"global_object_network_network"
#define CBCCD_TBL_NAME_OBJ_NET_MULTI			"global_object_network_multicast"
#define CBCCD_TBL_NAME_OBJ_PF_PF				"global_object_packetfilter_packetfilter"
#define CBCCD_TBL_NAME_OBJ_SRV_AH				"global_object_service_ah"
#define CBCCD_TBL_NAME_OBJ_SRV_ESP				"global_object_service_esp"
#define	CBCCD_TBL_NAME_OBJ_SRV_GRP				"global_object_service_group"
#define CBCCD_TBL_NAME_OBJ_SRV_ICMP				"global_object_service_icmp"
#define CBCCD_TBL_NAME_OBJ_SRV_IP 				"global_object_service_ip"
#define CBCCD_TBL_NAME_OBJ_SRV_TCP				"global_object_service_tcp"
#define CBCCD_TBL_NAME_OBJ_SRV_TCPUDP			"global_object_service_tcpudp"
#define CBCCD_TBL_NAME_OBJ_SRV_UDP 				"global_object_service_udp"
#define CBCCD_TBL_NAME_OBJ_TM_REC				"global_object_time_recurring"
#define CBCCD_TBL_NAME_OBJ_TM_SINGLE			"global_object_time_single"
#define CBCCD_TBL_NAME_PF_PF 					"global_packetfilter_packetfilter"
#define CBCCD_TBL_NAME_PF_PF_OU					"global_packetfilter_packetfilter_ou"
#define CBCCD_TBL_NAME_SRV_AH 					"global_service_ah"
#define CBCCD_TBL_NAME_SRV_AH_OU				"global_service_ah_ou"
#define CBCCD_TBL_NAME_SRV_ESP 					"global_service_esp"
#define CBCCD_TBL_NAME_SRV_ESP_OU				"global_service_esp_ou"
#define	CBCCD_TBL_NAME_SRV_GRP 					"global_service_group"
#define CBCCD_TBL_NAME_SRV_GRP_OU				"global_service_group_ou"
#define CBCCD_TBL_NAME_SRV_ICMP 				"global_service_icmp"
#define CBCCD_TBL_NAME_SRV_ICMP_OU				"global_service_icmp_ou"
#define CBCCD_TBL_NAME_SRV_IP 					"global_service_ip"
#define CBCCD_TBL_NAME_SRV_IP_OU 				"global_service_ip_ou"
#define CBCCD_TBL_NAME_SRV_TCP 					"global_service_tcp"
#define CBCCD_TBL_NAME_SRV_TCP_OU				"global_service_tcp_ou"
#define CBCCD_TBL_NAME_SRV_TCPUDP 				"global_service_tcpudp"
#define CBCCD_TBL_NAME_SRV_TCPUDP_OU			"global_service_tcpudp_ou"
#define CBCCD_TBL_NAME_SRV_UDP 					"global_service_udp"
#define CBCCD_TBL_NAME_SRV_UDP_OU 				"global_service_udp_ou"
#define CBCCD_TBL_NAME_TM_REC 					"global_time_recurring"
#define CBCCD_TBL_NAME_TM_REC_OU				"global_time_recurring_ou"
#define CBCCD_TBL_NAME_TM_SINGLE 				"global_time_single"
#define CBCCD_TBL_NAME_TM_SINGLE_OU				"global_time_single_ou"
#define CBCCD_TBL_NAME_MON_AVAIL				"monitoring_availability"
#define CBCCD_TBL_NAME_MON_DASH					"monitoring_dashboard"
#define CBCCD_TBL_NAME_MON_HW					"monitoring_hardware"
#define CBCCD_TBL_NAME_MON_LIC					"monitoring_license"
#define CBCCD_TBL_NAME_MON_NET					"monitoring_network"
#define CBCCD_TBL_NAME_MON_RES					"monitoring_resource"
#define CBCCD_TBL_NAME_MON_SRV					"monitoring_service"
#define CBCCD_TBL_NAME_NON_THREAT				"monitoring_threat"
#define CBCCD_TBL_NAME_MON_VER					"monitoring_version"
#define CBCCD_TBL_NAME_OU_DEFAULT				"ou_default"
#define CBCCD_TBL_NAME_OU_INFO					"ou_info"
#define CBCCD_TBL_NAME_REPORT_HW				"reporting_hardware"
#define CBCCD_TBL_NAME_REPORT_NET				"reporting_network"
#define CBCCD_TBL_NAME_REPORT_SEC				"reporting_security"

#define CBCCD_MAX_TBL_NUM						75

// cbccd table data
typedef struct _cbccd_tbl_row
{
	char guid[CBCC_MAX_GUID_LEN];
	char data[CBCC_MAX_COL_DATA_LEN];
	char changelog_type[CBCC_MAX_COL_DATA_LEN];

	int rev;							//it's only for cache manager.revision of each row

	struct _cbccd_tbl_row *next;
	struct _cbccd_tbl_row *prev;
} cbccd_tbl_row_t;

// cbccd table info
typedef struct _cbccd_tbl_info
{
	char tbl_name[CBCC_MAX_TBL_NAME_LEN];

	int rows_count;
	cbccd_tbl_row_t *rows;

	int total_rev;						// it's only for cache manager.revision of cache memory
} cbccd_tbl_info_t;

// CBCCD postgres DB connection types
enum CBCC_DB_CONN_TYPES
{
	CBCC_DB_CONN_TYPE_MAIN = 0,
	CBCC_DB_CONN_TYPE_MON,
	CBCC_DB_CONN_TYPE_REPORT,
	CBCC_DB_CONN_TYPE_ADMIN,
	CBCC_DB_CONN_TYPE_CONFIG,
	
	CBCC_DB_CONN_TYPE_NUM
};

// CBCCD postgres SQL manager
typedef struct _cbccd_pgsql_mgr
{
	bool init_flag;

	PGconn **db_conns;
	pthread_mutex_t mutex;

	cbccd_tbl_info_t tbl_infos[CBCCD_MAX_TBL_NUM];				// cache holding database contents
	cbccd_tbl_info_t changelog_info;							// this cache is not included in database

	struct _cbccd_ctx *c;
} cbccd_pgsql_mgr_t;

// postgres SQL manager API
int cbccd_pgsql_mgr_init(struct _cbccd_ctx *c);
void cbccd_pgsql_mgr_finalize(cbccd_pgsql_mgr_t *pgsql_mgr);

int cbccd_pgsql_set_guid_tbl_data(cbccd_pgsql_mgr_t *pgsql_mgr, enum CBCC_DB_CONN_TYPES conn_type, const char *tbl_name, const char *guid, const char *data);
void cbccd_pgsql_rm_guid_tbl_data(cbccd_pgsql_mgr_t *pgsql_mgr, enum CBCC_DB_CONN_TYPES conn_type, const char *tbl_name, const char *guid);

int cbccd_pgsql_get_tbl_idx(const char *tbl_name);

// API functions related with database cache
int cbccd_pgsql_cache_get_tbl_data(cbccd_pgsql_mgr_t *pgsql_mgr, int tbl_idx, const char *guid, char **data);
int cbccd_pgsql_cache_get_tbl_rows(cbccd_pgsql_mgr_t *pgsql_mgr, int tbl_idx, cbccd_tbl_row_t **rows);
void cbccd_pgsql_cache_get_tbl_list(cbccd_pgsql_mgr_t *pgsql_mgr, int tbl_idx, char **data);

// API functions related with cache
void cbccd_pgsql_set_cache(cbccd_pgsql_mgr_t *pgsql_mgr, const char *guid, const char *data);
void cbccd_pgsql_get_cache(cbccd_pgsql_mgr_t *pgsql_mgr, int read_min_rev, char **data);
void cbccd_pgsql_get_cache_rev(cbccd_pgsql_mgr_t *pgsql_mgr, char **data);

#endif		// __CBCCD_PGSQL_H__
