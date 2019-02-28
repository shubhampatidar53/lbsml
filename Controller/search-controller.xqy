xquery version '1.0-ml';

module namespace search-ctlr = 'http://alm.com/controller/search';

import module namespace search = 'http://alm.com/search' at '/common/model/search.xqy';

declare namespace util = 'http://alm.com/util';

declare option xdmp:mapping 'false';

declare function search-ctlr:SP_SAVEFAVSEARCH($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	
	let $SearchID := $request/SearchID/text()
	
	return search:SP_SAVEFAVSEARCH($SearchID)
};

declare function search-ctlr:SP_InsertSavedSearches_New($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	
	let $UserID := $request/UserID/text()
	let $PromotionID := $request/PromotionID/text()
	let $SearchType := $request/SearchType/text()
	let $SearchCriteria := $request/SearchCriteria/text()
	let $SearchTerm := $request/SearchTerm/text()
	let $SearchedFrom := $request/SearchedFrom/text()
	let $IpAddress := $request/IpAddress/text()
	let $SearchID := $request/SearchID/text()

	return search:SP_InsertSavedSearches_New(
		 $UserID
		,$PromotionID
		,$SearchType
		,$SearchCriteria
		,$SearchTerm
		,$SearchedFrom
		,$IpAddress
		,$SearchID
	)
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

declare function search-ctlr:CACHE_ALI_RE_Attorney_Data($params as element(util:params))
{
	search:CACHE_ALI_RE_Attorney_Data()
};

declare function search-ctlr:CACHE_SP_GETSEARCHDATA($params as element(util:params))
{
	search:CACHE_SP_GETSEARCHDATA()
};

declare function search-ctlr:CACHE_sp_getrefirms($params as element(util:params))
{
	search:CACHE_sp_getrefirms()
};

declare function search-ctlr:GetQuickSearchResults($params as element(util:params))
{
	(:let $term := search-ctlr:required($params/util:term, 'term')
	let $type := search-ctlr:required($params/util:type, 'type'):)
	(:let $page := search-ctlr:required($params/util:page, 'page') :)
	
	let $request := xdmp:get-request-body()/request
	
	let $term := $request/Term/text()
	let $type := $request/Type/text()	
	let $page := $request/PageName/text()
	
	return search:GetQuickSearchResults($term,$type,$page)
	(: return search:GetQuickSearchResults($term,$type) :)
};

declare function search-ctlr:GetQuickSearchResults_All($params as element(util:params))
{
	let $term := search-ctlr:required($params/util:term, 'term')
	let $type := search-ctlr:required($params/util:type, 'type')
	return search:GetQuickSearchResults_All($term,$type)
};

declare function search-ctlr:GetQuickSearchResults_All1($params as element(util:params))
{
	(:let $term := search-ctlr:required($params/util:term, 'term')
	let $type := search-ctlr:required($params/util:type, 'type')
	let $pageSize := search-ctlr:required($params/util:pageSize, 'pageSize')
	let $pageNo := search-ctlr:required($params/util:pageNo, 'pageNo')
	return search:GetQuickSearchResults_All1($term,$type,$pageSize,$pageNo):)
	
	let $request := xdmp:get-request-body()/request
	
	let $term := $request/SearchKeyword/text()
	let $type := $request/SearchType/text()
	let $pageSize := $request/PageSize/text()
	let $pageNo := $request/PageNo/text()
	
	return search:GetQuickSearchResults_All1($term,$type,$pageSize,$pageNo)
};

declare function search-ctlr:GetAMLaw200SearchResults($params as element(util:params))
{
	search:GetAMLaw200SearchResults()
};

declare function search-ctlr:required($value as item()*, $parameter as xs:string) as item()*
{
    if (fn:exists($value)) then
        $value
    else
        fn:error(xs:QName('MISSINGPARAM'), fn:concat('Required param '', $parameter, '' is missing'))
};