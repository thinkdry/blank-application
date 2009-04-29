/*
 * contents: UTF8.chomp module function.
 *
 * Copyright © 2006 Nikolai Weibull <now@bitwi.se>
 */

#include "rb_includes.h"

static VALUE
rb_utf_chomp_default(VALUE str)
{
        rb_str_modify(str);

        const char *end = RSTRING(str)->ptr + RSTRING(str)->len;

        char *last = utf_find_prev(RSTRING(str)->ptr, end);
        if (last == NULL)
                return Qnil;

        if (_utf_char_validated(last, end) == '\n') {
                char *last_but_one = utf_find_prev(RSTRING(str)->ptr, last);

                if (last_but_one != NULL && utf_char(last_but_one) == '\r')
                        last = last_but_one;
        } else if (!unichar_isnewline(utf_char(last))) {
                return Qnil;
        }

        RSTRING(str)->len -= (RSTRING(str)->ptr + RSTRING(str)->len) - last;
        *last = '\0';

        return str;
}

static VALUE
rb_utf_chomp_newlines(VALUE str)
{
        char *begin = RSTRING(str)->ptr;
        char *end = begin + RSTRING(str)->len;

        char *last = end;
        while (last > begin) {
                char *last_but_one = utf_find_prev(begin, last);
                if (last == NULL || !unichar_isnewline(utf_char(last_but_one)))
                        break;
                last = last_but_one;
        }

        if (last == end)
                return Qnil;

        rb_str_modify(str);
        RSTRING(str)->len -= end - last;
        *last = '\0';

        return str;
}

VALUE
rb_utf_chomp_bang(int argc, VALUE *argv, UNUSED(VALUE self))
{
        VALUE str, rs;

        rb_scan_args(argc, argv, "11", &str, &rs);

        if (RSTRING(str)->len == 0)
                return Qnil;

        if (argc == 1) {
                rs = rb_rs;
                if (rs == rb_default_rs)
                        rb_utf_chomp_default(str);
        }

        if (NIL_P(rs))
                return Qnil;

        StringValue(rs);

        long rs_len = RSTRING(rs)->len;
        if (rs_len == 0)
                return rb_utf_chomp_newlines(str);

        long len = RSTRING(str)->len;
        if (rs_len > len)
                return Qnil;

        char last_char = RSTRING(rs)->ptr[rs_len - 1];
        if (rs_len == 1 && last_char == '\n')
                rb_utf_chomp_default(str);

        char *p = RSTRING(str)->ptr;

        if (p[len - 1] != last_char ||
            (rs_len > 1 &&
             rb_memcmp(RSTRING(rs)->ptr, p + len - rs_len, rs_len) != 0))
                return Qnil;

        rb_str_modify(str);
        RSTRING(str)->len -= rs_len;
        RSTRING(str)->ptr[RSTRING(str)->len] = '\0';

        return str;
}

VALUE
rb_utf_chomp(int argc, VALUE *argv, VALUE self)
{
        StringValue(argv[0]);
        argv[0] = rb_utf_dup(argv[0]);
        rb_utf_chomp_bang(argc, argv, self);
        return argv[0];
}

