xquery version '1.0-ml';

module namespace event-ctlr = 'http://alm.com/controller/event';

import module namespace event = 'http://alm.com/event' at '/common/model/event.xqy';

declare namespace util = 'http://alm.com/util';

declare option xdmp:mapping 'false';

declare function event-ctlr:GetEventsPracticeTrends($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	
	let $pageNo := if ($request/EventPageNo/text() !='') then $request/EventPageNo/text() else 1
	let $recordsPerPage := if ($request/EventPageSize/text() != '') then $request/EventPageSize/text() else 10
	let $companyID := $request/FirmIds/text()
	let $practiceAreas := $request/PracticeArea/text()
	let $fromDate := if ($request/FromDate/text() != '') then $request/FromDate/text() else ()
	let $toDate := if ($request/ToDate/text() != '') then $request/ToDate/text() else ()
	let $Keywords := $request/Keyword/text()
	
	let $FirmLocation := $request/FirmLocation
	let $Cities := $FirmLocation/Cities/text()
	let $States := $FirmLocation/States/text()
	let $Countries := $FirmLocation/Countries/text()
	let $GeoGraphicRegions := $FirmLocation/GeoRegions/text()
	let $UsRegions := $FirmLocation/UsRegions/text()
	
	let $SortBy := $request/SortBy/text()
	let $SortDirection := $request/SortDirection/text()
	let $EventType := $request/EventType/text()
	
	return event:GetEventsPracticeTrends(
		 $pageNo
		,$recordsPerPage
		,$companyID
		,$practiceAreas
		,$fromDate
		,$toDate
		,$Keywords
		,$Cities
		,$States
		,$Countries
		,$GeoGraphicRegions
		,$UsRegions
		,$SortBy
		,$SortDirection
		,$EventType
	)
};

declare function event-ctlr:GetEventsFirmTrends($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	
	let $pageNo := if ($request/EventPageNo/text() !='') then $request/EventPageNo/text() else 1
	let $recordsPerPage := if ($request/EventPageSize/text() != '') then $request/EventPageSize/text() else 10
	let $companyID := $request/FirmIds/text()
	let $practiceAreas := $request/PracticeArea/text()
	let $fromDate := if ($request/FromDate/text() != '') then $request/FromDate/text() else ()
	let $toDate := if ($request/ToDate/text() != '') then $request/ToDate/text() else ()
	let $Keywords := $request/Keyword/text()
	
	let $FirmLocation := $request/FirmLocation
	let $Cities := $FirmLocation/Cities/text()
	let $States := $FirmLocation/States/text()
	let $Countries := $FirmLocation/Countries/text()
	let $GeoGraphicRegions := $FirmLocation/GeoRegions/text()
	let $UsRegions := $FirmLocation/UsRegions/text()
	
	let $SortBy := $request/SortBy/text()
	let $SortDirection := $request/SortDirection/text()
	let $EventType := $request/EventType/text()
	
	return event:GetEventsFirmTrends(
		 $pageNo
		,$recordsPerPage
		,$companyID
		,$practiceAreas
		,$fromDate
		,$toDate
		,$Keywords
		,$Cities
		,$States
		,$Countries
		,$GeoGraphicRegions
		,$UsRegions
		,$SortBy
		,$SortDirection
		,$EventType
	)
};

declare function event-ctlr:GetEventSearchData($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	
	let $pageNo := if ($request/EventPageNo/text() !='') then $request/EventPageNo/text() else 1
	let $recordsPerPage := if ($request/EventPageSize/text() != '') then $request/EventPageSize/text() else 10
	let $companyID := $request/FirmIds/text()
	let $practiceAreas := $request/PracticeArea/text()
	let $fromDate := if ($request/FromDate/text() != '') then $request/FromDate/text() else ()
	let $toDate := if ($request/ToDate/text() != '') then $request/ToDate/text() else ()
	let $Keywords := $request/Keyword/text()
	
	let $FirmLocation := $request/FirmLocation
	let $Cities := $FirmLocation/Cities/text()
	let $States := $FirmLocation/States/text()
	let $Countries := $FirmLocation/Countries/text()
	let $GeoGraphicRegions := $FirmLocation/GeoRegions/text()
	let $UsRegions := $FirmLocation/UsRegions/text()
	
	let $SortBy := $request/SortBy/text()
	let $SortDirection := $request/SortDirection/text()
	let $EventType := $request/EventType/text()

	return event:GetEventSearchData(
		$pageNo
		,$recordsPerPage
		,$companyID
		,$practiceAreas
		,$fromDate
		,$toDate
		,$Keywords
		,$Cities
		,$States
		,$Countries
		,$GeoGraphicRegions
		,$UsRegions
		,$SortBy
		,$SortDirection
		,$EventType
	)
};

declare function event-ctlr:GetEventSearchDataGLL($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	
	let $pageNo := if ($request/EventPageNo/text() !='') then $request/EventPageNo/text() else 1
	let $recordsPerPage := if ($request/EventPageSize/text() != '') then $request/EventPageSize/text() else 10
	let $companyID := $request/FirmIds/text()
	let $practiceAreas := $request/PracticeArea/text()
	let $fromDate := if ($request/FromDate/text() != '') then $request/FromDate/text() else ()
	let $toDate := if ($request/ToDate/text() != '') then $request/ToDate/text() else ()
	let $Keywords := $request/Keyword/text()
	
	let $FirmLocation := $request/FirmLocation
	let $Cities := $FirmLocation/Cities/text()
	let $States := $FirmLocation/States/text()
	let $Countries := $FirmLocation/Countries/text()
	let $GeoGraphicRegions := $FirmLocation/GeoRegions/text()
	let $UsRegions := $FirmLocation/UsRegions/text()
	
	let $SortBy := $request/SortBy/text()
	let $SortDirection := $request/SortDirection/text()

	return event:GetEventSearchDataGLL(
		$pageNo
		,$recordsPerPage
		,$companyID
		,$practiceAreas
		,$fromDate
		,$toDate
		,$Keywords
		,$Cities
		,$States
		,$Countries
		,$GeoGraphicRegions
		,$UsRegions
		,$SortBy
		,$SortDirection
	)
	
};

declare function event-ctlr:GetRecentEvents($params as element(util:params))
{
	event:GetRecentEvents()
};

declare function event-ctlr:required($value as item()*, $parameter as xs:string) as item()*
{
    if (fn:exists($value)) then
        $value
    else
        fn:error(xs:QName('MISSINGPARAM'), fn:concat('Required param '', $parameter, '' is missing'))
};