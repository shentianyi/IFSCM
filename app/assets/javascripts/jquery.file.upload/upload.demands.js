/*
 * jQuery File Upload Plugin JS Example 6.7
 * https://github.com/blueimp/jQuery-File-Upload
 *
 * Copyright 2010, Sebastian Tschan
 * https://blueimp.net
 *
 * Licensed under the MIT license:
 * http://www.opensource.org/licenses/MIT
 */

/*jslint nomen: true, unparam: true, regexp: true */
/*global $, window, document */

$(function() {'use strict';

	// Initialize the jQuery File Upload widget:
	$('#demandupload').fileupload({
		dataType:'json',
		beforeSend : function(xhr) {
			xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
		},
		success : function(data) {
			// alert(data.object.index);
			$('#batchId').val(data.object.key); 
			
			if(data.object.items.length>0){
			     $('#fileId').val(data.object.items[0].key);
			    for(var i=0;i<data.object.items.length;i++){
			         $('#items').append(i+">fileId:::<p>"+data.object.items[i].key+"</p>");
			    }
			}
		},
		error : function() {

		},
		done : function(e, data) {
			data.context.text('Upload finished.');
		}
	});

	// settings:
	$('#demandupload').fileupload('option', {
		singleFileUploads : false,
		maxFileSize : 50000000,
		acceptFileTypes : /(\.|\/)(csv)$/i
	});
});
