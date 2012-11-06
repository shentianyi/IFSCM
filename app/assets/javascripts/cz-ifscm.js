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
function cancel_demand_upload(){
     if(confirm('确定取消本次上传？')){
          $.ajax({
               url: '../demander/cancel_upload',
               data:{
                    'batchId' : $('#batchFileId').val()
               },
               dataType:'json',
               type:'post',
               success:function(data){
                    if(data.result){
                         alert(data.content);
                         window_redirect("../demander/demand_upload",1000);
                    }else{
                         alert(data.content);
                    }
               }
          });
     }
}
// ws: download demand files as zip
function download_demand (ele) {
  var form=$('#download_demand_form');
  form.submit();
}
