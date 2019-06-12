
#include "cbccd.h"

#include <openssl/err.h>

static void *cbccd_cmd_io(void *p);

// initialize ssl settings
static int init_ssl_settings(cbccd_ctx_t *c)
{
	cbccd_ssl_params_t *ssl_params = &c->cmd_mgr.ssl_params;
	
	if (c->no_ssl)
		return 0;
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "CMD: Initializing SSL settings");
	
	// init ssl library
	SSL_load_error_strings();
	SSLeay_add_ssl_algorithms();
	
	// create ssl method
	ssl_params->meth = SSLv23_server_method();
	if (!ssl_params->meth)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "CMD: Creating SSL method has failed.");
		return -1;
	}
	
	// create ssl context
	ssl_params->ctx = SSL_CTX_new(ssl_params->meth);
	if (!ssl_params->ctx)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "CMD: Creating SSL context object has failed.");
		return -1;
	}
	
	// set certificate and key file
	if (SSL_CTX_use_certificate_file(ssl_params->ctx, CBCCD_CERT_FILE_PATH, SSL_FILETYPE_PEM) <= 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "CMD: Using certificate file '%s' has failed due to '%s'",
					CBCCD_CERT_FILE_PATH, ERR_error_string(ERR_get_error(), NULL));
		SSL_CTX_free(ssl_params->ctx);
		
		return -1;
	}

	if (SSL_CTX_use_PrivateKey_file(ssl_params->ctx, CBCCD_KEY_FILE_PATH, SSL_FILETYPE_PEM) <= 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "CMD: Using private key file '%s' has failed due to '%s'",
					CBCCD_KEY_FILE_PATH, ERR_error_string(ERR_get_error(), NULL));
		SSL_CTX_free(ssl_params->ctx);
		
		return -1;
	}
	
	if (!SSL_CTX_check_private_key(ssl_params->ctx))
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "CMD: Certificate and key file doesn't match");
		SSL_CTX_free(ssl_params->ctx);
		
		return -1;
	}
	
	return 0;
}

// finalize ssl settings
static void finalize_ssl_settings(cbccd_ctx_t *c)
{
	cbccd_ssl_params_t *ssl_params = &c->cmd_mgr.ssl_params;
	
	if (c->no_ssl)
		return;
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "CMD: Finalizing SSL settings");
	
	// free ssl context
	SSL_CTX_free(ssl_params->ctx);
	
	// free loaded ssl strings
	ERR_free_strings();
	
	return;
}

// initialize cbccd command management
int cbccd_cmd_mgr_init(cbccd_ctx_t *c)
{
	cbccd_cmd_mgr_t *cmd_mgr = &c->cmd_mgr;
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "CMD: Initializing CBCC command management.");
	
	// init ssl settings
	if (init_ssl_settings(c) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "CMD: Initializing SSL settings has failed.");
		return -1;
	}
	
	// create socket for listening from CBCC agents
	cmd_mgr->cmd_srv_sock = create_socket();
	if (cmd_mgr->cmd_srv_sock < 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "CMD: Could not create socket for command manager(%s)", strerror(errno));
		return -1;
	}
	
	// set socket as non-blocking mode
	set_non_blocking_sock(cmd_mgr->cmd_srv_sock);
	
	// set listen mode
	if (set_listen_mode(cmd_mgr->cmd_srv_sock, false, CBCCD_CMD_LISTEN_PORT) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "CMD: Could not set socket as listen mode on *:%d(%s)", CBCCD_CMD_LISTEN_PORT, strerror(errno));
		close(cmd_mgr->cmd_srv_sock);

		return -1;
	}
	
	// create thread to process request from agents
	if (pthread_create(&cmd_mgr->pt_cmd, NULL, cbccd_cmd_io, (void *) cmd_mgr) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "CMD: Could not create thread for command I/O");
		close(cmd_mgr->cmd_srv_sock);
		
		return -1;
	}
	
	// initialize mutex
	pthread_mutex_init(&cmd_mgr->mt, NULL);
	
	// set init flag
	cmd_mgr->init_flag = true;
	cmd_mgr->c = c;
	
	return 0;
}

// finalize cbccd command management
void	cbccd_cmd_mgr_finalize(cbccd_cmd_mgr_t *cmd_mgr)
{
	// check init flag
	if (!cmd_mgr->init_flag)
		return;
		
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "CMD: Finalizing command manager");
		
	// set end flag
	cmd_mgr->end_flag = true;
	
	// wait until command I/O thread has terminated
	pthread_join(cmd_mgr->pt_cmd, NULL);
	
	// close command I/O socket
	close(cmd_mgr->cmd_srv_sock);
	
	// free buffer list
	cbcc_buffer_list_free(&cmd_mgr->buffer_list);
	
	// finalize mutex
	pthread_mutex_destroy(&cmd_mgr->mt);
	
	// finalize ssl settings
	finalize_ssl_settings(cmd_mgr->c);
	
	return;
}

