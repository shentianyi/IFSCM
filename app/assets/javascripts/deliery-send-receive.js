function flash_message(obj, times) {
	var i = 0, t = false, times = times || 4;
	if (t)
		return;
	t = setInterval(function() {
		i++;
		if (i % 2 == 0) {
			$(obj).hide();
		} else {
			$(obj).show();
		}
		if (i == times * 2) {
			clearInterval(t);
		}
	}, 300);
}

// ws
// 功能 ： 根据parterNr搜索关系零件
// 参数 ：
//  - string : partnerNr
// - string : partNr
// - int : pageIndex
// 返回 ：
// - 无
function get_partRels_by_parterNr_partNr(pageIndex) {
	var partnerNr = document.getElementById('client-search-text').value;
	if (partnerNr == "") {
		flash_message(".errparts");
	} else {
		$.ajax({
			url : '../part/get_partRels',
			type : 'post',
			dataType : 'html',
			data : {
				partnerNr : partnerNr,
				partNr : document.getElementById('part-search-text').value,
				pageIndex : pageIndex
			},
			success : function(data) {
				$('.tableviewparts').html(data);
			}
		});
	}
}

// ws
// 功能 ： 检查用户运单缓存，有则加载之
// 参数 ：
// - 无
// 返回 ：
// - 无
function check_staff_dn_cache() {
	$.ajax({
		url : '../delivery/get_dit_dn_cache',
		dataType : 'json',
		type : 'post',
		success : function(cache) {
			// show dn
			if (cache.dn != null) {
				var pane = $("#staff-dn-cache-link");
				var linker, del;
				var block = $("#staff-dn-cache-content");
				$.each(cache.dn, function(i, v) {
					// var link=
					linker = $("<div/>").html("<a class='dn-linker' href='../delivery/dn_detail?t=p&dnKey=" + v.key + "'>" + v.key + "</a>").attr('class', 'dn-linker-div');
					del = $("<span/>").attr('class', 'closebt').attr('id', v.key).attr('title', '取消');
					del.appendTo(linker);
					linker.appendTo(pane);
					var size = pane.children('div').size();
					block.css('height', 25 * size + 13 + "px")
					del.bind('click', {
						dnKey : del.attr('id')
					}, function(e) {
						if (delete_dn_from_staff(e.data.dnKey)) {
							var p = $("[id='" + e.data.dnKey + "']").parent();
							p.fadeOut("slow", function() {
								p.remove();
								p = null;
								var lsize = $("#staff-dn-cache-link").children().size();
								block.css('height', 25 * lsize + 13 + "px")
								if (lsize == 0) {
									$("#staff-dn-cache-content").hide();
								}
							});
						}
					});
				});
				block.show();
			}
			// show dit
			if (cache.dit != null) {
				$.each(cache.dit, function(i, t) {
					$("#build-dn-btn").show();
					add_dit_to_cart(t.spartNr, t.perPackAmount, t.packAmount, t.total, t.key);
				});
			}
		}
	});
}

// ws
// 功能 ： 取消用户运单
// 参数 ：
// - string : dnKey
// 返回 ：
// - 无
function delete_dn_from_staff(dnKey) {
	var result = false;
	if (confirm('确定取消？')) {
		$.ajax({
			url : '../delivery/cancel_staff_dn',
			data : {
				dnKey : dnKey
			},
			dataType : 'json',
			type : 'post',
			async : false,
			success : function(data) {
				if (!data.result) {
					alert(data.content);
				}
				result = data.result;
			}
		});
	}
	return result;
}

// ws
// 功能 ： 添加包装数据--弹出填写框
// 参数 ：
// - string : metaKey
// 返回 ：
// - 无
function add_pack_info(e, metaKey) {
	$('#selected-spart-nr').html($(e).parent().prevAll('.spartNr').html());
	$('#selected-part-rel-key').val(metaKey);
	$("#pick-part-info-box").show();
}

