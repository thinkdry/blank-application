/*
 * contents: Unicode character properties.
 *
 * Copyright (C) 2004 Nikolai Weibull <source@pcppopper.org>
 */

#include <ruby.h>
#include <assert.h>
#include <locale.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <string.h>
#include "unicode.h"
#include "private.h"
#include "data/character-tables.h"


#define COMBINING_DOT_ABOVE                     ((unichar)0x0307)
#define LATIN_CAPITAL_LETTER_I_WITH_DOT_ABOVE   ((unichar)0x0130)
#define COMBINING_GREEK_YPOGEGRAMMENI           ((unichar)0x0345)
#define GREEK_CAPITAL_LETTER_IOTA               ((unichar)0x0399)
#define LATIN_SMALL_LETTER_I                    ((unichar)0x0069)
#define LATIN_SMALL_LETTER_DOTLESS_I            ((unichar)0x0131)
#define LATIN_CAPITAL_LETTER_I_WITH_GRAVE       ((unichar)0x00cc)
#define LATIN_CAPITAL_LETTER_I_WITH_ACUTE       ((unichar)0x00cd)
#define LATIN_CAPITAL_LETTER_I_WITH_TILDE       ((unichar)0x0128)
#define LATIN_CAPITAL_LETTER_I_WITH_OGONEK      ((unichar)0x012e)
#define COMBINING_GRAVE_ACCENT                  ((unichar)0x0300)
#define COMBINING_ACUTE_ACCENT                  ((unichar)0x0301)
#define COMBINING_TILDE                         ((unichar)0x0303)
#define GREEK_CAPITAL_LETTER_SIGMA              ((unichar)0x03a3)
#define GREEK_SMALL_LETTER_SIGMA                ((unichar)0x03c3)
#define GREEK_SMALL_LETTER_FINAL_SIGMA          ((unichar)0x03c2)

#define OFFSET_IF(buf, len)    (((buf) != NULL) ? (buf) + (len) : NULL)

/* {{{1
 * Macros for accessing the Unicode character attribute table.
 *
 * TODO: Turn these macros into full-fledged functions, as this is rather silly
 * when we have ‹inline› in C99.
 */
#define ATTR_TABLE(page) \
	(((page) <= UNICODE_LAST_PAGE_PART1) \
	 ? attr_table_part1[page] \
	 : attr_table_part2[(page) - 0xe00])

#define ATTTABLE(page, char) \
	((ATTR_TABLE(page) == UNICODE_MAX_TABLE_INDEX) \
	 ? 0 : (attr_data[ATTR_TABLE(page)][char]))


/* {{{1
 * Internal function used for figuring out the type of a given character.
 */
static inline int
s_type(unichar c)
{
	const int16_t *table;
	unsigned int page;

	if (c <= UNICODE_LAST_CHAR_PART1) {
		page = c >> 8;
		table = type_table_part1;
	} else if (c >= UNICODE_FIRST_CHAR_PART2 && c <= UNICODE_LAST_CHAR) {
		page = (c - UNICODE_FIRST_CHAR_PART2) >> 8;
		table = type_table_part2;
	} else {
		return UNICODE_UNASSIGNED;
	}

	if (table[page] >= UNICODE_MAX_TABLE_INDEX)
		return table[page] - UNICODE_MAX_TABLE_INDEX;
	else
		return type_data[table[page]][c & 0xff];
}


/* {{{1
 * Bit-fiddling macros for testing the class of a type.
 */
#define IS(type, class) (((unsigned int)1 << (type)) & (class))
#define OR(type, rest)  (((unsigned int)1 << (type)) | (rest))


/* {{{1
 * Internal function used to check if the given type represents a digit type.
 */
static inline bool
s_isdigit(int type)
{
        return IS(type,
                  OR(UNICODE_DECIMAL_NUMBER,
                     OR(UNICODE_LETTER_NUMBER,
                        OR(UNICODE_OTHER_NUMBER, 0))));
}


