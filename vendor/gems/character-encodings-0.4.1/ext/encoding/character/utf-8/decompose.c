/*
 * contents: Unicode decomposition handling.
 *
 * Copyright (C) 2004 Nikolai Weibull <source@pcppopper.org>
 */

#include <ruby.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#include "unicode.h"

#include "data/decompose.h"
#include "data/compose.h"

#include "private.h"

#define COMBINING_CLASS(c)      \
        SPLIT_UNICODE_TABLE_LOOKUP(cclass_data, combining_class_table_part1, combining_class_table_part2, (c), 0)


/* {{{1
 * Hangul syllable [de]composition constants. A lot of work I'd say.
 */
enum {
        SBase = 0xac00,
        LBase = 0x1100,
        VBase = 0x1161,
        TBase = 0x11a7,
        LCount = 19,
        VCount = 21,
        TCount = 28,
        NCount = (VCount * TCount),
        SCount = (LCount * NCount),
        SLast  = (SBase + SCount - 1)
};


/* {{{1
 * Return the combinging class of ‘c’.
 */
int
unichar_combining_class(unichar c)
{
        return COMBINING_CLASS(c);
}


/* {{{1
 * Rearrange ‘str’ so that decomposed characters are arranged according to
 * their combining class.  Do this for at most ‘len’ bytes of data.
 */
static void
unicode_canonical_ordering_swap(unichar *str, size_t offset, int next, bool *swapped)
{
        size_t initial = offset + 1;

        size_t j = initial;
        while (j > 0 && COMBINING_CLASS(str[j - 1]) > next) {
                unichar c = str[j];
                str[j] = str[j - 1];
                str[j - 1] = c;
                j--;
        }

        *swapped = *swapped || (j != initial);
}

static bool
unicode_canonical_ordering_reorder(unichar *str, size_t len)
{
        bool swapped = false;

        int prev = COMBINING_CLASS(str[0]);
        for (size_t i = 0; i < len - 1; i++) {
                int next = COMBINING_CLASS(str[i + 1]);

                if (next != 0 && prev > next)
                        unicode_canonical_ordering_swap(str, i, next, &swapped);
                else
                        prev = next;
        }

        return swapped;
}

void
unicode_canonical_ordering(unichar *str, size_t len)
{
        while (unicode_canonical_ordering_reorder(str, len))
                ; /* This loop intentionally left empty. */
}


/* {{{1
 * Decompose the character ‘s’ according to the rules outlined in
 * http://www.unicode.org/unicode/reports/tr15/#Hangul.  ‘r’ should be ‹NULL›
 * or of sufficient length to store the decomposition of ‘s’.  Returns the
 * number of characters stored (or would be if it were non-NULL) in R.
 */
static size_t
decompose_hangul(unichar s, unichar *r)
{
        int SIndex = s - SBase;

        /* If this isn’t a Hangul symbol, then simply return it unchanged. */
        if (SIndex < 0 || SIndex >= SCount) {
                if (r != NULL)
                        r[0] = s;
                return 1;
        }

        unichar L = LBase + SIndex / NCount;
        unichar V = VBase + (SIndex % NCount) / TCount;
        unichar T = TBase + SIndex % TCount;

        if (r != NULL) {
                r[0] = L;
                r[1] = V;
        }

        if (T == TBase)
                return 2;

        if (r != NULL)
                r[2] = T;

        return 3;
}


/* {{{1
 * Search the Unicode decomposition table for ‘c’ and depending on the boolean
 * value of ‘compat’, return its compatibility or canonical decomposition if
 * found.
 */
static const char *
get_decomposition(int index, bool compat)
{
        int offset;

        if (compat) {
                offset = decomp_table[index].compat_offset;
                if (offset == UNICODE_NOT_PRESENT_OFFSET)
                        offset = decomp_table[index].canon_offset;
                /* Either .compat_offset or .canon_offset can be missing, but
                 * not both. */
        } else {
                offset = decomp_table[index].canon_offset;
                if (offset == UNICODE_NOT_PRESENT_OFFSET)
                        return NULL;
        }

        return &decomp_expansion_string[offset];
}

