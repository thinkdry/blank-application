/*
 * contents: Unicode class.
 *
 * Copyright © 2005 Nikolai Weibull <work@rawuncut.elitemail.org>
 */


#include <ruby.h>
#include <re.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <limits.h>
#include "unicode.h"
#include "private.h"
#include "rb_private.h"
#include "rb_methods.h"

static VALUE mUTF8Methods;

void
need_at_least_n_arguments(int argc, int n)
{
        static const char *const words[] = {
                NULL,   NULL, "two",   "three", "four",
                "five", "six", "seven", "eight", "nine"
        };

        if (argc >= n)
                return;

        if (n == 1)
                rb_raise(rb_eArgError, "need at least one argument");
        else if (1 < n && n < 10)
                rb_raise(rb_eArgError, "need at least %s arguments", words[n]);
        else
                rb_raise(rb_eArgError, "need at least %d arguments", n);
}

unichar
_utf_char_validated(char const *const str, char const *const str_end)
{
        unichar c = utf_char_validated_n(str, str_end - str);
        switch (c) {
        case UTF_BAD_INPUT_UNICHAR:
                rb_raise(rb_eArgError, "input isn’t valid UTF-8");
        case UTF_INCOMPLETE_INPUT_UNICHAR:
                rb_raise(rb_eArgError,
                         "input contains an incomplete UTF-8-encoded character");
        default:
                return c;
        }
}

/* TODO: instead of ‘end’, perhaps use a len/max-type parameter? */
char *
_utf_offset_to_pointer_validated_impl(const char *str, long offset,
                                      const char *limit, bool noisy)
{
	const char *p = str;
        long saved_offset = offset;

        if (offset > 0) {
                while (p < limit && offset-- > 0)
                        p = utf_next(p);

                if (offset > 0) {
                        if (noisy)
                                rb_raise(rb_eIndexError,
                                         "index %ld lays beyond end of string",
                                         saved_offset);
                        else
                                return NULL;
                }
        } else {
                while (offset != 0) {
                        const char *base = p;
                        p += offset;
                        while (p >= limit && (*p & 0xc0) == 0x80)
                                p--;

                        if (p < limit) {
                                if (noisy)
                                        rb_raise(rb_eIndexError,
                                                "index %ld lays before beginning of string",
                                                saved_offset);
                                else
                                        return NULL;
                        }
         
                        offset += utf_pointer_to_offset(p, base);
                 }
        }

	return (char *)p;
}

char *
_utf_offset_to_pointer_validated(const char *str, long offset, const char *end)
{
        return _utf_offset_to_pointer_validated_impl(str, offset, end, true);
}

char *
_utf_offset_to_pointer_failable(const char *str, long offset, const char *end)
{
        return _utf_offset_to_pointer_validated_impl(str, offset, end, false);
}

static char *
rb_utf_begin_setup(VALUE str, long offset, char **base_limit, char **limit)
{
        char *base = RSTRING(str)->ptr;

        *base_limit = RSTRING(str)->ptr + RSTRING(str)->len;
        *limit = *base_limit;

        if (offset < 0) {
                char *tmp = base;
                base = *base_limit;
                *base_limit = tmp;
        }

        return base;
}

bool
rb_utf_begin_from_offset(VALUE str, long offset, char **begin, char **limit)
{
        char *base_limit;
        char *base = rb_utf_begin_setup(str, offset, &base_limit, limit);

        *begin = _utf_offset_to_pointer_failable(base, offset, base_limit);

        return (*begin != NULL);
}

void
rb_utf_begin_from_offset_validated(VALUE str, long offset, char **begin,
                                   char **limit)
{
        char *base_limit;
        char *base = rb_utf_begin_setup(str, offset, &base_limit, limit);

        *begin = _utf_offset_to_pointer_validated(base, offset, base_limit);
}

char *
rb_utf_prev_validated(const char *begin, const char *p)
{
        char *prev = utf_find_prev(begin, p);
        if (prev == NULL)
                rb_raise(rb_eArgError, "input isn’t valid UTF-8");
        return prev;
}

char *
rb_utf_next_validated(const char *p, const char *end)
{
        char *next = (char *)utf_next(p);
        if (next > end)
                rb_raise(rb_eArgError, "input isn’t valid UTF-8");
        return next;
}

VALUE
rb_utf_update(VALUE str, long offset, long len, VALUE replacement)
{
        if (len < 0)
                rb_raise(rb_eIndexError, "negative length %ld", len);

        char *begin, *limit;
        rb_utf_begin_from_offset_validated(str, offset, &begin, &limit);
        char *end = _utf_offset_to_pointer_failable(begin, len, limit);
        if (end == NULL)
                end = limit;

        rb_str_update(str, begin - RSTRING(str)->ptr, end - begin, replacement);

        return replacement;
}

VALUE
rb_utf_new(const char *str, long len)
{
        VALUE rbstr = rb_str_new(str, len);
        rb_extend_object(rbstr, mUTF8Methods);
        return rbstr;
}

VALUE
rb_utf_new2(const char *str)
{
        VALUE rbstr = rb_str_new2(str);
        rb_extend_object(rbstr, mUTF8Methods);
        return rbstr;
}

VALUE
rb_utf_new5(VALUE obj, const char *str, long len)
{
        VALUE rbstr = rb_str_new5(obj, str, len);
        rb_extend_object(rbstr, mUTF8Methods);
        return rbstr;
}

