require 'cachedhash'

require 'open-uri'
require 'rexml/document'

module FlickrThumbs

  FLICKR_API_KEY = ''

  class FlickrThumbs < CachedHash::CachedHash

    def lookup(key)
      # puts "flickr lookup #{key}"
      result = ''
      begin
        open("http://api.flickr.com/services/rest/?api_key=#{FLICKR_API_KEY}&method=flickr.photos.getinfo&photo_id=#{key}") do |f|
          doc = REXML::Document.new(f.read)
          farm = doc.root.elements['//rsp/photo/@farm']
          secret = doc.root.elements['//rsp/photo/@secret']
          server = doc.root.elements['//rsp/photo/@server']
          unless farm.nil? or secret.nil? or server.nil?
            result = "http://farm#{farm.value}.static.flickr.com/#{server.value}/#{key}_#{secret.value}_m.jpg"
          end
        end
      rescue Exception => e
        # puts e.message
      end
      result
    end
  end

end
