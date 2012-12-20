// ws
// 功能 ： 根据parterNr搜索关系零件
// 参数 ：
//  - string : partnerNr
// - string : partNr
// - int : pageIndex
// 返回 ：
// - 无
function flash_message(obj, times) {
     var i = 0, t = false, times = times || 4;
     if(t)
          return;
     t = setInterval(function() {
          i++;
          if(i % 2 == 0) {
               $(obj).hide();
          } else {
               $(obj).show();
          }
          if(i == times * 2) {
               clearInterval(t);
          }
     }, 300);
}

// ws
// 功能 ： 根据parterNr搜索关系零件
// 参数 ：
//  - string : partnerNr
// - string : partNr
// - int : pageIndex
// 返回 ：
// - 无
function get_partRels_by_parterNr_partNr(pageIndex) {
     var partnerNr = document.getElementById('client-search-text').value;
     if(partnerNr == "") {
          flash_message(".errparts");
     } else {
          $.ajax({
               url : '../part/get_partRels',
               type : 'post',
               dataType : 'html',
               data : {
                    partnerNr : partnerNr,
                    partNr : document.getElementById('part-search-text').value,
                    pageIndex : pageIndex
               },
               success : function(data) {
                    $('.tableviewparts').html(data);
               }
          });
     }
}

// ws
// 功能 ： 检查用户运单缓存，有则加载之
// 参数 ：
// - 无
// 返回 ：
// - 无
function check_staff_dn_cache() {
     $.ajax({
          url : '../delivery/get_dit_dn_cache',
          dataType : 'json',
          type : 'post',
          success : function(cache) {
               // show dn
               if(cache.dn != null) {
                    var pane = $("#staff-dn-cache-link");
                    var linker, del;
                    $.each(cache.dn, function(i, v) {
                         // var link=
                         linker = $("<div/>").html("<a href='../delivery/view_pend_dn?dnKey=" + v.key + "'>" + v.key + "</a>");
                         del = $("<div/>").attr('class', 'deleteparts').attr('id', v.key).attr('title', '取消').css('cursor', 'pointer').html('X');
                         del.appendTo(linker);
                         linker.appendTo(pane);
                         del.bind('click', {
                              dnKey : del.attr('id')
                         }, function(e) {
                              if(delete_dn_from_staff(e.data.dnKey)) {
                                   var p = $("[id='" + e.data.dnKey + "']").parent();
                                   p.fadeOut("slow", function() {
                                        p.remove();
                                        p = null;
                                        if($("#staff-dn-cache-link").children().size() == 0) {
                                             $("#staff-dn-cache-content").hide();
                                        }
                                   });
                              }
                         });
                    });
                    $("#staff-dn-cache-content").show();
               }
               // show dit
               if(cache.dit != null) {
                    $.each(cache.dit, function(i, t) {
                         $("#build-dn-btn").show();
                         add_dit_to_cart(t.spartNr, t.perPackAmount, t.packAmount, t.total, t.key);
                    });
               }
          }
     });
}

// ws
// 功能 ： 取消用户运单
// 参数 ：
// - string : dnKey
// 返回 ：
// - 无
function delete_dn_from_staff(dnKey) {
     var result = false;
     if(confirm('确定取消？')) {
          $.ajax({
               url : '../delivery/cancel_staff_dn',
               data : {
                    dnKey : dnKey
               },
               dataType : 'json',
               type : 'post',
               async : false,
               success : function(data) {
                    if(!data.result) {
                         alert(data.content);
                    }
                    result = data.result;
               }
          });
     }
     return result;
}

// ws
// 功能 ： 添加包装数据--弹出填写框
// 参数 ：
// - string : metaKey
// 返回 ：
// - 无
function add_pack_info(e, metaKey) {
     $('#selected-spart-nr').html($(e).parent().prevAll('.spartNr').html());
     $('#selected-part-rel-key').val(metaKey);
}

// ws
// 功能 ：将选中零件加入 cart
// 参数 ：
// - 无
// 返回 ：
// - 无
function add_part_to_cart() {
     var per = $("#selected-part-perpack").val();
     var packN = $("#selected-part-pack-num").val();
     var partNr = $("#selected-spart-nr").html();
     if(!isPositiveNum(per)) {
          alert('每包装箱量必须为正数！');
          return;
     }
     if(!isPositiveInt(packN)) {
          alert('包装箱数必须为正整数！');
          return;
     }
     $.ajax({
          url : '../delivery/add_di_temp',
          dataType : 'json',
          data : {
               metaKey : $("#selected-part-rel-key").val(),
               packAmount : packN,
               perPackAmount : per
          },
          type : 'post',
          success : function(msg) {
               if(msg.result) {
                    var t = msg.object;
                    add_dit_to_cart(partNr, t.perPackAmount, t.packAmount, t.total, t.key);
               }
          }
     });
}

