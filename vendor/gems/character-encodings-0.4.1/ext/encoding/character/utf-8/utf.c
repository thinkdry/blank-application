/*
 * contents: UTF-8 string operations.
 *
 * Copyright (C) 2004 Nikolai Weibull <source@pcppopper.org>
 */


#include <ruby.h>
#include <assert.h>
#include <locale.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <wchar.h>

#include "unicode.h"
#include "private.h"


#define UNICODE_ISVALID(char)				\
	((char) < 0x110000 &&				\
	 (((char) & 0xffffff800) != 0xd800) &&		\
	 ((char) < 0xfdd0 || (char) > 0xfdef) &&	\
	 ((char) & 0xfffe) != 0xfffe)


/* {{{1
 * These are a couple of constants we use for dealing with the bit-twiddling
 * necessary when dealing with UTF-8 character sequences.
 */
enum {
	BIT_1 = 7,
	BIT_X = 6,
	BIT_2 = 5,
	BIT_3 = 4,
	BIT_4 = 3,
	BIT_5 = 2,
	BIT_6 = 1,

	OCT_1 = ((1 << (BIT_1 + 1)) - 1) ^ 0xff,	/* 0000 0000 */
	OCT_X = ((1 << (BIT_X + 1)) - 1) ^ 0xff,	/* 1000 0000 */
	OCT_2 = ((1 << (BIT_2 + 1)) - 1) ^ 0xff,	/* 1100 0000 */
	OCT_3 = ((1 << (BIT_3 + 1)) - 1) ^ 0xff,	/* 1110 0000 */
	OCT_4 = ((1 << (BIT_4 + 1)) - 1) ^ 0xff,	/* 1111 0000 */
	OCT_5 = ((1 << (BIT_5 + 1)) - 1) ^ 0xff,	/* 1111 1000 */
	OCT_6 = ((1 << (BIT_6 + 1)) - 1) ^ 0xff,	/* 1111 1100 */

	UNI_LEN1 = 0x80,
	UNI_LEN2 = 0x800,
	UNI_LEN3 = 0x10000,
	UNI_LEN4 = 0x200000,
	UNI_LEN5 = 0x4000000,

	MASK_X = (1 << BIT_X) - 1,			/* 0011 1111 */
	TEST_X = MASK_X ^ 0xff,				/* 1100 0000 */
};

/* {{{1
 * Determine whether ‘p’ is part of a UTF-8 multi-byte sequence.
 */
#define CONT_X(p)	((((unsigned char)p) & TEST_X) == OCT_X)

/* {{{1
 * Add the bits from ‘p’ to ‘c’, which is first shifted right to make room for
 * the additional bits.
 */
#define ADD_X(c, p)	(((c) << BIT_X) | (((unsigned char)p) & MASK_X))

/* {{{1
 * Put bits from ‘c’ into ‘p’ and shift them off of ‘c’ afterwards.
 */
#define PUT_X(c, p)	((p) = OCT_X | ((c) & MASK_X), (c) >> BIT_X)


/* {{{1
 * s_utf_skip_lengths: This table is used for keeping track of how long a given
 * UTF-8 character sequence is from the contents of the first byte.
 */
static const uint8_t s_utf_skip_length_data[256] = {
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
	2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 
	3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 6, 6, 1, 1
};


const char * const s_utf_skip_lengths = (const char *)s_utf_skip_length_data;



/* {{{1
 * Private function used to calculate the length and mask to use when dealing
 * with a given UTF-8 character sequence.
 */
static inline void
_utf_compute(unsigned char c, int *mask, int *len)
{
	if (c < 0x80) {
		*len = 1;
		*mask = 0x7f;
	} else if ((c & 0xe0) == 0xc0) {
		*len = 2;
		*mask = 0x1f;
	} else if ((c & 0xf0) == 0xe0) {
		*len = 3;
		*mask = 0x0f;
	} else if ((c & 0xf8) == 0xf0) {
		*len = 4;
		*mask = 0x07;
	} else if ((c & 0xfc) == 0xf8) {
		*len = 5;
		*mask = 0x03;
	} else if ((c & 0xfe) == 0xfc) {
		*len = 6;
		*mask = 0x01;
	} else {
		*len = -1;
	}
}

