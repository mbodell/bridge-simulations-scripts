# From http://www.bridgebase.com/forums/topic/69586-math-problem/
# N is AKJT9 - 7 AQJ9743
# S is 87 JT7654 A654 5
# all white starting with W the auction is:
# 1NT (15-17) 2S (showing C) P 3C (forced)
# P 6C All pass
# Lead is HA (east plays H2)
#
# The two main lines to consider are:
# Line 1: Play on spades planning to ruff the third round if necessary
# Line 2: Play on clubs taking the finesse

south is {87 JT7654 A654 5}
north is {AKJT9 - 7 AQJ9743}
west gets AH KH
east gets 2H

array set count {
	hands 0
	strictNT 0
	no5Mbut6mNT 0
	realNT 0
	line1 0
	line2 0
}

correlation strictNTc
correlation no5Mbut6mNTc
correlation realNTc

shapecond strictNT { $s <= 4 && $s >= 2 && $h <= 4 && $h >= 2 && $d <= 5 && $d >= 2 && $c <= 5 && $c >= 2}
shapecond no5Mbut6mNT { $s <= 4 && $s >= 2 && $h <= 4 && $h >= 2 && $d <= 6 && $d >= 2 && $c <= 6 && $c >= 2}
shapecond realNT { $s <= 5 && $s >= 2 && $h <= 5 && $h >= 2 && $d <= 6 && $d >= 2 && $c <= 6 && $c >= 2}

proc write_deal {} {
	global count
	global strictNTc
	global no5Mbut6mNTc
	global realNTc

	incr count(hands)

	set line1 0
	set line2 0

	# Figure out if L2 - club finesse - works
	set club_loser 2
	set clubs_west [clubs west]
	if {$clubs_west == 2 && [west has KC]} {
		set club_loser 0
	} elseif {$clubs_west == 2 || $clubs_west == 3 || ($clubs_west == 4 && [east has TC]) || ($clubs_west == 1 && [west has TC KC])} {
		set club_loser 1
	}
	set spade_loser 1
	set spades_west [spades west]
	set sQ_west [west has QS]
	if {($spades_west == 1 && $sQ_west == 1) || ($spades_west == 2 && $sQ_west == 1) || 
		($spades_west == 4 && $sQ_west == 0) || ($spades_west == 5 && $sQ_west == 0)} {
		set spade_loser 0
	}
	if {($spade_loser + $club_loser) < 2} {
		set line2 1
		incr count(line2)
	}

	# figure out clubs from the top losers which is often important for line 1
	set club_loser_top 2
	if {$clubs_west == 2 || $clubs_west == 3 || ($clubs_west == 4 && [east has TC KC]) || ($clubs_west == 1 && [west has TC KC])} {
		set club_loser_top 1
	}

	# Figure out if L1 - spades first - works
	if {($spades_west == 4 && $sQ_west == 0) || ($spades_west == 5 && $sQ_west == 0)} {
		# this is case 1 Q or Qx with east - we now take the club finesse in trumps
		if {$club_loser <= 1} {
			set line1 1
		}
	} elseif {($spades_west == 1 && $sQ_west == 1) || ($spades_west == 2 && $sQ_west == 1)} {
		# this is case 2 Q or Qx with west - we play clubs from the top
		if {$club_loser_top == 1} {
			# Still need to avoid the ruff
			if {!($clubs_west == 3 && [east has KC])} {
				set line1 1
			}
		} 
	} elseif {$spades_west == 3} {
		if {$club_loser_top == 1} {
			set line1 1
		}
	}

	if {$line1 == 1} {
		incr count(line1)
	}
	
	set p [hcp west]

	if {$p < 18 && $p > 14} {
		if {[strictNT west]} {
			incr count(strictNT)
			incr count(no5Mbut6mNT)
			incr count(realNT)
			strictNTc add $line1 $line2
			no5Mbut6mNTc add $line1 $line2
			realNTc add $line1 $line2
		} elseif {[no5Mbut6mNT west]} {
			incr count(no5Mbut6mNT)
			incr count(realNT)
			no5Mbut6mNTc add $line1 $line2
			realNTc add $line1 $line2
		} elseif {[realNT west]} {
			incr count(realNT)
			realNTc add $line1 $line2
		}
	}

#	formatter::write_deal
#	puts "There were $club_loser club loser on this hand"
#	puts "There were $spade_loser spade loser on this hand"
#	puts "Line 1, spades first, $line1"
#	puts "Line 2, club finesse first, $line2"
}

deal_finished {
	global count
	global strictNTc
	global no5Mbut6mNTc
	global realNTc

	puts "There were $count(hands) hands dealt"
	puts "There were $count(realNT) inclusive NT hands dealt ([expr double($count(realNT))/$count(hands)*100]%)"
	puts "There were $count(no5Mbut6mNT) 6 minor but no 5 major NT hands dealt ([expr double($count(no5Mbut6mNT))/$count(hands)*100]%)"
	puts "There were $count(strictNT) srtict balanced no 5 major NT hands dealt ([expr double($count(strictNT))/$count(hands)*100]%)"
	puts "There were $count(line1) times line1 - spades first - worked ([expr double($count(line1))/$count(hands)*100]%)"
	puts "There were $count(line2) times line2 - club finesse first - worked ([expr double($count(line2))/$count(hands)*100]%)"
	set snl1 [expr double(round([strictNTc average x] * 10000))/100]
	set snl2 [expr double(round([strictNTc average y] * 10000))/100]
	puts "With a strict NT shape, line 1 - spades first - works ($snl1%) while line 2 - club finesse first - works ($snl2%)"
	set 6ml1 [expr double(round([no5Mbut6mNTc average x] * 10000))/100]
	set 6ml2 [expr double(round([no5Mbut6mNTc average y] * 10000))/100]
	puts "With a 6 minor ok but 5M not NT shape, line 1 - spades first - works ($6ml1%) while line 2 - club finesse first - works ($6ml2%)"
	set nnl1 [expr double(round([realNTc average x] * 10000))/100]
	set nnl2 [expr double(round([realNTc average y] * 10000))/100]
	puts "With a normal NT shape, line 1 - spades first - works ($nnl1%) while line 2 - club finesse first - works ($nnl2%)"
}

main {
	accept
}
