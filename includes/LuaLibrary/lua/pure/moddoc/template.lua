-- <nowiki>
--------------------------------------------------------------------------------
-- A feature-packed example generator for brace-based wikitext.
--
-- @author [[User:DarthKitty]]
-- @author [[User:Speedit]]
-- @version 0.6.2
--
-- @TODO Extract CSS to stylesheet; transition from data-attributes to classes.
-- @TODO Modify `p.transclusion` to handle non-template namespaces.
-- @TODO Consider adding i18n for error messages, flags, &c.
-- @TODO Consider adding generator(s?) for magic words and parser functions.
--------------------------------------------------------------------------------
local p = {}
local getArgs = require("Dev:Arguments").getArgs
local userError = require("Dev:User error")
local yesno = require("Dev:Yesno")

--------------------------------------------------------------------------------
-- Parses a parameter to get its components: its name (optional), and either its
-- value or its description (but not both).
--
-- @param {string} param
--     A parameter.
-- @returns {table}
--     The components of a parameter.
--------------------------------------------------------------------------------
local function parseParam(param)
    local tmp = param
    local name, value, description

    -- the parameter's name is anything to the left of the first equals sign;
    -- the equals sign can be escaped, for wikis that don't have [[Template:=]]
    if tmp:find("=") or tmp:find(mw.text.nowiki("=")) then
        name, tmp = tmp
            :gsub(mw.text.nowiki("="), "=", 1)
            :match("^(.-)%s*=%s*(.-)$")
    end

    -- if the remaining text is wrapped in matching quotes, then it's a literal
    -- value; otherwise, it's a description of the parameter
    local first = tmp:sub(1, 1)
    local last = tmp:sub(-1)

    if (first == "\"" and last == "\"") or (first == "'" and last == "'") then
        value = tmp:sub(2, -2)
    elseif tmp == "" then
        description = "..." -- the description cannot be an empty string
    else
        description = tmp
    end

    return {
        name = name,
        value = value,
        description = description
    }
end

--------------------------------------------------------------------------------
-- The heart of the module. Transforms a list of parameters into wikitext
-- syntax.
--
-- @param {string} mode
--     Which kind of brace-based wikitext we're dealing with.
-- @param {string} opener
--     Text to insert between the two left-braces and the first parameter.
-- @param {table|nil} params
--     A sequentual table of parameters.
-- @param {table|nil} options
--     A table with configuration flags.
-- @returns {string}
--     A blob of wikitext describing any brace-based syntax.
--------------------------------------------------------------------------------
local function builder(mode, opener, params, options)
    if type(opener) ~= "string" then
        error("no opener specified", 3)
    end

    if params == nil then
        params = {}
    elseif type(params) ~= "table" then
        error("invalid parameter list", 3)
    end

    if options == nil then
        options = {}
    elseif type(options) ~= "table" then
        error("invalid configuration options", 3)
    end

    local html = mw.html.create("code")
        :attr("data-t-role", "wrapper")
        :attr("data-t-mode", mode)
        :css("all", "unset")
        :css("font-family", "monospace")
        :tag("span")
            :attr("data-t-role", "opener")
            :wikitext(mw.text.nowiki("{"):rep(2))
            :wikitext(opener)
            :done()

    if options.multiline then
        html:attr("data-t-multiline", "data-t-multiline")
    end

    for i, param in ipairs(params) do
        if type(param) ~= "string" then
            error("invalid entry #" .. i .. " in parameter list", 3)
        end

        local components = parseParam(param)
        local paramHtml = html:tag("span")
            :attr("data-t-role", "parameter")
            :attr("data-t-index", i)
            :wikitext(mw.text.nowiki("|"))

        if options.multiline then
            paramHtml:css("display", "block")
        end

        if components.name then
            paramHtml:tag("span")
                :attr("data-t-role", "parameter-name")
                :css("font-weight", "bold")
                :wikitext(components.name)

            paramHtml:wikitext(" = ")
        end

        if components.value then
            paramHtml:tag("span")
                :attr("data-t-role", "parameter-value")
                :wikitext(components.value)
        end

        if components.description then
            paramHtml:tag("span")
                :attr("data-t-role", "parameter-description")
                :css("opacity", "0.65")
                :wikitext(mw.text.nowiki("<"))
                :wikitext(components.description)
                :wikitext(mw.text.nowiki(">"))
        end
    end

    html:tag("span")
        :attr("data-t-role", "closer")
        :wikitext(mw.text.nowiki("}"):rep(2))

    return tostring(html)
end

--------------------------------------------------------------------------------
-- Generator for transclusion syntax, e.g. {{foo}}.
--
-- @param {string} title
--     The name of the template to link to, without the namespace prefix.
-- @param {table|nil} params
--     A sequentual table of parameters.
-- @param {table|nil} options
--     A table with configuration flags.
-- @returns {string}
--     A blob of wikitext describing a template.
--------------------------------------------------------------------------------
function p.transclusion(title, params, options)
    if type(title) ~= "string" or title == "" then
        error("no title specified", 2)
    end

    return builder(
        "transclusion",
        "[[Template:" .. title .. "|" .. title .. "]]",
        params,
        options
    )
end

--------------------------------------------------------------------------------
-- Generator for invocation syntax, e.g. {{#invoke:foo|bar}}.
--
-- @param {string} title
--     The name of the module to link to, without the namespace prefix.
-- @param {string} func
--     The name of the function to call.
-- @param {table|nil} params
--     A sequentual table of parameters.
-- @param {table|nil} options
--     A table with configuration flags.
-- @returns {string}
--     A blob of wikitext describing a module.
--------------------------------------------------------------------------------
function p.invocation(title, func, params, options)
    if type(title) ~= "string" or title == "" then
        error("no module specified", 2)
    end

    if type(func) ~= "string" or func == "" then
        error("no function specified", 2)
    end

    local link = "[[Module:" .. title .. "|" .. title .. "]]"

    return builder(
        "invocation",
        "#invoke:" .. link .. mw.text.nowiki("|") .. func,
        params,
        options
    )
end

--------------------------------------------------------------------------------
-- Entry point from the wikitext side. Determines which generator to use based
-- on the provided arguments.
--
-- @param {table} wikitext
--     A wikitext representation of a template call.
-- @returns {string}
--     A blob of wikitext describing any brace-based syntax.
--------------------------------------------------------------------------------
function p.main(wikitext, options)
    local args = mw.text.split(wikitext, '|')
    local mode, minimumArity

    if options.invocation then
        mode = "invocation"
        minimumArity = 2
    else
        mode = "transclusion"
        minimumArity = 1
    end

    local params = {}

    -- a dynamically-generated list of arguments to the generator
    -- required arguments are inserted before `params` and `options`
    local varargs = {params, options}

    for i, value in ipairs(args) do
        if i <= minimumArity then
            -- pass the first few values directly to the generator
            -- these are used to calculate the opener
            table.insert(varargs, i, value)
        else
            -- put the remaining values in a table, and pass it to the generator
            -- these are shown as parameters in the resulting wikitext
            params[#params + 1] = value
        end
    end

    local success, response = pcall(p[mode], unpack(varargs))

    return success and response or userError(response)
end

return p