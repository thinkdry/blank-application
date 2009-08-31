function initialize()
{
}

function showhide(id){
    if (document.getElementById){
        obj = document.getElementById(id);
        if (obj.style.display == "none"){
            obj.style.display = "";
        }
        else
        {
            obj.style.display = "none";
        }
    }
}


var file1="";
function LimitAttach(form, file, allowed_types, alert_message) {
    var a = $('submit_button');
    
//    if(type=="audio"){
//        extArray = new Array(".wav",".mp3",".wma",".mp4");
//    }
//    if(type=="video"){
//        extArray = new Array(".mov", ".mpeg", ".mpg", ".3gp", ".flv", ".avi");
//    }
//    if(type=="image"){
//        extArray = new Array(".gif", ".jpg", ".jpeg", ".png", ".bmp");
//    }
//    if(type=="cmsfile"){
//        extArray = new Array(".txt",".doc",".pdf");
//    }
    allowSubmit = false;
    if(file1==file) return;
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



function changer(pop, objects)
{
    reset(objects);
    if(pop=="select")
        return
    else
        $(pop).show();
}

function reset(objects)
{
    var nodes = objects.evalJSON();
    nodes.each(function(node) {
        $(node).hide();
    });
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
              
function selectTab(idSelected, ajax){

    if (ajax==undefined) {
        //to_box is the id of the container div of the tabs, where content is displayed.
        var content = document.getElementById('top_box');
		
        var HTMLNewContent = '<div width="100%" align="center"><img src="/images/ajax-loader.gif" align="center"/></div>';
		
        content.innerHTML = HTMLNewContent;
    }
		
    // get the container witch contains the tabs
    var tabsElement = document.getElementById('tabs');
		
    // get the tabs links on witch we should change the class
    var tabsElements = tabsElement.getElementsByTagName('a');
		
    for (var i = 0 ; i < tabsElements.length ; ++i){
        if (tabsElements[i].id == idSelected){
            tabsElements[i].className = 'active';
        }
        else{
            tabsElements[i].className = '';
        }
    }
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
	
	
//display the good tiem in a item list, google way of displaying.
function toggleAccordion(idClicked){
    var items_length = document.getElementById("total_items").value;
    for (var i=0 ; i < items_length ; ++i){
        var item_element = document.getElementById("itemInformations_"+i);
        if ("itemInformations_"+i != idClicked){
            item_element.style.display = 'none';
            item_element.parentNode.className = 'item_in_list';
        }else{
            if(item_element.style.display == 'none'){
                item_element.style.display = '';
                item_element.parentNode.className = 'selected_item_in_list';
            }else{
                item_element.style.display = 'none';
                item_element.parentNode.className = 'item_in_list';
            }
        }
    }
}

// To add a params from the current url and reload the page
function params(item_url, parent_id){
    if (item_url.indexOf('?') > 1){
        window.location.href = item_url + "&" + parent_id ;
    }else{
        window.location.href = item_url + "?" + parent_id ;
    }
}

// To add or replace a filter in the current url and reload the page
function params_filter(parent_id){
    if (window.location.href.indexOf('?') > 1 ) {
        window.location.href = window.location.href.split('?')[0] + "?" + parent_id ;
    } else {
        window.location.href = window.location.href + "?" + parent_id ;
    }
}

// To remove a param from the current url and reload the page
function remove_param(parent_id){
    if (window.location.href.indexOf('?'+parent_id) > 1){
        window.location.href = window.location.href.replace("?"+parent_id,"");
    }else{
        window.location.href = window.location.href.replace("&"+parent_id,"");
    }
}

// to check to date is grater than from or not if to date is present
function do_search(message){
    var valid = true;
    if ($("search[created_after]") && $("search[created_before]")){
        var from = $("search[created_after]").value;
        var to = $("search[created_before]").value;
        //        var today = new Date().stripTime();
        if(to != 0 ){
            valid = false;
            var from_date = new Date(from)
            var to_date = new Date(to)
            if(from_date < to_date){
                valid = true;
            }else{
                alert(message);
            }
        }
    }
    return valid;
}
  
function insert_field(name, model_name, place_id, field_name) {
    if (name != 0 && name.length == (name.replace(/<(\S+).*>(|.*)<\/(\S+).*>|<%(.*)%>|<%=(.*)%>+/g, "")).length) {
        var dadiv = new Element('div', {
            'id': name+'_000',
            'class':'keyword_label'
        }).insert(name)
        var dadelete = new Element('a', {
            'onclick': 'this.parentNode.remove(); return false;'
        }).insert('<img width="15" src="/images/icons/delete.png" alt="Delete"/>')
        var dahidden = new Element('input', {
            'id': model_name+'_'+field_name+'_',
            'type': 'hidden',
            'value': name,
            'name': model_name+'['+field_name+'][]'
        })
        dadiv.appendChild(dadelete)
        dadiv.appendChild(dahidden)
        $(place_id).insert(dadiv)
    }
}

function check_feed(){
    var url= $('feed_source_url').value;
    if(url != 0){
        new Ajax.Request("/feed_sources/check_feed?url="+url,{
            onLoading: function(){
                $('loading').style.display = 'block';
            },
            onSuccess: function(transport){
                var text = transport.responseText;
                if(text.split('-')[0] == 'exists'){
                    window.location.href = window.location.href.split('feed_sources')[0] + 'feed_sources/'+text.split('-')[1];
                }else if(text.split('-')[0] == 'new'){
                    $('loading').style.display = 'none';
                    alert(text.split('-')[1])
                    $('submit_button').disabled = '';
                //window.location.href = window.location.href.split('feed_sources')[0] + 'feed_sources/new?url='+url;
                }else{
                    alert(text);
                    $('loading').style.display = 'none';
                }
                $('loading').style.display = 'none';
            },
            method: 'get'
        });
    }
}
    
function add_new_follower(){
    var email = $('new_follower_email').value;
    if(email != 0){
        var new_email = new Element('div', {
            'id': email
        }).insert(email)
        var delete_email = new Element('a', {
            'onclick': 'this.parentNode.remove(); return false;'
        }).insert('<img width="15" src="/images/icons/delete.png" alt="Delete"/>')
        var hidden_email = new Element('input', {
            'type': 'hidden',
            'value': email,
            'name': 'configuration[sa_exception_followers_email][]'
        })
        new_email.appendChild(delete_email)
        new_email.appendChild(hidden_email)
        $('followers_email').insert(new_email);
        $('new_follower_email').value = '';
    }
}