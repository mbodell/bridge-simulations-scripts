south is {K9862 873 98 J74}

array set count {
	SK 0
	S9 0
	S8 0
	S6 0
	S2 0
	H8 0
	H7 0
	H3 0
	D9 0
	D8 0
	CJ 0
	C7 0
	C4 0
	setSK 0
	setS9 0
	setS8 0
	setS6 0
	setS2 0
	setH8 0
	setH7 0
	setH3 0
	setD9 0
	setD8 0
	setCJ 0
	setC7 0
	setC4 0
	impSK 0
	impS9 0
	impS8 0
	impS6 0
	impS2 0
	impH8 0
	impH7 0
	impH3 0
	impD9 0
	impD8 0
	impCJ 0
	impC7 0
	impC4 0
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
	set SK [dds -leader south -trick KS east notrump]
	set S9 [dds -reuse -leader south -trick 9S east notrump]
	set S8 [dds -reuse -leader south -trick 8S east notrump]
	set S6 [dds -reuse -leader south -trick 6S east notrump]
	set S2 [dds -reuse -leader south -trick 2S east notrump]
	set H8 [dds -reuse -leader south -trick 8H east notrump]
	set H7 [dds -reuse -leader south -trick 7H east notrump]
	set H3 [dds -reuse -leader south -trick 3H east notrump]
	set D9 [dds -reuse -leader south -trick 9D east notrump]
	set D8 [dds -reuse -leader south -trick 8D east notrump]
	set CJ [dds -reuse -leader south -trick JC east notrump]
	set C7 [dds -reuse -leader south -trick 7C east notrump]
	set C4 [dds -reuse -leader south -trick 4C east notrump]

	# There seems to be some bug where occasionally I see 0 tricks with the SK lead, espeically the first time
	if {$SK == 0} {
  		set SK [dds -leader south -trick KS east notrump]
  		incr count(bad)
  		if {$SK == 0} {
  			incr count(realbad)
  			$SK = $S9
  		}
	}

	# Remember the total tricks by lead
	set count(SK) [expr $count(SK) + $SK]
	set count(S9) [expr $count(S9) + $S9]
	set count(S8) [expr $count(S8) + $S8]
	set count(S6) [expr $count(S6) + $S6]
	set count(S2) [expr $count(S2) + $S2]
	set count(H8) [expr $count(H8) + $H8]
	set count(H7) [expr $count(H7) + $H7]
	set count(H3) [expr $count(H3) + $H3]
	set count(D9) [expr $count(D9) + $D9]
	set count(D8) [expr $count(D8) + $D8]
	set count(CJ) [expr $count(CJ) + $CJ]
	set count(C7) [expr $count(C7) + $C7]
	set count(C4) [expr $count(C4) + $C4]

	# Remember the set contract by lead
	if {$SK < 9} { incr count(setSK)}
	if {$S9 < 9} { incr count(setS9)}
	if {$S8 < 9} { incr count(setS8)}
	if {$S6 < 9} { incr count(setS6)}
	if {$S2 < 9} { incr count(setS2)}
	if {$H8 < 9} { incr count(setH8)}
	if {$H7 < 9} { incr count(setH7)}
	if {$H3 < 9} { incr count(setH3)}
	if {$D9 < 9} { incr count(setD9)}
	if {$D8 < 9} { incr count(setD8)}
	if {$CJ < 9} { incr count(setCJ)}
	if {$C7 < 9} { incr count(setC7)}
	if {$C4 < 9} { incr count(setC4)}

	# Calculate raw scores
	set rSK [score {3 notrump} nonvul $SK]
	set rS9 [score {3 notrump} nonvul $S9]
	set rS8 [score {3 notrump} nonvul $S8]
	set rS6 [score {3 notrump} nonvul $S6]
	set rS2 [score {3 notrump} nonvul $S2]
	set rH8 [score {3 notrump} nonvul $H8]
	set rH7 [score {3 notrump} nonvul $H7]
	set rH3 [score {3 notrump} nonvul $H3]
	set rD9 [score {3 notrump} nonvul $D9]
	set rD8 [score {3 notrump} nonvul $D8]
	set rCJ [score {3 notrump} nonvul $CJ]
	set rC7 [score {3 notrump} nonvul $C7]
	set rC4 [score {3 notrump} nonvul $C4]


	# Calculate the IMP scores for each contract
	# I suspect D9 is the best lead based on earlier 10,000 simulation that held declarer to 
	# 10.25 tricks instead of 
	# 10.30 for heart x or 
	# 10.36 for clubs x or 
	# 10.44 for club J or 
	# 10.54 for spade x or 
	# 11.09 for Spade K
	# So compare every contract against the other table leading D9
	set iSK [imp_score $rD9 $rSK]
	set iS9 [imp_score $rD9 $rS9]
	set iS8 [imp_score $rD9 $rS8]
	set iS6 [imp_score $rD9 $rS6]
	set iS2 [imp_score $rD9 $rS2]
	set iH8 [imp_score $rD9 $rH8]
	set iH7 [imp_score $rD9 $rH7]
	set iH3 [imp_score $rD9 $rH3]
	set iD9 [imp_score $rD9 $rD9]
	set iD8 [imp_score $rD9 $rD8]
	set iCJ [imp_score $rD9 $rCJ]
	set iC7 [imp_score $rD9 $rC7]
	set iC4 [imp_score $rD9 $rC4]

	# Remember the imps by lead
	set count(impSK) [expr $count(impSK) + $iSK]
	set count(impS9) [expr $count(impS9) + $iS9]
	set count(impS8) [expr $count(impS8) + $iS8]
	set count(impS6) [expr $count(impS6) + $iS6]
	set count(impS2) [expr $count(impS2) + $iS2]
	set count(impH8) [expr $count(impH8) + $iH8]
	set count(impH7) [expr $count(impH7) + $iH7]
	set count(impH3) [expr $count(impH3) + $iH3]
	set count(impD9) [expr $count(impD9) + $iD9]
	set count(impD8) [expr $count(impD8) + $iD8]
	set count(impCJ) [expr $count(impCJ) + $iCJ]
	set count(impC7) [expr $count(impC7) + $iC7]
	set count(impC4) [expr $count(impC4) + $iC4]





#    formatter::write_deal
#    puts "On SK you get $SK for $rSK score which is $iSK compared to the diamond lead"
#    puts "On S9 you get $S9"
#    puts "On S8 you get $S8"
#    puts "On S6 you get $S6 for $rS6 score which is $iS6 compared to the diamond lead"
#    puts "On S2 you get $S2"
#    puts "On H8 you get $H8 for $rH8 score which is $iH8 compared to the dimaond lead"
#    puts "On H7 you get $H7"
#    puts "On H3 you get $H3"
#    puts "On D9 you get $D9 for $rD9 score which is $iD9 compared to the dimaond lead"
#    puts "On D8 you get $D8"
#    puts "On CJ you get $CJ"
#    puts "On C7 you get $C7"
#    puts "On C4 you get $C4 for $rC4 score which is $iC4 compared to the diamond lead"
#    puts "---------------------------------"

}

