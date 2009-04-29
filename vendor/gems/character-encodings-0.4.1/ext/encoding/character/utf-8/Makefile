
SHELL = /bin/sh

#### Start of system configuration section. ####

srcdir = .
topdir = /usr/lib/ruby/1.8/i486-linux
hdrdir = $(topdir)
VPATH = $(srcdir):$(topdir):$(hdrdir)
exec_prefix = $(prefix)
prefix = $(DESTDIR)/usr
sharedstatedir = $(prefix)/com
mandir = $(prefix)/share/man
psdir = $(docdir)
oldincludedir = $(DESTDIR)/usr/include
localedir = $(datarootdir)/locale
bindir = $(exec_prefix)/bin
libexecdir = $(prefix)/lib/ruby1.8
sitedir = $(DESTDIR)/usr/local/lib/site_ruby
htmldir = $(docdir)
vendorarchdir = $(vendorlibdir)/$(sitearch)
includedir = $(prefix)/include
infodir = $(prefix)/share/info
vendorlibdir = $(vendordir)/$(ruby_version)
sysconfdir = $(DESTDIR)/etc
libdir = $(exec_prefix)/lib
sbindir = $(exec_prefix)/sbin
rubylibdir = $(libdir)/ruby/$(ruby_version)
docdir = $(datarootdir)/doc/$(PACKAGE)
dvidir = $(docdir)
vendordir = $(libdir)/ruby/vendor_ruby
datarootdir = $(prefix)/share
pdfdir = $(docdir)
archdir = $(rubylibdir)/$(arch)
sitearchdir = $(sitelibdir)/$(sitearch)
datadir = $(datarootdir)
localstatedir = $(DESTDIR)/var
sitelibdir = $(sitedir)/$(ruby_version)

CC = cc
LIBRUBY = $(LIBRUBY_SO)
LIBRUBY_A = lib$(RUBY_SO_NAME)-static.a
LIBRUBYARG_SHARED = -l$(RUBY_SO_NAME)
LIBRUBYARG_STATIC = -l$(RUBY_SO_NAME)-static

RUBY_EXTCONF_H = 
CFLAGS   =  -fPIC -fno-strict-aliasing -g -g -O2  -fPIC $(cflags) -std=c99 -finline-functions -Wall -Wextra -Wwrite-strings -Waggregate-return -Wmissing-prototypes -Wmissing-declarations -Wnested-externs -Wundef -Wpointer-arith -Wcast-align -Werror -Winline 
INCFLAGS = -I. -I$(topdir) -I$(hdrdir) -I$(srcdir)
DEFS     = -D_FILE_OFFSET_BITS=64
CPPFLAGS = -DHAVE_ASSERT_H -DHAVE_LIMITS_H -DHAVE_LOCALE_H -DHAVE_STDBOOL_H -DHAVE_STDDEF_H -DHAVE_STDINT_H -DHAVE_STDIO_H -DHAVE_STDLIB_H -DHAVE_STRING_H -DHAVE_SYS_TYPES_H -DHAVE_WCHAR_H  $(DEFS) $(cppflags)
CXXFLAGS = $(CFLAGS) 
ldflags  = -L. -Wl,-Bsymbolic-functions -rdynamic -Wl,-export-dynamic
dldflags = 
archflag = 
DLDFLAGS = $(ldflags) $(dldflags) $(archflag)
LDSHARED = $(CC) -shared
AR = ar
EXEEXT = 

RUBY_INSTALL_NAME = ruby1.8
RUBY_SO_NAME = ruby1.8
arch = i486-linux
sitearch = i486-linux
ruby_version = 1.8
ruby = /usr/bin/ruby1.8
RUBY = $(ruby)
RM = rm -f
MAKEDIRS = mkdir -p
INSTALL = /usr/bin/install -c
INSTALL_PROG = $(INSTALL) -m 0755
INSTALL_DATA = $(INSTALL) -m 644
COPY = cp

#### End of system configuration section. ####

preload = 

libpath = . $(libdir)
LIBPATH =  -L. -L$(libdir)
DEFFILE = 

CLEANFILES = mkmf.log
DISTCLEANFILES = 

