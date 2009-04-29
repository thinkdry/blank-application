/*
 * contents: UTF8.aref module function.
 *
 * Copyright © 2006 Nikolai Weibull <now@bitwi.se>
 */

#include "rb_includes.h"
#include <re.h>

static VALUE
rb_utf_substr(VALUE str, long offset, long len)
{
        if (len < 0)
                return Qnil;

        char *begin, *limit;
        if (!rb_utf_begin_from_offset(str, offset, &begin, &limit))
                return Qnil;
        char *end = _utf_offset_to_pointer_failable(begin, len, limit);
        if (end == NULL)
                end = limit;

        VALUE substr = (begin == end) ?
                rb_utf_new5(str, NULL, 0) :
                rb_utf_new5(str, begin, end - begin);

        OBJ_INFECT(substr, str);

        return substr;
}

static VALUE
rb_utf_substr_and_infect(VALUE str, long offset, long len, VALUE source)
{
        VALUE substr = rb_utf_substr(str, offset, len);
        OBJ_INFECT(substr, source);
        return substr;
}

/* XXX: Stolen straight from string.c. */
static VALUE
rb_str_subpat(VALUE str, VALUE re, int nth)
{
        if (rb_reg_search(re, str, 0, 0) >= 0)
                return rb_reg_nth_match(nth, rb_backref_get());

        return Qnil;
}

static VALUE
rb_utf_aref_num(VALUE str, long offset)
{
        char *begin, *limit;
        if (!rb_utf_begin_from_offset(str, offset, &begin, &limit))
                return Qnil;

        char *end = rb_utf_next_validated(begin, limit);

        return rb_utf_new(begin, end - begin);
}

static VALUE
rb_utf_aref_default(VALUE str, VALUE index)
{
        long n_chars = utf_length_n(RSTRING(str)->ptr, RSTRING(str)->len);

        long begin, len;
        switch (rb_range_beg_len(index, &begin, &len, n_chars, 0)) {
        case Qfalse:
                return rb_utf_aref_num(str, NUM2LONG(index));
        case Qnil:
                return Qnil;
        default:
                return rb_utf_substr_and_infect(str, begin, len, index);
        }
}

static VALUE
rb_utf_aref(VALUE str, VALUE index)
{
        switch (TYPE(index)) {
        case T_FIXNUM:
                return rb_utf_aref_num(str, FIX2LONG(index));
        case T_REGEXP:
                return rb_str_subpat(str, index, 0);
        case T_STRING:
                if (rb_utf_index(str, index, 0) != -1)
                        return rb_utf_dup(index);
                return Qnil;
        default:
                return rb_utf_aref_default(str, index);
        }
}

VALUE
rb_utf_aref_m(int argc, VALUE *argv, UNUSED(VALUE self))
{
        StringValue(argv[0]);

        if (argc > 3 || argc < 2)
                rb_raise(rb_eArgError,
                         "wrong number of arguments (%d for 2)", argc);

        if (argc == 2)
                return rb_utf_aref(argv[0], argv[1]);

        if (TYPE(argv[1]) == T_REGEXP)
                return rb_str_subpat(argv[0], argv[1], NUM2INT(argv[2]));

        return rb_utf_substr(argv[0], NUM2INT(argv[1]), NUM2INT(argv[2]));
}
