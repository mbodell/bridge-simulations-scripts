south is {T4 K83 J43 AT843}

array set count {
	ST 0
	S4 0
	HK 0
	H8 0
	H3 0
	DJ 0
	D4 0
	D3 0
	CA 0
	CT 0
	C8 0
	C4 0
	C3 0
	setST 0
	setS4 0
	setHK 0
	setH8 0
	setH3 0
	setDJ 0
	setD4 0
	setD3 0
	setCA 0
	setCT 0
	setC8 0
	setC4 0
	setC3 0
	impST 0
	impS4 0
	impHK 0
	impH8 0
	impH3 0
	impDJ 0
	impD4 0
	impD3 0
	impCA 0
	impCT 0
	impC8 0
	impC4 0
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
	set ST [dds -leader south -trick TS east spades]
	set S4 [dds -reuse -leader south -trick 4S east spades]
	set HK [dds -reuse -leader south -trick KH east spades]
	set H8 [dds -reuse -leader south -trick 8H east spades]
	set H3 [dds -reuse -leader south -trick 3H east spades]
	set DJ [dds -reuse -leader south -trick JD east spades]
	set D4 [dds -reuse -leader south -trick 4D east spades]
	set D3 [dds -reuse -leader south -trick 3D east spades]
	set CA [dds -reuse -leader south -trick AC east spades]
	set CT [dds -reuse -leader south -trick TC east spades]
	set C8 [dds -reuse -leader south -trick 8C east spades]
	set C4 [dds -reuse -leader south -trick 4C east spades]
	set C3 [dds -reuse -leader south -trick 3C east spades]

	# There seems to be some bug where occasionally I see 0 tricks with the ST lead, espeically the first time
	if {$ST == 0} {
  		set ST [dds -leader south -trick TS east spades]
  		incr count(bad)
  		if {$ST == 0} {
  			incr count(realbad)
  			$ST = $S4
  		}
	}

	# Remember the total tricks by lead
	set count(ST) [expr $count(ST) + $ST]
	set count(S4) [expr $count(S4) + $S4]
	set count(HK) [expr $count(HK) + $HK]
	set count(H8) [expr $count(H8) + $H8]
	set count(H3) [expr $count(H3) + $H3]
	set count(DJ) [expr $count(DJ) + $DJ]
	set count(D4) [expr $count(D4) + $D4]
	set count(D3) [expr $count(D3) + $D3]
	set count(CA) [expr $count(CA) + $CA]
	set count(CT) [expr $count(CT) + $CT]
	set count(C8) [expr $count(C8) + $C8]
	set count(C4) [expr $count(C4) + $C4]
	set count(C3) [expr $count(C3) + $C3]

	# Remember the set contract by lead
	if {$ST < 10} { incr count(setST)}
	if {$S4 < 10} { incr count(setS4)}
	if {$HK < 10} { incr count(setHK)}
	if {$H8 < 10} { incr count(setH8)}
	if {$H3 < 10} { incr count(setH3)}
	if {$DJ < 10} { incr count(setDJ)}
	if {$D4 < 10} { incr count(setD4)}
	if {$D3 < 10} { incr count(setD3)}
	if {$CA < 10} { incr count(setCA)}
	if {$CT < 10} { incr count(setCT)}
	if {$C8 < 10} { incr count(setC8)}
	if {$C4 < 10} { incr count(setC4)}
	if {$C3 < 10} { incr count(setC3)}

	# Calculate raw scores
	set rST [score {4 spades} vul $ST]
	set rS4 [score {4 spades} vul $S4]
	set rHK [score {4 spades} vul $HK]
	set rH8 [score {4 spades} vul $H8]
	set rH3 [score {4 spades} vul $H3]
	set rDJ [score {4 spades} vul $DJ]
	set rD4 [score {4 spades} vul $D4]
	set rD3 [score {4 spades} vul $D3]
	set rCA [score {4 spades} vul $CA]
	set rCT [score {4 spades} vul $CT]
	set rC8 [score {4 spades} vul $C8]
	set rC4 [score {4 spades} vul $C4]
	set rC3 [score {4 spades} vul $C3]


	# Calculate the IMP scores for each contract
	# I suspect CA is the best lead based on earlier 100 simulation plus DD bias for A leads
	# So compare every contract against the other table leading CA
	set iST [imp_score $rCA $rST]
	set iS4 [imp_score $rCA $rS4]
	set iHK [imp_score $rCA $rHK]
	set iH8 [imp_score $rCA $rH8]
	set iH3 [imp_score $rCA $rH3]
	set iDJ [imp_score $rCA $rDJ]
	set iD4 [imp_score $rCA $rD4]
	set iD3 [imp_score $rCA $rD3]
	set iCA [imp_score $rCA $rCA]
	set iCT [imp_score $rCA $rCT]
	set iC8 [imp_score $rCA $rC8]
	set iC4 [imp_score $rCA $rC4]
	set iC3 [imp_score $rCA $rC3]

	# Remember the imps by lead
	set count(impST) [expr $count(impST) + $iST]
	set count(impS4) [expr $count(impS4) + $iS4]
	set count(impHK) [expr $count(impHK) + $iHK]
	set count(impH8) [expr $count(impH8) + $iH8]
	set count(impH3) [expr $count(impH3) + $iH3]
	set count(impDJ) [expr $count(impDJ) + $iDJ]
	set count(impD4) [expr $count(impD4) + $iD4]
	set count(impD3) [expr $count(impD3) + $iD3]
	set count(impCA) [expr $count(impCA) + $iCA]
	set count(impCT) [expr $count(impCT) + $iCT]
	set count(impC8) [expr $count(impC8) + $iC8]
	set count(impC4) [expr $count(impC4) + $iC4]
	set count(impC3) [expr $count(impC3) + $iC3]





#    formatter::write_deal
#    puts "On ST you get $ST for $rST score which is $iST compared to the club A lead"
#    puts "On S4 you get $S4"
#    puts "On HK you get $HK"
#    puts "On H8 you get $H8 for $rH8 score which is $iH8 compared to the club A lead"
#    puts "On H3 you get $H3"
#    puts "On DJ you get $DJ for $rDJ score which is $iDJ compared to the club A lead"
#    puts "On D4 you get $D4"
#    puts "On D3 you get $D3"
#    puts "On CA you get $CA for $rCA score which is $iCA compared to the club A lead"
#    puts "On CT you get $CT"
#    puts "On C8 you get $C8"
#    puts "On C4 you get $C4"
#    puts "On C3 you get $C3 for $rC3 score which is $iC3 compared to the club A lead"
#    puts "---------------------------------"

}

