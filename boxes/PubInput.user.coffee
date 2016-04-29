box.initdom = (dom)->
  console.log "input init"

box.setValue = (dom, value, callback)->
  dom.find('input').val value
  callback 0

#得到当前插件的值
box.getValue = (dom, callback)->
  console.log dom.find('input').val()
  callback 0, dom.find('input').val()