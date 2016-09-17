# Types:
#   string - Well a string obviously
#   number - Also fairly obvious, note that numbers are both integers and floating point numbers
#   object - A JSON object like: {x: 4, y: 5}, important note: arrays don't match this
#   any - Anything is acceptable
# Suffix:
#   type! - Required, meaning if this field is not present the tool won't accept it. Required array
#           looks like this: "type[]!"
#   type[] - A JSON array of "type". An array of objects would be "object[]" if you have
#           an array that contains different types use "any[]"

baseTypes = ["string", "number"]

# Checks whetever or not an object fits a specified "schema type"
isType = (obj, type) ->
    jstype = typeof obj

    required = type.endsWith "!"
    reqstr = if required then "!" else ""
    isarray = type.endsWith "[]#{reqstr}"

    isBaseType = baseTypes.indexOf(jstype) > -1

    shorten = 0

    if required
        shorten++
    if isarray
        shorten += 2

    typebasename = type.substr 0, type.length - shorten
    reqfreeType = type.substr 0, type.length - (if required then 1 else 0)

    # check if the type is an actual array if it ends with []
    isAnActualArray = isarray and Array.isArray obj
    if isarray and not isAnActualArray
        return false

    # check for any
    if reqfreeType == "any"
        return true

    # check for string, number
    if isBaseType and not isarray
        return jstype == reqfreeType

    # check for object
    if not isarray
        # Arrays are also object in JS but we don't want them
        return jstype == "object" and not Array.isArray(obj)

    # is either string[] or number[]
    if isAnActualArray and baseTypes.indexOf(typebasename) > -1
        return obj.every (item) -> isType item, typebasename

    # is any[]
    if isAnActualArray and typebasename == "any"
        return true

    # is object[]
    if isAnActualArray
        return obj.every (item) -> isType item, "object"

    return false

isRequired = (type) -> type.endsWith "!"

isValid = (obj, schemaObject) ->
    valid = true

    for key in Object.keys schemaObject
        schemaType = schemaObject[key]

        if typeof schemaType == "object"
            valid = valid and isValid(obj[key], schemaType)
        else if isRequired(schemaType) and not obj[key]?
            valid = false
        else if obj[key]?
            valid = valid and isType obj[key], schemaType
    return valid


module.exports =
    isType: isType
    isRequired: isRequired
    isValid: isValid
