save = (id) ->
  localStorage[id] = document.getElementById(id).value

restore = (id) ->
  document.getElementById(id).value = localStorage[id]

init = ->
  $('#version').text('version: '+BG.version)

  unless localStorage["_init"] is "_init"
    localStorage["_init"] = "_init"
    localStorage["cybozuUrl"] = ""
    localStorage["_password"] = ""
    localStorage["_account"] = ""
    localStorage["serverCheckInterval"] = 30
    localStorage["eventCheckInterval"] = 30
    localStorage["eventBefore"] = 10
    localStorage["closeAfter"] = 0
  restoreOptions()

restoreOptions = ->
  restore "_password"
  restore "_account"
  restore "cybozuUrl"
  restore "serverCheckInterval"
  restore "eventCheckInterval"
  restore "eventBefore"
  restore "closeAfter"
  console.log "options restored."

saveAndClose = ->
  saveOptions()
  chrome.tabs.getSelected(null, (tab) ->
    chrome.tabs.remove tab.id
  )

saveOptions = ->
  save "_password"
  save "_account"
  save "cybozuUrl"
  save "serverCheckInterval"
  save "eventCheckInterval"
  save "eventBefore"
  save "closeAfter"
  console.log "options saved"
  BG.init()

resetOptions = ->
  localStorage["_init"] = ""
  init()

loginTest = ->
  saveOptions()
  BG.getEvents loginCallback

loginCallback = (data) ->
  BG.notify data
BG = chrome.extension.getBackgroundPage()
