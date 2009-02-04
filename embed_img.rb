require 'rubygems'
require 'builder'

module EmbedImg

  def EmbedImg.is_img?(url)
    Regexp.new('^https?://[a-z0-9\./\?&%\-_:=;,~]*?\.(jpg|jpeg|gif|png)$',
      Regexp::IGNORECASE).match(url)
  end

  class Embedder

    def embed(url)
      if EmbedImg::is_img?(url)
        xm = Builder::XmlMarkup.new
        xm.a(:href => url) {
          xm.img(:src => url, :alt => '')
        }
      end
    end

  end

end
