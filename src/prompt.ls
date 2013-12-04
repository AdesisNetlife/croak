require! promptly

module.exports = (message, callback, list, type, options) ->
  # simple input arguments normalizer based on its type
  args = Array::slice.call &
  
  { type, fnArgs } = do ->
    temp = {}
    fnArgs = []

    args.forEach (value, i) ->
      switch get-type value
        when 'string'
          if i is 0
            temp.message = value
          else
            temp.type = value
        when 'function' then temp.callback = value
        when 'array' then temp.list = value
        when 'object' then temp.options = value

    temp.type ?= 'prompt'
    for own param, value of temp when param isnt 'type'
      value |> fnArgs.push

    { type: temp.type, fnArgs: fnArgs }

  promptly[type].apply null, fnArgs

get-type = ->
  type = typeof it
  if type is 'object'
    type = 'array' if it |> Array.isArray
  type
