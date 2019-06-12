#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>
#include <errno.h>

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>

#include "cbcc_common.h"

#include "cbcc_buffer.h"
#include "cbcc_sock.h"
#include "cbcc_json.h"
#include "cbcc_util.h"

// usage function
static void usage()
{
	fprintf(stderr, "Usage: cbccd_wapi_test [json file path]\n");
	exit(-1);
}

// main function
int main(int argc, char *argv[])
{
	int sock = -1;
	struct sockaddr_in addr;
	
	char *json_buf_from_file = NULL;
	
	int resp_code = 0;
	int ret = -1;
	
	char resp_data[40960];
	
	if (argc != 2)
		usage();
	
	// check option
	if (read_file_contents(argv[1], &json_buf_from_file) < 0)
	{
		fprintf(stderr, "Could not read json data from file %s.", argv[1]);
		return -1;
	}
	
	// create socket
	sock = create_socket();
	if (sock < 0)
	{
		fprintf(stderr, "Could not create socket due to %s.\n", strerror(errno));
		goto end;
	}
	
	// set address
	memset(&addr, 0, sizeof(addr));
	addr.sin_family = AF_INET;
	addr.sin_addr.s_addr = inet_addr("127.0.0.1");
	addr.sin_port = htons(CBCCD_WAPI_LISTEN_PORT);
	
	// connect to cbccd WAPI service
	if (connect(sock, (struct sockaddr *) &addr, sizeof(addr)) != 0)
	{
		fprintf(stderr, "Could not connect to WAPI service due to %s.\n", strerror(errno));
		goto end;
	}
	
	// send request
	if (send(sock, json_buf_from_file, strlen(json_buf_from_file), 0) < 0)
	{
		fprintf(stderr, "Could not send WAPI json data due to %s.\n", strerror(errno));
		goto end;
	}

	memset(resp_data, 0, sizeof(resp_data));
	if (recv(sock, resp_data, sizeof(resp_data), 0) < 0)
	{
		fprintf(stderr, "Could not receive WAPI response due to %s.\n", strerror(errno));
		goto end;
	}
	
	printf("%s\n", resp_data);
	
end:
	if (sock > 0)
		close(sock);
	
	if (json_buf_from_file)
		free(json_buf_from_file);
	
	return ret;
}
