#! /usr/bin/ruby -w
=begin
  :contents: Generate Unicode table headers.
  :arch-tag: 98c7456d-c7d9-4b40-9971-409428593ad5

  Copyright (C) 2004 Nikolai Weibull <source@pcppopper.org>

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.
  
  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.
  
  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
=end



def error(fmt, *args)
  $stderr.printf("%s: %s\n", File.basename($0), sprintf(fmt, *args))
  exit(1)
end

class File
  def self.process(path)
    begin
      File.open(path) do |file|
	file.each_line do |line|
	  next if line =~ /^(#|\s*$)/
	  yield line
	end
      end
    rescue IOError => e
      error("I/O error while processing input:\n" +
	    "    file: %s\n" +
	    "    error: %s\n", path, e.message)
    end
  end
end

class String
  def escape
    self.unpack('H*')[0].gsub(/(.{2})/, '\\x\1')
  end

  def width
    self.gsub(/\t/, ' ' * 8).length
  end
end

class Array
  def verify_size(wanted, path, index)
    if !(wanted === self.size)
      error("entry doesn't contain the required %s fields:\n" +
	    "    file: %s\n" +
	    "    entry: %s\n" +
	    "    field count: %d\n",
	    wanted.to_s,
	    path,
	    (self.size > index) ? self[index] : 'N/A',
	    self.size)
    end
  end

  def verify_field(index, code, path, raw_code, type, ccase)
    if self[index].to_i(16) != code
      error("entry has type %s but UCD_%s(%s) != %s:\n" +
	    "    file: %s\n" +
	    "    entry: %s\n",
	    type, ccase, raw_code, raw_code, path, raw_code)
    end
  end
end

class Hash
  def enumerate_ordered
    n = 0
    self.keys.sort.each do |code|
      if self[code] == 1
	self.delete(code)
	next
      end
      self[code] = n
      n += 1
    end
    n
  end
end

# XXX: this is too memory consuming to keep like this.  We need to split it up
# like the perl script does in hashes and arrays.  Argh!
class UnicodeCodepoint
  def initialize(code)
    @code = code
    @type = @value = @lower = @upper = @cclass = @compat = nil
    @compositions = @decompositions = @break_props = nil
  end

  attr_accessor :code
  attr_accessor :type, :value, :lower, :upper, :cclass, :compat
  attr_accessor :compositions, :decompositions, :break_props
end

# XXX: cleanup
class CollectedData
  def initialize(dir = '.', indent = "\t")
    @dir = dir
    @indent = indent 
    @cps = []

    @excludes = nil

    @pages_before_e0000 = 0
    @last = 0x10ffff

    @type = []
    @value = []
    @title_to_lower = {}
    @title_to_upper = {}
    @cclass = []
    @decompose_compat = []
    @compositions = {}
    @decompositions = []

    @break_props = []

    @special_case_offsets = []
    @special_cases = []

    @casefold = []
    @casefold_longest = -1

    @bidimirror = []
  end

  attr :dir
  attr :indent
  attr :cps, true
  attr :excludes, true
  attr :pages_before_e0000, true
  attr :last
  attr_accessor :type, :value, :title_to_lower, :title_to_upper, :cclass,
    :decompose_compat, :compositions, :decompositions
  attr :break_props, true
  attr :special_case_offsets, true
  attr :special_cases, true
  attr :casefold, true
  attr :casefold_longest, true
  attr :bidimirror, true
end

class CompositionExclusions
  def process(data)
    data.excludes = Hash.new
    File.process(File.join(data.dir, 'CompositionExclusions.txt')) do |line|
      data.excludes[line.chomp.sub(/^\s*(.*?)\s*(#.*)?$/,'\1').to_i(16)] = true
    end
  end
end

class UnicodeData
  CODE, NAME, CATEGORY, COMBINING_CLASSES, BIDI_CATEGORY,
    DECOMPOSITION, DECIMAL_VALUE, DIGIT_VALUE, NUMERIC_VALUE, MIRRORED,
    OLD_NAME, COMMENT, UPPER, LOWER, TITLE = (0..14).to_a

  def process(data)
    prev_code = -1
    path = File.join(data.dir, 'UnicodeData.txt')
    File.process(path) do |line|
      fields = line.chomp.split(/;/, -1)
      fields.verify_size(15, path, CODE)
      code = fields[CODE].to_i(16)

      if code >= 0xe0000 and prev_code < 0xe0000
	data.pages_before_e0000 = (prev_code >> 8) + 1
      end

      if code > prev_code + 1
	process_gap(data,
		    prev_code + 1,
		    code - 1,
		    fields[NAME] =~ /Last>$/ ? fields : new_gap_fields)
      end
      process_one(data, code, fields)
      prev_code = code
    end
    process_gap(data, prev_code + 1, 0x10ffff, new_gap_fields)
  end

private

  def new_gap_fields
    ['', '', 'Cn', '0', '', '', '', '', '', '', '', '', '', '', '']
  end

  def process_gap(data, low, hi, fields)
    low.upto(hi) do |i|
      fields[CODE] = sprintf('%04x', i)
      process_one(data, i, fields)
    end
  end

  def process_one(data, code, fields)
#    puts(code.to_s)
#    data.cps[code] ||= UnicodeCodepoint.new(code)
    data.type[code] = fields[CATEGORY]

    # TODO: Why not process things like 'Nl'?
    case data.type[code]
    when 'Nd'
      data.value[code] = fields[DECIMAL_VALUE].to_i
    when 'Ll'
      data.value[code] = fields[UPPER].to_i(16)
    when 'Lu'
      data.value[code] = fields[LOWER].to_i(16)
    when 'Lt'
      data.title_to_lower[code] = fields[LOWER].to_i(16)
      data.title_to_upper[code] = fields[UPPER].to_i(16)
    end

    data.cclass[code] = fields[COMBINING_CLASSES]

    unless fields[DECOMPOSITION] == ''
      if fields[DECOMPOSITION] =~ /^\<.*\>\s*(.*)/
	data.decompose_compat[code] = true
	fields[DECOMPOSITION] = $1
      else
	data.decompose_compat[code] = false
	unless data.excludes.include?(code)
	  data.compositions[code] = fields[DECOMPOSITION]
	end
      end
      data.decompositions[code] = fields[DECOMPOSITION]
    end
  end
end

class LineBreak
  BREAK_CODE, BREAK_PROPERTY = (0..1).to_a

  def process(data)
    prev_code = -1
    path = File.join(data.dir, 'LineBreak.txt')
    File.process(path) do |line|
      fields = line.chomp.sub(/\s*#.*/, '').split(/;/, -1)
      fields.verify_size(2, path, BREAK_CODE)

      if fields[BREAK_CODE] =~ /([0-9A-F]{4,6})\.\.([0-9A-F]{4,6})/
	start_code, end_code = $1.to_i(16), $2.to_i(16)
      else
	start_code = end_code = fields[BREAK_CODE].to_i(16)
      end

      if start_code > prev_code + 1
	process_gap(data, prev_code + 1, start_code - 1)
      end

      start_code.upto(end_code) do |i|
	data.break_props[i] = fields[BREAK_PROPERTY]
      end

      prev_code = end_code
    end

    process_gap(data, prev_code + 1, 0x10ffff)
  end

private

  def process_gap(data, low, hi)
    low.upto(hi) do |i|
      data.break_props[i] = (data.type[i] == 'Cn') ? 'XX' : 'AL'
    end
  end
end

class SpecialCasing
  CASE_CODE, CASE_LOWER, CASE_TITLE, CASE_UPPER, CASE_CONDITION = (0..4).to_a

  def initialize
    @offset = 0
  end

  def process(data)
    path = File.join(data.dir, 'SpecialCasing.txt')
    File.process(path) do |line|
      fields = line.chomp.sub(/\s*#.*/, '').split(/\s*;\s*/, -1)
      fields.verify_size((5..6), path, CASE_CODE)
      raw_code, code = fields[CASE_CODE], fields[CASE_CODE].to_i(16)
      unless data.type[code].nil?
	# We ignore conditional special cases
	next if fields.size == 6

	case data.type[code]
	when 'Lu'
	  fields.verify_field(CASE_UPPER, code, path, raw_code, 'Lu', 'Upper')
	  add_special_case(data, code, data.value[code],
			   fields[CASE_LOWER], fields[CASE_TITLE])
	when 'Lt'
	  fields.verify_field(CASE_TITLE, code, path, raw_code, 'Lt', 'Title')
	  add_special_case(data, code, nil,
			   fields[CASE_LOWER], fields[CASE_UPPER])
	when 'Ll'
	  fields.verify_field(CASE_LOWER, code, path, raw_code, 'Ll', 'Lower')
	  add_special_case(data, code, data.value[code],
			   fields[CASE_UPPER], fields[CASE_TITLE])
	else
	  error("special case for non-alphabetic code point:\n" +
		"    file: %s\n" +
		"    type: %s\n" +
		"    code point/entry: %s\n",
		path, data.type[code], raw_code)
	end
      else
	error("special case for code point which doesn't have a type:\n" +
	      "    file: %s\n" +
	      "    code point/entry: %d\n",
	      path, code)
      end
    end
  end

private

  def add_special_case(data, code, single, field1, field2)
    values = [
      single.nil? ? nil : [single],
      field1.split(/\s+/).map{ |s| s.to_i(16) },
      [0],
      field2.split(/\s+/).map{ |s| s.to_i(16) },
    ]
    result = ''
    values.each{ |value| result += value.pack('U*') unless value.nil? }

    data.special_case_offsets.push(@offset)
    data.value[code] = 0x1000000 + @offset
    data.special_cases.push(result.escape)
    @offset += 1 + result.length
  end
end

class CaseFolding
  FOLDING_CODE, FOLDING_STATUS, FOLDING_MAPPING = (0..2).to_a

  def process(data)
    path = File.join(data.dir, 'CaseFolding.txt')
    File.process(path) do |line|
      fields = line.chomp.sub(/\s*#.*/, '').split(/\s*;\s*/, -1)
      fields.verify_size(4, path, FOLDING_CODE)

      # skip Simple and Turkic rules
      next if fields[FOLDING_STATUS] =~ /^[ST]$/

      raw_code, code = fields[FOLDING_CODE], fields[FOLDING_CODE].to_i(16)
      values = fields[FOLDING_MAPPING].split(/\s+/).map{ |s| s.to_i(16) }
      if values.size == 1 &&
	!(!data.value[code].nil? && data.value[code] >= 0x1000000) &&
	!data.type[code].nil?
	case data.type[code]
	when 'Ll'
	  lower = code
	when 'Lt'
	  lower = data.title_to_lower[code]
	when 'Lu'
	  lower = data.value[code]
	else
	  lower = code
	end
	next if lower == values[0]
      end

      string = values.pack('U*')
      if string.length + 1 > data.casefold_longest
	data.casefold_longest = string.length + 1
      end
      data.casefold.push([code, string.escape])
    end
  end
end

class BidiMirroring
  def process(data)
    path = File.join(data.dir, 'BidiMirroring.txt')
    File.process(path) do |line|
      fields = line.chomp.sub(/\s*#.*/, '').split(/\s*;\s*/, -1)
      fields.verify_size(2, path, 0)
      data.bidimirror.push([fields[0].to_i(16), fields[1].to_i(16)])
    end
  end
end

class Printer
  def initialize
    @index = 0
  end

  def process(data)
    @last_char_part1_i = data.pages_before_e0000 * 256 - 1
    @last_char_part1_x = sprintf('0x%04x', @last_char_part1_i)
    @last_char_part1_X = sprintf('%04X', @last_char_part1_i)
    print_tables(data)
    print_decomp(data)
    print_composition_table(data)
    print_line_break(data)
  end

private

  # Map general category code onto symbolic name.
  Mappings = {
    # Normative.
    'Lu' => 'UNICODE_UPPERCASE_LETTER',
    'Ll' => 'UNICODE_LOWERCASE_LETTER',
    'Lt' => 'UNICODE_TITLECASE_LETTER',
    'Mn' => 'UNICODE_NON_SPACING_MARK',
    'Mc' => 'UNICODE_COMBINING_MARK',
    'Me' => 'UNICODE_ENCLOSING_MARK',
    'Nd' => 'UNICODE_DECIMAL_NUMBER',
    'Nl' => 'UNICODE_LETTER_NUMBER',
    'No' => 'UNICODE_OTHER_NUMBER',
    'Zs' => 'UNICODE_SPACE_SEPARATOR',
    'Zl' => 'UNICODE_LINE_SEPARATOR',
    'Zp' => 'UNICODE_PARAGRAPH_SEPARATOR',
    'Cc' => 'UNICODE_CONTROL',
    'Cf' => 'UNICODE_FORMAT',
    'Cs' => 'UNICODE_SURROGATE',
    'Co' => 'UNICODE_PRIVATE_USE',
    'Cn' => 'UNICODE_UNASSIGNED',

    # Informative.
    'Lm' => 'UNICODE_MODIFIER_LETTER',
    'Lo' => 'UNICODE_OTHER_LETTER',
    'Pc' => 'UNICODE_CONNECT_PUNCTUATION',
    'Pd' => 'UNICODE_DASH_PUNCTUATION',
    'Ps' => 'UNICODE_OPEN_PUNCTUATION',
    'Pe' => 'UNICODE_CLOSE_PUNCTUATION',
    'Pi' => 'UNICODE_INITIAL_PUNCTUATION',
    'Pf' => 'UNICODE_FINAL_PUNCTUATION',
    'Po' => 'UNICODE_OTHER_PUNCTUATION',
    'Sm' => 'UNICODE_MATH_SYMBOL',
    'Sc' => 'UNICODE_CURRENCY_SYMBOL',
    'Sk' => 'UNICODE_MODIFIER_SYMBOL',
    'So' => 'UNICODE_OTHER_SYMBOL'
  }

  BreakMappings = {
    'BK' => 'UNICODE_BREAK_MANDATORY',
    'CR' => 'UNICODE_BREAK_CARRIAGE_RETURN',
    'LF' => 'UNICODE_BREAK_LINE_FEED',
    'CM' => 'UNICODE_BREAK_COMBINING_MARK',
    'SG' => 'UNICODE_BREAK_SURROGATE',
    'ZW' => 'UNICODE_BREAK_ZERO_WIDTH_SPACE',
    'IN' => 'UNICODE_BREAK_INSEPARABLE',
    'GL' => 'UNICODE_BREAK_NON_BREAKING_GLUE',
    'CB' => 'UNICODE_BREAK_CONTINGENT',
    'SP' => 'UNICODE_BREAK_SPACE',
    'BA' => 'UNICODE_BREAK_AFTER',
    'BB' => 'UNICODE_BREAK_BEFORE',
    'B2' => 'UNICODE_BREAK_BEFORE_AND_AFTER',
    'HY' => 'UNICODE_BREAK_HYPHEN',
    'NS' => 'UNICODE_BREAK_NON_STARTER',
    'OP' => 'UNICODE_BREAK_OPEN_PUNCTUATION',
    'CL' => 'UNICODE_BREAK_CLOSE_PUNCTUATION',
    'QU' => 'UNICODE_BREAK_QUOTATION',
    'EX' => 'UNICODE_BREAK_EXCLAMATION',
    'ID' => 'UNICODE_BREAK_IDEOGRAPHIC',
    'NU' => 'UNICODE_BREAK_NUMERIC',
    'IS' => 'UNICODE_BREAK_INFIX_SEPARATOR',
    'SY' => 'UNICODE_BREAK_SYMBOL',
    'AL' => 'UNICODE_BREAK_ALPHABETIC',
    'PR' => 'UNICODE_BREAK_PREFIX',
    'PO' => 'UNICODE_BREAK_POSTFIX',
    'SA' => 'UNICODE_BREAK_COMPLEX_CONTEXT',
    'AI' => 'UNICODE_BREAK_AMBIGUOUS',
    'NL' => 'UNICODE_BREAK_NEXT_LINE',
    'WJ' => 'UNICODE_BREAK_WORD_JOINER',
    'XX' => 'UNICODE_BREAK_UNKNOWN',
    'JL' => 'UNICODE_BREAK_HANGUL_L_JAMO',
    'JV' => "UNICODE_BREAK_HANGUL_V_JAMO",
    'JT' => "UNICODE_BREAK_HANGUL_T_JAMO",
    'H2' => "UNICODE_BREAK_HANGUL_LV_SYLLABLE",
    'H3' => "UNICODE_BREAK_HANGUL_LVT_SYLLABLE"
  };

  NOT_PRESENT_OFFSET = 65535

  def print_table(data, low, mid, hi, size, header, part1_h, part2_h, &f)
    @index = 0
    rows = []
    print(header)
    low.step(hi, 256) do |i|
      rows[i / 256] = print_row(data, i, size){ |i| f.call(i) }
    end
    print("\n};\n")
    print(part1_h)
    low.step(mid, 256) do |i|
      printf("%s%s,\n", data.indent, rows[i / 256])
    end
    print("};\n")
    if mid != hi
      print(part2_h)
      0xe0000.step(hi, 256) do |i|
	printf("%s%s,\n", data.indent, rows[i / 256])
      end
      print("};\n")
    end
  end

  def print_tables(data, outfile = 'character-tables.h')
    row = []
    saved_stdout = $stdout
    File.open(outfile, 'w') do |file|
      header_h = outfile.upcase.gsub(/[^A-Z0-9]/, '_')
      $stdout = file
      print <<EOF
/* Automatically generated file */

#ifndef #{header_h}
#define #{header_h}

#define UNICODE_DATA_VERSION "#{UnicodeVersion}"

#define UNICODE_LAST_CHAR #{sprintf('0x%04x', data.last)}

#define UNICODE_MAX_TABLE_INDEX 10000

#define UNICODE_LAST_CHAR_PART1 #{@last_char_part1_x}

#define UNICODE_LAST_PAGE_PART1 #{data.pages_before_e0000 - 1}

#define UNICODE_FIRST_CHAR_PART2 0xe0000

#define UNICODE_SPECIAL_CASE_TABLE_START 0x1000000
EOF
      print_table(data, 0, @last_char_part1_i, data.last, 1,
		  <<EOH, <<EOH1, <<EOH2){ |i| Mappings[data.type[i]] }


static const char type_data[][256] = {
EOH


/* U+0000 through U+#{@last_char_part1_X} */
static const int16_t type_table_part1[#{data.pages_before_e0000}] = {
EOH1


/* U+E0000 through U+#{sprintf('%04X', data.last)} */
static const int16_t type_table_part2[768] = {
EOH2

      print_table(data, 0, @last_char_part1_i, data.last, 4,
		  <<EOH, <<EOH1, <<EOH2) { |i| data.value[i].nil? ? '0x0000' : sprintf('0x%04x', data.value[i]) }


static const unichar attr_data[][256] = {
EOH


/* U+0000 through U+#{@last_char_part1_X} */
static const int16_t attr_table_part1[#{data.pages_before_e0000}] = {
EOH1


/* U+E0000 through U+#{sprintf('%04X', data.last)} */
static const int16_t attr_table_part2[768] = {
EOH2

      print <<EOF


static const unichar title_table[][3] = {
EOF
      data.title_to_lower.keys.sort.each do |code|
	printf("%s{ 0x%04x, 0x%04x, 0x%04x },\n", data.indent,
	       code, data.title_to_upper[code], data.title_to_lower[code])
      end
      print("};\n")

      print_special_case_table(data)
      print_case_fold_table(data)

      print <<EOF
static const struct {
#{data.indent}unichar ch;
#{data.indent}unichar mirrored_ch;
} bidi_mirroring_table[] = {
EOF
      data.bidimirror.each do |item|
	printf("%s{ 0x%04x, 0x%04x },\n", data.indent, item[0], item[1])
      end
      print <<EOF
};

#endif /* #{header_h} */
EOF
    end
    $stdout = saved_stdout
  end

  def print_row(data, start, type_size)
    flag = true
    values = []
    0.upto(255) do |i|
      values[i] = yield(start + i)
      flag = false if values[i] != values[0]
    end
    return values[0] + " + UNICODE_MAX_TABLE_INDEX" if flag

    puts(',') if @index != 0
    printf("%s{ /* page %d, index %d */\n%s",
	   data.indent, start / 256, @index, data.indent * 2)
    column = data.indent.width * 2
    start.upto(start + 255) do |i|
      text = values[i - start]
      if text.length + column + 2 > 79
	printf("\n%s", data.indent * 2)
	column = data.indent.width * 2
      end

      printf("%s, ", text)
      column += text.width + 2
    end

    print("\n#{data.indent}}")
    @index += 1
    return sprintf("%d /* page %d */", @index - 1, start / 256);
  end

  def print_special_case_table(data)
    print <<EOF


/*
 * Table of special cases for case conversion; each record contains
 * First, the best single character mapping to lowercase if Lu,
 * and to uppercase if Ll, followed by the output mapping for the two cases
 * other than the case of the codepoint, in the order Ll, Lu, Lt, encoded in
 * UTF-8, separated and terminated by a NUL character.
 */
static const char special_case_table[] = {
EOF
    data.special_cases.each_with_index do |sc, i|
      printf(%Q< "%s\\0" /* offset %d */\n>, sc, data.special_case_offsets[i])
    end
    print <<EOF
};

EOF
  end

  def print_case_fold_table(data)
    print <<EOF

/*
 * Table of casefolding cases that can't be derived by lowercasing.
 */
static const struct {
#{data.indent}uint16_t ch;
#{data.indent}char data[#{data.casefold_longest}];
} casefold_table[] = {
EOF
    data.casefold.sort_by{ |a| a[0] }.each do |cf|
      if cf[0] > 0xffff
	error('casefold_table.ch field too short.' +
	      '  Upgrade to unichar to fit values beyond 0xffff.')
      end
      printf(%Q<%s{ 0x%04x, "%s" },\n>, data.indent, cf[0], cf[1])
    end
    print <<EOF
};
EOF
  end

  def print_decomp(data, outfile = 'decompose.h')
    row = []
    saved_stdout = $stdout
    File.open(outfile, 'w') do |file|
      header_h = outfile.upcase.gsub(/[^A-Z0-9]/, '_')
      $stdout = file
      print <<EOF
/* Automatically generated file */

#ifndef #{header_h}
#define #{header_h}


#define UNICODE_LAST_CHAR #{sprintf('0x%04x', data.last)}

#define UNICODE_MAX_TABLE_INDEX (0x110000 / 256)

#define UNICODE_LAST_CHAR_PART1 #{@last_char_part1_x}

#define UNICODE_LAST_PAGE_PART1 #{data.pages_before_e0000 - 1}

#define UNICODE_FIRST_CHAR_PART2 0xe0000

#define UNICODE_NOT_PRESENT_OFFSET #{NOT_PRESENT_OFFSET}
EOF
      print_table(data, 0, @last_char_part1_i, data.last, 1,
		  <<EOH, <<EOH1, <<EOH2){ |i| data.cclass[i] }


static const uint8_t cclass_data[][256] = {
EOH


static const int16_t combining_class_table_part1[#{data.pages_before_e0000}] = {
EOH1


static const int16_t combining_class_table_part2[768] = {
EOH2

      print <<EOL


static const struct {
#{data.indent}unichar ch;
#{data.indent}uint16_t canon_offset;
#{data.indent}uint16_t compat_offset;
} decomp_table[] = {
EOL
      decomp_offsets = {}
      decomp_string = ''
      @decomp_string_offset = 0
      0.upto(data.last) do |i|
	unless data.decompositions[i].nil?
	  canon_decomp = data.decompose_compat[i] ?
	    nil : make_decomp(data, i, false)
	  compat_decomp = make_decomp(data, i, true)
	  if not canon_decomp.nil? and compat_decomp == canon_decomp
	    compat_decomp = nil
	  end
	  canon_offset = handle_decomp(canon_decomp, decomp_offsets,
				       decomp_string)
	  compat_offset = handle_decomp(compat_decomp, decomp_offsets,
					decomp_string)

	  if @decomp_string_offset > NOT_PRESENT_OFFSET
	    error('decomposition string offset beyond not-present-offset,' +
		  " upgrade value:\n" +
		  "    offset: %d\n" +
		  "    max: %d\n",
		  @decomp_string_offset, NOT_PRESENT_OFFSET)
	  end
	  printf("%s{ 0x%04x, %s, %s },\n",
		 data.indent, i, canon_offset, compat_offset)
	end
      end
      print("\n};")

      print <<EOL

static const char decomp_expansion_string[] = #{decomp_string};


#endif /* #{header_h} */
EOL
    end
    $stdout = saved_stdout
  end

  def expand_decomp(data, code, compat)
    ary = []
    data.decompositions[code].split(/ /).each do |item|
      pos = item.to_i(16)
      if not data.decompositions[pos].nil? and
	(compat or not data.decompose_compat[pos])
	ary.concat(expand_decomp(data, pos, compat))
      else
	ary.push(pos)
      end
    end
    ary
  end

  def make_decomp(data, code, compat)
    str = ''
    expand_decomp(data, code, compat).each do |item|
      str += item.is_a?(Array) ? item.flatten.pack('U') : [item].pack('U')
    end
    str
  end

  def handle_decomp(decomp, decomp_offsets,
		    decomp_string)
    offset = 'UNICODE_NOT_PRESENT_OFFSET'
    unless decomp.nil?
      if decomp_offsets.member?(decomp)
	offset = decomp_offsets[decomp]
      else
	offset = @decomp_string_offset
	decomp_offsets[decomp] = offset
	decomp_string << ("\n  \"" + decomp.escape +
			  "\\0\" /* offset #{offset} */")
	@decomp_string_offset += decomp.length + 1
      end
    end
    offset
  end

  def print_composition_table(data, outfile = 'compose.h')
    first = Hash.new(0)
    second = Hash.new(0)

    data.compositions.each do |code, value|
      values = value.split(/\s+/).map{ |s| s.to_i(16) }

      # skip non-starters and single-character decompositions
      if data.cclass[values[0]] != '0' or values.size == 1
	data.compositions.delete(code)
	next
      end

      if values.size != 2
	error("decomposition of entry contains more than two elements:\n" +
	      "    entry: %d\n" +
	      "    elements: %d\n",
	      code, values.size)
      end

      first[values[0]] += 1
    end
    
    n_first = first.enumerate_ordered

    data.compositions.each do |code, value|
      values = value.split(/\s+/).map{ |s| s.to_i(16) }

      second[values[1]] += 1 if first.member?(values[0])
    end

    n_second = second.enumerate_ordered

    first_singletons = []
    second_singletons = []
    reverse = {}
    data.compositions.each do |code, value|
      values = value.split(/\s+/).map{ |s| s.to_i(16) }

      if first.member?(values[0]) and second.member?(values[1])
	reverse["#{first[values[0]]}|#{second[values[1]]}"] = code
      elsif not first.member?(values[0])
	first_singletons.push([values[0], values[1], code])
      else
	second_singletons.push([values[1], values[0], code])
      end
    end

    first_singletons = first_singletons.sort_by{ |a| a[0] }
    second_singletons = second_singletons.sort_by{ |a| a[0] }

    row = []
    saved_stdout = $stdout
    File.open(outfile, 'w') do |file|
      header_h = outfile.upcase.gsub(/[^A-Z0-9]/, '_')
      $stdout = file
      values = {}
      total = first_start = 1
      last = 0

      first.each do |code, value|
	values[code] = value + total
	last = code if code > last
      end
      total += n_first

      first_single_start = total
      first_singletons.each_with_index do |item, i|
	code = item[0]
	values[code] = i + total
	last = code if code > last
      end
      total += first_singletons.size

      second_start = total
      second.each do |code, value|
	values[code] = value + total
	last = code if code > last
      end
      total += n_second

      second_single_start = total
      second_singletons.each_with_index do |item, i|
	code = item[0]
	values[code] = i + total
	last = code if code > last
      end

      print <<EOL
/* Automatically generated file */

#ifndef #{header_h}
#define #{header_h}


#define COMPOSE_FIRST_START #{first_start}
#define COMPOSE_FIRST_SINGLE_START #{first_single_start}
#define COMPOSE_SECOND_START #{second_start}
#define COMPOSE_SECOND_SINGLE_START #{second_single_start}
#define COMPOSE_TABLE_LAST #{last / 256}
EOL

      print_table(data, 0, last, last, 2,
		  <<EOH, <<EOH1, nil){ |i| values.member?(i) ? values[i].to_s : '0' }


static const uint16_t compose_data[][256] = {
EOH


static const int16_t compose_table[COMPOSE_TABLE_LAST + 1] = {
EOH1

      print <<EOL


static const uint16_t compose_first_single[][2] = {
EOL
      first_singletons.each_with_index do |item, i|
	if item[1] > 0xffff or item[2] > 0xffff
	  error("compose_first_single table field too short." +
		"  Upgrade to unichar to fit values beyond 0xffff.")
	end
	printf("%s{ %#06x, %#06x },\n", data.indent, item[1], item[2])
      end
      print("};\n")

      print <<EOL


static const uint16_t compose_second_single[][2] = {
EOL
      second_singletons.each_with_index do |item, i|
	if item[1] > 0xffff or item[2] > 0xffff
	  error("compose_second_single table field too short." +
		"  Upgrade to unichar to fit values beyond 0xffff.")
	end
	printf("%s{ %#06x, %#06x },\n", data.indent, item[1], item[2])
      end
      print("};\n")

      print <<EOL


static const uint16_t compose_array[#{n_first}][#{n_second}] = {
EOL
      0.upto(n_first - 1) do |i|
	printf("%s{\n%s", data.indent, data.indent * 2)
	column = data.indent.width * 2
	0.upto(n_second - 1) do |j|
	  if column + 8 > 79
	    printf("\n%s", data.indent * 2)
	    column = data.indent.width * 2
	  end
	  if reverse.member?("#{i}|#{j}")
	    if reverse["#{i}|#{j}"] > 0xffff
	      error("compose_array table field too short." +
		    "  Upgrade to unichar to fit values beyond 0xffff.")
	    end
	    printf("0x%04x, ", reverse["#{i}|#{j}"])
	  else
	    print("     0, ")
	  end
	  column += 8
	end
	printf("\n%s},\n", data.indent)
      end
      print("};\n")

      print <<EOL


#endif /* #{header_h} */
EOL
    end
    $stdout = saved_stdout
  end

  def print_line_break(data, outfile = 'break.h')
    row = []
    saved_stdout = $stdout
    File.open(outfile, 'w') do |file|
      header_h = outfile.upcase.gsub(/[^A-Z0-9]/, '_')
      $stdout = file
      print <<EOF
/* Automatically generated file */

#ifndef #{header_h}
#define #{header_h}

#define UNICODE_DATA_VERSION "#{UnicodeVersion}"

#define UNICODE_LAST_CHAR #{sprintf('0x%04x', data.last)}

#define UNICODE_MAX_TABLE_INDEX 10000

/*
 * The last code point that should be looked up in break_property_table_part1.
 */
#define UNICODE_LAST_CHAR_PART1 #{@last_char_part1_x}

/*
 * The first code point that should be looked up in break_property_table_part2.
 */
#define UNICODE_FIRST_CHAR_PART2 0xe0000
EOF
      print_table(data, 0, @last_char_part1_i, data.last, 1,
		  <<EOH, <<EOH1, <<EOH2){ |i| BreakMappings[data.break_props[i]] }


static const int8_t break_property_data[][256] = {
EOH


/* U+0000 through U+#{@last_char_part1_X} */
static const int16_t break_property_table_part1[#{data.pages_before_e0000}] = {
EOH1


/* U+E0000 through U+#{sprintf('%04X', data.last)} */
static const int16_t break_property_table_part2[768] = {
EOH2

      print <<EOF


#endif /* #{header_h} */
EOF
    end
    $stdout = saved_stdout
  end
end

UnicodeVersion = ARGV[0]

class Runner
  def main
    check_for_data_files(ARGV[1])
    data = CollectedData.new(ARGV[1], "\t")
    [CompositionExclusions, UnicodeData, LineBreak,
      SpecialCasing, CaseFolding, BidiMirroring, Printer].each do |klass|
      klass.new.process(data)
    end
  end

private
  def check_for_data_files(dir)
    ['UnicodeData.txt', 'LineBreak.txt', 'SpecialCasing.txt', 'CaseFolding.txt',
      'CompositionExclusions.txt', 'BidiMirroring.txt'].each do |file|
      path = File.join(dir, file)
      unless File.readable?(path)
	error('missing required file: %s', path)
      end
    end
  end
end

Runner.new.main



# vim: set sts=2 sw=2:
