###
  插件公共类
###
init = (BoxBase) ->
  class PluginPub extends BoxBase
    constructor: (@label)->

      ###
      私有变量
      ###
    _globalId: ""
    _globalEditVerify: false
    _globalFormVerify: false

# 插件的描述json
    _pluginJson: {}
# 插件的标题
    _pluginLabel: "插件标题"
# 插件的类型
    _pluginType: ""


# Get/Set 方法
    getGlobalId: -> @_globalId
    setGlobalId: (id)-> @_globalId = id
    getPluginJson: -> @_pluginJson
    setPluginJson: (json) -> @_pluginJson = json
    getEditviewHtml: -> @_editview
    setEditviewHtml: (id, name, label) ->
      viewHtml = $ """ <span></span> """
      @_editview = viewHtml
    getPluginLabel: -> @_pluginLabel
    getPluginType: -> @_pluginType
    setPluginType: (pluginType) -> @_pluginType = pluginType





# 设置所有控件Dom的name属性
    setPluginName: (name, domKeyword)=>
      id = @getGlobalId()
      cbkDom = $('#' + id)
      cbkDom.find(domKeyword).each (i, e)=>
        @setPluginPrototype(e, "name", name)

# 设置对象的值
    setPluginVal: (value, domKeyWord)=>
      id = @getGlobalId()
      wbkDom = $('#' + id)
      tmpDom = wbkDom.find(domKeyWord)
      if tmpDom?
        tmpDom.val(value)

# 设置插件的label属性
    setPluginLabel: (labelText) ->
      @_pluginLabel = labelText
      @setPluginVal(labelText, ".plugin-title-input")

# 重写setName 方法
    setName: (name)=>
      @_name = name
      #这里要写自己的set方法
      if "" isnt @getPluginType()
        @setPluginName(name, @getPluginType()) # 修改chkeckbox控件的name
      @setPluginVal(name, ".nameProperType") # 修改对应input框的值

# 初始化name
    initPluginName: =>
      name = @getName()
      if name? or ("" is name)
        name = "box-" + Math.ceil(Math.random() * 100000)
      else
        name += Math.ceil(Math.random() * 100000)
      @setName(name)

# 初始化插件的id
    initPluginId: =>
      id = "box-" + new Date().getTime() + Math.ceil(Math.random() * 1000)
      @setGlobalId(id)

# 初始化插件的标题
    initPluginLabel: =>
      @setPluginLabel("插件标题")

# 插件加载前的初始化操作
    pluginLoadInit: =>
      @initPluginId()
      @initPluginName()
      @initPluginLabel()

# 当设置插件的标题的input内容发生变化时的处理函数
    pluginTitleInputChange: ()=>
      id = @getGlobalId()
      wbkDom = $('#' + id)
      input = wbkDom.find('.plugin-title-input').val()
      input = input.replace(/(^\s*)|(\s*$)/g, "")
      if "" isnt input
        if input isnt @getPluginLabel()
          @setPluginLabel(input)
          @errMsgShow(false)
      else
        msg = "插件名称不能为空,否则插件名称将默认为: 插件标题"
        @setPluginLabel("插件标题")
        @errMsgShow(true, msg)



# 当设置插件name属性的input内容变化时处理函数
    pluginNameInputChange: ()=>
      id = @getGlobalId()
      wbkDom = $('#' + id)
      name = wbkDom.find(".nameProperType").val()
      name = name.replace(/(^\s*)|(\s*$)/g, "")
      if ("" isnt name)
        if name isnt @getName() #如果名称不同才做操作
          @setName(name)
          @errMsgShow(false)
      else
        msg = "name不能为空,否则插件标题将默认为最近一次的名称:#{@getName()}"
        @setName(@getName())
        @errMsgShow(true, msg)


# 错误信息显示
    errMsgShow: (flag, msg) =>
      id = @_globalId
      cbkDom = $('#' + id)
      if flag? and msg?
        cbkDom.find('.errMsg').text(msg)
        cbkDom.find('.errMsg').css("display", "inline")
      else
        cbkDom.find('.errMsg').text("")
        cbkDom.find('.errMsg').css("display", "none")


