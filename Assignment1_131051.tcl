#Lab Assignment-1
#Shivani Shah-131051
#Lan Simulator
set ns [ new Simulator ]
#define color for flows
#color Blue is defined for 2-7 ftp connection
$ns color 1 Blue
#color Red is defined for 1-10 udp connection
$ns color 2 Red
#color Purple is defined for 8-0 udp connection
$ns color 3 Purple

#open trace files
set tracefile [open out.tr w]
set winfile [open winfile w]
$ns trace-all $tracefile
set namfile [open out.nam w]
$ns namtrace-all $namfile

#finish procedure
proc finish {} {
	global ns tracefile namfile
	$ns flush-trace
	close $tracefile
	close $namfile
	exec nam out.nam &
	exit 0
}

#create 11 nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]
set n7 [$ns node]
set n8 [$ns node]
set n9 [$ns node]
set n10 [$ns node]
$n2 color Blue
$n2 shape box
$n7 color Blue
$n7 shape box
$n1 color Red
$n1 shape box
$n10 color Red
$n10 shape box
$n8 color Purple
$n8 shape box
$n0 color Purple
$n0 shape box

#create links between the nodes
set lan [$ns newLan "$n2 $n9 $n4" 0.5Mb 40ms LL Queue/DropTail MAC/Csma/Cd Channel rotate $n2 right]
$ns duplex-link $n1 $n0 2Mb 10ms DropTail
$ns duplex-link $n0 $n3 2Mb 10ms DropTail
$ns duplex-link $n3 $n2 2Mb 10ms DropTail
$ns duplex-link $n1 $n2 2Mb 10ms DropTail
$ns duplex-link $n5 $n4 1Mb 5ms DropTail
$ns duplex-link $n5 $n6 2Mb 30ms DropTail
$ns duplex-link $n4 $n6 2Mb 25ms DropTail
$ns duplex-link $n6 $n7 2Mb 3ms DropTail
$ns duplex-link $n6 $n8 2Mb 10ms DropTail
$ns duplex-link $n9 $n10 2Mb 10ms DropTail

#give node position
$ns duplex-link-op $n1 $n0 orient up
$ns duplex-link-op $n0 $n3 orient right
$ns duplex-link-op $n1 $n2 orient right
$ns duplex-link-op $n3 $n2 orient down
$ns duplex-link-op $n5 $n4 orient left-down
$ns duplex-link-op $n5 $n6 orient down
$ns duplex-link-op $n4 $n6 orient right-down
$ns duplex-link-op $n6 $n7 orient left-down
$ns duplex-link-op $n6 $n8 orient right-down
$ns duplex-link-op $n9 $n10 orient right

#setup tcp connection between 2-7 node
set tcp [new Agent/TCP]
$ns attach-agent $n2 $tcp
set sink [new Agent/TCPSink]
$ns attach-agent $n7 $sink
$ns connect $tcp $sink
$tcp set fid_ 1
$tcp set packetSize_ 552

#set up ftp connection
set ftp [new Application/FTP]
$ftp attach-agent $tcp

#set UDP connection between 1-10
set udp [new Agent/UDP]
$ns attach-agent $n1 $udp
set null [new Agent/Null]
$ns attach-agent $n10 $null
$ns connect $udp $null
$udp set fid_ 2

#set UDP connection between 8-0
set udp1 [new Agent/UDP]
$ns attach-agent $n8  $udp1
set null [new Agent/Null]
$ns attach-agent $n0 $null
$ns connect $udp1 $null
$udp1 set fid_ 3

#set up CBR over UDP connection between 1-10
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set packetSize_ 1000
$cbr set rate_ 0.01Mb
$cbr set random_ false 

#set up CBR over UDP connection between 8-0
set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $udp1
$cbr1 set packetSize_ 1000
$cbr1 set rate_ 0.01Mb
$cbr1 set random_ false 

#scheduling the events
$ns at 0.1 "$cbr start"
$ns at 0.2 "$ftp start"
$ns at 0.1 "$cbr1 start"
$ns at 125.5 "$cbr1 stop"
$ns at 124.0 "$ftp stop"
$ns at 125.5 "$cbr stop"
proc plotWindow {tcpSource file} {
global ns
set time 0.1
set now [ $ns now]
set cwnd [$tcpSource set cwnd_]
puts $file "$now $cwnd"
$ns at [ expr $now+$time ] "plotWindow $tcpSource $file"
}
$ns at 0.1 "plotWindow $tcp $winfile"
$ns at 125.0 "finish"
$ns run


