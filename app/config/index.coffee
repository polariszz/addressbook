config = require "./default"
_ = require "underscore"

NODE_ENV = process.env.NODE_ENV || "development"
console.log("NODE_ENV", NODE_ENV)

try
    env_config = require("./" + NODE_ENV)
catch e
    console.log("[config]: requiring ", NODE_ENV)
    console.log("falling back to development")
    env_config = require("./development")

_.extend(config, env_config)
module.exports = config
