require 'rubygems'
require 'builder'

module EmbedYoutube

  def EmbedYoutube.youtube_id(url)
    match = Regexp.new('http://(?:(?:www|uk)\.)?youtube\.com/watch\?v=(.+?)(?:&|$)',
      Regexp::IGNORECASE).match(url)
    match[1] if match
  end

  class Embedder
 
    def embed(url)
      id = EmbedYoutube::youtube_id(url)
      unless id.nil?
        movie = "http://www.youtube.com/v/#{id}&hl=en&fs=1&showsearch=0"
        xm = Builder::XmlMarkup.new
        xm.object(:type => 'application/x-shockwave-flash',
          :width => 425,
          :height => 344,
          :data => movie) {
          xm.param(:name => 'movie', :value => movie)
        }
      end
    end

  end

end
