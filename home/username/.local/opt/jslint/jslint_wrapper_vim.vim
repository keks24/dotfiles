"" ############################################################################
"" # Copyright 2026 Ramon Fischer                                             #
"" #                                                                          #
"" # Licensed under the Apache License, Version 2.0 (the "License");          #
"" # you may not use this file except in compliance with the License.         #
"" # You may obtain a copy of the License at                                  #
"" #                                                                          #
"" #     http://www.apache.org/licenses/LICENSE-2.0                           #
"" #                                                                          #
"" # Unless required by applicable law or agreed to in writing, software      #
"" # distributed under the License is distributed on an "AS IS" BASIS,        #
"" # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. #
"" # See the License for the specific language governing permissions and      #
"" # limitations under the License.                                           #
"" ############################################################################

"" The Unlicense
""
"" This is free and unencumbered software released into the public domain.
""
"" Anyone is free to copy, modify, publish, use, compile, sell, or
"" distribute this software, either in source code form or as a compiled
"" binary, for any purpose, commercial or non-commercial, and by any
"" means.
""
"" In jurisdictions that recognize copyright laws, the author or authors
"" of this software dedicate any and all copyright interest in the
"" software to the public domain. We make this dedication for the benefit
"" of the public at large and to the detriment of our heirs and
"" successors. We intend this dedication to be an overt act of
"" relinquishment in perpetuity of all present and future rights to this
"" software under copyright law.
""
"" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
"" EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"" MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"" IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
"" OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
"" ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
"" OTHER DEALINGS IN THE SOFTWARE.


"" jslint_wrapper_vim.vim
""
"" jslint wrapper for vim

let s:dir = expand("<sfile>:p:h")

"" this function will jslint a javascript file via "nodejs"
function! Jslint()
    "" jslint file (via nodejs)
    "" embedded js reports as "<file>.<node -e>.js" or "<file>.<script>.js"
    let &l:errorformat =
        \ "%f.<node -e>.js:%n:%l:%c:%m," .
        \ "%f.<script>.js:%n:%l:%c:%m," .
        \ "%f:%n:%l:%c:%m"
    "" shellescape(..., 1) also escapes "%" and "#", which :make expands
    let &l:makeprg = "node"
        \ . " " . shellescape(s:dir . "/jslint.mjs", 1)
        \ . " jslint_wrapper_vim"
        \ . " " . shellescape(fnamemodify(bufname("%"), ":p"), 1)
    silent make! | cwindow | redraw!
endfunction

command! Jslint call Jslint()
