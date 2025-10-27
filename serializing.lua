local M = {}
M.currentFile = nil

function M:setFile(file)
    self.currentFile = tostring(file)
end

function M:unsetFile()
    self.currentFile = nil
end

function M:resetFile()
    love.filesystem.write(self.currentFile, "")
end

function M:setCleanFile(file)
    self.currentFile = file
    M:resetFile(file)
end

function M:serialize(o)
    local tab = "    "
    if type(o) == 'number' then
        love.filesystem.append(self.currentFile, o)
    elseif type(o) == 'string' then
        love.filesystem.append(self.currentFile, string.format("%q", o))
    elseif type(o) == 'table' then
        love.filesystem.append(self.currentFile, "{\n")
        for k, v in pairs(o) do
            love.filesystem.append(self.currentFile, tab..k.." = ")
            self:serialize(v)
            love.filesystem.append(self.currentFile, ",\n")
        end
        love.filesystem.append(self.currentFile, "}\n")
    else 
        error('cannot serialize a '..type(o))
    end
end

function M:deserialize(file)
    return love.filesystem.read(file or self.currentFile)
end

function M:translate(o)
    return assert(load("return "..o))()
end

--[[
function M:deserializeAndTranslate()
    local o_data = M:deserialize()
    local o = M:translate(o_data)
    return o
end
]]

return M