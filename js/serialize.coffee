#重新定位布局中的子box index
columnInx = (o)->
  inx = 0
  os = {}
  o.find("div.column").each (i, t)->
    t = $ t
    oc = t.closest('div[objinx]')
    if oc[0]
      objinx = oc.attr 'objinx'
      if not os[objinx]
        os[objinx] = 0
      t.attr 'inx', os[objinx]++


#从dom得到json数据
domToJson = (env, callback)->
  oc = env.domobject
  o = env.rootcolumn
  out = [] #数据结构 [name, data, childrenBox...]
  os = {} #用于保存索引
  nos = {}
  columnInx o
  async.eachSeries o.find("div[objinx]"), (t, callback)->
    t = $ t
    objinx = t.attr "objinx"
    oo = oc[objinx]
    return callback 1 if not oo or os[objinx]
    if nos[oo.name]
      ni = 1
      ni++ while nos[oo.name+ni]
      oo.setName oo.name+ni #保存当前没有冲突的新的名字
    ot = [t.attr('cls')]
    os[objinx] = ot
    nos[oo.name] = ot
    oo.toJson (err, s)->
      return callback err if err
      ot.push s
      #检查是否有父结点，从而决定把节点放在对应的位置
      parent = t.parent(".column[inx]")
      if parent[0]
        po = parent.closest('div[objinx]')
        pobj = os[po.attr('objinx')]
        return callback 1 if not pobj
        inx = (parseInt parent.attr 'inx') + 2 #因为前面俩位是类名和数据
        if not pobj[inx]
          pobj[inx] = []
        pobj[inx].push ot
      else
        out.push ot
      callback 0
  ,
    (err) ->
      callback err, out

#从json数据生成dom
#TODO: request remove function before remove it
jsonToDom = (json, env, callback)->
  doit = (json, oo, callback)->
    async.eachSeries json, (jn, callback)->
      cls = jn[0]
      try
        dom = new window[cls]
        dom.className = cls
      catch
        console.log "#{cls} don't exist, use BoxBase instead."
        dom = new window.BoxBase
      dom.fromJson jn[1], (err)->
        return callback err if err
        ot = $ """
          <div class="box ui-draggable" cls="#{cls}" objinx="#{env.randindex}">
            <span class="drag label label-default"><i class="glyphicon glyphicon-move"></i> 拖动</span>
            <span class="remove label label-danger"><i class="glyphicon glyphicon-remove"></i> 删除</span>
            <span class="boxname label label-default">#{dom.name}</span>
            <div class="configuration"></div>
            <div class="view"></div>
          </div>
        """
        oo.append ot
        view = ot.find "div.view"
        view.append dom.editview
        ot.find("div.configuration").append dom.toolview
        dom.initdom ot
        env.domobject[env.randindex] = dom
        env.randindex++
        column = view.find "div.column"
        if column[0]
          #为每个column增加inx
          column.each (i, t)->
            $(t).attr 'inx', i
          sortit column
        async.forEachOf jn[2..], (cjson, i, callback)->
          cdom = view.find "div.column[inx=#{i}]"
          if not cdom[0] #忽略不存在的项或cloumn
            console.log "#{cls} don't exist column #{i}, ignore it."
            return callback 0
          doit cjson, cdom, callback
        ,
          callback
    , callback
  env.rootcolumn.empty()
  doit json, env.rootcolumn, callback

