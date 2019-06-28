south is QT53 3 J752 KQ85

shapecond nt_shape {$s <= 5 && $s >= 2 && $h <= 5 && $h >= 2 && $d <= 6 && $d >= 2 && $c <= 6 && $c >= 2 && ($s < 5 || ($h < 4 && $c < 4 && $d < 4)) && ($h < 5 || ($s < 4 && $c < 4 && $d < 4))}

array set count {
 hands 0
 spade 0
 heart 0
 diamond 0
 club 0
 clubH 0
 spadeset 0
 heartset 0
 diamondset 0
 clubset 0
 clubHset 0
 spadeMP 0
 spadeW 0
 spadeT 0
 diamondMP 0
 diamondW 0
 dimaondT 0
 clubMP 0
 clubW 0
 clubT 0
 clubHMP 0
 clubHW 0
 clubHT 0
}

patternclass longest { return $l1 }
patternclass longest2 { return [expr {$l1 + $l2}] }
holdingProc aceandtens {a k q j t} { return [expr {$a + $t}] }
holdingProc aceandtenandnine {a k q j t x9} { return [expr {$a + $t + $x9}] }
patterncond has_shortness { $l4 < 2 }

proc upgrade_nt {hand} {
  if {[longest $hand] >= 6} {return 1}
  if {[longest $hand] == 5 && ([aceandtens $hand]>=4 || [aceandtenandnine $hand]>=6)} {return 1}
  if {[aceandtens $hand]>=5 || [aceandtenandnine $hand] >= 7} {return 1}
  return 0
}

proc open1nt {hand} {
  set p [hcp $hand]
  if {$p<14 || $p>17} {
    return 0
  } 
  if {![nt_shape $hand]} {
    return 0
  }
  if {$p==14 && ![upgrade_nt $hand]} {
    return 0
  }
  if {$p==17 && ([upgrade_nt $hand] || [spades $hand]==5 || [hearts $hand]==5)} {
    return 0
  }

  return 1
}

proc blast3ntover1nt {hand} {
  set p [hcp $hand]
  set l1 [longest $hand]
  if {$p<9 || $p>15} {
    # Either too weak to blast or too strong
    return 0
  }
  if {$p == 9 && ![upgrade_nt $hand]} {
    # should probably invite
    return 0
  }
  if {[spades $hand] > 3 || [hearts $hand] > 3} {
    # Should stayman
    return 0
  }
  if {[expr {$l1 + $p}] >= 20 || ([expr {$l1 + $p}] == 19 && [upgrade_nt $hand])} {
    # Should try for slam
    return 0
  }
  if {[has_shortness $hand]} {
    # stiff or void, show it
    return 0
  }
  return 1
}

proc passover1nt {hand} {
  set p [hcp $hand]
  if {$p >= 8} {
    return 0
  }
  if {[spades $hand] >= 5 || [hearts $hand] >= 5 || [clubs $hand] >= 6 || [diamonds $hand] >= 6} {
    return 0
  }
  return 1
}

proc nocompeteover1nt {hand} {
  set p [hcp $hand]
  set long2 [longest2 $hand]
  set losers [losers $hand]
  if {$p >= 8 && ([expr $long2 - (double($losers)/2)] >= 2)} {
    return 0
  }
  if {$p >= 6 && ([spades $hand] >= 6 || [hearts $hand] >= 6 || [clubs $hand] >= 7 || [diamonds $hand] >= 7) } {
	  return 0
	}
	if {$p >= 17} {
		return 0
	}
  return 1
}