// ws
// 功能 ：将选中零件加入 cart
// 参数 ：
// - 无
// 返回 ：
// - 无
function add_part_to_cart() {
	if ($('#selected-part-rel-key').val() != "") {
		var per = $("#selected-part-perpack");
		var packN = $("#selected-part-pack-num");
		var partNr = $("#selected-spart-nr").html();
		if (!isPositiveNum(per.val())) {
			alert('每包装箱量必须为正数！');
			per.val("");
			return;
		}
		if (!isPositiveInt(packN.val())) {
			alert('包装箱数必须为正整数！');
			packN.val("");
			return;
		}
		$.ajax({
			url : '../delivery/add_di_temp',
			dataType : 'json',
			data : {
				metaKey : $("#selected-part-rel-key").val(),
				packAmount : packN.val(),
				perPackAmount : per.val(),
				partNr : partNr
			},
			type : 'post',
			success : function(msg) { packN
				if (msg.result) {
					$("#pick-part-info-box").hide();
					per.val("");
					packN.val("");
					$('#selected-part-rel-key').val("");
					var t = msg.object;
					add_dit_to_cart(partNr, t.perPackAmount, t.packAmount, t.total, t.key);
				} else {
					alert(msg.content);
				}
			}
		});
	}
}

// ws
// 功能 ： 将运单项加入购物车
// 参数 ：
// - string : partNr
// - int : per
// - int : amount
// - int : total
// - string : mkey
// 返回 ：
// - 无
function add_dit_to_cart(partNr, per, amount, total, key) {
	if ($("#build-dn-btn").is(":hidden")) {
		$("#build-dn-btn").show();
	}
	var cart = $('#unfoldcart');
	var cartSize = cart.children('.cfirstlevel').size();
	// alert(cartSize);
	var lineclass = cartSize % 2 == 0 ? 'cartline cfirstlevel' : 'oddcartline cfirstlevel';
	var line = $("<div/>").attr('class', lineclass).html("<div class='partserialnmb'>" + (cartSize + 1) + "</div><div class='partscart'>" + partNr + "</div>" + "<div class='partscart'>" + per + "&nbsp;X&nbsp;" + amount + "&nbsp;=&nbsp;" + total + "</div>");
	var del = $("<div/>").attr('class', 'deleteparts').attr('id', key).css('cursor', 'pointer').html('X');
	// <div class='deleteparts' style='cursor:pointer;' id='"+mkey+"'>X</div>
	del.appendTo(line);
	line.appendTo(cart);
	del.bind('click', {
		id : del.attr('id')
	}, function(e) {
		delete_dit_from_cart(e.data.id);
	});
	line = null;
	del = null;
}

// ws
// 功能 ： 将包装从cart中移除
// 参数 ：
// - string : key
// 返回 ：
// - 无
function delete_dit_from_cart(key) {
	$.ajax({
		url : '../delivery/delete_dit',
		type : 'post',
		dataType : 'json',
		data : {
			tempKey : key
		},
		success : function(data) {
			if (data.result) {
				var p = $("[id='" + key + "']").parent();
				// reset cart item no
				var nexts = p.nextAll();
				var no = null;
				var ele = null;
				$.each(nexts, function(i, n) {
					ele = $(n).find(".partserialnmb");
					no = parseInt(ele.text() - 1);
					ele.html(no);
					$(n).attr('class', (no + 1) % 2 == 0 ? 'cartline cfirstlevel' : 'oddcartline cfirstlevel')
				});
				no = null;
				ele = null;
				nexts = null;
				//.....
				if (p.parent().children().size() == 1) {
					$("#build-dn-btn").hide();
				}
				p.effect("shake", {
					times : 1,
					distance : 30
				}, 500);
				p.fadeOut("slow", function() {
					p.remove();
					p = null;
				});
			}
		}
	});
}

// ws
// 功能 ： 清空运单项缓存
// 参数 ：
//  - 无
// 返回 ：
// - 无
function clean_staff_dit() {
	if (confirm('确定放弃运单？')) {
		var f = $("<form/>").attr("action", "../delivery/clean_dit").attr("method", "post");
		f.appendTo("body").submit();
	}
}

