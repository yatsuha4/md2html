#
require_relative 'block'

#
class Parser
  #
  def initialize
    @head = ''
    @body = ''
    @keywords = { 'head' => @head, 'body' => @body }
    @blocks = []
  end

  #
  def [](key)
    return @keywords[key]
  end

  #
  def []=(key, value)
    case key
    when 'redirect'
      @head << "<meta http-equiv='refresh' content='0;url=#{value}'>"
    else
      @keywords[key] = value
    end
  end

  #
  def parse(path)
    text = ''
    File.foreach(path) { |line|
      text << line.chomp
      if /\\$/.match(line)
        text.chomp!('\\')
      else
        if html = parse_line(text)
          html.gsub!(/\\(.)/) { $1 }
          # @body << html << "\n"
          @body << html
        end
        text = ''
      end
    }
    close_all_block
  end

  #
  def parse_line(text)
    parse_inline(text)
    if match = /^%(\w+)\s+(.*)$/.match(text)
      self[match[1]] = match[2]
      return nil
    elsif match = /^(#+)\s*(.*)\s*$/.match(text)
      close_all_block
      n = match[1].length
      return "<h#{n}>#{match[2]}</h#{n}>"
    elsif match = /^(\s*)\*\s*(.*)\s*$/.match(text)
      open_block(Block.new(match[1].length, 'ul'))
      return "<li>#{match[2]}</li>"
    elsif match = /^(\s*)(\|.*\|)(h?)\s*$/.match(text)
      open_block(Block.new(match[1].length, 'table'))
      tag = match[3].empty? ? 'td' : 'th'
      tr = match[2].scan(/\|(.*?)(?=\|)/).map { |m| "<#{tag}>#{m[0]}</#{tag}>" }.join
      return "<tr>#{tr}</tr>"
    elsif match = /^(\s*)(.*?)(\s*)$/.match(text)
      if match[2].empty?
        close_all_block
        return nil
      else
        indent = match[1].length
        open_block(Block.new(indent, indent > 0 ? 'pre' : 'p'))
        return match[2] + "<br/>"
      end
    end
  end

  #
  def parse_inline(text)
    text.gsub!(/!\[([^\s\\]+?)\]/) {
      src = $1
      id = File.basename(src, '.*')
      "<img src='#{src}' id='#{id}'/>"
    }
    text.gsub!(/\[([^\s\\]+?)\](\((.*?)\))?/) { |match|
      "<a href='#{$1}'>#{$3 || $1}</a>"
    }
    text.gsub!(/\*\*(.*?)\*\*/) {
      "<strong>#{$1}</strong>"
    }
  end

  #
  def open_block(block)
    while !@blocks.empty? && @blocks.last.indent > block.indent
      close_block
    end
    if @blocks.empty? || block.indent > @blocks.last.indent
      @body << block.open << "\n"
      @blocks.push(block)
    end
  end

  #
  def close_block
    if !@blocks.empty?
      block = @blocks.pop
      @body << block.close << "\n"
    end
  end

  #
  def close_all_block
    while !@blocks.empty?
      close_block
    end
  end
end