deal_finished {
	global count
    puts "SK lead yeilds $count(SK) tricks ([expr double($count(SK))/$count(hands)]), sets $count(setSK) times ([expr double($count(setSK))/$count(hands)*100]%) with imps of $count(impSK) ([expr double($count(impSK))/$count(hands)])."
    puts "S9 lead yeilds $count(S9) tricks ([expr double($count(S9))/$count(hands)]), sets $count(setS9) times ([expr double($count(setS9))/$count(hands)*100]%) with imps of $count(impS9) ([expr double($count(impS9))/$count(hands)])."
    puts "S8 lead yeilds $count(S8) tricks ([expr double($count(S8))/$count(hands)]), sets $count(setS8) times ([expr double($count(setS8))/$count(hands)*100]%) with imps of $count(impS8) ([expr double($count(impS8))/$count(hands)])."
    puts "S6 lead yeilds $count(S6) tricks ([expr double($count(S6))/$count(hands)]), sets $count(setS6) times ([expr double($count(setS6))/$count(hands)*100]%) with imps of $count(impS6) ([expr double($count(impS6))/$count(hands)])."
    puts "S2 lead yeilds $count(S2) tricks ([expr double($count(S2))/$count(hands)]), sets $count(setS2) times ([expr double($count(setS2))/$count(hands)*100]%) with imps of $count(impS2) ([expr double($count(impS2))/$count(hands)])."
    puts "H8 lead yeilds $count(H8) tricks ([expr double($count(H8))/$count(hands)]), sets $count(setH8) times ([expr double($count(setH8))/$count(hands)*100]%) with imps of $count(impH8) ([expr double($count(impH8))/$count(hands)])."
    puts "H7 lead yeilds $count(H7) tricks ([expr double($count(H7))/$count(hands)]), sets $count(setH7) times ([expr double($count(setH7))/$count(hands)*100]%) with imps of $count(impH7) ([expr double($count(impH7))/$count(hands)])."
    puts "H3 lead yeilds $count(H3) tricks ([expr double($count(H3))/$count(hands)]), sets $count(setH3) times ([expr double($count(setH3))/$count(hands)*100]%) with imps of $count(impH3) ([expr double($count(impH3))/$count(hands)])."
    puts "D9 lead yeilds $count(D9) tricks ([expr double($count(D9))/$count(hands)]), sets $count(setD9) times ([expr double($count(setD9))/$count(hands)*100]%) with imps of $count(impD9) ([expr double($count(impD9))/$count(hands)])."
    puts "D8 lead yeilds $count(D8) tricks ([expr double($count(D8))/$count(hands)]), sets $count(setD8) times ([expr double($count(setD8))/$count(hands)*100]%) with imps of $count(impD8) ([expr double($count(impD8))/$count(hands)])."
    puts "CJ lead yeilds $count(CJ) tricks ([expr double($count(CJ))/$count(hands)]), sets $count(setCJ) times ([expr double($count(setCJ))/$count(hands)*100]%) with imps of $count(impCJ) ([expr double($count(impCJ))/$count(hands)])."
    puts "C7 lead yeilds $count(C7) tricks ([expr double($count(C7))/$count(hands)]), sets $count(setC7) times ([expr double($count(setC7))/$count(hands)*100]%) with imps of $count(impC7) ([expr double($count(impC7))/$count(hands)])."
    puts "C4 lead yeilds $count(C4) tricks ([expr double($count(C4))/$count(hands)]), sets $count(setC4) times ([expr double($count(setC4))/$count(hands)*100]%) with imps of $count(impC4) ([expr double($count(impC4))/$count(hands)])."
    puts "I had bad $count(bad) and realbad $count(realbad) times"
}




main {
	global count
	incr count(deals)
        reject if {![open1nt east]}
        reject if {!([spades east] >= 4)}
        reject if {[hearts east] >= 4}
        reject if {!([hcp west] >= 9)}
        reject if {([hcp west] >= 15)}
        reject if {!([hearts west] == 4)}
        reject if {!([spades west] < 4)}
        reject if {[longest west] >= 6}
        reject if {![passover1ntstayman north]}
        accept
}
