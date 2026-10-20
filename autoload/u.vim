let s:last_line = -1
let s:echoed_empty = 0

function! s:init_var(var, value) abort
	if !exists('g:u_' . a:var)
		execute 'let g:u_' . a:var . ' = ' . string(a:value)
	endif
endfunction

function! s:setup_options() abort
	let options = [
		\ ['dir_rs', []],
		\ ['dir_writable', []],
	\ ]
	for [opt, val] in options
		call s:init_var(opt, val)
		unlet val
	endfor
endfunction

function! u#BeforeRead()
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

	" define other prop types
	if empty(prop_type_get("error_hint"))
		call prop_type_add('error_hint', {'highlight': 'uError2'})
	endif
endfunction

function! u#ToRust()
	let l:file = expand('%:p')
	let l:cmd = ["u", "to-rs", l:file]
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

func! u#DeriveDebugOther(keyword)
	let l:line_num = line(".")
	let l:line_text = getline(line_num)
	if l:line_text[0:1] !=# "//"
		" defer to prevent modification error
		call timer_start(0, { -> s:DoDeriveDebug(l:line_num, l:line_text) })
	endif
	return a:keyword
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
	endif
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

" ------------------------------------------------------------------------------
" auto open some-path/.*.u when opening some-path/*.rs
function! u#AutoOpen()
	let l:file_full = expand('<afile>:p')
	call s:AutoOpenInner(l:file_full)
endfunction

function! s:AutoOpenInner(file_full)
	call s:setup_options()

	let l:dir = fnamemodify(a:file_full, ':h')
	let l:file = fnamemodify(a:file_full, ':t')
	let l:target = l:dir . '/.' . substitute(l:file, '\.rs$', '.u', '')

	if exists("t:open_rs_directly")
		call u#OpenRs()
		return
	endif

	" open .rs file directly
	for l:d in g:u_dir_rs
		if StringStartsWith(l:dir, expand(l:d))
			call u#OpenRs()
			return
		endif
	endfor

	" if rs-to-u fails, open *.rs file directly
	let l:output = system("u r-u ". a:file_full . " " . l:target)
	if l:output != ""
		call u#OpenRs()
		return
	endif

	" writable
	let l:writable = 0
	for l:d in g:u_dir_writable
		if StringStartsWith(l:dir, expand(l:d))
			let l:writable = 1
			break
		endif
	endfor
	if !l:writable
		call system("chmod 444 " . l:target)
	endif

	" open .u file
	execute 'edit ' . fnameescape(l:target)
	execute 'filetype detect'
	" explicitly kickstart ALE for this new buffer if it's installed
	if exists(':ALELint') == 2
		ALELint
	endif
	execute 'bdelete #'

	let t:mhf_ops = []
	call insert(t:mhf_ops, { "name": "open .rs", "f": "u#OpenRsFromU" }, 0)
endfunction

" open .rs directly from .u file
function! u#OpenRsFromU()
	let l:dir = expand("%:p:h")
	let l:file = expand("%:p:t")
	let l:target = l:dir . '/' . l:file[1:(len(l:file) - 3)] . '.rs'
	let t:open_rs_directly = 0
	execute 'edit ' . fnameescape(l:target)

	let t:mhf_ops = []
	call insert(t:mhf_ops, { "name": "open .u", "f": "u#OpenUFromRs" }, 0)
endfunction

" open .u directly from .rs file
function! u#OpenUFromRs()
	unlet t:open_rs_directly
	let l:file_full = expand("%:p")
	call s:AutoOpenInner(l:file_full)
endfunction

" auto delete some-path/.*.u when closing the tab if file some-path/*.rs exists
function! u#AutoDelete()
	let l:dir = expand('<afile>:p:h')
	let l:file = expand('<afile>:t')
	let l:target = l:dir . '/' . substitute(l:file, '^\.\(.*\)\.u$', '\1.rs', '')
	if !filereadable(l:target)
		return
	endif

	call delete(expand('<afile>'))
endfunction

" auto write to some-path/*.rs when writing to some-path/.*.u
function! u#AutoWrite()
	let l:file_full = expand('<afile>')
	if !filereadable(l:file_full)
		return
	endif

	call prop_clear(1, line("$"))

	call SaveLight()

	let l:dir = expand('<afile>:p:h')
	let l:file = expand('<afile>:t')
	let l:target = l:dir . '/' . substitute(l:file, '^\.\(.*\)\.u$', '\1.rs', '')

	let l:output = system("u u-r ". l:file_full . " " . l:target)
	if l:output != ""
		let l:out = json_decode(l:output)[0]
		call prop_add(l:out.lnum, 0, {
			\ 'type': "error_hint",
			\ 'text': "    " . l:out.text,
			\ 'text_align': 'after',
		\ })
		return
	endif
endfunction

" open .rs file
function! u#OpenRs()
	execute 'noautocmd edit ' . fnameescape(expand('<afile>:p'))

	" purge undo history, so that pressing 'u' after opening the file won't clear all content
	let s:ul = &g:undolevels
	setlocal undolevels=-1
	execute "normal! a \<BS>"
	let &l:undolevels = s:ul

	setfiletype rust
	setlocal nomodified
endfunction
