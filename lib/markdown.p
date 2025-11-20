# markdown.p
# v. 1.0.2
# Evgeniy Lepeshkin, 2025-11-20

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
# $.highlight(1) - use code hilight with highlight.js
# 
@create[param]
$self.innerHTML(^if($param.innerHTML){$param.innerHTML}{0})
$self.emoji(^if(def $param.emoji){$param.emoji}{1})
$self.typograph(^if($param.typograph){$param.typograph}{1})
$self.highlight(^if($param.highlight){$param.highlight}{0})

^if($self.highlight){
	^use[lang-highlight.p]
	$tHighlight[^table::create[$lang-highlight:languages]]
}
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

	^if(^text.match[\*\^[[A-ZА-ЯЁ]+\^]:]){
		$text[^addAbbreviation[$text]]
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
			^try{
				$result[$result^outLineRules[^if($parts.type ne $Types.CODE && $parts.type ne $Types.FENCE){^inLineRules[$parts.piece]}{$parts.piece};$parts.type;$parts.cnt]]
			}{
				$exceptions.handled(1)
			}
		}{
			$result[$result^#0A]
		}
	}

	$result[^_return[$result;escaped]]
}
### End @parse


#######################################
# Wrap lines with tags and parse nesting tags
#
# @param text {string} — markdown markup
# @param type {string} — string token
# @param cnt {int} — repeat count
# $result {string} — HTML
#
@outLineRules[text;type;cnt][rules]
$result[$text][locals]
^if(def $result){
	^switch[$type]{
		^case[$Types.UL;$Types.OL]{
			$result[^parseList[^replaceNewLine[$result;^#0A]]]
		}

		^case[$Types.H]{
			$result[^result.match[^^(#{1,6})\s(.+)?^$][]{<h^match.1.length[]>$match.2</h^match.1.length[]>}]
		}

		^case[$Types.CITE]{
			$result[^result.match[^^(\s*>(?:\s*>)*)(.*)?^$][]{^if((^cnt.int(0) && $cnt != ^match.1.length[]) || !^cnt.int(0)){<blockquote>}{<$Types.BR>}^replaceNewLine[$match.2;$Types.NESTING;$type;^match.1.length[]]^if((^cnt.int(0) && $cnt != ^match.1.length[]) || !^cnt.int(0)){</blockquote>}}]
		}

		^case[$Types.FENCE]{
			$result[^result.match[^^`{3}\s*([a-z0-9-+]+)?^taint[regex][$Types.NL]?([^^`]*?)`{3}^$][i]{<pre><code^if(def $match.1 && ^tHighlight.locate[lang;$match.1]){ class="language-$match.1"}>^apply-taint[as-is][^replaceNewLine[$match.2]]</code></pre>}]
		}

		^case[$Types.CODE]{
			$result[^result.match[\\n(?: {4}|\t)][g]{\n}]
			$result[^result.match[^^( {4}|\t)(.+)^$][]{<pre><code>^apply-taint[as-is][^replaceNewLine[$match.2]]</code></pre>}]
		}

		^case[$Types.TBL]{
			$result[^result.match[((\|\s*:*\-+:*\s*(?=\|))+\|)\\n][]{</thead>$head[^if(def $match.1){^match.1.mid(1)}]}]
			^if(def $head){
				$aligns[^hash::create[]]
				$head[^head.split[|;v]]
				^head.menu{
					^aligns.add[$.[^head.offset[]][^getAllign[^head.piece.trim[]]]]
				}
			}
			$rows[^result.mid(1)]
			$rows[^rows.split[|;v]]
			$tdCnt(0)
			$tag[th]

			$result[<table><thead><tr>^if($rows){^rows.menu{^if($rows.piece eq $Types.NL){$Types.NL}($rows.piece eq "\n</thead>"){\n</thead>$tag[td]}{<${tag}^if(def $aligns.[$tdCnt]){ align="$aligns.[$tdCnt]"}>$rows.piece^if($tdCnt == ^eval(^aligns._count[] - 1)){$tdCnt(0)}{^tdCnt.inc[]}</${tag}>}}}</tr></table>]

			$result[^replaceNewLine[$result;</tr>^#0A<tr>]]
		}

		^case[DEFAULT]{
			$result[<p>$result</p>]
		}
	}
}{
	^switch[$type]{
		^case[$Types.HR]{
			$result[<$Types.HR>]
		}

		^case[DEFAULT]{
			$result[^for[i](1;$cnt){<$Types.BR>}]
		}
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
	^rem{ bold, italic }
	^if(!^result.match[^^(_{4,}|\*{4,})]){
		$result[^result.match[(?<![_*])(_{1,3}|\*{1,3})([^^\1]+?)\1][g]{${hTag.[^match.1.length[]].open}${match.2}$hTag.[^match.1.length[]].close}]
	}

	^rem{ strike }
	$result[^result.match[(?<!~)(~{2}\b)([^^~]+?)\1(?!~)][g]{<s>$match.2</s>}]

	^rem{ inserted }
	$result[^result.match[(?<!\b)(\+{2}\b)([^^+]+?)\1(?!\b)][g]{<ins>$match.2</ins>}]

	^rem{ marked }
	$result[^result.match[(?<!\b)(\={2}\b)([^^+]+?)\1(?!\b)][g]{<mark>$match.2</mark>}]

	^rem{ image }
	$result[^result.match[\!\^[([^^^]]+)\^]\(([^^)]+?)(?:\s"([^^"]+?)")?\)][g]{<img src="$match.2" alt="^taint[html][$match.1]"^if(def $match.3){title="^taint[html][$match.3]"}>}]

	^rem{ email }
	$result[^result.match[(?<![="]mailto:)(?:&lt^;|<)?([-\w.]+@[-\w.]+\.\w{2,15})(?:&gt^;|>)?][gi]{<a href="mailto:$match.1">$match.1</a>}]

	^rem{ link }
	$result[^result.match[\^[([^^^]]+)\^]\(([^^)]+?)(?:\s"([^^"]+?)")?\)][gi]{<a href="$match.2"^if(def $match.3){ title="^taint[html][$match.3]"}>$match.1</a>}]
	$result[^result.match[(?<![="`])((?:https?://|ftp://|mailto:)(?:[:\w~%{}\./?=&@,#-]+))][gi]{<a href="$match.1">$match.1</a>}]

	^rem{ inline code }
	$result[^result.match[(?<!`)`([^^`]+?)`(?!`)][g]{<code>$match.1</code>}]

	^rem{ subscript }
	$result[^result.match[(?<!~)~([^^~\p{P}]+?)~(?!~)][g]{<sub>$match.1</sub>}]

	^rem{ superscript }
	$result[^result.match[\^^([^^\^^\p{P}]+?)\^^][g]{<sup>$match.1</sup>}]

	^rem{ abbr }
	^if($tAbbreviation){
		^tAbbreviation.menu{
			$result[^result.match[(?<!\.)\b^taint[regex][$tAbbreviation.abbr]\b][g]{<abbr title="^taint[html][$tAbbreviation.title]">$tAbbreviation.abbr</abbr>}]
		}
	}
}
### End @inLineRules


#######################################
# Create strings table with tokens
#
#	@param text {string} — markdown markup
# $result {table} — with broken lines
#
@splitLines[text][locals]
$temp[^table::create{piece}]
^text.match[^^(.*?)^$][gm]{^temp.append[$.piece[$match.1]]}

$result[^table::create{piece	type	cnt}]
^if($temp){
	^temp.menu{
		$piece[$temp.piece]
		$type[^checkType[$temp.piece]]
		^temp.offset(1)
		$nextType[^checkType[$temp.piece]]
		^temp.offset(-1)
		$cnt(0)

		^switch[$type]{
			^case[$Types.CITE]{
				^while($nextType eq $Types.CITE && ^temp.line[] < ^temp.count[]){
					^temp.offset(1)
					$nextType[^checkType[$temp.piece]]
					$piece[$piece^if($nextType eq $Types.CITE){$Types.NL}$temp.piece]
					^temp.delete[]
					^temp.offset(-1)
				}
			}

			^case[$Types.FENCE]{
				^while($nextType ne $Types.FENCE && ^temp.line[] < ^temp.count[]){
					^temp.offset(1)
					$nextType[^checkType[$temp.piece]]
					$piece[$piece^if($nextType ne $Types.FENCE){$Types.NL}$temp.piece]
					^temp.delete[]
					^temp.offset(-1)
				}
			}

			^case[$Types.CODE]{
				^while($nextType eq $Types.CODE && ^temp.line[] < ^temp.count[]){
					^temp.offset(1)
					$nextType[^checkType[$temp.piece]]
					$piece[$piece^if($nextType eq $Types.CODE){$Types.NL}$temp.piece]
					^temp.delete[]
					^temp.offset(-1)
				}
			}

			^case[$Types.UL]{
				^while(($nextType eq $Types.UL || $nextType eq $Types.OL || $nextType eq $Types.P) && ^temp.line[] < ^temp.count[]){
					^temp.offset(1)
					$nextType[^checkType[$temp.piece]]
					$piece[$piece^if($nextType eq $Types.UL || $nextType eq $Types.OL){$Types.NL}($nextType eq $Types.P){<$Types.BR>}$temp.piece]
					^temp.delete[]
					^temp.offset(-1)
				}
			}

			^case[$Types.OL]{
				^while(($nextType eq $Types.OL || $nextType eq $Types.UL || $nextType eq $Types.P) && ^temp.line[] < ^temp.count[]){
					^temp.offset(1)
					$nextType[^checkType[$temp.piece]]
					$piece[$piece^if($nextType eq $Types.OL || $nextType eq $Types.UL){$Types.NL}($nextType eq $Types.P){<$Types.BR>}$temp.piece]
					^temp.delete[]
					^temp.offset(-1)
				}
			}

			^case[$Types.P]{
				^while($nextType eq $Types.P && ^temp.line[] < ^temp.count[]){
					^temp.offset(1)
					$isLast(^temp.line[] == ^temp.count[])
					$nextType[^checkType[$temp.piece]]
					$piece[$piece^if($nextType eq $Types.P){<$Types.BR>}$temp.piece]
					^if($nextType eq $Types.P){
						^temp.delete[]
					}
					^if(!$isLast){
						^temp.offset(-1)
					}
				}
				$isLast(false)
			}

			^case[$Types.BR]{
				^while($nextType eq $Types.BR && ^temp.line[] < ^temp.count[]){
					^temp.offset(1)
					$nextType[^checkType[$temp.piece]]
					^if($nextType eq $Types.BR){
						^temp.delete[]
					}
					^temp.offset(-1)
					^cnt.inc[]
				}
			}

			^case[$Types.TBL]{
				^while($nextType eq $Types.TBL && ^temp.line[] < ^temp.count[]){
					^temp.offset(1)
					$isLast(^temp.line[] == ^temp.count[])
					$nextType[^checkType[$temp.piece]]
					$piece[$piece^if($nextType eq $Types.TBL){$Types.NL}$temp.piece]
					^temp.delete[]
					^if(!$isLast){
						^temp.offset(-1)
					}
				}
				$isLast(false)
			}

			^case[$Types.HR]{
				$piece[]
			}
		}

		^if(($type eq $Types.P || $type eq $Types.H || $type eq $Types.HR) && $nextType eq $Types.BR){
			^temp.offset(1)
			^temp.delete[]
			^temp.offset(-1)
		}

		^result.append[
			$.piece[$piece]
			$.type[$type]
			$.cnt($cnt)
		]

		$type[]
		$nextType[]
	}
}
### End @splitLines


#######################################
# Check type of line
@checkType[text]
$result[]
^if(!def $text){
	$result[$Types.BR]
}{
	^if(^text.match[^^[-_*]{3,}^$]){
		$result[$Types.HR]
	}(^text.match[^^^#{1,6}\s]){
		$result[$Types.H]
	}(^text.match[^^\s*>(?:\s*>)*\s]){
		$result[$Types.CITE]
	}(^text.match[^^\s*[+*-]\s]){
		$result[$Types.UL]
	}(^text.match[^^\s*\d+[.)]?\s]){
		$result[$Types.OL]
	}(^text.match[^^`{3}]){
		$result[$Types.FENCE]
	}(^text.match[^^(?: {4,}|\t+)(?![>+*-])]){
		$result[$Types.CODE]
	}(^text.left(1) eq "|"){
		$result[$Types.TBL]
	}{
		$result[$Types.P]
	}
}
### End @checkType


########################################
# Parse list <ol>, <ul>
# @param text {string} — only list markdown markup
# $result {string} — list HTML
#
@parseList[text][locals]
^if(def $text){
	$levels[^hash::create[]]
	$list[^table::create{level	title	type	number}]

	$text[^text.match[^^([ ]+|\t+)*([+*-]|\d+[.)]?)\s+(.+?)^$][gm]{^list.append[
		$.level(^if(def $match.1 && ^match.1.left(1) eq " "){^eval(^match.1.length[] / 2)}{^match.1.length[]} + 1)
		$.title[$match.3]
		$.type[^if(def $match.2 && ^match.2.match[\d]){$Types.OL}{$Types.UL}]
		$.number[^if(def $match.2 && ^match.2.match[\d+]){^match.2.match[\D+][]{}}{0}]
	]}]

	$level(1)
	$nextNumber(1)

	$result[^apply-taint[optimized-as-is][
		<$list.type>
			^list.menu{
				^if(^list.level.int(0) == $level){
					<li^if($list.type eq $Types.OL && $list.number != $nextNumber){ value="$list.number"}>$list.title</li>
				}{
					^if(^list.level.int(0) > $level){
						$levels.[$list.level][$list.type]<$list.type>^#0A<li>$list.title</li>
					}
					^if(^list.level.int(0) < $level){
						^while($level > ^list.level.int(0)){
							</$levels.[$level]>
							^levels.delete[$level]
							^level.dec[]
						}
						<li>$list.title</li>
					}
					$level(^list.level.int(0))
				}
				$nextNumber($list.number + 1)
			}
		</$list.type>
	]]
}
### End @parseList


#######################################
# Escape tag brackets
@escapeTagBrackets[text]
$result[$text]

^if(def $text){
	$result[^result.match[<(/?[a-z][^^>]*?)>][g]{&lt^;$match.1&gt^;}]
}
### End @escapeTagBrackets


#######################################
@replaceNewLine[text;template;type;cnt]
$result[$text]

^if(!def $template){
	$template[^#0A]
}
^if(def $result){
	^if($template eq $Types.NESTING){
		$result[^result.match[^^(.+?)?(?:^taint[regex][$Types.NL])(.*)^$][]{$match.1^outLineRules[$match.2;$type;$cnt]}]
	}{
		$result[^result.replace[$Types.NL;$template]]
	}
}
### End @replaceNewLine


#######################################
# Add abbreviation table rows
@addAbbreviation[text]
$result[$text]

^if(def $result){
	$result[^result.match[^^\*\^[([A-ZА-ЯЁ]+)\^]: (.+)(?:\n|^$)][gm]{^tAbbreviation.append[$.abbr[$match.1]$.title[$match.2]]}]
}
### End @addAbbreviation


########################################
# Get table align value
@getAllign[text]
$result[]

^if(def $text){
	^if(^text.match[:][gn] == 2){
		$result[center]
	}{
		^if(^text.left(1) eq ":"){
			$result[left]
		}{
				^if(^text.right(1) eq ":"){
				$result[right]
			}	
		}
	}
}
### End @getAlign


#######################################
# remove text structures
@_remove[text;type][locals]
$result[$text]

^if(def $result){
	$counter(0)
	^hContainer.add[$.[$type][^hash::create[]]]
	$result[^text.match[\\(^escaped.menu{^taint[regex][$escaped.char]}[|])][g]{$Types.ESC^hContainer.[$type].add[$.[$counter][$match.1]]^counter.inc[]}]
}
### End @_remove


########################################
# return text structures
@_return[text;type][locals]
$counter(0)
$result[$text]
^if($hContainer.[$type]){
	$result[^result.match[$Types.ESC][g]{$hContainer.[$type].$counter^hContainer.[$type].delete[$counter]^counter.inc[]}]
}
### End @_return


#######################################
@auto[]
$emoji(1)
$innerHTML(0)
$typograph(1)
$highlight(0)

# line types
$Types[
	$.ABBR[abbr]
	$.BR[br]
	$.CITE[cite]
	$.CODE[code]
	$.FENCE[fence]
	$.H[h]
	$.HR[hr]
	$.OL[ol]
	$.P[p]
	$.TBL[tbl]
	$.UL[ul]
	$.NL[\n]
	$.ESC[╔╬╗]
	$.NESTING[nesting]
]

# hash for temporary save text structures
$hContainer[
	$.escaped[]
]

# tags by number of repetitions
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

# escaped chars table
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
\n}]

# highlighted languages
$tHighlight[^table::create{lang}]

# abbreviation
$tAbbreviation[^table::create{abbr	title}]
### End @auto
