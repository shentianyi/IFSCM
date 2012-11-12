/**
* 被锁定的按钮的样式
* 提示激活信件发送成功的提示框样式
 * 
 */



/**
 * 负责A0页面的JS效果
 * brix: BrilliantX主对象
 *   author Tianyi Shen
 * 
 */

var brix = brix || {};
brix.configs={};
brix.configs.lang="zh-cn";
brix.configs.effect={};
brix.configs.effect.shake={};
brix.configs.effect.shake.options={"times":6,"distance":5};
brix.configs.effect.shake.speed=20;




/*
 * 选择器映射器，用于存储选择器常量。
 */
var nameMapping = {
	"regButton" : "#jid_showReg", //注册按钮
	"regBody" : "#signup", //注册窗体
	"regClose":"#jid_regClose", //注册窗体的关闭键
	"signMail":"#jid_email", //登入页面的邮件文本框
	"signPsw":"#jid_psd", //登录页面的密码文本框 
	"signSubmit":"#jid_submit",
	"signSubItems":"",
	"signBody":"#signin",
	"regPsw":"#jid_reg_psd",//注册窗体内的密码文本框
	"regPswConf":"#jid_reg_psdcheck",//注册窗体内的密码确认文本框
	"overlay":".overlay", //灰度蒙版窗体
	"toValidate":"toValid", //需要验证属性
	"cls_err": ".error", //文本框出错时的样式的类
	"cls_msg_error":".uperror", //存储错误文本的类
	"signError":'#signError',
	"regSubmit":"#jid_regSubmit",
	"regVerifyImg":"verify",
	"regSubItems":"",
	"activateBody":"#activate",
	"activMsg":"#actimess",
	"activClose":"#jid_actClose",
	"activButton":"#jid_actSubmit",
	"resendMsg":"#resendSucess",
	"regErrorSumm":"#jid_errSummary",
	"lockedBt":".btlock"
	};
	
	var urlMapping = {
		"getVcode":"",
		"signUp":"/login",//登陆的Ajax请求地址在此修改
		"register":"../user/create",
		"main":"/welcome", //登陆成功后跳转的页面地址在此修改
		"regSuccess":"",
		"resend":"../user/sendmail"
	};
	
	var existTypeUrl = {
		"username":"../user/useraddrCheck"
	};


	// var msgs = {
		// "notActivated":"您的帐号还未激活，如果您尚未收到激活邮件，请点击下面的按钮重新获取获取地址",
		// "toActivate":"注册成功，一封激活邮件已经发至您的注册邮箱，如果在十分钟内仍然未收到激活邮件，请点击下面的按钮重新获取链接"
	// };

//whether the browser supports placeHolder; 
//the result will be made by isPlaceHolderSupportstored
// and stored in this varible. 
brix.isPhSupport = "pl";


//set an input element to support placeholder
//you can set your own class and send the selector in like "./needPh"
//or simply use placeholder attribute and input "input[placeholder]"
//the function will enable all the input element with a plcaeholder
//attribute;
brix.enablePlaceholder=function(selector){
		if (!this.isPlaceHolderSupport()){
			if (typeof selector === 'string'){
			$(selector).placeholder();
			};
	};
};


/*
 * 检查浏览器是否支持placeholder特性
 * 检查结果缓存在isPhSupport变量中
 */
brix.isPlaceHolderSupport = function(){
	if (this.isPhSupport!=="pl"){
		return this.isPhSupport;
	}
	else {
		var i = document.createElement("input");
		this.isPhSupport =  'placeholder' in i;
		return this.isPhSupport
	};
};


/*
 * 注册窗口所需要的方法与对象
 */
brix.signupUtil={};

brix.signupUtil.isAllValidate={};

/*
 * 注册窗口发生事件时所需要的清理工作
 */

// brix.signupUtil.clearRegInput = function(){
	// $(nameMapping.signPsw).val("");
	// $(nameMapping.regPsw).val(""); //去除密码框内容
	// $(nameMapping.regPswConf).val("");//去除密码确认框内容
// };


/*
 * bind events to show/hide the registration window.
 * 	and define the animation behavior of the elements.
 */

