init = (PluginPub) ->
  class SubsysForm extends PluginPub
    constructor: (@label)->
      @_pluginType = "form"

#定义插件自己的html
    setEditviewHtml: (id, name, label) ->
      viewHtml = $ """
        <div id='#{id}' name='subsysForm'  class='plugin-border'>
        <div class='wbk-plugin-container subsysForm'>
           <table class="table table-striped">
            <tbody>
            <tr>
                <td>
                    <label>子系统英文简称:&nbsp;</label>
                    <input name="ename" type="text">
                </td>
                <td>
                    <label>子系统中文全称:&nbsp;</label>
                    <input name="cname" type="text">
                </td>
                <td>
                    <label>子系统英文全称:&nbsp;</label>
                    <input name="fullename" type="text">
                </td>
                <td>
                    <label>所属系统:&nbsp;</label>
                    <input name="systemBelong" type="text">
                </td>
                <td colspan="3">
                    <label>描述:&nbsp;</label>
                    <textarea name="desc" rows="1"></textarea>
                </td>
                <td>
                    <label>服务窗口:&nbsp;</label>
                    <select name="windowtime" class="form-select">
                        <option value="5*8">5*8</option>
                        <option value="5*13(早8-晚9)">5*13(早8-晚9)</option>
                        <option value="6*13(早8-晚9)">6*13(早8-晚9)</option>
                        <option value="7*11(早8-晚7)">7*11(早8-晚7)</option>
                        <option value="7*15(早8-晚11)">7*15(早8-晚11)</option>
                        <option value="7*24">7*24</option>
                        <option value="夜间跑批(凌晨0-6)白天报送">夜间跑批白天报送</option>
                    </select>
                </td>
            </tr>

            <tr>
                <td colspan="8">
                    <label>开发负责部门:&nbsp;</label>
                    <div class="form-inline checkbox-group-lg">
                        <label><input type="checkbox" name="kaifa_dept" value="大数据分析与运用中心"> &nbsp;大数据分析与运用中心</label>
                        <label><input type="checkbox" name="kaifa_dept" value="互联网产品研究部"> &nbsp;互联网产品研究部 </label>
                        <label><input type="checkbox" name="kaifa_dept" value="存款及后台管理产品部"> &nbsp; 存款及后台管理产品部</label>
                        <label><input type="checkbox" name="kaifa_dept" value="公司及同业客户产品部"> &nbsp;公司及同业客户产品部 </label>
                        <label><input type="checkbox" name="kaifa_dept" value="基础架构产品部-产品设计室"> &nbsp;基础架构产品部-产品设计室
                        </label>
                        <label><input type="checkbox" name="kaifa_dept" value="基础架构产品部-二线运营室"> &nbsp;基础架构产品部-二线运营室
                        </label>
                        <label><input type="checkbox" name="kaifa_dept" value="基础架构产品部-工具开发室"> &nbsp;基础架构产品部-工具开发室
                        </label>
                        <label><input type="checkbox" name="kaifa_dept" value="基础架构产品部-平台开发室"> &nbsp;基础架构产品部-平台开发室
                        </label>
                        <label><input type="checkbox" name="kaifa_dept" value="基础架构产品部-企业应用开发室"> &nbsp;基础架构产品部-企业应用开发室
                        </label>
                        <label><input type="checkbox" name="kaifa_dept" value="基础架构产品部-一线运营室"> &nbsp;基础架构产品部-一线运营室
                        </label>
                        <label><input type="checkbox" name="kaifa_dept" value="零售客户产品部"> &nbsp;零售客户产品部 </label>
                        <label><input type="checkbox" name="kaifa_dept" value="信用卡及信用贷款产品部"> &nbsp;信用卡及信用贷款产品部 </label>
                        <label><input type="checkbox" name="kaifa_dept" value="综合管理部-信息安全室"> &nbsp;综合管理部-信息安全室 </label>
                    </div>
                </td>
            </tr>

            <tr>
                <td>
                    <label>开发负责人RTX:&nbsp;</label>
                    <input name="kaifa_fzr" type="text">
                </td>
                <td>
                    <label>运维负责人RTX:&nbsp;</label>
                    <input name="yunwei_fzr" type="text">
                </td>
                <td>
                    <label>测试负责人RTX:&nbsp;</label>
                    <input name="ceshi_fzr" type="text">
                </td>
                <td>
                    <label>事件响应负责人RTX:&nbsp;</label>
                    <input name="shijian_fzr" type="text">
                </td>

                <td>
                    <label>子系统负责人RTX:&nbsp;</label>
                    <input name="zixitong_fzr" type="text">
                </td>
                <td>
                    <label>业务负责部门:&nbsp;</label>
                    <input name="yewu_dept" type="text">
                </td>
                <td>
                    <label>业务负责人RTX:&nbsp;</label>
                    <input name="yewu_fzr" type="text">
                </td>
                <td>
                    <label>子系统状态:&nbsp;</label>
                    <select name="subsysStatus" class="form-select">
                        <option value="未上线">未上线</option>
                        <option value="已上线">已上线</option>
                        <option value="已下线">已下线</option>
                        <option value="不上线">不上线</option>
                    </select>
                </td>
            </tr>

            <tr>
                <td>
                    <label>建设方式:&nbsp;</label>
                    <div class="form-group">
                        <label><input type="radio" name="designWay" value="自主研发"> &nbsp;自主研发 </label>
                        <label><input type="radio" name="designWay" value="项目外包"> &nbsp;项目外包 </label>
                        <br>
                        <label><input type="radio" name="designWay" value="外购改造"> &nbsp;外购改造 </label>
                        <label><input type="radio" name="designWay" value="部分外包"> &nbsp;部分外包 </label>
                    </div>
                </td>
                <td>
                    <label>开发语言:&nbsp;</label>
                    <input name="dev_language" type="text">
                </td>
                <td>
                    <label>部署法人:&nbsp;</label><br>
                    <label><input type="checkbox" name="distictName" value="Webank"> &nbsp;Webank</label>
                </td>
                <td>
                    <label>部署区域:&nbsp;</label>
                    <div class="form-inline">
                        <label><input type="checkbox" name="devDept" value="R-DCN"> &nbsp;R-DCN </label>
                        <label><input type="checkbox" name="devDept" value="C-DCN"> &nbsp;C-DCN </label>
                        <br>
                        <label><input type="checkbox" name="devDept" value="ADM"> &nbsp;ADM </label>
                        <label><input type="checkbox" name="devDept" value="I-ECN"> &nbsp;I-ECN </label>
                        <br>
                        <label><input type="checkbox" name="devDept" value="DMZ"> &nbsp;DMZ </label>
                        <label><input type="checkbox" name="devDept" value="CS"> &nbsp;CS </label>
                        <br>
                        <label><input type="checkbox" name="devDept" value="PADM"> &nbsp;PADM </label>
                        <label><input type="checkbox" name="devDept" value="MGMT"> &nbsp;MGMT </label>
                        <label><input type="checkbox" name="devDept" value="其他"> &nbsp;其他 </label>
                    </div>
                </td>
                <td>
                    <label>是否有用tdSql:&nbsp;</label>
                    <br>
                    <select name="if_tdSql" class="form-select">
                        <option value="是">是</option>
                        <option value="否">否</option>
                    </select>
                </td>
                <td>
                    <label>tdSql数据库名称:&nbsp;</label>
                    <input name="dbName" type="text">
                </td>
                <td colspan="2">
                    <label>数据库使用说明:&nbsp;</label>
                    <textarea name="dbUsedInfo"></textarea>
                </td>
            </tr>

            <tr>
                <td>
                    <label>上线时间:&nbsp;</label>
                    <input name="online_time" type="text" readonly value="" class="form_dataPicker"
                           data-date-format="yyyy-mm-dd"
                           placeholder='点击选择日期'>
                </td>
                <td>
                    <label>下线时间:&nbsp;</label>
                    <input name="offline_time" type="text" readonly value="" class="form_dataPicker"
                           data-date-format="yyyy-mm-dd"
                           placeholder='点击选择日期'>
                </td>
                <td>
                    <label>PTO:&nbsp;</label>
                    <input name="pto" type="text">
                </td>
                <td>
                    <label>RPO:&nbsp;</label>
                    <input name="rpo" type="text">
                </td>
                <td>
                    <label>厂商名称:&nbsp;</label>
                    <input name="supplier" type="text">
                </td>
                <td>
                    <label>负责人:&nbsp;</label>
                    <input name="charge_person" type="text">
                </td>
                <td>
                    <label>联系人:&nbsp;</label>
                    <input name="contact_person" type="text">
                </td>
                <td>
                    <label>联系方式:&nbsp;</label>
                    <input name="contact_type" type="text">
                </td>
            </tr>

            <tr>
                <td colspan="5">
                    <table class="scoreTable">
                        <tbody>
                        <tr>
                            <td>
                                <label>服务对象:&nbsp;</label>
                                <div class="form-group">
                                    <label><input type="radio" name="serv_obj" value="外部客户直接操作" score="30"> &nbsp;外部客户直接操作
                                    </label>
                                    <br>
                                    <label><input type="radio" name="serv_obj" value="服务外部客户" score="20"> &nbsp;服务外部客户
                                    </label>
                                    <br>
                                    <label><input type="radio" name="serv_obj" value="服务行内客户" score="5"> &nbsp;服务行内客户
                                    </label>
                                    <br>
                                    <label><input type="radio" name="serv_obj" value="其他" score="15"> &nbsp;其他
                                    </label>
                                </div>
                            </td>
                            <td>
                                <label>涉及账务:&nbsp;</label>
                                <div class="form-group">
                                    <label><input type="radio" name="finance" value="是" score="30"> &nbsp;是 </label>
                                    <br>
                                    <label><input type="radio" name="finance" value="否" score="5"> &nbsp;否 </label>
                                </div>
                            </td>
                            <td>
                                <label>关联度:&nbsp;</label>
                                <div class="form-group">
                                    <label><input type="radio" name="correlation" value="关联系统>=5" score="20"> &nbsp;关联系统>=5
                                    </label>
                                    <br>
                                    <label><input type="radio" name="correlation" value="5>关联系统>=1" score="10">
                                        &nbsp;5>关联系统>=1 </label>
                                    <br>
                                    <label><input type="radio" name="correlation" value="无关联" score="5"> &nbsp;无关联
                                    </label>
                                </div>
                            </td>
                            <td>
                                <label>服务时间:&nbsp;</label>
                                <div class="form-group">
                                    <label><input type="radio" name="serviceTime" value="全天候" score="20"> &nbsp;全天候
                                    </label>
                                    <br>
                                    <label><input type="radio" name="serviceTime" value="特殊时段" score="10"> &nbsp;特殊时段
                                    </label>
                                    <br>
                                    <label><input type="radio" name="serviceTime" value="工作日时间" score="5"> &nbsp;工作日时间
                                    </label>
                                </div>
                            </td>
                            <td>
                                <label>时效性:&nbsp;</label>
                                <div class="form-group">
                                    <label><input type="radio" name="effectiveness" value="高(实时,秒级)" score="0">
                                        &nbsp;高(实时,秒级) </label>
                                    <br>
                                    <label><input type="radio" name="effectiveness" value="中(分钟级)" score="0"> &nbsp;中(分钟级)
                                    </label>
                                    <br>
                                    <label><input type="radio" name="effectiveness" value="较小(小时级及以上)" score="0">
                                        &nbsp;较小(小时级及以上) </label>
                                </div>
                            </td>
                            <td>
                                <label>评分级别:&nbsp;</label>
                                <p name="riskLevel">C</p>
                                <br>
                                <label>评分:&nbsp;</label>
                                <p name="riskScore">20</p>
                            </td>
                        </tr>
                        </tbody>
                    </table>
                </td>
                <td>
                    <label>子系统等级:&nbsp;</label>
                    <br>
                    <select name="subsysLevel" class="form-select">
                        <option value="不调整">不调整</option>
                        <option value="A">A</option>
                        <option value="B">B</option>
                        <option value="C">C</option>
                    </select>
                </td>
                <td colspan="2">
                    <label>评分级别调整备注:&nbsp;</label>
                    <textarea name="score_change_detail"></textarea>
                </td>
            </tr>
            </tbody>
        </table>

        <div>
            <nav>
                <ul class="pagination">
                    <li class="prev-item">
                        <a href="javascript:void(0)" aria-label="Previous">
                            <span aria-hidden="true">&laquo;</span>
                        </a>
                    </li>
                    <li class="next-item">
                        <a href="javascript:void(0)" aria-label="Next">
                            <span aria-hidden="true">&raquo;</span>
                        </a>
                    </li>
                </ul>
            </nav>
        </div>

        <div class="pull-right">
            <button class="btn btn-default wbkAddSubsysForm"><i class="icon icon-plus"></i> 增加表单</button>
            <button class="btn btn-default delCurrentForm"><i class="icon icon-minus"></i> 删除当前表单</button>
        </div>
        <div class="clearfix"></div>

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

    getDragview: -> $ "<h1>[申请子系统表单]</h1>"

# 重写setName 方法
    setName: (name)=>
      @_name = name
      #这里要写自己的set方法
      @setPluginName(name, "textarea") # 修改chkeckbox控件的name
      @setPluginVal(name, ".nameProperType") # 修改对应input框的值


# 得到当前的valueType
    getValueType: (callback)->
      result =
        ename:
          valueType: 'string'
        cname:
          valueType: 'string'
        fullename:
          valueType: 'string'
        systemBelong:
          valueType: 'string'
        desc:
          valueType: 'string'
        windowtime:
          valueType: 'string'
        kaifa_dept:
          valueType: 'string'
        kaifa_fzr:
          valueType: 'string'
        yunwei_fzr:
          valueType: 'string'
        ceshi_fzr:
          valueType: 'string'
        shijian_fzr:
          valueType: 'string'
        zixitong_fzr:
          valueType: 'string'
        yewu_dept:
          valueType: 'string'
        yewu_fzr:
          valueType: 'string'
        subsysStatus:
          valueType: 'string'
        designWay:
          valueType: 'string'
        dev_language:
          valueType: 'string'
        distictName:
          valueType: 'string'
        devDept:
          valueType: 'string'
        if_tdSql:
          valueType: 'string'
        dbName:
          valueType: 'string'
        dbUsedInfo:
          valueType: 'string'
        online_time:
          valueType: 'string'
        offline_time:
          valueType: 'string'
        pto:
          valueType: 'string'
        rpo:
          valueType: 'string'
        supplier:
          valueType: 'string'
        charge_person:
          valueType: 'string'
        contact_person:
          valueType: 'string'
        contact_type:
          valueType: 'string'
        serv_obj:
          valueType: 'string'
        finance:
          valueType: 'string'
        correlation:
          valueType: 'string'
        serviceTime:
          valueType: 'string'
        effectiveness:
          valueType: 'string'
        riskLevel:
          valueType: 'string'
        riskScore:
          valueType: 'string'
        subsysLevel:
          valueType: 'string'
        score_change_detail:
          valueType: 'string'

      callback 0, result


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
        #@getValueType()
        tmpJson = 3
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

#页面初始化
    initdom: (o)->
      tmpJson = @getPluginJson()
      if tmpJson.label?
        @createFormByJson(@getPluginJson())

      #绑定事件
      @bindPluginEvent(o)

    getJs: ->
      js = super()
      js.push "SubsysForm"
      js

#    getExjs: ->
#      t['moment-with-locales'] = '1'
#      t['bootstrap-datetimepicker.min'] = '!jQuery.fn.datetimepicker'
#      t

    getExcss: ->
      'bootstrap.min': 1
      'pluginStyle': 1

  # set if requirejs
  if define? and define.amd
    define [], -> SubsysForm
  else if window?
    window.SubsysForm = SubsysForm

#开始运行
if require?
  require ["PluginPub"], init
else
  init window.PluginPub
