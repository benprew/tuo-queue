#!/usr/bin/env ruby

require 'bundler'
require 'sinatra'
require 'json'
require_relative 'lib/tuo_queue'
require_relative 'lib/job'
require_relative 'lib/result'

get '/' do
  slim :index
end

get '/job/create' do
  slim :create
end

post '/job/create' do
  user = params['username']
  your_deck = params['your_deck']
  enemy_deck = params['enemy_deck']
  command = params['command']
  cmd_count = params['cmd_count']

  user.gsub!(/[^a-zA-Z0-9]+/, '_')

  inventory_file = "/tmp/#{user}.txt"
  # save inventory file
  File.open(inventory_file, 'w') do |f|
    f.write(params['myfile'][:tempfile].read)
  end

  job = Job.new
  job.created_at = Time.now

  cmd = "'#{your_deck}' '#{enemy_deck}' '#{command}' '#{cmd_count}' " \
        "-o='#{inventory_file}'"

  if command == 'climb' && params['fund']
    cmd += " fund #{params['fund']}"
  end

  job.name = "vs. #{enemy_deck} (#{command})"
  job.command = cmd
  job.user = user
  job.save

  redirect "/job/#{job.id}"
end

get '/job/queued/list' do
  @jobs = Job.queued

  slim :list
end

get '/job/completed/list' do
  @jobs = Job.completed

  slim :list
end

get '/job/:id' do
  @job = Job.where(id: params['id']).first
  slim :job
end
