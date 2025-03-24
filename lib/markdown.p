# markdown.p
# v. 0.1.0
# Evgeniy Lepeshkin, 2025-03-24

@CLASS
markdown

#######################################
# Constructor
#
# @param param {hash} - preferences
#
# $.emoji(1) - parse emoji shortcuts
# $.innerHTML(0) - accept inline HTTML (not safe)
# $.typograph(1) — use typograph replacement
# 
@create[param]
$self.emoji(^if($param.emoji){$param.emoji}{1})
$self.innerHTML(^if($param.innerHTML){$param.innerHTML}{0})
$self.typograph(^if($param.typograph){$param.typograph}{1})
### End @create


#######################################
# Parse markdown markup to HTML
#
# @param text {string} — markdown markup
# $result {string} — HTML markup
#
@parse[text][parts]
$result[]

^if(def $text){
	
	^if(!$innerHTML && ^text.match[</?[a-z]][i]){
		$text[^escapeTagBrackets[$text]]
	}

	$text[^_remove[$text;escaped]]

	^if($emoji){
		^use[emoji-shortcuts.p]
		$text[^emoji-shortcuts:parse[$text]]
	}

	^if($typograph){
		^use[typograph.p]
		$text[^typograph:parse[$text]]
	}

	$parts[^splitLines[$text]]

	^if($parts){
		^parts.menu{
			$result[$result^outLineRules[^inLineRules[$parts.piece];$parts.prev;$parts.next]]
		}{
			$result[$result^#0A]
		}
	}

	$result[^_return[$result;escaped]]
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
			^rem{ paragraph }
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
# Parse inline styles and HTML
#
# @param text {string} — markdown markup
# $result {string} — markdown with parsed inline
#
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
}
### End @inLineRules


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
### End @escapeTagBrackets


#######################################
# remove text structures
@_remove[text;type][locals]
$result[$text]

^if(def $result){
	$counter(0)
	^hContainer.add[$.[$type][^hash::create[]]]
	$result[^text.match[\\(^escaped.menu{^taint[regex][$escaped.char]}[|])][g]{╔╬╗^hContainer.[$type].add[$.[$counter][$match.1]]^counter.inc[]}]
}
### End @_remove


########################################
# return text structures
@_return[text;type][locals]
$counter(0)
$result[$text]
^if($hContainer.[$type]){
	$result[^result.match[╔╬╗][g]{$hContainer.[$type].$counter^hContainer.[$type].delete[$counter]^counter.inc[]}]
}
### End @_return


#######################################
@auto[]
$emoji(1)
$innerHTML(0)
$typograph(1)

$hContainer[
	$.escaped[]
]

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

$escaped[^table::create{char
\
`
*
_
^{
^}
^[
^]
^(
^)
^#
-
.
!
|
~
=
<
>
&lt^;
&gt^;}]

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
