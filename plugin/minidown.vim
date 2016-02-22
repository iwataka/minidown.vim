if &compatible || (exists('g:loaded_minidown') && g:loaded_minidown)
  finish
endif
let g:loaded_minidown = 1

fu! s:setup()
  command! -buffer -complete=file Minidown call minidown#preview()
  command! -buffer -complete=file MinidownCompile call minidown#compile()
endfu

augroup minidown
  autocmd!
  autocmd FileType markdown call s:setup()
augroup END
