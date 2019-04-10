fu! pageline#init()
  " Disable gui tabline
  if has('gui_running')
    set guioptions-=e
  endif

  let s:LOG_TAG = '[PageLine]'
  let s:PAGE_ADJ_OPT_KEY = 'xxxPagelineAdjOpt'
  let s:PAGE_CUR_IDX_KEY = 'xxxPagelineCurIdx'

  " Set up options of UI.
  let s:EXT_L = get(g:, 'pageline#ext_l', '<<')
  let s:EXT_R = get(g:, 'pageline#ext_r', '>>')
  let s:NO_EXT_L = ''
  for i in range(strlen(s:EXT_L))
    let s:NO_EXT_L .= ' '
  endfor
  let s:NO_EXT_R = ''
  for i in range(strlen(s:EXT_R))
    let s:NO_EXT_R .= ' '
  endfor
  let s:SEP_TAB_LM = get(g:, 'pageline#sep_tab_lm', ' ')
  let s:SEP_TAB_RM = get(g:, 'pageline#sep_tab_rm', ' ')
  let s:SEP_TAB_IN = get(g:, 'pageline#sep_tab_in', '|')
  let s:SEP_ACT_LM = get(g:, 'pageline#sep_act_lm', ' ')
  let s:SEP_ACT_RM = get(g:, 'pageline#sep_act_rm', ' ')
  let s:SEP_ACT_L  = get(g:, 'pageline#sep_act_l',  ' ')
  let s:SEP_ACT_R  = get(g:, 'pageline#sep_act_r',  ' ')

  " Length
  let s:EXT_L_LEN = strlen(s:EXT_L)
  let s:EXT_R_LEN = strlen(s:EXT_R)
  let s:SEP_TAB_LM_LEN = strlen(s:SEP_TAB_LM)
  let s:SEP_TAB_RM_LEN = strlen(s:SEP_TAB_RM)
  let s:SEP_TAB_IN_LEN = strlen(s:SEP_TAB_IN)
  let s:SEP_ACT_LM_LEN = strlen(s:SEP_ACT_LM)
  let s:SEP_ACT_RM_LEN = strlen(s:SEP_ACT_RM)
  let s:SEP_ACT_L_LEN  = strlen(s:SEP_ACT_L)
  let s:SEP_ACT_R_LEN  = strlen(s:SEP_ACT_R)

  " Modified and Rean-Only
  let s:ENABLED_SIGN = get(g:, 'pageline#enabled_file_status_sign', 1)
  if (s:ENABLED_SIGN)
    let s:MODIFIED = get(g:, 'pageline#sign_modified', ' +')
    let s:READONLY = get(g:, 'pageline#sign_readonly', ' -')
  endif

  " Highlight group
  let s:HI_G_EXT       = get(g:, 'pageline#hi_g_ext',       'TabLineFill')
  let s:HI_G_TAB       = get(g:, 'pageline#hi_g_tab',       'TabLine')
  let s:HI_G_TAB_SEP   = get(g:, 'pageline#hi_g_tab_sep',   'TabLine')
  let s:HI_G_TAB_MOD   = get(g:, 'pageline#hi_g_tab_mod',   'TabLine')
  let s:HI_G_ACT       = get(g:, 'pageline#hi_g_act',       'TabLineSel')
  let s:HI_G_ACT_L     = get(g:, 'pageline#hi_g_act_l',     'TabLineSel')
  let s:HI_G_ACT_R     = get(g:, 'pageline#hi_g_act_r',     'TabLineSel')
  let s:HI_G_ACT_MOD   = get(g:, 'pageline#hi_g_act_mod',   'TabLineSel')
  let s:HI_G_ACT_MOD_L = get(g:, 'pageline#hi_g_act_mod_l', 'TabLineSel')
  let s:HI_G_ACT_MOD_R = get(g:, 'pageline#hi_g_act_mod_r', 'TabLineSel')

  " Hilight tag
  let s:HI_EXT       = '%#'.s:HI_G_EXT.'#'
  let s:HI_TAB       = '%#'.s:HI_G_TAB.'#'
  let s:HI_TAB_SEP   = '%#'.s:HI_G_TAB_SEP.'#'
  let s:HI_TAB_MOD   = '%#'.s:HI_G_TAB_MOD.'#'
  let s:HI_ACT       = '%#'.s:HI_G_ACT.'#'
  let s:HI_ACT_L     = '%#'.s:HI_G_ACT_L.'#'
  let s:HI_ACT_R     = '%#'.s:HI_G_ACT_R.'#'
  let s:HI_ACT_MOD   = '%#'.s:HI_G_ACT_MOD.'#'
  let s:HI_ACT_MOD_L = '%#'.s:HI_G_ACT_MOD_L.'#'
  let s:HI_ACT_MOD_R = '%#'.s:HI_G_ACT_MOD_R.'#'

  " Display names for special file types.
  let s:SPEC_NAMES = get(g:, 'pageline#display_names_for_special_file_types', {
        \})

  " Set up the tabline.
  set showtabline=2
  " Set up the tabline routine.
  call s:setupTablineRoutine()