proc write_deal {} {
#  set tr [deal::tricks east notrump]
  set trS [dds -leader south -trick 3S east notrump]
  set trH [dds -leader south -trick 3H east notrump]
	set trD [dds -leader south -trick 2D east notrump]
  set trC [dds -leader south -trick 5C east notrump]
	set trCH [dds -leader south -trick KC east notrump]
  set h [hcp east]
  set hw [hcp west]
  global count
  incr count(hands)

  set tmpTr $count(spade)
  set count(spade) [expr $tmpTr + $trS]

  set tmpTr $count(heart)
  set count(heart) [expr $tmpTr + $trH]

  set tmpTr $count(diamond)
  set count(diamond) [expr $tmpTr + $trD]

  set tmpTr $count(club)
  set count(club) [expr $tmpTr + $trC]

  set tmpTr $count(clubH)
  set count(clubH) [expr $tmpTr + $trCH]

  if {$trS < 7} { incr count(spadeset) }
  if {$trH < 7} { incr count(heartset) }
  if {$trD < 7} { incr count(diamondset) }
  if {$trC < 7} { incr count(clubset) }
  if {$trCH < 7} { incr count(clubHset) }

  if {$trS < $trH} {
    incr count(spadeMP)
#    puts "Spade MP 2"
    incr count(spadeMP)
    incr count(spadeW)
  }
  
  if {$trS == $trH} {
    incr count(spadeMP)
#    puts "Spade MP 1"
    incr count(spadeT)
  }

  if {$trD < $trH} {
    incr count(diamondMP)
#    puts "Diamond MP 2"
    incr count(diamondMP)
    incr count(diamondW)
  }
  
  if {$trD == $trH} {
    incr count(diamondMP)
#    puts "Diamond MP 1"
    incr count(diamondT)
  }

  if {$trC < $trH} {
    incr count(clubMP)
#    puts "Club MP 2"
    incr count(clubMP)
    incr count(clubW)
  }
  
  if {$trC == $trH} {
    incr count(clubMP)
#    puts "Club MP 1"
    incr count(clubT)
  }

  if {$trCH < $trH} {
    incr count(clubHMP)
#    puts "ClubH MP 2"
    incr count(clubHMP)
    incr count(clubHW)
  }
  
  if {$trCH == $trH} {
    incr count(clubHMP)
#    puts "ClubH MP 1"
    incr count(clubHT)
  }


#  formatter::write_deal
#  puts "east hcp: $h"
#  puts "west hcp: $hw"
#  puts "Tricks in nt are $tr"
#  puts "Tricks on the ST lead are $trS"
#  puts "Tricks on the HQ lead are $trH"
#  puts "Tricks on the CK lead are $trC"
#  puts "---------------------------------"
}


deal_finished {
  global count
  puts "On the spade lead declarer took $count(spade) tricks or [expr double($count(spade))/$count(hands)] tricks on average"
  puts "On the heart lead declarer took $count(heart) tricks or [expr double($count(heart))/$count(hands)] tricks on average"
  puts "On the diamond lead declarer took $count(diamond) tricks or [expr double($count(diamond))/$count(hands)] tricks on average"
  puts "On the club lead declarer took $count(club) tricks or [expr double($count(club))/$count(hands)] tricks on average"
  puts "On the high club lead declarer took $count(clubH) tricks or [expr double($count(clubH))/$count(hands)] tricks on average"
  puts "The spade lead set declarer $count(spadeset) times or ([expr double($count(spadeset))/$count(hands)*100]%)"
  puts "The heart lead set declarer $count(heartset) times or ([expr double($count(heartset))/$count(hands)*100]%)"
  puts "The diamond lead set declarer $count(diamondset) times or ([expr double($count(diamondset))/$count(hands)*100]%)"
  puts "The club lead set declarer $count(clubset) times or ([expr double($count(clubset))/$count(hands)*100]%)"
  puts "The high club lead set declarer $count(clubHset) times or ([expr double($count(clubHset))/$count(hands)*100]%)"
  puts "The matchpoint score for the spade lead (compared to heart) is ([expr double($count(spadeMP))/(2*$count(hands))*100]%) based on $count(spadeW) wins and $count(spadeT) ties and [expr {$count(hands) - $count(spadeW) - $count(spadeT)}] losses"
  puts "The matchpoint score for the diamond lead (compared to heart) is ([expr double($count(diamondMP))/(2*$count(hands))*100]%) based on $count(diamondW) wins and $count(diamondT) ties and [expr {$count(hands) - $count(diamondW) - $count(diamondT)}] losses"
  puts "The matchpoint score for the club lead (compared to heart) is ([expr double($count(clubMP))/(2*$count(hands))*100]%) based on $count(clubW) wins and $count(clubT) ties and [expr {$count(hands) - $count(clubW) - $count(clubT)}] losses"
  puts "The matchpoint score for the high club lead (compared to heart) is ([expr double($count(clubHMP))/(2*$count(hands))*100]%) based on $count(clubHW) wins and $count(clubHT) ties and [expr {$count(hands) - $count(clubHW) - $count(clubHT)}] losses"

}

main {
        reject if {![open1nt east]}
        reject if {![passover1nt west]}
	reject if {![nocompeteover1nt north]}
	accept
}
