#
require_relative 'block'

#
class Parser
  #
  def initialize
    @body = ''
    @keywords = { 'body' => @body }
    @blocks = []
  end

  #
  def [](key)
    return @keywords[key]
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
          @body << html << "\n"
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
      @keywords[match[1]] = match[2]
      return nil
    elsif match = /^(#+)\s*(.*)\s*$/.match(text)
      close_all_block
      n = match[1].length
      return "<h#{n}>#{match[2]}</h#{n}>"
    elsif match = /^(\s*)\*\s*(.*)\s*$/.match(text)
      open_block(Block.new(match[1].length, 'ul'))
      return "<li>#{match[2]}</li>"
    else
      text.strip!
      if text.empty?
        close_all_block
        return nil
      else
        open_block(Block.new(0, "p"))
        return text + "<br/>"
      end
    end
  end

  #
  def parse_inline(text)
    text.gsub!(/!\[([^\s\\]+?)\]/) { |match|
      "<img src='#{$1}'/>"
    }
    text.gsub!(/\[([^\s\\]+?)\](\((.*?)\))?/) { |match|
      "<a href='#{$1}'>#{$3 || $1}</a>"
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
