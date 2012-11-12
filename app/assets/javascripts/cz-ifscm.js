$("document").ready(function() {
     $(".botbts").css({
          "opacity" : .8
     });
     $(".listoffiles").css({
          "opacity" : .8
     });
});

// ws: Negative judgement
function notNegaNum(value) {
     if(!isNaN(value)) {
          var nreg = /^\d+$/;
          return nreg.test(value);
     }
     return false;
}

// ws : redirect
// url : direction ulr
// timeout : redirect after timeout -- ms
function window_redirect(url, timeout) {
     setTimeout(function() {
          window.location.href = url;
     }, timeout);
}

// ws : demand upload file
function upload_demand_files() {
     $(function() {'use strict';
          // Initialize the jQuery File Upload widget:
          $('#demandupload').fileupload({
               dataType : 'html',
               beforeSend : function(xhr) {
                    xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
               },
               success : function(data) {
                    do_after_fileinfo_load(data);
               },
               error : function() {

               },
               done : function(e, data) {
                    // data.context.text('Upload finished.');
               }
          });

          // settings:
          $('#demandupload').fileupload('option', {
               singleFileUploads : false,
               maxFileSize : 50000000,
               acceptFileTypes : /(\.|\/)(csv)$/i
          });
     });

}

// ws : check staff file cache in redis
function check_staff_cache_file() {
     $.ajax({
          url : '../demander/check_staff_cache_file',
          dataType : 'json',
          type : 'post',
          success : function(data) {
               if(data.result) {
                    if(confirm('你有未完成预测上传，是否加载')) {
                         $.ajax({
                              url : '../demander/get_cache_file_info',
                              dataType : 'html',
                              type : 'post',
                              data : {
                                   'batchFileId' : data.object
                              },
                              success : function(result) {
                                   do_after_fileinfo_load(result);
                              }
                         });
                    } else {
                         $.ajax({
                              url : '../demander/clean_staff_cache_file',
                              type : 'post',
                              data : {
                                   'batchFileId' : data.object
                              }
                         });
                    }
               }
          }
     });
}

// ws : do after upfile info load
function do_after_fileinfo_load(data) {
      $('#upresult').html(data);
     // document.getElementById('upresult').innerHTML = data;
     if($('#batchFileId').val() != null) {
          $('#upload-file-area').hide();
          $('.botbts').show();
          /*
           $(window).bind('beforeunload', function() {
           check_staff_unfinished_file(function(data) {
           if(data.result) {
           var msg = '你有未发送/取消的预测，是否离开？';
           if(/Firefox[\/\s](\d+)/.test(navigator.userAgent)) {
           if(confirm(msg)) {
           history.go();
           } else {
           window.setTimeout(function() {
           window.stop();
           }, 0);
           }
           } else {
           return msg;
           }
           }
           });
           alert('dddd');
           });
           */
     }
}

// ws: get uploaded file demands
// field=>single file uuid ; pageIndex=> for page show
function get_upfile_demands(fileId, pageIndex) {
     $.ajax({
          url : '../demander/get_tempdemand_items',
          data : {
               'fileId' : fileId,
               'pageIndex' : pageIndex
          },
          dataType : 'html',
          type : 'post',
          success : function(data) {
               $('#demands').html(data);
               clicked('upData');
          }
     });
}

// ws: correct demand item
function correct_demand_error(ele) {
     var demand = $(ele).parent().parent();
     update_demand(demand, function(data) {
          if(data != null) {
               if(data.result) {
                    if(data.object.vali) {
                         var msgDiv = demand.find('.demand-msg-div');
                         msgDiv.html("已正确");
                    } else {
                         var msgs = jQuery.parseJSON(data.object.msg);
                         if(msgs != null) {
                              var msgDiv = demand.find('.demand-msg-div');
                              msgDiv.html("");
                              for(var i = 0; i < msgs.length; i++) {
                                   var span = $('<span/>').text(msgs[i] + '/');
                                   msgDiv.append(span);
                              }
                         }
                    }
                    demand.find("#date").text(data.object.date);
               } else {
                    alert(data.content);
               }
          } else {
               alert('无法找到DOM');
          }
     });
}

