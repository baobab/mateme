
// Array of max days in month in a year and in a leap year
monthMaxDays	= [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
monthMaxDaysLeap= [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
hideSelectTags = [];

function getRealYear(dateObj)
{
    return (dateObj.getYear() % 100) + (((dateObj.getYear() % 100) < 39) ? 2000 : 1900);
}

function getDaysPerMonth(month, year)
{
    /*
	Check for leap year. These are some conditions to check year is leap year or not...
	1.Years evenly divisible by four are normally leap years, except for... 
	2.Years also evenly divisible by 100 are not leap years, except for... 
	3.Years also evenly divisible by 400 are leap years. 
	*/
    if ((year % 4) == 0)
    {
        if ((year % 100) == 0 && (year % 400) != 0)
            return monthMaxDays[month];
	
        return monthMaxDaysLeap[month];
    }
    else
        return monthMaxDays[month];
}

function createCalender(year, month, day)
{
    // current Date
    var curDate = new Date();
    var curDay = curDate.getDate();
    var curMonth = curDate.getMonth();
    var curYear = getRealYear(curDate)

    // if a date already exists, we calculate some values here
    if (!year)
    {
        var year = curYear;
        var month = curMonth;
    }

    var yearFound = 0;
    for (var i=0; i<document.getElementById('selectYear').options.length; i++)
    {
        if (document.getElementById('selectYear').options[i].value == year)
        {
            document.getElementById('selectYear').selectedIndex = i;
            yearFound = true;
            break;
        }
    }
    if (!yearFound)
    {
        document.getElementById('selectYear').selectedIndex = 0;
        year = document.getElementById('selectYear').options[0].value;
    }
    document.getElementById('selectMonth').selectedIndex = month;

    // first day of the month.
    var fristDayOfMonthObj = new Date(year, month, 1);
    var firstDayOfMonth = fristDayOfMonthObj.getDay();

    continu		= true;
    firstRow	= true;
    var x	= 0;
    var d	= 0;
    var trs = []
    var ti = 0;
    while (d <= getDaysPerMonth(month, year))
    {
        if (firstRow)
        {
            trs[ti] = document.createElement("TR");
            if (firstDayOfMonth > 0)
            {
                while (x < firstDayOfMonth)
                {
                    trs[ti].appendChild(document.createElement("TD"));
                    x++;
                }
            }
            firstRow = false;
            var d = 1;
        }
        if (x % 7 == 0)
        {
            ti++;
            trs[ti] = document.createElement("TR");
        }
        if (day && d == day)
        {
            var setID = 'calenderChoosenDay';
            var styleClass = 'choosenDay';
            var setTitle = 'this day is currently selected';
        }
        else if (d == curDay && month == curMonth && year == curYear)
        {
            var setID = 'calenderToDay';
            var styleClass = 'toDay';
            var setTitle = 'this day today';
        }
        else
        {
            var setID = false;
            var styleClass = 'normalDay';
            var setTitle = false;
        }
        var td = document.createElement("TD");
        td.className = styleClass;
        if (setID)
        {
            td.id = setID;
        }
        if (setTitle)
        {
            td.title = setTitle;
        }
        td.onmouseover = new Function('highLiteDay(this)');
        td.onmouseout = new Function('deHighLiteDay(this)');
        if (targetEl)
            td.onclick = new Function('pickDate('+year+', '+month+', '+d+')');
        else
            td.style.cursor = 'default';
        td.appendChild(document.createTextNode(d));
        trs[ti].appendChild(td);
        x++;
        d++;
    }
    return trs;
}

function showCalender(elPos, tgtEl)
{
    if(document.getElementById("calenderTable").style.display == "block"){
        closeCalender();
        return;
    }
    
    targetEl = false;

    if (document.getElementById(tgtEl))
    {
        targetEl = document.getElementById(tgtEl);
    }
    else
    {
        if (document.forms[0].elements[tgtEl])
        {
            targetEl = document.forms[0].elements[tgtEl];
        }
    }
    var calTable = document.getElementById('calenderTable');

    var positions = [0,0];
    var positions = getParentOffset(elPos, positions);
    //calTable.style.left = positions[0]+'px';
    //calTable.style.top = (positions[1]+elPos.offsetHeight)+'px';

    calTable.style.display='block';

    var matchDate = new RegExp('^([0-9]{2})-([0-9]{2})-([0-9]{4})$');
    var m = matchDate.exec(targetEl.value);
    if (m == null)
    {
        trs = createCalender(false, false, false);
        showCalenderBody(trs);
    }
    else
    {
        if (m[1].substr(0, 1) == 0)
            m[1] = m[1].substr(1, 1);
        if (m[2].substr(0, 1) == 0)
            m[2] = m[2].substr(1, 1);
        m[2] = m[2] - 1;
        trs = createCalender(m[3], m[2], m[1]);
        showCalenderBody(trs);
    }

    calTable.style.left = (positions[0] + elPos.offsetWidth - calTable.offsetWidth)+'px';
    calTable.style.top = (positions[1]-calTable.offsetHeight)+'px';
    
    hideSelect(document.body, 1);
}
function showCalenderBody(trs)
{
    var calTBody = document.getElementById('calender');
    while (calTBody.childNodes[0])
    {
        calTBody.removeChild(calTBody.childNodes[0]);
    }
    for (var i in trs)
    {
        calTBody.appendChild(trs[i]);
    }
}
function setYears(sy, ey)
{
    // current Date
    var curDate = new Date();
    var curYear = getRealYear(curDate);
    if (sy)
        startYear = curYear;
    if (ey)
        endYear = curYear;
    document.getElementById('selectYear').options.length = 0;
    var j = 0;
    for (y=ey; y>=sy; y--)
    {
        document.getElementById('selectYear')[j++] = new Option(y, y);
    }
}
function hideSelect(el, superTotal)
{
    if (superTotal >= 100)
    {
        return;
    }

    var totalChilds = el.childNodes.length;
    for (var c=0; c<totalChilds; c++)
    {
        var thisTag = el.childNodes[c];
        if (thisTag.tagName == 'SELECT')
        {
            if (thisTag.id != 'selectMonth' && thisTag.id != 'selectYear')
            {
                var calenderEl = document.getElementById('calenderTable');
                var positions = [0,0];
                var positions = getParentOffset(thisTag, positions);	// nieuw
                var thisLeft	= positions[0];
                var thisRight	= positions[0] + thisTag.offsetWidth;
                var thisTop	= positions[1];
                var thisBottom	= positions[1] + thisTag.offsetHeight;
                var calLeft	= calenderEl.offsetLeft;
                var calRight	= calenderEl.offsetLeft + calenderEl.offsetWidth;
                var calTop	= calenderEl.offsetTop;
                var calBottom	= calenderEl.offsetTop + calenderEl.offsetHeight;

                if (
                    (
                        /* check if it overlaps horizontally */
                        (thisLeft >= calLeft && thisLeft <= calRight)
                        ||
                        (thisRight <= calRight && thisRight >= calLeft)
                        ||
                        (thisLeft <= calLeft && thisRight >= calRight)
                        )
                    &&
                    (
                        /* check if it overlaps vertically */
                        (thisTop >= calTop && thisTop <= calBottom)
                        ||
                        (thisBottom <= calBottom && thisBottom >= calTop)
                        ||
                        (thisTop <= calTop && thisBottom >= calBottom)
                        )
                    )
                    {
                    hideSelectTags[hideSelectTags.length] = thisTag;
                    thisTag.style.display = 'none';
                }
            }

        }
        else if(thisTag.childNodes.length > 0)
        {
            hideSelect(thisTag, (superTotal+1));
        }
    }
}
function closeCalender()
{
    for (var i=0; i<hideSelectTags.length; i++)
    {
        hideSelectTags[i].style.display = 'block';
    }
    hideSelectTags.length = 0;
    document.getElementById('calenderTable').style.display='none';
}
function highLiteDay(el)
{
    el.className = 'hlDay';
}
function deHighLiteDay(el)
{
    if (el.id == 'calenderToDay')
        el.className = 'toDay';
    else if (el.id == 'calenderChoosenDay')
        el.className = 'choosenDay';
    else
        el.className = 'normalDay';
}
function pickDate(year, month, day)
{
    month++;
    day	= day < 10 ? '0'+day : day;
    month	= month < 10 ? '0'+month : month;
    if (!targetEl)
    {
        alert('target for date is not set yet');
    }
    else
    {
        targetEl.value= year+'-'+month+'-'+day;
        closeCalender();
    }
}
function getParentOffset(el, positions)
{
    positions[0] += el.offsetLeft;
    positions[1] += el.offsetTop;
    if (el.offsetParent)
        positions = getParentOffset(el.offsetParent, positions);
    return positions;
}