mg = require 'mongoose'

userSchema = mg.Schema({
    username: {type:String, unique: true}
    password: {type:String, validate: (v)->
        v.length > 0
    }
    name: String
    location: String
    phone1: String
    phone2: String
    company: String
    followers: [{ type: mg.Schema.Types.ObjectId, ref: 'User'}]
    meta: {
        createAt: {type: Date, default: Date.now()}
        updateAt: {type: Date, default: Date.now()}
    }
})

userSchema.pre 'save', (next) ->
    console.log("pre saving")
    self = @
    if self.isNew
        self.meta.createAt = self.meta.updateAt = Date.now()
    else
        self.meta.updateAt = Date.now()
    next()

userSchema.statics = {
    fetch: (cb) ->
        @find({})
            .sort('meta.createAt')
            .exec(cb)
    findById: (id, cb) ->
        console.log(id)
        ObjectId = mg.Types.ObjectId
        oId = new ObjectId(id)
        @findOne({_id: oId}).exec(cb)
    findByUsername: (username, cb) ->
        @findOne({username: username})
            .exec(cb)
}

User = mg.model('User', userSchema)
###
User.prototype.validate = () ->
    self = this
    return self.name? && self.location? &&(self.phone1? || self.phone2?)
###
module.exports = User
