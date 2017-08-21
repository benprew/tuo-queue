# facade for Tyrant app

require 'json'
require 'httparty'

class Tyrant
  CARDS_FILE = '/var/local/tuo-queue/tuo/data/cards.json'
  include HTTParty
  base_uri 'http://mobile.tyrantonline.com'

  CONFIG_FILE = "/home/throwingbones/.tyrant_config"
  def self.load_config
    return unless File.exist? CONFIG_FILE
    @config = JSON.parse(File.read(CONFIG_FILE))
  end

  def self.api_request(guild, message, params={})
    body = {
      password: @config[guild]['password'],
      syncode: @config[guild]['syncode'],
      user_id: @config[guild]['user_id']
    }.merge(params)

    JSON.parse(post(
      "/api.php?message=#{message}",
      body: body
    ))
  rescue NoMethodError
    {}
  end

  def self.guild_player_ids(guild_name='')
    api_request(guild_name, 'updateFaction')['faction']['members'].keys
  rescue NoMethodError
    []
  end

  def self.inventory(guild, params)
    api_request(guild, 'init', params)['user_cards']
      .map { |id, v| [id.to_i, v['num_owned'].to_i] }
      .select { |e| e[1] > 0 }
      .map { |info| "#{card_id_to_name(info[0])} (#{info[1]})" }
  rescue NoMethodError
    []
  end

  def self.guildmate(guild, player_id)
    api_request(guild, 'getProfileData', target_user_id: player_id)['player_info']
  end

  def self.card_ids_to_name(ids)
    ids.map { |id| card_id_to_name(id) }
  end

  def self.card_id_to_name(id)
    @cards ||= JSON.parse(File.read(CARDS_FILE))
    "#{@cards[id.to_s]['name']}-#{@cards[id.to_s]['level']}"
  rescue
    update_cards
    retry
  end

  def self.update_cards
    @cards = JSON.parse(File.read(CARDS_FILE))
  end

  load_config
end
