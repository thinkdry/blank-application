/*
 * contents: Translation (#tr) related functions
 *
 * Copyright © 2006 Nikolai Weibull <now@bitwi.se>
 */

#ifndef TR_H
#define TR_H

#ifndef WORD_BIT
#  define WORD_BIT              (sizeof(int) * CHAR_BIT)
#endif

#define TR_TABLE_SIZE           ((int)(UNICODE_N_CODEPOINTS / WORD_BIT))

#define tr_table_lookup(table, offset)       \
        ((table)[(offset) / WORD_BIT] & (1U << (offset) % WORD_BIT))

struct tr {
        bool inside_range;
        unichar now;
        unichar max;
        char *p;
        char *p_end;
};

enum tr_state
{
        TR_FOUND,
        TR_READ_ANOTHER,
        TR_FINISHED
};

void tr_init(struct tr *tr, char *p, char *p_end) HIDDEN;
bool tr_should_exclude(struct tr *tr) HIDDEN;
enum tr_state tr_next(struct tr *t) HIDDEN;
void tr_setup_table(VALUE str, unsigned int *table, bool initialize) HIDDEN;
void tr_setup_table_from_strings(unsigned int *table, int argc,
                                 VALUE *argv) HIDDEN;

#endif /* TR_H */
