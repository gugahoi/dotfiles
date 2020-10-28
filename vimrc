call plug#begin(expand('~/.vim/bundle'))

" Generic Plugins
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'scrooloose/nerdcommenter'
Plug 'vim-airline/vim-airline'
Plug 'tpope/vim-surround'

" Linting Plugin
"Plug 'dense-analysis/ale'

" Git Utils
" Plug 'tpope/vim-fugitive'

" Go Plugins
Plug 'fatih/vim-go'

" File mgmt
Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf.vim'

" JS Plugins
Plug 'pangloss/vim-javascript'
Plug 'MaxMEllon/vim-jsx-pretty'
Plug 'mattn/emmet-vim'

" Typescript
"Plug 'leafgarland/typescript-vim'
"Plug 'lanks/vim-tsx'

" Time mgmt
Plug 'wakatime/vim-wakatime'

" Documentation
Plug 'rizzatti/dash.vim'

" Indentation Coloring
Plug 'Yggdroot/indentLine'

" Color scheme
Plug 'morhetz/gruvbox'
call plug#end()

colo gruvbox
" dark mode
set bg=dark

" Go Keybinding
" Tests
autocmd FileType go nmap <leader>t  <Plug>(go-test)

" run :GoBuild or :GoTestCompile based on the go file
function! s:build_go_files()
  let l:file = expand('%')
  if l:file =~# '^\f\+_test\.go$'
    call go#cmd#Test(0, 1)
  elseif l:file =~# '^\f\+\.go$'
    call go#cmd#Build(0)
  endif
endfunction

autocmd FileType go nmap <leader>b :<C-u>call <SID>build_go_files()<CR>

" Auto Add Imports when saving go files
let g:go_fmt_command = "goimports"
" Disable autocompletion through vim-go (coc will be doing that for us)
let g:go_code_completion_enabled = 0

" Fix Backspace mapping so it actually deletes
set backspace=indent,eol,start

" Highlight
let g:go_highlight_functions = 1  
let g:go_highlight_methods = 1  
let g:go_highlight_structs = 1  
let g:go_highlight_operators = 1  
let g:go_highlight_build_constraints = 1  

" indentation
set expandtab
set autoindent
set smartindent
set tabstop=2
set softtabstop=2
set shiftwidth=2

" Fix backspace indent
set backspace=indent,eol,start

" Tabs. May be overridden by autocmd rules
set tabstop=4
set softtabstop=0
set shiftwidth=4
set expandtab

" Always show sign column
set signcolumn=yes

" Highlight chars in lines that are longer than 80 chars
highlight ColorColumn ctermfg=1 ctermbg=NONE
autocmd BufRead,BufNewFile *.md setlocal textwidth=81
let &colorcolumn=join(range(81,999),",")
highlight LineNr ctermfg=8

" Line numbers
set number
set relativenumber

" Bindings for fzf (https://github.com/junegunn/fzf.vim)
nmap <leader>f :Files<cr>|     " fuzzy find files in the working directory (where you launched Vim from)
nmap <leader>/ :BLines<cr>|    " fuzzy find lines in the current file
nmap <leader>b :Buffers<cr>|   " fuzzy find an open buffer
nmap <leader>r :Rg |           " fuzzy find text in the working directory
nmap <leader>c :Commands<cr>|  " fuzzy find Vim commands (like Ctrl-Shift-P in Sublime/Atom/VSC)

"Recovery commands from history through FZF
nmap <leader>y :History:<CR>

" JSX Config
let g:vim_jsx_pretty_colorful_config = 1

" ALE Linter options
let b:ale_fixers = {'javascript': ['prettier', 'eslint']}
" ALE Show errors/Warnings in status line
let g:airline#extensions#ale#enabled = 1

"" Rewrite capital commands for the shift holders like me
cnoreabbrev W! w!
cnoreabbrev Q! q!
cnoreabbrev Qall! qall!
cnoreabbrev Wq wq
cnoreabbrev Wa wa
cnoreabbrev wQ wq
cnoreabbrev WQ wq
cnoreabbrev W w
cnoreabbrev Q q
cnoreabbrev Qall qall

" Avoid unintentional switches to Ex mode.
nnoremap Q <nop>

"  Alternatively, use ; instead of : to insert commands
nnoremap ; :

" CocVim
inoremap <silent><expr> <TAB>
  \ pumvisible() ? coc#_select_confirm() :
  \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
  \ <SID>check_back_space() ? "\<TAB>" :
  \ coc#refresh()

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

let g:coc_snippet_next = '<tab>'
let g:coc_global_extensions = [ 
    \'coc-json', 
    \'coc-tsserver',
    \'coc-emmet',
    \'coc-eslint', 
    \'coc-prettier'
\]

"" Enable hidden buffers
set hidden

"" Searching
set hlsearch
set incsearch
set ignorecase
set smartcase

"" Disable the blinking cursor.
set gcr=a:blinkon0
set scrolloff=3

" Search mappings: These will make it so that going to the next one in a
" search will center on the line it's found in.
nnoremap n nzzzv
nnoremap N Nzzzv

" Switching windows
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l

" Disable arrow keys
noremap <Up> <Nop>
noremap <Down> <Nop>
noremap <Left> <Nop>
noremap <Right> <Nop>

noremap <C-h> <C-w>h
