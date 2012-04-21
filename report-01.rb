#! C:\Ruby193\bin\ruby.exe

# Report-01 List all stocks order by perc_vol_chg DESC

require 'rubygems'
require 'mongo'

con = Mongo::Connection.new("127.0.0.1")
db   = con['set50']
coll = db['analyses']
res = coll.find({:date => "20120405",:perc_vol_chg => {"$gt" => 200}}).sort([:perc_vol_chg,-1])
con.close

tm = []
stock = []
pvc = []
res.each do |doc|
	time = doc['time']
	symbol = doc['symbol']
	perc_vol_chg = doc['perc_vol_chg']
	if !stock.include?(symbol)
		tm << time
		stock << symbol
		pvc << perc_vol_chg
	end
end

(0..stock.size-1).each do |n|
	puts "#{tm[n]}: #{stock[n]} --> #{pvc[n]}"
end
