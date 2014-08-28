// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery.turbolinks
//= require jquery-ui
//= require jquery_ujs
//= require turbolinks
//= require bootstrap
//= require select2
//= require cocoon
//= require_tree .



// $(document).ready(function() {
//   $('select#simple-example').select2();
// });
// 

   
$(document).ready(function(){
    $('span').tooltip();
});



function checkUncheckAll(theElement) { 
	var theForm = theElement.form, z = 0; 
		for(z=0; z<theForm.length;z++){ 
		if(theForm[z].type == 'checkbox' && theForm[z].name != 'checkall'){ 
			theForm[z].checked = theElement.checked; 
		} 
	} 
}



$(document).ready(function(){
  $('.panel-body').hide();

  $('.panel-heading').click(function(e){
    e.preventDefault();
    $(this).next('.panel-body').fadeToggle("slow");
  });

  
  process_precision()
  
});

/*
var element_id = 1;

$(document).bind('cocoon:after-insert', function(e,inserted_item) {
   e.preventDefault();
   setTimeout(function(){
   	window.element_id = window.element_id + 1;
   	custom_id = "trait_select" + element_id;
   	$('#sur_trait').attr('id', custom_id);
   	$('#sur_value').attr('id', 'trait_value' + element_id);
   	$('#sur_methodology').attr('id', 'trait_methodology' + element_id);
   	$('#sur_standard').attr('id', 'trait_standard' + element_id);
    $('#sur_suggested_standard').attr('id', 'suggested_standard' + element_id) ;
   	//alert('success');
   }, 2000);
   

});

$(window).on('load', function(){
	$('#sur_trait').attr('id', 'trait_select1');
	$('#sur_value').attr('id', 'trait_value1');
	$('#sur_methodology').attr('id', 'trait_methodology1');
	$('#sur_standard').attr('id', 'trait_standard1');
  $('#sur_suggested_standard').attr('id', 'suggested_standard1');
  
});


*/


function process_precision()

{

  // Process the precision fields while document loads for first time (new / edit)
  var selected_value_type = $('[id*=_value_type]');
  selected_value_type.each(function(){
    if ( $(this).val() =="" || $(this).val()== "raw_value")
      $(this).parents(".nested-fields").find(".precision").hide();
    else 
      $(this).parents(".nested-fields").find(".precision").show();
  });

  // Add event listener for on change in value_type
  $("[id*=_value_type]").on("change", function() {
      var selected_value;
      selected_value = $(this).val();
      if (selected_value === "raw_value" || selected_value == "") {
        $(this).parents(".nested-fields").find(".precision").children().val("");
        $(this).parents(".nested-fields").find(".precision").hide();
      } else {
        $(this).parents(".nested-fields").find(".precision").show();
      }
    });
  
}

$(document).bind('cocoon:after-insert', function(e,inserted_item) {
  
    process_precision()
});

function get_suggestions(request, response){
  var params = { search: request.term };
  $.get("/search/json_completion", params, function(data){
    response(data);
  }, "json");
}

$(document).ready(function(){

 $( ".search" ).autocomplete({
  source: get_suggestions,
   minLength: 2 
  });
}); 


