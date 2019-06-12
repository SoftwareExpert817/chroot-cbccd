
#include "cbccd.h"

// forground mode flag
static bool forground = false;
static enum CBCC_DEBUG_LEVEL cbcc_debug_level = CBCC_DEBUG_LEVEL_HIGH;
static bool no_ssl = false;
static bool end_flag = false;

// print version
static void print_version()
{
	static const char build_time[] = { __DATE__ " " __TIME__ };
	printf("CBCCD version %s (Build at '%s')\n", CBCC_VERSION_STR, build_time);
	exit(0);
}

// print usage info
static void usage()
{
	fprintf(stderr, "Usage: cbccd [Options]:\n"
			"\t\t-f\t\tRun forgound mode\n"
			"\t\t-n\t\tRun non-SSL mode\n"
			"\t\t-d [1-4]\tSet verbose level\n"
			"\t\t-v\t\tPrint version\n");
	exit(-1);
}

// signal handler
static void signal_handler(int signum)
{
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "Main: Received signal '%d'", signum);
	end_flag = true;
}

// init signal handlers
static void init_signal()
{
	signal(SIGINT, signal_handler);
	signal(SIGTERM, signal_handler);
	signal(SIGHUP, signal_handler);

	return;
}

// initialize cbccd context
static int cbccd_ctx_init(cbccd_ctx_t *c)
{
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "Main: Initializing cbccd context.");

	// init cbccd context object
	memset(c, 0, sizeof(cbccd_ctx_t));
	
	c->no_ssl = no_ssl;
	
	// initialize cbccd DB manager
	if (cbccd_pgsql_mgr_init(c) != 0)
		return -1;
		
	// initialize cbccd command manager
	if (cbccd_cmd_mgr_init(c) != 0)
		return -1;
	
	// initialize wapi manager
	if (cbccd_wapi_mgr_init(c) != 0)
		return -1;
		
	// initialize config manager
	if (cbccd_config_mgr_init(c) != 0)
		return -1;

	// initialize device manager
	if (cbccd_device_mgr_init(c) != 0)
		return -1;
		
	// initialize admin manager
	if (cbccd_admin_mgr_init(c) != 0)
		return -1;
	
	return 0;
}

// finalize cbccd context
static void cbccd_ctx_finalize(cbccd_ctx_t *c)
{
	CBCC_DEBUG_MSG(CBCC_DEBUG_LEVEL_NOR, "Main: Finalizing cbccd context.");
	
	// finalize cbccd command manager
	cbccd_cmd_mgr_finalize(&c->cmd_mgr);

	// finalize wapi manager
	cbccd_wapi_mgr_finalize(&c->wapi_mgr);
	
	// finalize admin manager
	cbccd_admin_mgr_finalize(&c->admin_mgr);

	// finalize device manager
	cbccd_device_mgr_finalize(&c->device_mgr);
	
	// finalize configuration manager
	cbccd_config_mgr_finalize(&c->conf_mgr);
	
	// finalize cbccd DB manager
	cbccd_pgsql_mgr_finalize(&c->pgsql_mgr);
	
	return;
}

// main function
int main(int argc, char *argv[])
{
	cbccd_ctx_t ctx;
	
	// check if running user is root
	if (getuid() != 0)
	{
		fprintf(stderr, "Please run cbccd as root privilege.\n");
		exit(1);
	}

	// parse arguments
	if (argc > 1)
	{
		int opt;
		while ((opt = getopt(argc, argv, "fd:nv")) != -1)
		{
			switch (opt)
			{
				case 'f':
					forground = true;				// set forground flag
					break;
				
				case 'd':
					cbcc_debug_level = (enum CBCC_DEBUG_LEVEL) atoi(optarg);
					if (cbcc_debug_level > CBCC_DEBUG_LEVEL_VERBOSE)
						cbcc_debug_level = CBCC_DEBUG_LEVEL_VERBOSE;
					
					break;
				
				case 'n':
					no_ssl = true;
					break;
				
				case 'v':
					print_version();
					break;

				default:
					usage();
					break;
			}
		}
	}
	
	// check process is running
	pid_t pid = get_procid_by_procname(CBCCD_PROC_NAME);
	if (pid > 0)
	{
		fprintf(stderr, "Process is already running with pid '%d'.\n", pid);
		exit(1);
	}
	
	// if forground flag isn't set, then daemonize program
	if (!forground)
		daemonize();
		
	// write PID file
	write_pid_file(CBCCD_PROC_NAME);
	
	// init signal
	init_signal();
	
	// initializing debugging
	if (cbcc_dbg_init(CBCCD_PROC_NAME, cbcc_debug_level) != 0)
	{
		exit(1);
	}
	
	// intialize CBCCD context
	if (cbccd_ctx_init(&ctx) != 0)
	{
		CBCC_DEBUG_ERR(CBCC_DEBUG_LEVEL_NOR, "Main: Could not initialize CBCC context");

		cbccd_ctx_finalize(&ctx);
		cbcc_dbg_finalize();
		
		exit(1);
	}
	
	while (!end_flag)
	{
		sleep(1);
	}
	
	// finalize cbccd context
	cbccd_ctx_finalize(&ctx);
	
	// finalize debugging
	cbcc_dbg_finalize();
	
	return 0;
}
