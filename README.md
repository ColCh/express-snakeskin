express-snakeskin
=================

Шаблоны [Snakeskin](https://github.com/kobezzza/Snakeskin) в [express](https://github.com/visionmedia/express) !

Установка
---------

`$ npm install --save express-snakeskin`

Использование
-------------

### Настройка веб приложения
```javascript
var snakeskin = require('express-snakeskin');
app.engine('ss', snakeskin);
app.set('view engine', 'ss');
// app.set ( 'views', ... )
// app.render ... 
```

### Использование
*user.ss*
```
{template user()}
	{@name}
{/template}
```
*app.js*
```javascript
res.render('user', { name: 'ColCh' }, function(err, html){
  // ... всё как обычно
});
```

Подробнее
------------

* Исключения, брошенные на уровне *Snakeskin*, поднимаются до уровня *express*

* Для перевода из скомпилированного шаблона в *HTML*
 вызывается функция, совпадающая с именем файла 
 (см. выше пример с шаблоном *user*). 
 Это поведение можно изменить через `options. ` (ниже будет подробнее)
 
* Если нет шаблона, имя которого совпадает с именем файла,
	вызывается функция `main`

* Можно определить имя функции, 
 	которая будет вызываться для перевода в *HTML*.
 	Определяется  через `options._ss` (ниже будет подробнее)

* Т.к. шаблоны в *Snakeskin* - это функции, 
	то по умолчанию функция шаблона вызывается без аргументов.
	Передать аргументы к главной функции можно с использованием `options._ss` (ниже будет подробнее)

* *Snakeskin* может компилироваться в файлы `*.ss.js`, но загружаться по умолчанию они не будут. 
	Изменяется это поведение опять таки через `options._ss`

* Обычное для *express* кеширование переключается через свойство `options.cache`

### *options* для *Snakeskin*

С `options` можно передать объект настроек для *Snakeskin* через свойство `_ss`.

Пример:
```javascript
var options = {
	name: 'ColCh', // переменные задаются так же
	_ss: {
		coldCache: true, // Boolean. Если true, будет искать и выполнять файл *.ss.js в той же папке, что и *.ss
		mainArgs: [1, 'abc'], // Array. Аргументы к исполняемой главной функции
		mainTemplate: 'render' // String. Имя главной функции
	}
}
res.render('user', options);
```

Имя этого свойства находится в `snakeskin.specialprop` и может переназначаться:
```javascript
// На этапе конфигурации
snakeskin.specialprop = 'snakeskin options';

// На этапе ответа
var options = {
	'snakeskin options': {
		// ...
	}
}
res.render('user', options);
```

### *options* по для всех 

Можно определить объект с настройками *Snakeskin* по умолчанию. 
Объект с настройками по умолчанию будет сливаться с переданным в `render`, **без глубокого копирования**

```javascript
// конфигурация
snakeskin.options({
	coldCache: true 
	// аналогично с остальными
});

// Если рядом с user.ss будет user.ss.js, то будет использован он
res.render('user', { name: 'ColCh' });

// user.ss.js не будет использоваться
res.render('user', { name: 'ColCh', _ss: {coldCache: false} });
```

### Структура объекта *options* и его значения по умолчанию
```javascript
{
		// Boolean. Если true, будет искать и выполнять файл *.ss.js в той же папке, что и *.ss
		coldCache: false,
		 // Array. Аргументы к исполняемой главной функции
		mainArgs: [],
		// String. Имя главной функции
		mainTemplate: ''
}
```