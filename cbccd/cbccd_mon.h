#ifndef __CBCCD_MON_H__
#define __CBCCD_MON_H__

// process device monitoring data from client
int cbccd_mon_set_data(struct _cbccd_ctx *c, int clnt_sock, const char *cmd_data);

// remove monitoring data
void cbccd_mon_remove_data(struct _cbccd_ctx *c, const char *dev_guid);

#endif			// __CBCCD_MON_H__
