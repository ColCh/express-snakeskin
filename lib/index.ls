require! {
  snakeskin: 'snakeskin/snakeskin.js'
  fs
  path
}
{is-type, apply} = require 'prelude-ls'

# кеш чтения файлов
read-cache = {}

# Функция чтения файлов с опциональным кешированием
read-file = (file, options, done) !->
  if options.cache and file of read-cache
    done null, read-cache[ file ]
  else
    (err, str) <-! fs.readFile file, 'utf8' 
    if str then str -= /^\uFEFF/ # удаление BOM
    if options.cache then read-cache[ file ] = str
    done err, str

# Экспортируемый синлетон 
SnakeSkinCompiler =  {

  # настройки по умолчанию
  defaultOptions: {
    cold-cache: off
    main-args: []
    main-template: ''
  }

  # имя шаблона, если имя файла не совпадает ни с каким
  # шаблоном и нет шаблона из options
  default-main-template: 'main'

  # имя специального свойства для настроек snakeskin в View.options
  specialprop: '_ss'

  # прокси-метод для импорта фильтров
  import-filters: snakeskin~importFilters

  # установка значений для настроек по умолчанию
  options: (options) !->
    if 'Object' `is-type` options then
      @defaultOptions <<<< options

  # прозрачная интеграция с express
  __express: SnakeSkinCompiler~renderFile

  # рендер строк
  render: (template, options, fn) !->
    # options является необязательным аргументом
    if 'Function' `is-type` options then
      fn = options
      options = {}

    _ss = options[SnakeSkinCompiler.specialprop] ||= SnakeSkinCompiler.defaultOptions
    options[SnakeSkinCompiler.specialprop] = _ss = ^^SnakeSkinCompiler.defaultOptions <<<< _ss

    options.file ||= '' # имя файла

    try
      js_tmpl = {}
      snakeskin.Vars = options # глобальные переменные 

      # FIXME: вынести в process.nextTick? низя
      if 'Object' `is-type` template
        js_tmpl = template
      else
        snakeskin.compile template, { context: js_tmpl }, { file: options.file }

      renderer = js_tmpl[ _ss.main-template ] or js_tmpl[ SnakeSkinCompiler.default-main-template ]
      unless renderer then return fn new Error "no renderer found!"
      tmpl = apply renderer, _ss.main-args
      fn null, tmpl
    catch
      fn e, void

  # рендер файлов
  renderFile: (file, options, fn) !->
    # options является необязательным аргументом
    if 'Function' `is-type` options then
      fn = options
      options = {}

    _ss = options[SnakeSkinCompiler.specialprop] ||= SnakeSkinCompiler.defaultOptions
    options[SnakeSkinCompiler.specialprop] = _ss = ^^SnakeSkinCompiler.defaultOptions <<<< _ss

    # определим имя рисовальщика-шаблона. Совпадает с именем файла
    _ss.main-template ||= path.basename file, path.extname file

    options.file = file

    if _ss.cold-cache

      [orig-global-snakeskin, global.Snakeskin] = [global.Snakeskin, snakeskin]
      require file + '.js' # FIXME WTF
      SnakeSkinCompiler.render Snakeskin.cache, options, fn
      global.Snakeskin = orig-global-snakeskin

    else

      (err, str) <~! read-file file, options
      if err then return fn err, void
      SnakeSkinCompiler.render str, options, fn

}

module.exports = SnakeSkinCompiler
