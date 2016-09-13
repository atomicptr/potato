program = require "commander"

packAction = require "./action_pack"
unpackAction = require "./action_unpack"
printAction = require "./action_print"

packageJson = require "../package.json"

module.exports = (args) ->
    program
        .version packageJson.version
        .usage("pack|unpack <directory>")

    program
        .command "pack <directories...>"
        .option "--as-json", "Pack as .json file"
        .option "-o, --output <directory>", "Output Directory"
        .option "-q, --quiet", "No console output."
        .option "--panic", "Exit the program when an error occurs"
        .option "--stdout", "Print output to stdout instead of a file. This option auto enables also --panic and --quiet"
        .action packAction

    program
        .command "unpack <potatoFile> [outputPath]"
        .option "-q, --quiet", "No console output."
        .option "-f, --force", "If output directory already exists override it (Does not merge both structures)"
        .action unpackAction

    program
        .command "print <potatoFile>"
        .action printAction

    program.parse args

    # show help if executed without commands
    if program.args.length == 0
        program.help()
