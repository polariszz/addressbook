colors = require('colors')
config = require('../config')
moment = require('moment')
_ = require('underscore')
log_level = config.log.level

levels = {
    'debug': 0
    'info': 1
    'warn': 2
    'error': 3
}

colors = {
    'debug': 'blue'
    'info': 'green'
    'warn': 'yellow'
    'error': 'red'
}

class Log
    constructor: (tag) ->
        @tag = tag

    log: (level, msgs) ->
        if levels[level] < levels[log_level]
            return
        now = moment().format('YYYY-MM-DD HH:mm:ss')
        if level.length < 5
            space = ' '
        else
            space = ''
        prefix = '[' + now + '|' + level[colors[level]] + space + ']' + '['+ @tag + ']'

        if level == 'error' and typeof(msgs[0]) == 'object' and msgs[0].stack?
            console.error(prefix + msgs[0].stack[colors[level]])
            return

        output = (content) ->
            if _.isArray(content)
                output(content.join(' '))
            else if _.isObject(content)
                m = ''
                _.each(content, (k, v) ->
                    m += v + ' '
                )
                output(m)
            else if _.isString(content)
                console.log(prefix, content[colors[level]])
        output(msgs)

    info: () ->
        @log('info', _.toArray(arguments))

    warn: () ->
        @log('warn', _.toArray(arguments))

    debug: () ->
        @log('debug', _.toArray(arguments))

    error: (err) ->
        @log('error', err)

module.exports = Log
