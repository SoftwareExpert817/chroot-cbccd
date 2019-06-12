#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>

#include <openssl/bio.h>
#include <openssl/evp.h>
#include <openssl/buffer.h>

// get file size
int get_file_size(const char *fpath)
{
	struct stat st;
	
	// get file stat
	if (stat(fpath, &st) != 0)
		return -1;
		
	// check if given file is regular
	if (!S_ISREG(st.st_mode))
		return -1;
		
	return st.st_size;
}


// base 64 encoding function
static int base64_encode(unsigned char *src, int src_len, char **dst)
{
	BIO *bmem, *b64;
	BUF_MEM *bptr;

	char *ret;

	b64 = BIO_new(BIO_f_base64());
	bmem = BIO_new(BIO_s_mem());
	b64 = BIO_push(b64, bmem);

	BIO_write(b64, src, src_len);
	BIO_flush(b64);
	BIO_get_mem_ptr(b64, &bptr);

	ret = (char *) malloc(bptr->length);
	memcpy(ret, bptr->data, bptr->length - 1);
	ret[bptr->length - 1] = '\0';

	BIO_free_all(b64);

	*dst = ret;
	
	return 0;
}


// get base64 encoded data
int get_base64_encoded_from_file(const char *fpath, char **base64_encoded)
{
	FILE *fp;
	
	unsigned char *buf;
	int fsize;
	
	// get file size
	fsize = get_file_size(fpath);
	if (fsize <= 0)
		return -1;
	
	// get file contents
	fp = fopen(fpath, "rb");
	if (!fp)
		return -1;
	
	buf = (unsigned char *) malloc(fsize);
	fread(buf, 1, fsize, fp);
	
	fclose(fp);

	base64_encode(buf, fsize, base64_encoded);
	
	return 0;
}

// get length of binary data decoded
static int calc_b64_decode_len(const char* b64input)
{
	int len = strlen(b64input);
	int padding = 0;

	if (b64input[len-1] == '=' && b64input[len-2] == '=')
		padding = 2;
	else if (b64input[len-1] == '=')
		padding = 1;

	return (int) len * 0.75 - padding;
}

// base64 decode function
static int base64_decode(const char *src, unsigned char **dst, int *dst_len)
{
	BIO *b64, *bio;

	unsigned char *buf;
	int len;

	FILE* fp;

	len = calc_b64_decode_len(src);
	if (len <= 0)
		return -1;

	buf = (unsigned char *) malloc(len);
	memset(buf, 0, len);

	fp = fmemopen((void *) src, strlen(src), "r");

	b64 = BIO_new(BIO_f_base64());
	bio = BIO_new_fp(fp, BIO_NOCLOSE);
	bio = BIO_push(b64, bio);

	BIO_read(bio, buf, len);

	BIO_free_all(bio);
	fclose(fp);

	*dst = buf;
	*dst_len = len;

	return 0;
}

// base64 decode to file function
static int base64_decode_to_file(const char *src, const char *fpath)
{
	BIO *b64, *bio, *bio_out;

	FILE *fp, *fp_out;
	
	unsigned char inbuf[512];
	int inlen;

	fp = fmemopen((void *) src, strlen(src), "r");
	fp_out = fopen(fpath, "wb");

	b64 = BIO_new(BIO_f_base64());
	bio = BIO_new_fp(fp, BIO_NOCLOSE);
	bio_out = BIO_new_fp(fp_out, BIO_NOCLOSE);
	BIO_push(b64, bio);
	
	while((inlen = BIO_read(b64, inbuf, sizeof(inbuf))) > 0)
		BIO_write(bio_out, inbuf, inlen);

	BIO_flush(bio);
	BIO_flush(bio_out);
	BIO_free_all(b64);
	
	fclose(fp);
	fclose(fp_out);

	return 0;
}

// decode base64 encoded data and write into file
int decode_base64_to_file(const char *base64_encoded, const char *fpath)
{
	FILE *fp;
	
	unsigned char *decoded;
	int decoded_len;
	
	// base64 decode
	if (base64_decode(base64_encoded, &decoded, &decoded_len) < 0)
	{
		fprintf(stderr, "base64 decode has failed.\n");
		return -1;
	}
	
	// open file in binary mode
	fp = fopen(fpath, "wb");
	if (!fp)
	{
		fprintf(stderr, "UTIL: Could not open file '%s' for writting base64 decoded data.", fpath);

		free(decoded);
		return -1;
	}
	
	fwrite(decoded, 1, decoded_len, fp);
	fclose(fp);
	
	free(decoded);
	
	return 0;
}

int main(int argc, char *argv[])
{
	char *b64_encoded = NULL;
	char b64_decoded_fpath[256];
	
	if (argc != 2)
	{
		fprintf(stderr, "Usage: b64_test [input file]\n");
		return -1;
	}
	
	if (get_base64_encoded_from_file(argv[1], &b64_encoded) != 0)
	{
		fprintf(stderr, "Base64 encoding from file '%s' has failed.", argv[1]);
		return -1;
	}
	
	snprintf(b64_decoded_fpath, sizeof(b64_decoded_fpath), "%s.1", argv[1]);
	
	if (base64_decode_to_file(b64_encoded, b64_decoded_fpath) != 0)
	{
		fprintf(stderr, "Base64 decoding has failed.\n");
	}
	else
	{
		fprintf(stderr, "Base64 decoding has succeeded.\n");
	}
	
	free(b64_encoded);
	
	return 0;
}
