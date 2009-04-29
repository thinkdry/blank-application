# contents: UTF-8 String methods.
#
# Copyright © 2006 Nikolai Weibull <now@bitwi.se>

require 'encoding/character/utf-8/utf8'

# TODO: Rework this to use a dispatch object instead, so that the encoding can
# be changed on the fly.
# TODO: Add String#encoding.
module Encoding::Character::UTF8::Methods
  def self.def_thunk_replacing_variant(method)
    define_method(:"#{method}!") do
      replace(send(method))
    end
  end

  def <=>(other)
    Encoding::Character::UTF8.collate(self, other)
  end

  def [](*args)
    Encoding::Character::UTF8.aref(self, *args)
  end

  def slice(*args)
    Encoding::Character::UTF8.aref(self, *args)
  end

  def []=(*args)
    Encoding::Character::UTF8.aset(self, *args)
  end

  def casecmp(other)
    Encoding::Character::UTF8.casecmp(self, other)
  end

  def center(*args)
    Encoding::Character::UTF8.center(self, *args)
  end

  def chomp(*args)
    Encoding::Character::UTF8.chomp(self, *args)
  end

  def chomp!(*args)
    Encoding::Character::UTF8.chomp!(self, *args)
  end
  
  def chop
    Encoding::Character::UTF8.chop(self)
  end

  def chop!
    Encoding::Character::UTF8.chop!(self)
  end

  def count(*args)
    Encoding::Character::UTF8.count(self, *args)
  end

  def delete(*args)
    Encoding::Character::UTF8.delete(self, *args)
  end

  def delete!(*args)
    Encoding::Character::UTF8.delete!(self, *args)
  end

  def downcase
    Encoding::Character::UTF8.downcase(self)
  end
  def_thunk_replacing_variant :downcase

  def each_char(&block)
    Encoding::Character::UTF8.each_char(self, &block)
  end

  def index(*args)
    Encoding::Character::UTF8.index(self, *args)
  end

  def insert(index, other)
    Encoding::Character::UTF8.insert(self, index, other)
  end

  def length
    Encoding::Character::UTF8.length(self)
  end

  def lstrip
    Encoding::Character::UTF8.lstrip(self)
  end

  def lstrip!
    Encoding::Character::UTF8.lstrip!(self)
  end

  def normalize(*args)
    Encoding::Character::UTF8.normalize(self, *args)
  end

  def rindex(*args)
    Encoding::Character::UTF8.rindex(self, *args)
  end

  def rstrip
    Encoding::Character::UTF8.rstrip(self)
  end

  def rstrip!
    Encoding::Character::UTF8.rstrip!(self)
  end

  def reverse
    Encoding::Character::UTF8.reverse(self)
  end
  def_thunk_replacing_variant :reverse

  def squeeze
    Encoding::Character::UTF8.squeeze(self)
  end

  def squeeze!
    Encoding::Character::UTF8.squeeze!(self)
  end

  def strip
    Encoding::Character::UTF8.strip(self)
  end

  def strip!
    Encoding::Character::UTF8.strip!(self)
  end

  def to_i(*args)
    Encoding::Character::UTF8.to_i(self, *args)
  end

  def tr(from, to)
    Encoding::Character::UTF8.tr(self, from, to)
  end

  def tr!(from, to)
    replace(tr(from, to))
  end

  def tr_s(from, to)
    Encoding::Character::UTF8.tr_s(self, from, to)
  end

  def tr_s!(from, to)
    replace(tr_s(from, to))
  end

  def inspect
    "u#{_inspect}"
  end

  def ljust(*args)
    Encoding::Character::UTF8.ljust(self, *args)
  end

  def rjust(*args)
    Encoding::Character::UTF8.rjust(self, *args)
  end

  def upcase
    Encoding::Character::UTF8.upcase(self)
  end
  def_thunk_replacing_variant :upcase

  def capitalize
    self[0].upcase + self[1..-1].downcase
  end
  def_thunk_replacing_variant :capitalize

  def foldcase
    Encoding::Character::UTF8.foldcase(self)
  end
  def_thunk_replacing_variant :foldcase

private

  Inspect = String.instance_method(:inspect)

  def _inspect
    Inspect.bind(self).call
  end
end

class String
  def +@
    self.extend(Encoding::Character::UTF8::Methods)
  end
end

module Kernel
  def u(str)
    str.extend(Encoding::Character::UTF8::Methods)
  end
end
