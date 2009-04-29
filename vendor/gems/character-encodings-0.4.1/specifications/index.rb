# contents: Specification of String#index.
#
# Copyright © 2006 Nikolai Weibull <now@bitwi.se>

require 'encoding/character/utf-8'

context "An empty string" do
  setup do
    @string = u""
  end

  specify "should contain the empty string at index 0" do
    @string.index("").should_equal 0
  end

  specify "shouldn’t contain any string at an index > 0" do
    @string.index("", 1).should_be nil
    @string.index("", -1).should_be nil
  end
end

context "The string “hëllö”" do
  setup do
    @string = u"hëllö"
  end

  specify "should contain the string “lö” at index 3" do
    @string.index("lö").should_equal 3
    @string.index("lö", 3).should_equal 3
  end

  specify "should contain the string “hë” at index 0" do
    @string.index("hë").should_equal 0
  end
end
