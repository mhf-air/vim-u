" 1. Only run for specific toml files (optional)
if expand('%:t') != 'u.toml'
	finish
endif

" 2. Load your 'u' logic
runtime! ftplugin/u.vim
