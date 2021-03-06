south is AT7 AT 8543 T762

source lib/score.tcl

shapecond nt_shape {$s <= 5 && $s >= 2 && $h <= 5 && $h >= 2 && $d <= 6 && $d >= 2 && $c <= 6 && $c >= 2 && ($s < 5 || ($h < 4 && $c < 4 && $d < 4)) && ($h < 5 || ($s < 4 && $c < 4 && $d < 4))}

array set count {
 hands 0
 tricks 0
 nineormore 0
 eight 0
 seven 0
 sixorless 0
 accept 0
 acceptandmake 0
 decline 0
 declineandgame 0
 declineanddime 0
 seventeen 0
 sixteen 0
 fifteen 0
 fourteen 0
}

correlation blast3nt
correlation invite2nt
correlation pass1nt
sdev trickcount

patternclass longest { return $l1 }
patternclass longest2 { return $l1 + $l2 }
holdingProc aceandtens {a k q j t} { return [expr {$a + $t}] }
holdingProc aceandtenandnine {a k q j t x9} { return [expr {$a + $t + $x9}] }
patterncond has_shortness { $l4 < 2 }
patterncond is_box { $l4 == 3 }


proc upgrade_nt {hand} {
  if {[longest $hand] >= 6} {return 1}
  if {[longest $hand] == 5 && ([aceandtens $hand]>=4 || [aceandtenandnine $hand]>=6)} {return 1}
  if {[aceandtens $hand]>=5 || [aceandtenandnine $hand] >= 7} {return 1}
  return 0
}

proc downgrade_nt {hand} {
  if {[is_box $hand] && ([aceandtens $hand] < 3) && ([aceandtenandnine $hand] < 4)} {return 1}
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

proc accept_invite {hand} {
  set p [hcp $hand]

  if {$p > 16} {
    return 1
  }

  if {$p == 16 && ![downgrade_nt $hand]} {
    return 1
  }

  return 0
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
  set tr [deal::tricks north notrump]

  set acI [accept_invite north]

  global count
  global blast3nt
  global invite2nt
  global pass1nt
  global trickcount

  incr count(hands)

  set h [hcp north]

  if {$h == 17} { incr count(seventeen) }
  if {$h == 16} { incr count(sixteen) }
  if {$h == 15} { incr count(fifteen) }
  if {$h == 14} { incr count(fourteen) }

  trickcount add $tr

  set count(tricks) [expr $count(tricks) + $tr]

  if {$tr >= 9 } { 
    incr count(nineormore) 
  } elseif {$tr == 8} {
    incr count(eight) 
  } elseif {$tr == 7} {
    incr count(seven) 
  } else {
    incr count(sixorless) 
  }
 

  set rawscore3nt [score {3 notrump} vul $tr]
  set rawscore1nt [score {1 notrump} vul $tr]
  set 3ntc1nt [imp_score $rawscore3nt $rawscore1nt]
  set 1ntc3nt [imp_score $rawscore1nt $rawscore3nt]
  set 3ntci 0
  set ic3nt 0
  set 1ntci 0
  set ic1nt 0
  set rawscore2nt [score {2 notrump} vul $tr]
  if { $acI } {
    incr count(accept)
    set 1ntci $1ntc3nt
    set ic1nt $3ntc1nt
    if {$tr >= 9} { incr count(acceptandmake) }
  } else {
    incr count(decline)
    if {$tr >= 9} { incr count(declineandgame) }
    if {$tr == 8} { incr count(declineanddime) }
    set 1ntci [imp_score $rawscore1nt $rawscore2nt]
    set ic1nt [imp_score $rawscore2nt $rawscore1nt]
    set 3ntci [imp_score $rawscore3nt $rawscore2nt]
    set ic3nt [imp_score $rawscore2nt $rawscore3nt]
  }

  blast3nt add $3ntc1nt $3ntci
  invite2nt add $ic3nt $ic1nt
  pass1nt add $1ntc3nt $1ntci

#  formatter::write_deal
#  puts "There are $tr tricks in NT"
#  puts "Blasting 3nt scores $rawscore3nt points, Passing scores $rawscore1nt, Inviting accepts? $acI"
#  puts "Blasting gets $3ntc1nt imps against 1nt ($1ntc3nt) and inviting gets $ic1nt imps against 1nt ($1ntci) and blasting gets $3ntci against inviting ($ic3nt)"
#  puts "---------------------------------"
}


deal_finished {
  global count
  global blast3nt
  global invite2nt
  global pass1nt
  global trickcount

  puts "There were an average of [trickcount average] tricks available in nt"
  puts "In general, blasting instead of passing wins you [blast3nt average x].  Blasting instead of invite wins you [blast3nt average y]"
  puts "In general, inviting instead of blasting wins you [invite2nt average x].  Inviting instead of passing wins you [invite2nt average y]"
  puts "In general, passing instead of blasting wins you [pass1nt average x]. Passing instead of inviting wins you [pass1nt average y]"
  puts "================================================="
  puts "There are 9 or more tricks $count(nineormore) times ([expr double($count(nineormore))/$count(hands)*100]%)"
  puts "There are 8 tricks $count(eight) times ([expr double($count(eight))/$count(hands)*100]%)"
  puts "There are 7 tricks $count(seven) times ([expr double($count(seven))/$count(hands)*100]%)"
  puts "There are 6 or less tricks $count(sixorless) times ([expr double($count(sixorless))/$count(hands)*100]%)"
  puts "================================"
  puts "North had: 17 points $count(seventeen) times ([expr double($count(seventeen))/$count(hands)*100]%); 16 points $count(sixteen) times ([expr double($count(sixteen))/$count(hands)*100]%); 15 points $count(fifteen) times ([expr double($count(fifteen))/$count(hands)*100]%); 14 points $count(fourteen) times ([expr double($count(fourteen))/$count(hands)*100]%)"
  puts "We accept the invite $count(accept) times ([expr double($count(accept))/$count(hands)*100]%) and decline $count(decline) times ([expr double($count(decline))/$count(hands)*100]%)"
  puts "When we accept we make it $count(acceptandmake) times ([expr double($count(acceptandmake))/$count(accept)*100]% of accepts)"
  puts "When we decline we would have made game $count(declineandgame) times ([expr double($count(declineandgame))/$count(decline)*100]% of declines)"
  puts "When we decline we would make 8 exactly $count(declineanddime) times ([expr double($count(declineanddime))/$count(decline)*100]% of declines)"
}

main {
        reject if {![open1nt north]}
        reject if {![passover1nt east]}
	accept
}