/* {{{1
 * Internal function used to check if the given type represents an alphabetic
 * type.
 */
static inline bool
s_isalpha(int type)
{
        return IS(type,
                  OR(UNICODE_LOWERCASE_LETTER,
                     OR(UNICODE_UPPERCASE_LETTER,
                        OR(UNICODE_TITLECASE_LETTER,
                           OR(UNICODE_MODIFIER_LETTER,
                              OR(UNICODE_OTHER_LETTER, 0))))));
}


/* {{{1
 * Internal function used to check if the given type represents a mark type.
 */
static inline bool
s_ismark(int type)
{
        return IS(type,
                  OR(UNICODE_NON_SPACING_MARK,
                     OR(UNICODE_COMBINING_MARK,
                        OR(UNICODE_ENCLOSING_MARK, 0))));
}


/* {{{1
 * Determine whether ‘c’ is an alphanumeric, such as A, B, C, 0, 1, or 2.
 */
bool
unichar_isalnum(unichar c)
{
	int type = s_type(c);

	return s_isdigit(type) || s_isalpha(type);
}


/* {{{1
 * Determine whether ‘c’ is an alphabetic (i.e. a letter), such as A, B, or C.
 */
bool
unichar_isalpha(unichar c)
{
	return s_isalpha(s_type(c));
}


/* {{{1
 * Determine whether ‘c’ is a control character, such as ‹NUL›.
 */
bool
unichar_iscntrl(unichar c)
{
	return s_type(c) == UNICODE_CONTROL;
}


/* {{{1
 * Determine whether ‘c’ is a digit, such as 0, 1, or 2.
 */
bool
unichar_isdigit(unichar c)
{
	return s_type(c) == UNICODE_DECIMAL_NUMBER;
}


/* {{{1
 * Determine whether ‘c’ is printable and not a space or control character such
 * as tab or <NUL›, such as A, B, or C.
 */
bool
unichar_isgraph(unichar c)
{
        return !IS(s_type(c),
                   OR(UNICODE_CONTROL,
                      OR(UNICODE_FORMAT,
                         OR(UNICODE_UNASSIGNED,
                            OR(UNICODE_PRIVATE_USE,
                               OR(UNICODE_SURROGATE,
                                  OR(UNICODE_SPACE_SEPARATOR, 0)))))));
}


/* {{{1
 * Determine whether ‘c’ is a lowercase letter, such as a, b, or c.
 */
bool
unichar_islower(unichar c)
{
	return s_type(c) == UNICODE_LOWERCASE_LETTER;
}


/* {{{1
 * Determine whether ‘c’ is printable, which works the same as
 * unichar_isgraph(), except that space characters are also printable.
 */
bool
unichar_isprint(unichar c)
{
        return !IS(s_type(c),
                   OR(UNICODE_CONTROL,
                      OR(UNICODE_FORMAT,
                         OR(UNICODE_UNASSIGNED,
                            OR(UNICODE_PRIVATE_USE,
                               OR(UNICODE_SURROGATE, 0))))));
}


/* {{{1
 * Determine whether ‘c’ is some form of punctuation or other symbol.
 */
bool
unichar_ispunct(unichar c)
{
        return IS(s_type(c),
                  OR(UNICODE_CONNECT_PUNCTUATION,
                     OR(UNICODE_DASH_PUNCTUATION,
                        OR(UNICODE_OPEN_PUNCTUATION,
                           OR(UNICODE_CLOSE_PUNCTUATION,
                              OR(UNICODE_INITIAL_PUNCTUATION,
                                 OR(UNICODE_FINAL_PUNCTUATION,
                                    OR(UNICODE_OTHER_PUNCTUATION,
                                       OR(UNICODE_MODIFIER_SYMBOL,
                                          OR(UNICODE_MATH_SYMBOL,
                                             OR(UNICODE_CURRENCY_SYMBOL,
                                                OR(UNICODE_OTHER_SYMBOL, 0)))))))))))) ? true : false;
}


