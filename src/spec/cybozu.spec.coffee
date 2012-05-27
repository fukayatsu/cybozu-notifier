Cybozu = require '../lib/cybozu'

defaultConfig =
  url:"http://onlinedemo.cybozu.co.jp/"+
        "scripts/garoon3/grn.exe/portal/index?"
  id:"sato"
  pass:"sato"

describe 'Cybozu', ->
  describe 'インスタンス生成時', ->
    cyb = new Cybozu defaultConfig
    it '設定が正しいこと', -> 
      expect(cyb.config.id).toEqual 'sato'
      expect(cyb.config.pass).toEqual 'sato'
      expect(cyb.config.url).toEqual defaultConfig.url

  describe '予定を取得する時', ->
    cyb = new Cybozu defaultConfig
    it "ユーザ名が取得できる", ->
      cyb.getEvents (data)->
        expect(data).toEqual '佐藤'
        asyncSpecDone()
      asyncSpecWait()
