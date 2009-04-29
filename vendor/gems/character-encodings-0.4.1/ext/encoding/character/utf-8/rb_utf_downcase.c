/*
 * contents: UTF8.downcase module function.
 *
 * Copyright © 2006 Nikolai Weibull <now@bitwi.se>
 */

#include "rb_includes.h"

VALUE
rb_utf_downcase(UNUSED(VALUE self), VALUE str)
{
        return rb_utf_alloc_using(utf_downcase(StringValuePtr(str)));
}