#系列化页面成为html，用于预览或输出用户使用
toHtml = (env, callback)->
  oc = env.domobject
  o = env.rootcolumn
  out = []
  os = {}
  nos = {}
  columnInx o
  async.eachSeries o.find("div[objinx]"), (t, callback)->
    t = $ t
    objinx = t.attr "objinx"
    oo = oc[objinx]
    return callback 1 if not oo or os[objinx]
    if nos[oo.name]
      ni = 1
      ni++ while nos[oo.name+ni]
      oo.setName oo.name+ni #保存当前没有冲突的新的名字
    oo.toHtml (err, ht)->
      return callback err if err
      #压缩当前的html
      ht = ht.replace(/(['"])\s*[\r\n]+\s*/mg, "$1 ").replace(/\s*[\r\n]+\s*/mg, '').replace(/^\s+|\s+$/g, '')
      #增加属性为了能正确得到数据，所有的这些属性都是box开头
      ht = ht.replace(/^(\<[a-zA-Z]+)/, "$1 boxclass=\"#{oo.className}\" boxname=\"#{oo.name}\" boxextend=\"#{oo.extend}\"")
      ot = [ht]
      os[objinx] = ot
      nos[oo.name] = ot
      # 检查是否还有父节点
      parent = t.parent(".column[inx]")
      if parent[0]
        po = parent.closest "div[objinx]"
        pobj = os[po.attr('objinx')]
        return callback 1 if not pobj
        inx = (parseInt parent.attr 'inx') + 1
        if not pobj[inx]
          pobj[inx] = []
        pobj[inx].push ot
      else
        out.push ot
      callback 0
  , (err)->
    #整理生成的html文本，查找所有的孩子进行字符串替换
    #几重循环，我自己看都头晕，没有办法，框架就是要写这么难看的代码
    #如果您维护这段代码而且有更好的方法，欢迎联系mike.cyc@gmail.com，谢谢！
    joinit = (a)->
      if a.length > 1
        #do child
        str = a[0]
        cd = a[1..]
        for v, i in cd
          if v
            for vv, ii in v
              if vv.length > 1
                v[ii] = joinit vv
              else
                v[ii] = vv[0]
            cd[i] = v.join("")
          else
            cd[i] = ''
        #查找当前的html字符串，把生成的子串添加进去
        count = 0
        str.replace /(<div [^\n>]*?class=[^\n>=]*?column[^\n>]*?>)(<\/div>)/g, ($0, $1, $2)->
          "#{$1}#{cd[count++] or ''}#{$2}"
      else
        a[0]
    for v, i in out
      out[i] = joinit v
    callback err, out.join ''

cssCache = {} #缓存已经请求的数据
#生成用户态需要的css
toCss = (env, callback)->
  allcss = {}
  for i, v of env.domobject
    for c in v.css
      allcss[c] = 1
  out = []
  async.eachSeries Object.keys(allcss), (name, callback)->
    if cssCache[name]
      out.push cssCache[name]
      return callback 0
    $.ajax "#{config.boxpath}#{name}.user.css?#{(new Date()).getTime()}",
      contentType: 'text/plain'
      dataType: 'text'
      mimeType: 'text/plain'
      success: (dt)->
        #简单压缩一下
        dt = dt.replace(/\/\*[\s\S]*?\*\//mg, '').replace(/\s*[\r\n]+\s*/mg, '').replace(/^\s+|\s+$/g, '')
        cssCache[name] = dt
        out.push dt
        callback 0
      error: (xhr, ts, err)->
        console.log "Request #{config.boxpath}#{name}.user.css failed: #{ts}"
        callback 1
  , (err)->
    callback err, out.join('')

#用户态的js
jsCache = {}
toJs = (env, callback) ->
  alljs = {}
  for i, v of env.domobject
    for c in v.js
      alljs[c] = 1
  out = []
  async.eachSeries Object.keys(alljs), (name, callback) ->
    if jsCache[name]
      out.push jsCache[name]
      return callback 0
    $.ajax "#{config.boxpath}#{name}.user.js?#{(new Date()).getTime()}",
      contentType: 'text/plain'
      dataType: 'text'
      mimeType: 'text/plain'
      success: (dt) ->
        #简单压缩一下
        dt = dt.replace(/\/\*[\s\S]*?\*\//mg, '').replace(/\s*\/\/[^\n\r]*[\r\n]?/mg, "\n").replace(/\s*[\r\n]+\s*/mg, '').replace(/^\s+|\s+$/g, '')
        #还需要在这里包一层，避免变量等冲突的问题
        dt = """box.#{name}={};(function(box){#{dt}})(box.#{name});"""
        jsCache[name] = dt
        out.push dt
        callback 0
      error: (xhr, ts, err)->
        console.log "Request #{config.boxpath}#{name}.user.js failed: #{ts}"
        callback 1
  , (err)->
    callback err, out.join('')

#输出第三方的js
toExcss = (env, callback)->
  allexcss = {}
  for i, v of env.domobject
    for ii, vv of v.excss
      allexcss[ii] = vv
  callback 0, allexcss

#输出第三方的js
toExjs = (env, callback)->
  allexjs = {}
  for i, v of env.domobject
    for ii, vv of v.exjs
      allexjs[ii] = vv
  callback 0, allexjs

#输出
window.domToJson = domToJson
window.jsonToDom = jsonToDom
window.toHtml = toHtml
window.toCss = toCss
window.toJs = toJs
window.toExcss = toExcss
window.toExjs = toExjs
