init = (PluginPub) ->
  class Radio extends PluginPub
    constructor: (@label)->

    _pluginType : ":radio"

# 获取增加的html代码
    getBaseHtml: (name, value, canDel) =>
      if canDel?
        return """
          <div class='ckb-container'>
            <input type="radio" name="#{name}" value='#{value}'/>
            <label class='plugin-text'><input type="text" class='labelText' placeholder='请输入选项的名称' value='#{value}'/></label>
            <span class='delCkb glyphicon glyphicon-minus'></span>
          </div>
        """
      else
        return """
          <div class='ckb-container'>
            <input type="radio" name="#{name}" value='#{value}'/>
            <label class='plugin-text'><input type="text" class='labelText' placeholder='请输入选项的名称' value='#{value}'/></label>
          </div>
        """

#定义插件自己的html
    setEditviewHtml: (id, name, label) ->
      viewHtml = $ """
        <div id='#{id}' class='plugin-border'>
          <label class='wbk-plugin-title'>
            <input class='plugin-title-input' placeholder='请输入单选框标题'/>
          </label>
          <div class='wbk-plugin-container'>
            <div class='ckb-container'>
              <input type="radio" name='#{name}'/>
              <label class='plugin-text'><input type="text" class='labelText' placeholder='请输入选项的名称'/></label>
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

    getDragview: -> $ "<h1>[单选框组]</h1>"

# 增加一行,多行控件适用
    addOption: (e)->
      newLine = @getBaseHtml(@getName(), "", true)
      e.append(newLine)
      @bindPluginEvent(e)
      name = @getName()
      @setName(name)

# 删除一行
    delOption: (p)->
      p.remove()

# 检查控件是否配置正确
    verifyEdit:() ->
      if !super()
        return false
      else
        result = true
        id = @_globalId
        valueList = []
        cbkDom = $('#' + id)
        pluginType = @getPluginType()
        cbkDom.find(pluginType).each (i, e)=>
          value = $(e).attr("value")
          console.log value
          if value? and "" isnt value
            if (value in valueList) #如果值重复
              input = $(e).next().find('input')
              input.css("background", "yellow")
              value = value + "_" + Math.ceil(Math.random() * 1000)
              $(e).attr("value", value)
              input.val(value)
              msg = "选项名称重复!"
              @errMsgShow(true, msg);
              result = false
              @_globalEditVerify = result
              return result
            else
              input = $(e).next().find('input')
              input.css("background", "white")
              valueList.push(value)
              @errMsgShow(false);
          else
            input = $(e).next().find('input')
            input.css("background", "yellow")
            result = false
            msg = '请填写全部的选项名称!'
            @errMsgShow(true, msg)
            @_globalEditVerify = result
            return result

      @_globalEditVerify = result
      if valueList?
        tmpJson =
          optionList: valueList
          name: @getName()
        @setPluginJson(tmpJson)
      return result


# 获取插件的html
    getPluginHtml: =>
      if @verifyEdit()
        id = @_globalId
        wbkdom = $('#' + id).clone(true)
        wbkContainer = wbkdom.find('.wbk-plugin-container')

        #增加标题
        pluginLabel = wbkdom.find('.wbk-plugin-title')
        inputDom = pluginLabel.find('.plugin-title-input')
        pluginLabel.text(inputDom.val())
        pluginLabel.empty()
        wbkContainer.prepend(pluginLabel)

        ckbContainer = wbkContainer.find('.ckb-container')
        ckbContainer.each (i, e) =>
          label = $(e).find('label')
          input = $(e).find('input')
          label.text(input.val())
          if $(e).find('span')?
            $(e).find('span').remove()
        console.log wbkContainer.prop('outerHTML')
        return wbkContainer.prop('outerHTML')
      else
        console.log "验证没通过"
        return false



# 创建插件本身的描述json
    createPluginJson: =>
      if @verifyEdit()
        tmpJson = @getPluginJson()
        if tmpJson.optionList?
          console.log @getPluginJson()
          return true
        else
          console.log "create #{@getPluginType()} plugin json error!"
          return false
      else
        console.log "verify error!"
        return false


# 根据插件本身的描述json创建插件的dom
    createFormByJson: (json)=>
      console.log "create"
      #修改name
      @setName(json.name)
      @setPluginLabel(json.label)

      id = @_globalId
      cbkDom = $('#' + id)
      name = cbkDom.find(".nameProperType")
      name.val(@getName())
      ckbGroup = ckbDom.find('.wbk-plugin-container')
      ckbGroup.html("")
      optionList = json.optionList
      for option,index in optionList
        if 0 is index
          domHtml = @getBaseHtml(@getName(), option)
          ckbGroup.append(domHtml)
        else
          domHtml = @getBaseHtml(@getName(), option, true)
          ckbGroup.append(domHtml)

      @bindPluginEvent(ckbDom)

# 继承并丰富事件绑定的方法
    bindPluginEvent: (e) =>
      super(e)
      e.find(".delCkb").click (obj)=>
        objDom = $(obj.target).parent()
        @delOption(objDom)

      e.find(".labelText").change (obj)=>
        value = $(obj.target).val()
        value = value.replace(/(^\s*)|(\s*$)/g, "");
        $(obj.target).val(value)
        chkbox = $(obj.target).parent().prev()
        chkbox.val(value)

      # 绑定方法
      e.find(".addCkb").click (obj)=>
        div = $(obj.target).parent();
        ckbGroup = div.find(".wbk-plugin-container")
        @addOption(ckbGroup)

#页面初始化
    initdom: (o)->

#      testJson =
#        name: "testRadio"
#        label: "测试"
#        optionList: ["aa","bb"]
#      @setPluginJson(testJson)
#
#      tmpJson = @getPluginJson()
#      if tmpJson.label? and tmpJson.optionList?
#        @createFormByJson(@getPluginJson())

      #绑定事件
      @bindPluginEvent(o)


  # set if requirejs
  if define? and define.amd
    define [], -> Radio
  else if window?
    window.Radio = Radio

#开始运行
if require?
  require ["PluginPub"], init
else
  init window.PluginPub
