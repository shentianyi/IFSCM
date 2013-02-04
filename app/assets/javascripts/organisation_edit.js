

function organisation_edit(){
	$.get("../organisation_manager/edit?id="+$('#id').val(),
				function(data){
					$('button[name=modify]').show();
					$("#result").html(data);
				}, "html");
}


function organisation_edit_submit(){
	eles = document.getElementById('forminfo').elements;
	var hash={};
	for (var i=0; i<eles.length; i++)
			hash[eles[i].name]=eles[i].value;
	$.post("../organisation_manager/edit",hash,
			  function(data){ 
			  	if (data.flag){
			  		alert(data.msg);
			  		window.location = "../organisation_manager";
			  	}else
			  		alert(data.msg);
			  },
			  "json");
}

function organisation_new(){
	eles = document.getElementById('forminfo').elements;
	var hash={};
	for (var i=0; i<eles.length; i++)
			hash[eles[i].name]=eles[i].value;
	$.post("../organisation_manager/new",hash,
					function(data){
					  	if (data.flag){
					  		alert(data.msg);
					  		window.location = "../organisation_manager/new";
					  	}else
					  		alert(data.msg);
					}, "json");
}

function org_rel_new(){
	eles = document.getElementById('formRelation').elements;
	var hash={};
	for (var i=0; i<eles.length; i++)
		hash[eles[i].name]=eles[i].value;
	$.post("../organisation_manager/create_org_relation",hash,
					function(data){
					  	if (data.flag){
					  		alert(data.msg);
					  	}else
					  		alert(data.msg);
					}, "json");
}

function org_staff_new(){
	eles = document.getElementById('formStaff').elements;
	var hash={};
	for (var i=0; i<eles.length; i++)
		hash[eles[i].name]=eles[i].value;
	$.post("../organisation_manager/create_staff",hash,
					function(data){
					  	if (data.flag){
					  		alert(data.msg);
					  	}else
					  		alert(data.msg);
					}, "json");
}

function organisation_manager(idStr){
      var vali = true;
      var lock = false;
      var csvReg = /(\.|\/)(csv)$/i;
      $(idStr).fileupload({
			       singleFileUploads : false,
			       acceptFileTypes : /(\.|\/)(csv)$/i,
			       dataType : 'json',
			       change : function(e, data) {
			            vali = true;
			            $(idStr+'-preview').html('');
			            $.each(data.files, function(index, file) {
			                 var msg = "上传中 ... ...";
			                 if(!csvReg.test(file.name)) {
			                      msg = '格式错误，只允许csv文件';
			                      vali = false;
			                 }
			                 $(idStr+'-preview').show().append("<span>文件：" + file.name + "</span><br/><span info>处理：" + msg + "</span>");
			            });
			       },
			       add : function(e, data) {
			                 if(vali)
			                      if(data.submit != null)
			                           data.submit();
			       },
			       beforeSend : function(xhr) {
			            xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
			       },
			       success : function(data) {
					  	if (data.flag){
					  		$(idStr+'-preview > span').html("处理："+data.msg);
					  	}else{
					  		$(idStr+'-preview > span[info]').html("处理："+data.msg);
					  	}
			       },
			       done : function(e, data) {
			            // data.context.text('Upload finished.');
			       }
	  });
}

$(function() {
      organisation_manager("#relpartFile");
      organisation_manager("#relpartPackageFile");
      organisation_manager("#relpartCheckFile");
});