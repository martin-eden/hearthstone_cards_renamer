--[[
  Convert Hearthstone cards info.

  It awaits CardDefs.xml file, represented as Lua table. Then it
  restructures a bit it's data and removes translations to languages
  other than English.

  All other information is not removed.

  (Next step planned is restruc this records again, by removing
  all non-collectible cards and unparsed fields.)
]]

require('workshop.base')

local map_values = request('!.table.map_values')

local excluded_types =
  map_values(
    {
      'deDE',
      -- 'enUS',
      'esES',
      'esMX',
      'frFR',
      'itIT',
      'jaJP',
      'koKR',
      'plPL',
      'ptBR',
      'ruRU',
      'thTH',
      'zhCN',
      'zhTW',
    }
  )

local rip_translations
rip_translations =
  function(node)
    if is_table(node) and (node.type == 'Tag') then
      for i = #node, 1, -1 do
        if excluded_types[node[i].type] then
          table.remove(node, i)
        end
      end
      return node
    else
      if is_table(node) then
        for k, v in pairs(node) do
          node[k] = rip_translations(v)
        end
      end
      return node
    end
  end

local remove_empty_tables
remove_empty_tables =
  function(node)
    if is_table(node) then
      for k, v in pairs(node) do
        remove_empty_tables(v)
        if is_table(v) and not next(v) then
          node[k] = nil
        end
      end
    end
  end

local int_tags =
  map_values(
    {
      'ADAPT',
      'ADJACENT_BUFF',
      'AI_MUST_PLAY',
      'ATK',
      'AttackVisualType',
      'AURA',
      'BATTLECRY',
      'CANT_ATTACK',
      'CANT_BE_TARGETED_BY_HERO_POWERS',
      'CANT_BE_TARGETED_BY_SPELLS',
      'CARD_SET',
      'CARDRACE',
      'CARDTYPE',
      'CHARGE',
      'CHOOSE_ONE',
      'CLASS',
      'COLLECTIBLE',
      'COMBO',
      'COST',
      'COUNTER',
      'DEATHRATTLE',
      'DevState',
      'DISCOVER',
      'DIVINE_SHIELD',
      'DURABILITY',
      'ELITE',
      'ENCHANTMENT_BIRTH_VISUAL',
      'ENCHANTMENT_IDLE_VISUAL',
      'ENRAGED',
      'FACTION',
      'FORGETFUL',
      'FREEZE',
      'HEALTH',
      'HEROPOWER_DAMAGE',
      'HIDE_STATS',
      'IMMUNE',
      'INSPIRE',
      'InvisibleDeathrattle',
      'JADE_GOLEM',
      'LIFESTEAL',
      'OVERLOAD',
      'OVERLOAD_OWED',
      'POISONOUS',
      'QUEST',
      'QUEST_PROGRESS_TOTAL',
      'RARITY',
      'RECEIVES_DOUBLE_SPELLDAMAGE_BONUS',
      'RITUAL',
      'SECRET',
      'SILENCE',
      'SPELLPOWER',
      'STEALTH',
      'TAG_ONE_TURN_EFFECT',
      'TAUNT',
      'TOPDECK',
      'TRIGGER_VISUAL',
      'WINDFURY',
    }
  )

local string_tags =
  map_values(
    {
      'CARDNAME',
      'CARDTEXT_INHAND',
      'FLAVORTEXT',
      'ARTISTNAME',
      'HOW_TO_EARN',
      'HOW_TO_EARN_GOLDEN',
      'TARGETING_ARROW_TEXT',
    }
  )

local handle_tag =
  function(tag_rec)
    assert_table(tag_rec)
    assert((tag_rec.type == 'Tag') or (tag_rec.type == 'ReferencedTag'))

    local is_referenced = (tag_rec.type == 'ReferencedTag')

    tag_rec.type = nil

    local key, value
    if string_tags[tag_rec.attributes.name] then
      key = tag_rec.attributes.name
      tag_rec.attributes.name = nil

      if tag_rec[1] then
        value = tag_rec[1].value
        tag_rec[1].type = nil
        tag_rec[1].value = nil
      elseif tag_rec.value then
        value = tag_rec.value
        tag_rec.value = nil
      end

      tag_rec.attributes.enumID = nil
      tag_rec.attributes.type = nil
    elseif int_tags[tag_rec.attributes.name] then
      key = tag_rec.attributes.name
      tag_rec.attributes.name = nil

      value = tonumber(tag_rec.attributes.value)
      tag_rec.attributes.value = nil

      tag_rec.attributes.enumID = nil
      tag_rec.attributes.type = nil
    elseif (tag_rec.attributes.name == 'HERO_POWER') then
      key = 'hero_power_card_id'
      tag_rec.attributes.name = nil

      value = tag_rec.attributes.cardID
      tag_rec.attributes.cardID = nil

      tag_rec.attributes.enumID = nil
      tag_rec.attributes.type = nil
      tag_rec.attributes.value = nil
    end

    if is_referenced and key then
      key = 'reference_' .. key
    end

    return key, value
  end

local format_card =
  function(raw_card_rec)
    assert(raw_card_rec.type == 'Entity')

    raw_card_rec.type = nil

    local id = tonumber(raw_card_rec.attributes.ID)
    raw_card_rec.attributes.ID = nil

    local card_id = raw_card_rec.attributes.CardID
    raw_card_rec.attributes.CardID = nil

    local version = tonumber(raw_card_rec.attributes.version)
    raw_card_rec.attributes.version = nil

    local result =
      {
        id = id,
        card_id = card_id,
        version = version,
        unparsed = raw_card_rec,
      }

    local power_id
    local show_in_history
    local play_requirements

    for i = 1, #raw_card_rec do
      local node = raw_card_rec[i]
      assert_table(node)
      local node_type = node.type
      if
        (node_type == 'Tag') or
        (node_type == 'ReferencedTag')
      then
        local key, value = handle_tag(node)
        if key then
          result[key] = value
        end
      elseif (node_type == 'MasterPower') then
        assert(not power_id)
        power_id = node.value
        node.type = nil
        node.value = nil
      elseif (node_type == 'Power') then
        local another_power_id = node.attributes.definition
        assert(another_power_id)
        node.attributes.definition = nil
        node.type = nil
        for i = 1, #node do
          if (node[i].type == 'PlayRequirement') then
            play_requirements = play_requirements or {}
            local req_id = tonumber(node[i].attributes.reqID)
            table.insert(play_requirements, req_id)
            node[i].type = nil
            node[i].attributes.reqID = nil
            node[i].attributes.param = nil
          end
        end
      elseif (node_type == 'TriggeredPowerHistoryInfo') then
        assert(node.attributes.showInHistory)
        assert(node.attributes.effectIndex)
        if (node.attributes.effectIndex == '0') then
          show_in_history = (node.attributes.showInHistory == 'True')
          node.attributes.showInHistory = nil
          node.attributes.effectIndex = nil
          node.type = nil
        end
      end
    end

    result.power_id = power_id
    result.show_in_history = show_in_history
    result.play_requirements = play_requirements

    return result
  end

local format_cards =
  function(t)
    assert_table(t)
    assert_table(t[1])
    assert(t[1].type == 'CardDefs')
    t = t[1]
    for i = 1, #t do
      t[i] = format_card(t[i])
    end
    return t
  end

local transform =
  function(t)
    local result = rip_translations(t)
    result = format_cards(result)
    remove_empty_tables(result)
    return result
  end

local convert = request('!.file.convert')
convert(
  {
    action_name = 'Transform #1',
    f_in_name = arg[1],
    f_out_name = arg[2],
    transform = transform,
  }
)
