/*
 * contents: Codepoint class.
 *
 * Copyright © 2006 Nikolai Weibull <now@bitwi.se>
 */

#include <ruby.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <limits.h>
#include "unicode.h"
#include "private.h"

static VALUE
rb_codepoint_to_utf8(UNUSED(VALUE self), VALUE codepoint)
{
        /* TODO: validate input */
        char buf[MAX_UNICHAR_BYTE_LENGTH];
        int len = unichar_to_utf(FIX2UINT(codepoint), buf);

        return rb_utf_new(buf, len);
}

static VALUE
rb_codepoint_from_utf8(UNUSED(VALUE self), VALUE str)
{
        StringValue(str);

        const char *s = RSTRING(str)->ptr;
        const char *end = s + RSTRING(str)->len;
        return INT2FIX(_utf_char_validated(s, end));
}

void Init_codepoint(void);
void
Init_codepoint(void)
{
        VALUE mEncoding = rb_define_module("Encoding");
        VALUE mCharacter = rb_define_module_under(mEncoding, "Character");

        VALUE mUnicode = rb_define_module_under(mCharacter, "Unicode");
        VALUE mCodepoint = rb_define_module_under(mUnicode, "Codepoint");

        /* TODO: undecided */
        rb_define_module_function(mCodepoint, "to_utf8", rb_codepoint_to_utf8, 1);
        rb_define_module_function(mCodepoint, "from_utf8", rb_codepoint_from_utf8, 1);
}
