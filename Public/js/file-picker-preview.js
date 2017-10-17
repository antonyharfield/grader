$(".control input[type=file]").change(function() {
    var input = this;
    if (input.files && input.files[0]) {
        var reader = new FileReader();
        reader.onload = function (e) {
            $(input).prevAll("img").attr('src', e.target.result);
        }
        reader.readAsDataURL(input.files[0]);
    }
});
