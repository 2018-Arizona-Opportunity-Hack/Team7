function invalidate() {
    $('#username').addClass('is-invalid');
    $('#password').addClass('is-invalid');
    $('#password').val('');
    $('#errormsg').show();
}

function validateForms() {
    if ($('#username').val() === '') {
	$('#username').addClass('is-invalid');
	return false;
    }

    if ($('#password').val() === '') {
	$('#password').addClass('is-invalid');
	return false;
    }

    return true;
}

$(document).ready(function() {
    $('#loginBtn').click(function(e) {
	e.preventDefault();

	if (validateForms()) {
	    $.ajax({
		url: '/auth/authenticate',
		method: 'POST',
		data: JSON.stringify({
		    un: $('#username').val(),
		    pw: $('#password').val()
		}),
		contentType: 'application/json',
		success: function(data) {
		    try {
			data = JSON.parse(data);

			if (data && data.result) {
		            window.location.href = '/';
		        } else {
		            invalidate();
		        }
		    } catch (e) {
			invalidate();
		    }
	        }
	    });
	}
    });

    $('#username').focus(function() {
	$(this).removeClass('is-invalid');
	$('#errormsg').hide();
    });

    $('#password').focus(function() {
	$(this).removeClass('is-invalid');
	$('#errormsg').hide()
    });
});
