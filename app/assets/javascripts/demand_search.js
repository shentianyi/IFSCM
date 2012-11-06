
function demand_search( hash, page ){
	
     if (page==null)
     	page=0;
     	
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
               amount: hash["amount"],
               options: hash,
               page: page
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

function demand_search_activate(e){
	$('.forcasttype').removeClass('typeactive');
	$(e).addClass('typeactive');
	demand_search( {type:$(e).attr('demand')} );
}

function demand_search_with_type( hash ){
	hash['type'] =$('.typeactive').attr('demand');
	demand_search( hash );
}

function demand_search_multi_types(){
	arr = [];
	$('.activetype').each(function(){
		arr.push( $(this).val() );
	});
	demand_search( { type:arr } );
}

function forcasttype_reverse(e){
	if ( $(e).hasClass('activetype') )
		$(e).removeClass('activetype');
	else
		$(e).addClass('activetype');
}

function pop(e){
	var id = e.attributes['link'].nodeValue;
	$('#'+id).show();
}

function pop_cancel(e){
	$(e).parent().hide();
}
