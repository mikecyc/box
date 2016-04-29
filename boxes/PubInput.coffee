init = (PluginPub) ->
  class PubInput extends PluginPub
    constructor: (@label)->
      @_pluginType = "PubInput"

#定义插件自己的html
    setEditviewHtml: (id, name, label) ->
      viewHtml = $ """
        <div id='#{id}'  class='plugin-border'>
          <label class='wbk-plugin-title'>
            <input class='plugin-title-input' placeholder='请输入标题'/>
          </label>
        <div class='wbk-plugin-container'>
          <input name='#{name or 'unknow'}' id='' cols='30' rows='5'></input>
        </div>
          <label>插件name属性:</label><input type='text' class='nameProperType' placeholder='请输入控件的name属性' value='#{name}' />
          <label>是否必填: &nbsp;</label><input type='checkbox' class='ifNeedVal' />
          <code class='errMsg'></code>
        </div>
      """
      @_editview = viewHtml

    getDragview: -> $ "<h1>[文本框]</h1>"

# 重写setName 方法
    setName: (name)=>
      @_name = name
      #这里要写自己的set方法
      @setPluginName(name, "textarea") # 修改chkeckbox控件的name
      @setPluginVal(name, ".nameProperType") # 修改对应input框的值



# 获取插件的html
    getPluginHtml: =>
      console.log "new getPluginHtml"
      if @verifyEdit()
        id = @_globalId
        wbkdom = $('#' + id).clone(true)
        wbkContainer = wbkdom.find('.wbk-plugin-container')
        pluginLabel = wbkdom.find('.wbk-plugin-title')
        inputDom = pluginLabel.find('.plugin-title-input')
        tmpHtml = "<nobr>"+inputDom.val()+"</nobr>"
        pluginLabel.html(tmpHtml)
        wbkContainer.prepend(pluginLabel)
        console.log wbkContainer.prop('outerHTML')
        return wbkContainer.prop('outerHTML')
      else
        console.log "false"
        return false

# 创建插件本身的描述json
    createPluginJson: =>
      if @verifyEdit()
        tmpJson =
          name: @getName()
          label: @getPluginLabel()
        @setPluginJson(tmpJson)
        console.log tmpJson
        return true
      else
        console.log "create PubInput plugin json error!"
        return false

# 根据插件本身的描述json创建插件的dom
    createFormByJson: (json)=>
      console.log "create TextArea"
      #      #修改name
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
      ifNeedVal = o.find('.ifNeedVal')
      inputDom = o.find('.wbk-plugin-container').find('input')
      ifNeedVal.change (e) =>
        if $(e.target).is(':checked')
          inputDom.attr('data-msg-required','该字段不能为空!')
          inputDom.attr('data-rule-required','true')
        else
          inputDom.attr('data-msg-required','')
          inputDom.attr('data-rule-required','false')

      tmpJson = @getPluginJson()
      if tmpJson.label?
        @createFormByJson(@getPluginJson())

      #绑定事件
      @bindPluginEvent(o)

    getJs: ->
      js = super()
      js.push "PubInput"
      js

  # set if requirejs
  if define? and define.amd
    define [], -> PubInput
  else if window?
    window.PubInput = PubInput

#开始运行
if require?
  require ["PluginPub"], init
else
  init window.PluginPub
