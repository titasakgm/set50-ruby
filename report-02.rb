#! C:\Ruby193\bin\ruby.exe

# Report-02

require 'rubygems'
require 'mongo'

sym = "KTB"

con = Mongo::Connection.new("127.0.0.1")
db   = con['set50']
coll = db['analyses']
res = coll.find({:date => "20120405",:symbol => sym}).sort([:time, 1])
con.close

oldv = 0
voldif = 0
res.each do |doc|
	time = doc['time']	
	offer = doc['offer']
	bid = doc['bid']
	vol_offer = doc['vol_offer']
	vol_bid = doc['vol_bid']
	close = doc['close']
	perc_vol_chg = doc['perc_vol_chg']
	volume = doc['volume']
  if oldv == 0
		voldiff = volume
	else
  	voldiff = volume - oldv
	end
	oldv = volume
  bidp = vol_bid * 100 / (vol_bid + vol_offer)
	offp = 100 - bidp
	puts "#{time} [#{bid}=#{offer}]:#{close} [#{offp}=#{bidp}] [#{vol_offer}=#{vol_bid}] #{voldiff}(#{perc_vol_chg})"
end
