$("document").ready(function() {
     $(".botbts").css({
          "opacity" : .8
     });
     $(".listoffiles").css({
          "opacity" : .8
     });
});

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
     var file = $('.upData');
     if(file != null && demand != null) {
          $.ajax({
               url : '../demander/correct_error',
               data : {
                    'batchId' : $('#batchFileId').val(),
                    'fileId' : file.attr("id"),
                    'uuid' : demand.attr("id"),
                    'partNr' : demand.children('.partNr').text(),
                    'supplierNr' : demand.children('.supplierNr').text(),
                    'filedate' : demand.children('.filedate').text(),
                    'type' : demand.children('.type').text(),
                    'amount' : demand.children('.amount').text()
               },
               dataType : 'json',
               type : 'post',
               success : function(data) {
                    if(data.result) {
                         if(data.object.vali) {
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
               }
          });
     }
}