static const char *
find_decomposition(unichar c, bool compat)
{
        int index;

        if (!unicode_table_lookup(decomp_table, c, &index))
                return NULL;

        return get_decomposition(index, compat);
}


/* {{{1
 * Copy over the UTF-8 decomposition in ‘decomposition’ to the unichar buffer
 * ‘chars’.  Return the number of unichars in ‘chars’.
 */
static size_t
decomposition_to_wc(const char *decomposition, unichar *chars)
{
        size_t i = 0;
        for (const char *p = decomposition; *p != '\0'; p = utf_next(p))
                chars[i++] = utf_char(p);

        return i;
}


/* {{{1
 * Generate the canonical decomposition of ‘c’.  The length of the
 * decomposition is stored in ‘len’.
 */
/* TODO: clean this up. */
unichar *
unicode_canonical_decomposition(unichar c, size_t *len)
{
        const char *decomp;
        unichar *r;

        /* Hangul syllable */
        if (c >= SBase && c <= SLast) {
                *len = decompose_hangul(c, NULL);
                r = ALLOC_N(unichar, *len);
                decompose_hangul(c, r);
        } else if ((decomp = find_decomposition(c, false)) != NULL) {
                *len = utf_length(decomp);
                r = ALLOC_N(unichar, *len);
                decomposition_to_wc(decomp, r);
        } else {
                r = ALLOC(unichar);
                *r = c;
                *len = 1;
        }

        /* Supposedly following the Unicode 2.1.9 table means that the
         * decompositions come out in canonical order.  I haven't tested this,
         * but we rely on it here. */
        return r;
}


/* {{{1
 * Combine Hangul characters ‘a’ and ‘b’ if possible, and store the result in
 * ‘result’.  The combinations tried are L,V => LV and LV,T => LVT in that
 * order.
 */
static bool
combine_hangul(unichar a, unichar b, unichar *result)
{
        int LIndex = a - LBase;
        int VIndex = b - VBase;

        if (0 <= LIndex && LIndex < LCount && 0 <= VIndex && VIndex < VCount) {
                *result = SBase + (LIndex * VCount + VIndex) * TCount;
                return true;
        }
        
        int SIndex = a - SBase;
        int TIndex = b - TBase;

        if (0 <= SIndex && SIndex < SCount &&
            (SIndex % TCount) == 0 &&
            0 < TIndex && TIndex < TCount) {
                *result = a + TIndex;
                return true;
        }

        return false;
}


/* {{{1
 * Try to combine the Unicode characters ‘a’ and ‘b’ storing the result in
 * ‘result’.
 */
static uint16_t
compose_index(unichar c)
{
        unsigned int page = c >> 8;

        if (page > COMPOSE_TABLE_LAST)
                return 0;

        return SPLIT_UNICODE_TABLE_LOOKUP_PAGE(compose_data, compose_table, page, c);
}

static bool
lookup_compose(const uint16_t table[][2], uint16_t index, unichar c,
               unichar *result)
{
        if (c != table[index][0])
                return false;

        *result = table[index][1];

        return true;
}

static bool
combine(unichar a, unichar b, unichar *result)
{
        if (combine_hangul(a, b, result))
                return true;

        uint16_t index_a = compose_index(a);
        if (index_a >= COMPOSE_FIRST_SINGLE_START && index_a < COMPOSE_SECOND_START)
                return lookup_compose(compose_first_single,
                                      index_a - COMPOSE_FIRST_SINGLE_START,
                                      b,
                                      result);

        uint16_t index_b = compose_index(b);
        if (index_b >= COMPOSE_SECOND_SINGLE_START)
                return lookup_compose(compose_second_single,
                                      index_b - COMPOSE_SECOND_SINGLE_START,
                                      a,
                                      result);

        if (index_a >= COMPOSE_FIRST_START &&
            index_a < COMPOSE_FIRST_SINGLE_START &&
            index_b >= COMPOSE_SECOND_START &&
            index_b < COMPOSE_SECOND_SINGLE_START) {
                unichar r = compose_array[index_a - COMPOSE_FIRST_START][index_b - COMPOSE_SECOND_START];

                if (r != 0) {
                        *result = r;
                        return true;
                }
        }

        return false;
}


