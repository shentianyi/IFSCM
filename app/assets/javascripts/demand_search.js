///////////////////////////////////////////////////////////////////     UI
function pop(e) {
     var id = e.attributes['link'].nodeValue;
     $('#' + id).css({
          top : $(e).offset().top + $(e).height(),
          left : $(e).offset().left + $(e).width()
     }).show().find("input").get(0).focus();
}

function pop_cancel(e) {
     $(e).parent().hide();
     $(e).parent().find('input[placeholder]').val("");
}

function chartview_cancel() {
     $('.chartview').hide();
}

///////////////////////////////////////////////////////////////////      msg  queue          for new demand
function get_kestrel() {
     $.post("../demander/kestrel_newer", { }, function(data) {
          for(t in data) {
               if(data[t] > 0)
                    $('<span class="notifyNewForcast"></span>').text(data[t]).appendTo($('div[demand=' + t + ']')).click(function(e) {
                         demand_search({
                              kestrel : 'kestrel',
                              type : $(this).parent().attr('demand')
                         });
                         $(this).remove();
                         $('#kestrel').show();
                         e.stopPropagation();
                    });
          }
     }, "json");
}

function clear_kestrel(e) {
     $.post("../demander/kestrel_newer", {
          type : "delete"
     }, function(data) {
          alert("已无新消息");
     }, "json");
     $(e).hide();
     $('span.notifyNewForcast').remove();
     demand_search({
          kestrel : "kestrel",
          type : ""
     });
}

///////////////////////////////////////////////////////////////////        basic      search	   API
function demand_search(hash, page) {

     if(page == null)
          page = 0;
     $.ajax({
          url : '../demander/search',
          type : "POST",
          data : {
               kestrel : hash.kestrel,
               client : hash["client"],
               supplier : hash["supplier"],
               partNr : hash["partNr"],
               start : hash["start"],
               end : hash["end"],
               type : hash["type"],
               amount : hash["amount"],
               options : hash,
               page : page
          },
          dataType : "html",
          success : function(data) {
               $("#result").html(data);
          }
     });
}

///////////////////////////////////////////////////////////////////	        ext     search
function get_demand_search_stimulate() {
     var label = {
          // client: [],
          // supplier: [],
          // partNr: [],
          // // start: hash["start"],
          // // end: hash["end"],
          // type: [],
          // amount: []
     }
     var v;
     $('.search_label').children().each(function() {
          v = $(this).text();
          if($(this).parent().attr('name') == "time") {
               v = v.split('~');
               label.start = v[0].trim();
               label.end = v[1].trim();
          } else if($(this).parent().attr('name') == "amount")
               label.amount = v.split('~');
          else if( typeof label[$(this).parent().attr('name')] == "undefined")
               label[$(this).parent().attr('name')] = [v];
          else
               label[$(this).parent().attr('name')].push(v);
     });
     return label;
}

function demand_search_stimulate() {
     var label = get_demand_search_stimulate();
     $('.forcasttype[demand=""]').removeClass('typeactive');
     demand_search(label);
}

function demand_search_label_add(hash) {
     for(t in hash)
     if(hash[t].length > 0 && typeof hash[t] == "string") {
          $('#label_' + t).children().each(function() {
               if($(this).text() == hash[t])
                    $(this).remove();
          });
          $('<span class="notifyNewForcast"></span>').text(hash[t]).appendTo($('#label_' + t)).click(function() {
               var temp = {};
               temp[$(this).parent().attr('name')] = $(this).text()
               demand_search_label_delete(temp);
          });
          $('#label_' + t).show();
     } else if(hash[t].length > 0) {
          $('#label_time').children().remove();
          $('#label_time').hide();
          $('#label_amount').children().remove();
          $('#label_amount').hide();
          hash[t] = hash[t][0] + "~" + hash[t][1];
          $('<span class="notifyNewForcast"></span>').text(hash[t]).appendTo($('#label_' + t)).click(function() {
               var temp = {};
               temp[$(this).parent().attr('name')] = $(this).text()
               demand_search_label_delete(temp);
          });
          $('#label_' + t).show();
     }
     demand_search_stimulate();
}

