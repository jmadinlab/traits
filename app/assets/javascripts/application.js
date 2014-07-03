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
//= require jquery-ui
//= require jquery_ujs
//= require turbolinks
//= require cocoon
//= require bootstrap
//= require jquery.turbolinks
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


