#!/bin/env ruby
# encoding: utf-8

require 'nokogiri'
require 'pry'
require 'scraperwiki'

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

def scrape_term_8(url)
  noko = noko_for(url)
  noko.xpath('//table[.//th[contains(.,"Lista e Deputeteve")]]//ul//li').each do |li|
    data = { 
      name: li.at_xpath('.//text()').text.tidy,
      wikiname__sq: li.xpath('.//a[not(@class="new")]/@title').text,
      area: li.xpath('preceding::b').last.text.gsub('Qarku ','').tidy,
      party: li.xpath('preceding::p').last.text.tidy,
      term: '8',
      source: url,
    }
    ScraperWiki.save_sqlite([:name, :area, :party, :term], data)
  end
end

def scrape_term_7(url)
  noko = noko_for(url)
  noko.xpath('//table[.//th[contains(.,"Party")]]').each do |ctable|
    constituency = ctable.xpath('preceding::h3/span[@class="mw-headline"]').last.text
    ctable.xpath('.//tr[td]').each do |tr|
      tds = tr.css('td')
      data = { 
        name: tds[1].css('a').first.text.tidy,
        wikiname__en: tds[1].xpath('.//a[not(@class="new")]/@title').text,
        area: constituency,
        party: tds[2].css('a').first.text.tidy,
        term: '7',
        source: url,
      }
      ScraperWiki.save_sqlite([:name, :area, :party, :term], data)
    end
  end
end


scrape_term_8('https://sq.wikipedia.org/wiki/Kuvendi_i_Shqip%C3%ABris%C3%AB')
scrape_term_7('https://en.wikipedia.org/wiki/List_of_members_of_the_parliament_of_Albania,_2009%E2%80%932013')

