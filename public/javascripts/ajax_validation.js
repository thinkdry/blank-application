function ajax_validation(model, attribute, value, url)
{
    $.ajax({
        type: "POST",
        url: url,
        data: "model="+model+"&attribute="+attribute+"&value="+value,
        success: function(html){
            element = "#errors_for_" + model + "_" + attribute;
            $(element).html(html);
        }
    });
}
