// ws: 判断数字是否是非负数
function isNotNegaNum(v) {
	if (!isNaN(v)) {
		var reg = /^([0-9]\d*|\d+\.\d+)$/;
		return reg.test(v);
	}
	return false;
}

// ws : 判断数字是否是正整数
function isPositiveInt(v) {
	if (!isNaN(v)) {
		var reg = /^[1-9]\d*$/;
		return reg.test(v);
	}
	return false;
}

// ws : 判断数字是否是整数
function isPositiveNum(v) {
	if (!isNaN(v)) {
		var reg = /^([1-9]\d*|\d+\.\d+)$/;
		return reg.test(v);
	}
	return false;
}

// ws : 显示处理窗口
function show_handle_dialog() {
	document.getElementById('handle-dialog-modal').style.display = 'block';
	document.getElementById('dialog-overlay').style.display = 'block';
}

// ws : 隐藏处理窗口
function hide_handle_dialog() {
	document.getElementById('handle-dialog-modal').style.display = 'none';
	document.getElementById('dialog-overlay').style.display = 'none';
}

function MessageBox(str) {
	$('#MessageBox > p').html(str).parent().show();
}

$(function() {
	$('#MessageBox  div.close-logo').click(function() {
		$(this).parent().parent().hide();
	})
})
function change_label_to_text(obj) {
	var tag = obj.firstChild.tagName;
	if ( typeof (tag) != "undefined" && (tag == "INPUT" || tag == "TEXTAREA"))
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
		if (txt.value.length == 0)
			txt.value = val;
		obj.innerHTML = txt.value;
	}
}
