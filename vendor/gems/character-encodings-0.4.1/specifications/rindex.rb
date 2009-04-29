# contents: Specification of String#rindex.
#
# Copyright © 2006 Nikolai Weibull <now@bitwi.se>

require 'encoding/character/utf-8'

context "An empty string" do
  setup do
    @string = u""
  end

  specify "should contain the empty string at index 0" do
    @string.rindex("").should_equal 0
  end

=begin
  specify "shouldn’t contain any string at an index > 0" do
    @string.rindex("", 1).should_be nil
    @string.rindex("", -1).should_be nil
  end
=end
end

context "The string “hëllö”" do
  setup do
    @string = u"hëllö"
  end

  specify "should contain the string “lö” at index 3" do
    @string.rindex("lö").should_equal 3
    @string.rindex("lö", 3).should_equal 3
  end

  specify "should contain the string “hë” at index 0" do
    @string.rindex("hë").should_equal 0
  end
end

context "The string “hëllölö”" do
  setup do
    @string = u"hëllölö"
  end

  specify "should contain the string “lö” at index 5" do
    @string.rindex("lö").should_equal 5
    @string.rindex("lö", 5).should_equal 5
  end

  specify "should contain the string “lö” at index 3, when starting at index 4" do
    @string.rindex("lö", 4).should_equal 3
  end
end
