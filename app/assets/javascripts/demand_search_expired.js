///////////////////////////////////////////////////////////////////     UI

///////////////////////////////////////////////////////////////////        basic      search	   API
function demand_search(hash, page) {

     if(page == null)
          page = 0;
     $.ajax({
          url : '../demander/search_expired',
          type : "POST",
          data : {
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
function get_demand_label() {
     var label = {
          // client: [],
          // supplier: [],
          // partNr: [],
          // // start: hash["start"],
          // // end: hash["end"],
          // type: [],
          // amount: []
     }
     var arr = [];
	 $('.activetype').each(function(){  arr.push( $(this).val() );  });
     label.client = $('#client_float > input.startsearch').val();
     label.supplier = $('#supplier_float > input.searchcontent').val();
     label.partNr = $("#partNr_float > input.searchcontent").val();
     label.start = $("#date_float > input").get(0).value;
     label.end = $("#date_float > input").get(1).value;;
     label.type = arr;
     label.amount = [$("#amount_float > input").get(0).value, $("#amount_float > input").get(1).value];
     return label;
}

function download_viewed_demand() {
     var label = get_demand_label();
     var form = $("<form/>").attr("action", "../demander/download_viewed_demand").attr("method", "post");
     $.each(label, function(k, v) {
          form.append($("<input>").attr("type", "hidden").attr("name", k).val(v));
     });
     form.appendTo("body").submit();
}

///////////////////////////////////////////////////////////////////         DOM  on   ready
$(function() {
     $('.textsearchbox').not($('#date_float')).keypress(function(event) {
          if(event.which == 13)
               $(this).find('input.startsearch').click()
     });
     $('#type_float > input.searchforcasttype').click(function(){ $(this).toggleClass('activetype'); });
     $('#search_expired_button > input[name=search]').click(function() {
          var label = get_demand_label();
          demand_search(label);
     });
     $('#search_expired_button > input[name=cancel]').click(function() {
          $('input.searchcontent').val("");
          $('.activetype').removeClass("activetype");
          demand_search(get_demand_label());
     });

     $('#date_float > input[placeholder*=开始]').datepicker({
          showButtonPanel : true
     });
     $('#date_float > input[placeholder*=结束]').datepicker({
          showButtonPanel : true
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
     
     demand_search(get_demand_label());
});
