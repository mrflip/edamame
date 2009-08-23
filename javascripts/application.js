jQuery.fn.accordion = function(){
  $(this).toggleClass("closed");
  $(this).parent(".toggle").find('> :not(h2)').toggle();
  console.log("clicked");
}


// ***************************************************************************
//
//   Load all this stuff
//
$(document).ready(function(){
  $(".toggle h2").click(function(){ $(this).accordion(); });
    // $(".toggle h2").accordion();
});
