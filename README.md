# vim-pageline

Enhanced tabline for Vim.

# Screenshots

Without configurations:

![image](https://github.com/ChrisRF-W/vim-pageline/blob/master/screenshots/an_example_of_vim_pageline.png?raw=true)

With custom configurations:

![image](https://github.com/ChrisRF-W/vim-pageline/blob/master/screenshots/an_example_of_vim_pageline_with_custom_configs.png?raw=true)

# Example configuration

```vim
let s:gui01 = "#282a2e"
let s:gui03 = "#969896"
let s:gui07 = "#ffffff"
let s:gui09 = "#f96a38"
let s:gui0B = "#198844"
let s:cterm01 = "18"
let s:cterm03 = "08"
let s:cterm07 = "15"
let s:cterm09 = "16"
let s:cterm0B = "02"

let g:pageline#enabled_file_status_sign = 0

let g:pageline#hi_g_ext       = 'PageLineExt'
let g:pageline#hi_g_tab       = 'PageLineTab'
let g:pageline#hi_g_tab_sep   = 'PageLineTabSep'
let g:pageline#hi_g_tab_mod   = 'PageLineTabMod'
let g:pageline#hi_g_act       = 'PageLineAct'
let g:pageline#hi_g_act_l     = 'PageLineAct'
let g:pageline#hi_g_act_r     = 'PageLineAct'
let g:pageline#hi_g_act_mod   = 'PageLineActMod'
let g:pageline#hi_g_act_mod_l = 'PageLineActMod'
let g:pageline#hi_g_act_mod_r = 'PageLineActMod'

try
  call pageline#hi('PageLineExt',    s:gui07, s:gui01, s:cterm07, s:cterm01)
  call pageline#hi('PageLineTab',    s:gui0B, s:gui01, s:cterm0B, s:cterm01)
  call pageline#hi('PageLineTabSep', s:gui03, s:gui01, s:cterm03, s:cterm01)
  call pageline#hi('PageLineTabMod', s:gui09, s:gui01, s:cterm09, s:cterm01)
  call pageline#hi('PageLineAct',    s:gui01, s:gui0B, s:cterm01, s:cterm0B)
  call pageline#hi('PageLineActMod', s:gui01, s:gui09, s:cterm01, s:cterm09)
catch
"  echo 'vim-pageline might not be installed.'
endtry

" Display names for special file types.
"let g:pageline#display_names_for_special_file_types = {
"      \ 'qf': '[Location List]'
"      \}
```

# Installation

[vim-plug](https://github.com/junegunn/vim-plug)

    Plug 'ChrisRF-W/vim-pageline'

# Usage

Use it as original Vim tabline.

# License

MIT License.