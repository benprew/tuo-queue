require 'mechanize'

class Loki
  def self.login
    @mech = Mechanize.new
    login = @mech.get 'https://tuo-results.dieser-loki.de/login'

    f = login.forms.first

    f._username = ENV['LOKI_USERNAME']
    f._password = ENV['LOKI_PASSWORD']
    @mech.submit(f, f.buttons.first)
  end

  def self.deck(player_id)
    page = @mech.get(cards_url(player_id))
    page.search('#deck/tbody/tr').map { |e| e.at_xpath('td[1]/text()').to_s.strip }
  end

  def self.inventory(player_id)
    page = @mech.get(cards_url(player_id))
    page.search('#ownedCards/tbody/tr').map { |e| e.at_xpath('td[1]/text()').to_s.strip }
  end

  def self.cards_url(id)
    "/ownedcard/#{id}/cards"
  end
end
