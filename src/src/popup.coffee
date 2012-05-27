tableHtml = (data) ->
  html = """
    <tr data-href="#{data.link}">
      <td>
        <a>#{data.title}</a>
      </td><td>
        <a>#{data.msg}</a>
      </td>
    </tr>
    """
  $(html).appendTo data.to

setPending = (p) ->
  tableHtml
    to: "#table-pending"
    link:p.link
    title:p.title
    msg:p.updated
setEvent = (ev) ->
  #title = if ev.allDay then '' else BG.dateToTimeStr(new Date(ev.start))
  tableHtml
    to: "#table-today"
    link:ev.link || ''
    title:ev.title || ''
    msg:ev.name || ''

initPendings = ->
  $('#tab1 a').text("未読の通知")
  setPending(p) for p in BG.pendings
  if BG.pendings.length > 0
    $('#tab1 a').text("未読の通知( #{BG.pendings.length} )")
  addLink()

initEvents = ->
  $('#tab2 a').text("本日の予定")
  for re in BG.rawEvents
    mt = $(re).text().match /(\d{2}:\d{2})?-?(\d{2}:\d{2})? ?(.*)/
    setEvent
      link:BG.getHost()+$("a", re).attr('href')
      name:mt[3] || 'error'
      title:mt[1] || ''
  if BG.rawEvents.length > 0
    $('#tab2 a').text("本日の予定( #{BG.rawEvents.length} )")
  addLink()

#行全体にリンクを設定
addLink = ->
  $('tr[data-href]')
    .addClass('clickable')
    .click (e)-> window.open $(e.target).closest('tr').data('href')

init = ->
  $("#title").attr "href", localStorage.cybozuUrl
  current = BG.tab || 1
  setTab current
  initPendings()
  initEvents()

setTab = (n) ->
  $("#tab#{n}").addClass('active')
  $("#content#{n}").addClass('active')

refresh = ->
  $("#table-pending").empty()
  $("#table-today").empty()
  BG.getPendings(initPendings)
  BG.getEvents(initEvents)
  BG.notifyEvent()

search = ->
  query = $('#query').attr('value')
  chrome.tabs.create( url: "#{BG.getSearchUrl(query)}", null)
  window.close()

config = ->
  chrome.tabs.create( url: "/option.html", null)
  window.close()

tab = (n) ->
  BG.tab = n

BG = chrome.extension.getBackgroundPage()
