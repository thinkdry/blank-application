/*
 * contents: Internal functionality for turning strings into Bignums.
 *
 * Copyright © 2006 Nikolai Weibull <now@bitwi.se>
 */

#include "rb_includes.h"
#include "rb_utf_internal_bignum.h"

/* Stolen straight from bignum.c. */
#define BDIGITS(x)      ((BDIGIT *)RBIGNUM(x)->digits)
#define BITSPERDIG      (SIZEOF_BDIGITS * CHAR_BIT)
#define BIGRAD          ((BDIGIT_DBL)1 << BITSPERDIG)
#define BIGDN(x)        RSHIFT(x, BITSPERDIG)
#define BIGLO(x)        ((BDIGIT)((x) & (BIGRAD - 1)))

static VALUE
bignew_1(VALUE klass, long len, int sign)
{
    NEWOBJ(big, struct RBignum);
    OBJSETUP(big, klass, T_BIGNUM);
    big->sign = sign ? 1 : 0;
    big->len = len;
    big->digits = ALLOC_N(BDIGIT, len);

    return (VALUE)big;
}

#define bignew(len, sign) bignew_1(rb_cBignum, len, sign)

static const char *
rb_utf_to_inum_sign(const char *s, int *sign)
{
        *sign = 1;

        if (*s == '-')
                *sign = 0;

        if (*s == '+' || *s == '-')
                return s + 1;

        return s;
}

static const char *
rb_utf_to_inum_base(const char *s, int *base)
{
        if (s[0] == '0') {
                int offset = 2;
                switch (s[1]) {
                case 'x': case 'X':
                        *base = 16;
                        break;
                case 'b': case 'B':
                        *base = 2;
                        break;
                case 'o': case 'O':
                        *base = 8;
                        break;
                case 'd': case 'D':
                        *base = 10;
                        break;
                default:
                        *base = 8;
                        offset = 1;
                        break;
                }
                return s + offset;
        } else if (*base < -1) {
                *base = -*base;
        } else {
                *base = 10;
        }

        return s;
}

static size_t
rb_utf_to_inum_base_bit_length(const char *s, int base)
{
        if (base < 2 || base > 36)
                rb_raise(rb_eArgError, "illegal radix %d", base);

        size_t bit_length;
        switch (base) {
        case 2:
                bit_length = 1;
        case 3:
                bit_length = 2;
        case 4: case 5: case 6: case 7: case 8:
                bit_length = 3;
        case 9: case 10: case 11: case 12: case 13: case 14: case 15: case 16:
                bit_length = 4;
        default:
                if (base <= 32)
                        bit_length = 5;
                
                bit_length = 6;
        }

        return bit_length * utf_length(s);
}

static bool
rb_utf_to_inum_num_separator(const char *str, const char *s, bool verify,
                             unichar c, unichar *non_digit)
{
        if (c != '_')
                return false;

        if (!verify)
                return true;

        if (*non_digit != 0)
                rb_raise(rb_eArgError,
                         "unexpected ‘%lc’ found at position %ld",
                         c, utf_pointer_to_offset(str, s));

        *non_digit = c;

        return true;
}

static bool
rb_utf_to_inum_digit_value(const char *str, const char *s, unichar c,
                           int base, bool verify, int *digit_value)
{
        /* If we stumble upon a space, return false so that we may end our
         * processing and skip over any trailing white-space. */
        if (unichar_isspace(c))
                return false;

        int value = unichar_xdigit_value(c);
        if (value == -1) {
                if (!verify)
                        return false;
                rb_raise(rb_eArgError,
                         "non-digit character ‘%lc’ found at position %ld",
                         c, utf_pointer_to_offset(str, s));
        }

        if (value >= base) {
                if (!verify)
                        return false;

                rb_raise(rb_eArgError,
                         "value (%d) greater than base (%d) at position %ld",
                         value, base, utf_pointer_to_offset(str, s));
        }

        *digit_value = value;

        return true;
}

