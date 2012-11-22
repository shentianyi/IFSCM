// ws: Negative judgement
function notNegaNum(value) {
     if(!isNaN(value)) {
          var nreg = /^([0-9]\d*|\d+\.\d+)$/;
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
    $(function() {
          var vali = true;
          var canceled = false;
          $('#demandupload').fileupload({
               singleFileUploads : false,
               acceptFileTypes : /(\.|\/)(csv)$/i,
               dataType : 'html',
               change : function(e, data) {
                    canceled = false;
                    vali = true;  
                    $('#file-upload-info-list').show();
                    $('#upload-file-preview').html('');
                    var i = 0;
                    var reg = /(\.|\/)(csv)$/i;
                    $.each(data.files, function(index, file) {
                         i++;
                         var msg = "";
                         if(!reg.test(file.name)) {
                              msg = '格式错误，只允许csv文件';
                              vali = false;
                         }
                         $('#upload-file-preview').append("<tr><td class='filenum-td'><span class='filenum-list'>" + i + "</span></td><td class='filename-td'>" + file.name + "</td><td class='filebyte-td'>" + file.size + " Byte</td><td class='filemsg-td'>" + msg + "</td></tr>");
                    });
               },
               add : function(e, data) {
                    $("#cancel-button").click(function() {
                         canceled = true;
                         $('#file-upload-info-list').hide();
                         $('#upload-file-preview').html('');
                         $('#demandupload').fileupload('destroy');
                         // $.each(data.files,function(k,v){
                              // alert(k);
                              // alert(v);
                         // });
                         location.reload();
                         // data.files=[];?
                    });

                    $("#upload-button").click(function() {
                                 // alert(JSON.stringify(data)+'');
                                 
                         if(vali && !canceled) {
                          data.submit();
                         }
                    });
               },
               beforeSend : function(xhr) {
                    xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
               },
               success : function(data) {
                    do_after_fileupload(data);
               },
               done : function(e, data) {
                    // data.context.text('Upload finished.');
               }
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

// ws : do after files are uploaded
function do_after_fileupload(data) {
     $('#upresult').html(data);
     $('#upload-file-area').hide();
     $('#handingMsg').show();
}

// ws : do after upfile info load
function do_after_fileinfo_load(data) {
     $('#upresult').html(data);
     // document.getElementById('upresult').innerHTML = data;
     // if($('#batchFileId').val() != null) {
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
     // }
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
                    var de = data.object;
                    var sfileInfo = $('.listoffiles').find('#' + de.sk);
                    var sfileErrorCountSpan = sfileInfo.find('#file-error-count-info-span');
                    $('#batch-file-error-count-info-span').text(de.bc);
                    if(de.sc == 0) {
                         sfileErrorCountSpan.attr('class', 'filestatus noshowfile').text('没有错误');
                         get_upfile_demands(de.sk, 0);
                    } else {
                         sfileErrorCountSpan.attr('class', 'filestatus filerr').text('有' + de.sc + '处错误');
                         if(de.vali) {
                              // var msgDiv = demand.find('.demand-msg-div');
                              // msgDiv.html("已正确");
                              $('#' + de.key).hide();
                         } else {
                              var msgs = jQuery.parseJSON(de.msg);
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
                    }
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
                                        // gen amount bar & reset img
                                        var rate = parseFloat(de.rate);
                                        // var width;          
                                        if(de.oldamount !=null) {
                                             demand.find('.percentage').text(Math.abs(de.rate.toFixed(2)) + '%');
                                             if(rate > 0) {
                                                  demand.find('#thisLineWidthDiv').css('width', '100%');
                                                  demand.find('#lastLineWidthDiv').css('width', parseInt(de.oldamount) > 0 ? '' + (100 / (1 + rate / 100)) + '%' : '0%');
                                                  demand.find('.percentageImg').attr('src', '/assets/arrup.png');
                                             } else if(rate < 0) {
                                                  demand.find('#thisLineWidthDiv').css('width', '' + (100 + rate ) + '%');
                                                  demand.find('#lastLineWidthDiv').css('width', '100%');
                                                  demand.find('.percentageImg').attr('src', '/assets/arrdown.png');
                                             } else {
                                                  demand.find('#thisLineWidthDiv').css('width', parseInt(de.amount) > 0 ? '100%' : '0%');
                                                  demand.find('#lastLineWidthDiv').css('width', parseInt(de.oldamount) > 0 ? '100%' : '0%');
                                                  demand.find('.percentageImg').attr('src', '/assets/equal.png');
                                             }
                                        }
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
                    alert('请填入非负数预测量！');
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
     var overlay = document.getElementById('handle-dialog-modal');
     overlay.style.display = 'block';
     var dialog = document.getElementById('dialog-overlay');
     dialog.style.display = 'block';

     $.ajax({
          url : '../demander/send_demand',
          data : {
               'batchFileId' : $('#batchFileId').val()
          },
          dataType : 'json',
          type : 'post',
          success : function(data) {
               dialog.style.display = 'none';
               overlay.style.display = 'none';
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

// ws:check sfaff unfinished file
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

function changetype(obj) {
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
          return false;
     }
     return false;
}

function clicked(className) {
     var o, i, j;
     var allPageTags = document.getElementsByTagName('table');
     if(allPageTags != null) {
          for( i = 0; i < allPageTags.length; i++) {
               if(allPageTags[i].className == "upData") {
                    o = allPageTags[i].rows;
               }
          }
          for( i = 1; i < o.length; i++) {
               for( j = 0; j < o[i].cells.length - 1; j++) {
                    // not change the text type
                    if(o[i].cells[j].className == 'no-type-change')
                         continue;
                    // the cell has specific onclick event
                    if(o[i].cells[j].className == 'no-auto-click-bind')
                         continue;

                    o[i].cells[j].ondblclick = function() {
                         changetype(this);
                    }
               }
          }
     }
}
