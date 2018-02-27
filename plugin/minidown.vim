if &compatible || (exists('g:loaded_minidown') && g:loaded_minidown)
  finish
endif
let g:loaded_minidown = 1

if !exists('g:minidown_auto_compile')
  let g:minidown_auto_compile = 1
endif

fu! s:is_mac()
  let result = has('mac') || has('macunix')
  if !result || has('unix')
    let os = substitute(system('uname'), '\n', '', '')
    let result = result || os == 'Darwin' || os == 'Mac'
  endif
  return result
endfu

if !exists('g:minidown_open_cmd')
  if s:is_mac()
    let g:minidown_open_cmd = 'open "%s"'
  elseif has('win32unix') && executable('cygstart')
    let g:minidown_open_cmd = 'cygstart "%s"'
  elseif has('unix')
    let g:minidown_open_cmd = 'xdg-open "%s"'
  elseif has('win32')
    " Somewhat this command doesn't need file names double-quoted.
    " Although This is working properly, I'm still investigating about this
    " reason.
    let g:minidown_open_cmd = 'rundll32 url.dll,FileProtocolHandler %s'
  endif
endif

if !exists('g:minidown_css')
  let g:minidown_css = expand(expand('<sfile>:p:h:h').'/css/github.css')
endif

if !exists('g:minidown_from')
  let g:minidown_from = {
        \ 'markdown': 'markdown_github-hard_line_breaks',
        \ 'rst': 'rst'
        \ }
endif

if !exists('g:minidown_to')
  let g:minidown_to = 'html5'
endif

if !exists('g:minidown_enable_toc')
  let g:minidown_enable_toc = 1
endif

fu! s:setup()
  command! -buffer Minidown call minidown#preview()
  command! -buffer MinidownCompile call minidown#compile()
endfu

augroup minidown
  autocmd!
  for k in keys(g:minidown_from)
    exe 'autocmd FileType '.k.' call s:setup()'
  endfor
augroup END
