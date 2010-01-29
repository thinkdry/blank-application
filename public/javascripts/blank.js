//this line is for recognison of ajax method. cf rails cast 136!
jQuery.ajaxSetup({ 
    'beforeSend': function(xhr) {
        xhr.setRequestHeader("Accept", "text/javascript")
        }
})

$(document).ready(function () {	
	
    wasVisible = new Boolean(false);
	
    //General menu, script for uniqueness of visible element.
    $('a.menuDropButton').click(function(){
        wasVisible = false;
		
        if ($(this).next('div.subMenu').is(":visible")){
            wasVisible = true;
        }
		
        $('.subMenu:visible').each(function(){
            $(this).css("display","none");
        });
		
        if (wasVisible == false) {
            $(this).next('div.subMenu').css("display", "block");
        }
    });
	
    //Effect on tabs on mouse over.
    $('.munuElement').hover(
        function () {
            $(this).stop().animate({
                paddingRight: "25px"
            }, 200);
        },
        function () {
            $(this).stop().animate({
                paddingRight: "15px"
            });
        }
        );
	
    //Filter drop down in item list.
    $('.filter').live("click", function(){
        var self = $(this);
        self.next('ul.ddown').slideToggle('fast');
    });
	
	//Modal Box for footer reply
	$(".commentfooterReply").live('click',function(){
		$('#commentReply #comment_parent_id').val($(this).attr("id"));
		$.fn.colorbox({width:"660px", inline:true, href:"#commentReply"});
	});

    //RATING SYSTEM
    $('.auto-submit-star').rating({
        callback: function(value, link){
            var url = $("#submit_rating").attr("action");
            $.ajax({
                type: "POST",
                url :url,
                data: "rated="+value,
                success: function(){
                    $('input').rating('readOnly',true);
					//TODO translate
					$('#notice').showMessage("Your Rating Has Been Registered", 1500);
                }
            });
        }
    });

	// Translation ajax update
	$('.translation_field').live("dblclick", function(){
		section=$(this).attr("id").split('_');
	 	datas = "id=" + section[1] + "&section=" + $('#translation_' + section[1] + "_section").val() + "&subsection=" + $('#translation_' + section[1] + "_subsection").val() + "&key=" + $('#translation_' + section[1] + "_key").val() + "&value=" + $('#translation_' + section[1] + "_value").val();
		url= "/superadmin/translations/updating";       
          	$.ajax({
            	type: "PUT",
              	url :url,
              	data: datas,
              	success: function(){
					//TODO translate
					$('#notice').showMessage("Your update has been registered", 2000);
              	} 
			});   
	});

	//HINT FOR FORMS && AJAX VALIDATION
	$(".formElement input").focus( function() {	
		$(this).nextAll('.ajax_hint_message').css('display','inline');
	});
	$(".formElement textarea").focus( function() {	
		$(this).nextAll('.ajax_hint_message').css('display','inline');
	});
	$(".formElement input").blur( function(){
		if ($(this).attr("type") == "checkbox"){
			return null;
		}
		if ($(this).attr("noHint") == null){
			$(this).displayHintForField();
		}
	});
	
	$(".formElement textarea").blur( function(){
		$(this).displayHintForField();
	});
	
  	$('#notice').animate({
  		opacity: 1}, 1500, function(){
  	    	$(this).fadeOut('fast')
  	});
	
	$('#error_closing').live('click', function(){
		$('#error').fadeOut('fast');
	});
	
	$(".deleteLink").live('click', function(){
		var modalId = $(this).attr('modal_id')
		$.fn.colorbox({width:"300px", inline:true, href:modalId});
	});	
	$(".deleteClose").click(function(){
		$.fn.colorbox.close();
	});

	$('#fck_insert_image').colorbox({width:"600px", onComplete:function(){$('#images_tabs').tabs();}});
	$('#fck_insert_link').colorbox({width:"600px", onComplete:function(){$('#insert_link').tabs();}});
	$('#fck_insert_video').colorbox({width:"600px", onComplete:function(){$('#videos_tabs').tabs();}});
	$('#fck_insert_audio').colorbox({width:"600px", onComplete:function(){$('#audios_tabs').tabs();}});
	
	$('#fck_insert_gallery').colorbox({width:"700px"});
	
	$('#insert_gallery button').live('click', function(){
		//get the datas of checked checkboxes
		
		if ($('#gallery_name').val() == "" || $("#insert_gallery input:checked").length <= 0){
			$('#warning').html("Enter a name and select some pics");
		}
		
		else{
			var escapedName = $('#gallery_name').val().replace(/\./g, "_");
			escapedName = escapedName.replace(/:/g, "_");
			escapedName = escapedName.replace(/\//g, "_");
			escapedName = escapedName.replace(/ /g, "_");
		
			var data = { 'list_of_pics[]' : [], 'gallery_name' : escapedName};
		
			$("#insert_gallery input:checked").each(function() { data['list_of_pics[]'].push($(this).val());});
			//send the request
			$.ajax({
	        	type: "PUT",
	          	url: "/admin/ck_insert/gallery",
	          	data: data,
	          	success: function(html){
					//TODO translate
					CKEDITOR.instances.ckInstance.insertHtml(html);
					$.fn.colorbox.close();
	          	} 
			});
		}
	});
	
	$('#insert_image a').live('click', function(){
		stringToInsert = '<img src="' + $(this).attr("picSrc") +'" ';
		if ($('#image_align').val() != ""){
			stringToInsert += 'align="' + $('#image_align').val() +'" ';
		}
		if ($('#image_width').val() != "" && !isNaN($('#image_width').val())){
			stringToInsert += 'width="' + $('#image_width').val() + 'px" '; 
		}
		stringToInsert +=  + '"/>'
		
		$('#image_align').val("");
		$('#image_width').val("");
		
		CKEDITOR.instances.ckInstance.insertHtml(stringToInsert);
		
		$.fn.colorbox.close();
	});
	
	
	$('.item_list a').live('click', function(){
		stringToInsert = '';
		
		if (CKEDITOR.instances.ckInstance.getSelection().getNative() != ""){
			stringToInsert += '<a href="' + $(this).attr('itmUrl') + '">';
			stringToInsert += CKEDITOR.instances.ckInstance.getSelection().getNative();
			stringToInsert += '</a>';
		}
		
		CKEDITOR.instances.ckInstance.insertHtml(stringToInsert);
		
		$.fn.colorbox.close();
	});
	
	
	$('#insert_video a').live('click', function(){
		
		stringToInsert = '<embed ';
		if ($('#player_width').val() != "") {
			stringToInsert += 'width="' + ('#player_width').val() +'" '; 
		}else{
			stringToInsert += 'width="370" '; 
		}
		if ($('#player_height').val() != "") {
			stringToInsert += 'height="' + ('#player_height').val() +'" '; 
		}else{
			stringToInsert += 'height="257" '; 
		}
		
		stringToInsert +='flashvars="&image=' + $(this).attr('itmUrl') + '/2.png&file=' + $(this).attr('itmUrl') +'/video.flv"';
		stringToInsert += 'allowfullscreen="true" allowscriptaccess="always" quality="high" src="/players/videoplayer.swf" type="application/x-shockwave-flash"/>';
				
		CKEDITOR.instances.ckInstance.insertHtml(stringToInsert);
		
		$.fn.colorbox.close();
	});

	$('#insert_audio a').live('click', function(){
		stringToInsert = '<embed allowfullscreen="true" allowscriptaccess="always" quality="high"';
		stringToInsert += ' flashvars="&playerID=1&soundFile=' + $(this).attr('itmUrl');
		stringToInsert += '" src="/players/audioplayer.swf" type="application/x-shockwave-flash"/>';
		CKEDITOR.instances.ckInstance.insertHtml(stringToInsert);
		
		$.fn.colorbox.close();
	});
	
	$('.audit_changes_tip').tipsy();
	
	$('#filter').keyup(function(){
		var filter = $(this).val();
		var count = 0;
		
		$(".filtered:first li").each(function () {
			if ($(this).text().search(new RegExp(filter, "i")) < 0) {
		 		$(this).addClass("hidden");
			}else {
				$(this).removeClass("hidden");
		 		count++;
		 	}
		});		
		$('#number_of_item').html(count);
	});
	
	$('#comments_filter').keyup(function(){
		var filter = $(this).val();
		
		$(".filtered:first li").each(function () {
			if ($(this).text().search(new RegExp(filter, "i")) < 0) {
		 		$(this).addClass("hidden");
			}else {
				$(this).removeClass("hidden");
		 	}
			if ($(this).next('li').text().search(new RegExp(filter, "i")) < 0) {
				$(this).next('li').addClass("hidden");
			}else{
				$(this).next('li').removeClass("hidden");
			}
		});
	});
	
	$('#website_tabs').tabs();
	
	$('#add_website_url').click(function(){
		$(this).insert_field('website', '#website_url_names_list', 'website_url_names');
	});

	$('#add_level_one_menu').colorbox({width:"650px"});
	$('.add_sub_menu').colorbox({width:"650px"});
	
	$('#sortable').tablesorter(); 
		
	$('#translation_project').live('change', function(){	
		ajaxDivReplace($('#translation_project option:selected').attr('url'), "#language_configuration", "GET");
	});
	
	$('#translation_lang').live('change', function(){	
		ajaxDivReplace($('#translation_lang option:selected').attr('url'), "#language_configuration", "GET");
	});
	
	$('#translation_dropdown').live('change', function(){
		var data = { 'language_id' : $('#language_id').val(), 'project_id' : $('#project_id').val(), 'translation[translation_dropdown]' : $('#translation_dropdown option:selected').val() };
		$.ajax({type: "GET",
				data: data,
		   	 	url: $(this).attr('url'),
		  	    success: function(html){
		  			$('#language_configuration').html(html);
		       }
		 });
	});
	
	// ************************************************************
	// When keyword field got focus, submit is disable, user can add
	// Keyword by pressing enter.
	// When, keyword field loose focus, submit can be clicked
	// ************************************************************
	
	// $('form').submit(function(){
	// 	alert($('#submit_state').attr("disable"));
	// });
	// 
	// $('#keyword_value').focus(function(){
	// 	$('#submit_state').attr("disabled", "true");
	// 	alert($('#submit_state').attr("disable"));
	// });
	// 
	// $('#keyword_value').blur(function(){
	// 	$('#submit_state').removeAttr("disabled");
	// });
	// 
	// $('#keyword_value').keyup(function(e) {
	//     if(e.keyCode == 13) {
	//         insert_keyword($(this).next('a').attr('itemclass'),"#keywords_list", "keywords_field");
	//     }
	// })
});


function ajaxDivReplace(url, div, method){
	 $.ajax({type: method,
	     	 url: url,
	  	     success: function(html){
	  			$(div).html(html);
	     	}
	 });
}


function ajaxSaveOfFCKContent(){
	
	var url = $('#ajax_save_url').val();
	var itemId = $('#item_id').val();
	var body = CKEDITOR.instances.ckInstance.getData();
	
	//if item has been saved before (get an id... in wich you can save!!)
	if (itemId != ""){
		$.ajax({
	        type: "PUT",
	        url: url + itemId,
			data: 'content=' + escape(body),
	        success: function(html){
				$('#notice').showMessage(html, 1500);
	        }
	    });
	}
	else {
		//TODO translate
		$('#notice').showMessage("Save the whole article first", 1500);
	}
}

jQuery.fn.showMessage = function(message, delay){
	$('#notice').html(message);
	$('#notice').css('display', 'block');
	$('#notice').animate({opacity: 1}, delay, function(){$(this).fadeOut('fast')});
}

jQuery.fn.displayHintForField = function(){
	//hide the hint message
	$(this).nextAll('.ajax_hint_message').css('display','none');
	//ajax validation called with attribute embeded in the input file
	var model = $(this).attr("itemclass");
	var attribute = $(this).attr("validate");
	var value = $(this).val();
	var inputConcerned = $(this);
	//lauch ajax validation on server for the current field
	$.ajax({
        type: "POST",
        url: $(this).attr("url"),
        data: "model="+model+"&attribute="+attribute+"&value="+value,
        success: function(html){
			element = "#hint_for_" + model + "_" + attribute;
			//if there is an error
			if (html != ""){
				//remove the previous error message
				$(element).find('.formError').remove();
				//add the new error message
				$(element).find('.hintMessage').append(html);
				//put red border on relative input
				$(inputConcerned).css('border', '1px solid red');
			}
			else{
				//remove the form error
				$(element).find('.formError').remove();
				//remove the red border
				$(inputConcerned).css('border', '1px solid #ccc');
			}
        }
    });
}

function itemUploadComplete(stringToInsert){
	CKEDITOR.instances.ckInstance.insertHtml(stringToInsert);
	$.fn.colorbox.close();
	$('#image_file').val("");
	$('#video_file').val("");
	$('#audio_file').val("");
}

function autocomplete_on(array, div){

    if(div == '#keyword_value'){
        $(div).autocomplete(array);
    }
    
    if (div == '#user_login'){
        $(div).autocomplete(array,{
            minChars: 0,
            width: 310,
            matchContains: "word",
            autoFill: false,
            formatItem: function(row, i, max) {
                return row.login + "[" + row.name + "]" + "[" + row.email + "]";
            },
            formatMatch: function(row, i, max) {
                return row.login + " " + row.name + " " + row.email;
            },
            formatResult: function(row) {
                return row.login;
            }
        });
    }
}


function classify_bar(url) {
    $.ajax({
        type: 'GET',
        url: url,
        dataType: "script",
        success:function(html){
			
        }
    });
}


function add_new_user(url){
    var user_login = $('#user_login').val();
    var role_id = $('#user_role').val();
    if(user_login != 0){
        if($("#workspace_user_" + user_login)[0] == null){
            $.ajax({
                type: 'GET',
                url: url,
                data: "user_login="+user_login+"&role_id=" + role_id,
                dataType: "script",
				success:function(html){
					$('#notice').showMessage("User Added Successfully", 1500);
				}
            });
        }else{
			//TODO translate
            $('#warning').showMessage("User is already existing", 1500);
        }
        $('#user_login').val('');
    }

}

function show_people(container_id){
    var start_with = $('#start_with').val();
    var group_id = $('#group_id').val();
    var url = "/admin/workspaces/"+container_id+"/groups/filtering_contacts/";
    $.ajax({
        type: 'GET',
        url: url,
        data: "start_with="+start_with+"&group_id="+group_id,
        dataType: "script"
    });
}

function selectAll(chkObj,id){
    var multi=document.getElementById(id);
    if(chkObj)
        for(i=0;i<multi.options.length;i++)
            multi.options[i].selected=true;
    else
        for(i=0;i<multi.options.length;i++)
            multi.options[i].selected=false;
}


function insert_keyword(model_name, place, field_name){
    var name = $('#keyword_value').val();
    var key_words = name.split(',')
    for(var i=0; i < key_words.length; i++){
        var name = key_words[i].replace(/(^\s+|\s+$)/g, "");
        name = replaceChar(name, ".","_")
        if(name != 0 && name.length == (name.replace(/<(\S+).*>(|.*)<\/(\S+).*>|<%(.*)%>|<%=(.*)%>+/g, "")).length){
            var hidden_field = "<input type='hidden' id='"+model_name+"_"+field_name+"' value='"+name+"' name='"+model_name+"["+field_name+"][]'>";
            $(place).append("<div id='"+name+"' class='keyword_label'><span>"+hidden_field+name+"</span><a href='#' onclick='$(\"#" + name + "\").remove(); return false;'>X</a></div>")
        }
        $('#keyword_value').val('');
		$('#keyword_value').focus();
    }
}

jQuery.fn.insert_field = function(model_name, place, field_name){
    var name = $('#website_url_name_value').val();
	var escapedName = name.replace(/\./g, "_");
	escapedName = escapedName.replace(/:/g, "_");
	escapedName = escapedName.replace(/\//g, "_");
    var field_values = name.split(',');
    for(var i=0; i < field_values.length; i++){
        var name = field_values[i].replace(/(^\s+|\s+$)/g, "");
        if(name != 0 && name.length == (name.replace(/<(\S+).*>(|.*)<\/(\S+).*>|<%(.*)%>|<%=(.*)%>+/g, "")).length){
            var hidden_field = '<input type="hidden" id="'+model_name+'_'+field_name+'" value="'+name+'" name="'+model_name+'['+field_name+'][]"/>';

			var siteUrlField = '<div id="' + escapedName + '" class="keyword_label"><span>' + hidden_field + name + '</span>';
			siteUrlField += '<a href="javascript:;" onclick="$(\'#' + escapedName + '\').remove();">X</a></div>';
			
            $(place).append(siteUrlField);
        }
        $('#website_url_name_value').val('');
		$('#website_url_name_value').focus();
    }
}

// Function to get encodig progress
function get_encoding_progress(item_id,item_type){
  var url = "/admin/"+item_type+"s/"+item_id+"/get_"+item_type+"_progress";
  $.ajax({
    type: "GET",
    url: url,
    data: "check=true",
    success: function(response){
      if(response == 'encoded'){
	      $.ajax({
	        type: "GET",
	        url: url,
	        data: "check=false",
	        dataType: "script"
	      });
	    }else if(response == 'encoding_error'){
	      $.ajax({
	        type: "GET",
	        url: url,
	        data: "check=false&status=fail"
	      });
	    }else{
	      get_encoding_progress(item_id,item_type);
	    }
    }
  });
}

var file1="";
function LimitAttach(form, file, allowed_types, alert_message) {
    var a = $('#submit_button');
    allowSubmit = false;
    if(file1 == file) return;
    if (!file) return;
    while (file.indexOf("\\") != -1)
        file = file.slice(file.indexOf("\\") + 1);
    ext = file.slice(file.lastIndexOf(".")).toLowerCase();
    for (var i = 0; i < allowed_types.length; i++)
    {
        if (allowed_types[i] == ext) {
            allowSubmit = true;
            a.disabled = '';
            break;
        }
    }
    if (!allowSubmit){
        alert(alert_message)
        a.disabled = 'true';
    }
}

// to move option value from one select box to another select box
function shiftRight(removeOptions,addOptions,saveFlag)
{
    var availableOptions = document.getElementById(removeOptions);
    var assignedOptions = document.getElementById(addOptions);
    var selcted_Options = new Array();
    for(i=availableOptions.options.length-1;i>=0;i--)
    {
        if(availableOptions.options[i].selected){
            var optn = document.createElement("OPTION");
            optn.text = availableOptions.options[i].text;
            optn.value = availableOptions.options[i].value;
            assignedOptions.options.add(optn);
            availableOptions.remove(i);
        }else{
            selcted_Options.push(availableOptions.options[i].value);
        }
    }

    document.getElementById('selected_Options').value = selcted_Options
}

function selectItemTab(idSelected){
		
    // get the tabs links on witch we should change the class
    var tabsElements = document.getElementById('tabs').getElementsByTagName('li');
		
    for (var i = 0 ; i < tabsElements.length ; ++i){
        if (tabsElements[i].id == idSelected){
            tabsElements[i].className = 'selected';
        }
        else{
            tabsElements[i].className = '';
        }
    }
}

function shiftLeft(removeOptions,addOptions,saveFlag)
{
    var availableOptions = document.getElementById(removeOptions);
    var assignedOptions = document.getElementById(addOptions);
    var selcted_Options = new Array();
    for (i=0;i<assignedOptions.options.length; i++){
        selcted_Options.push(assignedOptions.options[i].value);
    }
    for (i=0; i<availableOptions.options.length; i++){
        if (selcted_Options.indexOf(availableOptions.options[i].value) <0 && availableOptions.options[i].selected) {
            selcted_Options.push(availableOptions.options[i].value);
            var optn = document.createElement("OPTION");
            optn.text = availableOptions.options[i].text;
            optn.value = availableOptions.options[i].value;
            assignedOptions.options.add(optn);
        }
    }
    for(i=availableOptions.options.length-1;i>=0;i--)
    {
        if(availableOptions.options[i].selected)
            availableOptions.remove(i);
    }
    document.getElementById('selected_Options').value = selcted_Options;
}

function replaceChar(str, from_char, to_char){
  for(var i=0;i < str.length;i++){
    if(str[i] == from_char){
      str = str.replace(from_char,to_char);
    }
  }
  return str;
}

function add_new_follower(){
    //getting the mail value
    var email = $('#new_follower_email').val();
    //cleaning for jQuery to understand the div ID.
    var emailDivId = replaceChar(email, "@","_")
    var emailDivId = replaceChar(emailDivId, ".", "_");
	
    if(email != 0){
        //creating a new div with ID, for deletion possible.
        var new_email = "<div id='" + emailDivId + "'>";
        new_email += email + " | <a onclick=\"$('#" + emailDivId + "').remove()\">DELETE</a>";
        new_email += "<input type='hidden' name='configuration[sa_exception_followers_email][]' value='"+email+"'></div>";

        //adding the mail to the follower list.
        $('#followers_email').append(new_email);
        //reseting form.
        $('#new_follower_email').value = '';
    }
}

