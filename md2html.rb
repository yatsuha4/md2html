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
  html.gsub!(/([ \t]*)\$(\w+?)\$([ \t]*)(\n?)/) {
    keyword = parser[$2]
    if keyword and !keyword.empty?
      "#{$1}#{keyword}#{$3}#{$4}"
    else
      ""
    end
  }
  if output
    File.open(output, 'w') { |fd|
      fd.write(html)
    }
  else
    puts(html)
  end
end
