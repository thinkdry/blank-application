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
