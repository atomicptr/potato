# potato

A tool to pack a file based json database into one big file, with potatoes.

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

#### Implementations

* C# https://gist.github.com/atomicptr/484276c6d637be157213237d48181050

#### Do it yourself

The process of parsing a .potato file is very trivial. It's basically a gzip compressed BSON object which would look like this if it were a JSON object instead (assuming this is the file that was made from the structure above):
```
{
    "items": {
        "sword": content of swords.json,
        "shield": content of shield.json
    },
    "assets": {
        "img.asset.png": { data: base64 string of the asset... }
    },

}
```

## License

MIT
