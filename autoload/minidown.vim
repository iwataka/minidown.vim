if exists('g:minidown_loaded') && g:minidown_loaded
  finish
endif

if !exists('g:minidown_sleep_time')
  " The unit of this is second.
  let g:minidown_sleep_time = 1
endif

if !exists('g:minidown_tmp_dir')
  let g:minidown_tmp_dir = '/tmp/'
endif

if has('unix')
  let s:open_cmd = 'xdg-open'
elsei has('win32unix')
  let s:open_cmd = 'cygstart'
elsei has('win32') || has('win64')
  let s:open_cmd = 'start'
elsei has('mac')
  let s:open_cmd = 'open'
endif

fu! minidown#preview(...)
  if a:0 > 0
    call s:preview(a:000)
  else
    let fname = expand('%')
    call s:preview(fname)
  endif
endfu

fu! s:preview(src)
  if !executable('pandoc')
    echoe 'Mini-markdown requires pandoc command!'
    return
  endif
  if type(a:src) == type('')
    let src = expand(a:src)
    if has('python')
      call s:preview_python(src)
    elseif has('ruby')
      call s:preview_ruby(src)
    else
      echoe 'Mini-markdown requires ruby or python interface!'
    endif
  elseif type(a:src) == type([])
    for s in a:src
      call s:preview(s)
    endfor
  endif
endfu

function! s:preview_ruby(src)
ruby << EOF
require 'tempfile'
tmp_dir = VIM::evaluate('g:minidown_tmp_dir')
file = Tempfile.new(['output', '.html'], tmp_dir)
begin
  src = VIM::evaluate('a:src')
  path = file.path
  open_cmd = VIM::evaluate('s:open_cmd')
  system("pandoc #{src} -o #{path}")
  system("#{open_cmd} #{path}")
  VIM.command('redraw!')
  sleep_time = VIM::evaluate('g:minidown_sleep_time')
  sleep(sleep_time)
ensure
  file.close
  file.unlink
end
EOF
endfunction

fu! s:preview_python(src)
py << EOF
import tempfile
import time
from subprocess import call
tmp_dir = vim.eval('g:minidown_tmp_dir')
file = tempfile.NamedTemporaryFile(suffix = '.html', dir = tmp_dir)
try:
  src = vim.eval('a:src')
  path = file.name
  open_cmd = vim.eval('s:open_cmd')
  call(["pandoc", src, "-o", path])
  call([open_cmd, path])
  vim.command('redraw!')
  sleep_time = vim.eval('g:minidown_sleep_time')
  time.sleep(float(sleep_time))
finally:
  file.close()
EOF
endfu
