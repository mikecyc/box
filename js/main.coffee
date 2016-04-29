#缓存当前的拖动对象
dragcls = null
updatedom = 0
#当前可编辑区
env = window.env =
  rootcolumn: null
  domobject: {}
  formData: null
  randindex: 0
  formId: ''
  formName: ''
  formVersion: ''
  teamId: ''
  focusBox: null

#取消所有的错误提示
$.fn.resetForm = ->
  t = this
  $.each t.find('.error'), (index, element)->
    $(element).data("title", '').removeClass('error').tooltip('destroy')
    return
  t

#获取URL参数
getUrlParam = (name) ->
  reg = new RegExp "(^|&)#{name}=([^&]*)(&|$)", "i"
  r = window.location.search.substr(1).match reg
  if r then decodeURI r[2] else ''

#根据配置文件生成左侧的导航菜单
initmenu = ->
  boxes = config.boxes
  items = []
  for box in boxes
    items.push """
      <ul class="nav nav-list accordion-group">
        <li class="nav-header">
          <i class="glyphicon-plus glyphicon"></i> #{box[0]}
          <div class="pull-right popover-info"><i class="glyphicon glyphicon-question-sign"></i>
            <div class="popover fade right">
              <div class="arrow"></div>
              <h3 class="popover-title">提示：</h3>
              <div class="popover-content">#{box[1]}</div>
            </div>
          </div>
        </li>
        <li class="boxes" id="estRows">
    """
    for ib in box[2..]
      items.push """
        <div class="box" cls="#{ib[0]}" label="#{ib[1]}" param="#{ib[2]||''}">
          <span class="drag label label-default"><i class="glyphicon glyphicon-move"></i> 拖动</span>
          <div class="preview"><span>#{ib[1]}</span></div>
        </div>
      """
    # end items
    items.push """
        </li>
      </ul>
    """
  items.join "\n"


#处理拖动事件
dragit = (o)->
  o.draggable
    connectToSortable: ".column"
    helper: "clone"
    handle: ".drag"
    start: (e, t)->
      updatedom = 1
      cls = t.helper.attr 'cls'
      if window[cls]
        dragcls = new window[cls] t.helper.attr('label'), t.helper.attr('param')
        dragcls.className = cls
      else
        dragcls = new window.BoxBase
        console.log "#{cls} don't exist, use BoxBase instead."
      t.helper.empty().append(dragcls.drapview).css
        width: 400
        opacity: .5

#可排序接口
sortit = (o)->
  o.sortable
    connectWith: ".column"
    opacity: .75
    handle: ".drag"
    start: (e, t)->
      t.helper.css
        opacity: .8
    update: (e, t)->
      if updatedom
        updatedom = 0
        ot = $ t.item[0]
        ot.attr "objinx", env.randindex
        ot.html """
          <span class="drag label label-default"><i class="glyphicon glyphicon-move"></i> 拖动</span>
          <span class="remove label label-danger"><i class="glyphicon glyphicon-remove"></i> 删除</span>
          <span class="boxname label label-default">#{dragcls.name}</span>
          <div class="configuration"></div>
          <div class="view"></div>
        """
        view = ot.find('div.view')
        view.append dragcls.editview
        ot.find('div.configuration').append dragcls.toolview
        dragcls.initdom ot
        #保存dom object
        env.domobject[env.randindex++] = dragcls
        column = view.find "div.column"
        if column[0]
          #为每个column增加inx
          column.each (i, t)->
            $(t).attr 'inx', i
          sortit column
        dofocus ot, env

window.sortit = sortit

getHtmlCss = (rid, icss, iexcss, ispreview)->
  excss = for css, attr of iexcss when attr
    css
  view = """
    (function(w){
      if(!w.boxCssCache){
        w.boxCssCache = {};
      }
      var i, x, css = #{JSON.stringify(excss)};
      for(i=0; i<css.length; i++){
        if(!w.boxCssCache[css[i]]){
          $('head').append('<link href="#{if ispreview then config.excsspath else config.outcsspath}'+ css[i] +'.css" rel="stylesheet">');
          w.boxCssCache[css[i]] = 1;
        }
      }
      if(!w.boxCssCache['#{rid}']){
        $('head').append('<style>#{icss.replace(/'/g, "\\'")}</style>');
        w.boxCssCache['#{rid}'] = 2;
      }
    }).call(this,window);
  """
  view.replace(/\s*\/\/[^\n\r]*[\r\n]?/mg, "\n").replace(/\s*[\r\n]+\s*/mg, '').replace(/^\s+|\s+$/g, '')

