/*
 * contents: UTF8.collate module function.
 *
 * Copyright © 2006 Nikolai Weibull <now@bitwi.se>
 */

#include "rb_includes.h"

VALUE
rb_utf_collate(UNUSED(VALUE self), VALUE str, VALUE other)
{
        return INT2FIX(utf_collate(StringValuePtr(str), StringValuePtr(other)));
}
