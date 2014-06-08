/**
 * @file Express app file. Taken & inspired by consolidate.js
 * @author ColCh <colouredchalkmelky@gmail.com>
 * Date: 02.06.2014
 */
var express = require('express');
var app = express();

var snakeskin = require('../index.js');

app.engine('ss', snakeskin.renderFile);
app.set('view engine', 'ss');
app.set('views', __dirname + '/views');

var users = [];
users.push({ name: 'tobi' });
users.push({ name: 'loki' });
users.push({ name: 'jane' });

app.get('/', function(req, res){
  res.render('index', {
    index: 'Snakeskin as express view!'
  });
});

//TODO переменные - как суперглобали
//TODO рендер без указания имени template'а (рендерим функцию, совпадающую с именем файла шаблона)
app.get('/users', function(req, res){
  res.render('users', {
    title: 'Users',
    users: users
  });
});

app.listen(3000);
console.log('Express server listening on port 3000');