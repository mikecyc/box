class BoxBase
  ### The mother of all box plugins ###

  #框架会自动设置这个名字，请不要设置跟这个属性同名的属性或方法
  className: 'BoxBase'

  _name: "box"
  #保存服务器返回的附加参数，提交的时候原样返回就好
  _extend: {}
  #提示当前的插件的类型，如果为form类型将表示插件已经实现了自己的取值和设置值的方法
  _pluginType: null

  @property = (name, getter) ->
    if typeof getter is 'string'
      get = -> this[getter].call this
    else
      get = -> getter.call this
    Object.defineProperty @prototype, name,
      get: get
      enumerable: true

  @property 'pluginType', 'getPluginType'
  getPluginType: -> @_pluginType

  # 这个插件的动态名字
  @property 'name', 'getName'
  getName: -> @_name
  setName: (name)-> @_name = name

  @property 'drapview', 'getDragview'
  getDragview: -> $ "<h1>[Box drag view]</h1>"

  @property 'editview', 'getEditview'
  getEditview: -> $ "<h1>[Box edit view]</h1>" # return dom or dom string

  @property 'toolview', 'getToolview'
  getToolview: -> $ "<span></span>"

  #预览的时候调用的方法
  @property 'preview', 'getPreview'
  getPreview: -> $ "<h1>[Box preview]</h1>"

  # 得到插件title
  @property 'title', 'getTitle'
  getTitle: -> ''

  # 绑定事件，初始化编辑框之类的
  # 将传入当前的box dom, jquery 方式
  initdom: (o)->

  # 对应的dom被删除前调的函数
  beforeRemove: (o)->

  # 更新property视图
  # o 为当前的视图容器，jQuery格式
  updatePropertyView: (o, t) ->
    #o.append "not property."

  removePropertyView: (o, t) ->
    # 在这里清理一些事件绑定之类的，框架会自动清空视图

  # 生成一个json对象，是对象的方式，用于保存
  toJson: (callback)->
    throw new Error "Not json implemented."

  # 通过一个json对象初始化数据，完成后callback
  # 只有初始化数据才会调用
  fromJson: (json, callback) ->
    throw new Error "Not translate json function implemented."

  # 得到当前的valueType
  getValueType: (callback)->
    callback 0, "string"

  #访问服务器之后，重新设置一些附加的数据
  #统一在这里添加就好啦，因为是固定的数据结构
  setValueType: (valueType, callback)->
    extend = {}
    for i, v of valueType
      if i isnt 'valueType'
        extend[i] = v
    @_extend = extend
    callback 0

  @property 'extend', 'getExtend'
  getExtend: ->
    (Base64.encode JSON.stringify(if @title then $.extend({}, @_extend, {title: @title}) else @_extend)).replace(/=+$/, '')

  # 得到对应模块的数据，如果没有子节点返回值的字符串，如果有字节点返回[]
  # 这只有在用户态的情况下用到，故在这里删除
  #getValue: (callback)->
    #throw new Error "Not getValue function implemented."

  # 生成最终的html
  toHtml: (callback)->
    throw new Error "Not create html function implemented."

# 这是预览和用户态的时候用到
# 把这部分放到独立的文件当中
# 列表记录需要加载的文件名，框架加载的时候会自动加上.user.css或.user.js
# 加载的目录跟插件目录一致，这样方便管理插件
  @property 'css', 'getCss'
  getCss: -> ['BoxBase'] #如 ['BoxBase']

  #内部的js将内嵌到html文件里面
  @property 'js', 'getJs'
  getJs: -> [] #如 ['BoxBase']

  #加载第三方css文件，value如果为真表示加载
  #注意：这里的判断是在编辑态而不是用户态
  @property 'excss', 'getExcss'
  getExcss: ->
    'bootstrap.min': 1

  #加载第三方js文件，key为文件名，value为判断条件
  #注意：如果包含的js文件同名将覆盖前面的js，如果有依赖关系的js建议合并起来或自己内部处理，可以选择require.js
  @property 'exjs', 'getExjs'
  getExjs: ->
    'bootstrap.min': '!jQuery.fn.alert && !jQuery.fn.modal'
    'jquery.validate': '!jQuery.fn.validate'
    'base64.min': '!window.Base64'

# set if requirejs
if define? and define.amd
  define [], -> BoxBase
else if window?
  window.BoxBase = BoxBase
