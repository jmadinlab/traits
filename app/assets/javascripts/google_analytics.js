$(document).ready( function() {
  $('body').on('click','a',function(event) {
    /* download tracking */
      // add whatever download file extensions are relevant to you
      
      var exts = ['pdf','doc','xls','xlsx', 'csv'];
      var p = new RegExp('\\.('+exts.join('|')+')$','i');
      var href = String(event.target.href)||'';
      if ( href.match(p) ) {
        //_gaq.push(['_trackEvent', 'Link Clicks', 'Download', href])
        //alert('csv downloaded');
        ga('send', 'event', 'Download', 'Download CSV', href);
      }    
  });
});