package.path = package.path .. ';../../../?.lua'
require('workshop.base')

local used_modules =
  {
    'workshop.base',
    '!.table.map_values',
    '!.file.convert',
    '!.string.trim_space_control',
  }
local deploy_script_name = 'deploy.sh'
local deploy_dir_name = 'deploy'

local create_deploy_script = request('!.system.create_deploy_script')
create_deploy_script(used_modules, deploy_script_name, deploy_dir_name)
