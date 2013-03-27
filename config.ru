$: << File.dirname(__FILE__)
$: << File.join(File.dirname(__FILE__),'lib')

require 'rubygems'
require 'sinatra'
require 'json'
require 'ri_cal'
require 'rack-cache'
require 'httparty'
require 'calendar_helper'
require 'happening'
require 'app.rb'

run Sinatra::Application