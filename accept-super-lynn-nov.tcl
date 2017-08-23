source lib/score.tcl

south is KJ3 T9764 85 K72


array set count {
 hands 0
 tricks 0
 makegame 0
 declinegame 0
 }

sdev trickcount

patternclass longest { return $l1 }
patternclass longest2 { return $l1 + $l2 }
holdingProc aceandtens {a k q j t} { return [expr {$a + $t}] }
holdingProc aceandtenandnine {a k q j t x9} { return [expr {$a + $t + $x9}] }
patterncond has_shortness { $l4 < 2 }
patterncond is_box { $l4 == 3 }
holdingProc honorscount {a k q j t} { return [expr {$a + $k + $q + $j + $t}] }

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
  set tr [deal::tricks south hearts]

  global count
  global trickcount


  incr count(hands)


  if {$tr >= 10} { 
    incr count(makegame) 
    }  else { 
      incr count(declinegame) 
    }

  trickcount add $tr

  set count(tricks) [expr $count(tricks) + $tr]


 # formatter::write_deal
 # puts "There are $tr tricks in hearts"
 # puts "---------------------------------"
}


deal_finished {
  global count
  global makegame
  global declinegame
  global trickcount

  puts "There were an average of [trickcount average] tricks available in hearts"
  puts "We make game $count(makegame) times ([expr double($count(makegame))/$count(hands)*100]%)"
  puts "We don't make game $count(declinegame) times ([expr double($count(declinegame))/$count(hands)*100]%)"
}

main {
  reject if {![bidpass east]}
  reject if {![bidpass west]}
  reject if {![open1nt north]}
  reject if {[hearts north]<4}
  reject if {[hcp north]<16}
	accept
}
