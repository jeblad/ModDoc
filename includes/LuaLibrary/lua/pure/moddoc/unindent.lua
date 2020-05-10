--- Unindent resets the indentation level of mulitline strings.
--  It is useful for multiline strings inside functions and large tables.
--  
--  Lua supports multiline strings in the format `[[\n...\n]]`. In general,
--  Lua does not outdent indented multiline strings out of the box. Though
--  Lua supports variable indentation in multiline strings, custom logic is
--  necessary to reset the string's indentation. This module adopts a
--  flexible approach based on string scanning.
--  
--  Unlike Penlight's `pl.text.dedent` behaviour where every line has the
--  indentation of the first line removed, the line prefixed with the least
--  non-tab whitespace is reset to zero indentation. Thus, the opening line
--  of the string may retain some indentation *if* there are lines of less
--  indentation terminating the string.
--  
--  @script             unindent
--  @license            MIT
--  @author             LMN8
--  @attribution        [[github:kikito|@kikito]] ([[github:kikito/inspect.lua/blob/master/spec/unindent.lua|Github]])
--  @param              {string} str Multiline string indented consistently.
--  @returns            {string} Unindented string.
return function(str)
    str = str:gsub(' +$', ''):gsub('^ +', '') -- remove spaces at start and end
    local level = math.huge
    local minPrefix = ''
    local len
    for prefix in str:gmatch('\n( +)') do
        len = #prefix
        if len < level then
            level = len
            minPrefix = prefix
        end
    end
    return (str:gsub('\n' .. minPrefix, '\n'):gsub('\n$', ''))
end

