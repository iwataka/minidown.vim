let s:save_cpo = &cpoptions
set cpoptions&vim

if !exists('g:minidown_auto_compile')
  let g:minidown_auto_compile = 1
endif

if !exists('g:minidown_open_cmd')
  if has('unix')
    let g:minidown_open_cmd = 'xdg-open'
  elsei has('win32unix')
    let g:minidown_open_cmd = 'cygstart'
  elsei has('win32')
    let g:minidown_open_cmd = 'start'
  elsei has('mac')
    let g:minidown_open_cmd = 'open'
  endif
endif

if !exists('g:minidown_css')
  let g:minidown_css = expand(expand('<sfile>:p:h:h').'/css/github.css')
endif

if !exists('g:minidown_from')
  let g:minidown_from = 'markdown_github-hard_line_breaks'
endif

if !exists('g:minidown_to')
  let g:minidown_to = 'html5'
endif

fu! minidown#preview() abort
  call minidown#compile()
  call system(g:minidown_open_cmd.' '.b:minidown_dest)
  if g:minidown_auto_compile
    autocmd! minidown * <buffer>
    autocmd minidown BufWritePost <buffer> call minidown#compile()
  endif
endfu

fu! minidown#compile() abort
  if !executable('pandoc')
    throw 'Install pandoc and put it on your PATH'
  endif
  let fname = fnamemodify(expand('%'), ':p')
  let b:minidown_dest = exists('b:minidown_dest') ? b:minidown_dest : s:temp_html()
  let cmd = 'pandoc -s -f '.g:minidown_from.' -t '.g:minidown_to.' -c '.g:minidown_css.' -o '.b:minidown_dest
  call system(cmd.' '.fname)
endfu

fu! s:temp_html()
  let result = ''
  while empty(result) || filereadable(result)
    let result = tempname().'.html'
  endwhile
  return result
endfu

let &cpo = s:save_cpo
unlet s:save_cpo
