# contents: Specification for String#each_char.
#
# Copyright © 2006 Nikolai Weibull <now@bitwi.se>

require 'encoding/character/utf-8'

context "An empty string" do
  setup do
    @string = u""
  end

  specify "shouldn’t yield any characters" do
    i = 0
    @string.each_char{ |c| i += 1 }
    i.should_be 0
  end
end

context "The string “hëllö”" do
  setup do
    @string = u"hëllö"
  end

  specify "should yield five characters" do
    characters = ['h', 'ë', 'l', 'l', 'ö']
    @string.each_char{ |c| c.should_equal characters.shift }
  end
end
