xquery version '1.0-ml';

module namespace search-ctlr = 'http://alm.com/controller/search-Bhupendra';

import module namespace search = 'http://alm.com/search-Bhupendra' at '/common/model/search-Bhupendra.xqy';

declare namespace util = 'http://alm.com/util';

declare option xdmp:mapping 'false';

declare function search-ctlr:SP_InsertSavedSearches_New($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request	
	return $request
};

declare function search-ctlr:sp_GetREOrganizerFirms($params as element(util:params))
{
	search:sp_GetREOrganizerFirms(
		search-ctlr:required($params/util:term, 'term')
	)
};

declare function search-ctlr:sp_GetREFirms($params as element(util:params))
{
	search:sp_GetREFirms(
		search-ctlr:required($params/util:term, 'term')
	)
};

declare function search-ctlr:SP_GETSEARCHDATA($params as element(util:params))
{
	search:SP_GETSEARCHDATA(
		search-ctlr:required($params/util:term, 'term')
	)
};

declare function search-ctlr:sp_GetAttorneyNames($params as element(util:params))
{
	search:sp_GetAttorneyNames(
		search-ctlr:required($params/util:term, 'term')
	)
};

declare function search-ctlr:GetQuickSearchResultsOnTerms($params as element(util:params))
{
	search:GetQuickSearchResultsOnTerms(
		 search-ctlr:required($params/util:term, 'term')
		,search-ctlr:required($params/util:type, 'type')
		,search-ctlr:required($params/util:pagename, 'pagename')
	)
};

declare function search-ctlr:GetAMLaw200SearchResults($params as element(util:params))
{
	search:GetAMLaw200SearchResults()
};

declare function search-ctlr:GetQuickSearchResults($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	
	let $term := $request/term/text()
	let $type := $request/type/text()
	return search:GetQuickSearchResults($term,$type)
};

declare function search-ctlr:required($value as item()*, $parameter as xs:string) as item()*
{
    if (fn:exists($value)) then
        $value
    else
        fn:error(xs:QName("MISSINGPARAM"), fn:concat("Required param '", $parameter, "' is missing"))
};