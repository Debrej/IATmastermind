set term postscript eps enhanced "Helvetica" 20 color dashed

# reset all options to default, just for precaution
reset

# set the figure size
set size 0.7,0.7

##############
# throughput #
##############

# set the figure name
set output "Perf.eps"

# set the x axis
set xrange [0:50]
set xlabel "Population"
set xtics 0,10,100
set mxtics 2

# set the y axis
set yrange [0:2]
set ylabel "Taux mutation"
set ytics 0,0.2,2
set mytics 2

# set the legend (boxed, on the bottom)
set key box left width 1 height 0.5 samplen 2

# set the grid (grid lines start from tics on both x and y axis)
set grid xtics ytics
set colorsequence default
# plot the data from the log file
plot "<awk '{print}' res_0.5.log" u 2:1 t "T 0.5" w l lt 2 lw 3, "<awk '{print}' res_0.1.log" u 2:1 t "T 0.1" w l lt 1 lw 3, "<awk '{print}' res_0.05.log" u 2:1 t "T 0.05" w l lt 3 lw 3, "<awk '{print}' res_0.02.log" u 2:1 t "T 0.02" w l lt 4 lw 3,"<awk '{print}' res_0.005.log" u 2:1 t "T 0.005" w l lt 5 lw 3 