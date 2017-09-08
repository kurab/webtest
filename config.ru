require 'sinatra/base'
require 'i18n'
require 'logger'
require 'sinatra/logger'
require "sinatra/cookies"

Dir.glob('./app/{models,helpers,controllers}/*.rb').each { |file| require file }

map '/exam' do 
    run ExamController
end

map '/' do
    run WebsiteController
end

map '/admin' do
    run AdminController
end