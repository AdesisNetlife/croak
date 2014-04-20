require! promptly

module.exports = (message, callback, list, type, options) ->

  const args = Array::slice.call &

  { type, fnArgs } = do ->
    temp = {}
    fnArgs = []

    args.for-each (value, i) ->
      switch value |> get-type
        when 'string'
          if i is 0
            temp <<< message: value
          else
            temp <<< type: value
        when 'function' then temp <<< callback: value
        when 'array' then temp <<< list: value
        when 'object' then temp <<< options: value

    temp.type ?= 'prompt'
    for own param, value of temp
      when param isnt 'type'
      then value |> fnArgs.push

    type: temp.type, fnArgs: fnArgs

  fnArgs |> promptly[type]apply null, _

get-type = ->
  type = typeof it
  type = 'array' if it |> Array.isArray if type is 'object'
  type
