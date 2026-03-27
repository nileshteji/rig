scriptencoding utf-8
set encoding=utf-8

"----------------------------------------------------------------------
" Basic Options (merged from nvim set.lua + vim-misc)
"----------------------------------------------------------------------
" Leader key: from nvim config (Space)
let mapleader=" "

set autoread              " Reload files that have not been modified
set backspace=2           " Makes backspace behave like you'd expect
set hidden                " Allow buffers to be backgrounded without being saved
set laststatus=2          " Always show the status bar
set ruler                 " Show the line number and column in the status bar
set t_Co=256              " Use 256 colors
set showmatch             " Highlight matching braces
set showmode              " Show the current mode on the open buffer
set splitbelow            " Splits show up below by default
set splitright            " Splits go to the right by default
set title                 " Set the title for gvim
set visualbell            " Use a visual bell to notify us

" From nvim set.lua
set guicursor=            " Block cursor in all modes
set number                " Line numbers
set relativenumber        " Relative line numbers
set tabstop=4             " Tab width
set softtabstop=4         " Soft tab width
set shiftwidth=4          " Shift width
set expandtab             " Expand tabs to spaces
set smartindent           " Smart indentation
set nowrap                " No line wrapping
set noswapfile            " No swap files
set nobackup              " No backup files
set undodir=~/.vim/undodir
set undofile              " Persistent undo
set nohlsearch            " No highlight search (from nvim)
set incsearch             " Incremental search
set termguicolors         " True color support
set scrolloff=8           " Keep 8 lines visible around cursor
set signcolumn=yes        " Always show sign column
set isfname+=@-@          " Include @ in filenames
set updatetime=50         " Faster update time
set cmdheight=1           " Minimal command line height (vim requires >= 1)

" From vim-misc: invisible characters
set list
set listchars=tab:›\ ,eol:¬,trail:⋅

" From vim-misc: smart case searching
set ignorecase
set smartcase

" From vim-misc: show line break character
if !has("win32")
    set showbreak=↪
end

" From vim-misc: colorcolumn at 80
set colorcolumn=80

" From vim-misc: wildcard settings
set wildmode=list:longest
set wildignore+=.git,.hg,.svn
set wildignore+=*.pyc
set wildignore+=*.swp

" Customize session options
set sessionoptions="curdir,folds,help,options,tabpages,winsize"

" From nvim init.lua: netrw settings
let g:netrw_browse_split = 0
let g:netrw_banner = 0
let g:netrw_winsize = 25

syntax on

"----------------------------------------------------------------------
" GUI settings
"----------------------------------------------------------------------
if !has("gui_running")
    let &t_ut=''
endif
set guioptions=cegmt
if has("win32")
    set guifont=Inconsolata:h11
else
    set guifont=Monaco\ for\ Powerline:h12
endif
if exists("&fuopt")
    set fuopt+=maxhorz
endif

"----------------------------------------------------------------------
" Ensure directories exist
"----------------------------------------------------------------------
if !isdirectory(expand("~/.vim/undodir"))
    call mkdir(expand("~/.vim/undodir"), "p")
endif

"----------------------------------------------------------------------
" Key Mappings (nvim priority, vim-misc fills gaps)
"----------------------------------------------------------------------

" === FROM NVIM remap.lua (priority) ===

" File explorer (netrw)
nnoremap <leader>pv :Ex<CR>

