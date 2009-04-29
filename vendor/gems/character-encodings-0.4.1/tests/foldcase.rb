# contents: Tests for String#foldcase.
#
# Copyright © 2006 Nikolai Weibull <now@bitwi.se>

require 'tests/unicodedatatestbase'
require 'encoding/character/utf-8'

class TC_StringFoldcase < Test::Unit::TestCase
  include UnicodeDataTestBase

  Code, Status, Mapping = (0..2).to_a

  def test_foldcase
    open_data_file('CaseFolding.txt') do |file|
      i = 0
      file.each_line do |line|
        i += 1
        next if line =~ /^#/
        next if line =~ /^\s*$/
        fields = line.split('; ')
        raise "#{line}: Wrong number of fields; #{field.size} instead of 4." unless fields.size == 4
        next if fields[Status] == 'S' || fields[Status] == 'T'
        numbers = fields[Mapping].split(' ').map{ |s| s.hex }
        assert_equal(numbers.pack('U*'), u([fields[Code].hex].pack('U')).foldcase)
      end
    end
  end
end