/* {{{1
 * Determine whether ‘c’ is some form of whitespace, such as space, tab or a
 * line separator (newline, carriage return, etc.).
 */
bool
unichar_isspace(unichar c)
{
	switch (c) {
	case '\t':
	case '\n':
	case '\r':
	case '\f':
		return true;
	default:
                return IS(s_type(c),
                          OR(UNICODE_SPACE_SEPARATOR,
                             OR(UNICODE_LINE_SEPARATOR,
                                OR(UNICODE_PARAGRAPH_SEPARATOR, 0)))) ? true : false;
	}
}


/* {{{1
 * Determine whether ‘c’ is an uppeercase letter, such as A, B, or C
 */
bool
unichar_isupper(unichar c)
{
	return s_type(c) == UNICODE_UPPERCASE_LETTER;
}


/* {{{1
 * Determine whether ‘c’ is a titlecase letter, such as the slavic digraph Ǳ,
 * which at the beginning of a word is written as ǲ, where only the initial D
 * is capitalized.  (Complicated huh?)
 */
bool
unichar_istitle(unichar c)
{
	/* TODO: binary search helpful? */
	for (size_t i = 0; i < lengthof(title_table); i++)
		if (title_table[i][0] == c)
			return true;

	return false;
}


/* {{{1
 * Determine whether ‘c’ is a new-line.
 */
#define UNICHAR_NEXT_LINE               ((unichar)0x0085)
#define UNICHAR_LINE_SEPARATOR          ((unichar)0x2028)
#define UNICHAR_PARAGRAPH_SEPARATOR     ((unichar)0x2029)

bool
unichar_isnewline(unichar c)
{
        switch (c) {
        case '\n': case '\f': case '\r': case UNICHAR_NEXT_LINE:
        case UNICHAR_LINE_SEPARATOR: case UNICHAR_PARAGRAPH_SEPARATOR:
                return true;
        default:
                return false;
        }
}

/* {{{1
 * Determine whether ‘c’ is a hexadecimal digit, such as 0, 1, ..., 9, a, b,
 * ..., f, or A, B, ..., F.
 */
#define UNICHAR_FULLWIDTH_A     0xff21
#define UNICHAR_FULLWIDTH_F     0xff26
#define UNICHAR_FULLWIDTH_a     0xff41
#define UNICHAR_FULLWIDTH_f     0xff46
bool
unichar_isxdigit(unichar c)
{
	return ((c >= 'a' && c <= 'f') ||
		(c >= 'A' && c <= 'F') ||
                (c >= UNICHAR_FULLWIDTH_a && c <= UNICHAR_FULLWIDTH_f) ||
                (c >= UNICHAR_FULLWIDTH_A && c <= UNICHAR_FULLWIDTH_F) ||
                (s_type(c) == UNICODE_DECIMAL_NUMBER));
//		s_isdigit(s_type(c)));
}


/* {{{1
 * Determine whether code point ‘c’ has been assigned a code value.
 */
bool
unichar_isassigned(unichar c)
{
	return s_type(c) != UNICODE_UNASSIGNED;
}


/* {{{1
 * Determine whether ‘c’ is a wide character, thus is typically rendered in a
 * double-width cell on a terminal.
 */
