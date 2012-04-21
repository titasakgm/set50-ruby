#! C:\Ruby193\bin\ruby.exe

# mongo-report-02.rb Count number of records on date: '20120405' GROUP BY symbol
 
require 'rubygems'
require 'mongo'

con = Mongo::Connection.new("127.0.0.1")
db   = con['set50']
coll = db['quotes']

map = "function() {
							var key = {'symbol':this.symbol}; 
							emit(key, {'count':1});
					}"
reduce = "function(key,values) {
								var sum = 0;
								values.forEach (function(value){
								  sum += value['count'];
								});
								return {'count':sum};
							}"
res = coll.map_reduce(map, reduce, {:out => "group_by_symbol"})

coll = db['group_by_symbol']
res = coll.find
res.each do |doc|
	puts doc.inspect
end

con.close

=begin
> map
function() {var key = {'symbol':this.symbol}; emit(key, {'count':1})}
> reduce
function(key,values) {var sum = 0;values.forEach(function(value){sum += value['count'];});
return {'count':sum};}
> db.quotes.mapReduce(map, reduce, {'out':"group_by_symbol"})
{
        "result" : "group_by_symbol",
        "timeMillis" : 748,
        "counts" : {
                "input" : 14355,
                "emit" : 14355,
                "reduce" : 765,
                "output" : 54
        },
        "ok" : 1,
}
=end
