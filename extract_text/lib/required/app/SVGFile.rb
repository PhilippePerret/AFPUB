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
      #
      # Last treatments of paragraphs
      # 
      paragraphs = AfPub::Paragraphs.compact(lines)
      #
      # Compact text
      # 
      text = paragraphs.join(Options.paragraph_separator)
      # 
      # Last traitment of text
      # 
      text = AfPub::Paragraphs.finalize(text)
      # 
      # Add Page Number Mark if required
      # 
      if Options.page_number?
        titre_page = "Page ##{page_number}"
        text = "\n\n#{titre_page}\n#{'-'*titre_page.length}\n\n#{text}"
      end

      puts "\n\n\n+++ FINAL TEXT #{'<'*60}\n#{text}\n#{'>'*80}" if debug?
      #
      # Return the final text
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
    debug? && puts("--- Extraction page #{page_number}".bleu)
    APNode.reset
    texts = []

    #
    # We can extract all texts from nodes
    # 
    text_nodes.each do |node|
      texts << node.text
    end

    return texts.compact
  end
  #/proceed_extraction


  ##
  # Text nodes 
  # ----------
  # Some of them are in a <g> tag with matrix transformation so we
  # must calculate the real positions (x, y).
  # 
  # @return text nodes as {APNode} instances
  #   - sorted
  #   - only the right ones (exclusion)
  # 
  def text_nodes
    @text_nodes ||= get_text_nodes
  end
  def get_text_nodes
    xdoc = Nokogiri::XML(File.read(path))
    verbose? && puts("* Get text nodes in #{path}".bleu)
    text_tag_index = 0
    node_groupes = []
    xdoc.css('svg > text, svg > g').each do |node|
      if node.name == 'text'
        inode = APNode.new(self, node, text_tag_index)
        text_tag_index += 1
        # 
        # Le groupe, même s'il n'aura qu'un seul élément
        # 
        igroup = APNodeGroup.new(nil)
        igroup.add_text_node(inode)
        verbose? && puts("+++ relève de text node (#{igroup.point.inspect}) : #{node.text}")
      else
        # 
        # Traitement d'un groupe de texte (g)
        # 
        # Note : on ne reclasse pas les lignes à l'intérieur 
        # d'un groupe de texts. C'est seulement les groupes 
        # ensemble qu'il faut classer.
        # 
        # Note 2 : on n'est pas sûr qu'un groupe contienne des
        # noeuds textuels. Donc on les relève d'abord, avant de
        # créer l'instance.
        # 
        text_node_list = []
        debug_list = []
        node.css('text').each do |cnode|
          debug_list << "+++ relève de text node in g : #{cnode.text}"
          text_node_list << APNode.new(self, cnode, text_tag_index)
          text_tag_index += 1
        end
        if text_node_list.any?
          igroup = APNodeGroup.new(node)
          igroup.text_nodes = text_node_list
          if verbose?
            puts "\n+++ Groupe <g> (#{igroup.point.inspect})"
            puts debug_list.join("\n")
          end
        end
      end
    end#/ xdoc.css.each
    
    # 
    # Nodes sorting
    #
    # Cela consiste à classer d'abord les groupes de noeud puis
    # à prendre leurs textes dans l'ordre
    # 
    nodes = []
    APNodeGroup.groups.sort do |agroup, bgroup|
      agroup.after?(bgroup) ? -1 : 1
    end.each do |group|
      nodes += group.text_nodes
    end

    #
    # Nodes exclusion (if any)
    # 
    nodes = nodes.reject do |node|
      Options.exclude_nodes && Options.excluded_node?(node)        
    end

    if verbose? || debug?
      nodes.each do |node|
        puts "-- #{node.text}"
      end
    end

    return nodes
  end
  #/get_text_nodes

  def page_number
    @page_number ||= File.basename(path).match(/_([0-9]+)\.svg$/).to_a[1].to_i
  end


end #/SVGFile
end #/module AfPub
