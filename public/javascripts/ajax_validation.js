function ajax_validation(model, attribute, value, url)
{
	new Ajax.Updater("errors_for_" + model + "_" + attribute, url, {
		parameters: { model: model, attribute: attribute, value: value }
	});
}