bool
unichar_iswide(unichar c)
{
	if (c < 0x1100)
		return false;

        return (c <= 0x115f || 				/* Hangul Jamo init. consonants */
                c == 0x2329 || c == 0x232a || 		/* angle brackets */
                (c >= 0x2e80 && c <= 0xa4cf && 		/* CJK ... Yi */
                 (c < 0x302a || c > 0x302f) &&
                 c != 0x303f && c != 0x3099 && c != 0x309a) ||
                (c >= 0xac00 && c <= 0xd7a3) || 	/* Hangul syllables */
                (c >= 0xf900 && c <= 0xfaff) || 	/* CJK comp. graphs */
                (c >= 0xfe30 && c <= 0xfe6f) || 	/* CJK comp. forms */
                (c >= 0xff00 && c <= 0xff60) || 	/* fullwidth forms */
                (c >= 0xffe0 && c <= 0xffe6) || 	/*       -"-       */
                (c >= 0x20000 && c <= 0x2fffd) || 	/* CJK extra stuff */
                (c >= 0x30000 && c <= 0x3fffd));    	/*       -"-       */
}


/* {{{1
 * Convert ‘c’ to its uppercase representation (if any).
 */
static unichar
special_case_table_lookup(unichar c)
{
        unichar tv = ATTTABLE(c >> 8, c & 0xff);

        if (tv >= UNICODE_SPECIAL_CASE_TABLE_START)
                tv = utf_char(special_case_table +
                              tv - UNICODE_SPECIAL_CASE_TABLE_START);

        if (tv == '\0')
                return c;

        return tv;
}

static unichar
titlecase_table_lookup(unichar c, bool want_upper)
{
        for (size_t i = 0; i < lengthof(title_table); i++)
                if (title_table[i][0] == c)
                        return title_table[i][want_upper ? 1 : 2];

        return c;
}

unichar
unichar_toupper(unichar c)
{
	int type = s_type(c);

	if (type == UNICODE_LOWERCASE_LETTER)
                return special_case_table_lookup(c);
        
        if (type == UNICODE_TITLECASE_LETTER)
                return titlecase_table_lookup(c, true);

        return c;
}


/* {{{1
 * Convert ‘c’ to its lowercase representation (if any).
 */
unichar
unichar_tolower(unichar c)
{
	int type = s_type(c);

	if (type == UNICODE_UPPERCASE_LETTER)
                return special_case_table_lookup(c);
        
        if (type == UNICODE_TITLECASE_LETTER)
                return titlecase_table_lookup(c, false);

        return c;
}


/* {{{1
 * Convert ‘c’ to its titlecase representation (if any).
 */
unichar
unichar_totitle(unichar c)
{
	for (size_t i = 0; i < lengthof(title_table); i++)
		if (title_table[i][0] == c ||
                    title_table[i][1] == c ||
                    title_table[i][2] == c)
			return title_table[i][0];

        if (s_type(c) == UNICODE_LOWERCASE_LETTER)
                return unichar_toupper(c);

        return c;
}


/* {{{1
 * Return the numeric value of ‘c’ if it's a decimal digit, or -1 if not.
 */
int
unichar_digit_value(unichar c)
{
	if (s_type(c) == UNICODE_DECIMAL_NUMBER)
		return ATTTABLE(c >> 8, c & 0xff);

        return -1;
}


/* {{{1
 * Return the numeric value of ‘c’ if it's a hexadecimal digit, or -1 if not.
 */
int
unichar_xdigit_value(unichar c)
{
	if (c >= 'a' && c <= 'f')
		return c - 'a' + 10;
	else if (c >= 'A' && c <= 'F')
		return c - 'A' + 10;
        else if (c >= UNICHAR_FULLWIDTH_a && c <= UNICHAR_FULLWIDTH_f)
                return c - UNICHAR_FULLWIDTH_a + 10;
        else if (c >= UNICHAR_FULLWIDTH_A && c <= UNICHAR_FULLWIDTH_F)
                return c - UNICHAR_FULLWIDTH_A + 10;
	else
		return unichar_digit_value(c);
}


/* {{{1
 * Determine the Unicode character type of ‘c’.
 */
UnicodeType
unichar_type(unichar c)
{
	return s_type(c);
}


/* {{{1
 * LocaleType: This ‹enum› is used for dealing with different locales for
 * turning strings into uppercase or lowercase.
 */
