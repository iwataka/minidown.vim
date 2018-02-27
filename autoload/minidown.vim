let s:save_cpo = &cpoptions
set cpoptions&vim

fu! minidown#preview() abort
  call minidown#compile()
  call system(printf('%s "%s"', g:minidown_open_cmd, b:minidown_dest))
endfu

fu! minidown#compile() abort
  if !executable('pandoc')
    throw 'Install pandoc and put it on your PATH'
  endif
  let fname = fnamemodify(expand('%'), ':p')
  if !exists('b:minidown_dest')
    call s:set_dest()
  endif
  let cmd = printf(
        \ 'pandoc -s -f %s -t %s -c "%s" -o "%s"',
        \ g:minidown_from[&ft],
        \ g:minidown_to,
        \ g:minidown_css,
        \ b:minidown_dest)
  let args = ''
  if g:minidown_enable_toc
    let args .= '--toc'
  endif
  call system(printf('%s %s "%s"', cmd, args, fname))
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

let &cpo = s:save_cpo
unlet s:save_cpo
