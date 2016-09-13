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
        .option "--panic", "Exit the program when an error occurs"
        .option "--stdout", "Print output to stdout instead of a file. This option auto enables also --panic and --quiet"
        .action packAction

    program.parse args

    # show help if executed without commands
    if program.args.length == 0
        program.help()

    # if command pack or unpack are not used
    if program.args.indexOf("pack") == -1 and program.args.indexOf("unpack") == -1
        program.help()
