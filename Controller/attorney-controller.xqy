xquery version "1.0-ml";

module namespace attorney-ctlr = "http://alm.com/controller/attorney";

import module namespace attorney = "http://alm.com/attorney" at "/common/model/attorney.xqy";

import module namespace search = "http://marklogic.com/appservices/search"
     at "/MarkLogic/appservices/search/search.xqy";

declare namespace util = "http://alm.com/util";

declare option xdmp:mapping "false";

declare function attorney-ctlr:GetLocationsRE($params as element(util:params))
{
	attorney:GetLocationsRE()
};

declare function attorney-ctlr:GetPracticeAreasFromRE($params as element(util:params))
{
	attorney:GetPracticeAreasFromRE()
};

declare function attorney-ctlr:sp_GetWatchListFirms($params as element(util:params))
{
	attorney:sp_GetWatchListFirms($params/util:watchlistID,$params/util:userEmail)
};

declare function attorney-ctlr:GetFirmDefaultWatchList($params as element(util:params))
{
	attorney:GetFirmDefaultWatchList($params/util:userEmail)
};

declare function attorney-ctlr:GetTimelineEventsFromALI($params as element(util:params))
{
	if($params/util:name ne '') then attorney:GetTimelineEventsFromALI($params/util:name) else()
};

declare function attorney-ctlr:GetTimelineEventsFromRE($params as element(util:params))
{
	attorney:GetTimelineEventsFromRE($params/util:attorneyID)
};

declare function attorney-ctlr:GetTimelineEvents2FromRE($params as element(util:params))
{
	attorney:GetTimelineEvents2FromRE($params/util:attorneyID)
};

declare function attorney-ctlr:GetRecentClients($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	let $name := $request/AttorneyName/text()
	let $email := $request/AttorneyEmail/text()
	let $phone := $request/AttorneyPhone/text()
	return attorney:GetRecentClients($name,$email,$phone)
};

declare function attorney-ctlr:GetPractiseConcentration($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	let $name := $request/AttorneyName/text()
	let $email := $request/AttorneyEmail/text()
	let $phone := $request/AttorneyPhone/text()
	return attorney:GetPractiseConcentration($name,$email,$phone)
};

declare function attorney-ctlr:GetLawfirmProfileOverview($params as element(util:params))
{
	attorney:GetLawfirmProfileOverview($params/util:orgID)
};

declare function attorney-ctlr:GetLawfirmProfileOverview1($params as element(util:params))
{
	attorney:GetLawfirmProfileOverview1($params/util:orgID)
};

declare function attorney-ctlr:IsNonAMLawFirm($params as element(util:params))
{
	attorney:IsNonAMLawFirm($params/util:orgID)
};

declare function attorney-ctlr:GetREIDByOrgID($params as element(util:params))
{
	attorney:GetREIDByOrgID($params/util:orgID)
};

declare function attorney-ctlr:sp_GetAttorneyDetail($params as element(util:params))
{
	attorney:sp_GetAttorneyDetail($params/util:attorneyID,$params/util:firmId) 
};



declare function attorney-ctlr:sp_GetAttorneys1($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	return attorney:sp_GetAttorneys1($request/cities/text(),$request/countries/text(),$request/geographicregions/text(),$request/usregions/text(),$request/Titles/text(),$request/Firms/text(),$request/PracticeAreas/text(),$request/FromYear/text(),$request/ToYear/text(),$request/SearchKeyword/text(),$request/AttorneyName/text(),$request/lawSchoolNames/text(),$request/PageNo/text(),$request/PageSize/text(),$request/SortBy/text(),$request/SortDirection/text(),$request/admissions/text())
	
};

declare function attorney-ctlr:sp_GetREFirmContactsAddedNew2($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	let $fromDate :=fn:tokenize($request/fromDate/text(),'T')
	let $toDate := fn:tokenize($request/toDate/text(),'T')
	let $gender := $request/genderType/text()
	let $isPrimaryPracticeArea := $request/isPrimaryPracticeArea/text()
	let $keyword := $request/Keyword/text()
	return attorney:sp_GetREFirmContactsAddedNew2($request/firmIds/text(),$request/changetype/text(),xs:string($fromDate[1]),xs:string($toDate[1]),$request/title/text(),
						$request/practiceAreas/text(),$request/attorneyname/text(),$request/lawschools/text(),$request/cities/text(),$request/states/text(),$request/countries/text(),
						$request/geographicregions/text(),$request/usregions/text(),$request/SortBy/text(),$request/SortDirection/text(),$request/PageNo/text(),$request/PageSize/text(),
						$gender,$isPrimaryPracticeArea,$keyword)
	
};