/* {{{1
 * Private function used to figure out the length of the UTF-8 representation
 * of a given Unicode character (UTF-32).
 */
static inline unsigned short
_utf_length(const unichar c)
{
	if (c < UNI_LEN1)
		return 1;
	else if (c < UNI_LEN2)
		return 2;
	else if (c < UNI_LEN3)
		return 3;
	else if (c < UNI_LEN4)
		return 4;
	else if (c < UNI_LEN5)
		return 5;
	else
		return 6;
}

/* {{{1
 * Private function used to retrieve a UTF-32 character from an UTF-8 character
 * sequence given a mask and length previously retrieved with _utf_compute().
 */
static inline unichar
_utf_get(const char *str, int mask, int len)
{
	unichar c = (unsigned char)str[0] & mask;

	for (int i = 1; i < len; i++) {
		unsigned char ch = ((const unsigned char *)str)[i];

		if (CONT_X(ch)) {
			c = ADD_X(c, ch);
		} else {
			c = UTF_BAD_INPUT_UNICHAR;
			break;
		}
	}

	return c;
}


/* {{{1
 * Retrieve a UTF-32 character from a UTF-8 character sequence.
 */
unichar
utf_char(const char *str)
{
	int mask;
	int len;

	_utf_compute(*str, &mask, &len);

	return (len > -1) ? _utf_get(str, mask, len) : UTF_BAD_INPUT_UNICHAR;
}


/* {{{1
 * TODO
 */
unichar
utf_char_n(const char *str, size_t max)
{
        if (max == 0)
                return UTF_INCOMPLETE_INPUT_UNICHAR;

	size_t len;
	unichar c = (unsigned char)*str;

	/* TODO: _utf_compute() here */
	if (c < 0x80) {
		return c;
	} else if (c < 0xc0) {
		return UTF_BAD_INPUT_UNICHAR;
	} else if (c < 0xe0) {
		len = 2;
		c &= 0x1f;
	} else if (c < 0xf0) {
		len = 3;
		c &= 0x0f;
	} else if (c < 0xf8) {
		len = 4;
		c &= 0x07;
	} else if (c < 0xfc) {
		len = 5;
		c &= 0x03;
	} else if (c < 0xfe) {
		len = 6;
		c &= 0x01;
	} else {
		return UTF_BAD_INPUT_UNICHAR;
	}

	if (len > max) {
		for (size_t i = 1; i < max; i++) {
			if (!CONT_X(str[i]))
				return UTF_BAD_INPUT_UNICHAR;
		}

		return UTF_INCOMPLETE_INPUT_UNICHAR;
	}

	for (size_t i = 1; i < len; i++) {
		unsigned char ch = ((const unsigned char *)str)[i];

		if (!CONT_X(ch))
			return (ch != NUL) ? UTF_BAD_INPUT_UNICHAR : UTF_INCOMPLETE_INPUT_UNICHAR;

		c = ADD_X(c, ch);
	}

	return (_utf_length(c) == len) ? c : UTF_BAD_INPUT_UNICHAR;
}


/* {{{1
 * Retrieve a UTF-32 character from a UTF-8 character sequence.  This function
 * does additional checking while converitng, such as not overruning a maximum
 * length and checks for incomplete, invalid or out-of-range characters.
 */
unichar
utf_char_validated(const char *str)
{
	unichar result = utf_char(str);

	if (result & 0x80000000) {
		return result;
	} else if (!unichar_isvalid(result)) {
		return UTF_BAD_INPUT_UNICHAR;
	} else {
		return result;
	}
}


/* {{{1 */
unichar
utf_char_validated_n(const char *str, size_t max)
{
	unichar result = utf_char_n(str, max);

	if (result & 0x80000000) {
		return result;
	} else if (!unichar_isvalid(result)) {
		return UTF_BAD_INPUT_UNICHAR;
	} else {
		return result;
	}
}


/* {{{1
 * Return a pointer to the next UTF-8 character sequence in ‘str’.  This
 * requires that it is at the start of the previous one already and no
 * additional error checking is done.
 */
/*
inline char *
utf_next(const char *str)
{
	return (char *)str + s_utf_skip_lengths[*(const uchar *)str];
}
*/


/* {{{1
 * Synchronize and go to the next UTF-8 character sequence in ‘p’.  This search
 * will not go beyond ‘end’.  ‹NULL› is returned if it couldn't be found.
 */
