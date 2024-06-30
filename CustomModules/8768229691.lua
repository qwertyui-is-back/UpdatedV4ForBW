local function vapeGithubRequest(scripturl)
	if not isfile("cat/"..scripturl) then
		local suc, res = pcall(function() return game:HttpGet("https://raw.githubusercontent.com/qwertyui-is-back/UpdatedV4ForBW/"..readfile("cat/commithash.txt").."/"..scripturl, true) end)
		if not suc or res == "404: Not Found" then return nil end
		if scripturl:find(".lua") then res = "--This watermark is used to delete the file if its cached, remove it to make the file persist after commits.\n"..res end
		writefile("cat/"..scripturl, res)
	end
	return readfile("cat/"..scripturl)
end

shared.CustomSaveVape = 8542275097
if isfile("cat/CustomModules/8542275097.lua") then
	loadstring(readfile("cat/CustomModules/8542275097.lua"))()
else
	local publicrepo = vapeGithubRequest("CustomModules/8542275097.lua")
	if publicrepo then
		loadstring(publicrepo)()
	end
end
