augroup u.toml.vim
	autocmd!
	au BufReadCmd *.rs call u#AutoOpen()
augroup END
