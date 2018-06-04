# Hearthstone card images renamer

Ok, this is code to retrieve Hearthstone card images and card
descriptions. And struct them nicely, placing in directories
named by expansions and class names.

License: GPLv3

## Requirements
| what | howto get |
|:---:| --- |
| Linux| |
| git | |
| Lua 5.3.4 | `$ sudo apt install lua5.3` or donwload from official [Lua site](https://www.lua.org/download.html) |
| luarocks | `$ sudo apt install luarocks` or donwload from official [luarocks site](https://luarocks.org/) |
| `luaexpat` rock | `$ sudo luarocks install luaexpat` |

## Installation
`$ git clone https://github.com/martin-eden/hearthstone_cards_renamer`

## Deinstallation
Remove `hearthstone_cards_renamer` directory.

## Usage

`$ bash convert.sh`

It clones repositories with images and with card descritions.
Then parses XML with card descriptions, creates rename script and
runs it.

Results are placed in `./data.final/card_images/`.

## Other notes

* Images are from `Chris Schmich's` [hearthstone-card-images](https://github.com/schmich/hearthstone-card-images) repository.
* Card descriptions from [HearthSim](https://github.com/HearthSim/hsdata) project.
* Results of conversion are in [heartstone_cards_named](https://github.com/martin-eden/hearthstone_cards_named) repository.
* [My other repositories](https://github.com/martin-eden/contents).
* Checked 2018-06-04.
