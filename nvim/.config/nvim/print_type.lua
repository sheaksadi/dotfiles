local function run()
  local file = io.open("type.txt", "w")
  file:write("test")
  file:close()
end
run()
