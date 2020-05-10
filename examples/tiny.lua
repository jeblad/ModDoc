--- "Hello, world" as a Scribunto Lua module.
--  @module         hello_world
--  @usage          {{#invoke:hello world|main}}
local p = {}

--- Entrypoint for Hello world script.
--  @function       p.main
--  @param          {Frame} frame Main frame for function.
--  @return         {string} "Hello world" wrapped in a pre block.
function p.main( frame )
    return frame:extensionTag{ name = 'pre', content = 'Hello, world!' }
end

return p