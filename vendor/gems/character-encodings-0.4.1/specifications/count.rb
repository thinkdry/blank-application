# contents: Tests for String#count method.
#
# Copyright © 2006 Nikolai Weibull <now@bitwi.se>

require 'encoding/character/utf-8'

context "An empty string" do
  setup do
    @string = u""
  end

  specify "should return a count of zero" do
    @string.count("whatever").should_be 0
  end
end

context "A string containing one ‘l’" do
  setup do
    @string = u"helo"
  end

  specify "should return a count of one “l”’s given an “l”" do
    @string.count("l").should_be 1
  end

  specify "should return a count of one “l”’s given any input" do
    @string.count("helo", "wrld").should_be 1
  end
end
