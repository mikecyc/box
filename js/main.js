// Generated by CoffeeScript 1.10.0
(function() {
  var act, dofocus, dragcls, dragit, env, getHtmlCss, getHtmlJs, getUrlParam, initmenu, loadForm, makeHtml, setTitle, sortit, updatedom;

  dragcls = null;

  updatedom = 0;

  env = window.env = {
    rootcolumn: null,
    domobject: {},
    formData: null,
    randindex: 0,
    formId: '',
    formName: '',
    formVersion: '',
    teamId: '',
    focusBox: null
  };

  $.fn.resetForm = function() {
    var t;
    t = this;
    $.each(t.find('.error'), function(index, element) {
      $(element).data("title", '').removeClass('error').tooltip('destroy');
    });
    return t;
  };

  getUrlParam = function(name) {
    var r, reg;
    reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)", "i");
    r = window.location.search.substr(1).match(reg);
    if (r) {
      return decodeURI(r[2]);
    } else {
      return '';
    }
  };

  initmenu = function() {
    var box, boxes, ib, items, j, k, len, len1, ref;
    boxes = config.boxes;
    items = [];
    for (j = 0, len = boxes.length; j < len; j++) {
      box = boxes[j];
      items.push("<ul class=\"nav nav-list accordion-group\">\n  <li class=\"nav-header\">\n    <i class=\"glyphicon-plus glyphicon\"></i> " + box[0] + "\n    <div class=\"pull-right popover-info\"><i class=\"glyphicon glyphicon-question-sign\"></i>\n      <div class=\"popover fade right\">\n        <div class=\"arrow\"></div>\n        <h3 class=\"popover-title\">提示：</h3>\n        <div class=\"popover-content\">" + box[1] + "</div>\n      </div>\n    </div>\n  </li>\n  <li class=\"boxes\" id=\"estRows\">");
      ref = box.slice(2);
      for (k = 0, len1 = ref.length; k < len1; k++) {
        ib = ref[k];
        items.push("<div class=\"box\" cls=\"" + ib[0] + "\" label=\"" + ib[1] + "\" param=\"" + (ib[2] || '') + "\">\n  <span class=\"drag label label-default\"><i class=\"glyphicon glyphicon-move\"></i> 拖动</span>\n  <div class=\"preview\"><span>" + ib[1] + "</span></div>\n</div>");
      }
      items.push("  </li>\n</ul>");
    }
    return items.join("\n");
  };

  dragit = function(o) {
    return o.draggable({
      connectToSortable: ".column",
      helper: "clone",
      handle: ".drag",
      start: function(e, t) {
        var cls;
        updatedom = 1;
        cls = t.helper.attr('cls');
        if (window[cls]) {
          dragcls = new window[cls](t.helper.attr('label'), t.helper.attr('param'));
          dragcls.className = cls;
        } else {
          dragcls = new window.BoxBase;
          console.log(cls + " don't exist, use BoxBase instead.");
        }
        return t.helper.empty().append(dragcls.drapview).css({
          width: 400,
          opacity: .5
        });
      }
    });
  };

  sortit = function(o) {
    return o.sortable({
      connectWith: ".column",
      opacity: .75,
      handle: ".drag",
      start: function(e, t) {
        return t.helper.css({
          opacity: .8
        });
      },
      update: function(e, t) {
        var column, ot, view;
        if (updatedom) {
          updatedom = 0;
          ot = $(t.item[0]);
          ot.attr("objinx", env.randindex);
          ot.html("<span class=\"drag label label-default\"><i class=\"glyphicon glyphicon-move\"></i> 拖动</span>\n<span class=\"remove label label-danger\"><i class=\"glyphicon glyphicon-remove\"></i> 删除</span>\n<span class=\"boxname label label-default\">" + dragcls.name + "</span>\n<div class=\"configuration\"></div>\n<div class=\"view\"></div>");
          view = ot.find('div.view');
          view.append(dragcls.editview);
          ot.find('div.configuration').append(dragcls.toolview);
          dragcls.initdom(ot);
          env.domobject[env.randindex++] = dragcls;
          column = view.find("div.column");
          if (column[0]) {
            column.each(function(i, t) {
              return $(t).attr('inx', i);
            });
            sortit(column);
          }
          return dofocus(ot, env);
        }
      }
    });
  };

  window.sortit = sortit;

  getHtmlCss = function(rid, icss, iexcss, ispreview) {
    var attr, css, excss, view;
    excss = (function() {
      var results;
      results = [];
      for (css in iexcss) {
        attr = iexcss[css];
        if (attr) {
          results.push(css);
        }
      }
      return results;
    })();
    view = "(function(w){\n  if(!w.boxCssCache){\n    w.boxCssCache = {};\n  }\n  var i, x, css = " + (JSON.stringify(excss)) + ";\n  for(i=0; i<css.length; i++){\n    if(!w.boxCssCache[css[i]]){\n      $('head').append('<link href=\"" + (ispreview ? config.excsspath : config.outcsspath) + "'+ css[i] +'.css\" rel=\"stylesheet\">');\n      w.boxCssCache[css[i]] = 1;\n    }\n  }\n  if(!w.boxCssCache['" + rid + "']){\n    $('head').append('<style>" + (icss.replace(/'/g, "\\'")) + "</style>');\n    w.boxCssCache['" + rid + "'] = 2;\n  }\n}).call(this,window);";
    return view.replace(/\s*\/\/[^\n\r]*[\r\n]?/mg, "\n").replace(/\s*[\r\n]+\s*/mg, '').replace(/^\s+|\s+$/g, '');
  };

  getHtmlJs = function(rid, ijs, iexjs, ispreview) {
    var view;
    view = "(function(window, $, jQuery){\nvar console = window.console || {log: function(){}},\ndom, box, boxfuns = {}, seriesGetData, doSetData, queue;\n//全局接口的入口，查找当前的dom得到id号进行调用，这样可以避免全局污染\nwindow[\"box" + rid + "\"] = function(dt, callback){\n  if(!dom || !doSetData){\n    //简单起见，这里只保存最新的一个调用值\n    queue = [dt, callback];\n    return;\n  }\n  if($.isFunction(dt)){\n    callback = dt;\n    //在这里先调用validate的方法进行表单验证\n    if(dom.valid && !dom.valid()){\n      return callback(\"valid failed.\");\n    }\n    seriesGetData(dom, function(err, dt){\n      callback(err, dt);\n    });\n  }else{\n    //设置新的表单数据\n    doSetData(dt, dom, callback);\n  }\n};\nasync.forEachOfSeries(" + (JSON.stringify(iexjs)) + ", function(item, key, callback){\n  try{\n    if(eval(item)){\n      $.ajax(\"" + (ispreview ? config.exjspath : config.outjspath) + "\"+key+\".js\",{\n        contentType: 'text/plain',\n        dataType:'text',\n        mimeType: 'text/plain',\n        cache:true,\n        success:function(dt){\n          var tdef = window.define;\n          //暂时取消define\n          window.define = null;\n          var spt = document.createElement('script');\n          spt.innerHTML = dt;\n          $('head').append(spt);\n          window.define = tdef;\n          callback(0);\n        },\n        error: function(xhr, ts, ex){\n          callback(ex);\n        }\n      });\n    }else{\n      callback(0);\n    }\n  }catch(ex){\n    callback(ex);\n  }\n}, function(err){\n  dom = $(\"#box" + rid + "\"),\n  //所有的插件需要调用的方法都放在这里，请用push的方法实现\n  //考虑到有一些需求可能需要用到异步请求，所以所有的调用都异步调用\n  box = {};\n  if(dom.validate){\n    dom.validate({\n      debug:true,\n      showErrors: function(errorMap, errorList) {\n        $.each(this.validElements(), function (index, element) {\n            var $element = $(element);\n            $element.data(\"title\", \"\") // Clear the title - there is no error associated anymore\n                .removeClass(\"error\")\n                .tooltip(\"destroy\");\n        });\n        $.each(errorList, function (index, error) {\n            var $element = $(error.element);\n            $element.tooltip(\"destroy\") // Destroy any pre-existing tooltip so we can repopulate with new tooltip content\n                .data(\"title\", error.message)\n                .addClass(\"error\")\n                .tooltip(); // Create a new tooltip based on the error messsage we just set in the title\n        });\n      }\n    });\n  }else{\n    console.log(\"plugin validate not found. ignore it.\");\n  }\n  " + ijs + "\n  //进行dom初始化\n  boxfuns.initdom = function(domx){\n    var allbox = domx.find(\"[boxclass]\");\n    allbox.each(function(){\n      var t = $(this);\n      var cls = t.attr('boxclass');\n      if(box[cls] && box[cls].initdom){\n        box[cls].initdom(t, dom, box, boxfuns); //把box传过去是为了有继承关系的类，因为派生而需要调基类的方法\n      }\n    });\n  };\n  boxfuns.initdom(dom);\n  //遍历整个dom，并得到验证之后的数据，如果有错误的话就提示错误\n  boxfuns.getValue = seriesGetData = function(dom, callback){\n    var nix = {}, nos = {}, out = {}, rootdom = dom;\n    var allbox = dom.find(\"[boxname]:visible\");\n    async.eachSeries(allbox, function(t, callback){\n      t = $(t);\n      var cls = t.attr('boxclass');\n      var name = t.attr('boxname');\n      var extend = $.parseJSON(Base64.decode(t.attr('boxextend')));\n      //把得到的数据值填充到输出的对象中\n      var setval = function(v){\n        var parentNode = t.parent().closest(\"[boxname]\");\n        if(parentNode[0] == rootdom[0]){\n          parentNode = []; //针对只得到部分的dom片段\n        }\n        if($.isArray(v)){\n          if(v.length > 0){\n            //如果有值说明插件内部已经自己处理了，这里框架就不用关心了\n            //这里只处理没有值的情况\n            extend.value = v;\n            out[name] = extend;\n            return;\n          }\n          //因dom的结构和接口定义的结构不一样，遍历起来真的好麻烦\n          if(!nix[name]){\n            t.parent().children('[boxname='+ name +']').each(function(){\n              var t = $(this);\n              if(nix[name]){\n                nix[name]++;\n              }else{\n                nix[name] = 1;\n              }\n              t.attr(\"boxinx\", nix[name]); //作一个索引的标记\n              if(!nos[name]){\n                extend.value = [{}];\n                nos[name] = extend;\n              }else{\n                nos[name].value[nix[name]-1] = {}; //先造好容器\n              }\n            });\n            if(parentNode[0]){\n              var inx = parseInt(parentNode.attr('boxinx'))-1;\n              nos[parentNode.attr('boxname')].value[inx][name] = nos[name];\n            }else{\n              out[name] = nos[name];\n            }\n          }\n          return;\n        }\n\n        extend.value = v;\n        //查找应该放到哪个位置\n        if(parentNode[0]){\n          var inx = parseInt(parentNode.attr('boxinx'))-1;\n          nos[parentNode.attr('boxname')].value[inx][name] = extend;\n        }else{\n          out[name] = extend;\n        }\n      };\n      if(box[cls] && box[cls].getValue){\n        box[cls].getValue(t, function(err, v){\n          if(err){\n            return callback(err);\n          }\n          setval(v);\n          callback(0);\n        });\n      }else{\n        if(t.find('div.column')[0]){\n          setval([]);\n        }else{\n          console.log(\"Can't find box: \"+ cls);\n          setval('');\n        }\n        callback(0);\n      }\n    }, function(err){\n      callback(err, out);\n    });\n  };\n  var valueToHtml = function(o, v, callback){\n    var boxclass = o.attr(\"boxclass\");\n    if(box[boxclass] && box[boxclass].setValue){\n      box[boxclass].setValue(o, v, callback);\n    }else{\n      console.log(\"INFO: box \"+ boxclass + \" or box.setValue no found, ignore it.\");\n      callback(0);\n    }\n  };\n  //这里采用多重循环dom，效率方面可能有点低，因一般情况下dom的查询并不多，暂时还看不到性能的瓶颈\n  boxfuns.setValue = doSetData = function(dt, dom, callback){\n    // Clear errer status\n    dom.find(\".error\").data(\"title\", \"\").removeClass(\"error\").tooltip(\"destroy\");\n    async.eachOfSeries(dt, function(item, key, callback){\n      var o = dom.find(\"[boxname=\"+ key +\"]\");\n      if(o[0]){\n        var value = item.value;\n        if($.isArray(value)){\n          // 如果是数组的话说明是有多组的，再进行遍历\n          valueToHtml($(o[0]), value, function(err){\n            //重新获取新的列表，因为可能已经更新\n            var os = o.parent().children(\"[boxname=\"+ key +\"]\");\n            async.eachOfSeries(value, function(item, key, callback){\n              if(os[key]){\n                doSetData(item, $(os[key]), callback);\n              }else{\n                //如果不存在将忽略\n                console.log(\"ignore \"+ key);\n                callback(0);\n              }\n            }, callback);\n          });\n        }else{\n          valueToHtml(o, value, callback);\n        }\n      }else{\n        console.log(\"Ignore box: \" + key);\n        callback(0);\n      }\n    }, callback);\n  };\n  //查找执行事件\n  if(queue) {\n    window[\"box" + rid + "\"](queue[0], queue[1]);\n    queue = null;\n  }\n});\n}).call(this, window, window.jQuery, window.jQuery);";
    return view.replace(/\s*\/\/[^\n\r]*[\r\n]?/mg, "\n").replace(/\s*[\r\n]+\s*/mg, '').replace(/^\s+|\s+$/g, '');
  };

  setTitle = function(env) {
    return document.title = (env.formName ? env.formName + " - " : "[未命名] - ") + "Box";
  };

  makeHtml = function(env, ispreview, callback) {
    var rid;
    rid = Math.round(Math.random() * 10000);
    return async.waterfall([
      function(callback) {
        return async.series({
          css: function(callback) {
            return toCss(env, callback);
          },
          js: function(callback) {
            return toJs(env, callback);
          },
          excss: function(callback) {
            return toExcss(env, callback);
          },
          exjs: function(callback) {
            return toExjs(env, callback);
          }
        }, callback);
      }, function(cj, callback) {
        return toHtml(env, function(err, html) {
          var out;
          if (ispreview) {
            out = "<html><head>\n  <meta charset=\"utf-8\">\n  <style>html,body{padding:0;margin:0;}div.layout{padding:40px 10px 20px 10px}</style>\n  <script src=\"" + config.exjspath + "jquery.min.js\"></script>\n  <script src=\"" + config.exjspath + "async.js\"></script>\n</head><body>\n  <script>" + (getHtmlCss(rid, cj.css, cj.excss, ispreview)) + "</script>\n  <div class=\"layout\"><form class=\"boxview\" id=\"box" + rid + "\">" + html + "</form></div>\n  <script>" + (getHtmlJs(rid, cj.js, cj.exjs, ispreview)) + "</script>\n</body></html>";
            out = out.replace(/\s*[\r\n]+\s*/mg, '').replace(/^\s+|\s+$/g, '');
          } else {
            out = JSON.stringify([getHtmlCss(rid, cj.css, cj.excss, ispreview), "<form class=\"boxview\" id=\"box" + rid + "\">" + html + "</form>", getHtmlJs(rid, cj.js, cj.exjs, ispreview)]);
          }
          return callback(err, out, rid);
        });
      }
    ], callback);
  };

  loadForm = function(env, callback) {
    return $.post(config.rooturl + "/itsm/request/getFormSerializationByFormIdAndVersion.spr", {
      formId: env.formId,
      formVersion: env.formVersion
    }, function(result) {
      if (result != null ? result.retCode : void 0) {
        $.notify(result.retDetail, "error");
        callback(result.redCode, result);
        return;
      }
      return jsonToDom(JSON.parse(result.data.formSerialization), env, function(err) {
        if (err) {
          $.notify(err, 'error');
          return callback(err);
        }
        return callback(err, result.data);
      });
    }, 'json');
  };

  act = {
    list: function(e, env) {
      var domModal;
      domModal = $("#formList");
      return $.post(config.rooturl + "/itsm/request/getFormListEditByUser.spr", null, function(result) {
        var form, j, k, l, len, len1, len2, len3, m, out, ref, ref1, ref2, ref3, ref4, ref5, ref6, teamField, teamList, version;
        if (result.retCode) {
          return $.notify(result.retDetail, "error");
        }
        out = ["<div class=\"tree\"><ul>"];
        ref = result.data;
        for (j = 0, len = ref.length; j < len; j++) {
          teamField = ref[j];
          out.push("<li teamFieldId=\"" + teamField.teamFieldId + "\"><span><i class=\"glyphicon glyphicon-tasks\"></i> " + teamField.teamFieldName + "</span>");
          if ((ref1 = teamField.teamList) != null ? ref1[0] : void 0) {
            out.push("<ul>");
            ref2 = teamField.teamList;
            for (k = 0, len1 = ref2.length; k < len1; k++) {
              teamList = ref2[k];
              out.push("<li teamId=\"" + teamList.teamId + "\"><span><i class=\"glyphicon glyphicon-minus\"></i> " + teamList.teamName + "</span>");
              if ((ref3 = teamList.formList) != null ? ref3[0] : void 0) {
                out.push("<ul>");
                ref4 = teamList.formList;
                for (l = 0, len2 = ref4.length; l < len2; l++) {
                  form = ref4[l];
                  out.push("<li formId=\"" + form.formId + "\"><span><i class=\"glyphicon glyphicon-minus\"></i> " + form.formName + "</span>");
                  if ((ref5 = form.formVersionList) != null ? ref5[0] : void 0) {
                    out.push("<ul><li>");
                    ref6 = form.formVersionList;
                    for (m = 0, len3 = ref6.length; m < len3; m++) {
                      version = ref6[m];
                      out.push("<span class=\"vn\" version=\"" + version + "\"><i class=\"glyphicon glyphicon-tag\"></i> " + version + "</span>");
                    }
                    out.push("</li></ul>");
                  }
                  out.push("</li>");
                }
                out.push("</ul>");
              }
              out.push("</li>");
            }
            out.push("</ul>");
          }
          out.push("</li>");
        }
        out.push("</ul></div>");
        domModal.modal('show');
        domModal.find("div.modal-body").css("height", domModal.height() - 200).html(out.join(""));
        domModal.find('.tree li:has(ul)').addClass('parent_li').find(' > span').attr('title', 'Collapse this branch');
        domModal.find('.tree li.parent_li > span').click(function(e) {
          var children;
          e.stopPropagation();
          children = $(this).parent('li.parent_li').find(' > ul > li');
          if (children.is(':visible')) {
            children.hide('fast');
            $(this).attr('title', 'Expand this branch').find(' > i').addClass('glyphicon-plus').removeClass('glyphicon-minus');
          } else {
            children.show('fast');
            $(this).attr('title', 'Collapse this branch').find(' > i').addClass('glyphicon-minus').removeClass('glyphicon-plus');
          }
        });
        return domModal.find(".tree .vn").click(function(e) {
          domModal.find(".tree .vn").removeClass("active");
          return $(this).addClass("active");
        }).dblclick(function(e) {
          return domModal.find("[act=loadform]").trigger("click");
        });
      }, 'json');
    },
    preview: function(e, env) {
      return makeHtml(env, 1, function(err, html, rid) {
        var box, error1, im, j, len, md, ref;
        md = $("#previewModal");
        md.modal('show');
        im = $("<iframe frameborder=\"0\" height=\"" + (md.height() - 200) + "\" width=\"100%\"></iframe>");
        md.find("div.modal-body").empty().append(im);
        im[0].contentDocument.open();
        im[0].contentDocument.write(html);
        im[0].contentDocument.close();
        ref = env.rootcolumn.find("div.box[objinx]");
        for (j = 0, len = ref.length; j < len; j++) {
          box = ref[j];
          try {
            $(box).children("span.boxname").html(env.domobject[box.getAttribute("objinx")].name);
          } catch (error1) {

          }
        }
        window.boxViewtype = function() {
          return im[0].contentWindow["box" + rid](function(err, dt) {
            if (err) {
              $.notify("出错啦，可能验证没有通过");
              return;
            }
            env.formData = dt;
            console.log(dt);
            return $.notify("已经在控制台上打印了结果", "success");
          });
        };
        return window.restoreDataFun = function() {
          if (!env.formData) {
            return $.notify("请先点击“查看数据”获取数据");
          }
          return im[0].contentWindow["box" + rid](env.formData, function(err) {
            if (err) {
              console.log(err);
              return $.notify("恢复数据失败");
            } else {
              return $.notify("恢复数据成功", "success");
            }
          });
        };
      });
    },
    viewtype: function(e, env) {
      return window.boxViewtype();
    },
    restoreData: function(e, env) {
      return window.restoreDataFun();
    },
    save: function(e, env, opt) {
      var saveit, type;
      type = opt[1];
      if (!type) {
        type = 'newForm';
      }
      if (type === 'updateVersion' && (!env.formId || !env.formVersion)) {
        type = 'newForm';
      }
      if (type === 'newVersion' && !env.formId) {
        type = 'newForm';
      }
      saveit = function() {
        return domToStruct(env, function(err, dt) {
          if (err) {
            return console.log(err);
          }
          return $.post(config.rooturl + "/itsm/request/insertFormDataStructure.spr", {
            formDataStructure: JSON.stringify(dt),
            formId: env.formId,
            formName: env.formName,
            formVersion: env.formVersion,
            teamId: env.teamId,
            type: type
          }, function(dt) {
            if (dt != null ? dt.retCode : void 0) {
              return console.log(dt.retDetail);
            }
            dt = dt.data;
            if (dt.formId) {
              env.formId = dt.formId;
            }
            if (dt.formVersion) {
              env.formVersion = dt.formVersion;
            }
            return structToDom(dt.dataStructureJson, env, function(err) {
              if (err) {
                return console.log(err);
              }
              return domToJson(env, function(err, json) {
                if (err) {
                  return console.log(err);
                }
                return $.post(config.rooturl + "/itsm/request/updateFormSerialization.spr", {
                  formSerialization: JSON.stringify(json),
                  formId: env.formId,
                  formVersion: env.formVersion
                }, function(result) {
                  if (dt != null ? dt.retCode : void 0) {
                    return console.log(dt.retDetail);
                  }
                  return makeHtml(env, 0, function(err, html) {
                    if (err) {
                      return console.log(err);
                    }
                    return $.post(config.rooturl + "/itsm/request/updateFormHtml.spr", {
                      formHtml: html,
                      formId: env.formId,
                      formVersion: env.formVersion
                    }, function(result) {
                      if (!result.retCode) {
                        $.notify("保存成功", 'success');
                      }
                      return console.log(result, env, "Save End");
                    }, 'json');
                  });
                }, 'json');
              });
            });
          }, 'json');
        });
      };
      if (!env.formName || type === 'newForm') {
        return $.post(config.rooturl + "/itsm/request/getFormListEditByUser.spr", function(result) {
          var form, j, k, len, len1, nameForm, ref, ref1, sel, team, teamList, teamfield;
          if (result.retCode) {
            return $.notify(result.retDetail);
          }
          teamList = [];
          ref = result.data;
          for (j = 0, len = ref.length; j < len; j++) {
            teamfield = ref[j];
            teamList.push("<optgroup label=\"" + teamfield.teamFieldName + "\">");
            ref1 = teamfield.teamList;
            for (k = 0, len1 = ref1.length; k < len1; k++) {
              team = ref1[k];
              sel = team.teamId === env.teamId ? " selected" : "";
              teamList.push("<option value=\"" + team.teamId + "\"" + sel + ">" + team.teamName + "</option>");
            }
            teamList.push("</optgroup>");
          }
          nameForm = $("#formName");
          form = nameForm.find('form');
          form.find("input:text").val(env.formName);
          form.resetForm();
          form.find("select").html(teamList.join(""));
          nameForm.modal('show');
          return form.unbind('submit').submit(function(e) {
            e.preventDefault();
            if (form.valid()) {
              env.formName = form.find("input:text").val();
              env.teamId = form.find("select").val();
              nameForm.modal('hide');
              setTitle(env);
              return saveit();
            }
          });
        });
      } else {
        return saveit();
      }
    },
    loadform: function(e, env) {
      var modal, verdom;
      modal = $("#formList");
      verdom = modal.find(".tree span.active");
      if (!verdom[0]) {
        return $.notify("请选择表单", "error");
      }
      env.formVersion = verdom.attr("version");
      env.formId = verdom.closest("[formid]").attr("formid");
      env.teamId = verdom.closest("[teamid]").attr("teamid");
      loadForm(env, function(err, dt) {
        if (err) {
          return err;
        }
        env.formName = dt.formName;
        return setTitle(env);
      });
      return modal.modal('hide');
    },
    jsonData: function(e, env) {
      return domToJson(env, function(err, json) {
        if (err) {
          $.notify("数据错误");
          return console.log(err);
        } else {
          console.log(JSON.stringify(json));
          return $.notify("已经在控制台打印了结果", "success");
        }
      });
    }
  };

  dofocus = function(t, env) {
    var infoview, inx, objinx;
    objinx = t.attr("objinx");
    if (env.domobject[objinx]) {
      if (env.focusBox) {
        inx = env.focusBox.attr("objinx");
        if (inx === objinx) {
          return;
        }
        infoview = $("div.pubinfo>.infoview");
        env.domobject[inx].removePropertyView(infoview, env.focusBox);
        env.focusBox.removeClass("boxactive");
      }
      env.focusBox = t;
      infoview = $("<div class=\"infoview\"></div>");
      $("div.pubinfo").empty().append(infoview);
      env.domobject[objinx].updatePropertyView(infoview, t);
      return t.addClass("boxactive");
    }
  };

  $(function() {
    var formId, formVersion, rootcolumn, sidebar;
    sidebar = $('div.sidebar-nav').html(initmenu());
    sidebar.find("li.boxes:first").show();
    sidebar.find('li.nav-header').click(function() {
      sidebar.find("li.boxes").hide();
      return $(this).next().slideDown();
    });
    dragit(sidebar.find('div.box'));
    rootcolumn = $('div.column');
    env.rootcolumn = rootcolumn;
    sortit(rootcolumn);
    formId = getUrlParam('formId');
    formVersion = getUrlParam('formVersion');
    if (formId && formVersion) {
      env.formId = formId;
      env.formVersion = formVersion;
      loadForm(env, function(err, dt) {
        if (err) {
          return err;
        }
        env.formName = dt.formName;
        return setTitle(env);
      });
    } else {
      jsonToDom([
        ["DynamicLayout", "dynamiclayout", [["Input", "input"]]], [
          "TabLayout", [
            "tablayout", {
              "tabs": [["a", ""], ["b", ""], ["c", ""]],
              "focus": 1
            }
          ], [["Input", "input1"]], null, [["Input", "input2"]]
        ]
      ], env, function(err) {});
      setTitle(env);
    }
    rootcolumn.mousedown(function(e) {
      var infoview, inx, ref, t;
      t = $(e.target).closest(".box[objinx]");
      if (t[0]) {
        dofocus(t, env);
        return;
      }
      if (env.focusBox) {
        inx = env.focusBox.attr('objinx');
        infoview = $("div.pubinfo>.infoview");
        if ((ref = env.domobject[inx]) != null) {
          ref.removePropertyView(infoview, env.focusBox);
        }
        env.focusBox.removeClass("boxactive");
        env.focusBox = null;
        $("div.pubinfo").empty();
      }
    });
    $('.modal form').each(function() {
      return $(this).validate({
        debug: true,
        showErrors: function(errorMap, errorList) {
          $.each(this.validElements(), function(index, element) {
            $(element).data("title", '').removeClass('error').tooltip('destroy');
          });
          return $.each(errorList, function(index, error) {
            $(error.element).tooltip("destroy").data("title", error.message).addClass("error").tooltip();
          });
        }
      });
    });
    rootcolumn.delegate(".remove", "click", function(e) {
      var infoview, inx, objinx, t;
      e.preventDefault();
      t = $(this).parent();
      objinx = t.attr('objinx');
      if (env.focusBox && env.focusBox[0] === t[0]) {
        inx = env.focusBox.attr("objinx");
        infoview = $("div.pubinfo>.infoview");
        env.domobject[inx].removePropertyView(infoview, env.focusBox);
        env.focusBox = null;
        $("div.pubinfo").empty();
      }
      env.domobject[objinx].beforeRemove(t);
      t.remove();
      return delete env.domobject[objinx];
    });
    rootcolumn.delegate(".boxname", "click", function(e) {
      var box, ct, form, o, objinx, t;
      e.preventDefault();
      ct = $(this);
      t = ct.parent();
      objinx = t.attr('objinx');
      o = env.domobject[objinx];
      box = $("#boxName");
      form = box.find('form');
      form.find("input:text").val(o.name);
      form.resetForm();
      box.modal('show');
      return form.unbind('submit').submit(function(e) {
        var name;
        e.preventDefault();
        if (form.valid()) {
          name = form.find("input:text").val();
          box.modal('hide');
          console.log(name);
          o.setName(name);
          return ct.html(name);
        }
      });
    });
    return $('ul.nav,div.modal').delegate('[act]', 'click', function(e) {
      var at, name1, t;
      e.preventDefault();
      t = $(e.target).closest('[act]');
      at = t.attr('act').split('|');
      return typeof act[name1 = at[0]] === "function" ? act[name1](e, env, at) : void 0;
    });
  });

}).call(this);