require 'httparty'
require 'json'
require 'bundler'
require 'sequel'
require 'sqlite3'

require_relative 'loki'
require_relative 'tyrant'

DB = Sequel.sqlite('/var/local/tuo-queue/job.sqlite3')

DB.create_table? :players do
  primary_key :id
  String :slug
  String :name
  String :guild
  Integer :tyrant_id
  Integer :loki_id
  String :inventory
  String :deck
  unique :slug
end

class Player < Sequel::Model
  def self.cleanup(n)
    return nil unless n
    n.downcase.gsub(/[^a-z0-9]/, '')
  end

  def update_deck_and_inventory
    self.tyrant_id = guess_tyrant_id unless tyrant_id
    self.deck = (tyrant_deck || loki_deck || deck).to_json
    self.inventory = (tyrant_inventory || loki_inventory).to_json
    save
  end

  def guess_tyrant_id
    Tyrant.guild_player_ids(guild).select do |id|
      slug == Player.cleanup(Tyrant.guildmate(guild, id)['name'])
    end.first
  end

  private

  def tyrant_deck
    return nil unless tyrant_id
    Tyrant.deck(guild, tyrant_id)
  end

  def loki_deck
    return nil unless loki_id
    Loki.login
    Loki.deck(loki_id)
  end

  def loki_inventory
    return nil unless loki_id
    Loki.login
    Loki.inventory(loki_id)
  end

  def tyrant_inventory
    return nil unless tyrant_id
    Tyrant.inventory(guild, user_id: tyrant_id)
  end

  def defense_deck
    @info['defense_deck']
  end
end
