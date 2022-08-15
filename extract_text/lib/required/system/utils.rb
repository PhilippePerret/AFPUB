# encoding: UTF-8
# frozen_string_literal: true
require 'erb'

##
# "Enroule" le code d'un message d'opération.
#
# @usage
# ======
# 		wrap_into_message("Compter jusqu'à 100") do
# 			compter_jusqua_cent
# 		end
#
# La méthode va écrire le message "Compter jusqu'à 100…" en bleu
# à la console, puis passera en vert avec "OK" à la fin à la fin de
# l'opération.
#
def wrap_into_message(message, &block)
  STDOUT.write "  🪚 #{message}…".bleu
  yield block
  # sleep 0.2 # pour le voir
  puts "\r  🍺 #{message} OK".vert + ' '*30
end

# 
# Déserbe un fichier pour un propriétaire, en forçant l'encodage
# 
def deserb(path, owner)
	ERB.new(File.read(path).force_encoding('utf-8')).result(owner.bind)
end

# 
# Traite un fichier markdown étendu
# Si +owner+ est défini (c'est une PageSite) et il faut évaluer les
# code double crochet à l'intérieur
# 
def kramdown(code, owner = nil)
	code = code.gsub(/\{\{(.*?)\}\}/) do
		eval($1)
	end
	Kramdown::Document.new(code).to_html
end

class String
	# 
	# Retourne TRUE si le fichier de path self est plus vieux (créé 
	# avant) le fichier de path +compared_path+
	# 
	# @usage
	# 
	# 		mypath.older_than?(autrepath)
	# 
	def older_than?(compared_path)
		return true if not File.exist?(self)
		File.stat(self).mtime < File.stat(compared_path).mtime
	end
end

# 
# Active (met au premier plan) la fenêtre de Terminal
# 
def tell_me_to_activate
	`osascript -e 'tell application "Terminal" to activate'`
end


# 
# Prends le temps +time+, qui peut être une horloge avec frame, et
# retourne le nombre de secondes correspondant.
# 
def secondize(time)
	return time if time.is_a?(Integer)
	horloge, frames = time.split(',').collect{|n|n.strip}
	scs, mns, hrs = horloge.split(':').reverse.collect{|n|n.to_i}
	return ((scs + (mns||0) * 60 + (hrs||0) * 3600) * 1000 + (frames || 0)).to_f / 1000
end


# 
# Permet de définir un dossier en le créant s'il n'existe pas
# 
def mkdir(dirpath)
	`mkdir -p "#{dirpath}"`
	File.exist?(dirpath) || raise("Impossible de créer le dossier #{dirpath.inspect}…")
	return dirpath
end

# 
# Pour écrire les données +ydata+ dans le fichier yaml +ypath+
# au format YAML
# 
def file_yaml_write(ypath, ydata)
	File.delete(ypath) if File.exist?(ypath)
	File.open(ypath,'wb'){|f|f.write(YAML.dump(ydata))}
end

# 
# Requiert tous les modules ruby du dossier +dossier+
# 
# +dossier+		{String} Path au dossier à requiérir
# +deep+			{Boolean} Si true, charge aussi les modules dans les
# 						sous dossier (défaut), sinon, ne charge que les modules
# 						à la racine du dossier.
# 
def require_folder(dossier, deep = true)
	dpath = "#{dossier}#{deep ? '/**' : ''}/*.rb"
	Dir[dpath].each{|m|require(m)}
end

def redefine_constant(const, value)
  self.class.send(:remove_const, const) if self.class.const_defined?(const)
  self.class.const_set(const, value)
end
