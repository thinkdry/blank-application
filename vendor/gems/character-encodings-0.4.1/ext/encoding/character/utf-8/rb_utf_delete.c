/*
 * contents: UTF8.delete module functions.
 *
 * Copyright © 2006 Nikolai Weibull <now@bitwi.se>
 */

#include "rb_includes.h"
#include "rb_utf_internal_tr.h"

VALUE
rb_utf_delete_bang(int argc, VALUE *argv, UNUSED(VALUE self))
{
        need_at_least_n_arguments(argc, 2);

        VALUE str = argv[0];
        StringValue(str);
        if (RSTRING(str)->len == 0)
                return Qnil;

        unsigned int table[TR_TABLE_SIZE];
        tr_setup_table_from_strings(table, argc - 1, &argv[1]);

        rb_str_modify(str);

        bool modified = false;
        char *s = RSTRING(str)->ptr;
        char const *s_end = s + RSTRING(str)->len;
        char *t = s;
        while (s < s_end) {
                unichar c = utf_char(s);

                char *next = rb_utf_next_validated(s, s_end);
                if (tr_table_lookup(table, c)) {
                        modified = true;
                } else {
                        memmove(t, s, next - s);
                        t += next - s;
                }

                s = next;
        }
        *t = '\0';
        RSTRING(str)->len = t - RSTRING(str)->ptr;

        if (modified)
                return str;

        return Qnil;
}

VALUE
rb_utf_delete(int argc, VALUE *argv, VALUE self)
{
        need_at_least_n_arguments(argc, 2);

        StringValue(argv[0]);
        argv[0] = rb_utf_dup(argv[0]);
        rb_utf_delete_bang(argc, argv, self);
        return argv[0];
}
