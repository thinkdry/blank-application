# contents: Specification of String#squeeze.
#
# Copyright © 2006 Nikolai Weibull <now@bitwi.se>

require 'encoding/character/utf-8'

context "An empty string" do
  setup do
    @string = u""
  end

  specify "should return an empty string after squeezing anything" do
    @string.delete("whatever").should_be_empty
  end
end

context "The string “hëllö”" do
  setup do
    @string = u"hëllö"
  end

  specify "should return “hëlö” after squeezing all ‘ö’’s" do
    @string.squeeze.should_equal "hëlö"
  end
end
