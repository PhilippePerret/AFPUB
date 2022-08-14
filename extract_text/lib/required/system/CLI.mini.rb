# encoding: utf-8
=begin

  Version mini 1.3

=end

module CLI
  attr_reader :options
  attr_reader :values

  def self.command
    @command ||= begin
      cmd = nil
      ARGV.each do |arg|
        next if arg.start_with?('-')
        cmd = arg and break
      end
      cmd
    end
  end

  # Pour les tests
  def self.command=(value)
    @command = value
  end

  def self.options
    @@options || {}
  end
  def self.values
    @@values || {}
  end

  # Parse la ligne de commande
  def self.parse
    reset
    ARGV.each do |arg|
      if arg.start_with?('--')
        k, v = parse_arg(arg[2..-1])
      elsif arg.start_with?('-')
        k, v = parse_arg(arg[1..-1])
      end
    end
  end

  def self.parse_arg(arg)
    if arg.match?('=')
      harg = arg.split('=', -1)
      k = harg.shift
      v = harg.join('=')
      v = v.gsub(/^["']/,'').gsub(/["']$/,'')
      v = eval("\"#{v}\"")
      @@values.merge!(k.to_sym => v)
      @@options.merge!(k.to_sym => v)
    else
      @@options.merge!(arg.to_sym => true)
    end
  end

  def self.reset
    @@options = {}
    @@values  = {} # les [--]cle=<valeur>    
  end

end #/Cli


CLI.parse

=begin

  HISTORIQUE DES VERSIONS
  -----------------------

  1.3
    Parse la ligne de commande pour récupérer les options et les
    valeurs définies par --key=value ou -key=value

  1.2
    Possibilité de définir la commande par CLI.command = <command>
    pour les tests

  1.1
    CLI.command retourne la commande utilisée, c'est-à-dire
    le premier mot après l'application.

=end
