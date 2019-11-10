#! /bin/bash

# Load and process Hearthstone card images.

bash clear_data.sh
bash create_dirs.sh

echo "--[ Get card images ]--"
git clone \
  --depth 1 \
  --branch master \
  --single-branch \
  https://github.com/schmich/hearthstone-card-images \
  ./data.src/card_images

echo "--[ Get card descriptions ]--"
git clone \
  --depth 1 \
  --branch master \
  --single-branch \
  https://github.com/HearthSim/hsdata \
  ./data.src/card_defs

lua xml_to_lua.lua ./data.src/card_defs/CardDefs.xml ./data.intermediate/card_defs.lua
lua align-pass_1.lua ./data.intermediate/card_defs.lua ./data.intermediate/card_defs.aligned.1.lua
lua align-pass_2.lua ./data.intermediate/card_defs.aligned.1.lua ./data.intermediate/card_defs.aligned.2.lua
# lua filter_collectible.lua ./data.intermediate/card_defs.aligned.2.lua ./data.intermediate/card_defs.filtered.collectible.lua
# lua filter_final.lua ./data.intermediate/card_defs.filtered.collectible.lua ./data.intermediate/card_defs.filtered.final.lua

# mv ./data.intermediate/card_defs.filtered.final.lua ./data.final/

lua create_rename_script.lua ./data.intermediate/card_defs.aligned.2.lua ./data.intermediate/rename_script.sh
# lua create_rename_script.lua ./data.intermediate/card_defs.filtered.collectible.lua ./data.intermediate/rename_script.sh

echo "--[ Copying card images before renaming ]"
cp --recursive ./data.src/card_images/cards/en_US/*.png ./data.final/card_images/

echo "--[ Renaming ]"
orig_dir=`pwd`
cd ./data.final/card_images
bash ../../data.intermediate/rename_script.sh
cd "$orig_dir"
