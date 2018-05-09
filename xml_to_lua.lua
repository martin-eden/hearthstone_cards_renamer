--[[
  Load given XML file, convert it to Lua table, save table as file.

  Usage:

    @ <f_in> <f_out>

  Requires:

    * luarocks package "luaexpat" (module "lxp")
]]

require('workshop.base')

local parents = {}
local nesting_deep = 0

local lxp = require('lxp')

local trim = request('!.string.trim_space_control')

local parsed_xml = {}
local callbacks =
  {
    StartElement =
      function(parser, name, attributes)
        local node =
          {
            type = name,
          }
        for i = 1, #attributes do
          attributes[i] = nil
        end
        if next(attributes) then
          node.attributes = attributes
        end
        assert((nesting_deep == 0) or parents[nesting_deep])
        local parent = parents[nesting_deep] or parsed_xml
        table.insert(parent, node)
        nesting_deep = nesting_deep + 1
        parents[nesting_deep] = node
      end;
    EndElement =
      function(parser, name)
        nesting_deep = nesting_deep - 1
      end;
    CharacterData =
      function(parser, s)
        s = trim(s)
        if (s ~= '') then
          parents[nesting_deep].value = s
        end
      end;
  }

local parse_xml =
  function(xml_str)
    local p = lxp.new(callbacks)
    p:parse(xml_str)
    p:parse()
    p:close()
    return parsed_xml
  end

local convert = request('!.file.convert')
convert(
  {
    tool_name = 'Convert XML to Lua',
    f_in_name = arg[1],
    f_out_name = arg[2],
    parse = parse_xml,
  }
)
