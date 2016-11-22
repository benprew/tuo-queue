#!/usr/bin/env ruby

require 'bundler'
require 'sinatra'

get '/' do
  slim :index
end

get '/enqueue' do
  slim :enqueue
end

post '/enqueue' do
  user = params['username']
  your_deck = params['your_deck']
  enemy_deck = params['enemy_deck']
  command = params['command']

  user.gsub! %r{[./\\]}, '_'

  Dir.mkdir("queue/#{user}") unless Dir.exist? "queue/#{user}"

  File.open("queue/#{user}/#{Time.now.iso8601}.job", 'w') do |f|
    f.write %("#{your_deck}" "#{enemy_deck}" "#{command}" -o )
  end
end
