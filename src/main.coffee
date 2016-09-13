program = require "commander"
packAction = require "./action_pack"

packageJson = require "../package.json"

module.exports = (args) ->
    program
        .version packageJson.version
        .usage("pack|unpack <directory>")

    program
        .command "pack <directories...>"
        .option "--as-json", "Pack as .json file"
        .option "-o, --output <directory>", "Output Directory"
        .option "-q, --quiet", "No output on stdout."
        .action packAction

    program.parse args

    # show help if executed without commands
    if program.args.length == 0
        program.help()
