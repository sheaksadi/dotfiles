local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()

-- Font settings
config.font = wezterm.font("JetBrains Mono")
config.font_size = 10.0 -- Smaller font

-- Terminal appearance
config.window_background_opacity = 0.9
config.window_decorations = "RESIZE"
config.initial_cols = 80
config.initial_rows = 24
config.hide_tab_bar_if_only_one_tab = true -- Add this line

config.window_padding = {
	left = 0,
	right = 0,
	top = 6,
	bottom = 0,
}
config.skip_close_confirmation_for_processes_named =
	{ "wsl.exe", "wslhost.exe", "pwsh.exe", "powershell.exe", "cmd.exe", "bash", "zsh", "fish", "sh" }
config.window_close_confirmation = "NeverPrompt"
-- Default shell (WSL)
config.default_prog = { "wsl.exe" }

-- Color scheme toggle
wezterm.on("toggle-colorscheme", function(window, pane)
	local overrides = window:get_config_overrides() or {}
	if overrides.color_scheme == "Zenburn" then
		overrides.color_scheme = "Cloud (terminal.sexy)"
	else
		overrides.color_scheme = "Zenburn"
	end
	window:set_config_overrides(overrides)
end)

-- Keybindings
config.keys = {
	{
		key = "E",
		mods = "CTRL|SHIFT|ALT",
		action = wezterm.action.EmitEvent("toggle-colorscheme"),
	},
	{
		key = "W",
		mods = "CTRL|SHIFT",
		action = wezterm.action.SpawnCommandInNewTab({ args = { "wsl.exe" } }),
	},
	{
		key = "P",
		mods = "CTRL|SHIFT",
		action = wezterm.action.SpawnCommandInNewTab({ args = { "powershell.exe", "-NoLogo" } }),
	},
	{
		key = "x",
		mods = "SHIFT|CTRL",
		action = wezterm.action.CloseCurrentTab({ confirm = false }),
	},
	{
		key = "r",
		mods = "CTRL|SHIFT",
		action = wezterm.action.ReloadConfiguration,
	},
	{
		key = "c",
		mods = "CTRL",
		action = wezterm.action_callback(function(window, pane)
			local has_selection = window:get_selection_text_for_pane(pane) ~= ""
			if has_selection then
				window:perform_action(act.CopyTo("Clipboard"), pane)
			else
				window:perform_action(act.SendKey({ key = "C", mods = "CTRL" }), pane)
			end
		end),
	},
	{
		key = "v",
		mods = "CTRL",
		action = act.PasteFrom("Clipboard"),
	},
}

-- Color scheme
config.color_scheme = "Cloud (terminal.sexy)"

return config
