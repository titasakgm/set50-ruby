#! C:\Ruby193\bin\ruby.exe

require 'rubygems'
require 'net/http'
require 'mongo'

def get_last_vol(con,date,time,sym)
  db   = con['stock']
  coll = db['quotes']
	
	old_vol = 0
  tms = coll.distinct('time',{'date' => date,'symbol' => sym}).sort()
	p tms
  if tms.length > 0 # NOT 10:00
    i = tms.index(time)
		if i == 0
			old_vol = 0
		else
			last_time = i.nil? ? tms.last : tms[i-1]
      info = coll.find({'date' => date, 'symbol' => sym, 'time' => last_time})
      info.each do |doc|
	      old_vol = doc['volume']
	    end
		end
	end
	old_vol
end

sym = 'KBANK'
date = '20120412'
time = '10:01'

con = Mongo::Connection.new("127.0.0.1")
p time
p get_last_vol(con,date,time,sym)