char *
utf_find_next(const char *p, const char *end)
{
	if (*p != NUL) {
		if (end != NULL) {
			for (p++; p < end && CONT_X(*p); p++) {
				/* this loop intentionally left empty */
			}
		} else {
			for (p++; CONT_X(*p); p++) {
				/* this loop intentionally left empty */
			}
		}
	}
	return (p == end) ? NULL : (char *)p;
}


/* {{{1
 * Return a pointer to the previous UTF-8 character sequence in ‘str’.
 */
char *
utf_prev(const char *p)
{
	while (true) {
		p--;

		if (!CONT_X(*p))
			return (char *)p;
	}
}


/* {{{1
 * Synchronize and go to the previous UTF-8 character sequence in ‘p’.  This
 * search will not go beyond ‘begin’.  ‹NULL› is returned if it couldn't be
 * found.
 */
char *
utf_find_prev(const char *begin, const char *p)
{
	for (p--; p >= begin; p--) {
		if (!CONT_X(*p))
			return (char *)p;
	}

	return NULL;
}


/* {{{1
 * Convert an integer offset to a pointer within ‘str’.
 *
 */
char *
utf_offset_to_pointer(const char *str, long offset)
{
	const char *p = str;

        if (offset > 0) {
                while (offset-- > 0)
                        p = utf_next(p);
        } else {
                while (offset != 0) {
                        const char *base = p;
                        p += offset;
                        while ((*p & 0xc0) == 0x80)
                                p--;
         
                        offset += utf_pointer_to_offset(p, base);
                 }
        }

	return (char *)p;
}


/* {{{1
 * Convert a pointer to an integer offset within ‘str’.
 */
long
utf_pointer_to_offset(const char *str, const char *pos)
{
        if (pos < str)
                return -utf_pointer_to_offset(pos, str);

	long offset = 0;
	for (const char *p = str; p < pos; p = utf_next(p))
		offset++;

	return offset;
}


/* {{{1
 * Copy the contents of an UTF-8 string to another.
 */
void
utf_copy(char *dest, const char *src)
{
	strcpy(dest, src);
}


/* {{{1
 * Copy at most n Unicode characters from an UTF-8 string to another.  The
 * destination string will be ‹NUL›-terminated properly.
 */
void
utf_copy_n(char *dest, const char *src, size_t n)
{
	const char *p;

	for (p = src; n > 0 && *p != NUL; p = utf_next(p), n--) {
		/* this loop intentionally left empty */;
	}

	strncpy(dest, src, p - src);
	dest[p - src] = NUL;
}


/* {{{1
 * Append an UTF-8 string onto another.
 */
void
utf_append(char *dest, const char *src)
{
	strcat(dest, src);
}


/* {{{1
 * Append at most ‘n’ Unicode character from an UTF-8 string onto another.
 */
void
utf_append_n(char *dest, const char *src, size_t n)
{
	const char *p;

	for (p = src; n > 0 && *p != NUL; p = utf_next(p), n--) {
		/* this loop intentionally left empty */;
	}

	strncat(dest, src, p - src);
	dest[p - src] = NUL;
}


/* {{{1
 * Compare two strings for ordering using the linguistically correct rules of
 * the current locale.
 */
int
utf_collate(const char *a, const char *b)
{
	assert(a != NULL);
	assert(b != NULL);

	unichar *a_norm = _utf_normalize_wc(a, 0, false, NORMALIZE_ALL_COMPOSE);
	unichar *b_norm = _utf_normalize_wc(b, 0, false, NORMALIZE_ALL_COMPOSE);

	int result = wcscoll((wchar_t *)a_norm, (wchar_t *)b_norm);

	free(a_norm);
	free(b_norm);

	return result;
}


/* {{{1
 * We need UTF-8 encoding of numbers to encode the weights if
 * we are using wcsxfrm. However, we aren't encoding Unicode
 * characters, so we can't simply use unichar_to_utf.
 *
 * The following routine is taken (with modification) from GNU
 * libc's strxfrm routine:
 *
 * Copyright (C) 1995-1999,2000,2001 Free Software Foundation, Inc.
 * Written by Ulrich Drepper <drepper@cygnus.com>, 1995.
 */