typedef enum {
	LOCALE_NORMAL,
	LOCALE_TURKIC,
	LOCALE_LITHUANIAN
} LocaleType;


/* {{{1
 * Retrieve the locale type from the environment (LC_CTYPE).
 */
static LocaleType
get_locale_type(void)
{
	const char *locale = setlocale(LC_CTYPE, NULL);

	if ((locale[0] == 'a' && locale[1] == 'z') ||
	    (locale[0] == 't' && locale[1] == 'r'))
		return LOCALE_TURKIC;

	if (locale[0] == 'l' && locale[1] == 't')
		return LOCALE_LITHUANIAN;

        return LOCALE_NORMAL;
}


/* {{{1
 * Put character marks found in ‘p_inout’ into itself.  If ‘remove_dot’ is
 * true, remove the dot over an uppercase I for a turkish locale.
 */
static size_t
output_marks(const char **p_inout, char *buf, bool remove_dot)
{
	size_t len = 0;
	const char *p = *p_inout;

	for ( ; *p != '\0'; p = utf_next(p)) {
		unichar c = utf_char(p);

                if (!s_ismark(s_type(c)))
                        break;

                if (!remove_dot || c != COMBINING_DOT_ABOVE)
                        len += unichar_to_utf(c, (buf != NULL) ? buf + len : NULL);
	}

	*p_inout = p;

	return len;
}

/* {{{1
 * Output titlecases where appropriate.
 */
static size_t
output_special_case(char *buf, int offset, int type, bool upper)
{
	const char *p = special_case_table + offset;

	if (type != UNICODE_TITLECASE_LETTER)
		p = utf_next(p);

	if (upper)
		p += utf_byte_length(p) + 1;

	size_t len = utf_byte_length(p);

	if (buf != NULL)
		memcpy(buf, p, len);

	return len;
}

/* {{{1
 * Do uppercasing of ‘p’ for Lithuanian locales.
 */
static size_t
remove_all_combining_dot_above(unichar c, char *buf)
{
        size_t decomp_len;
        unichar *decomp = unicode_canonical_decomposition(c, &decomp_len);

        size_t len = 0;
        for (size_t i = 0; i < decomp_len; i++)
                if (decomp[i] != COMBINING_DOT_ABOVE)
                        len += unichar_to_utf(unichar_toupper(decomp[i]),
                                              OFFSET_IF(buf, len));

        free(decomp);

        return len;
}

static size_t
real_toupper_lithuanian(const char **p, unichar c, int type, char *buf,
                        bool *was_i)
{
	if (c == 'i') {
		*was_i = true;
		return 0;
	}

	if (*was_i) {
                size_t len = remove_all_combining_dot_above(c, buf);
		return len + output_marks(p, OFFSET_IF(buf, len), true);
	}

	if (!s_ismark(type))
		*was_i = false;

	return 0;
}

/* {{{1
 * Do real upcasing. */
static inline size_t
real_do_toupper(unichar c, int type, char *buf)
{
	bool upper = (type != UNICODE_LOWERCASE_LETTER);
	unichar tv = ATTTABLE(c >> 8, c & 0xff);

	if (tv >= UNICODE_SPECIAL_CASE_TABLE_START)
                return output_special_case(buf,
                                           tv - UNICODE_SPECIAL_CASE_TABLE_START,
                                           type, upper);

        /* TODO: this should really use titlecase_table_lookup somehow. */
        if (type == UNICODE_TITLECASE_LETTER)
                for (size_t i = 0; i < lengthof(title_table); i++)
                        if (title_table[i][0] == c)
                                return unichar_to_utf(title_table[i][1], buf);

        return unichar_to_utf(tv != '\0' ? tv : c, buf); 
}

/* {{{1
 * Do real uppercasing of ‘str’.
 */
