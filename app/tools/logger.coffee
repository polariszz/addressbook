### winston logger ###
winston = require 'winston'
config = require '../config'

logger = new (winston.Logger)({
    transports: [
        new (winston.transports.Console)({level: config.log.level})
        new (winston.transports.File)({
            filename: config.log.file
            level: config.log.file_level
        })
    ]
})

module.exports = logger
