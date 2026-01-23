# typograph.p
# v. 1.1.1
# Evgeniy Lepeshkin, 2026-01-23

@CLASS
typograph

#######################################
@parse[text]
$result[$text]

^if(def $result){
	^rem{ copyright }
	$result[^result.match[\([cс]\)][gi]{©}]

	^rem{ trademark }
	$result[^result.match[\(tm\)][gi]{<sup>™</sup>}]

	^rem{ registered }
	$result[^result.match[\(r\)][gi]{<sup>®</sup>}]

	^rem{ ruble }
	$result[^result.match[(?<![a-z])\([рp]\)][gi]{₽}]

	^rem{ plus/minus }
	$result[^result.match[\+/-][g]{±}]

	^rem{ dash }
	$result[^result.match[(?<!-)-{2}(?>\s)][g]{—}]

	^rem{ hellip }
	$result[^result.match[(?<!\.)\.{3}(?!\.)][g]{…}]
}
### End @parse
