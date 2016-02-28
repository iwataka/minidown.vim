let s:save_cpo = &cpoptions
set cpoptions&vim

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
  let cmd = 'pandoc -s -f '.g:minidown_from[&ft].' -t '.g:minidown_to.' -c '.g:minidown_css.' -o '.b:minidown_dest
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