getHtmlJs = (rid, ijs, iexjs, ispreview)->
  view = """
(function(window, $, jQuery){
var console = window.console || {log: function(){}},
dom, box, boxfuns = {}, seriesGetData, doSetData, queue;
//全局接口的入口，查找当前的dom得到id号进行调用，这样可以避免全局污染
window["box#{rid}"] = function(dt, callback){
  if(!dom || !doSetData){
    //简单起见，这里只保存最新的一个调用值
    queue = [dt, callback];
    return;
  }
  if($.isFunction(dt)){
    callback = dt;
    //在这里先调用validate的方法进行表单验证
    if(dom.valid && !dom.valid()){
      return callback("valid failed.");
    }
    seriesGetData(dom, function(err, dt){
      callback(err, dt);
    });
  }else{
    //设置新的表单数据
    doSetData(dt, dom, callback);
  }
};
async.forEachOfSeries(#{JSON.stringify(iexjs)}, function(item, key, callback){
  try{
    if(eval(item)){
      $.ajax("#{if ispreview then config.exjspath else config.outjspath}"+key+".js",{
        contentType: 'text/plain',
        dataType:'text',
        mimeType: 'text/plain',
        cache:true,
        success:function(dt){
          var tdef = window.define;
          //暂时取消define
          window.define = null;
          var spt = document.createElement('script');
          spt.innerHTML = dt;
          $('head').append(spt);
          window.define = tdef;
          callback(0);
        },
        error: function(xhr, ts, ex){
          callback(ex);
        }
      });
    }else{
      callback(0);
    }
  }catch(ex){
    callback(ex);
  }
}, function(err){
  dom = $("#box#{rid}"),
  //所有的插件需要调用的方法都放在这里，请用push的方法实现
  //考虑到有一些需求可能需要用到异步请求，所以所有的调用都异步调用
  box = {};
  if(dom.validate){
    dom.validate({
      debug:true,
      showErrors: function(errorMap, errorList) {
        $.each(this.validElements(), function (index, element) {
            var $element = $(element);
            $element.data("title", "") // Clear the title - there is no error associated anymore
                .removeClass("error")
                .tooltip("destroy");
        });
        $.each(errorList, function (index, error) {
            var $element = $(error.element);
            $element.tooltip("destroy") // Destroy any pre-existing tooltip so we can repopulate with new tooltip content
                .data("title", error.message)
                .addClass("error")
                .tooltip(); // Create a new tooltip based on the error messsage we just set in the title
        });
      }
    });
  }else{
    console.log("plugin validate not found. ignore it.");
  }
  #{ijs}
  //进行dom初始化
  boxfuns.initdom = function(domx){
    var allbox = domx.find("[boxclass]");
    allbox.each(function(){
      var t = $(this);
      var cls = t.attr('boxclass');
      if(box[cls] && box[cls].initdom){
        box[cls].initdom(t, dom, box, boxfuns); //把box传过去是为了有继承关系的类，因为派生而需要调基类的方法
      }
    });
  };
  boxfuns.initdom(dom);
  //遍历整个dom，并得到验证之后的数据，如果有错误的话就提示错误
  boxfuns.getValue = seriesGetData = function(dom, callback){
    var nix = {}, nos = {}, out = {}, rootdom = dom;
    var allbox = dom.find("[boxname]:visible");
    async.eachSeries(allbox, function(t, callback){
      t = $(t);
      var cls = t.attr('boxclass');
      var name = t.attr('boxname');
      var extend = $.parseJSON(Base64.decode(t.attr('boxextend')));
      //把得到的数据值填充到输出的对象中
      var setval = function(v){
        var parentNode = t.parent().closest("[boxname]");
        if(parentNode[0] == rootdom[0]){
          parentNode = []; //针对只得到部分的dom片段
        }
        if($.isArray(v)){
          if(v.length > 0){
            //如果有值说明插件内部已经自己处理了，这里框架就不用关心了
            //这里只处理没有值的情况
            extend.value = v;
            out[name] = extend;
            return;
          }
          //因dom的结构和接口定义的结构不一样，遍历起来真的好麻烦
          if(!nix[name]){
            t.parent().children('[boxname='+ name +']').each(function(){
              var t = $(this);
              if(nix[name]){
                nix[name]++;
              }else{
                nix[name] = 1;
              }
              t.attr("boxinx", nix[name]); //作一个索引的标记
              if(!nos[name]){
                extend.value = [{}];
                nos[name] = extend;
              }else{
                nos[name].value[nix[name]-1] = {}; //先造好容器
              }
            });
            if(parentNode[0]){
              var inx = parseInt(parentNode.attr('boxinx'))-1;
              nos[parentNode.attr('boxname')].value[inx][name] = nos[name];
            }else{
              out[name] = nos[name];
            }
          }
          return;
        }

        extend.value = v;
        //查找应该放到哪个位置
        if(parentNode[0]){
          var inx = parseInt(parentNode.attr('boxinx'))-1;
          nos[parentNode.attr('boxname')].value[inx][name] = extend;
        }else{
          out[name] = extend;
        }
      };
      if(box[cls] && box[cls].getValue){
        box[cls].getValue(t, function(err, v){
          if(err){
            return callback(err);
          }
          setval(v);
          callback(0);
        });
      }else{
        if(t.find('div.column')[0]){
          setval([]);
        }else{
          console.log("Can't find box: "+ cls);
          setval('');
        }
        callback(0);
      }
    }, function(err){
      callback(err, out);
    });
  };
  var valueToHtml = function(o, v, callback){
    var boxclass = o.attr("boxclass");
    if(box[boxclass] && box[boxclass].setValue){
      box[boxclass].setValue(o, v, callback);
    }else{
      console.log("INFO: box "+ boxclass + " or box.setValue no found, ignore it.");
      callback(0);
    }
  };
  //这里采用多重循环dom，效率方面可能有点低，因一般情况下dom的查询并不多，暂时还看不到性能的瓶颈
  boxfuns.setValue = doSetData = function(dt, dom, callback){
    // Clear errer status
    dom.find(".error").data("title", "").removeClass("error").tooltip("destroy");
    async.eachOfSeries(dt, function(item, key, callback){
      var o = dom.find("[boxname="+ key +"]");
      if(o[0]){
        var value = item.value;
        if($.isArray(value)){
          // 如果是数组的话说明是有多组的，再进行遍历
          valueToHtml($(o[0]), value, function(err){
            //重新获取新的列表，因为可能已经更新
            var os = o.parent().children("[boxname="+ key +"]");
            async.eachOfSeries(value, function(item, key, callback){
              if(os[key]){
                doSetData(item, $(os[key]), callback);
              }else{
                //如果不存在将忽略
                console.log("ignore "+ key);
                callback(0);
              }
            }, callback);
          });
        }else{
          valueToHtml(o, value, callback);
        }
      }else{
        console.log("Ignore box: " + key);
        callback(0);
      }
    }, callback);
  };
  //查找执行事件
  if(queue) {
    window["box#{rid}"](queue[0], queue[1]);
    queue = null;
  }
});
}).call(this, window, window.jQuery, window.jQuery);
  """
  view.replace(/\s*\/\/[^\n\r]*[\r\n]?/mg, "\n").replace(/\s*[\r\n]+\s*/mg, '').replace(/^\s+|\s+$/g, '')