function demand_search_label_delete(hash) {
     for(t in hash)
     if(hash[t].length > 0) {
          $('#label_' + t).children().each(function() {
               if($(this).text() == hash[t])
                    $(this).remove();
          })
          if($('#label_' + t).children().size() == 0)
               $('#label_' + t).hide();
     }
     demand_search_stimulate();
}

function demand_search_activate(e) {
     $(e).toggleClass('typeactive');
     if($(e).hasClass('typeactive'))
          demand_search_label_add({
               type : $(e).attr('demand')
          });
     else
          demand_search_label_delete({
               type : $(e).attr('demand')
          });
}

function demand_search_all(e) {
     $('.search_label').children().remove().end().hide();
     $('.forcasttype').removeClass('typeactive');
     $(e).addClass('typeactive');
     demand_search({});
}

// function demand_search_multi_types(){
// arr = [];
// $('.activetype').each(function(){
// arr.push( $(this).val() );
// });
// demand_search( { type:arr } );
// }

function download_viewed_demand() {
     var label = get_demand_search_stimulate();
     var form = $("<form/>").attr("action", "../demander/download_viewed_demand").attr("method", "post");
     $.each(label, function(k, v) {
          form.append($("<input>").attr("type", "hidden").attr("name", k).val(v));
     });
     form.appendTo("body").submit();
}

///////////////////////////////////////////////////////////////////         charting
function showTooltip(x, y, contents) {
     $('<div id="tooltip">' + contents + '</div>').css({
          top : y - 40,
          left : x + 5
     }).appendTo('body').fadeIn();
}

function chart_history(key, tstart, tend) {
     if(key === "null")
          return false;
     if( typeof tstart == "undefined") {
          var endline = new Date(new Date().valueOf() + 1 * (24 * 60 * 60 * 1000));
     } else {
          var startline = tstart;
          var endline = new Date(new Date(tstart).valueOf() + 3 * (24 * 60 * 60 * 1000));
     }
     var cview = $('.chartview');
     cview.show().css({
          top : ($(window).height() - cview.height()) / 2,
          left : ($(window).width() - cview.width()) / 2
     });
     $.post("../demander/demand_history", {
          demandId : key,
          startIndex : startline,
          endIndex : endline
     }, function(data) {
          var charting = $('#charting');
          if($('.chartactive').attr("name") == "line")
               source = {
                    data : data.chart,
                    lines : {
                         show : true
                    },
                    points : {
                         show : true
                    },
                    color : '#71c73e'
               };
          else
               source = {
                    data : data.chart,
                    lines : {
                         show : true,
                         steps : true,
                         fill : true
                    },
                    points : {
                         show : true,
                         fillColor : '#77b7c5'
                    },
                    color : '#77b7c5'
               };
          $.plot(charting, [source], {
               xaxis : {
                    min : data.xmin,
                    max : data.xmax,
                    ticks : data.x,
                    tickColor : 'transparent',
               },
               yaxis : {
                    min : 0
               },
               grid : {
                    borderColor : 'transparent',
                    minBorderMargin : 20,
                    labelMargin : 10,
                    color : '#646464',
                    backgroundColor : {
                         colors : ["#fff", "#e4f4f4"]
                    },
                    hoverable : true,
                    mouseActiveRadius : 20,
               }
          });
          var yaxisLabel = $("<div>").text("零件： " + data.partNr).appendTo(charting);
          yaxisLabel.css("position", "absolute").css('top', '-10%').css('width', '600px').css("text-align", 'center');
          var previousPoint = null;
          charting.bind('plothover', function(event, pos, item) {
               if(item) {
                    if(previousPoint != item.dataIndex) {
                         previousPoint = item.dataIndex;
                         $('#tooltip').remove();
                         var x = item.datapoint[0], y = item.datapoint[1];
                         var d = new Date(x * 1000);
                         showTooltip(item.pageX, item.pageY, '数量： ' + y + ' , 时间： ' + (d.getMonth() + 1) + '/' + d.getDate() + ' ' + d.getHours() + ':' + d.getMinutes());
                    }
               } else {
                    $('#tooltip').remove();
                    previousPoint = null;
               }
          });
          $('div.centerchart').attr('prime', key).attr('startline', data.x[0][1]);
          $('div.previousdate').attr('startline', data.scope[0]);
          $('div.laterdate').attr('startline', data.scope[1]);
     }, "json");
}

