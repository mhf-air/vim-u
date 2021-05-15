
" Note: should not use augroup in ftdetect (see :help ftdetect)
au BufRead,BufNewFile *.u setfiletype u

au BufRead *.u call u#BeforeRead()
au BufWritePost *.u call u#ToRust()

au CursorMoved,CursorHold *.u  call u#ShowErrorMsg()

function! u#BeforeRead()

	hi uError ctermfg=9 ctermbg=235 guifg=Red
	hi uWarning ctermfg=11 ctermbg=235 guifg=Yellow
	hi uSymbol ctermfg=9
	hi uKeyword ctermfg=172

	call sign_define("uError", {
		\ "text" : ">>",
		\ "texthl" : "uError"})
	call sign_define("uWarning", {
		\ "text" : "--",
		\ "texthl" : "uWarning"})

	let uPropError = prop_type_get('uPropError')
	if empty(uPropError)
		call prop_type_add('uPropError', {'highlight': 'Error'})
	endif
	let uPropWarning = prop_type_get('uPropWarning')
	if empty(uPropWarning)
		call prop_type_add('uPropWarning', {'highlight': 'SpellCap'})
	endif

	let s:last_line = -1
	let s:echoed_empty = 0

	call u#ToRust()

	" Syntax highlighting breaks less often.
	syntax sync fromstart

endfunction

function! u#ToRust()

	let l:cmd = "u u-compile"
	let l:output = system(l:cmd ." ". expand('%:p'))
	" let l:output = '[ { "lnum": 1,  "col": 1, "_width": 6, "text": "one" }, { "lnum": 10, "col": 9, "_width": 5, "text": "two" }]'
	let l:list = []
	if l:output != ""
		try
			let l:list = json_decode(l:output)
		catch /.*/
		endtry
	endif

	call sign_unplace('*', {'buffer' : "%"})
	call prop_remove({ "type": "uPropError", "all": 1 })
	for item in l:list
		call sign_place(0, '', 'uError', '%', { 'lnum': item.lnum })
		call prop_add(item.lnum, item.col, {'length': item._width, 'type': 'uPropError'})
	endfor

	call setloclist(0, l:list, 'r')

endfunction

function! u#ShowErrorMsg()

	let l:line = line(".")
	if l:line == s:last_line
		return
	endif

	let l:list = getloclist(0)
	let l:msg = ""

	let l:i = 0
	for item in l:list
		if item.lnum == l:line
			let l:msg = l:list[l:i].text
			break
		endif
		let l:i = l:i + 1
	endfor

	if l:msg != ""
		echo l:msg
		let s:echoed_empty = 0
	elseif !s:echoed_empty
		echo ""
		let s:echoed_empty = 1
	endif

endfunction
