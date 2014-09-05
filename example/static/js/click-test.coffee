setCss = h.curry (k, v) ->
    $('#main').css k, v

times = h.curry (n, v) -> n * v

$ ->

    # Create individual stream for each color input
    ms = eventStream('midi', 'nanoKONTROL2:19').map(times 200).each setCss 'margin'
    ps = eventStream('midi', 'nanoKONTROL2:20').map(times 200).each setCss 'padding'
    ps = eventStream('midi', 'nanoKONTROL2:21').map(times 100).each setCss 'font-size'
    ps = eventStream('midi', 'nanoKONTROL2:22').map(times 5).each setCss 'line-height'

