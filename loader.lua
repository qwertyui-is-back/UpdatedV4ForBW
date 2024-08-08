shared.options = shared.options or {beta = false, sigma = false}
shared.beta = shared.options.beta
shared.sigma = shared.options.sigma
local STRING = "https://raw.githubusercontent.com/qwertyui-is-back/UpdatedV4ForBW/main"
if shared.beta then
    STRING = "https://raw.githubusercontent.com/qwertyui-is-back/UpdatedV4ForBW/beta"
end
return loadstring(game:HttpGet(STRING.."/NewMainScript.lua", true))()