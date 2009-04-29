# contents: Auxiliary classes and methods for Test::Unit based tests.
#
# Copyright © 2006 Nikolai Weibull <now@bitwi.se>

require 'test/unit'

module UnicodeDataTestBase
  UnidataBase = 'http://www.unicode.org/Public/UNIDATA/'

  def open_data_file(file, &block)
    dir = File.join(File.dirname(__FILE__), 'data')
    begin
      Dir.mkdir(dir)
    rescue Errno::EEXIST
    end
    path = File.join(dir, file)
    begin
      File.open(path, &block)
    rescue Errno::ENOENT
      url = UnidataBase + file
      print <<EOM
#{file} is missing.  However, it can easily be downloaded at
#{url}.
EOM
      require 'readline' rescue exit 1
      print <<EOM
If you would like, I can download and install it for you.
If so, please type “yes”:
EOM
      exit 1 unless Readline.readline == 'yes'
      puts "OK, trying to fetch #{file} for you…"
      require 'open-uri'
      length = 0
      open(url,
          :content_length_proc => proc{ |size| length = size if size and size > 0 },
          :progress_proc => proc{ |size| print(length ? "\r%3d%" % (100 * size / length) : "\r#{size}") }) do |remote|
        File.open(path, 'w') do |local|
          local.write remote.read(8192) until remote.eof?
        end
      end
      puts "\nAh, finally done.  I’ll try to open #{file} again now."
      retry
    end
  end
end
