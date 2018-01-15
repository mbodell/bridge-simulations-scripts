
source lib/score.tcl


array set count {
 attempts 0
 hands 0
 tricks 0
 tricksS 0
 choiceOfSpBetter 0
 choiceOfSpWorse 0
 choiceOfBothMake 0
 choiceOfSpMake 0
 choiceOf3ntMake 0
 choiceOfBothFail 0
}

sdev trickcount
sdev trickScount
sdev impSpadeV
sdev impSpadeNV


patternclass longest { return $l1 }
patternclass longest2 { return $l1 + $l2 }
holdingProc aceandtens {a k q j t} { return [expr {$a + $t}] }
holdingProc aceandtenandnine {a k q j t x9} { return [expr {$a + $t + $x9}] }
patterncond has_shortness { $l4 < 2 }
patterncond is_box { $l4 == 3 }
patterncond is_4432 { $l1 == 4 && $l2 == 4 && $l3 == 3 && $l4 == 2 }
patterncond is_5332 { $l1 == 5 && $l2 == 3 && $l3 == 3 && $l4 == 2 }
shapecond NT2dshape { $s <= 3 && $s >= 2 && $h <= 3 && $h >= 2 && $d <= 5 && $d >= 2 && $c <= 5 && $c >= 2}
shapecond NTshape {$s <= 5 && $s >= 2 && $h <= 5 && $h >= 2 && $d <= 6 && $d >= 2 && $c <= 6 && $c >= 2 && ($s < 5 || ($h < 4 && $d < 4 && $c < 4)) && ($h < 5 || ($s < 4 && $d < 4 && $c < 4))} 

proc open1nt {hand} {
  set p [hcp $hand]

  if { $p < 14 || $p > 17 } {
    return 0
  }

  if {![NTshape $hand]} {
    return 0
  }
  if {$p == 14} {
    if {[longest $hand] < 5 && !([aceandtens $hand] > 3 || [aceandtenandnine $hand] > 5)} {
      return 0
    }
  }
  if {$p == 17} {
    if {[longest $hand] >= 5 || ([aceandtens $hand] > 3 || [aceandtenandnine $hand] > 5)} {
      return 0
    }
  }

  return 1
}

proc open1ntandacceptinv {hand} {
  set p [hcp $hand]
  set l [longest $hand]
  
  if {($p + $l) >= 20} {
    return 1
  }

  return 0
}

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
  set trS [deal::tricks south spades]

  set scV [score {3 notrump} vul $tr]
  set scSV [score {4 spades} vul $trS]
  set scNV [score {3 notrump} nonvul $tr]
  set scSNV [score {4 spades} nonvul $trS]

  global count
  global trickcount
  global trickScount
  global impSpadeV
  global impSpadeNV


  incr count(hands)


  trickcount add $tr

  set count(tricks) [expr $count(tricks) + $tr]
  
  trickScount add $trS

  set count(tricksS) [expr $count(tricksS) + $trS]

  if {$tr >= 9 && $trS >= 10} {
    incr count(choiceOfBothMake)
    if {$tr >= $trS} {
      incr count(choiceOfSpWorse)
    } else {
      incr count(choiceOfSpBetter)
    }
  } elseif {$tr >= 9} {
    incr count(choiceOf3ntMake)
    incr count(choiceOfSpWorse)
  } elseif {$trS >= 10} {
    incr count(choiceOfSpMake)
    incr count(choiceOfSpBetter)
  } else {
    incr count(choiceOfBothFail)
    if {($tr + 1) > $trS} {
      incr count(choiceOfSpWorse)
    } elseif {($tr + 1) < $trS} {
      incr count(choiceOfSpBetter)
    }
  }

  set impSV [imp_score $scSV $scV]

  impSpadeV add $impSV

  set impSNV [imp_score $scSNV $scNV]

  impSpadeNV add $impSNV

#  formatter::write_deal
#  puts "There are $tr tricks in NT (NV $scNV, V $scV)"
#  puts "There are $trS tricks in spades (NV $scSNV, V $scSV); imps V $impSV; imps NV $impSNV"
#  puts "---------------------------------"
}


deal_finished {
  global count
  global trickcount
  global trickScount
  global impSpadeV
  global impSpadeNV

  puts "We attempted $count(attempts) shuffles and played $count(hands) total hands"
  puts "=================================================="
  puts "Across all hands there were an average of [trickcount average] tricks available in nt"
  puts "Across all hands there were an average of [trickScount average] tricks available in spades"
  puts "=================================================="
  set sameS [expr $count(hands) - $count(choiceOfSpBetter) - $count(choiceOfSpWorse)]
  puts "If we choice of game between 4 Spaces and 3nt:"
  puts "Spades scores better $count(choiceOfSpBetter) times ([expr double(round(double($count(choiceOfSpBetter))/$count(hands)*10000))/100]%), NT scores better $count(choiceOfSpWorse) times ([expr double(round(double($count(choiceOfSpWorse))/$count(hands)*10000))/100]%) and they are the same $sameS times ([expr double(round(double($sameS)/$count(hands)*10000))/100]%)"
  puts "So in MP of even split S scores [expr double(round(double($count(choiceOfSpBetter)*2+$sameS)/(2*$count(hands))*10000))/100]% and NT scores [expr double(round(double($count(choiceOfSpWorse)*2+$sameS)/(2*$count(hands))*10000))/100]%"
  puts "=================================================="
  puts "In terms of games: both games make $count(choiceOfBothMake) times ([expr double(round(double($count(choiceOfBothMake))/$count(hands)*10000))/100]%), only the NT game makes $count(choiceOf3ntMake) times ([expr double(round(double($count(choiceOf3ntMake))/$count(hands)*10000))/100]%), only spades make $count(choiceOfSpMake) times ([expr double(round(double($count(choiceOfSpMake))/$count(hands)*10000))/100]%), and both are down $count(choiceOfBothFail) times ([expr double(round(double($count(choiceOfBothFail))/$count(hands)*10000))/100]%)"
  puts "So being in spades scored [impSpadeNV average] imps better when NV"
  puts "So being in spades scored [impSpadeV average] imps better when V"
}

main {
  global count

  incr count(attempts)
  reject if {![open1nt north]}
  reject if {[spades north] != 3}
  reject if {![is_5332 north]}
  # North is 3=(532) and 15-17 NT
#  reject if {![passover1nt east]}
  reject if {![is_5332 south]}
  reject if {[spades south] < 5}
  reject if {[hcp south] != 9}
  # South is 5=(332) and 9 hcp
  accept
}
