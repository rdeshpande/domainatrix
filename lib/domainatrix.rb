$LOAD_PATH.unshift(File.dirname(__FILE__)) unless $LOAD_PATH.include?(File.dirname(__FILE__))

require 'addressable/uri'
require 'domainatrix/domain_parser.rb'
require 'domainatrix/url.rb'

module Domainatrix
  VERSION = "0.0.7"

  def self.parse(url)
    @domain_parser ||= DomainParser.new("#{File.dirname(__FILE__)}/effective_tld_names.dat")
    parsed = @domain_parser.parse(url)
    Url.new(parsed) if parsed
  end

  def self.scan(text, &block)
    @schemes ||= %w(http https)
    all_trailing_clutter = /[.,:);]+$/
    clutter_without_parens = /[.,:);]+$/

    candidate_urls = URI.extract(text, @schemes)
    candidate_urls.map! do |url|
      # If the URL has an open paren, allow closing parens.
      if url.include?("(")
        url.gsub(clutter_without_parens, '')
      else
        url.gsub(all_trailing_clutter, '')
      end
    end

    urls = candidate_urls.map do |url|
      parse(url) rescue nil
    end.compact
    urls.map!(&block) if block
    urls
  end
end
