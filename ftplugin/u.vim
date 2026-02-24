if exists("b:did_ftplugin")
	finish
endif
let b:did_ftplugin = 1

augroup u.vim
	autocmd!
	au BufWritePost <buffer> call u#ToRust()
	au CursorMoved,CursorHold <buffer> call u#ShowErrorMsg()

	au BufWritePost */u.toml call u#ToCargoToml()
augroup END

" after entering <CR> followed by '.', if the above line doesn't have
" a leading '.', then prepend a <Tab> infront of the '.'
inoremap <silent> <buffer> . <C-R>=u#InsertDot()<CR>

call u#BeforeRead()
