# typograph.p
# v. 0.1.0
# Evgeniy Lepeshkin, 2025-03-21

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
	$result[^result.match[\([рp]\)][gi]{₽}]

	^rem{ plus/minus }
	$result[^result.match[\+/-][gi]{±}]

	^rem{ dash }
	$result[^result.match[-{2}(?>\s)][gi]{—}]
}
### End @parse
