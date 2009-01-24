#!/usr/bin/env ruby

module FeedParserUtilities
  # Adapted from python2.4's encodings/aliases.py

  Encoding_Aliases = {     
    'unicode'		 => 'utf-16',  

    # MacOSX does not have Unicode as a separate encoding nor even
    # aliased. My Ubuntu box has it as a separate encoding but I cannot
    # for the life of me figure out where the source code for UNICODE.so
    # is (supposedly, in libc6 .deb but that's a damn lie), so I don't
    # know what it expects. After some extensive research, I've decided
    # to alias it to utf-16 much like Python does when it is built with
    # --enable-unicode=ucs2. This could be seriously wrong. I have no idea.

    # ascii codec
    '646'                => 'ascii',
    'ansi_x3.4_1968'     => 'ascii',
    'ansi_x3_4_1968'     => 'ascii', # some email headers use this non-standard name
    'ansi_x3.4_1986'     => 'ascii',
    'cp367'              => 'ascii',
    'csascii'            => 'ascii',
    'ibm367'             => 'ascii',
    'iso646_us'          => 'ascii',
    'iso_646.irv_1991'   => 'ascii',
    'iso_ir_6'           => 'ascii',
    'us'                 => 'ascii',
    'us_ascii'           => 'ascii',

    # big5 codec
    'big5_tw'            => 'big5',
    'csbig5'             => 'big5',

    # big5hkscs codec
    'big5_hkscs'         => 'big5hkscs',
    'hkscs'              => 'big5hkscs',

    # cp037 codec
    '037'                => 'cp037',
    'csibm037'           => 'cp037',
    'ebcdic_cp_ca'       => 'cp037',
    'ebcdic_cp_nl'       => 'cp037',
    'ebcdic_cp_us'       => 'cp037',
    'ebcdic_cp_wt'       => 'cp037',
    'ibm037'             => 'cp037',
    'ibm039'             => 'cp037',

    # cp1026 codec
    '1026'               => 'cp1026',
    'csibm1026'          => 'cp1026',
    'ibm1026'            => 'cp1026',

    # cp1140 codec
    '1140'               => 'cp1140',
    'ibm1140'            => 'cp1140',

    # cp1250 codec
    '1250'               => 'cp1250',
    'windows_1250'       => 'cp1250',

    # cp1251 codec
    '1251'               => 'cp1251',
    'windows_1251'       => 'cp1251',

    # cp1252 codec
    '1252'               => 'cp1252',
    'windows_1252'       => 'cp1252',

    # cp1253 codec
    '1253'               => 'cp1253',
    'windows_1253'       => 'cp1253',

    # cp1254 codec
    '1254'               => 'cp1254',
    'windows_1254'       => 'cp1254',

    # cp1255 codec
    '1255'               => 'cp1255',
    'windows_1255'       => 'cp1255',

    # cp1256 codec
    '1256'               => 'cp1256',
    'windows_1256'       => 'cp1256',

    # cp1257 codec
    '1257'               => 'cp1257',
    'windows_1257'       => 'cp1257',

    # cp1258 codec
    '1258'               => 'cp1258',
    'windows_1258'       => 'cp1258',

    # cp424 codec
    '424'                => 'cp424',
    'csibm424'           => 'cp424',
    'ebcdic_cp_he'       => 'cp424',
    'ibm424'             => 'cp424',

    # cp437 codec
    '437'                => 'cp437',
    'cspc8codepage437'   => 'cp437',
    'ibm437'             => 'cp437',

    # cp500 codec
    '500'                => 'cp500',
    'csibm500'           => 'cp500',
    'ebcdic_cp_be'       => 'cp500',
    'ebcdic_cp_ch'       => 'cp500',
    'ibm500'             => 'cp500',

    # cp775 codec
    '775'              => 'cp775',
    'cspc775baltic'      => 'cp775',
    'ibm775'             => 'cp775',

    # cp850 codec
    '850'                => 'cp850',
    'cspc850multilingual' => 'cp850',
    'ibm850'             => 'cp850',

    # cp852 codec
    '852'                => 'cp852',
    'cspcp852'           => 'cp852',
    'ibm852'             => 'cp852',

    # cp855 codec
    '855'                => 'cp855',
    'csibm855'           => 'cp855',
    'ibm855'             => 'cp855',

    # cp857 codec
    '857'                => 'cp857',
    'csibm857'           => 'cp857',
    'ibm857'             => 'cp857',

    # cp860 codec
    '860'                => 'cp860',
    'csibm860'           => 'cp860',
    'ibm860'             => 'cp860',

    # cp861 codec
    '861'                => 'cp861',
    'cp_is'              => 'cp861',
    'csibm861'           => 'cp861',
    'ibm861'             => 'cp861',

    # cp862 codec
    '862'                => 'cp862',
    'cspc862latinhebrew' => 'cp862',
    'ibm862'             => 'cp862',

    # cp863 codec
    '863'                => 'cp863',
    'csibm863'           => 'cp863',
    'ibm863'             => 'cp863',

    # cp864 codec
    '864'                => 'cp864',
    'csibm864'           => 'cp864',
    'ibm864'             => 'cp864',

    # cp865 codec
    '865'                => 'cp865',
    'csibm865'           => 'cp865',
    'ibm865'             => 'cp865',

    # cp866 codec
    '866'                => 'cp866',
    'csibm866'           => 'cp866',
    'ibm866'             => 'cp866',

    # cp869 codec
    '869'                => 'cp869',
    'cp_gr'              => 'cp869',
    'csibm869'           => 'cp869',
    'ibm869'             => 'cp869',

    # cp932 codec
    '932'                => 'cp932',
    'ms932'              => 'cp932',
    'mskanji'            => 'cp932',
    'ms_kanji'           => 'cp932',

    # cp949 codec
    '949'                => 'cp949',
    'ms949'              => 'cp949',
    'uhc'                => 'cp949',

    # cp950 codec
    '950'                => 'cp950',
    'ms950'              => 'cp950',

    # euc_jp codec
    'euc_jp'             => 'euc-jp',
    'eucjp'              => 'euc-jp',
    'ujis'               => 'euc-jp',
    'u_jis'              => 'euc-jp',

    # euc_kr codec
    'euc_kr'             => 'euc-kr',
    'euckr'              => 'euc-kr',
    'korean'             => 'euc-kr',
    'ksc5601'            => 'euc-kr',
    'ks_c_5601'          => 'euc-kr',
    'ks_c_5601_1987'     => 'euc-kr',
    'ksx1001'            => 'euc-kr',
    'ks_x_1001'          => 'euc-kr',

    # gb18030 codec
    'gb18030_2000'       => 'gb18030',

    # gb2312 codec
    'chinese'            => 'gb2312',
    'csiso58gb231280'    => 'gb2312',
    'euc_cn'             => 'gb2312',
    'euccn'              => 'gb2312',
    'eucgb2312_cn'       => 'gb2312',
    'gb2312_1980'        => 'gb2312',
    'gb2312_80'          => 'gb2312',
    'iso_ir_58'          => 'gb2312',

    # gbk codec
    '936'                => 'gbk',
    'cp936'              => 'gbk',
    'ms936'              => 'gbk',

    # hp-roman8 codec
    'hp_roman8'          => 'hp-roman8',
    'roman8'             => 'hp-roman8',
    'r8'                 => 'hp-roman8',
    'csHPRoman8'         => 'hp-roman8',

    # iso2022_jp codec
    'iso2022_jp'         => 'iso-2022-jp',
    'csiso2022jp'        => 'iso-2022-jp',
    'iso2022jp'          => 'iso-2022-jp',
    'iso_2022_jp'        => 'iso-2022-jp',

    # iso2022_jp_1 codec
    'iso2002_jp_1'       => 'iso-2022-jp-1',
    'iso2022jp_1'        => 'iso-2022-jp-1',
    'iso_2022_jp_1'      => 'iso-2022-jp-1',

    # iso2022_jp_2 codec
    'iso2022_jp_2'       => 'iso-2002-jp-2',
    'iso2022jp_2'        => 'iso-2022-jp-2',
    'iso_2022_jp_2'      => 'iso-2022-jp-2',

    # iso2022_jp_3 codec
    'iso2002_jp_3'       => 'iso-2022-jp-3',
    'iso2022jp_3'        => 'iso-2022-jp-3',
    'iso_2022_jp_3'      => 'iso-2022-jp-3',

    # iso2022_kr codec
    'iso2022_kr'         => 'iso-2022-kr',
    'csiso2022kr'        => 'iso-2022-kr',
    'iso2022kr'          => 'iso-2022-kr',
    'iso_2022_kr'        => 'iso-2022-kr',

    # iso8859_10 codec
    'iso8859_10'         => 'iso-8859-10',
    'csisolatin6'        => 'iso-8859-10',
    'iso_8859_10'        => 'iso-8859-10',
    'iso_8859_10_1992'   => 'iso-8859-10',
    'iso_ir_157'         => 'iso-8859-10',
    'l6'                 => 'iso-8859-10',
    'latin6'             => 'iso-8859-10',

    # iso8859_13 codec
    'iso8859_13'         => 'iso-8859-13',
    'iso_8859_13'        => 'iso-8859-13',

    # iso8859_14 codec
    'iso8859_14'         => 'iso-8859-14',
    'iso_8859_14'        => 'iso-8859-14',
    'iso_8859_14_1998'   => 'iso-8859-14',
    'iso_celtic'         => 'iso-8859-14',
    'iso_ir_199'         => 'iso-8859-14',
    'l8'                 => 'iso-8859-14',
    'latin8'             => 'iso-8859-14',

    # iso8859_15 codec
    'iso8859_15'         => 'iso-8859-15',
    'iso_8859_15'        => 'iso-8859-15',

    # iso8859_1 codec
    'latin_1'            => 'iso-8859-1',
    'cp819'              => 'iso-8859-1',
    'csisolatin1'        => 'iso-8859-1',
    'ibm819'             => 'iso-8859-1',
    'iso8859'            => 'iso-8859-1',
    'iso_8859_1'         => 'iso-8859-1',
    'iso_8859_1_1987'    => 'iso-8859-1',
    'iso_ir_100'         => 'iso-8859-1',
    'l1'                 => 'iso-8859-1',
    'latin'              => 'iso-8859-1',
    'latin1'             => 'iso-8859-1',

    # iso8859_2 codec
    'iso8859_2'          => 'iso-8859-2',
    'csisolatin2'        => 'iso-8859-2',
    'iso_8859_2'         => 'iso-8859-2',
    'iso_8859_2_1987'    => 'iso-8859-2',
    'iso_ir_101'         => 'iso-8859-2',
    'l2'                 => 'iso-8859-2',
    'latin2'             => 'iso-8859-2',

    # iso8859_3 codec
    'iso8859_3'          => 'iso-8859-3',
    'csisolatin3'        => 'iso-8859-3',
    'iso_8859_3'         => 'iso-8859-3',
    'iso_8859_3_1988'    => 'iso-8859-3',
    'iso_ir_109'         => 'iso-8859-3',
    'l3'                 => 'iso-8859-3',
    'latin3'             => 'iso-8859-3',

    # iso8859_4 codec
    'iso8849_4'          => 'iso-8859-4',
    'csisolatin4'        => 'iso-8859-4',
    'iso_8859_4'         => 'iso-8859-4',
    'iso_8859_4_1988'    => 'iso-8859-4',
    'iso_ir_110'         => 'iso-8859-4',
    'l4'                 => 'iso-8859-4',
    'latin4'             => 'iso-8859-4',

    # iso8859_5 codec
    'iso8859_5'          => 'iso-8859-5',
    'csisolatincyrillic' => 'iso-8859-5',
    'cyrillic'           => 'iso-8859-5',
    'iso_8859_5'         => 'iso-8859-5',
    'iso_8859_5_1988'    => 'iso-8859-5',
    'iso_ir_144'         => 'iso-8859-5',

    # iso8859_6 codec
    'iso8859_6'          => 'iso-8859-6',
    'arabic'             => 'iso-8859-6',
    'asmo_708'           => 'iso-8859-6',
    'csisolatinarabic'   => 'iso-8859-6',
    'ecma_114'           => 'iso-8859-6',
    'iso_8859_6'         => 'iso-8859-6',
    'iso_8859_6_1987'    => 'iso-8859-6',
    'iso_ir_127'         => 'iso-8859-6',

    # iso8859_7 codec
    'iso8859_7'          => 'iso-8859-7',
    'csisolatingreek'    => 'iso-8859-7',
    'ecma_118'           => 'iso-8859-7',
    'elot_928'           => 'iso-8859-7',
    'greek'              => 'iso-8859-7',
    'greek8'             => 'iso-8859-7',
    'iso_8859_7'         => 'iso-8859-7',
    'iso_8859_7_1987'    => 'iso-8859-7',
    'iso_ir_126'         => 'iso-8859-7',

    # iso8859_8 codec
    'iso8859_9'          => 'iso8859_8',
    'csisolatinhebrew'   => 'iso-8859-8',
    'hebrew'             => 'iso-8859-8',
    'iso_8859_8'         => 'iso-8859-8',
    'iso_8859_8_1988'    => 'iso-8859-8',
    'iso_ir_138'         => 'iso-8859-8',

    # iso8859_9 codec
    'iso8859_9'          => 'iso-8859-9',
    'csisolatin5'        => 'iso-8859-9',
    'iso_8859_9'         => 'iso-8859-9',
    'iso_8859_9_1989'    => 'iso-8859-9',
    'iso_ir_148'         => 'iso-8859-9',
    'l5'                 => 'iso-8859-9',
    'latin5'             => 'iso-8859-9',

    # iso8859_11 codec
    'iso8859_11'         => 'iso-8859-11',
    'thai'               => 'iso-8859-11',
    'iso_8859_11'        => 'iso-8859-11',
    'iso_8859_11_2001'   => 'iso-8859-11',

    # iso8859_16 codec
    'iso8859_16'         => 'iso-8859-16',
    'iso_8859_16'        => 'iso-8859-16',
    'iso_8859_16_2001'   => 'iso-8859-16',
    'iso_ir_226'         => 'iso-8859-16',
    'l10'                => 'iso-8859-16',
    'latin10'            => 'iso-8859-16',

    # cskoi8r codec 
    'koi8_r'             => 'cskoi8r',

    # mac_cyrillic codec
    'mac_cyrillic'       => 'maccyrillic',

    # shift_jis codec
    'csshiftjis'         => 'shift_jis',
    'shiftjis'           => 'shift_jis',
    'sjis'               => 'shift_jis',
    's_jis'              => 'shift_jis',

    # shift_jisx0213 codec
    'shiftjisx0213'      => 'shift_jisx0213',
    'sjisx0213'          => 'shift_jisx0213',
    's_jisx0213'         => 'shift_jisx0213',

    # utf_16 codec
    'utf_16'             => 'utf-16',
    'u16'                => 'utf-16',
    'utf16'              => 'utf-16',

    # utf_16_be codec
    'utf_16_be'          => 'utf-16be',
    'unicodebigunmarked' => 'utf-16be',
    'utf_16be'           => 'utf-16be',

    # utf_16_le codec
    'utf_16_le'          => 'utf-16le',
    'unicodelittleunmarked' => 'utf-16le',
    'utf_16le'           => 'utf-16le',

    # utf_7 codec
    'utf_7'              => 'utf-7',
    'u7'                 => 'utf-7',
    'utf7'               => 'utf-7',

    # utf_8 codec
    'utf_8'              => 'utf-8',
    'u8'                 => 'utf-8',
    'utf'                => 'utf-8',
    'utf8'               => 'utf-8',
    'utf8_ucs2'          => 'utf-8',
    'utf8_ucs4'          => 'utf-8',
  }
end
