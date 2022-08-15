# encoding: UTF-8

module AfPub
class Options
class << self

  # --- Public methods ---

  # @return TRUE is page number +number+ is to be processed.
  # 
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

  # @return TRUE if page number mark is to be written
  def page_number?
    @page_number ||= begin
      if CLI.options.key?(:page_number)
        CLI.options[:page_number] == 'true'
      else
        true
      end
    end
  end

  # @return TRUE if text +node+ must be excluded.
  # @param node {APNode} The text node
  def exclude_node?(node)
    return false if exclude_nodes.nil?
    exclude_nodes.each do |regexp|
      if node.text.match?(regexp)
        verbose? && puts("+ Le Node #{node.text.inspect} must be excluded".bleu)
        return true
      end
    end
    return false
  end

  def not_paragraph?(line)
    return false if not_paragraphs.nil?
    not_paragraphs.each do |regexp|
      if line.match?(regexp)
        verbose? && puts("+ Line #{line.inspect} n'est pas un paragraphe".bleu)
        return true 
      end
    end
    return false
  end

  # --- /public methods ---


  def exclude_nodes 
    @exclude_nodes ||= read_definitions_in('exclude_nodes')
  end

  def not_paragraphs
    @not_paragraphs ||= read_definitions_in('not_paragraphs.txt')
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


private

  ##
  # Read +filename+ (a file name in main SVG folder) and returns
  # all expression as regular expression to filter the text nodes.
  # 
  def read_definitions_in(filename)
    path = File.join(ExtractedFile.current_folder.folder_path,filename)
    if File.exist?(path)
      File.readlines(path).map do |line|
        line = line.strip
        next if line.start_with?('#') || line == ''
        verbose? && puts("line not paragraph: #{line}")
        if line.start_with?('/')
          eval(line)
        else
          /^#{line}$/
        end
      end.compact
    end
  end

end #/<< class
end #/class Options
end #/module AfPub
