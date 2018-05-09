#! /bin/bash

mkdir -p ./data.src
rm -rf ./data.src/*

mkdir -p ./data.intermediate
rm -r ./data.intermediate/*

mkdir -p ./data.final
rm -r ./data.final/*

git clone \
  --depth 1 \
  --branch master \
  --single-branch \
  https://github.com/schmich/hearthstone-card-images \
  ./data.src/card_images

git clone \
  --depth 1 \
  --branch master \
  --single-branch \
  https://github.com/HearthSim/hsdata \
  ./data.src/card_defs

lua xml_to_lua.lua ./data.src/card_defs/CardDefs.xml ./data.intermediate/card_defs.lua
lua align-pass_1.lua ./data.intermediate/card_defs.lua ./data.intermediate/card_defs.aligned.1.lua
lua align-pass_2.lua ./data.intermediate/card_defs.aligned.1.lua ./data.intermediate/card_defs.aligned.2.lua
lua filter_collectible.lua ./data.intermediate/card_defs.aligned.2.lua ./data.intermediate/card_defs.filtered.collectible.lua
lua filter_final.lua ./data.intermediate/card_defs.filtered.collectible.lua ./data.intermediate/card_defs.filtered.final.lua

mv ./data.intermediate/card_defs.filtered.final.lua ./data.final/

lua create_rename_script.lua ./data.intermediate/card_defs.aligned.2.lua ./data.intermediate/rename_script.sh
# lua create_rename_script.lua ./data.intermediate/card_defs.filtered.collectible.lua ./data.intermediate/rename_script.sh

rm -r ./data.final/card_images/
mkdir ./data.final/card_images/
cp --recursive ./data.src/card_images/rel/*.png ./data.final/card_images/

orig_dir=`pwd`
cd ./data.final/card_images
bash ../../data.intermediate/rename_script.sh
cd $orig_dir
