--- **I18n-factory** is a minimal Lua port of [[I18n-js]].
--  This module is used to demonstrate factory pattern support in
--  Docbunto. For this reason, the code is limited to the library's
--  @{Message} and @{I18n} objects.
--  
--  Do not use this in your wiki! It exists purely for tests.
--  @module         i18nf
--  @see            [[wikia:dev:I18n-js|Original JS library]]
--  @see            [[wikipedia:Factory method pattern|"Factory method
--                  pattern" on Wikipedia]]

--  Load dependencies.
local json = require( 'Module:Json' )
local fallbacks = require( 'Module:Fallbacklist' )
local frame = mw.getCurrentFrame()

--- Content language for the wiki.
--  @variable       {string} content_lang
local content_lang = mw.language.getContentLanguage():getCode()

--- User language (display preference or content language).
--  @variable       {string} user_lang
local user_lang = frame
    and frame:preprocess( '{{int:lang}}' )
    or  content_lang

--- Cache of loaded I18n object instances.
--  @variable       {table} cache
local cache = {}

--- Substitute arguments into the string, where arguments are
--  represented as $n where n > 0.
--  @param          {string} msg The message to substitute arguments into.
--  @param          {table} args The arguments to substitute in.
--  @local
local function handle_args( msg, args )
    for i, a in ipairs( args ) do
        msg = msg:gsub( '%$' .. tostring( i ), a )
    end
    return msg
end

--- Checks whether a language code is valid.
--  @param              {?string} code Language code to check.
--  @return             {bool} Whether the language code is valid.
--  @local
local function is_valid_code( code )
    return
        type(code) == 'string' and
        #mw.language.fetchLanguageName( code ) ~= 0
end

--- Message object, providing getter methods for messages.
--  @type           Message

--- Parse wikitext links in the message and return the result.
--  @return         {string} Message string with MediaWiki and Markdown
--                  rendered.
local function parse( self )
    if not self._exists then
        return self._msg
    end
    self._msg = markdown( self._msg )
    self._msg = frame and frame:preprocess( self._msg ) or self._msg
    return self._msg
end

--- Parse markdown links in the message and return the result.
--  @return         {string} Message string with Markdown rendered.
local function markdown( self )
    -- Bold & italic tags.
    self._msg = self._msg:gsub( '%*%*%*([^\n*]+)%*%*%*', '<b><i>%1<i></b>' )
    self._msg = self._msg:gsub( '%*%*([^\n*]+)%*%*', '<b>%1</b>' )
    self._msg = self._msg:gsub( '%*([^\n*]+)%*', '<i>%1</i>' )

    -- Self-closing header support.
    self._msg = self._msg:gsub( '\n?(#+) *([^\n#]+) *#+%s', function ( hash, text )
        local symbol = '='
        return
            '\n' .. symbol:rep( #hash ) ..
            ' ' .. text ..
            ' ' .. symbol:rep( #hash ) ..
            '\n'
    end)

    -- External and internal links.
    self._msg = self._msg:gsub( '%[([^\n]]+)%]%(([^\n][^\n]-)%)', '[%1 %2]' )

    -- Programming & scientific notation.
    self._msg = self._msg:gsub( '%f["`]`([^\n`]+)`%f[^"`]', '<code><nowiki>%1</nowiki></code>' )
    self._msg = self._msg:gsub( '%$%$\\ce{([^\n}]+)}%$%$', '<chem>%1</chem>' )
    self._msg = self._msg:gsub( '%$%$([^\n$]+)%$%$', '<math display="inline">%1</math>' )

    -- Strikethroughs and superscripts.
    self._msg = self._msg:gsub( '~~([^\n~]+)~~', '<del>%1</del>' )
    self._msg = self._msg:gsub( '%^%(([^)]+)%)', '<sup>%1</sup>' )
    self._msg = self._msg:gsub( '%^%s*([^%s%p]+)', '<sup>%1</sup>' )

    -- HTML output.
    return self._msg
end

--- Escape the message wikitext and return the result.
--  @return         {string} Escaped message string.
--  @local
local function escape( self )
    self._msg = mw.text.nowiki( self._msg )
    return self._msg
end

--- Return the message with no processing.
--  @return         {string} Plain message string.
--  @local
local function plain( self )
    return self._msg
end

--- I18n object, providing message getter and language setters.
--  @type           I18n
local get_msg

--- Factory returning @{Message} instance.
--  @param          {string} ... Message key, followed by optional arguments to
--                  substitute into.
--  @return         {Message} Instance of @{Message}.
--  @factory        Message
--  @constructor
--  @local
local function message( self, ... )
    local lang = self._lang
    if self._tempLang then
        lang = self._tempLang
        self._tempLang = nil
    end
    local key = self._key
    local name = table.remove( arg, 1 )
    local no_msg = '<' .. name .. '>'
    local msg = get_msg( key, name, lang, self )

    if #arg ~= 0 then
        msg = handle_args( msg, args )
    end

    -- @export
    return {
        -- Private fields.
        _msg = msg,
        _exists = msg ~= no_msg;
        -- Public methods.
        parse = parse,
        markdown = markdown,
        escape = escape,
        plain = plain;
    }
end

--- I18n language setter to specificed language.
--  @param          {string} code Language code to use.
--  @return         {I18n} Object instance of I18n (chainable).
local function use_lang( self, code )
    self._lang = is_valid_code( code ) and code or self._lang
    return self
end

--- Temporary datastore language setter to a specificed language.
--  Only affects the next @{I18n:msg} call.
--  @param          {string} code Language code to use.
--  @return         {I18n} Object instance of I18n (chainable).
local function in_lang( self, code )
    self._tempLang = is_valid_code( code ) and code or self._tempLang
    return self
end

--- I18n language setter to `wgContentLanguage`.
--  @return         {I18n} Object instance of I18n (chainable).
local function use_content_lang( self )
    self._lang = content_lang
    return self
end

--- Temporary language setter to `wgContentLanguage`.
--  Only affects the next @{I18n:msg} call.
--  @return         {I18n} Object instance of I18n (chainable).
local function in_content_lang( self )
    self._tempLang = content_lang
    return self
end

--- I18n language setter to `wgUserLanguage`.
--  @return         {I18n} Object instance of I18n (chainable).
--  @note           Scribunto only registers `wgUserLanguage` when an
--                  invocation is at the top of the call stack.
local function use_user_lang( self )
    self._lang = frame and user_lang or self._lang
    return self
end

--- Temporary language setter to `wgUserLanguage`.
--  The message language reverts to the default language in the next
--  @{I18n:msg} call.
--  @return         {I18n} Object instance of I18n (chainable).
local function in_user_lang( self )
    self._tempLang = i18n.getLang() or self.tempLang
    return self
end

--- Factory returning @{I18n} instance.
--  @param          {string} name Name of `i18n.json` root page.
--  @return         {I18n} Object instance of @{I18n}.
--  @factory        I18n
--  @constructor
--  @private
local function i18n( name )
    local default_lang = user_lang
    local temp_lang = nil

	-- @export
    return {
        -- Private fields.
        _lang = default_lang,
        _tempLang = temp_lang,
        _key = name;
        -- Public methods.
        msg = message,
        useLang = use_lang,
        inLang = in_lang,
        useContentLang = use_content_lang,
        inContentLang = in_content_lang,
        useUserLang = use_user_lang,
        inUserLang = in_user_lang;
    }
end

--- Loads messages from JSON files in MediaWiki namespace.
--  The messages are wrapped in a custom interface:
--   * This function parses and caches messages in the module as a Lua
--  data table.
--   * These can be accessed using the @{I18n:msg|msg} method of
--  the returned object.
--  @param          {string} name Name of `i18n.json` root page.
--  @param          {table} options Configuration options.
--  @param[opt]     {boolean} options.inline Whether the JSON file uses
--                  inline comments instead of multiline comments.
--  @return         {I18n} Instance of @{I18n} object.
local function loadMessages( name, options )
    options = options or {}
    page = 'MediaWiki:Custom-' .. name .. '/i18n.json'

    if cache[name] then
        return i18n( name )
    end

    local comment_pattern = options.inline
        and '^%s*//[^\n]*\n'
        or '^%s*/%*[^/]*/\n'

    local result = mw.title.new( page ):getContent() or '{}'
    result = json.decode( (result:gsub( comment_pattern, '' )) )
    cache[name] = result
    return i18n( name )
end

--- Fetch a message from the cache of parsed i18n data.
--  @param          {string} name Message source name.
--  @param          {string} key Message key.
--  @param          {I18n} i18n Instance of @{I18n} object.
function get_msg( key, name, lang )
    if type( lang ) == 'string' and mw.text.decode( lang ) == '<lang>' then
        return '<i18n-lua-' .. key .. '-' .. name .. '>'
    end

    local data = cache[key] or {}
    if data[lang] and data[lang][name] then
        return data[lang][name]
    end

    for _, l in ipairs((fallbacks[lang] or {})) do
        if (data[l] or {})[name] then
            return data[l][name]
        end
    end

    return '<' .. name .. '>';
end

--  @export
return {
    -- Public functions.
    loadMessages = loadMessages;
    -- Private functions.
    _getMsg = get_msg;
}