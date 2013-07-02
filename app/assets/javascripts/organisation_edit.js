function organisation_edit() {
	$.get("../organisation_manager/edit?id=" + $('#id').val(), function(data) {
		$('button[name=modify]').show();
		$("#result").html(data);
	}, "html");
}

function organisation_edit_submit() {
	eles = document.getElementById('forminfo').elements;
	var hash = {};
	for (var i = 0; i < eles.length; i++)
		hash[eles[i].name] = eles[i].value;
	$.post("../organisation_manager/edit", hash, function(data) {
		if (data.flag) {
			alert(data.msg);
			window.location = "../organisation_manager";
		} else
			alert(data.msg);
	}, "json");
}

function organisation_new() {
	eles = document.getElementById('forminfo').elements;
	var hash = {};
	for (var i = 0; i < eles.length; i++)
		hash[eles[i].name] = eles[i].value;
	$.post("../organisation_manager/new", hash, function(data) {
		if (data.flag) {
			alert(data.msg);
			window.location = "../organisation_manager/new";
		} else
			alert(data.msg);
	}, "json");
}

function org_rel_new() {
	eles = document.getElementById('formRelation').elements;
	var hash = {};
	for (var i = 0; i < eles.length; i++)
		hash[eles[i].name] = eles[i].value;
	if ($('#orgrel_update').attr("checked"))
		hash['CZ-orgrel-update'] = true;
	$.post("../organisation_manager/create_org_relation", hash, function(data) {
		if (data.flag) {
			alert(data.msg);
		} else
			alert(data.msg);
	}, "json");
}

function org_costcenter_new() {
	eles = document.getElementById('formCostCenter').elements;
	var hash = {};
	for (var i = 0; i < eles.length; i++)
		hash[eles[i].name] = eles[i].value;
	$.post("../organisation_manager/create_costcenter", hash, function(data) {
		MessageBox(data.msg);
	}, "json");
}

function org_staff_new() {
	eles = document.getElementById('formStaff').elements;
	var hash = {};
	for (var i = 0; i < eles.length; i++)
		hash[eles[i].name] = eles[i].value;
	$.post("../organisation_manager/create_staff", hash, function(data) {
		if (data.flag) {
			alert(data.msg);
		} else
			alert(data.msg);
	}, "json");
}

function organisation_manager(idStr) {
	var vali = true;
	var lock = false;
	var csvReg = /(\.|\/)(csv|tff)$/i;
	$(idStr).fileupload({
		singleFileUploads : false,
		acceptFileTypes : /(\.|\/)(csv|tff)$/i,
		dataType : 'json',
		change : function(e, data) {
			vali = true;
			$(idStr + '-preview').html('');
			$.each(data.files, function(index, file) {
				var msg = "上传中 ... ...";
				if (!csvReg.test(file.name)) {
					msg = '格式错误';
					vali = false;
				}
				$(idStr + '-preview').show().append("<span>文件：" + file.name + "</span><br/><span info>处理：" + msg + "</span>");
			});
		},
		add : function(e, data) {
			if (vali)
				if (data.submit != null)
					data.submit();
		},
		beforeSend : function(xhr) {
			if ($('#partrel_update').attr("checked"))
				xhr.setRequestHeader('CZ-partrel-update', true);
			if ($('#strategy_update').attr("checked"))
				xhr.setRequestHeader('CZ-strategy-update', true);
			xhr.setRequestHeader('CZ-partrel-encoding', $('input[name=partrel_encoding]:radio:checked').val() );
			xhr.setRequestHeader('CZ-strategy-encoding', $('input[name=strategy_encoding]:radio:checked').val() );
			xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
		},
		success : function(data) {
			$(idStr + '-preview > span[info]').html("处理：" + data.msg);
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
	organisation_manager("#dn-printer-template-uploader");
	$(".toggle_container").hide();
	$(".expand_heading").click(function() {
		$(this).next(".toggle_container").slideToggle("slow");
	});
});

function get_orl_printers() {
	$.post('../organisation_manager/get_printer', {
		cid : $("#clientId").val(),
		sid : $("#supplierId").val(),
		ptype : $("#printerType").val()
	}, function(data) {
		$("#printer_result").html(data);
	});
}

function add_orl_printer() {
	if (($("#clientId").val() != $("#supplierId").val()) && $("#template").val().length > 0 && $("#moduleName").val().length > 0) {
		$.post('../organisation_manager/add_printer', {
			cid : $("#clientId").val(),
			sid : $("#supplierId").val(),
			ptype : $("#printerType").val(),
			template : $("#template").val(),
			moduleName : $("#moduleName").val()
		}, function(data) {
			alert(data.msg);
		});
	} else {
		alert("请检查填写信息");
	}

}

function del_orl_printer() {
	$.post('../organisation_manager/del_printer', {
		printerKey : $("#printerKey").val()
	}, function(data) {
		alert(data.msg);
	});
}

function add_orl_defalut_printer() {
	$.post('../organisation_manager/add_default_printer', {
		printerKey : $("#printerKey").val()
	}, function(data) {
		alert(data.msg);
	});
}

function update_orl_default_printer() {
	if($("#printerKey").val().length>0){
	$.post('../organisation_manager/update_default_printer', {
		printerKey : $("#printerKey").val(),
		updated : $("#updatedcheck").attr('checked') == "checked",
		template : $("#template").val(),
		moduleName : $("#moduleName").val()
	}, function(data) {
		alert(data.msg);
	});
	}else{
		alert("oh,wowowo,请填写PrinterKey");
	}
}

function get_orl_dncontact() {
	if ($("#clientId").val() != $("#supplierId").val()) {
		$.post('../organisation_manager/get_dncontact', {
			cid : $("#clientId").val(),
			sid : $("#supplierId").val(),
			ctype : $("#contactType").val()
		}, function(data) {
			$("#contact_result").html(data);
		});
	} else {
		alert("请检查填写信息");
	}
}

function add_orl_dncontact(type) {
	if ($("#clientId").val() != $("#supplierId").val()) {
		$.post('../organisation_manager/add_dncontact', {
			cid : $("#clientId").val(),
			sid : $("#supplierId").val(),
			ctype : $("#contactType").val(),
			recer_name : $("#recer_name").val(),
			recer_contact : $("#recer_contact").val(),
			rece_address : $("#rece_address").val(),
			sender_name : $("#sender_name").val(),
			sender_contact : $("#sender_contact").val(),
			send_address : $("#send_address").val(),
			type : type,
			conKey : $("#dncontactKey").val()
		}, function(data) {
			if (type == 300) {
				for (var k in data) {
					$("#" + k).val(data[k]);
				}
			} else {
				alert("done:" + data.key)
			}
		});
	} else {
		alert("请检查填写信息");
	}
}

function del_orl_dncontact() {
	$.post('../organisation_manager/del_dncontact', {
		// cid : $("#clientId").val(),
		// sid : $("#supplierId").val(),
		conKey : $("#dncontactKey").val()
	}, function(data) {
		alert(data.msg);
	});
}

