 function newlabel()
{
  if( ($('key').value) && ($('value').value))
    {
      if(($('element').value)=="user")
      {
        c="<a onclick=$(this).parentNode.remove();return false;' href='#newlabel'>Cancel</a>";
        str="<div id="+$('key').value+">"+$('key').value+"<input type=text id="+$('subelement1').value+"_"+$('key').value+" value="+$('value').value+" name="+$('subelement1').value+"["+$('key').value+"]"+" size='30'>"+c+"</div>"
        $($('element').value).innerHTML+=str;
      }
      else if(($('element').value)=="item")
      {
        c="<a onclick=$(this).parentNode.remove();return false;' href='#newlabel'>Cancel</a>";
        str="<div id="+$('key').value+">"+$('key').value+"<input type=text id="+$('subelement2').value+"_"+$('key').value+" value="+$('value').value+" name="+$('subelement2').value+"["+$('key').value+"]"+" size='30'>"+c+"</div>"
        $($('element').value).innerHTML+=str;
      }
      else
        {
           c="<a onclick=$(this).parentNode.remove();return false;' href='#'>Cancel</a>";
           str="<div id="+$('key').value+">"+$('key').value+"<input type=text id="+$('element').value+"_"+$('key').value+" value="+$('value').value+" name="+$('element').value+"["+$('key').value+"]"+" size='30'>"+c+"</div>"
           $($('element').value).innerHTML+=str;
        }

    }
    else
      alert("Please Add a Key Value Pair!");
}

function changer(pop)
  {
    reset();
    if(pop=="select")
    return
    else
    $(pop).show();
  }
  
function reset()
  {
     $('home').hide();
     $('workspace').hide();
     $('user').hide();
     $('layout').hide();
     $('item').hide();
     $('general').hide();
  }
  