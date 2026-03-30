function! s:insert_license_slash()
  set formatoptions-=cro
  execute "normal! i// -------------------------------------------------------------------------------------------------"
  execute "normal! o// SPDX-License-Identifier: Apache-2.0"
  execute "normal! o// Copyright (C) 2026 Jayesh Badwaik <j.badwaik@fz-juelich.de>"
  execute "normal! o// -------------------------------------------------------------------------------------------------"
  normal! o
  set formatoptions+=cro
endfunction

function! s:insert_license_hash()
  set formatoptions-=cro
  execute "normal! i# --------------------------------------------------------------------------------------------------"
  execute "normal! o# SPDX-License-Identifier: Apache-2.0"
  execute "normal! o# Copyright (C) 2026 Jayesh Badwaik <j.badwaik@fz-juelich.de>"
  execute "normal! o# --------------------------------------------------------------------------------------------------"
  set formatoptions+=cro
endfunction

function! s:insert_license_percent()
  set formatoptions-=cro
  execute "normal! i% --------------------------------------------------------------------------------------------------"
  execute "normal! o% SPDX-License-Identifier: Apache-2.0"
  execute "normal! o% Copyright (C) 2026 Jayesh Badwaik <j.badwaik@fz-juelich.de>"
  execute "normal! o% --------------------------------------------------------------------------------------------------"
  set formatoptions+=cro
endfunction


function! s:insert_license_quote()
  set formatoptions-=cro
  execute "normal! i\" --------------------------------------------------------------------------------------------------"
  execute "normal! o\" SPDX-License-Identifier: Apache-2.0"
  execute "normal! o\" Copyright (C) 2026 Jayesh Badwaik <j.badwaik@fz-juelich.de>"
  execute "normal! o\" --------------------------------------------------------------------------------------------------"
  set formatoptions+=cro
endfunction

function! s:insert_license_html()
  set formatoptions-=cro
  execute "normal! i<!--"
  execute "normal! o- SPDX-License-Identifier: Apache-2.0"
  execute "normal! o- Copyright (C) 2026 Jayesh Badwaik <j.badwaik@fz-juelich.de>"
  execute "normal! o-->"
  set formatoptions+=cro
endfunction

function! Insert_license_slash()
  execute "normal! O"
  call s:insert_license_cpp()
endfunction

function! Insert_license_hash()
  execute "normal! O"
  call s:insert_license_hash()
endfunction

function! Insert_license_percent()
  execute "normal! O"
  call s:insert_license_percent()
endfunction

function! Insert_license_quote()
  execute "normal! O"
  call s:insert_license_quote()
endfunction

function! Insert_license_html()
  execute "normal! O"
  call s:insert_license_html()
endfunction

autocmd BufNewFile *.{cuh}          call <SID>insert_license_slash()
autocmd BufNewFile *.{cuhpp}        call <SID>insert_license_slash()
autocmd BufNewFile *.{h}            call <SID>insert_license_slash()
autocmd BufNewFile *.{c}            call <SID>insert_license_slash()
autocmd BufNewFile *.{hpp}          call <SID>insert_license_slash()
autocmd BufNewFile *.{cpp}          call <SID>insert_license_slash()
autocmd BufNewFile *.{cu}           call <SID>insert_license_slash()
autocmd BufNewFile *.{ipp}          call <SID>insert_license_slash()
autocmd BufNewFile *.{rs}           call <SID>insert_license_slash()

autocmd BufNewFile CMakeLists.txt   call <SID>insert_license_hash()
autocmd BufNewFile *.cmake          call <SID>insert_license_hash()
autocmd BufNewFile *.{sh}           call <SID>insert_license_hash()
autocmd BufNewFile *.{py}           call <SID>insert_license_hash()
autocmd BufNewFile *.{toml}           call <SID>insert_license_hash()
autocmd BufNewFile *.{yml}           call <SID>insert_license_hash()

autocmd BufNewFile *.{md} call <SID>insert_license_html()

autocmd BufNewFile *.{tex} call <SID>insert_license_percent()
autocmd BufNewFile *.{sty} call <SID>insert_license_percent()
autocmd BufNewFile *.{cls} call <SID>insert_license_percent()

" Remove Trailing Whitespace on Save
autocmd BufWritePre * %s/\s\+$//e

" Show trailing whitespace:
highlight ExtraWhitespace ctermbg=red guibg=red
autocmd ColorScheme * highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/

function! Insert_header_guard()
  execute "normal! O"
  call s:insert_header_guard()
endfunction


autocmd BufNewFile *.{cuh}          call <SID>insert_header_guard()
autocmd BufNewFile *.{cuhpp}        call <SID>insert_header_guard()
autocmd BufNewFile *.{h}            call <SID>insert_header_guard()
autocmd BufNewFile *.{hpp}          call <SID>insert_header_guard()
autocmd BufNewFile *.{hip}          call <SID>insert_header_guard()

" VimTeX Specific Config
let g:tex_flavor = 'latex'
" Local Leader
:let maplocalleader = "\\"
:let g:vimtex_view_method = 'zathura'
:let g:vimtex_quickfix_mode = 0

let g:vimtex_compiler_latexmk_engines = {
      \ '_' : '-lualatex'
      \}

if !exists('g:ycm_semantic_triggers')
  let g:ycm_semantic_triggers = {}
endif
let g:ycm_semantic_triggers.tex = g:vimtex#re#youcompleteme
noremap <C-S-k> :VimtexTocOpen <CR>

let g:vimtex_toc_config = {
      \ 'split_width' : '100'
      \}

let g:vimtex_compiler_latexmk = {
      \ 'backend' : 'jobs',
      \ 'background' : 1,
      \ 'build_dir' : './tmp/livepreview',
      \ 'aux_dir' : './tmp/livepreview',
      \ 'callback' : 1,
      \ 'continuous' : 1,
      \ 'executable' : 'latexmk',
      \ 'options' : [
      \   '-lualatex',
      \   '-silent',
      \   '-synctex=1',
      \   '-interaction=nonstopmode',
      \   '-cd'
      \ ]
      \}

let g:vimtex_view_automatic=0

function VimtexErrorDisplay(status)
  sign define piet text=>> texthl=ErrorMsg
  let nl = line('$')
  let l=1
  while l <= nl
    if a:status == 0
      exe "sign place ". l . " line=" . l . " name=piet file=".expand("%:p")
    else
      exe "sign unplace " .l
    endif
    let l += 1
  endwhile
endfunction

augroup filetypedetect
  au BufRead,BufNewFile *.tikz set filetype=tex
augroup END

