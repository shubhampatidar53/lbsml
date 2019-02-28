xquery version '1.0-ml';

module namespace firm-comp = 'http://alm.com/firm-comparison';

import module namespace config = 'http://alm.com/config' at '/common/config.xqy';
import module namespace search = 'http://marklogic.com/appservices/search' at '/MarkLogic/appservices/search/search.xqy';
import module namespace firm = 'http://alm.com/firm' at '/common/model/firm.xqy';
import module namespace helper = 'http://alm.com/helper' at '/common/model/helper.xqy';
import module namespace json = 'http://marklogic.com/xdmp/json'  at '/MarkLogic/json/json.xqy';
import module namespace mem = 'http://xqdev.com/in-mem-update' at '/MarkLogic/appservices/utils/in-mem-update.xqy';
import module namespace survey-listing = 'http://alm.com/survey-listing' at '/common/model/survey-listing.xqy';

declare namespace dd-org = 'http://alm.com/LegalCompass/dd/organization';
declare namespace org-branch = 'http://alm.com/LegalCompass/rd/organization-branch';
declare namespace AMLAW_200 = 'http://alm.com/LegalCompass/dd/AMLAW_200';
declare namespace RD_AMLAW_200 = 'http://alm.com/LegalCompass/rd/AMLAW_200';
declare namespace ALIST = 'http://alm.com/LegalCompass/dd/ALIST';
declare namespace Global_100 = 'http://alm.com/LegalCompass/dd/Global_100';
declare namespace survey = 'http://alm.com/LegalCompass/dd/survey';
declare namespace Who_Counsels_who = 'http://alm.com/LegalCompass/rd/Who_Counsels_who';
declare namespace COMPANYPROFILE_LFR_NEW = 'http://alm.com/LegalCompass/rd/COMPANYPROFILE_LFR_NEW';
declare namespace bdbs-transaction = 'http://alm.com/LegalCompass/rd/bdbs-transaction';
declare namespace bdbs-party = 'http://alm.com/LegalCompass/rd/bdbs-party';
declare namespace firm-org = 'http://alm.com/LegalCompass/lawfirm/dd/organization';
declare namespace bdbs-representer = 'http://alm.com/LegalCompass/rd/bdbs-representer';
declare namespace org-address = 'http://alm.com/LegalCompass/rd/organization-address';

declare namespace amlaw200 = "http://alm.com/LegalCompass/rd/AMLAW_200";
declare namespace organization = "http://alm.com/LegalCompass/rd/organization";
declare namespace nlj250 = "http://alm.com/LegalCompass/rd/NLJ_250";
declare namespace global100 = "http://alm.com/LegalCompass/rd/Global_100";
declare namespace alist = "http://alm.com/LegalCompass/rd/ALIST";
declare namespace diversity = "http://alm.com/LegalCompass/rd/Diversity_Scorecard";
declare namespace femalesb = "http://alm.com/LegalCompass/rd/FEMALE_SCORECARD";
declare namespace ny100 = "http://alm.com/LegalCompass/rd/NY100";
declare namespace associateclass = "http://alm.com/LegalCompass/rd/ASSOCIATE_CLASS_BILLING_SURVEY";
declare namespace associatenatl = "http://alm.com/LegalCompass/rd/Associate_natl";
declare namespace techscore = "http://alm.com/LegalCompass/rd/Tech_Scorecard";
declare namespace prob = "http://alm.com/LegalCompass/rd/Pro_Bono";
declare namespace nljbilling = "http://alm.com/LegalCompass/rd/NLJ_BILLING";
declare namespace china40 ='http://alm.com/LegalCompass/rd/CHINA_40';
declare namespace uk50 ='http://alm.com/LegalCompass/rd/UK_50';
declare namespace xref = 'http://alm.com/LegalCompass/rd/FIRMS_ALI_XREF_RE';
declare namespace company_locs = "http://alm.com/LegalCompass/company_locs";
declare namespace cityns = "http://alm.com/LegalCompass/rd/city";

declare namespace organization_advancesearch = 'http://alm.com/LegalCompass/lawfirm-advancesearch/dd/organization';

declare option xdmp:mapping 'false';