// send command via client socket
int cbccd_cmd_send(cbccd_cmd_mgr_t *cmd_mgr, int clnt_sock, const char *cmd)
{
	cbccd_device_info_t *dev_info = cbccd_device_get_info_by_sock(&cmd_mgr->c->device_mgr, clnt_sock);
	int ret;
	
	// device info is available
	if (!dev_info)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "CMD: Could not found device info by socket '%d'", clnt_sock);
		return -1;
	}
	
	// lock mutex
	pthread_mutex_lock(&cmd_mgr->mt);
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_VERBOSE, "CMD: Sending command %s to client %s", cmd, dev_info->guid);
	
	cbcc_tlv_buffer_list_t tlvs;
	
	// build tlv message
	cbcc_tlv_buffer_build(cmd, &tlvs);
	
	// send tlv message
	if (cmd_mgr->c->no_ssl)
		ret = send_tlv_buffer(clnt_sock, &tlvs);
	else
		ret = ssl_send_tlv_buffer(cmd_mgr->ssl_params.ssl[clnt_sock], &tlvs);
	
	// free tlv list
	cbcc_tlv_buffer_free(&tlvs);
	
	// unlock mutex
	pthread_mutex_unlock(&cmd_mgr->mt);
	
	return ret;
}

// get ip address by socket
const char *cbccd_cmd_get_ipaddr_by_sock(cbccd_cmd_mgr_t *cmd_mgr, int clnt_sock)
{
	return cmd_mgr->sock_addr_infos[clnt_sock].ipaddr;
}

// get command code from buffer
static const char *cbcc_cmd_names[] =
{
	CBCC_CMD_LOGIN,
	CBCC_CMD_MONITOR,
	CBCC_CMD_DEPLOY,
	CBCC_CMD_CREATE_BACKUP,
	CBCC_CMD_RESTORE_BACKUP,
	CBCC_CMD_ACTION,
	CBCC_CMD_REPORT,
	CBCC_CMD_AGENT_DISABLE,
	CBCC_CMD_CHECK_CONFIG,
	CBCC_CMD_KEEPALIVE,
	NULL,
};

static enum CBCC_CMD_CODES cbccd_get_cmd_code(const char *cmd_name)
{
	enum CBCC_CMD_CODES cmd_code = CBCC_CMD_CODE_UNKNOWN;
	
	for (unsigned int i = CBCC_CMD_CODE_LOGIN; i < CBCC_CMD_CODE_UNKNOWN; i++)
	{
		// if command name is NULL
		if (cbcc_cmd_names[i] == NULL)
			break;
		
		if (strcmp(cmd_name, cbcc_cmd_names[i]) == 0)
			return i;
	}
	
	return cmd_code;
}

