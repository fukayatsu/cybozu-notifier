$("a").each ->
  url = $(this).attr("href")
  return  unless url

  unless url.indexOf("/schedule/view") is -1
    $(this).attr("rel", url).cluetip
      width: 500
      showTitle: false
      ajaxProcess: (html) ->
        mainarea = $("div.mainarea", html)
        mainarea.html()

  else unless url.indexOf("/user_view") is -1
    unless url.indexOf("javascript") is -1
      ms = url.match(/popupWin\(\'(.*)\',\'/)
      url = ms[1].replace("/grn/user_view", "/schedule/user_view")
    console.log url
    $(this).attr("rel", url).cluetip
      width: 265
      showTitle: false
      ajaxProcess: (html) ->
        mainarea = $("div.mainarea", html)
        viewTable = $("table.view_table", mainarea)
        img = $("img", viewTable)[0]
        src = "\"" + $(img).attr("src") + "\""
        "<img src=" + src + ">"
