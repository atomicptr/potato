path = require "path"
chokidar = require "chokidar"

packAction = require "./action_pack"

# finds out to which directory in dirs path belongs
whichDir = (dirs, mypath) ->
    pathParts = mypath.split path.sep

    tmp = {}
    tmp[dir] = contains: true, depth: 0 for dir in dirs

    for dir in dirs
        for part, index in dir.split path.sep
            isSamePart = part == pathParts[index]
            tmp[dir].depth = if isSamePart then tmp[dir].depth + 1 else tmp[dir].depth
            tmp[dir].contains = tmp[dir].contains and isSamePart

    arr = dirs.map (dir) -> dir: dir, contains: tmp[dir].contains, depth: tmp[dir].depth

    contains = arr.filter (dir) -> dir.contains
    sorted = contains.sort (a, b) -> a.depth < b.depth

    return if sorted.length == 0 then null else sorted[0].dir

pack = (dir, cmd, callback) ->
    cmd.quiet = true
    cmd.__watch_callback = callback
    packAction [dir], cmd

module.exports = (directories, cmd) ->
    options =
        ignoreInitial: true,
        awaitWriteFinish: true

    dirs = directories.map (dir) -> path.resolve process.cwd(), dir

    console.log "watching #{dir}" for dir in dirs

    watcher = chokidar.watch dirs, options

    makeCallback = (dirs, action) -> (changedItem) ->
        console.log "#{action} #{changedItem}"
        pack whichDir(dirs, changedItem), cmd, (potato, files) ->
            console.log "rebuild #{potato} with #{files.length} files:"
            console.log "\t#{file}" for file in files

    watcher.on "add", makeCallback(dirs, "add")
    watcher.on "change", makeCallback(dirs, "change")
    watcher.on "unlink", makeCallback(dirs, "delete")
