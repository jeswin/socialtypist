// Generated by CoffeeScript 1.2.1-pre
(function() {
  var MongoStore, app, conf, controllers, database, dbconf, express, findHandler, host, models, port, root, utils;

  root = typeof exports !== "undefined" && exports !== null ? exports : this;

  express = require('express');

  MongoStore = (require('../common/express-session-mongo')).MongoStore;

  conf = require('./conf');

  dbconf = require('../models/dbconf');

  database = new (require('../common/database')).Database(dbconf["default"]);

  models = new (require('../models')).Models(dbconf["default"]);

  controllers = require('./controllers');

  utils = require('../common/utils');

  app = express.createServer();

  app.use(express.bodyParser({
    uploadDir: 'public/temp/images'
  }));

  app.set("view engine", "hbs");

  app.set('view options', {
    layout: 'layouts/default'
  });

  app.use('/public', express["static"](__dirname + '/public'));

  app.use(express.favicon());

  app.use(express.cookieParser());

  app.use(express.session({
    secret: '345fdgerf',
    store: new MongoStore({
      db: 'typistsessions',
      "native": false
    })
  }));

  findHandler = function(name, getHandler) {
    return function(req, res, next) {
      var controller;
      controller = (function() {
        switch (name.toLowerCase()) {
          case 'home':
            return new controllers.HomeController();
          case 'stories':
            return new controllers.StoriesController();
          default:
            throw 'Boom';
        }
      })();
      return getHandler(controller)(req, res, next);
    };
  };

  app.get('/', findHandler('home', function(c) {
    return c.index;
  }));

  app.post('/addSession', findHandler('home', function(c) {
    return c.addSession;
  }));

  app.get('/removeSession', findHandler('home', function(c) {
    return c.removeSession;
  }));

  app.get('/stories/create', findHandler('stories', function(c) {
    return c.createForm;
  }));

  app.post('/stories', findHandler('stories', function(c) {
    return c.create;
  }));

  app.get('/stories/:storyid', findHandler('stories', function(c) {
    return c.show;
  }));

  app.get('/stories/:storyid/edit', findHandler('stories', function(c) {
    return c.editForm;
  }));

  app.put('/stories/:storyid', findHandler('stories', function(c) {
    return c.update;
  }));

  app.post('/stories/:storyid/parts', findHandler('stories', function(c) {
    return c.createPart;
  }));

  app.put('/stories/:storyid/parts/:partid', findHandler('stories', function(c) {
    return c.updatePart;
  }));

  app.del('/stories/:storyid/parts/:partid', findHandler('stories', function(c) {
    return c.deletePart;
  }));

  app.post('/stories/:storyid/publish', findHandler('stories', function(c) {
    return c.publish;
  }));

  app.post('/stories/:storyid/upload', findHandler('stories', function(c) {
    return c.upload;
  }));

  app.use(function(err, req, res, next) {
    return res.render('500', {
      status: err.status || 500,
      error: utils.dumpError(err),
      layout: false
    });
  });

  app.use(function(req, res, next) {
    return res.render('400', {
      status: 400,
      url: req.url,
      layout: false
    });
  });

  host = process.argv[2];

  port = process.argv[3];

  app.listen(port);

}).call(this);
