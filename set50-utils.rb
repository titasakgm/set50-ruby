#! C:\Ruby193\bin\ruby.exe

require 'rubygems'
require 'mongo'

class Set50
	def initialize
		@con = Mongo::Connection.new("127.0.0.1")
		@db = @con['set50']
		@quotes = @db['quotes']
	end
	
	def get_time_series(date)
		times = @quotes.distinct(:time,{:date => date}).sort
	end
	
	def get_stock_info(date,sym)
		info = []
		old_vol = 0
		self.get_time_series(date).each do |tm|
			i = @quotes.find({:date => date, :symbol => sym, :time => tm})
			i.each do |doc|
				bid = doc['bid']
				vol_bid = doc['vol_bid']
				offer = doc['offer']
				vol_offer = doc['vol_offer']
				close = doc['close']
				volume = doc['volume']
				vol_chg = (old_vol == 0) ? volume : volume - old_vol
				old_vol = volume
				value = doc['value']
				info << {
					:symbol => sym, :date => date, :time => tm, :bid => bid, :vol_bid => vol_bid,
					:offer => offer, :vol_offer => vol_offer, :close => close,
					:volume => volume, :vol_chg => vol_chg, :value => value
				}
			end
		end
		info
	end
end
