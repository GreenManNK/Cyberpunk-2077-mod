if type(package) == "table" and type(package.loaded) == "table" then
  package.loaded["bridges/rcf/provider"] = nil
end

return require("bridges/rcf/provider")
