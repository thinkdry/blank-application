# contents: Specification of String#[].
#
# Copyright © 2006 Nikolai Weibull <now@bitwi.se>

require 'encoding/character/utf-8'

context "An empty string" do
  setup do
    @string = u""
  end

  specify "should return nil when sent #\\[\\], given an index of 0 and a negative length" do
    [-10, -2, -1].each do |length|
      @string[0, length].should_be nil
    end
  end

  specify "should contain the empty string at index 0, given any non-negative length" do
    [0, 1, 2, 10].each do |length|
      @string[0, length].should_equal ""
    end
  end

  specify "should return nil when sent #\\[\\], given any non-zero index and any length" do
    [-10, -2, -1, 1, 2, 10].each do |index|
      [-10, -2, -1, 0, 1, 2, 10].each do |length|
        @string[index, length].should_be nil
      end
    end
  end
end

context "The string “hëllö”" do
  setup do
    @string = u"hëllö"
  end

  specify "should contain the string “lö” at index 3" do
    @string[3, 2].should_equal "lö"
  end

  specify "should contain the string “hë” at index 0" do
    @string[0, 2].should_equal "hë"
  end
end
