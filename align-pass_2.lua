-- Todo: Cards with fields: Cult Master

require('workshop.base')

local type_names =
  {
    [3] = 'hero',
    [4] = 'minion',
    [5] = 'spell',
    [7] = 'weapon',
  }

local class_names =
  {
    [2] = 'druid',
    [3] = 'hunter',
    [4] = 'mage',
    [5] = 'paladin',
    [6] = 'priest',
    [7] = 'rogue',
    [8] = 'shaman',
    [9] = 'warlock',
    [10] = 'warrior',
    [12] = 'neutral',
  }

local rarities =
  {
    [1] = 'common',
    [2] = 'free',
    [3] = 'rare',
    [4] = 'epic',
    [5] = 'legendary',
  }

local set_names =
  {
    [0] = 'hall of fame',
    [2] = 'basic',
    [3] = 'classic',
    [4] = 'promo',
    [12] = 'adv - 1 - 2014-07 - naxxramas',
    [13] = 'exp - 1 - 2014-12 - goblins vs gnomes',
    [14] = 'adv - 2 - 2015-04 - blackrock mountain',
    [15] = 'exp - 2 - 2015-08 - the grand tournament',
    [17] = 'heroes pack',
    [18] = 'tavern brawl',
    [20] = 'adv - 3 - 2015-11 - league of explorers',
    [21] = 'exp - 3 - 2016-04 - whispers of the old gods',
    [23] = 'adv - 4 - 2016-11 - one night in karazhan',
    [25] = 'exp - 4 - 2016-12 - mean streets of gatzetzan',
    [27] = "exp - 5 - 2017-04 - journey to un'goro",
    [1001] = 'exp - 6 - 2017-08 - knights of the frozen throne',
    [1004] = 'exp - 7 - 2017-12 - kobolds and catacombs',
    [1125] = 'exp - 8 - 2018-04 - witchwood',
    [1127] = 'exp - 9 - 2018-08 - the boomsday project',
    [1129] = "exp - 10 - 2018-12 - rastaknhan's rumble",
    [1130] = 'exp - 11 - 2019-04 - rise of shadows',
    [1158] = 'exp - 12 - 2019-08 - saviors of uldum',
  }

local race_names =
  {
    [14] = 'murloc',
    [15] = 'demon',
    [17] = 'mech',
    [18] = 'elemental',
    [20] = 'beast',
    [21] = 'totem',
    [23] = 'pirate',
    [24] = 'dragon',
  }

local faction_names =
  {
    [1] = 'horde',
    [2] = 'alliance',
    [3] = 'neutral',
  }

local map =
  function(value, mapping)
    return
      mapping[value] or
      value or
      mapping[0]
  end

local remove =
  function(rec, field_name)
    local result = rec[field_name]
    rec[field_name] = nil
    return result
  end

local represent_card =
  function(native_card)
    local result = native_card

    result.main =
      {
        attack = remove(native_card, 'ATK'),
        health = remove(native_card, 'HEALTH'),
        cost = remove(native_card, 'COST'),
      }

    result.texts =
      {
        name = remove(native_card, 'CARDNAME'),
        description = remove(native_card, 'CARDTEXT_INHAND'),
        hint = remove(native_card, 'FLAVORTEXT'),
        earn_ordinary = remove(native_card, 'HOW_TO_EARN'),
        earn_golden = remove(native_card, 'HOW_TO_EARN_GOLDEN'),
        artist = remove(native_card, 'ARTISTNAME'),
      }

    result.groups =
      {
        class = map(remove(native_card, 'CLASS'), class_names),
        rarity = map(remove(native_card, 'RARITY'), rarities),
        type = map(remove(native_card, 'CARDTYPE'), type_names),
        set = map(remove(native_card, 'CARD_SET'), set_names),
        race = map(remove(native_card, 'CARDRACE'), race_names),
        faction = map(remove(native_card, 'FACTION'), faction_names),
        is_collectible = remove(native_card, 'COLLECTIBLE'),
      }

    result.raw_id = remove(native_card, 'id')
    result.id = remove(native_card, 'card_id')

    result.crap =
      {
        version = remove(native_card, 'version'),
        power_id = remove(native_card, 'power_id'),
        show_in_history = remove(native_card, 'show_in_history'),
        play_requirements = remove(native_card, 'play_requirements'),
        standalone_visual = remove(native_card, 'TRIGGER_VISUAL'),
        elite_visual = remove(native_card, 'ELITE'),
      }
    result.crap = nil

    return result
  end

local transform =
  function(t)
    assert_table(t)
    assert(t.type == 'CardDefs')
    local result = {}
    for _, card in ipairs(t) do
      table.insert(result, represent_card(card))
    end
    return result
  end

local convert = request('!.file.convert')
convert(
  {
    action_name = 'Transform #2',
    f_in_name = arg[1],
    f_out_name = arg[2],
    transform = transform,
  }
)
