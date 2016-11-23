#!/usr/bin/env ruby

require 'bundler'
require 'sinatra'
require_relative 'lib/tuo_queue'
require_relative 'lib/job'
require_relative 'lib/result'

get '/' do
  slim :index
end

get '/queue/add' do
  slim :queue_add
end

post '/queue/add' do
  user = params['username']
  your_deck = params['your_deck']
  enemy_deck = params['enemy_deck']
  command = params['command']
  cmd_count = params['cmd_count']

  user.gsub! %r{[./\\]}, '_'

  FileUtils.mkdir_p(TuoQueue::QUEUE_DIR) unless Dir.exist? TuoQueue::QUEUE_DIR

  job = "#{Time.now.iso8601}_#{user}.job"

  File.open("#{TuoQueue::QUEUE_DIR}/#{job}", 'w') do |f|
    f.write %("#{your_deck}" "#{enemy_deck}" "#{command}" "#{cmd_count}")
  end

  redirect '/queue/list'
end

get '/queue/list' do
  @results = TuoQueue.enqueued.map { |f| Job.new f }

  slim :queue_list
end

get '/result/list' do
  @results = TuoQueue.completed

  slim :result_list
end

get '/result/:result_file' do
  @result = Result.new params['result_file']

  slim :result
end
