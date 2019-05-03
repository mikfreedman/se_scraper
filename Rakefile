# Rakefile

require 'rake'
require 'bundler'
Bundler.setup
require 'grape-raketasks'
require 'grape-raketasks/tasks'

desc 'load the Sinatra environment.'
task :environment do
  require File.expand_path('scraper', File.dirname(__FILE__))
end

task :dev do
  require 'dotenv/load'
  require 'dotenv'
  Dotenv.load
  %x[rackup]
end