// ws
// 功能 ： 清空运单项缓存
// 参数 ：
//  - 无
// 返回 ：
// - 无
function update_staff_dit(key) {
	var tr = $("[id='" + key + "']");
	var per = tr.find('.pernum').val();
	var packN = tr.find('.packnum').val();

	if (!isPositiveNum(per)) {
		alert('每包装箱量必须为正数！');
		return;
	}
	if (!isPositiveInt(packN)) {
		alert('包装箱数必须为正整数！');
		return;
	}
	$.ajax({
		url : '../delivery/update_dit',
		dataType : 'json',
		data : {
			ditkey : key,
			packAmount : packN,
			perPackAmount : per
		},
		type : 'post',
		success : function(msg) {
			if (msg.result) {
				tr.find('.total').text(msg.object.total);
			} else {
				alert(msg.content);
			}
		}
	});
}

function delete_dit_from_list(key) {
	if (confirm('确定删除？')) {
		$.ajax({
			url : '../delivery/delete_dit',
			type : 'post',
			dataType : 'json',
			data : {
				tempKey : key
			},
			success : function(data) {
				if (data.result) {
					$("[id='" + key + "']").hide();
				} else {
					alert(data.content);
				}
			}
		});
	}
}

// ws
// 功能 ： 生成运单
// 参数 ：
//  - 无
// 返回 ：
// - 无
function build_delivery_note() {
	var desiOrgNr = document.getElementById('clientNr').value;
	show_handle_dialog();
	$.ajax({
		url : '../delivery/build_dn',
		type : 'post',
		dataType : 'json',
		data : {
			desiOrgNr : desiOrgNr
		},
		success : function(data) {
			if (data.result) {
				window.location = "../delivery/dn_detail?dnKey=" + data.object + "&t=p";
			} else {
				hide_handle_dialog();
				alert(data.content);
			}
		}
	});
}

// ws
// 功能 ： 根据运单号获得运单内容
// 参数 ：
//  - string : dnKey
// - int : pageIndex
// 返回 ：
// - 无
function get_dn_detail(type, pageIndex) {
	window.location = "../delivery/dn_detail?dnKey=" + $('#dnkey-hidden').val() + "&t=" + type + "&p=" + pageIndex;
}

// ws
// 功能 ： 发送运单
// 参数 ：
//  - object : 发送按钮
// 返回 ：
// - 无
function send_staff_dn(ele) {
	var desi = $("#destination-text");
	var sendDate = $("#sendDate-text");
	if (desi.val() == "" || sendDate.val() == "") {
		flash_message(".errparts");
	} else {
		show_handle_dialog();
		$.ajax({
			url : '../delivery/send_delivery',
			type : 'post',
			dataType : 'json',
			async : false,
			data : {
				dnKey : $('#dnkey-hidden').val(),
				destiStr : desi.val(),
				sendDate : sendDate.val()
			},
			success : function(data) {
				if (data.result) {
					desi.attr('disabled', true);
					$(ele).unbind('click').removeAttr('onclick').bind('click', function() {
						alert('运单已经发送成功，不可重复发送');
					});
					$('#cancelDeliverySendBtn').unbind('click').removeAttr('onclick').bind('click', function() {
						alert('已经发送成功，不可取消');
					});
				}
				hide_handle_dialog();
				alert(data.content);
			}
		});

	}
}

// ws
// 功能 ： 取消用户运单
// 参数 ：
//  - 无
// 返回 ：
// - 无
function cancel_staff_dn() {
	if (delete_dn_from_staff($('#dnkey-hidden').val())) {
		window.location = "../delivery/pick_part";
	}
}

