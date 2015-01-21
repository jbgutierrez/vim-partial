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

function! s:partial(bang) range abort
  let templates = {
        \   'css'  : "@import url('%s');"   ,
        \   'dust' : '{> "%s" /}'           ,
        \   'erb'  : "<%%= render '%s' %%>" ,
        \   'haml' : "= render '%s'"        ,
        \   'html' : "<%%= render '%s' %%>" ,
        \   'sass' : "@import '%s'"         ,
        \   'scss' : "@import '%s';"        ,
        \   'slim' : "== render '%s'"
        \ }

  if exists("g:partial_templates")
    call extend(templates, g:partial_templates)
  endif

  let fname = expand('%')
  let extension = fnamemodify(fname, ":e")
  if !has_key(templates, extension)
    return s:error('Unsupported file type')
  endif

  let template = templates[extension]
  let pname = input('Partial name: ', fnamemodify(fname, ":r"), 'file')

  if pname == '' || pname == fname
    return
  endif

  if extension != fnamemodify(pname, ':e')
    let pname .= '.'.extension
  endif

  if filereadable(pname) && !a:bang
    return s:error('E13: File exists')
  endif

  if !isdirectory(fnamemodify(pname, ':h'))
    call mkdir(fnamemodify(pname, ':h'), 'p')
  endif

  let first = a:firstline
  let last = a:lastline
  let range = first.",".last
  let spaces = matchstr(getline(first),'^\s*')
  let partial = fnamemodify(pname, ':r:s?\v.*/(views|templates)/??')

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
    silent! exe "w! ".pname
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