static VALUE
rb_utf_to_inum_as_fix(const char *str, const char *s, int sign, int base,
                      bool verify)
{
        unsigned long value = 0;

        unichar non_digit = 0;
        while (*s != '\0') {
                unichar c = utf_char(s);
                s = utf_next(s);

                if (rb_utf_to_inum_num_separator(str, s, verify, c, &non_digit))
                        continue;

                int digit_value;
                if (!rb_utf_to_inum_digit_value(str, s, c, base, verify, &digit_value))
                        break;
                value *= base;
                value += digit_value;

                non_digit = 0;
        }

        if (verify) {
                while (*s != '\0' && unichar_isspace(utf_char(s)))
                        s = utf_next(s);
                if (*s != '\0')
                        rb_raise(rb_eArgError,
                                 "trailing garbage found at position %ld",
                                 utf_pointer_to_offset(str, s));
        }

        if (POSFIXABLE(value)) {
                if (sign)
                        return LONG2FIX(value);
                else
                        return LONG2FIX(-(long)value);
        }

        VALUE big = rb_uint2big(value);
        RBIGNUM(big)->sign = sign;
        return rb_big_norm(big);
}

static VALUE
rb_cutf_to_inum(const char * const str, int base, bool verify)
{
        /* FIXME: How can this even happen? */
        if (str == NULL) {
                if (verify)
                        rb_invalid_str(str, "Integer");
                return INT2FIX(0);
        }

        const char *s = str;

        /* Skip any leading whitespace. */
        while (unichar_isspace(utf_char(s)))
                s = utf_next(s);

        /* Figure out what sign this number uses. */
        int sign;
        s = rb_utf_to_inum_sign(s, &sign);

        /* Do we have another sign?  If so, that’s not correct. */
        if (*s == '+' || *s == '-') {
                if (verify)
                        rb_raise(rb_eArgError,
                                 "extra sign ‘%c’ found at position %ld",
                                 *s, utf_pointer_to_offset(str, s));
                return INT2FIX(0);
        }

        int tmp_base = base;
        s = rb_utf_to_inum_base(s, &tmp_base);
        if (base <= 0)
                base = tmp_base;

        /* Remove preceeding 0s. */
        while (*s == '0')
                s++;

        /* Figure out how many bits we need to represent the number. */
        size_t bit_length = rb_utf_to_inum_base_bit_length(str, base);

        /* If the bit_length is less than the number of bits in a VALUE we can
         * try to store it as a FIXNUM. */
        if (bit_length <= sizeof(VALUE) * CHAR_BIT)
                return rb_utf_to_inum_as_fix(str, s, sign, base, verify);

        if (verify && *str == '_')
                rb_raise(rb_eArgError,
                         "leading digit-separator ‘_’ found at position %ld",
                         utf_pointer_to_offset(str, s));

        bit_length = bit_length / BITSPERDIG + 1;

        /* TODO: Rename these variables. */
        VALUE z = bignew(bit_length, sign);
        BDIGIT *zds = BDIGITS(z);
        MEMZERO(zds, BDIGIT, bit_length);
        int big_len = 1;

        unichar non_digit = 0;
        while (true) {
                unichar c = utf_char(s);
                s = utf_next(s);

                if (rb_utf_to_inum_num_separator(str, s, verify, c, &non_digit))
                        continue;

                int digit_value;
                if (!rb_utf_to_inum_digit_value(str, s, c, base, verify, &digit_value))
                        break;

                bool more_to_shift = true;
                while (more_to_shift) {
                        BDIGIT_DBL num = digit_value;

                        for (int i = 0; i < big_len; i++) {
                                num += (BDIGIT_DBL)zds[i] * base;
                                zds[i] = BIGLO(num);
                                num = BIGDN(num);
                        }

                        more_to_shift = false;
                        if (num != 0) {
                                big_len++;
                                more_to_shift = true;
                        }
                }

                non_digit = 0;
        }

        if (!verify)
                return rb_big_norm(z);

        s--;
        if (str + 1 < s && s[-1] == '_')
                rb_raise(rb_eArgError,
                         "trailing digit-separator ‘_’ found at position %ld",
                         utf_pointer_to_offset(str, s));

        if (*s != '\0')
                rb_raise(rb_eArgError,
                         "trailing garbage found at position %ld",
                         utf_pointer_to_offset(str, s));

        return rb_big_norm(z);
}

VALUE
rb_utf_to_inum(VALUE str, int base, bool verify)
{
        StringValue(str);

        char *s;
        if (verify)
                s = StringValueCStr(str);
        else
                s = RSTRING(str)->ptr;

        if (s != NULL) {
                long len = RSTRING(str)->len;
                /* no sentinel somehow */
                if (s[len] != '\0') {
                        char *p = ALLOCA_N(char, len + 1);

                        MEMCPY(p, s, char, len);
                        p[len] = '\0';
                        s = p;
                }
        }

        return rb_cutf_to_inum(s, base, verify); 
}
