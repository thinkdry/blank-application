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
function LimitAttach(form, file, type) {
    if(type=="audio")
        extArray = new Array(".wav",".mp3",".wma",".mp4");
    if(type=="video")
        extArray = new Array(".mov", ".mpeg", ".mpg", ".3gp", ".flv", ".avi");
    if(type=="image")
        extArray = new Array(".gif", ".jpg", ".jpeg", ".png", ".bmp");
    if(type=="cmsfile")
        extArray = new Array(".txt",".doc",".pdf");
    allowSubmit = false;
    if(file1==file) return;
    if (!file) return;
    while (file.indexOf("\\") != -1)
        file = file.slice(file.indexOf("\\") + 1);
    ext = file.slice(file.indexOf(".")).toLowerCase();
    for (var i = 0; i < extArray.length; i++)
    {
        if (extArray[i] == ext) {
            allowSubmit = true; break;
        }
    }
    if (!allowSubmit)
        alert("Please only upload files that end in types:  "
            + (extArray.join("  ")) + "\nPlease select a new "
            + "file to upload and submit again.");
    file1=file
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
              
function selectTab(idSelected){
		
    var content = document.getElementById('top_box');
		
    var HTMLNewContent = '<div width="100%" align="center"><img src="/images/ajax-loader.gif" align="center"/></div>';
		
    content.innerHTML = HTMLNewContent;
		
		
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
	
	
	function toggleAccordion(idClicked){
		
		var listOfItemForToggle = document.getElementsByName('itemInformations');
		
		for (var i=0 ; i < listOfItemForToggle.length ; ++i){
			
			if (listOfItemForToggle[i].id == idClicked){
				if (listOfItemForToggle[i].style.display == ''){
					listOfItemForToggle[i].style.display = 'none';
					listOfItemForToggle[i].parentNode.className = 'item_in_list';
				}
				else{
					listOfItemForToggle[i].style.display = '';
					listOfItemForToggle[i].parentNode.className = 'selected_item_in_list';	
				}
			}
			else {
				listOfItemForToggle[i].style.display = 'none';
				listOfItemForToggle[i].parentNode.className = 'item_in_list';
			}
		}	
	}