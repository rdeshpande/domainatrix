$LOAD_PATH.unshift(File.dirname(__FILE__)) unless $LOAD_PATH.include?(File.dirname(__FILE__))

require 'uri'
require 'domainatrix/domain_parser.rb'
require 'domainatrix/url.rb'

module Domainatrix
  VERSION = "0.0.7"

  def self.parse(url)
    @domain_parser ||= DomainParser.new("#{File.dirname(__FILE__)}/effective_tld_names.dat")
    Url.new(@domain_parser.parse(url))
  end

  def self.scan(text, &block)
    @schemes ||= %w(http https)

    urls = URI.extract(text, @schemes).select do |url|
      parse(url) rescue nil
    end
    urls.map!(&block) if block
    urls
  end
end
