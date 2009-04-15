require 'vimeohtmls'

module EmbedVimeo

  HTMLS_CACHE = VimeoHtmls::VimeoHtmls.new('vimeo_htmls_cache.yaml')

  def EmbedVimeo.vimeo_id(url)
    match = Regexp.new('http://(?:www\.)?vimeo\.com/(\d+)',
      Regexp::IGNORECASE).match(url)
    match[1] if match
  end

  class Embedder
 
    def embed(url)
      id = EmbedVimeo::vimeo_id(url)
      EmbedVimeo::HTMLS_CACHE.get(id) unless id.nil?
    end

  end

end
