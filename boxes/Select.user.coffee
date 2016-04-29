box.initdom = (dom)->
  console.log "Select init"

box.setValue = (dom, value, callback)->
  dom.find('select').val value
  callback 0

#得到当前插件的值
box.getValue = (dom, callback)->
  console.log dom.find('select').val()
  callback 0, dom.find('select').val()