// CBCCD command process routine
static void cbccd_process_cmd(cbccd_cmd_mgr_t *cmd_mgr, int clnt_sock, const char *cmd_buf)
{
	char cmd_name[CBCC_MAX_CMD_NAME_LEN];
	char *cmd_data = NULL;
	
	int resp_code;
	char *resp_data;

	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_VERBOSE, "CMD: Process command '%s' from client socket '%d'", cmd_buf, clnt_sock);
	
	cbcc_json_object_t cbcc_cmd_objs[] = 
	{
		{
			.key = "cmd",
			.type = CBCC_JSON_DATA_TYPE_STRING,
			.data.str_val = cmd_name,
			.data_size = sizeof(cmd_name)
		},
		{
			.key = "data",
			.type = CBCC_JSON_DATA_TYPE_OBJECT_BIG,
			.data.str_val_big = &cmd_data,
		}
	};
	
	// get json object from command buffer
	if (cbcc_json_parse_from_buffer(cmd_buf, cbcc_cmd_objs, sizeof(cbcc_cmd_objs) / sizeof(cbcc_json_object_t)) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "CMD: Parsing command JSON buffer has failed.");
		return;
	}

	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_VERBOSE, "CMD: command name '%s', command data '%s'", cmd_name, cmd_data);
	
	// get command code
	enum CBCC_CMD_CODES cmd_code = cbccd_get_cmd_code(cmd_name);
	if (cmd_code == CBCC_CMD_CODE_UNKNOWN)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "CMD: Command name '%s' is unknown", cmd_name);
		return;
	}
	
	// process command by code
	switch (cmd_code)
	{
		case CBCC_CMD_CODE_LOGIN:
			resp_code = cbccd_device_login(&cmd_mgr->c->device_mgr, clnt_sock, cmd_data);
			break;
			
		case CBCC_CMD_CODE_MONITOR:
			cbccd_mon_set_data(cmd_mgr->c, clnt_sock, cmd_data);
			break;
			
		case CBCC_CMD_CODE_DEPLOY_OBJ:
			cbccd_config_send_data(&cmd_mgr->c->conf_mgr, clnt_sock, cmd_data);
			break;
			
		case CBCC_CMD_CODE_CREATE_BACKUP:
			cbccd_admin_set_create_backup_info(cmd_mgr->c, clnt_sock, cmd_data);
			break;
		
		case CBCC_CMD_CODE_REPORT:
			cbccd_report_set_data(cmd_mgr->c, clnt_sock, cmd_data);
			break;
		
		case CBCC_CMD_CODE_KEEPALIVE:
			cbccd_device_update_status(&cmd_mgr->c->device_mgr, clnt_sock);
			break;
		
		default:
			break;
	}
	
	// free command data
	if (cmd_data)
		free(cmd_data);
	
	// send response when login
	if (cmd_code != CBCC_CMD_CODE_LOGIN)
		return;
	
	cbcc_json_object_t cbcc_cmd_resp_objs[] =
	{
		{
			.key = "code",
			.type = CBCC_JSON_DATA_TYPE_INT,
			.data.int_val_set = resp_code,
		}
	};
	
	// build response message
	cbcc_json_build(cbcc_cmd_resp_objs, CBCC_JOBJS_COUNT(cbcc_cmd_resp_objs), &resp_data);
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_VERBOSE, "CMD: Sending response '%s' for command '%s' to client '%d'", resp_data, cmd_name, clnt_sock);
	
	if (cbccd_cmd_send(cmd_mgr, clnt_sock, resp_data) < 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "CMD: Sending response has failed due to %s", strerror(errno));
	}
	
	// free response data
	free(resp_data);
	
	return;
}

// free ssl info
static void free_ssl_info(cbccd_cmd_mgr_t *cmd_mgr, int clnt_sock)
{
	cbccd_ssl_params_t *ssl_params = &cmd_mgr->ssl_params;
	
	if (cmd_mgr->c->no_ssl)
		return;
	
	SSL_free(ssl_params->ssl[clnt_sock]);
	ssl_params->ssl[clnt_sock] = NULL;
	
	return;
}

// verify ssl status
static int verify_ssl_status(cbccd_cmd_mgr_t *cmd_mgr, int clnt_sock)
{
	cbccd_ssl_params_t *ssl_params = &cmd_mgr->ssl_params;
	int err;
	
	if (cmd_mgr->c->no_ssl)
		return 0;
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "CMD: Verifying SSL parameters from client");
	
	// create new ssl session and set client socket into ssl
	ssl_params->ssl[clnt_sock] = SSL_new(ssl_params->ctx);
	if (!ssl_params->ssl[clnt_sock])
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "CMD: Could not create SSL structure dut to '%s'", ERR_error_string(ERR_get_error(), NULL));
		return -1;
	}
	
	SSL_set_fd(ssl_params->ssl[clnt_sock], clnt_sock);
	
	// accepting SSL request
	err = SSL_accept(ssl_params->ssl[clnt_sock]);
	if (err < 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "CMD: Accepting SSL connection from client has failed due to '%s'",
				ERR_error_string(ERR_get_error(), NULL));
		
		free_ssl_info(cmd_mgr, clnt_sock);
		
		return -1;
	}
	
	return 0;
}

// free socket info
void cbccd_cmd_free_socket(cbccd_cmd_mgr_t *cmd_mgr, int clnt_sock)
{
	// free ssl info
	free_ssl_info(cmd_mgr, clnt_sock);

	// free buffer
	cbcc_buffer_free(&cmd_mgr->buffer_list, clnt_sock);

	// remove client socket from fd set and close it
	FD_CLR(clnt_sock, &cmd_mgr->fds);
	close(clnt_sock);

	// if client socket was max, then set another as max
	if (clnt_sock == cmd_mgr->max_fd)
		cmd_mgr->max_fd = get_max_fd(cmd_mgr->max_fd, &cmd_mgr->fds);

	return;
}

