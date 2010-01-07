// Load all the functions for website using jquery

$(document).ready(function(){
            //Examples of how to assign the ColorBox event to elements
            $("a[rel='gallery']").colorbox();
});

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
                alert ('save ok');
            }
        });
    }
    else {
        alert('save first');
    }
}
function show_or_hide_body_edit(edit_body,show_body){
    document.getElementById('body_edit').style.display = edit_body;
    document.getElementById('page_body_show').style.display = show_body;
}