// ws
// 功能 ： 将运单项加入购物车
// 参数 ：
// - string : partNr
// - int : per
// - int : amount
// - int : total
// - string : mkey
// 返回 ：
// - 无
function add_dit_to_cart(partNr, per, amount, total, key) {
     if($("#build-dn-btn").is(":hidden")) {
          $("#build-dn-btn").show();
     }
     var cart = $('#unfoldcart');
     var cartSize = cart.children('.cfirstlevel').size();
     // alert(cartSize);
     var lineclass = cartSize % 2 == 0 ? 'cartline cfirstlevel' : 'oddcartline cfirstlevel';
     var line = $("<div/>").attr('class', lineclass).html("<div class='partserialnmb'>" + (cartSize + 1) + "</div><div class='partscart'>" + partNr + "</div>" + "<div class='partscart'>" + per + "&nbsp;X&nbsp;" + amount + "&nbsp;=&nbsp;" + total + "</div>");
     var del = $("<div/>").attr('class', 'deleteparts').attr('id', key).css('cursor', 'pointer').html('X');
     // <div class='deleteparts' style='cursor:pointer;' id='"+mkey+"'>X</div>
     del.appendTo(line);
     line.appendTo(cart);
     del.bind('click', {
          id : del.attr('id')
     }, function(e) {
          delete_dit_from_cart(e.data.id);
     });
     line = null;
     del = null;
}

// ws
// 功能 ： 将包装从cart中移除
// 参数 ：
// - string : key
// 返回 ：
// - 无
function delete_dit_from_cart(key) {
     $.ajax({
          url : '../delivery/delete_dit',
          type : 'post',
          dataType : 'json',
          data : {
               tempKey : key
          },
          success : function(data) {
               if(data.result) {
                    var p = $("[id='" + key + "']").parent();
                    // reset cart item no
                    var nexts = p.nextAll();
                    var no = null;
                    var ele = null;
                    $.each(nexts, function(i, n) {
                         ele = $(n).find(".partserialnmb");
                         no = parseInt(ele.text() - 1);
                         ele.html(no);
                         $(n).attr('class', (no + 1) % 2 == 0 ? 'cartline cfirstlevel' : 'oddcartline cfirstlevel')
                    });
                    no = null;
                    ele = null;
                    nexts = null;
                    //.....
                    if(p.parent().children().size() == 1) {
                         $("#build-dn-btn").hide();
                    }
                    p.effect("shake", {
                         times : 1,
                         distance : 30
                    }, 500);
                    p.fadeOut("slow", function() {
                         p.remove();
                         p = null;
                    });
               }
          }
     });
}

// ws
// 功能 ： 生成运单
// 参数 ：
//  - 无
// 返回 ：
// - 无
function build_delivery_note() {
     var desiOrgNr = document.getElementById('client-search-text').value;
     if(desiOrgNr == "") {
          flash_message(".errparts");
          alert("请先填写正确的客户号");
          return;
     }
     show_handle_dialog();
     $.ajax({
          url : '../delivery/build_dn',
          type : 'post',
          dataType : 'json',
          data : {
               desiOrgNr : desiOrgNr
          },
          success : function(data) {
               if(data.result) {
                    window.location = "../delivery/view_pend_dn?dnKey=" + data.object;
               } else {
                    alert(data.content);
               }
          }
     });
}

// ws
// 功能 ： 根据运单号获得运单内容
// 参数 ：
//  - string : dnKey
// - int : pageIndex
// 返回 ：
// - 无
function get_dn_detail(pageIndex) {
     $.ajax({
          url : '../delivery/view_pend_dn',
          type : 'post',
          dataType : 'html',
          data : {
               dnKey : $('#dnkey-hidden').val(),
               pageIndex : pageIndex
          },
          success : function(data) {
               $('#delivery-items-div').html(data);
          }
     });
}

// ws
// 功能 ： 发送运单
// 参数 ：
//  - object : 发送按钮
// 返回 ：
// - 无
function send_staff_dn(ele) {
     var desi = $("#destination-text").val();
     if(desi == "") {
          flash_message(".errparts");
     } else {
          show_handle_dialog();
          $.ajax({
               url : '../delivery/send_delivery',
               type : 'post',
               dataType : 'json',
               async : false,
               data : {
                    dnKey : $('#dnkey-hidden').val(),
                    destiStr : desi
               },
               success : function(data) {
                    if(data.result) {
                         $(ele).unbind('click').removeAttr('onclick').bind('click', function() {
                              alert('运单已经发送成功，不可重复发送');
                         });
                         $('#cancelDeliverySendBtn').unbind('click').removeAttr('onclick').bind('click', function() {
                              alert('已经发送成功，不可取消');
                         });
                    }
                    hide_handle_dialog();
                    alert(data.content);
               }
          });

     }
}

// ws
// 功能 ： 取消用户运单
// 参数 ：
//  - 无
// 返回 ：
// - 无
function cancel_staff_dn() {
     if(delete_dn_from_staff($('#dnkey-hidden').val())) {
          window.location = "../delivery/pick_part";
     }
}

