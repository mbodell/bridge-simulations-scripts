south is {T942 982 KT4 QT3}

array set count {
	ST 0
	S9 0
	S4 0
	S2 0
	H9 0
	H8 0
	H2 0
	DK 0
	DT 0
	D4 0
	CQ 0
	CT 0
	C3 0
	setST 0
	setS9 0
	setS4 0
	setS2 0
	setH9 0
	setH8 0
	setH2 0
	setDK 0
	setDT 0
	setD4 0
	setCQ 0
	setCT 0
	setC3 0
	impST 0
	impS9 0
	impS4 0
	impS2 0
	impH9 0
	impH8 0
	impH2 0
	impDK 0
	impDT 0
	impD4 0
	impCQ 0
	impCT 0
	impC3 0
	hands 0
	deals 0
	bad 0
	realbad 0
}
source lib/score.tcl

patternclass longest { return $l1 }
patternclass longest2 { return $l1 + $l2 }
holdingProc aceandtens {a k q j t} { return [expr {$a + $t}] }
holdingProc aceandtenandnine {a k q j t x9} { return [expr {$a + $t + $x9}] }
patterncond has_shortness { $l4 < 2 }
patterncond is_box { $l4 == 3 }

shapecond nt_shape {$s <= 5 && $s >= 2 && $h <= 5 && $h >= 2 && $d <= 6 && $d >= 2 && $c <= 6 && $c >= 2 && ($s < 5 || ($h < 4 && $c < 4 && $d < 4)) && ($h < 5 || ($s < 4 && $c < 4 && $d < 4))}


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

proc passover1nt {hand} {
  set p [hcp $hand]
  set l1 [longest $hand]
  set l2 [longest2 $hand]
  set ltc [newLTC $hand]

  if {$p > 17} {
    # X 1nt for penalty
    return 0
  }

  if {($l2 - $ltc) > 2.5} {
    # we overcall a 2 suited bid
    return 0
  }

  if {($l1 > 7) || ($l1 == 6 && [has_shortness $hand])} {
    # conservative one suited showing
    return 0
  }

  return 1
}

proc passover1ntstayman {hand} {
	set p [hcp $hand]
	set l1 [longest $hand]
	set c [clubs $hand]

	if {$p >= 10 && $c >= 5} {
		# X 2C
		return 0
	}
	if {$c >= 6} {
		# X 2C
		return 0
	}
	if {$l1 >= 7 && $p >= 8} {
		# bid your suit
		return 0
	}
	return 1
}

proc bidpass {hand} {
  set p [hcp $hand]
  set l1 [longest $hand]
  set l2 [longest2 $hand]

  # Open 12 counts
  if {$p > 11} {
    return 0
  }

  # Open rule of 20 hands
  if {($p + $l1 + $l2) > 19} {
    return 0
  }

  # Open preempts as long as you have 4+ points and 6+ cards
  if {($p > 3) && ($l1 > 5)} {
    return 0
  }

  # else pass
  return 1
}


proc imp_score {a b} {
  set diff [expr $a - $b]
  set pos 1
  if {$diff < 0 } {
    set pos -1
    set diff [expr -1 * $diff]
  }
  if {$diff <= 10} {return 0}
  if {$diff <= 40} {return [expr $pos * 1]}
  if {$diff <= 80} {return [expr $pos * 2]}
  if {$diff <= 120} {return [expr $pos * 3]}
  if {$diff <= 160} {return [expr $pos * 4]}
  if {$diff <= 210} {return [expr $pos * 5]}
  if {$diff <= 260} {return [expr $pos * 6]}
  if {$diff <= 310} {return [expr $pos * 7]}
  if {$diff <= 360} {return [expr $pos * 8]}
  if {$diff <= 420} {return [expr $pos * 9]}
  if {$diff <= 490} {return [expr $pos * 10]}
  if {$diff <= 590} {return [expr $pos * 11]}
  if {$diff <= 740} {return [expr $pos * 12]}
  if {$diff <= 890} {return [expr $pos * 13]}
  if {$diff <= 1090} {return [expr $pos * 14]}
  if {$diff <= 1290} {return [expr $pos * 15]}
  if {$diff <= 1490} {return [expr $pos * 16]}
  if {$diff <= 1740} {return [expr $pos * 17]}
  if {$diff <= 1990} {return [expr $pos * 18]}
  if {$diff <= 2240} {return [expr $pos * 19]}
  if {$diff <= 2490} {return [expr $pos * 20]}
  if {$diff <= 2990} {return [expr $pos * 21]}
  if {$diff <= 3490} {return [expr $pos * 22]}
  if {$diff <= 3990} {return [expr $pos * 23]}
  return [expr $pos * 24]
}


