
///////////////////////////////////////////////////////////////////     UI
function pop(e){
	var id = e.attributes['link'].nodeValue;
	$('#'+id).css({
        top: $(e).offset().top+$(e).height(),
        left: $(e).offset().left+$(e).width()
    }).show().find("input").get(0).focus();
}

function pop_cancel(e){
	$(e).parent().hide();
}

function chartview_cancel(){
	$('.chartview').hide();
}

function forcasttype_reverse(e){
	if ( $(e).hasClass('activetype') )
		$(e).removeClass('activetype');
	else
		$(e).addClass('activetype');
}

///////////////////////////////////////////////////////////////////      msg  queue          for new demand
function get_kestrel(){
	$.post("../demander/kestrel_newer",{ },
			  function(data){ 
			  	for (t in data){
			  		if (data[t]>0)
			  			$('<span class="notifyNewForcast"></span>').text(data[t]).appendTo($('div[demand='+t+']'))
			  				.click(function(e){  
			  					demand_search({kestrel:'kestrel',type:$(this).parent().attr('demand')});
			  					$(this).remove();
			  					$('#kestrel').show();
			  					e.stopPropagation();
			  				});
			  	}
			  },
			  "json");
}

function clear_kestrel(e){
	$.post("../demander/kestrel_newer",{ type:"delete" },
		function(data){alert("已无新消息");},"json");
	$(e).hide();
	$('span.notifyNewForcast').remove();
	demand_search({kestrel:"kestrel",type:""});
}

///////////////////////////////////////////////////////////////////        basic      search	   API
function demand_search( hash, page ){
	
     if (page==null)
     	page=0;
     	
     $.ajax({
          url : '../demander/search',
          type : "POST",
          data : {
          	   kestrel: hash.kestrel,
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

///////////////////////////////////////////////////////////////////	        ext     search
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

///////////////////////////////////////////////////////////////////         charting
function showTooltip(x, y, contents) {
    $('<div id="tooltip">' + contents + '</div>').css({
        top: y - 40,
        left: x + 5
    }).appendTo('body').fadeIn();
}

function chart_history(key, tstart, tend ){
	if (key==="null") return false;
	if (typeof tstart=="undefined")
	{	var endline = new Date(new Date().valueOf() + 1*(24*60*60*1000) );
	}else
	{	var startline = tstart;
		var endline = new Date(new Date(tstart).valueOf() + 3*(24*60*60*1000) );
	}
	$('.chartview').show();
	$.post("../demander/demand_history",{demandId:key,startIndex:startline,endIndex:endline},
			  function(data){  
			  	var charting = $('#charting');
			  	if ( $('.chartactive').attr("name")=="line" )  source={ data:data.chart, lines: {show: true}, points: {show: true}, color: '#71c73e' };
			  	else source={ data:data.chart, lines: {show: true, steps: true, fill: true}, points: {show: true, fillColor: '#77b7c5'}, color: '#77b7c5' };
			  	$.plot(charting,  [
			  		source
			  	], {
			  		xaxis:{ min:data.xmin, max:data.xmax, ticks:data.x, tickColor: 'transparent', },
			  		yaxis:{ min:0 },
					grid: {
						borderColor: 'transparent',
						minBorderMargin: 20,
						labelMargin: 10,
						color: '#646464',
						backgroundColor: {	colors: ["#fff", "#e4f4f4"] 	},
						hoverable: true,
						mouseActiveRadius: 20,
					}
			  	});
			  	var yaxisLabel = $("<div>").text("零件： "+data.partNr).appendTo(charting);
			  	yaxisLabel.css("position","absolute").css('top','-10%').css('width','600px')
			  				.css("text-align", 'center');
			  	var previousPoint = null;
				charting.bind('plothover', function (event, pos, item) {
				    if (item) {
				        if (previousPoint != item.dataIndex) {
				            previousPoint = item.dataIndex;
				            $('#tooltip').remove();
				            var x = item.datapoint[0], y = item.datapoint[1];
				            var d = new Date(x*1000);
				            showTooltip( item.pageX, item.pageY, '数量： ' + y + ' , 时间： ' + (d.getMonth()+1)+'/'+d.getDate()+' '+d.getHours()+':'+d.getMinutes() );
				        }
				    } else {
				        $('#tooltip').remove();
				        previousPoint = null;
				    }
				});
			  	$('div.centerchart').attr('prime',key).attr('startline',data.x[0][1]);
			  	$('div.previousdate').attr('startline',data.scope[0]);
			  	$('div.laterdate').attr('startline',data.scope[1]);
			  },
			  "json");
}

function active_chart_type(e){
	$('.charttypebt').removeClass('chartactive');
	$(e).addClass('chartactive');
	chart_history(  $('div.centerchart').attr('prime'), new Date($('div.centerchart').attr('startline'))  );
}
///////////////////////////////////////////////////////////////////         DOM  on   ready
$(function() {
	$('.textsearchbox').draggable().blur(function(){  $(this).hide();  });
	$('.chartview').draggable();
	// $('.searchcancle').click(function(){ pop_cancel(this); });
	
	$('.forcasttype').css('cursor', 'pointer').click(function(){demand_search_activate( this );});
	$('#client_float > input.searchcontent').autocomplete({source: "/organisation_manager/redis_search", appendTo: "#client_float"} );
	$('#supplier_float > input.searchcontent').autocomplete({source: "/organisation_manager/redis_search", appendTo: "#supplier_float"} );
	$("#partNr_float > input.searchcontent").autocomplete({ source:"/part/redis_search", appendTo: "#partNr_float" });
	$('#client_float > input.startsearch').click(function(){ demand_search_with_type( {client:$('#client_float > input[placeholder]').val()} );    });
	$('#supplier_float > input.startsearch').click(function(){ demand_search_with_type( {supplier:$('#supplier_float > input[placeholder]').val()} );    });
	$('#partNr_float > input.startsearch').click(function(){ demand_search_with_type( {partNr:$('#partNr_float > input[placeholder]').val()} );    });
	$('#type_float > input.searchforcasttype').click(function(){ forcasttype_reverse(this); });
	
	$('div.previousdate').click(function (){	chart_history( $('div.centerchart').attr('prime'), new Date(new Date($('div.centerchart').attr('startline')).valueOf() - 1*(24*60*60*1000)) );		})
											.dblclick(function (){	chart_history( $('div.centerchart').attr('prime'),new Date($('div.previousdate').attr('startline'))  );		});
	$('div.laterdate').click(function (){	chart_history( $('div.centerchart').attr('prime'), new Date(new Date($('div.centerchart').attr('startline')).valueOf() + 1*(24*60*60*1000))  );		})
									.dblclick(function (){	chart_history( $('div.centerchart').attr('prime'),new Date($('div.laterdate').attr('startline'))  );		});
	$('.charttypebt').click(function(){  active_chart_type(this);  });
	
	$('#kestrel').click(function(){clear_kestrel(this);});
	get_kestrel();
	demand_search( {} );
});
