@USE
markdown.p

# статически
^markdown:parse[Text with [link](https://github.com "GitHub").]

# или объект класса
$markdown[^markdown::create[
	^rem{ включать внутрь разметки HTML (небезопасно) }
	$.innerHTML(0)
	^rem{ менять в тексте шорткаты на эмодзи }
	$.emoji(1)
	^rem{ заменять сочетания символов }
	$.typograph(1)
	^rem{ подсвечивать код }
	$.highlight(1)
	
	^rem{ настроить ссылки }
	$.links[
		^rem{ добавить в начало ссылки часть пути или имя сервера }
		$.path[//$env:SERVER_NAME|/some-path]
		^rem{ добавлять атрибут target="" }
		$.target[_blank|_self|...]
		^rem{ добавлять атрибут rel="" }
		$.rel[next|prev|nofollow|...]
	]
	
	^rem{ настроить картинки }
	$.images[
		^rem{ добавить в начало ссылки часть пути или имя сервера }
		$.path[//$env:SERVER_NAME|/some-path]
		^rem{ добавлять атрибут class="" }
		$.class[классы через пробел]
		^rem{ оборачивать в <figure><img ...><figcaption>...</figcaption></figure> }
		$.figure(1)
	]
]]

^markdown.parse[Text with [link](https://github.com "GitHub").]
