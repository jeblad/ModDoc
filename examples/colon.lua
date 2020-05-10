-----
-- Compatibility testing against LDoc.
-- Currently tests colon mode and type modifiers.
-- module: multiple
local multiple = {}

-----
-- Function with return groups.
-- treturn: string Result.
function multiple.mul1() end

-----
-- Function with return and error tag.
-- error: 'message'
-- return: Result.
function multiple.mul2() end

-----
-- Function with multiple error tags.
-- error: 'not found'
--         * When `multiple.lua` is missing in the same directory.
-- error: 'bad format'
--         * When `multiple.lua` contains invalid UTF-8 sequences.
-- return: Result.
function multiple.mul3() end

-----
-- Function with inline return and errors.
-- string: name Person's name.
-- error:[31] 'not a string'
-- error:[34] 'zero-length string'
-- treturn: string Name converted to uppercase.
function multiple.mul4( name )
    if type( name ) ~= 'string' then
        error( 'not a string' )
    end
    if #name == 0 then
        error( 'zero-length string' )
    end
    return name:upper()
end

-----
-- Function that raises an error.
-- string: filename Filename to access.
-- treturn: string Contents of file in UTF-8 charset.
-- raise: 'file not found'
function multiple.mul5( filename ) end

-----
-- First useless function.
-- Optional type specifiers are allowed in this format.
-- Note how these types are rendered!
-- string: name Person's name.
-- int: age Person's age.
-- tab: options As configured in @{person2}.
-- treturn: ?table|string
function multiple.mul6( name, age, options ) end

-----
-- Implicit table can always use `:` notation.
-- table: person2
-- bool: gender Has an official ID number.
-- bool: sex One of `'M'` (male), `'F'` (female) or 'N' (N/A).
-- bool: spouse Has a wife or husband.
person2 = {
    id = true,
    gender = true,
    spouse = true,
}

-----
-- Explicit table in `:` format.
-- table: person3
-- string: surname Person's surname.
-- string: birthdate Person's birthdate.
-- tab: options List of options for person - @{person2}.

-----
-- A function with typed args.
-- Note the the standard tparam aliases, and how the 'opt' and 'optchain'
-- modifiers may also be used. If the Lua function has varargs, then
-- you may document an indefinite number of extra arguments!
-- tparam: ?string|Person name Person's name.
-- int: age Person's age.
-- string:[opt] calender Optional calendar type. Default: `'gregorian'`.
-- int:[optchain] offset Optional birthday offset.
-- treturn: string Birthday month in calendar (usually Gregorian).
function multiple.mul7( name, age, ... ) end

-----
-- Testing `[opt]`.
-- param: one First parameter.
-- param:[opt] two Second parameter.
-- param: three Third parameter.
-- vararg:[optchain] Other parameters after/including fourth parameter.
function multiple.mul8( one, two, three, ... ) end

-----
-- Third useless function.
-- Can always put comments inline, may
-- be multiple.
-- string: name Person's name.
-- int: age Person's age. Must be a positive integer.
function multiple.mul9( name, age ) end

-----
-- Function with single optional argument.
-- param:[opt] three Third parameter. Limitations:
--              * This parameter must be greater than two.
--              * This parameter must be less than four.
--              * Valve cannot count to this number.
function multiple.mul10( one ) end

-----
-- An implicit table.
-- string: name Name of person.
-- int: age Age of person.
person4 = {
    name = '', 
    age = 0,
}

-----
-- An explicit table.
-- Can use tparam aliases in table definitions.
-- table: person4
-- string: name
-- int: age

return multiple