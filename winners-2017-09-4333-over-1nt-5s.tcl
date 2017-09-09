south is {T843 AT8 KT9 Q85}

source lib/score.tcl


array set count {
 attempts 0
 hands 0
 tricks 0
 tricksS 0
 decline 0
 declineandgame 0
 declineanddime 0
 acceptSp 0
 acceptSpBothMake 0
 acceptSpSpMake 0
 acceptSp3ntMake 0
 acceptSpBothFail 0
 acceptSpSpBetter 0
 acceptSpSpWorse 0
 choiceOfSpBetter 0
 choiceOfSpWorse 0
 choiceOfBothMake 0
 choiceOfSpMake 0
 choiceOf3ntMake 0
 choiceOfBothFail 0
}

sdev blast3nt
sdev invite2nt
sdev inviteS
sdev trickcount
sdev trickScount

patternclass longest { return $l1 }
patternclass longest2 { return $l1 + $l2 }
holdingProc aceandtens {a k q j t} { return [expr {$a + $t}] }
holdingProc aceandtenandnine {a k q j t x9} { return [expr {$a + $t + $x9}] }
patterncond has_shortness { $l4 < 2 }
patterncond is_box { $l4 == 3 }
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
  set tr [deal::tricks north notrump]
  set trS [deal::tricks north spades]

  global count
  global blast3nt
  global invite2nt
  global inviteS
  global trickcount
  global trickScount


  incr count(hands)


  trickcount add $tr

  set count(tricks) [expr $count(tricks) + $tr]
  
  trickScount add $trS

  set count(tricksS) [expr $count(tricksS) + $trS]

  set accept [open1ntandacceptinv north]
  
  if {$tr >= 9 } {
    blast3nt add 1
  } else {
    blast3nt add 0
  }
  
  if {$accept} {
    if {$tr >= 9 } {
      invite2nt add 1
    } else {
      invite2nt add 0
    }
    if {[spades north] >= 4} {
      if {$trS >= 10} {
        inviteS add 1
      } else {
        inviteS add 0
      }
    }
  } else {
    incr count(decline)
    if {$tr >= 9} {
      incr count(declineandgame)
    } elseif {$tr == 8} {
      incr count(declineanddime)
    }
  }

  if {$accept && [spades north] >= 4} {
    incr count(acceptSp)
    if {$tr >= 9 && $trS >= 10} {
      incr count(acceptSpBothMake)
      if {$tr >= $trS} {
        incr count(acceptSpSpWorse)
      } else {
        incr count(acceptSpSpBetter)
      }
    } elseif {$tr >= 9} {
      incr count(acceptSp3ntMake)
      incr count(acceptSpSpWorse)
    } elseif {$trS >= 10} {
      incr count(acceptSpSpMake)
      incr count(acceptSpSpBetter)
    } else {
      incr count(acceptSpBothFail)
      if {($tr + 1) > $trS} {
        incr count(acceptSpSpWorse)
      } elseif {($tr + 1) < $trS} {
        incr count(acceptSpSpBetter)
      }
    }
  }
  if {[spades north] >= 4} {
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
  }

#  formatter::write_deal
#  puts "There are $tr tricks in NT"
#  puts "There are $trS tricks in spades"
#  puts "Do we accept? $accept"
#  puts "---------------------------------"
}


