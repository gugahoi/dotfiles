call plug#begin(expand('~/.vim/bundle'))
" Use single quotes

Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/nerdtree'
Plug 'tpope/vim-fugitive'
Plug 'fatih/vim-go'
Plug 'shougo/neocomplete.vim'
Plug 'majutsushi/tagbar'
Plug 'SirVer/ultisnips'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'vim-airline/vim-airline'
Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf.vim'
call plug#end()

" Auto Start NerdTREE
" autocmd vimenter * NERDTree
nmap <F6> :NERDTreeToggle<CR>
" Go to document window
autocmd VimEnter * wincmd p

" Auto Start Neocomplete
let g:neocomplete#enable_at_startup = 1

" TagbarToggle
nmap <F8> :TagbarToggle<CR>

" Go Keybinding
" Tests
autocmd FileType go nmap <leader>t  <Plug>(go-test)
" Run
autocmd FileType go nmap <leader>r  <Plug>(go-run)

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

" Fix Backspace mapping so it actually deletes
:set backspace=indent,eol,start

" Highlight
let g:go_highlight_functions = 1  
let g:go_highlight_methods = 1  
let g:go_highlight_structs = 1  
let g:go_highlight_operators = 1  
let g:go_highlight_build_constraints = 1  

" Neocomplete: Use smartcase.
let g:neocomplete#enable_smart_case = 1

" disable preview on autocomplete
set completeopt-=preview

" indentation
set expandtab
set autoindent
set smartindent
set tabstop=2
set softtabstop=2
set shiftwidth=2


" Highligh chars in lines that are longer than 80 chars
highlight ColorColumn ctermfg=1 ctermbg=NONE
autocmd BufRead,BufNewFile *.md setlocal textwidth=80
let &colorcolumn=join(range(80,999),",")
highlight LineNr ctermfg=8

" Line numbers
set number

" Bindings for fzf (https://github.com/junegunn/fzf.vim)
nmap <leader>f :Files<cr>|     " fuzzy find files in the working directory (where you launched Vim from)
nmap <leader>/ :BLines<cr>|    " fuzzy find lines in the current file
nmap <leader>b :Buffers<cr>|   " fuzzy find an open buffer
nmap <leader>r :Rg |           " fuzzy find text in the working directory
nmap <leader>c :Commands<cr>|  " fuzzy find Vim commands (like Ctrl-Shift-P in Sublime/Atom/VSC)
