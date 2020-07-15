-- LaTeX ligatures in SILE.
-- Copyright 2020, Fredrick R. Brennan (@ctrlcctrlv)
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
--     Unless required by applicable law or agreed to in writing, software
--     distributed under the License is distributed on an "AS IS" BASIS,
--     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--     See the License for the specific language governing permissions and
--     limitations under the License.
--
-- Version: 2020-07-15
-- Note: This script relies on PR #940 and won't work in SILE <= 0.10.5.

-- ok, so:
-- (/opt/sile/core/parserbits.lua)
-- bits.identifier = (bits.letter + bits.digit)^1 
-- bits.letter = R("az", "AZ") + P"_" -- lolwut, why _ is here
-- bits.digit = R"09"
-- (/opt/share/sile/core/inputs-texlike.lua)
-- ID = lpeg.C(SILE.parserBits.letter * (SILE.parserBits.letter + SILE.parserBits.digit)^0)
-- SILE.inputs.TeXlike.identifier = (ID + lpeg.S":-")^1
-- myID = C(SILE.inputs.TeXlike.identifier + S"{}\\%") / 1
--
-- my interpretation of this as a Lua pattern is:
local build_ident = {begins = '\\', digit = '0-9', letter = 'a-zA-Z_', extravalid = ':-'}
build_ident.first = '[' .. build_ident.letter .. ']'
build_ident.after = '[' .. build_ident.letter .. build_ident.digit .. build_ident.extravalid .. ']'
build_ident.full = build_ident.begins .. build_ident.first .. build_ident.after .. '*'
local identifier = build_ident.full
SU.debug("texmode", "Info: We think an identifier looks like: ", identifier)

-- This list is quite complete. See unicoder.lua
-- Thank you Cumhur "Joomy" Korkut 🥰
local symbols = require("packages/texmode.unicoder")

local combining = {}
local simple_symbols = {}
local ligas = {['------']= {'⸺', "([^\x5c])%-%-%-%-%-%-"},
               ['---']   = {'—', "([^\x5c])%-%-%-"},
               ['--']    = {'–', "([^\x5c])%-%-"},
               ['?`']    = {'¿', "([^\x5c])%?%`"},
               ['!`']    = {'¡', "([^\x5c])%!%`"},
               ["''"]    = {'”', "([^\x5c])%'%'"},
             --['"']     = {'”', "([^\x5c])%\""}, -- see comment @ function dblquotes
               ['``']    = {'“', "([^\x5c])%`%`"},
               ['`']     = {'‘', "([^\x5c])%`"},
               ["'"]     = {'’', "([^\x5c])%'"},
               ['<<']    = {'«', "([^\x5c])%<%<"},
               ['>>']    = {'»', "([^\x5c])%>%>"},
               [',,']    = {'„', "([^\x5c])%,%,"},
               ['<']     = {'‹', "([^\x5c])%<"},
               ['>']     = {'›', "([^\x5c])%>"}}

local TEXLIKECC = function(command, char, name)
    combining[command] = char
end

local TEXLIKESYM = function(command, char, name)
    simple_symbols[command] = char
end

-- To be used by texmode(...)
local define_symbols = function()
    for n, s in pairs(symbols) do
        if not string.match(n, '^[%\\%_%^]') then
            goto continue
        end
        if string.match(n, '^\\') then
            TEXLIKESYM(n:gsub('^\\', ''), utf8.codepoint(s), string.format("U+%08x (%s)", utf8.codepoint(s), s))
            goto continue
        end
        ::continue::
    end
end

-- Accents from https://mirrors.concertpass.com/tex-archive/info/symbols/comprehensive/symbols-a4.pdf , p20 (table 18)
local define_combining_characters = function()
    -- A macro, sorta, thus, capitals. :-)
    TEXLIKECC('"', 0x0308, "Dieresis")
    TEXLIKECC("'", 0x0301, "Acute")
    TEXLIKECC('.', 0x0307, "Dot above")
    TEXLIKECC('=', 0x0304, "Macron")
    TEXLIKECC('^', 0x0302, "Circumflex")
    TEXLIKECC('`', 0x0300, "Grave")
    TEXLIKECC('|', 0x030D, "Vertical line above")
    -- Easter egg, e.g. for old-Spanish style Tagalog orthography
    TEXLIKECC('~~', 0x0360, "Double tilde")
    TEXLIKECC('~', 0x0303, "Tilde")
    TEXLIKECC('b', 0x0331, "Macron below")
    TEXLIKECC('c', 0x0327, "Cedilla")
    -- Why are there two of these ??
    TEXLIKECC('C', 0x030F, "Double grave")
    --------------------------------
    TEXLIKECC('d', 0x0323, "Dot below")
    TEXLIKECC('f', 0x0311, "Inverted breve")
    -- Why are there two of these ??
    TEXLIKECC('G', 0x030F, "Double grave")
    --------------------------------
    TEXLIKECC('h', 0x0309, "Hook above")
    TEXLIKECC('H', 0x030B, "Hungarumlaut")
    TEXLIKECC('k', 0x0328, "Ogonek")
    TEXLIKECC('r', 0x0351, "Ring above")
    TEXLIKECC('t', 0x0361, "Tie above")
    TEXLIKECC('u', 0x0306, "Breve")
    TEXLIKECC('U', 0x030E, "Double vertical line above")
    TEXLIKECC('v', 0x030C, "Háček")
end

local inputfilter = SILE.require("packages/inputfilter").exports
-- not done elsewhere so it doesn't mess up arguments to other commands
local function dblquotes(input, content) 
    return input:gsub('%"', '”')
