-- pluralize.lua
--
-- A 100% pure Lua port of the 'pluralize' JavaScript library.
-- This version has NO external dependencies and uses native Lua string patterns.

local pluralize = {}

local pluralRules = {}
local singularRules = {}
local uncountables = {}
local irregularPlurals = {}
local irregularSingles = {}

---
-- Replicates the case of an original word onto a new word token.
-- @param word (string) The original word with the desired case.
-- @param token (string) The new word to apply the case to.
-- @return (string) The token with the case of the original word.
local function restoreCase(word, token)
	if word == token then
		return token
	end
	if word == word:lower() then
		return token:lower()
	end
	if word == word:upper() then
		return token:upper()
	end
	if word:sub(1, 1) == word:sub(1, 1):upper() then
		return token:sub(1, 1):upper() .. token:sub(2):lower()
	end
	return token:lower()
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

-- Irregular rules.
for _, rule in ipairs({
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
	{ "my", "our" },
	{ "its", "their" },
	{ "his", "their" },
	{ "her", "their" },
	{ "echo", "echoes" },
	{ "dingo", "dingoes" },
	{ "volcano", "volcanoes" },
	{ "tornado", "tornadoes" },
	{ "torpedo", "torpedoes" },
	{ "genus", "genera" },
	{ "viscus", "viscera" },
	{ "stigma", "stigmata" },
	{ "stoma", "stomata" },
	{ "dogma", "dogmata" },
	{ "lemma", "lemmata" },
	{ "schema", "schemata" },
	{ "anathema", "anathemata" },
	{ "ox", "oxen" },
	{ "axe", "axes" },
	{ "die", "dice" },
	{ "yes", "yeses" },
	{ "foot", "feet" },
	{ "eave", "eaves" },
	{ "goose", "geese" },
	{ "tooth", "teeth" },
	{ "quiz", "quizzes" },
	{ "human", "humans" },
	{ "proof", "proofs" },
	{ "carve", "carves" },
	{ "valve", "valves" },
	{ "looey", "looies" },
	{ "thief", "thieves" },
	{ "groove", "grooves" },
	{ "pickaxe", "pickaxes" },
	{ "passerby", "passersby" },
	{ "canvas", "canvases" },
}) do
	pluralize.addIrregularRule(rule[1], rule[2])
end

-- Pluralization rules (converted from regex to Lua patterns).
for _, r in ipairs({
	{ "s$", "s" },
	{ "^(ax)is$", "%1es" },
	{ "^(test)is$", "%1es" },
	{ "^(alias)$", "%1es" },
	{ "us$", "uses" },
	{ "tlas$", "tlases" },
	{ "gas$", "gases" },
	{ "(e[mn]u)$", "%1s" },
	{ "([^l]ias)$", "%1" },
	{ "([aeiou]las)$", "%1" },
	{ "([ejzr]as)$", "%1" },
	{ "([iu]am)$", "%1" },
	{ "(alumn|syllab|vir|radi|nucle|fung|cact|stimul|termin|bacill|foc|uter|loc|strat)i$", "%1i" },
	{ "(alumn|syllab|vir|radi|nucle|fung|cact|stimul|termin|bacill|foc|uter|loc|strat)us$", "%1i" },
	{ "(alumn|alg|vertebr)a$", "%1ae" },
	{ "(seraph|cherub)$", "%1im" },
	{ "(seraph|cherub)im$", "%1im" },
	{ "(her|at|gr)o$", "%1oes" },
	{
		"(agend|addend|millenni|dat|extrem|bacteri|desiderat|strat|candelabr|errat|ov|symposi|curricul|automat|quor)um$",
		"%1a",
	},
	{ "(apheli|hyperbat|periheli|asyndet|noumen|phenomen|criteri|organ|prolegomen|hedr|automat)on$", "%1a" },
	{ "sis$", "ses" },
	{ "(kni)fe$", "%1ves" },
	{ "(wi)fe$", "%1ves" },
	{ "(li)fe$", "%1ves" },
	{ "(ar)f$", "%1ves" },
	{ "(l)f$", "%1ves" },
	{ "(ea)f$", "%1ves" },
	{ "(eo)f$", "%1ves" },
	{ "(oa)f$", "%1ves" },
	{ "(hoo)f$", "%1ves" },
	{ "([bcdfghjklmnpqrstvwxyz])y$", "%1ies" },
	{ "(qu)y$", "%1ies" }, -- Replaces ([^aeiouy]|qu)y$
	{ "([^ch][ieo][ln])ey$", "%1ies" },
	{ "(x|ch|ss|sh|zz)$", "%1es" },
	{ "(matr|cod|mur|sil|vert|ind|append)ix$", "%1ices" },
	{ "(matr|cod|mur|sil|vert|ind|append)ex$", "%1ices" },
	{ "^(m)ouse$", "%1ice" },
	{ "^(l)ouse$", "%1ice" },
	{ "(pe)rson$", "%1ople" },
	{ "(pe)ople$", "%1ople" },
	{ "(child)$", "%1ren" },
	{ "(child)ren$", "%1ren" },
	{ "eaux$", "%0" },
	{ "m[ae]n$", "men" },
	{ "^thou$", "you" },
}) do
	pluralize.addPluralRule(r[1], r[2])
