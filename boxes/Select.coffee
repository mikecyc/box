# 下拉选框
init = (BoxBase) ->
  class Select extends Radio
    constructor: (@label)->

    _pluginType: "select"

# 获取增加的html代码
    getBaseHtml: (value, text, canDel) =>
      if canDel?
        return """
          <div class='ckb-container'>
            <label>选项的值:</label>
              <input type="text" class='option-value' placeholder='请输入选项的值'  value='#{value}'/>
            <label>选项的文本:</label>
              <input type="text" class='option-text' placeholder='请输入选项的文本' value='#{text}'/>
            <span class='delCkb glyphicon glyphicon-minus'></span>
          </div>
        """
      else
        return """
          <div class='ckb-container'>
            <label>选项的值:</label>
              <input type="text" class='option-value' placeholder='请输入选项的值'  value='#{value}'/>
            <label>选项的文本:</label>
              <input type="text" class='option-text' placeholder='请输入选项的文本' value='#{text}'/>
          </div>
        """

#定义插件自己的html
    setEditviewHtml: (id, name, label) ->
      viewHtml = $ """
        <div id='#{id}' class='plugin-border'>
          <label class='wbk-plugin-title'>
            <input class='plugin-title-input' type="text"  placeholder='请输入复选框标题'/>
          </label>
          <div class='wbk-plugin-container'>
            <select class='form-control wbk-select' name='#{name}'>
              <option value='select-0'>select-0</option>
            </select>
            <div class='ckb-container'>
              <label>选项的值:</label>
                <input type="text" class='option-value' placeholder='请输入选项的值'  value='select-0'/>
              <label>选项的文本:</label>
                <input type="text" class='option-text' placeholder='请输入选项的文本' value='select-0'/>
            </div>
          </div>
          <button class='btn btn-default btn-sm addCkb'>增加选项</button>
          <button class='btn btn-default btn-sm getPluginHtml'>插件的html</button>
          <button class='btn btn-default btn-sm getPluginJson'>插件的Json</button>
          <button class='btn btn-default btn-sm createForm'>生成dom</button>
          <label>插件name属性:</label><input type='text' class='nameProperType' placeholder='请输入控件的name属性' value='#{name}' />
          <code class='errMsg'></code>
        </div>
      """
      @_editview = viewHtml

    getDragview: -> $ "<h1>[下拉选择框]</h1>"


# 增加一行,多行控件适用
    addOption: (e)->
      text = 'select-' + Math.ceil(Math.random() * 100000)
      value = text
      newLine = @getBaseHtml(value, text, true)
      e.append(newLine)
      @bindPluginEvent(e)


# 根据input的值刷新select插件
    updateOptions: =>
      @errMsgShow(false);
      id = @getGlobalId()
      wbkdom = $('#' + id)
      select = wbkdom.find('select')

      valList = []
      textList = []
      optionList = []

      wbkdom.find('.ckb-container').each (i, e)=>
        value = $(e).find('.option-value').val()
        text = $(e).find('.option-text').val()

        if text is ""
          text = 'select-' + Math.ceil(Math.random() * 100000)
          $(e).find('.option-text').val(text)
          msg = "选项的文本为空,已经自动设置成:#{text}"
          @errMsgShow(true, msg)
        if value is ""
          value = 'select-' + Math.ceil(Math.random() * 100000)
          $(e).find('.option-value').val(value)
          msg = "选项的value为空,已经自动设置成:#{value}"
          @errMsgShow(true, msg)


        if text in textList
          text = text + '-' + Math.ceil(Math.random() * 100000)
          $(e).find('.option-text').val(text)
          msg = "选项的value有重复,已经自动设置成:#{text}"
          @errMsgShow(true, msg)

        if value in valList
          value = value + '-' + Math.ceil(Math.random() * 100000)
          $(e).find('.option-value').val(value)
          msg = "选项的文本有重复,已经自动设置成:#{value}"
          @errMsgShow(true, msg)

        valList.push(value)
        textList.push(text)
      select.empty();
      for val,i in valList
        select.append("<option value='#{val}'>#{textList[i]}</option>")
        tmpObj =
          value: val
          text: textList[i]
        optionList.push(tmpObj)

      #设置插件的json
      tmpJson =
        name: @getName()
        label: @getPluginLabel()
        optionList: optionList
      @setPluginJson(tmpJson)


# 检查控件是否配置正确
    verifyEdit: ->
      result = true

      id = @_globalId
      wbkDom = $('#' + id)
      if !@checkPluginLabel(wbkDom)
        result = false
      else
        @updateOptions()

      @_globalEditVerify = result
      return result

# 获取插件的html
    getPluginHtml: =>
      if @verifyEdit()
        id = @_globalId
        wbkdom = $('#' + id).clone(true)
        wbkContainer = wbkdom.find('.wbk-plugin-container')
        pluginLabel = wbkdom.find('.wbk-plugin-title')
        inputDom = pluginLabel.find('.plugin-title-input')
        pluginLabel.text(inputDom.val())
        wbkContainer.prepend(pluginLabel)
        wbkContainer.find('.ckb-container').each (i, e) =>
          $(e).remove()
        console.log wbkContainer.prop('outerHTML')
        return wbkContainer.prop('outerHTML')
      else
        console.log "select getPluginHtml error"
        return false


# 根据插件本身的描述json创建插件的dom
    createFormByJson: (json)=>
      console.log "create"
      #修改name
      @setName(json.name)
      @setPluginLabel(json.label)

      id = @_globalId
      wbkDom = $('#' + id)
      name = wbkDom.find(".nameProperType")
      name.val(@getName())
      wbkContainer = wbkDom.find('.wbk-plugin-container')

      #清空select和input
      wbkContainer.find('.ckb-container').each (i, e) =>
        $(e).remove()
      select = wbkDom.find('select')
      select.empty()

      optionList = json.optionList
      for option,index in optionList
        select.append("<option value='#{option.value}'>#{option.text}</option>")
        if 0 is index
          domHtml = @getBaseHtml(option.value, option.text)
          wbkContainer.append(domHtml)
        else
          domHtml = @getBaseHtml(option.value, option.text, true)
          wbkContainer.append(domHtml)

      @bindPluginEvent(wbkDom)

# 初始化
    initdom: (o)->

      testJson =
        name: "testSlect"
        label: "测试下拉选框"
        optionList: [
          {
            value:"123"
            text:"123选项"
          },
          {
            value:"345"
            text:"345选项"
          }
        ]
      @setPluginJson(testJson)

#      tmpJson = @getPluginJson()
#      if tmpJson.label? and tmpJson.optionList?
#        @createFormByJson(@getPluginJson())
      tmpJson = @getPluginJson()
      if tmpJson.label?
        @createFormByJson(@getPluginJson())

      #绑定事件
      @bindPluginEvent(o)

    getJs: ->
      js = super()
      js.push "Select"
      js

  # set if requirejs21
  if define? and define.amd
    define [], -> Select
  else if window?
    window.Select = Select

# 开始运行
if require?
  require ["BoxBase"], init
else
  init window.BoxBase
