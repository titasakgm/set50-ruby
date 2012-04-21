#! C:\Ruby193\bin\ruby.exe

require 'D:\\SET\\set50-utils'

coll = "quotes"
date = "20120405"
sym = "ADVANC"

con = Mongo::Connection.new("127.0.0.1")
db = con['set50']
quotes = db['quotes']

s = Set50.new
times = s.get_time_series(date)

info = s.get_stock_info(date,sym)

info.each do |h|
	time = h[:time]
	bid = h[:bid]
	offer = h[:offer]
	close = h[:close]
	exec = (close == bid) ? 'bid' : 'offer'
	vol_chg =  h[:vol_chg] 
	p "#{time} #{bid}:#{offer}|#{exec} ==> #{vol_chg}"
end




