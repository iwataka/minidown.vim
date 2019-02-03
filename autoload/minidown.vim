let s:save_cpo = &cpoptions
set cpoptions&vim

fu! minidown#preview() abort
  call minidown#compile()
  call s:run_cmd(printf(g:minidown_open_cmd, b:minidown_dest))
endfu

fu! minidown#compile() abort
  if &filetype == 'asciidoc'
    call s:asciidoctor_compile()
  else
    call s:pandoc_compile()
  endif
  call s:post_compile()
endfu

fu! s:asciidoctor_compile() abort
  let executable = 'asciidoctor'
  call s:pre_compile_for_executable(executable)
  let fname = fnamemodify(expand('%'), ':p')
  call s:run_cmd(printf('%s "%s"', executable, fname))
endfu

fu! s:pandoc_compile() abort
  call s:pre_compile_for_executable('pandoc')
  let fname = fnamemodify(expand('%'), ':p')
  let cmd = printf(
        \ 'pandoc -s -f %s -t %s -c "%s" -o "%s"',
        \ g:minidown_pandoc_from[&ft],
        \ g:minidown_pandoc_to,
        \ g:minidown_pandoc_css,
        \ b:minidown_dest)
  let args = ''
  if g:minidown_pandoc_enable_toc
    let args .= '--toc'
  endif
  call s:run_cmd(printf('%s %s "%s"', cmd, args, fname))
endfu

fu! s:pre_compile_for_executable(exe) abort
  if !executable(a:exe)
    throw printf('Install %s and put it on your PATH', a:exe)
  endif
  if !exists('b:minidown_dest')
    call s:set_dest()
  endif
endfu

fu! s:post_compile() abort
  if g:minidown_auto_compile
    autocmd! minidown BufWritePost <buffer>
    autocmd minidown BufWritePost <buffer> call minidown#compile()
  endif
endfu

fu! s:set_dest() abort
  let dest = expand('%:p:r').'.html'
  if filereadable(dest)
    throw dest.' already exists!'
  endif
  autocmd! minidown BufLeave,VimLeave <buffer>
  autocmd minidown BufLeave,VimLeave <buffer> 
        \ if exists('b:minidown_dest') |
        \   call delete(b:minidown_dest) |
        \ endif
  let b:minidown_dest = dest
endfu

" TODO: Asynchronous execution
fu! s:run_cmd(cmd) abort
  call system(a:cmd)
endfu

let &cpo = s:save_cpo
unlet s:save_cpo
