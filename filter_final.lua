require('workshop.base')

local filter =
  function(card_rec)
    return
      (
        (card_rec.groups.class == 'mage') or
        (card_rec.groups.class == 'neutral')
      )
      and
      -- (card_rec.groups.type == 'minion') and
      -- (card_rec.groups.rarity == 'rare') and
      (card_rec.groups.set == 'classic')
  end

local transform =
  function(cards)
    for i = #cards, 1, -1 do
      if not filter(cards[i]) then
        table.remove(cards, i)
      end
    end
    return cards
  end

local convert = request('!.file.convert')
convert(
  {
    action_name = 'Apply custom filter',
    f_in_name = arg[1],
    f_out_name = arg[2],
    transform = transform,
  }
)
