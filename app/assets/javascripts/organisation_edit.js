

function organisation_edit(){
	$.post("../organisation_manager/edit",{
		id: $('#id').val()
	}, function(data){
		$("#result").html(data);
	}, "html");
}


function organisation_edit_submit(){
	eles = document.getElementById('forminfo').elements;
	var hash={};
	for (var i=0; i<eles.length; i++)
			hash[eles[i].name]=eles[i].value;
	$.post("../organisation_manager/update",hash,
			  function(data){ 
			  	if (data.flag){
			  		alert(data.msg);
			  	}else
			  		alert(data.msg);
			  },
			  "json");
}
