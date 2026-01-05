Writer.

A Pandoc writer.

@h Setup.

@ First, we avoid some boilerplate using the //scaffolding -> https://pandoc.org/lua-filters.html#module-pandoc.scaffolding// module.
=
Writer = pandoc.scaffolding.Writer

@ Then we detect whether we are writing an Inform 7 story or extension.
=
for _, i in ipairs(PANDOC_STATE.input_files) do
	local ext = pandoc.List(i:gmatch "[^%.]+"):at(-2)
	if ext == "ni" or ext == "i7" then i7_story = true end
	if ext == "i7x" then i7_ext = true end
end

Writer.Extensions = {
	smart = false,
	mark = true,
	alert = true,
	lists_without_preceding_blankline = true,
}

@ Then we come to the parsing.

@h Plain content.

What it says on the tin.

=
Writer.Block.Para = function(para)
	--return Writer.Inlines(para.content)
	return {Writer.Inlines(para.content)}
end

Writer.Inline.Space = function(str)
	return " "
end

Writer.Block.Plain = function(p)
	return Writer.Inlines(p.content)
end

Writer.Inline.SoftBreak = function(str)
	return "\n"
end

@h Strings.

We keep track of whether we are inside a quote, to handle bracket syntax.
=
local insidequote = false

Writer.Inline.Str = function(str)
	if (str.text:find("^\"") or str.text:find("\"$")) and not str.text:find("^\"[^\"]*\"$") then
		insidequote = not insidequote
	end
	return str.text
end

@h Quoted.

And this does the same, but for quoted text in a document with smart quotes.
(It's best to read in Inform 7 source with smart quotes disabled, but we
support it anyway.)
=
Writer.Inline.Quoted = function(str)
	insidequote = true
	local result = Writer.Inlines(str.content)
	insidequote = false
	return "\"" .. result .. "\""
end

@h Inline code.

We use inline code spans for two things: Text substitutions (inside quotes) and
Inform 6 code (outside quotes).
=
Writer.Inline.Code = function(code)
	if insidequote then
		return "[" .. code.text .. "]"
	else
		return "(- " .. code.text .. " -)"
	end
end

@h Comments.

Inform 7 comments are written as square brackets. We can support a few different
markup elements as comments, like strikeout/strikethrough (for code that's
commented out) and block quotes (for explanatory comments).

=
Writer.Inline.Strikeout = function(strike)
	return "[" .. Writer.Inlines(strike.content) .. "]"
end

Writer.Block.BlockQuote = function(bq)
	return "[\n" .. Writer.Blocks(bq.content) .. "\n]"
end

@h Code blocks.

Code blocks in Inform 7 are either included Inform 6 code, or Preform grammar.

=
-- TODO indent each line
Writer.Block.CodeBlock = function(code)
	local after = ""
	if code.attr.classes[1] == "preform" then
		after = " in the Preform grammar"
	end

	return "Include (-\n" .. code.text .. "\n-)" .. after .. "."
end

@h Headings.

Markdown has 6 heading levels. Inform 7 has 5, but it also has a story title.

A mnemonic to remember the levels is "Very Bad People Choose Sin".

=
local levels = {
	"Volume",
	"Book",
	"Part",
	"Chapter",
	"Section"
}

@

Then we convert the headings, keeping track of how many top-level headings we
have seen, to avoid converting a document with more than one story title.

=
local h1 = 0

Writer.Block.Header = function(h)
	if h.level == 1 then
	    h1 = h1 + 1
	    if i7_story then
			if h1 == 1 then
				-- TODO If title is not wrapped in quotes
				return "\"" .. pandoc.utils.stringify(h.content) .. "\""
			else
				error("Only one top-level heading allowed in Inform 7 story files (it should be used for the story title and author).")
			end
		elseif i7_ext then
			if h1 == 1 then
				return Writer.Inlines(h.content) .. " begins here."
			elseif h1 == 1 then
				return string.rep("-", 4) .." Documentation " .. string.rep("-", 4)
			else
				error("Only two top-level headings allowed in Inform 7 extensions (it should be used for the extension title and, optionally, the documentation header).")
			end
	    end
	end
	return levels[h.level - 1] .. " - " .. Writer.Inlines(h.content)
end

@h Lists.

Since Markdown and Pandoc don't preserve indents, we use lists to represent
indented blocks.

=
local indent_level = 0

Writer.Block.BulletList = function(bl)
	local result = ""
	indent_level = indent_level + 1
	for i, item in ipairs(bl.content) do
		result = result .. string.rep("\t", indent_level) .. Writer.Blocks(item)
	end
	indent_level = indent_level - 1
	return result .. "\n"
end

Writer.Block.OrderedList = Writer.Block.BulletList

@

And then we have to make sure that Pandoc does not insert extra blank lines
before lists.

=
Writer.Blocks = function(blocks, sep)
	sep = sep or pandoc.layout.blankline
	local result = ""
	for i, block in ipairs(blocks) do
		local sep_foo = sep
		if i == #blocks or ((block.tag == "Para" or block.tag == "Plain") and blocks[i+1] and (blocks[i+1].tag == "BulletList" or blocks[i+1].tag == "OrderedList")) then
			sep_foo = "\n"
		end
		result = result .. Writer.Block(block) .. sep_foo
	end
	return result
end


