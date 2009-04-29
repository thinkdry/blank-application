/*
 * contents: UTF8.to_i module function.
 *
 * Copyright © 2006 Nikolai Weibull <now@bitwi.se>
 */

#include "rb_includes.h"
#include "rb_utf_internal_bignum.h"

VALUE
rb_utf_to_i(int argc, VALUE *argv, UNUSED(VALUE self))
{
        VALUE str, rbbase;

        int base = 10;
        if (rb_scan_args(argc, argv, "11", &str, &rbbase) == 2)
                base = NUM2INT(rbbase);

        /* XXX: this test is actually unnecessary, as this will be checked in
         * rb_utf_to_inum() as well. */
        if (base < 0)
                rb_raise(rb_eArgError, "illegal radix %d", base);

        return rb_utf_to_inum(str, base, false);
}
