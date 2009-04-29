/*
 * contents: UTF8.folcase module function.
 *
 * Copyright © 2006 Nikolai Weibull <now@bitwi.se>
 */

#include "rb_includes.h"

VALUE
rb_utf_foldcase(UNUSED(VALUE self), VALUE str)
{
        return rb_utf_alloc_using(utf_foldcase(StringValuePtr(str)));
}
