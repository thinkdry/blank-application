function initialize()
{
}

function show_hidden_descendants(element)
{
	$(element).select('.hidden').each(function(child) {
		Effect.BlindDown(child);
	});
}