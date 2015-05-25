south is {K9862 873 98 J74}
north is {Q73 AQ52 762 Q83}
west is {J JT94 AJ5 AT652}

#Similar bug for same South with North as {T53 AKT KT62 Q96} and West is {7 Q942 AQJ74 T82}

proc write_deal {} {
    formatter::write_deal
	set SK [dds -leader south -trick KS east notrump]
    puts "On SK you get $SK for east"
}

main {
	accept
}
