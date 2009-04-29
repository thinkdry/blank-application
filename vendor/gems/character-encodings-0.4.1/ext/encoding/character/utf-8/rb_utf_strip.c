/*
 * contents: UTF8.strip module function.
 *
 * Copyright © 2006 Nikolai Weibull <now@bitwi.se>
 */

#include "rb_includes.h"

VALUE
rb_utf_strip_bang(VALUE self, VALUE str)
{
        VALUE left = rb_utf_lstrip_bang(self, str);
        VALUE right = rb_utf_rstrip_bang(self, str);

        if (NIL_P(left) && NIL_P(right))
                return Qnil;

        return str;
}

VALUE
rb_utf_strip(VALUE self, VALUE str)
{
        str = rb_utf_dup(str);
        rb_utf_strip_bang(self, str);
        return str;
}
