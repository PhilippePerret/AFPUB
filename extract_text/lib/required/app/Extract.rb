# encoding: UTF-8
module AfPub
class ExtractedFile

  ##
  # = main point d'entrée =
  # 
  # Extrait le text from all the SVG files of the current
  # folder
  # 
  def self.current_folder
    ExtractedFile.new(File.expand_path('.')).proceed
  end


  attr_reader :folder_path

  ##
  # Instanciate with full path of svg files folder
  # 
  def initialize(folder_path)
    @folder_path = folder_path
  end

  ##
  # Proceed to extraction
  # 
  def proceed
    puts "Je dois apprendre à procéder à l'extraction du dossier #{folder_path.inspect}.".jaune
    folder_conform? || return
    export_all_svgs
  end

  def export_all_svgs

    File.delete(text_file_path) if File.exist?(text_file_path)

    flux = File.open(text_file_path,'a')
    begin
      # 
      # Loop on sorted svg files
      # 
      sorted_svg_files.each do |svg_file|
        # 
        # Extract text from svg file
        # 
        text = svg_file.extract_text
        #
        # Add text to final file
        # 
        flux.puts(text) unless text.nil? || text.empty?
      end
    rescue Exception => e
      puts "#{e.message}\n#{e.backtrace.join("\n")}".rouge
    else
      puts "Extraction succeeds!\nThe whole text is in the './#{folder_name}/#{text_file_name}' file.\n\n".vert
    ensure
      flux.close
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
      Dir["#{folder_path}/*.svg"]
    end
  end

  ##
  # Ensure folder is a "conform" folder, that's to say he owns
  # svg files with same affixe name.
  # 
  def folder_conform?
    svg_files.count > 0 || raise(ERRORS[:no_svg_files])
    puts "Folder contains SVG files. OK.".vert

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
    puts "All SVG files are correct. OK.".vert

  rescue Exception => e
    puts "\n\n#{e.message}\nI can't operate.\n\n".rouge
    return false
  else
    return true
  end

  def document_affixe
    @document_affixe 
  end

  def text_file_path
    @text_file_path ||= File.join(folder_path, text_file_name)
  end

  def text_file_name
    @text_file_name ||= "_#{document_affixe}_.txt"
  end

  def folder_name
    @folder_name ||= File.basename(folder_path)
  end

end #/class ExtractFile

ERRORS = {
  no_svg_files: "No SVG files in that folder!",
  bad_file_affixe: "The '%s' file name doesn't match the document affixe (%s).\n*** The folder should only contains exported SVG files from the Affinity Publisher document ***."
}
end #/module AfPub