static inline int
_utf_encode(char *buf, wchar_t c)
{
	int retval;

	if (c < 0x80) {
		if (buf != NULL)
			*buf++ = (char)c;
		retval = 1;
	} else {
		int step;

		for (step = 2; step < 6; step++) {
			if ((c & (~(uint32_t)0 << (5 * step + 1))) == 0)
				break;
		}

		retval = step;

		if (buf != NULL) {
			*buf = (unsigned char)(~0xff >> step);
			step--;
			do {
				c = PUT_X(c, buf[step]);
			} while (--step > 0);
			*buf |= c;
		}
	}

	return retval;
}


/* {{{1
 * Generate a collation key from a string which can be compared with other
 * collation keys using str_compare().
 */
static char *
utf_collate_key_impl(const char *str, size_t len, bool use_len)
{
	assert(str != NULL);

	unichar *str_norm = _utf_normalize_wc(str, len, use_len, NORMALIZE_ALL_COMPOSE);
	size_t xfrm_len = wcsxfrm(NULL, (wchar_t *)str_norm, 0);
	wchar_t result_wc[xfrm_len + 1];
	wcsxfrm(result_wc, (wchar_t *)str_norm, xfrm_len + 1);

	int result_len = 0;
	for (size_t i = 0; i < xfrm_len; i++)
		result_len += _utf_encode(NULL, result_wc[i]);

	char *result = ALLOC_N(char, result_len + 1);
	result_len = 0;
	for (size_t i = 0; i < xfrm_len; i++)
		result_len += _utf_encode(result + result_len, result_wc[i]);
	result[result_len] = NUL;

	free(str_norm);

	return result;
}


/* {{{1
 * Generate a collation key from a string which can be compared with other
 * collation keys using str_compare().
 */
char *
utf_collate_key(const char *str)
{
	return utf_collate_key_impl(str, 0, false);
}


/* {{{1
 * Generate a collation key from a string (of length ‘len’) which can be
 * compared with other collation keys using str_compare().
 */
char *
utf_collate_key_n(const char *str, size_t len)
{
	return utf_collate_key_impl(str, len, true);
}


/* {{{1
 * Retrieve the offset/index of ‘needle’ in ‘haystack’ which is of size
 * ‘haystack_len’.
 */
static int
str_index_n(const char *haystack, const char *needle, size_t haystack_len)
{
	assert(haystack != NULL);
	assert(needle != NULL);

	size_t needle_len = strlen(needle);

	if (needle_len == 0)
		return 0;

	if (haystack_len < needle_len)
		return -1;

	const char *end = haystack + haystack_len - needle_len;
	for (const char *p = haystack; *p != '\0' && p <= end; p++) {
		size_t i;

		for (i = 0; i < needle_len; i++) {
			if (p[i] != needle[i])
				break;
		}

		if (i == needle_len)
			return p - haystack;
	}

	return -1;
}


/* {{{1
 * Retrieve the index/offset of the right-most occurence of ‘needle’ in
 * ‘haystack’, or -1 if it doesn't exist.
 */
static int
str_rindex(const char *haystack, const char *needle)
{
	assert(haystack != NULL);
	assert(needle != NULL);

	size_t needle_len = strlen(needle);
	size_t haystack_len = strlen(haystack);

	if (needle_len == 0)
		return haystack_len;

	if (haystack_len < needle_len)
		return -1;

	for (const char *p = haystack + haystack_len - needle_len; p >= haystack; p--) {
		size_t i;

		for (i = 0; i < needle_len; i++) {
			if (p[i] != needle[i])
				break;
		}

		if (i == needle_len)
			return p - haystack;
	}

	return -1;
}


/* {{{1
 * Retrieve the index/offset of the right-most occurence of ‘needle’ in
 * ‘haystack’, or -1 if it doesn't exist.
 */
static int
str_rindex_n(const char *haystack, const char *needle, size_t haystack_len)
{
	assert(haystack != NULL);
	assert(needle != NULL);

	size_t needle_len = strlen(needle);
	const char *haystack_max = haystack + haystack_len;
	const char *p = haystack;

	while (p < haystack_max && *p != '\0')
		p++;

	if (p < haystack + needle_len)
		return -1;

	p -= needle_len;

	for ( ; p >= haystack; p--) {
		size_t i;

		for (i = 0; i < needle_len; i++) {
			if (p[i] != needle[i])
				break;
		}

		if (i == needle_len)
			return p - haystack;
	}

	return -1;
}


