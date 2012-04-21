#!C:\Ruby193\bin\ruby.exe

require 'rubygems'
require 'mongo'

def update_quotes (con, id, perc_volume)
	db = con['stock']
	coll = db['quotes']
	coll.update({'_id' => id},{"$set" => {'perc_volume' => perc_volume}})
end

def get_close_vol (date)
  con = Mongo::Connection.new
	db = con['stock']
	coll = db['closes']
	dd = coll.distinct('date').sort()
	i = dd.index(date)
	closedate = i.nil? ? dd.last : dd[i-1]
	p "closedate: #{closedate}"
  res = coll.find({'date' => closedate})	
	con.close
	
	h = {}
	res.each do |doc|
		sym = doc['symbol']
		close_vol = doc['volume'].to_i
		h[sym] = close_vol
	end
  h
	#p "date: #{closedate} symbol: #{sym} close_vol: #{close_vol}"
end

t1 = Time.now
p t1
con = Mongo::Connection.new
db = con['stock']
coll = db['quotes']
dates = coll.distinct('date').sort()

dates.each do |date|
	closex = get_close_vol(date)
	p Time.now
	p closex
	res = coll.find({'date' => date}).sort([['symbol',1],['time',1]])
	n = 0
	res.each do |doc|
		n += 1
		id = doc['_id']
		sym = doc['symbol']
		date = doc['date']
		time = doc['time']
		vol = doc['volume'].to_i
		last_close_vol = closex[sym]
		next if last_close_vol.nil?
		perc_volume = sprintf("%0.2f", vol * 100.0 / last_close_vol).to_f
		p "#{n}: #{date},#{time},#{sym},#{last_close_vol},#{perc_volume}"
		update_quotes(con, id, perc_volume)
	end
end

t2 = Time.now
p "Total Time: #{t2-t1} seconds"