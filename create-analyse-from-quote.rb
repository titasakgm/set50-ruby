#!C:\Ruby193\bin\ruby.exe

require 'rubygems'
require 'mongo'

def insert_analyses(con,date,time,sym,perc_volume,close,change)
	db = con['stock']
	coll = db['analyses']
  doc = {
		:date => date,
		:time => time,
		:symbol => sym,
		:perc_volume => perc_volume,
		:close => close,
		:change => change
	}
	coll.insert(doc)
end

t = Time.now
yy = t.year
mm = sprintf("%02d", t.mon)
dd = sprintf("%02d", t.day)
date = "#{yy}#{mm}#{dd}"

con = Mongo::Connection.new("127.0.0.1")
db = con['stock']
coll = db['quotes']
tms = coll.distinct('time',{'date' => date}).sort()
time = tms.last
res = coll.find({'date' => date, 'time' => time}).sort(['perc_volume',-1]).limit(10)
res.each do |doc|
  id = doc['_id']
  date = doc['date']
  time = doc['time']
  sym = doc['symbol']
	perc_volume = doc['perc_volume']
  close = doc['close']
  change = doc['change']
  insert_analyses(con,date,time,sym,perc_volume,close,change)
end
