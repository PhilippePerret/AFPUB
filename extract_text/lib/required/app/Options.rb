# encoding: UTF-8

module AfPub
class Options
class << self

  def not_paragraphs
    @not_paragraphs ||= begin
      path = File.join(ExtractedFile.current_folder.folder_path,'not_paragraphs.txt')
      if File.exist?(path)
        File.readlines(path).map do |line|
          line = line.strip
          next if line.start_with?('#') || line == ''
          puts "line not paragraph: #{line}"
          if line.start_with?('/')
            eval(line)
          else
            /^#{line}$/
          end
        end.compact
      end
    end
  end
  def column_width
    @column_width ||= begin
      CLI.options[:column_width] || 1000
    end
  end

  def paragraph_separator
    @paragraph_separator ||= begin
      if CLI.options.key?(:paragraph_separator)
        CLI.options[:paragraph_separator]
      else
        "\n\n"
      end
    end
  end

  def page_in_range?(number)
    return true if pages_range.nil?
    pages_range.each do |paire|
      min, max = paire
      if number >= min && number <= max
        return true
      end
    end
    return false
  end
  def pages_range
    @pages_range ||= begin
      if CLI.options.key?(:pages)
        CLI.options[:pages].split(',').map do |n|
          if n.match?('-')
            n.split('-').map{|p| p.to_i}
          else
            [n.to_i, n.to_i]
          end
        end
      else
        nil
      end
    end
  end

  def page_number?
    @page_number ||= begin
      if CLI.options.key?(:page_number)
        CLI.options[:page_number] == 'true'
      else
        true
      end
    end
  end

  def lang
    @lang ||= begin
      if CLI.options.key?(:lang)
        CLI.options[:lang]
      else
        DEFAULT_LANG
      end
    end
  end

  def define_errors_and_messages
    Object.const_set('ERRORS',    ERRORS_DATA[lang])
    Object.const_set('MESSAGES',  MESSAGES_DATA[lang])
  end

end #/<< class
end #/class Options
end #/module AfPub
