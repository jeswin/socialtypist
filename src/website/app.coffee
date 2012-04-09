root = exports ? this

express = require 'express'

MongoStore = (require '../common/express-session-mongo').MongoStore
conf = require './conf'
dbconf = require '../models/dbconf'
database = new (require '../common/database').Database(dbconf.default)
models = new (require '../models').Models(dbconf.default)
controllers = require './controllers'
utils = require '../common/utils'


app = express.createServer()
app.use express.bodyParser({uploadDir:'public/temp/images'})

app.set("view engine", "hbs");
app.set('view options', { layout: 'layouts/default' })

#static file handlers.
#app.use('/', express.static(__dirname + '/public/root'))
app.use('/public', express.static(__dirname + '/public'))
app.use(express.favicon());


#session
app.use express.cookieParser()
#app.use cookieSessions('sid')
app.use express.session({secret:'345fdgerf', store: new MongoStore({ db: 'typistsessions', native: false })})


#a channel factory
findHandler = (name, getHandler) ->
    return (req, res, next) ->
        controller = switch name.toLowerCase()
            when 'home' then new controllers.HomeController()
            when 'stories' then new controllers.StoriesController()
            else throw 'Boom'
        getHandler(controller)(req, res, next)

#all routes go here.
app.get '/', findHandler('home', (c) -> c.index)
app.post '/addSession', findHandler('home', (c) -> c.addSession)
app.get '/removeSession', findHandler('home', (c) -> c.removeSession)
app.get '/stories/create', findHandler('stories', (c) -> c.create)
app.post '/stories/create', findHandler('stories', (c) -> c.create_post)
app.get '/stories/:storyid/edit', findHandler('stories', (c) -> c.edit)
app.post '/stories/:storyid/saveTitle', findHandler('stories', (c) -> c.saveTitle)
app.post '/stories/:storyid/savePart', findHandler('stories', (c) -> c.savePart)
app.post '/stories/:storyid/removePart', findHandler('stories', (c) -> c.removePart)
app.post '/stories/:storyid/publish', findHandler('stories', (c) -> c.publish)
app.post '/stories/:storyid/upload', findHandler('stories', (c) -> c.upload)
app.get '/stories/:storyid', findHandler('stories', (c) -> c.display)


# handle all app errors - 500
app.use (err, req, res, next) ->
    res.render('500', {
        status: err.status || 500,
        error: utils.dumpError(err),
        layout: false
    })

# handle 404
app.use (req, res, next) ->
    res.render('400', {
        status: 400
        , url: req.url
        , layout: false
    })

host = process.argv[2]
port = process.argv[3]

app.listen(port)
