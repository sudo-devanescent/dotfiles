-- wezterm.lua
-- Minimalista, mantenible

local wezterm = require("wezterm")

-- config_builder valida las claves y muestra la ubicación exacta del error
-- si se asigna una opción inválida (typo), en vez de fallar en silencio.
local config = wezterm.config_builder()

-- ============================================================
-- Fuente
-- ============================================================

-- Requiere la variante Nerd Font instalada (glifos de iconos).
-- Ver: https://www.nerdfonts.com
config.font = wezterm.font("JetBrainsMono Nerd Font Mono")
config.font_size = 11.0

-- ============================================================
-- Apariencia
-- ============================================================

config.color_scheme = "Campbell (Gogh)"
config.window_background_opacity = 0.88

config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.enable_scroll_bar = false

-- ============================================================
-- Ventana: tamaño y comportamiento
-- ============================================================

config.initial_cols = 99
config.initial_rows = 29

-- Evita redimensionamientos al cambiar el tamaño de fuente
config.adjust_window_size_when_changing_font_size = false

-- Evita bordes sin pintar al redimensionar.
-- NOTA: revisa si aplica (si estás en Windows).
config.use_resize_increments = true

-- No pedir confirmación al cerrar la ventana
config.window_close_confirmation = "NeverPrompt"

-- ============================================================
-- Cursor
-- ============================================================

config.default_cursor_style = "SteadyBlock"
config.cursor_blink_rate = 0

-- ============================================================
-- Configuración específica por plataforma
-- ============================================================

if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	-- Shell por defecto en Windows: PowerShell 7+ (pwsh), no cmd.exe ni
	-- Windows PowerShell 5.1
	config.default_prog = { "pwsh.exe", "-NoLogo" }
end

-- ============================================================
-- Eventos
-- ============================================================

-- Centrar ventana al iniciar (funciona en X11 y macOS; en Wayland es un
-- no-op documentado por WezTerm ya que el protocolo no permite a las apps
-- controlar su propia posición; en Windows depende de la versión: puede
-- fallar en builds antiguos)
wezterm.on("gui-startup", function(cmd)
	local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
	local gui_window = window:gui_window()
	local screen = wezterm.gui.screens().active
	local dims = gui_window:get_dimensions()

	gui_window:set_position(
		screen.x + (screen.width - dims.pixel_width) / 2,
		screen.y + (screen.height - dims.pixel_height) / 2
	)
end)

-- Fija el título de la ventana a "Terminal" en vez del proceso en ejecución
-- (por defecto muestra el nombre del shell, p. ej. "pwsh.exe")
wezterm.on("format-window-title", function()
	return "Terminal"
end)

return config
