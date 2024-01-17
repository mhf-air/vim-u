" cloned and modified from https://github.com/fatih/vim-go

" Check if tagbar is installed under plugins or is directly under rtp
" this covers pathogen + Vundle/Bundle
"
" Also make sure the ctags command exists
"
if !executable('ctags')
  finish
elseif globpath(&rtp, 'plugin/tagbar.vim') == ""
  finish
endif

" don't spam the user when Vim is started in Vi compatibility mode
let s:cpo_save = &cpo
set cpo&vim

if !exists("g:u_tags_bin")
  let g:u_tags_bin = "utags"
endif


function! s:SetTagbar()
  let bin_path = g:u_tags_bin
  if empty(bin_path)
	  return
  endif

  if !exists("g:tagbar_type_u")
	  let g:tagbar_type_u = {
	  	  \ 'ctagstype' : 'u',
	  	  \ 'kinds'     : [
	  	  \ 'r:macros',
	  	  \ 'c:constants',
	  	  \ 'v:variables',
	  	  \ 'a:aliases',
	  	  \ 't:types',
	  	  \ 'n:interfaces',
	  	  \ 'w:fields',
	  	  \ 'm:methods',
	  	  \ 'f:functions'
	  	  \ ],
	  	  \ 'sro' : '..',
	  	  \ 'kind2scope' : {
	  	  \ 't' : 'ctype',
	  	  \ 'n' : 'ntype'
	  	  \ },
	  	  \ 'scope2kind' : {
	  	  \ 'ctype' : 't',
	  	  \ 'ntype' : 'n'
	  	  \ },
	  	  \ 'ctagsbin'  : bin_path,
	  	  \ 'ctagsargs' : '-sort -silent'
	  	  \ }
  endif
endfunction


call s:SetTagbar()

" restore Vi compatibility settings
let &cpo = s:cpo_save
unlet s:cpo_save

" vim: sw=2 ts=2 et
