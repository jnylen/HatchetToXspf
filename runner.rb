require 'rubygems'
require 'httparty'
require 'nokogiri'
require 'oj'

# Playlist id
playlist_id = ARGV[0]
puts "No id supplied." if playlist_id.nil?

# json
puts "Fetching data from Hatchet..."
response = HTTParty.get('https://api.hatchet.is/v2/playlistEntries?playlist_id=' + playlist_id.to_s)
json = Oj.load(response.body)

# Pass them into a hash
puts "Going through artists and albums.."
artists = {}
json["artists"].each do |artist|
  artists[artist["id"]] = artist["name"]
end

albums = {}
json["albums"].each do |album|
  albums[album["id"]] = album["name"]
end


# XSPLF maker
puts "Building XSPF.."
@builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
  xml.playlist('version' => '1', "xmlns" => "http://xspf.org/ns/0/") {
    xml.title json["playlists"][0]["title"]

    xml.trackList {
      json["tracks"].each do |track|
        xml.track {
          xml.title track["name"]
          xml.creator artists[track["artist"]]
          #xml.album = albums[track["album"]] # no way to match these
          xml.location track["url"]
        }
      end
    }
  }
end

puts "Writing to file: playlist_" + playlist_id.to_s + ".xspf"
File.write("playlist_" + playlist_id.to_s + ".xspf", @builder.to_xml)
