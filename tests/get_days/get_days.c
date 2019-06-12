#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include <time.h>

int main()
{
	time_t tt = time(NULL);
	struct tm *tm = localtime(&tt);
	
	printf("wday is '%d'\n", tm->tm_wday);
	
	struct timeval tv;
	gettimeofday(&tv, NULL);
	
	printf("second is '%d'\n", tv.tv_sec);
	
	char date_str[128];
	struct tm tm_day_start;
	
	strftime(date_str, sizeof(date_str), "%Y-%m-%d 00:00:00", tm);
	printf("current date string is '%s'\n", date_str);
	printf("timestamp of current day is '%d'\n", mktime(tm));
	
	strptime(date_str, "%Y-%m-%d %H:%M:%S", &tm_day_start);
	printf("timestamp of current day start is '%d'\n", mktime(&tm_day_start));
	
	return 0;
}
