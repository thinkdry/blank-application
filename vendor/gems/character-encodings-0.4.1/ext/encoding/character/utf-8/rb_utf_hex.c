/*
 * contents: UTF8.hex module function.
 *
 * Copyright © 2006 Nikolai Weibull <now@bitwi.se>
 */

#include "rb_includes.h"
#include "rb_utf_internal_bignum.h"

VALUE
rb_utf_hex(UNUSED(VALUE self), VALUE str)
{
        return rb_utf_to_inum(str, 16, false);
}