/******** 运单查看部分js ****************/
// ws
// 功能 ： 初始化页面设置
// 参数 ：
// - 无
// 返回 ：
// - 无
function dn_list_ready() {
	$('.textsearchbox').keypress(function(event) {
		if (event.which == 13)
			$(this).find('input.startsearch').click()
	}).hover(function() {
		$(this).children().unbind('blur');
	}, function() {
		$(this).children().blur(function() {
			pop_cancel(this);
		});
	});

	// // date picker
	// $('#startdate-search-text').datepicker({
	// showButtonPanel : true
	// });
	//
	// $('#enddate-search-text').datepicker({
	// showButtonPanel : true
	// });
	//
	// auto complete
	$('#dn-search-text').autocomplete({
		source : "/delivery/redis_search_dn"
	});
	$('#client-search-text').autocomplete({
		source : "../organisation_manager/redis_search"
	});
	$('#supplier-search-text').autocomplete({
		source : "../organisation_manager/redis_search"
	});
	// dn way state and obj state
	$(".wayState[wayState='ALL']").click(function() {
		$('.search_label').children().remove().end().hide();
		search_dn();
	});
	// dn way state and obj state
	$(".wayState").not("[wayState='ALL']").click(function(e) {
		add_condition_node({
			wayState : {
				key : $(this).attr('wayState'),
				value : $(this).text()
			}
		});
	});
	$(".objState").click(function(e) {
		add_condition_node({
			objState : {
				key : $(this).attr('objState'),
				value : $(this).text()
			}
		});
	});

	// search box
	$("#dn-search-box>input.startsearch").click(function() {
		add_condition_node({
			dnKey : $("#dn-search-text").val()
		});
	});

	$("#rece-search-box>input.startsearch").click(function() {
		add_condition_node({
			receiver : $("#client-search-text").val()
		});
	});

	$("#sender-search-box>input.startsearch").click(function() {
		add_condition_node({
			sender : $("#supplier-search-text").val()
		});
	});

	$("#date-search-box>input.startsearch").click(function() {
		add_condition_node({
			date : [$("#startdate-search-text").val(), $("#enddate-search-text").val()]
		});
	});
	check_org_kn_queue();
	search_dn();
}

// ws
// 功能 ： 添加查询条件节点
// 参数 ：
// - hash : 查询条件
// 返回 ：
// - 无
function add_condition_node(hash) {
	$.each(hash, function(k, v) {
		var kv = null;
		if ( typeof (v) == 'string' || v.constructor == Array) {
			kv = v;
		} else {
			kv = v["key"]
		}
		if ($("#label_" + k).children("[" + k + "='" + kv + "']").size() == 0) {
			if ( typeof (v) == 'string')
				$('<span class="notifyNewForcast"></span>').attr('key', k).attr(k, v).text(v).appendTo($('#label_' + k)).click(function() {
					del_condition_node(k, v);
				});
			else if (v.constructor == Array) {
				$("#label_" + k).children().remove();
				$('<span class="notifyNewForcast"></span>').attr('key', k).attr('value-type', 'array').attr(k, v).text(v[0] + '~' + v[1]).appendTo($('#label_' + k)).click(function() {
					del_condition_node(k, v);
				});
			} else {
				$('<span class="notifyNewForcast"></span>').attr('key', k).attr(k, v["key"]).text(v["value"]).appendTo($('#label_' + k)).click(function() {
					del_condition_node(k, v["key"]);
				});
			}
			$('#label_' + k).show();
			search_dynamic();
		}
	});
}

// ws
// 功能 ： 删除查询条件节点
// 参数 ：
// - string : k - 节点Key
// - string : v - 节点Value
// 返回 ：
// - 无
function del_condition_node(k, v) {
	$("#label_" + k).children("[" + k + "=" + v + "]").remove();
	if ($("#label_" + k).children().size() == 0) {
		$('#label_' + k).hide();
	}
	search_dynamic();
}

// ws
// 功能 ： 获取组织运单队列未读运单数，并为提示添加事件
// 参数 ：
// - 无
// 返回 ：
// - 无
function check_org_kn_queue() {
	$.post('../delivery/count_dn_queue', function(data) {
		if (data.count > 0) {
			$('<span class="notifyNewForcast"></span>').text(data.count).appendTo($("div[wayState='ALL']")).click(function(e) {
				$('.search_label').children().remove().end().hide();
				search_dn({
					queue : true
				});
				e.stopPropagation();
			}).dblclick(function(e) {
				clear_org_kn_queue();
				search_dn();
				e.stopPropagation();
			});
		}
	}, 'json');
}

// ws
// 功能 ： 双击提示数字，清空组织未读运单
// 参数 ：
// - 无
// 返回 ：
// - 无
function clear_org_kn_queue() {
	$.post('../delivery/clean_dn_queue', function(data) {
		if (data.result) {
			$('.notifyNewForcast').remove();
		}
	}, 'json');
}

// ws
// 功能 ： 搜索运单
// 参数 ：
// - hash : condition
// - int : pageIndex
// 返回 ：
// - 无
function search_dn(condition, pageIndex) {
	if (condition == null)
		condition = {};
	if (pageIndex == null)
		pageIndex = 0;
	$.ajax({
		url : '../delivery/search_dn',
		type : 'post',
		data : {
			condition : condition,
			pageIndex : pageIndex
		},
		dataType : 'html',
		success : function(data) {
			$("#dn-list-div").html(data);
		}
	});
}

