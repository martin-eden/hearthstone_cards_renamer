# Hearthstone card images renamer

Ok, this is code to retrieve Hearthstone cards images and card
descriptions. Then rename it to nice names and place in directories
named by expansions and class names.

License: GPLv3

## Requirements

* Linux

* git

* Lua 5.3.4

    `sudo apt install lua5.3` or donwload from official [Lua site]
    (https://www.lua.org/download.html)

* luarocks

    `sudo apt install luarocks` or donwload from official [luarocks site]
    (https://luarocks.org/)

* `luaexpat` rock

    `sudo luarocks install luaexpat`

## Usage

`bash convert.sh`

It clones repositories with images and with card descritions.
Then parses XML with card descriptions, creates rename script and
runs it.

If you're tinkering with conversion logic, I recommend to comment
sections with repos cloning for subsequent runs.


## Other notes

* [My other repositories](https://github.com/martin-eden/contents)
* Checked 2018-05-08.