/* {{{1
 * Retrieve the index of the left-most occurence of ‘c’ in ‘str’, or -1 if it
 * doesn't exist.
 */
int
utf_char_index(const char *str, unichar c)
{
	char ch[7];

	ch[unichar_to_utf(c, ch)] = NUL;
	char *p = strstr(str, ch);
	return (p != NULL) ? p - str : -1;
}


/* {{{1
 * Retrieve the index of the left-most occurence of ‘c’ in ‘str’, or -1 if it
 * doesn't exist, going over at most ‘len’ bytes in ‘str’.
 */
int
utf_char_index_n(const char *str, unichar c, size_t len)
{
	char ch[7];

	ch[unichar_to_utf(c, ch)] = NUL;

	return str_index_n(str, ch, len);
}


/* {{{1
 * Retrieve the index of the right-most occurence of ‘c’ in ‘str’, or -1 if it
 * doesn't exist.
 */
int
utf_char_rindex(const char *str, unichar c)
{
	char ch[7];

	ch[unichar_to_utf(c, ch)] = NUL;

	return str_rindex(str, ch);
}


/* {{{1
 * Retrieve the index of the right-most occurence of ‘c’ in ‘str’, or -1 if it
 * doesn't exist, going over at most ‘len’ bytes in ‘str’.
 */
int
utf_char_rindex_n(const char *str, unichar c, size_t len)
{
	char ch[7];

	ch[unichar_to_utf(c, ch)] = NUL;

	return str_rindex_n(str, ch, len);
}


/* {{{1
 * Retrieve the index of the left-most occurence of ‘needle’ in ‘haystack’, or
 * -1 if it doesn't exist.
 */
int
utf_index(const char *haystack, const char *needle)
{
	return strstr(haystack, needle) - haystack;
}


/* {{{1
 * Retrieve the index of the left-most occurence of ‘needle’ in ‘haystack’, or
 * -1 if it doesn't exist, going over at most ‘len’ bytes in ‘haystack’.
 */
int
utf_index_n(const char *haystack, const char *needle, size_t len)
{
	return str_index_n(haystack, needle, len);
}


/* {{{1
 * Retrieve the index of the right-most occurence of ‘needle’ in ‘haystack’, or
 * -1 if it doesn't exist.
 */
int
utf_rindex(const char *haystack, const char *needle)
{
	return str_rindex(haystack, needle);
}


/* {{{1
 * Retrieve the index of the right-most occurence of ‘needle’ in ‘haystack’, or
 * -1 if it doesn't exist, going over at most ‘len’ bytes in ‘haystack’.
 */
int
utf_rindex_n(const char *haystack, const char *needle, size_t len)
{
	return str_rindex_n(haystack, needle, len);
}


/* {{{1
 * Check if the given string begins with ‘prefix’.
 */
bool
utf_has_prefix(const char *str, const char *prefix)
{
	assert(str != NULL);
	assert(prefix != NULL);

	do {
		if (*prefix == NUL)
			return true;
		else if (*str == NUL)
			return false;
	} while (*str++ == *prefix++);

	return false;
}


/* {{{1
 * Retrieve the number of UTF-8 encoded Unicode characters in ‘str’.
 */
long
utf_length(const char *str)
{
        assert(str != NULL);

        long n = 0;
        const char *p = str;
        while (*p != '\0') {
                n++;
                p = utf_next(p);
        }

        return n;
}


/* {{{1
 * Retrieve the number of UTF-8 encoded Unicode characters in ‘str’, examining
 * ‘len’ bytes.
 */
long
utf_length_n(const char *str, long len)
{
        assert(str != NULL || len == 0);

        if (len == 0)
                return 0;

        long n = 0;
        const char *p = str;
        const char *end = str + len;
        while (p < end) {
                n++;
                p = utf_next(p);
        }

        /* This makes sure that we don’t count incomplete characters.  It won’t
         * save us from illegal UTF-8-sequences, however. */
        if (p > end)
                n--;

        return n;
}


/* {{{1
 * Retrieve the number of bytes making up the given UTF-8 string.
 */
size_t
utf_byte_length(const char *str)
{
	return strlen(str);
}


