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
                alert ('Saved');
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

// contact form validations
function validate_contact(){
    var first_name = document.getElementById('person_first_name').value;
    var last_name = document.getElementById('person_last_name').value;
    var email = document.getElementById('person_email').value;
    //var primary_phone = document.getElementById('person_primary_phone').value;
    var valid = true;
    if(first_name == 0){
        alert('Le nom doit être renseigné');
        valid = false;
    }else if(last_name == 0){
        alert('Le prénom doit être renseigné');
        valid = false;
    }else if(email == 0){
        alert("L'email doit être renseigné");
        valid = false;
    }else if(! /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,8})+$/.test(email) || (email.length < 10 || email.length > 40)){
        alert("L'email n'est pas valide");
        //valid = false;
    }
    return valid;
}
