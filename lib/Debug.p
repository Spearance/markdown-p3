@dstop[o]
	^if(^Debug:isDeveloper[]){
		^process[$MAIN:CLASS]{@unhandled_exception[hException^;tStack]^#0A^^Debug:exception[^$hException^;^$tStack]}
		^if($o is double){ ^Debug:stop($o) }{ ^Debug:stop[$o] }
	}
	$result[]

@dshow[o][result]
	^if(^Debug:isDeveloper[] && (!def $form:mode || $form:mode ne xml)){
		^if($o is double){ ^Debug:show($o) }{ ^Debug:show[$o] }
	}

@dcompact[h][result]
	^Debug:compact[^hash::create[$h]]

@CLASS
Debug

@auto[]
#	$self.bDeveloper(^env:REMOTE_ADDR.match[^^87\.254\.136\.170]))
	$self.bDeveloper(true)
	$self.tReplacePath[^table::create[nameless]{^if(def $env:DOCUMENT_ROOT){$env:DOCUMENT_ROOT	&#8230^;/}}]
	$self.sSavePath[/../data/log/debug.html]
	$self.hStatistics[
		$.iCalls(0)
		$.iCompact(0)
		$.hUsage[
			$.hBegin[$status:rusage]
		]
		$.hMemory[
			$.iEnd(0)
			$.iCollected(0)
			$.iBegin($status:memory.used)
		]
		$.fStartTime($status:rusage.tv_sec+$status:rusage.tv_usec/1000000)
	]

	$self.sConsole[^self.getStyle[]]

	$self.iTabSize(4)

	$self.iLimit(16384)
	$self.iCall(0)
	$self.iHashId(0)

	$self.iShift(0)

@isDeveloper[][result]
	$result($bDeveloper)

@exception[hException;tStack]
	$response:status(500)
	$response:content-type[
		$.value[text/html]
		$.charset[$response:charset]
	]
	<style type="text/css" media="screen">
		body{background-color:#f5f5f5;font-size:100%;margin:0;padding: 0}
	</style>
	<div id="_D">
		^if($hException.type eq debug){
			^taint[optimized-as-is][$hException.source]
		}{
			<pre>^untaint[html]{ $hException.comment }</pre>
			^if(def $hException.source){
				<b>$hException.source</b><br>
				<pre>^untaint[html]{$hException.file^($hException.lineno^)}</pre>
			}
			^if(def $hException.type){ exception.type=$hException.type }
		}
		^if($tStack is table){
			<hr/>
			<table id="_dStack">
			^tStack.menu{
				^if($hException.type eq debug && ^tStack.line[] < 4 && $tStack.name ne rem){}{<tr><th>^^$tStack.name</th><td>^file:dirname[^if(def $tStack.file){^tStack.file.replace[$self.tReplacePath]}]/<i>^file:basename[$tStack.file] ^[$tStack.lineno^]</i><sup>$tStack.colno</sup></td></tr>}
			}
			</table>
		}
	</div>



@extendPostprocess[]
	^if($MAIN:postprocess is junction){
		$MAIN:jOriginalPostprocess[$MAIN:postprocess]
	}
	^process[$MAIN:CLASS]{@postprocess[body][result]
		^^if(^$MAIN:jOriginalPostprocess is junction){
			^$body[^^MAIN:jOriginalPostprocess[^$body]]
		}
		^^if(^$Debug:iCall){
			^$result[^^body.match[(<body[^^^^>]*>)?][i]{^$match.1<div style="display:none" id="_D">^^Debug:getScript^[^]^$Debug:sConsole</div>}]
		}
	}

@getScript[]
<script>
function Debug_Toggle(s) {
	var o = document.getElementById(s);
	if(o) o.style.display = o.style.display == '' ? 'none' : '';
}
function Debug_Console_Js(top) { this.construct(window) }
Debug_Console_Js.prototype = {
	height: 400,
	construct: function(t) { with (this) {
		top = t || window;
		var owner = window.HTMLElement? window : body;
		var th = this;
		var prevKeydown = owner.onkeydown;
		owner.onkeydown = function(e) {
			if (!e) e = window.event;
			if ((e.ctrlKey || e.metaKey) && (e.keyCode == 192 || e.keyCode == 96 || e.keyCode == 191)) {
				th.toggle();
				return false;
			}
			if (prevKeydown) {
				this.__prev = prevKeydown;
				return this.__prev(e);
			}
		}
	}},
	toggle: function() { with (this) {
		Debug_Toggle('_D');
	}}
}
window.hackerConsole = window.hackerConsole || window.Debug_Console_Js && new window.Debug_Console_Js();
</script>

@getStyle[]
<style type="text/css">
	/* светлая сторона */
	#_D{background:#f5f5f5;color:#444;font-family:courier new;font-size:12px;position:relative;z-index:99999;padding:1em 1em .2em}
	#_D #_dStack i{color:#000;font-style:normal}
	#_D #_dStack td{color:#999}
	#_D #_dStack th{color:#35d;padding-right:1em;text-align:left}
	#_D .ancor{color:#0096ff;cursor:hand}
	#_D .bool{color:#4dc6de;font-weight:700}
	#_D .date{color:#f50}
	#_D .hash{color:#666}
	#_D .numeric{color:#03f}
	#_D .string{color:#669;white-space:pre}
	#_D .userclass{color:#06d}
	#_D .void{color:#aaa}
	#_D b{font-weight:400}
	#_D code{color:#000}
	#_D del{position:absolute;text-decoration:none;top:-1000em}
	#_D dfn{color:#06f;display:block;font-style:normal;margin-bottom:1em}
	#_D em{color:#555;font-style:normal}
	#_D hr{background:#999;border:0;color:#999;height:1px;width:100%;margin:.5em 0 1em}
	#_D pre{margin:.5em 0 1.8em;padding:0;overflow:visible;width:100%}
	#_D pre.xdoc,#_D pre.file{margin:0}
	#_D s{color:#555;text-decoration:none}
	#_D samp{white-space:pre}
	#_D table{font-size:1em}
	#_D table.table{border-collapse:collapse;margin:6px 3px 0}
	#_D table.table td,#_D table.table th{border:1px dotted #999;padding:2px 5px}
	#_D table.table th{color:#555}
	#_D var{color:#d30;font-style:normal;font-weight:400;text-decoration:none}

/* темная сторона */
#_D{background:#0c1021;color:silver;font-family:courier new;font-size:12px;padding:1em;position:relative;z-index:99999}#_D #_dStack i{color:#ccc;font-style:normal}#_D #_dStack td{color:#777}#_D #_dStack th{color:#fbdc2d;padding-right:1em;text-align:left}#_D .ancor{color:#0096ff;cursor:hand}#_D .bool{color:#4dc6de;font-weight:700}#_D .date{color:#f50}#_D .hash{color:#aaa}#_D .numeric{color:#d8fa3c}#_D .string{color:#df8644;white-space:pre}#_D .userclass{color:#0096ff}#_D .void{color:#666}#_D b{font-weight:400}#_D del{color:#333;position:absolute;text-decoration:none;top:-1000em}#_D dfn{color:#69f;display:block;font-style:normal;margin-bottom:1em}#_D em{color:#555;font-style:normal}#_D hr{background:#666;border:0;color:#666;height:1px;margin:.5em 0 1em;width:100%}#_D pre{margin:.5em 0 1.4em}#_D pre.xdoc{margin:0}#_D s{color:#555;text-decoration:none}#_D samp{white-space:pre}#_D table{font-size:1em}#_D table.table{border-collapse:collapse;margin:6px 3px 0}#_D table.table td,#_D table.table th{border:1px dotted #666;padding:2px 5px}#_D table.table th,#_D code{color:#6cb649}#_D var{color:#ff6400;font-style:normal;font-weight:400;text-decoration:none}
</style>
<dfn>
	$dNow[^date::now[]]
	${dNow.hour}:^dNow.minute.format[%.02u]:^dNow.second.format[%.02u]&nbsp
	<em>[^if(def $env:REMOTE_HOST && $env:REMOTE_HOST ne $env:REMOTE_ADDR){REMOTE_ADDR: $env:REMOTE_ADDR REMOTE_HOST: $env:REMOTE_HOST}{$env:REMOTE_ADDR}]&nbsp
	^env:PARSER_VERSION.match[compiled on ][]{}</em>&nbsp
	^rem{ посчитать параметры запроса }
	$uriParam[^request:uri.match[^^[^^\?]*\??(.*)?][]{$match.1}]
	$uriParam[^uriParam.split[&]]
	$uriParamReal(0)
	^if($form:tables is hash){^form:tables.foreach[key;val]{^uriParamReal.inc(^val.count[])}}
	$queryParam[$request:query]
	$queryParam[^queryParam.split[&]]
	$queryParamCount(^queryParam.count[]-^uriParam.count[])
	post/get/query: ^eval($uriParamReal-^queryParam.count[])/^uriParam.count[]/$queryParamCount&nbsp
	^if($cookie:fields){cookie: ^cookie:fields._count[]}
</dfn>
<hr/>

@compact[hParam][iPrevUsed;result]
^hStatistics.iCalls.inc(1)
^if($hParam.bForce || !$hStatistics.hMemory.iEnd || ($self.iLimit && ($status:memory.used - $hStatistics.hMemory.iEnd) > $self.iLimit)){
	^hStatistics.iCompact.inc(1)
	$iPrevUsed($status:memory.used)
	^memory:compact[]
	^hStatistics.hMemory.iCollected.inc($iPrevUsed - $status:memory.used)
	$hStatistics.hMemory.iEnd($status:memory.used)
}

@showSystemParam[][result]
$self.hStatistics.hMemory.iEnd($status:memory.used)
$self.hStatistics.hUsage.hEnd[$status:rusage]
$usage((^self.hStatistics.hUsage.hEnd.tv_sec.double[] -
				^self.hStatistics.hUsage.hBegin.tv_sec.double[]) +
				(^self.hStatistics.hUsage.hEnd.tv_usec.double[] -
				^self.hStatistics.hUsage.hBegin.tv_usec.double[])/1000000)
$utime($self.hStatistics.hUsage.hEnd.utime - $self.hStatistics.hUsage.hBegin.utime)
$result[<code>
	memory used/collected: $self.hStatistics.hMemory.iEnd/$self.hStatistics.hMemory.iCollected KB
	calls/dcompacts: $self.hStatistics.iCalls/$self.hStatistics.iCompact
	Usage: ^usage.format[%.3f] s,
	Utime: ^utime.format[%.3f] s
</code>]

@show[o][result]
^if(!$self.iCall){^extendPostprocess[]}
$self.iCall(1)
$sConsole[$sConsole
^showSystemParam[]
<pre>^taint[optimized-as-is][^if($o is double){^showObject($o)}{^showObject[$o]}]</pre>
]

@stop[o][result]
^if($o is double){ ^self.show($o) }{ ^self.show[$o] }
#^sConsole.save[$self.sSavePath]
^throw[debug;$sConsole]

@showObject[o][result;jShow]
^iHashId.inc[]
^if(def $o){
	$jShow[$[show_$o.CLASS_NAME]]
	^if($jShow is junction){
		^if($o is double){^jShow($o)}{^jShow[$o]}
	}{
		^show_userclass[$o]
	}
}{
	^show_void[]
}

@show_userclass[o]
$result[<u class="userclass value">$o.CLASS_NAME</u>]

@show_void[]
$result[<span class="void value">void</span>]

@show_bool[o]
$result[<span class="bool value">^if($o){true}{false}</span>]

@show_string[o]
$result[<span class="string value">^self.replaceString[$o]</span>]

@show_int[o]
$result[<span class="numeric value">$o</span>]

@show_double[o]
$result[<span class="numeric value">$o</span>]

@show_date[d]
$result[<del>^^date::create^[</del><span class="date value">^d.sql-string[]</span><del>^]</del>]

@show_hash[h;b;sort][k;v;sTabs]
^self.iShift.inc[]
$sTabs[^for[i](2;$self.iShift){&#09}]
$result[
<span class="hash value">^h.foreach[k;v]{&#09$sTabs<var>^$.^k.match[(.*[^^a-zа-я0-9_\-].*)][i]{<s>^[</s>$match.1<s>^]</s>}</var>^if($v is double || $v is bool){(<span id="hash_$iHashId">^self.showObject($v)</span>)}{^[<span id="hash_$iHashId">^self.showObject[$v]</span>^]}
}</span>$sTabs]
^self.iShift.dec[]

@show_table[t][tCol;tFlipped;bNamless;bF]
	$tCol[^t.columns[]]
	$bNamless(false)
	^if(^t.count[] > 0 && ^tCol.count[] == 0){
		$bNamless(true)
		$tFlipped[^t.flip[]]
		$tCol[^table::create{column}]
		^for[i](0;$tFlipped-1){^tCol.append{$i}}
		$t[^tFlipped.flip[]] ^rem{ помогает для named таблиц, у которых колонки не заданы }
	}
	$sTabs[^for[i](1;$self.iShift){&#09}]
	$fMarginLeft($self.iShift*5)
	^if($self.iShift > 0){^fMarginLeft.inc(5)}
	$bF(false)
	$result[<table class="table value" style="margin-left: ${fMarginLeft}em">^if(!$bNamless){<tr>^tCol.menu{<th>^if(!$bF){$bF(true)<del>^^table::create^if($bNamless){^[nameless^]}^{</del>}$tCol.column</th>}</tr>}^t.menu{<tr>^tCol.menu{<td>^if(!$bF){$bF(true)<del>^^table::create^if($bNamless){^[nameless^]}^{</del>}^show_string[^if($bNamless){$t.[$tCol.column]}{$t.fields.[$tCol.column]}]</td>}</tr>}</table><del>^}</del>$sTabs]

@show_file[f][h]
$sTabs[^for[i](1;$self.iShift){&#09}]
$fMarginLeft($self.iShift*5)
^if($self.iShift > 0){^fMarginLeft.inc(5)}
$result[<pre class="file value" style="margin-left: ${fMarginLeft}em">
^try{
	$h[^file::stat[$f.name]]
	File: ^file:fullpath[$f.name]
	Size: $h.size byte
	Create: ${h.cdate.day}.${h.cdate.month}.${h.cdate.year} ${h.cdate.hour}:${h.cdate.minute}
	Modify: ${h.mdate.day}.${h.mdate.month}.${h.mdate.year} ${h.mdate.hour}:${h.mdate.minute}
	Last call: ${h.adate.day}.${h.adate.month}.${h.adate.year} ${h.adate.hour}:${h.adate.minute}
	MIME-type: $h.content-type^if(${h.content-type} eq "text/plain" || ${h.content-type} eq "text/html"){
		First 100 symbols:
		^f.text.left(100)...

		Last 100 symbols:
		...^f.text.right(100)}}{
	$exception.handled(1)
	^file:fullpath[$f.name] (file) not find!
}</pre>$sTabs]

@show_image[i]
^if(def $i.src){^i.html[]} <b>(image)</b> Height: ${i.height}px Width: ${i.width}px ^if(def $i.exif){^self.show_hash[$i.exif]}{EXIF not find} <br/>

@show_xdoc[x][s]
	^self.prepareFormat[$x]
	$s[^x.string[ $.omit-xml-declaration[no] $.method[xml] $.indent[yes]]]

	$sTabs[^for[i](1;$self.iShift){&#09}]
	$fMarginLeft($self.iShift*5)
	^if($self.iShift > 0){^fMarginLeft.inc(5)}

	$sDoc[^self.replaceString[$s]]
	$sDoc[^sDoc.trim[end]]
	$result[<pre class="xdoc value" style="margin-left: ${fMarginLeft}em"><del>^^xdoc::create^{</del>$sDoc<del>^}</del></pre>$sTabs]

@show_xnode[x][result]
	^switch[$x.nodeType]{
		^case[1]{$result[<span class="node1 value">&lt^;$x.nodeName^self.showAttributes[$x]&gt^;^self.showChild[$x]&lt^;/$x.nodeName&gt^;</span>]}
		^case[2]{$result[<span class="node2 value">$x.nodeName="$x.nodeValue"</span>]}
		^case[3]{$result[<span class="node3 value">$x.nodeValue</span>]}
	}

@showAttributes[x][result]
	^try{
		$result[^x.attributes.foreach[k;v]{ ^self.show_xnode[$v]}]
	}{
		$exception.handled(1)
	}

@showChild[x][result]
	^try{
		$result[^x.childNodes.foreach[k;v]{^self.show_xnode[$v]}]
	}{
		$exception.handled(1)
	}

@replaceString[s][result]
	$result[^s.replace[^table::create[nameless]{<	&lt^;^#0A>	&gt^;}]]

@show_Array[a][result]
	$result[Array($a.count): <br/> ^show_hash[$a.hash;;1]]

@showXObject[o]
	$result[<span style="color:red">$o.typeName</span>
		^if($o.getID is junction){<b>^o.getID[]</b>}
		^if($o.getName is junction){<span style="color:blue">(^o.getName[])</span>}
		^if($o.ToString is junction){<span style="color:red">(^o.ToString[])</span>}
		^if($o.current)[
			^self.showObject[$o.current]
		]
	]

# clear empty text nodes
@prepareFormat[document][rootnodes;result]
	$rootnodes[$document.documentElement.childNodes]
	^self.prepareFormatChild[$document.documentElement;$rootnodes]

@prepareFormatChild[parent;child][i;node;result]
	^for[i](0;$child-1){
		$node[$child.$i]
		^if(($node.nodeType == $xdoc:TEXT_NODE) && ^node.nodeValue.trim[] eq ""){
			$node[^parent.removeChild[$node]]
		}{
			^if($node.nodeType==$xdoc:ELEMENT_NODE){
				^self.prepareFormatChild[$node;$node.childNodes]
			}
		}
	}
