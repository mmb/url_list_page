require 'cachedhash'

require 'cgi'
require 'iconv'
require 'net/http'
require 'net/https'
require 'open-uri'
require 'uri'

require 'rubygems'
require 'htmlentities'
require 'hpricot'

module UrlTitles

  class UrlTitles < CachedHash::CachedHash

    def lookup(key)
      # puts "lookup #{key}"

      result = nil
      begin
        uri_parsed = URI.parse(key)

        net_http = Net::HTTP.new(uri_parsed.host, uri_parsed.port)
        net_http.use_ssl = (uri_parsed.scheme == 'https')

        net_http.start do |http|
          if http.request_head(uri_parsed.path)['content-type'].match(
            /^text\/html/)

            f = open(key, 'User-Agent' =>
              'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.4) Gecko/20030624')

            doc = Hpricot(f)

            test_xpaths = ['//html/head/title', '//head/title', '//html/title',
              '//title']

            test_xpaths.each { |xpath|
              if !(doc/xpath).first.nil?
                result = HTMLEntities.new.decode(
                  Iconv.conv('utf-8', f.charset, (doc/xpath).first.inner_html))
                break
              end
            }
          end
        end
      rescue Exception => e
        # puts e.message
      end
      result = key if result.nil? or result.empty?
      result
    end
  end

end

