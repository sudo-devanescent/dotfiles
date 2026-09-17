" --------------------------------------
"         Configuración de Vim       
" --------------------------------------

" Default Settings
syntax on
set number
set showmode
set nocompatible
set background=dark
set fillchars=eob:\ 

" --------------------------------------
" Gestión de plugins con vim-plug
" --------------------------------------

call plug#begin('~/vimfiles/plugged')

" Mejora Netrw (acceso rápido y navegación con '-')
Plug 'tpope/vim-vinegar'

" Establece valores neutrales para Vim
Plug 'tpope/vim-sensible'

" Manipulación eficiente de pares de caracteres
Plug 'tpope/vim-surround'

" Temas de color
Plug 'arcticicestudio/nord-vim'                " Tema Nord
Plug 'cocopon/iceberg.vim'                     " Tema Iceberg
Plug 'dracula/vim', { 'as': 'dracula' }        " Tema Dracula
Plug 'NLKNguyen/papercolor-theme'              " Tema PaperColor

call plug#end()

" --------------------------------------
" Usabilidad y apariencia general
" --------------------------------------

" Búsqueda y navegación
set number                      " Muestra números de línea
set cursorline                  " Resalta la línea actual
set showcmd                     " Muestra comandos parcialmente escritos
set showmatch                   " Resalta paréntesis/coincidencias
set hidden                      " Permite mantener buffers abiertos
set path+=**                    " Búsqueda recursiva

" Menú de autocompletado (wildmenu)
set wildmenu
" Parámetros para wildmenu
set wildmode=list:longest,full
" Ignorar archivos compilados, binarios, etc.
set wildignore+=**/node_modules/**/**,**/target/**,**/.git/**
set wildignore+=*.pyc,*.o,*.obj,*.bin,*.zip,*.tar.gz

" Ajustes visuales
set laststatus=2                " Siempre mostrar barra de estado
set termguicolors               " Activa colores 24-bit
set background=dark             " Fondo oscuro por defecto
if has('mouse')
  set mouse=a                   " Habilita ratón en todos los modos
endif

" Colorscheme activo
colorscheme dracula

" --------------------------------------
" Edición e indentación
" --------------------------------------

" Backspace funcional
set backspace=indent,eol,start

" Tabs e indentación
set expandtab                   " Convierte <Tabs> en espacios
set shiftwidth=4                " Ancho de indentación en espacios
set tabstop=4                   " Número de espacios que representa <Tab>
set autoindent                  " Indentación automática
set smartindent                 " Indentación inteligente

" Archivos y backup
set nobackup                    " No crear archivos de backup
set nowritebackup               " No guardar backup temporal

" --------------------------------------
" Atajos personalizados
" --------------------------------------

" Quitar resaltado de búsqueda
nnoremap <Esc> :nohlsearch<CR>

" --------------------------------------
"           FIN DEL ARCHIVO
" --------------------------------------
