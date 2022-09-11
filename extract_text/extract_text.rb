#!/usr/bin/env ruby
# encoding: UTF-8
=begin
  
  Extract all texts from an Affinity Publisher Document.

=end
require_relative 'lib/required'
begin
  if help? || ['help','aide'].include?(ARGV[0])
    AfPub::ExtractedFile.show_help
  elsif ARGV[0] == 'config'
    AfPub::ExtractedFile.create_config
  else
    AfPub::ExtractedFile.current.proceed
  end
rescue Exception => e
  puts e.message.rouge
  puts e.backtrace.join("\n").rouge
end
