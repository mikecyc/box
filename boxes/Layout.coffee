init = (BoxBase) ->
  class Layout extends BoxBase
    constructor: (@label, column)->
      @column = (column||"6 6").split ' '
      @setName "layout"

    getDragview: -> $ "<h1>[Layout box]#{@column.join(',')}</h1>"

    getEditview: ->
      o = ["""<div class="row clearfix">"""]
      for v in @column
        o.push """<div class="col-md-#{v} column"></div>"""
      o.push """</div>"""
      @_editview = $ o.join("")

    getToolview: ->
      @_toolview = $ """
        <span></span>
      """
    toJson: (callback)->
      callback 0, [@name, @column]

    fromJson: (json, callback)->
      if json
        [name, @column] = json
        @setName name
      callback 0

    getValueType: (callback)->
      callback 0, {}

    toHtml: (callback)->
      o = ["""<div class="row clearfix">"""]
      for v in @column
        o.push """<div class="col-md-#{v} column"></div>"""
      o.push """</div>"""
      callback 0, o.join('')


# set if requirejs
  if define? and define.amd
    define [], -> Layout
  else if window?
    window.Layout = Layout

#开始运行
if require?
  require ["BoxBase"], init
else
  init window.BoxBase
