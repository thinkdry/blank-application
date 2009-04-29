# contents: Specification of String#tr.
#
# Copyright © 2006 Nikolai Weibull <now@bitwi.se>

require 'encoding/character/utf-8'

context "An empty string" do
  setup do
    @string = u""
  end

  specify "should stay the same for any translation" do
    @string.tr("abc", "def").should_be_empty
  end
end

context "The string “äbcdë”" do
  setup do
    @string = u"äbcdë"
  end

  specify "should return the string “abcde” when ‘ä’ and ‘ë’ are translated to ‘a’ and ‘e’" do
    @string.tr("äë", "ae").should_equal "abcde"
  end

  specify "should return the string “ëëëëë” when “a-zäë” are translated to ‘ë’" do
    @string.tr("a-zäë", "ë").should_equal "ëëëëë"
  end
end

context "The string “aaaaa”" do
  setup do
    @string = u"aaaaa"
  end

  specify "should return the string “ëëëëë” when “a” is translated to ‘ä-ë’" do
    @string.tr("a", "ä-ë").should_equal "ëëëëë"
  end
end