" Move lines up/down in visual mode
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" Join lines and keep cursor position
nnoremap J mzJ`z

" Half-page jump and center
nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz

" Search and center
nnoremap n nzzzv
nnoremap N Nzzzv

" Paste over selection without losing register (greatest remap ever)
xnoremap <leader>p "_dP

" Yank to system clipboard
nnoremap <leader>y "+y
vnoremap <leader>y "+y
nnoremap <leader>Y "+Y

" Delete to void register
nnoremap <leader>d "_d
vnoremap <leader>d "_d

" Escape from insert with Ctrl-C
inoremap <C-c> <Esc>

" Disable Ex mode
nnoremap Q <nop>

" Tmux sessionizer
nnoremap <C-f> <cmd>silent !tmux neww tmux-sessionizer<CR>

" Quickfix list navigation
nnoremap <C-k> :cnext<CR>zz
nnoremap <C-j> :cprev<CR>zz
nnoremap <leader>k :lnext<CR>zz
nnoremap <leader>j :lprev<CR>zz

" Search and replace word under cursor
nnoremap <leader>s :%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>

" Make current file executable
nnoremap <silent> <leader>x :!chmod +x %<CR>

" Source current file
nnoremap <leader><leader> :source %<CR>

" === FROM VIM-MISC (gap fillers - not in nvim) ===

" Escape from insert mode with jj/jk variants
inoremap jj <esc>
inoremap jJ <esc>
inoremap Jj <esc>
inoremap JJ <esc>
inoremap jk <esc>
inoremap jK <esc>
inoremap Jk <esc>
inoremap JK <esc>

" Visual j/k movement (respects wrapping)
map j gj
map k gk

" cd to the directory containing the current file
nmap <leader>cd :cd %:h<CR>
nmap <leader>lcd :lcd %:h<CR>

" Shortcut to edit the vimrc
nmap <silent> <leader>vimrc :e ~/.vimrc<CR>

" Split navigation (using <C-h> and <C-l> since <C-j>/<C-k> are used for quickfix)
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

" Clear search highlights
noremap <silent><leader>/ :nohlsearch<cr>

" Command to write as root
cmap w!! %!sudo tee > /dev/null %

" Expand %% in command mode to current file directory
cnoremap %% <C-R>=expand('%:h').'/'<CR>

" SyncStack helper: show current syntax highlight groups
nmap <leader>sp :call <SID>SynStack()<CR>
function! <SID>SynStack()
    if !exists("*synstack")
        return
    endif
    echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
    echo map(synstack(line('.'), col('.')), 'synIDattr(synIDtrans(v:val), "name")')
endfunc

"----------------------------------------------------------------------
" Autocommands (from vim-misc)
"----------------------------------------------------------------------
" Clear trailing whitespace on save
autocmd BufWritePre * :%s/\s\+$//e

" Don't fold anything
autocmd BufWinEnter * set foldlevel=999999

"----------------------------------------------------------------------
" Plugin settings (from vim-misc)
"----------------------------------------------------------------------
" JavaScript & JSX
let g:jsx_ext_required = 0

" JSON: don't conceal
let g:vim_json_syntax_conceal = 0

" Default SQL type to PostgreSQL
let g:sql_type_default = 'pgsql'

"----------------------------------------------------------------------
" Vim-Plug plugin manager
"----------------------------------------------------------------------
" Auto-install vim-plug if not present
let data_dir = '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
    silent execute '!curl -fLo ' . data_dir . '/autoload/plug.vim --create-dirs '
        \ . 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

" Colorscheme (gruvbox to match nvim)
Plug 'morhetz/gruvbox'

" Fuzzy finder (vim alternative to Telescope)
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Git integration (same as nvim)
Plug 'tpope/vim-fugitive'

" Git signs in gutter
Plug 'airblade/vim-gitgutter'

" Status line (vim alternative to lualine)
Plug 'itchyny/lightline.vim'

" Undo tree (same as nvim)
Plug 'mbbill/undotree'

" Comment toggling (vim alternative to Comment.nvim)
Plug 'tpope/vim-commentary'

" Surround (useful vim plugin)
Plug 'tpope/vim-surround'

" Repeat plugin commands with .
Plug 'tpope/vim-repeat'

" Indent guides (vim alternative to indent-blankline)
Plug 'Yggdroot/indentLine'

" Copilot (same as nvim)
Plug 'github/copilot.vim'

call plug#end()

"----------------------------------------------------------------------
" Colorscheme (gruvbox to match nvim)
"----------------------------------------------------------------------
set background=dark
let g:gruvbox_contrast_dark = 'hard'
let g:gruvbox_transparent_bg = 1
let g:gruvbox_bold = 0
let g:gruvbox_italic = 1
silent! colorscheme gruvbox

" Transparent background
highlight Normal guibg=NONE ctermbg=NONE
highlight SignColumn guibg=NONE ctermbg=NONE

"----------------------------------------------------------------------
" Plugin keybindings
"----------------------------------------------------------------------

" FZF (analogous to Telescope in nvim)
nnoremap <leader>pf :Files<CR>
nnoremap <C-p> :GFiles<CR>
nnoremap <leader>ps :Rg<Space>
nnoremap <leader>vh :Helptags<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>l :Lines<CR>

" Undotree (same binding as nvim)
nnoremap <leader>u :UndotreeToggle<CR>

" Fugitive (same bindings as nvim)
nnoremap <leader>gs :Git<CR>
nnoremap <leader>gh :diffget //2<CR>
nnoremap <leader>gm :diffget //3<CR>
nnoremap <leader>gc :Git add .<CR>:Git commit<CR>

"----------------------------------------------------------------------
" Lightline config
"----------------------------------------------------------------------
let g:lightline = {
    \ 'colorscheme': 'gruvbox',
    \ 'active': {
    \   'left': [ [ 'mode', 'paste' ],
    \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ],
    \   'right': [ [ 'lineinfo' ],
    \              [ 'percent' ],
    \              [ 'fileformat', 'fileencoding', 'filetype' ] ]
    \ },
    \ 'component_function': {
    \   'gitbranch': 'FugitiveHead'
    \ },
    \ }

"----------------------------------------------------------------------
" IndentLine config
"----------------------------------------------------------------------
let g:indentLine_enabled = 1
let g:indentLine_char = '│'

"----------------------------------------------------------------------
" GitGutter config
"----------------------------------------------------------------------
let g:gitgutter_enabled = 1
set updatetime=100

"----------------------------------------------------------------------
" Filetype-specific settings (from vim-misc ftplugin)
"----------------------------------------------------------------------
augroup filetypes
    autocmd!
    autocmd FileType javascript setlocal shiftwidth=2 tabstop=2 softtabstop=2 expandtab
    autocmd FileType typescript setlocal shiftwidth=2 tabstop=2 softtabstop=2 expandtab
    autocmd FileType handlebars setlocal shiftwidth=2 tabstop=2 softtabstop=2 expandtab
    autocmd FileType ruby       setlocal shiftwidth=2 tabstop=2 softtabstop=2 nocursorline norelativenumber number
    autocmd FileType sh         setlocal shiftwidth=2 tabstop=2 softtabstop=2 expandtab
    autocmd FileType proto      setlocal shiftwidth=2 tabstop=2 softtabstop=2 expandtab
    autocmd FileType html       setlocal shiftwidth=4 tabstop=4 softtabstop=4 noexpandtab
    autocmd FileType go         setlocal shiftwidth=4 tabstop=4 softtabstop=4 noexpandtab
    autocmd FileType yaml       setlocal shiftwidth=4 tabstop=4 softtabstop=4 expandtab
augroup END

"----------------------------------------------------------------------
" Filetype detection (from vim-misc ftdetect)
"----------------------------------------------------------------------
augroup ftdetect_custom
    autocmd!
    autocmd BufRead,BufNewFile *.hcl        set filetype=hcl
    autocmd BufNewFile,BufRead *.md,*.markdown,*.mdown setl filetype=markdown
    autocmd BufRead,BufNewFile *.bats       set filetype=sh
    autocmd BufNewFile,BufRead *.asciidoc,*.asc setfiletype asciidoc
    autocmd BufRead,BufNewFile Vagrantfile  set filetype=ruby
augroup END
