#! /bin/bash
# Expect protocol name as first parameter (tcp or udp)

# Define input and output file names
ThroughFile="../data/$1_throughput.dat";
PngName="../data/LB$1.png";

#getting the first and the last line of the file
HeadLine=($(head $ThroughFile --lines=1))
TailLine=($(tail $ThroughFile --lines=1))

#getting the information from the first and the last line
FirstN=${HeadLine[0]}
LastN=${TailLine[0]}

# TO BE DONE START
#N sono i byte di quanto è lungo un certo messaggio
#T è il throughtputh e D è il dalay
#N=T(N)*D(N)
#D(N)=L0+N/B                    l0 è la latenza per la trasmissione di un messaggio di zero byte     B è la massima bamìnda per la trasmissione di messaggi molto lunghi
#per trovare L0 e B bisogna stimare i valori dei due parametri che caraterrizzano il canale di trasmissione: utilizzare due messaggi, uno breve N1 e uno lungo N2
#$ echo "" #B=(N2-N1)/((D(N2-D(n1))

# echo "" #L0=(N2-N1)/((D(N2-D(n1))  (D(N1)*N2-D(N2)*N1)/(N2-N1)
#N sono i byte di quanto è lungo un certo messaggio
#T è il throughtputh e D è il dalay
#N=T(N)D(N)
#D(N)=L0+N/B                    l0 è la latenza per la trasmissione di un messaggio di zero byte     B è la massima bamìnda per la trasmissione di messaggi molto lunghi
N1=${HeadLine[0]}
T1=${HeadLine[1]}
N2=${TailLine[0]}
T2=${TailLine[1]}

#per trovare L0 e B bisogna stimare i valori dei due parametri che caraterrizzano il canale di trasmissione: utilizzare due messaggi, uno breve N1 e uno lungo N2
T1KB=$(echo "$T1 / 1024" | bc -l)
T2KB=$(echo "$T2 / 1024" | bc -l)

#B=(N2-N1)/((D(N2-D(n1))
#L0=(N2-N1)/((D(N2-D(n1))  (D(N1)N2-D(N2)N1)/(N2-N1)

B=$(echo "($N2 - $N1) / (($T2KB - $T1KB) / ($T2 - $T1))" | bc -l)
L0=$(echo "($T2KB $N1 - $T1KB * $N2) / ($N2 - $N1)" | bc -l)
# TO BE DONE END


# Plotting the results
gnuplot <<-eNDgNUPLOTcOMMAND
  set term png size 900, 700
  set output "${PngName}"
  set logscale x 2
  set logscale y 10
  set xlabel "msg size (B)"
  set ylabel "throughput (KB/s)"
  set xrange[$FirstN:$LastN]
  lbmodel(x)= x / ($Latency + (x/$Band))

#TO BE DONE START
plot "${ThroughFile}" using 1:2 with lines title "Measured Throughput", \
    lbmodel(x) with lines title "Fitted Model"
#TO BE DONE END

  clear

eNDgNUPLOTcOMMAND
