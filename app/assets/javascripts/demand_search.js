
function demand_search( hash ){
     if (hash["page"]&&hash["page"].length>0)
     	;
     else
     	hash["page"]=1;
     	
     $.ajax({
          url : '../demander/search',
          type : "POST",
          data : {
               client: hash["client"],
               supplier: hash["supplier"],
               partNr: hash["partNr"],
               start: hash["start"],
               end: hash["end"],
               type: hash["type"],
               page: hash["page"]
          },
          dataType : "html",
          success : function(data) {
               $("#result").html("");
               if(data != null && data.length > 0) {
                    $("#result").html(data);
               }
          }
     });
}

function demand_search_from_sup_option_one(e){
	// var hash = { supplier : $('#supplier').val() }
	if ( $(e).parent().attr("id")=="client_float" )
		var hash = { client : $(e).prev().val() };
	else if ($(e).parent().attr("id")=="partNr_float" )
		var hash = { partNr : $(e).prev().val() };
	demand_search(hash);	
}

function demand_search_type(e){
	var hash = { 	type : e.attributes['demand'].nodeValue }
	demand_search(hash);
}

function pop(e){
	var id = e.attributes['link'].nodeValue;
	$('#'+id).show();
}

function pop_cancel(e){
	$(e).parent().hide();
}
