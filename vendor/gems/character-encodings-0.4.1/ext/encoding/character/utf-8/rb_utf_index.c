/*
 * contents: UTF8.index module function.
 *
 * Copyright © 2006 Nikolai Weibull <now@bitwi.se>
 */

#include "rb_includes.h"

VALUE
rb_utf_index_m(int argc, VALUE *argv, UNUSED(VALUE self))
{
        VALUE str, sub, rboffset;

        long offset = 0;
        if (rb_scan_args(argc, argv, "21", &str, &sub, &rboffset) == 3)
                offset = NUM2LONG(rboffset);

        StringValue(str);

        char *begin, *end;
        if (!rb_utf_begin_from_offset(str, offset, &begin, &end)) {
                if (TYPE(sub) == T_REGEXP)
                        rb_backref_set(Qnil);

                return Qnil;
        }

        switch (TYPE(sub)) {
        case T_REGEXP:
                offset = rb_utf_index_regexp(str, begin, end, sub, offset, false);
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
                offset = rb_utf_index(str, sub, offset);
                break;
        }

        if (offset < 0)
                return Qnil;

        return LONG2NUM(offset);
}
