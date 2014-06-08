require! {
  chai
  chai.expect
  fs
  path
  engine: '../../index.js' # импортим JS'овый файл!
  _: 'prelude-ls'
}

fixtures-path = path.join __dirname, \.., \fixtures

do
  <-! describe "Generic express renderer"

  specify "should render template matching with filename by default" (done) !->
    (err, tmpl) <-! engine .renderFile "#{fixtures-path}/inheritance.ss"
    if err then return done err
    expect tmpl .be .equal 'Hello, World!'
    done!

  specify "should render specified template with custom main func" (done) !->
    tmpl = '{template custom_main_func()}Hello, World!{/template}'
    options = _ss: main-template: 'custom_main_func'
    (err, tmpl) <-! engine.render tmpl, options
    if err then return done err
    expect tmpl .be .equal 'Hello, World!'
    done!

  specify "should render a string" (done) !->
    tmpl = '{template main()}Hello, World!{/template}'
    (err, tmpl) <-! engine.render tmpl
    if err then return done err
    expect tmpl .be .equal 'Hello, World!'
    done!

  specify "should support locals passing to Snakeskin as super globals" (done) !->
    tmpl = '{template main()}Hello, {@variable}!{/template}'
    locals = variable: 'World'
    (err, tmpl) <-! engine.render tmpl, locals
    if err then return done err
    expect tmpl .be .equal 'Hello, World!'
    done!

  specify "should bubble exceptions from Snakeskin to express" (done) !->
    tmpl = '{template main()}Its an err example!{oops}'
    (err, tmpl) <-! engine.render tmpl
    expect tmpl .to .not .exist
    expect err .to .be .exist
    done!

do
  <-! describe "Snakeskin integration to express"

  specify "should support passing arguments to main renderer" (done) !->
    options = _ss: main-args: ['Hello', 'World!']
    (err, tmpl) <-! engine .renderFile "#{fixtures-path}/args.ss", options
    if err then return done err
    expect tmpl .be .equal 'Hello, World!'
    done!

  specify "should support chainging name of special prop" (done) !->
    # меняем имя спец. свойства на 'snakeskin options'
    [orig-special-prop, engine.specialprop] = [engine.specialprop, 'snakeskin options']
    options = 'snakeskin options': main-args: ['foobar']
    (err, tmpl) <-! engine.render "{template main(myVar = 'Override me!')}{myVar}{/template}", options
    engine.specialprop = orig-special-prop # возвращаем имя спец свойства на место
    if err then return done err
    expect tmpl .to .be .eq 'foobar'
    done!

  specify "should support filters import" (done) !->
 
    # Импортим фильтр
    engine.importFilters do
      'repeat': (str) ->
        return str + str

    (err, tmpl) <-! engine.render "{template main()}{'foo'|repeat}{/template}"
    if err then return done err
    expect tmpl .to .be .eq 'foofoo'
    done!

do
  <-! describe "Snakeskin caching"

  # счетчик вызовов fs.readFile или fs.readFileSync
  readCount = 0

  origMethods = fs{readFile, readFileSync}

  hook = (fn) -> (...args) ->
    readCount++
    fn.apply fs, args

  # перед тестом хукаем функции на чтение файлов
  beforeEach !->
    # и сбрасываем число чтений
    readCount := 0
    for methodName, method of origMethods
      fs[methodName] = hook method

  # после теста убираем хуки на оригинальные функции
  afterEach !->
    for methodName, method of origMethods
      fs[methodName] = method

  specify "should not cache by default" (done) !->
    # рендерим файл 3 раза
    (err, tmpl) <-! engine .renderFile "#{fixtures-path}/args.ss"
    (err, tmpl) <-! engine .renderFile "#{fixtures-path}/args.ss"
    (err, tmpl) <-! engine .renderFile "#{fixtures-path}/args.ss"
    if err then return done err
    # и на самом деле он читается 3 раза
    expect readCount .to .be .eq 3
    done!


  specify "should support cache on demand" (done) !->
    # рендерим файл несколько раз
    (err, tmpl) <-! engine .renderFile "#{fixtures-path}/args.ss", {+cache}
    (err, tmpl) <-! engine .renderFile "#{fixtures-path}/args.ss", {+cache}
    (err, tmpl) <-! engine .renderFile "#{fixtures-path}/args.ss", {+cache}
    if err then return done err
    # но на самом деле он читается только один раз
    expect readCount .to .be .eq 1
    done!

do
  <-! describe "Snakeskin cold caching"

  locals = user: name : 'ColCh'

  specify "should ignore *.ss.js files by default" (done) !->
    (err, tmpl) <-! engine .renderFile "#{fixtures-path}/user.ss", locals
    if err then return done err
    expect tmpl .to .be .eq 'Hello, ColCh!'
    done!
  
  specify "should support *.ss.js files (cold cache)" (done) !->

    cold-cache-locals = locals with _ss: cold-cache: on

    (err, tmpl) <-! engine .renderFile "#{fixtures-path}/user.ss", cold-cache-locals
    expect tmpl .to .be .eq 'Hi, ColCh! Its an cold cache emulation'
    done err