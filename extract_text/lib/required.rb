# encoding: UTF-8
require 'nokogiri'
require 'minitest'
require 'minitest/color'

LIB_FOLDER = __dir__
APP_FOLDER = File.dirname(__dir__)

Dir["#{LIB_FOLDER}/required/system/**/*.rb"].each{|m|require(m)}
Dir["#{LIB_FOLDER}/required/app/**/*.rb"].each{|m|require(m)}