extout = 
extout_prefix = 
target_prefix = /encoding/character/utf-8
LOCAL_LIBS = 
LIBS = $(LIBRUBYARG_SHARED)  -lpthread -ldl -lcrypt -lm   -lc
SRCS = break.c rb_utf_lstrip.c rb_utf_insert.c rb_utf_chomp.c utf.c rb_utf_strip.c rb_utf_downcase.c decompose.c rb_utf_foldcase.c rb_utf_aref.c rb_utf_to_i.c rb_utf_normalize.c rb_utf_oct.c rb_utf_rindex.c rb_utf_rstrip.c rb_utf_reverse.c rb_utf_hex.c rb_utf_internal_bignum.c rb_utf_squeeze.c rb_utf_length.c rb_utf_tr.c rb_utf_internal_tr.c rb_utf_collate.c rb_utf_index.c rb_utf_chop.c rb_utf_each_char.c rb_utf_casecmp.c rb_utf_justify.c rb_utf_aset.c unicode.c rb_utf_delete.c properties.c rb_utf_count.c private.c rb_utf_upcase.c
OBJS = break.o rb_utf_lstrip.o rb_utf_insert.o rb_utf_chomp.o utf.o rb_utf_strip.o rb_utf_downcase.o decompose.o rb_utf_foldcase.o rb_utf_aref.o rb_utf_to_i.o rb_utf_normalize.o rb_utf_oct.o rb_utf_rindex.o rb_utf_rstrip.o rb_utf_reverse.o rb_utf_hex.o rb_utf_internal_bignum.o rb_utf_squeeze.o rb_utf_length.o rb_utf_tr.o rb_utf_internal_tr.o rb_utf_collate.o rb_utf_index.o rb_utf_chop.o rb_utf_each_char.o rb_utf_casecmp.o rb_utf_justify.o rb_utf_aset.o unicode.o rb_utf_delete.o properties.o rb_utf_count.o private.o rb_utf_upcase.o
TARGET = utf8
DLLIB = $(TARGET).so
EXTSTATIC = 
STATIC_LIB = 

BINDIR        = $(bindir)
RUBYCOMMONDIR = $(sitedir)$(target_prefix)
RUBYLIBDIR = /home/obiwan/workspace/blank/vendor/gems/character-encodings-0.4.1/lib$(target_prefix)
RUBYARCHDIR = /home/obiwan/workspace/blank/vendor/gems/character-encodings-0.4.1/lib$(target_prefix)

TARGET_SO     = $(DLLIB)
CLEANLIBS     = $(TARGET).so $(TARGET).il? $(TARGET).tds $(TARGET).map
CLEANOBJS     = *.o *.a *.s[ol] *.pdb *.exp *.bak

all:		$(DLLIB)
static:		$(STATIC_LIB)

clean:
		@-$(RM) $(CLEANLIBS) $(CLEANOBJS) $(CLEANFILES)

distclean:	clean
		@-$(RM) Makefile $(RUBY_EXTCONF_H) conftest.* mkmf.log
		@-$(RM) core ruby$(EXEEXT) *~ $(DISTCLEANFILES)

realclean:	distclean
install: install-so install-rb

install-so: $(RUBYARCHDIR)
install-so: $(RUBYARCHDIR)/$(DLLIB)
$(RUBYARCHDIR)/$(DLLIB): $(DLLIB)
	$(INSTALL_PROG) $(DLLIB) $(RUBYARCHDIR)
install-rb: pre-install-rb install-rb-default
install-rb-default: pre-install-rb-default
pre-install-rb: Makefile
pre-install-rb-default: Makefile
pre-install-rb: $(RUBYARCHDIR)
install-rb: $(RUBYARCHDIR)/unicode.h
$(RUBYARCHDIR)/unicode.h: $(srcdir)/unicode.h $(RUBYARCHDIR)
	$(INSTALL_DATA) $(srcdir)/unicode.h $(@D)
$(RUBYARCHDIR):
	$(MAKEDIRS) $@

site-install: site-install-so site-install-rb
site-install-so: install-so
site-install-rb: install-rb

.SUFFIXES: .c .m .cc .cxx .cpp .C .o

.cc.o:
	$(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) -c $<

.cxx.o:
	$(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) -c $<

.cpp.o:
	$(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) -c $<

.C.o:
	$(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) -c $<

.c.o:
	$(CC) $(INCFLAGS) $(CPPFLAGS) $(CFLAGS) -c $<

