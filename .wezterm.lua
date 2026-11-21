-- wezterm.lua
-- Config multiplataforma (Linux Wayland/x11, Windows 11). Minimalista y mantenible.
-- Requiere WezTerm >= 20220807 (por config_builder).

local wezterm = require("wezterm")

-- config_builder valida las claves y muestra la ubicación exacta del error
-- si se asigna una opción inválida (typo), en vez de fallar en silencio.
local config = wezterm.config_builder()

-- ============================================================
-- Detección de plataforma
-- ============================================================

-- Se usa find() sobre el triple para cubrir también variantes como
-- aarch64-pc-windows-msvc (Windows 11 ARM).
local is_windows = wezterm.target_triple:find("windows", 1, true) ~= nil
local is_linux = wezterm.target_triple:find("linux", 1, true) ~= nil

-- ============================================================
-- Utilidades
-- ============================================================

-- Devuelve true si `name` es resoluble en el PATH de Windows.
-- pcall evita que un fallo al lanzar where.exe rompa la carga de la config.
local function windows_command_exists(name)
	local ok, success = pcall(wezterm.run_child_process, { "where.exe", name })
	return ok and success
end

-- Centra la ventana en la pantalla activa al iniciar.
-- Funciona en X11; en Wayland es un no-op documentado por WezTerm (el
-- protocolo no permite a las apps controlar su propia posición); en Windows
-- puede fallar en builds antiguos.
local function center_window(cmd)
	local _, _, window = wezterm.mux.spawn_window(cmd or {})
	local gui_window = window:gui_window()
	if not gui_window then
		return
	end

	local screen = wezterm.gui.screens().active
	if not screen then
		return
	end

	local dims = gui_window:get_dimensions()

	-- set_position espera enteros; la división en Lua 5.4 devuelve float.
	gui_window:set_position(
		math.floor(screen.x + (screen.width - dims.pixel_width) / 2),
		math.floor(screen.y + (screen.height - dims.pixel_height) / 2)
	)
end

-- ============================================================
-- Fuente
-- ============================================================

-- Se prefiere la variante Nerd Font
-- Si no está instalada, se usa JetBrains Mono, incluida en WezTerm; los
-- glifos de iconos siguen disponibles gracias a su Symbols Nerd Font integrada.
-- Ver: https://www.nerdfonts.com
config.font = wezterm.font_with_fallback({
	"JetBrainsMono Nerd Font Mono",
	"JetBrains Mono",
})
config.font_size = 11.0

-- ============================================================
-- Apariencia
-- ============================================================

config.color_scheme = "Campbell (Gogh)"

-- Si no se aplica o se ve mal (p. ej. X11 sin compositor), poner 1.0.
config.window_background_opacity = 0.88

config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.enable_scroll_bar = false

-- ============================================================
-- Ventana: tamaño y comportamiento
-- ============================================================

config.initial_cols = 111
config.initial_rows = 33

-- Evita redimensionamientos al cambiar el tamaño de fuente
config.adjust_window_size_when_changing_font_size = false

-- ============================================================
-- Cursor
-- ============================================================

-- Cursor: StreadyBlock
config.default_cursor_style = "SteadyBlock"

-- ============================================================
-- Renderizado (solo fallback)
-- ============================================================

-- Por defecto se usa el backend predeterminado (aceleración por GPU).
-- En VMs sin aceleración 3D, lanzar WezTerm con WEZTERM_SOFTWARE=1:
--   Linux:   WEZTERM_SOFTWARE=1 wezterm
--   Windows: $env:WEZTERM_SOFTWARE = 1; wezterm-gui
if os.getenv("WEZTERM_SOFTWARE") == "1" then
	config.front_end = "Software"
end

-- ============================================================
-- Configuración específica por plataforma
-- (al final de las opciones para poder sobrescribirlas)
-- ============================================================

if is_windows then
	-- Shell por defecto: PowerShell 7+ (pwsh), con fallback a Windows
	-- PowerShell 5.1 si pwsh no está instalado (evita que la ventana falle).
	if windows_command_exists("pwsh.exe") then
		config.default_prog = { "pwsh.exe", "-NoLogo" }
	else
		config.default_prog = { "powershell.exe", "-NoLogo" }
	end
elseif is_linux then
	-- El aviso de actualización no es accionable si se instala por gestor
	-- de paquetes.
	config.check_for_updates = false
end

-- ============================================================
-- Eventos
-- ============================================================

wezterm.on("gui-startup", center_window)

-- Fija el título de la ventana a "Terminal" en vez del proceso en ejecución
-- (por defecto muestra el nombre del shell, p. ej. "pwsh.exe")
wezterm.on("format-window-title", function()
	return "Terminal"
end)

return config
