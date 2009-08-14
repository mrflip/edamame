#!/usr/bin/env ruby
$: << File.dirname(__FILE__)+'/../../lib'
require 'rubygems'
require 'sinatra/base'
require 'haml'
require 'json'
require 'extlib/blank'
require 'edamame'

#
# run with
#   shotgun --port=12000 --server=thin ./config.ru
#
class EdamameSan < Sinatra::Base
  # Server setup
  helpers do include Rack::Utils ; alias_method :h, :escape_html ; end
  set :sessions,           true
  set :static,             true
  set :logging,            true
  set :dump_errors,        true
  set :root,               File.dirname(__FILE__)
  #configure :production do Fiveruns::Dash::Sinatra.start(@@config[:fiveruns_key]) end

  # configure do
  #   @@config = YAML.load_file(ENV['HOME']+"/.monkeyshines") rescue nil || {}
  #   Log.info "Loaded config file with #{@@config.length} things"
  # end

  # before do
  #   next if request.path_info =~ /ping$/
  # end

  #
  # Front Page
  #
  get "/" do
    haml :root
  end

  puts "hi!"

  # private
  #
  # def inspection *args
  #   str = args.map{|thing| thing.inspect }.join("\n")
  #   Log.info str
  #   '<pre>'+h(str)+'</pre>'
  # end
end
