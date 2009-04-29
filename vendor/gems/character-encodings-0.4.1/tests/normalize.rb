# contents: Tests for String#normalize.
#
# Copyright © 2006 Nikolai Weibull <now@bitwi.se>

require 'ostruct'
require 'tests/unicodedatatestbase'
require 'encoding/character/utf-8'

class TC_StringUnicodeNormalize < Test::Unit::TestCase
  include UnicodeDataTestBase

  Data = OpenStruct.new
  Data.wanted_line = ENV['line'] ? ENV['line'].to_i : 0
  Data.line = 0

  def test_part_0
    Data.file = open_data_file('NormalizationTest.txt')
    read_lines_until(/^@Part0/)
    read_lines_until(/^@Part1/){ |columns| test_columns(columns) }
  end

  def test_part_1
    read_lines_until(/^@Part2/){ |columns| test_columns(columns) }
  end

  def test_part_2
    read_lines_until(/^@Part3/){ |columns| test_columns(columns) }
  end

  def test_part_3
    read_lines_until(:last){ |columns| test_columns(columns) }
    Data.file.close
  end

private

  def read_lines_until(line = :last, &block)
    if line == :last
      until Data.file.eof?
        deal_with_line(Data.file.gets, &block)
      end
    else
      while (got_line = Data.file.gets) !~ line
        raise "unexpected end of file while looking for #{line}" unless got_line
        deal_with_line(got_line, &block)
      end
      Data.line += 1
    end
  end

  def deal_with_line(line)
    Data.line += 1
    return if line[0] == ?#
    columns = line.split(';', 6)
    return if columns.length == 0
    raise "#{Data.file}:#{Data.line}: Format of line does not conform to standard" unless columns.length == 6
    return if Data.wanted_line != 0 and Data.line != Data.wanted_line
    yield columns if block_given?
  end

  def encode(string)
    string.unpack('U*').map{ |c| '%04X' % c }.join(' ')
  end

  def test_columns(columns)
    catch :skip do
      strings = columns[0..4].map do |c|
        s = u(c.split(' ').map{ |i| i.to_i(16) }.pack("U*"));
        throw :skip if s.empty?
        s
      end
      [ [:nfd, false, 2], [:nfd, true, 4],
        [:nfc, false, 1], [:nfc, true, 3],
        [:nfkd, true, 4],
        [:nfkc, true, 3] ].each do |mode, compat, expected|
        test_normalization(columns, strings, mode, compat, expected)
      end
    end
  end

  def test_normalization(columns, strings, mode, compat, expected)
    mode_is_compat = (mode == :nfkc || mode == :nfkd)
    if mode_is_compat || !compat
      0.upto(2){ |i| test_one_normalization(columns, strings, mode, compat, expected, i, i + 1) }
    end
    if mode_is_compat || compat
      3.upto(4){ |i| test_one_normalization(columns, strings, mode, compat, expected, i, i) }
    end
  end

  def test_one_normalization(columns, strings, mode, compat, expected, column, file_column)
    normalized = strings[column].normalize(mode)
    unless normalized.eql? strings[expected]
      m = mode.to_s.upcase
      flunk <<EOM
#{Data.line}:#{file_column}: #{m} normalization failed for #{columns[5].chomp.sub(/\s+#\s+\([^)]+\) /, "")}.
      #{m}(#{columns[column]}) = #{columns[expected]}, not #{encode(normalized)} (#{normalized.inspect}).
EOM
    end
  end
end
