
" ======================================================================
"                         Configuración de Vim
" ======================================================================
" Linux (X11/Wayland), Windows 11 (nativo) y Termux. Vim >= 8.2 (ideal 9.x).
" Sin swap, undo ni backup permanentes. viminfo e instalación de plugins
" quedan dentro del directorio de configuración (s:vimdir).
" Windows: guardar como ~/_vimrc o ~/vimfiles/vimrc (el código no depende
" del nombre).

" ----------------------------------------------------------------------
" 0. Interruptores (1 = activo, 0 = inactivo)
" ----------------------------------------------------------------------

" Atajos al portapapeles del sistema (<Leader>y / <Leader>p). Ver sección 10.
let g:vimrc_clipboard = get(g:, 'vimrc_clipboard', 1)

" ----------------------------------------------------------------------
" 1. Entorno y compatibilidad
" ----------------------------------------------------------------------

" Garantiza modo no compatible (p. ej. si Vim arranca con -u); sin esto las
" líneas de continuación '\' no funcionan.
if &compatible
  set nocompatible
endif

" Codificación interna (antes de scriptencoding). No se reasigna si ya es utf-8.
if &encoding !=# 'utf-8'
  set encoding=utf-8
endif
scriptencoding utf-8              " Este archivo contiene caracteres no ASCII

" Ruta de este archivo (válida aunque Vim arranque con -u y $MYVIMRC esté vacío)
let s:vimrc = expand('<sfile>:p')

" Detección de entorno
let s:is_win    = has('win32')
let s:is_termux = !empty($TERMUX_VERSION) || $PREFIX =~# 'com\.termux'
let s:is_sudo   = !empty($SUDO_USER)

