bson = require "bson"
path = require "path"
fs = require "fs"
glob = require "glob"
zlib = require "zlib"

nestedObject = require("./utils").nestedObject

packageJson = require "../package.json"

BSON = new bson.BSONPure.BSON()

module.exports = (directories, cmd) ->
    for dir in directories
        absolutePath = path.resolve process.cwd(), dir

        obj = {}
        obj.__potato = version: packageJson.version, timestamp: new Date().getTime()
        objName = path.basename dir

        outputPath = if cmd.output? then cmd.output else "."
        packAsJson = cmd.asJson?
        quiet = cmd.quiet?
        panic = cmd.panic?
        stdout = cmd.stdout?
        ignoreAssets = cmd.ignoreAssets?
        watchCallback = cmd.__watch_callback

        if stdout
            quiet = true
            panic = true

        if not fs.existsSync(absolutePath)
            console.error "Can't find a directory called \"#{dir}.\". (Absolute Path: #{absolutePath})"
            if panic
                process.exit 1
            continue

        if not fs.lstatSync(absolutePath).isDirectory()
            console.error "#{dir} is not a directory, can't make a potato out of it."
            if panic
                process.exit 1
            continue

        if not quiet
            console.log "Trying to pack: #{absolutePath}"

        globOptions =
            cwd: path.resolve(absolutePath),
            matchBase: true

        files = glob.sync "*.json", globOptions
        assets = glob.sync "*.asset.*", globOptions

        filesAndAssets = if ignoreAssets then files else files.concat(assets)

        if not quiet
            console.log "\tfound #{filesAndAssets.length} files..."

        for file in filesAndAssets
            if not quiet
                console.log "\tpacking #{path.resolve dir, file}..."

            parts = file.split("/").slice(0, file.split("/").length - 1)

            content = null

            fileContent = fs.readFileSync(path.resolve absolutePath, file)

            # If the file is an asset
            if assets.indexOf(file) > -1
                content = data: fileContent.toString("base64")
                content.__potato_isasset = true # TODO: remember file type
                content.__potato_filetype = path.extname file
            else
                content = JSON.parse(fileContent)

                if Array.isArray(content)
                    content = {data: content}
                    content.__potato_isarray = true

            content.__potato_isfile = true

            if parts.length == 0
                # put it in base
                obj = nestedObject obj, [path.basename(file, ".json")], content
            else
                obj = nestedObject obj, parts.concat(path.basename(file, ".json")), content

        # done building structure...
        outputFile = path.resolve process.cwd(), outputPath, if packAsJson then "#{objName}.json" else "#{objName}.potato"

        data = null

        if packAsJson
            data = JSON.stringify obj, null, "    "
        else
            data = BSON.serialize obj, false, true, false

        # wrapper to prevent the overshadowing of outputFile
        makeCallback = (outputFile) -> (err) ->
            if err?
                console.error "ERROR: Could not write file #{outputFile}\n#{err}"
                if panic
                    process.exit 1
                return
            if not quiet
                console.log "DONE. You can find the packed resource at #{outputFile}"

            if watchCallback?
                watchCallback outputFile, filesAndAssets

        compressedData = if not packAsJson then zlib.gzipSync(data) else data

        if not stdout
            fs.writeFile outputFile, compressedData, makeCallback(outputFile)
        else
            process.stdout.write(compressedData)
