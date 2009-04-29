/*
 * contents: Private functions used by the UTF-8 character-encoding library.
 *
 * Copyright © 2007 Nikolai Weibull <now@bitwi.se>
 */

#include <ruby.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>

#include "unicode.h"

#include "private.h"

/* Lookup C in the sorted TABLE using binary search.  TABLE consists of N
 * entries, where each entry is SIZEOF_ENTRY bytes in size and the first
 * component is a unichar of size SIZEOF_CHAR.  If C is found in TABLE, its
 * index is stored in INDEX and true is returned.  Otherwise, false is returned
 * and INDEX is left untouched. */
bool
binary_search_unicode_table(const void *table, size_t n, size_t sizeof_entry, size_t sizeof_char, unichar c, int *index)
{
#define ENTRY(index) ((unichar)(*(unichar *)((const char *)table + ((index) * sizeof_entry))) & char_mask)

	int begin = 0;
        int end = n - 1;
        int middle;

        /* This is ugly, but not all tables use unichars as their lookup
         * character.  The casefold table, for example, uses uint16_t-sized
         * characters.  To only get the interesting part of our table entry
         * we’ll have to mask the retrieved value. */
        int char_mask = (1 << (8 * sizeof_char)) - 1;

        /* Drop out early if we know for certain that C can’t be in the
         * decomposition table. */
        if (c < ENTRY(0) || c > ENTRY(end))
                return false;

        while (begin <= end) {
                middle = binary_search_middle_of(begin, end);

                unichar probe = ENTRY(middle);
                if (c < probe)
                        end = middle - 1;
                else if (c > probe)
                        begin = middle + 1;
                else
                        break;
        }

        if (begin > end)
                return false;

        *index = middle;

        return true;

#undef ENTRY
}
