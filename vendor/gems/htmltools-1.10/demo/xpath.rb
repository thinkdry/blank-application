#!/usr/bin/ruby
# This is a demo program that takes a given HTML file, parses it,
# and allows exploration of XPath queries.
require 'html/xmltree'
require 'html/rexml-nodepath'
require 'rexml/xpath'


def displayXPath(d, path)
  REXML::XPath.each(d, path) do |node|
    puts node.full_path + " --> " + node.to_s
  end
  nil
end


unless ARGV.size >= 1
  $stderr.puts(%Q{usage: #{$0} file.html                  interactive
       #{$0} file.html expressions      read expressions from expressions
})
  exit(1)
end

$use_readline = false
if $stderr.isatty
  $stdout.sync = true
  begin
    require 'readline'
    $use_readline = true
    $stderr.puts('line editing enabled')
    trap('SIGINT', 'IGNORE')
  rescue LoadError
    $use_readline = false
  end
end

def getline(prompt)
  if $use_readline
    Readline.readline(prompt, true)
  else
    $stdout.print prompt
    $stdin.gets
  end
end

inputFile = ARGV.shift
p = HTMLTree::XMLParser.new(true)
p.parse_file_named(inputFile)
d = p.document

if ARGV.size > 0 then
  for path in ARGV
    displayXPath(d, path)
  end
  exit
end

prompt = 'Enter XPath expression on a single line (ctrl-D (unix) or ctrl-Z (win) to quit): '
while expr = getline(prompt)
    displayXPath(d, expr)
    prompt = 'expr: '
end
