#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main()
{
	static char *test[] =
	{
		"1", "2", "3", "4",
	};
	
	char test1[256][512];
	char test2[512][256];
	
	printf("size of array is %d\n", sizeof(test) / sizeof(char *));
	printf("size of test1:%d, test2:%d\n", sizeof(test1[0]),sizeof(test2[0]));
	
	return 0;
}