#设置标题
setTitle = (env)->
  document.title = (if env.formName then "#{env.formName} - " else "[未命名] - ") + "Box"

# 生成最终的html，这是不可逆的过程
makeHtml = (env, ispreview, callback)->
  rid = Math.round(Math.random()*10000)
  async.waterfall [
    (callback) ->
      async.series
        css: (callback)->toCss env, callback
        js: (callback)->toJs env, callback
        excss: (callback)->toExcss env, callback
        exjs: (callback)->toExjs env, callback
      , callback
    (cj, callback)->
      toHtml env, (err, html)->
        if ispreview
          out = """
            <html><head>
              <meta charset="utf-8">
              <style>html,body{padding:0;margin:0;}div.layout{padding:40px 10px 20px 10px}</style>
              <script src="#{config.exjspath}jquery.min.js"></script>
              <script src="#{config.exjspath}async.js"></script>
            </head><body>
              <script>#{getHtmlCss(rid, cj.css, cj.excss, ispreview)}</script>
              <div class="layout"><form class="boxview" id="box#{rid}">#{html}</form></div>
              <script>#{getHtmlJs(rid, cj.js, cj.exjs, ispreview)}</script>
            </body></html>
            """
          out = out.replace(/\s*[\r\n]+\s*/mg, '').replace(/^\s+|\s+$/g, '')
        else
          out = JSON.stringify [getHtmlCss(rid, cj.css, cj.excss, ispreview), """<form class="boxview" id="box#{rid}">#{html}</form>""", getHtmlJs(rid, cj.js, cj.exjs, ispreview)]
        callback err, out, rid
  ], callback

