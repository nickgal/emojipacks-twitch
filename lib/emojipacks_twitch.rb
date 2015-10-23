require 'bundler'
require 'yaml'
require 'open-uri'
Bundler.require

class EmojipacksTwitch
  def self.build
    # from https://twitchemotes.com/apidocs
    # currently ~ 67,000 emotes
    json_file = open('http://twitchemotes.com/api_cache/v2/images.json')
    images_hash = JSON.parse json_file.read
    output_hash = {
      'title' => 'Twitch'
    }
    output_hash['emojis'] = images_hash['images'].map do |image_id, details|
      {
        'name' => details['code'].downcase,
        'src' => "https://static-cdn.jtvnw.net/emoticons/v1/#{image_id}/1.0"
      }
    end
    File.open('twitch.yml', 'w') do |f|
      f.write output_hash.to_yaml
    end
  end

  def self.build_global
    url = 'http://twitchemotes.com/api_cache/v2/global.json'
    global_json = JSON.parse open(url).read
    image_template = "https:#{global_json['template']['small']}"
    output_hash = {
      'title' => 'Twitch Global Emotes'
    }
    output_hash['emojis'] = global_json['emotes'].map do |code, obj|
      src = image_template.sub('{image_id}', obj['image_id'].to_s)
      {
        'name' => code.downcase,
        'src' => src
      }
    end
    File.open('twitch-global.yml', 'w') do |f|
      f.write output_hash.to_yaml
    end
  end
end
