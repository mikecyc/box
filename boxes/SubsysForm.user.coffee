# 表单统一用 jquery.validate.js 进行处理，请在要验证的input节点上加上相关的信息，如
#  data-msg-number="The field RangeAndNumberDemo must be a number."
#  data-msg-range="The field RangeAndNumberDemo must be between -20 and 40."
#  data-rule-number="true"
#  data-rule-range="[-20,40]"
# 下面的js可以附加解决一些问题，如添加 jquery.validate 验证插件等

# 这是当初始化用户数据的时候调用，dom是jquery对象，value是要设置的值

###
  定义子系统表单模块
###
class SubsysFormModel
  constructor: (@dom, @_subsysModels)->
    if !@dom
      @dom = $('.subsysForm')

    if !@_subsysModels?
      @_subsysModels = []

  dom: null
  _currentFormNum: 0
  _subsysModels: []
  _subsysObj:
    ename: ''
    cname: ''
    fullename: ''
    systemBelong: ''
    desc: ''
    windowtime: ''
    kaifa_dept: []
    kaifa_fzr: ''
    yunwei_fzr: ''
    ceshi_fzr: ''
    shijian_fzr: ''
    zixitong_fzr: ''
    yewu_dept: ''
    yewu_fzr: ''
    subsysStatus: ''
    designWay: [],
    dev_language: ''
    distictName: []
    devDept: []
    if_tdSql: ''
    dbName: ''
    dbUsedInfo: ''
    online_time: ''
    offline_time: ''
    pto: ''
    rpo: ''
    supplier: ''
    charge_person: ''
    contact_person: ''
    contact_type: ''
    serv_obj: []
    finance: []
    correlation: []
    serviceTime: []
    effectiveness: []
    riskLevel: ''
    riskScore: ''
    subsysLevel: ''
    score_change_detail: ''

  getSubsysModels: =>
    result = []

    for subModel,index in @_subsysModels
      rModel = {}
      for k,v of subModel
        fDom = @dom.find('[name="' + k+'"]');
        if 'string' is typeof(v)
          rModel[k] =
            value: v
            valueType: 'string'
            attrType: if fDom? then fDom.attr('attrtype') else ''
            ownerId: if fDom? then fDom.attr('ownerid') else ''
        else
          rModel[k] =
            value: v.toString()
            valueType: 'string'
            attrType: if fDom? then fDom.attr('attrtype') else ''
            ownerId: if fDom? then fDom.attr('ownerid') else ''
      result.push(rModel)
    return result

# 取得新的子系统表单数据模型
  getNewSubsysModel: (index) =>
    model = $.extend(true, {}, @_subsysObj)
    if index
      model.ename = "subSystemName_" + index
    else
      model.ename = "subSystemName__"
    return model


# 填充表单
  fillForm: (subsysModel) =>
    formDom = @dom
    # input
    formDom.find('input').each (i, e) =>
      name = $(e).attr('name')
      $(e).val(subsysModel[name])

    # textarea
    formDom.find('textarea').each (i, e) =>
      name = $(e).attr('name')
#      console.log(subsysModel[name])
      $(e).val(subsysModel[name])

    # select
    formDom.find('select').each (i, e) =>
      name = $(e).attr('name')
      $(e).val(subsysModel[name])

# 根据类型,名称,和值更新数据模型
  updateFormModel: (type, name, value) =>
    index = @_currentFormNum
    currentForm = @_subsysModels[index]
    switch type
      when 'text' then currentForm[name] = value
      when 'radio' then currentForm[name][0] = value
      when 'checkbox'
        valueList = @getCheckboxValuesByName(name)
        currentForm[name] = valueList
      else
#        console.log "type:#{type}"
#        console.log "name:#{name}"
        console.log "update Form error!"

# 根据名称取到复选框的值
  getCheckboxValuesByName: (name)=>
    formDom = @dom
    valueList = []
    formDom.find('input[name="' + name + '"]:checked').each (i, e) =>
      valueList.push($(e).val())
    return valueList

