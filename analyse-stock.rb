#! C:\Ruby193\bin\ruby.exe

require 'rubygems'
require 'net/http'
require 'mongo'

def save_analyse(date,time,sym,bid,vol_bid,offer,vol_offer,close,volume,perc_vol_chg,value,perc_val_chg)
	con = Mongo::Connection.new("127.0.0.1")
	db   = con['set50']
	coll = db['analyses']	
  doc = {
		'date' => date,
		'time' => time,
		'symbol' => sym,
		'bid' => bid,
		'vol_bid' => vol_bid,
		'offer' => offer,
		'vol_offer' => vol_offer,
		'close' => close,
		'volume' => volume,
		'perc_vol_chg' => perc_vol_chg,
		'value' => value,
		'perc_val_chg' => perc_val_chg
	}
	coll.insert(doc)
	con.close
end

def get_stats(date, time, symbol)
	con = Mongo::Connection.new("127.0.0.1")
	db   = con['set50']
	coll = db['quotes']	
	res = coll.find_one({:date => date, :time => time, :symbol => symbol},
	                          {:fields => {:bid => 1, :vol_bid => 1,
														                  :offer => 1, :vol_offer => 1,
																							:close => 1, :volume => 1,:value => 1} })
	con.close
  bid = res['bid']
	vol_bid = res['vol_bid']
	offer = res['offer']
	vol_offer = res['vol_offer']
	close = res['close']
	volume = res['volume']
	value = res['value']
	info = [bid,vol_bid,offer,vol_offer,close,volume,value]
end

def get_close(date, symbol)
	con = Mongo::Connection.new("127.0.0.1")
	db   = con['set50']
	coll = db['closes']	
	res = coll.find_one({:date => date, :symbol => symbol},
	                          {:fields => {:close => 1,:volume => 1,:value => 1} })
	con.close
	close = res['close'].to_f
	vol = res['volume'].to_i
	val = res['value'].to_i
	info = [close,vol,val]
end

def get_newest(date)
	con = Mongo::Connection.new("127.0.0.1")
	db   = con['set50']
	coll = db['quotes']	
	res = coll.find_one({:date => date},{:fields => {:time => -1} })
	con.close
	time = nil
	res.each do |doc|
		#["time", "14:35"]
		time = doc[1]
	end
	time
end

def analyse(sym)
puts "sym: #{sym}"
t = Time.now - 24 * 60 * 60
t_prev = t - 24 * 60 * 60

yy = t.year
mm = sprintf("%02d", t.mon)
dd = sprintf("%02d", t.day)
hr = sprintf("%02d", t.hour)
mn = sprintf("%02d", t.min)

yy_prev = t_prev.year + 543
mm_prev = sprintf("%02d", t_prev.mon)
dd_prev = sprintf("%02d", t_prev.day)

date = "#{yy}#{mm}#{dd}"
date_prev = "#{dd_prev}/#{mm_prev}/#{yy_prev}"

("16:00" .. "16:30").each do |tm|
	info = get_close(date_prev, sym)
	close_prev = info[0]
	vol_prev = info[1]
	val_prev = info[2]
	info = get_stats(date,tm,sym)
	bid = info[0]
	vol_bid = info[1]
	offer = info[2]
	vol_offer = info[3]
	close = info[4]
	volume = info[5]
	value = info[6]
	perc_vol_chg = sprintf("%0.2f", volume * 100.0 / vol_prev).to_f
	perc_val_chg = sprintf("%0.2f", value * 100.0 / val_prev).to_f
	save_analyse(date,tm,sym,bid,vol_bid,offer,vol_offer,close,volume,perc_vol_chg,value,perc_val_chg)
end
end

t1 = Time.now

#if sym.nil?
#	puts "usage: analyse-stock.rb <SYMBOL>\n"
#	exit(0)
#end

ss = open("SET50.txt").readlines
ss.each do |s|
	sym = s.chomp
	analyse(sym)
end


t2 = Time.now
puts "Time: #{t2-t1} seconds"