/******** dn list ****************/
function dn_list_ready() {
     $('.textsearchbox').keypress(function(event) {
          if(event.which == 13)
               $(this).find('input.startsearch').click()
     }).hover(function() {
          $(this).children().unbind('blur');
     }, function() {
          $(this).children().blur(function() {
               pop_cancel(this);
          });
     });
     // auto complete
     $('#dn-search-text').autocomplete({
          source : "/delivery/redis_search_dn"
     });
     $('#client-search-text').autocomplete({
          source : "../organisation_manager/redis_search"
     });
     $('#supplier-search-text').autocomplete({
     source : "../organisation_manager/redis_search"
     });
     // dn way state and obj state
     $(".wayState[wayState='ALL']").click(function() {
          $('.search_label').children().remove().end().hide();
          search_dn();
     });
     // dn way state and obj state
     $(".wayState").not("[wayState='ALL']").click(function(e) {
          add_condition_node({
               wayState : {
                    key : $(this).attr('wayState'),
                    value : $(this).text()
               }
          });
     });
     $(".objState").click(function(e) {
          add_condition_node({
               objState : {
                    key : $(this).attr('objState'),
                    value : $(this).text()
               }
          });
     });

     // search box
     $("#dn-search-box>input.startsearch").click(function() {
          add_condition_node({
               dnKey : $("#dn-search-text").val()
          });
     });

     $("#rece-search-box>input.startsearch").click(function() {
          add_condition_node({
               receiver : $("#client-search-text").val()
          });
     });

     $("#sender-search-box>input.startsearch").click(function() {
          add_condition_node({
               sender : $("#supplier-search-text").val()
          });
     });

     $("#date-search-box>input.startsearch").click(function() {
          add_condition_node({
               date : [$("#startdate-search-text").val(), $("#enddate-search-text").val()]
          });
     });

     check_org_kn_queue();
     search_dn();
}

function add_condition_node(hash) {
     $.each(hash, function(k, v) {
          var kv = null;
          if( typeof (v) == 'string' || v.constructor == Array) {
               kv = v;
          } else {
               kv = v["key"]
          }
          if($("#label_" + k).children("[" + k + "='" + kv + "']").size() == 0) {
               if( typeof (v) == 'string')
                    $('<span class="notifyNewForcast"></span>').attr('key', k).attr(k, v).text(v).appendTo($('#label_' + k)).click(function() {
                         del_condition_node(k, v);
                    });
               else if(v.constructor == Array) {
                    $("#label_" + k).children().remove();
                    $('<span class="notifyNewForcast"></span>').attr('key', k).attr('value-type', 'array').attr(k, v).text(v[0] + '~' + v[1]).appendTo($('#label_' + k)).click(function() {
                         del_condition_node(k, v);
                    });
               } else {
                    $('<span class="notifyNewForcast"></span>').attr('key', k).attr(k, v["key"]).text(v["value"]).appendTo($('#label_' + k)).click(function() {
                         del_condition_node(k, v["key"]);
                    });
               }
               $('#label_' + k).show();
               search_dynamic();
          }
     });
}

function del_condition_node(k, v) {
     $("#label_" + k).children("[" + k + "=" + v + "]").remove();
     if($("#label_" + k).children().size() == 0) {
          $('#label_' + k).hide();
     }
     search_dynamic();
}

function check_org_kn_queue() {
     $.post('../delivery/count_dn_queue', function(data) {
          if(data.count > 0) {
               $('<span class="notifyNewForcast"></span>').text(data.count).appendTo($("div[wayState='ALL']")).click(function(e) {
                    $('.search_label').children().remove().end().hide();
                    search_dn({
                         queue : true
                    });
                    e.stopPropagation();
               }).dblclick(function(e) {
                    clear_org_kn_queue();
                    search_dn();
                    e.stopPropagation();
               });
          }
     }, 'json');
}

function clear_org_kn_queue() {
     $.post('../delivery/clean_dn_queue', function(data) {
          if(data.result) {
               $('.notifyNewForcast').remove();
          }
     }, 'json');
}

function search_dn(condition, pageIndex) {
     if(condition == null)
          condition = {};
     if(pageIndex == null)
          pageIndex = 0;
     $.ajax({
          url : '../delivery/search_dn',
          type : 'post',
          data : {
               condition : condition,
               pageIndex : pageIndex
          },
          dataType : 'html',
          success : function(data) {
               $("#dn-list-div").html(data);
          }
     });
}

function search_dynamic() {
     var condition = {};
     $(".search_label").children().each(function() {
          var t = $(this);
          var key = t.attr('key');
          if(condition[key] == null)
               condition[key] = [];
          if(t.attr('value-type') == 'array')
               condition[key].push(t.attr(key).split(','));
          else
               condition[key].push(t.attr(key));
     });
     search_dn(condition);
}

function pop_box(e) {
     var id = e.attributes['box'].nodeValue;
     $('#' + id).css({
          top : $(e).offset().top + $(e).height(),
          left : $(e).offset().left + $(e).width()
     }).show().find("input").get(0).focus();
}

function pop_cancel(e) {
     $(e).parent().hide();
}
