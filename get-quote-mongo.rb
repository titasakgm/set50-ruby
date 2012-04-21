#! C:\Ruby193\bin\ruby.exe

require 'rubygems'
require 'net/http'
require 'mongo'

def get_last_vol(con,date,time,sym)
  db   = con['stock']
  coll = db['quotes']
	
	last_vol = 0
  tms = coll.distinct('time',{'date' => date,'symbol' => sym}).sort()
  if tms.length > 0 # NOT 10:00
    i = tms.index(time)
		if i == 0 # 10:00 Not likely
			old_vol = 0
		else
			last_time = i.nil? ? tms.last : tms[i-1]
      info = coll.find({'date' => date, 'symbol' => sym, 'time' => last_time})
      info.each do |doc|
	      last_vol = doc['volume']
	    end
		end
	end
	last_vol
end

def save(con,stock,date,time,close_vol, perc_volume)
	db   = con['stock']
	coll = db['quotes']
	sym = stock[0]
	tms = coll.find({'date' => date,'symbol' => sym}).sort([time,-1]).limit(1)
	symbol = stock[0]
	
	return if symbol =~ /^0/ or symbol == 'Last'
	
	if symbol =~ /^SET/ or symbol =~ /mai/
		volume = stock[6].to_i * 1000
		vol_diff = 0
		doc = {
			'date' => date,
			'time' => time,
			'symbol' => symbol,
			'close' => stock[1].to_f,
			'change' => stock[2].to_f,
			'perc_change' => stock[3].to_f,
			'high' => stock[4].to_f,
			'low' => stock[5].to_f,
			'volume' => stock[6].to_i * 1000,
			'value' => (stock[7].to_f * 1000).to_i
		}
	else
  	last_volume = get_last_vol(con,date,time,sym)
		volume = stock[9].to_i
		vol_diff = volume - last_volume
		doc = {
			'date' => date,
			'time' => time,
			'symbol' => stock[0],
			'open' => stock[1].to_f,
			'high' => stock[2].to_f,
			'low' => stock[3].to_f,
			'close' => stock[4].to_f,
			'change' => stock[5].to_f,
			'perc_change' => stock[6].to_f,
			'bid' => stock[7].to_f,
			'offer' => stock[8].to_f,
			'volume' => stock[9].to_i,
			'value' => stock[10].to_i,
			'vol_diff' => vol_diff,
			'perc_volume' => perc_volume
		}
	end
	p "doc: #{doc}"
	coll.insert(doc)
end

def get_close_vol (date)
  con = Mongo::Connection.new("127.0.0.1")
	db = con['stock']
	coll = db['closes']
	dd = coll.distinct('date').sort()
	i = dd.index(date)
	closedate = i.nil? ? dd.last : dd[i-1]
  res = coll.find({'date' => closedate})	
	con.close
	
	h = {}
	res.each do |doc|
		sym = doc['symbol']
		close_vol = doc['volume'].to_i
		h[sym] = close_vol
	end
  h
end

w = Net::HTTP.new("marketdata.set.or.th")
req = "/mkt/sectorquotation.do?market=A&industry=0"
req += "&sector=95&language=en&country=TH"
resp, data = w.get(req)

data = resp.body

# prepare for SET INDEX
# /remark/ when start == false -> ignore
# /remakr/ when start == true -> start = false
data = data.gsub(/bodytext-b/,'>bodytext-b<')
data = data.gsub(/remark/,'>remark<')
d = data.split(/\n/)

t = Time.now
yy = t.year
mm = sprintf("%02d", t.mon)
dd = sprintf("%02d", t.day)
hr = sprintf("%02d", t.hour)
mn = sprintf("%02d", t.min)

date = "#{yy}#{mm}#{dd}"
time = "#{hr}:#{mn}"

closex = get_close_vol(date)

start = false
count = 0
stock = []
close_vol = 0
perc_volume = 0.0

con = Mongo::Connection.new("127.0.0.1")

d.each do |l|
  l = l.chomp.gsub(/<.*?>/,'').strip
  l = l.tr(',','')
  next if l.length < 1
	if  l =~ /bodytext-b/
		start = true
	end
	if start and l =~ /remark/
		start = false
	end
	if l =~ /ADVANC/
		start = true
	end
	if start && l =~ /nbsp/
		stock[-1] = stock[-1].to_i * 1000 # Values
		volume = stock[9].to_f
		perc_volume = sprintf("%0.2f", volume * 100 / close_vol).to_f  if close_vol > 0
		save(con,stock,date,time,close_vol,perc_volume)
		break
	end
	if start
		if l =~ /^[A-Z][A-Z]/ or l =~ /bodytext-b/
			l = l.gsub(/bodytext-b/,'')
			next if l =~ /^X/
			if count == 0
				stock = [l]
				count = 1
				next
			elsif ['ATO','ATC'].include?(l)
				stock << l
			else
				stock[-1] = stock[-1].to_i * 1000 # Values
				if stock[0] =~ /^SET/ or stock[0] =~ /mai/
          volume = stock[6].to_f
					close_vol = 0
					perc_volume = 0.0
				else
          volume = stock[9].to_f
					close_vol = closex[stock[0]]
					perc_volume = sprintf("%0.2f", volume * 100 / close_vol).to_f
        end
				save(con,stock,date,time,close_vol,perc_volume)
				count = 0
				stock = [l]
				close_vol = closex[l]
				next
			end
		else
			stock << l
		end
		count += 1
	end
end

cmd = "ruby get-bid-offer.rb"
system(cmd)