local imgui    = require 'mimgui'
local encoding = require 'encoding'
encoding.default = 'CP1251'
local u8  = encoding.UTF8
local new = imgui.new

local hook = require("monethook")
local cfg  = require('jsoncfg')
local nat  = require('sym')

local xF, xG, xC = nat.xF, nat.xG, nat.xC

local GM = 0x40
local SM, ZT, ZW, SB, DB, VA, FG, AM = 7, 6, 8, 10, 11, 12, 14, 5
local BS, BI, SF = 5, 6, 1
local DM = 2000

local SW, SH = getScreenResolution()
local ws = new.bool(true)

local CN = 'flatped'
local cd = cfg.load({
    s1 = false,
    o1 = true,
    rm = false,
    rs = 2.0,
    pc = { 1.0, 1.0, 1.0, 1.0 },
}, CN)

local s1 = new.bool(cd.s1)
local o1 = new.bool(cd.o1)
local rm = new.bool(cd.rm)
local rs = new.float(cd.rs)
local pc = new.float[4](cd.pc[1], cd.pc[2], cd.pc[3], cd.pc[4])

local function sv()
    cfg.save({
        s1 = s1[0], o1 = o1[0], rm = rm[0], rs = rs[0],
        pc = { pc[0], pc[1], pc[2], pc[3] },
    }, CN)
end

local b1 = xF.new("uint32_t[1]")
local b2 = xF.new("RwColor")
local p2 = false
local q1 = {}
local r2 = {}
local en = true
local du = 0
local wp = false
local wd = false

local function hv(h, s, v)
    h = h % 360
    local c = v * s
    local x = c * (1 - math.abs(((h/60)%2)-1))
    local m = v - c
    local r,g,b = 0,0,0
    if     h<60  then r,g,b=c,x,0
    elseif h<120 then r,g,b=x,c,0
    elseif h<180 then r,g,b=0,c,x
    elseif h<240 then r,g,b=0,x,c
    elseif h<300 then r,g,b=x,0,c
    else              r,g,b=c,0,x end
    return math.floor((r+m)*255+0.5), math.floor((g+m)*255+0.5), math.floor((b+m)*255+0.5)
end

local function ma(r,g,b,a)
    a = a or 255
    return bit.bor(bit.lshift(a,24), bit.lshift(r,16), bit.lshift(g,8), b)
end

local function gc(md)
    if rm[0] then
        local t = os.clock() * rs[0] * 60
        local r,g,b = hv(t+(md or 0), 1.0, 1.0)
        return r, g, b, math.floor(pc[3]*255)
    end
    return math.floor(pc[0]*255), math.floor(pc[1]*255), math.floor(pc[2]*255), math.floor(pc[3]*255)
end

local function rg(st)
    nat.xRG(st, b1)
    return b1[0]
end

local function rt(st, v)
    nat.xRS(st, xC("void*", v))
end

local function sd()
    en = false
    du = os.clock()*1000 + DM
end

local function us()
    local pa = isPauseMenuActive()
    local de = not isPlayerPlaying(playerHandle)

    if pa and not wp then sd() end
    wp = pa

    if de and not wd then sd() end
    wd = de

    if pa or de then
        en = false
        q1 = {}
        return
    end

    if not en and os.clock()*1000 >= du then
        en = true
    end
end

local cm = xF.cast("void*(*)(void*, void*)", function(mp, dp)
    if mp == nil then return mp end
    local m = xC("RpMaterial*", mp)
    local c = xC("RwColor*", dp)

    r2[#r2+1] = { p=m, r=m.color.r, g=m.color.g, b=m.color.b, a=m.color.a, t=m.texture }

    m.color.r = c.r
    m.color.g = c.g
    m.color.b = c.b
    m.color.a = c.a
    m.texture = nil
    return mp
end)

local ca = xF.cast("void*(*)(void*, void*)", function(ap, dp)
    if ap == nil then return ap end
    local a = xC("RpAtomic*", ap)
    local g = a.geometry
    if g ~= nil then
        g.flags = bit.bor(g.flags, GM)
        nat.xGM(g, cm, dp)
    end
    return ap
end)

local function af(cl, r, g, b, a)
    b2.r, b2.g, b2.b, b2.a = r, g, b, a
    nat.xCA(cl, ca, b2)
end

local function rl()
    for i = 1, #r2 do
        local e = r2[i]
        e.p.color.r, e.p.color.g, e.p.color.b, e.p.color.a = e.r, e.g, e.b, e.a
        e.p.texture = e.t
    end
    r2 = {}
end

local function r3()
    us()

    if not en or not o1[0] then
        q1 = {}
        return
    end
    if #q1 == 0 then return end

    p2 = true
    nat.xDA()
    nat.xSA()

    local s1_=rg(SM); local f1=rg(FG); local z1=rg(ZT); local z2=rg(ZW)
    local sb=rg(SB); local db=rg(DB); local va=rg(VA); local am=rg(AM)

    rt(SM, SF); rt(FG, 0); rt(ZT, 0); rt(ZW, 0)
    rt(VA, 1); rt(SB, BS); rt(DB, BI)

    local qq = q1
    q1 = {}

    for _, pd in ipairs(qq) do
        if pd ~= nil then
            local md = (tonumber(xC("intptr_t", pd)) or 0) % 360
            local r,g,b,a = gc(md)
            rt(AM, ma(r,g,b,255))
            if pd.pRwClump ~= nil then
                af(pd.pRwClump, r, g, b, a)
            end
            nat.xPR(xC("CPed*", pd))
            rl()
        end
    end

    rt(SM, s1_); rt(FG, f1); rt(ZT, z1); rt(ZW, z2)
    rt(SB, sb); rt(DB, db); rt(VA, va); rt(AM, am)

    p2 = false
end

local hk
hk = hook.new("void(*)(CPed*)", function(pd)
    if p2 or not en or pd == nil then
        if not en then q1 = {} end
        hk(pd)
        return
    end

    local lp = nat.xFP(0)
    local il = xC("uintptr_t", pd) == xC("uintptr_t", lp)

    if il then
        if s1[0] and pd.pRwClump ~= nil then
            q1[#q1+1] = pd
        else
            hk(pd)
            rl()
            return
        end
        hk(pd)
        return
    end

    if o1[0] then
        q1[#q1+1] = pd
    else
        hk(pd)
    end
end, xC("uintptr_t", xC("void*", nat.xG._ZN4CPed6RenderEv)))

local hf
hf = hook.new("void(*)(void)", function()
    hf()
    r3()
end, xC("uintptr_t", xC("void*", nat.xRF)))

imgui.OnFrame(
    function() return ws[0] end,
    function()
        imgui.SetNextWindowPos(imgui.ImVec2(SW/2, SH/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin(u8'Deprau - Chams', ws, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize)
        if imgui.Checkbox(u8'Chams', o1) then sv() end
        if imgui.Checkbox(u8'Self', s1) then sv() end       
        if imgui.Checkbox(u8'RGB', rm) then sv() end

        imgui.PushItemWidth(150)
        if rm[0] then
            if imgui.SliderFloat(u8'##sp', rs, 0.1, 10.0, u8'Speed: %.1f') then sv() end
        else
            if imgui.ColorEdit4(u8'##cl', pc) then sv() end
        end
        imgui.PopItemWidth()

        imgui.End()
    end
)

function main()
    sampRegisterChatCommand('flatped', function()
        ws[0] = not ws[0]
    end)
    while true do wait(0) end
end
