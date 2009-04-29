/*
 * contents: Encoding::Character::UTF8.normalize module function.
 *
 * Copyright © 2006 Nikolai Weibull <now@bitwi.se>
 */

#include "rb_includes.h"

#define SYMBOL2MODE(symbol, mode, id) do {              \
        static ID id_##symbol;                          \
        if (id_##symbol == 0)                           \
                id_##symbol = rb_intern(#symbol);       \
        if (id == id_##symbol)                          \
                return mode;                            \
} while (0)

static NormalizeMode
symbol_to_mode(VALUE symbol)
{
        if (!SYMBOL_P(symbol))
                rb_raise(rb_eTypeError, "not a symbol");

        ID id = SYM2ID(symbol);

        SYMBOL2MODE(default, NORMALIZE_DEFAULT, id);
        SYMBOL2MODE(nfd, NORMALIZE_NFD, id);
        SYMBOL2MODE(default_compose, NORMALIZE_DEFAULT_COMPOSE, id);
        SYMBOL2MODE(nfc, NORMALIZE_NFC, id);
        SYMBOL2MODE(all, NORMALIZE_ALL, id);
        SYMBOL2MODE(nfkd, NORMALIZE_NFKD, id);
        SYMBOL2MODE(all_compose, NORMALIZE_ALL_COMPOSE, id);
        SYMBOL2MODE(nfkc, NORMALIZE_NFKC, id);

        rb_raise(rb_eArgError, "unknown symbol");
}

VALUE
rb_utf_normalize(int argc, VALUE *argv, UNUSED(VALUE self))
{
        VALUE str, rbmode;

        NormalizeMode mode = NORMALIZE_DEFAULT;
        if (rb_scan_args(argc, argv, "11", &str, &rbmode) == 2)
                mode = symbol_to_mode(rbmode);

        StringValue(str);

        return rb_utf_alloc_using(utf_normalize_n(RSTRING(str)->ptr,
                                                  mode,
                                                  RSTRING(str)->len));
}
