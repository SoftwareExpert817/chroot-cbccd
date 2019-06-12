#ifndef __CBCCD_H__
#define __CBCCD_H__

struct _cbccd_ctx;

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <errno.h>
#include <unistd.h>
#include <pthread.h>
#include <signal.h>
#include <assert.h>
#include <sys/stat.h>
#include <sys/types.h>

#define _XOPEN_SOURCE
#include <time.h>

#include <sys/socket.h>

#include <netinet/in.h>
#include <arpa/inet.h>

#include <libpq-fe.h>

#include "cbcc_common.h"
#include "cbcc_debug.h"
#include "cbcc_buffer.h"
#include "cbcc_sock.h"
#include "cbcc_json.h"
#include "cbcc_util.h"

#include "cbccd_config.h"
#include "cbccd_device.h"
#include "cbccd_pgsql.h"
#include "cbccd_mon.h"
#include "cbccd_cmd.h"
#include "cbccd_admin.h"
#include "cbccd_report.h"
#include "cbccd_wapi.h"

// cbccd context struct
typedef struct _cbccd_ctx
{
	bool no_ssl;
	
	struct _cbccd_cmd_mgr		cmd_mgr;
	struct _cbccd_device_mgr	device_mgr;
	struct _cbccd_pgsql_mgr		pgsql_mgr;
	struct _cbccd_admin_mgr		admin_mgr;
	struct _cbccd_config_mgr	conf_mgr;
	struct _cbccd_wapi_mgr		wapi_mgr;
} cbccd_ctx_t;

#endif			// __CBCCD_H__
