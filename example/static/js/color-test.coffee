showColor = (c) ->
    console.log 'color: ', c
    $('#main').css backgroundColor: "rgba(#{ c.r },#{ c.g },#{ c.b },#{ c.a })"

$ ->

    # Create individual stream for each color input
    crs = eventStream('midi', 'recv:nanoKONTROL2:3').map (v) -> {r: Math.round v * 255}
    cgs = eventStream('midi', 'recv:nanoKONTROL2:4').map (v) -> {g: Math.round v * 255}
    cbs = eventStream('midi', 'recv:nanoKONTROL2:5').map (v) -> {b: Math.round v * 255}
    cas = eventStream('midi', 'recv:nanoKONTROL2:2').map (v) -> {a: v}

    # Define the starting color, to be extended
    color0 = {r: 255, g: 255, b: 255, a: 1}

    # Merge latest r, g, b, l values into one rgbl object
    rgbas = h.merge([crs, cgs, cbs, cas])
        .scan(color0, h.flip(h.extend))

    # Debounce and output color
    rgbas.doto(showColor).resume()
