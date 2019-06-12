#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include <openssl/md5.h>

// create guid by key
// Note: guid will have '-' in index 8, 12, 16, 20
#define MD5SUM_LEN				16

void create_guid(const char *key, char *guid, size_t s)
{
	unsigned char md5sum[MD5SUM_LEN];
	MD5_CTX md5_ctx;
	
	int i;
	
	// initialize MD5 context
	if (!MD5_Init(&md5_ctx))
	{
		return;
	}
	
	MD5_Update(&md5_ctx, key, strlen(key));
	MD5_Final(md5sum, &md5_ctx);
	
	// init guid buffer
	memset(guid, 0, s);
	
	// set guid
	for (i = 0; i < MD5SUM_LEN; i++)
	{
		char tmp[3];
		
		if (i == 4 || i == 6 || i == 8 || i == 10)
			strcat(guid, "-");
		
		snprintf(tmp, sizeof(tmp), "%02x", md5sum[i]);
		strcat(guid, tmp);
	}
	
	return;
}

int main()
{
	char key[32];
	char guid[64];
	time_t tt;
	
	tt = time(NULL);
	
	snprintf(key, sizeof(key), "%d", tt);
	
	fprintf(stderr, "input string '%s'\n", key);
	create_guid(key, guid, sizeof(guid));
	
	fprintf(stderr, "guid is '%s'\n", guid);
	
	return 0;
}