declare function attorney-ctlr:sp_GetLawyerMoves($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	let $fromDate :=fn:tokenize($request/FromDate/text(),'T')
	let $toDate := fn:tokenize($request/ToDate/text(),'T')
	return attorney:sp_GetLawyerMoves($request/FirmIds/text(),xs:string($fromDate[1]),xs:string($toDate[1]),$request/Titles/text(),$request/practiceAreas/text())
	
};

declare function attorney-ctlr:GetAttorneysAdvanceSearchMLQueryCount($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request

	let $query := fn:replace($request/MLQuery/text(),"&amp;","&amp;amp;")
	let $cities := $request/cities/text()
	let $states := $request/states/text()
	let $countries := $request/countries/text()
	let $geographicregions := $request/geographicregions/text()
	let $usregions := $request/usregions/text()
	let $keywords := $request/SearchKeyword/text()
	let $firms := $request/Firms/text()
	let $sortDirection := $request/SortDirection/text()
	let $sortBy := $request/SortBy/text()
	let $practiceAreas := $request/practiceAreas/text()
	let $filterValue := ""
	let $attorneyName := $request/AttorneyName/text()

	return attorney:GetAttorneysAdvanceSearchMLQueryCount(
		$query
		,$cities
		,$states
		,$countries
		,$geographicregions
		,$usregions
		,$keywords
		,$firms
		,$sortBy
		,$sortDirection
		,$filterValue
		,$practiceAreas
		,$attorneyName
		)
};

declare function attorney-ctlr:GetAttorneysAdvanceSearchSqlQuery($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	
	let $pageNo := $request/PageNo/text()
	let $pageSize := $request/PageSize/text()
	let $query := fn:replace($request/MLQuery/text(),"&amp;","&amp;amp;")
	let $cities := $request/cities/text()
	let $states := $request/states/text()
	let $countries := $request/countries/text()
	let $geographicregions := $request/geographicregions/text()
	let $usregions := $request/usregions/text()
	let $keywords := $request/SearchKeyword/text()
	let $firms := $request/Firms/text()
	let $sortDirection := $request/SortDirection/text()
	let $sortBy := $request/SortBy/text()
	let $practiceAreas := $request/practiceAreas/text()
	let $attorneyName := $request/AttorneyName/text()
return json:to-array(attorney:GetAttorneysAdvanceSearchSqlQuery(
	$pageNo
	,$pageSize
	,$query
	,$cities
	,$states
	
	,$countries
	,$geographicregions
	,$usregions
	,$keywords
	,$firms
	,$sortBy
	,$sortDirection
	,$practiceAreas
	,$attorneyName
	)
	)
};

declare function attorney-ctlr:GetAttorneysAdvanceSearchMLQueryFirmList($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	
	let $pageNo := $request/PageNo/text()
	let $pageSize := $request/PageSize/text()
	let $query := fn:replace($request/MLQuery/text(),"&amp;","&amp;amp;")
	let $cities := $request/cities/text()
	let $states := $request/states/text()
	let $countries := $request/countries/text()
	let $geographicregions := $request/geographicregions/text()
	let $usregions := $request/usregions/text()
	let $keywords := $request/SearchKeyword/text()
	let $firms := $request/Firms/text()
	let $sortDirection := $request/SortDirection/text()
	let $sortBy := $request/SortBy/text()
	let $practiceAreas := $request/practiceAreas/text()
	

return json:to-array(attorney:GetAttorneysAdvanceSearchMLQueryFirmList(
	$pageNo
	,$pageSize
	,$query
	,$cities
	,$states
	,$countries
	,$geographicregions
	,$usregions
	,$keywords
	,$firms
	,$sortBy
	,$sortDirection
	,$practiceAreas
	
	)
	)
};

declare function attorney-ctlr:GetLawyerMovesFirmID($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	let $fromDate :=fn:tokenize($request/fromDate/text(),'T')
	let $toDate := fn:tokenize($request/toDate/text(),'T')
	let $gender := $request/genderType/text()
	let $isPrimaryPracticeArea := $request/isPrimaryPracticeArea/text()
	let $keyword := $request/Keyword/text()
	return attorney:GetLawyerMovesFirmID($request/firmIds/text(),$request/changetype/text(),xs:string($fromDate[1]),xs:string($toDate[1]),$request/title/text(),
						$request/practiceAreas/text(),$request/attorneyname/text(),$request/lawschools/text(),$request/cities/text(),$request/states/text(),$request/countries/text(),
						$request/geographicregions/text(),$request/usregions/text(),$request/SortBy/text(),$request/SortDirection/text(),$request/PageNo/text(),$request/PageSize/text(),
						$gender,$isPrimaryPracticeArea,$keyword)
	
};