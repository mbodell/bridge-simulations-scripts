south is {942 86 AKQT96 73}

source lib/score.tcl


array set count {
 deals 0
 hands 0
 tricks 0
 make3nt 0
}

sdev blast3nt
sdev invite2nt
sdev trickcount

patternclass longest { return $l1 }
patternclass longest2 { return $l1 + $l2 }
holdingProc aceandtens {a k q j t} { return [expr {$a + $t}] }
holdingProc aceandtenandnine {a k q j t x9} { return [expr {$a + $t + $x9}] }
patterncond has_shortness { $l4 < 2 }
patterncond is_box { $l4 == 3 }
shapecond NT2dshape { $s <= 3 && $s >= 2 && $h <= 3 && $h >= 2 && $d <= 5 && $d >= 2 && $c <= 5 && $c >= 2}

proc open1ntstaynegrejinv {hand} {
  set p [hcp $hand]

  if {$p != 14} {
    return 0
  }

  if {[NT2dshape $hand]} {
    return 1
  }

  return 0
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
  set tr [deal::tricks south notrump]

  global count
  global trickcount

  incr count(hands)

  if {$tr >= 9} { incr count(make3nt) }

  trickcount add $tr

  set count(tricks) [expr $count(tricks) + $tr]



#  formatter::write_deal
#  puts "There are $tr tricks in NT"
}


deal_finished {
  global count
  global trickcount
  puts "We dealt $count(deals) hands to find the result of these $count(hands) hands"
  puts "There were an average of [trickcount average] tricks available in nt"
  puts "We made game $count(make3nt) times ([expr double($count(make3nt))/$count(hands)*100]%)"
}

main {
  global count
  incr count(deals)
  reject if {([spades north] < 2) || ([spades north] > 4)}
  reject if {([hearts north] < 2) || ([hearts north] > 5)}
  reject if {([diamonds north] < 1) || ([diamonds north] > 5)}
  reject if {([clubs north] < 2) || ([clubs north] > 6)}
  reject if {([hcp north] < 13) || ([hcp north] > 14)}
	accept
}