proc write_deal {} {
	global count
	incr count(hands)

	# Calculate double dummy tricks for each lead
	set ST [dds -leader south -trick TS east notrump]
	set S9 [dds -reuse -leader south -trick 9S east notrump]
	set S4 [dds -reuse -leader south -trick 4S east notrump]
	set S2 [dds -reuse -leader south -trick 2S east notrump]
	set H9 [dds -reuse -leader south -trick 9H east notrump]
	set H8 [dds -reuse -leader south -trick 8H east notrump]
	set H2 [dds -reuse -leader south -trick 2H east notrump]
	set DK [dds -reuse -leader south -trick KD east notrump]
	set DT [dds -reuse -leader south -trick TD east notrump]
	set D4 [dds -reuse -leader south -trick 4D east notrump]
	set CQ [dds -reuse -leader south -trick QC east notrump]
	set CT [dds -reuse -leader south -trick TC east notrump]
	set C3 [dds -reuse -leader south -trick 3C east notrump]

	# There seems to be some bug where occasionally I see 0 tricks with the SK lead, espeically the first time
	if {$ST == 0} {
  		set ST [dds -leader south -trick TS east notrump]
  		incr count(bad)
  		if {$ST == 0} {
  			incr count(realbad)
  			$ST = $S9
  		}
	}

	# Remember the total tricks by lead
	set count(ST) [expr $count(ST) + $ST]
	set count(S9) [expr $count(S9) + $S9]
	set count(S4) [expr $count(S4) + $S4]
	set count(S2) [expr $count(S2) + $S2]
	set count(H9) [expr $count(H9) + $H9]
	set count(H8) [expr $count(H8) + $H8]
	set count(H2) [expr $count(H2) + $H2]
	set count(DK) [expr $count(DK) + $DK]
	set count(DT) [expr $count(DT) + $DT]
	set count(D4) [expr $count(D4) + $D4]
	set count(CQ) [expr $count(CQ) + $CQ]
	set count(CT) [expr $count(CT) + $CT]
	set count(C3) [expr $count(C3) + $C3]

	# Remember the set contract by lead
	if {$ST < 9} { incr count(setST)}
	if {$S9 < 9} { incr count(setS9)}
	if {$S4 < 9} { incr count(setS4)}
	if {$S2 < 9} { incr count(setS2)}
	if {$H9 < 9} { incr count(setH9)}
	if {$H8 < 9} { incr count(setH8)}
	if {$H2 < 9} { incr count(setH2)}
	if {$DK < 9} { incr count(setDK)}
	if {$DT < 9} { incr count(setDT)}
	if {$D4 < 9} { incr count(setD4)}
	if {$CQ < 9} { incr count(setCQ)}
	if {$CT < 9} { incr count(setCT)}
	if {$C3 < 9} { incr count(setC3)}

	# Calculate raw scores
	set rST [score {3 notrump} nonvul $ST]
	set rS9 [score {3 notrump} nonvul $S9]
	set rS4 [score {3 notrump} nonvul $S4]
	set rS2 [score {3 notrump} nonvul $S2]
	set rH9 [score {3 notrump} nonvul $H9]
	set rH8 [score {3 notrump} nonvul $H8]
	set rH2 [score {3 notrump} nonvul $H2]
	set rDK [score {3 notrump} nonvul $DK]
	set rDT [score {3 notrump} nonvul $DT]
	set rD4 [score {3 notrump} nonvul $D4]
	set rCQ [score {3 notrump} nonvul $CQ]
	set rCT [score {3 notrump} nonvul $CT]
	set rC3 [score {3 notrump} nonvul $C3]


	# Calculate the IMP scores for each contract
	# MSC gave 100 to only the D4 with every other one 50 or below
	# So compare every contract against the other table leading D9
	set iST [imp_score $rD4 $rST]
	set iS9 [imp_score $rD4 $rS9]
	set iS4 [imp_score $rD4 $rS4]
	set iS2 [imp_score $rD4 $rS2]
	set iH9 [imp_score $rD4 $rH9]
	set iH8 [imp_score $rD4 $rH8]
	set iH2 [imp_score $rD4 $rH2]
	set iDK [imp_score $rD4 $rDK]
	set iDT [imp_score $rD4 $rDT]
	set iD4 [imp_score $rD4 $rD4]
	set iCQ [imp_score $rD4 $rCQ]
	set iCT [imp_score $rD4 $rCT]
	set iC3 [imp_score $rD4 $rC3]

	# Remember the imps by lead
	set count(impST) [expr $count(impST) + $iST]
	set count(impS9) [expr $count(impS9) + $iS9]
	set count(impS4) [expr $count(impS4) + $iS4]
	set count(impS2) [expr $count(impS2) + $iS2]
	set count(impH9) [expr $count(impH9) + $iH9]
	set count(impH8) [expr $count(impH8) + $iH8]
	set count(impH2) [expr $count(impH2) + $iH2]
	set count(impDK) [expr $count(impDK) + $iDK]
	set count(impDT) [expr $count(impDT) + $iDT]
	set count(impD4) [expr $count(impD4) + $iD4]
	set count(impCQ) [expr $count(impCQ) + $iCQ]
	set count(impCT) [expr $count(impCT) + $iCT]
	set count(impC3) [expr $count(impC3) + $iC3]





#    formatter::write_deal
#    puts "On ST you get $ST for $rST score which is $iST compared to the diamond lead"
#    puts "On S9 you get $S9"
#    puts "On S4 you get $S4"
#    puts "On S2 you get $S2 for $rS2 score which is $iS2 compared to the diamond lead"
#    puts "On H9 you get $S9"
#    puts "On H8 you get $H8 for $rH8 score which is $iH8 compared to the dimaond lead"
#    puts "On H2 you get $H2"
#    puts "On DK you get $DK for $rDK score which is $iDK compared to the diamond lead"
#    puts "On DT you get $DT for $rDT score which is $iDT compared to the dimaond lead"
#    puts "On D4 you get $D4"
#    puts "On CQ you get $CQ"
#    puts "On CT you get $CT"
#    puts "On C3 you get $C3 for $rC3 score which is $iC3 compared to the diamond lead"
#    puts "---------------------------------"

}


