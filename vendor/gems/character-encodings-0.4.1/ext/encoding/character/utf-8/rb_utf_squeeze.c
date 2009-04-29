/*
 * contents: UTF8.squeeze module function.
 *
 * Copyright © 2006 Nikolai Weibull <now@bitwi.se>
 */

#include "rb_includes.h"
#include "rb_utf_internal_tr.h"

VALUE
rb_utf_squeeze_bang(int argc, VALUE *argv, UNUSED(VALUE self))
{
        need_at_least_n_arguments(argc, 1);

        VALUE str = argv[0];
        StringValue(str);
        if (RSTRING(str)->len == 0)
                return Qnil;

        unsigned int table[TR_TABLE_SIZE];
        if (argc == 1)
                for (int i = 0; i < TR_TABLE_SIZE; i++)
                        table[i] = ~0U;
        else
                tr_setup_table_from_strings(table, argc - 1, &argv[1]);

        rb_str_modify(str);

        char *begin = RSTRING(str)->ptr;
        char const *end = begin + RSTRING(str)->len;

        /* We know that there is a character to eat (if the input isn’t
         * invalid), as we’ve already verified that RSTRING(str)->len > 0, so
         * ‘s_end’ must lay beyond ‘s’.  Also, as we validate when we fetch the
         * character, there’s no need to validate the call to utf_next(). */
        unichar previous = _utf_char_validated(begin, end);
        char *s = utf_next(begin);
        char *t = s;
        while (s < end) {
                unichar c = _utf_char_validated(s, end);
                char *next = utf_next(s);

                if (c != previous || !tr_table_lookup(table, c)) {
                        memmove(t, s, next - s);
                        t += next - s;
                        previous = c;
                }

                s = next;
        }
        *t = '\0';

        if (t - begin != RSTRING(str)->len) {
                RSTRING(str)->len = t - begin;
                return str;
        }

        return Qnil;
}

VALUE
rb_utf_squeeze(int argc, VALUE *argv, VALUE self)
{
        need_at_least_n_arguments(argc, 1);

        StringValue(argv[0]);
        argv[0] = rb_utf_dup(argv[0]);
        rb_utf_squeeze_bang(argc, argv, self);
        return argv[0];
}
