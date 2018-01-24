source lib/score.tcl

shapecond nt_shape {$s <= 5 && $s >= 2 && $h <= 5 && $h >= 2 && $d <= 6 && $d >= 2 && $c <= 6 && $c >= 2 && ($s < 5 || ($h < 4 && $c < 4 && $d < 4)) && ($h < 5 || ($s < 4 && $c < 4 && $d < 4))}

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

proc open1ntweak {hand} {
  set p [hcp $hand]
  if {$p<11 || $p>14} {
    return 0
  } 
  if {![nt_shape $hand]} {
    return 0
  }
  if {$p==11 && ![upgrade_nt $hand]} {
    return 0
  }
  if {$p==14 && [upgrade_nt $hand]} {
    return 0
  }

  return 1
}


proc write_deal {} {
  formatter::write_deal
  puts "---------------------------------"
}


deal_finished {
}

main {
  reject if {![open1ntweak south]}
	accept
}
