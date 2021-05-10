
" Note: should not use augroup in ftdetect (see :help ftdetect)
au BufRead,BufNewFile *.u setfiletype u

au BufRead *.u call u#BeforeRead()
au BufWritePost *.u call u#ToRust()

au CursorMoved,CursorHold *.u  call u#ShowErrorMsg()

function! u#BeforeRead()

	hi uError ctermfg=9 guifg=Red
	call sign_define("uError", {
		\ "text" : ">>",
		\ "texthl" : "uError"})

	let prop_type = prop_type_get('uPropType')
	if empty(prop_type)
		call prop_type_add('uPropType', {'highlight': 'Error'})
	endif

	let s:last_line = -1
	let s:echoed_empty = 0

	call u#ToRust()

endfunction

function! u#ToRust()

	let l:cmd = "u u-compile"
	let l:output = system(l:cmd ." ". expand('%:p'))
	" let l:output = '[ { "lnum": 1,  "col": 1, "_width": 6, "text": "one" }, { "lnum": 10, "col": 9, "_width": 5, "text": "two" }, { "lnum": 30, "col": 9, "_width": 4, "text": "three" }, ]'
	let l:list = []
	if l:output != ""
		try
			let l:list = json_decode(l:output)
		catch /.*/
		endtry
	endif

	call sign_unplace('*', {'buffer' : "%"})
	call prop_remove({ "type": "uPropType", "all": 1 })
	for item in l:list
		call sign_place(0, '', 'uError', '%', { 'lnum': item.lnum })
		call prop_add(item.lnum, item.col, {'length': item._width, 'type': 'uPropType'})
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