deal_finished {
	global count
    puts "ST lead yeilds $count(ST) tricks ([expr double($count(ST))/$count(hands)]), sets $count(setST) times ([expr double($count(setST))/$count(hands)*100]%) with imps of $count(impST) ([expr double($count(impST))/$count(hands)])."
    puts "S9 lead yeilds $count(S9) tricks ([expr double($count(S9))/$count(hands)]), sets $count(setS9) times ([expr double($count(setS9))/$count(hands)*100]%) with imps of $count(impS9) ([expr double($count(impS9))/$count(hands)])."
    puts "S4 lead yeilds $count(S4) tricks ([expr double($count(S4))/$count(hands)]), sets $count(setS4) times ([expr double($count(setS4))/$count(hands)*100]%) with imps of $count(impS4) ([expr double($count(impS4))/$count(hands)])."
    puts "S2 lead yeilds $count(S2) tricks ([expr double($count(S2))/$count(hands)]), sets $count(setS2) times ([expr double($count(setS2))/$count(hands)*100]%) with imps of $count(impS2) ([expr double($count(impS2))/$count(hands)])."
    puts "H9 lead yeilds $count(H9) tricks ([expr double($count(H9))/$count(hands)]), sets $count(setH9) times ([expr double($count(setH9))/$count(hands)*100]%) with imps of $count(impH9) ([expr double($count(impH9))/$count(hands)])."
    puts "H8 lead yeilds $count(H8) tricks ([expr double($count(H8))/$count(hands)]), sets $count(setH8) times ([expr double($count(setH8))/$count(hands)*100]%) with imps of $count(impH8) ([expr double($count(impH8))/$count(hands)])."
    puts "H2 lead yeilds $count(H2) tricks ([expr double($count(H2))/$count(hands)]), sets $count(setH2) times ([expr double($count(setH2))/$count(hands)*100]%) with imps of $count(impH2) ([expr double($count(impH2))/$count(hands)])."
    puts "DK lead yeilds $count(DK) tricks ([expr double($count(DK))/$count(hands)]), sets $count(setDK) times ([expr double($count(setDK))/$count(hands)*100]%) with imps of $count(impDK) ([expr double($count(impDK))/$count(hands)])."
    puts "DT lead yeilds $count(DT) tricks ([expr double($count(DT))/$count(hands)]), sets $count(setDT) times ([expr double($count(setDT))/$count(hands)*100]%) with imps of $count(impDT) ([expr double($count(impDT))/$count(hands)])."
    puts "D4 lead yeilds $count(D4) tricks ([expr double($count(D4))/$count(hands)]), sets $count(setD4) times ([expr double($count(setD4))/$count(hands)*100]%) with imps of $count(impD4) ([expr double($count(impD4))/$count(hands)])."
    puts "CQ lead yeilds $count(CQ) tricks ([expr double($count(CQ))/$count(hands)]), sets $count(setCQ) times ([expr double($count(setCQ))/$count(hands)*100]%) with imps of $count(impCQ) ([expr double($count(impCQ))/$count(hands)])."
    puts "CT lead yeilds $count(CT) tricks ([expr double($count(CT))/$count(hands)]), sets $count(setCT) times ([expr double($count(setCT))/$count(hands)*100]%) with imps of $count(impCT) ([expr double($count(impCT))/$count(hands)])."
    puts "C3 lead yeilds $count(C3) tricks ([expr double($count(C3))/$count(hands)]), sets $count(setC3) times ([expr double($count(setC3))/$count(hands)*100]%) with imps of $count(impC3) ([expr double($count(impC3))/$count(hands)])."
    puts "I had bad $count(bad) and realbad $count(realbad) times"
}




main {
	global count
	incr count(deals)
		reject if {![bidpass north]}
        reject if {![open1nt east]}
        reject if {!([hearts east] >= 4)}
        reject if {[spades east] >= 4}
        reject if {!([hcp west] >= 9)}
        reject if {!([spades west] == 4)}
        reject if {!([hearts west] < 4)}
        reject if {[longest west] >= 6}
        reject if {![passover1ntstayman north]}
        accept
}