$(DLLIB): $(OBJS)
	@-$(RM) $@
	$(LDSHARED) -o $@ $(OBJS) $(LIBPATH) $(DLDFLAGS) $(LOCAL_LIBS) $(LIBS)



###
break.o: break.c unicode.h data/break.h
decompose.o: decompose.c unicode.h private.h data/decompose.h \
  data/compose.h
private.o: private.c private.h
properties.o: properties.c unicode.h private.h data/character-tables.h
rb_utf_aref.o: rb_utf_aref.c rb_includes.h unicode.h private.h \
  rb_methods.h
rb_utf_aset.o: rb_utf_aset.c rb_includes.h unicode.h private.h \
  rb_methods.h
rb_utf_casecmp.o: rb_utf_casecmp.c rb_includes.h unicode.h private.h \
  rb_methods.h
rb_utf_chomp.o: rb_utf_chomp.c rb_includes.h unicode.h private.h \
  rb_methods.h
rb_utf_chop.o: rb_utf_chop.c rb_includes.h unicode.h private.h \
  rb_methods.h
rb_utf_collate.o: rb_utf_collate.c rb_includes.h unicode.h private.h \
  rb_methods.h
rb_utf_count.o: rb_utf_count.c rb_includes.h unicode.h private.h \
  rb_methods.h rb_utf_internal_tr.h
rb_utf_delete.o: rb_utf_delete.c rb_includes.h unicode.h private.h \
  rb_methods.h rb_utf_internal_tr.h
rb_utf_downcase.o: rb_utf_downcase.c rb_includes.h unicode.h private.h \
  rb_methods.h
rb_utf_each_char.o: rb_utf_each_char.c rb_includes.h unicode.h private.h \
  rb_methods.h
rb_utf_foldcase.o: rb_utf_foldcase.c rb_includes.h unicode.h private.h \
  rb_methods.h
rb_utf_hex.o: rb_utf_hex.c rb_includes.h unicode.h private.h rb_methods.h \
  rb_utf_internal_bignum.h
rb_utf_index.o: rb_utf_index.c rb_includes.h unicode.h private.h \
  rb_methods.h
rb_utf_insert.o: rb_utf_insert.c rb_includes.h unicode.h private.h \
  rb_methods.h
rb_utf_internal_bignum.o: rb_utf_internal_bignum.c rb_includes.h \
  unicode.h private.h rb_methods.h rb_utf_internal_bignum.h
rb_utf_internal_tr.o: rb_utf_internal_tr.c rb_includes.h unicode.h \
  private.h rb_methods.h rb_utf_internal_tr.h
rb_utf_justify.o: rb_utf_justify.c rb_includes.h unicode.h private.h \
  rb_methods.h
rb_utf_length.o: rb_utf_length.c rb_includes.h unicode.h private.h \
  rb_methods.h
rb_utf_lstrip.o: rb_utf_lstrip.c rb_includes.h unicode.h private.h \
  rb_methods.h
rb_utf_normalize.o: rb_utf_normalize.c rb_includes.h unicode.h private.h \
  rb_methods.h
rb_utf_oct.o: rb_utf_oct.c rb_includes.h unicode.h private.h rb_methods.h \
  rb_utf_internal_bignum.h
rb_utf_reverse.o: rb_utf_reverse.c rb_includes.h unicode.h private.h \
  rb_methods.h
rb_utf_rindex.o: rb_utf_rindex.c rb_includes.h unicode.h private.h \
  rb_methods.h
rb_utf_rstrip.o: rb_utf_rstrip.c rb_includes.h unicode.h private.h \
  rb_methods.h
rb_utf_squeeze.o: rb_utf_squeeze.c rb_includes.h unicode.h private.h \
  rb_methods.h rb_utf_internal_tr.h
rb_utf_strip.o: rb_utf_strip.c rb_includes.h unicode.h private.h \
  rb_methods.h
rb_utf_to_i.o: rb_utf_to_i.c rb_includes.h unicode.h private.h \
  rb_methods.h rb_utf_internal_bignum.h
rb_utf_tr.o: rb_utf_tr.c rb_includes.h unicode.h private.h rb_methods.h \
  rb_utf_internal_tr.h
rb_utf_upcase.o: rb_utf_upcase.c rb_includes.h unicode.h private.h \
  rb_methods.h
unicode.o: unicode.c unicode.h private.h rb_methods.h
utf.o: utf.c unicode.h private.h
