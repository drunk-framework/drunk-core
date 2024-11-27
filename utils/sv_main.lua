Drunk.Utils = {}

-- ===========================================================
-- ===================( Player Identifier )===================
-- ===========================================================

Drunk.Utils.ExtractIdentifiers = function(source)
    local identifiers = {}
    local playerIdents = GetPlayerIdentifiers(source)

    for i = 1, #playerIdents do
        local ident = playerIdents[i]
        local colonPosition = string.find(ident, ":") - 1
        local identifierType = string.sub(ident, 1, colonPosition)
        identifiers[identifierType] = ident
    end

    return identifiers
end

Drunk.Utils.ExtractIdentifier = function(source, identifier)
    local identifiers = {}
    local playerIdents = GetPlayerIdentifiers(source)

    for i = 1, #playerIdents do
        local ident = playerIdents[i]
        local colonPosition = string.find(ident, ":") - 1
        local identifierType = string.sub(ident, 1, colonPosition)
        identifiers[identifierType] = ident
    end

    return identifiers[identifier]
end