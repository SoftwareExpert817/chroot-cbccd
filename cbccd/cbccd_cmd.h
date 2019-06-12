#ifndef __CBCCD_CMD_H__
#define __CBCCD_CMD_H__

// cbccd command manager ssl parameters
typedef struct _cbccd_ssl_params
{
	const SSL_METHOD *meth;
	SSL_CTX *ctx;
	
	SSL *ssl[65535];
} cbccd_ssl_params_t;

// cbccd socket address info structure
typedef struct _cbccd_sock_addr_info
{
	char ipaddr[CBCC_MAX_IPADDR_LEN];
	int sport;
} cbccd_sock_addr_info_t;

// cbccd command management structure
typedef struct _cbccd_cmd_mgr
{
	bool init_flag;				// init flag
	bool end_flag;				// end flag
	
	int cmd_srv_sock;			// command listen socket
	
	int max_fd;
	fd_set fds;
	
	pthread_t pt_cmd;			// command process thread ID
	
	cbcc_buffer_list_t buffer_list;		// command buffer list
	
	cbccd_sock_addr_info_t sock_addr_infos[65535];
	cbccd_ssl_params_t ssl_params;
	
	pthread_mutex_t mt;			// mutex for client socket operation
	
	struct _cbccd_ctx *c;			// pointer cbccd context object
} cbccd_cmd_mgr_t;

// cbccd command management API
int	cbccd_cmd_mgr_init(struct _cbccd_ctx *c);
void	cbccd_cmd_mgr_finalize(cbccd_cmd_mgr_t *cmd_mgr);

// send data
int	cbccd_cmd_send(cbccd_cmd_mgr_t *cmd_mgr, int clnt_sock, const char *cmd);

// get ip address by socket
const char *cbccd_cmd_get_ipaddr_by_sock(cbccd_cmd_mgr_t *cmd_mgr, int clnt_sock);

// free socket info
void cbccd_cmd_free_socket(cbccd_cmd_mgr_t *cmd_mgr, int clnt_sock);

#endif		// __CBCCD_CMD_H__
