freshdom = (dom, index) ->
  dom.children("select")[0].selectedIndex = index
  for col, i in dom.children("div.tabs-column").children("div")
    if i is index
      $(col).show()
    else
      $(col).hide()

# dom -- 当前jquery元素
# root -- 当前form，jquery元素
# domfuns -- 所有插件提供的函数
# boxfuns -- 所有框架提供的可调用的函数
box.initdom = (dom, root, domfuns, boxfuns)->
  dom.children("select").change ->
    freshdom dom, this.selectedIndex

# 这是当初始化用户数据的时候调用，dom是jquery对象，value是要设置的值
box.setValue = (dom, value, callback)->
  if value and value[0]
    # 设置激活状态
    boxname = Object.keys(value[0])[0]
    if boxname
      for item, i in dom.children("div.tabs-column").children("div")
        if $(item).find("""[boxname=#{boxname}]""")[0]
          freshdom dom, i
          break

  callback 0

#得到当前插件的值
#box.getValue = (dom, callback)->
  #callback 0, dom.find('input').val()