// ws: rest demand amount -- now just reset the amount of demand
function reset_demand_amount(obj) {
     var tag = obj.firstChild.tagName;
     if( typeof (tag) != "undefined" && (tag == "INPUT" || tag == "TEXTAREA"))
          return;
     var val = obj.innerHTML;
     var txt = document.createElement("INPUT");
     txt.value = val;
     txt.style.background = "#FFC";
     txt.style.width = obj.offsetWidth + "px";
     obj.innerHTML = "";
     obj.appendChild(txt);
     txt.focus();
     txt.onblur = function(e) {
          if(txt.value.length == 0)
               txt.value = val;
          obj.innerHTML = txt.value;
          if(val != txt.value) {
               if(notNegaNum(txt.value)) {
                    var demand = $(obj).parent();
                    update_demand(demand, function(data) {
                         if(data != null) {
                              if(data.result) {
                                   var de = data.object;
                                   if(de.vali) {
                                        demand.find('#this_demand_amount').text(de.amount);
                                        demand.find('.percentage').text(Math.abs(Math.round(de.rate)) + '%');
                                        // gen amount bar & reset img
                                        var rate = parseFloat(de.rate);
                                        if(rate >= 0) {
                                             demand.find('#thisLineWidthDiv').css('width', '100%');
                                             if(parseInt(de.oldamount) > 0)
                                                  demand.find('#lastLineWidthDiv').css('width', '' + (100 / (1 + rate / 100)) + '%');
                                             else
                                                  demand.find('#lastLineWidthDiv').css('width', '0%');
                                             demand.find('.percentageImg').attr('src', '/assets/arrup.png');
                                        } else {
                                             demand.find('#thisLineWidthDiv').css('width', '' + (100 / (1 - rate / 100)) + '%');
                                             demand.find('#lastLineWidthDiv').css('width', '100%');
                                             demand.find('.percentageImg').attr('src', '/assets/arrdown.png');
                                        }
                                        //.....
                                   } else {
                                        alert(jQuery.parseJSON(de.msg)[0]);
                                   }
                              } else {
                                   alert(data.content);
                              }
                         } else {
                              alert('无法找到DOM');
                         }
                    });
               } else {
                    alert('请填入非负整数预测量！');
               }
          }
     }
}

// ws: for error and normal demand update
function update_demand(demand, handler) {
     var file = $('.upData');
     if(file != null && demand != null) {
          $.ajax({
               url : '../demander/correct_error',
               data : {
                    'batchId' : $('#batchFileId').val(),
                    'fileId' : file.attr("id"),
                    'uuid' : demand.attr("id"),
                    'partNr' : demand.find('#partNr').text(),
                    'supplierNr' : demand.find('#supplierNr').text(),
                    'filedate' : demand.find('#filedate').text(),
                    'type' : demand.find('#type').text(),
                    'amount' : demand.find('#amount').text()
               },
               dataType : 'json',
               type : 'post',
               success : function(data) {
                    handler(data);
               }
          });
     }
}

// ws: cancel demand upload
function cancel_demand_upload() {
     if(confirm('确定取消本次上传？')) {
          $.ajax({
               url : '../demander/cancel_upload',
               data : {
                    'batchId' : $('#batchFileId').val()
               },
               dataType : 'json',
               type : 'post',
               success : function(data) {
                    if(data.result) {
                         alert(data.content);
                         window_redirect("../demander/demand_upload", 1000);
                    } else {
                         alert(data.content);
                    }
               }
          });
     }
}

// ws: download demand files as zip
function download_demand(ele) {
     var form = $('#download_demand_form');
     form.submit();
}

// ws: send demand
function send_demand_batchFile(ele) {
     $.ajax({
          url : '../demander/send_demand',
          data : {
               'batchFileId' : $('#batchFileId').val()
          },
          dataType : 'json',
          type : 'post',
          success : function(data) {
               if(data.result) {
                    $(ele).unbind('click').removeAttr('onclick').bind('click', function() {
                         alert('预测已经发送成功，不可重复发送');
                    });
                    $('#cancelDemandUpBtn').unbind('click').removeAttr('onclick').bind('click', function() {
                         alert('已经发送成功，不可取消');
                    });
                    $('[id=amount]').unbind('dblclick').removeAttr('ondblclick');
                    alert(data.content);
                    // window_redirect("../demander/demand_upload",1000);
               } else {
                    alert(data.content);
               }
          }
     });
}

function check_staff_unfinished_file(handler) {
     $.ajax({
          url : '../demander/check_staff_unfinished_file',
          type : 'post',
          dataType : 'json',
          data : {
               'batchFileId' : $('#batchFileId').val()
          },
          success : function(data) {
               handler(data);
          }
     });
}

