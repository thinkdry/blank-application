/*
 * contents: UTF8.casecmp module function.
 *
 * Copyright © 2006 Nikolai Weibull <now@bitwi.se>
 */

#include "rb_includes.h"

VALUE
rb_utf_casecmp(UNUSED(VALUE self), VALUE str1, VALUE str2)
{
        StringValue(str1);
        StringValue(str2);

        char *folded1 = utf_foldcase(RSTRING(str1)->ptr);
        char *folded2 = utf_foldcase(RSTRING(str2)->ptr);

        int result = utf_collate(folded1, folded2);

        free(folded2);
        free(folded1);

        return INT2FIX(result);
}