static size_t
real_toupper_one(const char **p, const char *prev, char *buf,
                 LocaleType locale_type, bool *was_i)
{
        unichar c = utf_char(prev);
        int type = s_type(c);

        if (locale_type == LOCALE_LITHUANIAN) {
                size_t len = real_toupper_lithuanian(p, c, type, buf, was_i);
                if (len > 0)
                        return len;
        }

        if (locale_type == LOCALE_TURKIC && c == 'i')
                return unichar_to_utf(LATIN_CAPITAL_LETTER_I_WITH_DOT_ABOVE,
                                      buf);

        if (c == COMBINING_GREEK_YPOGEGRAMMENI) {
                /* Nasty, need to move it after other combining marks...this
                 * would go away if we normalized first. */
                /* TODO: don’t we need to make sure we don’t go beyond the end
                 * of ‘p’? */
                size_t len = output_marks(p, buf, false);
                return len + unichar_to_utf(GREEK_CAPITAL_LETTER_IOTA,
                                            OFFSET_IF(buf, len));
        }
        
        if (IS(type, OR(UNICODE_LOWERCASE_LETTER,
                        OR(UNICODE_TITLECASE_LETTER, 0))))
                return real_do_toupper(c, type, buf);

        size_t len = s_utf_skip_lengths[*(const unsigned char *)prev];

        if (buf != NULL)
                memcpy(buf, prev, len);

        return len;
}

static size_t
real_toupper(const char *str, size_t max, bool use_max, char *buf,
	     LocaleType locale_type)
{
	const char *p = str;
	size_t len = 0;
	bool p_was_i = false;

	while ((!use_max || p < str + max) && *p != '\0') {
		const char *prev = p;
		p = utf_next(p);

                len += real_toupper_one(&p, prev, OFFSET_IF(buf, len),
                                        locale_type, &p_was_i);
	}

	return len;
}

/* {{{1
 * Wrapper around real_toupper() for dealing with memory allocation and such.
 */
static char *
utf_upcase_impl(const char *str, size_t max, bool use_max)
{
	assert(str != NULL);

	LocaleType locale_type = get_locale_type();

	size_t len = real_toupper(str, max, use_max, NULL, locale_type);
	char *result = ALLOC_N(char, len + 1);
	real_toupper(str, max, use_max, result, locale_type);
	result[len] = '\0';

	return result;
}


/* {{{1
 * Convert all characters in ‘str’ to their uppercase representation if
 * applicable.  Returns the freshly allocated representation.
 */
char *
utf_upcase(const char *str)
{
	return utf_upcase_impl(str, 0, false);
}


/* {{{1
 * Convert all characters in ‘str’ to their uppercase representation if
 * applicable.  Returns the freshly allocated representation.  Do this for at
 * most ‘len˚ bytes from ‘str’.
 */
char *
utf_upcase_n(const char *str, size_t len)
{
	return utf_upcase_impl(str, len, true);
}


/* {{{1
 * Traverse the string checking for characters with combining class == 230
 * until a base character is found.
 */ 
static bool
has_more_above(const char *str)
{
	for (const char *p = str; *p != '\0'; p = utf_next(p)) {
		int c_class = unichar_combining_class(utf_char(p));

		if (c_class == 230)
			return true;

		if (c_class == 0)
			return false;
	}

	return false;
}

static inline size_t
real_do_tolower(unichar c, int type, char *buf)
{
	unichar tv = ATTTABLE(c >> 8, c & 0xff);

	if (tv >= UNICODE_SPECIAL_CASE_TABLE_START)
                return output_special_case(buf,
                                           tv - UNICODE_SPECIAL_CASE_TABLE_START,
                                           type, false);

        /* TODO: this should really use titlecase_table_lookup somehow. */
        if (type == UNICODE_TITLECASE_LETTER)
                for (size_t i = 0; i < lengthof(title_table); i++)
                        if (title_table[i][0] == c)
                                return unichar_to_utf(title_table[i][2], buf);

        return unichar_to_utf(tv != '\0' ? tv : c, buf);
}

/* {{{1
 * The real implementation of downcase.
 */
