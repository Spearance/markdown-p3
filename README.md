# Класс Markdown для Parser 3

Преобразует Markdown разметку в HTML. 

Вызов:

```
@USE
markdown.p

^markdown:parse[Text with [link](https://github.com "GitHub").]
```

В рамках данного класса угловые скобки тегов внутри разметки переводятся в мнемоники.

Было:

``` markdown
Этот текст содержит <b>теги</b>.
```

Стало:

``` markdown
Этот текст содержит &lt;b&gt;теги&lt;/b&gt;.
```
