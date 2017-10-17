$(document).ready(function() {
    $("time").each(function() {
        var datetime = $(this).attr("datetime");
        if (datetime != "") {
            var localDatetime = moment(datetime).format("llll");
            $(this).text(localDatetime);
        }
        else {
            $(this).text("Anytime");
        }
    });
    $(".countdown").each(function() {
        var element = $(this);
        var x = setInterval(function() {
          var deadline = moment(element.data('deadline'));
          var diff = deadline.diff(moment(), 'seconds');
          var minutes = parseInt(diff / 60);
          var seconds = diff % 60;
          element.text(minutes + 'm ' + seconds + 's');

          // If the count down is finished, write some text
          if (deadline.isBefore()) {
            clearInterval(x);
            element.html('Event ended!');
          }
        }, 1000);
    });
});
