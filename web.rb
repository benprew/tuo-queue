#!/usr/bin/env ruby

require 'bundler'
require 'sinatra'
require 'json'
require_relative 'lib/job'

get '/' do
  slim :index
end

get '/job/create' do
  @bges = File.read("#{Job::TUO_DIR}/data/bges.txt")
    .split(/\n/)
    .select { |l| l =~ /^[a-zA-Z0-9]/ }
    .sort
    .map { |bge| [bge.split(/:/)[0], bge] }
  slim :create
end

post '/job/create' do
  cmd_args = []
  your_deck = params['your_deck']
  enemy_deck = params['enemy_deck']
  command = params['command']
  cmd_count = params['cmd_count']
  user = params['username'].gsub(/[^a-zA-Z0-9]+/, '_').downcase
  inventory_file = "/tmp/#{user}.txt"

  # update from form
  if params['your_inventory']
    # save inventory file
    File.open(inventory_file, 'w') do |f|
      f.write(params['your_inventory'][:tempfile].read)
    end
  end

  job = Job.new
  job.created_at = Time.now

  ed_cmd = "'#{enemy_deck + (enemy_deck =~ /LV24/ ? '' : "-#{params['enemy_level']}")}'"

  cmd_args << "'#{your_deck}'"
  cmd_args << ed_cmd
  cmd_args << "'#{command}'"
  cmd_args << "'#{cmd_count}'"
  cmd_args << "-e '#{params['bge']}'" unless params['bge'].empty?
  cmd_args << "-o='#{inventory_file}'" if File.exist?(inventory_file)
  cmd_args << "yf '#{params['your_structs']}'" unless params['your_structs'].empty?
  cmd_args << "ef '#{params['enemy_structs']}'" unless params['enemy_structs'].empty?

  if command == 'climb' && !params['fund'].empty?
    cmd_args << "fund #{params['fund']}"
  end

  job.name = "vs. #{enemy_deck} (#{command})"
  job.command = cmd_args.join(' ')
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
