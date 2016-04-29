init = (PluginPub) ->
  class DatePicker extends PluginPub
    constructor: (@label)->
#      @js = """
#           $('.datetimepicker').datetimepicker({
#              locale: 'zh-cn',
#              format: 'YYYY-MM-DD',
#              disabledTimeIntervals:[true]
#            });
#      """
      @_pluginType = "input"

#定义插件自己的html
    setEditviewHtml: (id, name, label) ->
      viewHtml = $ """
        <div id='#{id}'  class='plugin-border'>
          <label class='wbk-plugin-title'>
            <input class='plugin-title-input' placeholder='请输入标题'/>
          </label>
        <div class='wbk-plugin-container'>
        <input type="text" value="" class="datetimepicker" placeholder='点击选择日期'>
        </div>
          <button class='btn btn-default btn-sm getPluginHtml'>插件的html</button>
          <button class='btn btn-default btn-sm getPluginJson'>插件的Json</button>
          <button class='btn btn-default btn-sm createForm'>生成dom</button>
          <label>插件name属性:</label><input type='text' class='nameProperType' placeholder='请输入控件的name属性' value='#{name}' />
          <label>是否必填: &nbsp;</label><input type='checkbox' class='ifNeedVal' placeholder='请输入控件的name属性' />
          <code class='errMsg'></code>
        </div>
      """
      @_editview = viewHtml


    getDragview: -> $ "<h1>[时间选择器]</h1>"

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
        pluginLabel.text(inputDom.val())
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
        console.log "create TextArea plugin json error!"
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

# 初始化time插件

    initDatetimePicker: =>
     $('.datetimepicker').datetimepicker({
        locale: 'zh-cn',
        format: 'YYYY-MM-DD',
        disabledTimeIntervals:[true]
      });



    #页面初始化
    initdom: (o)->

      #初始化time插件
      @initDatetimePicker()

#      lala =
#        name : "testLala"
#        label: "testLabel"
#      @setPluginJson(lala)

      tmpJson = @getPluginJson()
      if tmpJson.label?
        @createFormByJson(@getPluginJson())

      #绑定事件
      @bindPluginEvent(o)

#getJs
    getJs: ->
      js = super()
      js.push "DatePicker"
      js

    getExjs: ->
      t = super()
      t['moment-with-locales'] = '1'
      t['bootstrap-datetimepicker.min'] = '!jQuery.fn.datetimepicker'
      t

  # set if requirejs
  if define? and define.amd
    define [], -> DatePicker
  else if window?
    window.DatePicker = DatePicker

#开始运行
if require?
  require ["PluginPub"], init
else
  init window.PluginPub
