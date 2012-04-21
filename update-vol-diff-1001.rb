#!C:\Ruby193\bin\ruby.exe

require 'rubygems'
require 'mongo'

def update_quotes (id, vol_diff)
  con = Mongo::Connection.new
	db = con['stock']
	coll = db['quotes']
	coll.update({'_id' => id},{"$set" => {'vol_diff' => vol_diff}})
  con.close
end

def get_1001_vol (date, sym)
  con = Mongo::Connection.new
	db = con['stock']
	coll = db['quotes']
  doc = coll.find({'date' => date, 'time' => '10:01', 'symbol' => sym})
  con.close
	
	volume = 0
	doc.each do |d|
		volume = d['volume'].to_i
	end
  volume
end

con = Mongo::Connection.new
db = con['stock']
coll = db['quotes']

res = coll.find({'time' => '10:02'}).sort([['date',1],['symbol',1]])

res.each do |doc|
	id = doc['_id']
	sym = doc['symbol']
	date = doc['date']
	time = doc['time']
	vol = doc['volume'].to_i
	old_vol = get_1001_vol(date,sym)
	vol_diff = vol - old_vol
	p id,sym,date,time,vol_diff,old_vol
	update_quotes(id, vol_diff)
end
