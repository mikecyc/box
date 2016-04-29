// Generated by CoffeeScript 1.10.0
(function() {
  var columnInx, cssCache, domToJson, jsCache, jsonToDom, toCss, toExcss, toExjs, toHtml, toJs;

  columnInx = function(o) {
    var inx, os;
    inx = 0;
    os = {};
    return o.find("div.column").each(function(i, t) {
      var objinx, oc;
      t = $(t);
      oc = t.closest('div[objinx]');
      if (oc[0]) {
        objinx = oc.attr('objinx');
        if (!os[objinx]) {
          os[objinx] = 0;
        }
        return t.attr('inx', os[objinx]++);
      }
    });
  };

  domToJson = function(env, callback) {
    var nos, o, oc, os, out;
    oc = env.domobject;
    o = env.rootcolumn;
    out = [];
    os = {};
    nos = {};
    columnInx(o);
    return async.eachSeries(o.find("div[objinx]"), function(t, callback) {
      var ni, objinx, oo, ot;
      t = $(t);
      objinx = t.attr("objinx");
      oo = oc[objinx];
      if (!oo || os[objinx]) {
        return callback(1);
      }
      if (nos[oo.name]) {
        ni = 1;
        while (nos[oo.name + ni]) {
          ni++;
        }
        oo.setName(oo.name + ni);
      }
      ot = [t.attr('cls')];
      os[objinx] = ot;
      nos[oo.name] = ot;
      return oo.toJson(function(err, s) {
        var inx, parent, po, pobj;
        if (err) {
          return callback(err);
        }
        ot.push(s);
        parent = t.parent(".column[inx]");
        if (parent[0]) {
          po = parent.closest('div[objinx]');
          pobj = os[po.attr('objinx')];
          if (!pobj) {
            return callback(1);
          }
          inx = (parseInt(parent.attr('inx'))) + 2;
          if (!pobj[inx]) {
            pobj[inx] = [];
          }
          pobj[inx].push(ot);
        } else {
          out.push(ot);
        }
        return callback(0);
      });
    }, function(err) {
      return callback(err, out);
    });
  };

  jsonToDom = function(json, env, callback) {
    var doit;
    doit = function(json, oo, callback) {
      return async.eachSeries(json, function(jn, callback) {
        var cls, dom, error;
        cls = jn[0];
        try {
          dom = new window[cls];
          dom.className = cls;
        } catch (error) {
          console.log(cls + " don't exist, use BoxBase instead.");
          dom = new window.BoxBase;
        }
        return dom.fromJson(jn[1], function(err) {
          var column, ot, view;
          if (err) {
            return callback(err);
          }
          ot = $("<div class=\"box ui-draggable\" cls=\"" + cls + "\" objinx=\"" + env.randindex + "\">\n  <span class=\"drag label label-default\"><i class=\"glyphicon glyphicon-move\"></i> 拖动</span>\n  <span class=\"remove label label-danger\"><i class=\"glyphicon glyphicon-remove\"></i> 删除</span>\n  <span class=\"boxname label label-default\">" + dom.name + "</span>\n  <div class=\"configuration\"></div>\n  <div class=\"view\"></div>\n</div>");
          oo.append(ot);
          view = ot.find("div.view");
          view.append(dom.editview);
          ot.find("div.configuration").append(dom.toolview);
          dom.initdom(ot);
          env.domobject[env.randindex] = dom;
          env.randindex++;
          column = view.find("div.column");
          if (column[0]) {
            column.each(function(i, t) {
              return $(t).attr('inx', i);
            });
            sortit(column);
          }
          return async.forEachOf(jn.slice(2), function(cjson, i, callback) {
            var cdom;
            cdom = view.find("div.column[inx=" + i + "]");
            if (!cdom[0]) {
              console.log(cls + " don't exist column " + i + ", ignore it.");
              return callback(0);
            }
            return doit(cjson, cdom, callback);
          }, callback);
        });
      }, callback);
    };
    env.rootcolumn.empty();
    return doit(json, env.rootcolumn, callback);
  };

  toHtml = function(env, callback) {
    var nos, o, oc, os, out;
    oc = env.domobject;
    o = env.rootcolumn;
    out = [];
    os = {};
    nos = {};
    columnInx(o);
    return async.eachSeries(o.find("div[objinx]"), function(t, callback) {
      var ni, objinx, oo;
      t = $(t);
      objinx = t.attr("objinx");
      oo = oc[objinx];
      if (!oo || os[objinx]) {
        return callback(1);
      }
      if (nos[oo.name]) {
        ni = 1;
        while (nos[oo.name + ni]) {
          ni++;
        }
        oo.setName(oo.name + ni);
      }
      return oo.toHtml(function(err, ht) {
        var inx, ot, parent, po, pobj;
        if (err) {
          return callback(err);
        }
        ht = ht.replace(/(['"])\s*[\r\n]+\s*/mg, "$1 ").replace(/\s*[\r\n]+\s*/mg, '').replace(/^\s+|\s+$/g, '');
        ht = ht.replace(/^(\<[a-zA-Z]+)/, "$1 boxclass=\"" + oo.className + "\" boxname=\"" + oo.name + "\" boxextend=\"" + oo.extend + "\"");
        ot = [ht];
        os[objinx] = ot;
        nos[oo.name] = ot;
        parent = t.parent(".column[inx]");
        if (parent[0]) {
          po = parent.closest("div[objinx]");
          pobj = os[po.attr('objinx')];
          if (!pobj) {
            return callback(1);
          }
          inx = (parseInt(parent.attr('inx'))) + 1;
          if (!pobj[inx]) {
            pobj[inx] = [];
          }
          pobj[inx].push(ot);
        } else {
          out.push(ot);
        }
        return callback(0);
      });
    }, function(err) {
      var i, j, joinit, len, v;
      joinit = function(a) {
        var cd, count, i, ii, j, k, len, len1, str, v, vv;
        if (a.length > 1) {
          str = a[0];
          cd = a.slice(1);
          for (i = j = 0, len = cd.length; j < len; i = ++j) {
            v = cd[i];
            if (v) {
              for (ii = k = 0, len1 = v.length; k < len1; ii = ++k) {
                vv = v[ii];
                if (vv.length > 1) {
                  v[ii] = joinit(vv);
                } else {
                  v[ii] = vv[0];
                }
              }
              cd[i] = v.join("");
            } else {
              cd[i] = '';
            }
          }
          count = 0;
          return str.replace(/(<div [^\n>]*?class=[^\n>=]*?column[^\n>]*?>)(<\/div>)/g, function($0, $1, $2) {
            return "" + $1 + (cd[count++] || '') + $2;
          });
        } else {
          return a[0];
        }
      };
      for (i = j = 0, len = out.length; j < len; i = ++j) {
        v = out[i];
        out[i] = joinit(v);
      }
      return callback(err, out.join(''));
    });
  };

  cssCache = {};

  toCss = function(env, callback) {
    var allcss, c, i, j, len, out, ref, ref1, v;
    allcss = {};
    ref = env.domobject;
    for (i in ref) {
      v = ref[i];
      ref1 = v.css;
      for (j = 0, len = ref1.length; j < len; j++) {
        c = ref1[j];
        allcss[c] = 1;
      }
    }
    out = [];
    return async.eachSeries(Object.keys(allcss), function(name, callback) {
      if (cssCache[name]) {
        out.push(cssCache[name]);
        return callback(0);
      }
      return $.ajax("" + config.boxpath + name + ".user.css?" + ((new Date()).getTime()), {
        contentType: 'text/plain',
        dataType: 'text',
        mimeType: 'text/plain',
        success: function(dt) {
          dt = dt.replace(/\/\*[\s\S]*?\*\//mg, '').replace(/\s*[\r\n]+\s*/mg, '').replace(/^\s+|\s+$/g, '');
          cssCache[name] = dt;
          out.push(dt);
          return callback(0);
        },
        error: function(xhr, ts, err) {
          console.log("Request " + config.boxpath + name + ".user.css failed: " + ts);
          return callback(1);
        }
      });
    }, function(err) {
      return callback(err, out.join(''));
    });
  };

  jsCache = {};

  toJs = function(env, callback) {
    var alljs, c, i, j, len, out, ref, ref1, v;
    alljs = {};
    ref = env.domobject;
    for (i in ref) {
      v = ref[i];
      ref1 = v.js;
      for (j = 0, len = ref1.length; j < len; j++) {
        c = ref1[j];
        alljs[c] = 1;
      }
    }
    out = [];
    return async.eachSeries(Object.keys(alljs), function(name, callback) {
      if (jsCache[name]) {
        out.push(jsCache[name]);
        return callback(0);
      }
      return $.ajax("" + config.boxpath + name + ".user.js?" + ((new Date()).getTime()), {
        contentType: 'text/plain',
        dataType: 'text',
        mimeType: 'text/plain',
        success: function(dt) {
          dt = dt.replace(/\/\*[\s\S]*?\*\//mg, '').replace(/\s*\/\/[^\n\r]*[\r\n]?/mg, "\n").replace(/\s*[\r\n]+\s*/mg, '').replace(/^\s+|\s+$/g, '');
          dt = "box." + name + "={};(function(box){" + dt + "})(box." + name + ");";
          jsCache[name] = dt;
          out.push(dt);
          return callback(0);
        },
        error: function(xhr, ts, err) {
          console.log("Request " + config.boxpath + name + ".user.js failed: " + ts);
          return callback(1);
        }
      });
    }, function(err) {
      return callback(err, out.join(''));
    });
  };

  toExcss = function(env, callback) {
    var allexcss, i, ii, ref, ref1, v, vv;
    allexcss = {};
    ref = env.domobject;
    for (i in ref) {
      v = ref[i];
      ref1 = v.excss;
      for (ii in ref1) {
        vv = ref1[ii];
        allexcss[ii] = vv;
      }
    }
    return callback(0, allexcss);
  };

  toExjs = function(env, callback) {
    var allexjs, i, ii, ref, ref1, v, vv;
    allexjs = {};
    ref = env.domobject;
    for (i in ref) {
      v = ref[i];
      ref1 = v.exjs;
      for (ii in ref1) {
        vv = ref1[ii];
        allexjs[ii] = vv;
      }
    }
    return callback(0, allexjs);
  };

  window.domToJson = domToJson;

  window.jsonToDom = jsonToDom;

  window.toHtml = toHtml;

  window.toCss = toCss;

  window.toJs = toJs;

  window.toExcss = toExcss;

  window.toExjs = toExjs;

}).call(this);
