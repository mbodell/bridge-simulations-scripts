south is {T9842 J76 87 KT9}

array set count {
	ST 0
	S9 0
	S8 0
	S4 0
	S2 0
	HJ 0
	H7 0
	H6 0
	D8 0
	D7 0
	CK 0
	CT 0
	C9 0
	setST 0
	setS9 0
	setS8 0
	setS4 0
	setS2 0
	setHJ 0
	setH7 0
	setH6 0
	setD8 0
	setD7 0
	setCK 0
	setCT 0
	setC9 0
	impST 0
	impS9 0
	impS8 0
	impS4 0
	impS2 0
	impHJ 0
	impH7 0
	impH6 0
	impD8 0
	impD7 0
	impCK 0
	impCT 0
	impC9 0
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
holdingProc honorscount {a k q j t} { return [expr {$a + $k + $q + $j + $t}] }
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

proc open2nt {hand} {
  set p [hcp $hand]
  if {$p<19 || $p>21} {
    return 0
  } 
  if {![nt_shape $hand]} {
    return 0
  }
  if {$p==19 && ![upgrade_nt $hand]} {
    return 0
  }
  if {$p==21 && ([upgrade_nt $hand] || [spades $hand]==5 || [hearts $hand]==5)} {
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
    # we overD8ll a 2 suited bid
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

proc passover2ntstayman {hand} {
	set p [hcp $hand]
	set l1 [longest $hand]
	set c [clubs $hand]

	if {$p >= 10 && $c >= 5 && [honorscount $hand clubs] >= 3} {
		# X 2C
		return 0
	}
	if {$c >= 6} {
		# X 2C
		return 0
	}
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
	set S8 [dds -reuse -leader south -trick 8S east notrump]
	set S4 [dds -reuse -leader south -trick 4S east notrump]
	set S2 [dds -reuse -leader south -trick 2S east notrump]
	set HJ [dds -reuse -leader south -trick JH east notrump]
	set H7 [dds -reuse -leader south -trick 7H east notrump]
	set H6 [dds -reuse -leader south -trick 6H east notrump]
	set D8 [dds -reuse -leader south -trick 8D east notrump]
	set D7 [dds -reuse -leader south -trick 7D east notrump]
	set CK [dds -reuse -leader south -trick KC east notrump]
	set CT [dds -reuse -leader south -trick TC east notrump]
	set C9 [dds -reuse -leader south -trick 9C east notrump]

	# There seems to be some bug where occasionally I see 0 tricks with the ST lead, espeically the first time
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
	set count(S8) [expr $count(S8) + $S8]
	set count(S4) [expr $count(S4) + $S4]
	set count(S2) [expr $count(S2) + $S2]
	set count(HJ) [expr $count(HJ) + $HJ]
	set count(H7) [expr $count(H7) + $H7]
	set count(H6) [expr $count(H6) + $H6]
	set count(D8) [expr $count(D8) + $D8]
	set count(D7) [expr $count(D7) + $D7]
	set count(CK) [expr $count(CK) + $CK]
	set count(CT) [expr $count(CT) + $CT]
	set count(C9) [expr $count(C9) + $C9]

	# Remember the set contraD7 by lead
	if {$ST < 10} { incr count(setST)}
	if {$S9 < 10} { incr count(setS9)}
	if {$S8 < 10} { incr count(setS8)}
	if {$S4 < 10} { incr count(setS4)}
	if {$S2 < 10} { incr count(setS2)}
	if {$HJ < 10} { incr count(setHJ)}
	if {$H7 < 10} { incr count(setH7)}
	if {$H6 < 10} { incr count(setH6)}
	if {$D8 < 10} { incr count(setD8)}
	if {$D7 < 10} { incr count(setD7)}
	if {$CK < 10} { incr count(setCK)}
	if {$CT < 10} { incr count(setCT)}
	if {$C9 < 10} { incr count(setC9)}

	# D8lculate raw scores
	set rST [score {3 notrump} vul $ST]
	set rS9 [score {3 notrump} vul $S9]
	set rS8 [score {3 notrump} vul $S8]
	set rS4 [score {3 notrump} vul $S4]
	set rS2 [score {3 notrump} vul $S2]
	set rHJ [score {3 notrump} vul $HJ]
	set rH7 [score {3 notrump} vul $H7]
	set rH6 [score {3 notrump} vul $H6]
	set rD8 [score {3 notrump} vul $D8]
	set rD7 [score {3 notrump} vul $D7]
	set rCK [score {3 notrump} vul $CK]
	set rCT [score {3 notrump} vul $CT]
	set rC9 [score {3 notrump} vul $C9]


	# Calculate the IMP scores for each contract
	# I suspect ST is the best lead based on guess
	# So compare every contract against the other table leading ST
	set iST [imp_score $rST $rST]
	set iS9 [imp_score $rST $rS9]
	set iS8 [imp_score $rST $rS8]
	set iS4 [imp_score $rST $rS4]
	set iS2 [imp_score $rST $rS2]
	set iHJ [imp_score $rST $rHJ]
	set iH7 [imp_score $rST $rH7]
	set iH6 [imp_score $rST $rH6]
	set iD8 [imp_score $rST $rD8]
	set iD7 [imp_score $rST $rD7]
	set iCK [imp_score $rST $rCK]
	set iCT [imp_score $rST $rCT]
	set iC9 [imp_score $rST $rC9]

	# Remember the imps by lead
	set count(impST) [expr $count(impST) + $iST]
	set count(impS9) [expr $count(impS9) + $iS9]
	set count(impS8) [expr $count(impS8) + $iS8]
	set count(impS4) [expr $count(impS4) + $iS4]
	set count(impS2) [expr $count(impS2) + $iS2]
	set count(impHJ) [expr $count(impHJ) + $iHJ]
	set count(impH7) [expr $count(impH7) + $iH7]
	set count(impH6) [expr $count(impH6) + $iH6]
	set count(impD8) [expr $count(impD8) + $iD8]
	set count(impD7) [expr $count(impD7) + $iD7]
	set count(impCK) [expr $count(impCK) + $iCK]
	set count(impCT) [expr $count(impCT) + $iCT]
	set count(impC9) [expr $count(impC9) + $iC9]





#    formatter::write_deal
#    puts "On ST you get $ST for $rST score which is $iST compared to the ST lead"
#    puts "On S9 you get $S9"
#    puts "On S8 you get $S8"
#    puts "On S4 you get $S4 for $rS4 score which is $iS4 compared to the ST lead"
#    puts "On S2 you get $S2"
#    puts "On HJ you get $HJ for $rHJ score which is $iHJ compared to the ST lead"
#    puts "On H7 you get $H7"
#    puts "On H6 you get $H6"
#    puts "On D8 you get $D8 for $rD8 score which is $iD8 compared to the ST lead"
#    puts "On D7 you get $D7"
#    puts "On CK you get $CK"
#    puts "On CT you get $CT"
#    puts "On C9 you get $C9 for $rC9 score which is $iC9 compared to the ST lead"
#    puts "---------------------------------"

}

deal_finished {
	global count
    puts "ST lead yeilds $count(ST) tricks ([expr double($count(ST))/$count(hands)]), sets $count(setST) times ([expr double($count(setST))/$count(hands)*100]%) with imps of $count(impST) ([expr double($count(impST))/$count(hands)])."
    puts "S9 lead yeilds $count(S9) tricks ([expr double($count(S9))/$count(hands)]), sets $count(setS9) times ([expr double($count(setS9))/$count(hands)*100]%) with imps of $count(impS9) ([expr double($count(impS9))/$count(hands)])."
    puts "S8 lead yeilds $count(S8) tricks ([expr double($count(S8))/$count(hands)]), sets $count(setS8) times ([expr double($count(setS8))/$count(hands)*100]%) with imps of $count(impS8) ([expr double($count(impS8))/$count(hands)])."
    puts "S4 lead yeilds $count(S4) tricks ([expr double($count(S4))/$count(hands)]), sets $count(setS4) times ([expr double($count(setS4))/$count(hands)*100]%) with imps of $count(impS4) ([expr double($count(impS4))/$count(hands)])."
    puts "S2 lead yeilds $count(S2) tricks ([expr double($count(S2))/$count(hands)]), sets $count(setS2) times ([expr double($count(setS2))/$count(hands)*100]%) with imps of $count(impS2) ([expr double($count(impS2))/$count(hands)])."
    puts "HJ lead yeilds $count(HJ) tricks ([expr double($count(HJ))/$count(hands)]), sets $count(setHJ) times ([expr double($count(setHJ))/$count(hands)*100]%) with imps of $count(impHJ) ([expr double($count(impHJ))/$count(hands)])."
    puts "H7 lead yeilds $count(H7) tricks ([expr double($count(H7))/$count(hands)]), sets $count(setH7) times ([expr double($count(setH7))/$count(hands)*100]%) with imps of $count(impH7) ([expr double($count(impH7))/$count(hands)])."
    puts "H6 lead yeilds $count(H6) tricks ([expr double($count(H6))/$count(hands)]), sets $count(setH6) times ([expr double($count(setH6))/$count(hands)*100]%) with imps of $count(impH6) ([expr double($count(impH6))/$count(hands)])."
    puts "D8 lead yeilds $count(D8) tricks ([expr double($count(D8))/$count(hands)]), sets $count(setD8) times ([expr double($count(setD8))/$count(hands)*100]%) with imps of $count(impD8) ([expr double($count(impD8))/$count(hands)])."
    puts "D7 lead yeilds $count(D7) tricks ([expr double($count(D7))/$count(hands)]), sets $count(setD7) times ([expr double($count(setD7))/$count(hands)*100]%) with imps of $count(impD7) ([expr double($count(impD7))/$count(hands)])."
    puts "CK lead yeilds $count(CK) tricks ([expr double($count(CK))/$count(hands)]), sets $count(setCK) times ([expr double($count(setCK))/$count(hands)*100]%) with imps of $count(impCK) ([expr double($count(impCK))/$count(hands)])."
    puts "CT lead yeilds $count(CT) tricks ([expr double($count(CT))/$count(hands)]), sets $count(setCT) times ([expr double($count(setCT))/$count(hands)*100]%) with imps of $count(impCT) ([expr double($count(impCT))/$count(hands)])."
    puts "C9 lead yeilds $count(C9) tricks ([expr double($count(C9))/$count(hands)]), sets $count(setC9) times ([expr double($count(setC9))/$count(hands)*100]%) with imps of $count(impC9) ([expr double($count(impC9))/$count(hands)])."
    puts "I had bad $count(bad) and realbad $count(realbad) times in $count(deals) hands"
}




main {
	global count
	incr count(deals)
        reject if {![open2nt east]}
        reject if {!([spades east] >= 4)}
        # BWS bids 2H with both majors, I assume opponents do to in a BW contest with no other information on auction
        reject if {[hearts east] >= 4}
        # these points show game but no slam for west
        reject if {!([hcp west] >= 5)}
        reject if {([hcp west] >= 12)}
        # only go through stayman but not raise spades with 4!H and <4!S
        reject if {[spades west] >= 4}
        reject if {[hearts west] != 4}
        reject if {![passover2ntstayman north]}
        accept
}
