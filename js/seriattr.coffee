#由dom生成一个结构
#后端人员提供的接口方式，对前端只是增加负担，尽量满足他们的要求吧
#做前端的就是如此被动
domToStruct = (env, callback)->
  nos = {}
  oc = env.domobject
  o = env.rootcolumn
  out = {}
  async.eachSeries o.find("div[objinx]"), (t, callback)->
    t = $ t
    objinx = t.attr "objinx"
    oo = oc[objinx]
    return callback 1 if not oo
    if nos[oo.name]
      ni = 1
      ni++ while nos[oo.name+ni]
      oo.setName oo.name+ni #保存当前没有冲突的新的名字
    oo.getValueType (err, at)->
      return callback err if err
      nos[oo.name] = valueType: at
      #得到title
      title = oo.title
      if title
        nos[oo.name].title = title
      #检查父节点
      po = t.parent().closest("div[objinx]")
      if po[0]
        pobj = oc[po.attr('objinx')]
        return callback 1 if not pobj
        pn = pobj.name
        return callback 1 if not nos[pn]
        nos[pn].valueType[oo.name] = nos[oo.name]
      else
        out[oo.name] = nos[oo.name]
      callback 0
    return
  , (err)->
    callback err, out

#把服务器返回的valueType写到表单插件里
structToDom = (json, env, callback)->
  #把所有的oc按名字进行散列化
  nos = {}
  for i, v of env.domobject
    nos[v.getName()] = v
  doit = (json, callback)->
    async.forEachOf json, (v, k, callback)->
      if nos[k] and v.valueType
        nos[k].setValueType v, (err)->
          return callback err if err
          if nos[k].pluginType isnt 'form' && $.isPlainObject v.valueType
            doit v.valueType, callback
          else
            callback 0
      else
        callback 0 #因有一个名字插件内部已经实现了系列化，故不输出错误
    , callback
  doit json, callback


window.structToDom = structToDom
window.domToStruct = domToStruct