// CBCCD command I/O thread
static void *cbccd_cmd_io(void *p)
{
	cbccd_cmd_mgr_t *cmd_mgr = (cbccd_cmd_mgr_t *) p;
	struct timeval tv;
	
	// set max socket descriptor
	cmd_mgr->max_fd = cmd_mgr->cmd_srv_sock;
	
	// init socket set
	FD_ZERO(&cmd_mgr->fds);
	FD_SET(cmd_mgr->max_fd, &cmd_mgr->fds);
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "CMD: Starting CBCCD command I/O thread.");
	
	while (!cmd_mgr->end_flag)
	{
		int i, ret;
		fd_set tmp_fds;
		
		// set timeout value
		tv.tv_sec = 0;
		tv.tv_usec = 50 * 1000;
		
		// copy socket set
		memcpy(&tmp_fds, &cmd_mgr->fds, sizeof(fd_set));
		
		// async select call
		ret = select(cmd_mgr->max_fd + 1, &tmp_fds, NULL, NULL, &tv);
		if (ret < 0)
		{
			CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "CMD: Command proc async call failed.");
			sleep(3);
			continue;
		}
		
		for (i = 0; i <= cmd_mgr->max_fd; i++)
		{
			if (!FD_ISSET(i, &tmp_fds))
				continue;

			if (i == cmd_mgr->cmd_srv_sock)			// accept call
			{
				int clnt_sock = -1;
				do
				{
					struct sockaddr_in clnt_addr;
					int socklen = sizeof(clnt_addr);
					
					// initialize client address
					memset(&clnt_addr, 0, sizeof(clnt_addr));
					
					// accept client connection
					clnt_sock = accept(cmd_mgr->cmd_srv_sock, (struct sockaddr *) &clnt_addr, (socklen_t *) &socklen);
					if (clnt_sock < 0 && errno != EWOULDBLOCK)
						break;
					
					// set client socket to fd set
					if (clnt_sock > 0)
					{
						// verify ssl status
						if (verify_ssl_status(cmd_mgr, clnt_sock) != 0)
						{
							// close client socket
							close(clnt_sock);
							break;
						}
						
						FD_SET(clnt_sock, &cmd_mgr->fds);
						if (clnt_sock > cmd_mgr->max_fd)
							cmd_mgr->max_fd = clnt_sock;
						
						// set socket address info
						snprintf(cmd_mgr->sock_addr_infos[clnt_sock].ipaddr, sizeof(cmd_mgr->sock_addr_infos[clnt_sock].ipaddr),
								"%s", inet_ntoa(clnt_addr.sin_addr));
						cmd_mgr->sock_addr_infos[clnt_sock].sport = ntohs(clnt_addr.sin_port);
					}
				}
				while (clnt_sock == -1);
			}
			else						// request from clients
			{
				do
				{
					unsigned char cmd_buf[CBCC_MAX_SOCK_BUF_LEN];
					bool failed = false;
					
					// get command buffer from client
					if (cmd_mgr->c->no_ssl)
						ret = recv(i, cmd_buf, sizeof(cmd_buf), 0);
					else
						ret = SSL_read(cmd_mgr->ssl_params.ssl[i], cmd_buf, sizeof(cmd_buf));
					
					if (ret > 0)
					{
						cbcc_buffer_t *buf = NULL;
						int completed = 0;
						
						// add stream into buffer and check buffer is completed status
						if (cbcc_buffer_add(&cmd_mgr->buffer_list, i, cmd_buf, ret, &buf, &completed) != 0)
						{
							CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "CMD: Parsing TLV buffer from socket '%d' has failed.", i);

							cbcc_buffer_free(&cmd_mgr->buffer_list, i);
							break;
						}
						
						if (completed)
						{
							// process command
							cbccd_process_cmd(cmd_mgr, i, (const char *) buf->buffer);
						
							// free buffer
							cbcc_buffer_free(&cmd_mgr->buffer_list, i);
						}
						
						break;
					}
					else if (ret == 0)				// client disconnected
					{
						failed = true;
					}
					else
					{
						if (errno != EWOULDBLOCK)
						{
							CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_HIGH, "CMD: client with socket '%d' was abnormally disconnected", i);
							failed = true;
						}
					}
					
					// modify fd set if client has been disconnected
					if (failed)
					{
						// free client socket
						cbccd_cmd_free_socket(cmd_mgr, i);
						
						// set device into offline status
						cbccd_device_set_offline(&cmd_mgr->c->device_mgr, i, false);
						
						break;
					}
				}
				while (1);
			}
		}
	}
	
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "CMD: Stopped CBCCD command I/O thread.");
	
	return 0;
}
