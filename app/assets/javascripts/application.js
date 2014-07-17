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
//= require cocoon
//= require bootstrap
//= require select2
//= require_tree .



// $(document).ready(function() {
//   $('select#simple-example').select2();
// });
// 


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
