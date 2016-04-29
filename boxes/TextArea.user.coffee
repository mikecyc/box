box.initdom = (dom)->
  console.log "TextArea init"

box.setValue = (dom, value, callback)->
  dom.find('textarea').val value
  callback 0

#得到当前插件的值
box.getValue = (dom, callback)->
#  console.log dom[0]
#  console.log dom.find('textarea').val()
  callback 0, dom.find('textarea').val()