brix.signupUtil.bindEvents = function(){
	var lockButton = function(selector){
		$(selector).attr("disabled","disabled");
		//$(selector).addClass(nameMapping.lockedBt);
	};
	var releaseButton =function(selector){
		$(selector).removeAttr("disabled");
		//$(selector).removeClass(nameMapping.lockedBt)
	};
	
	var showDialog=function(selector){ $(nameMapping.overlay)
									.attr("style","opacity:0;display:block")
									.animate({opacity:0.8},300,function(){ //通过动画效果展现灰度蒙版
										$(selector)
											.attr("style","opacity:0;display:block")
											.animate({opacity:1},300);});};
											
	var hideDialog = function(selector){
			$(nameMapping.overlay)
				.animate(
					{opacity:0},700,function(){ //通过动画隐去灰度蒙版
						$(this).attr("style","display:none");//最终隐去
			});
		$(selector).attr("style","display:none");
	};
	
	var shakeDialog = function(selector){
		$(selector)
					  .effect("shake", 
					  						brix.configs.effect["shake"].options,
					  						brix.configs.effect["shake"].speed)
	};


	
	
	$(nameMapping.signSubmit)
		.unbind('click')
		.bind("click",function(event){
		lockButton(nameMapping.signSubmit);
		$(nameMapping.signError + "> p").text("");
		
			$.ajax(
				{url:urlMapping.signUp,
					timeout:10000,
					type:"POST",
					dataType:"json",
					data:{"staffNr":$(nameMapping.signMail).val(),"password":$(nameMapping.signPsw).val()},
					/*
					beforeSend:function(){
						$(nameMapping.signSubmit).attr("style","visibility:hidden");
					},
					*/
					success:function(data){
						switch(data.status){
							case 0:
								$(nameMapping.signError + "> p").text("请输入正确的用户名和密码");
							$(nameMapping.signError).attr("style","visibility:visible");
							// $(nameMapping.signBody)
								// .effect("shake", brix.configs.effect["shake"].options,brix.configs.effect["shake"].speed);
							break;
							
							case 1:
								//转到index action ../main
								window.location.href=urlMapping.main;
							break;
								
							//case 2: //已注册未验证
								//$(nameMapping.activMsg).text(msgs.notActivated);
								//showDialog(nameMapping.activateBody);
							//break;
							default:
							
							break;
						}
					},
					
					complete: function(){
						releaseButton(nameMapping.signSubmit);
					},
					
					error:function(data){
						$(nameMapping.signError + ">p").text("我们的服务似乎暂时不能使用，请稍后再试");
							$(nameMapping.signError).attr("style","visibility:visible");
							
							$(nameMapping.signBody)
								.effect("shake", brix.configs.effect["shake"].options,brix.configs.effect["shake"].speed);
					} //communication failed.Show nothing to the users. 
					});
				});
					//showDialog(nameMapping.activateBody);});//for debug
	//	});
	
		
	
	/**$(nameMapping.regButton)
	.unbind('click') //去除可能已存在的handler
	.bind('click',function(){
		showDialog(nameMapping.regBody);
		});	 //开始显示注册窗体**/
	
		//显示验证码，并绑定验证码点击事件，点击后验证码自动更新
		/**
		$(nameMapping.regVerifyImg).unbind('click')
			.bind('click',function(){
				$(this).attr("src",urlMapping.getVcode + "/r=" + Math.random());
			})
			.attr("src",urlMapping.getVcode);
	**/
	
	
	/**$(nameMapping.regClose)
		.unbind('click')
		.bind('click',function(){
			brix.signupUtil.clearRegInput(); //去除密码内容
			hideDialog(nameMapping.regBody);
	});
	
	$(nameMapping.activClose)
		.unbind('click')
		.bind('click',function(){
			hideDialog(nameMapping.activateBody);
			brix.signupUtil.clearRegInput();
		});
		
		
		$(nameMapping.activButton).unbind('click')
		.bind('click',function(){
			hideDialog(nameMapping.activateBody);
				$(nameMapping.resendMsg).attr("style","display:block");
				$(nameMapping.resendMsg).delay(1500).animate({opacity:0},800);
			$.ajax({
				url:urlMapping.resend,
				data:{"useraddr":$(nameMapping.signMail)}
			});
		});**/
		
		/**$(nameMapping.regSubmit).unbind('click')
		.bind('click',function(){
					$(nameMapping.regErrorSumm + ">p").text("");
					$(nameMapping.regErrorSumm).removeAttr("style");
				
			lockButton(nameMapping.regSubmit);	
					
			for(i in brix.signupUtil.isAllValidate){
				if(brix.signupUtil.isAllValidate[i]===false){
					shakeDialog(nameMapping.regBody);
					$(nameMapping.regErrorSumm + ">p").text("请先填写完整所有项目");
					$(nameMapping.regErrorSumm).attr("style","display:block");
					releaseButton(nameMapping.regSubmit);
					return false;
				};
			};
			
			$.ajax({
				url:urlMapping.register,
				data:{"useraddr":$(nameMapping.regMail).val(),
								"password":$(nameMapping.regPsw).val(),
								"password_confirm":$(nameMapping.regPswConf).val(),
								"name":$(nameMapping.regName).val()},
				success:function(data){
					if(data.status==true){
						window.location.href=urlMapping.regSuccess;
					}
					else{
						if(data.errors){
							$(nameMapping.regErrorSumm + ">p").text("出错了！" + data.errors[0]);
						};
					};
					shakeDialog(nameMapping.regBody);
					  						
					$(nameMapping.regErrorSumm).attr("style","display:block");
					
				},
				complete:function(data){
					releaseButton(nameMapping.regSubmit);
				},
				error:function(data){
					shakeDialog(nameMapping.regBody);
					$(nameMapping.regErrorSumm + ">p").text("我们的服务暂时不可用，请稍后再试");
					$(nameMapping.regErrorSumm).attr("style","display:block");
					
				}
			});
		});**/
	};






