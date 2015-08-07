
if exists("b:did_ftplugin")
  finish
endif

" MAPPINGS
nnoremap <buffer> + :call NewTask(1)<cr>
nnoremap <buffer> - :call NewTask(-1)<cr>

" ACTIONS

let s:regProject = '^\s*.*:$'
let s:regMarker = '☐'
let s:regDone = '@done'
let s:regCancelled = '@cancelled'
let s:regAttribute = '@\w\+\(([^)]*)\)\='
let s:dateFormat = '%Y-%m-%d %H:%M'

function! NewTask(direction)
  let line = getline('.')
  let isMatch = match(line, s:regProject)
  let text = '☐ '

  if a:direction == -1
    exec 'normal O' . text
  else
    exec 'normal o' . text
  endif

  if isMatch > -1
    exec 'normal >>'
  endif

  startinsert!
endfunc

function! SetLineMarker(marker)
  " if there is a marker, swap it out.
  " If there is no marker, add it in at first non-whitespace
  let rline = getline('.')
  let markerMatch = match(rline, s:regMarker)
  if markerMatch > -1
    call cursor(line('.'), markerMatch + 1)
    exec 'normal R' . a:marker
  endif
endfunc

function! AddAttribute(name, value)
  " at the end of the line, insert in the attribute:
  let attVal = ''
  if a:value != ''
    let attVal = '(' . a:value . ')'
  endif
  exec 'normal A @' . a:name . attVal
endfunc

function! RemoveAttribute(name)
  " if the attribute exists, remove it
  let rline = getline('.')
  let regex = '@' . a:name . '\(([^)]*)\)\='
  let attStart = match(rline, regex)
  let attEnd = matchend(rline, regex)
  echom attStart . ', ' . attEnd
  let diff = (attEnd - attStart) + 1
  call cursor(line('.'), attStart)
  exec 'normal ' . diff . 'dl'
endfunc

function! TaskComplete()
  let line = getline('.')
  let isMatch = match(line, s:regMarker)
  let doneMatch = match(line, s:regDone)
  let cancelledMatch = match(line, s:regCancelled)

  echom isMatch
  if isMatch > -1
    if doneMatch > -1
      " this task is done, so we need to remove the marker and the
      " @done/@project
    else
      if cancelledMatch > -1
        " this task was previously cancelled, so we need to swap the marker
        " and just remove the @cancelled first
        call RemoveAttribute('cancelled')
      endif
      " swap out the marker, add the @done, find the projects and add @project
      let projects = GetProjects(line('.'))
      call SetLineMarker('✔')
      call AddAttribute('done', strftime(s:dateFormat))
      call AddAttribute('project', join(projects, ' / '))
    endif
  endif
endfunc

function! TaskCancel()

endfunc