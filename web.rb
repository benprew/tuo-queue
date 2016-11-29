#!/usr/bin/env ruby

require 'bundler'
require 'sinatra'
require 'JSON'
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

  user.gsub! %r{[./\\]}, '_'

  job = Job.new

  cmd = %("#{your_deck}" "#{enemy_deck}" "#{command}" "#{cmd_count}")

  if command == 'climb' && params['fund']
    cmd += " fund #{params['fund']}"
  end

  job.command = cmd
  job.user = user
  job.save

  redirect "/job/#{job.id}"
end

get '/job/queued/list' do
  @results = Job.queued

  slim :list_queued
end

get '/job/completed/list' do
  @results = Job.completed

  slim :list_completed
end

get '/job/:id' do
  @job = Job.where(id: params['id']).first
  slim :job
end
