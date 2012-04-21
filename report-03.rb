#! C:\Ruby193\bin\ruby.exe

# Report

require 'rubygems'
require 'mongo'

con = Mongo::Connection.new("127.0.0.1")
db   = con['set50']
coll = db['quotes']
res = coll.find({:date => "20120405"})
con.close

puts res.count
