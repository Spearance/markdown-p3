# Класс Markdown для Parser 3

Преобразует Markdown разметку в HTML. 

## Вызов

```
@USE
markdown.p

# статически
^markdown:parse[Text with [link](https://github.com "GitHub").]

# или объект класса
$markdown[^markdown::create[
	$.inlineHTML(0)		# включать внутрь разметки HTML (не безопасно)
	$.emoji(1)				# менять в тексте шорткаты на эмодзи 
	$.typograph(1)		# заменять сочетания символов
]]

^markdown.parse[Text with [link](https://github.com "GitHub").]
```

## Поддержка

* Заголовки (H1—H6)
* Абзацы
* Ссылки
* Картинки
* Цитаты (кроме вложенных)
* Горизонтальная линия

### Инлайн стили

* Жирный
* Курсив
* Жирный-курсив
* Зачёркнутый
* Подчеркнутый
* Маркированный

### Код

* Код инлайновый


### Типографика
| Набор| Преобразование |
|:----:|:--------------:|
| (с)  | © |
| (r)  | ® |
| (tm) | ™ |
| (P)  | ₽ |
| --   | — |

### Emoji

Поддерживается преобразование популярных шорткатов `:-)` в эмодзи `🙂`, также поддерживаются текстовые `:sunglasses:` преобразования `😎`.

## Особенности

В рамках данного класса HTML разметка внутри Markdown не допускается. Угловые скобки тегов внутри разметки переводятся в мнемоники.

Было:

``` markdown
Этот текст содержит <b>теги</b>.
```

Стало:

``` markdown
Этот текст содержит &lt;b&gt;теги&lt;/b&gt;.
```
