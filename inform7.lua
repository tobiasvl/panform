Writer = pandoc.scaffolding.Writer

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

local insidequote = false

Writer.Inline.Str = function(str)
	if (str.text:find("^\"") or str.text:find("\"$")) and not str.text:find("^\"[^\"]*\"$") then
		insidequote = not insidequote
	end
	return str.text
end

Writer.Inline.Quoted = function(str)
	insidequote = true
	local result = Writer.Inlines(str.content)
	insidequote = false
	return "\"" .. result .. "\""
end

Writer.Inline.Code = function(code)
	if insidequote then
		return "[" .. code.text .. "]"
	else
		return "(- " .. code.text .. " -)"
	end
end

Writer.Inline.Strikeout = function(strike)
	return "[" .. Writer.Inlines(strike.content) .. "]"
end

Writer.Block.BlockQuote = function(bq)
	return "[\n" .. Writer.Blocks(bq.content) .. "\n]"
end

-- TODO indent each line
Writer.Block.CodeBlock = function(code)
	local after = ""
	if code.attr.classes[1] == "preform" then
		after = " in the Preform grammar"
	end

	return "Include (-\n" .. code.text .. "\n-)" .. after .. "."
end

local levels = {
	"Volume",
	"Book",
	"Part",
	"Chapter",
	"Section"
}

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



Reader = {}
setmetatable(Reader, Reader)

Reader.__call = function(input, opts)
end

function Reader(input, opts)
    return pandoc.Doc({pandoc.Str(input)})
end

