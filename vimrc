call plug#begin(expand('~/.vim/bundle'))

" Generic Plugins
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'rodrigore/coc-tailwind-intellisense', {'do': 'npm install'}
"Plug 'tpope/vim-surround'
Plug 'scrooloose/nerdcommenter'
Plug 'vim-airline/vim-airline'
Plug 'machakann/vim-sandwich'
Plug 'jiangmiao/auto-pairs'
Plug 'skywind3000/asyncrun.vim'
"Plug 'ms-jpq/coq_nvim', {'branch': 'coq'}

" Snippets
"Plug 'ms-jpq/coq.artifacts', {'branch': 'artifacts'}

" Git Utils
Plug 'tpope/vim-fugitive'

" Go Plugins
"Plug 'fatih/vim-go'

" Swift
Plug 'keith/swift.vim'

" File mgmt
"Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim' 

" JS Plugins
"Plug 'pangloss/vim-javascript'
"Plug 'MaxMEllon/vim-jsx-pretty'
"Plug 'mattn/emmet-vim'

" Typescript
"Plug 'leafgarland/typescript-vim'
"Plug 'ianks/vim-tsx'
Plug 'HerringtonDarkholme/yats.vim'
Plug 'peitalin/vim-jsx-typescript'

" Time mgmt
Plug 'wakatime/vim-wakatime'

" Documentation
"Plug 'rizzatti/dash.vim'

" Indentation Coloring
Plug 'Yggdroot/indentLine'

Plug 'machakann/vim-highlightedyank'

" Color scheme
"Plug 'morhetz/gruvbox'
Plug 'ayu-theme/ayu-vim'

" Tests
Plug 'vim-test/vim-test'

" Autocomplete Machine Learning
Plug 'github/copilot.vim'

" Pretty Quick Fix List
Plug 'https://gitlab.com/yorickpeterse/nvim-pqf.git'
call plug#end()

" Gruvbox settings
"colo gruvbox
"set bg=dark

" vim-sandwich
let g:sandwich#recipes = deepcopy(g:sandwich#default_recipes)

" Ayu Settings
set termguicolors
let ayucolor="dark"   
colo ayu

" indentation
set expandtab
set autoindent
set smartindent
set tabstop=2
set softtabstop=2
set shiftwidth=2

" Fix backspace indent
set backspace=indent,eol,start

" Always show sign column
set signcolumn=number

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

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
nmap <leader>r :Rg<cr>|           " fuzzy find text in the working directory
nmap <leader>c :Commands<cr>|  " fuzzy find Vim commands (like Ctrl-Shift-P in Sublime/Atom/VSC)
nmap <leader>y :History:<CR>

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

"" Enable hidden buffers
set hidden

"" Searching
set hlsearch
set incsearch
set ignorecase
set smartcase

"" Disable the blinking cursor.
set gcr=a:blinkon0
set scrolloff=8

" Search mappings: These will make it so that going to the next one in a
" search will center on the line it's found in.
nnoremap n nzzzv
nnoremap N Nzzzv

nmap <space>c :copen<CR>

"""""""""""""""""""""
" COC Configuration "
"""""""""""""""""""""
"
" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Applying codeAction to the selected region.
nmap <silent> ga <Plug>(coc-codeaction)
nmap <silent> <space>qf  <Plug>(coc-fix-current)

" Applying codeAction to the selected region.
xmap <silent> <C-a> <Plug>(coc-codeaction-selected)
nmap <silent> <C-a> <Plug>(coc-codeaction-selected)

" Symbol renaming.
nmap <space>r <Plug>(coc-rename)
nmap <space>f :CocFix<CR>
nmap <space>o :CocCommand editor.action.organizeImport<CR>

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Test Running
" these "Ctrl mappings" work well when Caps Lock is mapped to Ctrl
nmap <silent> t<C-n> :TestNearest<CR>
nmap <silent> t<C-f> :TestFile<CR>
nmap <silent> t<C-s> :TestSuite<CR>
nmap <silent> t<C-l> :TestLast<CR>
nmap <silent> t<C-g> :TestVisit<CR>
"let test#strategy = "neovim"

" Automatically run tests on save if available
"augroup test
  "autocmd!
  "autocmd BufWrite * if test#exists() |
    "\   TestFile |
    "\ endif
"augroup END

" Create directories on Save
" source: https://vi.stackexchange.com/a/679
augroup Mkdir
  autocmd!
  autocmd BufWritePre * call mkdir(expand("<afile>:p:h"), "p")
augroup END

" Switching windows
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l
noremap <C-h> <C-w>h

" Disable arrow keys
noremap <Up> <Nop>
noremap <Down> <Nop>
noremap <Left> <Nop>
noremap <Right> <Nop>

let g:airline#extensions#tabline#enabled = 0

lua require('pqf').setup()
