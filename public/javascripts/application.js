/* jQuery Tiny Pub/Sub - v0.7 - 10/27/2011
 * http://benalman.com/
 * Copyright (c) 2011 "Cowboy" Ben Alman; Licensed MIT, GPL 
 * https://gist.github.com/661855
 */

(function($) {

  var o = $({});

  $.subscribe = function() {
    o.on.apply(o, arguments);
  };

  $.unsubscribe = function() {
    o.off.apply(o, arguments);
  };

  $.publish = function() {
    o.trigger.apply(o, arguments);
  };

}(jQuery));

$.site = { mode: "", prevMode: "" };

$.subscribe("modeChange", function(e){
    if( $.site.mode == 'desktop' ){
        $.publish("enterDesktop");
    }else{
        $.publish("enterMobile");
    }
});

$.subscribe("enterDesktop", function(e){
    console.log("desktop mode");
});

$.subscribe("enterMobile", function(e){
    console.log("mobile mode");
});


var info = $("#info");

function toggleMode(){
    $.site.mode = $(window).width() > 768 ? 'desktop' : 'mobile';
}

$(document).ready(function(){
    info.text($(window).width() + "x" + $(window).height());
    
    toggleMode();
    $.site.prevMode = $.site.mode;
    $.publish("modeChange");
    
    $( "ul.sortable" ).sortable();
    $( "ul.sortable" ).disableSelection(); //disables text selection
    
    // $("#page_sorter ul").sortable({
    //     connectWith: "#page_sorter ul",
    //     placeholder: "ui-state-highlight",
    //     update: function(){
    //         console.log( $("#page_sorter ul").sortable('serialize') );
    //     }
    // });
    $( "#page_sorter ol" ).nestedSortable({
        disableNesting: 'no-nest',
        forcePlaceholderSize: true,
		handle: 'div',
		helper:	'clone',
		items: 'li',
		opacity: .6,
		revert: 250,
		tabSize: 25,
		tolerance: 'pointer',
		toleranceElement: '> div',
		update: function(){
		    console.log($(this).nestedSortable('serialize'));
		}
    });
});

$(window).resize(function(){
   info.text($(window).width() + "x" + $(window).height());
   
   toggleMode();
   
   
   if( $.site.mode != $.site.prevMode ){
       $.publish("modeChange");
       $.site.prevMode = $.site.mode;
   }
    
});