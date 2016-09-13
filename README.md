# potato

A tool to pack a file based json database into one big file.

## Install

```
npm install -g potato-pack
```

## Usage

Assuming you have a structure like this:

```
mydata/
    /items/
        sword.json
        shield.json
    /assets/
        img.asset.png
    config.json
```

### Pack data

Just use the following command:

```
potato pack ./mydata
```

which will create a file called "mydata.potato". "pack" has some options you can check them via

```
potato pack --help
```

### Unpack data

Just use the following command:

```
potato unpack ./mydata.potato dest/
```

which will create a folder structure in "dest/". And yes this part was totally copy & paste from above :).

### How to use the packed data

At the moment there is no implementation for .potato files (derp). Need to do that at some point too...

## License

MIT
