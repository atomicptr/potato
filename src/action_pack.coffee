bson = require "bson"
path = require "path"
fs = require "fs"
glob = require "glob"

nestedObject = require("./utils").nestedObject

BSON = new bson.BSONPure.BSON()

module.exports = (directories, cmd) ->
    for dir in directories
        absolutePath = path.resolve __dirname, dir
        if not fs.existsSync(absolutePath)
            console.log "Can't find a directory called \"#{dir}.\". (Absolute Path: #{absolutePath})"
            continue

        if not fs.lstatSync(absolutePath).isDirectory()
            console.log "#{dir} is not a directory, can't make a potato out of it."
            continue

        console.log "Trying to pack: #{absolutePath}"

        obj = {}
        objName = path.basename dir

        outputPath = if cmd.output? then cmd.output else "."
        packAsJson = cmd.asJson?

        globOptions =
            cwd: path.resolve(absolutePath),
            matchBase: true

        files = glob.sync "*.json", globOptions

        console.log "\tfound #{files.length} files..."

        for file in files
            console.log "\tpacking #{path.resolve dir, file}..."

            parts = file.split("/").slice(0, file.split("/").length - 1)

            content = JSON.parse(fs.readFileSync(path.resolve absolutePath, file))

            if parts.length == 0
                # put it in base
                obj = nestedObject obj, [path.basename(file, ".json")], content
            else
                obj = nestedObject obj, parts.concat(path.basename(file, ".json")), content

        # done building structure...
        outputFile = path.resolve __dirname, outputPath, if packAsJson then "#{objName}.json" else "#{objName}.potato"

        data = null

        if packAsJson
            data = JSON.stringify obj, null, "    "
        else
            data = BSON.serialize obj, false, true, false

        # wrapper to prevent the overshadowing of outputFile
        makeCallback = (outputFile) -> (err) ->
            if err?
                console.error "ERROR: Could not write file #{outputFile}\n#{err}"
                return
            console.log "DONE. You can find the packed resource at #{outputFile}"

        fs.writeFile outputFile, data, makeCallback(outputFile)