loadForm = (env, callback)->
  $.post "#{config.rooturl}/itsm/request/getFormSerializationByFormIdAndVersion.spr"
  ,
    formId: env.formId
    formVersion: env.formVersion
  , (result) ->
    if result?.retCode
      $.notify(result.retDetail, "error")
      callback result.redCode, result
      return
    jsonToDom JSON.parse(result.data.formSerialization), env, (err)->
      if err
        $.notify(err, 'error')
        return callback err
      callback err, result.data
  , 'json'

#按钮相应事件列表
act =
  list: (e, env) ->
    domModal = $("#formList")
    $.post "#{config.rooturl}/itsm/request/getFormListEditByUser.spr"
    , null, (result)->
      return $.notify(result.retDetail, "error") if result.retCode
      out = ["""<div class="tree"><ul>"""]
      for teamField in result.data
        out.push """<li teamFieldId="#{teamField.teamFieldId}"><span><i class="glyphicon glyphicon-tasks"></i> #{teamField.teamFieldName}</span>"""
        if teamField.teamList?[0]
          out.push "<ul>"
          for teamList in teamField.teamList
            out.push """<li teamId="#{teamList.teamId}"><span><i class="glyphicon glyphicon-minus"></i> #{teamList.teamName}</span>"""
            if teamList.formList?[0]
              out.push "<ul>"
              for form in teamList.formList
                out.push """<li formId="#{form.formId}"><span><i class="glyphicon glyphicon-minus"></i> #{form.formName}</span>"""
                if form.formVersionList?[0]
                  out.push "<ul><li>"
                  for version in form.formVersionList
                    out.push """<span class="vn" version="#{version}"><i class="glyphicon glyphicon-tag"></i> #{version}</span>"""
                  out.push "</li></ul>"
                out.push "</li>"
              out.push "</ul>"
            out.push "</li>"
          out.push "</ul>"
        out.push "</li>"
      out.push "</ul></div>"
      domModal.modal 'show'
      domModal.find("div.modal-body").css("height", domModal.height() - 200).html out.join("")
      domModal.find('.tree li:has(ul)').addClass('parent_li').find(' > span').attr 'title', 'Collapse this branch'
      domModal.find('.tree li.parent_li > span').click (e) ->
        e.stopPropagation()
        children = $(this).parent('li.parent_li').find(' > ul > li')
        if children.is(':visible')
          children.hide 'fast'
          $(this).attr('title', 'Expand this branch').find(' > i').addClass('glyphicon-plus').removeClass 'glyphicon-minus'
        else
          children.show 'fast'
          $(this).attr('title', 'Collapse this branch').find(' > i').addClass('glyphicon-minus').removeClass 'glyphicon-plus'
        return
      domModal.find(".tree .vn").click (e)->
        domModal.find(".tree .vn").removeClass("active")
        $(this).addClass("active")
      .dblclick (e)->
        domModal.find("[act=loadform]").trigger "click"
    , 'json'


  preview: (e, env)->
    makeHtml env, 1, (err, html, rid) ->
      md = $("#previewModal")
      md.modal('show')
      im = $ """<iframe frameborder="0" height="#{md.height()-200}" width="100%"></iframe>"""
      md.find("div.modal-body").empty().append(im)
      im[0].contentDocument.open()
      im[0].contentDocument.write html
      im[0].contentDocument.close()
      #因为得到html这个过程可能会自动修改插件的名字，故在这里刷新显示的名字列表
      for box in env.rootcolumn.find("div.box[objinx]")
        try
          $(box).children("span.boxname").html env.domobject[box.getAttribute "objinx"].name
        catch

      #预览事件函数
      window.boxViewtype = ->
        im[0].contentWindow["box#{rid}"] (err, dt)->
          if err
            $.notify "出错啦，可能验证没有通过"
            return
          env.formData = dt
          console.log dt
          $.notify "已经在控制台上打印了结果", "success"

      window.restoreDataFun = ->
        if not env.formData
          return $.notify "请先点击“查看数据”获取数据"
        im[0].contentWindow["box#{rid}"] env.formData, (err) ->
          if err
            console.log err
            $.notify "恢复数据失败"
          else
            $.notify "恢复数据成功", "success"

  viewtype: (e, env) ->
    window.boxViewtype()

  restoreData: (e, env) ->
    window.restoreDataFun()

