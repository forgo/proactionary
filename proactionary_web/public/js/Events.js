// Global Javascript Namespace of Events (Proactionary Application)
//  check for existence and avoid clobbering existing namespace/variable
var Events = Events === undefined ? {} : Events;

Events = (function() {
    // Event Filter Parameters
    var DAYS_PAST = 0;
    var DAYS_FUTURE = 30;
    var momentRange = updateMomentRange();
    var DB_DATE_FORMAT = "YYYY-MM-DD";
    var date1picker = null;
    var date2picker = null;
    var eventFilter = {};
    var eventCount = 0;

    function alertFilter(caller) {
        alert(caller + ": now filter is = " +  JSON.stringify(eventFilter, null, "  "));
    }

    function disableEventFilterForm() {
        document.getElementById("event_filter_form_fieldset").setAttribute("disabled", true); 
    }

    function enableEventFilterForm() {
        document.getElementById("event_filter_form_fieldset").removeAttribute("disabled");
    }

    function stringForLocation() {
        var lat = eventFilter["location"]["lat"];
        var lng = eventFilter["location"]["lng"];
        return "{ " + lat + ", " + lng + " }";
    }

    function setFilterDescription() {
        var filterDescription = document.getElementById("filter-description");
        if(filterDescription){
            if (eventFilter["date_option"] == "between") {
                filterDescription.innerHTML = eventFilter["category_label"] + " events " + 
                eventFilter["range"] + " miles from " + eventFilter["address"] + " " + eventFilter["date_option"] + " " +
                date1picker.toString() + " and " +  date2picker.toString() + ".";

            }
            else {
                filterDescription.innerHTML = eventFilter["category_label"] + " events " + 
                eventFilter["range"] + " miles from " + eventFilter["address"] + " " + eventFilter["date_option"] + " " + 
                date1picker.toString() + ".";
            }
        }
    }

    function setEventCountDescription() {
        var eventCountDescription = document.getElementById("event-count-description");
        if (eventCountDescription) {
            eventCountDescription.innerHTML = eventCount + " events found.";
        }
    }

    function aggregateEventsFromSections(sections) {
        'use strict';
        var promoters_encountered = {}
        var events = [];
        var ev = {}
        var section_events = [];
        for (var i = sections.length - 1; i >= 0; i--) {
            section_events = sections[i]["events"];

            for(var j = section_events.length -1; j >=0 ; j--) {

                // Duplicates of Promoters in Events Causes Unnecessary Redundancy in Map Markers
                if (Object.prototype.hasOwnProperty.call(promoters_encountered, section_events[j]["promoter_id"])) {
                    
                    if(section_events[j]["alt_location"] == "Y") {
                        alert('Encountered This Promoter, But This is an Alternate Location, Still Show on Map');
                        // Encountered This Promoter, But This is an Alternate Location, Still Show on Map
                        section_events[j]["show_marker"] = true;
                    }
                    else {
                        // Already Encountered This Location
                        section_events[j]["show_marker"] = false;
                    }
                }
                else {
                    // Add Promoter to Our "Encountered" Set of Promoters
                    promoters_encountered[section_events[j]["promoter_id"]] = true;

                    // Mark This Particular Event to Be Used for Unique Map Marker
                    section_events[j]["show_marker"] = true;
                }
            }

            events = events.concat(section_events);
            section_events = [];
        };
        return events;
    }

    function filterRequest() {
        'use strict';

        // Disable Ability to Interact with Event Filter While Getting Response
        disableEventFilterForm();

        // Show Spinner Animated GIF While Processing Event Results
        var spinner = document.getElementById("events_spinner");
        spinner.style.visibility = "visible";

        // Update The Description of Events Being Returned on Page
        setFilterDescription();

       eventFilter["location"]["subloc"] = {"subsubint":792,"subsubfloat":3.14,"subsubstring":"lolwut"};
       eventFilter["abraham"] = [2,["a","b","c"],{"keyinception":"cowabunga"},8];

        // AJAX Request To Return Events Based On Current Filter Values
        JHRGet("/events", eventFilter, function(response, xhr) {
        // JHR("/events", eventFilter, function(response, xhr) {
            // Hide Spinner When Response Is Available
            spinner.style.visibility = "hidden";

            // Re-enable Ability to Interact with Event Filter Form
            enableEventFilterForm();

            // The Response is Not Ready or the Status is Not OK
            if (xhr.readyState != 4 || xhr.status != 200) {
                return;
            }

            // Update Event Count and Show Description
            eventCount = response["events"]["count"];
            setEventCountDescription();

            // Using the Payload of the Response, Populate the Sidebar Events
            document.getElementById("sidebar-content").innerHTML = response["sidebar"];

            // Using the Payload of the Response, Re-Draw Markers on Map
            // Re-orient the Map for Results
            var aggEvents = aggregateEventsFromSections(response["events"]["sections"]);
            GMaps.reorientOnMarker(parseFloat(eventFilter["range"]), aggEvents);
        })
    }

    function getNextElement(field) {
        var form = field.form;
        for ( var e = 0; e < form.elements.length; e++) {
            if (field == form.elements[e]) {
                break;
            }
        }
        ++e;
        return form.elements[e % form.elements.length];
    }

    function tabOnEnter(field, evt) {

        if (evt.keyCode === 9) {
            Events.update();
        }

        if (evt.keyCode === 13) {
            if (evt.preventDefault) {
                evt.preventDefault();
            } else if (evt.stopPropagation) {
                evt.stopPropagation();
            } else {
                evt.returnValue = false;
            }
            if (field.id == "event_location") {
                Events.update();
            }
            getNextElement(field).focus();
            return false;
        } else {
            return true;
        }
    }

    function getEventTarget(event) {
        event = event || window.event;
        return event.target || event.srcElement; 
    }

    function updateSelectedLI(event, ul_id) {
        'use strict';
        var ul = document.getElementById(ul_id);

        // ul.classList.add("notransition");

        // // do stuff
        // ul.style.visibility = 'hidden';
        // ul.offsetHeight;

        // ul.classList.remove("notransition");

        // ul.style.visibility = 'visible';
        // ul.offsetHeight;


        var lis = ul.getElementsByTagName("li");
        var selectedLI, lastSelectedLI;

        // Iterate Over List Items and Unselect All
        for (var i = 0, len = lis.length, li; i < len; ++i) {
            li = lis[i];

            // Remember This List Item if it was Previously Selected
            if (li.getAttribute("data-selected") == "true") {
                lastSelectedLI = li;
            }
            li.setAttribute("data-selected","false");
        }

        if (event) {
            selectedLI = getEventTarget(event);
            selectedLI.setAttribute("data-selected","true");
            return selectedLI;
        }
        else {
            lastSelectedLI.setAttribute("data-selected","true");
            return lastSelectedLI;
        }
    }

    function updateCategory(event) {
        'use strict';
        var li = updateSelectedLI(event, "event_category", "category_id");
        eventFilter["category_id"] = li.getAttribute("data-value");
        eventFilter["category_label"] = li.innerHTML;
        //alertFilter("updateCategory");
    }

    function updateRange(event) {
        'use strict'
        var li = updateSelectedLI(event, "event_range");
        eventFilter["range"] = li.getAttribute("data-value");
        //alertFilter("updateRange");
    }

    function updateDateOption(event) {
        'use strict'
        var li = updateSelectedLI(event, "event_date_option");
        eventFilter["date_option"] = li.getAttribute("data-value");
    }

    function updateMomentRange() {
        // <daysPast> ago, at midnight (00:00:00)
        var minMoment = moment().set('hour',0).set('minute',0).set('second',0).subtract('days',DAYS_PAST);
        // <daysFuture> from now, before the clock strikes midnight (23:59:59)
        var maxMoment = minMoment.clone().add('days',DAYS_FUTURE).set('hour',23).set('minute',59).set('second',59);
        return [minMoment,maxMoment];
    }

    function updateDate() {
        var date1 = document.getElementById("date1");
        var date2 = document.getElementById("date2");

        if (eventFilter["date_option"] == "on") {
            date2.style.visibility = 'hidden';
            date2picker = null;
            updateMomentRange();
            bindDate1Picker();
            date1picker.setMoment(momentRange[0].clone().add('days',DAYS_PAST).toDate());
            date1picker.setMinDate(momentRange[0].clone().subtract('seconds',1).toDate());
            date1picker.setMaxDate(momentRange[1].toDate());
            eventFilter["date1"] = date1picker.getMoment().utc().format(DB_DATE_FORMAT);
            eventFilter["date2"] = "";
        }
        else if (eventFilter["date_option"] == "between") {
            date2.style.visibility = 'visible';
            bindDate1Picker();
            bindDate2Picker();
            eventFilter["date1"] = date1picker.getMoment().utc().format(DB_DATE_FORMAT);
            eventFilter["date2"] = date2picker.getMoment().utc().format(DB_DATE_FORMAT);
        }
        //alertFilter("updateDate");
    }

    function date1PickerChanged() {
        if (date2picker !== null) {
            var newDate2Min = date1picker.getMoment().clone().add('days',1);
            date2picker.setMinDate(newDate2Min.toDate());
            var newDate1Max = date2picker.getMoment().clone().subtract('days',1);
            date1picker.setMaxDate(newDate1Max);
            eventFilter["date1"] = date1picker.getMoment().utc().format(DB_DATE_FORMAT);
        }
        else {
            eventFilter["date2"] = "";
        }
    }

    function date2PickerChanged() {
        if (date1picker !== null) {
            var newDate2Min = date2picker.getMoment().clone();
            date2picker.setMoment(newDate2Min.clone().set('hour',23).set('minute',59).set('second',59),true);
            date2picker.setMinDate(newDate2Min.toDate());
            var newDate1Max = date2picker.getMoment().clone().subtract('days',1);
            date1picker.setMaxDate(newDate1Max.toDate());
            eventFilter["date2"] = date2picker.getMoment().utc().format(DB_DATE_FORMAT);
        }
        else {
            eventFilter["date1"] = "";
        }
    }

    function bindDate1Picker() {
        'use strict';
        var date1field = document.getElementById("date1-field");
        var date1trigger = document.getElementById("date1-trigger");

        if(!date1picker) {
            date1picker = new Pikaday(
            {
                field: date1field,
                trigger: date1trigger,
                format: "MMM DD, YYYY",
                minDate: momentRange[0].clone().subtract('seconds',1).toDate(),
                maxDate: momentRange[1].toDate(),
                onOpen: function() {
                    var picker = this;
                    date1trigger.onkeydown = function(evt) {
                        var selectedDate = picker.getDate();
                        navigatePicker(picker, evt.keyCode, selectedDate);
                        tabOnEnter(date1field,evt);
                    };
                },
                onSelect: function() {
                    date1field.innerHTML = date1picker.toString();
                    date1PickerChanged();
                    Events.updateDate();
                }
            });
            // Set Initial Date for Picker 1 to Minimum of Range
            //  2nd param true avoids callback to onSelect
            date1picker.setMoment(momentRange[0].clone().add('days',DAYS_PAST),true);
        }
    }

    function bindDate2Picker() {
        'use strict';
        var date2field = document.getElementById("date2-field");
        var date2trigger = document.getElementById("date2-trigger");

        if(!date2picker) {
            date2picker = new Pikaday(
            {
                field: date2field,
                trigger: date2trigger,
                format: "MMM DD, YYYY",
                minDate: momentRange[0].clone().add('days',1).toDate(),
                maxDate: momentRange[1].toDate(),
                onOpen: function() {
                    var picker = this;
                    date2trigger.onkeydown = function(evt) {
                        var selectedDate = picker.getDate();
                        navigatePicker(picker, evt.keyCode, selectedDate);
                        tabOnEnter(date2field,evt);
                    };
                },
                onSelect: function() {
                    date2field.innerHTML = date2picker.toString();
                    date2PickerChanged();
                    Events.updateDate();
                }
            });
            // Set Initial Date for Picker 2 to Very End of Next Day From Picker 1
            //  2nd param true avoids callback to onSelect
            date2picker.setMoment(date1picker.getMoment().clone().set('hour',23).set('minute',59).set('second',59).add('days',1),true);
            date2picker.setMinDate(date1picker.getMoment().clone().add('days',1).toDate());
            date1picker.setMaxDate(date1picker.getMoment().toDate());
        }

    }

    // TODO: Fix updates based on keyboard changes of calendar days
    //       don't allow for movements beyond min/max range, for example
    //       avoid updating query every keyboard move? or good feature?
    var navigatePicker = function(picker, keycode, selectedDate) {
        switch (keycode) {
            // Left
            case 37:
                //alert("left");
                var prevDay = moment(selectedDate).subtract("days", 1).toDate();
                picker.setDate(prevDay);
                break;
            // Right
            case 39:
                //alert("right");
                var nextDay = moment(selectedDate).add("days", 1).toDate();
                picker.setDate(nextDay);
                break;
            // Top
            case 38:
                //alert("top");
                var prevWeek = moment(selectedDate).subtract("weeks", 1).toDate();
                picker.setDate(prevWeek);
                break;
            // Down
            case 40:
                //alert("down");
                var nextWeek = moment(selectedDate).add("weeks", 1).toDate();
                picker.setDate(nextWeek);
                break;
            // Esc or Enter
            case 27:
            case 13:
            picker.hide();
            if (picker == date1picker) {date1PickerChanged();}
            if (picker == date2picker) {date2PickerChanged();}
            break;
            default:
            break;
        }
    };

    function suggestCoordinate() {
        'use strict';
        eventFilter["location_option"] = "coordinate";

        // AJAX Request to Return Coordinates / Bounds Based on IP / Given Range
        JHR("/suggest_coordinate_browser", { range: eventFilter["range"] }, function(response, xhr) {

            // The Response is Not Ready or the Status is Not OK
            if (xhr.readyState != 4 || xhr.status != 200) {
                return;
            }

            eventFilter["location"] = response["center"];
            eventFilter["address"] = response["address"].isEmpty ? "no address found" : response["address"];

            // THIS IS IMPORTANT TO INITIALLY CREATE THE MAP OBJECT
            GMaps.reorientOnMarker;
            GMaps.frameAndCenter(response["min"], response["max"], response["center"], parseFloat(eventFilter["range"]));

            filterRequest();
        })
    }

    function provideCoordinate(coordinate, range) {
        'use strict';
        eventFilter["location_option"] = "coordinate";

        // AJAX Request to Return Coordinates / Bounds Based on IP / Given Range
        JHR("/provide_coordinate_browser", { coordinate: coordinate, range: eventFilter["range"] }, function(response, xhr) {

            // The Response is Not Ready or the Status is Not OK
            if (xhr.readyState != 4 || xhr.status != 200) {
                return;
            }

            if (coordinate) {
                eventFilter["location"] = coordinate;
            }
            else {
                eventFilter["location"] = response["center"];
            }
            eventFilter["address"] = response["address"];

            // THIS IS IMPORTANT TO INITIALLY CREATE THE MAP OBJECT
            GMaps.frameAndCenter(response["min"], response["max"], response["center"], parseFloat(eventFilter["range"]));

            filterRequest();
        })
    }

    function update(event_category, event_range, event_date_option, map_click, coordinate, range) {
        'use strict';
        
        updateCategory(event_category);
        updateRange(event_range);
        updateDateOption(event_date_option);
        updateDate();

        if (map_click) {
            provideCoordinate(coordinate, range);
        }
        else {
            suggestCoordinate();
        }
    }

    return {
        update: function() {
            update(null, null, null, false, null, null);
        },
        updateCategory: function(event) {
            update(event, null, null, false, null, null);
        },
        updateRange: function(event) {
            update(null, event, null, false, null, null);
        },
        updateDateOption: function(event) {
            update(null, null, event, false, null, null);
        },
        updateDate: function() {
            update(null, null, null, false, null, null);
        },
        mapClick: function(coordinate, range) {
            update(null, null, null, true, coordinate, range);
        }
    };
})();
