let s:last_line = -1
let s:echoed_empty = 0

function! u#BeforeRead()
	" NOTE: useless
	" let l:cmd = "u u-fix-mod " . expand("%:p")
	" let l:job = job_start(l:cmd)

	call sign_define("uError", {
		\ "text" : ">>",
		\ "texthl" : "uError"})
	call sign_define("uWarning", {
		\ "text" : "--",
		\ "texthl" : "uWarning"})

	let l:uPropError = prop_type_get('uPropError')
	if empty(l:uPropError)
		call prop_type_add('uPropError', {'highlight': 'Error'})
	endif
	let l:uPropWarning = prop_type_get('uPropWarning')
	if empty(l:uPropWarning)
		call prop_type_add('uPropWarning', {'highlight': 'SpellCap'})
	endif

	let s:last_line = -1
	let s:echoed_empty = 0

	call u#ToRust()

	" Syntax highlighting breaks less often.
	syntax sync fromstart

endfunction

function! u#ToRust()
	let l:file = expand('%:p')
	let l:cmd = ["u", "u-compile", l:file]
	call job_start(l:cmd, {
		\ 'close_cb': {ch -> u#HandleCompileOutput(ch)},
		\ 'out_mode': 'nl'
		\ })
endfunction

function! u#HandleCompileOutput(channel)
	let l:output = ""
	" Read everything from the stdout channel
	while ch_status(a:channel, {'part': 'out'}) == 'buffered'
		let l:output .= ch_read(a:channel)
	endwhile

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

	" to be honest, I don't know why I added this line
	" call ale#engine#CleanupEveryBuffer()

	for l:it in l:list
		call sign_place(0, '', 'uError', '%', { 'lnum': l:it.lnum })
		call prop_add(l:it.lnum, l:it.col, {'length': l:it._width, 'type': 'uPropError'})
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
	for l:it in l:list
		if l:it.lnum == l:line
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
	let l:job = job_start(l:cmd, {'close_cb': 'u#ToCargoTomlCb'})
endfunction

function! u#ToCargoTomlCb(ch)
	redraw | echom "sync done"
endfunction

" ------------------------------------------------------------
func! u#InsertDot()
	let l:cur_line = getline('.')
	let l:pos = col('.')
	let l:before = trim(strpart(l:cur_line, 0, l:pos))

	if len(l:before) != 0
		" for ... in struct short init expression, reduce indent
		if len(l:before) == 2 && l:before == '..'
			return ".\<Esc>\<\<A"
		end
		return "."
	end

	let l:above_line = trim(getline(line('.') - 1))
	if len(l:above_line) == 0
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
	let l:above_last = l:above_line[len(l:above_line) - 1]
	if l:above_last == ',' || l:above_last == '{' || l:above_last == '}'
		return "."
	end

	if l:above_line[0] != '.'
		return "\<Tab>."
	end

	return "."
endf

func! u#DeriveDebug()
	if v:char ==# '('
		let l:line_num = line(".")
		let l:line_text = getline(line_num)
		if empty(l:line_text)
			return
		endif
		if l:line_text[-7:] ==# " struct" && l:line_text[0:1] !=# "//"
			" defer to prevent modification error
			call timer_start(0, { -> s:DoDeriveDebug(l:line_num, l:line_text) })
		endif
	elseif v:char ==# '{'
		let l:line_num = line(".")
		let l:line_text = getline(line_num)
		if empty(l:line_text)
			return
		endif
		if (l:line_text[-8:] ==# " struct " || l:line_text[-6:] ==# " enum ")
				\ && l:line_text[0:1] !=# "//"
			" defer to prevent modification error
			call timer_start(0, { -> s:DoDeriveDebug(l:line_num, l:line_text) })
		endif
	end
endf
func! s:DoDeriveDebug(line_num, line_text)
	let l:indent = matchstr(a:line_text, '^\s*')
	call append(a:line_num - 1, l:indent .. "#[derive(Debug)]")
endf

func! u#AddPubCrate(type = '')
	s/^\s*\k\+/&^/
endf
func! u#AddPub(type = '')
	s/^\s*\k\+/&+/
endf
func! u#AddMut()
	s/^\s*\k\+/& mut/
endf

func! u#OnNormalO()
	" check if current line starts with optional whitespace followed by '//'
	let l:line = getline(".")
	if l:line =~# '^\s*//'
		if l:line =~# '^\s*///'
			return "o" . "/// "
		endif
		if l:line =~# '^\s*//!'
			return "o" . "//! "
		endif
		return "o" . "// "
	endif
	return "o"
endf

function! u#OnInsertEnter()
	let l:line = getline(".")
	if l:line =~# '^\s*//'
		if l:line =~# '^\s*///'
			return "\<CR>" . "/// "
		endif
		if l:line =~# '^\s*//!'
			return "\<CR>" . "//! "
		endif
		return "\<CR>" . "// "
	endif
	return "\<CR>"
endfunction
