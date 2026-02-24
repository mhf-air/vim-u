" only run for specific toml files
if expand('%:t') != 'u.toml'
	finish
endif

augroup u.toml.vim
	autocmd!
	au BufWritePost */u.toml call u#ToCargoToml()
augroup END
