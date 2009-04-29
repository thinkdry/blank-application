/*
 * contents: UTF8.oct module function.
 *
 * Copyright © 2006 Nikolai Weibull <now@bitwi.se>
 */

#include "rb_includes.h"
#include "rb_utf_internal_bignum.h"

VALUE
rb_utf_oct(UNUSED(VALUE self), VALUE str)
{
        return rb_utf_to_inum(str, -8, false);
}
