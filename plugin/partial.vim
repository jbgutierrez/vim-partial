" =============================================================================
" File:          plugin/partial.vim
" Description:   Makes creating partials in your code a breeze!
" Author:        Javier Blanco <http://jbgutierrez.info>
" =============================================================================

if ( exists('g:loaded_partial') && g:loaded_partial ) || v:version < 700 || &cp
  finish
endif
let g:loaded_partial = 1

" Mappings {{{

if !hasmapto(':PartialExtract')
  vmap <unique> <leader>x :PartialExtract<cr>
endif

" }}}

" Functions {{{

function! s:error(str)
  echohl ErrorMsg
  echomsg a:str
  echohl None
  let v:errmsg = a:str
endfunction

function! s:debug(str)
  if exists("g:partial_debug") && g:partial_debug
    echohl Debug
    echomsg a:str
    echohl None
  endif
endfunction

function! s:sub(str,pat,rep)
  return substitute(a:str,'\v\C'.a:pat,a:rep,'')
endfunction

let s:templates = {
      \   'css'  : "@import url('%s');"   ,
      \   'dust' : '{> "%s" /}'           ,
      \   'erb'  : "<%%= render '%s' %%>" ,
      \   'haml' : "= render '%s'"        ,
      \   'html' : "<%%= render '%s' %%>" ,
      \   'less' : "@import '%s';"        ,
      \   'sass' : "@import '%s'"         ,
      \   'scss' : "@import '%s';"        ,
      \   'slim' : "== render '%s'"
      \ }

if exists("g:partial_templates")
  call extend(s:templates, g:partial_templates)
endif

function! s:partial(bang) range abort
  let extension = expand('%:e')
  if !has_key(s:templates, extension)
    return s:error('Unsupported file type')
  endif
  let template = s:templates[extension]

  let filename = expand('%')
  let basename = fnamemodify(filename, ':r:r')
  let partial_name = input('Partial name: ', basename, 'file')
  if partial_name == '' || partial_name == filename | return | endif

  let extensions = fnamemodify(filename, ':e:e')
  let partial_name = fnamemodify(partial_name, ':r:r:s?\v.*/(views|templates)/??').".".extensions

  if filereadable(partial_name) && !a:bang
    return s:error('E13: File exists')
  endif

  let folder = fnamemodify(partial_name, ':h')
  if !isdirectory(folder)
    call mkdir(folder, 'p')
  endif

  let first = a:firstline
  let last = a:lastline
  let range = first.",".last
  let spaces = matchstr(getline(first),'^\s*')
  let partial = fnamemodify(partial_name, ':r:r:s?\v(.*)_([^/^.]+)[^/]*?\1\2?')

  let buf = @@
  let ai = &ai
  let &ai = 0
  set splitright

  let replacement = printf(template, partial)
  silent! exe range."yank"
  silent! exe "normal! :".first.",".last."change\<cr>".spaces.replacement."\<cr>.\<cr>"

  vnew
  silent! put
  0delete
  if spaces != ""
    silent! exe '%substitute/^'.spaces.'//'
  endif

  try
    silent! exe "w! ".partial_name
  catch
    s:error('E80 Error while writing')
  endtry

  let &ai = ai
  let @@ = buf
  set nosplitright
  wincmd h
endfunction

"}}}

" Commands {{{

if !exists(":PartialExtract")
  command -bang -range PartialExtract <line1>,<line2>call <sid>partial(<bang>0)
endif

"}}}

" Autocommands {{{

augroup partialPluginAuto
  autocmd!
  autocmd BufEnter * exe "setlocal suffixesadd=.".expand('%:e')
augroup END

" }}}

" vim:fen:fdm=marker:fmr={{{,}}}:fdl=0:fdc=1:ts=2:sw=2:sts=2
