bson = require "bson"
path = require "path"
fs = require "fs"
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
            json = BSON.deserialize(data)

            unpackPath = path.resolve process.cwd(), outputPath, path.basename(potatoFile, ".potato")

            alreadyExists = fs.existsSync(unpackPath)

            if alreadyExists and not force
                console.error "ERROR: #{unpackPath} already exists, either specify a different output path or add --force (which will override the existing files)"
                return

            if alreadyExists and force
                console.log "Delete existing #{unpackPath}..."
                rimraf.sync(unpackPath)

            console.log "Unpack contents to #{unpackPath}..."

            createObjects = (outputPath, obj) ->
                mkdirp.sync(outputPath)

                for key in Object.keys obj
                    if key.indexOf("__potato") > -1
                        continue

                    if obj[key].__potato_isfile?
                        content = Object.assign({}, obj[key])
                        delete content.__potato_isfile

                        filePath = path.resolve(outputPath, "#{key}.json")
                        console.log "\tunpacked #{filePath}"

                        fs.writeFileSync filePath, JSON.stringify(content, null, "    ")
                    else # is not a file
                        createObjects(path.resolve(outputPath, key), obj[key])

            createObjects unpackPath, json
