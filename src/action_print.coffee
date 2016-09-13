bson = require "bson"
path = require "path"
fs = require "fs"

nestedObject = require("./utils").nestedObject

BSON = new bson.BSONPure.BSON()

module.exports = (potatoFile, cmd) ->
    absolutePath = path.resolve process.cwd(), potatoFile

    fs.exists absolutePath, (exists) ->
        if not exists
            console.error("ERROR: Could not find potato file: #{absolutePath}")
            return

        fs.readFile absolutePath, (err, data) ->
            if err?
                console.error(err)
                return
            json = BSON.deserialize(data)

            console.log(JSON.stringify(json, null, "    "))
