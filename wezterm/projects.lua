local wezterm = require 'wezterm'
local module = {}

local project_dir = wezterm.home_dir .. "/Projects"

local function project_dirs()
  local projects = { wezterm.home_dir }

  for _, dir in ipairs(wezterm.glob(project_dir .. '/*')) do
    table.insert(projects, dir)
  end

  return projects
end

function module.choose_project()
  local choices = {}
  for _, value in ipairs(project_dirs()) do
    table.insert(choices, { label = value })
  end

  return wezterm.action.InputSelector {
    title = "Projects",
    choices = choices,
    fuzzy = true,
    action = wezterm.action_callback(function(child_window, child_pane, id, label)
      if not label then return end

      -- The SwitchToWorkspace action will switch us to a workspace if it already exists,
      -- otherwise it will create it for us.
      child_window:perform_action(wezterm.action.SwitchToWorkspace {
        -- We'll give our new workspace a nice name, like the last path segment
        -- of the directory we're opening up.
        name = label:match("([^/]+)$"),
        -- We'll spawn a new terminal with the current working
        -- directory set to the directory that was picked.
        spawn = { cwd = label },
      }, child_pane)
    end),
  }
end

return module