// ws
// 功能 ： 遍历条件节点，查询运单
// 参数 ：
// - 无
// 返回 ：
// - 无
function search_dynamic() {
	var condition = {};
	$(".search_label").children().each(function() {
		var t = $(this);
		var key = t.attr('key');
		if (condition[key] == null)
			condition[key] = [];
		if (t.attr('value-type') == 'array')
			condition[key].push(t.attr(key).split(','));
		else
			condition[key].push(t.attr(key));
	});
	search_dn(condition);
}

// ws
// 功能 ： 显示搜索框
// 参数 ：
// - 调用者 : e
// 返回 ：
// - 无
function pop_box(e) {
	var id = e.attributes['box'].nodeValue;
	$('#' + id).css({
		top : $(e).offset().top + $(e).height(),
		left : $(e).offset().left + $(e).width()
	}).show().find("input").get(0).focus();
}

// ws
// 功能 ： 隐藏搜索框
// 参数 ：
// - 调用者 : e
// 返回 ：
// - 无
function pop_cancel(e) {
	$(e).parent().hide();
}

// ws
// 功能 ： 生成标签PDF
// 参数 ：
// - 调用者 : 无
// 返回 ：
// - 无
function generate_dn_label_pdf(type) {
	var desi = $("#destination-text").val();
	var sendDate = $("#sendDate-text").val();
	if ((desi == "" || sendDate == "") && type == 100) {
		flash_message(".errparts");
	} else {
		show_handle_dialog();
		$.ajax({
			url : '../delivery/gen_dn_pdf',
			type : 'post',
			// async : false,
			data : {
				printType : type,
				dnKey : $("#dnkey-hidden").val(),
				destination : desi,
				sendDate : sendDate
			},
			dataType : 'json',
			success : function(data) {
				hide_handle_dialog();
				if (data.result) {
					window.open(data.content, '_blank');
					window.focus();
				} else {
					alert(data.content);
				}
			}
		});
	}
}

// ws
// 功能 ： 将运单添加到客户端打印列表
// 参数 ：
// - 调用者 : 无
// 返回 ：
// - 无
function add_dn_to_print_queue() {
	$.ajax({
		url : "../delivery/add_to_print",
		type : 'post',
		data : {
			dnKey : $("#dnkey-hidden").val()
		},
		dataType : 'json',
		success : function(data) {
			alert(data.content);
		}
	});
}

// ws
// 功能 ： 获取运单接收列表
// 参数 ：
// - 调用者 : 无
// 返回 ：
// - 无
function redirect_delivery_action(action, params) {
	if (params == null) {
		window.location = "../delivery/" + action + "?dnKey=" + $("#dnKey").val();
	} else {
		var p = "";
		for (var h in params) {
			p += "&" + h + "=" + params[h];
		}
		window.location = "../delivery/" + action + "?dnKey=" + $("#dnKey").val() + p;
	}
}

// ws
// 功能 ： 获取运单项css
// 参数 ：
// - integer : state code
// 返回 ：
// - 无

function get_dn_obj_state_css(state) {
	switch(state) {
		case 100:
			return 'normal';
		case 200:
			return 'abnorm'
	}
}

// ws
// 功能 ： 获取运输状态css
// 参数 ：
// - integer : state code
// 返回 ：
// - 无
function get_dn_obj_waystate_css(state) {
	switch(state) {
		case 100:
			return "instransit";
		case 400:
			return "received";
		case 600:
			return "returned";
		default :
			return "instransit"
	}
}

function trimEnd(str) {
	var reg = /,$/gi;
	return str.replace(reg, "");
}

function check_all() {
	var cbs = document.getElementsByTagName('input');
	var check = document.getElementById('check-all');
	for (var i = 0; i < cbs.length; i++) {
		if (cbs[i].type == "checkbox" && $("#" + cbs[i].id).attr("no-all-check") == null) {
			cbs[i].checked = check.className == 1 ? true : false;
		}
	}
	check.className = check.className == 1 ? 0 : 1;
}

