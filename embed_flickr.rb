require 'flickrthumbs'

require 'rubygems'
require 'builder'

module EmbedFlickr

  THUMBS_CACHE = FlickrThumbs::FlickrThumbs.new('flickr_thumbs_cache.yaml')

  def EmbedFlickr.flickr_id(url)
    match = Regexp.new('http://(?:www\.)?flickr\.com/photos/[^/]+?/(\\d+)',
      Regexp::IGNORECASE).match(url)
    match[1] if match
  end

  class Embedder
 
    def embed(url)
      id = EmbedFlickr::flickr_id(url)
      unless id.nil?
        thumb = EmbedFlickr::THUMBS_CACHE.get(id)
        unless thumb.empty?
          xm = Builder::XmlMarkup.new
          xm.a(:href => url) {
            xm.img(:src => thumb, :alt => '')
          }
        end
      end
    end

  end

end
