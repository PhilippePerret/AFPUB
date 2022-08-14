# encoding: UTF-8
module AfPub
class SVGFile

  attr_reader :path

  def initialize(path)
    @path = path
  end

  ##
  # = main =
  # 
  # Extract (and return) all texts form the SVG file
  # 
  # @return {String} The whole text or nil if empty
  # 
  def extract_text
    text = proceed_extraction
    if text == ''
      return nil
    else
      if options[:page_number]
        titre_page = "Page ##{page_number}"
        text = "\n\n#{titre_page}\n#{'-'*titre_page.length}\n\n#{text}"
      end

      return text
    end
  end

  ##
  # Extraction of all texts from all <text> tags in the SVG file
  # 
  def proceed_extraction
    APNode.reset
    text = []
    paragraphs = []
    paragraph  = ''

    xdoc = Nokogiri::XML(File.read(path))
    # 
    # All <text> nodes
    # 
    nodes = xdoc.css('text')
    # puts "[page #{page_number}] Nombre de text nodes : #{nodes.count}"

    # 
    # Loop over every <text> node of the document
    # to make {APNode} node instances.
    # 
    nodes = nodes.map.with_index do |node, idx|
      # Debug
      # puts "#{node.name} = #{node.text}"
      # 
      # Passed through nodes 
      # 
      next if node.text.match(/^[0-9]+$/)
      # 
      # {AFNode} instance
      # 
      APNode.new(node, idx)
    end.compact

    #
    # Text can be placed after another even if it is above. We check
    # the x and y node attributes to check the right position.
    # 
    nodes.each do |node|
      # Here, +node+ is an {AFNode} instance
      puts "node x y : #{node.x} #{node.y}"
      puts "node.deltax_with_previous = #{node.deltax_with_previous}"
      puts "node.deltay_with_previous = #{node.deltay_with_previous}"
    end.compact

    
    return text.join(options[:text_delimiter])
  end
  #/proceed_extraction

  def options
    @options ||= begin
      {
        text_delimiter: "\n",
        page_number:    true
      }
    end
  end

  def page_number
    @page_number ||= File.basename(path).match(/_([0-9]+)\.svg$/).to_a[1].to_i
  end

end #/SVGFile
end #/module AfPub
