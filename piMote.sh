#!/bin/bash
# PiMote interface script by Thomas Galea.
# Script allows easy use of Energenie's PiMote board within Bash.
#
# You are free to do what you want with this script. Use it, modify it, improve it. I just ask that you keep my credit.

# Pins used for code.
D0="/sys/class/gpio/gpio17/value"
D1="/sys/class/gpio/gpio22/value"
D2="/sys/class/gpio/gpio23/value"
D3="/sys/class/gpio/gpio27/value"
# Pins used for Mode & Modulator (Mode isn't used in this script, but we don't want it floating).
MS="/sys/class/gpio/gpio24/value"
MD="/sys/class/gpio/gpio25/value"

code=""

# Print usage info if invalid entries.
function help {
	printf "Usage:\n"
	printf "	$0 [socket number] [new state]\n\n"

	printf "	[Socket number] is 1-4. Use 0 or \"all\" to control all four.\n"
	printf "	[new state] decides whether to switch the socket (on) or (off) (you can also use 1 or 0).\n"
	exit 2
}

# Identify what socket to target.
case ${1,,} in
	all|0) code=110;;
	    1) code=111;;
	    2) code=011;;
	    3) code=101;;
	    4) code=001;;
	    *) printf "Unrecognised socket number!\n\n";help;;
esac

# Identify whether to turn on or off.
case ${2,,} in
	0|off) code="$code"0;;
	1|on)  code="$code"1;;
	*) printf "Invalid state!\n\n";help;;
esac

# Ensure all pins are exported and set as output.
for pin in 17 22 23 24 25 27;do
	if [ ! -f /sys/class/gpio/gpio$pin/value ];then
		echo "$pin" >/sys/class/gpio/export
		sleep 0.1
		echo "out" >/sys/class/gpio/gpio$pin/direction
	fi
done
unset pin

# Set up the code pins.
x=0
for bit in $(echo $code | grep -o .);do
	case $x in
		0) echo $bit >$D0;;
		1) echo $bit >$D1;;
		2) echo $bit >$D2;;
		3) echo $bit >$D3;;
	esac
	let x+=1
done
unset bit

# Pins are set. Let's fire.
echo "1" >$MD
sleep 1
echo "0" >$MD

# And now clear the pins.
echo 0 >$D0
echo 0 >$D1
echo 0 >$D2
echo 0 >$D3

exit 0
