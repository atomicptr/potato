bson = require "bson"
path = require "path"
fs = require "fs"
zlib = require "zlib"
rimraf = require "rimraf"
mkdirp = require "mkdirp"

nestedObject = require("./utils").nestedObject

BSON = new bson.BSONPure.BSON()

module.exports = (potatoFile, outputPath, cmd) ->
    if not outputPath?
        outputPath = "."

    absolutePath = path.resolve process.cwd(), potatoFile
    quiet = cmd.quiet?
    force = cmd.force?

    if not potatoFile.endsWith(".potato")
        console.error("ERROR: #{absolutePath} doesn't look like a potato (doesn't end with .potato)")
        return

    fs.exists absolutePath, (exists) ->
        if not exists
            console.error("ERROR: Could not find potato file: #{absolutePath}")
            return

        fs.readFile absolutePath, (err, data) ->
            if err?
                console.error(err)
                return
            json = BSON.deserialize zlib.gunzipSync data

            unpackPath = path.resolve process.cwd(), outputPath, path.basename(potatoFile, ".potato")

            alreadyExists = fs.existsSync(unpackPath)

            if alreadyExists and not force
                console.error "ERROR: #{unpackPath} already exists, either specify a different output path or add --force (which will override the existing files)"
                return

            if alreadyExists and force
                if not quiet
                    console.log "Delete existing #{unpackPath}..."
                rimraf.sync(unpackPath)

            if not quiet
                console.log "Unpack contents to #{unpackPath}..."

            createObjects = (outputPath, obj) ->
                mkdirp.sync(outputPath)

                for key in Object.keys obj
                    # restore schema
                    if key == "__potato_schema"
                        schemaPath = path.resolve outputPath, key
                        data = JSON.stringify obj[key], null, "    "
                        fs.writeFileSync schemaPath, data
                        if not quiet
                            console.log "\tunpacked schema at #{schemaPath}"
                        continue

                    if key.indexOf("__potato") > -1
                        continue

                    if obj[key].__potato_isfile?
                        content = Object.assign({}, obj[key])
                        delete content.__potato_isfile

                        filePath = null
                        data = null

                        if obj[key].__potato_isasset?
                            filePath = path.resolve(outputPath, key)
                            data = new Buffer(obj[key].data, "base64");
                        else if obj[key].__potato_isarray?
                            filePath = path.resolve(outputPath, "#{key}.json")
                            data = JSON.stringify(content.data, null, "    ")
                        else
                            filePath = path.resolve(outputPath, "#{key}.json")
                            data = JSON.stringify(content, null, "    ")

                        if not quiet
                            console.log "\tunpacked #{filePath}"

                        fs.writeFileSync filePath, data
                    else # is not a file
                        createObjects(path.resolve(outputPath, key), obj[key])

            createObjects unpackPath, json
            if not quiet
                console.log "DONE. Unpacked potato at #{unpackPath}"
