require 'sinatra'
require 'rest-client'
require 'nokogiri'

set :bind, "0.0.0.0"
set :APP_ENV, "production"


require_relative "route"

