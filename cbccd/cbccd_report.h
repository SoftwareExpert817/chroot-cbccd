#ifndef __CBCCD_REPORT_H__
#define __CBCCD_REPORT_H__

// CBCC report types
enum CBCC_REPORT_TYPES
{
	CBCC_REPORT_TYPE_HW = 0,
	CBCC_REPORT_TYPE_NET,
	CBCC_REPORT_TYPE_SEC,
	CBCC_REPORT_TYPE_NUM
};

#define CBCC_REPORT_HW_TBL_NAME				"reporting_hardware"
#define CBCC_REPORT_NET_TBL_NAME			"reporting_network"
#define CBCC_REPORT_SEC_TBL_NAME			"reporting_security"

// set reporting data into database
int cbccd_report_set_data(struct _cbccd_ctx *c, int clnt_sock, const char *report_data);

// delete all reporting data for device
void cbccd_report_delete_data(struct _cbccd_ctx *c, const char *dev_guid);

#endif		// __CBCCD_REPORT_H__
