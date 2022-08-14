#!/usr/bin/env ruby
# encoding: UTF-8
=begin
  
  Extract all texts from an Affinity Publisher Document.

=end
require_relative 'lib/required'
begin
  AfPub::Options.define_errors_and_messages
  AfPub::ExtractedFile.current_folder.proceed
rescue Exception => e
  puts e.message.rouge
  puts e.backtrace.join("\n").rouge
end
