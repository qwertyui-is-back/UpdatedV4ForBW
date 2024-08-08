shared.options = shared.options or {beta = false, sigma = false}
local STRING = "https://raw.githubusercontent.com/qwertyui-is-back/UpdatedV4ForBW/main"
if shared.options.beta then
    STRING = "https://raw.githubusercontent.com/qwertyui-is-back/UpdatedV4ForBW/beta"
end
shared.beta = shared.options.beta
shared.sigma = shared.options.sigma
return loadstring(game:HttpGet(STRING.."/NewMainScript.lua", true))()