User = require("./models/User")
_ = require("underscore")

routes = (app) ->
    app.get '/', (req, res) ->
        return res.render "layout.jade", { title : "polaris" }

    app.get '/addressbook', (req, res) ->
        User.fetch (err, users) ->
            if err
                console.log(err)
            else
                return res.render("addressbook/list.jade", {
                    title: "addressbook"
                    users: users
                    "current_user": req.session.user
                    validate: (user) ->
                         return user.name? && user.location? &&(user.phone1? || user.phone2?)
                })
    app.post '/addressbook/update', (req, res) ->
        userObj = req.body
        User.findById(userObj._id, (err, user) ->
            if err
                console.log(err)
                return res.send(JSON.stringify({success: 0, err: err}))
            for field of userObj
                if field != '_id'
                    user[field] = userObj[field]
            console.log("2", user)
            user.save((err) ->
                console.log('got here')
                if err
                    console.log(err)
                    return res.send(JSON.stringify({success: 0, err: err}))
                return res.send(JSON.stringify({success: 1}))
            )
        )

    app.get '/signinup', (req, res) ->
        return res.render "auth/signinup.jade", { title : "signinup" }

    app.post '/signin', (req, res) ->
        userObj = {
            username: req.body.username
            password: req.body.password
        }
        User.findByUsername(req.body.username, (err, user) ->
            if err
                console.log(err)
                return res.send(JSON.stringify({'success': 0, 'err': err}))
            if not user
                console.log("User not exists")
                return res.send(JSON.stringify({'success': 0, 'err': "User not exists"}))
            if user.password != req.body.password
                console.log("Wrong password")
                return res.send(JSON.stringify({'success': 0, 'err': "Wrong password"}))
            req.session.user = user
            return res.send(JSON.stringify({'success': 1}))
        )

    app.post '/signup', (req, res) ->
        userObj = new User({
            username: req.body.username
            password: req.body.password
        })
        userObj.save( (err) ->
            if (err)
                console.log(err)
                return res.send(JSON.stringify({
                    'success': 0
                    'err': "Invalid username/password"
                }))
            console.log('saving')
            req.session.user = userObj
            return res.send(JSON.stringify({'success': 1}))
        )


module.exports = routes
