/*
 * contents: Method declarations.
 *
 * Copyright © 2006 Nikolai Weibull <now@bitwi.se>
 */

#ifndef RB_METHODS_H
#define RB_METHODS_H

VALUE rb_utf_collate(UNUSED(VALUE self), VALUE str, VALUE other) HIDDEN;
VALUE rb_utf_downcase(UNUSED(VALUE self), VALUE str) HIDDEN;
VALUE rb_utf_length(UNUSED(VALUE self), VALUE str) HIDDEN;
VALUE rb_utf_reverse(UNUSED(VALUE self), VALUE str) HIDDEN;
VALUE rb_utf_upcase(UNUSED(VALUE self), VALUE str) HIDDEN;
VALUE rb_utf_aref_m(int argc, VALUE *argv, UNUSED(VALUE self)) HIDDEN;
VALUE rb_utf_aset_m(int argc, VALUE *argv, UNUSED(VALUE self)) HIDDEN;
VALUE rb_utf_casecmp(UNUSED(VALUE self), VALUE str1, VALUE str2) HIDDEN;
VALUE rb_utf_center(int argc, VALUE *argv, UNUSED(VALUE self)) HIDDEN;
VALUE rb_utf_ljust(int argc, VALUE *argv, UNUSED(VALUE self)) HIDDEN;
VALUE rb_utf_rjust(int argc, VALUE *argv, UNUSED(VALUE self)) HIDDEN;
VALUE rb_utf_chomp_bang(int argc, VALUE *argv, UNUSED(VALUE self)) HIDDEN;
VALUE rb_utf_chomp(int argc, VALUE *argv, VALUE self) HIDDEN;
VALUE rb_utf_chop_bang(UNUSED(VALUE self), VALUE str) HIDDEN;
VALUE rb_utf_chop(VALUE self, VALUE str) HIDDEN;
VALUE rb_utf_count(int argc, VALUE *argv, UNUSED(VALUE self)) HIDDEN;
VALUE rb_utf_delete_bang(int argc, VALUE *argv, UNUSED(VALUE self)) HIDDEN;
VALUE rb_utf_delete(int argc, VALUE *argv, VALUE self) HIDDEN;
VALUE rb_utf_each_char(UNUSED(VALUE self), VALUE str) HIDDEN;
VALUE rb_utf_index_m(int argc, VALUE *argv, UNUSED(VALUE self)) HIDDEN;
VALUE rb_utf_insert(UNUSED(VALUE self), VALUE str, VALUE index,
                    VALUE other) HIDDEN;
VALUE rb_utf_lstrip_bang(UNUSED(VALUE self), VALUE str) HIDDEN;
VALUE rb_utf_lstrip(VALUE self, VALUE str) HIDDEN;
VALUE rb_utf_rindex_m(int argc, VALUE *argv, UNUSED(VALUE self)) HIDDEN;
VALUE rb_utf_rstrip_bang(UNUSED(VALUE self), VALUE str) HIDDEN;
VALUE rb_utf_rstrip(VALUE self, VALUE str) HIDDEN;
VALUE rb_utf_squeeze_bang(int argc, VALUE *argv, UNUSED(VALUE self)) HIDDEN;
VALUE rb_utf_squeeze(int argc, VALUE *argv, VALUE self) HIDDEN;
VALUE rb_utf_strip_bang(VALUE self, VALUE str) HIDDEN;
VALUE rb_utf_strip(VALUE self, VALUE str) HIDDEN;
VALUE rb_utf_to_i(int argc, VALUE *argv, UNUSED(VALUE self)) HIDDEN;
VALUE rb_utf_hex(UNUSED(VALUE self), VALUE str) HIDDEN;
VALUE rb_utf_oct(UNUSED(VALUE self), VALUE str) HIDDEN;
VALUE rb_utf_tr(UNUSED(VALUE self), VALUE str, VALUE from, VALUE to) HIDDEN;
VALUE rb_utf_tr_s(UNUSED(VALUE self), VALUE str, VALUE from, VALUE to) HIDDEN;
VALUE rb_utf_foldcase(UNUSED(VALUE self), VALUE str) HIDDEN;
VALUE rb_utf_normalize(int argc, VALUE *argv, UNUSED(VALUE self)) HIDDEN;

#endif /* RB_METHODS_H */
