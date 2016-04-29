init = (BoxBase) ->
  class TabLayout extends BoxBase
    constructor: (@label)->
      @setName "tablayout"
      @jsonData =
        tabs: [
          ["", ""] #name, url
        ]
        focus: 0

    getDragview: -> $ "<h1>[TabLayout box]</h1>"

    makeView: ->
      tabs = []
      columns = []
      for tab, i in @jsonData.tabs
        tabs.push """<li role="presentation"#{if i is @jsonData.focus then ' class="active"' else ''} index="#{i}"><a href="#">#{tab[0] or '　'}</a></li>"""
        columns.push """<div class="column"#{if i is @jsonData.focus then '' else ' style="display:none;"'}></div>"""

      """
<div>
<ul class="nav nav-tabs">
  #{tabs.join('')}
</ul>
<div class="tabs-column">
  #{columns.join('')}
</div>
</div>
      """

    getEditview: ->
      @_editview = $ @makeView()

    getToolview: ->
      @_toolview = $ """
      """

    initdom: (o)->
      @_editview.children("ul.nav-tabs").click (e) =>
        t = $(e.target).closest("[index]")
        if t[0]
          e.preventDefault()
          index = parseInt t.attr 'index'
          if index isnt @jsonData.focus
            @jsonData.focus = index
            @freshTabs()

    toJson: (callback)->
      callback 0, [@name, @jsonData]

    fromJson: (json, callback)->
      if json
        @setName json[0]
        @jsonData = json[1] if json[1]
      callback 0

    getValueType: (callback)->
      callback 0, {}

    toHtml: (callback)->
      tabs = []
      columns = []
      for tab, i in @jsonData.tabs
        tabs.push """<option value="#{i}"#{if i is @jsonData.focus then ' selected="true"' else ''}>#{tab[0] or ''}</option>"""
        columns.push """<div class="column"#{if i is @jsonData.focus then '' else ' style="display:none;"'}></div>"""

      callback 0, """
<div>
<select class="form-control">
  #{tabs.join('')}
</select>
<div class="tabs-column">
  #{columns.join('')}
</div>
</div>
      """

    freshTabs: =>
      index = @jsonData.focus
      for tab, i in @_editview.children("ul.nav-tabs").children('li')
        if index is i
          $(tab).addClass "active"
        else
          $(tab).removeClass "active"
      @updatePropertyView(@propertyView)
      for column, i in @_editview.children("div.tabs-column").children("div")
        if index is i
          $(column).show()
        else
          $(column).hide()

    removePropertyView: (o, t) ->
      @propertyView = null

    updatePropertyView: (o, t) ->
      if not o
        return
      @propertyView = o
      freshView = =>
        items = []
        for item, i in @jsonData.tabs
          items.push """
<div class="list-group-item#{if i is @jsonData.focus then ' active' else ''}" style="padding:5px;" index="#{i}">
  <div class="form-group">
    <label>标签名称</label>
    <input type="text" class="form-control" name="tabname" value="#{item[0]}"/>
  </div>
  <button class="btn btn-default btn-sm" tact="plus"><i class="glyphicon glyphicon-plus"></i></button>
  <button class="btn btn-default btn-sm" tact="minus"><i class="glyphicon glyphicon-minus"></i></button>
  <button class="btn btn-default btn-sm" tact="up"><i class="glyphicon glyphicon-chevron-up"></i></button>
  <button class="btn btn-default btn-sm" tact="down"><i class="glyphicon glyphicon-chevron-down"></i></button>
</div>
          """
        o.empty()
        o.append """
  <div class="list-group">
#{items.join('')}
  </div>
        """
      freshView()
      o.unbind().click (e) =>
        t = $(e.target).closest "[tact]"
        if t[0]
          e.preventDefault()
          act = t.attr "tact"
          cdom = t.closest("div[index]")
          index = parseInt cdom.attr "index"
          if act is "plus"
            @jsonData.tabs.splice index+1, 0, ['', '']
            cc = $("""<div class="column"></div>""")
            $(@_editview.children("div.tabs-column").children("div")[index]).after(cc)
            #绑定事件
            sortit cc
            @jsonData.focus = index+1
          else if act is "minus"
            if @jsonData.tabs.length <= 1
              $.notify "至少保留一项"
              return
            if not confirm "删除后无法恢复，确认删除？"
              return
            if index <= @jsonData.focus
              @jsonData.focus -= 1
            $(@_editview.children("div.tabs-column").children("div")[index]).remove()
            @jsonData.tabs.splice index, 1
          else if act is "up"
            if index <= 0
              $.notify "已经到顶"
              return
            it = @jsonData.tabs.splice index, 1
            @jsonData.tabs.splice index-1, 0, it[0]
            cl = @_editview.children("div.tabs-column").children("div")
            @jsonData.focus = index - 1
            $(cl[index-1]).before cl[index]
          else if act is "down"
            if index >= @jsonData.tabs.length - 1
              $.notify "已经到底"
              return
            it = @jsonData.tabs.splice index, 1
            @jsonData.tabs.splice index+1, 0, it[0]
            cl = @_editview.children("div.tabs-column").children("div")
            @jsonData.focus = index + 1
            $(cl[index+1]).after cl[index]
          # 刷新property view
          freshView()
          # 刷新 tabs
          tabs = []
          for tab, i in @jsonData.tabs
            tabs.push """<li role="presentation"#{if i is @jsonData.focus then ' class="active"' else ''} index="#{i}"><a href="#">#{tab[0] or '　'}</a></li>"""
          @_editview.find("ul.nav-tabs")[0].innerHTML = tabs.join('')
          # 刷新 cloumn
          for cl, i in @_editview.children("div.tabs-column").children("div")
            t = $(cl)
            t.attr 'inx', i
            if i is @jsonData.focus
              t.show()
            else
              t.hide()
        else if not $(e.target).is "input,button"
          cdom = $(e.target).closest("div[index]")
          index = parseInt cdom.attr "index"
          if index >= 0 and index isnt @jsonData.focus
            @jsonData.focus = index
            @freshTabs()

      .change (e) =>
        t = $ e.target
        if t.is(":text")
          c = t.closest("div[index]")
          index = parseInt c.attr "index"
          @jsonData.tabs[index] = [c.find('input[name=tabname]').val() or '', c.find('input[name=taburl]').val() or '']
          if t.is("[name=tabname]")
            $(@_editview.find("li[role=presentation]>a")[index]).html(t.val() or '　')

    getExjs: ->
      $.extend {}, super(),
        'notify': "!jQuery.notify"

    #getCss: ->
      #css = super()
      #css.push "TabLayout"
      #css

    getJs: ->
      js = super()
      js.push 'TabLayout'
      js


# set if requirejs
  if define? and define.amd
    define [], -> TabLayout
  else if window?
    window.TabLayout = TabLayout

#开始运行
if require?
  require ["BoxBase"], init
else
  init window.BoxBase
