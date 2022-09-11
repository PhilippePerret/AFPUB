# Todo list

* On en est dans TextAffinator.compact qui va rassembler les paragraphes qui doivent. Il faut renforcer l'intelligence de la détection des paragraphes.

* Ajouter les pages pour voir le résultat, affiner en conséquence
* Pouvoir décider de répétitions à supprimer (par exemple les "..." de la table des matières)
  - pouvoir préciser à partir de combien on supprime (pour éviter de supprimer des répétitions normales)

* Commande `afpub-extract-text -h` pour obtenir de l'aide
* Command  `afpub-extract-text config` pour créer le fichier configuration
* Options `--config=path/to/file` pour définir le fichier de configuration (sinon, dans le dossier)

## OPTIONS :


## BUGS

* Voir pourquoi les lettres entourées de ronds disparaissent
* Voir pourquoi les noms de motif disparaissent

## Essais

- (Beethoven) p. 19-20 pour voir si le premier paragraphe de la 20 va bien se retrouver sur le 19.
  - PAGE 20 On ne doit pas passer à la ligne sur le "F+m", sur le », sur le "Suisse", sur Beethoven
  - PAGE 24 Le "page 112." devrait être dans le texte (voir où), pas à la fin.
  - PAGE 32 Devrait comporter les lettres dans des ronds