#保存表单
  save: (e, env, opt)->
    type = opt[1]
    type = 'newForm' if not type
    type = 'newForm' if type is 'updateVersion' and (not env.formId or not env.formVersion)
    type = 'newForm' if type is 'newVersion' and not env.formId
    saveit = ->
      #得到最新的valueType
      domToStruct env, (err, dt) ->
        return console.log err if err
        $.post "#{config.rooturl}/itsm/request/insertFormDataStructure.spr"
        ,
          formDataStructure: JSON.stringify(dt)
          formId: env.formId
          formName: env.formName
          formVersion: env.formVersion
          teamId: env.teamId
          type: type
        , (dt)->
          return console.log dt.retDetail if dt?.retCode
          dt = dt.data
          # 更新formId and formVersion
          env.formId = dt.formId if dt.formId
          env.formVersion = dt.formVersion if dt.formVersion
          structToDom dt.dataStructureJson, env, (err) ->
            return console.log err if err
            #保存json数据为了能重新编辑
            domToJson env, (err, json) ->
              return console.log err if err
              $.post "#{config.rooturl}/itsm/request/updateFormSerialization.spr"
              ,
                formSerialization: JSON.stringify(json)
                formId: env.formId
                formVersion: env.formVersion
              , (result)->
                return console.log dt.retDetail if dt?.retCode
                #保存最终的html数据，包含style, html, javascript
                makeHtml env, 0, (err, html) ->
                  return console.log err if err
                  $.post "#{config.rooturl}/itsm/request/updateFormHtml.spr"
                  ,
                    formHtml: html
                    formId: env.formId
                    formVersion: env.formVersion
                  , (result)->
                    if not result.retCode
                      $.notify "保存成功", 'success'
                    console.log result, env, "Save End"
                  , 'json'
              , 'json'
        , 'json'

    if not env.formName or type is 'newForm'
      $.post "#{config.rooturl}/itsm/request/getFormListEditByUser.spr"
      , (result) ->
        return $.notify(result.retDetail) if result.retCode
        teamList = []
        for teamfield in result.data
          teamList.push """<optgroup label="#{teamfield.teamFieldName}">"""
          for team in teamfield.teamList
            sel = if team.teamId is env.teamId then " selected" else ""
            teamList.push """<option value="#{team.teamId}"#{sel}>#{team.teamName}</option>"""
          teamList.push "</optgroup>"
        nameForm = $("#formName")
        form = nameForm.find 'form'
        form.find("input:text").val env.formName
        form.resetForm()
        form.find("select").html teamList.join("")
        nameForm.modal 'show'
        form.unbind('submit').submit (e) ->
          e.preventDefault()
          if form.valid()
            env.formName = form.find("input:text").val()
            env.teamId = form.find("select").val()
            nameForm.modal 'hide'
            setTitle env
            saveit()
    else
      saveit()

  loadform: (e, env)->
    modal = $("#formList")
    verdom = modal.find(".tree span.active")
    return $.notify("请选择表单", "error") if not verdom[0]
    env.formVersion = verdom.attr "version"
    env.formId = verdom.closest("[formid]").attr "formid"
    env.teamId = verdom.closest("[teamid]").attr "teamid"
    loadForm env, (err, dt)->
      return err if err
      env.formName = dt.formName
      setTitle env
    modal.modal 'hide'
    #加载新的表单
  jsonData: (e, env) ->
    domToJson env, (err, json) ->
      if err
        $.notify "数据错误"
        console.log err
      else
        console.log JSON.stringify json
        $.notify "已经在控制台打印了结果", "success"

