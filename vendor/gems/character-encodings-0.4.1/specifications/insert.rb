# contents: Specification of String#insert.
#
# Copyright © 2006 Nikolai Weibull <now@bitwi.se>

require 'encoding/character/utf-8'

context "An empty string" do
  setup do
    @string = u""
  end

  specify "should be empty after insertion of an empty string at index 0" do
    @string.insert(0, "")
    @string.should_be_empty
  end

  specify "should raise an IndexError if inserting anything beyond index 0" do
    proc{ @string.insert(1, "") }.should_raise IndexError
  end

  specify "should be non-empty after insertion of any non-empty string" do
    @string.insert(0, "a")
    @string.should_not_be_empty
  end

  specify "should be equal to the string inserted" do
    string_to_insert = "äbc"
    @string.insert(0, string_to_insert)
    @string.should_equal string_to_insert
  end
end

context "The string “hëö”" do
  setup do
    @string = u"hëö"
  end

  specify "should equal the string “hëllö” after inserting “ll” at index 2" do
    @string.insert(2, "ll")
    @string.should_equal "hëllö"
  end

  specify "should equal the string “hëöll” after inserting “ll” at index -2" do
    @string.insert(-2, "ll")
    @string.should_equal "hëllö"
  end

  specify "should equal the string “hëöll” after inserting “ll” at index 3" do
    @string.insert(3, "ll")
    @string.should_equal "hëöll"
  end

  specify "should equal the string “hëöll” after inserting “ll” at index -1" do
    @string.insert(-1, "ll")
    @string.should_equal "hëöll"
  end

  specify "should equal the string “llhëö” after inserting “ll” at index 0" do
    @string.insert(0, "ll")
    @string.should_equal "llhëö"
  end

  specify "should equal the string “llhëö” after inserting “ll” at index -4" do
    @string.insert(0, "ll")
    @string.should_equal "llhëö"
  end
end