/* {{{1
 * The real implementation of utf_reverse() and utf_reverse_n() below.
 */
static char *
utf_reverse_impl(const char *str, size_t len, bool use_len)
{
	if (!use_len)
		len = utf_byte_length(str);

	char *result = ALLOC_N(char, len + 1);
	char *r = result + len;
	const char *p = str;
        while (r > result) {
		uint8_t skip = s_utf_skip_lengths[*(unsigned char *)p];
		r -= skip;
		for (char *m = r; skip > 0; skip--)
			*m++ = *p++;
	}
	result[len] = 0;

	return result;
}


/* {{{1
 * Return a new string which is ‘str’ reversed.
 */
char *
utf_reverse(const char *str)
{
	return utf_reverse_impl(str, 0, false);
}


/* {{{1
 * Return a new string which is ‘str’ reversed, examining at most ‘len’ bytes
 * of it.
 */
char *
utf_reverse_n(const char *str, size_t len)
{
	return utf_reverse_impl(str, len, true);
}


/* {{{1
 * The real implementation of utf_isvalid() and utf_isvalid_n() below.
 *
 * TODO: this needs optimizing.  Look at glib's new optimized implementation
 * (2.6.0) and also separate the ‘use_max’  into two cases.
 */
#define CONTINUATION_CHAR do {						\
	if ((*(unsigned char *)p & 0xc0) != 0x80)	/* 10xxxxxx */	\
		goto error;						\
	val <<= 6;							\
	val |= (*(unsigned char *)p) & 0x3f;				\
} while (0);

static const char *
fast_validate(const char *str)
{
	unichar val = 0;
	unichar min = 0;
	const char *p;

	for (p = str; *p != NUL; p++) {
		if (*(unsigned char *)p < 128)
			continue;

		const char *last = p;

		if ((*(unsigned char *)p & 0xe0) == 0xc0) { 			/* 110xxxxx */
			if ((*(unsigned char *)p & 0x1e) == 0)
				goto error;
			p++;
			if ((*(unsigned char *)p & 0xc0) != 0x80)		/* 10xxxxxx */
				goto error;
		} else {
			if ((*(unsigned char *)p & 0xf0) == 0xe0) {		/* 1110xxxx */
				min = (1 << 11);
				val = *(unsigned char *)p & 0x0f;
				goto two_remaining;
			} else if ((*(unsigned char *)p & 0xf8) == 0xf0) {	/* 11110xxx */
				min = (1 << 16);
				val = *(unsigned char *)p & 0x07;
			} else {
				goto error;
			}

			p++;
			CONTINUATION_CHAR;
two_remaining:
			p++;
			CONTINUATION_CHAR;
			p++;
			CONTINUATION_CHAR;

			if (val < min)
				goto error;

			if (!UNICODE_ISVALID(val))
				goto error;
		} 

		continue;
error:
		return last;
	}

	return p;
}

static const char *
fast_validate_len(const char *str, size_t max_len)
{
	unichar val = 0;
	unichar min = 0;
	const char *p;

	for (p = str; (size_t)(p - str) < max_len && *p != NUL; p++) {
		if (*(unsigned char *)p < 128)
			continue;

		const char *last = p;

		if ((*(unsigned char *)p & 0xe0) == 0xc0) { 			/* 110xxxxx */
			if (max_len - (p - str) < 2)
				goto error;

			if ((*(unsigned char *)p & 0x1e) == 0)
				goto error;
			p++;
			if ((*(unsigned char *)p & 0xc0) != 0x80) 		/* 10xxxxxx */
				goto error;
		} else {
			if ((*(unsigned char *)p & 0xf0) == 0xe0) {		/* 1110xxxx */
				if (max_len - (p - str) < 3)
					goto error;

				min = (1 << 11);
				val = *(unsigned char *)p & 0x0f;
				goto two_remaining;
			} else if ((*(unsigned char *)p & 0xf8) == 0xf0) {	/* 11110xxx */
				if (max_len - (p - str) < 4)
					goto error;

				min = (1 << 16);
				val = *(unsigned char *)p & 0x07;
			} else {
				goto error;
			}

			p++;
			CONTINUATION_CHAR;
two_remaining:
			p++;
			CONTINUATION_CHAR;
			p++;
			CONTINUATION_CHAR;

			if (val < min)
				goto error;
			if (!UNICODE_ISVALID(val))
				goto error;
		} 

		continue;
error:
		return last;
	}

	return p;
}


