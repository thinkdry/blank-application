/*
 * contents: Private Unicode related information.
 *
 * Copyright (C) 2004 Nikolai Weibull <source@pcppopper.org>
 */

#ifndef PRIVATE_H
#define PRIVATE_H

#define NUL '\0'
#define lengthof(ary)   (sizeof(ary) / sizeof((ary)[0]))

#if defined(__GNUC__)
#  define UNUSED(u)   \
        u __attribute__((__unused__))
#  define HIDDEN   \
        __attribute__((visibility("hidden")))
#else
#  define UNUSED(u)   \
        u
#  define HIDDEN
#endif

#define binary_search_middle_of(begin, end)     \
        (((unsigned)((begin) + (end))) >> 1)

#define unicode_table_lookup(table, c, index)    \
        binary_search_unicode_table(table, lengthof(table), sizeof((table)[0]), sizeof((table)[0].ch), c, index)

bool binary_search_unicode_table(const void *table, size_t n, size_t sizeof_entry, size_t sizeof_char, unichar c, int *index) HIDDEN;

#define SPLIT_UNICODE_TABLE_LOOKUP_PAGE(data, part, page, c)  \
        ((part[page] >= UNICODE_MAX_TABLE_INDEX) \
         ? (part[page] - UNICODE_MAX_TABLE_INDEX) \
         : (data[part[page]][(c) & 0xff]))

#define SPLIT_UNICODE_TABLE_LOOKUP(data, part1, part2, c, fallback)    \
        (((c) <= UNICODE_LAST_CHAR_PART1) \
         ? SPLIT_UNICODE_TABLE_LOOKUP_PAGE(data, part1, (c) >> 8, c) \
         : (((c) >= UNICODE_FIRST_CHAR_PART2 && (c) <= UNICODE_LAST_CHAR) \
            ? SPLIT_UNICODE_TABLE_LOOKUP_PAGE(data, part2, ((c) - UNICODE_FIRST_CHAR_PART2) >> 8, c) \
            : (fallback)))

unichar *_utf_normalize_wc(const char *str, size_t max_len, bool use_len,
                           NormalizeMode mode) HIDDEN;

#endif /* PRIVATE_H */