static size_t
tolower_turkic_i(const char **p, char *buf)
{
        unichar i = LATIN_SMALL_LETTER_DOTLESS_I;

        if (utf_char(*p) == COMBINING_DOT_ABOVE) {
                /* TODO: don’t we need to make sure we don’t go beyond the end
                 * of ‘p’? */
                *p = utf_next(*p);
                i = LATIN_SMALL_LETTER_I;
        } 

        return unichar_to_utf(i, buf);
}

static size_t
tolower_lithuianian_i(char *buf, unichar base, unichar combiner)
{
        size_t len = unichar_to_utf(base, buf);
        len += unichar_to_utf(COMBINING_DOT_ABOVE, OFFSET_IF(buf, len));
        if (combiner != '\0')
                len += unichar_to_utf(combiner, OFFSET_IF(buf, len));

        return len;
}

static size_t
tolower_sigma(const char **p, char *buf, const char *end, bool use_end)
{
        unichar sigma = GREEK_SMALL_LETTER_FINAL_SIGMA;

        /* SIGMA maps differently depending on whether it is final or not.  The
         * following simplified test would fail in the case of combining marks
         * following the sigma, but I don't think that occurs in real text.
         * The test here matches that in ICU. */
        if ((!use_end || *p < end) && **p != '\0' && s_isalpha(s_type(utf_char(*p))))
                sigma = GREEK_SMALL_LETTER_SIGMA;

        return unichar_to_utf(sigma, buf);
}

static size_t
real_tolower_one(const char **p, const char *prev, char *buf,
                 LocaleType locale_type, const char *end, bool use_end)
{
        unichar c = utf_char(prev);
        int type = s_type(c);

        if (locale_type == LOCALE_TURKIC && c == 'I')
                return tolower_turkic_i(p, buf);

        /* Introduce an explicit dot above the lowercasing capital I’s
         * and J’s whenever there are more accents above.
         * [SpecialCasing.txt] */
        if (locale_type == LOCALE_LITHUANIAN) {
                unichar base = LATIN_SMALL_LETTER_I;
                unichar combiner = '\0';

                switch (c) {
                case LATIN_CAPITAL_LETTER_I_WITH_GRAVE:
                        combiner = COMBINING_GRAVE_ACCENT;
                        break;
                case LATIN_CAPITAL_LETTER_I_WITH_ACUTE:
                        combiner = COMBINING_ACUTE_ACCENT;
                        break;
                case LATIN_CAPITAL_LETTER_I_WITH_TILDE:
                        combiner = COMBINING_TILDE;
                        break;
                case 'I':
                case 'J':
                case LATIN_CAPITAL_LETTER_I_WITH_OGONEK:
                        if (!has_more_above(*p))
                                goto no_lithuanian_i_casing;

                        base = unichar_tolower(c);
                        break;
                default:
                        goto no_lithuanian_i_casing;
                }

                return tolower_lithuianian_i(buf, base, combiner);
        }

no_lithuanian_i_casing:

        if (c == GREEK_CAPITAL_LETTER_SIGMA)
                return tolower_sigma(p, buf, end, use_end); 
        
        if (IS(type, OR(UNICODE_UPPERCASE_LETTER,
                        OR(UNICODE_TITLECASE_LETTER, 0))))
                return real_do_tolower(c, type, buf);

        size_t len = s_utf_skip_lengths[*(const unsigned char *)prev];

        if (buf != NULL)
                memcpy(buf, prev, len);

        return len;
}

static size_t
real_tolower(const char *str, size_t max, bool use_max, char *buf,
             LocaleType locale_type)
{
	const char *p = str;
        const char *end = str + max;
	size_t len = 0;

	while ((!use_max || p < end) && *p != '\0') {
		const char *prev = p;
		p = utf_next(p);

                len += real_tolower_one(&p, prev, OFFSET_IF(buf, len),
                                        locale_type, end, use_max);
	}

	return len;
}


