nestedObjectGetValue = (base, elements) ->
    if elements.length == 0
        return base

    tmp = elements.slice(0)
    first = tmp.shift()

    return nestedObjectGetValue base[first], tmp

nestedObject = (base, elements, value) ->
    if elements.length == 0
        return base

    base[elements[0]] ?= {}

    if value? and elements.length == 1
        base[elements[0]] = value

    base[elements[0]] = nestedObject base[elements[0]], elements.slice(1, elements.length), value

    return base

module.exports =
    nestedObject: nestedObject,
    nestedObjectGetValue: nestedObjectGetValue