VALUE
rb_utf_alloc_using(char *str)
{
        VALUE rbstr = rb_utf_new(NULL, 0);
        long len = strlen(str);

        RSTRING(rbstr)->ptr = str;
        RSTRING(rbstr)->aux.capa = len;
        RSTRING(rbstr)->len = len;
        RSTRING(rbstr)->ptr[len] = '\0';

        return rbstr;
}

VALUE
rb_utf_dup(VALUE str)
{
        str = rb_str_dup(str);
        rb_extend_object(str, mUTF8Methods);
        return str;
}

/* TODO: rewrite this using the new offset-calculating functions. */
long
rb_utf_index(VALUE str, VALUE sub, long offset)
{
        long n_chars = utf_length_n(RSTRING(str)->ptr, RSTRING(str)->len);

        if (offset < 0) {
                offset += n_chars;

                if (offset < 0)
                        return -1;
        }

        if (n_chars - offset < utf_length(RSTRING(sub)->ptr))
                return -1;

        if (RSTRING(sub)->len == 0)
                return offset;

        char *begin = utf_offset_to_pointer(RSTRING(str)->ptr, offset);
        long pos = rb_memsearch(RSTRING(sub)->ptr, RSTRING(sub)->len,
                                begin, RSTRING(str)->len - (begin - RSTRING(str)->ptr));

        if (pos < 0)
                return -1;

        return offset + utf_pointer_to_offset(begin, begin + pos);
}

long
rb_utf_index_regexp(VALUE str, const char *s, const char *end, VALUE sub,
                    long offset, bool reverse)
{
        long byte_offset = _utf_offset_to_pointer_validated(s, offset, end) - s;
        long byte_startpos = rb_reg_adjust_startpos(sub, str, byte_offset, reverse);
        long byte_index = rb_reg_search(sub, str, byte_startpos, reverse);
        if (byte_index == -1)
                return -1;
        return utf_pointer_to_offset(s, s + byte_index);
}

void Init_utf8(void);
void
Init_utf8(void)
{
        VALUE mEncoding = rb_define_module("Encoding");
        VALUE mCharacter = rb_define_module_under(mEncoding, "Character");
        VALUE mUTF8 = rb_define_module_under(mCharacter, "UTF8");

        mUTF8Methods = rb_define_module_under(mUTF8, "Methods");

        rb_define_module_function(mUTF8, "collate", rb_utf_collate, 2);
        rb_define_module_function(mUTF8, "aref", rb_utf_aref_m, -1);
        rb_define_module_function(mUTF8, "aset", rb_utf_aset_m, -1);
        rb_define_module_function(mUTF8, "casecmp", rb_utf_casecmp, 2);
        rb_define_module_function(mUTF8, "center", rb_utf_center, -1);
        rb_define_module_function(mUTF8, "chomp", rb_utf_chomp, -1);
        rb_define_module_function(mUTF8, "chomp!", rb_utf_chomp_bang, -1);
        rb_define_module_function(mUTF8, "chop", rb_utf_chop, 1);
        rb_define_module_function(mUTF8, "chop!", rb_utf_chop_bang, 1);
        rb_define_module_function(mUTF8, "count", rb_utf_count, -1);
        rb_define_module_function(mUTF8, "delete", rb_utf_delete, -1);
        rb_define_module_function(mUTF8, "delete!", rb_utf_delete_bang, -1);
        rb_define_module_function(mUTF8, "each_char", rb_utf_each_char, 1);
        rb_define_module_function(mUTF8, "index", rb_utf_index_m, -1);
        rb_define_module_function(mUTF8, "insert", rb_utf_insert, 3);
        rb_define_module_function(mUTF8, "lstrip", rb_utf_lstrip, 1);
        rb_define_module_function(mUTF8, "lstrip!", rb_utf_lstrip_bang, 1);
        rb_define_module_function(mUTF8, "rindex", rb_utf_rindex_m, -1);
        rb_define_module_function(mUTF8, "rstrip", rb_utf_rstrip, 1);
        rb_define_module_function(mUTF8, "rstrip!", rb_utf_rstrip_bang, 1);
        rb_define_module_function(mUTF8, "squeeze", rb_utf_squeeze, -1);
        rb_define_module_function(mUTF8, "squeeze!", rb_utf_squeeze_bang, -1);
        rb_define_module_function(mUTF8, "strip", rb_utf_strip, 1);
        rb_define_module_function(mUTF8, "strip!", rb_utf_strip_bang, 1);
        rb_define_module_function(mUTF8, "to_i", rb_utf_to_i, -1);
        rb_define_module_function(mUTF8, "hex", rb_utf_hex, 1);
        rb_define_module_function(mUTF8, "oct", rb_utf_oct, 1);
        rb_define_module_function(mUTF8, "tr", rb_utf_tr, 3);
        rb_define_module_function(mUTF8, "tr_s", rb_utf_tr_s, 3);

        rb_define_module_function(mUTF8, "downcase", rb_utf_downcase, 1);
        rb_define_module_function(mUTF8, "ljust", rb_utf_ljust, -1);
        rb_define_module_function(mUTF8, "length", rb_utf_length, 1);
        rb_define_module_function(mUTF8, "reverse", rb_utf_reverse, 1);
        rb_define_module_function(mUTF8, "rjust", rb_utf_rjust, -1);
        rb_define_module_function(mUTF8, "upcase", rb_utf_upcase, 1);

        rb_define_module_function(mUTF8, "foldcase", rb_utf_foldcase, 1);
        rb_define_module_function(mUTF8, "normalize", rb_utf_normalize, -1);
}
