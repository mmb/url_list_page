# == Usage
#   url_list_page.rb input output [options]
#
#   input is a file path or url or - for stdin
#   output is a file path
#
# == Options
#   -h, --help             displays help message
#   -c, --css CSS_URL      css url
#   -t, --title PAGE_TITLE page title

require 'embed_flickr'
require 'embed_img'
require 'embed_vimeo'
require 'embed_youtube'
require 'urltitles'

require 'rubygems'
require 'builder'

require 'open-uri'
require 'optparse'
require 'rdoc/usage'
require 'yaml'

options = { 
  :css => 'http://matthewm.boedicker.org/screen.css',
  :title => 'urls',
  :meta => [
    {:name => 'viewport', :content => 'initial-scale=1.0'},
    ],
}

if ARGV.length < 2
  RDoc::usage()
else
  if ARGV[0] == '-'
    options[:in] = STDIN
  else
    options[:in] = open(ARGV[0])
  end

  options[:out] = ARGV[1]
end

OptionParser.new do |opts|
  opts.on('-c', '--css CSS_URL', 'css url') { |css| options[:css] = css }
  opts.on('-t', '--title PAGE_TITLE', 'page title') do |title|
    options[:title] = title
  end
end.parse!(ARGV[2..-1])

$url_titles = UrlTitles::UrlTitles.new('url_titles_cache.yaml')

js = <<-EOS
$(document).ready(function() {
  $('div.embed').toggle(false);
  $('input.show').click(function() {
    $(this).nextAll('div.embed').toggle('slow', function() {
	if ($(this).html().length == 0) {
          var embed = $(this).prevAll('input.embed').val();
          $(this).html(embed);
	}
    });
    if ($(this).val() == 'Hide') {
      $(this).val('Show');
    } else {
      $(this).val('Hide');
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
output = xm.html(:xmlns => 'http://www.w3.org/1999/xhtml',
  :'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
  :'xsi:schemaLocation' => 'http://www.w3.org/MarkUp/SCHEMA/xhtml11.xsd',
  :'xml:lang' => 'en') {
  xm.head {
    xm.title(options[:title]) if options[:title]
    options.fetch(:meta, []).each { |m| xm.meta(m) }
    if options[:css]
      xm.link(:rel => 'stylesheet', :type => 'text/css', :href => options[:css])
    end
    xm.script('', :type => 'text/javascript',
      :src => 'http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js')
  }
  xm.body {
    xm.ul {
      options[:in].each_line do |url|
        url.strip!
        xm.li(:class => (STDIN.lineno % 2 == 0 ? 'even' : 'odd')) {
          xm.a($url_titles.get(url).strip, :href => url)
          embed = nil
          embedders.each do |embedder|
            embed = embedder.embed(url)
            break unless embed.nil?
          end
          unless embed.nil?
            xm.text! ' '
            xm.input(:type => 'button', :class => 'show', :value => 'Show')
            xm.input(:type => 'hidden', :class => 'embed', :value => embed)
            xm.div(:class => 'embed') { }
          end
        } unless url.empty?
      end
    }
    xm.script(js, :type => 'text/javascript')
    xm.p {
      xm.text! 'generated by '
      xm.a('url_list_page', :href => 'http://github.com/mmb/url_list_page/tree/master')
    }
  }
}

open(options[:out], 'w') { |f| f.write(output) }

EmbedFlickr::THUMBS_CACHE.save
EmbedVimeo::HTMLS_CACHE.save
$url_titles.save
