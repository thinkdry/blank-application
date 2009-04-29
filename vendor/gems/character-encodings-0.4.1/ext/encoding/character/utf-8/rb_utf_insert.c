/*
 * contents: UTF8.insert module function.
 *
 * Copyright © 2006 Nikolai Weibull <now@bitwi.se>
 */

#include "rb_includes.h"

/* TODO: Update to use new offset-calculating functions. */
VALUE
rb_utf_insert(UNUSED(VALUE self), VALUE str, VALUE index, VALUE other)
{
        long offset = NUM2LONG(index);

        StringValue(str);

        long n_chars = utf_length_n(RSTRING(str)->ptr, RSTRING(str)->len);

        if (abs(offset) > n_chars) {
                if (offset < 0)
                        offset -= n_chars;
                rb_raise(rb_eIndexError, "index %ld out of string", offset);
        }

        long byte_index;

        if (offset == -1) {
                byte_index = RSTRING(str)->len;
        } else {
                if (offset < 0)
                        offset++;

                char *s = RSTRING(str)->ptr;

                if (offset < 0)
                        s += RSTRING(str)->len;
                byte_index = utf_offset_to_pointer(s, offset) - s;
        }

        rb_str_update(str, byte_index, 0, other);

        return str;
}
