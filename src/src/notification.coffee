BG = chrome.extension.getBackgroundPage()
$("#message").attr("href", BG.n_link).text BG.n_message
$("#time").text BG.n_time
$("#room").text BG.n_room
$("#memo").text BG.n_memo
message = document.getElementById("message")
