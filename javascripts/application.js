jQuery.fn.accordion = function(){
  $(this).toggleClass("closed");
  $(this).parent(".toggle").find('> :not(h2)').toggle();
    // console.log("clicked");
}

function collapse_accordions() {
  $(".toggle h2").accordion();
}

// ***************************************************************************
//
//   Load all this stuff
//
$(document).ready(function(){
  $(".toggle h2").click(function(){ $(this).accordion(); });
    // collapse_accordions()
});

$('h1.gemheader').click(function(){ collapse_accordions(); });
