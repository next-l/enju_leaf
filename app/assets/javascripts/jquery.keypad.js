/* http://keith-wood.name/keypad.html
   Keypad field entry extension for jQuery v1.4.2.
   Written by Keith Wood (kbwood{at}iinet.com.au) August 2008.
   Dual licensed under the GPL (http://dev.jquery.com/browser/trunk/jquery/GPL-LICENSE.txt) and 
   MIT (http://dev.jquery.com/browser/trunk/jquery/MIT-LICENSE.txt) licenses. 
   Please attribute the author if you use it. */
   
(function($) { // hide the namespace

var PROP_NAME = 'keypad';

/* Keypad manager.
   Use the singleton instance of this class, $.keypad, to interact with the plugin.
   Settings for keypad fields are maintained in instance objects,
   allowing multiple different settings on the same page. */
function Keypad() {
	this._curInst = null; // The current instance in use
	this._disabledFields = []; // List of keypad fields that have been disabled
	this._keypadShowing = false; // True if the popup panel is showing , false if not
	this._keyCode = 0;
	this._specialKeys = [];
	this.addKeyDef('CLOSE', 'close', function(inst) {
		$.keypad._curInst = (inst._inline ? inst : $.keypad._curInst);
		$.keypad._hideKeypad();
	});
	this.addKeyDef('CLEAR', 'clear', function(inst) { $.keypad._clearValue(inst); });
	this.addKeyDef('BACK', 'back', function(inst) { $.keypad._backValue(inst); });
	this.addKeyDef('SHIFT', 'shift', function(inst) { $.keypad._shiftKeypad(inst); });
	this.addKeyDef('SPACE_BAR', 'spacebar', function(inst) { $.keypad._selectValue(inst, ' '); }, true);
	this.addKeyDef('SPACE', 'space');
	this.addKeyDef('HALF_SPACE', 'half-space');
	this.addKeyDef('ENTER', 'enter', function(inst) { $.keypad._selectValue(inst, '\x0D'); }, true);
	this.addKeyDef('TAB', 'tab', function(inst) { $.keypad._selectValue(inst, '\x09'); }, true);
	// Standard US keyboard alphabetic layout
	this.qwertyAlphabetic = ['qwertyuiop', 'asdfghjkl', 'zxcvbnm'];
	// Standard US keyboard layout
	this.qwertyLayout = ['!@#$%^&*()_=' + this.HALF_SPACE + this.SPACE + this.CLOSE,
		this.HALF_SPACE + '`~[]{}<>\\|/' + this.SPACE + '789',
		'qwertyuiop\'"' + this.HALF_SPACE + '456',
		this.HALF_SPACE + 'asdfghjkl;:' + this.SPACE + '123',
		this.SPACE + 'zxcvbnm,.?' + this.SPACE + this.HALF_SPACE + '-0+',
		'' + this.TAB + this.ENTER + this.SPACE_BAR + this.SHIFT +
		this.HALF_SPACE + this.BACK + this.CLEAR];
	this.regional = []; // Available regional settings, indexed by language code
	this.regional[''] = { // Default regional settings
		buttonText: '...', // Display text for trigger button
		buttonStatus: 'Open the keypad', // Status text for trigger button
		closeText: 'Close', // Display text for close link
		closeStatus: 'Close the keypad', // Status text for close link
		clearText: 'Clear', // Display text for clear link
		clearStatus: 'Erase all the text', // Status text for clear link
		backText: 'Back', // Display text for back link
		backStatus: 'Erase the previous character', // Status text for back link
		spacebarText: '&nbsp;', // Display text for space bar
		spacebarStatus: 'Space', // Status text for space bar
		enterText: 'Enter', // Display text for carriage return
		enterStatus: 'Carriage return', // Status text for carriage return
		tabText: '→', // Display text for tab
		tabStatus: 'Horizontal tab', // Status text for tab
		shiftText: 'Shift', // Display text for shift link
		shiftStatus: 'Toggle upper/lower case characters', // Status text for shift link
		alphabeticLayout: this.qwertyAlphabetic, // Default layout for alphabetic characters
		fullLayout: this.qwertyLayout, // Default layout for full keyboard
		isAlphabetic: this.isAlphabetic, // Function to determine if character is alphabetic
		isNumeric: this.isNumeric, // Function to determine if character is numeric
		isRTL: false // True if right-to-left language, false if left-to-right
	};
	this._defaults = { // Global defaults for all the keypad instances
		showOn: 'focus', // 'focus' for popup on focus,
			// 'button' for trigger button, or 'both' for either
		buttonImage: '', // URL for trigger button image
		buttonImageOnly: false, // True if the image appears alone, false if it appears on a button
		showAnim: 'show', // Name of jQuery animation for popup
		showOptions: {}, // Options for enhanced animations
		duration: 'normal', // Duration of display/closure
		appendText: '', // Display text following the text field, e.g. showing the format
		useThemeRoller: false, // True to add ThemeRoller classes
		keypadClass: '', // Additional CSS class for the keypad for an instance
		prompt: '', // Display text at the top of the keypad
		layout: ['123' + this.CLOSE, '456' + this.CLEAR, '789' + this.BACK, this.SPACE + '0'], // Layout of keys
		separator: '', // Separator character between keys
		target: null, // Input target for an inline keypad
		keypadOnly: true, // True for entry only via the keypad, false for real keyboard too
		randomiseAlphabetic: false, // True to randomise the alphabetic key positions, false to keep in order
		randomiseNumeric: false, // True to randomise the numeric key positions, false to keep in order
		randomiseOther: false, // True to randomise the other key positions, false to keep in order
		randomiseAll: false, // True to randomise all key positions, false to keep in order
		beforeShow: null, // Callback before showing the keypad
		onKeypress: null, // Callback when a key is selected
		onClose: null // Callback when the panel is closed
	};
	$.extend(this._defaults, this.regional['']);
	this.mainDiv = $('<div class="' + this._mainDivClass + '" style="display: none;"></div>');
}

$.extend(Keypad.prototype, {
	/* Class name added to elements to indicate already configured with keypad. */
	markerClassName: 'hasKeypad',
	
	_mainDivClass: 'keypad-popup', // The name of the main keypad division class
	_inlineClass: 'keypad-inline', // The name of the inline marker class
	_appendClass: 'keypad-append', // The name of the append marker class
	_triggerClass: 'keypad-trigger', // The name of the trigger marker class
	_disableClass: 'keypad-disabled', // The name of the disabled covering marker class
	_inlineEntryClass: 'keypad-keyentry', // The name of the inline entry marker class
	_coverClass: 'keypad-cover', // The name of the IE select cover marker class
	
	/* Override the default settings for all instances of keypad. 
	   @param  settings  (object) the new settings to use as defaults
	   @return  (object) the manager object */
	setDefaults: function(settings) {
		extendRemove(this._defaults, settings || {});
		return this;
	},

	/* Add the definition of a special key.
	   @param  id           (string) the identifier for this key - access via $.keypad.<id>
	   @param  name         (string) the prefix for localisation strings and
	                        the suffix for a class name
	   @param  action       (function) the action performed for this key -
	                        receives inst as a parameter
	   @param  noHighlight  (boolean) true to suppress highlight when using ThemeRoller
	   @return  (object) the manager object */
	addKeyDef: function(id, name, action, noHighlight) {
		if (this._keyCode == 32) {
			throw 'Only 32 special keys allowed';
		}
		this[id] = String.fromCharCode(this._keyCode++);
		this._specialKeys.push({code: this[id], id: id, name: name,
			action: action, noHighlight: noHighlight});
		return this;
	},

	/* Attach the keypad to a jQuery selection.
	   @param  target    (element) the target control
	   @param  settings  (object) the new settings to use for this instance */
	_attachKeypad: function(target, settings) {
		var inline = (target.nodeName.toLowerCase() != 'input' &&
			target.nodeName.toLowerCase() != 'textarea');
		var inst = {_inline: inline,
			_mainDiv: (inline ? $('<div class="' + this._inlineClass + '"></div>') :
			$.keypad.mainDiv), ucase: false};
		inst.settings = $.extend({}, settings || {}); 
		this._setInput(target, inst);
		this._connectKeypad(target, inst);
		if (inline) {
			$(target).append(inst._mainDiv).
				bind('click.keypad', function() { inst._input.focus(); });
			this._updateKeypad(inst);
		}
		else if ($(target).is(':disabled')) {
			this._disableKeypad(target);
		}
	},

	/* Determine the input field for the keypad.
	   @param  target  (jQuery) the target control
	   @param  inst    (object) the instance settings */
	_setInput: function(target, inst) {
		inst._input = $(!inst._inline ? target : this._get(inst, 'target') ||
			'<input type="text" class="' + this._inlineEntryClass + '" disabled="disabled"/>');
		if (inst._inline) {
			target = $(target);
			target.find('input').remove();
			if (!this._get(inst, 'target')) {
				target.append(inst._input);
			}
		}
	},

	/* Attach the keypad to a text field.
	   @param  target  (element) the target text field
	   @param  inst    (object) the instance settings */
	_connectKeypad: function(target, inst) {
		var field = $(target);
		if (field.hasClass(this.markerClassName)) {
			return;
		}
		var appendText = this._get(inst, 'appendText');
		var isRTL = this._get(inst, 'isRTL');
		if (appendText) {
			field[isRTL ? 'before' : 'after'](
				'<span class="' + this._appendClass + '">' + appendText + '</span>');
		}
		if (!inst._inline) {
			var showOn = this._get(inst, 'showOn');
			if (showOn == 'focus' || showOn == 'both') { // pop-up keypad when in the marked field
				field.focus(this._showKeypad).keydown(this._doKeyDown);
			}
			if (showOn == 'button' || showOn == 'both') { // pop-up keypad when button clicked
				var buttonText = this._get(inst, 'buttonText');
				var buttonStatus = this._get(inst, 'buttonStatus');
				var buttonImage = this._get(inst, 'buttonImage');
				var trigger = $(this._get(inst, 'buttonImageOnly') ? 
					$('<img src="' + buttonImage + '" alt="' +
					buttonStatus + '" title="' + buttonStatus + '"/>') :
				$('<button type="button" title="' + buttonStatus + '"></button>').
					html(buttonImage == '' ? buttonText :
					$('<img src="' + buttonImage + '" alt="' +
					buttonStatus + '" title="' + buttonStatus + '"/>')));
				field[isRTL ? 'before' : 'after'](trigger);
				trigger.addClass(this._triggerClass).click(function() {
					if ($.keypad._keypadShowing && $.keypad._lastField == target) {
						$.keypad._hideKeypad();
					}
					else {
						$.keypad._showKeypad(target);
					}
					return false;
				});
			}
		}
		inst.saveReadonly = field.attr('readonly');
		field.addClass(this.markerClassName)
			[this._get(inst, 'keypadOnly') ? 'attr' : 'removeAttr']('readonly', true).
			bind('setData.keypad', function(event, key, value) {
				inst.settings[key] = value;
			}).bind('getData.keypad', function(event, key) {
				return this._get(inst, key);
			});
		$.data(target, PROP_NAME, inst);
	},

	/* Detach keypad from its control.
	   @param  target  (element) the target text field */
	_destroyKeypad: function(target) {
		var $target = $(target);
		if (!$target.hasClass(this.markerClassName)) {
			return;
		}
		var inst = $.data(target, PROP_NAME);
		if (this._curInst == inst) {
			this._hideKeypad();
		}
		$target.siblings('.' + this._appendClass).remove().end().
			siblings('.' + this._triggerClass).remove().end().
			prev('.' + this._inlineEntryClass).remove();
		$target.empty().unbind('focus', this._showKeypad).
			removeClass(this.markerClassName)
			[inst.saveReadonly ? 'attr' : 'removeAttr']('readonly', true);
		$.removeData(inst._input[0], PROP_NAME);
		$.removeData(target, PROP_NAME);
	},

	/* Enable the keypad for a jQuery selection.
	   @param  target  (element) the target text field */
	_enableKeypad: function(target) {
		var control = $(target);
		if (!control.hasClass(this.markerClassName)) {
			return;
		}
		var nodeName = target.nodeName.toLowerCase();
		if (nodeName == 'input' || nodeName == 'textarea') {
			target.disabled = false;
			control.siblings('button.' + this._triggerClass).
				each(function() { this.disabled = false; }).end().
				siblings('img.' + this._triggerClass).
				css({opacity: '1.0', cursor: ''});
		}
		else if (nodeName == 'div' || nodeName == 'span') {
			control.children('.' + this._disableClass).remove();
			var inst = $.data(target, PROP_NAME);
			inst._mainDiv.find('button').attr('disabled', '');
		}
		this._disabledFields = $.map(this._disabledFields,
			function(value) { return (value == target ? null : value); }); // delete entry
	},

	/* Disable the keypad for a jQuery selection.
	   @param  target  (element) the target text field */
	_disableKeypad: function(target) {
		var control = $(target);
		if (!control.hasClass(this.markerClassName)) {
			return;
		}
		var nodeName = target.nodeName.toLowerCase();
		if (nodeName == 'input' || nodeName == 'textarea') {
		target.disabled = true;
			control.siblings('button.' + this._triggerClass).
			each(function() { this.disabled = true; }).end().
			siblings('img.' + this._triggerClass).
			css({opacity: '0.5', cursor: 'default'});
		}
		else if (nodeName == 'div' || nodeName == 'span') {
			var inline = control.children('.' + this._inlineClass);
			var offset = inline.offset();
			var relOffset = {left: 0, top: 0};
			inline.parents().each(function() {
				if ($(this).css('position') == 'relative') {
					relOffset = $(this).offset();
					return false;
				}
			});
			control.prepend('<div class="' + this._disableClass + '" style="width: ' +
				inline.outerWidth() + 'px; height: ' + inline.outerHeight() +
				'px; left: ' + (offset.left - relOffset.left) +
				'px; top: ' + (offset.top - relOffset.top) + 'px;"></div>');
			var inst = $.data(target, PROP_NAME);
			inst._mainDiv.find('button').attr('disabled', 'disabled');
		}
		this._disabledFields = $.map(this._disabledFields,
			function(value) { return (value == target ? null : value); }); // delete entry
		this._disabledFields[this._disabledFields.length] = target;
	},

	/* Is the text field disabled as a keypad?
	   @param  target  (element) the target text field
	   @return  (boolean) true if disabled, false if enabled */
	_isDisabledKeypad: function(target) {
		return (target && $.inArray(target, this._disabledFields) > -1);
	},

	/* Update the settings for keypad attached to a text field
	   @param  target  (element) the target text field
	   @param  name    (object) the new settings to update or
	                   (string) the name of the setting to change
	   @param  value   (any) the new value for the setting (omit if above is an object) */
	_changeKeypad: function(target, name, value) {
		var settings = name || {};
		if (typeof name == 'string') {
			settings = {};
			settings[name] = value;
		}
		var inst = $.data(target, PROP_NAME);
		if (inst) {
			if (this._curInst == inst) {
				this._hideKeypad();
			}
			extendRemove(inst.settings, settings);
			this._setInput($(target), inst);
			this._updateKeypad(inst);
		}
	},

	/* Pop-up the keypad for a given text field.
	   @param  field  (element) the text field attached to the keypad or
	                  (event) if triggered by focus */
	_showKeypad: function(field) {
		field = field.target || field;
		if ($.keypad._isDisabledKeypad(field) ||
				$.keypad._lastField == field) { // already here
			return;
		}
		var inst = $.data(field, PROP_NAME);
		$.keypad._hideKeypad(null, '');
		$.keypad._lastField = field;
		$.keypad._pos = $.keypad._findPos(field);
		$.keypad._pos[1] += field.offsetHeight; // add the height
		var isFixed = false;
		$(field).parents().each(function() {
			isFixed |= $(this).css('position') == 'fixed';
			return !isFixed;
		});
		if (isFixed && $.browser.opera) { // correction for Opera when fixed and scrolled
			$.keypad._pos[0] -= document.documentElement.scrollLeft;
			$.keypad._pos[1] -= document.documentElement.scrollTop;
		}
		var offset = {left: $.keypad._pos[0], top: $.keypad._pos[1]};
		$.keypad._pos = null;
		// determine sizing offscreen
		inst._mainDiv.css({position: 'absolute', display: 'block', top: '-1000px',
			width: ($.browser.opera ? '1000px' : 'auto')});
		$.keypad._updateKeypad(inst);
		// and adjust position before showing
		offset = $.keypad._checkOffset(inst, offset, isFixed);
		inst._mainDiv.css({position: (isFixed ? 'fixed' : 'absolute'), display: 'none',
			left: offset.left + 'px', top: offset.top + 'px'});
		var showAnim = $.keypad._get(inst, 'showAnim');
		var duration = $.keypad._get(inst, 'duration');
		duration = (duration == 'normal' && $.ui && $.ui.version >= '1.8' ? '_default' : duration);
		var postProcess = function() {
			$.keypad._keypadShowing = true;
			var borders = $.keypad._getBorders(inst._mainDiv);
			inst._mainDiv.find('iframe.' + $.keypad._coverClass). // IE6- only
				css({left: -borders[0], top: -borders[1],
					width: inst._mainDiv.outerWidth(), height: inst._mainDiv.outerHeight()});
		};
		if ($.effects && $.effects[showAnim]) {
			var data = inst._mainDiv.data(); // Update old effects data
			for (var key in data) {
				if (key.match(/^ec\.storage\./)) {
					data[key] = inst._mainDiv.css(key.replace(/ec\.storage\./, ''));
				}
			}
			inst._mainDiv.data(data).show(showAnim,
				$.keypad._get(inst, 'showOptions'), duration, postProcess);
		}
		else {
			inst._mainDiv[showAnim || 'show']((showAnim ? duration : ''), postProcess);
		}
		if (!showAnim) {
			postProcess();
		}
		if (inst._input[0].type != 'hidden') {
			inst._input[0].focus();
		}
		$.keypad._curInst = inst;
	},

	/* Generate the keypad content.
	   @param  inst  (object) the instance settings */
	_updateKeypad: function(inst) {
		var borders = this._getBorders(inst._mainDiv);
		inst._mainDiv.empty().append(this._generateHTML(inst)).
			find('iframe.' + this._coverClass). // IE6- only
			css({left: -borders[0], top: -borders[1],
				width: inst._mainDiv.outerWidth(), height: inst._mainDiv.outerHeight()});
		inst._mainDiv.removeClass().addClass(this._get(inst, 'keypadClass') +
			(this._get(inst, 'useThemeRoller') ? ' ui-widget ui-widget-content' : '') +
			(this._get(inst, 'isRTL') ? ' keypad-rtl' : '') + ' ' +
			(inst._inline ? this._inlineClass : this._mainDivClass));
		var beforeShow = this._get(inst, 'beforeShow');
		if (beforeShow) {
			beforeShow.apply((inst._input ? inst._input[0] : null),
				[inst._mainDiv, inst]);
		}
	},

	/* Retrieve the size of left and top borders for an element.
	   @param  elem  (jQuery object) the element of interest
	   @return  (number[2]) the left and top borders */
	_getBorders: function(elem) {
		var convert = function(value) {
			var extra = ($.browser.msie ? 1 : 0);
			return {thin: 1 + extra, medium: 3 + extra, thick: 5 + extra}[value] || value;
		};
		return [parseFloat(convert(elem.css('border-left-width'))),
			parseFloat(convert(elem.css('border-top-width')))];
	},

	/* Check positioning to remain on screen.
	   @param  inst    (object) the instance settings
	   @param  offset  (object) the current offset
	   @param  isFixed  (boolean) true if the text field is fixed in position
	   @return  (object) the updated offset */
	_checkOffset: function(inst, offset, isFixed) {
		var pos = inst._input ? this._findPos(inst._input[0]) : null;
		var browserWidth = window.innerWidth || document.documentElement.clientWidth;
		var browserHeight = window.innerHeight || document.documentElement.clientHeight;
		var scrollX = document.documentElement.scrollLeft || document.body.scrollLeft;
		var scrollY = document.documentElement.scrollTop || document.body.scrollTop;
		if (($.browser.msie && parseInt($.browser.version, 10) < 7) || $.browser.opera) {
			// recalculate width as otherwise set to 100%
			var width = 0;
			inst._mainDiv.find(':not(div,iframe)').each(function() {
				width = Math.max(width, this.offsetLeft + $(this).outerWidth() +
					parseInt($(this).css('margin-right'), 10));
			});
			inst._mainDiv.css('width', width);
		}
		// reposition keypad panel horizontally if outside the browser window
		if (this._get(inst, 'isRTL') ||
				(offset.left + inst._mainDiv.outerWidth() - scrollX) > browserWidth) {
			offset.left = Math.max((isFixed ? 0 : scrollX),
				pos[0] + (inst._input ? inst._input.outerWidth() : 0) -
				(isFixed ? scrollX : 0) - inst._mainDiv.outerWidth() -
				(isFixed && $.browser.opera ? document.documentElement.scrollLeft : 0));
		}
		else {
			offset.left -= (isFixed ? scrollX : 0);
		}
		// reposition keypad panel vertically if outside the browser window
		if ((offset.top + inst._mainDiv.outerHeight() - scrollY) > browserHeight) {
			offset.top = Math.max((isFixed ? 0 : scrollY),
				pos[1] - (isFixed ? scrollY : 0) - inst._mainDiv.outerHeight() -
				(isFixed && $.browser.opera ? document.documentElement.scrollTop : 0));
		}
		else {
			offset.top -= (isFixed ? scrollY : 0);
		}
		return offset;
	},
	
	/* Find an object's position on the screen.
	   @param  obj  (element) the element to find the position for
	   @return  (int[2]) the element's position */
	_findPos: function(obj) {
        while (obj && (obj.type == 'hidden' || obj.nodeType != 1)) {
            obj = obj.nextSibling;
        }
        var position = $(obj).offset();
	    return [position.left, position.top];
	},

	/* Hide the keypad from view.
	   @param  field     (element) the text field attached to the keypad
	   @param  duration  (string) the duration over which to close the keypad */
	_hideKeypad: function(field, duration) {
		var inst = this._curInst;
		if (!inst || (field && inst != $.data(field, PROP_NAME))) {
			return;
		}
		if (this._keypadShowing) {
			duration = (duration != null ? duration : this._get(inst, 'duration'));
			duration = (duration == 'normal' && $.ui && $.ui.version >= '1.8' ? '_default' : duration);
			var showAnim = this._get(inst, 'showAnim');
			if ($.effects && $.effects[showAnim]) {
				inst._mainDiv.hide(showAnim, this._get(inst, 'showOptions'), duration);
			}
			else {
				inst._mainDiv[(showAnim == 'slideDown' ? 'slideUp' :
					(showAnim == 'fadeIn' ? 'fadeOut' : 'hide'))](showAnim ? duration : '');
			}
		}
		var onClose = this._get(inst, 'onClose');
		if (onClose) {
			onClose.apply((inst._input ? inst._input[0] : null),  // trigger custom callback
				[inst._input.val(), inst]);
		}
		if (this._keypadShowing) {
			this._keypadShowing = false;
			this._lastField = null;
		}
		if (inst._inline) {
			inst._input.val('');
		}
		this._curInst = null;
	},

	/* Handle keystrokes.
	   @param  e  (event) the key event */
	_doKeyDown: function(e) {
		if (e.keyCode == 9) { // Tab out
			$.keypad.mainDiv.stop(true, true);
			$.keypad._hideKeypad();
		}
	},

	/* Close keypad if clicked elsewhere.
	   @param  event  (event) the mouseclick details */
	_checkExternalClick: function(event) {
		if (!$.keypad._curInst) {
			return;
		}
		var target = $(event.target);
		if (!target.parents().andSelf().is('.' + $.keypad._mainDivClass) &&
				!target.hasClass($.keypad.markerClassName) &&
				!target.parents().andSelf().hasClass($.keypad._triggerClass) &&
				$.keypad._keypadShowing) {
			$.keypad._hideKeypad();
		}
	},

	/* Toggle between upper and lower case.
	   @param  inst  (object) the instance settings */
	_shiftKeypad: function(inst) {
		inst.ucase = !inst.ucase;
		this._updateKeypad(inst);
		inst._input.focus(); // for further typing
	},

	/* Erase the text field.
	   @param  inst  (object) the instance settings */
	_clearValue: function(inst) {
		this._setValue(inst, '', 0);
		this._notifyKeypress(inst, $.keypad.DEL);
	},

	/* Erase the last character.
	   @param  inst  (object) the instance settings */
	_backValue: function(inst) {
		var field = inst._input[0];
		var value = inst._input.val();
		var range = [value.length, value.length];
		if (field.setSelectionRange) { // Mozilla
			range = (inst._input.attr('readonly') || inst._input.attr('disabled') ?
				range : [field.selectionStart, field.selectionEnd]);
		}
		else if (field.createTextRange) { // IE
			range = (inst._input.attr('readonly') || inst._input.attr('disabled') ?
				range : this._getIERange(field));
		}
		this._setValue(inst, (value.length == 0 ? '' :
			value.substr(0, range[0] - 1) + value.substr(range[1])), range[0] - 1);
		this._notifyKeypress(inst, $.keypad.BS);
	},

	/* Update the text field with the selected value.
	   @param  inst   (object) the instance settings
	   @param  value  (string) the new character to add */
	_selectValue: function(inst, value) {
		this.insertValue(inst._input[0], value);
		this._setValue(inst, inst._input.val());
		this._notifyKeypress(inst, value);
	},

	/* Update the text field with the selected value.
	   @param  input  (element) the input field or
	                  (jQuery) jQuery collection
	   @param  value  (string) the new character to add */
	insertValue: function(input, value) {
		input = (input.jquery ? input : $(input));
		var field = input[0];
		var newValue = input.val();
		var range = [newValue.length, newValue.length];
		if (field.setSelectionRange) { // Mozilla
			range = (input.attr('readonly') || input.attr('disabled') ?
				range : [field.selectionStart, field.selectionEnd]);
		}
		else if (field.createTextRange) { // IE
			range = (input.attr('readonly') || input.attr('disabled') ?
				range : this._getIERange(field));
		}
		input.val(newValue.substr(0, range[0]) + value + newValue.substr(range[1]));
		pos = range[0] + value.length;
		if (input.is(':visible')) {
			input.focus(); // for further typing
		}
		if (field.setSelectionRange) { // Mozilla
			if (input.is(':visible')) {
				field.setSelectionRange(pos, pos);
			}
		}
		else if (field.createTextRange) { // IE
			range = field.createTextRange();
			range.move('character', pos);
			range.select();
		}
	},

	/* Get the coordinates for the selected area in the text field in IE.
	   @param  field  (element) the target text field
	   @return  (int[2]) the start and end positions of the selection */
	_getIERange: function(field) {
		field.focus();
		var selectionRange = document.selection.createRange().duplicate();
		// Use two ranges: before and selection
		var beforeRange = this._getIETextRange(field);
		beforeRange.setEndPoint('EndToStart', selectionRange);
		// Check each range for trimmed newlines by shrinking the range by one
		// character and seeing if the text property has changed. If it has not
		// changed then we know that IE has trimmed a \r\n from the end.
		var checkCRLF = function(range) {
			var origText = range.text;
			var text = origText;
			var finished = false;
			while (true) {
				if (range.compareEndPoints('StartToEnd', range) == 0) {
					break;
				} 
				else {
					range.moveEnd('character', -1);
					if (range.text == origText) {
						text += '\r\n';
					} 
					else {
						break;
					}
				}
			}
			return text;
		};
		var beforeText = checkCRLF(beforeRange);
		var selectionText = checkCRLF(selectionRange);
		return [beforeText.length, beforeText.length + selectionText.length];
	},

	/* Create an IE text range for the text field.
	   @param  field  (element) the target text field
	   @return  (object) the corresponding text range */
	_getIETextRange: function(field) {
		var isInput = (field.nodeName.toLowerCase() == 'input');
		var range = (isInput ? field.createTextRange() : document.body.createTextRange());
		if (!isInput) {
			range.moveToElementText(field); // Selects all the text for a textarea
		}
		return range;
	},

	/* Set the text field to the selected value,
	   and trigger any on change event.
	   @param  inst   (object) the instance settings
	   @param  value  (string) the new value for the text field */
	_setValue: function(inst, value) {
		var maxlen = inst._input.attr('maxlength');
		if (maxlen > -1) {
			value = value.substr(0, maxlen);
		}
		inst._input.val(value);
		if (!this._get(inst, 'onKeypress')) {
			inst._input.trigger('change'); // fire the change event
		}
	},

	_notifyKeypress: function(inst, key) {
		var onKeypress = this._get(inst, 'onKeypress');
		if (onKeypress) { // trigger custom callback
			onKeypress.apply((inst._input ? inst._input[0] : null),
				[key, inst._input.val(), inst]);
		}
	},

	/* Get a setting value, defaulting if necessary.
	   @param  inst  (object) the instance settings
	   @param  name  (string) the name of the setting
	   @return  (any) the value of the setting, or its default if not set explicitly */
	_get: function(inst, name) {
		return inst.settings[name] !== undefined ?
			inst.settings[name] : this._defaults[name];
	},

	/* Generate the HTML for the current state of the keypad.
	   @param  inst  (object) the instance settings
	   @return  (jQuery) the HTML for this keypad */
	_generateHTML: function(inst) {
		var useTR = this._get(inst, 'useThemeRoller');
		var isRTL = this._get(inst, 'isRTL');
		var prompt = this._get(inst, 'prompt');
		var separator = this._get(inst, 'separator');
		var html = (!prompt ? '' : '<div class="keypad-prompt' +
			(useTR ? ' ui-widget-header ui-corner-all' : '') + '">' + prompt + '</div>');
		var layout = this._randomiseLayout(inst);
		for (var i = 0; i < layout.length; i++) {
			html += '<div class="keypad-row">';
			var keys = layout[i].split(separator);
			for (var j = 0; j < keys.length; j++) {
				if (inst.ucase) {
					keys[j] = keys[j].toUpperCase();
				}
				var keyDef = this._specialKeys[keys[j].charCodeAt(0)];
				if (keyDef) {
					html += (keyDef.action ? '<button type="button" class="keypad-special keypad-' +
						keyDef.name + (useTR ? ' ui-corner-all ui-state-default' +
						(keyDef.noHighlight ? '' : ' ui-state-highlight') : '') +
						'" title="' + this._get(inst, keyDef.name + 'Status') + '">' +
						(this._get(inst, keyDef.name + 'Text') || '&nbsp;') + '</button>' :
						'<div class="keypad-' + keyDef.name + '"></div>');
				}
				else {
					html += '<button type="button" ' +
						'class="keypad-key' + (useTR ? ' ui-corner-all ui-state-default' : '') + '">' +
						(keys[j] == ' ' ? '&nbsp;' : keys[j]) + '</button>';
				}
			}
			html += '</div>';
		}
		html += '<div style="clear: both;"></div>' + 
			(!inst._inline && $.browser.msie && parseInt($.browser.version, 10) < 7 ? 
			'<iframe src="javascript:false;" class="' + $.keypad._coverClass + '"></iframe>' : '');
		html = $(html);
		var thisInst = inst;
		var activeClasses = 'keypad-key-down' + (useTR ? ' ui-state-active' : '');
		html.find('button').mousedown(function() { $(this).addClass(activeClasses); }).
			mouseup(function() { $(this).removeClass(activeClasses); }).
			mouseout(function() { $(this).removeClass(activeClasses); }).
			filter('.keypad-key').click(function() { $.keypad._selectValue(thisInst, $(this).text()); });
		$.each(this._specialKeys, function(i, keyDef) {
			html.find('.keypad-' + keyDef.name).click(function() {
				keyDef.action.apply(thisInst._input, [thisInst]);
			});
		});
		return html;
	},

	/* Check whether characters should be randomised,
	   and, if so, produce the randomised layout.
	   @param  inst  (object) the instance settings
	   @return  (string[]) the layout with any requested randomisations applied */
	_randomiseLayout: function(inst) {
		var randomiseNumeric = this._get(inst, 'randomiseNumeric');
		var randomiseAlpha = this._get(inst, 'randomiseAlphabetic');
		var randomiseOther = this._get(inst, 'randomiseOther');
		var randomiseAll = this._get(inst, 'randomiseAll');
		var layout = this._get(inst, 'layout');
		if (!randomiseNumeric && !randomiseAlpha && !randomiseOther && !randomiseAll) {
			return layout;
		}
		var isNumeric = this._get(inst, 'isNumeric');
		var isAlphabetic = this._get(inst, 'isAlphabetic');
		var separator = this._get(inst, 'separator');
		var numerics = [];
		var alphas = [];
		var others = [];
		var newLayout = [];
		// Find characters of different types
		for (var i = 0; i < layout.length; i++) {
			newLayout[i] = '';
			var keys = layout[i].split(separator);
			for (var j = 0; j < keys.length; j++) {
				if (this._isControl(keys[j])) {
					continue;
				}
				if (randomiseAll) {
					others.push(keys[j]);
				}
				else if (isNumeric(keys[j])) {
					numerics.push(keys[j]);
				}
				else if (isAlphabetic(keys[j])) {
					alphas.push(keys[j]);
				}
				else {
					others.push(keys[j]);
				}
			}
		}
		// Shuffle them
		if (randomiseNumeric) {
			this._shuffle(numerics);
		}
		if (randomiseAlpha) {
			this._shuffle(alphas);
		}
		if (randomiseOther || randomiseAll) {
			this._shuffle(others);
		}
		var n = 0;
		var a = 0;
		var o = 0;
		// And replace them in the layout
		for (var i = 0; i < layout.length; i++) {
			var keys = layout[i].split(separator);
			for (var j = 0; j < keys.length; j++) {
				newLayout[i] += (this._isControl(keys[j]) ? keys[j] :
					(randomiseAll ? others[o++] :
					(isNumeric(keys[j]) ? numerics[n++] :
					(isAlphabetic(keys[j]) ? alphas[a++] :
					others[o++])))) + separator;
			}
		}
		return newLayout;
	},

	/* Is a given character a control character?
	   @param  ch  (char) the character to test
	   @return  (boolean) true if a control character, false if not */
	_isControl: function(ch) {
		return ch < ' ';
	},

	/* Is a given character alphabetic?
	   @param  ch  (char) the character to test
	   @return  (boolean) true if alphabetic, false if not */
	isAlphabetic: function(ch) {
		return (ch >= 'A' && ch <= 'Z') || (ch >= 'a' && ch <= 'z');
	},

	/* Is a given character numeric?
	   @param  ch  (char) the character to test
	   @return  (boolean) true if numeric, false if not */
	isNumeric: function(ch) {
		return (ch >= '0' && ch <= '9');
	},

	/* Randomise the contents of an array.
	   @param  values  (string[]) the array to rearrange */
	_shuffle: function(values) {
		for (var i = values.length - 1; i > 0; i--) {
			var j = Math.floor(Math.random() * values.length);
			var ch = values[i];
			values[i] = values[j];
			values[j] = ch;
		}
	}
});

/* jQuery extend now ignores nulls!
   @param  target  (object) the object to extend
   @param  props   (object) the new settings
   @return  (object) the updated target */
function extendRemove(target, props) {
	$.extend(target, props);
	for (var name in props) {
		if (props[name] == null || props[name] == undefined) {
			target[name] = props[name];
		}
	}
	return target;
};

/* Invoke the keypad functionality.
   @param  options  (string) a command, optionally followed by additional parameters or
                    (object) settings for attaching new keypad functionality
   @return  (object) the jQuery object */
$.fn.keypad = function(options) {
	var otherArgs = Array.prototype.slice.call(arguments, 1);
	if (options == 'isDisabled') {
		return $.keypad['_' + options + 'Keypad'].
			apply($.keypad, [this[0]].concat(otherArgs));
	}
	return this.each(function() {
		typeof options == 'string' ?
			$.keypad['_' + options + 'Keypad'].
				apply($.keypad, [this].concat(otherArgs)) :
			$.keypad._attachKeypad(this, options);
	});
};

$.keypad = new Keypad(); // singleton instance

// Add the keypad division and external click check
$(function() {
	$(document.body).append($.keypad.mainDiv).
		mousedown($.keypad._checkExternalClick);
});

})(jQuery);
