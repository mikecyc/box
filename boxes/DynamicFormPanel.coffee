init = (BoxBase) ->
  class DynamicFormPanel extends BoxBase
    constructor: (@label)->
      @setName "form"

    @_propertyDom = null

    getDragview: -> $ "<h1>[动态表单生成器]</h1>"

    getEditview: ->
      @_editview = $ """

        <div>
          <table class="table table-bordered table-striped">

            <tr><td>名称</td><td>插件</td><td>类型</td><td>操作</td></tr>
            <tr>
              <td>lalla</td>
              <td class='dynamic-plugin'>
                <div><input type="text" name="lala"/></div>
              </td>
              <td>input</td>
              <td><a href='javascript:void(0)'>删除</a></td>
            </tr>
            <tr><td colspan='4'>
                <button type='button' class='btn btn-default createform-by-api'><i class='glyphicon glyphicon-indent-left'></i>根据接口生成表单</button>
                <button type='button' class='btn btn-default'><i class='glyphicon glyphicon-plus'></i>增加控件</button>
                </td>
            </tr>
          </table>
        </div>

        <!-- Modal -->
        <div class="modal fade createform-modal" id="createformModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
          <div class="modal-dialog" role="document">
            <div class="modal-content">
              <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                <h4 class="modal-title" id="myModalLabel">根据接口创建表单</h4>
              </div>
              <div class="modal-body">
                <div class='form-inline'>
                  接口:  <input type='text' class='form-control-static input-api-url' placeholder='请输入接口URL'>
                  <button class='btn btn-default btn-test-api'>提交</button>
                  <span class='api-loading'><img src='img/load.gif' alt=''></span>
                  <span class='pull-right msg-show'>lala</span>
                  <span class='clearfix'></span>
                </div>

              </div>
              <table class="table table-bordered table-striped">

                <tr><td>名称</td><td>插件</td><td>类型</td></tr>
                <tr>
                  <td>nameProperty</td>
                  <td>
                    <div><input type="text" name="input"/></div>
                  </td>
                  <td>
                    <select name='' id='' class='form-control'>
                      <option value=''>普通input</option>
                      <option value=''>邮件input</option>
                      <option value=''>...</option>
                    </select>
                  </td>
                </tr>
                <tr>
                  <td>nameProperty2</td>
                  <td>
                    <div><input type="text" name="input"/></div>
                  </td>
                  <td>
                    <select name='' id='' class='form-control'>
                      <option value=''>普通input</option>
                      <option value=''>邮件input</option>
                      <option value=''>...</option>
                    </select>
                  </td>
                </tr>
              </table>

              <div class="modal-footer">
                <button type="button" class="btn btn-primary">创建</button>
              </div>
            </div>
          </div>
        </div>

      """

    _propertyTypeMap:
      canEditor : "能否编辑"
      ifDisplay: "是否显示"
      p1:"属性1"
      p2:"属性2"
      p3:"属性3"
      p4:"属性4"


    createPropertyDom: (name,dom,propList) =>
      propHtml = """
        <table class='table table-bordered table-striped table-responsive'>
            <thead>
              <tr><td colspan="2" style="background: #337AB7;color: white">[#{name}]的属性</td></tr>
              <tr><td>名称</td><td>属性</td></tr>
            </thead>
            <tbody>

            </tbody>
        </table>0
      """
      dom.append(propHtml)
      propDom = dom.find('tbody')

      propList.forEach (o,i) =>
        trHtml = """<tr><td nowrap='nowarp'>#{@_propertyTypeMap[o]}</td><td> <input type="text" name="#{o}" /></td></tr> """
        propDom.append(trHtml)


    bindTestApiBtn: (o)->
      loadDom = o.find('.api-loading')
      btnDom = o.find('.btn-test-api')
      btnDom.unbind('click')
      btnDom.click (e) =>
        loadDom.show()
        apiUrl = o.find('.input-api-url').val()
        if ''!= $.trim(apiUrl)
          $.ajax 'http://10.6.222.62:8080/itsm/request/getFormSerializationByFormIdAndVersion.spr',
#          $.getJSON 'http://localhost:8080/itsm/static/json/getMenuList.json',
            type:'GET'
            dataType: 'json',
            error: (jqXHR, textStatus, errorThrown) ->
              loadDom.hide()
              console.log jqXHR
              console.log textStatus
              $('.input-api-url').notify('接口请求失败!','error')
            success: (result) ->
              loadDom.hide()
              if result?
                $('.msg-show').notify('接口请求成功!','success',{position:'right',,'success'})
                console.log result
              else
                $('.msg-show').notify('接口请求失败!','error')
                console.log "error"

          console.log "test API:"+apiUrl


    bindCreateFormBtn: (o)->
      apiDom = o.find('.createform-by-api')
      apiDom.unbind('click')
      apiDom.click (e) =>
        o.find('.createform-modal').modal('show')


    bindDynamicPluginClick:(o)=>
      dynamicPluginDom = o.find('.dynamic-plugin')
      dynamicPluginDom.unbind('click')
      dynamicPluginDom.click (e) =>
        @_propertyDom.empty()
        name =  $(e.target).attr('name')
        name = "lala"
        testList = ["canEditor","ifDisplay","p1","p2"]
        @createPropertyDom(name,@_propertyDom,testList)

    bindEvent:(o)->
      @bindCreateFormBtn(o)
      @bindDynamicPluginClick(o)
      @bindTestApiBtn(o)

    getToolview: ->
      @_toolview = $ """<span></span>"""

    initdom: (o)=>
      @bindEvent(o)

    toJson: (callback)->
      callback 0, @name or 'unknow'

    fromJson: (json, callback)->
      @name = json
      callback 0

    toHtml: (callback)->
      callback 0, """
        <div>
          <tabel>
            <tr><td>名称</td><td>插件</td><td>类型</td></tr>
            <tr><td></td><td></td><td></td></tr>
          </tabel>
        </div>
      """
# extern css and js
    getCss: ->
      css = super()
      css.push "Input"
      css

    getJs: ->
      js = super()
      js.push "Input"
      js

# 更新property视图
# o 为当前的视图容器，jQuery格式
    updatePropertyView: (o, t) =>
      o.append "not property11."
      @_propertyDom = o

  #getExjs: ->
  #$.extend {}, super(),
  #'jquery.validate': '!jQuery.fn.validate'
  ##        'jquery.validate.unobtrusive': "!jQuery.validator.unobtrusive"

  # set if requirejs
  if define? and define.amd
    define [], -> DynamicFormPanel
  else if window?
    window.DynamicFormPanel = DynamicFormPanel

#开始运行
if require?
  require ["BoxBase"], init
else
  init window.BoxBase
