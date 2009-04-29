/*
 * contents: Translation (#tr) related functions.
 *
 * Copyright © 2006 Nikolai Weibull <now@bitwi.se>
 */

#include "rb_includes.h"
#include "rb_utf_internal_tr.h"

void
tr_init(struct tr *tr, char *p, char *p_end)
{
        tr->p = p;
        tr->p_end = p_end;
        tr->inside_range = false;
}

bool
tr_should_exclude(struct tr *tr)
{
        if (tr->p + 1 < tr->p_end && *tr->p == '^') {
                tr->p++;
                return true;
        }

        return false;
}

static enum tr_state
tr_next_char(struct tr *t)
{
        if (t->p == t->p_end)
                return TR_FINISHED;

        if (_utf_char_validated(t->p, t->p_end) == '\\') {
                char *next = utf_find_next(t->p, t->p_end);

                if (next == NULL) {
                        t->now = '\\';
                        t->p = t->p_end;
                        return TR_FOUND;
                }

                t->p = next;
        }

        t->now = _utf_char_validated(t->p, t->p_end);

        char *next = utf_find_next(t->p, t->p_end);
        if (next == NULL) {
                t->p = t->p_end;
                return TR_FOUND;
        }
        t->p = next;

        if (_utf_char_validated(t->p, t->p_end) == '-') {
                next = utf_find_next(t->p, t->p_end);

                if (next != NULL) {
                        unichar max = utf_char(next);

                        if (max < t->now) {
                                t->p = next;
                                return TR_READ_ANOTHER;
                        }

                        t->inside_range = true;
                        t->max = max;
                }
        }

        return TR_FOUND;
}

enum tr_state
tr_next(struct tr *t)
{
        while (true) {
                if (!t->inside_range) {
                        enum tr_state state;

                        if ((state = tr_next_char(t)) == TR_READ_ANOTHER)
                                continue;

                        return state;
                } else if (++t->now < t->max) {
                        return TR_FOUND;
                } else {
                        t->inside_range = false;
                        return TR_FOUND;
                }
        }
}

static void
tr_table_set(unsigned int *table, unichar c, unsigned int value)
{
        unsigned int offset = c / WORD_BIT;
        unsigned int bit = c % WORD_BIT;

        table[offset] = (table[offset] & ~(1U << bit)) | ((value & 1U) << bit);
}

void
tr_setup_table(VALUE str, unsigned int *table, bool initialize)
{
        unsigned int buf[TR_TABLE_SIZE];

        struct tr tr;
        tr_init(&tr, RSTRING(str)->ptr, RSTRING(str)->ptr + RSTRING(str)->len);

        bool exclude = tr_should_exclude(&tr);

        if (initialize)
                for (int i = 0; i < TR_TABLE_SIZE; i++)
                        table[i] = ~0U;

        unsigned int buf_initializer = exclude ? ~0U : 0U;
        for (int i = 0; i < TR_TABLE_SIZE; i++)
                buf[i] = buf_initializer;

        unsigned int buf_setter = !exclude;
        while (tr_next(&tr) != TR_FINISHED)
                tr_table_set(buf, tr.now, buf_setter);

        for (int i = 0; i < TR_TABLE_SIZE; i++)
                table[i] &= buf[i];
}

void
tr_setup_table_from_strings(unsigned int *table, int argc, VALUE *argv)
{
    bool initialize = true;
    for (int i = 0; i < argc; i++) {
            VALUE s = argv[i];

            StringValue(s);
            tr_setup_table(s, table, initialize);
            initialize = false;
    }
}

