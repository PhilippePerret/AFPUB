#!/usr/bin/env ruby
# encoding: UTF-8
=begin
  
  Extract all texts from an Affinity Publisher Document.

=end
require_relative 'lib/required'
begin
  AfPub::ExtractedFile.current_folder
rescue Exception => e
  puts e.message.rouge
  puts e.backtrace.join("\n").rouge
end