# 反相绑定插件和数据
  bindPluginData: (e)=>
    type = $(e.target).attr('type')
    value = $(e.target).val()
    name = $(e.target).attr('name')
    @updateFormModel(type, name, value)

    if name is 'ename'
      formdom = @dom
      pageitem = formdom.find('.page-item');
      pageitem.each (i, e) =>
        if $(e).hasClass('active')
          link = $(e).find('a')
          link.text(value)



# 算分插件
  bindScorePlugin: =>
    formDom = @dom
    serObj = formDom.find('input[name="serv_obj"]:checked')
    finance = formDom.find('input[name="finance"]:checked')
    correlation = formDom.find('input[name="correlation"]:checked')
    serviceTime = formDom.find('input[name="serviceTime"]:checked')
    effectiveness = formDom.find('input[name="effectiveness"]:checked')

    score_serObj = if serObj.attr('score')? then serObj.attr('score') else 0
    score_finance = if serObj.attr('score')? then finance.attr('score') else 0
    score_correlation = if serObj.attr('score')? then correlation.attr('score') else 0
    score_serviceTime = if serObj.attr('score')? then serviceTime.attr('score') else 0
    score_effectiveness = if serObj.attr('score')? then effectiveness.attr('score') else 0

    totalScore = parseInt(score_serObj) + parseInt(score_finance) + parseInt(score_correlation) + parseInt(score_serviceTime) + parseInt(score_effectiveness);
#    console.log totalScore

    level = 'C';

    if totalScore >= 80
      level = 'A'
    else if totalScore >= 60 and totalScore < 80
      level = 'B'

    formDom.find('p[name="riskScore"]').text(totalScore)
    formDom.find('p[name="riskLevel"]').text(level)

# 绑定增加子系统表单事件
  bindAddSubsysForm: =>
    @_currentFormNum = @_subsysModels.length - 1
    totalPage = @_subsysModels.length
    subsysModel = @getNewSubsysModel(totalPage)
#    console.log(subsysModel)
    @_subsysModels.push(subsysModel)
    @_currentFormNum = totalPage
    value = ""
    @addPage(totalPage, value)
    @fillForm(subsysModel)

# 绑定子系统标签的点击事件
  bindClickPageItem: (e) =>
    index = $(e.target).attr('index')
    @changeFormByIndex(index)

# 切换表单
  changeFormByIndex: (index) =>
    @_currentFormNum = index
    model = @_subsysModels[@_currentFormNum]
    @fillForm(model)
    @activeFormPageTag(index)

# 向前切换表单
  preChangeForm: =>
    if @_currentFormNum > 0
      @_currentFormNum -= 1
      @changeFormByIndex(@_currentFormNum)

# 向后切换表单
  nextChangeForm: =>
#    console.log "next"
    if @_currentFormNum < (@_subsysModels.length -1)
      @_currentFormNum += 1
      @changeFormByIndex(@_currentFormNum)

# 删除当前表单
  delCurrentFormByIndex: =>
#    console.log @_currentFormNum
    index = @_currentFormNum
    if (@_subsysModels.length - 1) > 0
      @_subsysModels.splice(index, 1)
      @_currentFormNum = 0
      @initFormGroup()
      @activeFormPageTag(0)
      model = @_subsysModels[0]
      @fillForm(model)
    else
      console.log "can't del the last one!"

# 绑定事件
  bindEvent: =>
    formdom = @dom

    formdom.find('input').change (e) =>
      @bindPluginData(e)

    formdom.find('.scoreTable').find('input').change =>
      @bindScorePlugin()

    formdom.find('.wbkAddSubsysForm').click =>
      @bindAddSubsysForm()

    formdom.find('.delCurrentForm').click =>
      @delCurrentFormByIndex()

    formdom.find('.prev-item').click =>
      @preChangeForm()

    formdom.find('.next-item').click =>
      @nextChangeForm()

# 激活标签
  activeFormPageTag: (index) =>
    formdom = @dom
    formdom.find('.page-item').each (i, e) =>
      if i is parseInt(index)
        if !$(e).hasClass('active')
          $(e).addClass('active')
      else
        if $(e).hasClass('active')
          $(e).removeClass('active')