end -- "Handle double quotes"

local function _utf8iter(s)
    -- below line from https://stackoverflow.com/a/13238257 by @prapin
    return s:gmatch("[%z\1-\127\194-\244][\128-\191]*")
end

local function texmode(options, content)
    local input = options._
    SU.debug("texmode", "Input was \n", input)
    if not input or type(input) ~= "string" then
        SU.warn("You're holding it wrong, please read texmode documentation")
        return
    end
    if not options.nosymbols then define_symbols() end
    if not options.nocombine then define_combining_characters() end
    -- remove most comments
    input = input:gsub('%%[^a-z].-([\r\n][\r\n]?)', '%1')
    local output = ''
    local utf8l = 1
    local bytel = 1
    local maxslen = 0
    for k, v in pairs(simple_symbols) do
        if string.len(k) > maxslen then maxslen = string.len(k) end
    end
    local maxclen = 0
    for k, v in pairs(combining) do
        if string.len(k) > maxclen then maxclen = string.len(k) end
    end
    local maxllen = 0
    for k, v in pairs(ligas) do
        if string.len(k) > maxllen then maxllen = string.len(k) end
    end

    -- how many codes to skip, set dynamically in loop
    local skip = -1
    for code in _utf8iter(input) do
        -- matched symbol
        local smatched = nil
        -- matched combiner and its argument
        local cmatched = nil
        local carg = ''
        -- matched a ligature
        local lmatched = nil

        local j = 0
        if skip > 0 then
            goto continue2
        end

        if string.sub(input, bytel, bytel+string.len("\\notex{")-1) == "\\notex{" then
            local i = string.sub(input, bytel):find('%}')
            local depth = 0
            skip = (bytel+i) - bytel
            output = output .. string.sub(input, bytel, bytel+i-1)
            SU.debug("texmode", string.format("Found \\notex, will skip %d, wrote %s", skip, string.sub(input, bytel, bytel+i-1)))
            goto continue2
        end

        if code == '\\' or code == '_' or code == '^' then
            for jj=maxslen,1,-1 do
                smatched = simple_symbols[string.sub(input, bytel+1, bytel+jj)] 
                if smatched then
                    if string.sub(input, bytel+jj+1, bytel+jj+1):match('[a-zA-Z0-9]') then 
                        smatched = nil
                    end
                    j=jj; break
                end
            end
        end
        if smatched then
            SU.debug("texmode", string.format("Matched %s, will skip %d (%s)", utf8.char(smatched), j, string.sub(input, bytel, bytel+j)))
            output = output .. utf8.char(smatched)
            skip = j+1
            goto continue2
        end

        for jj=maxclen,1,-1 do
            local ctest = string.sub(input, bytel+1, bytel+jj)
            cmatched = combining[ctest]
            if code == '\\' and cmatched then
                local potential = string.sub(input, bytel+jj+1)
                local depth = 0
                local maxdepth = 0
                if potential[1] == '{' then -- okay then, let's get counting!
                    for i = 1, #potential do
                        local c = potential:sub(i, i)
                        if c == '}' then
                            depth = depth - 1
                        elseif c == '{' then
                            depth = depth + 1
                        end
                        carg = carg .. c
                        if depth > maxdepth then maxdepth = depth end
                        if depth == 0 then break end
                    end
                    skip = carg:len() + ctest:len() + 1 -- for \
                    carg = carg:gsub('^%{', ''):gsub('%}$', '')
                    output = output .. carg
                    output = output .. utf8.char(cmatched)
                    SU.debug("texmode", string.format("[C] Matched %s w/arg %s @ depth %d, will skip %d", ctest, carg, maxdepth, skip))
                    break
                end
            end
        end

        for jj=maxllen,1,-1 do
            local test = string.sub(input, bytel, bytel+jj-1)
            --SU.debug("texmode", string.format("Testing %s...", test))
            if ligas[test] then
                output = output .. ligas[test][1]
                skip = string.len(test)
                SU.debug("texmode", string.format("[L] Matched %s, will skip %d", test, skip))
                break
            end
        end
        
        goto continue2

        ::continue2::
        --SU.debug("texmode", string.format("Skip is %d, code is %s", skip, code))
        if skip < 1 then output = output .. code else SU.debug("texmode", string.format("Skipping %s...", code)) end
        if skip <= 0 then  end
        skip = skip - 1
        utf8l = utf8l + 1
        bytel = bytel + string.len(code)
    end
    return output
end

SILE.registerCommand("texmode", function(options, content)
    local output = texmode(options, content)
    if not output then SU.warn("texmode got none!?"); return false end
    SU.debug("texmode", "Output was \n", output)
    -- wth? why is this necessary? without it, if i do just e.g. {..output..}, unichar.lua will crash and AST will be badly formed
    -- nested document env's?? weird.
    local tree = SILE.inputs.TeXlike.docToTree('\\begin{document}'..output..'\\end{document}')
    SILE.process(inputfilter.transformContent(tree, dblquotes))
end, "Enable standard LaTeX ligatures in the environment")

SILE.registerCommand("notex", function(_, content)
    SILE.process(content) 
end, "Disable standard LaTeX ligatures for whatever is inside this")

local newline = function(_, content)
  SILE.settings.temporarily(function()
    SILE.settings.set("typesetter.parseppattern", "\n")
    SILE.doTexlike(" \n\\skip[height=0em]")
  end)
end

SILE.registerCommand("newline", newline)
SILE.registerCommand("\\", newline)
