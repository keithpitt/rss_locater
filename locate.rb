require 'rubygems'
require 'hpricot'
require 'active_record'

ActiveRecord::Base.establish_connection({
    :adapter => "postgresql",
    :username => "keith",
    :database => "yogle"
})

module Yogle

	HEADER = 'Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.9.0.5) Gecko/2008121622 Ubuntu/8.04 (hardy) Firefox/3.0.5'

	class RssFeed < ActiveRecord::Base
		set_primary_key :created_at
	end

	module GoogleSeeder

		PAGES = 10

		def self.crawl(tag)
			urls = []
			puts "Seeding: #{tag}"
			PAGES.times do |idx|
				page = idx * 10
				url = "http://www.google.com/search?q=#{tag}&start=#{page}"
				out = %x(wget -U "#{Yogle::HEADER}" -qO- "#{url}")
				doc = Hpricot(out)
				urls << (doc/"h3.r a.l").map { |l| l.attributes['href'] }
			end
			return urls.flatten
		end

	end

	module RssFinder

		def self.start
			seeds = File.open('output_seeds.txt').readlines
			url = 'http://www.google.com'
			#	Thread.new do
					Yogle::RssFinder.crawl(url)
			#	end
		end

		def self.crawl(url)
			IO.popen("wget -U '#{Yogle::HEADER}' -qO- '#{url}' -r") do |f|
				puts f.gets
			end 
		end

	end

	def self.google_crawl

		tags = %w(ruby bebo myspace metacafe radioblog wiki video shopping cooking boat sport politics news food weather fasion televion movies rails php mysql postgresql twitter blog rss feed feedburner tumblr blogger wordpress mephisto facebook radio open source code wikipedia)

		puts "Starting seed crawler..."
		seed_urls = tags.map{ |tag| GoogleSeeder.crawl(tag) }.flatten

		File.open("output_seeds.txt", "w+") { |x| x.write seed_urls.join("\n") }

		puts "Done!"

	end

end

Yogle::RssFinder.start
#Yogle.google_crawl
