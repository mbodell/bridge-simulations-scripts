south is QT2 J932 QJ42 32

shapecond nt_shape {$s <= 5 && $s >= 2 && $h <= 5 && $h >= 2 && $d <= 6 && $d >= 2 && $c <= 6 && $c >= 2 && ($s + $h) <= 8}

array set count {
 hands 0
 dQ 0
 d2 0
 dQset 0
 d2set 0
 dQMP 0
 dQW 0
 dQT 0
 tr 0
 heart2 0
 club2 0
 spadeQ 0
 spadeT 0
 spade2 0
}

patternclass longest { return $l1 }
patternclass shortest { return $l4 }
holdingProc aceandtens {a k q j t} { return [expr {$a + $t}] }
holdingProc aceandtenandnine {a k q j t x9} { return [expr {$a + $t + $x9}] }

proc upgrade_nt {hand} {
  if {[longest $hand] >= 6} {return 1}
  if {[longest $hand] == 5 && ([aceandtens $hand]>=4 || [aceandtenandnine $hand]>=6)} {return 1}
  if {[aceandtens $hand]>=5 || [aceandtenandnine $hand] >= 7} {return 1}
  return 0
}

proc open2nt {hand} {
  set p [hcp $hand]
  if {$p < 19 || $p > 21} {
    return 0
  }
  if {![nt_shape $hand]} { 
    return 0 
  }
  if {$p==19 && ![upgrade_nt $hand]} {
    return 0
  }

  return 1
}

proc transferSbid3ntover1nt {hand} {
  set p [hcp $hand]
  if {$p < 4 || $p > 10} {
    return 0
  }
  if {[spades $hand] != 5} {
    return 0
  }
  if {[hearts $hand] > 3} {
    return 0
  }
  if {[clubs $hand] > 5} {
    return 0
  }
  if {[diamonds $hand] > 5} {
    return 0
  }
  return 1
}

proc pass3ntoverStransfer {hand} {
  if {[spades $hand] > 3} { return 0 }
  if {[spades $hand] == 3 && [shortest $hand] != 3} { return 0 }
  return 1
}


proc write_deal {} {
  set tr [deal::tricks east notrump]
  set trQ [dds -leader south -trick QD east notrump]
  set tr2 [dds -leader south -trick 2D east notrump]
  set trH2 [dds -leader south -trick 2H east notrump]
  set trC2 [dds -leader south -trick 2C east notrump]
  set trSQ [dds -leader south -trick QS east notrump]
  set trST [dds -leader south -trick TS east notrump]
  set trS2 [dds -leader south -trick 2S east notrump]
  global count
  incr count(hands)

  set tmpTr $count(tr)
  set count(tr) [expr $tmpTr + $tr]

  set tmpQ $count(dQ)
  set count(dQ) [expr $tmpQ + $trQ]

  set tmp2 $count(d2)
  set count(d2) [expr $tmp2 + $tr2]

  set tmph2 $count(heart2)
  set count(heart2) [expr $tmph2 + $trH2]

  set tmpc2 $count(club2)
  set count(club2) [expr $tmpc2 + $trC2]

  set tmpsQ $count(spadeQ)
  set count(spadeQ) [expr $tmpsQ + $trSQ]

  set tmpsT $count(spadeT)
  set count(spadeT) [expr $tmpsT + $trST]

  set tmps2 $count(spade2)
  set count(spade2) [expr $tmps2 + $trS2]

  if {$trQ < 9} { incr count(dQset) }
  if {$tr2 < 9} { incr count(d2set) }

  if {$trQ < $tr2} {
    incr count(dQMP)
    incr count(dQMP)
#    puts "DQ MP 2"
    incr count(dQW)
  }
  
  if {$trQ == $tr2} {
    incr count(dQMP)
#    puts "DQ MP 1"
    incr count(dQT)
  }

  if {$trQ > $tr2} {
#    puts "DQ MP 0"
  }

#  formatter::write_deal
#  puts "---------------------------------"
}


deal_finished {
  global count
  puts "On the double dummy best lead each time declarer took $count(tr) or [expr double($count(tr))/$count(hands)] tricks on average"
  puts "On the diamond Q lead declarer took $count(dQ) tricks or [expr double($count(dQ))/$count(hands)] tricks on average"
  puts "On the diamond 2 lead declarer took $count(d2) tricks or [expr double($count(d2))/$count(hands)] tricks on average"
  puts "The diamond Q lead set declarer $count(dQset) times or ([expr double($count(dQset))/$count(hands)*100]%)"
  puts "The diamond 2 lead set declarer $count(d2set) times or ([expr double($count(d2set))/$count(hands)*100]%)"
  puts "The matchpoint score for the diamond Q lead is ([expr double($count(dQMP))/(2*$count(hands))*100]%) based on $count(dQW) wins and $count(dQT) ties and [expr {$count(hands) - $count(dQW) - $count(dQT)}] losses"
  puts "On the heart 2 lead declarer took $count(heart2) tricks or [expr double($count(heart2))/$count(hands)] tricks on average"
  puts "On the club 2 lead declarer took $count(club2) tricks or [expr double($count(club2))/$count(hands)] tricks on average"
  puts "On the spade Q lead declarer took $count(spadeQ) tricks or [expr double($count(spadeQ))/$count(hands)] tricks on average"
  puts "On the spade T lead declarer took $count(spadeT) tricks or [expr double($count(spadeT))/$count(hands)] tricks on average"
  puts "On the spade 2 lead declarer took $count(spade2) tricks or [expr double($count(spade2))/$count(hands)] tricks on average"

}

main {
        reject if {![open2nt east]}
	reject if {![transferSbid3ntover1nt west]}
	reject if {![pass3ntoverStransfer east]}
	accept
}
