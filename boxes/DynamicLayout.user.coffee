# dom -- 当前jquery元素
# root -- 当前form，jquery元素
# domfuns -- 所有插件提供的函数
# boxfuns -- 所有框架提供的可调用的函数

box.initdom = (dom, root, domfuns, boxfuns)->
  cdom = dom.clone()
  bindfun = (dom) ->
    dom.delegate ".dl-btn>button.btn", 'click', (e)->
      e.preventDefault()
      t = $ this
      box = t.closest "[boxname]"
      if t.is ".minus"
        if not box.siblings("[boxname=#{box.attr 'boxname'}]")[0]
          $.notify "至少要保留一项"
          return
        box.remove()
      else if t.is ".plus"
        d = cdom.clone()
        box.after d
        bindfun d
        boxfuns.getValue box, (err, val) ->
          return $.notify "复制初始化数据出错" if err
          boxfuns.initdom d
          boxfuns.setValue val, d, (err) ->
            return $.notify "初始化插件数据出错" if err
      return
  bindfun dom

# 这是当初始化用户数据的时候调用，dom是jquery对象，value是要设置的值
  box.setValue = (dom, value, callback)->
    boxname = dom.attr "boxname"
    alldom = dom.parent().children "[boxname=#{boxname}]"
    index = 0
    while value.length > alldom.length + index
      d = cdom.clone()
      dom.after d
      boxfuns.initdom d
      index++
    callback 0

#得到当前插件的值
#box.getValue = (dom, callback)->
  #callback 0, dom.find('input').val()
