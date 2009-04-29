# contents: String#length specification.
#
# Copyright © 2006 Nikolai Weibull <now@bitwi.se>

require 'encoding/character/utf-8'

context "An empty string" do
  setup do
    @string = u""
  end

  specify "should return 0 when sent #length" do
    @string.length.should_equal 0
  end
end

context "The string “hëllö”" do
  setup do
    @string = u"hëllö"
  end

  specify "should return 5 when sent #length" do
    @string.length.should_equal 5
  end
end

context "The string “hëllö\0agäin” with an embedded NUL-byte" do
  setup do
    @string = u"hëllö\0agäin"
  end

  specify "should return 11 when sent #length" do
    @string.length.should_equal 11
  end
end

context "The string “hëllö\0agäin” with a partial character at the end" do
  setup do
    @string = u"hëllö\0agäin\303"
  end

  specify "should return 11 when sent #length" do
    @string.length.should_equal 11
  end
end
