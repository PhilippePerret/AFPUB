# encoding: UTF-8
require 'nokogiri'

LIB_FOLDER = __dir__
APP_FOLDER = File.dirname(__dir__)

Dir["#{LIB_FOLDER}/required/**/*.rb"].each{|m|require(m)}

