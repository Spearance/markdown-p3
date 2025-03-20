# Evgeniy Lepeshkin, 2025 v. 0.1.0

@CLASS
markdown

#######################################
# Parse markdown markup to HTML
#
#	@param text {string} — markdown markup
# $result {string} — HTML markup
#
@parse[text][parts]
$result[]

^if(def $text){
	^if(^text.match[</?[a-z]][i]){
		$text[^escapeTagBrackets[$text]]
	}

	$parts[^splitLines[$text]]

	^if($parts){
		^parts.menu{
			$result[$result^outLineRules[^inLineRules[$parts.piece];$parts.prev;$parts.next]]
		}{
			$result[$result^#0A]
		}
	}
}
### End @parse


#######################################
@outLineRules[text;prev;next][rules]
$result[$text]
^if(def $result){
	^switch[^result.left(1)]{
		^case[_]{
			^rem{ hr }
			$result[^result.match[^^[_]{3,}\s*^$][]{<hr>}]
		}
		^case[-;*]{
			^if(^result.mid(1;1) eq " "){
				^rem{ li }
				$result[^result.match[^^[*-]\s(.+?)^$][]{<li>$match.1</li>}]
			}{
				^if(^result.mid(1;1) ne "^["){
					^rem{ hr }
					$result[^result.match[^^[*-]{3,}\s*^$][]{<hr>}]
				}{
					^rem{ tag <abbr> }
				}
			}
		}
		^case[^#]{
			^rem{ Headers }
			$result[^result.match[^^(#{1,6})\s(.+?)^$][]{<h^match.1.length[]>$match.2</h^match.1.length[]>}]
		}

		^case[>]{
			^rem{ blockquote }
			$result[^result.match[^^(\>)\s(.+?)^$][]{<blockquote>$match.2</blockquote>}]
		}

		^case[DEFAULT]{
			$result[<p>$result</p>]
		}
	}
}{
	^if($prev eq "\n" && $next eq "\n"){
		$result[$result<br>]
	}
}
### @outLineRules


#######################################
@inLineRules[text]
$result[$text]

^if(def $result){
	^rem{ new line }
	$result[^result.match[\^{%\\n%\^}][g]{<br>}]

	^rem{ bold, italic }
	^if(!^result.match[^^(_{4,}|\*{4,})]){
		$result[^result.match[(?<![_*])(_{1,3}|\*{1,3}\b)([^^\1]+?)\1][g]{${hTag.[^match.1.length[]].open}${match.2}$hTag.[^match.1.length[]].close}]
	}

	^rem{ strike }
	$result[^result.match[(?<!\b)(~{1,2}\b)([^^~]+?)\1(?!\b)][g]{<s>$match.2</s>}]

	^rem{ inserted }
	$result[^result.match[(?<!\b)(\+{2}\b)([^^+]+?)\1(?!\b)][g]{<ins>$match.2</ins>}]

	^rem{ marked }
	$result[^result.match[(?<!\b)(\={2}\b)([^^+]+?)\1(?!\b)][g]{<mark>$match.2</mark>}]

	^rem{ image }
	$result[^result.match[\!\^[([^^^]]+)\^]\(([^^)]+)\)][g]{<img src="$match.2" alt="^taint[html][$match.1]">}]

	^rem{ link }
	$result[^result.match[\^[([^^^]]+)\^]\(([^^)]+?)(?:\s"([^^"]+?)")?\)][g]{<a href="$match.2"^if(def $match.3){ title="^taint[html][$match.3]"}>$match.1</a>}]

	^rem{ inline code }
	$result[^result.match[(?<!`)`([^^`]+?)`(?!`)][g]{<code>$match.1</code>}]

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
### End @rules


#######################################
# Create table with broaking to lines text 
# including previus and next chars
#
#	@param text {string} — markdown markup
# $result {table} — with broken lines
#
@splitLines[text][temp;prev;next]
$temp[^table::create{piece}]
^text.match[^^(.*?)^$][gm]{^temp.append[$.piece[$match.1]]}

$result[^table::create{piece	prev	next}]

^if($temp){
	^temp.menu{
		^if(^temp.line[] > 1){
			^temp.offset(-1)
			$prev[^if(def $temp.piece){^temp.piece.left(1)}{\n}]
			^temp.offset(1)
		}{
			$prev[\A]
		}
		^if(^temp.line[] < ^temp.count[]){
			^temp.offset(1)
			$next[^if(def $temp.piece){^temp.piece.left(1)}{\n}]
			^temp.offset(-1)
		}{
			$next[\Z]
		}

		^result.append[
			$.piece[$temp.piece^if(def $temp.piece && !^tStarts.locate[char;$next]){^{%\n%^}^temp.offset(1)$temp.piece^temp.delete[]}]
			$.prev[$prev]
			$.next[$next]
		]
	}
}
### End @splitLines


#######################################
# Escape tag brackets
@escapeTagBrackets[text]
$result[$text]

^if(def $text){
	$result[^result.match[<(/?[a-z][^^>]*?)>][g]{&lt^;$match.1&gt^;}]
}
### End @escapeTescapeTagBracketsags


#######################################
@auto[]
$hTag[
	^rem{ italic }
	$.1[
		$.open[<em>]
		$.close[</em>]
	]
	^rem{ bold }
	$.2[
		$.open[<strong>]
		$.close[</strong>]
	]
	^rem{ bold-italic }
	$.3[
		$.open[<strong><em>]
		$.close[</em></strong>]
	]
]

$tStarts[^table::create{char
\n
-
_
*
~
^#
!
>
+}]
### End @auto
