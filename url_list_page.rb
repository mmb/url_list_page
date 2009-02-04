require 'embed_flickr'
require 'embed_img'
require 'embed_vimeo'
require 'embed_youtube'
require 'urltitles'

require 'yaml'

require 'rubygems'
require 'builder'

$url_titles = UrlTitles::UrlTitles.new('url_titles_cache.yaml')

js = <<-EOS
$(document).ready(function() {
  $('div.embed').toggle();
  $('input.show').click(function() {
    $(this).parent().children('div.embed').toggle('slow');
    if ($(this).attr('value') == 'Hide') {
      $(this).attr('value', 'Show');
    } else {
      $(this).attr('value', 'Hide');
    }
  });
});
EOS

embedders = Module.constants.select {
  |c| /^Embed/.match(c) }.collect {
    |e| eval("#{e}::Embedder").new }.select {
      |i| i.respond_to?(:embed) }

xm = Builder::XmlMarkup.new
xm.instruct! :xml
xm.declare! :DOCTYPE, :html, :PUBLIC, '-//W3C//DTD XHTML 1.1//EN',
  'http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd'
puts xm.html(:xmlns => 'http://www.w3.org/1999/xhtml',
  :'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
  :'xsi:schemaLocation' => 'http://www.w3.org/MarkUp/SCHEMA/xhtml11.xsd',
  :'xml:lang' => 'en') {
  xm.head {
    xm.title('urls')
    xm.link(:rel => 'stylesheet', :type => 'text/css', :href => 'screen.css')
    xm.script('', :type => 'text/javascript',
      :src => 'http://ajax.googleapis.com/ajax/libs/jquery/1.3/jquery.min.js')
  }
  xm.body {
    xm.ul {
      STDIN.each_line do |url|
        url.strip!
        xm.li {
          xm.a($url_titles.get(url), :href => url)
          embed = nil
          embedders.each do |embedder|
            embed = embedder.embed(url)
            break unless embed.nil?
          end
          unless embed.nil?
            xm << ' '
            xm.input(:type => 'button', :value => 'Show', :class => 'show')
            xm.div(:class => 'embed') { xm << embed }
	  end
        } unless url.empty?
      end
    }
    xm.script(js, :type => 'text/javascript')
  }
}

EmbedFlickr::THUMBS_CACHE.save
EmbedVimeo::HTMLS_CACHE.save
$url_titles.save
