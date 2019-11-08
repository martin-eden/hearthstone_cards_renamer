require('workshop.base')

local filter =
  function(card_rec)
    return card_rec.groups.is_collectible
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
    action_name = 'Filter collectible cards',
    f_in_name = arg[1],
    f_out_name = arg[2],
    transform = transform,
  }
)
