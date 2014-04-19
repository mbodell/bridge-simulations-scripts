south is T92 QJT9 432 432

shapecond nt_shape {$s <= 5 && $s >= 2 && $h <= 5 && $h >= 2 && $d <= 6 && $d >= 2 && $c <= 6 && $c >= 2 && ($s + $h) <= 8}

proc open1nt {hand} {
  set p [hcp $hand]
  if {$p<14 || $p>17} {
    return 0
  } 
  if {![nt_shape $hand]} {
    return 0
  }

  return 1
}

main {
        reject if {![open1nt east]}
	set w [hcp west]
	reject if {$w<9} {$w>15} {[spades west]>3} {[hearts west]>3}
	accept
}