/*
 * contents: UTF8.tr module function.
 *
 * Copyright © 2006 Nikolai Weibull <now@bitwi.se>
 */

#include "rb_includes.h"
#include "rb_utf_internal_tr.h"

struct tr_range
{
        unichar begin;
        unichar end;
};

static int
tr_ranges_setup(struct tr *tr, struct tr_range *ranges)
{
        int n = 0;
        bool was_inside_range = false;
        while (tr_next(tr) != TR_FINISHED) {
                if (tr->inside_range) {
                        if (!was_inside_range) {
                                ranges[n].begin = tr->now;
                                was_inside_range = true;
                        }
                } else {
                        if (was_inside_range)
                                ranges[n].end = tr->now;
                        else
                                ranges[n].begin = ranges[n].end = tr->now;
                        n++;
                        was_inside_range = false;
                }
        }

        return n;
}


struct tr_trans_closure
{
        struct tr_range *from;
        int n_from;
        struct tr_range *to;
        int n_to;
};

static unichar
tr_trans_replace_exclude(UNUSED(unichar c), void *closure)
{
        return *((unichar *)closure);
}

static int
tr_trans_replace_include_offset_of(struct tr_range *ranges, int range)
{
        int offset = 0;

        for (int i = 0; i < range; i++)
                offset += ranges[i].end - ranges[i].begin + 1;

        return offset;
}

static unichar
tr_trans_replace_include(unichar c, void *v_closure)
{
        struct tr_trans_closure *closure = (struct tr_trans_closure *)v_closure;

        for (int i = closure->n_from - 1; i >= 0; i--) {
                if (closure->from[i].begin >= c && closure->from[i].end <= c) {
                        int offset = tr_trans_replace_include_offset_of(closure->from, i);
                        int j;
                        for (j = 0; j < closure->n_to && offset > 0; j++)
                                offset -= closure->to[j].end - closure->to[j].begin + 1;

                        if (offset > 0)
                                return closure->to[closure->n_to - 1].end;

                        return closure->to[j].end - offset;
                }
        }

        return closure->to[closure->n_to - 1].end;
}

static VALUE
tr_trans_do(VALUE src, unsigned int *translation,
            unichar (*replace)(unichar, void *), void *closure, bool squeeze,
            UNUSED(bool replace_content))
{
        VALUE dst = Qnil;
        long len;

again:
        len = 0;

        const char *s = RSTRING(src)->ptr;
        const char *s_end = s + RSTRING(src)->len;

        char *t = NULL;
        
        if (dst != Qnil)
                t = RSTRING(dst)->ptr;

        bool modified = false;

        /* TODO: this should really be refactored… */
        if (squeeze) {
                unichar prev_c = -1;

                while (s < s_end) {
                        unichar c0 = utf_char(s);

                        const char *prev = s;
                        s = utf_next(s);

                        if (tr_table_lookup(translation, c0)) {
                                unichar c = replace(c0, closure);
                                if (prev_c == c)
                                        continue;
                                prev_c = c;
                                len += unichar_to_utf(c, (t != NULL) ? t + len : NULL);
                                modified = true;
                        } else {
                                prev_c = -1;
                                if (t != NULL)
                                        memcpy(t + len, prev, s - prev);
                                len += s - prev;
                        }

                }

                if (RSTRING(src)->len > (t + len - RSTRING(src)->ptr))
                        modified = true;
        } else {
                while (s < s_end) {
                        unichar c = utf_char(s);

                        const char *prev = s;
                        s = utf_next(s);

                        if (tr_table_lookup(translation, c)) {
                                len += unichar_to_utf(replace(c, closure),
                                                      (t != NULL) ? t + len : NULL);
                                modified = true;
                        } else {
                                if (t != NULL)
                                        memcpy(t + len, prev, s - prev);
                                len += s - prev;
                        }
                }
        }

#ifdef RB_STR_REPLACE_IS_EXTERN
        if (replace_content && !modified)
                return Qnil;
#endif

        if (dst == Qnil) {
#ifdef RB_STR_REPLACE_IS_EXTERN
                if (replace_content && len <= RSTRING(src)->len)
                        dst = src;
                else
#endif
                        dst = rb_str_buf_new(len);
                goto again;
        }

        t[len] = '\0';
        RSTRING(dst)->len = len;

#ifdef RB_STR_REPLACE_IS_EXTERN
        if (dst != src && replace_content) {
                rb_str_replace(src, dst);
                return src;
        }
#endif

        return dst;
}

static VALUE
tr_trans(VALUE str, VALUE from, VALUE to, bool squeeze, bool replace_content)
{
        StringValue(str);
        StringValue(from);
        StringValue(to);

        if (RSTRING(str)->ptr == NULL || RSTRING(str)->len == 0)
                return replace_content ? Qnil : str;

        if (RSTRING(to)->len == 0)
                return rb_utf_delete_bang(1, &from, str);

        struct tr tr_from;
        tr_init(&tr_from,
                RSTRING(from)->ptr,
                RSTRING(from)->ptr + RSTRING(from)->len);

        struct tr tr_to;
        tr_init(&tr_to,
                RSTRING(to)->ptr,
                RSTRING(to)->ptr + RSTRING(to)->len);

        unsigned int translation[TR_TABLE_SIZE];
        tr_setup_table(from, translation, true);

        tr_init(&tr_from,
                RSTRING(from)->ptr,
                RSTRING(from)->ptr + RSTRING(from)->len);
        if (tr_should_exclude(&tr_from)) {
                /* This case is easy.  Just include everything by default and
                 * exclude the rest as always.  Replace characters found by the
                 * last character found in tr_to. */
                while (tr_next(&tr_to) != TR_FINISHED)
                       ; /* We just need the last replacement character. */
                return tr_trans_do(str, translation, tr_trans_replace_exclude,
                                   &tr_to.now, squeeze, replace_content);
        } else {
                /* This case is hard.  We need a full-fledged lookup of what
                 * character to translate to, not simply a check whether to
                 * include it or not. */
                struct tr_trans_closure trans_closure;

                struct tr_range from_ranges[utf_length_n(RSTRING(from)->ptr, RSTRING(from)->len)];
                trans_closure.from = from_ranges;
                trans_closure.n_from = tr_ranges_setup(&tr_from, from_ranges);

                struct tr_range to_ranges[utf_length_n(RSTRING(to)->ptr, RSTRING(to)->len)];
                trans_closure.to = to_ranges;
                trans_closure.n_to = tr_ranges_setup(&tr_to, to_ranges);

                return tr_trans_do(str, translation, tr_trans_replace_include,
                                   &trans_closure, squeeze, replace_content);
        }
}

VALUE
rb_utf_tr(UNUSED(VALUE self), VALUE str, VALUE from, VALUE to)
{
        return tr_trans(str, from, to, false, false);
}

VALUE
rb_utf_tr_s(UNUSED(VALUE self), VALUE str, VALUE from, VALUE to)
{
        return tr_trans(str, from, to, true, false);
}
