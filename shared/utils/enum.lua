local M <const> = {}

---@param enum table
---@param value any
function M.isValidEnumValue(enum, value)
    for _, v in pairs(enum) do
        if v == value then
            return true
        end
    end

    return false
end

return M