# 增加一个page
  addPage: (index, value) =>
    formdom = @dom

    if index?
#      console.log index
#      console.log value
      if value? and "" != value
        pageValue = value
      else
        pageValue = 'subSystem' + index
        type = 'text'
        name = 'ename'
        @updateFormModel(type, name, pageValue)

      html = """
              <li class="page-item"><a href="javascript:void(0)" index="#{index}">#{pageValue}</a></li>
             """
      pageItem = formdom.find('.next-item')
      pageItem.before(html)
      @_currentFormNum = index
      formdom.find('.page-item').unbind('click')
      formdom.find('.page-item').click (e) =>
        @bindClickPageItem(e)
      @activeFormPageTag(index)
    else
      console.log "add Page Error"

# 初始化日期控件
  initDatePickerPlugin: =>
#    formdom = @dom

#    option =
#      minView: "month" #选择日期后，不会再跳转去选择时分秒
#      format: 'YYYY-MM-DD' #选择日期后，文本框显示的日期格式
#      locale: 'zh-cn' #汉化
#      disabledTimeIntervals: [true]
#      autoclose: true #选择日期后自动关闭
#    formdom.find('.form_dataPicker').datetimepicke(option)
    $('.form_dataPicker').datetimepicker({
      locale: 'zh-cn',
      format: 'YYYY-MM-DD',
      disabledTimeIntervals: [true]
    });

# 初始化表单切换分组
  initFormGroup: =>
    total = @_subsysModels.length
    formdom = @dom
    if total > 0
      formdom.find('.page-item').remove()
      for model,index in @_subsysModels
        value = model['ename']
        if value?
          @addPage(index, value)
        else
          @addPage(index)

# 总的初始化入口
  init: () =>
    if @_subsysModels.length > 0
      @fillForm(@_subsysModels[0])
    else
      tmpObj = @getNewSubsysModel(0)
      @_subsysModels.push(tmpObj)
      @fillForm(tmpObj)

    #    @initDatePickerPlugin()
    @initFormGroup()
    @bindEvent()
    @bindScorePlugin()

###
  运行区块
###


testmodel =
  ename: 'testEnName'
  cname: '测试子系统'
  fullename: 'test English fullname'
  systemBelong: 'EEE'
  desc: '这是一个测试子系统'
  windowtime: '5\*13\(早8\-晚9\)'
  kaifa_dept: ['大数据分析与运用中心', '互联网产品研究部']
  kaifa_fzr: 'kaifa'
  yunwei_fzr: 'yunwei'
  ceshi_fzr: 'ceshi'
  shijian_fzr: 'shijian'
  zixitong_fzr: 'zixitong_fzr'
  yewu_dept: '业务运维部门'
  yewu_fzr: 'yewu_fzr'
  subsysStatus: '已上线'
  designWay: ['部分外包']
  dev_language: 'Python'
  distictName: ['Webank']
  devDept: ['R-DCN', 'DMZ', 'MGMT']
  if_tdSql: "是"
  dbName: 'DB'
  dbUsedInfo: '数据库使用说明'
  online_time: '2015-10-10'
  offline_time: '2025-10-10'
  pto: 'pto'
  rpo: 'rop'
  supplier: '厂商'
  charge_person: '负责人'
  contact_person: '联系人'
  contact_type: '10000000'
  serv_obj: ['服务外部客户']
  finance: ['是']
  correlation: ['关联系统>=5']
  serviceTime: ['全天候']
  effectiveness: ['高(实时,秒级)']
  riskLevel: 'A'
  riskScore: '90'
  subsysLevel: 'B'
  score_change_detail: '调整为B'
modelList = []
modelList.push(testmodel)

#初始化一个对象备用
sub = new SubsysFormModel dom
#sub.init()


box.initdom = (dom) =>
  console.log "init form"
#  sub = new SubsysFormModel dom, modelList
  sub.init()

box.setValue = (dom, value, callback)->
  console.log "lala"
  sub = new SubsysFormModel dom, value
  sub.init()
  callback 0


#得到当前插件的值
box.getValue = (dom, callback)->
  callback 0, sub.getSubsysModels()