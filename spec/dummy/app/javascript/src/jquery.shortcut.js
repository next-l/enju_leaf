/**
 * LICENSE: Copyright (c) 2011 François 'cahnory' Germain
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 * that is available through the world-wide-web at the following URI:
 * http://www.php.net/license/3_01.txt.  If you did not receive a copy of
 * the PHP License and are unable to obtain it through the web, please
 * send a note to license@php.net so we can mail you a copy immediately.
 *
 * @author     François 'cahnory' Germain <cahnory@gmail.com>
 * @copyright  2011 François Germain
 * @license    http://www.opensource.org/licenses/mit-license.php
 */
(function($) {
	//	Private vars
	var	_pluginID		=	'shortcut-ID',	//	plugin unique ID (namespace, data,...)
		_ready			=	false,			//	if the plugin is ready to listen shortcuts
		_pressedKeys	=	[],				//	pressed keys ordered
		_keyStates		=	{},				//	avoid doublon
		_pressed		=	[],
		_keyNames		=	{
			8: 'backspace', 9: 'tab', 13: 'enter', 16: 'shift', 17: 'ctrl', 18: 'alt', 19: 'pause/break', 20: 'caps lock', 27: 'escape', 33: 'page up', 34: 'page down', 35: 'end', 36: 'home', 37: 'left arrow', 38: 'up arrow', 39: 'right arrow', 40: 'down arrow', 45: 'insert', 46: 'delete', 48: '0', 49: '1', 50: '2', 51: '3', 52: '4', 53: '5', 54: '6', 55: '7', 56: '8', 57: '9', 65: 'a', 66: 'b', 67: 'c', 68: 'd', 69: 'e', 70: 'f', 71: 'g', 72: 'h', 73: 'i', 74: 'j', 75: 'k', 76: 'l', 77: 'm', 78: 'n', 79: 'o', 80: 'p', 81: 'q', 82: 'r', 83: 's', 84: 't', 85: 'u', 86: 'v', 87: 'w', 88: 'x', 89: 'y', 90: 'z', 91: 'left window key', 92: 'right window key', 93: 'select key', 96: 'numpad 0', 97: 'numpad 1', 98: 'numpad 2', 99: 'numpad 3', 100: 'numpad 4', 101: 'numpad 5', 102: 'numpad 6', 103: 'numpad 7', 104: 'numpad 8', 105: 'numpad 9', 106: 'multiply', 107: 'add', 109: 'subtract', 110: 'decimal point', 111: 'divide', 112: 'f1', 113: 'f2', 114: 'f3', 115: 'f4', 116: 'f5', 117: 'f6', 118: 'f7', 119: 'f8', 120: 'f9', 121: 'f10', 122: 'f11', 123: 'f12', 144: 'num lock', 145: 'scroll lock', 186: 'semi-colon', 187: 'equal sign', 188: 'comma', 189: 'dash', 190: 'period', 191: 'forward slash', 192: 'grave accent', 219: 'open bracket', 220: 'back slash', 221: 'close braket', 222: 'single quote'
		},
		_keyNums		=	[],
		//	Initialize the plugin (only once)
		_init			=	function() {
			if(!_ready) {
				$(window).add(document).bind('focus.' + _pluginID + ' blur.' + _pluginID, function(e) {
					if(_pressedKeys.length) {
						var	last	=	$().shortcut.toString();
						_keyStates		=	{};
						_pressedKeys	=	[];
						
						//	Released shortcut
						toRelease	=	_pressed;
						for(i in toRelease)
							_trigger(toRelease[i], last, e, true);
					}
				});
				
				//	Key num by name
				for(i in _keyNames)
					_keyNums[_keyNames[i]]	=	i;
				
				_ready	=	true;
			}
		},
		//	Refresh shortcut
		_refresh		=	function(e, pressed) {
			var	key	=	e.keyCode ? e.keyCode : e.which;
			if(!_keyStates[key] && pressed) {
				_pressedKeys.push(key);
				_keyStates[key]	=	true;
			} else if(!pressed) {
				_keyStates[key]	=	false;
				for(i in _pressedKeys) {
					if(_pressedKeys[i] == key) {
						_pressedKeys.splice(i,1);
						break;
					}
				}
			}
		},
		//	shortcut name to num
		_parseShortcut	=	function(shortcut) {
			shortcut	=	shortcut.split('+');
			key			=	[];
			for(i in shortcut) {
				if(_keyNums[shortcut[i]]) {
					key.push(_keyNums[shortcut[i]]);
				} else {
					//	Invalid shortcut
					return false;
				}
			}
			return	key.join('+');
		},
		_trigger		=	function($this, shortcut, e, release) {
			shortcut	=	shortcut.split('.');
			namespace	=	shortcut[1];
			shortcuts	=	shortcut[0].split(',');
			for(i in shortcuts) {
				shortcut	=	_parseShortcut(shortcuts[i]);
				
				if(!shortcut)
					return	false;
				
				data		=	$this.data(_pluginID);
				
				if(release) {
					callback	=	1;
					for(i in _pressed) {
						if(_pressed[i] == $this) {
							_pressed.splice(i, 1);
							break;
						}
					}
				} else {
					callback	=	0;
					_pressed.push($this);
				}
				
				if(data.sBinds[shortcut]) {
					for(i in data.sBinds[shortcut])
						data.sBinds[shortcut][i][callback].apply($this, [e]);
				}
				if(!namespace){
					if(data.binds[shortcut] && data.binds[shortcut][callback])
						data.binds[shortcut][callback].apply($this, [e]);
				}
			}
		},
		//	Public methods
		_methods		=	{
			bind:	function(shortcut, callback, releaseCallback) {				
				shortcut	=	shortcut.split('.');
				namespace	=	shortcut[1];
				shortcuts	=	shortcut[0].split(',');
				for(i in shortcuts) {
					shortcut	=	_parseShortcut(shortcuts[i]);
					
					if(!shortcut)
						return	false;
					
					var	data	=	$(this).data(_pluginID);
					
					if(namespace) {
						//	Create namespace if doesn't exist
						if(!data.sBinds[shortcut])
							data.sBinds[shortcut]	=	[];
						
						data.sBinds[shortcut][namespace]	=	[callback, releaseCallback];
					} else {
						data.binds[shortcut]				=	[callback, releaseCallback];
					}
				}
			},
			trigger:	function(shortcut, e, release) {
				_trigger($(this), shortcut, e, release);
			},
			unbind:		function(shortcut) {
				shortcut	=	shortcut.split('.');
				namespace	=	shortcut[1];
				shortcuts	=	shortcut[0].split(',');
				for(i in shortcuts) {
					shortcut	=	_parseShortcut(shortcuts[i]);
					
					if(!shortcut)
						return	false;
					
					var	data	=	$(this).data(_pluginID);
					
					if(namespace) {
						data.sBinds[shortcut][namespace]	=	undefined;
					} else {
						data.binds[shortcut]				=	undefined;
					}
				}
			}
		};
	
	//	Plugin front controller
	$.fn.shortcut	=	function(inputs) {
		var	args	=	arguments,
			el		=	$(this).selector
					?	this
					:	$(document);
		
		_init();
		
		el.each(function() {
			var	$this	=	$(this),
				data	=	$this.data(_pluginID);
			
			//	Init if object wasn't
			if (!data) {				
				options	=	{
					binds:	{},
					sBinds:	{}
				};
				
				$this.data(_pluginID, options);
				
				$this.bind('keydown.shortcut',function(e){
					var	last	=	$().shortcut.toString();
					_refresh(e, true);
					var	current	=	$().shortcut.toString();
					
					//	Released shortcut
					if(last)
						_trigger($this, last, e, true);
					
					//	Pressed shortcut
					_trigger($this, $().shortcut.toString(), e);
				});
				$this.bind('keyup.shortcut',function(e){
					var	last	=	$().shortcut.toString();
					_refresh(e, false);
					
					//	Released shortcut
					_trigger($this, last, e, true);
				});
			}
			
			//	Method is called
			if (!_methods[inputs])
				return	_methods['bind'].apply(this, args);
			else
				return	_methods[inputs].apply(this, Array.prototype.slice.call(args, 1));
			
			//test
			$this.val($this.data(_pluginID).id);
		});
		return	this;
	}
	
	//	Return current pressed shortcut
	$.fn.shortcut.toString		=	function() {
		_init();
		shortcut	=	[];
		for(i in _pressedKeys)
			shortcut.push(_keyNames[_pressedKeys[i]]);
		
		return	shortcut.join('+');
	}
})(jQuery);