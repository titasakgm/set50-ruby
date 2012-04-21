#! C:\Ruby193\bin\ruby.exe

# mongo-report-01.rb Count number of records on date: '20120405'

require 'rubygems'
require 'mongo'

con = Mongo::Connection.new("127.0.0.1")
db   = con['set50']
coll = db['quotes']
res = coll.distinct(:time,{:date => "20120405"}).sort
con.close

puts "res.class: #{res.class}" # Array
res.each do |doc|
	p doc
end
