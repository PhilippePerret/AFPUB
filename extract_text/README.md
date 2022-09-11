# Extract-text

To extract text from an Affinity Publisher File.

Run the `extract_text.rb` script in console.

## Help

Run in a Terminal:

~~~bash

cd path/to/this/folder
ruby ./extract_text.rb help

~~~

## Annexe

<a name="prerequises"></a>

### Prerequises

* [Ruby](https://www.ruby-lang.org) > 2.6 up and running
* [Gem Nokogiri](http://nokogiri.org) (`gem install nokogiri`)
* Gem minitest-color (`gem install minitest-color`)
* Gem YAML (`gem install yaml`)
* `afpub-extract-text` alias :

  ```
  cd /path/to/this/folder/extract_text
  chmod +x ./extract_text.rb
  ln -s /path/to/this/folder/extract_text/extract_text.rb /usr/local/bin/afpub-extract-text
  ```
