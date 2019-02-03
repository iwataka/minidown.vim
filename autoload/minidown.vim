let s:save_cpo = &cpoptions
set cpoptions&vim

" TODO: Windows file separator
let s:plantuml_jar_path = expand('<sfile>:p:h:h').'/lib/plantuml.jar'

fu! minidown#preview() abort
  call minidown#compile()
  let dests = isdirectory(b:minidown_dest) ?
        \ split(glob(b:minidown_dest.'/*'), '\n') : [b:minidown_dest]
  for dest in dests
    call s:run_cmd(printf(g:minidown_open_cmd, dest))
  endfor
endfu

fu! minidown#compile() abort
  if &ft == 'asciidoc' || &ft == 'plantuml'
    exe printf('call s:%s_compile()', &ft)
  else
    call s:pandoc_compile()
  endif
  call s:post_compile()
endfu

fu! s:pandoc_compile() abort
  let executable = 'pandoc'
  call s:pre_compile_for_executable(executable, '.html', 0)
  let fname = fnamemodify(expand('%'), ':p')
  let cmd = printf(
        \ '%s -s -f %s -t %s -c "%s" -o "%s"',
        \ executable,
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

fu! s:asciidoc_compile() abort
  let executable = 'asciidoctor'
  call s:pre_compile_for_executable(executable, '.html', 0)
  let fname = fnamemodify(expand('%'), ':p')
  call s:run_cmd(printf('%s "%s"', executable, fname))
endfu

fu! s:plantuml_compile() abort
  if !filereadable(s:plantuml_jar_path)
    call s:download_plantuml_jar(g:minidown_plantuml_jar_version)
  endif
  let executable = 'java'
  call s:pre_compile_for_executable(executable, '.d', 1)
  let fname = fnamemodify(expand('%'), ':p')
  let cmd = printf(
        \ '%s -jar %s -o %s -t%s "%s"',
        \ executable,
        \ s:plantuml_jar_path,
        \ b:minidown_dest,
        \ g:minidown_plantuml_to,
        \ fname)
  call s:run_cmd(cmd)
endfu

fu! s:pre_compile_for_executable(exe, out_suffix, out_is_dir) abort
  if !executable(a:exe)
    throw printf('Install %s and put it on your PATH', a:exe)
  endif
  if !exists('b:minidown_dest')
    call s:set_dest(a:out_suffix, a:out_is_dir)
  endif
endfu

fu! s:post_compile() abort
  if g:minidown_auto_compile
    autocmd! minidown BufEnter,BufWritePost <buffer>
    autocmd minidown BufEnter,BufWritePost <buffer> call minidown#compile()
  endif
endfu

fu! s:set_dest(suffix, is_dir) abort
  let dest = expand('%:p').a:suffix
  if (a:is_dir && isdirectory(dest)) ||
        \ (!a:is_dir && filereadable(dest))
    throw dest.' already exists!'
  endif
  let b:minidown_dest = dest
  autocmd! minidown BufLeave,VimLeave <buffer>
  autocmd minidown BufLeave,VimLeave <buffer> 
        \ if exists('b:minidown_dest') |
        \   let flag = isdirectory(b:minidown_dest) ? 'rf' : '' |
        \   call delete(b:minidown_dest, flag) |
        \ endif
endfu

fu! s:download_plantuml_jar(version) abort
  let url = printf(
        \ 'http://central.maven.org/maven2/net/sourceforge/plantuml/plantuml/%s/plantuml-%s.jar',
        \ a:version,
        \ a:version)
  if executable('curl')
    let cmd = printf('curl -fL %s -o %s', url, s:plantuml_jar_path)
  elseif executable('wget')
    let cmd = printf('wget %s -O %s', url, s:plantuml_jar_path)
  elseif executable('powershell')
    let cmd = printf('powershell -Command "& {Invoke-WebRequest -Uri %s -OutFile %s}"', url, s:plantuml_jar_path)
  else
    throw printf('Download %s and place it to %s', url, s:plantuml_jar_path)
  endif
  call s:run_cmd(cmd)
endfu

" TODO: Asynchronous execution
fu! s:run_cmd(cmd) abort
  call system(a:cmd)
endfu

let &cpo = s:save_cpo
unlet s:save_cpo
