_ = require('underscore')

_req = {}

module.exports = (options) ->
    options = options || {}
    safe = (options.unsafe == undefined) ? ture: !options.unsafe

    return (req, res, next) ->
        _req = req
        if req.flash || !safe
            next()
        req.flash = _flash
        next()

_flash = (type, msg) ->
    TYPES = ['error', 'warn', 'info']
    if type and type not in TYPES
        return ''
    imsg = {
        error: ''
        warn: ''
        info: ''
    }
    msgs = _req.session.flash = _req.session.flash || imsg
    if type && msg
        if typeof(msg) != 'string'
            return ''
        msgs[type] = msg
        return
    else if type
        ret = msgs[type]
        msgs[type] = ''
        return ret
    else
        _req.session.flash = imsg
        return msgs

_.extend _flash, {
    error : (msg) ->
        return @('error', msg)
    warn : (msg) ->
        return @('warn', msg)
    info : (msg) ->
        return @('info', msg)
}
