require 'cachedhash'

require 'open-uri'
require 'rexml/document'

module VimeoHtmls

  class VimeoHtmls < CachedHash::CachedHash

    def lookup(key)
      # puts "vimeo lookup #{key}"
      result = ''
      begin
        open("http://vimeo.com/api/oembed.xml?url=http%3A//vimeo.com/#{key}") do |f|
          doc = REXML::Document.new(f.read)
	  node = doc.root.elements['//oembed/html/text()']
          result = node.value unless node.nil?
        end
      rescue Exception => e
        # puts e.message
      end
      result
    end
  end

end
