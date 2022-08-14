# Extract-text

To extract text from an Affinity Publisher File.

## Extract text

1. [Check the prerequises](#prerequises),
2. Export your content :
    - format: SVG (numeric, hight quality), 
    - per page (not frame).
3. open a new Terminal window at the new SVG folder where .svg exported pages lie,
4. run `afpub-extract-text` in the Terminal window
5. find the exported text in the `_<file affixe>_.txt` file at the top of the SVG folder (for instance, if the init file name is `MyBook.afpub`, the text file name would be `_MyBook_.txt`).


## Command line

```

$> cd /path/to/SVGs/folder # or contextual menu "New Terminal at folder"
$> afput-extract-text[ options]

```

**Options**

```
--pages=<range>   
                
                Only theses pages.
                Examples:
                  --pages=2-6 (pages from 2 to 6)
                  --pages=2,6 (pages 2 and 6)
                  --pages=2,6-8,12 (pages 2, 6 to 8 and 12)

--page_number=true|false
                  
                  If true (default), the script add 'Page X' mark
                  before each page treated.
                  Example:
                    --page_number=false
                  

--paragraph_separator=<type>    
                  
                  Paragraph separator. Values : 'simple' or
                    'double' (default)
                   Example: 
                      --return=simple

--column_width=<px>
                  
                  If double columns, the width of the left column,
                  in pixels.
                  Example: 
                      --column_width=152

--lang=<lang>   

                  To define the UI language. Available: 'en' (english)
                  or 'fr' (french).
```

### Treatment as span (not paragraph)

We can define in the `not_paragraphs.txt` file some texts that should not be treated as paragraph even they look like paragraph.

~~~
# in ./not_paragraphs.txt
# A comment ignored

Maj.
~~~

Even if it looks like a paragraph (capitalize letter and dot), if this text is along in a line, it will not be treated as a paragraph.


This file can contain regular expressions:

~~~
# in ./not_paragraphs.txt
# comments

/^[A-G]m?$/
~~~

Even if 'Bm' start with a capital letter, it will not be treated as a paragraph because it matches de above regular expression.

Each expression should be writen one above the other.

~~~
# in ./not_paragraphs.txt

FirstException
SecondException
...
NiemeException

~~~


## Annexe

<a name="prerequises"></a>

### Prerequises

* [Ruby](https://www.ruby-lang.org) > 2.6 up and running
* [Nokogiri gem](http://nokogiri.org) (`gem install nokogiri`)
* `afpub-extract-text` alias :

  ```
  cd /path/to/this/folder/extract_text
  chmod +x ./extract_text.rb
  ln -s /path/to/this/folder/extract_text/extract_text.rb /usr/local/bin/afpub-extract-text
  ```