/* {{{1 */
static char *
utf_downcase_impl(const char *str, size_t max, bool use_max)
{
	assert(str != NULL);

	LocaleType locale_type = get_locale_type();

	size_t len = real_tolower(str, max, use_max, NULL, locale_type);
	char *result = ALLOC_N(char, len + 1);
	real_tolower(str, max, use_max, result, locale_type);
	result[len] = '\0';

	return result;
}


/* {{{1
 * Convert all characters in ‘str’ to their lowercase representation if
 * applicable.  Returns the freshly allocated representation.
 */
char *
utf_downcase(const char *str)
{
	return utf_downcase_impl(str, 0, false);
}


/* {{{1
 * Convert all characters in ‘str’ to their lowercase representation if
 * applicable.  Returns the freshly allocated representation.  Do this for at
 * most ‘len˚ bytes from ‘str’.
 */
char *
utf_downcase_n(const char *str, size_t len)
{
	return utf_downcase_impl(str, len, true);
}


/* {{{1
 * The real implementation of case folding below.
 */

static bool
casefold_table_lookup(unichar c, char *folded, size_t *len)
{
        int index;

        if (!unicode_table_lookup(casefold_table, c, &index))
                return false;

        char const *folded_c = casefold_table[index].data;

        if (folded != NULL)
                strcpy(folded, folded_c);

        *len += utf_byte_length(folded_c);

        return true;
}

static char *
utf_foldcase_impl(const char *str, size_t max, bool use_max)
{
	assert(str != NULL);

	char *folded = NULL;
	size_t len = 0;

again:
	for (const char *p = str; (!use_max || p < str + max) && *p != '\0'; p = utf_next(p)) {
		unichar c = utf_char(p);

                if (casefold_table_lookup(c, OFFSET_IF(folded, len), &len))
                        continue;

		len += unichar_to_utf(unichar_tolower(c), OFFSET_IF(folded, len));
	}

	if (folded == NULL) {
		folded = ALLOC_N(char, len + 1);
		folded[0] = NUL;
		len = 0;
		goto again;
	}

	folded[len] = '\0';

	return folded;
}


/* {{{1
 * Convert a string into a form that is independent of case.  Return the
 * freshly allocated representation.
 */
char *
utf_foldcase(const char *str)
{
	return utf_foldcase_impl(str, 0, false);
}


/* {{{1
 * Convert a string into a form that is independent of case.  Return the
 * freshly allocated representation.  Do this for at most ‘len’ bytes from the
 * string.
 */
char *
utf_foldcase_n(const char *str, size_t len)
{
	return utf_foldcase_impl(str, len, true);
}


/* {{{1
 * The real implementation of utf_width() and utf_width_n() below.
 */
static size_t
utf_width_impl(const char *str, size_t len, bool use_len)
{
	assert(str != NULL);

	size_t width = 0;

	for (const char *p = str; (!use_len || p < str + len) && *p != NUL; p = utf_next(p))
		width += unichar_iswide(utf_char(p)) ? 2 : 1;

	return width;
}


/* {{{1
 * Calculate the width in cells of ‘str’.
 */
size_t
utf_width(const char *str)
{
	return utf_width_impl(str, 0, false);
}


/* {{{1
 * Calculate the width in cells of ‘str’, which is of length ‘len’.
 */
size_t
utf_width_n(const char *str, size_t len)
{
	return utf_width_impl(str, len, true);
}


/* {{{1
 * Retrieve the mirrored representation of ‘c’ (if any) and store it in
 * ‘mirrored’.
 */
bool
unichar_mirror(unichar c, unichar *mirrored)
{
        int index;

        if (!unicode_table_lookup(bidi_mirroring_table, c, &index))
                return false;

        if (mirrored != NULL)
                *mirrored = bidi_mirroring_table[index].mirrored_ch;

        return true;
}


/* }}}1 */
