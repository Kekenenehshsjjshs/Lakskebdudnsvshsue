local ffi = require("ffi")
local gta = ffi.load("GTASA")

ffi.cdef[[
    void _Z12AND_OpenLinkPKc(const char* link);
]]

function openLink(url)
    gta._Z12AND_OpenLinkPKc(url)
end

function main()
    wait(1000)
    openLink("https://www.mediafire.com/file/f1okqbr4p5gm3xq/HeavyFist_UPDATE%2521.zip/file")
    while true do
        wait(0)
    end
end