" Directorio base de Vim: primera entrada de 'runtimepath' (~/.vim, ~/vimfiles...)
let s:vimdir = substitute(fnamemodify(split(&runtimepath, ',')[0], ':p'), '[\\/]\+$', '', '')
if s:is_win
  let s:vimdir = tr(s:vimdir, '\', '/')
endif

" ----------------------------------------------------------------------
" 2. Plugins (vim-plug)
" ----------------------------------------------------------------------

let s:plug_file = s:vimdir . '/autoload/plug.vim'
let s:plug_url  = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

" Bajo sudo no se instala nada (evita crear archivos de root en ~/.vim)
let s:can_install = !s:is_sudo && executable('git')

" Descarga vim-plug si falta. Se baja a un archivo temporal y solo se
" renombra si curl termina bien y el archivo no está vacío.
if !filereadable(s:plug_file) && s:can_install && executable('curl')
  let s:plug_tmp = s:plug_file . '.tmp'
  silent! call mkdir(fnamemodify(s:plug_file, ':h'), 'p')
  call system('curl -fsSL --connect-timeout 5 --max-time 30 -o '
        \ . shellescape(s:plug_tmp) . ' ' . shellescape(s:plug_url))
  if v:shell_error == 0 && getfsize(s:plug_tmp) > 0
    call rename(s:plug_tmp, s:plug_file)
  else
    call delete(s:plug_tmp)
  endif
endif

if filereadable(s:plug_file)
  call plug#begin(s:vimdir . '/plugged')

  " Netrw mejorado (abre el explorador con '-')
  Plug 'tpope/vim-vinegar'

  " Valores por defecto razonables (backspace, wildmenu, showcmd, etc.)
  Plug 'tpope/vim-sensible'

  " Manipulación de pares de caracteres (comillas, paréntesis, etiquetas)
  Plug 'tpope/vim-surround'

  " Temas de color (se cambian con :colorscheme)
  Plug 'arcticicestudio/nord-vim'                " Nord
  Plug 'cocopon/iceberg.vim'                     " Iceberg
  Plug 'dracula/vim', { 'as': 'dracula' }        " Dracula

  call plug#end()

  " Si falta algún plugin, lo instala al arrancar y recarga este archivo.
  " Sin git, o bajo sudo, no hace nada.
  if s:can_install && !empty(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
    augroup vimrc_plug
      autocmd!
      execute 'autocmd VimEnter * PlugInstall --sync | source ' . fnameescape(s:vimrc)
    augroup END
  endif
else
  " Sin vim-plug: valores por defecto de Vim
  runtime defaults.vim
endif

" Explícitos por si vim-plug no está disponible ('enable' no pisa colores)
syntax enable
filetype plugin indent on

" ----------------------------------------------------------------------
" 3. Valores base (idénticos con o sin plugins)
" ----------------------------------------------------------------------
" Fijan lo que difiere entre vim-sensible y defaults.vim.

set backspace=indent,eol,start    " <BS> borra sangría, saltos de línea e inserción previa
set laststatus=2                  " Barra de estado siempre visible
set ruler                         " Posición del cursor
set showcmd                       " Comando pendiente en la última línea
set wildmenu                      " Menú de completado en la línea de comandos
set scrolloff=5                   " Líneas de contexto al desplazarse
silent! set display=truncate      " Muestra '@@@' en vez de ocultar líneas largas
set nrformats-=octal              " <C-a>/<C-x> no tratan 007 como octal
set complete-=i                   " <C-n> no recorre includes (lento con path+=**)
set autoread                      " Recarga archivos modificados fuera de Vim
set history=1000                  " Historial de comandos

" Timeouts de teclas: respuesta rápida de <Esc> sin cortar secuencias
set ttimeout
set ttimeoutlen=50

" Restaura la posición del cursor al reabrir (si defaults.vim no lo hizo ya)
if !exists('#vimStartup#BufReadPost')
  augroup vimrc_cursor
    autocmd!
    autocmd BufReadPost *
          \ if line("'\"") >= 1 && line("'\"") <= line('$') && &filetype !~# 'commit'
          \ |   execute 'normal! g`"'
          \ | endif
  augroup END
endif

" ----------------------------------------------------------------------
" 4. Interfaz y colores
" ----------------------------------------------------------------------

set number                        " Números de línea
set cursorline                    " Resalta la línea actual

" Sin pitidos ni parpadeos
if exists('+belloff')
  set belloff=all
else
  set noerrorbells novisualbell t_vb=
endif

" Sustituye el '~' de las líneas vacías por un espacio (aspecto limpio)
silent! execute 'set fillchars+=eob:\ '

" Colores 24-bit solo si el entorno los soporta
if has('termguicolors')
      \ && (s:is_win || s:is_termux || $COLORTERM =~# '\v^(truecolor|24bit)$')
  " tmux/screen no siempre anuncian los códigos de color verdadero
  if &term =~# '^\%(tmux\|screen\)'
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  endif
  set termguicolors
endif

" Ratón en todos los modos
if has('mouse')
  set mouse=a
endif

" Tema activo. Opciones principales: iceberg, nord, dracula
" Si el tema no está disponible (versión antigua o plugin sin instalar),
" se usa 'default', incluido en todas las versiones.
set background=dark
let s:theme = 'lunaperche'
if empty(globpath(&runtimepath, 'colors/' . s:theme . '.vim'))
  let s:theme = 'default'
endif
try
  execute 'colorscheme ' . s:theme
catch
  silent! colorscheme desert
endtry

" ----------------------------------------------------------------------
" 5. Búsqueda y navegación
" ----------------------------------------------------------------------

set hlsearch                      " Resalta coincidencias
set incsearch                     " Búsqueda incremental
set ignorecase                    " Ignora mayúsculas al buscar...
set smartcase                     " ...salvo que el patrón las incluya

set hidden                        " Permite cambiar de buffer sin guardar
set path+=**                      " :find y gf recursivos (lento en directorios enormes)

" Autocompletado de comandos y archivos
set wildmode=list:longest,full
set wildignore+=*/node_modules/*,*/.git/*
set wildignore+=*.pyc,*.o,*.obj,*.bin,*.zip,*.tar.gz

" ----------------------------------------------------------------------
" 6. Edición e indentación
" ----------------------------------------------------------------------

set expandtab                     " <Tab> inserta espacios
set shiftwidth=4                  " Ancho de indentación
set tabstop=4                     " Ancho visual de un <Tab>
set softtabstop=-1                " <Tab>/<BS> usan el valor de shiftwidth
set smarttab                      " <Tab> al inicio de línea usa shiftwidth
set autoindent                    " Mantiene la indentación de la línea anterior

" ----------------------------------------------------------------------
" 7. Archivos
" ----------------------------------------------------------------------

set noswapfile                    " Sin archivos .swp
set nobackup                      " Sin respaldo permanente (file~)
set writebackup                   " Respaldo temporal al guardar; se borra si todo va bien
if has('persistent_undo')
  set noundofile                  " Sin archivos de undo
endif
set fileformats=unix,dos          " Prioriza fin de línea Unix; detecta DOS

" Netrw no guarda historial de directorios (.netrwhist)
let g:netrw_dirhistmax = 0

" viminfo (historial, marcas, registros) dentro de s:vimdir, nunca en ~.
" Bajo sudo se desactiva para no crear archivos de root en el HOME del usuario.
if s:is_sudo
  set viminfo=
else
  silent! call mkdir(s:vimdir, 'p', 0700)
  if isdirectory(s:vimdir)
    if exists('+viminfofile')
      let &viminfofile = s:vimdir . '/viminfo'
    else
      let &viminfo = substitute(&viminfo, ',n.*$', '', '') . ',n' . s:vimdir . '/viminfo'
    endif
  endif
endif

" ----------------------------------------------------------------------
" 8. Atajos
" ----------------------------------------------------------------------

" Ctrl+L: quita el resaltado de búsqueda, actualiza diffs y redibuja
nnoremap <silent> <C-l> :nohlsearch<Bar>diffupdate<CR><C-l>

" ----------------------------------------------------------------------
" 9. Ajustes por plataforma
" ----------------------------------------------------------------------

" Windows: los archivos .bat/.cmd nuevos se crean con CRLF (cmd.exe puede
" fallar con LF en etiquetas y 'goto'). No modifica archivos existentes.
if s:is_win
  augroup vimrc_win
    autocmd!
    autocmd BufNewFile *.bat,*.cmd setlocal fileformat=dos
  augroup END
endif

" ----------------------------------------------------------------------
" 10. Portapapeles del sistema (opcional y autónomo)
" ----------------------------------------------------------------------
" Explícito: Vim no toca el portapapeles salvo con estos atajos.
" Solo se activa si Vim tiene +clipboard; si no, no hace nada y no avisa.
" Si el portapapeles no está accesible (p. ej. sin servidor X), Vim usa el
" registro sin nombre. Para desactivarlo: g:vimrc_clipboard = 0 o borrar
" esta sección. Linux/Windows: "+ es el portapapeles estándar (Ctrl+V).
if g:vimrc_clipboard && has('clipboard') && !s:is_termux
  nnoremap <Leader>y "+y
  xnoremap <Leader>y "+y
  nnoremap <Leader>p "+p
  nnoremap <Leader>P "+P
  xnoremap <Leader>p "+p
endif

" ======================================================================
"                           FIN DEL ARCHIVO
" ======================================================================
