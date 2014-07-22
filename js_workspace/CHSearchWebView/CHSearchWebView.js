var SPNS = SPNS || {};

SPNS.search = (function() {
	var HighlightClassName = "MyAppHighlight100500uniqueName";
	var SearchResultCount = 0;
	var FoundElements = new Array();
	var FoundElementsCurrentPosition = 0;
	
	//// public functions ////
	// search with text, main entry point
	var search = function(keyword) {
		if( keyword.length != 0 ) {
			SearchAllOccurencesOfString(keyword);
		}
	};
	
	// search function which takes value from element with identifier
	var searchFromElement = function(identifier) {
	   var searchStr = document.getElementById(identifier).value;
	   search(searchStr);
	};
	
	// scroll to the next found element
	var highlightNextResult = function() {
	    var index = (FoundElementsCurrentPosition + 1) % SearchResultCount;
	    ScrollToFoundElement(index);
	};
	
	// scroll to the previous found element
	var highlightPreviousResult = function() {
		var index = FoundElementsCurrentPosition - 1;
		if (index < 1) index = SearchResultCount;
	    ScrollToFoundElement(index);
	};
	
	//// private functions ////
	// highlight all occurences with text and scroll to the first found
	var SearchAllOccurencesOfString = function(keyword) {
	    HighlightAllOccurencesOfString(keyword);
	    if (SearchResultCount > 0) {
	        ScrollToFoundElement(0);
	    }
	};
	
	// does the actual highlight operation after clearing all the mess from previous search
	var HighlightAllOccurencesOfString = function(keyword) {
	    RemoveAllHighlights();
	    HighlightAllOccurencesOfStringForElement(document.body, keyword.toLowerCase());
		
	    if (SearchResultCount > 0) {
	    	// sort elements by their top offset from smaller to higher
	    	FoundElements.sort(function(a,b){
				var offsetA = getOffset(a);
				var offsetB = getOffset(b);
				return offsetA.top - offsetB.top;
			});
	    }
	};
	
	// helper function, recursively searches in elements and their child nodes
	var HighlightAllOccurencesOfStringForElement = function(element,keyword) {
	    if (element) {
	        if (element.nodeType == 3) {        // Text node
	            while (true) {
	                var value = element.nodeValue;  // Search for keyword in text node
	                var idx = value.toLowerCase().indexOf(keyword);
	                
	                if (idx < 0) break;             // not found, abort
	                
	                var span = document.createElement("span");
	                var text = document.createTextNode(value.substr(idx,keyword.length));
	                span.appendChild(text);
	                span.setAttribute("class",HighlightClassName);
	                span.style.backgroundColor="yellow";
	                span.style.color="black";
	                text = document.createTextNode(value.substr(idx+keyword.length));
	                element.deleteData(idx, value.length - idx);
	                var next = element.nextSibling;
	                element.parentNode.insertBefore(span, next);
	                element.parentNode.insertBefore(text, next);
	                element = text;
	                SearchResultCount++;	// update the counter
	                FoundElements.push(span);
	            }
	        } else if (element.nodeType == 1) { // Element node
	            if (element.style.display != "none" && element.nodeName.toLowerCase() != 'select') {
	                for (var i=element.childNodes.length-1; i>=0; i--) {
	                    HighlightAllOccurencesOfStringForElement(element.childNodes[i],keyword);
	                }
	            }
	        }
	    }
	};
	

	
	// the main entry point to remove the highlights
	var RemoveAllHighlights = function() {
	    SearchResultCount = 0;
	    FoundElements = new Array();
	    RemoveAllHighlightsForElement(document.body);
	};
	
	// helper function, recursively removes the highlights in elements and their childs
	var RemoveAllHighlightsForElement = function(element) {
	    if (element) {
	        if (element.nodeType == 1) {
	            if (element.getAttribute("class") == HighlightClassName) {
	                var text = element.removeChild(element.firstChild);
	                element.parentNode.insertBefore(text,element);
	                element.parentNode.removeChild(element);
	                return true;
	            } else {
	                var normalize = false;
	                for (var i=element.childNodes.length-1; i>=0; i--) {
	                    if (RemoveAllHighlightsForElement(element.childNodes[i])) {
	                        normalize = true;
	                    }
	                }
	                if (normalize) {
	                    element.normalize();
	                }
	            }
	        }
	    }
	    return false;
	};
	
	// scrolls to element taken by index from FoundElements array
	var ScrollToFoundElement = function(index) {
	   FoundElementsCurrentPosition = index;
	   var e = FoundElements[index];
	   var offset = getOffset(e);
	   var x = offset.left;
	   var y = offset.top;
	   window.scrollTo(x,y);
	};
	
	// helper function which gets the actual x and y in order to scroll
	var getOffset = function(el) {
	    var _x = 0;
	    var _y = 0;
	    while( el && !isNaN( el.offsetLeft ) && !isNaN( el.offsetTop ) ) {
	        _x += el.offsetLeft - el.scrollLeft;
	        _y += el.offsetTop - el.scrollTop;
	        el = el.offsetParent;
	    }
	    return { top: _y, left: _x };
	};

    return {
    	// public functions declaration
        search: search,
        searchFromElement: searchFromElement,
        highlightNextResult: highlightNextResult,
        highlightPreviousResult: highlightPreviousResult
    };
})();











