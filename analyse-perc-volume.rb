#!C:\Ruby193\bin\ruby.exe

require 'rubygems'
require 'mongo'

def insert_analyses(con, date, time, sym, perc_volume,close,change)
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
	p "doc: #{doc}"
	coll.insert(doc)
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
	tms = coll.distinct('time',{'date' => date}).sort()
	
	tms.each do |tm|
		res = coll.find({'date' => date, 'time' => tm}).sort(['perc_volume',-1]).limit(10)
		res.each do |doc|
			id = doc['_id']
			date = doc['date']
			time = doc['time']
			sym = doc['symbol']
			perc_volume = doc['perc_volume']
			close = doc['close']
			change = doc['change']
			p "#{date},#{time},#{sym},#{perc_volume},#{close},#{change}"
			insert_analyses(con, date, time, sym, perc_volume,close,change)
		end
	end
end

t2 = Time.now
p "Total Time: #{t2-t1} seconds"