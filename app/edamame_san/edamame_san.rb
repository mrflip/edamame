#!/usr/bin/env ruby
$: << File.dirname(__FILE__)+'/../../lib'
require 'rubygems'
require 'sinatra/base'
require 'haml'
require 'json'
require 'edamame'

#
# run with
#   shotgun --port=11211 --server=thin ./config.ru
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

  before do
    next if request.path_info =~ /ping$/
    @store = Edamame::Store::TyrantStore.new ':11219'
    puts 'before!'
  end

  #
  # Front Page
  #
  get "/" do
    haml :root
  end

  get "/load" do
    @dest_store = Edamame::Store::TyrantStore.new ':11212'
    iter = 0
    @store.each_as(Wuclan::Domains::Twitter::Scrape::TwitterSearchJob) do |key, obj|
      edamame_job = Edamame::Job.new(
        'twitter_search_scrape', 0, obj.priority, 120,
        1, obj.prev_items.to_i/1000, 0, Time.now.to_f,
        {
          :type          => 'Every',
          :prev_rate     => (1 / obj.prev_rate.to_f),
          :prev_items    => obj.prev_items,
          :prev_span_min => obj.prev_span_min,
          :prev_span_max => obj.prev_span_max
        },
        {  'query_term' => obj.query_term }
        )
      p edamame_job.to_hash
      @dest_store.set obj.query_term, edamame_job
      (iter+=1) ; break if (iter > 10)
    end
    haml :load
  end

  private

  def inspection *args
    str = args.map{|thing| thing.inspect }.join("\n")
    Log.info str
    '<pre>'+h(str)+'</pre>'
  end
end
