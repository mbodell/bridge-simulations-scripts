south is T92 QJT9 432 432

shapecond nt_shape {$s <= 5 && $s >= 2 && $h <= 5 && $h >= 2 && $d <= 6 && $d >= 2 && $c <= 6 && $c >= 2 && ($s + $h) <= 8}

array set count {
 fourteen 0
 fifteen 0
 sixteen 0
 seventeen 0
 hands 0
}

patternclass longest { return $l1 }
holdingProc aceandtens {a k q j t} { return [expr {$a + $t}] }

proc upgrade_nt {hand} {
  if {[longest $hand] == 6} {return 1}
  if {[longest $hand] == 5 && [aceandtens $hand]>=4} {return 1}
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

proc write_deal {} {
  set h [hcp east]
  global count
  incr count(hands)
  if {$h == 14} { incr count(fourteen) }
  if {$h == 15} { incr count(fifteen) }
  if {$h == 16} { incr count(sixteen) }
  if {$h == 17} { incr count(seventeen) }
  if {$h == 14} {
    formatter::write_deal
    puts "east hcp: $h"
    puts "---------------------------------"
  }
}


deal_finished {
  puts "We were dealt 14 hcp $count(fourteen) times"
  puts "We were dealt 14 hcp $count(fourteen) times or ([expr double($count(fourteen))/$count(hands)]%)"
  puts "We were dealt 15 hcp $count(fifteen) times or ([expr double($count(fifteen))/$count(hands)]%)"
  puts "We were dealt 16 hcp $count(sixteen) times or ([expr double($count(sixteen))/$count(hands)]%)"
  puts "We were dealt 17 hcp $count(seventeen) times or ([expr double($count(seventeen))/$count(hands)]%)"
}

main {
        reject if {![open1nt east]}
	set w [hcp west]
	reject if {$w<9} {$w>15} {[spades west]>3} {[hearts west]>3}
	accept
}