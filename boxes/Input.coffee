init = (BoxBase) ->
  class Input extends BoxBase
    constructor: (@label)->
      @setName "input"

    getDragview: -> $ "<h1>[Input box]</h1>"

    getEditview: ->
      @_editview = $ """
        <div><label>名称</label> <input type="text" name="#{@name or 'unknow'}"/></div>
      """

    getToolview: ->
      @_toolview = $ """
      <span></span>
      """
    initdom: (o)->
      o.find("input").change ->
        console.log $(this).val()

    getTitle: ->
      "名称"

    toJson: (callback)->
      callback 0, @name or 'unknow'

    fromJson: (json, callback)->
      @name = json
      callback 0

    toHtml: (callback)->
      callback 0, """
        <div><label>名称</label> <input data-msg-maxlength="The field StringLengthAndRequiredDemo must be a string with a minimum length of 5 and a maximum length of 10."
      data-msg-minlength="The field StringLengthAndRequiredDemo must be a string with a minimum length of 5 and a maximum length of 10."
      data-msg-required="The StringLengthAndRequiredDemo field is required."
      data-rule-maxlength="10"
      data-rule-minlength="5"
      data-rule-required="true" type="text" name="#{@name or 'unknow'}"/></div>
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

    #getExjs: ->
      #$.extend {}, super(),
        #'jquery.validate': '!jQuery.fn.validate'
##        'jquery.validate.unobtrusive': "!jQuery.validator.unobtrusive"

# set if requirejs
  if define? and define.amd
    define [], -> Input
  else if window?
    window.Input = Input

#开始运行
if require?
  require ["BoxBase"], init
else
  init window.BoxBase
