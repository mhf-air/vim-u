" modified from https://github.com/rust-lang/rust.vim

if exists("b:current_syntax")
	finish
endif

" --------------------------------------------------------------------------------

syn keyword     uCrate      crate       contained
syn keyword     uImport     import      contained

syn keyword     uItem       mod
syn keyword     uItem       const static type 
syn keyword     uItem       func struct enum union interface impl macro where

syn keyword     uStmt       let if else match for in ret break continue
syn keyword     uStmt       mut ref
syn keyword     uStmt       async await move extern dyn
syn keyword     uStmt       as fn loop pub while return trait use
syn keyword     uStmt       abstract become box do final override priv typeof unsized virtual yield

syn keyword     uBool       true false

syn keyword     uUnsafe     unsafe

syn keyword     uType       i8 i16 i32 i64 i128 isize
syn keyword     uType       u8 u16 u32 u64 u128 usize
syn keyword     uType       f32 f64
syn keyword     uType       bool char str
syn keyword     uType       Self
syn keyword     uType       A B C D E F G H I J K L M N O P Q R S T U V W X Y Z

syn match   uSquare         /\v\[|\]/
syn match   uBrace          /\v\{|\}/
syn match   uDoubleBrace    /\v\{\{|\}\}/
syn match   uOp             /\v[\+|\~|\*|\/|%|<<|>>|&|\||\^|=|!|<|>|``]?\=?/
syn match   uOp             /\v[$|;|#|?|@|::|\.\.=|=>]/
syn match   uDecl           /\v[:=|\->]/

syn match   uIInterface    "\<i-[a-zA-Z0-9-]\+"
syn match   uEEnum         "\<e-[a-zA-Z0-9-]\+"

syn match   uIdentifier  contains=rustIdentifierPrime "\%([^[:cntrl:][:space:][:punct:][:digit:]]\|_|\-\)\%([^[:cntrl:][:punct:][:space:]]\|_\|\-\)*" display contained

" number
syn match   uDecNumber   display "\<[0-9][0-9_]*\%([iu]\%(size\|8\|16\|32\|64\|128\)\)\="
syn match   uHexNumber   display "\<0x[a-fA-F0-9_]\+\%([iu]\%(size\|8\|16\|32\|64\|128\)\)\="
syn match   uOctNumber   display "\<0o[0-7_]\+\%([iu]\%(size\|8\|16\|32\|64\|128\)\)\="
syn match   uBinNumber   display "\<0b[01_]\+\%([iu]\%(size\|8\|16\|32\|64\|128\)\)\="

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
syn region    uString      matchgroup=uStringDelimiter start='b\?\z(#*\)"' end='"\z1' contains=@Spell

" crate
syn region  uCrate      start="crate {" end="}" transparent contains=uCrate
" import
syn region  uImport     start="import {" end="}" transparent contains=uImport

" mod
syn region  uMod        start="mod {" end="}"

" attr
syn region  uAttr       start="#!\?\[" end="\]" contains=none

" macro call
syn region  uMacroCall  start=",,(" end=")" contains=uOp
syn region  uMacroCall  start=",,\[" end="\]" contains=uOp
syn region  uMacroCall  start=",,{" end="}" contains=uOp

" comment
syn region uCommentLine                                                 start="//"                      end="$"   contains=uTodo,@Spell
syn region uCommentLineDoc                                              start="//\%(//\@!\|!\)"         end="$"   contains=uTodo,@Spell
syn region uCommentLineDocError                                         start="//\%(//\@!\|!\)"         end="$"   contains=uTodo,@Spell contained
syn region uCommentBlock             matchgroup=uCommentBlock           start="/\*\%(!\|\*[*/]\@!\)\@!" end="\*/" contains=uTodo,uCommentBlockNest,@Spell
syn region uCommentBlockDoc          matchgroup=uCommentBlockDoc        start="/\*\%(!\|\*[*/]\@!\)"    end="\*/" contains=uTodo,uCommentBlockDocNest,uCommentBlockDocuCode,@Spell
syn region uCommentBlockDocError     matchgroup=uCommentBlockDocError   start="/\*\%(!\|\*[*/]\@!\)"    end="\*/" contains=uTodo,uCommentBlockDocNestError,@Spell contained
syn region uCommentBlockNest         matchgroup=uCommentBlock           start="/\*"                     end="\*/" contains=uTodo,uCommentBlockNest,@Spell contained transparent
syn region uCommentBlockDocNest      matchgroup=uCommentBlockDoc        start="/\*"                     end="\*/" contains=uTodo,uCommentBlockDocNest,@Spell contained transparent
syn region uCommentBlockDocNestError matchgroup=uCommentBlockDocError   start="/\*"                     end="\*/" contains=uTodo,uCommentBlockDocNestError,@Spell contained transparent


" --------------------------------------------------------------------------------

hi uError ctermfg=9 ctermbg=235
hi uWarning ctermfg=11 ctermbg=235

hi uSymbol ctermfg=9
hi uKeyword ctermfg=172
hi uIInterface ctermfg=100
hi uUnsafe ctermfg=9
hi uArray ctermfg=101
hi uBrace ctermfg=102
hi uKeyword ctermfg=11
hi uOp ctermfg=81
hi uAttr ctermfg=103
hi uLabel ctermfg=103


hi def link     uCrate          Keyword
hi def link     uImport         uKeyword
hi def link     uMod            uKeyword
hi def link     uAttr           uAttr
hi def link     uItem           uKeyword
hi def link     uStmt           uKeyword
hi def link     uUnsafe         uUnsafe
hi def link     uType           Type

hi def link     uBrace          uBrace
hi def link     uDoubleBrace    uArray
hi def link     uOp             uOp
hi def link     uDecl           uKeyword

hi def link     uIInterface     uInterface
hi def link     uEEnum          Type

hi def link     uIdentifier     Identifier

hi def link     uDecNumber      Number
hi def link     uHexNumber      Number
hi def link     uOctNumber      Number
hi def link     uBinNumber      Number

hi def link     uLifetime                   Special
hi def link     uLabel                      uLabel
hi def link     uString                     String
hi def link     uStringDelimiter            String
hi def link     uCharacter                  Character
hi def link     uCharacterInvalid           Error
hi def link     uCharacterInvalidUnicode    uCharacterInvalid
hi def link     uBool                       Boolean

hi def link     uCommentLine            Comment
hi def link     uCommentLineDoc         SpecialComment
hi def link     uCommentLineDocLeader   uCommentLineDoc
hi def link     uCommentLineDocError    Error
hi def link     uCommentBlock           uCommentLine
hi def link     uCommentBlockDoc        uCommentLineDoc
hi def link     uCommentBlockDocStar    uCommentBlockDoc
hi def link     uCommentBlockDocError   Error
hi def link     uCommentDocCodeFence    uCommentLineDoc


" --------------------------------------------------------------------------------
syn sync minlines=500

let b:current_syntax = "u"

" vim: set et sw=4 sts=4 ts=4:
