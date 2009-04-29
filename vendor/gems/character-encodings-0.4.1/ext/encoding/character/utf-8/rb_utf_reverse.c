/*
 * contents: UTF8.reverse module function.
 *
 * Copyright © 2006 Nikolai Weibull <now@bitwi.se>
 */

#include "rb_includes.h"

VALUE
rb_utf_reverse(UNUSED(VALUE self), VALUE str)
{
        return rb_utf_alloc_using(utf_reverse(StringValuePtr(str)));
}
