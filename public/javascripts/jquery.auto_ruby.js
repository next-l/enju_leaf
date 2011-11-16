//--------設定--------
var convFlag  = 1;      //モードフラグ ひらがな→0　カタカナ→1
//--------------------

(function($){
    $.fn.auto_ruby = function(ruby) {
		var Baseval = "";
		loopTimer($(this),ruby,Baseval);
	    /*$(this).keyup(function() {
          Baseval = setRuby($(this),ruby,Baseval);
	    })*/			
    };
})(jQuery);



function setRuby(nameId,rubyId,baseVal) {
	var newVal = nameId.attr('value');
    if (baseVal == newVal){return baseVal;}
	if (newVal == '') {
          rubyId.attr('value','');
		  baseVal = "";
		  return baseVal;
	}

	var addVal = newVal;
	for(var i=baseVal.length; i>=0; i--) {
		if (newVal.substr(0,i) == baseVal.substr(0,i)) {
			addVal = newVal.substr(i);break;
		}
	}
	baseVal = newVal;
	var addruby = addVal.replace( /[^ 　ぁあ-んァー]/g, "" );
	if (addruby == ""){return baseVal; }
	if(convFlag){addruby = convKana(addruby);}
	rubyId.attr('value',rubyId.attr('value') + addruby);
	return baseVal;
}


function loopTimer(nameField,rubyField,baseval){
  baseval = setRuby(nameField,rubyField,baseval);
  timer = setTimeout(function() {loopTimer(nameField,rubyField,baseval)},30);
}

function convKana(val){
	var c, a = [];
	for(var i=val.length-1;0<=i;i--){
			c = val.charCodeAt(i);
			a[i] = (0x3041 <= c && c <= 0x3096) ? c + 0x0060 : c;
	}
	return String.fromCharCode.apply(null, a);
}

var timer = false



