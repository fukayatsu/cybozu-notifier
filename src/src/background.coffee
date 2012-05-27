notify = (data) ->
  BG.n_message = data.message or "test"
  BG.n_link = data.link or localStorage.cybozuUrl
  BG.n_time = data.time or ""
  BG.n_room = data.room or ""
  BG.n_memo = data.memo or ""
  BG.n_sec = data.sec or 0
  noti = window.webkitNotifications.createHTMLNotification("notification.html")
  noti.show()
  if n_sec > 0
    setTimeout (->
      noti.cancel()
    ), n_sec * 1000
  noti
setBadge = (text) ->
  chrome.browserAction.setBadgeText text: text

setBadgeColor = (color) ->
  chrome.browserAction.setBadgeBackgroundColor color: color

init = ->
  unless localStorage["_init"] is "_init"
    setTimeout ->
      chrome.tabs.create( url: "./option.html", null)
    , 1000
  else
    clearInterval serverTimer
    clearInterval eventTimer
    sCheck = localStorage["serverCheckInterval"]
    eCheck = localStorage["eventCheckInterval"]
    getEvents()
    serverTimer = setInterval(getEvents, sCheck * 1000 * 60)
    eventTimer = setInterval(notifyEvent, eCheck * 1000)

timeToDate = (ds) ->
  ms = ds.match(/\d{2}:\d{2}/g)
  st = ms[0].match(/(\d{2}):(\d{2})/)
  en = undefined
  start = undefined
  end = undefined
  allDay = false
  if ms.length is 2
    en = ms[1].match(/(\d{2}):(\d{2})/)
    allDay = true  if ms[0] is "00:00" and ms[1] is "23:59"
  else
    en = st
  start = new Date(today.getYear() + 1900, today.getMonth(), today.getDate(), st[1] - 0, st[2] - 0).getTime()
  end = new Date(today.getYear() + 1900, today.getMonth(), today.getDate(), en[1] - 0, en[2] - 0).getTime()
  start: start
  end: end
  allDay: allDay

getSearchUrl = (query='') ->
  getRootUrl() + "/schedule/index?gid=search&search_text=#{query}"

getPendingsUrl = ->
  getRootUrl() + "/notification/pending_list?"

getRootUrl = ->
  cybozuUrl = localStorage.cybozuUrl
  cybozuUrl.slice(0, cybozuUrl.indexOf("/portal/"))

getHost = ->
  cybozuUrl = localStorage.cybozuUrl
  cybozuUrl.split("/")[0] + "//" + cybozuUrl.split("/")[2]

getPendings = (callback) ->
  #TODO この辺は正規表現でやりたい
  id = localStorage._account
  pass = localStorage._password
  idpass = "_account=" + id + "&_password=" + pass
  $.ajaxSetup {cache: false}
  $.get getPendingsUrl() + idpass, (html) ->
    trs = $("#view_part tbody tr", $(html))
    BG.pendings = []
    i = 2

    while i < trs.length
      tr = $(trs[i])
      tds = $("td", tr)
      title = $(tds[1]).text()
      link = getHost() + $("a", tds[1]).attr("href")
      message = $(tds[2]).text()
      userName = $(tds[3]).text()
      updated = $(tds[4]).text()
      BG.pendings.push
        title: title
        link: link
        message: message
        userName: userName
        updated: updated
      i++
    if BG.pendings.length > 0
      setBadge "" + BG.pendings.length
    else
      setBadge ""

    callback() if callback

getEvent = (eventId) ->
  id = localStorage._account
  pass = localStorage._password
  cybozuUrl = localStorage.cybozuUrl
  p_idx = cybozuUrl.indexOf("/portal/")
  eventUrl = cybozuUrl.slice(0, p_idx) + "/schedule/view?event=" + eventId + "&"
  idpass = "_account=" + id + "&_password=" + pass
  $.get eventUrl + idpass, (html) ->
    mainarea = $("div.mainarea", html)
    viewTable = $("table.view_table", mainarea)[1]
    trs = $("tr", viewTable)
    tds = $("td", trs)
    timeStr = $(tds[0]).text()
    dates = timeToDate(timeStr)
    name = undefined
    room = undefined
    memo = undefined
    #unless BG.events[eventId]
    #  BG.events[eventId] = {}
    #  BG.events[eventId].notified = false
    if timeStr.match(/\d{4}/)
      name = $(tds[1]).text()
      room = $($("span.voice", tds[2])).text()
      memo = $(tds[3]).text()
    else
      name = $(tds[2]).text()
      room = $($("span.voice", tds[3])).text()
      memo = $(tds[4]).text()
    BG.events.push
      id: eventId
      name: name
      link: eventUrl
      start: dates.start
      end: dates.end
      allDay: dates.allDay
      room: room
      memo: memo

getEvents = (callback) ->
  cybozuUrl = localStorage["cybozuUrl"]
  id = localStorage["_account"]
  pass = localStorage["_password"]
  if not cybozuUrl or not id or not pass
    notify message: "設定が不正です"
    return
  loginUrl = cybozuUrl + "_account=" + id + "&_password=" + pass
  BG.events = []
  BG.rawEvents = []
  $.ajaxSetup {cache: false}
  $.get loginUrl, (html) ->
    weektd = $("td.s_user_week.normalEvent", "<div>" + html + "</div>")
    if weektd.length is 0
      if callback
        callback
          message: "ログイン失敗。設定を見直して下さい"
          sec: 0
    else
      eventElem = $(".normalEventElement", weektd[0])
      unless BG.today.getDate() is new Date().getDate()
        console.log "new day!"
        BG.events = []
        BG.rawEvents = []
        BG.notified = []
        BG.today = new Date()
      for elem in eventElem
        eventLink = $("a", elem).attr("href")
        if eventLink
          BG.rawEvents.push elem
          match = eventLink.match("event=([0-9]+)")
          getEvent match[1]  if match
      callback? {message: "ログイン成功!",sec: 3}

dateToTimeStr = (d) ->
  m = d.getMinutes()
  h = d.getHours()
  m = "0" + m  if m < 10
  h = "0" + h  if h < 10
  h + ":" + m

notifyEvent = ->
  getPendings()
  now = new Date().getTime()
  tgt = now + (localStorage.eventBefore - 0) * 1000 * 60
  for ev in events
    st = ev.start
    en = ev.end
    if not (ev.id in BG.notified) and (now < st < tgt)
      start = dateToTimeStr(new Date(st))
      end = dateToTimeStr(new Date(en))
      msg =
        message: ev.name
        link: ev.link
        time: start + " - " + end
        room: ev.room
        memo: ev.memo
        sec: localStorage.closeAfter

      notify msg
      BG.notified.push ev.id
      break
    else
events = []
rawEvents = []
notified = []
pendings = []
BG = this
serverTimer = undefined
eventTimer = undefined
timeOffset = 0
BG.today = new Date(2000, 1, new Date().getDate() - 1)
$.get '/manifest.json', (data) ->
  mt = data.match(/"version".*"(.*)"/)
  BG.version = mt[1]
