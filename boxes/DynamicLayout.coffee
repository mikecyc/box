init = (BoxBase) ->
  class DynamicLayout extends BoxBase
    constructor: (@label)->
      @setName "dynamiclayout"

    getDragview: -> $ "<h1>[DynamicLayout box]</h1>"

    makeView: ->
      """<div class="dynamiclayout row clearfix"><div class="column"></div><div class="dl-btn"><button class="btn plus">+</button> <button class="btn minus">-</button></div></div>"""

    getEditview: ->
      @_editview = $ @makeView()

    getToolview: ->
      @_toolview = $ """
      """
    initdom: (o)->
      @_editview.find(".dl-btn button").click ->
        $.notify "只能在预览状态下使用", "warn"

    toJson: (callback)->
      callback 0, @name

    fromJson: (json, callback)->
      if json
        @setName json
      callback 0

    getValueType: (callback)->
      callback 0, {}

    toHtml: (callback)->
      callback 0, @makeView()

    getExjs: ->
      $.extend {}, super(),
        'notify': "!jQuery.notify"

    getCss: ->
      css = super()
      css.push "DynamicLayout"
      css

    getJs: ->
      js = super()
      js.push 'DynamicLayout'
      js


# set if requirejs
  if define? and define.amd
    define [], -> DynamicLayout
  else if window?
    window.DynamicLayout = DynamicLayout

#开始运行
if require?
  require ["BoxBase"], init
else
  init window.BoxBase
