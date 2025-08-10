-- pluralize.lua
--
-- A 100% pure Lua port of the 'pluralize' JavaScript library.
-- This version has NO external dependencies and uses native Lua string patterns.
-- The rule sets have been significantly expanded based on analysis of major
-- open-source pluralization libraries.

local pluralize = {}

local pluralRules = {}
local singularRules = {}
local uncountables = {}
local irregularPlurals = {}
local irregularSingles = {}

---
-- Replicates the case of an original word onto a new word token by using
-- the original word as a "case template". This correctly handles all cases,
-- including `camelCase` and `PascalCase`.
--
-- @param word (string) The original word with the desired case (e.g., "allBots").
-- @param token (string) The new, transformed word (e.g., "allbot").
-- @return (string) The token with the case of the original word restored (e.g., "allBot").
local function restoreCase(word, token)
	-- If words are identical, no work needed.
	if word == token then
		return token
	end

	-- Fast path for the most common cases.
	if word == word:lower() then
		return token:lower()
	end
	if word == word:upper() then
		return token:upper()
	end

	-- Advanced path for mixed-case words (camelCase, PascalCase, etc.)
	-- We build the result character by character.
	local result_chars = {}
	for i = 1, #token do
		local original_char = word:sub(i, i)

		-- Check if the character at the same position in the original word was uppercase.
		-- The check for original_char ~= "" handles cases where the new word is longer than the old one.
		if original_char ~= "" and original_char == original_char:upper() then
			table.insert(result_chars, token:sub(i, i):upper())
		else
			table.insert(result_chars, token:sub(i, i):lower())
		end
	end

	return table.concat(result_chars)
end

---
-- Replaces a word using a Lua string pattern rule.
-- @param word (string) The word to perform replacement on.
-- @param rule (table) A table containing { pattern, replacement }.
-- @return (string|nil) The replaced word, or nil if the rule didn't match.
local function replace(word, rule)
	local pattern = rule[1]
	local replacement = rule[2]

	local new_word, matches = word:gsub(pattern, replacement)
	if matches > 0 then
		return new_word
	end

	return nil
end

---
-- Applies a list of rules to a word to transform it.
-- @param token (string) The lowercased word for matching.
-- @param word (string) The original cased word for the final result.
-- @param rules (table) The list of rules to apply.
-- @return (string) The transformed word.
local function sanitizeWord(token, word, rules)
	if #token == 0 or uncountables[token] then
		return word
	end

	for i = #rules, 1, -1 do
		local rule = rules[i]
		local result = replace(token, rule)
		if result then
			return restoreCase(word, result)
		end
	end

	return word
end

---
-- Creates a function that will replace a word.
-- @param replaceMap (table) Map of direct singular->plural or plural->singular replacements.
-- @param keepMap (table) Map of words that should not be changed (e.g. irregular plurals).
-- @param rules (table) The list of pattern-based rules.
-- @return (function) A function that takes a word and returns the transformed word.
local function replaceWord(replaceMap, keepMap, rules)
	return function(word)
		local token = word:lower()

		if keepMap[token] then
			return restoreCase(word, token)
		end

		if replaceMap[token] then
			return restoreCase(word, replaceMap[token])
		end

		return sanitizeWord(token, word, rules)
	end
end

---
-- Creates a function to check if a word is plural or singular.
-- @return (function) A function that takes a word and returns true or false.
local function checkWord(replaceMap, keepMap, rules)
	return function(word)
		local token = word:lower()

		if keepMap[token] then
			return true
		end
		if replaceMap[token] then
			return false
		end

		local sanitized = sanitizeWord(token, token, rules)
		return sanitized == token
	end
end

---
-- Pluralize or singularize a word based on the passed in count.
-- @param word (string) The word to pluralize.
-- @param count (number) How many of the word exist.
-- @param inclusive (boolean) Whether to prefix with the number (e.g. 3 ducks).
-- @return (string) The pluralized word.
function pluralize.pluralize(word, count, inclusive)
	local pluralized = count == 1 and pluralize.singular(word) or pluralize.plural(word)
	return (inclusive and tostring(count) .. " " or "") .. pluralized
end

---
-- Add a pluralization rule to the collection.
-- @param rule (string) The Lua pattern.
-- @param replacement (string) The replacement string.
function pluralize.addPluralRule(rule, replacement)
	table.insert(pluralRules, { rule, replacement })
end

---
-- Add a singularization rule to the collection.
-- @param rule (string) The Lua pattern.
-- @param replacement (string) The replacement string.
function pluralize.addSingularRule(rule, replacement)
	table.insert(singularRules, { rule, replacement })
end

