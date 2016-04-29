# 多选框组
init = (BoxBase) ->
  class CheckBox extends Radio
    constructor: (@label)->

    _pluginType : ":checkbox"

# 获取增加的html代码
    getBaseHtml: (name, value, canDel) =>
      if canDel?
        return """
          <div class='ckb-container'>
            <input type="checkbox" name="#{name}" value='#{value}'/>
            <label class='plugin-text'><input type="text" class='labelText' placeholder='请输入选项的名称' value='#{value}'/></label>
            <span class='delCkb glyphicon glyphicon-minus'></span>
          </div>
        """
      else
        return """
          <div class='ckb-container'>
            <input type="checkbox" name="#{name}" value='#{value}'/>
            <label class='plugin-text'><input type="text" class='labelText' placeholder='请输入选项的名称' value='#{value}'/></label>
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
            <div class='ckb-container'>
              <input type="checkbox" name='#{name}'/>
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

    getDragview: -> $ "<h1>[复选框组]</h1>"

# 初始化
    initdom: (o)->

#      testJson =
#        name: "testCheck"
#        label: "测试"
#        optionList: ["aa","bb"]
#      @setPluginJson(testJson)
#
#      tmpJson = @getPluginJson()
#      if tmpJson.label? and tmpJson.optionList?
#        @createFormByJson(@getPluginJson())

      tmpJson = @getPluginJson()
      if tmpJson.label?
        @createFormByJson(@getPluginJson())

      #绑定事件
      @bindPluginEvent(o)

  # set if requirejs21
  if define? and define.amd
    define [], -> CheckBox
  else if window?
    window.CheckBox = CheckBox

# 开始运行
if require?
  require ["BoxBase"], init
else
  init window.BoxBase