function checked_ids() {
	var cbs = document.getElementsByTagName('input');
	var ids = "";
	for (var i = 0; i < cbs.length; i++) {
		if (cbs[i].type == "checkbox" && $("#" + cbs[i].id).attr("no-all-check") == null) {
			if (cbs[i].checked) {
				ids += cbs[i].id + ",";
			}
		}
	}
	return trimEnd(ids);
}

// ws
// 功能 ： 运单接收，拒收
// 参数 ：
// - type : 接受类型
// - action : action
// - pdata : 额外数据
// - call : 回调
// 返回 ：
// - 无
function pack_rece_reje(type, action, pdata, call) {
	var actions = {
		1 : "doaccept",
		2 : "mark_abnormal"
	};
	var ids = checked_ids();
	if (ids.length > 0) {
		if (confirm("确认执行此操作？")) {
			var data = {
				dnKey : $("#dnkey-hidden").val(),
				ids : ids,
				type : type
			};
			if (pdata != null) {
				for (var v in pdata) {
					data[v] = pdata[v];
				}
			}
			show_handle_dialog();
			$.ajax({
				url : "../delivery/" + actions[action],
				type : 'post',
				data : data,
				dataType : 'json',
				success : function(msg) {
					hide_handle_dialog();
					if (msg.result) {
						alert("操作成功！");
						ids = ids.split(",");
						if (action == 1) {
							for (var i = 0; i < ids.length; i++) {
								$("#waystate-th-" + ids[i]).attr('class', get_dn_obj_waystate_css(type)).html(msg.object);
							}
						} else if (action == 2) {
							for (var i = 0; i < ids.length; i++) {
								$("#state-th-" + ids[i]).attr('class', get_dn_obj_state_css(msg.object)).html(msg.content);
							}
						}
						if (call != null) {
							call();
						}
					} else {
						alert(msg.content);
					}
				}
			});
		}
	}
}

// ws
// 功能 ： 标记异常
// 参数 ：
// 返回 ：
// - 无
function mark_pack_abnormal() {
	if (checked_ids().length > 0) {
		var data = {
			desc : $("#check-desc-input").val()
		};
		pack_rece_reje($("#inspect_type").val(), 2, data, hide_inspect_box);
	} else {
		alert("请选择包装箱！");
		hide_inspect_box();
	}
}

// ws
// 功能 ： 设置运单状态为到达
// 参数 ：
// - 无
// 返回 ：
// - 无
function delivery_arrived() {
	show_handle_dialog();
	$.post('../delivery/arrive', {
		dnKey : $("#dnkey-hidden").val()
	}, function(msg) {
		if (msg.result) {
			$(".arrive-button-group").remove();
			$(".accept-button-group").show();
			$("[id^='waystate-th-']").attr('class', get_dn_obj_waystate_css(msg.wayStateCode)).html(msg.wayState);
			hide_handle_dialog();
		}
	}, 'json');
}

// ws
// 功能 ： 运单质检
// 参数 ：
// - type : 质检类型
// - action : action
// - pdata : 额外数据
// - call : 回调
// 返回 ：
// - 无
function pack_inspect(type, action, pdata, call) {
	var actions = {
		1 : "doinspect",
		2 : "doreturn"
	};
	var ids = checked_ids();
	if (ids.length > 0) {
		if (confirm("确认此操作？")) {

			var data = {
				dnKey : $("#dnkey-hidden").val(),
				ids : ids,
				type : type
			};
			if (pdata != null) {
				for (var v in pdata) {
					data[v] = pdata[v];
				}
			}
			show_handle_dialog();
			$.ajax({
				url : "../delivery/" + actions[action],
				type : 'post',
				data : data,
				dataType : 'json',
				success : function(msg) {
					hide_handle_dialog();
					if (msg.result) {
						alert("操作成功！");
						ids = ids.split(",");
						if (action == 1) {
							var checked = $("#pack-return-checkbox").attr("checked");
							for (var i = 0; i < ids.length; i++) {
								$("#check-th-" + ids[i]).html("是");
								$("#operate-th-" + ids[i]).html("");
								$("#state-th-" + ids[i]).attr('class', get_dn_obj_state_css(msg.object)).html(msg.content);
								if (checked != null) {
									$("#waystate-th-" + ids[i]).attr('class', get_dn_obj_waystate_css(msg.wayStateCode)).html(msg.wayState);
								}
							}
							if (call != null) {
								call();
							}
						} else if (action == 2) {

						}
					} else {
						if (msg.content) {
							alert(msg.content);
						} else {
							var mess = "下列包装箱不可退货：\n";
							for (var i = 0; i < msg.object.length; i++) {
								mess += $("#pack-key-th-" + msg.object[i]).html() + ";\n";
							}
							alert(mess);
						}
					}
				}
			});

		}
	}
}

