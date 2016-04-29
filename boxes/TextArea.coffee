init = (PluginPub) ->
  class TextArea extends PluginPub
    constructor: (@label)->
      @_pluginType = "TextArea"
      @_textareaLine = ""
      @_ifNeedVal = ""

#定义插件自己的html
    setEditviewHtml: (id, name, label) ->
      viewHtml = $ """
        <div id='#{id}'  class='plugin-border'>
          <label class='wbk-plugin-title'>
            <input class='plugin-title-input' placeholder='请输入文本框标题'/>
          </label>
        <div class='wbk-plugin-container'>
          <textarea name='#{name or 'unknow'}' id='' cols='30' rows='1'></textarea>
        </div>
          <button class='btn btn-default btn-sm getPluginHtml'>插件的html</button>
          <button class='btn btn-default btn-sm getPluginJson'>插件的Json</button>
          <button class='btn btn-default btn-sm createForm'>生成dom</button>
          <label>插件name属性:</label><input type='text' class='nameProperType' placeholder='请输入控件的name属性' value='#{name}' />
          <label>是否必填: &nbsp;</label><input type='checkbox' class='ifNeedVal' placeholder='请输入控件的name属性' />
          <label>文本框行数: &nbsp;</label>
          <select name='' class=' textarea-line' style='width: 100px;display: inline-block'>
            <option value='1'>1行</option>
            <option value='5'>5行</option>
            <option value='10'>10行</option>
            <option value='15'>15行</option>
          </select>
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
          textareaLine: @_textareaLine
          ifNeedVal : @_ifNeedVal

        @setPluginJson(tmpJson)
        console.log tmpJson
        return true
      else
        console.log "create TextArea plugin json error!"
        return false

    setTextareaLine:(e,line) =>
      @setPluginPrototype(e, "rows", line)
# 根据插件本身的描述json创建插件的dom
    createFormByJson: (json)=>
      console.log "create TextArea"
#      #修改name
      @setName(json.name)
      @setPluginLabel(json.label)

      id = @_globalId
      wbkDom = $('#' + id)
#      console.log json.textareaLine
      @setTextareaLine( wbkDom.find('textarea'),json.textareaLine)
      tl = wbkDom.find('.textarea-line')
      tl.val(json.textareaLine)

      ifNeedVal = wbkDom.find('.ifNeedVal')
      if json.ifNeedVal is 1
        ifNeedVal.eq(0).attr('checked','true')


      @bindPluginEvent(wbkDom)

# 继承并丰富事件绑定的方法
    bindPluginEvent: (e) =>
      super(e)

    #页面初始化
    initdom: (o)->
      ifNeedVal = o.find('.ifNeedVal')
      textareaLine = o.find('.textarea-line')
      textareaDom = o.find('.wbk-plugin-container').find('textarea')
      ifNeedVal.change (e) =>
        if $(e.target).is(':checked')
          textareaDom.attr('data-msg-required','该字段不能为空!')
          textareaDom.attr('data-rule-required','true')
          @_ifNeedVal = 1
        else
          textareaDom.attr('data-msg-required','')
          textareaDom.attr('data-rule-required','false')
          @_ifNeedVal = 0

      textareaLine.change (e) =>
        textareaDom.attr('rows',$(e.target).val())
        @_textareaLine = $(e.target).val()

      tmpJson = @getPluginJson()
      if tmpJson.label?
        @createFormByJson(@getPluginJson())

      #绑定事件
      @bindPluginEvent(o)

    getJs: ->
      js = super()
      js.push "TextArea"
      js

  # set if requirejs
  if define? and define.amd
    define [], -> TextArea
  else if window?
    window.TextArea = TextArea

#开始运行
if require?
  require ["PluginPub"], init
else
  init window.PluginPub
