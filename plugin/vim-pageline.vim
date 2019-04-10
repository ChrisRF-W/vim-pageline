if (get(g:, 'LOADED_PAGELINE', 0) == 1) || v:version < 700
  finish
endif
let g:LOADED_PAGELINE = 1

" Start pageline.
call pageline#init()
