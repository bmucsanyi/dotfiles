local wezterm = require 'wezterm'
local projects = require 'projects'
local mux = wezterm.mux
local config = wezterm.config_builder()

-------------
-- Startup --
-------------
wezterm.on('gui-startup', function(cmd)
  local tab, pane, window = mux.spawn_window(cmd or {})
  window:gui_window():maximize()
end)

---------------------------
-- Environment variables --
---------------------------
config.set_environment_variables = {
  PATH = '/opt/homebrew/bin:' .. os.getenv('PATH')
}

-----------------
-- Performance --
-----------------
-- config.max_fps = 144
-- config.animation_fps = 144
config.front_end = "WebGpu"

-----------
-- Theme --
-----------
config.color_scheme = 'Tokyo Night'

------------
-- Sounds --
------------
config.audible_bell = "Disabled"

----------
-- Tabs --
----------
wezterm.on(
  'format-tab-title',
  function(tab, tabs, panes, config, hover, max_width)
    local active_pane = tab.active_pane

    -- cwd is a URL object with file:// as beginning.
    local cwd = active_pane.current_working_dir
    if cwd == nil then
      return
    end

    -- get cwd in string format, https://wezfurlong.org/wezterm/config/lua/wezterm.url/Url.html
    local cwd_str = cwd.file_path

    -- shorten the path by using ~ as $HOME.
    local home_dir = os.getenv('HOME')
    return string.gsub(cwd_str, home_dir, '~')
  end
)

----------------
-- Status bar --
----------------
local function segments_for_right_status(window)
  for _, b in ipairs(wezterm.battery_info()) do
    battery_str = '🔋' .. string.format('%.0f%%', b.state_of_charge * 100)
  end

  hostname_str = '💻 ' .. wezterm.hostname()
  time_str = '📅 ' .. wezterm.strftime('%a %b %-d %H:%M')
  workspace_str = '🏢 ' .. window:active_workspace()

  return {
    workspace_str,
    time_str,
    hostname_str,
    battery_str,
  }
end

wezterm.on('update-status', function(window, _)
  local SOLID_LEFT_ARROW = utf8.char(0xe0b2)
  local segments = segments_for_right_status(window)

  local color_scheme = window:effective_config().resolved_palette
  local bg = wezterm.color.parse(color_scheme.background)
  local fg = color_scheme.foreground

  -- Each powerline segment is colored progressively.
  local gradient_to, gradient_from = bg
  gradient_from = gradient_to:lighten(0.2)

  local gradient = wezterm.color.gradient(
    {
      orientation = 'Horizontal',
      colors = { gradient_from, gradient_to },
    },
    #segments -- Only gives us as many colours as we have segments.
  )

  -- We'll build up the elements to send to wezterm.format in this table.
  local elements = {}

  for i, seg in ipairs(segments) do
    local is_first = i == 1

    if is_first then
      table.insert(elements, { Background = { Color = 'none' } })
    end
    table.insert(elements, { Foreground = { Color = gradient[i] } })
    table.insert(elements, { Text = SOLID_LEFT_ARROW })

    table.insert(elements, { Foreground = { Color = fg } })
    table.insert(elements, { Background = { Color = gradient[i] } })
    table.insert(elements, { Text = ' ' .. seg .. ' ' })
  end

  window:set_right_status(wezterm.format(elements))
end)

-------------
-- Actions --
-------------
local function move_pane(key, direction)
  return {
    key = key,
    mods = 'LEADER',
    action = wezterm.action.ActivatePaneDirection(direction),
  }
end

local function resize_pane(key, direction)
  return {
    key = key,
    action = wezterm.action.AdjustPaneSize { direction, 3 }
  }
end

config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }
config.keys = {
  {
    -- When the left arrow is pressed
    key = 'LeftArrow',
    -- With the "Option" key modifier held down
    mods = 'OPT',
    -- Send ESC + B to the terminal
    action = wezterm.action.SendString '\x1bb',
  },
  {
    key = 'RightArrow',
    mods = 'OPT',
    action = wezterm.action.SendString '\x1bf',
  },
  {
    key = ',',
    mods = 'SUPER',
    action = wezterm.action.SpawnCommandInNewTab {
      cwd = wezterm.home_dir,
      args = { 'hx', wezterm.config_file },
    },
  },
  {
    key = '"',
    mods = 'LEADER',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  {
    key = '%',
    mods = 'LEADER',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },
  {
    key = 'a',
    -- When we're in leader mode _and_ CTRL + A is pressed...
    mods = 'LEADER|CTRL',
    -- Actually send CTRL + A key to the terminal
    action = wezterm.action.SendKey { key = 'a', mods = 'CTRL' },
  },
  move_pane('j', 'Down'),
  move_pane('k', 'Up'),
  move_pane('h', 'Left'),
  move_pane('l', 'Right'),
  {
    -- When we push LEADER + R...
    key = 'r',
    mods = 'LEADER',
    -- Activate the `resize_panes` keytable
    action = wezterm.action.ActivateKeyTable {
      name = 'resize_panes',
      -- Ensures the keytable stays active after it handles its
      -- first keypress.
      one_shot = false,
      -- Deactivate the keytable after a timeout.
      timeout_milliseconds = 1000,
    }
  },
  {
    key = 'p',
    mods = 'LEADER',
    action = projects.choose_project(),
  },
  {
    key = 'f',
    mods = 'LEADER',
    -- Present a list of existing workspaces
    action = wezterm.action.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES' },
  },
  {
    key = 'x',
    mods = 'LEADER',
    action = wezterm.action.CloseCurrentPane { confirm = false },
  },
}

config.key_tables = {
  resize_panes = {
    resize_pane('j', 'Down'),
    resize_pane('k', 'Up'),
    resize_pane('h', 'Left'),
    resize_pane('l', 'Right'),
  },
}

-----------
-- Fonts --
-----------
-- config.font = wezterm.font({ family = 'JetBrains Mono'})
config.font = wezterm.font({ family = 'IBM Plex Mono' })
config.font_size = 13

------------------
-- Window style --
------------------
-- config.window_background_opacity = 0.8
config.window_background_opacity = 0.85
config.macos_window_background_blur = 30
config.window_decorations = 'RESIZE'
-- config.window_frame = {
--   font = wezterm.font({ family = 'JetBrains Mono', weight = 'Bold' }),
--   font_size = 11,
-- }
config.window_frame = {
  font = wezterm.font({ family = 'IBM Plex Mono', weight = 'Bold' }),
  font_size = 11,
}
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }

return config
