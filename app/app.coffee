express = require('express')
path = require('path')
bodyParser = require('body-parser')
moment = require('moment')
session = require('express-session')
routes = require('./routes')
mongoose = require('mongoose')
User = require('./models/User')
flash = require('./tools/flash')
utils = require('./utils')
config = require('./config')
log = new (require('./tools/logger'))('app')

app = express()
port = process.env.PORT or 8080
app.set 'views', path.join(__dirname, "views")
app.set 'view engine', 'jade'
app.use bodyParser()
app.use session({
    secret: 'polaris',
    resave: true,
    saveUninitialized: true
})
app.use(flash())

app.use express.static(__dirname + "/public")

mongoose.connect( config.database )
log.info('mongoose connected to' ,config.database ,'at' ,mongoose.connection.port)

app.use '/', (req, res, next) ->
    log.info(req.ip, req.path)
    next()

auth_paths = [
    '/signinup'
    '/signin'
    '/signup'
]
# auth
app.use '/', (req, res, next) ->
    unless req.path in auth_paths or req.session?.user?
        res.redirect('/signinup')
    else
        next()

# error-handle
app.use '/', (req, res, next) ->
    for type in utils.error_msgs_types
        if req.query[type]
            req.flash(type, req.query[type])
    next()

app.get '/signinup', (req, res, next) ->
    if req.session?.user?
        res.redirect('/addressbook')
    else
        next()

app.get '/', (req, res, next) ->
    res.redirect('/addressbook')

routes(app)

log.info("express started on PORT: " ,port)
app.listen(port)
