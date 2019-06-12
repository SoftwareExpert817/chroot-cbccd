#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include <time.h>

int main(int argc, char *argv[])
{
	char time_str[128];
	
	if (argc != 2)
	{
		fprintf(stderr, "Usage: get_time [timestamp]\n");
		exit(-1);
	}
	
	time_t tt = atol(argv[1]);
	struct tm *tm = localtime(&tt);
	
	strftime(time_str, sizeof(time_str), "%a %d %b %Y %T", tm);
	
	printf("current time stamp is '%d'", time(NULL));
	printf("time string is %s\n", time_str);
	
	return 0;
}
