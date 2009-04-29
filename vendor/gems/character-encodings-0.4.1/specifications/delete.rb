# contents: Specification for String#delete.
#
# Copyright © 2006 Nikolai Weibull <now@bitwi.se>

require 'encoding/character/utf-8'

context "An empty string" do
  setup do
    @string = u""
  end

  specify "should return an empty string after deleting anything" do
    @string.delete("whatever").should_be_empty
  end
end

context "The string “hëllö”" do
  setup do
    @string = u"hëllö"
  end

  specify "should return “hëll” after deleting all ‘ö’’s" do
    @string.delete("ö").should_equal "hëll"
  end
end
