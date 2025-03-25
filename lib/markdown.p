# markdown.p
# v. 0.1.0
# Evgeniy Lepeshkin, 2025-03-25

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
$self.emoji(^if($param.emoji){$param.emoji}{1})
$self.innerHTML(^if($param.innerHTML){$param.innerHTML}{0})
$self.typograph(^if($param.typograph){$param.typograph}{1})
$self.highlight(^if($param.highlight){$param.highlight}{0})

^if($self.highlight){
	^use[lang-highlight.p]
	$tHighlight[$lang-highlight.languages]
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
			$result[$result^outLineRules[^if($parts.type ne $Types.CODE && $parts.type ne $Types.FENCE){^inLineRules[$parts.piece]}{$parts.piece};$parts.type;$parts.cnt]]
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
$result[$text]
^if(def $result){
	^switch[$type]{
		^case[$Types.UL]{
			$result[^result.match[\\n\s*[+*-]\s][g]{\n}]
			$result[^result.match[^^\s*[+*-]\s(.+)?^$][]{<ul><li>^replaceNewLine[$match.1;</li>^#0A<li>]</li></ul>}]
		}
		^case[$Types.OL]{
			$result[^result.match[\\n\s*\d+\.\s][g]{\n}]
			$result[^result.match[^^\s*(\d+)\.\s(.+)?^$][]{<ol start="^match.1.int(1)"><li>^replaceNewLine[$match.2;</li>^#0A<li>]</li></ol>}]
		}
		^case[$Types.H]{
			$result[^result.match[^^(#{1,6})\s(.+)?^$][]{<h^match.1.length[]>$match.2</h^match.1.length[]>}]
		}

		^case[$Types.CITE]{
			$result[^result.match[^^\s*>(?:\s*>)*(.+)?^$][]{<blockquote>^replaceNewLine[$match.1;nesting;$type]</blockquote>}]
		}

		^case[$Types.FENCE]{
			$result[^result.match[^^`{3}\s*([a-z0-9-+]+)?^taint[regex][$Types.NL]?([^^`]*?)`{3}^$][i]{<pre><code^if(def $match.1 && ^tHighlight.locate[lang;$match.1]){ class="language-$match.1"}>^apply-taint[as-is][^replaceNewLine[$match.2]]</code></pre>}]
		}

		^case[$Types.CODE]{
			$result[^result.match[\\n(?: {4}|\t)][g]{\n}]
			$result[^result.match[^^( {4}|\t)(.+)^$][]{<pre><code>^apply-taint[as-is][^replaceNewLine[$match.2]]</code></pre>}]
		}

		^case[DEFAULT]{
			$result[<p>$result</p>]
		}
	}
}{
	^switch[$type]{
		^case[$Types.HR]{
			$result[<hr>]
		}
		^case[DEFAULT]{
			$result[^for[i](1;$cnt){<br>}]
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

		^while($type eq $Types.CITE && $nextType eq $Types.CITE && ^temp.line[] < ^temp.count[]){

			^temp.offset(1)
			$nextType[^checkType[$temp.piece]]
			$piece[$piece^if($nextType eq $Types.CITE){$Types.NL}$temp.piece]
			^temp.delete[]
			^temp.offset(-1)
		}

		^while($type eq $Types.FENCE && $nextType ne $Types.FENCE && ^temp.line[] < ^temp.count[]){
			^temp.offset(1)
			$nextType[^checkType[$temp.piece]]
			$piece[$piece^if($nextType ne $Types.FENCE){$Types.NL}$temp.piece]
			^temp.delete[]
			^temp.offset(-1)
		}

		^while($type eq $Types.CODE && $nextType eq $Types.CODE && ^temp.line[] < ^temp.count[]){
			^temp.offset(1)
			$nextType[^checkType[$temp.piece]]
			$piece[$piece^if($nextType eq $Types.CODE){$Types.NL}$temp.piece]
			^temp.delete[]
			^temp.offset(-1)
		}

		^while($type eq $Types.UL && ($nextType eq $Types.UL || $nextType eq $Types.P) && ^temp.line[] < ^temp.count[]){
			^temp.offset(1)
			$nextType[^checkType[$temp.piece]]
			$piece[$piece^if($nextType eq $Types.UL){$Types.NL}($nextType eq $Types.P){<$Types.BR>}$temp.piece]
			^temp.delete[]
			^temp.offset(-1)
		}

		^while($type eq $Types.OL && ($nextType eq $Types.OL || $nextType eq $Types.P) && ^temp.line[] < ^temp.count[]){
			^temp.offset(1)
			$nextType[^checkType[$temp.piece]]
			$piece[$piece^if($nextType eq $Types.OL){$Types.NL}($nextType eq $Types.P){<$Types.BR>}$temp.piece]
			^temp.delete[]
			^temp.offset(-1)
		}

		^while($type eq $Types.BR && $nextType eq $Types.BR && ^temp.line[] < ^temp.count[]){
			^temp.offset(1)
			$nextType[^checkType[$temp.piece]]
			^if($nextType eq $Types.BR){
				^temp.delete[]
			}
			^temp.offset(-1)
			^cnt.inc[]
		}

		^if($type eq $Types.HR){
			$piece[]
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
	}(^text.match[^^^#{1,6}]){
		$result[$Types.H]
	}(^text.match[^^\s*>(?:\s*>)*]){
		$result[$Types.CITE]
	}(^text.match[^^\s*[+*-]\s]){
		$result[$Types.UL]
	}(^text.match[^^\s*(?:\+|\d+\.?)\s]){
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


#######################################
# Escape tag brackets
@escapeTagBrackets[text]
$result[$text]

^if(def $text){
	$result[^result.match[<(/?[a-z][^^>]*?)>][g]{&lt^;$match.1&gt^;}]
}
### End @escapeTagBrackets


#######################################
@replaceNewLine[text;template;type]
$result[$text]

^if(!def $template){
	$template[^#0A]
}
^if(def $result){
	^if($template eq "nesting"){
		$result[^result.match[^^(.+?)${Types.NL}(.+)?^$][]{$match.1^outLineRules[$match.2;$type]}]
	}{
		$result[^result.replace[$Types.NL;$template]]
	}
}
### End @replaceNewLine


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

# line types
$Types[
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
### End @auto
