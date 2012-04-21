#! C:\Ruby193\bin\ruby.exe

require 'rubygems'
require 'net/http'
require 'mongo'

def save_close(symbol,date,stock)
	con = Mongo::Connection.new("127.0.0.1")
	db   = con['stock']
	coll = db['closes']	
	doc = {
		'date' => date,
		'symbol' => symbol,
		'close' => stock[3].to_f,
		'volume' => stock[6].to_i,
		'value' => stock[7].to_i * 1000
	}
	p doc.inspect
	coll.insert(doc)
	con.close
end

date = ARGV[0]
date = "12/04/2555"
dmy = date.split('/')
yy = dmy[2].to_i - 543
datex = "#{yy}#{dmy[1]}#{dmy[0]}"

if date.nil?
	puts "usage: get-close-date.rb <date dd/mm/yyyy BE>\n"
	exit(0)
end

t1 = Time.now

ss = open("SET50.txt").readlines
n = 0
i = 0
ss.each do |s|
	n += 1
	 i = 0
	bidoffer = []
	sym = s.chomp
	w = Net::HTTP.new("www.set.or.th")
	req = "/set/historicaltrading.do?symbol=#{sym}&language=th&country=TH"
	resp, data = w.get(req)

	data = resp.body.gsub(/<\/td>/,"X")
	d = data.split(/\n/)
	#puts "data.length: #{data.length}"
	#puts "d.size: #{d.size}"
	
	start = false
	count = 0
	stock = []
	n = 0

	d.each do |l|
		l = l.chomp.gsub(/<.*?>/,'').strip
		l = l.tr(',','')
		next if l.length < 1
		if l =~ /#{date}/
			start = true
			next
		end
		if start
			n += 1
			stock << l
			if n == 8
				save_close(sym,datex,stock)
				break
			end
		end
	end
end

t2 = Time.now
puts "Time: #{t2-t1} seconds"