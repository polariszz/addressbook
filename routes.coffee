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
            user.save((err, user) ->
                console.log('got here')
                if err
                    console.log(err)
                    return res.send(JSON.stringify({success: 0, err: err}))
                req.session.user = user
                return res.send(JSON.stringify({success: 1}))
            )
        )

    app.get '/signinup', (req, res) ->
        return res.render "auth/signinup.jade", { title : "signinup" }

    app.post '/signin', (req, res) ->
        User.findByUsername(req.body.username, (err, user) ->
            if err
                console.log(err)
                return res.send(JSON.stringify({'success': 0, 'err': err}))
            if not user
                console.log("User not exists")
                return res.send(JSON.stringify({'success': 0, 'err': "User not exists"}))
            user.comparePasswords(req.body.password, (err, match) ->
                if !match or err
                    console.log("Wrong password")
                    return res.send(JSON.stringify({'success': 0, 'err': "Wrong password"}))
                req.session.user = user
                return res.end(JSON.stringify({'success': 1}))
            )
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
            req.session.user = userObj
            return res.send(JSON.stringify({'success': 1}))
        )

    app.get '/logout', (req, res) ->
        req.session.user = null
        return res.redirect('/singinup')

    app.post('/user/star', (req, res) ->
        error = (msg) ->
            return res.end(JSON.stringify({success: 0, err, msg}))
        succeed = () ->
            return res.end(JSON.stringify({success: 1}))

        User.findById(req.body._id, (err, user) ->
            if err
                return error(err)
            unless user?
                return error("User dosen't exist")
            _u = req.session.user
            i = user.followers.indexOf(_u._id)
            if req.body.toggle
                if i != -1
                    # should remove
                    user.followers.splice(i, 1)
                else
                    # should add
                    user.followers.push(_u._id)
            else
                if req.body.star and i == -1
                    user.followers.push(_u._id)
                if req.body.unstar and i != -1
                    user.followers.splice(i, 1)
            user.save( (err, user) ->
                if err
                    return error(err)
                return succeed()
            )
        )
    )

module.exports = routes
