/*
 * contents: UTF8.each_char module function.
 *
 * Copyright © 2006 Nikolai Weibull <now@bitwi.se>
 */

#include "rb_includes.h"

VALUE
rb_utf_each_char(UNUSED(VALUE self), VALUE str)
{
#if 0
        RETURN_ENUMERATOR(str, 0, 0);
#endif

        const char *s = RSTRING(str)->ptr;
        const char *s_end = s + RSTRING(str)->len;
        while (s < s_end) {
                char buf[MAX_UNICHAR_BYTE_LENGTH];
                int len = unichar_to_utf(_utf_char_validated(s, s_end), buf);
                VALUE c = rb_utf_new(buf, len);
                rb_yield(c);
                s = utf_next(s);
        }

        return str;
}
