require 'bundler'
require 'yaml'
require 'open-uri'
Bundler.require

class EmojipacksTwitch
  def self.build
    # from https://twitchemotes.com/apidocs
    # currently ~ 67,000 emotes
    json_file = open('https://twitchemotes.com/api_cache/v2/images.json')
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
    File.open('output/twitch.yml', 'w') do |f|
      f.write output_hash.to_yaml
    end
  end

  def self.build_global
    url = 'https://twitchemotes.com/api_cache/v2/global.json'
    global_json = JSON.parse open(url).read

    build_hash global_json, 'Twitch Global Emotes', 'global'
  end

  def self.build_subscriber
    channels = (ENV['CHANNELS'] || '').split(' ')
    url = "https://twitchemotes.com/api_cache/v2/subscriber.json"
    subscriber_json = JSON.parse open(url).read
    channel_json = if channels.empty?
      subscriber_json['channels']
    else
      subscriber_json['channels'].select{ |key,val| channels.include?(key) }
    end

    channel_json.map do |channel_name, json|
      build_hash json, "Twitch Subscriber Emotes - #{channel_name}", channel_name
    end
  end

  def self.build_hash(json, title, filename)
    image_template = 'https://static-cdn.jtvnw.net/emoticons/v1/{image_id}/1.0'
    output_hash = {
      'title' => title
    }
    output_hash['emojis'] = json['emotes'].map do |code, obj|
      unless filename == 'global'
        obj = code
        code = obj['code']
      end
      src = image_template.sub('{image_id}', obj['image_id'].to_s)
      {
        'name' => code.downcase,
        'src' => src
      }
    end
    File.open("output/twitch-#{filename}.yml", 'w') do |f|
      f.write output_hash.to_yaml
    end
  end
end
