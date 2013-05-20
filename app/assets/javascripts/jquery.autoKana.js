// Copyright (c) 2005-2008 spinelz.org (http://script.spinelz.org/)
// 
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
// 
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//
// This is not original version.
// Required library was changed from "prototype.js" to "jQuery.js".
// Modified: 2010-05-24 21:13:10.

var AutoKana = function(eleId1, eleId2, options) {
	this.initialize(eleId1, eleId2, options);
};

jQuery.extend(AutoKana, {
	kana_extraction_pattern: new RegExp('[^ 　ぁあ-んー]', 'g'),
	kana_compacting_pattern: new RegExp('[ぁぃぅぇぉっゃゅょ]', 'g'),
	label_string_hiragana: 'かな自動補完',
	label_string_katakana: 'カナ自動補完'
});

AutoKana.prototype = {
	initialize: function(eleId1, eleId2, options) {
		this.elName = document.getElementById(arguments[0]);
		this.elKana = document.getElementById(arguments[1]);
		var defaultOptions  = {
			build:    true,
			katakana: false,
			toggle:   true
		};
		this.options = jQuery.extend(defaultOptions, arguments[2] || {});
		this.active  = true;
		this._stateClear();
		this._build();
	},
	start: function() {
		this.active = true;
	},
	stop: function() {
		this.active = false;
	},
	toggle: function(event) {
		var ev = event || window.event;
		if(event) {
			var el = event.target;
			if(el.checked) {
				this.active = true;
			} else {
				this.active = false;
			}
		} else {
			this.active = !this.active;
		}
	},
	_addEvents: function() {
		var self = this;
		jQuery(this.elName).bind('blur', function(event) {
			self._clearInterval.apply(self);
		}).bind('focus', function(event) {
			self._stateInput.apply(self);
			self._setInterval();
		}).bind('keydown', function(event) {
			if (self.flagConvert) {
				self._stateInput.apply(self);
			}
		});
	},
	_build: function() {
		if(this.options.build) {
			this._addEvents();
		}
		if(this.options.toggle) {
			this._buildToggle();
		}
	},
	_buildToggle: function() {
		var el_parent       = this.elName.parentNode;
		var el_new_frame    = document.createElement('div');
		var el_new_checkbox = this._buildToggleCheckBox();
		var el_new_label    = this._buildToggleLabel();
		el_parent.replaceChild(el_new_frame, this.elName);
		el_new_frame.appendChild(this.elName);
		el_new_frame.appendChild(el_new_checkbox);
		el_new_frame.appendChild(el_new_label);
	},
	_buildToggleCheckBox: function() {
		var el = document.createElement('input');
		el.type             = 'checkbox';
		el.id               = this.elName.id + '_toggle';
		el.checked          = true;
		el.style.border     = 'none';
		el.style.background = 'transparent';
		el.style.cursor     = 'pointer';
		jQuery(el).bind('click', this.toggle);
		return el;
	},
_buildToggleLabel: function() {
		var el = document.createElement('label');
		el.htmlFor          = this.elName.id + '_toggle';
		el.style.cursor     = 'pointer';
		el.innerHTML        = ((this.options.katakana) ? AutoKana.label_string_katakana : AutoKana.label_string_hiragana);
		return el;
	},
	_checkConvert: function(new_values) {
		if(!this.flagConvert) {
			if(Math.abs(this.values.length - new_values.length) > 1) {
				var tmp_values = new_values.join('').replace(AutoKana.kana_compacting_pattern, '').split('');
				if(Math.abs(this.values.length - tmp_values.length) > 1) {
					this._stateConvert();
				}
				} else {
				if(this.values.length == this.input.length && this.values.join('') != this.input) {
					this._stateConvert();
				}
			}
		}
	},
	_checkValue: function() {
		var new_input, new_values;
		new_input = this.elName.value;
		if(new_input == '') {
			this._stateClear();
			this._setKana();
		} else {
			new_input = this._removeString(new_input);
			if(this.input == new_input) {
				return;
			} else {
				 this.input = new_input;
				 if(!this.flagConvert) {
					new_values = new_input.replace(AutoKana.kana_extraction_pattern, '').split('');
					this._checkConvert(new_values);
					this._setKana(new_values);
				 }
			}
		}
	},
	_clearInterval: function() {
		clearInterval(this.timer);
	},
	_isHiragana: function(char) {
		return ((char >= 12353 && char <= 12435) || char == 12445 || char == 12446);
	},
	_removeString: function(new_input) {
		if(new_input.match(this.ignoreString)) {
			return new_input.replace(this.ignoreString, '');
		} else {
			var i, l, ignoreArray, inputArray;
			ignoreArray   = this.ignoreString.split('');
			inputArray    = new_input.split('');
			for(i=0,l=ignoreArray.length; i<l; i++) {
				if(ignoreArray[i] == inputArray[i]) {
					inputArray[i] = '';
				}
			}
			return inputArray.join('');
		}
	},
	_setInterval: function() {
		var self = this;
		this.timer = setInterval(function() {self._checkValue();}, 30);
	},
	_setKana: function(new_values) {
		if(!this.flagConvert) {
			if(new_values) {
				this.values = new_values;
			}
			if(this.active) {
				this.elKana.value = this._toKatakana(this.baseKana + this.values.join(''));
			}
		}
	},
	_stateClear: function() {
		this.baseKana       = '';
		this.flagConvert    = false;
		this.ignoreString   = '';
		this.input          = '';
		this.values         = [];
	},
	_stateInput: function() {
		this.baseKana       = this.elKana.value;
		this.flagConvert    = false;
		this.ignoreString   = this.elName.value;
	},
	_stateConvert: function() {
		this.baseKana       = this.baseKana + this.values.join('');
		this.flagConvert    = true;
		this.values         = [];
	},
	_toKatakana: function(src) {
		if(this.options.katakana) {
			var c, i, l, str;
			str = "";
			for(i=0,l=src.length; i<l; i++) {
				c = src.charCodeAt(i);
				if(this._isHiragana(c)) {
					str += String.fromCharCode(c + 96);
				} else {
					str += src.charAt(i);
				}
			}
			return str;
		} else {
			return src;
		}
	}
};
