south is T92 QJT9 432 432

shapecond nt_shape {$s <= 5 && $s >= 2 && $h <= 5 && $h >= 2 && $d <= 6 && $d >= 2 && $c <= 6 && $c >= 2 && ($s + $h) <= 8}

array set count {
 fourteen 0
 fifteen 0
 sixteen 0
 seventeen 0
 hands 0
 w9 0
 w10 0
 w11 0
 w12 0
 w13 0
 w14 0
 w15 0
}

patternclass longest { return $l1 }
holdingProc aceandtens {a k q j t} { return [expr {$a + $t}] }
holdingProc aceandtenandnine {a k q j t x9} { return [expr {$a + $t + $x9}] }

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
  return 1
}

proc write_deal {} {
  set h [hcp east]
  set hw [hcp west]
  global count
  incr count(hands)
  if {$h == 14} { incr count(fourteen) }
  if {$h == 15} { incr count(fifteen) }
  if {$h == 16} { incr count(sixteen) }
  if {$h == 17} { incr count(seventeen) }
  if {$hw == 9} { incr count(w9) }
  if {$hw == 10} { incr count(w10) }
  if {$hw == 11} { incr count(w11) }
  if {$hw == 12} { incr count(w12) }
  if {$hw == 13} { incr count(w13) }
  if {$hw == 14} { incr count(w14) }
  if {$hw == 15} { incr count(w15) }
  if {$hw == 9 || $hw == 15} {
  formatter::write_deal
  puts "east hcp: $h"
  puts "west hcp: $hw"
  puts "---------------------------------"
  }
}


deal_finished {
  global count
  puts "East was dealt 14 hcp $count(fourteen) times or ([expr double($count(fourteen))/$count(hands)]%)"
  puts "East was dealt 15 hcp $count(fifteen) times or ([expr double($count(fifteen))/$count(hands)]%)"
  puts "East was dealt 16 hcp $count(sixteen) times or ([expr double($count(sixteen))/$count(hands)]%)"
  puts "East was dealt 17 hcp $count(seventeen) times or ([expr double($count(seventeen))/$count(hands)]%)"
  puts "West was dealt 9 hcp $count(w9) times or ([expr double($count(w9))/$count(hands)]%)"
  puts "West was dealt 10 hcp $count(w10) times or ([expr double($count(w10))/$count(hands)]%)"
  puts "West was dealt 11 hcp $count(w11) times or ([expr double($count(w11))/$count(hands)]%)"
  puts "West was dealt 12 hcp $count(w12) times or ([expr double($count(w12))/$count(hands)]%)"
  puts "West was dealt 13 hcp $count(w13) times or ([expr double($count(w13))/$count(hands)]%)"
  puts "West was dealt 14 hcp $count(w14) times or ([expr double($count(w14))/$count(hands)]%)"
  puts "West was dealt 15 hcp $count(w15) times or ([expr double($count(w15))/$count(hands)]%)"
}

main {
        reject if {![open1nt east]}
        reject if {![blast3ntover1nt west]}
	accept
}