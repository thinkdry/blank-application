# contents: Tests for String#upcase and String#downcase.
#
# Copyright © 2006 Nikolai Weibull <now@bitwi.se>

require 'tests/unicodedatatestbase'
require 'encoding/character/utf-8'

class TC_StringCase < Test::Unit::TestCase
  include UnicodeDataTestBase

  Code, Name, Category, _, _, _, _, _, _, _, _, _, Upper, Lower, Title = (0..14).to_a
  CasingCode, CasingLower, CasingTitle, CasingUpper, CasingCondition = (0..4).to_a

  def test_upcase_and_downcase
    # TODO: Do it like this.  First read in SpecialCasing.txt and set up lookup
    # tables for all the characters that need special casing.  Then, iterate
    # over UnicodeData and simply check that the correct casings are performed,
    # looking up data in the tables for special casing if no simple casing
    # information is available (and skipping when appropriate - such as when
    # there is some condition defined for the special casing).
    special = Struct.new(:conditions, :upper, :lower, :title).new({}, [], [], [])
    open_data_file('SpecialCasing.txt') do |file|
      i = 0
      file.each_line do |line|
        i += 1
        next if line =~ /^(#|\s*$)/
        fields = line.sub(/\s*#.*$/, "").split('; ')
        unless fields.size == 4 or fields.size == 5
          raise "#{line}: Wrong number of fields; #{field.size} instead of 4 or 5."
        end
        code = fields[CasingCode].hex
        special.conditions[code] = fields[CasingCondition] if fields.size == 5
        special.upper[code] = utfify(fields[CasingUpper])
        special.lower[code] = utfify(fields[CasingLower])
        special.title[code] = utfify(fields[CasingTitle])
      end
    end

    open_data_file('UnicodeData.txt') do |file|
      i = 0
      prev_code = -1
      file.each_line do |line|
        i += 1
        next if line =~ /^(#|\s*$)/
        fields = line.split(';')
        raise "#{line}: Wrong number of fields; #{field.size} instead of 15." unless fields.size == 15
        code = fields[Code].hex
        if code > prev_code + 1 and fields[Name] =~ /Last>$/ and fields[Category] =~ /^L[lut]$/
          prev_code.upto(code - 1){ |c| test_one c, fields, special }
        end
        test_one code, fields, special
        prev_code = code
      end
    end
    puts @i
  end

private

  def utfify(codepoints)
    return codepoints if codepoints == ""
    codepoints.split(' ').map{ |cp| cp.hex }.pack('U*')
  end

  def utfone(codepoint)
    u([codepoint].pack('U*'))
  end

  def test_one(code, fields, special)
    @i ||= 0
    @i += 1
    case fields[Category]
    when 'Ll'
      test_upcase(code, fields, special)
    when 'Lu'
      test_downcase(code, fields, special)
    when 'Lt'
      test_upcase(code, fields, special)
      test_downcase(code, fields, special)
    end
  end

  def test_upcase(code, fields, special)
    if special.upper[code]
      if not special.conditions[code]
        assert_equal(special.upper[code], utfone(code).upcase)
      end
    elsif not fields[Upper].empty?
      assert_equal(utfify(fields[Upper]), utfone(code).upcase)
    end
  end

  def test_downcase(code, fields, special)
    if special.lower[code]
      if not special.conditions[code]
        assert_equal(special.lower[code], utfone(code).downcase)
      end
    elsif not fields[Lower].empty?
      assert_equal(utfify(fields[Lower]), utfone(code).downcase)
    end
  end
end
