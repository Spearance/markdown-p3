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
]]

^markdown.parse[Text with [link](https://github.com "GitHub").]
