#!/usr/bin/env ruby

require 'bundler'
require 'sinatra'
require 'json'
require 'ostruct'
require_relative 'lib/job'
require_relative 'lib/player'

get '/' do
  slim :index
end

get '/job/simple_job' do
  @enemy_level = 10
  @enemy_decks = missions + [OpenStruct.new(name: :Gauntlet, value: :LV24BR)]
  slim :simple_job
end

get '/job/raid_job' do
  @structures = File.read('raid_structs.txt')
  @enemy_level = 21
  @enemy_decks = File.read('current_raid.txt').split("\n")
  slim :simple_job
end

get '/job/create' do
  slim :create
end

post '/job/create' do
  cmd_args = []

  response.set_cookie(
    'player',
    value: params['username'],
    expires: Time.now + 30.days,
    path: '/'
  )

  enemy_deck = params['enemy_deck'].tr("'", '')
  command = params['command'].tr("'", '')
  cmd_count = params['cmd_count']
  user = params['username'].gsub(/[^a-zA-Z0-9]+/, '_').downcase

  job = Job.new
  job.created_at = Time.now

  ed_cmd = enemy_deck + (missions.include?(enemy_deck) ? "-#{params['enemy_level']}": '')

  inv = inventory(params, user)

  p params
  p ed_cmd

  cmd_args << "'#{your_deck(params)}'"
  cmd_args << "'#{ed_cmd}'"
  cmd_args << '-r' if params['ordered']
  cmd_args << "'#{command}'"
  cmd_args << "'#{cmd_count}'"
  cmd_args << "-e '#{params['bge']}'" if params['bge'] && !params['bge'].empty?
  cmd_args << "-s" if params['mode'] == 'surge'
  cmd_args << "-o='#{inv}'" if inv
  cmd_args << "yf '#{params['your_structs']}'" unless params['your_structs'].empty?
  cmd_args << "ef '#{params['enemy_structs']}'" unless params['enemy_structs'].empty?
  cmd_args << "_gauntlets _ctn _japaneseman"

  if command == 'climb' && !params['fund'].empty?
    cmd_args << "fund #{params['fund']}"
  end

  mode = params['mode'] == 'surge' ? 'surge' : 'fight'
  attrs = [command, mode, params['bge'], params['your_structs'], params['enemy_structs']].reject(&:empty?)

  job.name = "vs. #{enemy_deck} (#{attrs.join(',')})"
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

get '/job/list' do
  @jobs = Job.list
  @players = @jobs.map(&:user).uniq.compact.sort

  slim :list
end

get '/job/:id' do
  @job = Job.where(id: params['id']).first
  slim :job
end

def missions
  File.read('missions.txt').split(/\n/)
end

def your_deck(params)
  return params['your_deck'].tr("'", '') if params['your_deck']

  if p = Player.find(slug: Player.cleanup(params['username']))
    p.update_deck_and_inventory
    if p.deck
      JSON.parse(p.deck).join(',').tr("'", '')
    else
      "#{params['username']}-ATK"
    end
  else
    "#{params['username']}-ATK"
  end
end

def inventory(params, user)
  inventory_file = nil

  # update from form
  if params['your_inventory_file']
    inventory_file = "/tmp/#{user}.txt"
    # save inventory file
    File.open(inventory_file, 'w') do |f|
      f.write(params['your_inventory_file'][:tempfile].read)
    end
    inventory_file
  elsif params['your_inventory']
    params['your_inventory'].tr("'", '')
  elsif p = Player.find(slug: Player.cleanup(params['username']))
    p.update_deck_and_inventory

    if p.inventory
      JSON.parse(p.inventory).join(',').tr("'", '')
    elsif File.exist? "/tmp/#{user}.txt"
      "/tmp/#{user}.txt"
    end
  elsif File.exist? "/tmp/#{user}.txt"
    "/tmp/#{user}.txt"
  end
end

def bges
  File.read("bges.txt")
    .split(/\n/)
end

def guild_decks
  File.read("#{Job::TUO_DIR}/data/customdecks_ctn.txt")
    .split(/\n/)
    .select { |l| l =~ /:/ }
    .map { |l| l.split(':')[0] }
    .sort
end
