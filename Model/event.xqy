xquery version '1.0-ml';

module namespace event = 'http://alm.com/event';

import module namespace config = 'http://alm.com/config' at '/common/config.xqy';
import module namespace helper = 'http://alm.com/helper' at '/common/model/helper.xqy';
import module namespace json = 'http://marklogic.com/xdmp/json'  at '/MarkLogic/json/json.xqy';

declare namespace ALI_RE_Event_Data = 'http://alm.com/LegalCompass/dd/ALI_RE_Event_Data';
declare namespace practices_kws = 'http://alm.com/LegalCompass/rd/practices_kws';
declare namespace company = 'http://alm.com/LegalCompass/rd/company';

declare option xdmp:mapping 'false';

declare function event:GetEventsPracticeTrends(
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
{
	let $fromDate := fn:tokenize($fromDate,'T')[1]
	let $toDate := fn:tokenize($toDate,'T')[1]
	
		let $city_q := if($Cities !='') then for $item in $Cities
							return cts:element-value-query(xs:QName('ALI_RE_Event_Data:city'), fn:tokenize($item,'-')[1], ('case-insensitive'))
		else ()
		
	let $state_q := if($States !='') then
			cts:element-value-query(xs:QName('ALI_RE_Event_Data:state'), $States, ('case-insensitive'))
		else ()
		
	let $country_q := if($Countries !='') then
			cts:element-value-query(xs:QName('ALI_RE_Event_Data:country'), $Countries, ('case-insensitive'))
		else ()
		
	let $geographic_region_q := if($GeoGraphicRegions !='') then
			cts:element-value-query(xs:QName('ALI_RE_Event_Data:geographic_region'), $GeoGraphicRegions, ('wildcarded','case-insensitive'))
		else ()
		
	let $us_region_q := if($UsRegions !='') then
			cts:element-value-query(xs:QName('ALI_RE_Event_Data:us_region'), $UsRegions, ('case-insensitive'))
		else ()

	let $eventTypes := fn:tokenize($EventType,'[|]')

	let $eventType := if(count($eventTypes) eq 1) then
			if($eventTypes[1] eq 'Webinar') then cts:element-value-query(xs:QName('ALI_RE_Event_Data:EventType'), 'Webinar', ('case-insensitive'))
			else cts:not-query(cts:element-value-query(xs:QName('ALI_RE_Event_Data:EventType'), 'Webinar', ('case-insensitive')))
		else ()	

	let $location_q := if($Cities != '' or $States != '' or $Countries != '' or $GeoGraphicRegions != '' or $UsRegions != '')
		then cts:or-query(($city_q,$state_q,$country_q,$geographic_region_q,$us_region_q))
		else ()			
	
	let $keyword_q := (:if($Keywords !='') then
			let $term := fn:concat('*',$Keywords,'*')
			return cts:or-query((
				 cts:element-value-query(xs:QName('ALI_RE_Event_Data:EventTitle'),$term,('wildcarded','case-insensitive'))
				,cts:element-value-query(xs:QName('ALI_RE_Event_Data:EventDescription'),$term,('wildcarded','case-insensitive'))
				,cts:element-value-query(xs:QName('ALI_RE_Event_Data:practice_area'),$term,('wildcarded','case-insensitive'))
			))
		else ():)
		
		if($Keywords !='') then
			
							if(fn:contains(fn:lower-case($Keywords),'and') and fn:not(fn:contains(fn:lower-case($Keywords),'"'))) then 
								 event:GetAndOperatorQuery($Keywords)
													
							
							else if(fn:contains(fn:lower-case($Keywords),'or') and fn:not(fn:contains(fn:lower-case($Keywords),'"'))) then 
								 event:GetOrOperatorQuery($Keywords)
													
							else if(fn:contains(fn:lower-case($Keywords),'"') and fn:contains(fn:lower-case($Keywords),'" or "')) then 
								 event:GetExactOrOperatorQuery($Keywords)

							else if(fn:contains(fn:lower-case($Keywords),'"') and fn:contains(fn:lower-case($Keywords),' or ')) then 
								 event:GetExactOrOperatorQuery($Keywords)	 
										
							else if(fn:contains(fn:lower-case($Keywords),'"') and fn:contains(fn:lower-case($Keywords),'" and "')) then 
								 event:GetExactAndOperatorQuery($Keywords)

							else if(fn:contains(fn:lower-case($Keywords),'"') and fn:contains(fn:lower-case($Keywords),' and ')) then 
								 event:GetExactAndOperatorQuery($Keywords)	 			
										
							else if(fn:contains(fn:lower-case($Keywords),' or ') and fn:contains(fn:lower-case($Keywords),' and ')) then 
								 event:GetAndOrOperatorQuery($Keywords)
							
							(:else if(fn:contains(fn:lower-case($Keywords),'"') and fn:not(fn:contains(fn:lower-case($Keywords),'" and "')) and fn:not(fn:contains(fn:lower-case($Keywords),'" or "'))) then 
								 event:GetExactAndOperatorQuery($Keywords)	:)
							
							else if(fn:contains($Keywords,',') and fn:not(fn:contains(fn:lower-case($Keywords),'"'))) then 
								   cts:or-query((
									cts:element-word-query(xs:QName('ALI_RE_Event_Data:EventTitle'),fn:tokenize($Keywords,','),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('ALI_RE_Event_Data:EventDescription'),fn:tokenize($Keywords,','),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('ALI_RE_Event_Data:practice_area'),fn:tokenize($Keywords,','),('wildcarded','case-insensitive'))
								))

								else if(fn:contains($Keywords,' ') and fn:not(fn:contains(fn:lower-case($Keywords),'"'))) then 
								   cts:or-query((
									cts:element-word-query(xs:QName('ALI_RE_Event_Data:EventTitle'),fn:tokenize($Keywords,' '),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('ALI_RE_Event_Data:EventDescription'),fn:tokenize($Keywords,' '),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('ALI_RE_Event_Data:practice_area'),fn:tokenize($Keywords,' '),('wildcarded','case-insensitive'))
								))
								else cts:or-query((
										cts:element-word-query(xs:QName('ALI_RE_Event_Data:EventTitle'),fn:replace($Keywords,'"',''),('wildcarded','case-insensitive')),
										cts:element-word-query(xs:QName('ALI_RE_Event_Data:EventDescription'),fn:replace($Keywords,'"',''),('wildcarded','case-insensitive')),
										cts:element-word-query(xs:QName('ALI_RE_Event_Data:practice_area'),fn:replace($Keywords,'"',''),('wildcarded','case-insensitive'))
										))
							
					else ()
	
	let $company_id_q := if ($companyID !='') then
			let $companyIDs := fn:tokenize($companyID,',')
			return cts:or-query((
				 cts:element-value-query(xs:QName('ALI_RE_Event_Data:re_id'),$companyIDs,('case-insensitive'))
				,cts:element-value-query(xs:QName('ALI_RE_Event_Data:FirmID'),$companyIDs,('case-insensitive'))
			))
		else ()
	
	let $date_q := if (($fromDate != '') and ($toDate != '')) then (
			 cts:element-range-query(xs:QName('ALI_RE_Event_Data:EventDate'), '>=', xs:date($fromDate))
			,cts:element-range-query(xs:QName('ALI_RE_Event_Data:EventDate'), '<=', xs:date($toDate))
			,cts:not-query(cts:element-value-query(xs:QName('ALI_RE_Event_Data:EventDate'), ('*-00-00*','0/0/*','00/00/*'), ('wildcarded')))
		)
		else ()
		
	let $conditions := (
		 cts:directory-query($config:DD-ALI_RE_EVENT_DATA-PATH,'infinity')
		,$location_q
		,$keyword_q
		,$company_id_q
		,if ($practiceAreas) then cts:element-word-query(xs:QName('ALI_RE_Event_Data:practice_area'),fn:tokenize($practiceAreas,'[|]'),('wildcarded', 'case-insensitive')) else ()
		,$date_q
		,$eventType
	)
	
	let $practice_areas :=if ($practiceAreas != '') then fn:tokenize($practiceAreas,'[|]') else cts:values(cts:element-reference(xs:QName('practices_kws:practice_area')))
	
	let $Main := for $practice_area in $practice_areas
		let $query := cts:and-query((
			cts:element-value-query(xs:QName('ALI_RE_Event_Data:practice_area'),$practice_area,('wildcarded','case-insensitive'))
			,$conditions
		))
	
		let $search := cts:search(/ALI_RE_Event_Data, $query)
		let $obj := for $res in $search
			let $EventDate := $res/ALI_RE_Event_Data:EventDate/text()
			let $MonthName := fn:format-date(xs:date($EventDate),'[MNn] - [Y0001]')
			return element {'obj'} {
				element {'EventDate'} {$res/ALI_RE_Event_Data:EventDate/text()}
				,element {'PracticeArea'} {$practice_area}
				,element {'MonthName'} {$MonthName}
			}
		return $obj
		
	let $FinalMain := for $practice_area in $practice_areas
		let $search := $Main[PracticeArea eq $practice_area]
		let $EventMonths := fn:distinct-values($search/MonthName/text())
		let $obj := for $MonthName in $EventMonths
			let $node := $search[MonthName eq $MonthName]
			let $Total := fn:count($node)
			return element {'obj'} {
				 element {'EventDate'} {$node[1]/EventDate/text()}
				,element {'PracticeArea'} {$practice_area}
				,element {'MonthName'} {$MonthName}
				,element {'Total'} {$Total}
			}
		return $obj
	
	let $FinalPractice := (
  
		for $practice_area in fn:distinct-values($FinalMain/PracticeArea/text())
    
			let $query := cts:and-query((
				 cts:element-word-query(xs:QName('ALI_RE_Event_Data:practice_area'),$practice_area,('wildcarded','case-insensitive'))
				,$conditions
			))
    
			let $TotalCount := xdmp:estimate(cts:search(fn:doc(),$query))
			
			let $obj := element {'obj'} {
				 element {'PracticeArea'} {$practice_area}
				,element {'TotalCount'} {$TotalCount}
			}
			
			order by $practice_area ascending
			(:order by $TotalCount descending,$practice_area ascending:)
    
		return $obj
    
	)[1 to 5]
	
	let $response := for $item in $FinalMain
		let $practiceAreas := $item/PracticeArea/text()
		let $node := $FinalPractice[PracticeArea eq $practiceAreas]
		let $EventDate := $item/EventDate
		order by $EventDate ascending
		return if ($node) then $item else ()
  
	let $response := element {'RESULT'} {$response}
	
	let $custom :=
		let $config := json:config('custom')
		let $_ := map:put( $config, 'whitespace', 'ignore' )
		let $_ := map:put( $config, 'array-element-names', ('obj') )
		return $config
	
	let $response := xdmp:to-json-string(json:transform-to-json($response, $custom)//obj)
	let $res := if($response eq 'null') then () else $response
	
	return if(fn:contains($res,'[')) then $res else fn:concat('[',$res,']')
};

(:declare function event:GetEventSearchData(
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
{
	let $direction := if (fn:upper-case($SortDirection) = 'DESC') then 'descending' else 'ascending'
	
	let $start := ((($pageNo - 1) * $recordsPerPage) + 1)
	let $end := (($start + $recordsPerPage) - 1 )
	
	let $fromDate := fn:tokenize($fromDate,'T')[1]
	let $toDate := fn:tokenize($toDate,'T')[1]
	
	let $city_q := if($Cities !='') then
			cts:element-value-query(xs:QName('ALI_RE_Event_Data:city'), $Cities, ('case-insensitive'))
		else ()
		
	let $state_q := if($States !='') then
			cts:element-value-query(xs:QName('ALI_RE_Event_Data:state'), $States, ('case-insensitive'))
		else ()
		
	let $country_q := if($Countries !='') then
			cts:element-value-query(xs:QName('ALI_RE_Event_Data:country'), $Countries, ('case-insensitive'))
		else ()
		
	let $geographic_region_q := if($GeoGraphicRegions !='') then
			cts:element-value-query(xs:QName('ALI_RE_Event_Data:geographic_region'), $GeoGraphicRegions, ('case-insensitive'))
		else ()
		
	let $us_region_q := if($UsRegions !='') then
			cts:element-value-query(xs:QName('ALI_RE_Event_Data:us_region'), $UsRegions, ('case-insensitive'))
		else ()
	
	let $keyword_q := if($Keywords !='') then
			let $term := fn:concat('*',$Keywords,'*')
			
			return cts:or-query((
				 cts:element-word-query(xs:QName('ALI_RE_Event_Data:EventTitle'),$term,('wildcarded','case-insensitive'))
				,cts:element-word-query(xs:QName('ALI_RE_Event_Data:EventDescription'),$term,('wildcarded','case-insensitive'))
				,cts:element-word-query(xs:QName('ALI_RE_Event_Data:practice_area'),$term,('wildcarded','case-insensitive'))
			))
		else ()
	
	let $company_id_q := if ($companyID !='') then
			let $companyIDs := fn:tokenize($companyID,',')
			return cts:or-query((
				 cts:element-value-query(xs:QName('ALI_RE_Event_Data:FirmID'),$companyIDs,('case-insensitive'))
				,cts:and-query((
					 cts:element-value-query(xs:QName('ALI_RE_Event_Data:re_id'),$companyIDs,('case-insensitive'))
					,cts:element-value-query(xs:QName('ALI_RE_Event_Data:FirmID'),'')
				))
			))
		else ()
	
	let $date_q := if (($fromDate != '') and ($toDate != '')) then (
			 cts:element-range-query(xs:QName('ALI_RE_Event_Data:EventDate'), '>=', xs:date($fromDate))
			,cts:element-range-query(xs:QName('ALI_RE_Event_Data:EventDate'), '<=', xs:date($toDate))
			,cts:not-query(cts:element-value-query(xs:QName('ALI_RE_Event_Data:EventDate'), ('*-00-00*','0/0/*','00/00/*'), ('wildcarded')))
		)
		else ()
		
	let $conditions := (
		 cts:directory-query($config:DD-ALI_RE_EVENT_DATA-PATH,'infinity')
		,$city_q
		,$state_q
		,$country_q
		,$geographic_region_q
		,$us_region_q
		,$keyword_q
		,$company_id_q
		,if ($practiceAreas) then cts:element-value-query(xs:QName('ALI_RE_Event_Data:practice_area'),fn:tokenize($practiceAreas,'[|]'),('wildcarded', 'case-insensitive')) else ()
		,$date_q
	)
	
	let $sort-query := if (fn:upper-case($SortBy)= fn:upper-case('EventDate')) then (
			cts:index-order(cts:element-reference(xs:QName('ALI_RE_Event_Data:EventDate')) ,$direction)
		) else if (fn:upper-case($SortBy)= fn:upper-case('FirmName')) then (
			cts:index-order(cts:element-reference(xs:QName('ALI_RE_Event_Data:FirmName')) ,$direction)
		) else if (fn:upper-case($SortBy)= fn:upper-case('EventUrl')) then (
			cts:index-order(cts:element-reference(xs:QName('ALI_RE_Event_Data:EventUrl')) ,$direction)
		) else if (fn:upper-case($SortBy)= fn:upper-case('EventTitle')) then (
			cts:index-order(cts:element-reference(xs:QName('ALI_RE_Event_Data:EventTitle')) ,$direction)
		) else if (fn:upper-case($SortBy)= fn:upper-case('EventDescription')) then (
			cts:index-order(cts:element-reference(xs:QName('ALI_RE_Event_Data:EventDescription')) ,$direction)
		) else if (fn:upper-case($SortBy)= fn:upper-case('PracticeArea')) then (
			cts:index-order(cts:element-reference(xs:QName('ALI_RE_Event_Data:PracticeArea')) ,$direction)
		) else if (fn:upper-case($SortBy)= fn:upper-case('Location')) then (
			cts:index-order(cts:element-reference(xs:QName('ALI_RE_Event_Data:Location')) ,$direction)
		) else if (fn:upper-case($SortBy)= fn:upper-case('Speakers')) then (
			cts:index-order(cts:element-reference(xs:QName('ALI_RE_Event_Data:Speakers')) ,$direction)
		) else if (fn:upper-case($SortBy)= fn:upper-case('HomeUrl')) then (
			cts:index-order(cts:element-reference(xs:QName('ALI_RE_Event_Data:HomeUrl')) ,$direction)
		) else ()
		
	let $TotalCount := if($Keywords !='')
		then count(cts:search(/ALI_RE_Event_Data, cts:and-query(($conditions))))
		else xdmp:estimate(cts:search(/ALI_RE_Event_Data, cts:and-query(($conditions))))
	let $search := cts:search(/ALI_RE_Event_Data, cts:and-query(($conditions)), $sort-query)[xs:integer($start) to xs:integer($end)]
	
	let $response := for $item in $search
		return element {'RECORD'} {
			 element {'totalcount'} {$TotalCount}
			,element {'EventID'} {$item/ALI_RE_Event_Data:EventID/text()}
			,element {'EventUrl'} {$item/ALI_RE_Event_Data:EventUrl/text()}
			,element {'EventTitle'} {$item/ALI_RE_Event_Data:EventTitle/text()}
			,element {'EventDescription'} {$item/ALI_RE_Event_Data:EventDescription/text()}
			,element {'EventDate'} {$item/ALI_RE_Event_Data:EventDate/text()}
			,element {'Speakers'} {$item/ALI_RE_Event_Data:Speakers/text()}
			,element {'Location'} {$item/ALI_RE_Event_Data:Location/text()}
			,element {'std_loc'} {$item/ALI_RE_Event_Data:std_loc/text()}
			,element {'PracticeArea'} {$item/ALI_RE_Event_Data:PracticeArea/text()}
			,element {'FirmID'} {$item/ALI_RE_Event_Data:FirmID/text()}
			,element {'FirmName'} {$item/ALI_RE_Event_Data:FirmName/text()}
			,element {'HomeUrl'} {$item/ALI_RE_Event_Data:HomeUrl/text()}
		}
	
	let $count := fn:count($response)
	
	let $response := element {'RESULT'} {$response}
	
	let $custom :=
		let $config := json:config('custom')
		let $_ := map:put( $config, 'whitespace', 'ignore' )
		let $_ := map:put( $config, 'array-element-names', ('RECORD') )
		return $config
	
	let $response := if ($count > 1) then 
			xdmp:to-json-string(json:transform-to-json($response, $custom)//RECORD) 
		else json:to-array(json:transform-to-json($response, $custom)//RECORD)
		
	return $response
};
:)





declare function event:GetEventSearchDataGLL(
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
{
	let $direction := if (fn:upper-case($SortDirection) = 'DESC') then 'descending' else 'ascending'
	
	let $start := ((($pageNo - 1) * $recordsPerPage) + 1)
	let $end := (($start + $recordsPerPage) - 1 )
	
	let $fromDate := fn:tokenize($fromDate,'T')[1]
	let $toDate := fn:tokenize($toDate,'T')[1]
	
	let $city_q := if($Cities !='') then
			cts:element-value-query(xs:QName('ALI_RE_Event_Data:city'), $Cities, ('case-insensitive'))
		else ()
		
	let $state_q := if($States !='') then
			cts:element-value-query(xs:QName('ALI_RE_Event_Data:state'), $States, ('case-insensitive'))
		else ()
		
	let $country_q := if($Countries !='') then
			cts:element-value-query(xs:QName('ALI_RE_Event_Data:country'), $Countries, ('case-insensitive'))
		else ()
		
	let $geographic_region_q := if($GeoGraphicRegions !='') then
			cts:element-value-query(xs:QName('ALI_RE_Event_Data:geographic_region'), $GeoGraphicRegions, ('case-insensitive'))
		else ()
		
	let $us_region_q := if($UsRegions !='') then
			cts:element-value-query(xs:QName('ALI_RE_Event_Data:us_region'), $UsRegions, ('case-insensitive'))
		else ()
	
	let $location_q := if($Cities != '' or $States != '' or $Countries != '' or $GeoGraphicRegions != '' or $UsRegions != '')
		then cts:or-query(($city_q,$state_q,$country_q,$geographic_region_q,$us_region_q))
		else ()
	let $keyword_q := if($Keywords !='') then
			let $term := fn:concat('*',$Keywords,'*')
			(:return cts:or-query((
				 cts:element-value-query(xs:QName('ALI_RE_Event_Data:EventTitle'),$term,('wildcarded','case-insensitive'))
				,cts:element-value-query(xs:QName('ALI_RE_Event_Data:EventDescription'),$term,('wildcarded','case-insensitive'))
				,cts:element-value-query(xs:QName('ALI_RE_Event_Data:practice_area'),$term,('wildcarded','case-insensitive'))
			)):)
			return cts:or-query((
				 cts:element-word-query(xs:QName('ALI_RE_Event_Data:EventTitle'),$term,('wildcarded','case-insensitive'))
				,cts:element-word-query(xs:QName('ALI_RE_Event_Data:EventDescription'),$term,('wildcarded','case-insensitive'))
				,cts:element-word-query(xs:QName('ALI_RE_Event_Data:practice_area'),$term,('wildcarded','case-insensitive'))
			))
		else ()
	
	(:let $company_id_q := if ($companyID !='') then
			let $companyIDs := fn:tokenize($companyID,',')
			return cts:or-query((
				 cts:element-value-query(xs:QName('ALI_RE_Event_Data:FirmID'),$companyIDs,('case-insensitive'))
				,cts:and-query((
					 cts:element-value-query(xs:QName('ALI_RE_Event_Data:re_id'),$companyIDs,('case-insensitive'))
					,cts:element-value-query(xs:QName('ALI_RE_Event_Data:FirmID'),'')
				))
			))
		else ():)
	let $company_id_q := if ($companyID !='') then
			let $companyIDs := fn:tokenize($companyID,',')
			return cts:or-query((
					cts:element-value-query(xs:QName('ALI_RE_Event_Data:FirmID'),$companyIDs,('case-insensitive'))				
					(:,cts:element-value-query(xs:QName('ALI_RE_Event_Data:re_id'),$companyIDs,('case-insensitive')):)
					))
			else ()	
	
	let $date_q := if (($fromDate != '') and ($toDate != '')) then (
			 cts:element-range-query(xs:QName('ALI_RE_Event_Data:EventDate'), '>=', xs:date($fromDate))
			,cts:element-range-query(xs:QName('ALI_RE_Event_Data:EventDate'), '<=', xs:date($toDate))
			,cts:not-query(cts:element-value-query(xs:QName('ALI_RE_Event_Data:EventDate'), ('*-00-00*','0/0/*','00/00/*'), ('wildcarded')))
		)
		else ()
		
	(:let $conditions := (
		 cts:directory-query($config:DD-ALI_RE_EVENT_DATA-PATH)
			
			,$city_q
			,$state_q
			,$country_q
			,$geographic_region_q
			,$us_region_q
			
		,$keyword_q
		,$company_id_q
		,if ($practiceAreas) then cts:element-value-query(xs:QName('ALI_RE_Event_Data:practice_area'),fn:tokenize($practiceAreas,'[|]'),('wildcarded', 'case-insensitive')) else ()
		,$date_q
	)
	:)
	let $conditions := (
		 (:cts:directory-query($config:DD-ALI_RE_EVENT_DATA-PATH,'infinity'):)
		 cts:directory-query($config:DD-ALI_RE_EVENT_DATA-PATH)
		,$location_q 
		,$keyword_q
		,$company_id_q
		,if ($practiceAreas) then cts:element-value-query(xs:QName('ALI_RE_Event_Data:practice_area'),fn:tokenize($practiceAreas,'[|]'),('wildcarded', 'case-insensitive')) else ()
		,$date_q
	)
	let $sort-query := if (fn:upper-case($SortBy)= fn:upper-case('EventDate')) then (
			cts:index-order(cts:element-reference(xs:QName('ALI_RE_Event_Data:EventDate')) ,$direction)
		) else if (fn:upper-case($SortBy)= fn:upper-case('FirmName')) then (
			cts:index-order(cts:element-reference(xs:QName('ALI_RE_Event_Data:FirmName')) ,$direction)
		) else if (fn:upper-case($SortBy)= fn:upper-case('EventUrl')) then (
			cts:index-order(cts:element-reference(xs:QName('ALI_RE_Event_Data:EventUrl')) ,$direction)
		) else if (fn:upper-case($SortBy)= fn:upper-case('EventTitle')) then (
			cts:index-order(cts:element-reference(xs:QName('ALI_RE_Event_Data:EventTitle')) ,$direction)
		) else if (fn:upper-case($SortBy)= fn:upper-case('EventDescription')) then (
			cts:index-order(cts:element-reference(xs:QName('ALI_RE_Event_Data:EventDescription')) ,$direction)
		) else if (fn:upper-case($SortBy)= fn:upper-case('PracticeArea')) then (
			cts:index-order(cts:element-reference(xs:QName('ALI_RE_Event_Data:PracticeArea')) ,$direction)
		) else if (fn:upper-case($SortBy)= fn:upper-case('Location')) then (
			cts:index-order(cts:element-reference(xs:QName('ALI_RE_Event_Data:Location')) ,$direction)
		) else if (fn:upper-case($SortBy)= fn:upper-case('Speakers')) then (
			cts:index-order(cts:element-reference(xs:QName('ALI_RE_Event_Data:Speakers')) ,$direction)
		) else if (fn:upper-case($SortBy)= fn:upper-case('HomeUrl')) then (
			cts:index-order(cts:element-reference(xs:QName('ALI_RE_Event_Data:HomeUrl')) ,$direction)
		) else ()
		
	let $TotalCount := if($Keywords !='')
		then count(cts:search(/ALI_RE_Event_Data, cts:and-query(($conditions))))
		else xdmp:estimate(cts:search(/ALI_RE_Event_Data, cts:and-query(($conditions))))
	let $search := cts:search(/ALI_RE_Event_Data, cts:and-query(($conditions)), $sort-query)[xs:integer($start) to xs:integer($end)]
	
	let $response := for $item in $search
		return element {'RECORD'} {
			 element {'totalcount'} {$TotalCount}
			,element {'EventID'} {$item/ALI_RE_Event_Data:EventID/text()}
			,element {'EventUrl'} {$item/ALI_RE_Event_Data:EventUrl/text()}
			,element {'EventTitle'} {$item/ALI_RE_Event_Data:EventTitle/text()}
			,element {'EventDescription'} {$item/ALI_RE_Event_Data:EventDescription/text()}
			,element {'EventDate'} {$item/ALI_RE_Event_Data:EventDate/text()}
			,element {'Speakers'} {$item/ALI_RE_Event_Data:Speakers/text()}
			,element {'Location'} {$item/ALI_RE_Event_Data:Location/text()}
			,element {'std_loc'} {$item/ALI_RE_Event_Data:std_loc/text()}
			,element {'PracticeArea'} {$item/ALI_RE_Event_Data:PracticeArea/text()}
			,element {'FirmID'} {$item/ALI_RE_Event_Data:FirmID/text()}
			,element {'FirmName'} {$item/ALI_RE_Event_Data:FirmName/text()}
			,element {'HomeUrl'} {$item/ALI_RE_Event_Data:HomeUrl/text()}
		}
	
	let $count := fn:count($response)
	
	let $response := element {'RESULT'} {$response}
	
	let $custom :=
		let $config := json:config('custom')
		let $_ := map:put( $config, 'whitespace', 'ignore' )
		let $_ := map:put( $config, 'array-element-names', ('RECORD') )
		return $config
	
	let $response := if ($count > 1) then 
			xdmp:to-json-string(json:transform-to-json($response, $custom)//RECORD) 
		else json:to-array(json:transform-to-json($response, $custom)//RECORD)
		
	return $response
};


declare function event:GetEventsFirmTrends(
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
{
	let $fromDate := fn:tokenize($fromDate,'T')[1]
	let $toDate := fn:tokenize($toDate,'T')[1]
	
		let $city_q := if($Cities !='') then for $item in $Cities
							return cts:element-value-query(xs:QName('ALI_RE_Event_Data:city'), fn:tokenize($item,'-')[1], ('case-insensitive'))
		else ()
		
	let $state_q := if($States !='') then
			cts:element-value-query(xs:QName('ALI_RE_Event_Data:state'), $States, ('case-insensitive'))
		else ()
		
	let $country_q := if($Countries !='') then
			cts:element-value-query(xs:QName('ALI_RE_Event_Data:country'), $Countries, ('case-insensitive'))
		else ()
		
	let $geographic_region_q := if($GeoGraphicRegions !='') then
			cts:element-value-query(xs:QName('ALI_RE_Event_Data:geographic_region'), $GeoGraphicRegions, ('case-insensitive'))
		else ()
		
	let $us_region_q := if($UsRegions !='') then
			cts:element-value-query(xs:QName('ALI_RE_Event_Data:us_region'), $UsRegions, ('case-insensitive'))
		else ()

	let $eventTypes := fn:tokenize($EventType,'[|]')

	let $eventType := if(count($eventTypes) eq 1) then
			if($eventTypes[1] eq 'Webinar') then cts:element-value-query(xs:QName('ALI_RE_Event_Data:EventType'), 'Webinar', ('case-insensitive'))
			else cts:not-query(cts:element-value-query(xs:QName('ALI_RE_Event_Data:EventType'), 'Webinar', ('case-insensitive')))
		else ()	
		
	let $location_q := if($Cities != '' or $States != '' or $Countries != '' or $GeoGraphicRegions != '' or $UsRegions != '')
		then cts:or-query(($city_q,$state_q,$country_q,$geographic_region_q,$us_region_q))
		else ()			
	
	let $keyword_q := if($Keywords !='') then
			
							if(fn:contains(fn:lower-case($Keywords),'and') and fn:not(fn:contains(fn:lower-case($Keywords),'"'))) then 
								 event:GetAndOperatorQuery($Keywords)
													
							
							else if(fn:contains(fn:lower-case($Keywords),'or') and fn:not(fn:contains(fn:lower-case($Keywords),'"'))) then 
								 event:GetOrOperatorQuery($Keywords)
													
							else if(fn:contains(fn:lower-case($Keywords),'"') and fn:contains(fn:lower-case($Keywords),'" or "')) then 
								 event:GetExactOrOperatorQuery($Keywords)

							else if(fn:contains(fn:lower-case($Keywords),'"') and fn:contains(fn:lower-case($Keywords),' or ')) then 
								 event:GetExactOrOperatorQuery($Keywords)	 
										
							else if(fn:contains(fn:lower-case($Keywords),'"') and fn:contains(fn:lower-case($Keywords),'" and "')) then 
								 event:GetExactAndOperatorQuery($Keywords)

							else if(fn:contains(fn:lower-case($Keywords),'"') and fn:contains(fn:lower-case($Keywords),' and ')) then 
								 event:GetExactAndOperatorQuery($Keywords)	 			
										
							else if(fn:contains(fn:lower-case($Keywords),' or ') and fn:contains(fn:lower-case($Keywords),' and ')) then 
								 event:GetAndOrOperatorQuery($Keywords)
							
							(:else if(fn:contains(fn:lower-case($Keywords),'"') and fn:not(fn:contains(fn:lower-case($Keywords),'" and "')) and fn:not(fn:contains(fn:lower-case($Keywords),'" or "'))) then 
								 event:GetExactAndOperatorQuery($Keywords)	:)
							
							else if(fn:contains($Keywords,',') and fn:not(fn:contains(fn:lower-case($Keywords),'"'))) then 
								   cts:or-query((
									cts:element-word-query(xs:QName('ALI_RE_Event_Data:EventTitle'),fn:tokenize($Keywords,','),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('ALI_RE_Event_Data:EventDescription'),fn:tokenize($Keywords,','),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('ALI_RE_Event_Data:practice_area'),fn:tokenize($Keywords,','),('wildcarded','case-insensitive'))
								))

								else if(fn:contains($Keywords,' ') and fn:not(fn:contains(fn:lower-case($Keywords),'"'))) then 
								   cts:or-query((
									cts:element-word-query(xs:QName('ALI_RE_Event_Data:EventTitle'),fn:tokenize($Keywords,' '),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('ALI_RE_Event_Data:EventDescription'),fn:tokenize($Keywords,' '),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('ALI_RE_Event_Data:practice_area'),fn:tokenize($Keywords,' '),('wildcarded','case-insensitive'))
								))
								else cts:or-query((
										cts:element-word-query(xs:QName('ALI_RE_Event_Data:EventTitle'),fn:replace($Keywords,'"',''),('wildcarded','case-insensitive')),
										cts:element-word-query(xs:QName('ALI_RE_Event_Data:EventDescription'),fn:replace($Keywords,'"',''),('wildcarded','case-insensitive')),
										cts:element-word-query(xs:QName('ALI_RE_Event_Data:practice_area'),fn:replace($Keywords,'"',''),('wildcarded','case-insensitive'))
										))
							
					else ()
	
	let $company_id_q := if ($companyID !='') then
			let $companyIDs := fn:tokenize($companyID,',')
			return cts:or-query((
				 cts:element-value-query(xs:QName('ALI_RE_Event_Data:re_id'),$companyIDs,('case-insensitive'))
				,cts:element-value-query(xs:QName('ALI_RE_Event_Data:FirmID'),$companyIDs,('case-insensitive'))
			))
		else ()
	
	let $date_q := if (($fromDate != '') and ($toDate != '')) then (
			 cts:element-range-query(xs:QName('ALI_RE_Event_Data:EventDate'), '>=', xs:date($fromDate))
			,cts:element-range-query(xs:QName('ALI_RE_Event_Data:EventDate'), '<=', xs:date($toDate))
			,cts:not-query(cts:element-value-query(xs:QName('ALI_RE_Event_Data:EventDate'), ('*-00-00*','0/0/*','00/00/*'), ('wildcarded')))
		)
		else ()
		
	let $conditions := (
		 cts:directory-query($config:DD-ALI_RE_EVENT_DATA-PATH,'infinity')
		,$location_q
		,$keyword_q
		,$company_id_q
		,if ($practiceAreas) then cts:element-value-query(xs:QName('ALI_RE_Event_Data:practice_area'),fn:tokenize($practiceAreas,'[|]'),('wildcarded', 'case-insensitive')) else ()
		,$date_q
		,$eventType
	)
	
	(: let $FirmIDs := cts:element-values(xs:QName('ALI_RE_Event_Data:FirmID'),(),(), cts:and-query(($conditions))) :)
	(: let $FirmIDs := cts:values(cts:element-reference(xs:QName('ALI_RE_Event_Data:FirmID')), (), (), cts:and-query(($conditions))) :)
	let $FirmIDs := fn:distinct-values(cts:search(/ALI_RE_Event_Data, cts:and-query(($conditions)))/ALI_RE_Event_Data:FirmID/text())
	
	let $response := (
		for $FirmID in cts:values(cts:element-reference(xs:QName('ALI_RE_Event_Data:FirmID')), (), (), cts:and-query(($conditions)))
		(:for $FirmID in $FirmIDs:)
			
			let $Total := cts:frequency($FirmID)
			(:let $FirmName := cts:search(/ALI_RE_Event_Data, cts:and-query((
					$conditions
					,cts:element-value-query(xs:QName('ALI_RE_Event_Data:FirmID'),xs:string($FirmID))
				)))[1]/ALI_RE_Event_Data:FirmName/text():)
			
			let $FirmName := cts:search(/ALI_RE_Event_Data, cts:and-query((
				cts:directory-query($config:DD-ALI_RE_EVENT_DATA-PATH,'infinity')
				,cts:element-value-query(xs:QName('ALI_RE_Event_Data:FirmID'),xs:string($FirmID))
			)))[1]/ALI_RE_Event_Data:FirmName/text()			
			
			let $obj := element {'RECORD'} {
				 element {'FirmID'} {$FirmID}
				,element {'Total'} {$Total}
				,element {'FirmName'} {$FirmName}
			}
			order by $Total descending
			return $obj
	)[1 to 5]
	
	let $count := fn:count($response)
	
	let $response := element {'RESULT'} {$response}
	
	let $custom :=
		let $config := json:config('custom')
		let $_ := map:put( $config, 'whitespace', 'ignore' )
		let $_ := map:put( $config, 'array-element-names', ('RECORD') )
		return $config
	
	let $response := if ($count > 1) then 
			xdmp:to-json-string(json:transform-to-json($response, $custom)//RECORD) 
		else json:to-array(json:transform-to-json($response, $custom)//RECORD)
		
	return $response
};

declare function event:GetRecentEvents()
{
	let $response-arr := json:array()
	(:let $company_ids := cts:element-values(xs:QName("company:company_id")):)
		
	let $events := cts:search(/,
		cts:and-query((
		cts:directory-query('/LegalCompass/denormalized-data/ALI_RE_Event_Data/')
		,cts:element-value-query(xs:QName("ALI_RE_Event_Data:re_id"),('6174'))
	,cts:element-range-query(xs:QName("ALI_RE_Event_Data:EventDate"),">=",(fn:current-date()))
		,cts:not-query(cts:element-value-query(xs:QName("ALI_RE_Event_Data:Location"),("Location not identified")))
		)),
		cts:index-order(cts:element-reference(xs:QName('ALI_RE_Event_Data:EventDate')) ,"descending"))[1 to 3]
		
	let $data := for $event in fn:reverse($events)
		let $response-obj := json:object()
		let $_ := (
		map:put($response-obj,"EventID", $event//ALI_RE_Event_Data:EventID/text())
		,map:put($response-obj,"FirmID", $event//ALI_RE_Event_Data:FirmID/text())
		,map:put($response-obj,"EventDate", $event//ALI_RE_Event_Data:EventDate/text())
		,map:put($response-obj,"EventUrl", $event//ALI_RE_Event_Data:EventUrl/text())
		,map:put($response-obj,"EventTitle", $event//ALI_RE_Event_Data:EventTitle/text())
		,map:put($response-obj,"EventDescription", $event//ALI_RE_Event_Data:EventDescription/text())
		,map:put($response-obj,"PracticeArea", $event//ALI_RE_Event_Data:PracticeArea/text())
		,map:put($response-obj,"Location", $event//ALI_RE_Event_Data:Location/text())
		,map:put($response-obj,"HomeUrl", $event//ALI_RE_Event_Data:HomeUrl/text())
		)
		
	let $_ := json:array-push($response-arr,$response-obj)
		return ($response-obj)	
	
	return ($response-arr)

};

declare function event:GetEventSearchData(
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
{
	let $direction := if (fn:upper-case($SortDirection) = 'DESC') then 'descending' else 'ascending'
	
	let $start := ((($pageNo - 1) * $recordsPerPage) + 1)
	let $end := (($start + $recordsPerPage) - 1 )
	
	let $fromDate := fn:tokenize($fromDate,'T')[1]
	let $toDate := fn:tokenize($toDate,'T')[1]
	
	let $city_q := if($Cities !='') then for $item in $Cities
							return cts:element-value-query(xs:QName('ALI_RE_Event_Data:city'), fn:tokenize($item,'-')[1], ('case-insensitive'))
		else ()
		
	let $state_q := if($States !='') then
			cts:element-value-query(xs:QName('ALI_RE_Event_Data:state'), $States, ('case-insensitive'))
		else ()
		
	let $country_q := if($Countries !='') then
			cts:element-value-query(xs:QName('ALI_RE_Event_Data:country'), $Countries, ('case-insensitive'))
		else ()
		
	let $geographic_region_q := if($GeoGraphicRegions !='') then
			cts:element-value-query(xs:QName('ALI_RE_Event_Data:geographic_region'), $GeoGraphicRegions, ('case-insensitive'))
		else ()
		
	let $us_region_q := if($UsRegions !='') then
			cts:element-value-query(xs:QName('ALI_RE_Event_Data:us_region'), $UsRegions, ('case-insensitive'))
		else ()

	let $eventTypes := fn:tokenize($EventType,'[|]')

	let $eventType := if(count($eventTypes) eq 1) then
			if($eventTypes[1] eq 'Webinar') then cts:element-value-query(xs:QName('ALI_RE_Event_Data:EventType'), 'Webinar', ('case-insensitive'))
			else cts:not-query(cts:element-value-query(xs:QName('ALI_RE_Event_Data:EventType'), 'Webinar', ('case-insensitive')))
		else ()	

	let $location_q := if($Cities != '' or $States != '' or $Countries != '' or $GeoGraphicRegions != '' or $UsRegions != '')
		then cts:or-query(($city_q,$state_q,$country_q,$geographic_region_q,$us_region_q))
		else ()	
	
	let $keyword_q := if($Keywords !='') then
			
							if(fn:contains(fn:lower-case($Keywords),' and ') and fn:not(fn:contains(fn:lower-case($Keywords),'"'))) then 
								 event:GetAndOperatorQuery($Keywords)
													
							
							else if(fn:contains(fn:lower-case($Keywords),' or ') and fn:not(fn:contains(fn:lower-case($Keywords),'"'))) then 
								 event:GetOrOperatorQuery($Keywords)
													
							else if(fn:contains(fn:lower-case($Keywords),'"') and fn:contains(fn:lower-case($Keywords),'" or "')) then 
								 event:GetExactOrOperatorQuery($Keywords)

							else if(fn:contains(fn:lower-case($Keywords),'"') and fn:contains(fn:lower-case($Keywords),' or ')) then 
								 event:GetExactOrOperatorQuery($Keywords)	 
										
							else if(fn:contains(fn:lower-case($Keywords),'"') and fn:contains(fn:lower-case($Keywords),'" and "')) then 
								 event:GetExactAndOperatorQuery($Keywords)

							else if(fn:contains(fn:lower-case($Keywords),'"') and fn:contains(fn:lower-case($Keywords),' and ')) then 
								 event:GetExactAndOperatorQuery($Keywords)	 			
										
							else if(fn:contains(fn:lower-case($Keywords),' or ') and fn:contains(fn:lower-case($Keywords),' and ')) then 
								 event:GetAndOrOperatorQuery($Keywords)
							
							(:else if(fn:contains(fn:lower-case($Keywords),'"') and fn:not(fn:contains(fn:lower-case($Keywords),'" and "')) and fn:not(fn:contains(fn:lower-case($Keywords),'" or "'))) then 
								 event:GetExactAndOperatorQuery($Keywords)	:)
							
							else if(fn:contains($Keywords,',') and fn:not(fn:contains(fn:lower-case($Keywords),'"'))) then 
								   cts:or-query((
									cts:element-word-query(xs:QName('ALI_RE_Event_Data:EventTitle'),fn:tokenize($Keywords,','),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('ALI_RE_Event_Data:EventDescription'),fn:tokenize($Keywords,','),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('ALI_RE_Event_Data:practice_area'),fn:tokenize($Keywords,','),('wildcarded','case-insensitive'))
								))

								else if(fn:contains($Keywords,' ') and fn:not(fn:contains(fn:lower-case($Keywords),'"'))) then 
								   cts:or-query((
									cts:element-word-query(xs:QName('ALI_RE_Event_Data:EventTitle'),fn:tokenize($Keywords,' '),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('ALI_RE_Event_Data:EventDescription'),fn:tokenize($Keywords,' '),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('ALI_RE_Event_Data:practice_area'),fn:tokenize($Keywords,' '),('wildcarded','case-insensitive'))
								))
								else cts:or-query((
										cts:element-word-query(xs:QName('ALI_RE_Event_Data:EventTitle'),fn:concat('*' , fn:replace($Keywords,'"',''),'*'),('wildcarded','case-insensitive')),
										cts:element-word-query(xs:QName('ALI_RE_Event_Data:EventDescription'),fn:concat('*' , fn:replace($Keywords,'"',''),'*'),('wildcarded','case-insensitive')),
										cts:element-word-query(xs:QName('ALI_RE_Event_Data:practice_area'),fn:concat('*' , fn:replace($Keywords,'"',''),'*'),('wildcarded','case-insensitive'))
										))
							
					else ()
	
	let $company_id_q := if ($companyID !='') then
			let $companyIDs := fn:tokenize($companyID,',')
			return cts:or-query((
				 cts:element-value-query(xs:QName('ALI_RE_Event_Data:FirmID'),$companyIDs,('case-insensitive'))
				,cts:and-query((
					 cts:element-value-query(xs:QName('ALI_RE_Event_Data:re_id'),$companyIDs,('case-insensitive'))
					,cts:element-value-query(xs:QName('ALI_RE_Event_Data:FirmID'),'')
				))
			))
		else ()
	
	let $date_q := if (($fromDate != '') and ($toDate != '')) then (
			 cts:element-range-query(xs:QName('ALI_RE_Event_Data:EventDate'), '>=', xs:date($fromDate))
			,cts:element-range-query(xs:QName('ALI_RE_Event_Data:EventDate'), '<=', xs:date($toDate))
			,cts:not-query(cts:element-value-query(xs:QName('ALI_RE_Event_Data:EventDate'), ('*-00-00*','0/0/*','00/00/*'), ('wildcarded')))
		)
		else ()
		
	let $conditions := (
		 cts:directory-query($config:DD-ALI_RE_EVENT_DATA-PATH,'infinity')
		,$location_q
		,$keyword_q
		,$company_id_q
		,if ($practiceAreas) then cts:element-value-query(xs:QName('ALI_RE_Event_Data:practice_area'),fn:tokenize($practiceAreas,'[|]'),('wildcarded', 'case-insensitive')) else ()
		,$date_q
		,$eventType
	)
	
	let $sort-query := if (fn:upper-case($SortBy)= fn:upper-case('EventDate')) then (
			cts:index-order(cts:element-reference(xs:QName('ALI_RE_Event_Data:EventDate')) ,$direction)
		) else if (fn:upper-case($SortBy)= fn:upper-case('FirmName')) then (
			cts:index-order(cts:element-reference(xs:QName('ALI_RE_Event_Data:FirmName')) ,$direction)
		) else if (fn:upper-case($SortBy)= fn:upper-case('EventUrl')) then (
			cts:index-order(cts:element-reference(xs:QName('ALI_RE_Event_Data:EventUrl')) ,$direction)
		) else if (fn:upper-case($SortBy)= fn:upper-case('EventTitle')) then (
			cts:index-order(cts:element-reference(xs:QName('ALI_RE_Event_Data:EventTitle')) ,$direction)
		) else if (fn:upper-case($SortBy)= fn:upper-case('EventDescription')) then (
			cts:index-order(cts:element-reference(xs:QName('ALI_RE_Event_Data:EventDescription')) ,$direction)
		) else if (fn:upper-case($SortBy)= fn:upper-case('PracticeArea')) then (
			cts:index-order(cts:element-reference(xs:QName('ALI_RE_Event_Data:PracticeArea')) ,$direction)
		) else if (fn:upper-case($SortBy)= fn:upper-case('Location')) then (
			cts:index-order(cts:element-reference(xs:QName('ALI_RE_Event_Data:Location')) ,$direction)
		) else if (fn:upper-case($SortBy)= fn:upper-case('Speakers')) then (
			cts:index-order(cts:element-reference(xs:QName('ALI_RE_Event_Data:Speakers')) ,$direction)
		) else if (fn:upper-case($SortBy)= fn:upper-case('HomeUrl')) then (
			cts:index-order(cts:element-reference(xs:QName('ALI_RE_Event_Data:HomeUrl')) ,$direction)
		) else ()
		
	let $TotalCount := if($Keywords !='' or fn:contains($Keywords,'-') or fn:contains($Keywords,"'") or fn:contains($Keywords,"&amp;"))
		then count(cts:search(/ALI_RE_Event_Data, cts:and-query(($conditions))))
		else xdmp:estimate(cts:search(/ALI_RE_Event_Data, cts:and-query(($conditions))))
	let $search := cts:search(/ALI_RE_Event_Data, cts:and-query(($conditions)), $sort-query)[xs:integer($start) to xs:integer($end)]
	
	let $response := for $item in $search
		return element {'RECORD'} {
			 element {'totalcount'} {$TotalCount}
			,element {'EventID'} {$item/ALI_RE_Event_Data:EventID/text()}
			,element {'EventUrl'} {$item/ALI_RE_Event_Data:EventUrl/text()}
			,element {'EventTitle'} {$item/ALI_RE_Event_Data:EventTitle/text()}
			,element {'EventDescription'} {$item/ALI_RE_Event_Data:EventDescription/text()}
			,element {'EventDate'} {$item/ALI_RE_Event_Data:EventDate/text()}
			,element {'Speakers'} {$item/ALI_RE_Event_Data:Speakers/text()}
			,element {'Location'} {$item/ALI_RE_Event_Data:Location/text()}
			,element {'std_loc'} {$item/ALI_RE_Event_Data:std_loc/text()}
			,element {'PracticeArea'} {$item/ALI_RE_Event_Data:PracticeArea/text()}
			,element {'FirmID'} {$item/ALI_RE_Event_Data:FirmID/text()}
			,element {'FirmName'} {$item/ALI_RE_Event_Data:FirmName/text()}
			,element {'HomeUrl'} {$item/ALI_RE_Event_Data:HomeUrl/text()}
			,element {'EventType'} {$item/ALI_RE_Event_Data:EventType/text()}
		}
	
	let $count := fn:count($response)
	
	let $response := element {'RESULT'} {$response}
	
	let $custom :=
		let $config := json:config('custom')
		let $_ := map:put( $config, 'whitespace', 'ignore' )
		let $_ := map:put( $config, 'array-element-names', ('RECORD') )
		return $config
	
	let $response := if ($count > 1) then 
			xdmp:to-json-string(json:transform-to-json($response, $custom)//RECORD) 
		else json:to-array(json:transform-to-json($response, $custom)//RECORD)
		
	return $response
};

(:----------------------------------- Keyword helper function -----------------------------------:)

declare function event:GetAndOperatorQuery($Keywords)
{
	let $query := cts:or-query((
										cts:and-query((
										for $item in fn:tokenize(fn:lower-case($Keywords),' and ')
										
											return 
											
											 cts:element-word-query(xs:QName('ALI_RE_Event_Data:EventTitle'),$item,('wildcarded','case-insensitive'))
											 
											
										)),
										
										cts:and-query((for $item in fn:tokenize(fn:lower-case($Keywords),' and ')
										
											return 
											
											 cts:element-word-query(xs:QName('ALI_RE_Event_Data:EventDescription'),$item,('wildcarded','case-insensitive'))
											
											
										)),
										
										cts:and-query((for $item in fn:tokenize(fn:lower-case($Keywords),' and ')
										
											return 
											
											 cts:element-word-query(xs:QName('ALI_RE_Event_Data:practice_area'),$item,('wildcarded','case-insensitive'))
										))
										
										))
	return $query									
};

declare function event:GetOrOperatorQuery($Keywords)
{
	let $query := cts:or-query((
										cts:or-query((
										for $item in fn:tokenize(fn:lower-case($Keywords),' or ')
										
											return 
											
											 cts:element-word-query(xs:QName('ALI_RE_Event_Data:EventTitle'),$item,('wildcarded','case-insensitive'))
											 
											
										)),
										
										cts:or-query((for $item in fn:tokenize(fn:lower-case($Keywords),' or ')
										
											return 
											
											 cts:element-word-query(xs:QName('ALI_RE_Event_Data:EventDescription'),$item,('wildcarded','case-insensitive'))
											
											
										)),
										
										cts:or-query((for $item in fn:tokenize(fn:lower-case($Keywords),' or ')
										
											return 
											
											 cts:element-word-query(xs:QName('ALI_RE_Event_Data:practice_area'),$item,('wildcarded','case-insensitive'))
										))
										
										))
										
	return $query																
};

declare function event:GetExactOrOperatorQuery($Keywords)
{
	let $query := cts:or-query((
										cts:or-query((
										for $item in fn:tokenize(fn:lower-case($Keywords),' or ')
										
											return 
											
											 cts:element-word-query(xs:QName('ALI_RE_Event_Data:EventTitle'),fn:concat('*',fn:replace($item,'"',''),'*'),('wildcarded','case-insensitive'))
											 
											
										)),
										
										cts:or-query((for $item in fn:tokenize(fn:lower-case($Keywords),' or ')
										
											return 
											
											 cts:element-word-query(xs:QName('ALI_RE_Event_Data:EventDescription'),fn:concat('*',fn:replace($item,'"',''),'*'),('wildcarded','case-insensitive'))
											
											
										)),
										
										cts:or-query((for $item in fn:tokenize(fn:lower-case($Keywords),' or ')
										
											return 
											
											 cts:element-word-query(xs:QName('ALI_RE_Event_Data:practice_area'),fn:concat('*',fn:replace($item,'"',''),'*'),('wildcarded','case-insensitive'))
										))
										
										))
	return $query									
};

declare function event:GetExactAndOperatorQuery($Keywords)
{
	let $query := cts:or-query((
										cts:and-query((
										for $item in fn:tokenize(fn:lower-case($Keywords),' and ')
										
											return 
											
											 cts:element-word-query(xs:QName('ALI_RE_Event_Data:EventTitle'),fn:replace($item,'"',''),('wildcarded','case-insensitive'))
											 
											
										)),
										
										cts:and-query((for $item in fn:tokenize(fn:lower-case($Keywords),' and ')
										
											return 
											
											 cts:element-word-query(xs:QName('ALI_RE_Event_Data:EventDescription'),fn:replace($item,'"',''),('wildcarded','case-insensitive'))
											
											
										)),
										
										cts:and-query((for $item in fn:tokenize(fn:lower-case($Keywords),' and ')
										
											return 
											
											 cts:element-word-query(xs:QName('ALI_RE_Event_Data:practice_area'),fn:replace($item,'"',''),('wildcarded','case-insensitive'))
										))
										
										))
	return $query									
};

declare function event:GetAndOrOperatorQuery($keyword)
{
	let $key := fn:tokenize($keyword,' or ')
	for $Keywords in $key
		let $query := cts:or-query((
											cts:and-query((
											for $item in fn:tokenize(fn:lower-case($Keywords),' and ')
											
												return 
												
												 cts:element-word-query(xs:QName('ALI_RE_Event_Data:EventTitle'),$item,('wildcarded','case-insensitive'))
												 
												
											)),
											
											cts:and-query((for $item in fn:tokenize(fn:lower-case($Keywords),' and ')
											
												return 
												
												 cts:element-word-query(xs:QName('ALI_RE_Event_Data:EventDescription'),$item,('wildcarded','case-insensitive'))
												
												
											)),
											
											cts:and-query((for $item in fn:tokenize(fn:lower-case($Keywords),' and ')
											
												return 
												
												 cts:element-word-query(xs:QName('ALI_RE_Event_Data:practice_area'),$item,('wildcarded','case-insensitive'))
											))
											
											))
		return $query
		
		
};