require 'nokogiri'
require 'json'
require 'open-uri'
require 'pry'
require 'trello'
require 'grape'

class Listing
  attr_reader :area, :price_per_foot, :rooms, :beds, :baths, :building_title, :price, :picture, :description

  def self.from_uri(uri)
    user_agent = "Mozilla/5.0"
    data =  Nokogiri::HTML(open(uri, "User-Agent" => user_agent))

    Listing.new(data)
  end

  def initialize(page)
    @price = extract(page.css(".details_info_price .price").children[0])
    @picture = page.css("#image-0").attribute("data-src").value
    @description = extract(page.css(".Description-block"))

    @building_title = extract(page.css(".building-title"))
    details = page.css(".details_info")

    @area = extract(details.children[0])
    @price_per_foot = extract(details.children[1])
    @rooms = extract(details.children[2])
    @beds = extract(details.children[3])
    @baths = extract(details.children[4])
  end

  private

  def extract(element)
    element.text.strip
  end
end


Trello.configure do |config|
  config.developer_public_key = ENV['TRELLO_DEVELOPER_PUBLIC_KEY'] # The "key" from step 1
  config.member_token = ENV['TRELLO_MEMBER_TOKEN'] # The token from step 2.
end


def description(listing)
  <<~DESC
* **Price**: #{listing.price}
* **Beds**: #{listing.beds}
* **Bath**: #{listing.baths}
* **Area**: #{listing.area}
* **Price/ft**: #{listing.price_per_foot}

Blurb
----------------
#{listing.description}
#
  DESC
end

def picture(listing)
  file = Tempfile.new(['trello-picture', 'jpg'])
  open(listing.picture) {|f|
    file.puts f.read
  }

  file.close

  File.open(file, "r")
end

def create_trello_card(listing, uri)
  card = Trello::Card.create({
    name: "#{listing.building_title} - #{listing.price}",
    list_id: ENV['TRELLO_LIST_ID'],
    desc: description(listing)
  })

  card.add_attachment(uri, "Streeteasy")
  card.add_attachment(picture(listing), "picture")
  card
end

module SeScraper
  class API < Grape::API
    format :json

    resource :cards do
      desc 'Create new Card'
      params do
        requires :url, type: String, desc: 'StreetEasy URL'
      end

      post do
        listing = Listing.from_uri(params[:url])
        card = create_trello_card(listing, params[:url])
        card.to_json
      end
    end
  end
end
