#! C:\Ruby193\bin\ruby.exe

require 'rubygems'
require 'net/http'
require 'mongo'

def save_bidoffer(con,symbol,date,time,bidoffer)
	db = con['stock']
	coll = db['quotes']
	
	update_query = { "$set" => {
		'bid' => bidoffer[0].to_f,
		'vol_bid' => bidoffer[1].to_i,
		'offer' => bidoffer[2].to_f,
		'vol_offer' => bidoffer[3].to_i
	} }
	p symbol,date,time
	p update_query
	
	coll.update({"symbol" => symbol,"date" => date,"time" => time}, 
									update_query)
end

con = Mongo::Connection.new("127.0.0.1")
ss = open("SET50.txt").readlines
n = 0
i = 0

ss.each do |s|
	n += 1
	i = 0
	bidoffer = []
	sym = s.chomp
	w = Net::HTTP.new("marketdata.set.or.th")
	req = "/mkt/stockquotation.do?symbol=#{sym}&language=th&country=TH"
	resp, data = w.get(req)

	data = resp.body
	d = data.split(/\n/)
	#puts "data.length: #{data.length}"
	#puts "d.size: #{d.size}"
	
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
		if l =~ /^\d/ and l =~ /nbsp/
			start = true
		elsif l =~ /^ATO/
			break
		end
		if start
			next if l.to_i == 0
			i += 1
			l = l.split(' ').first
			bidoffer << l
			if i == 4
				save_bidoffer(con,sym,date,time,bidoffer)
			end
		end
	end
end