// ws
// 功能 ： 打开质检数据填写窗口
// 参数 ：
// - 无
// 返回 ：
// - 无
function pop_pack_inspect(e) {
	if (checked_ids().length > 0) {
		$("#pick-part-info-box").show();
		var top = null;
		if (e.pageY - 400 > 100)
			top = e.pageY - 100;
		$("#pick-part-info-box").show();
		if (top != null) {
			$("#pick-part-info-box").offset({
				left : e.pageX,
				top : e.pageY - 400
			})
		}
	}
}

function abnormal_pack_inpect() {
	if (checked_ids().length > 0) {
		var data = {
			desc : $("#check-desc-input").val(),
			"return" : $("#pack-return-checkbox").attr("checked")
		};
		pack_inspect($("#inspect_type").val(), 1, data, hide_inspect_box);
	} else {
		alert("请选择包装箱！");
		hide_inspect_box();
	}
}

// ws
// 功能 ： 运单入库
// 参数 ：
// - dnKey : 运单key
// - id : package id
// - posiNr : 库位
// - ware : 仓库
// 返回 ：
// - 无
function pack_in_store(dnKey, id, posiNr, ware) {
	if (posiNr.length > 0) {
		$.ajax({
			url : "../delivery/doinstore",
			type : 'post',
			data : {
				dnKey : dnKey,
				id : id,
				posiNr : posiNr,
				ware : ware
			},
			dataType : 'json',
			success : function(msg) {
				if (msg.result) {
					$("#operate-th-" + id).html(posiNr);
					$("#store-th-" + id).html("是");
					$(".position:eq(" + ($(".position").index($("#" + id)) + 1) + ")").focus();
				} else {
					alert(msg.content);
				}
			}
		});
	}
}

// ws
// 功能 ： 运单退货
// 参数 ：
// - 无
// 返回 ：
// - 无
function return_delivery_note() {
	if (confirm("确认此操作？")) {
		show_handle_dialog();
		$.ajax({
			url : "../delivery/return_dn",
			type : 'post',
			data : {
				dnKey : $("#dnkey-hidden").val()
			},
			dataType : 'json',
			success : function(msg) {
				hide_handle_dialog();
				if (msg.result) {
					$("[id^='waystate-th-']").attr('class', get_dn_obj_waystate_css(msg.wayStateCode)).html(msg.wayState);
				} else {
					if (msg.content) {
						alert(msg.content);
					} else {
						var mess = "下列包装箱不可退货：\n";
						for (var i = 0; i < msg.object.length; i++) {
							mess += msg.object[i] + ";\n";
						}
						alert(mess);
					}
				}
			}
		});
	}
}

// ws
// 功能 ： 获取组织数据
// 参数 ：
// - 无
// 返回 ：
// - 无
function get_info_card(id,action,i) {
	var c={1:"/organisation_manager/",2:"/delivery/"};
	$.ajax({
		url : "../"+c[i]+action,
		data : {
			id : id
		},
		dataType : 'html',
		success : function(data) {
			$("#info-result").html(data);
		}
	});
}

// 功能 ： 获取运单异常项
// 参数 ：
// - id : 运单id
// - id : 运单key
// 返回 ：
// - 无
function get_abnormal_packs(id,key){
	window.open("../delivery/abnormal?id="+id+"&dnKey="+key,
	'newwindow',
	'height=700,width=600,top=200,left=200,toolbar=no,menubar=no,resizable=no,location=no, status=no');
}

function get_batch_pack(id){
	window.open("../delivery/pack?id="+id+"&dnKey="+$("#dnkey-hidden").val(),
	'newwindow',
	'height=700,width=600,top=200,left=200,toolbar=no,menubar=no,resizable=no,location=no, status=no');
}
