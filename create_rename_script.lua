require('workshop.base')

local used_names = {}

local get_names =
  function(card)
    local src_file_name = ('%d.png'):format(card.raw_id)

    local dir_name = ''
    if not card.groups.is_collectible then
      dir_name = 'not_collectible/'
    end
    dir_name = dir_name .. ('"%s"/'):format(card.groups.set)
    if card.groups.class then
      dir_name = dir_name .. ('"%s"/'):format(card.groups.class)
    end

    local dest_file_name = ('%s.png'):format(card.texts.name)

    local key = dir_name .. (card.texts.name or '')
    used_names[key] = used_names[key] or 0
    used_names[key] = used_names[key] + 1
    if (used_names[key] >= 2) then
      dest_file_name = ('%s (%d).png'):format(card.texts.name, used_names[key])
    end
    dest_file_name = ('%q'):format(dest_file_name)

    return src_file_name, dir_name, dest_file_name
  end

local used_dirs = {}

local create_rename_command =
  function(src_file_name, dir_name, dest_file_name)
    local result = ''
    if not used_dirs[dir_name] then
      used_dirs[dir_name] = true
      result = ('mkdir -p ./%s'):format(dir_name)
      result = result .. '\n'
    end
    result =
      result ..
      ('mv ./%s ./%s%s 2> /dev/null'):format(src_file_name, dir_name, dest_file_name)
    return result
  end

local compile =
  function(cards)
    local result = {}
    for _, card in ipairs(cards) do
      local src_file_name, dir_name, dest_file_name = get_names(card)
      local rename_cmd = create_rename_command(src_file_name, dir_name, dest_file_name)
      table.insert(result, rename_cmd)
    end
    result = table.concat(result, '\n')
    return result
  end

local convert = request('!.file.convert')
convert(
  {
    action_name = 'Create rename script',
    f_in_name = arg[1],
    f_out_name = arg[2],
    compile = compile,
  }
)
