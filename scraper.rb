#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'open-uri'
require 'colorize'
require 'wikidata'

require 'pry'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class String
  def tidy
    self.gsub(/[[:space:]]+/, ' ').strip
  end
end

def noko_for(url)
  Nokogiri::HTML(open(url).read) 
end

def scrape_list(url)
  noko = noko_for(url)

  noko.xpath('//table[.//th[contains(.,"Lista e Deputeteve")]]//ul//li').each do |li|
    data = { 
      name: li.at_xpath('.//text()').text.tidy,
      wikiname: li.xpath('.//a[not(@class="new")]/@title').text,
      area: li.xpath('preceding::b').last.text.tidy,
      party: li.xpath('preceding::p').last.text.tidy,
      term: '8',
      source: url,
    }
    ScraperWiki.save_sqlite([:name, :area, :party, :term], data)
  end
end

scrape_list('https://sq.wikipedia.org/wiki/Kuvendi_i_Shqip%C3%ABris%C3%AB')