/* {{{1
 * Check if ‘str’ constitutes a valid UTF-8 character sequence.
 */
bool
utf_isvalid(const char *str)
{
	const char *p = fast_validate(str);

	return *p == NUL;
}


/* {{{1
 * Check if ‘str’ constitutes a valid UTF-8 character sequence, examining at
 * most ‘max’ bytes.  If it turns out ‘str’ isn't a valid UTF-8 character
 * sequence and ‘end’ is non-‹NULL›, ‘end’ is set to the end of the valid range
 * of bytes in ‘str’.
 */
bool
utf_isvalid_n(const char *str, size_t max, const char **end)
{
	const char *p = fast_validate_len(str, max);

	if (end != NULL)
		*end = p;

	return p == str + max;
}


/* {{{1
 * Check whether ‘c’ is a valid Unicode character.
 */
bool
unichar_isvalid(unichar c)
{
	return UNICODE_ISVALID(c);
}


/* {{{1
 * Turn an Unicode character (UTF-32) into an UTF-8 character sequence and
 * store it in ‘result’, returning the length of the stored sequence.
 */
int
unichar_to_utf(unichar c, char *result)
{
	int len = 0;
	int first;

	if (c < UNI_LEN1) {
		first = 0;
		len = 1;
	} else if (c < UNI_LEN2) {
		first = 0xc0;
		len = 2;
	} else if (c < UNI_LEN3) {
		first = 0xe0;
		len = 3;
	} else if (c < UNI_LEN4) {
		first = 0xf0;
		len = 4;
	} else if (c < UNI_LEN5) {
		first = 0xf8;
		len = 5;
	} else {
		first = 0xfc;
		len = 6;
	} 

	if (result != NULL) {
		for (int i = len - 1; i > 0; i--)
			c = PUT_X(c, result[i]);

		result[0] = c | first;
	}

	return len;
}


/* {{{1
 * The real implementation of ucs4_to_utf8() and ucs4_to_utf8_n() below.
 */
static char *
ucs4_to_utf8_n_impl(unichar *str, size_t len, bool use_len,
		    size_t *items_read, size_t *items_written)
{
	size_t result_len = 0;
	char *result = NULL, *p;

	for (size_t i = 0; (!use_len || i < len) && str[i] != NUL; i++) {
		if (str[i] >= 0x80000000) {
			if (items_read != NULL)
				*items_read = i;

			rb_raise(rb_eArgError, "UCS-4 input contains character outside of range for UTF-8 (%lc))", str[i]);
		}

		result_len += _utf_length(str[i]);
	}

	p = result = ALLOC_N(char, result_len + 1);
	size_t i;
	for (i = 0; p < result + result_len; i++)
		p += unichar_to_utf(str[i], p);
	*p = NUL;

	if (items_written != NULL)
		*items_written = p - result;
	if (items_read != NULL)
		*items_read = i;

	return result;
}

/* {{{1
 * Turn an UTF-32 encoded string into an UTF-8 encoded one.  If non-‹NULL›,
 * store the number of characters read and bytes written in ‘items_read’ and
 * ‘items_written’ respectivelly.
 */
char *
ucs4_to_utf8(unichar *str, size_t *items_read, size_t *items_written)
{
	return ucs4_to_utf8_n_impl(str, 0, false, items_read, items_written);
}

/* {{{1
 * Turn an UTF-32 encoded string into an UTF-8 encoded one.  If non-‹NULL›,
 * store the number of characters read and bytes written in ‘items_read’ and
 * ‘items_written’ respectivelly.  Examine at most ‘len’ characters from ‘str’.
 */
char *
ucs4_to_utf8_n(unichar *str, size_t len, size_t *items_read, size_t *items_written)
{
	return ucs4_to_utf8_n_impl(str, len, true, items_read, items_written);
}


/* {{{1
 * The real implementation of utf8_to_ucs4_fast() and utf8_to_ucs4_fast_n()
 * below.
 */
