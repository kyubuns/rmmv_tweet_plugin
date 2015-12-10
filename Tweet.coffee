###:
# @plugindesc ツイートする
# @author kyubuns
#
# @param url
# @desc ツイートの末尾につけるURL(ex. http://kyubuns.net/ )
#
# @param via
# @desc ツイートの末尾につけるアカウント(ex. kyubuns )
#
# @help
#
# Plugin Command:
#   Tweet (message)
#
# Example:
#   Tweet \V[0001]点を取りました！ http://kyubuns.net/
#
# 動作確認済み環境:
#   Mac
#   * Chrome(Version47)
#   iOS
#   * Safari(iOS9) (Twitter公式アプリのインストールが必要)
#   * Chrome(Version47)
#
# 非対応環境:
#   Mac
#   * Safari(Version9)
#   iOS
#   * Firefox(Version1.2)
#
# License:
#   Copyright (c) 2015 kyubuns ( http://kyubuns.net/ )
#
#   licensed under the MIT License.
#   http://opensource.org/licenses/mit-license.php
###


_Game_Interpreter_command356 = Game_Interpreter.prototype.command356
Game_Interpreter.prototype.command356 = ->
  if this._params[0].split(" ")[0] == 'Tweet'
    $gameSystem.tweet(this._params[0])
  _Game_Interpreter_command356.call(this)


Game_System.prototype.tweet = (rawMessage) ->
  userAgent = window.navigator.userAgent.toLowerCase()

  if userAgent.indexOf('iphone') > 0
    # iOSは別処理
    tweet_iOS(rawMessage)
    return

  if userAgent.indexOf('chrome') == -1 && userAgent.indexOf('safari') > 0
    # Mac/Safariは未対応
    alert('Mac/Safariからはツイートできません。')
    return

  url = getTweetUrl(rawMessage)
  window.open(url, '_blank')


tweet_iOS = (rawMessage) ->
  userAgent = window.navigator.userAgent.toLowerCase()

  if userAgent.indexOf('fxios') > 0
    # iOS/Firefox
    alert('iOS/Firefoxからはツイートできません。')
    return

  if userAgent.indexOf('crios') > 0
    # iOS/Chrome
    url = getTweetUrl(rawMessage)
    window.open(url, '_blank')
    return

  # iOS/Safari
  start = new Date().getTime()
  url = getTweetUrl_iOS(rawMessage)
  window.location = url

  setTimeout(
    ->
      diff = new Date().getTime() - start
      if diff < 500 + 50
        alert('iOSからツイートするには、Twitter公式アプリをインストールする必要があります。')
  , 500)


getTweetUrl = (rawMessage) ->
  message = Window_Base.prototype.convertEscapeCharacters(rawMessage.slice(6))
  parameters = PluginManager.parameters('Tweet')
  paramUrl = String(parameters['url'] || '')
  via = String(parameters['via'] || '')
  url = 'https://twitter.com/intent/tweet?'
  url += "text=" + encodeURIComponent(message)
  url += "&url=" + encodeURIComponent(paramUrl) if url != ''
  url += "&via=" + encodeURIComponent(via) if via != ''
  url


getTweetUrl_iOS = (rawMessage) ->
  parameters = PluginManager.parameters('Tweet')
  paramUrl = String(parameters['url'] || '')
  via = String(parameters['via'] || '')
  message = Window_Base.prototype.convertEscapeCharacters(rawMessage.slice(6))
  message += ' ' + paramUrl if url != ''
  message += ' via @' + via if via != ''
  url = 'twitter://post?'
  url += "message=" + encodeURIComponent(message)
  url