endf

fu! s:setupTablineRoutine()
  set tabline=%!pageline#tabline()
endf

fu! pageline#tabline()
  let width = &columns - (s:EXT_L_LEN + s:EXT_R_LEN)
  if (width <= 0)
    echom s:LOG_TAG 'No enough space'
    return ''
  endif
  " Prepare optline.
  let optline = s:getOptline()
  let width = width - optline['len']
  if (width <= 0)
    echom s:LOG_TAG 'No enough space'
    return ''
  endif
  " Prepare information of tabs.
  let tabInfoMap = s:prepareTabInfoMap()
  " Prepare tabline.
  let tabline = s:getTabline(tabInfoMap)
  " Format tabline.
  let fmtOptline = s:fmtOptline(optline)
  let fmtTabline = s:fmtTabline(tabline, width)
  return fmtTabline.'%='.fmtOptline
endf

fu! pageline#tabClick(n, clicks, button, modifiers)
  if (a:button ==# 'l' && tabpagenr() != a:n)
    exe 'normal! '.a:n.'gt'
  endif
endf

fu! pageline#extClick(n, clicks, button, modifiers)
  " :h statusline
  let g:[s:PAGE_ADJ_OPT_KEY] = a:n
  " Reset it to refresh tabline.
  call s:setupTablineRoutine()
endf

fu! s:getOptline()
  return { 'str': '', 'len': 0 }
endf

fu! s:fmtOptline(optline)
  return a:optline['str']
endf

fu! s:getActBufNrOfTab(tabNr)
  let bufNrsOfTab = tabpagebuflist(a:tabNr)
  let actWinNrOfTab = tabpagewinnr(a:tabNr)
  return bufNrsOfTab[actWinNrOfTab - 1]
endf

fu! s:prepareTabInfoMap()
  let tabInfoMap = {}
  let nameInfoMap = {}
  let uniDispNameMap = {}
  for tabNr in range(1, tabpagenr('$'))
    let tabInfo = s:genTabInfo(tabNr, tabInfoMap, nameInfoMap, uniDispNameMap)
    let tabInfoMap[tabNr] = tabInfo
  endfor
  return tabInfoMap
endf

fu! s:genTabInfo(tabNr, tabInfoMap, nameInfoMap, uniDispNameMap)
  let bufNr = s:getActBufNrOfTab(a:tabNr)
  " Get type of the buffer.
  let bufFileType = getbufvar(bufNr, '&filetype')
  let specBufName = get(s:SPEC_NAMES, bufFileType, '')
  if !empty(specBufName)
    return [bufNr, specBufName]
  endif
  " Get name of the buffer.
  let bufName = bufname(bufNr)
  " If the name is empty
  if empty(bufName)
    return [bufNr, bufName]
  endif

  let dispBufName = fnamemodify(bufName, ':t')
  let nameInfo = get(a:nameInfoMap, dispBufName, v:null)
  " If the name is NOT duplicate.
  if (nameInfo is v:null)
    " Record the information of FIRST buffer which has the name.
    let a:nameInfoMap[dispBufName] = [bufNr, dispBufName, [a:tabNr], 0]
    " Note: The last element indicates whether the name is really duplicate.
    return [bufNr, dispBufName]
  endif
  " If the name is duplicate but it's FIRST buffer which has the name.
  if (nameInfo[0] == bufNr)
    " Record the Tab number of FIRST buffer which has the name.
    call add(nameInfo[2], a:tabNr)
    " Note: We use `nameInfo[1]` because it might be updated to a unique name.
    return [bufNr, nameInfo[1]]
  endif

  " If the name is duplicate (Different buffers have same display name).
  if (!nameInfo[3])
    " Record the unique name of FIRST buffer which has the duplicate name.
    let uniDispBufName = s:genUniDispBufName(nameInfo[0])
    let nameInfo[1] = uniDispBufName
    " Refresh previously found tabs.
    for dupNamedTabNr in nameInfo[2]
      " Set the new name.
      let tabInfo = a:tabInfoMap[dupNamedTabNr]
      let tabInfo[1] = uniDispBufName
    endfor
    " We only record it ONCE.
    let nameInfo[3] = 1
    " We don't have to record this unique name to `a:uniDispNameMap`, this name
    " is updated through `nameInfo`.
    "let a:uniDispNameMap[nameInfo[0]] = uniDispBufName
  endif

  " Use an unique name.
  let uniDispBufName = get(a:uniDispNameMap, bufNr, v:null)
  if (uniDispBufName is v:null)
    " Record the unique name of THIS buffer which has the duplicate name.
    let uniDispBufName = s:genUniDispBufName(bufNr)
    let a:uniDispNameMap[bufNr] = uniDispBufName
  endif
  return [bufNr, uniDispBufName]
endf

fu! s:genUniDispBufName(bufNr)
  let relBufName = fnamemodify(bufname(a:bufNr), ':~:.')
  return substitute(relBufName, '\v\w\zs.{-}\ze(\\|/)', '', 'g')
endf

fu! s:getTabline(tabInfoMap)
  let nTabs = tabpagenr('$')
  let actTabNr = tabpagenr()
  let curIdx = 0
  let nodeList = []
  for tabNr in range(1, nTabs)
    " Get the name of the tab.
    let [bufNr, dispBufName] = a:tabInfoMap[tabNr]
    let bufModStatus = (getbufvar(bufNr, '&modified') ? 1 : 0)
    let tabName    = s:genTabName(bufNr, dispBufName)
    let tabNameLen = strlen(tabName)
    if (tabNr == actTabNr)
      " The active tab always has both side separators.
      let actIdx = curIdx
      if (tabNr == 1)
        let nodeTag = (bufModStatus ? s:HI_ACT_MOD_L : s:HI_ACT_L)
        let curIdx += s:addNode(nodeList,
              \ curIdx, s:SEP_ACT_LM_LEN, s:SEP_ACT_LM, nodeTag, 0)
      else
        let nodeTag = (bufModStatus ? s:HI_ACT_MOD_L : s:HI_ACT_L)
        let curIdx += s:addNode(nodeList,
              \ curIdx, s:SEP_ACT_L_LEN, s:SEP_ACT_L, nodeTag, 0)
      endif
      let nodeTag = (bufModStatus ? s:HI_ACT_MOD : s:HI_ACT)
      let curIdx += s:addNode(nodeList,
            \ curIdx, tabNameLen, tabName, nodeTag, tabNr)
      if (tabNr == nTabs)
        let nodeTag = (bufModStatus ? s:HI_ACT_MOD_R : s:HI_ACT_R)
        let curIdx += s:addNode(nodeList,
              \ curIdx, s:SEP_ACT_RM_LEN, s:SEP_ACT_RM, nodeTag, 0)
      else
        let nodeTag = (bufModStatus ? s:HI_ACT_MOD_R : s:HI_ACT_R)
        let curIdx += s:addNode(nodeList,
              \ curIdx, s:SEP_ACT_R_LEN, s:SEP_ACT_R, nodeTag, 0)
      endif
      let actPos = [actIdx, curIdx]
    else
      " Only first tab has the left separator.
      if (tabNr == 1)
        let curIdx += s:addNode(nodeList,
              \ curIdx, s:SEP_TAB_LM_LEN, s:SEP_TAB_LM, s:HI_TAB_SEP, 0)
      endif
      let nodeTag = (bufModStatus ? s:HI_TAB_MOD : s:HI_TAB)
      let curIdx += s:addNode(nodeList,
            \ curIdx, tabNameLen, tabName, nodeTag, tabNr)
      " If next tab is not the active tab, it has the right separator.
      if (tabNr == nTabs)
        let curIdx += s:addNode(nodeList,
              \ curIdx, s:SEP_TAB_RM_LEN, s:SEP_TAB_RM, s:HI_TAB_SEP, 0)
      elseif (tabNr + 1 != actTabNr)
        let curIdx += s:addNode(nodeList,
              \ curIdx, s:SEP_TAB_IN_LEN, s:SEP_TAB_IN, s:HI_TAB_SEP, 0)
      endif
    endif
  endfor
  return { 'len': curIdx, 'actPos': actPos, 'nodeList': nodeList }
endf

fu! s:genTabName(bufNr, dispBufName)
  let dispBufName = a:dispBufName
  if empty(dispBufName)
    let dispBufName = '[No Name]'
  endif
  " Add the sign of its status.
  if (s:ENABLED_SIGN)
    if getbufvar(a:bufNr, '&readonly')
      let dispBufName .= s:READONLY
    elseif getbufvar(a:bufNr, '&modified')
      let dispBufName .= s:MODIFIED
    endif
  endif
  return ' '.dispBufName.' '
endf

fu! s:addNode(list, idx, len, node, nodeTag, tabNr)
  if (a:len != 0)
    call add(a:list, [a:idx, a:len, a:node, a:nodeTag, a:tabNr])
  endif
  return a:len
endf

fu! s:fmtTabline(tabline, width)
  if (a:width <= 0)
    return ''
  endif
  " Get indexes of the active tab.
  let [actIdx, actEndIdx] = a:tabline['actPos']

  " Adjust the current index of pageline.
  let lineLen = a:tabline['len']
  let pageAdjOpt = get(g:, s:PAGE_ADJ_OPT_KEY, 0)
  let pageCurIdx = get(g:, s:PAGE_CUR_IDX_KEY, 0)
  let pageCurIdx = s:adjPageCurIdx(
        \ pageAdjOpt, pageCurIdx, actIdx, actEndIdx, lineLen, a:width)
  let pageEndIdx = pageCurIdx + a:width
  " Clean the option.
  let g:[s:PAGE_ADJ_OPT_KEY] = 0

  " Set up the extension indicators.
  let [extLeft, extRight] = s:fmtExtLabel(pageCurIdx, pageEndIdx, lineLen)

  " Format the pageline.
  let nodeList = a:tabline['nodeList']
  let fmtLine = s:doFmtTabline(
        \ pageCurIdx, pageEndIdx, nodeList, extLeft, extRight)

  " Save the current index of pageline to GLOBAL variable map.
  let g:[s:PAGE_CUR_IDX_KEY] = pageCurIdx
  return fmtLine
endf

fu! s:adjPageCurIdx(opt, curIdx, actIdx, actEndIdx, lineLen, width)
  let pageCurIdx = a:curIdx
  if (a:opt == 0)
    " Adjust it by the index of the active tab.
    if (a:actIdx < pageCurIdx)
      let pageCurIdx = a:actIdx
    endif
    if (a:actEndIdx > pageCurIdx + a:width)
      let pageCurIdx = a:actEndIdx - a:width
    endif
  else
    " Adjust it by offsets.
    if (a:opt == 1)
      let pageCurIdx -= a:width
      if (pageCurIdx < 0)
        let pageCurIdx = 0
      endif
    elseif (a:opt == 2)
      let pageCurIdx += a:width
      if (pageCurIdx + a:width > a:lineLen)
        let pageCurIdx = a:lineLen - a:width
      endif
    endif
  endif
  return pageCurIdx
endf

fu! s:fmtExtLabel(pageCurIdx, pageEndIdx, lineLen)
  if (a:pageCurIdx == 0)
    let extLeft = s:NO_EXT_L
  else
    if has("tablineat")
      let extLeft = '%1@pageline#extClick@'.s:EXT_L.'%X'
    else
      let extLeft = s:EXT_L
    endif
  endif
  if (a:pageEndIdx >= a:lineLen)
    let extRight = s:NO_EXT_R
  else
    if has("tablineat")
      let extRight = '%2@pageline#extClick@'.s:EXT_R.'%X'
    else
      let extRight = s:EXT_R
    endif
  endif
  return [extLeft, extRight]
endf

fu! s:doFmtTabline(pageCurIdx, pageEndIdx, nodeList, extLeft, extRight)
  let quit = 0
  let lastTag = ''
  let fmtLine = s:HI_EXT.a:extLeft
  for [nodeIdx, nodeLen, node, nodeTag, tabNr] in a:nodeList
    let nodeEndIdx = nodeIdx + nodeLen
    if (nodeIdx <= a:pageCurIdx)
      if (a:pageCurIdx >= nodeEndIdx)
        continue
      endif
      " When (a:pageCurIdx < nodeEndIdx)
      let iSta = a:pageCurIdx - nodeIdx
    else
      " When (nodeIdx > a:pageCurIdx)
      let iSta = 0
    endif
    " When the node can be shown.
    if (a:pageEndIdx <= nodeEndIdx)
      let iEnd = a:pageEndIdx - nodeIdx
      let quit = 1
    else
      let iEnd = nodeEndIdx - nodeIdx
    endif
    let target = node[iSta:iEnd-1]
    let fmtLine .= s:fmtNode(tabNr, target, nodeTag, lastTag)
    if (quit)
      break
    endif
    let lastTag = nodeTag
  endfor
  let fmtLine .= '%T'.s:HI_EXT.a:extRight
  return fmtLine
endf

fu! s:fmtNode(tabNr, target, nodeTag, lastTag)
  let fmtNode = substitute(a:target, '%', '%%', 'g')
  if (a:tabNr != 0)
    if has("tablineat")
      let fmtNode = '%'.a:tabNr.'@pageline#tabClick@'.fmtNode
    else
      let fmtNode = '%'.a:tabNr.'T'.fmtNode
    endif
  endif
  if (a:nodeTag !=# a:lastTag)
    let fmtNode = a:nodeTag.fmtNode
  endif
  return fmtNode
endf

" Helper function
fu! pageline#hi(group, guifg, guibg, ctermfg, ctermbg, ...)
  let attr  = a:0 >= 1 ? a:1 : ''
  let guisp = a:0 >= 2 ? a:2 : ''
  let configStr = ''
  if (a:guifg != '')
    let configStr .= ' guifg='.a:guifg
  endif
  if (a:guibg != '')
    let configStr .= ' guibg='.a:guibg
  endif
  if (a:ctermfg != '')
    let configStr .= ' ctermfg='.a:ctermfg
  endif
  if (a:ctermbg != '')
    let configStr .= ' ctermbg='.a:ctermbg
  endif
  if (attr != '')
    let configStr .= ' gui='.attr.' cterm='.attr
  endif
  if (guisp != '')
    let configStr .= ' guisp='.guisp
  endif
  if (configStr != '')
    exec 'hi '.a:group.' '.configStr
  endif
endf
