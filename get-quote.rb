#! C:\Ruby193\bin\ruby.exe

require 'net/http'

def save(stock,date,time)
  dat = stock.join(',')
  dat = "#{date},#{time},#{dat}\n"
  puts dat
end

w = Net::HTTP.new("marketdata.set.or.th")
req = "/mkt/sectorquotation.do?market=A&industry=0"
req += "&sector=95&language=en&country=TH"
resp, data = w.get(req)

data = resp.body
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
	if l =~ /ADVANC/
		start = true
	end
	if start && l =~ /nbsp/
		stock[-1] = stock[-1].to_i * 1000 # Values
		save(stock,date,time)
		break
	end
	if start
		if l =~ /^[A-Z]/
			if count == 0
				stock = [l]
			elsif ['ATO','ATC'].include?(l)
				stock << l
			elsif count == 1 # ignore XD XM ...
				count = 2
				next
			else
				stock[-1] = stock[-1].to_i * 1000 # Values
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