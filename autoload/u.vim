let s:last_line = -1
let s:echoed_empty = 0

function! u#BeforeRead()
	" NOTE: useless
	" let l:cmd = "u u-fix-mod " . expand("%:p")
	" let job = job_start(l:cmd)

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
	call ale#engine#CleanupEveryBuffer()
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

" add redraw to supress 'Press enter to continue' in echom
function! u#ToCargoToml()
	redraw | echom "syncing..."
	let l:cmd = "u u-sync " . expand("%:p")
	let job = job_start(l:cmd, {'close_cb': 'u#ToCargoTomlCb'})
endfunction

function! u#ToCargoTomlCb(ch)
	redraw | echom "sync done"
endfunction

" ------------------------------------------------------------
func! u#InsertDot()
	let cur_line = getline('.')
	let pos = col('.')
	let before = trim(strpart(cur_line, 0, pos))

	if len(before) != 0
		" for ... in struct short init expression, reduce indent
		if len(before) == 2 && before == '..'
			return ".\<Esc>\<\<A"
		end
		return "."
	end

	let above_line = trim(getline(line('.') - 1))
	if len(above_line) == 0
		return "."
	end

	" for struct rest
	" a {
	"   ...b,
	" }
	"
	" for import
	" {
	" }
	" ..b
	let above_last = above_line[len(above_line) - 1]
	if above_last == ',' || above_last == '{' || above_last == '}'
		return "."
	end

	if above_line[0] != '.'
		return "\<Tab>."
	end

	return "."
endf
