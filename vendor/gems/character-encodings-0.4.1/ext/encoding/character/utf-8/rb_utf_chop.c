/*
 * contents: UTF8.chop module function.
 *
 * Copyright © 2006 Nikolai Weibull <now@bitwi.se>
 */

#include "rb_includes.h"

VALUE
rb_utf_chop_bang(UNUSED(VALUE self), VALUE str)
{
        StringValue(str);

        if (RSTRING(str)->len == 0)
                return Qnil;

        rb_str_modify(str);

        const char *end = RSTRING(str)->ptr + RSTRING(str)->len;

        char *last = rb_utf_prev_validated(RSTRING(str)->ptr, end);

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

VALUE
rb_utf_chop(VALUE self, VALUE str)
{
        str = rb_utf_dup(str);
        rb_utf_chop_bang(self, str);
        return str;
}
