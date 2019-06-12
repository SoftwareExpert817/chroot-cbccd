#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include <json/json.h>

int main()
{
	json_object *j_obj;
	char j_str[128];
	
	j_obj = json_object_new_object();
	
	json_object_object_add(j_obj, "test", json_object_new_string("test"));
	json_object_object_add(j_obj, "test2", json_object_new_int(1));
	
	snprintf(j_str, sizeof(j_str), "%s", json_object_get_string(j_obj));
	
	json_object_object_foreach(j_obj, key, val)
	{
		if (strcmp(key, "test2") == 0)
		{
			printf("finded test2 json object\n");
		}
	}
	
	json_object_put(j_obj);
	
	printf("json string is '%s'\n", j_str);
	
	return 0;
}
