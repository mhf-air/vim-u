if exists("b:did_ftplugin")
	finish
endif
let b:did_ftplugin = 1

augroup u.vim
	autocmd!
	au BufWritePost <buffer> call u#ToRust()
	au CursorMoved,CursorHold <buffer> call u#ShowErrorMsg()
	au InsertCharPre <buffer> call u#DeriveDebug()
augroup END

" after entering <CR> followed by '.', if the above line doesn't have
" a leading '.', then prepend a <Tab> infront of the '.'
inoremap <silent> <buffer> . <C-R>=u#InsertDot()<CR>

" allow repeat by '.'
nnoremap <silent> <buffer> <leader>^ :set operatorfunc=u#AddPubCrate<CR>g@l
nnoremap <silent> <buffer> <leader>+ :set operatorfunc=u#AddPub<CR>g@l
nnoremap <silent> <buffer> <leader>am :call u#AddMut()<CR>

" continue in comment when starting a new line from a line in comment
nnoremap <silent> <buffer> <expr> o u#OnNormalO()
inoremap <silent> <buffer> <expr> <CR> u#OnInsertEnter()

" auto add #[derive(Debug)] for struct and enum
" use iabbrev instead of InsertCharPre, because there might be WhereClause after 'struct'
iabbrev <buffer> <expr> struct u#DeriveDebugOther("struct")
iabbrev <buffer> <expr> enum u#DeriveDebugOther("enum")

call u#BeforeRead()
