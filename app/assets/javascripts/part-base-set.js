function strategy_ready() {
	$(".partsimage").click(function() {
		$(this).toggleClass("partsimage-choosen");
	});
	$(".partsimage").dblclick(function(event) {
		get_part_strategy(event, $(this).attr("id"));
	}); $
	$("#checkbox-all-parnum").click(function() {
		if ($(this).attr("checked")) {
			$(".partsimage").addClass("partsimage-choosen");
		} else {
			$(".partsimage").removeClass("partsimage-choosen");
		}
	});
	$("[id^='img-strategy-']").click(function() {
		$("[id^='img-strategy-']").removeClass("strategy-checked").css("background", "white");
		$(this).addClass("strategy-checked").css("background-color", "#efefef");
	});
	$("input[type='radio']").click(function() {
		$("input[type='radio']").attr("checked", false);
		$(this).attr("checked", true);
	});
	$(".logosearchv").click(function() {
		if ($(".partsimage-choosen").length > 0) {
			$(".popupqlt").attr("style", "display:block");
		}
	});
	$(".closeqltbt,.canclebt").click(function() {
		close_strategy();
	});
	$(".popupqlt").draggable();
	$("[id^='img-strategy-']:first").addClass("strategy-checked").css("background-color", "#efefef");
}

function get_part_strategy(e, id) {
	$(".partsimage").removeClass("partsimage-choosen");
	$("#" + id).addClass("partsimage-choosen");
	$(".tooltip-content").show().offset({
		top : e.pageY,
		left : e.pageX
	});
	$.post("../part/strategyinfo", {
		id : id
	}, function(msg) {
		$(".tooltip-content").hide();
		if (msg.result) {
			var obj = msg.object;
			$("[id^='img-strategy-']").removeClass("strategy-checked").css("background", "white");
			$("#img-strategy-" + obj.needCheck).addClass("strategy-checked").css("background-color", "#efefef");
			var w = document.getElementById('wares');
			for (var j = 0; j < w.length; j++) {
				if (w[j].value == obj.warehouse_id) {
					w.selectedIndex = j;
					break;
				}
			}
			$("#check-point-posi").val(obj.position_nr);
			if (obj.demote == "false") {
				$($("input[name='group1']")[1]).attr("checked", "true");
			} else {
				$($("input[name='group1']")[0]).attr("checked", "true");
			}
			$("#demote-times").val(obj.demote_times);
			$("#passed-times").val(obj.check_passed_times);
			$("#least-amount").val(obj.leastAmount);
			$(".popupqlt").attr("style", "display:block");
		} else {
			alert("数据获取出错，请重试");
		}
	}, 'json');
}

function close_strategy() {
	$(".popupqlt").attr("style", "display:none");
	$("[id^='img-strategy-']").removeClass("strategy-checked").css("background", "white");
	$($("[id^='img-strategy-']")[0]).addClass("strategy-checked").css("background-color", "#efefef");
	$("#check-point-posi").val("");
	$("#demote-times").val("");
	$("#least-amount").val("");
	$("input[name='group1']").attr("checked", "false");
	$($("input[name='group1']")[0]).attr("checked", "false");
	document.getElementById("wares").selectedIndex = 0;
}

function set_part_strategy() {
	var parts = $(".partsimage-choosen");
	if (parts.length > 0) {
		ids = "";
		for (var i = 0; i < parts.length; i++) {
			ids += parts[i].id + ",";
		}
		ids = trimEnd(ids);
		var posi = $("#check-point-posi").val();
		var times = $("#demote-times").val();
		var least = $("#least-amount").val();
		var vali = true;
		// if (posi.length == 0) {
			// flash_hidden_message("#check-point-posi-error");
			// vali = false;
		// }
		if (!isIntBetween(1, 10000, times) && $("input[name='group1'][checked]").val() == "1") {
			flash_hidden_message("#demote-times-error");
			vali = false;
		}
		if (least.length>0 && !isPositiveNum(least)) {
			flash_hidden_message("#least-amount-error");
			vali = false;
		}
		if (!vali)
			return false;
		var strategy = $(".strategy-checked").attr("strategy");
		$.post("../part/strategy", {
			ids : ids,
			ware : document.getElementById('wares').value,
			posiNr : posi,
			strategy : strategy,
			demote : $("input[name='group1'][checked]").val(),
			demoteTimes : times,
			least : least
		}, function(msg) {
			if (msg.result) {
				alert("操作成功！");
				close_strategy();
				var oscr = $("#img-strategy-" + strategy).attr("src");
				var img = $("#img-strategy-" + strategy).attr("img");
				var src = oscr.replace(img, "nw-" + img);
				parts.find('img').attr('src', src);
			} else {
				alert(msg.content);
			}
		}, 'json');
	}
}

function page_change(p) {
	window.location = "../part/strategy?s=" + $("#s").val() + '&p=' + p;
}