# encoding: UTF-8

module AfPub
class Options
class << self

  # --- Public methods ---

  # @return TRUE is page number +number+ is to be processed.
  # 
  def page_in_range?(number)
    return true if pages_traited == 'ALL' || pages_traited.include?(number)
    return true if pages_range.nil?
    pages_range.each do |paire|
      min, max = paire
      if number >= min && number <= max
        return true
      end
    end
    return false
  end

  # @return Les pages à traiter, d'après la configuration
  def pages_traited
    @pages_traited ||= begin
      pgs = config[:pages]
      if pgs.match('-')
        startp, endp = psg.split('-').map{|n|n.to_i}
        (startp..endp).to_a
      elsif pgs.match(',')
        psg.split(',').map{|n|n.to_i}
      else
        pgs # ALL
      end
    end
  end

  # @return TRUE if page number mark is to be written
  def page_number?
    :TRUE == @page_number ||= true_or_false(config[:add_page_number] || not(CLI.options[:page_number] == 'false'))
  end

  def text_per_page?
    :TRUE == @text_per_page ||= true_or_false(config[:text_per_page] || CLI.options.key?(:text_per_page) && CLI.options[:text_per_page] != 'false')
  end

  # @return TRUE if we don't want tabulation or double space
  def only_single_spaces?
    :TRUE == @only_single_spaces ||= true_or_false(not(CLI.options[:single_space] == 'false'))
  end

  ##
  # Si des éléments sont définis comme n'étant pas des lignes, 
  # @return TRUE si +line+ est considéré comme un paragraphe
  # 
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

  def exclure?(text)
    exclusions.each do |exclus|
      return true if text.match?(exclus)
    end
    return false
  end

  # --- /public methods ---


  def exclusions 
    @exclusions ||= begin
      ex = config[:excludes]||[]
      ex.map do |exclus|
        if exclus.is_a?(String)
          /^#{exclus}$/
        else
          exclus
        end
      end
    end
  end

  def not_paragraphs
    @not_paragraphs ||= config[:not_paragraphs]
  end

  def column_width
    @column_width ||= begin
      CLI.options[:column_width] || COLUMN_WIDTH
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

  ##
  # Load configuration file to define some constants
  # 
  # Called at the beginning of the work, try to find a file config.txt
  # which defines properties and mesurement of the document.
  # If doesn't exist, take default values
  # 
  def load_document_configuration
    Object.const_set('DEFAULT_LANG',        config[:lang])
    Object.const_set('Y_TOLERANCE',         config[:y_tolerance].to_i)
    Object.const_set('COLUMN_WIDTH',        config[:column_width].to_i)
    Object.const_set('MINIMUM_LINEHEIGHT',  config[:minimum_lineheight].to_i)
  end

  def config
    @config ||= get_config
  end

  def config_yaml_filepath
    @config_yaml_filepath ||= File.join(current_folder, 'config.yaml')
  end

private

  ##
  # @return configuration table (with default value added)
  def get_config
    config = {
      pages: 'ALL',
      remove_page_number: true,
      add_page_number: true,
      minimum_lineheight: 100,
      y_tolerance:        30,
      column_width:       1000,
      lang:               'en',
      not_paragraphs:     [],
      excludes:           []
    }
    table = {}
    if File.exist?(config_yaml_filepath)
      table = YAML.load_file(config_yaml_filepath)
    end
    config.merge!(table)
    config.merge!(y_demi_tolerance: config[:y_tolerance] / 2)
  end

  def current_folder
    @current_folder ||= ExtractedFile.current.folder
  end
end #/<< class
end #/class Options
end #/module AfPub
