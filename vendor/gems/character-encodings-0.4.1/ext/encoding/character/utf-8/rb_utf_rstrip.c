/*
 * contents: UTF8.rstrip module function.
 *
 * Copyright © 2006 Nikolai Weibull <now@bitwi.se>
 */

#include "rb_includes.h"

VALUE
rb_utf_rstrip_bang(UNUSED(VALUE self), VALUE str)
{
        StringValue(str);
        const char *begin = RSTRING(str)->ptr;
        if (begin == NULL || RSTRING(str)->len == 0)
                return Qnil;

        const char *end = begin + RSTRING(str)->len;
        const char *t = end;

        /* Remove trailing '\0'’s. */
        while (t > begin && t[-1] == '\0')
                t--;

        /* Remove trailing spaces. */
        while (t > begin) {
                /* FIXME: Should we be validating here? */
                const char *prev = rb_utf_prev_validated(begin, t);
                
                if (!unichar_isspace(utf_char(prev)))
                        break;

                t = prev;
        }

        if (t == end)
                return Qnil;

        rb_str_modify(str);
        RSTRING(str)->len = t - begin;
        RSTRING(str)->ptr[RSTRING(str)->len] = '\0';

        return str;
}

VALUE
rb_utf_rstrip(VALUE self, VALUE str)
{
        str = rb_utf_dup(str);
        rb_utf_rstrip_bang(self, str);
        return str;
}