end

-- Singularization rules (converted from regex to Lua patterns).
for _, r in ipairs({
	{ "s$", "" },
	{ "(ss)$", "%1" },
	{ "(wi)ves$", "%1fe" },
	{ "(kni)ves$", "%1fe" },
	{ "li(ves)$", "fe" }, -- Simplified from a complex regex
	{ "(ar)ves$", "%1f" },
	{ "(wo)lves$", "%1lf" },
	{ "(l)ves$", "%1f" }, -- Simplified
	{ "ies$", "y" },
	{ "(movi)es$", "%1e" },
	{ "(tivelv)es$", "%1e" }, -- twelve
	{ "(seraph|cherub)im$", "%1" },
	{ "(x|ch|ss|sh|zz|tto|go|cho|alias|us|gas)es$", "%1" },
	{ "(analy|diagno|parenthe|progno|synop|the|empha|cri|ne)ses$", "%1sis" },
	{ "(alumn|syllab|vir|radi|nucle|fung|cact|stimul|termin|bacill|foc|uter|loc|strat)i$", "%1us" },
	{ "(agend|addend|millenni|dat|extrem|bacteri|desiderat|strat|candelabr|errat|ov|symposi|curricul|quor)a$", "%1um" },
	{ "(apheli|hyperbat|periheli|asyndet|noumen|phenomen|criteri|organ|prolegomen|hedr|automat)a$", "%1on" },
	{ "(alumn|alg|vertebr)ae$", "%1a" },
	{ "(cod|mur|sil|vert|ind)ices$", "%1ex" },
	{ "(matr|append)ices$", "%1ix" },
	{ "(pe)ople$", "%1rson" },
	{ "(child)ren$", "%1" },
	{ "(eau)x?$", "%1" },
	{ "men$", "man" },
}) do
	pluralize.addSingularRule(r[1], r[2])
end

-- Uncountable rules.
for _, word in ipairs({
	"adulthood",
	"advice",
	"agenda",
	"aid",
	"aircraft",
	"alcohol",
	"ammo",
	"analytics",
	"anime",
	"athletics",
	"audio",
	"bison",
	"blood",
	"bream",
	"buffalo",
	"butter",
	"carp",
	"cash",
	"chassis",
	"chess",
	"clothing",
	"cod",
	"commerce",
	"cooperation",
	"corps",
	"debris",
	"diabetes",
	"digestion",
	"elk",
	"energy",
	"equipment",
	"excretion",
	"expertise",
	"firmware",
	"flounder",
	"fun",
	"gallows",
	"garbage",
	"graffiti",
	"hardware",
	"headquarters",
	"health",
	"herpes",
	"highjinks",
	"homework",
	"housework",
	"information",
	"jeans",
	"justice",
	"kudos",
	"labour",
	"literature",
	"machinery",
	"mackerel",
	"mail",
	"media",
	"mews",
	"moose",
	"music",
	"mud",
	"manga",
	"news",
	"only",
	"personnel",
	"pike",
	"plankton",
	"pliers",
	"police",
	"pollution",
	"premises",
	"rain",
	"research",
	"rice",
	"salmon",
	"scissors",
	"series",
	"sewage",
	"shambles",
	"shrimp",
	"software",
	"staff",
	"swine",
	"tennis",
	"traffic",
	"transportation",
	"trout",
	"tuna",
	"wealth",
	"welfare",
	"whiting",
	"wildebeest",
	"wildlife",
	"you",
	-- Patterns
	"pok[eé]mon$",
	"[^aeiou]ese$",
	"deer$",
	"fish$",
	"measles$",
	"o[iu]s$",
	"pox$",
	"sheep$",
}) do
	pluralize.addUncountableRule(word)
end

-- Assign final functions
pluralize.plural = replaceWord(irregularSingles, irregularPlurals, pluralRules)
pluralize.isPlural = checkWord(irregularSingles, irregularPlurals, pluralRules)
pluralize.singular = replaceWord(irregularPlurals, irregularSingles, singularRules)
pluralize.isSingular = checkWord(irregularPlurals, irregularSingles, singularRules)

return pluralize
