# encoding: UTF-8
module AfPub
class ExtractedFile
  class << self
    
    attr_accessor :current_svg_file

    ##
    # = main point d'entrée =
    # 
    # Extrait le text from all the SVG files of the current
    # folder
    # 
    def current
      @current ||= ExtractedFile.new(File.expand_path('.'))
    end

    def debug_folder
      @debug_folder ||= File.join(current.folder,'__DEBUG__')
    end

    def remove_debug_folder_or_create
      remove_if_exist?(debug_folder, true) # true => recreate
    end

    def save_in_file_debug(filename, code)
      @i_step ||= 0
      @i_step += 1 
      nam = "#{@i_step.to_s.rjust(3,'0')}-PAGE_#{current_svg_file.page_number.to_s.rjust(3,'0')}-#{filename}.txt"
      pth = File.join(debug_folder, nam)
      File.write(pth, code)
    end


    ##
    # Méthode créant le fichier configuration dans le dossier
    # courant
    def create_config
      clear
      if File.exist?(Options.config_yaml_filepath)
        puts "Config file 'config.yaml' already exists.\n\n".jaune
      else
        puts "* I build Config file…".bleu
        src_path = template_config_file
        dst_path = Options.config_yaml_filepath
        `cp "#{src_path}" "#{dst_path}"`
        if File.exist?(dst_path)
          puts "= Config file 'config.yaml' built with success in current folder.\n(#{dst_path})".vert
        else
          puts "# Bizarrrement, le fichier n'a pas pu être créé…".rouge
        end
      end
    end

    def template_config_file
      @template_config_file ||= File.join(APP_FOLDER,'lib','model_config.yaml')
    end

  end #/<< self


  attr_reader :folder

  ##
  # Instanciate with full path of svg files folder
  #
  def initialize(folder)
    @folder = folder
  end

  ##
  # = Point d'entrée du programme =
  # 
  # Proceed to extraction in the current folder
  # 
  def proceed
    now = Time.now
    puts "------- [#{now.to_i}] DÉBUT DE L'EXTRACTION #{now} --------".bleu
    init
    folder_conform? || return
    export_all_svgs
    puts "------- [#{now.to_i}]   FIN DE L'EXTRACTION #{Time.now} --------".bleu
  end

  def init
    Options.load_document_configuration
    Options.define_errors_and_messages
    self.class.remove_debug_folder_or_create
    SVGFile.remove_texts_folder
  end

  def export_all_svgs

    File.delete(text_file_path) if File.exist?(text_file_path)


    verbose? && puts("Options.pages_range: #{Options.pages_range}".bleu)

    # 
    # {Array} Pour mettre tous les textes
    # 
    # Ce sera une liste contenant des hashes qui définissent :
    #   {path:<chemin d'accès au fichier svg>, text: <le texte>}
    # 
    all_dtextes = []

    begin
      # 
      # Loop on each sorted svg files
      # 
      sorted_svg_files.each_with_index do |svg_file, idx|
        # +svg_file+ {AfPub::SVGFile}

        self.class.current_svg_file = svg_file

        # 
        # In range of files?
        # 
        if not Options.page_in_range?(svg_file.page_number)
          verbose? && puts((MESSAGES[:page_out_of_range] % [svg_file.page_number]).bleu)
          next
        end
        # 
        # Extract text from svg file
        # 
        # Le texte qui revient ici est entièrement traité.
        # 
        texte = svg_file.extract_text

        # 
        # Maybe no text at all
        # 
        next if texte.nil? || texte.empty?

        dtexte = {text:texte, svg_file:svg_file}
        all_dtextes << dtexte

      end # Loop end on each svg file

      # 
      # Write the text
      # --------------
      # Either in only one file, or per page
      # 
      if Options.text_per_page?
        all_dtextes.each do |dtexte|
          File.write(dtexte[:svg_file].text_path, dtexte[:text])
        end
      else
        #
        # Add in one fat file
        # 

        # 
        # Maintenant qu'on a tous les textes et qu'ils doivent être
        # rassemblés dans un unique fichier, on peut voir si le 
        # début d'un fichier N+1 est la fin du dernier paragraphe du
        # fichier N.
        # 
        # On le sait si 1) le dernier paragraphe du fichier N n'est
        # pas "fini" (pas de ponctuation, une parenthèse ouverte,
        # etc.) ET QUE le premier paragraphe du fichier N+1 peut ne
        # pas être un début de paragraphe (pas de capitale, parenthè-
        # fermée seule, etc.)
        # 
        # Le cas échéant, on ajoute à la fin du texte N le début du
        # texte N+1
        # 
        nombre_textes = all_dtextes.count
        for i in 1...nombre_textes
          #
          # Le texte avant
          # 
          prevtexte  = all_dtextes[i - 1][:text]
          prevparags = prevtexte.split("\n")
          prev_parag = prevparags.last || next
          # 
          # Le texte après
          # 
          nexttexte   = all_dtextes[i][:text]
          nextparags  = nexttexte.split("\n")
          next_parag  = nextparags.first || next
          # 
          # On tente de les fusionner
          # 
          fusion = TextAffinator.compact(prev_parag + "\n" + next_parag)
          # 
          # Si la fusion ne contient plus qu'un seul paragraphe,
          # les deux textes sont liés
          # Sinon, on ne touche à rien
          # 
          if fusion.split("\n").count < 2
            # puts "FUSION NÉCESSAIRE : #{fusion}"
            prevparags[-1] = fusion
            all_dtextes[i - 1][:text] = prevparags.join("\n")
            nextparags.shift
            all_dtextes[i][:text] = nextparags.join("\n")
          end
        end

        flux = File.open(text_file_path,'a')
        all_dtextes.each_with_index do |dtexte, idx|
          # 
          # Add Page Number Mark if required
          # 
          if Options.page_number?
            titre_page = "Page ##{dtexte[:svg_file].page_number}"
            dtexte[:text] = "\n\n#{titre_page}\n#{'–'*titre_page.length}\n\n#{dtexte[:text]}"
          end
          # 
          # Write into the uniq file
          # 
          flux.puts(dtexte[:text])
        end
      end

    rescue Exception => e
      puts "#{e.message}\n#{e.backtrace.join("\n")}".rouge
    else
      if Options.text_per_page?
        puts (MESSAGES[:extract_per_file_succeeded]).vert
      else
        puts (MESSAGES[:extract_succeeded] % [folder_name, text_file_name]).vert
      end
      puts "\n\n"
    ensure
      flux.close unless flux.nil?
    end
  end

  ##
  # @return {SVGFile} instances of SVG files sorted by index
  # 
  def sorted_svg_files
    @sorted_svg_files ||= begin
      svg_files.sort_by do |path|
        filename    = File.basename(path)
        file_number = filename.match(/([0-9]+)\.svg$/).to_a[1].to_i
      end.map do |path|
        SVGFile.new(path)
      end
    end
  end

  ##
  # @return SVG files paths
  #
  def svg_files
    @svg_files ||= begin
      Dir["#{folder}/*.svg"]
    end
  end

  ##
  # Ensure folder is a "conform" folder, that's to say he owns
  # svg files with same affixe name.
  # 
  def folder_conform?
    svg_files.count > 0 || raise(ERRORS[:no_svg_files])
    puts MESSAGES[:folder_contains_svgs].vert

    # "fi" stands for "first"
    fi_svg = svg_files.first
    fi_name = File.basename(fi_svg)
    @document_affixe = fi_name.match(/^(.*)_([0-9]+)\.svg$/)[1]

    # 
    # Regular expression for all svg files
    # 
    file_regexp = /^#{Regexp.escape(@document_affixe)}_[0-9]+\.svg$/

    #
    # All svg files must have the same affixe
    #
    svg_files.each do |fpath|
      File.basename(fpath).match?(file_regexp) || raise(ERRORS[:bad_file_affixe] % [File.basename(fpath), @document_affixe] )
    end
    puts MESSAGES[:all_svgs_are_correct].vert

  rescue Exception => e
    puts "\n\n#{e.message}".rouge
    puts "#{ERRORS[:cant_op]}\n\n".rouge
    return false
  else
    return true
  end

  def document_affixe
    @document_affixe 
  end

  def text_file_path
    @text_file_path ||= File.join(folder, text_file_name)
  end

  def text_file_name
    @text_file_name ||= "_#{document_affixe}_.txt"
  end

  def folder_name
    @folder_name ||= File.basename(folder)
  end

end #/class ExtractFile

end #/module AfPub
