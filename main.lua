local tokens = {}

function random_token()
  math.randomseed(os.time())
  return math.random(1000, 9999)
end

RegisterCommand('generate-token', function(serverId, args)
  if serverId ~= 0 then
    return
  end

  local token = next(tokens)

  if token then
    print(('Token: (%s)'):format(token))
    return
  end

  local token = random_token()
  print(('Token: (%s)'):format(token))
  tokens[tostring(token)] = true

end, true)

RegisterCommand('list-tokens',  function(serverId)
  if serverId ~= 0 then
    return
  end
  print('listing tokens')
  for token, _ in pairs(tokens) do 
    print(('token: %s'):format(token))
  end
  print('done listing tokens')
end, true)

AddEventHandler('playerConnecting', function(name, skr, d)
  local serverId = source
  print(('Connecting %s.'):format(name))

  d.defer()

  Wait(50)

  function onResponse(data, rawData)
    local token = data['txtToken']

    if not tokens[token] then
      d.done('Take a U turn!')
      return
    end

    tokens[token] = nil
    d.done()
  end

  d.presentCard([[
  {
    "type": "AdaptiveCard",
    "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
    "version": "1.6",
    "actions": [
        {
            "type": "Action.Submit",
            "title": "Enter"
        }
    ],
    "body": [
        {
            "type": "Input.Text",
            "placeholder": "Token",
            "id": "txtToken"
        }
    ]
}
  ]], onResponse)
end)