deal_finished {
  global count
  global blast3nt
  global invite2nt
  global inviteS
  global trickcount
  global trickScount

  set same [expr $count(acceptSp) - $count(acceptSpSpWorse) - $count(acceptSpSpBetter)]

  puts "We attempted $count(attempts) shuffles and played $count(hands) total hands"
  puts "=================================================="
  puts "Across all hands there were an average of [trickcount average] tricks available in nt"
  puts "Across all hands there were an average of [trickScount average] tricks available in spades"
  set blastA [blast3nt average]
  set blastM [expr $blastA * $count(hands)]
  puts "The blasting games made [expr round($blastM)] games ([expr double(round($blastA * 10000))/100]%)"
  puts "==================================================="
  set acceptI [expr $count(hands) - $count(decline)]
  puts "We'd invite and end up in game $acceptI times ([expr double(round(double($acceptI)/$count(hands)*10000))/100]%)"
  set invA [invite2nt average]
  set invG [expr $invA * $acceptI]
  puts "We'd make game after accepting the invite $invG times ([expr double(round($invA*10000))/100]%)"
#  puts "The inviting spade games made [inviteS average] percent of the time"

  puts "==================================================="
  puts "We'd decline invites $count(decline) times ([expr double($count(decline))/$count(hands)*100]%)"
  if {$count(decline)} {
  puts "When we stay low we would have made game $count(declineandgame) times ([expr double(round(double($count(declineandgame))/$count(decline)*10000))/100]%)"
  puts "When we stay low we would make 8 exactly $count(declineanddime) times ([expr double(round(double($count(declineanddime))/$count(decline)*10000))/100]%)"
  puts "When we stay low we would make 7 or fewer exactly [expr $count(decline) - $count(declineanddime) - $count(declineandgame)] times ([expr double(round(double(($count(decline) - $count(declineanddime) - $count(declineandgame)))/$count(decline)*10000))/100]%)"
  }
  puts "=================================================="
  puts "We'd accept spade invites $count(acceptSp) times ([expr double(round(double($count(acceptSp))/$count(hands)*10000))/100]%)"
  if {$count(acceptSp)} {
    puts "When we accept Spades scores better $count(acceptSpSpBetter) times ([expr double(round(double($count(acceptSpSpBetter))/$count(acceptSp)*10000))/100]%), NT scores better $count(acceptSpSpWorse) times ([expr double(round(double($count(acceptSpSpWorse))/$count(acceptSp)*10000))/100]%) and they are the same $same times ([expr double(round(double($same)/$count(acceptSp)*10000))/100]%)"
    puts "when we accept Spades both games make $count(acceptSpBothMake) times ([expr double(round(double($count(acceptSpBothMake))/$count(acceptSp)*10000))/100]%), only the NT game makes $count(acceptSp3ntMake) times ([expr double(round(double($count(acceptSp3ntMake))/$count(acceptSp)*10000))/100]%), only spades make $count(acceptSpSpMake) times ([expr double(round(double($count(acceptSpSpMake))/$count(acceptSp)*10000))/100]%), and both are down $count(acceptSpBothFail) times ([expr double(round(double($count(acceptSpBothFail))/$count(acceptSp)*10000))/100]%)"
  }
  puts "=================================================="
  set sameS [expr $count(hands) - $count(choiceOfSpBetter) - $count(choiceOfSpWorse)]
  puts "If we choice of game between 4 Spaces and 3nt and end up in spades"
  puts "Spades scores better $count(choiceOfSpBetter) times ([expr double(round(double($count(choiceOfSpBetter))/$count(hands)*10000))/100]%), NT scores better $count(choiceOfSpWorse) times ([expr double(round(double($count(choiceOfSpWorse))/$count(hands)*10000))/100]%) and they are the same $sameS times ([expr double(round(double($sameS)/$count(hands)*10000))/100]%)"
  puts "when we accept Spades both games make $count(choiceOfBothMake) times ([expr double(round(double($count(choiceOfBothMake))/$count(hands)*10000))/100]%), only the NT game makes $count(choiceOf3ntMake) times ([expr double(round(double($count(choiceOf3ntMake))/$count(hands)*10000))/100]%), only spades make $count(choiceOfSpMake) times ([expr double(round(double($count(choiceOfSpMake))/$count(hands)*10000))/100]%), and both are down $count(choiceOfBothFail) times ([expr double(round(double($count(choiceOfBothFail))/$count(hands)*10000))/100]%)"
}

main {
  global count

  incr count(attempts)
  reject if {![open1nt north]}
  reject if {[spades north] < 5}
  reject if {![passover1nt east]}
  accept
}