/*
 * bind event handler for validation of inputs
 */

/**

brix.signupUtil.bindValidateInputsEvent=function(){

	$('*[' + nameMapping.toValidate + ']').each(function(){ //寻找所有带有toValid属性的元素
		
		brix.signupUtil.isAllValidate[$(this).attr("id")]=false;
		
		
		  //toValid属性支持项目：required,equalto,mail,exists
		  
		 
		
		var toValids = $.parseJSON($(this).attr(nameMapping.toValidate)); //获取需要验证的项目
		
		$(this).unbind('blur');

		for(j in toValids){
				toValids[j] && toValids[j].params && toValids[j].params.selectors && function(){
					for (var k in toValids[j].params.selectors) //将保存的选择器转化为jquery对象
						if(typeof toValids[j].params.selectors[k] == "string"){
							toValids[j].params.selectors[k]= $(toValids[j].params.selectors[k]);
						}
				}();
		};
		
		
			$(this).bind('blur',{"toValids":toValids},function(eventObj){
			var breaker = true;
			for (i in eventObj.data.toValids){
				eventObj.data.params = eventObj.data.toValids[i].params;
				breaker = brix.signupUtil.validate[eventObj.data.toValids[i].type](eventObj);
				if (breaker===false){
					brix.signupUtil.isAllValidate[$(this).attr("id")]=false;
					break;
				} ;
				brix.signupUtil.isAllValidate[$(this).attr("id")]=true;
			};
		});
	});
};**/


/**
brix.signupUtil.validate={
	_showError:function(obj,errTxt){
			$(obj).hasClass(nameMapping.cls_err)||$(obj).addClass(nameMapping.cls_err);
			$(obj).siblings(nameMapping.cls_msg_error).attr("style","visibility:visible");
			$(obj).siblings(nameMapping.cls_msg_error).text(errTxt);
	},
	
	_hideError:function(obj){
			$(obj).hasClass(nameMapping.cls_err)||$(obj).removeClass(nameMapping.cls_err);
			$(obj).siblings(nameMapping.cls_msg_error).attr("style","visibility:hidden");
	},
	
	
	mail:function(eventObj){
		var _validateMail = function(eventObj){
			if(!brix.signupUtil.validator.mail(eventObj.target.value)){
				brix.signupUtil.validate._showError(eventObj.target,eventObj.data.params.errorStr);
				return false;
			}
			else{
				brix.signupUtil.validate._hideError(eventObj.target);
				return true;
			};
		};
		
			return _validateMail(eventObj);
		
	},
	
	required:function(eventObj){
		var errStr =""; 
		errStr= eventObj.data.params && eventObj.data.params.reqError || eventObj.data.params.errorStr;
				if (!brix.signupUtil.validator.required(eventObj.target.value)) {
		  brix.signupUtil.validate._showError(eventObj.target,errStr);
			return false;
			}
		else {
		  brix.signupUtil.validate._hideError(eventObj.target);
			return true;
		}
	},
	
	equalto:function(eventObj){
		var _validateEqualTo = function(eventObj){
			if (!brix.signupUtil.validator.equalto(eventObj.target.value,eventObj.data.params.selectors.toCompare.val())){
				brix.signupUtil.validate._showError(eventObj.target,eventObj.data.params.errorStr);
				return false;			
			}
			else{
				brix.signupUtil.validate._hideError(eventObj.target);
				return true;
			};
		};
	
		return 	_validateEqualTo(eventObj);
	},
	
	exist:function(eventObj){
		var _validateExist= function(eventObj){
			var sendData = {};
			sendData.existObj=eventObj.target.value;
			if (brix.signupUtil.validator.exist(sendData,existTypeUrl[eventObj.data.params.existType])===true){
				brix.signupUtil.validate._showError(eventObj.target,eventObj.data.params.errorStr);
				return false;
			}
			else{
				brix.signupUtil.validate._hideError(eventObj.target);
				return true;
			};
		};
			return _validateExist(eventObj);
	},
	
	minLength:function(eventObj){
			if (!brix.signupUtil.validator.minLength(eventObj.target.value)){
				brix.signupUtil.validate._showError(eventObj.target,eventObj.data.params.errorStr);
				return false;			
			}
			else{
				brix.signupUtil.validate._hideError(eventObj.target);
				return true;
			};
	}
};**/

/**
brix.signupUtil.validator={
	mail:function(value){return /^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))$/i.test(value);},
	
	required:function(str){return str.length>0;},
	
	equalto:function(val1,val2){
		return val1===val2;},
		
	exist:function(sendData,postUrl){
		$.ajax(
			{url:postUrl,
				type:"POST",
				dataType:"json",
				data:sendData,
				success:function(data){
					return data.status;
				},
				error:function(data){return false;} //communication failed.Show nothing to the users. 
					});
	},
	minLength:function(val){
		return val.length>=6;
	}
}**/










