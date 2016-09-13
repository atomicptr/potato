program = require "commander"
packAction = require "./action_pack"

packageJson = require "../package.json"

program
    .version packageJson.version

program
    .command "pack <directories...>"
    .option "--as-json", "Pack as .json file"
    .option "-o, --output <directory>", "Output Directory"
    .action packAction


program.parse process.argv
