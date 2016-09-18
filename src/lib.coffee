bson = require "bson"
zlib = require "zlib"

packageJson = require "../package.json"

BSON = new bson.BSONPure.BSON()

module.exports =
    version: packageJson.version
    # Arguments:
    #   strOrBuffer - A string or a buffer which contains the content of a potato file
    #   callback - A callback. First parameter contains an error object (or null if none occured)
    #               and the second one contains a JSON object with the potato file contents
    parse: (strOrBuffer, callback) ->
        zlib.gunzip strOrBuffer, (err, data) ->
            if err?
                callback err, null
            else
                json = BSON.deserialize data
                callback null, json
    # Arguments:
    #   object - The object you want to turn into a potato
    #   callback - callback(ERR, potatofied object)
    potatoify: (object, callback) ->
        data = BSON.serialize object, false, true, false
        zlib.gzip data, (err, data) ->
            if err?
                callback err, null
            else
                callback null, data