static unichar *
utf8_to_ucs4_fast_impl(const char *str, size_t len, bool use_len, size_t *items_written)
{
	assert(str != NULL);

	const char *p = str;
	size_t n = 0;
	if (use_len) {
		while (p < str + len && *p != NUL) {
			p = utf_next(p);
			n++;
		}
	} else {
		while (p != NUL) {
			p = utf_next(p);
			n++;
		}
	}

	unichar *result = ALLOC_N(unichar, n + 1);
	p = str;
	size_t i;
	for (i = 0; i < n; i++) {
		unichar c = ((unsigned char *)p)[0];
		int c_len;

		if (c < 0x80) {
			result[i] = c;
			p++;
		} else {
			/* TODO: use _utf_compute() here */
			if (c < 0xe0) {
				c_len = 2;
				c &= 0x1f;
			} else if (c < 0xf0) {
				c_len = 3;
				c &= 0x0f;
			} else if (c < 0xf8) {
				c_len = 4;
				c &= 0x07;
			} else if (c < 0xfc) {
				c_len = 5;
				c &= 0x03;
			} else {
				c_len = 6;
				c &= 0x01;
			}

			for (int j = 1; j < c_len; j++) {
				c <<= BIT_X;
				c |= ((unsigned char *)p)[j] & MASK_X;
			}

			result[i] = c;
			p += c_len;
		}
	}
	result[i] = NUL;

	if (items_written != NULL)
		*items_written = i;

	return result;
}


/* {{{1
 * Turn an UTF-8 character sequence into an UTF-32 one.  If non-‹NULL›, store
 * the number of characters written in ‘items_written’.
 */
unichar *
utf8_to_ucs4_fast(const char *str, size_t *items_written)
{
	return utf8_to_ucs4_fast_impl(str, 0, false, items_written);
}


/* {{{1
 * Turn an UTF-8 character sequence into an UTF-32 one.  If non-‹NULL›, store
 * the number of characters written in ‘items_written’.  Examine at most ‘len’
 * bytes from ‘str’.
 */
unichar *
utf8_to_ucs4_fast_n(const char *str, size_t len, size_t *items_written)
{
	return utf8_to_ucs4_fast_impl(str, len, true, items_written);
}


/* {{{1
 * The real implementation of utf8_to_ucs4() and utf8_to_ucs4_n() below.
 */
static unichar *
utf8_to_ucs4_impl(const char *str, size_t len, bool use_len, size_t *items_read, size_t *items_written)
{
	size_t n = 0;
	const char *p = str;
	for (; (!use_len || str + len - p > 0) && *p != NUL; p = utf_next(p)) {
		unichar c = utf_char_n(p, str + len - p);
		if (c & 0x80000000) {
			if (c == UTF_INCOMPLETE_INPUT_UNICHAR) {
				if (items_read != NULL)
					break;

				rb_raise(rb_eArgError, "partial character sequence in UTF-8 input");
			} else {
				rb_raise(rb_eArgError, "UTF-8 input contains character outside of range for UTF-8 (%lc))", c);
			}

			if (items_read != NULL)
				*items_read = p - str;

			return NULL;
		} else {
			n++;
		}
	}

	unichar *result = ALLOC_N(unichar, n + 1);
	size_t i;
	for (i = 0, p = str; i < n; i++) {
		result[i] = utf_char(p);
		p = utf_next(p);
	}
	result[i] = NUL;

	if (items_written != NULL)
		*items_written = n;
	if (items_read != NULL)
		*items_read = p - str;

	return result;
}


/* {{{1
 * Turn an UTF-8 character sequence into an UTF-32 one.  If non-‹NULL›, store
 * the number of characters written in ‘items_written’.  This function does
 * additional error-checking on the input.
 */
unichar *
utf8_to_ucs4(const char *str, size_t *items_read, size_t *items_written)
{
	return utf8_to_ucs4_impl(str, 0, false, items_read, items_written);
}


/* {{{1
 * Turn an UTF-8 character sequence into an UTF-32 one.  If non-‹NULL›, store
 * the number of characters written in ‘items_written’.  Examine at most ‘len’
 * bytes from ‘str’.  This function does additional error-checking on the
 * input.
 */
unichar *
utf8_to_ucs4_n(const char *str, int len, size_t *items_read, size_t *items_written)
{
	return utf8_to_ucs4_impl(str, len, true, items_read, items_written);
}


/* }}}1 */
