# encoding: UTF-8
module AfPub
class ExtractedFile

  def self.show_help
    clear
    less(traite TEXT_AIDE)
  end

  def self.traite(str)
    str.gsub(/\{\{(.*)\}\}/) {
      $1.jaune
    }
  end

TEXT_AIDE = <<-TXT

*************************
* AFPUB TEXT EXTRACTION *
*************************

Cet outil permet d'extraire le texte d'un fichier Affinity Publisher
(qui ne possède malheureusement pas d'exportation du texte).

PROCÉDURE
---------

* Ouvrir le fichier Affinity Publisher,
* exporter toutes les pages au format SVG en haute qualité,
  => (cela produit un dossier contenant tous les fichiers svg)
* ouvrir une fenêtre Terminal à ce dossier,
* [optionnel] jouer la commande {{afpub-extract-text config}} pour 
  créer un fichier de configuration,
* définir la configuration si le fichier config.yaml a été créé dans
  le dossier,
* jouer la commande {{afpub-extract-text}}

Dans le dossier des images SVG est alors créé un fichier qui contient
le texte. Il est toujours nécessaire de le corriger un peu.

CONFIGURATION
-------------

On peut produire un fichier de configuration permettant d'affiner
le traitement à l'aide de la commande {{afpub-extract-text config}} qui
doit être jouée dans le Terminal ouvert au dossier des fichiers SVG.

Ce fichier est auto-commenté, mais pour donner un aperçu, on peut
définir dans ce fichier si un seul fichier texte doit être produit ou
si au contraire chaque page doit faire l'objet d'un fichier, on peut
demander d'afficher le numéro de la page dans un export dans un seul
fichier. On peut indiquer des caractères dont il faut supprimer les
répétitions successives (comme les points dans la table des matières
par exemple).

TXT

end #/class ExtractedFile
end #/module AfPub
