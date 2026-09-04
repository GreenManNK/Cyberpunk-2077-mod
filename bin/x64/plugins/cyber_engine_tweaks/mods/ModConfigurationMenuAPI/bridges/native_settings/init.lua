if type(package) == "table" and type(package.loaded) == "table" then
  package.loaded["bridges/native_settings/provider"] = nil
end

return require("bridges/native_settings/provider")