/* {{{1
 * Normalize (compose/decompose) characters in ‘str’ so that strings that
 * actually contain the same characters will be recognized as equal for
 * comparison for example.
 */
static size_t
normalize_wc_decompose_one(unichar c, NormalizeMode mode, unichar *buf)
{
        bool do_compat = (mode == NORMALIZE_NFKC || mode == NORMALIZE_NFKD);
        const char *decomp = find_decomposition(c, do_compat);

        if (decomp == NULL) {
                if (buf != NULL)
                        buf[0] = c;
                return 1;
        }

        if (buf != NULL)
                return decomposition_to_wc(decomp, buf);

        return utf_length(decomp);
}

static void
normalize_wc_decompose(const char *str, size_t max_len, bool use_len,
                       NormalizeMode mode, unichar *buf, size_t *buf_len)
{
        size_t n = 0;
        size_t prev_start = 0;
        const char *end = str + max_len;
        for (const char *p = str; (!use_len || p < end) && *p != NUL; p = utf_next(p)) {
                unichar c = utf_char(p);
                size_t prev_n = n;

                unichar *base = (buf != NULL) ? buf + n : NULL;
                if (c >= SBase && c <= SLast)
                        n += decompose_hangul(c, base);
                else
                        n += normalize_wc_decompose_one(c, mode, base);

                if (buf != NULL && n > 0 && COMBINING_CLASS(buf[prev_n]) == 0) {
                        unicode_canonical_ordering(buf + prev_start,
                                                   n - prev_start);
                        prev_start = prev_n;
                }
        }

        if (buf != NULL && n > 0)
                unicode_canonical_ordering(buf + prev_start, n - prev_start);

        if (buf != NULL)
                buf[n] = NUL;

        *buf_len = n;
}

static unichar *
normalize_wc_compose(unichar *buf, size_t len)
{
        int new_len = len;
        size_t prev_start = 0;
        int prev_cc = 0;

        for (size_t i = 0; i < len; i++) {
                int cc = COMBINING_CLASS(buf[i]);
                size_t j = i - (len - new_len);

                if (j > 0 && (prev_cc == 0 || prev_cc < cc) &&
                    combine(buf[prev_start], buf[i], &buf[prev_start])) {
                        new_len--;
                        prev_cc = (j + 1 == prev_start) ?
                                  0 : COMBINING_CLASS(buf[j - 1]);
                } else {
                        if (cc == 0)
                                prev_start = j;

                        buf[j] = buf[i];
                        prev_cc = cc;
                }
        }

        buf[new_len] = NUL;

        return buf;
}

unichar *
_utf_normalize_wc(const char *str, size_t max_len, bool use_len, NormalizeMode mode)
{
        size_t n;
        normalize_wc_decompose(str, max_len, use_len, mode, NULL, &n);
        unichar *buf = ALLOC_N(unichar, n + 1);
        normalize_wc_decompose(str, max_len, use_len, mode, buf, &n);

        /* Just return if we don’t want composition. */
        if (!(mode == NORMALIZE_NFC || mode == NORMALIZE_NFKC))
                return buf;

        return normalize_wc_compose(buf, n);
}


/* {{{1
 * Normalize (compose/decompose) characters in ‘str˚ so that strings that
 * actually contain the same characters will be recognized as equal for
 * comparison for example.
 */
char *
utf_normalize(const char *str, NormalizeMode mode)
{
        unichar *wcs = _utf_normalize_wc(str, 0, false, mode);
        char *utf = ucs4_to_utf8(wcs, NULL, NULL);

        free(wcs);
        return utf;
}


/* {{{1
 * This function is the same as utf_normalize() except that at most ‘len˚
 * bytes are normalized from ‘str’.
 */
char *
utf_normalize_n(const char *str, NormalizeMode mode, size_t len)
{
        unichar *wcs = _utf_normalize_wc(str, len, true, mode);
        char *utf = ucs4_to_utf8(wcs, NULL, NULL);

        free(wcs);
        return utf;
}


/* }}}1 */
