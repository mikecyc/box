###
  邮件插件
###
init = (PluginPub) ->
  #普通的插件继承PluginPub这个类
  class Email extends PluginPub
    constructor: (@label)->
      @_pluginType = "Email"

# 定义插件自己的html
    setEditviewHtml: (id, name, label) ->
      viewHtml = $ """
        <div id='#{id}'  class='plugin-border'>
          <label class='wbk-plugin-title'>
              邮件地址:
          </label>
        <div class='wbk-plugin-container'>
          <input type="text" name="#{@name or 'unknow'}"
          data-msg-email="请输入邮件地址!"
          data-msg-required="该字段不能为空!"
          data-rule-email="true"
          data-rule-required="true"
          value='xxx@webank.com'
          />
        </div>
        <label>插件name属性:</label><input type='text' class='nameProperType' placeholder='请输入控件的name属性' value='#{name}' />
          <code class='errMsg'></code>
        </div>
      """
      @_editview = viewHtml

# 定义拖拽的时候插件的样子
    getDragview: -> $ "<h1>[邮件输入框]</h1>"

# 重写setName 方法
    setName: (name)=>
      @_name = name
      #这里要写自己的set方法,因为邮件也是input,所以参数是input
      @setPluginName(name, "input") # 修改chkeckbox控件的name


# 获取插件的html,当保存插件的时候调用
    getPluginHtml: =>
      console.log "new get Email Plugin! "
      if @verifyEdit()
        id = @_globalId
        wbkdom = $('#' + id).clone(true)
        wbkContainer = wbkdom.find('.wbk-plugin-container')
        pluginLabel = wbkdom.find('.wbk-plugin-title')
        if (pluginLabel.find('.plugin-title-input'))
          inputDom = pluginLabel.find('.plugin-title-input')
          pluginLabel.text(inputDom.val())
        wbkContainer.prepend(pluginLabel)
        console.log wbkContainer.prop('outerHTML')
        return wbkContainer.prop('outerHTML')
      else
        console.log "get Email Plugin false!"
        return false

# 创建插件本身的描述json,用来在编辑的时候使用
    createPluginJson: =>
      if @verifyEdit()
        tmpJson =
          name: @getName()
          label: @getPluginLabel()
        @setPluginJson(tmpJson)
        console.log tmpJson
        return true
      else
        console.log "create Email plugin json error!"
        return false

# 根据插件本身的描述json创建插件的dom
    createFormByJson: (json)=>
      console.log "create Email!"
      #      #修改name8u
      @setName(json.name)
      @setPluginLabel(json.label)
      id = @_globalId
      wbkDom = $('#' + id)
      @bindPluginEvent(wbkDom)

# 继承并丰富事件绑定的方法
    bindPluginEvent: (e) =>
      super(e)

#页面初始化
    initdom: (o)->
      tmpJson = @getPluginJson()
      if tmpJson.label?
        @createFormByJson(@getPluginJson())

      #绑定事件
      @bindPluginEvent(o)

    getJs: ->
      js = super()
      js.push "Email"
      js

  # set if requirejs
  if define? and define.amd
    define [], -> Email
  else if window?
    window.Email = Email

#开始运行
if require?
  require ["PluginPub"], init
else
  init window.PluginPub
