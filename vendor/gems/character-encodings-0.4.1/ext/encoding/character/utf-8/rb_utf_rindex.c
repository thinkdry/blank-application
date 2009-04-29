/*
 * contents: UTF8.rindex module function.
 *
 * Copyright © 2006 Nikolai Weibull <now@bitwi.se>
 */

#include "rb_includes.h"

static long
rb_utf_rindex(VALUE str, VALUE sub, long offset)
{
        if (RSTRING(str)->len < RSTRING(sub)->len)
                return -1;

        char *s, *end;
        rb_utf_begin_from_offset_validated(str, offset, &s, &end);

        if (RSTRING(sub)->len == 0)
                return utf_pointer_to_offset(RSTRING(str)->ptr, s);

        char *s_begin = RSTRING(str)->ptr;
        char *t = RSTRING(sub)->ptr;
        long len = RSTRING(sub)->len;
        while (s >= s_begin) {
                if (rb_memcmp(s, t, len) == 0)
                        return utf_pointer_to_offset(s_begin, s);
                s--;
        }

        return -1;
}

VALUE
rb_utf_rindex_m(int argc, VALUE *argv, UNUSED(VALUE self))
{
        VALUE str, sub, rboffset;

        rb_scan_args(argc, argv, "21", &str, &sub, &rboffset);

        StringValue(str);

        long offset = (argc == 3) ? NUM2LONG(rboffset) : RSTRING(str)->len;

        char *begin, *end;
        rb_utf_begin_from_offset(str, offset, &begin, &end);
        if (begin == NULL) {
                if (offset <= 0) {
                        if (TYPE(sub) == T_REGEXP)
                                rb_backref_set(Qnil);

                        return Qnil;
                }

                begin = end;
                /* TODO: this converting back and forward can be optimized away
                 * if rb_utf_index_regexp() and rb_utf_rindex() were split up
                 * into two additional functions, adding
                 * rb_utf_index_regexp_pointer() and rb_utf_rindex_pointer(),
                 * so that one can pass a pointer to start at immediately
                 * instead of an offset that gets calculated into a pointer. */
                offset = utf_length_n(RSTRING(str)->ptr, RSTRING(str)->len);
        }

        switch (TYPE(sub)) {
        case T_REGEXP:
                if (RREGEXP(sub)->len > 0)
                        offset = rb_utf_index_regexp(str, begin, end, sub,
                                                     offset, true);
                break;
        default: {
                VALUE tmp = rb_check_string_type(sub);
                if (NIL_P(tmp))
                        rb_raise(rb_eTypeError, "type mismatch: %s given",
                                 rb_obj_classname(sub));

                sub = tmp;
        }
                /* fall through */
        case T_STRING:
                offset = rb_utf_rindex(str, sub, offset);
                break;
        }

        if (offset < 0)
                return Qnil;

        return LONG2NUM(offset);
}
