# encoding: UTF-8

module AfPub
class Options
class << self

  # --- Public methods ---

  # @return TRUE is page number +number+ is to be processed.
  # 
  def page_in_range?(number)
    return true if pages_traited == 'ALL' || pages_traited.include?(number)
    unless pages_range.nil?
      pages_range.each do |paire|
        min, max = paire
        if number >= min && number <= max
          return true
        end
      end
    end
    return false
  end

  # @return Les pages à traiter, d'après la configuration
  def pages_traited
    @pages_traited ||= begin
      pgs = config[:pages]
      if pgs.match('-')
        startp, endp = pgs.split('-').map{|n|n.to_i}
        (startp..endp).to_a
      elsif pgs.match(',')
        pgs.split(',').map{|n|n.to_i}
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
        # puts "LINE '#{line}' ne peut pas être un paragraphe"
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

  # @return TRUE si +txt+ est un texte devant lequel 
  # on ne doit pas mettre d'espace
  NO_SPACE_BEFORE = {'e'=>true, 're'=>true, 'er'=>true, ',' => true, '.' => true}
  
  def no_space_before?(txt)
    return NO_SPACE_BEFORE.key?(txt)
  end

  def max_word_per_title
    @max_word_per_title ||= config[:max_word_per_title]
  end

  # --- /public methods ---


  def exclusions 
    @exclusions ||= begin
      (config[:excludes]||[]).map do |exclus|
        if exclus.is_a?(String)
          /^#{exclus}$/
        elsif exclus.start_with?('/') && exclus.end_with?('/')
          eval(exclus)
        else
          exclus
        end
      end
    end
  end

  def not_paragraphs
    @not_paragraphs ||= begin
      config[:not_paragraphs]&.map do |cond|
        if cond.start_with?('/') && cond.end_with?('/')
          eval(cond)
        else
          /^#{cond}$/
        end
      end
    end
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
    Object.const_set('GROUP_PARAG_DELIMITOR', paragraph_carriage)
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
      lang:               'en',
      remove_page_number: true,
      add_page_number: true,
      minimum_lineheight: 100,
      y_tolerance:        45,
      title_min_distance: 90,
      column_width:       0,
      max_word_per_title: 3,
      not_paragraphs:     [],
      excludes:           [],
      pages_with_one_column: [],
      paragraph_carriage_separator: 1,
      pages_not_ungrouped: []
    }
    table = {}
    if File.exist?(config_yaml_filepath)
      table = YAML.load_file(config_yaml_filepath)
    end
    config.merge!(table)
    config.merge!(y_demi_tolerance: config[:y_tolerance] / 2)
  end

  # Sera mis dans une constante
  def paragraph_carriage
    "\n" * (config[:paragraph_carriage_separator]||2)
  end

  def current_folder
    @current_folder ||= ExtractedFile.current.folder
  end
end #/<< class
end #/class Options
end #/module AfPub
