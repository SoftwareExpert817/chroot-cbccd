#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <libpq-fe.h>

#define CBCC_POSTGRE_DB_NAME			"cbcc"
#define CBCC_POSTGRE_DB_USERNAME		"cbcc"
#define CBCC_POSTGRE_DB_PASSWD			"cbccdbpw"

#define MAX_CONN_STRING				256

#define MAX_ROW_ITEMS				16
#define MAX_ROW_ITEM_STRLEN			64

#define MAX_SQL_STRLEN				1024

#define MAX_COLUMN_NUM				32
#define MAX_COLUMN_NAME_LEN			128

static PGconn *conn;
static PGresult *res;

// usage help function
static void usage()
{
	printf("Usage: pgsql_test [args]\n"
		"\t\t-A [table name] [array of fields seperated with comma]\t\t-Add row into given table\n"
		"\t\t-S [table name]\t\t-Show rows of given table\n"
		"\t\t-h \t\t-Show helps\n");
		
	PQfinish(conn);
	
	exit(0);
}

// insert table row
static void insert_table_row(const char *table_name, char *array_of_row)
{
	char row_items[MAX_SQL_STRLEN];
	int num_row_items = 0;
	
	char sep[] = ",";
	
	char sql[MAX_SQL_STRLEN];
	
	memset(row_items, 0, sizeof(row_items));
	
	// split string by ','
	char *p = strtok(array_of_row, sep);
	while (p)
	{
		char row_item[MAX_ROW_ITEM_STRLEN];
		
		if (num_row_items > (MAX_ROW_ITEMS - 1))
			break;
			
		// copy row item
		if (num_row_items == 0)
			snprintf(row_item, sizeof(row_item), "'%s'", p);
		else
			snprintf(row_item, sizeof(row_item), " ,'%s'", p);
			
		// concate string
		strcat(row_items, row_item);
		
		p = strtok(NULL, sep);
		num_row_items++;
	}
	
	// make sql statement
	snprintf(sql, sizeof(sql), "INSERT INTO %s VALUES (%s);", table_name, row_items);
	
	// run sql statement
	res = PQexec(conn, sql);
	if (PQresultStatus(res) != PGRES_COMMAND_OK)
	{
		fprintf(stderr, "Execute of sql has failed.(%s)", PQerrorMessage(conn));
		PQclear(res);
		
		return;
	}
	
	printf("SQL '%s' has executed successfully.\n", sql);
	
	PQclear(res);
	
	return;
}

// print table row
static void print_table_row(const char *table_name)
{
	char sql[MAX_SQL_STRLEN];
	
	char column_names[MAX_COLUMN_NAME_LEN][MAX_COLUMN_NUM];
	int num_of_columns;
	
	int i, j;
	
	// make sql string
	snprintf(sql, sizeof(sql), "SELECT * FROM %s", table_name);
	
	// execute sql
	res = PQexec(conn, sql);
	if (PQresultStatus(res) != PGRES_TUPLES_OK)
	{
		fprintf(stderr, "SQL execution has failed.(%s).\n", PQerrorMessage(conn));
		PQclear(res);
		
		return;
	}
	
	// get columns
	num_of_columns = PQnfields(res);
	for (i = 0; i < num_of_columns; i++)
	{
		snprintf(column_names[i], sizeof(column_names[i]), "%s", PQfname(res, i));
		printf("Column name is %s at index %d\n", column_names[i], i);
	}
	
	for (i = 0; i < PQntuples(res); i++)
	{
		printf("The row at index '%d' - ", i);
		for (j = 0; j < num_of_columns; j++)
		{
			printf(" %s ", PQgetvalue(res, i, j));
		}
		
		printf(".\n");
	}
	
	PQclear(res);
	
	return;
}

// main function
int main(int argc, char *argv[])
{
	char conn_str[MAX_CONN_STRING];
	
	// set connection string
	snprintf(conn_str, sizeof(conn_str), "dbname = %s user = %s password = %s",
			CBCC_POSTGRE_DB_NAME, CBCC_POSTGRE_DB_USERNAME, CBCC_POSTGRE_DB_PASSWD);
	
	// open connection with DB
	conn = PQconnectdb(conn_str);
	if (PQstatus(conn) != CONNECTION_OK)
	{
		fprintf(stderr, "Could not connect to database due to '%s'.\n", PQerrorMessage(conn));
		PQfinish(conn);
		
		exit(1);
	}
	
	printf("Database connection has established successfully.\n");

	if (argc > 2)
	{
		int opt;
		while ((opt = getopt(argc, argv, "A:S:h")) != -1)
		{
			switch (opt)
			{
				case 'A':
					insert_table_row(argv[2], argv[3]);
					break;
					
				case 'S':
					print_table_row(argv[2]);
					break;
					
				case 'h':
					usage();
					
				default:
					usage();
			}
		}
	}
	else
		usage();
		
	PQfinish(conn);
	
	return 0;
}
