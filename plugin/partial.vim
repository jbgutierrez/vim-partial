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

if exists("g:partial_templates") | call extend(s:templates, g:partial_templates) | endif

let s:templates_roots = [
      \ 'css',
      \ 'sass',
      \ 'styles',
      \ 'stylesheets',
      \ 'templates',
      \ 'views'
      \ ]
if exists("g:partial_templates_roots") | call extend(s:templates_roots, g:partial_templates_roots) | endif
let s:templates_roots_re = '\v(.*[\/])('.join(s:templates_roots, '|').')[\/]'

let s:use_splits = exists("g:partial_use_splits") ? g:partial_use_splits : 0
let s:keep_position = exists("g:partial_keep_position") ? g:partial_keep_position : 1
let s:vertical_split = exists("g:partial_vertical_split") ? g:partial_vertical_split : 0
let s:create_dirs = exists("g:partial_create_dirs") ? g:partial_create_dirs : 1

function! s:partial(bang) range abort
  let extension = expand('%:e')
  if !has_key(s:templates, extension)
    return s:error('Unsupported file type (see :help partial_templates)')
  endif
  let template = s:templates[extension]

  let filename = expand('%')
  let templates_root = expand('%:p:s?'.s:templates_roots_re.'.*?\1\2?')
  if templates_root == expand('%:p')
    return s:error("Destination path must be within a known root for templates (see :help partial_templates_roots)")
  endif
  let basename = expand('%:p:s?'.s:templates_roots_re.'(.*)?\3?:r:r')

  let partial_name = input('Partial name: ', basename, 'file')
  if partial_name == '' || partial_name == filename | return | endif

  let extensions = fnamemodify(filename, ':e:e')
  let partial_name = fnamemodify(partial_name, ':r:r').".".extensions

  if filereadable(partial_name) && !a:bang
    return s:error('E13: File exists')
  endif

  let folder = templates_root."/".fnamemodify(partial_name, ':h')
  if !isdirectory(folder)
    if s:create_dirs
      call mkdir(folder, 'p')
    else
      return s:error("Folder '".folder."' doesn't exists (see :help partial_create_dirs)")
    endif
  endif

  let first = a:firstline
  let last = a:lastline
  let range = first.",".last
  let spaces = matchstr(getline(first),'^\s*')
  let partial = fnamemodify(partial_name, ':r:r:s?'.s:templates_roots_re.'??:s?\v(.*)_([^/^.]+)[^/]*?\1\2?:s?\v\?/?g')

  let buf = @@
  let winnr = winnr()
  let autoindent = &autoindent
  let splitright = &splitright
  let splitbelow = &splitbelow
  let &autoindent = 0
  if s:keep_position
    let &splitright = 1
    let &splitbelow = 1
  end

  let replacement = printf(template, partial)
  silent! exe range."yank"
  silent! exe "normal! :".first.",".last."change\<cr>".spaces.replacement."\<cr>.\<cr>"

  if s:vertical_split | vnew | else | new | end

  silent! put
  0delete
  if spaces != ""
    silent! exe '%substitute/^'.spaces.'//'
  endif

  try
    silent! exe "w! ".templates_root."/".partial_name
  catch
    s:error('E80 Error while writing')
  endtry

  let &autoindent = autoindent
  let &splitright = splitright
  let &splitbelow = splitbelow
  if s:use_splits | exe winnr . "wincmd w" | else | close | endif
  let @@ = buf
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
  autocmd BufEnter * if &includeexpr == '' | setlocal includeexpr=substitute(v:fname,'\\v([^\\^/]+)$','_\\1','') | end
augroup END

" }}}

" vim:fen:fdm=marker:fmr={{{,}}}:fdl=0:fdc=1:ts=2:sw=2:sts=2
