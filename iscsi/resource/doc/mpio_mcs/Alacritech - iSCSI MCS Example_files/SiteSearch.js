var formCreated = false;

// Assumes there is an actual text input element with the id "searchBox".
function runSearch(searchText)
{
    var searchBox = document.getElementById("searchBox");
    var searchInput = document.getElementById("searchInput");
    var searchForm = document.getElementById("searchbox_005620973236873065961:4tpcvqmujhs");
    var searchValue = searchText ? searchText : searchBox.value;
    searchInput.value = searchValue;
    searchForm.submit();
} 

// Create the search form necessary to tie into google search.
function createSearchForm()
{
    if (!formCreated)
    {
        document.write('<div> \
                            <form id="searchbox_005620973236873065961:4tpcvqmujhs" action="http://www.alacritech.com/SearchResults.aspx"> \
                            <input id="searchInput" name="q" type="hidden" /> \
                            <input type="hidden" name="cx" value="005620973236873065961:4tpcvqmujhs" /> \
                            <input type="hidden" name="cof" value="FORID:11" /> \
                            </form> \
                        </div>');
    }
        
    formCreated = true;
}

// Key handler
function kH(e)
{
    var pK = e ? e.which : window.event.keyCode;
    
    if (e && e.target && e.target.id == "searchBox" && pK == 13)
    {
        runSearch();
        return false;
    }
}
document.onkeypress = kH;
if (document.layers) document.captureEvents(Event.KEYPRESS);


// Submit search.
function searchSubmit(control)
{
    if (formCreated && window.event.keyCode == 13 && window.event.srcElement == control)
    {
        runSearch();
        return false;
    }
}