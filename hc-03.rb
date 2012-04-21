[/hichart]$ cat hc-03.rb
#!/usr/bin/ruby

require 'rubygems'
require 'mongo'

sym = "KTB"

con = Mongo::Connection.new("192.168.1.40")
db   = con['set50']
coll = db['analyses']
res = coll.find({:date => "20120405",:symbol => sym}).sort([:time, 1])
con.close

oldv = 0
voldif = 0

tm = []
vbid = []
voff = []
bd = []
of = []
cl = []

res.each do |doc|
  time = doc['time']
  offer = doc['offer'].to_f
  bid = doc['bid'].to_f
  vol_offer = doc['vol_offer'].to_i
  vol_bid = doc['vol_bid'].to_i
  close = doc['close'].to_f
  perc_vol_chg = doc['perc_vol_chg'].to_f
  volume = doc['volume'].to_i
  if oldv == 0
    voldiff = volume
  else
    voldiff = volume - oldv
  end
  oldv = volume

  next if vol_bid == 0 and vol_offer == 0

  bidp = vol_bid * 100 / (vol_bid + vol_offer)
  offp = 100 - bidp

  tm << time
  vbid << bidp
  voff << offp
  bd << bid
  of << offer
  cl << close
end

time = "['#{tm.join("','")}']"

h = <<EOF
Content-type: text/html

<!DOCTYPE HTML>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>Stock Example</title>

<script type="text/javascript" src="js/jquery-1.7.1.min.js"></script>
<script type="text/javascript">
$(function () {
  var chart;
  $(document).ready(function() {
    chart = new Highcharts.Chart({
    chart: {
             renderTo: 'container',
             zoomtype: 'xy',
             height: 600
           },
           title: {
             text: 'SET 50'
           },
           plotOptions: {
                column: {
                    stacking: 'percent',
                    lineColor: '#ffffff',
                    lineWidth: 1,
                    marker: {
                        lineWidth: 1,
                        lineColor: '#ffffff'
                    },
                }
            },
           xAxis: {
             categories: #{time},
             labels: {
               rotation: 270
             }
           },
           yAxis: [{
             opposite: true,
             labels: {
               formatter: function() {
                 if (this.value <= 100)
                   return this.value + '%';
               },
               style: { color: '#89A54E' },
               enabled: true
             },
             title: {
               text: '%Offer%Bid',
               style: { color: '#89A54E' }
             },
             max: 400
           },{
             labels: {
               formatter: function() {
                 return this.value + 'Baht';
               },
               enabled: true,
               step: 4
             },
             gridLineWidth: 0,
             title: {
               text: 'Price',
               style: { color: '#4572A7' }
             }
           }],
           tooltip: {
             formatter: function() {
               var unit = {
                 'Offer%': '%',
                 'Offer': 'Baht',
                 'Close': 'Baht',
                 'Bid': 'Baht'
               }[this.series.name];

               return ''+
                 this.x + ': ' + this.y + ' ' + unit;
             }
           },
           series: [
             {
               name: 'Offer%',
               type: 'column',
               color: '#89A54E',
               data: [#{voff.join(',')}]
             }, {
               name: 'Bid%',
               type: 'column',
               color: '#4572A7',
               data: [#{vbid.join(',')}]
             }, {
               name: 'Offer',
               type: 'scatter',
               color: '#AA0000',
               yAxis: 1,
               data: [#{of.join(',')}]
             }, {
               name: 'Close',
               type: 'line',
               color: '#AA4643',
               yAxis: 1,
               data: [#{cl.join(',')}]
             }, {
               name: 'Bid',
               type: 'scatter',
               color: '#00AA00',
               yAxis: 1,
               data: [#{bd.join(',')}]
           }]
    });
  });
});
</script>
</head>
<body>

<script src="js/highcharts.js"></script>
<script src=""js/modules/exporting.js"></script>
<div id="container" style="min-width: 400px; height: 400px; margin: 0 auto"></div>

</body>
</html>
EOF

print h
