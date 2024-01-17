" modified from https://github.com/rust-lang/rust.vim

if exists("b:current_syntax")
	finish
endif

" --------------------------------------------------------------------------------

syn keyword     uCrate      crate       contained

syn keyword     uItem       import mod crate super
syn keyword     uItem       const static type
syn keyword     uItem       func struct enum union interface impl macro where

syn keyword     uStmt       let if else match for in ret break continue
syn keyword     uStmt       mut ref
syn keyword     uStmt       async await move extern dyn
syn keyword     uStmt       as fn loop pub while return trait use
syn keyword     uStmt       abstract become box do final override priv typeof unsized virtual yield

syn keyword     uBool       true false s
syn keyword     uSelf       s self

syn keyword     uUnsafe     unsafe

syn keyword     uType       i8 i16 i32 i64 i128 isize
syn keyword     uType       u8 u16 u32 u64 u128 usize
syn keyword     uType       f32 f64
syn keyword     uType       bool char str string
syn keyword     uType       Self

syn match   uOp             /\v[\+|\~|\*|\/|%|<<|>>|&|\||\^|=|!|<|>|``]?\=?/
syn match   uOp             /\v\$|;|#|\?|\@|:|::|\.\.\=|\=>/
syn match   uModPathSep     "\.\."
syn match   uOp             /\v\s\.\.(\.)?/

" identifier and symbol
syn match   uIdentifier         "\<[a-zA-Z0-9-]\+"
syn match   uIdentifierConst    "\<[a-zA-Z0-9-]\+--c"
syn match   uIdentifierStatic   "\<[a-zA-Z0-9-]\+--g"

syn match   uFirstSymbol    "\<[a-zA-Z0-9-]\+\s\+\(let\|:=\)\@="he=e-1,me=e-1
syn match   uDecl           /:=\|->/

" func call
syn match   uFuncCall    "\<[a-zA-Z0-9-]\+("he=e-1,me=e-1
syn match   uFuncCall    "\<[a-zA-Z0-9-]\+\["he=e-1,me=e-1 " foo[T]();

syn match   uStructType     "\<[A-Z]"
syn match   uStructType     "\<[A-Z][a-zA-Z0-9-]\+"

" syn match   uSymbol         "\<[a-zA-Z0-9-]\+\(+\((\(self\|super\|crate\|\(in\s\+\(self\|super\|crate\)\(\.\.[a-zA-Z0-9-]\+\)\+\)\))\)\?\)\?\s\+\(const\|static\|func\|struct\|enum\|union\|type\|interface\|macro\|mod\|(\)\@="he=e-1,me=e-1
" words [+[vis]] [space (Type)] space keyword
syn match   uSymbol         "\<[a-zA-Z0-9-]\+\(\(+\((\(self\|super\|crate\|\(in\s\+\(self\|super\|crate\)\(\.\.[a-zA-Z0-9-]\+\)\+\)\))\)\?\)\?\(\s\+(.*)\)\?\s\+\(const\|static\|func\|struct\|enum\|union\|type\|interface\|macro\|mod\)[a-zA-Z0-9-]\@!\)\@="
syn match   uSymbol         "^\s*[a-zA-Z0-9-]\+\(+\((\(self\|super\|crate\|\(in\s\+\(self\|super\|crate\)\(\.\.[a-zA-Z0-9-]\+\)\+\)\))\)\?\)\?\["he=e-1,me=e-1

" macro call
syn match   uMacroCall    "\<[a-zA-Z0-9-]\+,,"

" number
syn match   uDecNumber   display "\<[0-9][0-9_]*\%([iu]\%(size\|8\|16\|32\|64\|128\)\)\="
syn match   uHexNumber   display "\<0x[a-fA-F0-9_]\+\%([iu]\%(size\|8\|16\|32\|64\|128\)\)\="
syn match   uOctNumber   display "\<0o[0-7_]\+\%([iu]\%(size\|8\|16\|32\|64\|128\)\)\="
syn match   uBinNumber   display "\<0b[01_]\+\%([iu]\%(size\|8\|16\|32\|64\|128\)\)\="

" float
syn match   uFloat       display "\<[0-9][0-9_]*\.\%([^[:cntrl:][:space:][:punct:][:digit:]]\|_\|\.\)\@!"
syn match   uFloat       display "\<[0-9][0-9_]*\%(\.[0-9][0-9_]*\)\%([eE][+~]\=[0-9_]\+\)\=\(f32\|f64\)\="
syn match   uFloat       display "\<[0-9][0-9_]*\%(\.[0-9][0-9_]*\)\=\%([eE][+~]\=[0-9_]\+\)\(f32\|f64\)\="
syn match   uFloat       display "\<[0-9][0-9_]*\%(\.[0-9][0-9_]*\)\=\%([eE][+~]\=[0-9_]\+\)\=\(f32\|f64\)"

" char
" uLifetime must appear before uCharacter, or chars will get the lifetime highlighting
syn match   uLifetime    display "\'\%([^[:cntrl:][:space:][:punct:][:digit:]]\|_\)\%([^[:cntrl:][:punct:][:space:]]\|_\)*"
syn match   uLabel       display "\'\%([^[:cntrl:][:space:][:punct:][:digit:]]\|_\)\%([^[:cntrl:][:punct:][:space:]]\|_\)*:"
syn match   uLabel       display "\%(\<\%(break\|continue\)\s*\)\@<=\'\%([^[:cntrl:][:space:][:punct:][:digit:]]\|_\)\%([^[:cntrl:][:punct:][:space:]]\|_\)*"
syn match   uCharacterInvalid   display contained /b\?'\zs[\n\r\t']\ze'/
" The groups negated here add up to 0-255 but nothing else (they do not seem to go beyond ASCII).
syn match   uCharacterInvalidUnicode   display contained /b'\zs[^[:cntrl:][:graph:][:alnum:][:space:]]\ze'/
syn match   uCharacter   /b'\([^\\]\|\\\(.\|x\x\{2}\)\)'/ contains=uEscape,uEscapeError,uCharacterInvalid,uCharacterInvalidUnicode
syn match   uCharacter   /'\([^\\]\|\\\(.\|x\x\{2}\|u{\%(\x_*\)\{1,6}}\)\)'/ contains=uEscape,uEscapeUnicode,uEscapeError,uCharacterInvalid