# 获取增加的html代码
    getBaseHtml: (name, value, canDel) =>
      return """<span>#{name}#{value}#{canDel}</span>"""

# 拖拽的时候显示的样子
    getDragview: -> $ "<h1>[插件名称]</h1>"

# 编辑的时候显示的样子
    getEditview: =>

# 插件加载初始化
      @pluginLoadInit()

      id = @getGlobalId()
      name = @getName()
      label = @getPluginLabel()
      #生成对应的html代码
      @setEditviewHtml(id, name, label)

# 编辑的时候显示的工具栏
    getToolview: ->
      @_toolview = $ """
        <span class="btn-group btn-group-xs"></span>
      """


# 绑定控件的事件
    bindPluginEvent: (e)=>
      e.find(".nameProperType").change ()=>
        @pluginNameInputChange()

      e.find(".getPluginHtml").click =>
        @getPluginHtml()

      e.find(".getPluginJson").click =>
        @createPluginJson()

      e.find(".createForm").click =>
        @createFormByJson(@getPluginJson())

      e.find(".plugin-title-input").change ()=>
        @pluginTitleInputChange()

# 检查插件的标题是否为空
    checkPluginLabel:(obj)=>
      result = false
      inputDom = obj.find('.plugin-title-input')
      if inputDom? and "" isnt inputDom.val()
        @errMsgShow(false)
        result = true
      else
        msg = '请输入插件的标题'
        @errMsgShow(true,msg)
        result = false
      return result


# 检查控件是否配置正确
    verifyEdit: ->
      result = true
      id = @_globalId
      wbkDom = $('#' + id)
      if !@checkPluginLabel(wbkDom)
        result = false

      @_globalEditVerify = result
      return result

# 获取插件的html
    getPluginHtml: =>
      console.log "public class fn getPluginHtml"
      return ""

# 创建插件本身的描述json
    createPluginJson: =>
      console.log "public class fn getPluginJson"
      return ""

# 根据插件本身的描述json创建插件的dom
    createFormByJson: (json)=>
      console.log "create, public class fn createFormByJson"
      return ""

# 生成控件描述json,用来恢复控件的编辑状态
    toJson: (callback)->
      if @createPluginJson()
        callback 0, @getPluginJson()
      else
        console.log "create checkBox plugin json error!"
        callback 1

# 根据json初始化表单,用来编辑
    fromJson: (json, callback)->
      @setPluginJson(json)
      #根据json生成表单
      @createFormByJson(@getPluginJson())
      callback 0

# 生成最终的html
    toHtml: (callback)=>
      if @getPluginHtml()
        pluginHtml = @getPluginHtml()
        callback 0, pluginHtml
      else
        callback 1

# 修改控件的属性
    setPluginPrototype: (obj, key, value) ->
      $(obj).attr(key, value)

# 根据返回的json增加属性
    setValueType: (valueType, callback)->
      objson = valueType
      console.log objson
      for key,value of objson
        if ("valueType" != key)
          id = @_globalId
          ckbDom = $('#' + id)
          ckbGroup = ckbDom.find('.wbk-plugin-container')
          @setPluginPrototype(ckbGroup, key, value)
        else
          vtObj = value
          if 'object' is typeof vtObj
            for k,v of vtObj
              formObj = $('[name="'+k+'"]')
              for fk,fv of v
                @setPluginPrototype(formObj,fk,fv)
      super(valueType, callback)

# 初始化
    initdom: (o)->
      console.log "init Pub"


      #如果有初始化的json,则为编辑状态,根据json生成dom
      tmpJson = @getPluginJson()
      if tmpJson.optionList?
        @createFormByJson(@getPluginJson())

      # 绑定方法
      @bindPluginEvent(o)

  # set if requirejs21
  if define? and define.amd
    define [], -> PluginPub
  else if window?
    window.PluginPub = PluginPub

# 开始运行
if require?
  require ["BoxBase"], init
else
  init window.BoxBase

