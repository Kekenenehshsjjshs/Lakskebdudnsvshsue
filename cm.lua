local ffi = require("ffi")
local gta = ffi.load("GTASA")

ffi.cdef[[
    void _Z12AND_OpenLinkPKc(const char* link);
]]

local function openLink(url)
    gta._Z12AND_OpenLinkPKc(url)
end

function main()
    repeat wait(100) until isSampAvailable()

    wait(1000)

    openLink("https://youtu.be/-k3ZVxub_M4?si=WzzqBLwbUjUVhzAw")

    while true do
        wait(0)
    end
end
