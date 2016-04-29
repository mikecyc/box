# 表单统一用 jquery.validate.js 进行处理，请在要验证的input节点上加上相关的信息，如
#  data-msg-number="The field RangeAndNumberDemo must be a number."
#  data-msg-range="The field RangeAndNumberDemo must be between -20 and 40."
#  data-rule-number="true"
#  data-rule-range="[-20,40]"
# 下面的js可以附加解决一些问题，如添加 jquery.validate 验证插件等

# 这是当初始化用户数据的时候调用
# dom -- 当前jquery元素
# root -- 当前form，jquery元素
# domfuns -- 所有插件提供的函数
# boxfuns -- 所有框架提供的可调用的函数
#box.initdom = (dom, root, domfuns, boxfuns)->
  #console.log dom, root, domfuns, boxfuns

box.setValue = (dom, value, callback)->
  dom.find("input").val value
  callback 0

#得到当前插件的值
box.getValue = (dom, callback)->
  callback 0, dom.find('input').val()