function active_chart_type(e) {
     $('.charttypebt').toggleClass('chartactive');
     $('.charttypebt[name="line"]').toggleClass('charttypelineb');
     $('.charttypebt[name="line"]').toggleClass('charttypelinea');
     $('.charttypebt[name="step"]').toggleClass('charttypestepb');
     $('.charttypebt[name="step"]').toggleClass('charttypestepa');
     chart_history($('div.centerchart').attr('prime'), new Date($('div.centerchart').attr('startline')));
}

///////////////////////////////////////////////////////////////////         DOM  on   ready
$(function() {
     $('.textsearchbox').not($('#date_float')).keypress(function(event) {
          if(event.which == 13)
               $(this).find('input.startsearch').click()
     })
     // .mouseleave(function(){  $(this).hide();  });
     .hover(function() {
          $(this).children().unbind('blur');
     }, function() {
          $(this).children().blur(function() {
               pop_cancel(this)
          });
     });
     // $('.textsearchbox.texts').find('input[placeholder]').blur(function(){  pop_cancel(this);  });
     $('.searchcancelbt').click(function() {
          pop_cancel(this);
     });
     $('#date_float > input[placeholder*=开始]').datepicker({
          showButtonPanel : true
     });
     $('#date_float > input[placeholder*=结束]').datepicker({
          showButtonPanel : true
     });
     $('.textsearchbox').draggable();
     $('.chartview').draggable();

     $('.forcasttype[demand=""]').click(function() {
          demand_search_all(this);
     });
     $('.forcasttype').css('cursor', 'pointer').not('[demand=""]').click(function() {
          demand_search_activate(this);
     });
     $('#client_float > input.searchcontent').autocomplete({
          source : "/organisation_manager/redis_search",
          appendTo : "#client_float"
     });
     $('#supplier_float > input.searchcontent').autocomplete({
          source : "/organisation_manager/redis_search",
          appendTo : "#supplier_float"
     });
     $("#partNr_float > input.searchcontent").autocomplete({
          source : "/part/redis_search",
          appendTo : "#partNr_float"
     });
     $('#client_float > input.startsearch').click(function() {
          demand_search_label_add({
               client : $('#client_float > input[placeholder]').val()
          });
          $('#client_float > input[placeholder]').val("");
     });
     $('#supplier_float > input.startsearch').click(function() {
          demand_search_label_add({
               supplier : $('#supplier_float > input[placeholder]').val()
          });
          $('#supplier_float > input[placeholder]').val("");
     });
     $('#partNr_float > input.startsearch').click(function() {
          demand_search_label_add({
               partNr : $('#partNr_float > input[placeholder]').val()
          });
          $('#partNr_float > input[placeholder]').val("");
     });
     $('#date_float > input.startsearch').click(function() {
          demand_search_label_add({
               time : [$(this).prev().prev().val(), $(this).prev().val()]
          });
          $(this).prev().prev().val("");
          $(this).prev().val("");
     });
     $('#amount_float > input.startsearch').click(function() {
          demand_search_label_add({
               amount : [$(this).prev().prev().val(), $(this).prev().val()]
          });
          $(this).prev().prev().val("");
          $(this).prev().val("");
     });
     // $('#type_float > input.searchforcasttype').click(function(){ $(this).toggleClass('activetype'); });

     $('div.previousdate').click(function() {
          chart_history($('div.centerchart').attr('prime'), new Date(new Date($('div.centerchart').attr('startline')).valueOf() - 1 * (24 * 60 * 60 * 1000)));
     }).dblclick(function() {
          chart_history($('div.centerchart').attr('prime'), new Date($('div.previousdate').attr('startline')));
     });
     $('div.laterdate').click(function() {
          chart_history($('div.centerchart').attr('prime'), new Date(new Date($('div.centerchart').attr('startline')).valueOf() + 1 * (24 * 60 * 60 * 1000)));
     }).dblclick(function() {
          chart_history($('div.centerchart').attr('prime'), new Date($('div.laterdate').attr('startline')));
     });
     $('.charttypebt').click(function() {
          active_chart_type(this);
     });

     $('#kestrel').click(function() {
          clear_kestrel(this);
     });
     get_kestrel();
     demand_search({});
});