" string
syn match     uEscapeError   display contained /\\./
syn match     uEscape        display contained /\\\([nrt0\\'"]\|x\x\{2}\)/
syn match     uEscapeUnicode display contained /\\u{\%(\x_*\)\{1,6}}/
syn match     uStringContinuation display contained /\\\n\s*/
syn region    uString      matchgroup=uStringDelimiter start=+b"+ skip=+\\\\\|\\"+ end=+"+ contains=uEscape,uEscapeError,uStringContinuation
syn region    uString      matchgroup=uStringDelimiter start=+"+ skip=+\\\\\|\\"+ end=+"+ contains=uEscape,uEscapeUnicode,uEscapeError,uStringContinuation,@Spell
syn region    uString      matchgroup=uStringDelimiter start='b\?\z(##*\)"' end='"\z1' contains=@Spell

" crate
syn region  uCrate      start="crate {" end="}" transparent contains=uCrate,uCommentLine,uCommentLineDoc,uCommentBlock,uCommentBlockDoc,

" mod
syn region  uMod        start="mod {" end="}"

" attr
syn region  uAttr       start="#!\?\[" end="\]" contains=none

syn match   uShebang    /\%^#![^[].*/
" comment
syn region uCommentLine                                                 start="//"                      end="$"   contains=uTodo,@Spell
syn region uCommentLineDoc                                              start="//\%(//\@!\|!\)"         end="$"   contains=uTodo,uDocCode,@Spell
syn region uCommentLineDocError                                         start="//\%(//\@!\|!\)"         end="$"   contains=uTodo,uDocCode,@Spell contained
syn region uCommentBlock             matchgroup=uCommentBlock           start="/\*\%(!\|\*[*/]\@!\)\@!" end="\*/" contains=uTodo,uCommentBlockNest,@Spell
syn region uCommentBlockDoc          matchgroup=uCommentBlockDoc        start="/\*\%(!\|\*[*/]\@!\)"    end="\*/" contains=uTodo,uDocCode,uCommentBlockDocNest,uCommentBlockDocuCode,@Spell
syn region uCommentBlockDocError     matchgroup=uCommentBlockDocError   start="/\*\%(!\|\*[*/]\@!\)"    end="\*/" contains=uTodo,uDocCode,uCommentBlockDocNestError,@Spell contained
syn region uCommentBlockNest         matchgroup=uCommentBlock           start="/\*"                     end="\*/" contains=uTodo,uCommentBlockNest,@Spell contained transparent
syn region uCommentBlockDocNest      matchgroup=uCommentBlockDoc        start="/\*"                     end="\*/" contains=uTodo,uDocCode,uCommentBlockDocNest,@Spell contained transparent
syn region uCommentBlockDocNestError matchgroup=uCommentBlockDocError   start="/\*"                     end="\*/" contains=uTodo,uDocCode,uCommentBlockDocNestError,@Spell contained transparent


syn region  uDocCode    start="```"     end="```" contained


" todo
syn keyword uTodo contained TODO FIXME XXX NOTE SAFETY


" pair
syn match   uParen          /\v\(|\)/
syn match   uSquare         /\v\[|\]/
syn match   uBrace          /\v\{|\}/
syn match   uDoubleBrace    /\v\{\{|\}\}/

" --------------------------------------------------------------------------------
" see https://en.wikipedia.org/wiki/ANSI_escape_code for color palette

hi uError ctermfg=9 ctermbg=235
hi uWarning ctermfg=11 ctermbg=235

hi uSymbol ctermfg=202 cterm=bold
hi uFirstSymbol ctermfg=15 cterm=bold
hi uIdentifier ctermfg=15
hi uIdentifierConst ctermfg=109 cterm=bold
hi uIdentifierStatic ctermfg=181 cterm=bold
" hi uIInterface ctermfg=73
hi uUnsafe ctermfg=9 cterm=bold
hi uParen ctermfg=255
hi uSquare ctermfg=73
hi uBrace ctermfg=250
hi uDoubleBrace ctermfg=106
hi uArray ctermfg=121
hi uKeyword ctermfg=185
hi uOp ctermfg=81
hi uAttr ctermfg=103
hi uLabel ctermfg=103
hi uModPathSep ctermfg=103
hi uFunction ctermfg=221
hi uMacroCall ctermfg=183
hi uSelf ctermfg=13
hi uComment ctermfg=14
hi uSpecialComment ctermfg=117
hi uDocCode ctermfg=109


hi def link     uCrate          uKeyword
hi def link     uMod            uKeyword
hi def link     uAttr           uAttr
hi def link     uItem           uKeyword
hi def link     uStmt           uKeyword
hi def link     uUnsafe         uUnsafe
hi def link     uType           Type
hi def link     uStructType     uType

hi def link     uParen          uParen
hi def link     uSquare         uSquare
hi def link     uBrace          uBrace
hi def link     uDoubleBrace    uDoubleBrace

hi def link     uOp             uOp
hi def link     uDecl           uKeyword
hi def link     uModPathSep     uModPathSep

hi def link     uIdentifier         uIdentifier
hi def link     uIdentifierConst    uIdentifierConst
hi def link     uIdentifierStatic   uIdentifierStatic
hi def link     uSymbol             uSymbol
hi def link     uMacroCall          uMacroCall
hi def link     uFuncCall           uFunction
hi def link     uFirstSymbol        uFirstSymbol

hi def link     uDecNumber      Number
hi def link     uHexNumber      Number
hi def link     uOctNumber      Number
hi def link     uBinNumber      Number
hi def link     uFloat          Float

hi def link     uLifetime                   Special
hi def link     uLabel                      uLabel
hi def link     uString                     String
hi def link     uStringDelimiter            String
hi def link     uCharacter                  Character
hi def link     uCharacterInvalid           Error
hi def link     uCharacterInvalidUnicode    uCharacterInvalid
hi def link     uBool                       Boolean

hi def link     uSelf                       uSelf

hi def link     uShebang                uComment
hi def link     uCommentLine            uComment
hi def link     uCommentLineDoc         uSpecialComment
hi def link     uCommentLineDocLeader   uCommentLineDoc
hi def link     uCommentLineDocError    Error
hi def link     uCommentBlock           uCommentLine
hi def link     uCommentBlockDoc        uCommentLineDoc
hi def link     uCommentBlockDocStar    uCommentBlockDoc
hi def link     uCommentBlockDocError   Error
hi def link     uCommentDocCodeFence    uCommentLineDoc
hi def link     uDocCode                uDocCode

hi def link     uTodo                   Todo


" --------------------------------------------------------------------------------
syn sync minlines=500

let b:current_syntax = "u"

" vim: set et sw=4 sts=4 ts=4:
