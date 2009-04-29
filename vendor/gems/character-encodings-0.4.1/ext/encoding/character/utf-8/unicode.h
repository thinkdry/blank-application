/*
 * contents: Unicode handling.
 *
 * Copyright (C) 2004 Nikolai Weibull <source@pcppopper.org>
 */


#ifndef UNICODE_H
#define UNICODE_H

#if __GNUC__ > 2 || (__GNUC__ == 2 && __GNUC_MINOR__ > 4)
#define CONST_FUNC                              \
          __attribute__((__const__))
#else
#define CONST_FUNC
#endif

typedef uint32_t unichar;

#define MAXUNICHAR UINT32_MAX

#define MAX_UNICHAR_BYTE_LENGTH 6

#define UNICODE_N_CODEPOINTS            (0x10ffff + 1)

/* unichar return used for representing bad input to a function. */
#define UTF_BAD_INPUT_UNICHAR		((unichar)-1)


/* unichar return used for representing an incomplete input to a function. */
#define UTF_INCOMPLETE_INPUT_UNICHAR	((unichar)-2)


typedef enum {
	UNICODE_CONTROL,
	UNICODE_FORMAT,
	UNICODE_UNASSIGNED,
	UNICODE_PRIVATE_USE,
	UNICODE_SURROGATE,
	UNICODE_LOWERCASE_LETTER,
	UNICODE_MODIFIER_LETTER,
	UNICODE_OTHER_LETTER,
	UNICODE_TITLECASE_LETTER,
	UNICODE_UPPERCASE_LETTER,
	UNICODE_COMBINING_MARK,
	UNICODE_ENCLOSING_MARK,
	UNICODE_NON_SPACING_MARK,
	UNICODE_DECIMAL_NUMBER,
	UNICODE_LETTER_NUMBER,
	UNICODE_OTHER_NUMBER,
	UNICODE_CONNECT_PUNCTUATION,
	UNICODE_DASH_PUNCTUATION,
	UNICODE_CLOSE_PUNCTUATION,
	UNICODE_FINAL_PUNCTUATION,
	UNICODE_INITIAL_PUNCTUATION,
	UNICODE_OTHER_PUNCTUATION,
	UNICODE_OPEN_PUNCTUATION,
	UNICODE_CURRENCY_SYMBOL,
	UNICODE_MODIFIER_SYMBOL,
	UNICODE_MATH_SYMBOL,
	UNICODE_OTHER_SYMBOL,
	UNICODE_LINE_SEPARATOR,
	UNICODE_PARAGRAPH_SEPARATOR,
	UNICODE_SPACE_SEPARATOR
} UnicodeType;

bool unichar_isalnum(unichar c);
bool unichar_isalpha(unichar c);
bool unichar_iscntrl(unichar c);
bool unichar_isdigit(unichar c);
bool unichar_isgraph(unichar c);
bool unichar_islower(unichar c);
bool unichar_isprint(unichar c);
bool unichar_ispunct(unichar c);
bool unichar_isspace(unichar c);
bool unichar_isupper(unichar c);
bool unichar_istitle(unichar c);
bool unichar_isnewline(unichar c);
bool unichar_isxdigit(unichar c);
bool unichar_isassigned(unichar c);
bool unichar_iswide(unichar c);
bool unichar_isvalid(unichar c);

unichar unichar_toupper(unichar c);
unichar unichar_tolower(unichar c);
unichar unichar_totitle(unichar c);

int unichar_digit_value(unichar c);
int unichar_xdigit_value(unichar c);

UnicodeType unichar_type(unichar c);

int unichar_combining_class(unichar c) CONST_FUNC;

bool unichar_mirror(unichar c, unichar *mirrored);


typedef enum {
	UNICODE_BREAK_MANDATORY,
	UNICODE_BREAK_CARRIAGE_RETURN,
	UNICODE_BREAK_LINE_FEED,
	UNICODE_BREAK_COMBINING_MARK,
	UNICODE_BREAK_SURROGATE,
	UNICODE_BREAK_ZERO_WIDTH_SPACE,
	UNICODE_BREAK_INSEPARABLE,
	UNICODE_BREAK_NON_BREAKING_GLUE,
	UNICODE_BREAK_CONTINGENT,
	UNICODE_BREAK_SPACE,
	UNICODE_BREAK_AFTER,
	UNICODE_BREAK_BEFORE,
	UNICODE_BREAK_BEFORE_AND_AFTER,
	UNICODE_BREAK_HYPHEN,
	UNICODE_BREAK_NON_STARTER,
	UNICODE_BREAK_OPEN_PUNCTUATION,
	UNICODE_BREAK_CLOSE_PUNCTUATION,
	UNICODE_BREAK_QUOTATION,
	UNICODE_BREAK_EXCLAMATION,
	UNICODE_BREAK_IDEOGRAPHIC,
	UNICODE_BREAK_NUMERIC,
	UNICODE_BREAK_INFIX_SEPARATOR,
	UNICODE_BREAK_SYMBOL,
	UNICODE_BREAK_ALPHABETIC,
	UNICODE_BREAK_PREFIX,
	UNICODE_BREAK_POSTFIX,
	UNICODE_BREAK_COMPLEX_CONTEXT,
	UNICODE_BREAK_AMBIGUOUS,
	UNICODE_BREAK_UNKNOWN,
	UNICODE_BREAK_NEXT_LINE,
	UNICODE_BREAK_WORD_JOINER,
        UNICODE_BREAK_HANGUL_L_JAMO,
        UNICODE_BREAK_HANGUL_V_JAMO,
        UNICODE_BREAK_HANGUL_T_JAMO,
        UNICODE_BREAK_HANGUL_LV_SYLLABLE,
        UNICODE_BREAK_HANGUL_LVT_SYLLABLE
} UnicodeBreakType;

UnicodeBreakType unichar_break_type(unichar c);


typedef enum {
	NORMALIZE_DEFAULT,
	NORMALIZE_NFD = NORMALIZE_DEFAULT,
	NORMALIZE_DEFAULT_COMPOSE,
	NORMALIZE_NFC = NORMALIZE_DEFAULT_COMPOSE,
	NORMALIZE_ALL,
	NORMALIZE_NFKD = NORMALIZE_ALL,
	NORMALIZE_ALL_COMPOSE,
	NORMALIZE_NFKC = NORMALIZE_ALL_COMPOSE
} NormalizeMode;

void unicode_canonical_ordering(unichar *str, size_t len);
unichar *unicode_canonical_decomposition(unichar c, size_t *result_len);

char *utf_normalize(const char *str, NormalizeMode mode);
char *utf_normalize_n(const char *str, NormalizeMode mode, size_t len);




char *utf_upcase(const char *str);
char *utf_upcase_n(const char *str, size_t len);
char *utf_downcase(const char *str);
char *utf_downcase_n(const char *str, size_t len);
char *utf_foldcase(const char *str);
char *utf_foldcase_n(const char *str, size_t len);

unichar utf_char(const char *str);
unichar utf_char_n(const char *str, size_t max);
unichar utf_char_validated(const char *str);
unichar utf_char_validated_n(const char *str, size_t max);

extern const char * const s_utf_skip_lengths;
#define utf_next(str)	((str) + s_utf_skip_lengths[*(const unsigned char *)(str)])
char *utf_find_next(const char *p, const char *end);
char *utf_prev(const char *p);
char *utf_find_prev(const char *begin, const char *p);
char *utf_offset_to_pointer(const char *str, long offset);
long utf_pointer_to_offset(const char *str, const char *pos);

void utf_copy(char *dest, const char *src);
void utf_copy_n(char *dest, const char *src, size_t n);
void utf_append(char *dest, const char *src);
void utf_append_n(char *dest, const char *src, size_t n);
int utf_collate(const char *a, const char *b);
char *utf_collate_key(const char *str);
char *utf_collate_key_n(const char *str, size_t len);
int utf_char_index(const char *str, unichar c);
int utf_char_index_n(const char *str, unichar c, size_t len);
int utf_char_rindex(const char *str, unichar c);
int utf_char_rindex_n(const char *str, unichar c, size_t len);
int utf_index(const char *haystack, const char *needle);
int utf_index_n(const char *haystack, const char *needle, size_t len);
int utf_rindex(const char *haystack, const char *needle);
int utf_rindex_n(const char *haystack, const char *needle, size_t len);
bool utf_has_prefix(const char *str, const char *prefix);
long utf_length(const char *str);
long utf_length_n(const char *str, long len);
size_t utf_width(const char *str);
size_t utf_width_n(const char *str, size_t len);
size_t utf_byte_length(const char *str);
char *utf_reverse(const char *str);
char *utf_reverse_n(const char *str, size_t len);

bool utf_isvalid(const char *str);
bool utf_isvalid_n(const char *str, size_t max, const char **end);

/* XXX: should probably name stuff utf32 instead of ucs4 */
int unichar_to_utf(unichar c, char *result);
char *ucs4_to_utf8(unichar *str, size_t *items_read, size_t *items_written);
char *ucs4_to_utf8_n(unichar *str, size_t len, size_t *items_read, size_t *items_written);
unichar *utf8_to_ucs4_fast(const char *str, size_t *items_written);
unichar *utf8_to_ucs4_fast_n(const char *str, size_t len, size_t *items_written);
unichar *utf8_to_ucs4(const char *str, size_t *items_read, size_t *items_written);
unichar *utf8_to_ucs4_n(const char *str, int len, size_t *items_read, size_t *items_written);

#endif /* UNICODE_H */
