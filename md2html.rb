#
require 'optparse'

#
require_relative 'parser'

#
output = nil
template = nil

option = OptionParser.new
option.on('-o FILE') { |v| output = v }
option.on('-t FILE') { |v| template = v }
option.parse!

parser = Parser.new
ARGV.each { |path|
  parser.parse(path)
}
if template
  html = File.read(template)
  html.gsub!(/\$(\w+?)\$/) {
    parser[$1]
  }
  if output
    File.open(output, 'w') { |fd|
      fd.write(html)
    }
  else
    puts(html)
  end
end
