if type(package) == "table" and type(package.loaded) == "table" then
  package.loaded["bridges/ms/provider"] = nil
end

return require("bridges/ms/provider")
