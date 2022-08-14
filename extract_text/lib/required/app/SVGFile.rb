# encoding: UTF-8
module AfPub
class SVGFile

  class FalseErrorNodeFind < StandardError; end

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
    lines = proceed_extraction
    if lines.empty?
      return nil
    else
      paragraphs = AfPub::Paragraphs.compact(lines)
      text = paragraphs.join(options[:paragraph_delimiter])
      text = AfPub::Paragraphs.finalize(text)
      if options[:page_number]
        titre_page = "Page ##{page_number}"
        text = "\n\n#{titre_page}\n#{'-'*titre_page.length}\n\n#{text}"
      end

      puts "\n\n\n+++ FINAL TEXT #{'<'*60}\n#{text}\n#{'>'*80}" if debug?
      #
      # The final text
      # 
      return text
    end
  end

  ##
  # Extraction of all texts from all <text> tags in the SVG file
  # 
  # @return {Array of Strings} texts, all texts 
  # 
  def proceed_extraction
    puts "--- Extraction page #{page_number}".bleu if debug?
    APNode.reset
    texts = []
    paragraphs = []
    paragraph  = ''

    #
    # We can extract all texts from nodes
    # 
    sorted_text_nodes.each do |node|
      texts << node.text
    end

    return texts.compact
  end
  #/proceed_extraction

  ##
  # @return text nodes sorted such as a text before is a node before
  # Otherwise, in SVG code (remember: it's a image), some text node 
  # can be at the wrong place in the code flow
  #
  def sorted_text_nodes
    @sorted_text_nodes ||= begin
      text_nodes.dup.each do |node|
        #
        # OK if the node is at the right place
        #
        next unless node.far_from_previous?
        #
        # ELSE, search for the right place for the node
        # 
        # puts "Le noeud #{node.inspect} est trop loin de son précédent (#{node.previous.inspect}."
        APNode.delete_at(node.index)
        searched_index = nil
        #
        # Loop on every node except the +node+ one.
        # 
        APNode.eachNode do |cnode|
          begin
            if cnode.y > node.y && cnode.x > node.y
              raise FalseErrorNodeFind
            elsif cnode.y + 100 > node.y
              raise FalseErrorNodeFind
            end
          rescue FalseErrorNodeFind
            searched_index = cnode.index.dup.freeze
            break
          end
        end
        # 
        # Insert the node at the right place
        # 
        if searched_index.nil?
          APNode.add(node)
        else
          APNode.insert_at(node, searched_index)
        end
      end

      APNode.items # => sorted_text_nodes
    end
  end

  ##
  # @return text nodes (only the right ones) as {APNode} instances
  # 
  def text_nodes
    @text_nodes ||= begin
      xdoc = Nokogiri::XML(File.read(path))
      # 
      # Loop over every <text> node of the document
      # to make {APNode} node instances.
      # 
      nodes = xdoc.css('text').reject do |node|
        # 
        # Excludes some nodes 
        # 
        node.text.match(/^[0-9]+$/)
      end.map.with_index do |node, idx|
        # 
        # {AFNode} instance
        # 
        APNode.new(self, node, idx)
      end
    end
  end

  def options
    @options ||= begin
      {
        paragraph_delimiter: "\n\n",
        page_number:    true,
        column_width:   1000,
      }
    end
  end

  def page_number
    @page_number ||= File.basename(path).match(/_([0-9]+)\.svg$/).to_a[1].to_i
  end

end #/SVGFile
end #/module AfPub