dofocus = (t, env) ->
  objinx = t.attr "objinx"
  if env.domobject[objinx]
    if env.focusBox
      inx = env.focusBox.attr "objinx"
      if inx is objinx
        return
      infoview = $("div.pubinfo>.infoview")
      env.domobject[inx].removePropertyView infoview, env.focusBox
      env.focusBox.removeClass "boxactive"
    env.focusBox = t
    infoview = $("""<div class="infoview"></div>""")
    $("div.pubinfo").empty().append(infoview)
    env.domobject[objinx].updatePropertyView infoview, t
    t.addClass "boxactive"

#从这里开始运行
$ ->
  sidebar = $('div.sidebar-nav').html initmenu()
  sidebar.find("li.boxes:first").show()
  sidebar.find('li.nav-header').click ->
    sidebar.find("li.boxes").hide()
    $(this).next().slideDown()
  dragit sidebar.find('div.box')
  rootcolumn = $('div.column')
  env.rootcolumn = rootcolumn
  sortit rootcolumn #绑定可排序的dom

  formId = getUrlParam 'formId'
  formVersion = getUrlParam 'formVersion'
  if formId and formVersion
    env.formId = formId
    env.formVersion = formVersion
    loadForm env, (err, dt)->
      return err if err
      env.formName = dt.formName
      setTitle env
  else
    ## test
    #jsonToDom [["DynamicLayout","dynamiclayout",[["Input","input"]]],["TabLayout",["tablayout"],[["Input","input1"]]]], env, (err)->
    jsonToDom [["DynamicLayout","dynamiclayout",[["Input","input"]]],["TabLayout",["tablayout",{"tabs":[["a",""],["b",""],["c",""]],"focus":1}],[["Input","input1"]],null,[["Input", "input2"]]]], env, (err)->
      #setTimeout ->
        #$("button[act=preview]").trigger 'click'
      #, 100
    setTitle env

  rootcolumn.mousedown (e) ->
    t = $(e.target).closest ".box[objinx]"
    if t[0]
      dofocus t, env
      return
    # remove focuse
    if env.focusBox
      inx = env.focusBox.attr 'objinx'
      infoview = $ "div.pubinfo>.infoview"
      env.domobject[inx]?.removePropertyView infoview, env.focusBox
      env.focusBox.removeClass "boxactive"
      env.focusBox = null
      $("div.pubinfo").empty()
    return

#初始化验证表单
  $('.modal form').each ->
    $(this).validate
      debug: true
      showErrors: (errorMap, errorList) ->
        $.each this.validElements(), (index, element)->
          $(element).data("title", '').removeClass('error').tooltip('destroy')
          return
        $.each errorList, (index, error)->
          $(error.element).tooltip("destroy").data("title", error.message).addClass("error").tooltip()
          return

  # 删除dom事件
  rootcolumn.delegate ".remove", "click", (e)->
    e.preventDefault()
    t = $(this).parent()
    objinx = t.attr 'objinx'
    if env.focusBox and env.focusBox[0] is t[0]
      inx = env.focusBox.attr "objinx"
      infoview = $("div.pubinfo>.infoview")
      env.domobject[inx].removePropertyView infoview, env.focusBox
      env.focusBox = null
      $("div.pubinfo").empty()
    env.domobject[objinx].beforeRemove t
    t.remove()
    delete env.domobject[objinx]

  #重命名
  rootcolumn.delegate ".boxname", "click", (e)->
    e.preventDefault()
    ct = $(this)
    t = ct.parent()
    objinx = t.attr 'objinx'
    o = env.domobject[objinx]
    box = $("#boxName")
    form = box.find 'form'
    form.find("input:text").val o.name
    form.resetForm()
    box.modal 'show'
    form.unbind('submit').submit (e) ->
      e.preventDefault()
      if form.valid()
        name = form.find("input:text").val()
        box.modal 'hide'
        console.log name
        o.setName name
        ct.html name


  #绑定act事件
  $('ul.nav,div.modal').delegate '[act]', 'click', (e)->
    e.preventDefault()
    t = $(e.target).closest '[act]'
    at = t.attr('act').split '|'
    act[at[0]]? e, env, at


