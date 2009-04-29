/*
 * contents: Functions for dealing with Unicode tables.
 *
 * Copyright © 2007 Nikolai Weibull <now@bitwi.se>
 */

#ifndef TABLES_H
#define TABLES_H


/*
static inline int
split_unicode_table_lookup_page(const uint8_t data[][256], int16_t page, unichar c)
{
        return (page >= UNICODE_MAX_TABLE_INDEX) ?
                page - UNICODE_MAX_TABLE_INDEX :
                data[page][c & 0xff];
}

static inline int
split_unicode_table_lookup(const uint8_t data[][256], const int16_t part1[], const int16_t part2[], unichar c, int fallback)
{
	if (c <= UNICODE_LAST_CHAR_PART1)
                return split_unicode_table_lookup_page(data,
                                                       part1[c >> 8],
                                                       c);

        if (c >= UNICODE_FIRST_CHAR_PART2 && c <= UNICODE_LAST_CHAR)
                return split_unicode_table_lookup_page(data,
                                                       part2[(c - UNICODE_FIRST_CHAR_PART2) >> 8],
                                                       c);

        return fallback;
}
*/


#endif /* TABLES_H */
