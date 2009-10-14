ab -n 200 -c 20 localhost:3000/  
#Requests per second:    1.30 [#/sec] (mean)

url.purge .*
ab -n 200 -c 20 localhost:6081/
#Requests per second:    1822.76 [#/sec] (mean)     


ab -n 500 -c 50 localhost:6081/
#Requests per second:    1636.14 [#/sec] (mean)
 