---
-- Add an uncountable word rule.
-- @param word (string) The word to add.
function pluralize.addUncountableRule(word)
	-- If it's a pattern, add it to the plural and singular rules to be left alone.
	if not word:find("^%a+$") then
		pluralize.addPluralRule(word, "%0")
		pluralize.addSingularRule(word, "%0")
	else
		uncountables[word:lower()] = true
	end
end

---
-- Add an irregular word definition.
-- @param single (string) The singular form.
-- @param plural (string) The plural form.
function pluralize.addIrregularRule(single, plural)
	plural = plural:lower()
	single = single:lower()
	irregularSingles[single] = plural
	irregularPlurals[plural] = single
end

-- Irregular rules (expanded for more comprehensive coverage).
for _, rule in ipairs({
	-- Pronouns and Be-Verbs
	{ "I", "we" },
	{ "me", "us" },
	{ "he", "they" },
	{ "she", "they" },
	{ "them", "them" },
	{ "myself", "ourselves" },
	{ "yourself", "yourselves" },
	{ "itself", "themselves" },
	{ "herself", "themselves" },
	{ "himself", "themselves" },
	{ "themself", "themselves" },
	{ "is", "are" },
	{ "was", "were" },
	{ "has", "have" },
	{ "this", "these" },
	{ "that", "those" },
	-- Nouns
	{ "person", "people" },
	{ "man", "men" },
	{ "woman", "women" },
	{ "ox", "oxen" },
	{ "axe", "axes" },
	{ "foot", "feet" },
	{ "goose", "geese" },
	{ "tooth", "teeth" },
	{ "die", "dice" },
	{ "child", "children" },
	{ "corpus", "corpora" },
	{ "genus", "genera" },
	{ "sex", "sexes" },
	{ "move", "moves" },
	{ "quiz", "quizzes" },
	{ "testis", "testes" },
	-- Common technical/loan words
	{ "atlas", "atlases" },
	{ "octopus", "octopuses" }, -- Or octopodes/octopi, but 'octopuses' is most common
	{ "virus", "viruses" },
	{ "opus", "opuses" },
	{ "mythos", "mythoi" },
	{ "penis", "penises" },
	-- Words ending in -o
	{ "echo", "echoes" },
	{ "dingo", "dingoes" },
	{ "volcano", "volcanoes" },
	{ "tornado", "tornadoes" },
	{ "torpedo", "torpedoes" },
	-- Other common irregulars
	{ "passerby", "passersby" },
	{ "thief", "thieves" },
	{ "valve", "valves" },
	{ "canvas", "canvases" },
}) do
	pluralize.addIrregularRule(rule[1], rule[2])
end

-- Pluralization rules (expanded and reordered for accuracy).
for _, r in ipairs({
	-- Rules for words that don't change
	{ "s$", "s" },
	{ "eau$", "%0" }, -- From 'eaux' in singular rules
	{ "(.*)ese$", "%1ese" }, -- Chinese, Japanese
	-- Specific Irregular Patterns not in the irregular map
	{ "^(m)ouse$", "%1ice" },
	{ "^(l)ouse$", "%1ice" },
	{ "^(ax)is$", "%1es" },
	{ "^(test)is$", "%1es" },
	{ "(octop)us$", "%1uses" },
	{ "(vir)us$", "%1uses" },
	{ "(alias|status)$", "%1es" },
	{ "(buffal|tomat|potat|her)o$", "%1oes" },
	-- Nouns ending in -f or -fe
	{ "([lr])f$", "%1ves" }, -- leaf, life, wife
	{ "(kni|li|wi)fe$", "%1ves" },
	{ "(thie)f$", "%1ves" },
	{ "(sel|shel|wol)f$", "%1ves" },
	-- Nouns ending in -y
	{ "([bcdfghjklmnpqrstvwxyz])y$", "%1ies" },
	{ "(qu)y$", "%1ies" },
	-- Standard -es endings
	{ "(ss|sh|ch|x|z)$", "%1es" },
	-- Latin/Greek endings
	{ "(matr|vert|ind)(ix|ex)$", "%1ices" },
	{ "(app)endix$", "%1endices" },
	{ "(alumn|bacill|cact|foc|fung|nucle|radi|stimul|syllab|termin|uter)us$", "%1i" },
	{ "(alumn|alg|vertebr)a$", "%1ae" },
	{ "(dat|strat|agend|addend|criteri|phenomen|medi|millenni|curricul)um$", "%1a" },
	{ "(criteri|phenomen|automat)on$", "%1a" },
	{ "(seraph|cherub)$", "%1im" },
	-- Catch-all for nouns ending in -s
	{ "us$", "uses" },
	-- Default catch-all
	{ "$", "s" },
}) do
	pluralize.addPluralRule(r[1], r[2])
