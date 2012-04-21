#! C:\Ruby193\bin\ruby.exe

require 'rubygems'
require 'net/http'
require 'mongo'

def save(stock,date,time)
	@conn = Mongo::Connection.new("127.0.0.1")
	@db   = @conn['set50']
	@coll = @db['quotes']

	symbol = stock[0].to_s.gsub(/bodytext-b/,'')
	return if symbol =~ /^0/ or symbol == 'Last'
	
	if symbol =~ /^SET/ or symbol =~ /mai/
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
			'value' => stock[10].to_i
		}
	end
	
	puts "doc: #{doc}"
	@coll.insert(doc)
	@conn.close
end

t1 = Time.now

w = Net::HTTP.new("marketdata.set.or.th")
req = "/mkt/sectorquotation.do?market=A&industry=0"
req += "&sector=95&language=en&country=TH"
resp, data = w.get(req)

data = resp.body

#prepare for SET INDEX
# /remark/ when start == false -> ignore
# /remakr/ when start == true -> start = false
data = data.gsub(/bodytext-b/,'>bodytext-b<')
data = data.gsub(/remark/,'>remark<')
d = data.split(/\n/)
puts "data.length: #{data.length}"
puts "d.size: #{d.size}"

t = Time.now
yy = t.year
mm = sprintf("%02d", t.mon)
dd = sprintf("%02d", t.day)
hr = sprintf("%02d", t.hour)
mn = sprintf("%02d", t.min)

date = "#{yy}#{mm}#{dd}"
time = "#{hr}:#{mn}"

start = false
count = 0
stock = []

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
		stock[-1] = stock[-1].to_f * 1000 # Values
		save(stock,date,time)
		break
	end
	if start
		if l =~ /^[A-Z]/ or l =~ /bodytext-b/
                        next if l =~ /^X/
			if count == 0
				stock = [l]
				count = 1
				next
			elsif ['ATO','ATC'].include?(l)
				stock << l
			elsif count == 1 # ignore XD XM ...
				count = 2
				next
			else
				stock[-1] = stock[-1].to_f * 1000 # Values
				save(stock,date,time)
				count = 0
				stock = [l]
				next
			end
		else
			stock << l
		end
		count += 1
	end
end

t2 = Time.now
puts "Processing time: #{t2-t1} seconds"