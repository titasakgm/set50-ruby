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

con = Mongo::Connection.new
db = con['stock']
coll = db['quotes']

res = coll.find({}).sort([['date',1],['symbol',1],['time',1]])

old_date = nil
old_sym = nil
old_vol = 0

res.each do |doc|
	id = doc['_id']
	sym = doc['symbol']
	date = doc['date']
	time = doc['time']
	vol = doc['volume']
	vol_diff = vol - old_vol
	old_vol = vol
	if (old_sym == nil)
		old_sym = sym
		old_date = date
	elsif old_date != date # Change date
		old_sym = sym
		old_vol = 0
		old_date = date
	elsif old_sym != sym # Change symbol
 		old_vol = 0
		old_sym = sym
	end
	p id,sym,date,time,vol_diff
	update_quotes(id, vol_diff)
end