end

-- Singularization rules (expanded and reordered for accuracy).
for _, r in ipairs({
	{ "(s)s$", "%1s" }, -- No change for words ending in -ss (e.g. "success")
	{ "(n)ews$", "%1ews" },
	-- Specific irregular patterns
	{ "(m)ice$", "%1ouse" },
	{ "(l)ice$", "%1ouse" },
	{ "(c)hildren$", "%1hild" },
	{ "(p)eople$", "%1erson" },
	{ "(m)en$", "%1an" },
	{ "(ax)es$", "%1e" }, -- from 'axe'
	{ "(test)es$", "%1is" }, -- from 'testis'
	{ "(octop|vir)uses$", "%1us" },
	{ "(alias|status)es$", "%1" },
	{ "(buffal|tomat|potat|her)oes$", "%1o" },
	{ "(app)endices$", "%1endix" },
	{ "(matr|vert|ind)ices$", "%1ix" },
	-- Nouns ending in -ves
	{ "([lr])ves$", "%1f" },
	{ "(kni|li|wi)ves$", "%1fe" },
	{ "(thie)ves$", "%1f" },
	{ "(sel|shel|wol)ves$", "%1f" },
	-- Nouns ending in -ies
	{ "(movi)es$", "%1e" },
	{ "([bcdfghjklmnpqrstvwxyz])ies$", "%1y" },
	{ "(qu)ies$", "%1y" },
	-- Standard -es endings
	{ "(sh|ch|ss|x|z)es$", "%1" },
	-- Latin/Greek endings
	{ "(alumn|bacill|cact|foc|fung|nucle|radi|stimul|syllab|termin|uter)i$", "%1us" },
	{ "(dat|strat|agend|addend|criteri|phenomen|medi|millenni|curricul)a$", "%1um" },
	{ "(criteri|phenomen|automat)a$", "%1on" },
	{ "(alumn|alg|vertebr)ae$", "%1a" },
	{ "(analy|diagno|parenthe|progno|synop|the)ses$", "%1sis" },
	-- Default "s" removal (must be last)
	{ "s$", "" },
}) do
	pluralize.addSingularRule(r[1], r[2])
end

-- Uncountable rules (expanded for more comprehensive coverage).
for _, word in ipairs({
	-- Nouns that are the same in singular and plural
	"bison",
	"bream",
	"carp",
	"chassis",
	"cod",
	"corps",
	"debris",
	"deer",
	"elk",
	"fish",
	"flounder",
	"gallows",
	"graffiti",
	"headquarters",
	"herpes",
	"mackerel",
	"means",
	"mews",
	"moose",
	"offspring",
	"pike",
	"plankton",
	"pliers",
	"salmon",
	"scissors",
	"series",
	"shears",
	"sheep",
	"shrimp",
	"species",
	"swine",
	"trout",
	"tuna",
	"whiting",
	"wildebeest",
	-- Common uncountable nouns
	"adulthood",
	"advice",
	"agenda",
	"aid",
	"alcohol",
	"ammo",
	"anime",
	"athletics",
	"audio",
	"baggage",
	"blood",
	"butter",
	"cash",
	"chess",
	"clothing",
	"commerce",
	"cooperation",
	"diabetes",
	"digestion",
	"energy",
	"equipment",
	"evidence",
	"excretion",
	"expertise",
	"feedback",
	"firmware",
	"fun",
	"furniture",
	"garbage",
	"hardware",
	"health",
	"homework",
	"housework",
	"information",
	"jeans",
	"jewelry",
	"justice",
	"kudos",
	"labour",
	"literature",
	"luggage",
	"machinery",
	"mail",
	"manga",
	"money",
	"mud",
	"music",
	"news",
	"personnel",
	"police",
	"pollution",
	"premises",
	"rain",
	"research",
	"rice",
	"sewage",
	"shambles",
	"software",
	"staff",
	"tennis",
	"traffic",
	"transportation",
	"water",
	"wealth",
	"welfare",
	"wildlife",
	"you",
	-- Patterns for uncountable words
	"pok[eé]mon$",
	"[^aeiou]ese$",
	"o[iu]s$",
	"pox$",
}) do
	pluralize.addUncountableRule(word)
end

-- Assign final functions
pluralize.plural = replaceWord(irregularSingles, irregularPlurals, pluralRules)
pluralize.isPlural = checkWord(irregularSingles, irregularPlurals, pluralRules)
pluralize.singular = replaceWord(irregularPlurals, irregularSingles, singularRules)
pluralize.isSingular = checkWord(irregularPlurals, irregularSingles, singularRules)

return pluralize
