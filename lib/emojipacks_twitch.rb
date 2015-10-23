require 'bundler'
require 'yaml'
Bundler.require

class EmojipacksTwitch
  def self.build
    # from https://twitchemotes.com/apidocs
    # currently ~ 67,000 emotes
    json_file = open('http://twitchemotes.com/api_cache/v2/images.json')
    images_hash = JSON.parse json_file.read
    output_hash = {
      "title" => 'Twitch'
    }
    output_hash["emojis"] = images_hash["images"].map do |image_id, details|
      {
        "name" => details["code"].downcase,
        "src" => "https://static-cdn.jtvnw.net/emoticons/v1/#{image_id}/1.0"
      }
    end
    File.open('twitch.yml', 'w') do |f|
      f.write output_hash.to_yaml
    end
  end
end
