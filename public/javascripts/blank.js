$(document).ready(function () {	
    wasVisible = new Boolean(false);
	
    $('a.menuDropButton').click(function(){
        wasVisible = false;
		
        if ($(this).next('div.subMenu').is(":visible")){
            wasVisible = true;
        }
		
        $('.subMenu:visible').each(function(){
            $(this).css("display","none")
        });
		
        if (wasVisible == false) {
            $(this).next('div.subMenu').css("display", "block");
            $(this).next('div.subMenu').corner("bottom");
        }
    });
	
    $('input.rating').each(function(){
        $this.rating(function(){
            new Ajax.Request($(this.attributes))
        });
    });

    
});

function autocomplete_on(array){
    alert(array);
    $("#keyword_value").autocomplete(array);
}


function classify_bar(div,url) {
    $.ajax({
        type: 'GET',
        url: url,
        success: function(html){
            $(div).html(html);
        }
    });
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

function insert_field(name, model_name, place_id, field_name) {
    alert(name);
    var key_words = name.split(',')
    for(var i=0; i < key_words.length; i++){
        var name = key_words[i].replace(/(^\s+|\s+$)/g, "")
        if(name != 0 && name.length == (name.replace(/<(\S+).*>(|.*)<\/(\S+).*>|<%(.*)%>|<%=(.*)%>+/g, "")).length){
            var dadiv = "<div id='"+name+"_000' class='keyword_label'></div>"
            $(dadiv).innerHTML = name+"<a onclick='$('#dadiv').remove(this.parentNode);'> <img width='15' src='/images/icons/delete.png' alt='Delete'/></a>"+
            "<input type='hidden' id='"+model_name+"_"+field_name+"' value='"+name+"' name='"+model_name+"["+field_name+"][]'>"
            $(place_id).html(dadiv)
        }
    }
}

function insert_keyword(name, model_name, place, field_name){
    var key_words = name.split(',')
    for(var i=0; i < key_words.length; i++){
        var name = key_words[i].replace(/(^\s+|\s+$)/g, "");
        if(name != 0 && name.length == (name.replace(/<(\S+).*>(|.*)<\/(\S+).*>|<%(.*)%>|<%=(.*)%>+/g, "")).length){
            var hidden_field = "<input type='hidden' id='"+model_name+"_"+field_name+"' value='"+name+"' name='"+model_name+"["+field_name+"][]'>";
            var new_div = document.createElement('div');
            new_div.id = name+"_000";
            var remove_keyword = "<a onclick='$('#new_div').remove(this.parentNode);'> <img width='15' src='/images/icons/delete.png' alt='Delete'/></a>";
            new_div.class = 'keyword_label';
            var str = name + remove_keyword + hidden_field;

        }
        $(place).append(str);
    }
}