(: declare function firm-comp:GetFirmRankings1(
	 $PageNo
	,$PageSize
	,$FromYear
	,$ToYear
	,$FirmSearchKeys
	,$FirmLocation
	,$SortDirection
	,$SortBy
	,$FirmSize
	,$PracticeAreas
	,$ALMRankingListName
)
{
	let $direction := if (fn:lower-case($SortDirection) = 'desc') then 'descending' else 'ascending'
	
	(: Filter By WatchList And Firm Search Keys :)
	let $FirmSearch-IDs := if ($ALMRankingListName !='') then (
			if ($FirmSearchKeys != '') then (
				fn:tokenize($FirmSearchKeys,",")
			) else (
				let $res := survey-listing:GetSurveyOrganizations($ALMRankingListName,())
				return ($res ! xs:string(.))
			)
		) else (
			if ($FirmSearchKeys != '') then (
				fn:tokenize($FirmSearchKeys,",")
			) else ()
		)
	
	(: Filter By FirmLocation :)
	let $Location-IDs := if ($FirmLocation != '') then
			firm-comp:GetOrganizationIDByLocation($FirmLocation)
		else ()
	
	(: Filter By Practice Area :)
	let $PracticeAreas-IDs := if ($PracticeAreas != '') then
			firm-comp:GetOrganizationIDByPracticeAreas($PracticeAreas)
		else ()
	
	let $years := cts:element-values(xs:QName('RD_AMLAW_200:PUBLISHYEAR'),(),('ascending'))
	let $minYear := fn:min($years)
	
	(: Year Range Query :)
	let $from_to_date_query := cts:and-query((
			(: cts:element-range-query(xs:QName('firm-org:PUBLISHYEAR'), '>=', xs:integer($minYear)), :)
			cts:element-range-query(xs:QName('firm-org:PUBLISHYEAR'), '>=', xs:integer($FromYear)),
			cts:element-range-query(xs:QName('firm-org:PUBLISHYEAR'), '<=', xs:integer($ToYear))
		))

	
		
	let $firm_size_query := if ($FirmSize!='' and fn:upper-case($FirmSize) ne 'ALL FIRM SIZES') then (
			if (fn:contains($FirmSize,'1500+') and fn:not(fn:contains($FirmSize,'-'))) then (
				 cts:not-query(cts:element-value-query(xs:QName('firm-org:NUM_OF_ATTORNEYS'),''))
				,cts:element-range-query(xs:QName('firm-org:NUM_OF_ATTORNEYS'), '>', 1500)
			) else (
				let $arrRange := fn:tokenize($FirmSize,';')
				return if (fn:count($arrRange) > 1) then ( 
						let $largest := xs:integer(fn:tokenize($arrRange[last()],'-')[2])
						let $smallest := xs:integer(fn:tokenize($arrRange[1],'-')[1])
						return (
							 cts:element-range-query(xs:QName('firm-org:NUM_OF_ATTORNEYS'), '>', $smallest)
							,cts:element-range-query(xs:QName('firm-org:NUM_OF_ATTORNEYS'), '<', $largest)
						)
					)
					else (
						let $largest := xs:integer(fn:tokenize($arrRange,'-')[2])
						let $smallest := xs:integer(fn:tokenize($arrRange,'-')[1])
						return (
							 cts:not-query(cts:element-value-query(xs:QName('firm-org:NUM_OF_ATTORNEYS'),''))
							,cts:element-range-query(xs:QName('firm-org:NUM_OF_ATTORNEYS'), '>', $smallest)
							,cts:element-range-query(xs:QName('firm-org:NUM_OF_ATTORNEYS'), '<', $largest)
						)
					)
			)
		) else ()
  
	let $years := ($years ! xs:string(.))
	let $conditions := (
		 cts:directory-query($config:DD-ORGANIZATION-SURVEY-PATH)
		,cts:element-value-query(xs:QName("firm-org:OrganizationTypeID"),"1")
		,$from_to_date_query
		,$firm_size_query
		(:,cts:element-value-query(xs:QName('firm-org:PUBLISHYEAR'), $years):)
		,if ($Location-IDs) then cts:element-value-query(xs:QName('firm-org:OrganizationID'),($Location-IDs ! xs:string(.))) else ()
		,if ($FirmSearch-IDs) then cts:element-value-query(xs:QName('firm-org:OrganizationID'),($FirmSearch-IDs ! xs:string(.))) else ()
		,if ($PracticeAreas-IDs) then cts:element-value-query(xs:QName('firm-org:OrganizationID'),($PracticeAreas-IDs ! xs:string(.))) else ()
	)
	
	let $order-by := if (fn:upper-case($SortBy) = 'FIRMNAME') then (
			cts:index-order(cts:element-reference(xs:QName('firm-org:OrganizationName')) ,$direction)
		) 
		else if (fn:upper-case($SortBy) = 'YEAR') then (
			cts:index-order(cts:element-reference(xs:QName('firm-org:PUBLISHYEAR')) ,$direction)
		)
		else if (fn:upper-case($SortBy) = 'REVENUE') then (
			(: cts:index-order(cts:element-reference(xs:QName('firm-org:AMLAW_200_GROSS_REVENUE')) ,$direction)
			,cts:index-order(cts:element-reference(xs:QName('firm-org:Global_100_GROSS_REVENUE')) ,$direction) :)
			cts:index-order(cts:element-reference(xs:QName('firm-org:REVENUE')) ,$direction)
		)
		else if (fn:upper-case($SortBy) = 'AMLAW200RANK') then  (
			cts:index-order(cts:element-reference(xs:QName('firm-org:AMLAW200_RANK')) ,$direction)
		)
		else if (fn:upper-case($SortBy) = 'NLJ500RANK') then (
			cts:index-order(cts:element-reference(xs:QName('firm-org:NLJ250_RANK')) ,$direction)
		)
		else if (fn:upper-case($SortBy) = 'ALISTRANK') then (
			cts:index-order(cts:element-reference(xs:QName('firm-org:NLJ250_RANK')) ,$direction)
		)
		else if (fn:upper-case($SortBy) = 'GLOBAL100RANK') then (
			cts:index-order(cts:element-reference(xs:QName('firm-org:RANK_BY_GROSS_REVENUE')) ,$direction)
		)
		else if (fn:upper-case($SortBy) = 'NOOFATTORNEYS') then (
			(: cts:index-order(cts:element-reference(xs:QName('firm-org:NUM_ATTORNEYS')) ,$direction)
			,cts:index-order(cts:element-reference(xs:QName('firm-org:NUM_OF_LAWYERS')) ,$direction) :)
			cts:index-order(cts:element-reference(xs:QName('firm-org:NUM_OF_ATTORNEYS')) ,$direction)
		)
		else (
			 cts:index-order(cts:element-reference(xs:QName('firm-org:AMLAW200_RANK')) ,'ascending')
			,cts:index-order(cts:element-reference(xs:QName('firm-org:OrganizationName'),('type=string','collation=http://marklogic.com/collation/en/S4/AS/T00BB')),'ascending')
			,cts:index-order(cts:element-reference(xs:QName('firm-org:PUBLISHYEAR')),'descending')
		)

	let $TotalCount := xdmp:estimate(cts:search(fn:doc(), cts:and-query(($conditions))))

	let $start := xs:integer(((xs:integer($PageNo)* xs:integer($PageSize))-xs:integer($PageSize))+1)
	let $end := xs:integer((xs:integer($start) + xs:integer($PageSize)) - 1 )
	
	let $response-arr := json:array()
	
	(: let $lst_firm := cts:element-values(xs:QName('firm-org:OrganizationID'), (), (), cts:and-query(($conditions))) :)
	let $LSTFirms := fn:distinct-values(cts:search(/SURVEY, cts:and-query(($conditions)))//firm-org:OrganizationID/text())
	let $LSTFirms := json:to-array($LSTFirms)
	let $req-obj := json:object()
	let $_ := map:put($req-obj,'LSTFirms',$LSTFirms)
	return json:to-array($req-obj)
	}; :)

declare function firm-comp:GetFirmRankings(
	 $PageNo
	,$PageSize
	,$FromYear
	,$ToYear
	,$FirmSearchKeys
	,$FirmLocation
	,$SortDirection
	,$SortBy
	,$FirmSize
	,$PracticeAreas
	,$ALMRankingListName
)
{
	let $direction := if (fn:lower-case($SortDirection) = 'desc') then 'descending' else 'ascending'
	
	(: Filter By WatchList And Firm Search Keys :)
	let $FirmSearch-IDs := if ($ALMRankingListName !='') then (
			if ($FirmSearchKeys != '') then (
				fn:tokenize($FirmSearchKeys,",")
			) else (
				let $res := survey-listing:GetSurveyOrganizations($ALMRankingListName,())
				return ($res ! xs:string(.))
			)
		) else (
			if ($FirmSearchKeys != '') then (
				fn:tokenize($FirmSearchKeys,",")
			) else ()
		)
	
	(: Filter By FirmLocation :)
	let $Location-IDs := if ($FirmLocation != '') then
			firm-comp:GetOrganizationIDByLocation($FirmLocation)
		else ()
	
	(: Filter By Practice Area :)
	let $PracticeAreas-IDs := if ($PracticeAreas != '') then
			firm-comp:GetOrganizationIDByPracticeAreas($PracticeAreas)
		else ()
	
	let $years := cts:element-values(xs:QName('RD_AMLAW_200:PUBLISHYEAR'),(),('ascending'))
	let $minYear := fn:min($years)
	
	(: Year Range Query :)
	let $from_to_date_query := cts:and-query((
			(: cts:element-range-query(xs:QName('firm-org:PUBLISHYEAR'), '>=', xs:integer($minYear)), :)
			cts:element-range-query(xs:QName('firm-org:PUBLISHYEAR'), '>=', xs:integer($FromYear)),
			cts:element-range-query(xs:QName('firm-org:PUBLISHYEAR'), '<=', xs:integer($ToYear))
		))

	(: Prepare XQuery If Firm Size Is Applied :)
	(: let $firm_size_query := if ($FirmSize!='') then (
			if (fn:contains($FirmSize,'1500+') and fn:not(fn:contains($FirmSize,'-'))) then (
				cts:element-range-query(xs:QName('firm-org:NUM_ATTORNEYS'), '>', 1500)
			) else (
				let $arrRange := fn:tokenize($FirmSize,';')
				return if (fn:count($arrRange) > 1) then ( 
						let $largest := xs:integer(fn:tokenize($arrRange[last()],'-')[2])
						let $smallest := xs:integer(fn:tokenize($arrRange[1],'-')[1])
						return (
							 cts:element-range-query(xs:QName('firm-org:NUM_ATTORNEYS'), '>', $smallest)
							,cts:element-range-query(xs:QName('firm-org:NUM_ATTORNEYS'), '<', $largest)
						)
					)
					else (
						let $largest := xs:integer(fn:tokenize($arrRange,'-')[2])
						let $smallest := xs:integer(fn:tokenize($arrRange,'-')[1])
						return (
							 cts:not-query(cts:element-value-query(xs:QName('firm-org:NUM_ATTORNEYS'),''))
							,cts:element-range-query(xs:QName('firm-org:NUM_ATTORNEYS'), '>', $smallest)
							,cts:element-range-query(xs:QName('firm-org:NUM_ATTORNEYS'), '<', $largest)
						)
					)
			)
		) else () :)
		
	(:let $firm_size_query := if ($FirmSize!=''  and fn:upper-case($FirmSize) ne 'ALL FIRM SIZES') then (
			if (fn:contains($FirmSize,'1500+') and fn:not(fn:contains($FirmSize,'-'))) then (
				 cts:not-query(cts:element-value-query(xs:QName('firm-org:NUM_OF_ATTORNEYS'),''))
				,cts:element-range-query(xs:QName('firm-org:NUM_OF_ATTORNEYS'), '>', 1500)
			) else (
				let $arrRange := fn:tokenize($FirmSize,';')
				return if (fn:count($arrRange) > 1) then ( 
						let $largest := xs:integer(fn:tokenize($arrRange[last()],'-')[2])
						let $smallest := xs:integer(fn:tokenize($arrRange[1],'-')[1])
						return (
							 cts:element-range-query(xs:QName('firm-org:NUM_OF_ATTORNEYS'), '>', $smallest)
							,cts:element-range-query(xs:QName('firm-org:NUM_OF_ATTORNEYS'), '<', $largest)
						)
					)
					else (
						let $largest := xs:integer(fn:tokenize($arrRange,'-')[2])
						let $smallest := xs:integer(fn:tokenize($arrRange,'-')[1])
						return (
							 cts:not-query(cts:element-value-query(xs:QName('firm-org:NUM_OF_ATTORNEYS'),''))
							,cts:element-range-query(xs:QName('firm-org:NUM_OF_ATTORNEYS'), '>', $smallest)
							,cts:element-range-query(xs:QName('firm-org:NUM_OF_ATTORNEYS'), '<', $largest)
						)
					)
			)
		) else ():)
		
		
   let $FirmSizes := if($FirmSize ne '') then fn:tokenize($FirmSize,';') else ()
   let $firm_size_query := if($FirmSizes != '') then if(count($FirmSizes) eq 1) then 
								if($FirmSizes ne '1500+') then
									cts:and-query((cts:not-query(cts:element-value-query(xs:QName('firm-org:NUM_OF_ATTORNEYS'),'')),
										   cts:element-range-query(xs:QName('firm-org:NUM_OF_ATTORNEYS'), '>',xs:integer(fn:tokenize($FirmSizes,'-')[1])),
										   cts:element-range-query(xs:QName('firm-org:NUM_OF_ATTORNEYS'), '<',xs:integer(fn:tokenize($FirmSizes,'-')[2]))
										   ))
								else 		   
									cts:and-query((
										cts:not-query(cts:element-value-query(xs:QName('firm-org:NUM_OF_ATTORNEYS'),''))
									    ,cts:element-range-query(xs:QName('firm-org:NUM_OF_ATTORNEYS'),'>', xs:integer(fn:replace($FirmSizes,'[+]','')))
										  ))
								else if(count($FirmSizes) > 1) then 
										
										for $item in $FirmSizes
											return if($item ne '1500+') then
												cts:and-query((cts:not-query(cts:element-value-query(xs:QName('firm-org:NUM_OF_ATTORNEYS'),'')),
													   cts:element-range-query(xs:QName('firm-org:NUM_OF_ATTORNEYS'), '>',xs:integer(fn:tokenize($item,'-')[1])),
													   cts:element-range-query(xs:QName('firm-org:NUM_OF_ATTORNEYS'), '<',xs:integer(fn:tokenize($item,'-')[2]))
													   ))
											else 		   
												cts:and-query((
													cts:not-query(cts:element-value-query(xs:QName('firm-org:NUM_OF_ATTORNEYS'),''))
													,cts:element-range-query(xs:QName('firm-org:NUM_OF_ATTORNEYS'),'>', xs:integer(fn:replace($item,'[+]','')))
													  ))
								else()		
			else()	
  
	let $years := ($years ! xs:string(.))
	let $conditions := (
		 cts:directory-query($config:DD-ORGANIZATION-SURVEY-PATH)
		,cts:element-value-query(xs:QName("firm-org:OrganizationTypeID"),"1")
		,$from_to_date_query
		(: ,if(fn:not(fn:contains($FirmSize,'Any') or fn:contains(fn:upper-case($FirmSize),'ALL FIRM SIZES'))) then cts:or-query($firm_size_query) else() :)
		(:,if(fn:contains($FirmSize,'Any') or fn:contains(fn:upper-case($FirmSize),'ALL FIRM SIZES')) then () else cts:or-query($firm_size_query):)
		,if($FirmSize ne '') then cts:or-query($firm_size_query) else ()
		(:,cts:element-value-query(xs:QName('firm-org:PUBLISHYEAR'), $years):)
		,if ($Location-IDs) then cts:element-value-query(xs:QName('firm-org:OrganizationID'),($Location-IDs ! xs:string(.))) else ()
		,if ($FirmSearch-IDs) then cts:element-value-query(xs:QName('firm-org:OrganizationID'),($FirmSearch-IDs ! xs:string(.))) else ()
		,if ($PracticeAreas-IDs) then cts:element-value-query(xs:QName('firm-org:OrganizationID'),($PracticeAreas-IDs ! xs:string(.))) else ()
	)
	
	let $order-by := if (fn:upper-case($SortBy) = 'FIRMNAME') then (
			cts:index-order(cts:element-reference(xs:QName('firm-org:OrganizationName')) ,$direction)
		) 
		else if (fn:upper-case($SortBy) = 'YEAR') then (
			cts:index-order(cts:element-reference(xs:QName('firm-org:PUBLISHYEAR')) ,$direction)
		)
		else if (fn:upper-case($SortBy) = 'REVENUE') then (
			(: cts:index-order(cts:element-reference(xs:QName('firm-org:AMLAW_200_GROSS_REVENUE')) ,$direction)
			,cts:index-order(cts:element-reference(xs:QName('firm-org:Global_100_GROSS_REVENUE')) ,$direction) :)
			cts:index-order(cts:element-reference(xs:QName('firm-org:REVENUE')) ,$direction)
		)
		else if (fn:upper-case($SortBy) = 'AMLAW200RANK') then  (
			cts:index-order(cts:element-reference(xs:QName('firm-org:AMLAW200_RANK')) ,$direction)
		)
		else if (fn:upper-case($SortBy) = 'NLJ500RANK') then (
			cts:index-order(cts:element-reference(xs:QName('firm-org:NLJ250_RANK')) ,$direction)
		)
		else if (fn:upper-case($SortBy) = 'ALISTRANK') then (
			cts:index-order(cts:element-reference(xs:QName('firm-org:NLJ250_RANK')) ,$direction)
		)
		else if (fn:upper-case($SortBy) = 'GLOBAL100RANK') then (
			cts:index-order(cts:element-reference(xs:QName('firm-org:RANK_BY_GROSS_REVENUE')) ,$direction)
		)
		else if (fn:upper-case($SortBy) = 'NOOFATTORNEYS') then (
			(: cts:index-order(cts:element-reference(xs:QName('firm-org:NUM_ATTORNEYS')) ,$direction)
			,cts:index-order(cts:element-reference(xs:QName('firm-org:NUM_OF_LAWYERS')) ,$direction) :)
			cts:index-order(cts:element-reference(xs:QName('firm-org:NUM_OF_ATTORNEYS')) ,$direction)
		)
		else (
			 cts:index-order(cts:element-reference(xs:QName('firm-org:AMLAW200_RANK')) ,'ascending')
			,cts:index-order(cts:element-reference(xs:QName('firm-org:OrganizationName'),('type=string','collation=http://marklogic.com/collation/en/S4/AS/T00BB')),'ascending')
			,cts:index-order(cts:element-reference(xs:QName('firm-org:PUBLISHYEAR')),'descending')
		)

	let $TotalCount := xdmp:estimate(cts:search(fn:doc(), cts:and-query(($conditions))))

	let $start := xs:integer(((xs:integer($PageNo)* xs:integer($PageSize))-xs:integer($PageSize))+1)
	let $end := xs:integer((xs:integer($start) + xs:integer($PageSize)) - 1 )
	
	let $response-arr := json:array()
	
	(: let $lst_firm := cts:element-values(xs:QName('firm-org:OrganizationID'), (), (), cts:and-query(($conditions))) :)
	(:let $LSTFirms := fn:distinct-values(cts:search(/SURVEY, cts:and-query(($conditions)))//firm-org:OrganizationID/text())
	let $LSTFirms := json:to-array($LSTFirms):)

	let $count := 1
	
	let $_ := for $res in cts:search(/SURVEY, cts:and-query(($conditions)),$order-by)[$start to $end]
		
		(:let $LSTFirms := if ($count = 1) then $LSTFirms else ():)
		
		let $_ := xdmp:set($count,($count+1))
		
		let $Year := $res/firm-org:PUBLISHYEAR/text()
		let $FirmId := $res/firm-org:OrganizationID/text()
		let $FirmName := fn:normalize-space($res/firm-org:OrganizationName/text())
		let $AMLaw200Rank := $res/firm-org:AMLAW200_RANK/text()
		let $AListRank := $res/firm-org:ALIST_RANK/text()
		let $Global100Rank := $res/firm-org:RANK_BY_GROSS_REVENUE/text()
		let $NLJ500Rank := $res/firm-org:NLJ250_RANK/text()
		(:let $NoofAttorneys := if ($res/firm-org:NUM_ATTORNEYS/text() != '') then $res/firm-org:NUM_ATTORNEYS/text() else $res/firm-org:NUM_OF_LAWYERS/text()
		let $Revenue := if ($res/firm-org:AMLAW_200_GROSS_REVENUE/text() != '') then $res/firm-org:AMLAW_200_GROSS_REVENUE/text() else $res/firm-org:Global_100_GROSS_REVENUE/text():)
		
		let $NoofAttorneys := $res/firm-org:NUM_OF_ATTORNEYS/text()
		let $Revenue := $res/firm-org:REVENUE/text()
		
		let $IsAddedToCompareList := ''
		
		let $response-obj := json:object()
			
		let $_ := (
			 map:put($response-obj, 'TotalCount', $TotalCount)
			(:,map:put($response-obj, 'LSTFirms', $LSTFirms):)
			,map:put($response-obj, 'Year', $Year)
			,map:put($response-obj, 'FirmName', $FirmName)
			,map:put($response-obj, 'FirmId', $FirmId)
			,map:put($response-obj, 'AMLaw200Rank', $AMLaw200Rank)
			,map:put($response-obj, 'AListRank', $AListRank)
			,map:put($response-obj, 'Global100Rank', $Global100Rank)
			,map:put($response-obj, 'NLJ500Rank', $NLJ500Rank)
			,map:put($response-obj, 'NoofAttorneys', $NoofAttorneys)
			,map:put($response-obj, 'Revenue', if ($Revenue != '') then $Revenue else '0')
			,map:put($response-obj, 'IsAddedToCompareList', $IsAddedToCompareList)
		)
			
		let $_ := json:array-push($response-arr, $response-obj)
		
		return ()
	
	return $response-arr
};

declare function firm-comp:GetOrganizationIDByPracticeAreas($PracticeAreas)
{
	let $org_ids := if ($PracticeAreas != '') then
		
			let $RepresentationTypeIDs := firm:GetLevel1Level2Array($PracticeAreas)
      
			let $IDs := ($RepresentationTypeIDs ! xs:string(.))
      
			let $OUTSIDE_COUNSEL_ID := cts:element-values(xs:QName("Who_Counsels_who:OUTSIDE_COUNSEL_ID"),(),(),cts:and-query((
				cts:directory-query($config:RD-SURVEY-WHO_COUNSELS_WHO-PATH)
				,cts:element-value-query(xs:QName('Who_Counsels_who:REPRESENTATION_TYPE_ID'), $IDs)
				,cts:not-query(cts:element-value-query(xs:QName('Who_Counsels_who:OUTSIDE_COUNSEL_ID'), "0"))
				,cts:not-query(cts:element-value-query(xs:QName('Who_Counsels_who:OUTSIDE_COUNSEL_ID'), ""))
			)))
      
			let $FIRM_ID := cts:element-values(xs:QName("COMPANYPROFILE_LFR_NEW:FIRM_ID"),(),(),cts:and-query((
				cts:directory-query($config:RD-SURVEY-COMPANYPROFILE_LFR_NEW-PATH)
				,cts:element-value-query(xs:QName('COMPANYPROFILE_LFR_NEW:REPRESENTATION_TYPE_ID'), $IDs)
				,cts:not-query(cts:element-value-query(xs:QName('COMPANYPROFILE_LFR_NEW:FIRM_ID'), "0"))
				,cts:not-query(cts:element-value-query(xs:QName('COMPANYPROFILE_LFR_NEW:FIRM_ID'), ""))
			)))
      
			(:
			1 - BDBS_TRANSACTIONS BT 	- TRANSACTION_ID 	(BT:TRANSACTION_TYPE_ID = REPRESENTATION_TYPE_ID)
			2 - BDBS_PARTIES BP 		- Party_Id 			(BT.TRANSACTION_ID=BP.TRANSACTION_ID)
			3 - BDBS_REPRESENTERS BR 	- Organization_Id 	(BP.Party_Id = BR.Party_Id)
			:)
			
			let $TRANSACTION_IDs := cts:element-values(xs:QName('bdbs-transaction:TRANSACTION_ID'),(),(), cts:and-query((
				cts:directory-query($config:RD-BDBS_TRANSACTION-PATH)
				,cts:element-value-query(xs:QName('bdbs-transaction:TRANSACTION_TYPE_ID'), $IDs)
			)))
      
			let $PARTY_IDs := cts:element-values(xs:QName('bdbs-party:PARTY_ID'),(),(), cts:and-query((
				cts:directory-query($config:RD-BDBS_PARTY-PATH)
				,cts:element-value-query(xs:QName('bdbs-party:TRANSACTION_ID'),($TRANSACTION_IDs ! xs:string(.)))
				,cts:not-query(cts:element-value-query(xs:QName('bdbs-party:PARTY_ID'),'0'))
				,cts:not-query(cts:element-value-query(xs:QName('bdbs-party:PARTY_ID'),''))
			)))
			
			let $ORGANIZATION_IDs := cts:element-values(xs:QName('bdbs-representer:ORGANIZATION_ID'),(),(), cts:and-query((
				 cts:directory-query($config:RD-BDBS_REPRESENTER-PATH)
				,cts:element-value-query(xs:QName('bdbs-representer:PARTY_ID'),($PARTY_IDs ! xs:string(.)))
				,cts:not-query(cts:element-value-query(xs:QName('bdbs-representer:ORGANIZATION_ID'),'0'))
				,cts:not-query(cts:element-value-query(xs:QName('bdbs-representer:ORGANIZATION_ID'),''))
			)))
        
			return ($ORGANIZATION_IDs,$OUTSIDE_COUNSEL_ID,$FIRM_ID)
  
		else ()
		
	return $org_ids
};

declare function firm-comp:GetOrganizationIDByLocation($FirmLocation)
{
	let $ORGANIZATION_IDs := if (($FirmLocation != '') and ($FirmLocation)) then
		
			(: condition for Geo Region :)
			let $GeoRegion_Q := if ($FirmLocation/GeoRegions) then
				let $GeoRegions := $FirmLocation/GeoRegions/text()
				return cts:element-value-query(xs:QName('org-branch:GEOGRAPHIC_REGION'),$GeoRegions,('case-insensitive'))
			else ()

			(: condition for Region :)
			let $Region_Q := if ($FirmLocation/UsRegions) then
				let $UsRegions := $FirmLocation/UsRegions/text()
				return if ($UsRegions = ('US States/Cities','US Regions')) then
					let $USRegions := cts:element-values(xs:QName('org-branch:US_REGIONS'), (), (), cts:and-query((
						 cts:collection-query($config:RD-ORGANIZATION_BRANCH-COLLECTION)
						,cts:not-query(cts:element-value-query(xs:QName('org-branch:US_REGIONS'),''))
					)))
					return cts:element-value-query(xs:QName('org-branch:US_REGIONS'),$USRegions,('case-insensitive'))
				else 
					cts:element-value-query(xs:QName('org-branch:US_REGIONS'),$UsRegions,('case-insensitive')) 
			else ()

			(: condition for Countries :)
			let $Country_Q := if ($FirmLocation/Countries) then 
				let $Countries := $FirmLocation/Countries/text()
				return cts:element-value-query(xs:QName('org-branch:COUNTRY'),$Countries,('case-insensitive'))
			else ()

			(: condition for State :)
			let $STATE_Q := if ($FirmLocation/States) then 
				let $States := $FirmLocation/States/text()
				return cts:element-value-query(xs:QName('org-branch:STATE'),$States,('case-insensitive'))
			else ()

			(: condition for City :)
			let $CITY_Q := if ($FirmLocation/Cities) then 
				let $Cities := $FirmLocation/Cities/text()
				return cts:element-value-query(xs:QName('org-branch:CITY'), $Cities, ('case-insensitive'))
			else ()

			return  cts:element-values(xs:QName('org-branch:ORGANIZATION_ID'),(),(), 
				cts:and-query((
					cts:or-query((
					$GeoRegion_Q, $Region_Q, $Country_Q, $STATE_Q, $CITY_Q
					)),
					cts:not-query(cts:element-range-query(xs:QName('org-branch:ORGANIZATION_ID'),'<',1))
				)))

		else ()
		
	return $ORGANIZATION_IDs
};

(: declare function firm-comp:GetOrganizationIDByLocation_New($FirmLocation)
{
	let $ORGANIZATION_IDs := if (($FirmLocation != '') and ($FirmLocation)) then
		
			(: condition for Geo Region :)
			let $GeoRegion_Q := if ($FirmLocation/GeoRegions) then
				let $GeoRegions := $FirmLocation/GeoRegions/text()
				return cts:element-value-query(xs:QName('org-branch:GEOGRAPHIC_REGION'),$GeoRegions,('case-insensitive'))
			else ()

			(: condition for Region :)
			let $Region_Q := if ($FirmLocation/UsRegions) then
				let $UsRegions := $FirmLocation/UsRegions/text()
				return if ($UsRegions = ('US States/Cities','US Regions')) then
					let $USRegions := cts:element-values(xs:QName('org-branch:US_REGIONS'), (), (), cts:and-query((
						 cts:collection-query($config:RD-ORGANIZATION_BRANCH-COLLECTION)
						,cts:not-query(cts:element-value-query(xs:QName('org-branch:US_REGIONS'),''))
					)))
					return cts:element-value-query(xs:QName('org-branch:US_REGIONS'),$USRegions,('case-insensitive'))
				else 
					cts:element-value-query(xs:QName('org-branch:US_REGIONS'),$UsRegions,('case-insensitive')) 
			else ()

			(: condition for Countries :)
			let $Country_Q := if ($FirmLocation/Countries) then 
				let $Countries := $FirmLocation/Countries/text()
				return cts:element-value-query(xs:QName('org-branch:COUNTRY'),$Countries,('case-insensitive'))
			else ()

			(: condition for State :)
			let $STATE_Q := if ($FirmLocation/States) then 
				let $States := $FirmLocation/States/text()
				return cts:element-value-query(xs:QName('org-branch:STATE'),$States,('case-insensitive'))
			else ()

			(: condition for City :)
			(: let $CITY_Q := if ($FirmLocation/Cities) then 
				let $Cities := $FirmLocation/Cities/text() ! fn:tokenize(.,',')[1]
				return cts:element-value-query(xs:QName('org-branch:CITY'), $Cities, ('case-insensitive'))
			else () :)

			(: condition for City :)
			let $CITY_Q := if ($FirmLocation/Cities) then 
				let $Cities := $FirmLocation/Cities/text() ! fn:tokenize(.,',')[1]
				for $c in $Cities
				return if(count(fn:tokenize($c,('[|,]'))) > 1) 
				then 
				let $city := fn:tokenize($c,('[|,]'))[1]
          		let $state := fn:tokenize($c,('[|,]'))[2]
						return 
					if(fn:string-length($state) eq 2) 
					then 
					cts:and-query((
					cts:element-value-query(xs:QName('org-branch:CITY'), $city, ('case-insensitive'))
					,cts:element-value-query(xs:QName('org-branch:STATE'), $state, ('case-insensitive'))
					))
					else
					cts:and-query((
					cts:element-value-query(xs:QName('org-branch:CITY'), $city, ('case-insensitive'))
					,cts:element-value-query(xs:QName('org-branch:COUNTRY'), $state, ('case-insensitive'))
					))
				
				else
				cts:element-value-query(xs:QName('org-branch:CITY'), $Cities, ('case-insensitive'))
			else ()

			return  cts:element-values(xs:QName('org-branch:ORGANIZATION_ID'),(),(), 
				cts:and-query((
					cts:or-query((
					$GeoRegion_Q, $Region_Q, $Country_Q, $STATE_Q, $CITY_Q
					))
					,cts:element-value-query(xs:QName('org-branch:FISCAL_YEAR'), xs:string(cts:max(cts:element-reference(xs:QName("org-branch:FISCAL_YEAR")))))					
					,cts:not-query(cts:element-range-query(xs:QName('org-branch:ORGANIZATION_ID'),'<',1))
				)))

		else ()
		
	return $ORGANIZATION_IDs
}; :)


declare function firm-comp:GetOrganizationIDByLocation_New($FirmLocation)
{
	let $ORGANIZATION_IDs := if (($FirmLocation != '') and ($FirmLocation)) then
			
			(: condition for Geo Region :)
			let $GeoRegion_Q := if ($FirmLocation/GeoRegions) then
				let $GeoRegions := $FirmLocation/GeoRegions/text()
				(: return cts:element-value-query(xs:QName('cityns:geographic_region'),fn:tokenize($GeoRegions,',')) :)
				return cts:element-value-query(xs:QName('cityns:geographic_region'),$GeoRegions)
			else ()

			(: condition for Region :)
			let $Region_Q := if ($FirmLocation/UsRegions) then
				let $UsRegions := $FirmLocation/UsRegions/text()
				return cts:element-value-query(xs:QName('cityns:us_region'),$UsRegions)
			else ()

			(: condition for Countries :)
			let $Country_Q := if ($FirmLocation/Countries) then 
				let $Countries := $FirmLocation/Countries/text()
				return cts:element-value-query(xs:QName('cityns:country'),$Countries)
			else ()

			(: condition for State :)
			let $STATE_Q := if ($FirmLocation/States) then 
				let $States := $FirmLocation/States/text()
				return cts:element-value-query(xs:QName('cityns:state'),$States) 
			else ()

			(: condition for City :)
			(: let $CITY_Q := if ($FirmLocation/Cities) then 
				let $Cities := $FirmLocation/Cities/text()
				return cts:element-value-query(xs:QName('cityns:city'),$Cities)
			else () :)

			let $CITY_Q := if ($FirmLocation/Cities) then 
				let $Cities := $FirmLocation/Cities/text()
				for $c in $Cities
				(: return if(count(fn:tokenize($c,'[|]')) > 1) 
				then 
				let $city := fn:tokenize($c,'[|]')[1]
				let $state := fn:tokenize($c,'[|]')[2] :)
				return if(count(fn:tokenize($c,('[|,]'))) > 1) 
				then 
				let $city := fn:tokenize($c,('[|,]'))[1]
          		let $state := fn:tokenize($c,('[|,]'))[2]
						return 
					if(fn:string-length($state) eq 2) 
					then 
					cts:and-query((
					cts:element-value-query(xs:QName('cityns:city'), $city, ('case-insensitive'))
					,cts:element-value-query(xs:QName('cityns:state'), $state, ('case-insensitive'))
					))
					else
					cts:and-query((
					cts:element-value-query(xs:QName('cityns:city'), $city, ('case-insensitive'))
					,cts:element-value-query(xs:QName('cityns:country'), $state, ('case-insensitive'))
					))
				
				else
				cts:element-value-query(xs:QName('cityns:city'), $Cities, ('case-insensitive'))
					else ()

			let $std_locs := 
        cts:search(/,
          cts:and-query((
            cts:directory-query('/LegalCompass/relational-data/city/',"infinity"),
			      cts:or-query((
            $GeoRegion_Q,$Region_Q,$Country_Q,$STATE_Q,$CITY_Q
            )))))//cityns:std_loc/text()

        let $cIDs := cts:search(/,
          cts:and-query((
            cts:directory-query("/LegalCompass/relational-data/company_locs/", "infinity")
              ,cts:element-value-query(xs:QName('company_locs:std_loc'),$std_locs,"whitespace-sensitive")
              (: ,cts:element-value-query(xs:QName('company_locs:headquarter'),'1') :)
          )))//company_locs:company_id/text()

        let $aliIDs := cts:element-values(xs:QName("xref:ALI_ID"),(),(),
          cts:and-query((
            cts:element-value-query(xs:QName('xref:RE_ID'),$cIDs)
          ))
        )
    return $aliIDs
  else ()    
	
return $ORGANIZATION_IDs

};

declare function firm-comp:GetOrganizationIDByAddress($FirmLocation)
{
	let $ADDRESS_IDs := if (($FirmLocation != '') and ($FirmLocation)) then
			
			(: condition for Geo Region :)
			let $GeoRegion_Q := if ($FirmLocation/GeoRegions) then
					let $GeoRegions := $FirmLocation/GeoRegions/text()
					return cts:element-value-query(xs:QName('org-address:GEOGRAPHIC_REGION'),$GeoRegions,('case-insensitive'))
				else ()

			(: condition for Region :)
			let $Region_Q := if ($FirmLocation/UsRegions) then
					let $UsRegions := $FirmLocation/UsRegions/text()
					return if ($UsRegions = ('US States/Cities','US Regions')) then
						let $USRegions := cts:element-values(xs:QName('org-branch:US_REGIONS'), (), (), cts:and-query((
								 cts:collection-query($config:RD-ORGANIZATION_BRANCH-COLLECTION)
								,cts:not-query(cts:element-value-query(xs:QName('org-branch:US_REGIONS'),''))
							)))
						return cts:element-value-query(xs:QName('org-address:US_REGIONS'),$USRegions,('case-insensitive'))
					else 
						cts:element-value-query(xs:QName('org-address:US_REGIONS'),$UsRegions,('case-insensitive')) 
				else ()

			(: condition for Countries :)
			let $Country_Q := if ($FirmLocation/Countries) then 
					let $Countries := $FirmLocation/Countries/text()
					return cts:element-value-query(xs:QName('org-address:COUNTRY'),$Countries,('case-insensitive'))
				else ()

			(: condition for State :)
			let $STATE_Q := if ($FirmLocation/States) then 
					let $States := $FirmLocation/States/text()
					return cts:element-value-query(xs:QName('org-address:STATE'),$States,('case-insensitive'))
				else ()

			(: condition for City :)
			let $CITY_Q := if ($FirmLocation/Cities) then 
					let $Cities := ($FirmLocation/Cities/text() ! fn:tokenize(.,'[|]')[1])
					return cts:element-value-query(xs:QName('org-address:CITY'), $Cities, ('case-insensitive'))
				else ()

			return  cts:element-values(xs:QName('org-address:ADDRESS_ID'),(),(), 
				cts:and-query((
					 cts:directory-query($config:RD-ORGANIZATION-ADDRESS-PATH)
					,cts:not-query(cts:element-range-query(xs:QName('org-address:ADDRESS_ID'),'<',1))
					,cts:or-query((
						$GeoRegion_Q, $Region_Q, $Country_Q, $STATE_Q, $CITY_Q
					))
				)))

		else ()
		
	return $ADDRESS_IDs
};

declare function firm-comp:GetDatesBetweenTwoDates($sYear,$eYear)
{
  if ($sYear eq $eYear) then
    $sYear
  else
    if ($sYear le $eYear) then
      let $nYear := $sYear + 1
      return ($sYear,firm-comp:GetDatesBetweenTwoDates(xs:integer($nYear),$eYear))
    else
      let $nYear := $sYear - 1
      return ($sYear,firm-comp:GetDatesBetweenTwoDates(xs:integer($nYear),$eYear))
};

(:------------ By Shubham ---------------:)

declare function firm-comp:GetLawFirmRankings($firmID,$year)
{
  let $res-array := json:array()
  let $result := cts:search(/,
                  cts:and-query((
                       cts:directory-query("/LegalCompass/relational-data/organization/"),
                       cts:element-value-query(xs:QName('organization:ORGANIZATION_ID'),fn:tokenize($firmID,','))
                       )))
  let $loopData := for $item in $result
                       let $loopData1 := for $item1 in fn:tokenize($year,',')


                       let $amLaw200Year :=  cts:search(/,
                                                cts:and-query((
                                                     cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                     cts:element-value-query(xs:QName('amlaw200:ORGANIZATION_ID'),$item//organization:ORGANIZATION_ID/text()),
                                                     cts:element-value-query(xs:QName('amlaw200:PUBLISHYEAR'),xs:string($item1))
                                                     )))
                       (:let $loopData1 := for $item1 in $amLaw200Year:)
                       
                       let $nlj250 := cts:search(/,
                                            cts:and-query((
                                                 cts:directory-query("/LegalCompass/relational-data/surveys/NLJ_250/"),
                                                 cts:element-value-query(xs:QName('nlj250:ORGANIZATION_ID'),$item//organization:ORGANIZATION_ID/text()),
                                                 cts:element-value-query(xs:QName('nlj250:PUBLISHYEAR'),xs:string($item1))
                                                 )))
                       
                       let $global100 := cts:search(/,
                                                  cts:and-query((
                                                       cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
                                                       cts:element-value-query(xs:QName('global100:ORGANIZATION_ID'),$item//organization:ORGANIZATION_ID/text()),
                                                       cts:element-value-query(xs:QName('global100:PUBLISHYEAR'),xs:string($item1))
                                                       )))
                       let $alist := cts:search(/,
                                              cts:and-query((
                                                   cts:directory-query("/LegalCompass/relational-data/surveys/ALIST/"),
                                                   cts:element-value-query(xs:QName('alist:ORGANIZATION_ID'),$item//organization:ORGANIZATION_ID/text()),
                                                   cts:element-value-query(xs:QName('alist:PUBLISHYEAR'),xs:string($item1))
                                                   )))

						let $uk50 := cts:search(/,
                                              cts:and-query((
                                                   cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
                                                   cts:element-value-query(xs:QName('uk50:ORGANIZATION_ID'),$item//organization:ORGANIZATION_ID/text()),
                                                   cts:element-value-query(xs:QName('uk50:PUBLISHYEAR'),xs:string($item1))
                                                   )))		

                        let $china40 := cts:search(/,
                                              cts:and-query((
                                                   cts:directory-query("/LegalCompass/relational-data/surveys/CHINA_40/"),
                                                   cts:element-value-query(xs:QName('china40:ORGANIZATION_ID'),$item//organization:ORGANIZATION_ID/text()),
                                                   cts:element-value-query(xs:QName('china40:PUBLISHYEAR'),xs:string($item1))
                                                   )))	

                       let $res-obj := json:object()
					   let $orgName := if($item//organization:ALM_NAME/text() ne '') then $item//organization:ALM_NAME/text() else $item//organization:ORGANIZATION_NAME/text()
                       let $revenue := if($amLaw200Year//amlaw200:GROSS_REVENUE/text() ne '') then 
                                          $amLaw200Year//amlaw200:GROSS_REVENUE/text() 
                                       else if($global100//global100:GROSS_REVENUE/text() ne '') then $global100//global100:GROSS_REVENUE/text()
                                       else $uk50//uk50:GROSS_REVENUE_DOLLAR/text()
                       
                       
                       let $noofattorney := if($amLaw200Year//amlaw200:NUM_OF_LAWYERS/text() ne '') then $amLaw200Year//amlaw200:NUM_OF_LAWYERS/text() else 
                                              if($global100//global100:NUM_LAWYERS/text() ne '') then $global100//global100:NUM_LAWYERS/text() else
                                                  if($nlj250//nlj250:NUM_ATTORNEYS/text() ne '') then $nlj250//nlj250:NUM_ATTORNEYS/text() else
                                                    if($uk50//uk50:NUMBER_OF_LAWYERS/text() ne '') then $uk50//uk50:NUMBER_OF_LAWYERS/text() else
                                                    if($china40//china40:FIRMWIDE_LAWYERS/text() ne '') then $china40//china40:FIRMWIDE_LAWYERS/text() else()
                                 let $_ := (
                                             map:put($res-obj,'YEAR',xs:string($item1)),
                                             map:put($res-obj,'FirmName',$orgName),
                                             map:put($res-obj,'FirmId',$item//organization:ORGANIZATION_ID/text()),
                                             map:put($res-obj,'GROSS_REVENUE',$amLaw200Year//amlaw200:GROSS_REVENUE/text()),
                                             map:put($res-obj,'amlaw200rank',$amLaw200Year//amlaw200:AMLAW200_RANK/text()),
                                             map:put($res-obj,'Revenue',xs:string($revenue)),
                                             map:put($res-obj,'NoofAttorneys',(:$amLaw200Year//amlaw200:NUM_OF_LAWYERS/text():)$noofattorney),
											 map:put($res-obj,'NLJ500Rank',$nlj250//nlj250:NLJ250_RANK/text()),
                                             map:put($res-obj,'AListRank',$alist//alist:ALIST_RANK/text()),
                                             map:put($res-obj,'Global100Rank',$global100//global100:RANK_BY_GROSS_REVENUE/text())
                                            )
                                 let $_ := json:array-push($res-array,$res-obj)
                                 return()
                 return()                      
   return $res-array
  
};


declare function firm-comp:SP_GETLAWFIRMREVENUEANDPROFIT($firmID,$year)
{
  let $res-array := json:array()
  let $result := cts:search(/,
                  cts:and-query((
                       cts:directory-query("/LegalCompass/relational-data/organization/"),
                       cts:element-value-query(xs:QName('organization:ORGANIZATION_ID'),fn:tokenize($firmID,','))
                       )))
  let $loopData := for $item in $result
                        let $loopData1 := for $item1 in fn:tokenize($year,',')

                        let $amLaw200Year :=  cts:search(/,
                                                cts:and-query((
                                                     cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                     cts:element-value-query(xs:QName('amlaw200:ORGANIZATION_ID'),$item//organization:ORGANIZATION_ID/text()),
                                                     cts:element-value-query(xs:QName('amlaw200:PUBLISHYEAR'),xs:string($item1))
                                                     )))
                      
                       
					              let $amLaw200Data :=  cts:search(/,
                                                cts:and-query((
                                                     cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                     cts:element-value-query(xs:QName('amlaw200:ORGANIZATION_ID'),$item//organization:ORGANIZATION_ID/text()),
                                                     cts:element-value-query(xs:QName('amlaw200:PUBLISHYEAR'),xs:string($item1))
                                                     )))
					   
                       let $nlj250 := cts:search(/,
                                            cts:and-query((
                                                 cts:directory-query("/LegalCompass/relational-data/surveys/NLJ_250/"),
                                                 cts:element-value-query(xs:QName('nlj250:ORGANIZATION_ID'),$item//organization:ORGANIZATION_ID/text()),
                                                 cts:element-value-query(xs:QName('nlj250:PUBLISHYEAR'),xs:string($item1))
                                                 )))[1]
                       
                       let $global100 := cts:search(/,
                                                  cts:and-query((
                                                       cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
                                                       cts:element-value-query(xs:QName('global100:ORGANIZATION_ID'),$item//organization:ORGANIZATION_ID/text()),
                                                       cts:element-value-query(xs:QName('global100:PUBLISHYEAR'),xs:string($item1)))))[1]
                      
                       let $uk50 := cts:search(/,
                                              cts:and-query((
                                                   cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
                                                   cts:element-value-query(xs:QName('uk50:ORGANIZATION_ID'),$item//organization:ORGANIZATION_ID/text()),
                                                   cts:element-value-query(xs:QName('uk50:PUBLISHYEAR'),xs:string($item1))
                                                   )))		

                        let $china40 := cts:search(/,
                                              cts:and-query((
                                                   cts:directory-query("/LegalCompass/relational-data/surveys/CHINA_40/"),
                                                   cts:element-value-query(xs:QName('china40:ORGANIZATION_ID'),$item//organization:ORGANIZATION_ID/text()),
                                                   cts:element-value-query(xs:QName('china40:PUBLISHYEAR'),xs:string($item1))
                                                   )))
					   
					              let $res-obj := json:object()

                        let $revenue := if($amLaw200Data//amlaw200:GROSS_REVENUE/text() != '') then 
                                          $amLaw200Data//amlaw200:GROSS_REVENUE/text() 
                                       else if($global100//global100:GROSS_REVENUE/text() != '') then $global100//global100:GROSS_REVENUE/text()
                                       else $uk50//uk50:GROSS_REVENUE_DOLLAR/text()

                       (:let $revenue := if($amLaw200Year//amlaw200:GROSS_REVENUE/text() ne '') then $amLaw200Year//amlaw200:GROSS_REVENUE/text() else $global100//global100:GROSS_REVENUE/text():)
                       let $revenuePL := if($amLaw200Data//amlaw200:RPL/text() ne '') then $amLaw200Data//amlaw200:RPL/text() else
                                            if($global100//global100:REVENUE_PER_LAWYER/text() != '') then $global100//global100:REVENUE_PER_LAWYER/text() else
                                            if($uk50//uk50:RPL_DOLLAR/text() ne '') then $uk50//uk50:RPL_DOLLAR/text() else
                                                if($china40//china40:REVENUE_PER_LAWYER/text() ne '') then $china40//china40:REVENUE_PER_LAWYER/text() else json:null()

                       let $rankbygrossrev := if($amLaw200Data//amlaw200:AMLAW200_RANK/text() ne '') then $amLaw200Data//amlaw200:AMLAW200_RANK/text() else $global100//global100:RANK_BY_GROSS_REVENUE/text()
                       let $rpl := if($revenuePL ne '') then xs:integer($revenuePL) else json:null()
                       let $grossRevenue := if($revenue ne '') then xs:integer($revenue) else json:null()
                       let $rbgr := if($rankbygrossrev ne '') then xs:integer($rankbygrossrev) else json:null()
					   let $orgName := if($item//organization:ALM_NAME/text() ne '') then $item//organization:ALM_NAME/text() else $item//organization:ORGANIZATION_NAME/text()
					   let $ppp := if($amLaw200Data//amlaw200:PPP/text()ne '') then xs:integer($amLaw200Data//amlaw200:PPP/text()) 
                         else if($global100//global100:PPP/text() != '') then $global100//global100:PPP/text() else
					   					   if($uk50//uk50:PPP_DOLLAR/text()ne '') then xs:integer($uk50//uk50:PPP_DOLLAR/text()) else json:null()
						
						
										   	

					   let $costPerLawyer :=if($amLaw200Data//amlaw200:NUM_OF_LAWYERS/text() ne '') then ($amLaw200Data//amlaw200:GROSS_REVENUE/text() - $amLaw200Data//amlaw200:NET_OPERATING_INCOME/text()) div $amLaw200Data//amlaw200:NUM_OF_LAWYERS/text() else 0
             
             let $cplByGlobal100 := if($global100//global100:GROSS_REVENUE/text() != '') then fn:round-half-to-even(($global100//global100:GROSS_REVENUE/text() - ($global100//global100:PPP/text() * $global100//global100:NUM_EQUITY_PARTNERS/text())) div $global100//global100:NUM_LAWYERS/text(),0) else 0

             let $cplByUk50 := if($uk50//uk50:NUMBER_OF_LAWYERS/text() ne '') then fn:round-half-to-even(($uk50//uk50:GROSS_REVENUE_DOLLAR/text() - ($uk50//uk50:PPP_DOLLAR/text() * $uk50//uk50:NUMBER_OF_EQ_PARTNERS/text())) div $uk50//uk50:NUMBER_OF_LAWYERS/text() ,2) else()

					   let $cpl := if($costPerLawyer ne 0) then $costPerLawyer else 
                            if($cplByGlobal100 ne 0) then $cplByGlobal100
                               else $cplByUk50

             let $netOperatingIncomeAmLaw := $amLaw200Data//amlaw200:NUM_EQ_PARTNERS/text() * $amLaw200Data//amlaw200:PPP/text()
             let $netOperatingIncomeGlobal100 := $global100//global100:PPP/text() * $global100//global100:NUM_EQUITY_PARTNERS/text()                
             let $netOperatingIncomeUk50 := $uk50//uk50:PPP_DOLLAR/text() * $uk50//uk50:NUMBER_OF_EQ_PARTNERS/text()                
             let $netOperatingIncome := if(xs:string($netOperatingIncomeAmLaw) ne '') then $netOperatingIncomeAmLaw
                                        else if(xs:string($netOperatingIncomeGlobal100) ne '') then $netOperatingIncomeGlobal100
                                              else if(xs:string($netOperatingIncomeUk50) ne '') then $netOperatingIncomeUk50 else json:null()

             let $ppl := if($amLaw200Data//amlaw200:NUM_OF_LAWYERS/text() ne '') then fn:round-half-to-even(($amLaw200Data//amlaw200:PPP/text() * $amLaw200Data//amlaw200:NUM_EQ_PARTNERS/text()) div $amLaw200Data//amlaw200:NUM_OF_LAWYERS/text(),0) else 
                          if($global100//global100:NUM_LAWYERS/text() != '') then ($global100//global100:PPP/text() * $global100//global100:NUM_EQUITY_PARTNERS/text()) div $global100//global100:NUM_LAWYERS/text() else 
					   					    if($uk50//uk50:PPL_DOLLAR/text() ne '') then fn:round-half-to-even($uk50//uk50:PPL_DOLLAR/text() , 0) else 
										   	  if($china40//china40:PROFITS_PER_PARTNER/text() ne '') then xs:integer($china40//china40:PROFITS_PER_PARTNER/text()) else json:null()
                                 let $_ := (
                                             map:put($res-obj,'GrossRevenue',$grossRevenue),
											                       map:put($res-obj,'CostPerLawyer',$cpl),
                                             map:put($res-obj,'RevenuePerLawyer',$rpl),
                                             map:put($res-obj,'NetOperatingIncome',$netOperatingIncome),
                                             map:put($res-obj,'ProfitPerPartner',$ppp),
                                             map:put($res-obj,'CompansationAvgPartner',if($amLaw200Data//amlaw200:CAP/text() ne '') then xs:integer($amLaw200Data//amlaw200:CAP/text()) else json:null()),
                                             map:put($res-obj,'CompNonEQPartner',if($amLaw200Data//amlaw200:COMP_NON_EQ_PARTNERS/text() ne '') then xs:integer($amLaw200Data//amlaw200:COMP_NON_EQ_PARTNERS/text()) else json:null()),
                                             map:put($res-obj,'FirstYearSalary',if($nlj250//nlj250:FIRST_YEAR_SALARY/text() ne '') then $nlj250//nlj250:FIRST_YEAR_SALARY/text() else json:null()),
                                             map:put($res-obj,'API',if($amLaw200Data//amlaw200:API/text() ne '') then xs:double($amLaw200Data//amlaw200:API/text()) else 0),
                                             map:put($res-obj,'RankByGrossRevenue',$rbgr),
                                             map:put($res-obj,'RankByRPL',if($amLaw200Data//amlaw200:RANK_BY_RPL/text() ne '') then xs:integer($amLaw200Data//amlaw200:RANK_BY_RPL/text()) else 0),
                                             map:put($res-obj,'RankByCAP',if($amLaw200Data//amlaw200:RANK_BY_CAP/text() ne '') then xs:integer($amLaw200Data//amlaw200:RANK_BY_CAP/text()) else 0),
                                             map:put($res-obj,'RankByAPI',if($amLaw200Data//amlaw200:RANK_BY_API/text() ne '') then xs:integer($amLaw200Data//amlaw200:RANK_BY_API/text()) else 0),
                                             map:put($res-obj,'RankByPPP',if($amLaw200Data//amlaw200:RANK_BY_PPP/text() ne '') then xs:integer($amLaw200Data//amlaw200:RANK_BY_PPP/text()) else 0),
                                             map:put($res-obj,'LawyerPer10M',if($amLaw200Data//amlaw200:LAWYERS_10M/text() ne '') then xs:integer(fn:ceiling($amLaw200Data//amlaw200:LAWYERS_10M/text())) else 0),
                                             map:put($res-obj,'ValuePerLawyer',if($amLaw200Data//amlaw200:VPL/text() ne '') then xs:integer($amLaw200Data//amlaw200:VPL/text()) else json:null()),
                                             map:put($res-obj,'ProfitPerLawyer',$ppl),
                                             map:put($res-obj,'publishyear',xs:integer($item1)),
                                             map:put($res-obj,'OrganizationName',$orgName),
                                             map:put($res-obj,'OrganizationID',$item//organization:ORGANIZATION_ID/text()),
                                             map:put($res-obj,'YEAR',if($amLaw200Data//amlaw200:PUBLISHYEAR/text() ne '') then xs:integer($amLaw200Data//amlaw200:PUBLISHYEAR/text()) else 0)
                                            )
                                 let $_ := json:array-push($res-array,$res-obj)
                                 return()
                 return()                      
   return $res-array
  
};

declare function firm-comp:SP_GETLAWFIRMDIVERSITY($firmID,$year)
{
  let $res-array := json:array()
  let $result := cts:search(/,
                  cts:and-query((
                       cts:directory-query("/LegalCompass/relational-data/organization/"),
                       cts:element-value-query(xs:QName('organization:ORGANIZATION_ID'),fn:tokenize($firmID,','))
                       )))
  let $loopData := for $item in $result
                       
                       let $amLaw200Year :=  cts:search(/,
                                                cts:and-query((
                                                     cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                     cts:element-value-query(xs:QName('amlaw200:ORGANIZATION_ID'),$item//organization:ORGANIZATION_ID/text()),
                                                     cts:element-value-query(xs:QName('amlaw200:PUBLISHYEAR'),fn:tokenize($year,','))
                                                     )))
                       let $loopData1 := for $item1 in $amLaw200Year
                       
                       let $diversityScoreBoard := cts:search(/,
                                                      cts:and-query((
                                                      cts:directory-query("/LegalCompass/relational-data/surveys/Diversity_Scorecard/"),
                                                      cts:element-value-query(xs:QName('diversity:ORGANIZATION_ID'),$item//organization:ORGANIZATION_ID/text()),
                                                      cts:element-value-query(xs:QName('diversity:PUBLISHYEAR'),$item1//amlaw200:PUBLISHYEAR/text())
                                                      )))
                      let $femaleScoreBoard := cts:search(/,
                                                      cts:and-query((
                                                      cts:directory-query("/LegalCompass/relational-data/surveys/FEMALE_SCORECARD/"),
                                                      cts:element-value-query(xs:QName('femalesb:ORGANIZATION_ID'),$item//organization:ORGANIZATION_ID/text()),
                                                      cts:element-value-query(xs:QName('femalesb:PUBLISHYEAR'),$item1//amlaw200:PUBLISHYEAR/text())
                                                      )))                                
                      
                       let $res-obj := json:object()
                       let $orgName := if($item//organization:ALM_NAME/text() ne '') then $item//organization:ALM_NAME/text() else $item//organization:ORGANIZATION_NAME/text()
					   
					   let $pctFemalePartner := xs:double($femaleScoreBoard//femalesb:PCT_FEMALE_PARTNERS/text()) * 100
					   let $pctFemaleAttorney := xs:double($femaleScoreBoard//femalesb:PCT_FEMALE_ATTORNEYS/text()) * 100
					   
                       let $minorityPercentage := fn:concat(xs:double($diversityScoreBoard//diversity:MINORITY_PERCENTAGE/text())*100,'%')
                                 let $_ := (
                                             map:put($res-obj,'TotalAttorneys',$diversityScoreBoard//diversity:TOTAL_ATTORNEYS/text()),
                                             map:put($res-obj,'TotalFemaleAttorneys',$femaleScoreBoard//femalesb:FEMALE_ATTORNEYS/text()),
											 map:put($res-obj,'PctFemalePartners',fn:concat($pctFemalePartner,'%')),
                                             map:put($res-obj,'PctFemaleAttorneys',fn:concat($pctFemaleAttorney,'%')),
                                             map:put($res-obj,'FemaleAssociates',if($femaleScoreBoard//femalesb:FEMALE_ASSOCIATES/text() ne '') then xs:integer(fn:round($femaleScoreBoard//femalesb:FEMALE_ASSOCIATES/text())) else 0),
                                             map:put($res-obj,'FemalePartners',if($femaleScoreBoard//femalesb:FEMALE_PARTNERS/text() ne '') then xs:integer(fn:round($femaleScoreBoard//femalesb:FEMALE_PARTNERS/text())) else 0),
                                             map:put($res-obj,'TotalMinorityAttorneys',if($diversityScoreBoard//diversity:TOTAL_MINORITY_ATTORNEYS/text() ne '') then xs:integer($diversityScoreBoard//diversity:TOTAL_MINORITY_ATTORNEYS/text()) else 0),
                                             map:put($res-obj,'MinorityPercentage',$minorityPercentage),
                                             map:put($res-obj,'AsianAmericanAssociates',if($diversityScoreBoard//diversity:ASIAN_AMERICAN_ASSOCIATES/text() ne '') then xs:integer($diversityScoreBoard//diversity:ASIAN_AMERICAN_ASSOCIATES/text()) else 0),
                                             map:put($res-obj,'AsianAmericanPartners',if($diversityScoreBoard//diversity:ASIAN_AMERICAN_PARTNERS/text() ne '') then xs:integer($diversityScoreBoard//diversity:ASIAN_AMERICAN_PARTNERS/text()) else 0),
                                             map:put($res-obj,'AfricanAmericanAssociates',if($diversityScoreBoard//diversity:AFRICAN_AMERICAN_ASSOCIATES/text() ne '') then xs:integer($diversityScoreBoard//diversity:AFRICAN_AMERICAN_ASSOCIATES/text()) else 0),
                                             map:put($res-obj,'AfricanAmericanPartners',if($diversityScoreBoard//diversity:AFRICAN_AMERICAN_PARTNERS/text() ne '') then xs:integer($diversityScoreBoard//diversity:AFRICAN_AMERICAN_PARTNERS/text()) else 0),
                                             map:put($res-obj,'HispanicAssociates',if($diversityScoreBoard//diversity:HISPANIC_ASSOCIATES/text() ne '') then xs:integer($diversityScoreBoard//diversity:HISPANIC_ASSOCIATES/text()) else 0),
                                             map:put($res-obj,'HispanicPartners',if($diversityScoreBoard//diversity:HISPANIC_PARTNERS/text() ne '') then xs:integer($diversityScoreBoard//diversity:HISPANIC_PARTNERS/text()) else 0),
                                             map:put($res-obj,'OtherNonPartners',if($diversityScoreBoard//diversity:OTHER_NONPARTNERS/text() ne '') then xs:integer($diversityScoreBoard//diversity:OTHER_NONPARTNERS/text()) else 0),
                                             map:put($res-obj,'OtherPartners',if($diversityScoreBoard//diversity:OTHER_PARTNERS/text() ne '') then xs:integer($diversityScoreBoard//diversity:OTHER_PARTNERS/text()) else 0),
                                             map:put($res-obj,'DiversityRank',if($diversityScoreBoard//diversity:DIVERSITY_RANK/text() ne '') then xs:integer($diversityScoreBoard//diversity:DIVERSITY_RANK/text()) else 0),
                                             map:put($res-obj,'DiversityScore',if($diversityScoreBoard//diversity:DIVERSITY_SCORE/text() ne '') then xs:integer(fn:round($diversityScoreBoard//diversity:DIVERSITY_SCORE/text())) else 0),
                                             map:put($res-obj,'DiversityEquityPartners',if($diversityScoreBoard//diversity:DIVERSITY_EQUITY_PARTNERS/text() ne '') then xs:integer($diversityScoreBoard//diversity:DIVERSITY_EQUITY_PARTNERS/text()) else 0),
                                             map:put($res-obj,'DiversityNonEquityPartners',if($diversityScoreBoard//diversity:DIVERSITY_NON_EQUITY_PARTNERS/text() ne '') then xs:integer($diversityScoreBoard//diversity:DIVERSITY_NON_EQUITY_PARTNERS/text()) else 0),
                                             map:put($res-obj,'DiversityAssociates',if($diversityScoreBoard//diversity:DIVERSITY_ASSOCIATES/text() ne '') then xs:integer($diversityScoreBoard//diversity:DIVERSITY_ASSOCIATES/text()) else 0),
                                             map:put($res-obj,'DiversityOtherAttorneys',if($diversityScoreBoard//diversity:DIVERSITY_OTHER_ATTORNEYS/text() ne '') then xs:integer($diversityScoreBoard//diversity:DIVERSITY_OTHER_ATTORNEYS/text()) else 0),
                                             map:put($res-obj,'publishyear',if($item1//amlaw200:PUBLISHYEAR/text() ne '') then xs:integer($item1//amlaw200:PUBLISHYEAR/text()) else 0),
                                             map:put($res-obj,'OrganizationName',$orgName),
                                             map:put($res-obj,'OrganizationID',if($item//organization:ORGANIZATION_ID/text() ne '') then xs:integer($item//organization:ORGANIZATION_ID/text()) else 0),
                                             map:put($res-obj,'YEAR',if($item1//amlaw200:PUBLISHYEAR/text() ne '') then xs:integer($item1//amlaw200:PUBLISHYEAR/text()) else 0)
                                            )
                                 let $_ := json:array-push($res-array,$res-obj)
                                 return()
                 return()                      
   return $res-array
  
};

declare function firm-comp:SP_GETLAWFIRMSIZE($firmID,$year)
{
  let $res-array := json:array()
  let $result := cts:search(/,
                  cts:and-query((
                       cts:directory-query("/LegalCompass/relational-data/organization/"),
                       cts:element-value-query(xs:QName('organization:ORGANIZATION_ID'),fn:tokenize($firmID,','))
                       )))
  let $loopData := for $item in $result
                      (:for $i in fn:tokenize($year,',') :)
                      let $loopData1 := for $item1 in fn:tokenize($year,',')
                                    let $amLaw200Year :=  cts:search(/,
                                                              cts:and-query((
                                                                  cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                                  cts:element-value-query(xs:QName('amlaw200:ORGANIZATION_ID'),$item//organization:ORGANIZATION_ID/text()),
                                                                  cts:element-value-query(xs:QName('amlaw200:PUBLISHYEAR'),xs:string($item1))
                                                                  )))
                                    
                                    
                                    let $diversityScoreBoard := cts:search(/,
                                                                    cts:and-query((
                                                                    cts:directory-query("/LegalCompass/relational-data/surveys/Diversity_Scorecard/"),
                                                                    cts:element-value-query(xs:QName('diversity:ORGANIZATION_ID'),$item//organization:ORGANIZATION_ID/text()),
                                                                    cts:element-value-query(xs:QName('diversity:PUBLISHYEAR'),xs:string($item1))
                                                                    )))
                                    let $femaleScoreBoard := cts:search(/,
                                                                    cts:and-query((
                                                                    cts:directory-query("/LegalCompass/relational-data/surveys/FEMALE_SCORECARD/"),
                                                                    cts:element-value-query(xs:QName('femalesb:ORGANIZATION_ID'),$item//organization:ORGANIZATION_ID/text()),
                                                                    cts:element-value-query(xs:QName('femalesb:PUBLISHYEAR'),xs:string($item1))
                                                                    )))                                
                                    
                                    let $nlj250 := cts:search(/,
                                                          cts:and-query((
                                                              cts:directory-query("/LegalCompass/relational-data/surveys/NLJ_250/"),
                                                              cts:element-value-query(xs:QName('nlj250:ORGANIZATION_ID'),$item//organization:ORGANIZATION_ID/text()),
                                                              cts:element-value-query(xs:QName('nlj250:PUBLISHYEAR'),xs:string($item1))
                                                              )))
                                                              
                                    let $ny100 := cts:search(/,
                                                          cts:and-query((
                                                              cts:directory-query("/LegalCompass/relational-data/surveys/NY100/"),
                                                              cts:element-value-query(xs:QName('ny100:ORGANIZATION_ID'),$item//organization:ORGANIZATION_ID/text()),
                                                              cts:element-value-query(xs:QName('ny100:PUBLISHYEAR'),xs:string($item1))
                                                              )))
                                      
                                    let $global100 := cts:search(/,
                                                                cts:and-query((
                                                                    cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
                                                                    cts:element-value-query(xs:QName('global100:ORGANIZATION_ID'),$item//organization:ORGANIZATION_ID/text()),
                                                                    cts:element-value-query(xs:QName('global100:PUBLISHYEAR'),xs:string($item1)))))[1]
                                    
                                     let $uk50 := cts:search(/,
                                                            cts:and-query((
                                                                cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
                                                                cts:element-value-query(xs:QName('uk50:ORGANIZATION_ID'),$item//organization:ORGANIZATION_ID/text()),
                                                                cts:element-value-query(xs:QName('uk50:PUBLISHYEAR'),xs:string($item1))
                                                                )))		

                                    let $res-obj := json:object()
                                    let $revenue := if($amLaw200Year//amlaw200:GROSS_REVENUE/text() ne '') then $amLaw200Year//amlaw200:GROSS_REVENUE/text() else $global100//global100:GROSS_REVENUE/text()
                                    let $revenuePL := if($amLaw200Year//amlaw200:RPL/text() ne '') then $amLaw200Year//amlaw200:RPL/text() else $global100//global100:RPL/text()
                                    let $rankbygrossrev := if($amLaw200Year//amlaw200:AMLAW200_RANK/text() ne '') then $amLaw200Year//amlaw200:AMLAW200_RANK/text() else $global100//global100:RANK_BY_GROSS_REVENUE/text()
                                    let $rpl := if($revenuePL ne '') then xs:integer($revenuePL) else 0

                                    let $grossRevenue := if($revenue ne '') then xs:integer($revenue) else 0

                                    let $orgName := if($item//organization:ALM_NAME/text() ne '') then $item//organization:ALM_NAME/text() else $item//organization:ORGANIZATION_NAME/text()
                                    let $rbgr := if($rankbygrossrev ne '') then xs:integer($rankbygrossrev) else 0
                                    let $diffResult := (xs:integer($nlj250//nlj250:NUM_PARTNERS/text()) - xs:integer($nlj250//nlj250:NUM_NE_PARTNERS/text()))

                                    let $leverage :=if($diffResult ne 0) then xs:integer($nlj250//nlj250:NUM_ASSOCIATES/text()) div $diffResult else 
                                            if($amLaw200Year//amlaw200:LEVERAGE/text() ne '') then $amLaw200Year//amlaw200:LEVERAGE/text() else
											if($uk50 ne '') then $uk50//uk50:LEVERAGE/text() else()
                                               
									let $noOflawyers :=if($amLaw200Year//amlaw200:NUM_OF_LAWYERS/text() ne '') then $amLaw200Year//amlaw200:NUM_OF_LAWYERS/text() else 
                                              if($global100//global100:NUM_LAWYERS/text() ne '') then $global100//global100:NUM_LAWYERS/text() else
                                                  
                                                    if($uk50//uk50:NUMBER_OF_LAWYERS/text() ne '') then $uk50//uk50:NUMBER_OF_LAWYERS/text() else()
                                                    
                                    
                                              let $_ := (
                                    map:put($res-obj,'NumberOfAttornies',$nlj250//nlj250:NUM_ATTORNEYS/text()),
                                    map:put($res-obj,'Leverage',$leverage),
                                    map:put($res-obj,'NumberofEQPartners',if($nlj250//nlj250:EQUITY_PARTNERS/text() ne '') then xs:integer($nlj250//nlj250:EQUITY_PARTNERS/text()) else 0),
                                                          map:put($res-obj,'NumberofLawyers',$noOflawyers),
                                                          map:put($res-obj,'NumberOfPartners',if($nlj250//nlj250:NUM_PARTNERS/text() ne '') then xs:integer($nlj250//nlj250:NUM_PARTNERS/text()) else 0),
                                                          map:put($res-obj,'TotalPartners',if($amLaw200Year//amlaw200:TOTAL_PARTNERS/text() ne '') then xs:integer($amLaw200Year//amlaw200:TOTAL_PARTNERS/text()) else 0),
                                                          map:put($res-obj,'NumberofNonEQPartners',if($nlj250//nlj250:NUM_NE_PARTNERS/text() ne '') then xs:integer($nlj250//nlj250:NUM_NE_PARTNERS/text()) else 0),
                                                          map:put($res-obj,'NumberOfAssociates',if($nlj250//nlj250:NUM_ASSOCIATES/text() ne '') then xs:integer($nlj250//nlj250:NUM_ASSOCIATES/text()) else 0),
                                                          map:put($res-obj,'NumberofOtherAttornies',if($nlj250//nlj250:NUM_OTHER_ATTORNEYS/text() ne '') then xs:integer($nlj250//nlj250:NUM_OTHER_ATTORNEYS/text()) else 0),
                                                          map:put($res-obj,'NumberofCountriesOffices',if($global100//global100:NUM_COUNTRIES_WITH_OFFICES/text() ne '') then xs:integer($global100//global100:NUM_COUNTRIES_WITH_OFFICES/text()) else 0),
                                                          map:put($res-obj,'LawyerOutsideHomeCoun',if($global100//global100:LAWYERS_OUTSIDE_HOME_COUNTRY/text() ne '') then xs:integer($global100//global100:LAWYERS_OUTSIDE_HOME_COUNTRY/text()) else 0),
                                                          map:put($res-obj,'RankByNoOfLawyers',if($global100//global100:RANK_BY_NUM_LAWYERS/text() ne '') then xs:integer($global100//global100:RANK_BY_NUM_LAWYERS/text()) else 0),
                                                          map:put($res-obj,'NLJ250Rank',if($nlj250//nlj250:NLJ250_RANK/text() ne '') then xs:integer($nlj250//nlj250:NLJ250_RANK/text()) else 0),
                                                          map:put($res-obj,'NY100Rank',if($ny100//ny100:NY100_RANK/text() ne '') then xs:integer($ny100//ny100:NY100_RANK/text()) else 0),
                                                          
                                                          map:put($res-obj,'publishyear',xs:string($item1)),
                                                          map:put($res-obj,'OrganizationName',$orgName),
                                                          map:put($res-obj,'OrganizationID',if($item//organization:ORGANIZATION_ID/text() ne '') then xs:integer($item//organization:ORGANIZATION_ID/text()) else 0),
                                                          map:put($res-obj,'Year',xs:string($item1))
                                    
                                    
                                                          )
                                              let $_ := json:array-push($res-array,$res-obj)
                                              return()
                              return()                      
   return $res-array
  
};

(: declare function firm-comp:SP_GETLAWFIRMASSOCIATENATL($firmID,$year)
{
  let $res-array := json:array()
  let $result := cts:search(/,
                  cts:and-query((
                       cts:directory-query("/LegalCompass/relational-data/organization/"),
                       cts:element-value-query(xs:QName('organization:ORGANIZATION_ID'),fn:tokenize($firmID,','))
                       )))
  let $loopData := for $item in $result
                       for $i in fn:tokenize($year,',')
                         let $associateNATL :=  cts:search(/,
                                                  cts:and-query((
                                                       cts:directory-query("/LegalCompass/relational-data/surveys/Associate_natl/"),
                                                       cts:element-value-query(xs:QName('associatenatl:FIRM_ID'),$item//organization:ORGANIZATION_ID/text()),
                                                       cts:element-value-query(xs:QName('associatenatl:PUBLISHYEAR'),xs:string($i))
                                                       )))
                       let $loopData1 := for $item1 in $associateNATL
                       
                      
                       let $res-obj := json:object()
                      
                      let $_ := (map:put($res-obj,'LOCATION',$associateNATL//associatenatl:LOCATION/text()),
                                map:put($res-obj,'RANK',$associateNATL//associatenatl:RANK/text()),
                                map:put($res-obj,'OverallScore',$associateNATL//associatenatl:OVERALL_SCORE/text()),
                                map:put($res-obj,'RespondentPercentage',$associateNATL//associatenatl:RESPONDENT_PERCENTAGE/text()),
                                map:put($res-obj,'OrganizationName',$item//organization:ORGANIZATION_NAME/text()),
                                map:put($res-obj,'OrganizationID',$item//organization:ORGANIZATION_ID/text()),
								map:put($res-obj,'Year',xs:string($i)))
                                 let $_ := json:array-push($res-array,$res-obj)
                                 return()
                 return()                      
   return $res-array
  
}; :)

declare function firm-comp:SP_GETLAWFIRMASSOCIATENATL($firmID,$year)
{
  let $res-array := json:array()
  let $result := cts:search(/,
                  cts:and-query((
                       cts:directory-query("/LegalCompass/relational-data/organization/"),
                       cts:element-value-query(xs:QName('organization:ORGANIZATION_ID'),fn:tokenize($firmID,','))
                       )))
  let $loopData := for $item in $result
                       for $i in fn:tokenize($year,',')
                         let $associateNATL :=  cts:search(/,
                                                  cts:and-query((
                                                       cts:directory-query("/LegalCompass/relational-data/surveys/Associate_natl/"),
                                                       cts:element-value-query(xs:QName('associatenatl:FIRM_ID'),$item//organization:ORGANIZATION_ID/text()),
                                                       cts:element-value-query(xs:QName('associatenatl:PUBLISHYEAR'),xs:string($i))
                                                       )))
                       let $loopData1 := for $item1 in $associateNATL
                       
                      
                       let $res-obj := json:object()
                      
                      let $_ := (map:put($res-obj,'LOCATION',$associateNATL//associatenatl:LOCATION/text()),
                                map:put($res-obj,'RANK',$associateNATL//associatenatl:RANK/text()),
                                map:put($res-obj,'OverallScore',$associateNATL//associatenatl:OVERALL_SCORE/text()),
                                map:put($res-obj,'RespondentPercentage',fn:concat(xs:double($associateNATL//associatenatl:RESPONDENT_PERCENTAGE/text()) * 100 ,'%')),
                                map:put($res-obj,'OrganizationName',$item//organization:ORGANIZATION_NAME/text()),
                                map:put($res-obj,'OrganizationID',$item//organization:ORGANIZATION_ID/text()),
								map:put($res-obj,'Year',xs:string($i)))
                                 let $_ := json:array-push($res-array,$res-obj)
                                 return()
                 return()                      
   return $res-array
  
};

declare function firm-comp:SP_GETLAWFIRMASSOCIATEBILLING($firmID,$year)
{
  let $res-array := json:array()
  let $result := cts:search(/,
                  cts:and-query((
                       cts:directory-query("/LegalCompass/relational-data/organization/"),
                       cts:element-value-query(xs:QName('organization:ORGANIZATION_ID'),fn:tokenize($firmID,','))
                       )))
  let $loopData := for $item in $result
                     for $i in fn:tokenize($year,',')  
                       let $associateClass :=  cts:search(/,
                                                cts:and-query((
                                                     cts:directory-query("/LegalCompass/relational-data/surveys/ASSOCIATE_CLASS_BILLING_SURVEY/"),
                                                     cts:element-value-query(xs:QName('associateclass:ORGANIZATION_ID'),$item//organization:ORGANIZATION_ID/text()),
                                                     cts:element-value-query(xs:QName('associateclass:FISCAL_YEAR'),$i)
                                                     )))
                       let $loopData1 := for $item1 in $associateClass
                       
                      
                       let $res-obj := json:object()
                      let $orgName := if($item//organization:ALM_NAME/text() ne '') then $item//organization:ALM_NAME/text() else $item//organization:ORGANIZATION_NAME/text()
                      let $_ :=(map:put($res-obj,'FiscalYear',$associateClass//associateclass:FISCAL_YEAR/text()),
                                map:put($res-obj,'OrganizationID',$item//organization:ORGANIZATION_ID/text()),
                                map:put($res-obj,'OrganizationName',$orgName),
                                map:put($res-obj,'PrincipleOrLargest',$associateClass//associateclass:PRINCIPLE_OR_LARGEST/text()),
                                map:put($res-obj,'FirstYear',$associateClass//associateclass:FIRST_YEAR/text()),
                                map:put($res-obj,'SecondYear',$associateClass//associateclass:SECOND_YEAR/text()),
                                map:put($res-obj,'ThirdYear',$associateClass//associateclass:THIRD_YEAR/text()),
                                map:put($res-obj,'FourthYear',$associateClass//associateclass:FOURTH_YEAR/text()),
                                map:put($res-obj,'FifthYear',$associateClass//associateclass:FIFTH_YEAR/text()),
                                map:put($res-obj,'SixthYear',$associateClass//associateclass:SIXTH_YEAR/text()),
                                map:put($res-obj,'SeventhYear',$associateClass//associateclass:SEVENTH_YEAR/text()),
                                map:put($res-obj,'EightYear',$associateClass//associateclass:EIGHT_YEAR/text()),
                                map:put($res-obj,'NLJBillingSource',$associateClass//associateclass:NLJ_BILLING_SOURCE/text()),
                                map:put($res-obj,'YEAR',$associateClass//associateclass:FISCAL_YEAR/text()))
                                 let $_ := json:array-push($res-array,$res-obj)
                                 return()
                 return()                      
   return $res-array
  
};

declare function firm-comp:SP_GETLAWFIRMALIST($firmID,$year)
{
  let $res-array := json:array()
  let $result := cts:search(/,
                  cts:and-query((
                       cts:directory-query("/LegalCompass/relational-data/organization/"),
                       cts:element-value-query(xs:QName('organization:ORGANIZATION_ID'),fn:tokenize($firmID,','))
                       )))
  let $loopData := for $item in $result
                      for $i in fn:tokenize($year,',') 
                       let $aList :=  cts:search(/,
                                                cts:and-query((
                                                     cts:directory-query("/LegalCompass/relational-data/surveys/ALIST/"),
                                                     cts:element-value-query(xs:QName('alist:ORGANIZATION_ID'),$item//organization:ORGANIZATION_ID/text()),
                                                     cts:element-value-query(xs:QName('alist:PUBLISHYEAR'),$i)
                                                     )))
                       let $loopData1 := for $item1 in $aList
                       
                      
                       let $res-obj := json:object()
                       let $orgName := if($item//organization:ALM_NAME/text() ne '') then $item//organization:ALM_NAME/text() else $item//organization:ORGANIZATION_NAME/text()
                       let $_ :=( map:put($res-obj,'AListRank',$aList//alist:ALIST_RANK/text()),
                                  map:put($res-obj,'OverallScore',$aList//alist:OVERALL_SCORE/text()),
                                  map:put($res-obj,'publishyear',$aList//alist:PUBLISHYEAR/text()),
                                  map:put($res-obj,'OrganizationName',$orgName),
                                  map:put($res-obj,'OrganizationID',$item//organization:ORGANIZATION_ID/text()),
                                  map:put($res-obj,'YEAR',$aList//alist:PUBLISHYEAR/text()))
                                 let $_ := json:array-push($res-array,$res-obj)
                                 return()
                 return()                      
   return $res-array
  
};

declare function firm-comp:SP_GETLAWFIRMTECHRANKING($firmID,$year)
{
  let $res-array := json:array()
  let $result := cts:search(/,
                  cts:and-query((
                       cts:directory-query("/LegalCompass/relational-data/organization/"),
                       cts:element-value-query(xs:QName('organization:ORGANIZATION_ID'),fn:tokenize($firmID,','))
                       )))
  let $loopData := for $item in $result
                      for $i in fn:tokenize($year,',') 
                       let $techScoreCard :=  cts:search(/,
                                                cts:and-query((
                                                     cts:directory-query("/LegalCompass/relational-data/surveys/Tech_Scorecard/"),
                                                     cts:element-value-query(xs:QName('techscore:ORGANIZATION_ID'),$item//organization:ORGANIZATION_ID/text()),
                                                     cts:element-value-query(xs:QName('techscore:PUBLISHYEAR'),$i)
                                                     )))
                       let $loopData1 := for $item1 in $techScoreCard
                       
                      
                       let $res-obj := json:object()
                       let $orgName := if($item//organization:ALM_NAME/text() ne '') then $item//organization:ALM_NAME/text() else $item//organization:ORGANIZATION_ID/text()
                       let $_ :=( map:put($res-obj,'TechnologyRank',$techScoreCard//techscore:TECHNOLOGY_RANK/text()),
                                  map:put($res-obj,'MidlevelSurveyRank',$techScoreCard//techscore:MIDLEVEL_SURVEY_RANK/text()),
                                  map:put($res-obj,'TotalRespondents',$techScoreCard//techscore:TOTAL_RESPONDENTS/text()),
                                  map:put($res-obj,'FirmsTechnologyScore',$techScoreCard//techscore:FIRMS_TECHNOLOGY_SCORE/text()),
                                  map:put($res-obj,'TrainingScore',$techScoreCard//techscore:TRAINING_SCORE/text()),
                                  map:put($res-obj,'SupportScore',$techScoreCard//techscore:SUPPORT_SCORE/text()),
                                  map:put($res-obj,'HelpingClientsScore',$techScoreCard//techscore:HELPING_CLIENTS_SCORE/text()),
                                  map:put($res-obj,'CompositeScore',$techScoreCard//techscore:COMPOSITE_SCORE/text()),
                                  map:put($res-obj,'BillableHours',$techScoreCard//techscore:BILLABLE_HOURS/text()),
                                  map:put($res-obj,'spam_block',$techScoreCard//techscore:SPAM_BLOCK/text()),
                                  map:put($res-obj,'publishyear',$techScoreCard//techscore:PUBLISHYEAR/text()),
                                  map:put($res-obj,'OrganizationName',$orgName),
                                  map:put($res-obj,'OrganizationID',$item//organization:ORGANIZATION_ID/text()),
                                  map:put($res-obj,'YEAR',$techScoreCard//techscore:PUBLISHYEAR/text())
                                  )
                                 let $_ := json:array-push($res-array,$res-obj)
                                 return()
                 return()                      
   return $res-array
  
};

(: declare function firm-comp:SP_GETLAWFIRMPROBONO($firmID,$year)
{
  let $res-array := json:array()
  let $result := cts:search(/,
                  cts:and-query((
                       cts:directory-query("/LegalCompass/relational-data/organization/"),
                       cts:element-value-query(xs:QName('organization:ORGANIZATION_ID'),fn:tokenize($firmID,','))
                       )))
  let $loopData := for $item in $result
                     for $i in fn:tokenize($year,',')  
                       let $probono :=  cts:search(/,
                                                cts:and-query((
                                                     cts:directory-query("/LegalCompass/relational-data/surveys/Pro_Bono/"),
                                                     cts:element-value-query(xs:QName('prob:ORGANIZATION_ID'),$item//organization:ORGANIZATION_ID/text()),
                                                     cts:element-value-query(xs:QName('prob:PUBLISHYEAR'),$i)
                                                     )))
                       let $loopData1 := for $item1 in $probono
                       
                      
                       let $res-obj := json:object()
                       let $orgName := if($item//organization:ALM_NAME/text() ne '') then $item//organization:ALM_NAME/text() else $item//organization:ORGANIZATION_NAME/text()
                       let $_ :=( map:put($res-obj,'AmLawRank',$probono//prob:AMLAW_RANK/text()),
                                  map:put($res-obj,'TotalHours',$probono//prob:TOTAL_HOURS/text()),
                                  map:put($res-obj,'NumAttorneysProbono',$probono//prob:NUM_ATTORNEYS/text()),
                                  map:put($res-obj,'NumAttorneysOver20Hrs',$probono//prob:NUM_ATTORNEYS_OVER_20_HRS/text()),
                                  map:put($res-obj,'AvgHrsPerLawyer',xs:integer(fn:round($probono//prob:AVG_HRS_PER_LAWYER/text()))),
                                  map:put($res-obj,'PercentLawyersOver20Hrs',$probono//prob:PERCENT_LAWYERS_OVER_20_HRS/text()),
                                  map:put($res-obj,'PercentAttorneysInUS',$probono//prob:PERCENT_ATTORNEYS_IN_US/text()),
                                  map:put($res-obj,'ProBonoRank',$probono//prob:PROBONO_RANK/text()),
                                  map:put($res-obj,'ProBonoscore',$probono//prob:PROBONO_SCORE/text()),
                                  map:put($res-obj,'publishyear',$probono//prob:PUBLISHYEAR/text()),
                                  map:put($res-obj,'OrganizationName',$orgName),
                                  map:put($res-obj,'OrganizationID',$item//organization:ORGANIZATION_ID/text()),
                                  map:put($res-obj,'YEAR',$probono//prob:PUBLISHYEAR/text()),
								  map:put($res-obj,'json',$probono)
                                  )
                                 let $_ := json:array-push($res-array,$res-obj)
                                 return()
                 return()                      
   return $res-array
  
}; :)

declare function firm-comp:SP_GETLAWFIRMPROBONO($firmID,$year)
{
  let $res-array := json:array()
  let $result := cts:search(/,
                  cts:and-query((
                       cts:directory-query("/LegalCompass/relational-data/organization/"),
                       cts:element-value-query(xs:QName('organization:ORGANIZATION_ID'),fn:tokenize($firmID,','))
                       )))
  let $loopData := for $item in $result
                     for $i in fn:tokenize($year,',')  
                       let $probono :=  cts:search(/,
                                                cts:and-query((
                                                     cts:directory-query("/LegalCompass/relational-data/surveys/Pro_Bono/"),
                                                     cts:element-value-query(xs:QName('prob:ORGANIZATION_ID'),$item//organization:ORGANIZATION_ID/text()),
                                                     cts:element-value-query(xs:QName('prob:PUBLISHYEAR'),$i)
                                                     )))
                       let $loopData1 := for $item1 in $probono
                       
                      
                       let $res-obj := json:object()
                       let $orgName := if($item//organization:ALM_NAME/text() ne '') then $item//organization:ALM_NAME/text() else $item//organization:ORGANIZATION_NAME/text()
                       let $_ :=( map:put($res-obj,'AmLawRank',$probono//prob:AMLAW_RANK/text()),
                                  map:put($res-obj,'TotalHours',$probono//prob:TOTAL_HOURS/text()),
                                  map:put($res-obj,'NumAttorneysProbono',$probono//prob:NUM_ATTORNEYS/text()),
                                  map:put($res-obj,'NumAttorneysOver20Hrs',$probono//prob:NUM_ATTORNEYS_OVER_20_HRS/text()),
                                  map:put($res-obj,'AvgHrsPerLawyer',xs:integer(fn:round($probono//prob:AVG_HRS_PER_LAWYER/text()))),
                                  map:put($res-obj,'PercentLawyersOver20Hrs',fn:concat($probono//prob:PERCENT_LAWYERS_OVER_20_HRS/text() ,'%')),
                                  map:put($res-obj,'PercentAttorneysInUS',fn:concat($probono//prob:PERCENT_ATTORNEYS_IN_US/text(),'%')),
                                  map:put($res-obj,'ProBonoRank',$probono//prob:PROBONO_RANK/text()),
                                  map:put($res-obj,'ProBonoscore',$probono//prob:PROBONO_SCORE/text()),
                                  map:put($res-obj,'publishyear',$probono//prob:PUBLISHYEAR/text()),
                                  map:put($res-obj,'OrganizationName',$orgName),
                                  map:put($res-obj,'OrganizationID',$item//organization:ORGANIZATION_ID/text()),
                                  map:put($res-obj,'YEAR',$probono//prob:PUBLISHYEAR/text())
                                  )
                                 let $_ := json:array-push($res-array,$res-obj)
                                 return()
                 return()                      
   return $res-array
  
};


declare function firm-comp:SP_GETLAWFIRMBILLING($firmID,$year)
{
  let $res-array := json:array()
  let $result := cts:search(/,
                  cts:and-query((
                       cts:directory-query("/LegalCompass/relational-data/organization/"),
                       cts:element-value-query(xs:QName('organization:ORGANIZATION_ID'),fn:tokenize($firmID,','))
                       )))
  let $loopData := for $item in $result
                     for $i in fn:tokenize($year,',')  
                       let $nljBilling :=  cts:search(/,
                                                cts:and-query((
                                                     cts:directory-query("/LegalCompass/relational-data/surveys/NLJ_BILLING/"),
                                                     cts:element-value-query(xs:QName('nljbilling:ORGANIZATION_ID'),$item//organization:ORGANIZATION_ID/text()),
                                                     cts:element-value-query(xs:QName('nljbilling:FISCAL_YEAR'),$i)
                                                     )))[1]
                       let $loopData1 := for $item1 in $nljBilling
                       
                      
                       let $res-obj := json:object()
                       let $orgName := if($item//organization:ALM_NAME/text() ne '') then $item//organization:ALM_NAME/text() else $item//organization:ORGANIZATION_NAME/text()
                       let $_ :=( map:put($res-obj,'PartnerBillingRateAvg',$nljBilling//nljbilling:PARTNER_BILLING_RATE_AVG/text()),
                                  map:put($res-obj,'PartnerBillingRateMed',$nljBilling//nljbilling:PARTNER_BILLING_RATE_MED/text()),
                                  map:put($res-obj,'AssociateBillingRateAvg',$nljBilling//nljbilling:ASSOCIATE_BILLING_RATE_AVG/text()),
                                  map:put($res-obj,'AssociateBillingRateMed',$nljBilling//nljbilling:ASSOCIATE_BILLING_RATE_MED/text()),
                                  map:put($res-obj,'FirmwideBillingRateAvg',$nljBilling//nljbilling:FIRMWIDE_BILLING_RATE_AVG/text()),
                                  map:put($res-obj,'FirmwideBillingRateMed',$nljBilling//nljbilling:FIRMWIDE_BILLING_RATE_MED/text()),
                                  map:put($res-obj,'PartnerBillingRateHigh',$nljBilling//nljbilling:PARTNER_BILLING_RATE_HIGH/text()),
                                  map:put($res-obj,'PartnerBillingRateLow',$nljBilling//nljbilling:PARTNER_BILLING_RATE_LOW/text()),
                                  map:put($res-obj,'AssociateBillingRateHigh',$nljBilling//nljbilling:ASSOCIATE_BILLING_RATE_HIGH/text()),
                                  map:put($res-obj,'AssociateBillingRateLow',$nljBilling//nljbilling:ASSOCIATE_BILLING_RATE_LOW/text()),
                                  map:put($res-obj,'publishyear',$nljBilling//nljbilling:PUBLISHYEAR/text()),
                                  map:put($res-obj,'OrganizationName',$orgName),
                                  map:put($res-obj,'OrganizationID',$item//organization:ORGANIZATION_ID/text()),
                                  map:put($res-obj,'YEAR',$nljBilling//nljbilling:PUBLISHYEAR/text())
                                  )
                                 let $_ := json:array-push($res-array,$res-obj)
                                 return()
                 return()                      
   return $res-array
  
};

declare function firm-comp:GetFirmRankingsAdvanceSearch(
	 $PageNo
	,$PageSize
	,$FromYear
	,$ToYear
	,$FirmSearchKeys
	,$FirmLocation
	,$IsHeadquarter
	,$SortDirection
	,$SortBy
	,$FirmSize
	,$PracticeAreas
	,$ALMRankingListName
	,$MLQuery
	,$RegionMLQuery
	,$USRegionMLQuery
	,$CountryMLQuery
	,$StateMLQuery
	,$MetroAreaMLQuery
	,$CityMLQuery
	,$PracticeAreaMLQuery
	,$ISVEREINSMLQuery
	,$SurveyParticipationMLQuery
	,$NoOfOfficesMLQuery
	,$MansfieldMLQuery
	,$YearMLQuery
)
{
  let $response-arr := json:array()

  (: Advance Filter ML Query :)
  let $MLQuery := if($MLQuery ne '')
    then xdmp:value($MLQuery)
    else ()

  (: LOCATION ADVANCE FILTER ML QUERY :)
  let $RegionMLQuery := if($RegionMLQuery ne '')
    then xdmp:value($RegionMLQuery)    
    else ()

  let $USRegionMLQuery := if($USRegionMLQuery ne '')
    then xdmp:value($USRegionMLQuery)    
    else ()  

  let $CountryMLQuery := if($CountryMLQuery ne '')
    then xdmp:value($CountryMLQuery)    
    else ()

  let $StateMLQuery := if($StateMLQuery ne '')
    then xdmp:value($StateMLQuery)    
    else () 

  let $MetroAreaMLQuery := if($MetroAreaMLQuery ne '')
    then xdmp:value($MetroAreaMLQuery)    
    else ()

  let $CityMLQuery := if($CityMLQuery ne '')
    then xdmp:value($CityMLQuery)    
    else ()

	let $PracticeAreaMLQuery := if($PracticeAreaMLQuery ne '')
    then xdmp:value($PracticeAreaMLQuery)    
    else ()

	(: Alternative Ownership Structure :)
	let $ISVEREINSMLQuery := if($ISVEREINSMLQuery ne '')
    then xdmp:value($ISVEREINSMLQuery)    
    else ()

	(: Survey Participation Structure :)
	let $SurveyParticipationMLQuery := if($SurveyParticipationMLQuery ne '')
    then xdmp:value($SurveyParticipationMLQuery)    
    else ()

	(: Mansfield ML Query :)
	let $MansfieldMLQuery := if($MansfieldMLQuery ne '')
    then xdmp:value($MansfieldMLQuery)    
    else ()

	(: Number of offices filter :)
	let $NoOfOfficesMLQuery := if ($NoOfOfficesMLQuery != '') then			
		xdmp:value($NoOfOfficesMLQuery)		
		else ()    

	let $advanceSearchQuery := cts:and-query((
		$RegionMLQuery
		,$USRegionMLQuery
		,$CountryMLQuery
		,$StateMLQuery
		,$MetroAreaMLQuery
		,$CityMLQuery
		,$PracticeAreaMLQuery
		,$ISVEREINSMLQuery
		,$SurveyParticipationMLQuery
		,$NoOfOfficesMLQuery
		,$MansfieldMLQuery
		(: ,$YearMLQuery :)
	))    

	(: Pagging Logic :)
  	let $start := xs:integer(((xs:integer($PageNo)* xs:integer($PageSize))-xs:integer($PageSize))+1)
	let $end := xs:integer((xs:integer($start) + xs:integer($PageSize)) - 1 )

  	(: Filter By WatchList And Firm Search Keys :)
	let $FirmSearch-IDs := if ($ALMRankingListName !='') then (
			if ($FirmSearchKeys != '') then (
				fn:tokenize($FirmSearchKeys,",")
			) else (
				let $res := survey-listing:GetSurveyOrganizations($ALMRankingListName,())
				return ($res ! xs:string(.))
			)
		) else (
			if ($FirmSearchKeys != '') then (
				fn:tokenize($FirmSearchKeys,",")
			) else ()
		)

	(: Filter By FirmLocation :)
	let $Location-IDs := if ($FirmLocation != '' and $IsHeadquarter eq 'false') then
			firm-comp:GetOrganizationIDByLocation_New($FirmLocation)
		else if	($FirmLocation != '' and $IsHeadquarter eq 'true') then
			firm-comp:isHeadquarter($FirmLocation)
		else ()

	(: Filter By Practice Area :)
	let $PracticeAreas-IDs := if ($PracticeAreas != '') then
			firm-comp:GetOrganizationIDByPracticeAreas($PracticeAreas)
		else () 

	(: Filter By Practice Area :)
	(: let $SurveyParticipationMLQuery := if ($SurveyParticipationMLQuery ne '') then
			cts:element-value-query(xs:QName('organization_advancesearch:OrganizationID'),(fn:tokenize($SurveyParticipationMLQuery,",") ! xs:string(.)))
		else () 		  :)

	let $YearMLQuery := if($YearMLQuery ne '')
    then 
		let $OrgIDS := cts:element-values(xs:QName('organization_advancesearch:OrganizationID'),(),(),
			cts:and-query((
				xdmp:value($YearMLQuery)
				,$advanceSearchQuery
				,$MLQuery
			)))	
		return cts:element-value-query(xs:QName('organization_advancesearch:OrganizationID'),($OrgIDS ! xs:string(.)))
    else ()

  	let $FilterQuery := cts:and-query((
      cts:directory-query('/LegalCompass/denormalized-data/law-firm-advancesearch/survey/','infinity')
      ,cts:element-value-query(xs:QName('organization_advancesearch:PUBLISHYEAR'),xs:string(fn:max(cts:element-values(xs:QName('RD_AMLAW_200:PUBLISHYEAR'),(),('ascending')))))
      ,cts:element-value-query(xs:QName('organization_advancesearch:ORGANIZATION_TYPE_ID'),'1')
	  ,cts:element-value-query(xs:QName('organization_advancesearch:ISACTIVE'),'1')
      ,if ($Location-IDs) then cts:element-value-query(xs:QName('organization_advancesearch:OrganizationID'),($Location-IDs ! xs:string(.))) else if ($IsHeadquarter eq 'true') then  ( cts:element-value-query(xs:QName('organization_advancesearch:OrganizationID'), '' )) else if($FirmLocation != '' and fn:not($Location-IDs != '')) then cts:element-value-query(xs:QName('organization_advancesearch:OrganizationID'),'') else ()
      ,if ($FirmSearch-IDs) then cts:element-value-query(xs:QName('organization_advancesearch:OrganizationID'),($FirmSearch-IDs ! xs:string(.))) else ()
      ,if(fn:string($YearMLQuery) ne '') then () else $advanceSearchQuery
	  ,if(fn:string($YearMLQuery) ne '') then () else $MLQuery
	  ,$YearMLQuery
	  (: ,cts:element-range-query(xs:QName('organization_advancesearch:REVENUE'),">",xs:double(0)) :)
    ))
	 
  	let $TotalCount := xdmp:estimate(cts:search(/,$FilterQuery))
  
  	(: Sorting Logic :)
  	let $direction := if (fn:lower-case($SortDirection) = 'desc') then 'descending' else 'ascending'
  	let $order-by := if (fn:upper-case($SortBy) = 'FIRMNAME') then (
			cts:index-order(cts:element-reference(xs:QName('organization_advancesearch:OrganizationName')) ,$direction)
		) 
		else if (fn:upper-case($SortBy) = 'YEAR') then (
			cts:index-order(cts:element-reference(xs:QName('organization_advancesearch:PUBLISHYEAR')) ,$direction)
		)
		else if (fn:upper-case($SortBy) = 'REVENUE') then (
			(: cts:index-order(cts:element-reference(xs:QName('organization_advancesearch:AMLAW_200_GROSS_REVENUE')) ,$direction)
			,cts:index-order(cts:element-reference(xs:QName('organization_advancesearch:Global_100_GROSS_REVENUE')) ,$direction) :)
			cts:index-order(cts:element-reference(xs:QName('organization_advancesearch:REVENUE')) ,$direction)
		)
		else if (fn:upper-case($SortBy) = 'AMLAW200RANK') then  (
			cts:index-order(cts:element-reference(xs:QName('organization_advancesearch:AMLAW200_RANK')) ,$direction)
		)
		else if (fn:upper-case($SortBy) = 'NLJ500RANK') then (
			cts:index-order(cts:element-reference(xs:QName('organization_advancesearch:NLJ250_RANK')) ,$direction)
		)
		else if (fn:upper-case($SortBy) = 'ALISTRANK') then (
			cts:index-order(cts:element-reference(xs:QName('organization_advancesearch:ALIST_RANK')) ,$direction)
		)
		else if (fn:upper-case($SortBy) = 'GLOBAL100RANK') then (
			cts:index-order(cts:element-reference(xs:QName('organization_advancesearch:RANK_BY_GROSS_REVENUE')) ,$direction)
		)
		else if (fn:upper-case($SortBy) = 'NOOFATTORNEYS') then (
			(: cts:index-order(cts:element-reference(xs:QName('organization_advancesearch:NUM_ATTORNEYS')) ,$direction)
			,cts:index-order(cts:element-reference(xs:QName('organization_advancesearch:NUM_OF_LAWYERS')) ,$direction) :)
			cts:index-order(cts:element-reference(xs:QName('organization_advancesearch:NUM_OF_ATTORNEYS')) ,$direction)
		)
		else if (fn:upper-case($SortBy) = 'LEVERAGE') then (
			cts:index-order(cts:element-reference(xs:QName('organization_advancesearch:LEVERAGE')) ,$direction)	
		)
		else if (fn:upper-case($SortBy) = 'FEMALEPARTNER') then (
			cts:index-order(cts:element-reference(xs:QName('organization_advancesearch:PCT_FEMALE_PARTNERS')) ,$direction)	
		)
		else if (fn:upper-case($SortBy) = 'DIVERSITY') then (
			cts:index-order(cts:element-reference(xs:QName('organization_advancesearch:MINORITY_PERCENTAGE')) ,$direction)	
		)
		else if (fn:upper-case($SortBy) = 'NUMBEROFOFFICES') then (
			cts:index-order(cts:element-reference(xs:QName('organization_advancesearch:NOOFOFFICES')) ,$direction)	
		)
		else if (fn:upper-case($SortBy) = 'COSTPERLAWYER') then (
			cts:index-order(cts:element-reference(xs:QName('organization_advancesearch:COSTPERLAWYER')) ,$direction)	
		)
		else (
			 cts:index-order(cts:element-reference(xs:QName('organization_advancesearch:AMLAW200_RANK')) ,'ascending')
			 ,cts:index-order(cts:element-reference(xs:QName('organization_advancesearch:REVENUE')) ,'descending')
			 ,cts:index-order(cts:element-reference(xs:QName('organization_advancesearch:OrganizationName')) ,'ascending')
		)

  let $searchResult := cts:search(/,
    $FilterQuery
    ,$order-by
    )[$start to $end]

  let $result := for $item in $searchResult
  let $response-obj := json:object()

  let $YEAR_ML := $item//organization_advancesearch:PUBLISHYEAR_ML/text()

  let $Revenue := if ($item/organization_advancesearch:AMLAW_200_GROSS_REVENUE/text() != '') 
  	then $item/organization_advancesearch:AMLAW_200_GROSS_REVENUE/text() 
	else $item/organization_advancesearch:Global_100_GROSS_REVENUE/text()


  let $_ := (
  map:put($response-obj,'ORGANIZATION_ID',$item//organization_advancesearch:OrganizationTypeID/text())
  ,map:put($response-obj,'FirmName',$item//organization_advancesearch:OrganizationName/text())
  ,map:put($response-obj,'FirmId',$item//organization_advancesearch:OrganizationID/text())
  (: ,map:put($response-obj,'Year',$item//organization_advancesearch:PUBLISHYEAR/text()) :)
  ,map:put($response-obj,'Year',if($YEAR_ML) then $YEAR_ML else $item//organization_advancesearch:PUBLISHYEAR/text() )
  ,map:put($response-obj,'AMLAW200RANK',$item//organization_advancesearch:AMLAW200_RANK/text())
  ,map:put($response-obj,'NLJ500RANK',$item//organization_advancesearch:NLJ250_RANK/text())
  ,map:put($response-obj,'ALISTRANK',$item//organization_advancesearch:ALIST_RANK/text())
  ,map:put($response-obj,'Global100Rank',$item//organization_advancesearch:RANK_BY_GROSS_REVENUE/text())
  ,map:put($response-obj,'NOOFATTORNEYS',$item//organization_advancesearch:NUM_OF_ATTORNEYS/text())
  ,map:put($response-obj,'Revenue',xs:integer($item//organization_advancesearch:REVENUE/text()))
  ,map:put($response-obj,'LEVERAGE',$item//organization_advancesearch:LEVERAGE/text())
  ,map:put($response-obj,'FEMALEPARTNER',$item//organization_advancesearch:PCT_FEMALE_PARTNERS/text())
  ,map:put($response-obj,'DIVERSITY',$item//organization_advancesearch:MINORITY_PERCENTAGE/text())
  ,map:put($response-obj,'NUMBEROFOFFICES',$item//organization_advancesearch:NOOFOFFICES/text())
  ,map:put($response-obj,'COSTPERLAWYER',$item//organization_advancesearch:COSTPERLAWYER/text())
  ,map:put($response-obj,'URI',fn:base-uri($item))
  ,map:put($response-obj,'TotalCount',$TotalCount)
  (: ,map:put($response-obj,'Test',$YearMLQuery) :)
  )
  let $_ :=  json:array-push($response-arr,$response-obj)
  return ($response-obj)
  return $response-arr

};

declare function firm-comp:GetOrganizationIDByRegion($FirmLocation)
{
	let $ORGANIZATION_IDs := if (($FirmLocation != '') and ($FirmLocation)) then
		
			let $FirmLocation := if(fn:contains($FirmLocation,'US'))
				then fn:replace($FirmLocation,'US',"United States")
				else $FirmLocation

			(: condition for Geo Region :)
			let $GeoRegion_Q := if ($FirmLocation) then
				let $GeoRegions := fn:tokenize($FirmLocation,',')
				(: return cts:element-value-query(xs:QName('org-branch:GEOGRAPHIC_REGION'),$GeoRegions,('case-insensitive')) :)
				return cts:element-value-query(xs:QName('cityns:geographic_region'),$GeoRegions)
			else ()

			let $std_locs := 
				cts:search(/,
				cts:and-query((
					cts:directory-query('/LegalCompass/relational-data/city/',"infinity"),
					cts:or-query((
					$GeoRegion_Q
					)))))//cityns:std_loc/text()

				let $cIDs := cts:search(/,
				cts:and-query((
					cts:directory-query("/LegalCompass/relational-data/company_locs/", "infinity")
					,cts:element-value-query(xs:QName('company_locs:std_loc'),$std_locs,"whitespace-sensitive")
				)))//company_locs:company_id/text()

				let $aliIDs := cts:element-values(xs:QName("xref:ALI_ID"),(),(),
				cts:and-query((
					cts:element-value-query(xs:QName('xref:RE_ID'),$cIDs)
				))
				)
    		return $aliIDs

		else ()
		
	return $ORGANIZATION_IDs
};

declare function firm-comp:GetOrganizationIDByCountry($FirmLocation)
{
	let $ORGANIZATION_IDs := if (($FirmLocation != '') and ($FirmLocation)) then
		
			(: condition for Countries :)
			(:
			let $FirmLocation := if($FirmLocation eq 'United States')
				then "USA"
				else $FirmLocation:)

			let $FirmLocation := if(fn:contains($FirmLocation,'United States'))
				then fn:replace($FirmLocation,'United States','USA')
				else $FirmLocation
				
			let $Country_Q := if ($FirmLocation) then 
				let $Countries := fn:tokenize($FirmLocation,',')
				(: return cts:element-value-query(xs:QName('org-branch:COUNTRY'),$Countries,('case-insensitive')) :)
				return cts:element-value-query(xs:QName('cityns:country'),$Countries)
			else ()

			let $std_locs := 
				cts:search(/,
				cts:and-query((
					cts:directory-query('/LegalCompass/relational-data/city/',"infinity"),
					cts:or-query((
					$Country_Q
					)))))//cityns:std_loc/text()

				let $cIDs := cts:search(/,
				cts:and-query((
					cts:directory-query("/LegalCompass/relational-data/company_locs/", "infinity")
					,cts:element-value-query(xs:QName('company_locs:std_loc'),$std_locs,"whitespace-sensitive")
				)))//company_locs:company_id/text()

				let $aliIDs := cts:element-values(xs:QName("xref:ALI_ID"),(),(),
				cts:and-query((
					cts:element-value-query(xs:QName('xref:RE_ID'),$cIDs)
				))
				)
    		return $aliIDs

		else ()
		
	return ($ORGANIZATION_IDs ! xs:string(.))
};

declare function firm-comp:GetOrganizationIDByState($FirmLocation)
{
	let $ORGANIZATION_IDs := if (($FirmLocation != '') and ($FirmLocation)) then
		
	(: condition for State :)
			let $STATE_Q := if ($FirmLocation) then 
				let $States := fn:tokenize($FirmLocation,',')
				(: return cts:element-value-query(xs:QName('org-branch:STATE'),$States,('case-insensitive')) :)
				return cts:element-value-query(xs:QName('cityns:state'),$States)
			else ()

		let $std_locs := 
				cts:search(/,
				cts:and-query((
					cts:directory-query('/LegalCompass/relational-data/city/',"infinity"),
					cts:or-query((
					$STATE_Q
					)))))//cityns:std_loc/text()

				let $cIDs := cts:search(/,
				cts:and-query((
					cts:directory-query("/LegalCompass/relational-data/company_locs/", "infinity")
					,cts:element-value-query(xs:QName('company_locs:std_loc'),$std_locs,"whitespace-sensitive")
				)))//company_locs:company_id/text()

				let $aliIDs := cts:element-values(xs:QName("xref:ALI_ID"),(),(),
				cts:and-query((
					cts:element-value-query(xs:QName('xref:RE_ID'),$cIDs)
				))
				)
    		return $aliIDs

		else ()
		
	return $ORGANIZATION_IDs
};

declare function firm-comp:GetOrganizationIDByMetroArea($FirmLocation)
{
	let $ORGANIZATION_IDs := if (($FirmLocation != '') and ($FirmLocation)) then
		
	(: condition for METRO_AREA :)
			let $METRO_AREA_Q := if ($FirmLocation) then 
				let $MetroAreas := fn:tokenize($FirmLocation,',')
				return cts:element-value-query(xs:QName('org-branch:METRO_AREA'),$MetroAreas,('case-insensitive'))
			else ()

		return  cts:element-values(xs:QName('org-branch:ORGANIZATION_ID'),(),(), 
				cts:and-query((
					cts:or-query((
					$METRO_AREA_Q
					)),
					cts:not-query(cts:element-range-query(xs:QName('org-branch:ORGANIZATION_ID'),'<',1))
					,cts:element-value-query(xs:QName('org-branch:FISCAL_YEAR'), xs:string(cts:max(cts:element-reference(xs:QName("org-branch:FISCAL_YEAR")))))
				)))

		else ()
		
	return $ORGANIZATION_IDs
};

declare function firm-comp:GetOrganizationIDByCity($FirmLocation)
{
	let $ORGANIZATION_IDs := if (($FirmLocation != '') and ($FirmLocation)) then
		
			(: condition for City :)
			let $CITY_Q := if ($FirmLocation) then 
				let $Cities := $FirmLocation ! fn:tokenize(.,',')[1]
				(: return cts:element-value-query(xs:QName('org-branch:CITY'),cts:element-value-match(xs:QName("org-branch:CITY"),($Cities),"case-insensitive")) :)
				return cts:element-value-query(xs:QName('cityns:city'),cts:element-value-match(xs:QName("cityns:city"),($Cities),"case-insensitive"))
			else ()

			let $std_locs := 
				cts:search(/,
				cts:and-query((
					cts:directory-query('/LegalCompass/relational-data/city/',"infinity"),
					cts:or-query((
					$CITY_Q
					)))))//cityns:std_loc/text()

				let $cIDs := cts:search(/,
				cts:and-query((
					cts:directory-query("/LegalCompass/relational-data/company_locs/", "infinity")
					,cts:element-value-query(xs:QName('company_locs:std_loc'),$std_locs,"whitespace-sensitive")
				)))//company_locs:company_id/text()

				let $aliIDs := cts:element-values(xs:QName("xref:ALI_ID"),(),(),
				cts:and-query((
					cts:element-value-query(xs:QName('xref:RE_ID'),$cIDs)
				))
				)
    		return $aliIDs

		else ()
		
	return $ORGANIZATION_IDs
};

declare function firm-comp:GetOrganizationIDByUSRegion($FirmLocation)
{
	let $ORGANIZATION_IDs := if (($FirmLocation != '') and ($FirmLocation)) then
		
		(: condition for Region :)
			let $Region_Q := if ($FirmLocation) then
				let $UsRegions := fn:tokenize($FirmLocation,',')
				return if ($UsRegions = ('US States/Cities','US Regions')) then
					let $USRegions := cts:element-values(xs:QName('cityns:us_region'), (), (), cts:and-query((
						 cts:collection-query($config:RD-ORGANIZATION_BRANCH-COLLECTION)
						,cts:not-query(cts:element-value-query(xs:QName('cityns:us_region'),''))
					)))
					return cts:element-value-query(xs:QName('cityns:us_region'),$USRegions,('case-insensitive'))
				else 
					cts:element-value-query(xs:QName('cityns:us_region'),$UsRegions,('case-insensitive')) 
			else ()

			let $std_locs := 
				cts:search(/,
				cts:and-query((
					cts:directory-query('/LegalCompass/relational-data/city/',"infinity"),
					cts:or-query((
					$Region_Q
					)))))//cityns:std_loc/text()

				let $cIDs := cts:search(/,
				cts:and-query((
					cts:directory-query("/LegalCompass/relational-data/company_locs/", "infinity")
					,cts:element-value-query(xs:QName('company_locs:std_loc'),$std_locs,"whitespace-sensitive")
				)))//company_locs:company_id/text()

				let $aliIDs := cts:element-values(xs:QName("xref:ALI_ID"),(),(),
				cts:and-query((
					cts:element-value-query(xs:QName('xref:RE_ID'),$cIDs)
				))
				)
    		return $aliIDs

		else ()
		
	return $ORGANIZATION_IDs
};

declare function firm-comp:isHeadquarter($FirmLocation)
{
	let $ORGANIZATION_IDs := if (($FirmLocation != '') and ($FirmLocation)) then
			
			(: condition for Geo Region :)
			let $GeoRegion_Q := if ($FirmLocation/GeoRegions) then
				let $GeoRegions := $FirmLocation/GeoRegions/text()
				(: return cts:element-value-query(xs:QName('cityns:geographic_region'),fn:tokenize($GeoRegions,',')) :)
				return cts:element-value-query(xs:QName('cityns:geographic_region'),$GeoRegions)
			else ()

			(: condition for Region :)
			let $Region_Q := if ($FirmLocation/UsRegions) then
				let $UsRegions := $FirmLocation/UsRegions/text()
				return cts:element-value-query(xs:QName('cityns:us_region'),$UsRegions)
			else ()

			(: condition for Countries :)
			let $Country_Q := if ($FirmLocation/Countries) then 
				let $Countries := $FirmLocation/Countries/text()
				return cts:element-value-query(xs:QName('cityns:country'),$Countries)
			else ()

			(: condition for State :)
			let $STATE_Q := if ($FirmLocation/States) then 
				let $States := $FirmLocation/States/text()
				return cts:element-value-query(xs:QName('cityns:state'),$States) 
			else ()

			(: condition for City :)
			(: let $CITY_Q := if ($FirmLocation/Cities) then 
				let $Cities := $FirmLocation/Cities/text()
				return cts:element-value-query(xs:QName('cityns:city'),$Cities)
			else () :)

			let $CITY_Q := if ($FirmLocation/Cities) then 
				let $Cities := $FirmLocation/Cities/text()
				for $c in $Cities
				(: return if(count(fn:tokenize($c,'[|]')) > 1) 
				then 
				let $city := fn:tokenize($c,'[|]')[1]
				let $state := fn:tokenize($c,'[|]')[2] :)
				return if(count(fn:tokenize($c,('[|,]'))) > 1) 
				then 
				let $city := fn:tokenize($c,('[|,]'))[1]
          		let $state := fn:tokenize($c,('[|,]'))[2]
						return 
					if(fn:string-length($state) eq 2) 
					then 
					cts:and-query((
					cts:element-value-query(xs:QName('cityns:city'), $city, ('case-insensitive'))
					,cts:element-value-query(xs:QName('cityns:state'), $state, ('case-insensitive'))
					))
					else
					cts:and-query((
					cts:element-value-query(xs:QName('cityns:city'), $city, ('case-insensitive'))
					,cts:element-value-query(xs:QName('cityns:country'), $state, ('case-insensitive'))
					))
				
				else
				cts:element-value-query(xs:QName('cityns:city'), $Cities, ('case-insensitive'))
					else ()

			let $std_locs := 
        cts:search(/,
          cts:and-query((
            cts:directory-query('/LegalCompass/relational-data/city/',"infinity"),
			      cts:or-query((
            $GeoRegion_Q,$Region_Q,$Country_Q,$STATE_Q,$CITY_Q
            )))))//cityns:std_loc/text()

        let $cIDs := cts:search(/,
          cts:and-query((
            cts:directory-query("/LegalCompass/relational-data/company_locs/", "infinity")
              ,cts:element-value-query(xs:QName('company_locs:std_loc'),$std_locs,"whitespace-sensitive")
              ,cts:element-value-query(xs:QName('company_locs:headquarter'),'1')
          )))//company_locs:company_id/text()

        let $aliIDs := cts:element-values(xs:QName("xref:ALI_ID"),(),(),
          cts:and-query((
            cts:element-value-query(xs:QName('xref:RE_ID'),$cIDs)
          ))
        )
    return $aliIDs
  else ()    
	
return $ORGANIZATION_IDs

};


declare function firm-comp:GetFirmRankings1(
	 $PageNo
	,$PageSize
	,$FromYear
	,$ToYear
	,$FirmSearchKeys
	,$FirmLocation
	,$IsHeadquarter
	,$SortDirection
	,$SortBy
	,$FirmSize
	,$PracticeAreas
	,$ALMRankingListName
	,$MLQuery
	,$RegionMLQuery
	,$CountryMLQuery
	,$StateMLQuery
	,$MetroAreaMLQuery
	,$CityMLQuery
	,$PracticeAreaMLQuery
	,$ISVEREINSMLQuery
	,$SurveyParticipationMLQuery
	,$NoOfOfficesMLQuery
)
{
  let $response-arr := json:array()

  (: Advance Filter ML Query :)
  let $MLQuery := if($MLQuery ne '')
    then xdmp:value($MLQuery)
    else ()

  (: LOCATION ADVANCE FILTER ML QUERY :)
  let $RegionMLQuery := if($RegionMLQuery ne '')
    then xdmp:value($RegionMLQuery)    
    else ()  

  let $CountryMLQuery := if($CountryMLQuery ne '')
    then xdmp:value($CountryMLQuery)    
    else ()

  let $StateMLQuery := if($StateMLQuery ne '')
    then xdmp:value($StateMLQuery)    
    else () 

  let $MetroAreaMLQuery := if($MetroAreaMLQuery ne '')
    then xdmp:value($MetroAreaMLQuery)    
    else ()

  let $CityMLQuery := if($CityMLQuery ne '')
    then xdmp:value($CityMLQuery)    
    else ()

	let $PracticeAreaMLQuery := if($PracticeAreaMLQuery ne '')
    then xdmp:value($PracticeAreaMLQuery)    
    else ()

	(: Alternative Ownership Structure :)
	let $ISVEREINSMLQuery := if($ISVEREINSMLQuery ne '')
    then xdmp:value($ISVEREINSMLQuery)    
    else ()

	(: Survey Participation Structure :)
	let $SurveyParticipationMLQuery := if($SurveyParticipationMLQuery ne '')
    then xdmp:value($SurveyParticipationMLQuery)    
    else ()

	(: Number of offices filter :)
	let $NoOfOfficesMLQuery := if ($NoOfOfficesMLQuery != '') then			
		xdmp:value($NoOfOfficesMLQuery)		
		else ()    

	let $advanceSearchQuery := cts:and-query((
		$RegionMLQuery
		,$CountryMLQuery
		,$StateMLQuery
		,$MetroAreaMLQuery
		,$CityMLQuery
		,$PracticeAreaMLQuery
		,$ISVEREINSMLQuery
		,$SurveyParticipationMLQuery
		,$NoOfOfficesMLQuery
	))    

	(: Pagging Logic :)
  	let $start := xs:integer(((xs:integer($PageNo)* xs:integer($PageSize))-xs:integer($PageSize))+1)
	let $end := xs:integer((xs:integer($start) + xs:integer($PageSize)) - 1 )

  	(: Filter By WatchList And Firm Search Keys :)
	let $FirmSearch-IDs := if ($ALMRankingListName !='') then (
			if ($FirmSearchKeys != '') then (
				fn:tokenize($FirmSearchKeys,",")
			) else (
				let $res := survey-listing:GetSurveyOrganizations($ALMRankingListName,())
				return ($res ! xs:string(.))
			)
		) else (
			if ($FirmSearchKeys != '') then (
				fn:tokenize($FirmSearchKeys,",")
			) else ()
		)

	(: Filter By FirmLocation :)
	let $Location-IDs := if ($FirmLocation != '' and $IsHeadquarter eq 'false') then
			firm-comp:GetOrganizationIDByLocation_New($FirmLocation)
		else if	($FirmLocation != '' and $IsHeadquarter eq 'true') then
			firm-comp:isHeadquarter($FirmLocation)
		else ()

	(: Filter By Practice Area :)
	let $PracticeAreas-IDs := if ($PracticeAreas != '') then
			firm-comp:GetOrganizationIDByPracticeAreas($PracticeAreas)
		else () 

	(: Filter By Practice Area :)
	(: let $SurveyParticipationMLQuery := if ($SurveyParticipationMLQuery ne '') then
			cts:element-value-query(xs:QName('organization_advancesearch:OrganizationID'),(fn:tokenize($SurveyParticipationMLQuery,",") ! xs:string(.)))
		else () 		  :)


  	let $FilterQuery := cts:and-query((
      cts:directory-query('/LegalCompass/denormalized-data/law-firm-advancesearch/survey/','infinity')
      ,cts:element-value-query(xs:QName('organization_advancesearch:PUBLISHYEAR'),xs:string(fn:max(cts:element-values(xs:QName('RD_AMLAW_200:PUBLISHYEAR'),(),('ascending')))))
      ,cts:element-value-query(xs:QName('organization_advancesearch:ORGANIZATION_TYPE_ID'),'1')
      ,if ($Location-IDs) then cts:element-value-query(xs:QName('organization_advancesearch:OrganizationID'),($Location-IDs ! xs:string(.))) else ()
      ,if ($FirmSearch-IDs) then cts:element-value-query(xs:QName('organization_advancesearch:OrganizationID'),($FirmSearch-IDs ! xs:string(.))) else ()      
      ,$advanceSearchQuery
	  ,$MLQuery
	  (: ,cts:element-range-query(xs:QName('organization_advancesearch:REVENUE'),">",xs:double(0)) :)
    ))
	 
  	let $TotalCount := xdmp:estimate(cts:search(/,$FilterQuery))
  
  	(: Sorting Logic :)
  	let $direction := if (fn:lower-case($SortDirection) = 'desc') then 'descending' else 'ascending'
  	let $order-by := if (fn:upper-case($SortBy) = 'FIRMNAME') then (
			cts:index-order(cts:element-reference(xs:QName('organization_advancesearch:OrganizationName')) ,$direction)
		) 
		else if (fn:upper-case($SortBy) = 'YEAR') then (
			cts:index-order(cts:element-reference(xs:QName('organization_advancesearch:PUBLISHYEAR')) ,$direction)
		)
		else if (fn:upper-case($SortBy) = 'REVENUE') then (
			(: cts:index-order(cts:element-reference(xs:QName('organization_advancesearch:AMLAW_200_GROSS_REVENUE')) ,$direction)
			,cts:index-order(cts:element-reference(xs:QName('organization_advancesearch:Global_100_GROSS_REVENUE')) ,$direction) :)
			cts:index-order(cts:element-reference(xs:QName('organization_advancesearch:REVENUE')) ,$direction)
		)
		else if (fn:upper-case($SortBy) = 'AMLAW200RANK') then  (
			cts:index-order(cts:element-reference(xs:QName('organization_advancesearch:AMLAW200_RANK')) ,$direction)
		)
		else if (fn:upper-case($SortBy) = 'NLJ500RANK') then (
			cts:index-order(cts:element-reference(xs:QName('organization_advancesearch:NLJ250_RANK')) ,$direction)
		)
		else if (fn:upper-case($SortBy) = 'ALISTRANK') then (
			cts:index-order(cts:element-reference(xs:QName('organization_advancesearch:ALIST_RANK')) ,$direction)
		)
		else if (fn:upper-case($SortBy) = 'GLOBAL100RANK') then (
			cts:index-order(cts:element-reference(xs:QName('organization_advancesearch:RANK_BY_GROSS_REVENUE')) ,$direction)
		)
		else if (fn:upper-case($SortBy) = 'NOOFATTORNEYS') then (
			(: cts:index-order(cts:element-reference(xs:QName('organization_advancesearch:NUM_ATTORNEYS')) ,$direction)
			,cts:index-order(cts:element-reference(xs:QName('organization_advancesearch:NUM_OF_LAWYERS')) ,$direction) :)
			cts:index-order(cts:element-reference(xs:QName('organization_advancesearch:NUM_OF_ATTORNEYS')) ,$direction)
		)
		else (
			 cts:index-order(cts:element-reference(xs:QName('organization_advancesearch:AMLAW200_RANK')) ,'ascending')
			 ,cts:index-order(cts:element-reference(xs:QName('organization_advancesearch:OrganizationName')) ,'ascending')
		)



	let $LSTFirms := cts:values(cts:element-reference(xs:QName('organization_advancesearch:OrganizationID')),(),(),$FilterQuery)
    let $LSTFirms := json:to-array($LSTFirms)
	let $req-obj := json:object()
	let $_ := map:put($req-obj,'LSTFirms',$LSTFirms)
	return json:to-array($req-obj)

};