// --------------------------------------------------------------------
//
// Touchscreen Toolkit
//
// (c) 2010 Baobab Health Partnership www.baobabhealth.org

//This library is free software; you can redistribute it and/or
//modify it under the terms of the GNU Lesser General Public
//License as published by the Free Software Foundation; either
//version 2.1 of the License, or (at your option) any later version.
//
//This library is distributed in the hope that it will be useful,
//but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
//Lesser General Public License for more details.
//
//You should have received a copy of the GNU Lesser General Public
//License along with this library; if not, write to the Free Software
//Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
//
// --------------------------------------------------------------------
//


function updateKeyColor(element){
    for(node in element.parentNode.childnodes){
        element.style.backgroundColor = ""
    }
    element.style.backgroundColor = "lightblue"
}

var TimeSelector = function() {
    this.time = [new Date().getHours(), new Date().getMinutes(), new Date().getSeconds()];
        
    if (! arguments[0])
        arguments[0] = {};

    this.options = {
        hour: arguments[0].hour || this.time[0],
        minute: arguments[0].minute || this.time[1],
        second: arguments[0].second || this.time[2],
        format: "H:M:S",
        element: arguments[0].element || document.body,
        target: arguments[0].target
    };

    if (typeof(tstCurrentTime) != "undefined" && tstCurrentTime) {
        var splitTime = tstCurrentTime.split(":");
        if (splitTime.length == 3) {
            this.time = [splitTime[0], splitTime[1], splitTime[2]];
        }
    }	else {
        this.time = [this.options.hour, this.options.minute, this.options.second];
    }
    this.element = this.options.element;
    this.format = this.options.format;
    this.target = this.options.target;

    this.element.appendChild(this.build());

    this.currentHour = $('timeselector_hour');
    this.currentMinute = $('timeselector_minute');
    //this.currentSecond = $('timeselector_second');

    this.currentHour.value = this.time[0];
    this.currentMinute.value = this.time[1];
    //this.currentSecond.value = this.time[2];
};

TimeSelector.prototype = {
    build: function() {
        var node = document.createElement('div');
        // TODO: move style stuff to a css file
        node.innerHTML = ' \
			<div id="timeselector" class="dateselector"> \
			<table><tr> \
			<td valign="top"> \
			<div style="display: inline;" > \
                                <div style="text-align:center; width:100%; font-size:1.8em;">Hr</div>\
				<button id="timeselector_nextHour" onmousedown="ds.incrementHour();"><span>+</span></button> \
				<input id="timeselector_hour" type="text" > \
				<button id="timeselector_preHour" onmousedown="ds.decrementHour();"><span>-</span></button> \
			</div> \
			</td><td> \
			<div style="display: inline;"> \
                                <div style="text-align:center; width:100%; font-size:1.8em;">Min</div>\
				<button id="timeselector_nextMinute" onmousedown="ds.incrementMinute();"><span>+</span></button> \
				<input id="timeselector_minute" type="text"> \
				<button id="timeselector_preMinute" onmousedown="ds.decrementMinute();"><span>-</span></button> \
			</div> \
			</td><td> \
			<!--div style="display: inline;"> \
                                <div style="text-align:center; width:100%; font-size:1.8em;">Sec</div>\
				<button id="timeselector_nextSecond" onmousedown="ds.incrementSecond();"><span>+</span></button> \
				<input id="timeselector_second" type="text"> \
				<button id="timeselector_preSecond" onmousedown="ds.decrementSecond();"><span>-</span></button> \
			</div--> \
			</td><td> \
			<!--button id="Unknown" onmousedown="updateKeyColor(this);press(this.id);" style=""><span>Unknown</span></button--> \
			</tr></table> \
			</div> \
		';

        return node;
    },

    init: function() {
        this.update(this.target);
    },


    incrementHour: function() {
        if(this.currentHour.value >= (new Date().getHours())){
            
        } else if(this.currentHour.value == 23){
            this.currentHour.value = 0;
        } else {
            this.currentHour.value++;
        }
        
        this.time[0] = this.currentHour.value;
        this.update(this.target);
    },

    decrementHour: function() {
        if(this.currentHour.value == 0){
            this.currentHour.value = 0;
        } else {
            this.currentHour.value--;
        }

        this.time[0] = this.currentHour.value;
        this.update(this.target);
    },

    incrementMinute: function() {
        if(this.currentMinute.value == 59){
            this.currentMinute.value = 0;
            //} else if(this.currentMinute.value >= (new Date().getMinutes())){
            //  this.currentMinute.value++;
        } else  {
            this.currentMinute.value++;
        }

        this.time[1] = this.currentMinute.value;
        this.update(this.target);
    },

    decrementMinute: function() {
        if(this.currentMinute.value == 0){
            this.currentMinute.value = 0;
        } else {
            this.currentMinute.value--;
        }

        this.time[1] = this.currentMinute.value;
        this.update(this.target);
    },

    incrementSecond: function() {
        if(this.currentSecond.value == 59){
            this.currentSecond.value = 0;
        } else {
            this.currentSecond.value++;
        }

        this.time[2] = this.currentSecond.value;
        this.update(this.target);
    },

    decrementSecond: function() {
        if(this.currentSecond.value == 0){
            this.currentSecond.value = 0;
        } else {
            this.currentSecond.value--;
        }

        this.time[2] = this.currentSecond.value;
        this.update(this.target);
    },

    update: function(aDateElement) {
        var aTargetElement = aDateElement || this.target;

        if (!aTargetElement)
            return;

        aTargetElement.value = TimeUtil.zerofill((this.time[0]).toString(),2) + ":" +
                               TimeUtil.zerofill((this.time[1]).toString(),2) + ":" +
                               TimeUtil.zerofill((this.time[2]).toString(),2);
    }

};

/**
 * TimeUtil
 */
var TimeUtil = {
    zerofill: function(time,digit){
        var result = time;
        if(time.length < digit){
            var tmp = digit - time.length;
            for(i=0; i < tmp; i++){
                result = "0" + result;
            }
        }
        return result;
    }
}


