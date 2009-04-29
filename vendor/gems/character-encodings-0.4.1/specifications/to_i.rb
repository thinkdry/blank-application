# contents: Specification of String#to_i.
#
# Copyright © 2006 Nikolai Weibull <now@bitwi.se>

require 'encoding/character/utf-8'

context "An empty string" do
  setup do
    @string = u""
  end

  specify "should raise an ArgumentError when sent #to_i with an illegal base" do
    [-2, -1, 0, 1, 37, 38].each{ |base| proc{ @string.to_i(1) }.should_raise ArgumentError }
  end

  specify "should return 0 when sent #to_i, using any legal base" do
    @string.to_i.should_equal 0
    2.upto(36){ |base| @string.to_i(base).should_equal 0 }
  end
end

context "The string “1”" do
  setup do
    @string = u"1"
  end

  specify "should return 1 when sent #to_i, using any legal base" do
    @string.to_i.should_equal 1
    2.upto(36){ |base| @string.to_i(base).should_equal 1 }
  end
end

context "The string “٠”" do
  setup do
    @string = u"١"
  end

  specify "should return 1 when sent #to_i, using any legal base" do
    @string.to_i.should_equal 1
    2.upto(36){ |base| @string.to_i(base).should_equal 1 }
  end
end

=begin
context "The string “ⅷ”" do
  setup do
    @string = u"ⅷ"
  end

  specify "should return 8 when sent #to_i, using base 10" do
    @string.to_i.should_equal 8
  end
end
=end
