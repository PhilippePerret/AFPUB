# Extract-text

To extract text from a Affinity Publisher File.

## Extract text

1. [Check the prerequises](#prerequises),
2. Export your content :
  - SVG format (numeric, hight quality), 
  - per page (not frame).
3. open a new Terminal window at the new SVG folder where .svg exported pages lie,
4. run `afpub-extract-text` in the Terminal window
5. find the exported text in the `_<file affix>_.txt` file at the top of the SVG folder.


## Annexe

<a name="prerequises"></a>

### Prerequises

* Ruby > 2.6 up and running
* `afpub-extract-text` alias :

  ```
  cd /path/to/this/folder/extract_text
  chmod +x ./extract_text.rb
  ls -s ./extract_text.rb /usr/local/bin/afpub-extract-text
  ```
