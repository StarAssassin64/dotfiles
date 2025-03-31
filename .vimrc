": Keybindings
let mapleader = " "
nmap <BAR> :vsplit<CR>
nmap _ :split<CR>
nmap <leader>t :term<CR>
nmap <leader>gg :! lazygit<CR>

": Design Elements
set expandtab shiftwidth=4 tabstop=4 number

": Python Settings
autocmd FileType python command CoverageRunAndDisplay :! coverage run -m pytest -vv && coverage report -m
autocmd FileType python command FlaskRun :! Flask Run

": Makefile Settings
autocmd FileType make setlocal noexpandtab
if filereadable("./Makefile")
    command RunMake :! make
endif

": C++ Settings
autocmd FileType cpp command DbgComp :! g++ -o programdbg ./* -g
autocmd FileType cpp command CompRun :! g++ -o program ./* && ./program
autocmd FileType cpp command gdb :! gdb ./programdbg


": Plugin Settings
let data_dir = '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()
Plug 'arcticicestudio/nord-vim'
Plug 'scrooloose/nerdtree'
Plug 'plasticboy/vim-markdown'
Plug 'kien/rainbow_parentheses.vim'
Plug 'vim-airline/vim-airline'
call plug#end()

": Colorscheme
colorscheme nord

": Rainbow Parentheses Settings
au VimEnter * RainbowParenthesesToggle
au Syntax * RainbowParenthesesLoadRound
au Syntax * RainbowParenthesesLoadSquare
au Syntax * RainbowParenthesesLoadBraces