deal_finished {
	global count
    puts "ST lead yeilds $count(ST) tricks ([expr double($count(ST))/$count(hands)]), sets $count(setST) times ([expr double($count(setST))/$count(hands)*100]%) with imps of $count(impST) ([expr double($count(impST))/$count(hands)])."
    puts "S4 lead yeilds $count(S4) tricks ([expr double($count(S4))/$count(hands)]), sets $count(setS4) times ([expr double($count(setS4))/$count(hands)*100]%) with imps of $count(impS4) ([expr double($count(impS4))/$count(hands)])."
    puts "HK lead yeilds $count(HK) tricks ([expr double($count(HK))/$count(hands)]), sets $count(setHK) times ([expr double($count(setHK))/$count(hands)*100]%) with imps of $count(impHK) ([expr double($count(impHK))/$count(hands)])."
    puts "H8 lead yeilds $count(H8) tricks ([expr double($count(H8))/$count(hands)]), sets $count(setH8) times ([expr double($count(setH8))/$count(hands)*100]%) with imps of $count(impH8) ([expr double($count(impH8))/$count(hands)])."
    puts "H3 lead yeilds $count(H3) tricks ([expr double($count(H3))/$count(hands)]), sets $count(setH3) times ([expr double($count(setH3))/$count(hands)*100]%) with imps of $count(impH3) ([expr double($count(impH3))/$count(hands)])."
    puts "DJ lead yeilds $count(DJ) tricks ([expr double($count(DJ))/$count(hands)]), sets $count(setDJ) times ([expr double($count(setDJ))/$count(hands)*100]%) with imps of $count(impDJ) ([expr double($count(impDJ))/$count(hands)])."
    puts "D4 lead yeilds $count(D4) tricks ([expr double($count(D4))/$count(hands)]), sets $count(setD4) times ([expr double($count(setD4))/$count(hands)*100]%) with imps of $count(impD4) ([expr double($count(impD4))/$count(hands)])."
    puts "D3 lead yeilds $count(D3) tricks ([expr double($count(D3))/$count(hands)]), sets $count(setD3) times ([expr double($count(setD3))/$count(hands)*100]%) with imps of $count(impD3) ([expr double($count(impD3))/$count(hands)])."
    puts "CA lead yeilds $count(CA) tricks ([expr double($count(CA))/$count(hands)]), sets $count(setCA) times ([expr double($count(setCA))/$count(hands)*100]%) with imps of $count(impCA) ([expr double($count(impCA))/$count(hands)])."
    puts "CT lead yeilds $count(CT) tricks ([expr double($count(CT))/$count(hands)]), sets $count(setCT) times ([expr double($count(setCT))/$count(hands)*100]%) with imps of $count(impCT) ([expr double($count(impCT))/$count(hands)])."
    puts "C8 lead yeilds $count(C8) tricks ([expr double($count(C8))/$count(hands)]), sets $count(setC8) times ([expr double($count(setC8))/$count(hands)*100]%) with imps of $count(impC8) ([expr double($count(impC8))/$count(hands)])."
    puts "C4 lead yeilds $count(C4) tricks ([expr double($count(C4))/$count(hands)]), sets $count(setC4) times ([expr double($count(setC4))/$count(hands)*100]%) with imps of $count(impC4) ([expr double($count(impC4))/$count(hands)])."
    puts "C3 lead yeilds $count(C3) tricks ([expr double($count(C3))/$count(hands)]), sets $count(setC3) times ([expr double($count(setC3))/$count(hands)*100]%) with imps of $count(impC3) ([expr double($count(impC3))/$count(hands)])."
    puts "I had bad $count(bad) and realbad $count(realbad) times"
}




main {
	global count
	incr count(deals)
        reject if {![open1nt east]}
        reject if {!([spades east] >= 4)}
        # BWS bids 2H with both majors, I assume opponents do to in a BW contest with no other information on auction
        reject if {[hearts east] >= 4}
        # for now the below shows an "accept" of invite
        reject if {[hcp east] < 16 && [spades east] < 5}
        # these points show invites for west
        reject if {!([hcp west] >= 7)}
        reject if {([hcp west] >= 10)}
        # only go through stayman with 7 then invite if you had both majors and 5+ spades
        reject if {[hcp west] == 7 && [spades west] <= 4}
        reject if {[hcp west] == 8 && [is_box west]}
        reject if {([spades west] < 4)}
        reject if {[spades west] > 6}
        # you can only stayman and invite in spades with 5+ spades if you have also 4 hearts
        reject if {[spades west] > 4 && [hearts west] != 4}
        # 5 hearts is ok since by this point we have 4+ spades if 5/6 hearts
        reject if {([hearts west] > 6)}
        # if both majors are 5+ then you don't stayman
        reject if {[spades west] > 4 && [hearts west] > 4}
        reject if {![passover1ntstayman north]}
        accept
}
