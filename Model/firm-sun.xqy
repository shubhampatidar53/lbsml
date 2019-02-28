xquery version '1.0-ml';

module namespace firm = 'http://alm.com/firm';

import module namespace config = 'http://alm.com/config' at '/common/config.xqy';
import module namespace helper = 'http://alm.com/helper' at '/common/model/helper.xqy';
import module namespace search = 'http://marklogic.com/appservices/search' at '/MarkLogic/appservices/search/search.xqy';
import module namespace json = 'http://marklogic.com/xdmp/json'  at '/MarkLogic/json/json.xqy';
import module namespace firm-comp = 'http://alm.com/firm-comparison' at '/common/model/firm-comparison.xqy';

declare namespace organization = 'http://alm.com/LegalCompass/dd/organization';
declare namespace rd-organization = 'http://alm.com/LegalCompass/rd/organization';
declare namespace org-address = 'http://alm.com/LegalCompass/rd/organization-address';
declare namespace survey = 'http://alm.com/LegalCompass/dd/survey';
declare namespace xref = 'http://alm.com/LegalCompass/rd/FIRMS_ALI_XREF_RE';
declare namespace rd_person = 'http://alm.com/LegalCompass/rd/person';
declare namespace dd_person = 'http://alm.com/LegalCompass/dd/person';
declare namespace practices_kws = 'http://alm.com/LegalCompass/rd/practices_kws';
declare namespace city = 'http://alm.com/LegalCompass/rd/city';
declare namespace company = 'http://alm.com/LegalCompass/rd/company';
declare namespace organization-branch = 'http://alm.com/LegalCompass/rd/organization-branch';
declare namespace bdbs-representer = 'http://alm.com/LegalCompass/rd/bdbs-representer';
declare namespace bdbs-party = 'http://alm.com/LegalCompass/rd/bdbs-party';
declare namespace bdbs-transaction = 'http://alm.com/LegalCompass/rd/bdbs-transaction';
declare namespace data = 'http://alm.com/LegalCompass/rd/data';
declare namespace survey-listing = 'http://alm.com/LegalCompass/dd/survey-listing';
declare namespace Who_Counsels_who = 'http://alm.com/LegalCompass/rd/Who_Counsels_who';
declare namespace COMPANYPROFILE_LFR_NEW = 'http://alm.com/LegalCompass/rd/COMPANYPROFILE_LFR_NEW';
declare namespace COMPANYPROFILE_LFR = 'http://alm.com/LegalCompass/rd/COMPANYPROFILE_LFR';
declare namespace TOP500 = 'http://alm.com/LegalCompass/rd/TOP500';
declare namespace people_changes = 'http://alm.com/LegalCompass/rd/people_changes';
declare namespace organization-contact = 'http://alm.com/LegalCompass/rd/organization-contact';
declare namespace org-branch = 'http://alm.com/LegalCompass/rd/organization-branch';
declare namespace city_detail = 'http://alm.com/LegalCompass/rd/city_detail';
declare namespace ALI_RE_LateralMoves_Data = 'http://alm.com/LegalCompass/rd/ALI_RE_LateralMoves_Data';
declare namespace lfp_news = 'http://alm.com/LegalCompass/rd/lawfirmprofile_news';
declare namespace REPRESENTATION_TYPES = 'http://alm.com/LegalCompass/rd/REPRESENTATION_TYPES';

declare namespace organizations = 'http://alm.com/LegalCompass/rd/organization';
declare namespace amlaw100 = 'http://alm.com/LegalCompass/rd/AMLAW_100';
declare namespace Global_100 = 'http://alm.com/LegalCompass/rd/Global_100';
declare namespace nlj250 = 'http://alm.com/LegalCompass/rd/NLJ_250';
declare namespace dc20 = 'http://alm.com/LegalCompass/rd/DC20';
declare namespace legaltimes =  'http://alm.com/LegalCompass/rd/Legal_Times_150';
declare namespace ny100 = 'http://alm.com/LegalCompass/rd/NY100';
declare namespace alist = 'http://alm.com/LegalCompass/rd/ALIST';
declare namespace tx100 = 'http://alm.com/LegalCompass/rd/TX100';
declare namespace nljlgbt = "http://alm.com/LegalCompass/rd/NLJ_LGBT";

declare namespace AMLAW_200 = 'http://alm.com/LegalCompass/rd/AMLAW_200';
declare namespace Diversity_Scorecard = 'http://alm.com/LegalCompass/rd/Diversity_Scorecard';
declare namespace FEMALE_SCORECARD = 'http://alm.com/LegalCompass/rd/FEMALE_SCORECARD';
declare namespace UK_50 = 'http://alm.com/LegalCompass/rd/UK_50';
declare namespace CHINA_40 = 'http://alm.com/LegalCompass/rd/CHINA_40';

declare namespace firm-org = 'http://alm.com/LegalCompass/lawfirm/dd/organization';

declare namespace ALI_RE_Attorney_Data = 'http://alm.com/LegalCompass/dd/ALI_RE_Attorney_Data';
declare namespace TBL_RER_CACHE_ATTORNEY_MOVESCHANGES = 'http://alm.com/LegalCompass/dd/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES';

declare variable $company-obj := json:object();

declare option xdmp:mapping 'false';

declare function firm:GetSearchResults($ORGANIZATION_ID)
{
	let $search-result := for $x in cts:search(/TOP500,
		cts:and-query((
			cts:directory-query($config:RD-TOP500-PATH)
			,cts:element-value-query(xs:QName('TOP500:COMPANY_ID'),$ORGANIZATION_ID)
			,cts:not-query(cts:element-value-query(xs:QName('TOP500:PRIMARY_INDUSTRY'),''))
			(:,cts:element-value-query(xs:QName('TOP500:PRIMARY_INDUSTRY'), 'Semiconductor and Related Device Manufacturing', ('case-insensitive')):)
		)))
		return element {'RECORD'} { 
			element {'PRIMARY_INDUSTRY'} {$x/TOP500:PRIMARY_INDUSTRY/text()},
			element {'COMPANY_ID'} {$x/TOP500:COMPANY_ID/text()}
		}

	let $distinct-values := helper:distinct-node($search-result)
	
	let $response := for $facet in fn:distinct-values($distinct-values/PRIMARY_INDUSTRY/text())
		
		let $company_id := $distinct-values[PRIMARY_INDUSTRY eq $facet]/COMPANY_ID/text()
		let $count := fn:count($ORGANIZATION_ID[. = $company_id])
		(: let $total := fn:count($distinct-values[PRIMARY_INDUSTRY = $facet])
		let $total := if ($total = 1) then $count else $total:)
		
		let $obj := element {'RECORD'} {
			element {'Total'} {$count},
			element {'Industry'} {$facet}
		}
		
		return $obj

	return $response
};

declare function firm:GetTotalIndustrybyId_1($firmID)
{
	let $fromYear := (fn:max(cts:element-attribute-values(xs:QName('survey:YEAR'),xs:QName('PublishYear'),(),(), cts:directory-query($config:DD-SURVEY-AMLAW_100-PATH)))-1)
	let $toYear := fn:max(cts:element-attribute-values(xs:QName('survey:YEAR'),xs:QName('PublishYear'),(),(), cts:directory-query($config:DD-SURVEY-AMLAW_100-PATH)))

	(: ---------------------------------- Stored Procedure 1st Part ---------------------------------- :)
	let $PARTY_IDs := cts:element-values(xs:QName('bdbs-representer:PARTY_ID'),(),(),
		cts:and-query((
			cts:directory-query($config:RD-BDBS_REPRESENTER-PATH),
			cts:element-value-query(xs:QName('bdbs-representer:ORGANIZATION_ID'),$firmID),
			cts:not-query(cts:element-value-query(xs:QName('bdbs-representer:PARTY_ID'),''))
		)))

	let $TRANSACTION_IDs := cts:element-values(xs:QName('bdbs-transaction:TRANSACTION_ID'),(),(),
		cts:and-query((
			cts:directory-query($config:RD-BDBS_TRANSACTION-PATH),
			cts:element-range-query(xs:QName('bdbs-transaction:YEAR'),'>=',$fromYear),
			cts:element-range-query(xs:QName('bdbs-transaction:YEAR'),'<=',$toYear)
		)))

	let $ORGANIZATION_ID_1 := cts:search(/bdbs-party,
		cts:and-query((
			cts:directory-query($config:RD-BDBS_PARTY-PATH),
			cts:element-value-query(xs:QName('bdbs-party:PARTY_ID'),($PARTY_IDs ! xs:string(.))),
			cts:element-value-query(xs:QName('bdbs-party:TRANSACTION_ID'),($TRANSACTION_IDs ! xs:string(.))),
			cts:not-query(cts:element-value-query(xs:QName('bdbs-party:ORGANIZATION_ID'),''))
		)))/bdbs-party:ORGANIZATION_ID/text()
	
	
	let $RESPONSE_1 := firm:GetSearchResults($ORGANIZATION_ID_1)
	
	(: ---------------------------------- Stored Procedure 2nd Part ---------------------------------- :)
	
	let $ORGANIZATION_ID_2 := cts:search(/WhoCounselsWho, 
		cts:and-query((
			cts:directory-query($config:RD-SURVEY-WHO_COUNSELS_WHO-PATH)
			,cts:element-value-query(xs:QName('Who_Counsels_who:OUTSIDE_COUNSEL_ID'),$firmID)
			,cts:element-range-query(xs:QName('Who_Counsels_who:PUBLISHYEAR'), '>=', $fromYear)
			,cts:element-range-query(xs:QName('Who_Counsels_who:PUBLISHYEAR'), '<=', $toYear)
		)))/Who_Counsels_who:ORGANIZATION_ID/text()
	
	let $RESPONSE_2 := firm:GetSearchResults($ORGANIZATION_ID_2)
	
	(: ---------------------------------- Stored Procedure 3rd Part ---------------------------------- :)
	
	let $ORGANIZATION_ID_3 := cts:search(/COMPANYPROFILE_LFR_NEW,
		cts:and-query((
			cts:directory-query($config:RD-SURVEY-COMPANYPROFILE_LFR_NEW-PATH)
			,cts:element-value-query(xs:QName('COMPANYPROFILE_LFR_NEW:FIRM_ID'),$firmID)
			,cts:element-range-query(xs:QName('COMPANYPROFILE_LFR_NEW:YEAR'), '>=', $fromYear)
			,cts:element-range-query(xs:QName('COMPANYPROFILE_LFR_NEW:YEAR'), '<=', $toYear)
		)))/COMPANYPROFILE_LFR_NEW:COMPANY_ID/text()
		
	let $RESPONSE_3 := firm:GetSearchResults($ORGANIZATION_ID_3)
	
	(: ---------------------------------- Stored Procedure 4th Part ---------------------------------- :)
	
	let $ORGANIZATION_ID_4 := cts:search(/COMPANYPROFILE_LFR,
		cts:and-query((
			cts:directory-query($config:RD-SURVEY-COMPANYPROFILE_LFR-PATH)
			,cts:element-value-query(xs:QName('COMPANYPROFILE_LFR:FIRM_ID'),$firmID)
			,cts:element-range-query(xs:QName('COMPANYPROFILE_LFR:YEAR'), '>=', $fromYear)
			,cts:element-range-query(xs:QName('COMPANYPROFILE_LFR:YEAR'), '<=', $toYear)
		)))/COMPANYPROFILE_LFR:COMPANY_ID/text()
		
	let $RESPONSE_4 := firm:GetSearchResults($ORGANIZATION_ID_4)
	
	let $OBJECT := ($RESPONSE_1, $RESPONSE_2, $RESPONSE_3, $RESPONSE_4)
	
	let $response-arr := json:array()
	
	let $_ := for $OBJ in fn:distinct-values($OBJECT/Industry/text())
		
		let $response-obj := json:object()
		
		let $total := fn:sum($OBJECT[Industry = $OBJ]/Total/text())
		
		let $_ := (
			map:put($response-obj ,'Total', $total),
			map:put($response-obj ,'Industry', $OBJ)
		)
		let $_ := json:array-push($response-arr,$response-obj)
		
		return $_
		
	return $response-arr
};

declare function firm:GeLawFirmProfileNews(
	 $fromDate
	,$toDate
	,$ALIFirmId
	,$Source
	,$Keywords
)
{
	(: let $fromDate := fn:tokenize($fromDate,'T')[1]
	let $toDate := fn:tokenize($toDate,'T')[1] :)
	
	let $ALIFirmId := fn:tokenize($ALIFirmId,',')
	
	let $firm_q := if ($ALIFirmId) then 
			cts:element-value-query(xs:QName('lfp_news:FIRMID'),$ALIFirmId)
		else ()
	
	let $source_q := if ($Source != '') then
			if ($Source = 'General News') then
				cts:not-query(cts:element-value-query(xs:QName('lfp_news:NEWSPUBLISHER'),'Firm Site'))
			else (
				if ($Source = 'Law Firm Website') then
					cts:element-value-query(xs:QName('lfp_news:NEWSPUBLISHER'),fn:normalize-space(fn:replace('Firm Site',"'","''")))
				else 
					cts:element-value-query(xs:QName('lfp_news:NEWSPUBLISHER'),fn:normalize-space(fn:replace($Source,"'","''")))
			)
		else ()
		
	let $keyword_q := if ($Keywords != '') then
			let $q := fn:normalize-space(fn:replace($Keywords,"'","''"))
			return cts:element-word-query(xs:QName('lfp_news:HEADLINE'),fn:concat('*',$q,'*'),('case-insensitive','wildcarded'))
		else ()
	
	
	let $date_q := if (($fromDate != '') and ($toDate != '')) then (
			 cts:element-range-query(xs:QName('lfp_news:SORTDATE'), '>=', xs:dateTime($fromDate))
			,cts:element-range-query(xs:QName('lfp_news:SORTDATE'), '<=', xs:dateTime($toDate))
			,cts:not-query(cts:element-value-query(xs:QName('lfp_news:SORTDATE'), ''))
			)
		else ()

	let $conditions := (
		 cts:directory-query($config:RD-LAWFIRMPROFILE-NEWS-PATH,'infinity')
		,$date_q
		,$firm_q
		,$source_q
		,$keyword_q
	)

	let $response := cts:search(/LAWFIRMPROFILE_NEWS, cts:and-query(($conditions)))
	let $count := fn:count($response)
	let $response := element {'RESULT'} {$response}
	
	let $custom :=
		let $config := json:config('custom')
		let $_ := map:put( $config, 'whitespace', 'ignore' )
		let $_ := map:put( $config, 'array-element-names', ('LAWFIRMPROFILE_NEWS') )
		return $config
	
	let $response := if ($count > 1) then 
			xdmp:to-json-string(json:transform-to-json($response, $custom)//LAWFIRMPROFILE_NEWS) 
		else json:to-array(json:transform-to-json($response, $custom)//LAWFIRMPROFILE_NEWS)
	
	return $response

};

declare function firm:IsNewsExists(
	$firmID
)
{
	let $res := cts:search(/LAWFIRMPROFILE_NEWS,
		cts:and-query((
			 cts:directory-query($config:RD-LAWFIRMPROFILE-NEWS-PATH,'infinity')
			,cts:element-value-query(xs:QName('lfp_news:FIRMID'),$firmID)
		)))[1]
	  
	return if ($res) then '1' else '0'
};

declare function firm:sp_GetLawFirmStatics_LawSchool1(
	 $PageNo
	,$PageSize
	,$firmIds
	,$practiceAreas
	,$fromDate
	,$toDate
	,$firmSizefrom
	,$firmSizeTo
	,$FirmLocation
	,$Cities
	,$States
	,$Countries
	,$GeoGraphicRegions
	,$UsRegions
	,$lawschools
	,$sortBy
	,$sortDirection
)
{
	(: let $start := xs:integer($PageNo)
	let $end := xs:integer($PageSize) :)
	let $start := xs:integer(((xs:integer($PageNo)* xs:integer($PageSize))-xs:integer($PageSize))+1)
	let $end := xs:integer((xs:integer($start) + xs:integer($PageSize)) - 1 )
	
	let $fromDate := fn:tokenize($fromDate,'T')[1]
	let $toDate := fn:tokenize($toDate,'T')[1]

	let $location_val := if(($Cities !='') or ($States !='') or ($Countries != '') or ($GeoGraphicRegions !='') or  ($UsRegions !='')) then
	   cts:search(/city,
		 cts:and-query((
			cts:directory-query($config:RD-CITY-PATH)
		   ,cts:or-query((
			  cts:element-value-query(xs:QName('city:city'), $Cities, ('case-insensitive'))
			 ,cts:element-value-query(xs:QName('city:state'), $States, ('case-insensitive'))
			 ,cts:element-value-query(xs:QName('city:country'), $Countries, ('case-insensitive'))
			 ,cts:element-value-query(xs:QName('city:geographic_region'), $GeoGraphicRegions, ('case-insensitive'))
			 ,cts:element-value-query(xs:QName('city:us_region'), $UsRegions, ('case-insensitive'))
		 )))))/city:std_loc/text()
	  else (: fn:distinct-values(cts:search(/city,
			 cts:and-query((
				cts:directory-query($config:RD-CITY-PATH)
			 )))/city:std_loc/text()) :) ()

	let $date_q := if (($fromDate != '') and ($toDate != '')) then (
			 cts:element-range-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:last_action_date'), '>=', xs:date($fromDate))
			,cts:element-range-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:last_action_date'), '<=', xs:date($toDate))
		)
		else ()
	
	let $practiceAreas := if ($practiceAreas != '') then 
			let $key := fn:tokenize($practiceAreas,'[|]')
			let $res :=  cts:element-values(xs:QName('practices_kws:practice_area'),(),(), cts:and-query((
					cts:element-value-query(xs:QName('practices_kws:practice_area'),$key, ('wildcarded', 'case-insensitive'))
				)))
			return $res
		else ()
	
	
	let $firm_id_q := if ($firmIds != '') then
			let $firmIds := fn:tokenize($firmIds,',')
			return cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:RE_ID'),$firmIds)
		else ()
		
	let $re_id_q := if ($firmIds != '') then
			let $firmIds := fn:tokenize($firmIds,',')
			return cts:element-value-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:firm_id'),$firmIds)
		else ()
	
	let $attorney_conditions := (
		 cts:directory-query('/LegalCompass/denormalized-data/ALI_RE_Attorney_Data/')
		,if ($location_val != '') then cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:location'),$location_val,('case-insensitive')) else ()
		,cts:not-query(cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:std_school'),''))
		,if ($practiceAreas) then cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:practice_area'),$practiceAreas,('wildcarded', 'case-insensitive')) else ()
		,if ($lawschools != '') then cts:element-word-query(xs:QName('ALI_RE_Attorney_Data:std_school'),$lawschools,('whitespace-insensitive', 'wildcarded', 'case-insensitive')) else ()
		,$firm_id_q
	  )
	
	let $attorney_moveschanges_conditions := (
		 cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
		,if ($location_val != '') then cts:element-value-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:location'),$location_val,('case-insensitive')) else () 
		,cts:not-query(cts:element-value-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:std_school'),''))
		,$date_q
		,if ($practiceAreas) then cts:element-value-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:practice_area'),$practiceAreas,('wildcarded', 'case-insensitive')) else ()
		,if ($lawschools != '') then cts:element-word-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:std_school'),$lawschools,('whitespace-insensitive', 'wildcarded', 'case-insensitive')) else ()
		,$re_id_q
	  )

	let $attorney_search := cts:element-values(xs:QName('ALI_RE_Attorney_Data:std_school'),(),(), cts:and-query(($attorney_conditions)))
	let $attorney_moveschanges_search := cts:element-values(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:std_school'),(),(), cts:and-query(($attorney_moveschanges_conditions)))

	let $response := ( 
	  
	  let $school_obj_1 := for $res in $attorney_search
	  
		let $headCount := xdmp:estimate(cts:search(/,
		  cts:and-query((
			$attorney_conditions
			,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'), ('case-insensitive'))
			,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:std_school'), $res, ('case-insensitive'))
		  ))))

		let $partnerCount := xdmp:estimate(cts:search(/,
		  cts:and-query((
			$attorney_conditions
			,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:title'), ('Partner'), ('case-insensitive'))
			,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:std_school'), $res, ('case-insensitive'))
		  ))))

		let $associateCount := xdmp:estimate(cts:search(/,
		  cts:and-query((
			$attorney_conditions
			,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:title'), ('Associate'), ('case-insensitive'))
			,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:std_school'), $res, ('case-insensitive'))
		  ))))

		let $otherCouselCount := xdmp:estimate(cts:search(/,
		  cts:and-query((
			$attorney_conditions
			,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:title'), ('Other Counsel/Attorney'), ('case-insensitive'))
			,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:std_school'), $res, ('case-insensitive'))
		  ))))

		let $adminCount := xdmp:estimate(cts:search(/,
		  cts:and-query((
			$attorney_conditions
			,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:title'), ('Administrative / Support Staff'), ('case-insensitive'))
			,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:std_school'), $res, ('case-insensitive'))
		  ))))

		let $otherCount := xdmp:estimate(cts:search(/,
		  cts:and-query((
			$attorney_conditions
			,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:title'), ('Other'), ('case-insensitive'))
			,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:std_school'), $res, ('case-insensitive'))
		  ))))

		let $obj := element {'RECORD'} {
		   element {'std_school'} {$res}
		  ,element {'headCount'} {xs:integer($headCount)}
		  ,element {'partnerCount'} {$partnerCount}
		  ,element {'associateCount'} {$associateCount}
		  ,element {'otherCouselCount'} {$otherCouselCount}
		  ,element {'adminCount'} {$adminCount}
		  ,element {'otherCount'} {$otherCount}
		}
		
		where if (($firmSizefrom = 0) and ($firmSizeTo = 0)) then (1=1) else ($headCount ge xs:integer($firmSizefrom) and $headCount le xs:integer($firmSizeTo))
		
		return $obj
	  
	  let $school_obj_2 := for $res in $attorney_moveschanges_search
		
		let $headCountPlus := xdmp:estimate(cts:search(/,
		  cts:and-query((
			$attorney_moveschanges_conditions
			,cts:element-value-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'), ('case-insensitive'))
			,cts:element-value-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:std_school'), $res, ('case-insensitive'))
			,cts:element-value-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:last_action'), 'added', ('case-insensitive'))
		  ))))
		
		let $headCountMinus := xdmp:estimate(cts:search(/,
		  cts:and-query((
			$attorney_moveschanges_conditions
			,cts:element-value-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'), ('case-insensitive'))
			,cts:element-value-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:std_school'), $res, ('case-insensitive'))
			,cts:element-value-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:last_action'), 'removed', ('case-insensitive'))
		  ))))
		
		let $partnerCountPlus := xdmp:estimate(cts:search(/,
		  cts:and-query((
			$attorney_moveschanges_conditions
			,cts:element-value-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:title'), ('Partner'), ('case-insensitive'))
			,cts:element-value-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:std_school'), $res, ('case-insensitive'))
			,cts:element-value-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:last_action'), 'added', ('case-insensitive'))
		  ))))
		
		let $partnerCountMinus := xdmp:estimate(cts:search(/,
		  cts:and-query((
			$attorney_moveschanges_conditions
			,cts:element-value-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:title'), ('Partner'), ('case-insensitive'))
			,cts:element-value-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:std_school'), $res, ('case-insensitive'))
			,cts:element-value-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:last_action'), 'removed', ('case-insensitive'))
		  ))))
		
		let $associateCountPlus := xdmp:estimate(cts:search(/,
		  cts:and-query((
			$attorney_moveschanges_conditions
			,cts:element-value-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:title'), ('Associate'), ('case-insensitive'))
			,cts:element-value-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:std_school'), $res, ('case-insensitive'))
			,cts:element-value-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:last_action'), 'added', ('case-insensitive'))
		  ))))
		
		let $associateCountMinus := xdmp:estimate(cts:search(/,
		  cts:and-query((
			$attorney_moveschanges_conditions
			,cts:element-value-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:title'), ('Associate'), ('case-insensitive'))
			,cts:element-value-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:std_school'), $res, ('case-insensitive'))
			,cts:element-value-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:last_action'), 'removed', ('case-insensitive'))
		  ))))

		let $otherCouselCountPlus := xdmp:estimate(cts:search(/,
		  cts:and-query((
			$attorney_moveschanges_conditions
			,cts:element-value-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:title'), ('Other Counsel/Attorney'), ('case-insensitive'))
			,cts:element-value-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:std_school'), $res, ('case-insensitive'))
			,cts:element-value-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:last_action'), 'added', ('case-insensitive'))
		  ))))
		
		let $otherCouselCountMinus := xdmp:estimate(cts:search(/,
		  cts:and-query((
			$attorney_moveschanges_conditions
			,cts:element-value-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:title'), ('Other Counsel/Attorney'), ('case-insensitive'))
			,cts:element-value-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:std_school'), $res, ('case-insensitive'))
			,cts:element-value-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:last_action'), 'removed', ('case-insensitive'))
		  ))))
		
		let $adminCountPlus := xdmp:estimate(cts:search(/,
		  cts:and-query((
			$attorney_moveschanges_conditions
			,cts:element-value-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:title'), ('Administrative / Support Staff'), ('case-insensitive'))
			,cts:element-value-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:std_school'), $res, ('case-insensitive'))
			,cts:element-value-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:last_action'), 'added', ('case-insensitive'))
		  ))))
		
		let $adminCountMinus := xdmp:estimate(cts:search(/,
		  cts:and-query((
			$attorney_moveschanges_conditions
			,cts:element-value-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:title'), ('Administrative / Support Staff'), ('case-insensitive'))
			,cts:element-value-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:std_school'), $res, ('case-insensitive'))
			,cts:element-value-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:last_action'), 'removed', ('case-insensitive'))
		  ))))
		
		let $otherCountPlus := xdmp:estimate(cts:search(/,
		  cts:and-query((
			$attorney_moveschanges_conditions
			,cts:element-value-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:title'), ('Other'), ('case-insensitive'))
			,cts:element-value-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:std_school'), $res, ('case-insensitive'))
			,cts:element-value-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:last_action'), 'added', ('case-insensitive'))
		  ))))
		
		let $otherCountMinus := xdmp:estimate(cts:search(/,
		  cts:and-query((
			$attorney_moveschanges_conditions
			,cts:element-value-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:title'), ('Other'), ('case-insensitive'))
			,cts:element-value-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:std_school'), $res, ('case-insensitive'))
			,cts:element-value-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:last_action'), 'removed', ('case-insensitive'))
		  ))))
		  
		 let $obj := element {'RECORD'} {
		   element {'std_school'} {$res}
		  ,element {'headCountPlus'} {$headCountPlus}
		  ,element {'headCountMinus'} {$headCountMinus}
		  ,element {'partnerCountPlus'} {$partnerCountPlus}
		  ,element {'partnerCountMinus'} {$partnerCountMinus}
		  ,element {'associateCountPlus'} {$associateCountPlus}
		  ,element {'associateCountMinus'} {$associateCountMinus}
		  ,element {'otherCouselCountPlus'} {$otherCouselCountPlus}
		  ,element {'otherCouselCountMinus'} {$otherCouselCountMinus}
		  ,element {'adminCountPlus'} {$adminCountPlus}
		  ,element {'adminCountMinus'} {$adminCountMinus}
		  ,element {'otherCountPlus'} {$otherCountPlus}
		  ,element {'otherCountMinus'} {$otherCountMinus}
		}
		return $obj
	  
	  let $totalCount := fn:count($school_obj_1) 
	  
	  let $response-arr := (
		for $obj_1 in $school_obj_1
		
			let $schoolName := $obj_1/std_school/text()
			let $obj_2 := $school_obj_2[std_school eq $schoolName][1]
			
			let $obj := element {'RECORD'} {
			   element {'schoolName'} {$schoolName}
			  ,element {'totalCount'} {$totalCount}
			  ,$obj_1/node()[fn:local-name(.) ne 'std_school']
			  ,$obj_2/node()[fn:local-name(.) ne 'std_school']
			  ,element {'Changes'} { fn:round((( xs:double($obj_2/headCountPlus/text()) - xs:double($obj_2/headCountMinus/text())) div xs:double($obj_1/headCount/text())) * 100) }
			}
			
			order by $schoolName
			
			return $obj
		)[$start to $end]
	  
	  return ($response-arr)
	)
	
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

declare function firm:GetLevel1Level2Array($Representations)
{
	let $representationTypeArray := fn:tokenize($Representations,';')
	
	return for $RepresentationsTypeObj in $representationTypeArray
		let $level1level2Array := fn:tokenize($RepresentationsTypeObj,',')
		let $obj := if (fn:count($level1level2Array) > 1) then (
			if ((fn:count($representationTypeArray) = 1) and (fn:count($level1level2Array) > 2)) then (
				element {'obj'} {
					element {'level1'} {$level1level2Array[last()]},
					element {'level2'} {fn:string-join($level1level2Array[1 to last()-1],',')}
				}
			) else if ((fn:count($representationTypeArray) = 2) and (fn:count($level1level2Array) > 2) and ($representationTypeArray[1])) then (
				element {'obj'} {
					element {'level1'} {$level1level2Array[last()]},
					element {'level2'} {fn:string-join($level1level2Array[1 to last()-1],',')}
				}
			) else (
				if (fn:count($level1level2Array) > 2) then (
					element {'obj'} {
						element {'level1'} {$level1level2Array[last()]},
						element {'level2'} {fn:string-join($level1level2Array[1 to last()-1],',')}
					}
				) else (
					element {'obj'} {
						element {'level1'} {$level1level2Array[2]},
						element {'level2'} {$level1level2Array[1]}
					}
				)
			)
		) else ()
      
		let $res := firm:GetRepresentationTypeIDs($obj/level1/text(),$obj/level2/text())
			
		return $res  
};

declare function firm:GetClientResultChart(
	 $FirmID
	,$Representations
	,$YearFrom
	,$YearTo
)
{
	let $REPRESENTATION_TYPE_ID := if ($Representations != '' and (($Representations) or $Representations != 'All Types') and (cts:contains($Representations,';'))) then (
		
		let $representationTypeArray := fn:tokenize($Representations,';')
		
		return for $RepresentationsTypeObj in $representationTypeArray
			
			let $level1level2Array := fn:tokenize($RepresentationsTypeObj,',')
			
			let $obj := if (fn:count($level1level2Array) > 1) then (
				if ((fn:count($representationTypeArray) = 1) and (fn:count($level1level2Array) > 2)) then (
					element {'obj'} {
						element {'level1'} {$level1level2Array[last()]},
						element {'level2'} {fn:string-join($level1level2Array[1 to last()-1],',')}
					}
				) else if ((fn:count($representationTypeArray) = 2) and (fn:count($level1level2Array) > 2) and ($representationTypeArray[1])) then (
					element {'obj'} {
						element {'level1'} {$level1level2Array[last()]},
						element {'level2'} {fn:string-join($level1level2Array[1 to last()-1],',')}
					}
				) else (
					if (fn:count($level1level2Array) > 2) then (
						element {'obj'} {
							element {'level1'} {$level1level2Array[last()]},
							element {'level2'} {fn:string-join($level1level2Array[1 to last()-1],',')}
						}
					) else (
						element {'obj'} {
							element {'level1'} {$level1level2Array[2]},
							element {'level2'} {$level1level2Array[1]}
						}
					)
				)
			) else ()
      
			let $res := firm:GetCompanyLFRSummary($obj/level1/text(),$obj/level2/text())
			
			return $res  
	) else (
		for $item in cts:search(/REPRESENTATION_TYPES, cts:directory-query($config:RD-REPRESENTATION_TYPES-PATH))
			return element {'OBJ'} {
				 element {'REPRESENTATION_TYPE_ID'} {$item/REPRESENTATION_TYPES:REPRESENTATION_TYPE_ID/text()}
				,element {'LEVEL1'} {$item/REPRESENTATION_TYPES:LEVEL_1/text()}
				,element {'LEVEL2'} {$item/REPRESENTATION_TYPES:LEVEL_2/text()}
			}
	)
	
	
  
	let $COMPANYPROFILE_LFR_YEAR_QUERY := if (($YearFrom != '') and ($YearTo != '')) then (
		if ($YearFrom != $YearTo) then (
			 cts:element-range-query(xs:QName('COMPANYPROFILE_LFR:YEAR'), '>=', xs:integer($YearFrom))
			,cts:element-range-query(xs:QName('COMPANYPROFILE_LFR:YEAR'), '<=', xs:integer($YearTo))
		) else (
			cts:element-value-query(xs:QName('COMPANYPROFILE_LFR:YEAR'), xs:string($YearFrom))
		)
	) else ()
	
	let $COMPANYPROFILE_LFR_NEW_YEAR_QUERY := if (($YearFrom != '') and ($YearTo != '')) then (
		if ($YearFrom != $YearTo) then (
			 cts:element-range-query(xs:QName('COMPANYPROFILE_LFR_NEW:YEAR'), '>=', xs:integer($YearFrom))
			,cts:element-range-query(xs:QName('COMPANYPROFILE_LFR_NEW:YEAR'), '<=', xs:integer($YearTo))
		) else (
			cts:element-value-query(xs:QName('COMPANYPROFILE_LFR_NEW:YEAR'), xs:string($YearFrom))
		) 
	) else ()

	let $WHO_COUNSELS_WHO_YEAR_QUERY := if (($YearFrom != '') and ($YearTo != '')) then (
		if ($YearFrom != $YearTo) then (
			 cts:element-range-query(xs:QName('Who_Counsels_who:FISCAL_YEAR'), '>=', xs:integer($YearFrom))
			,cts:element-range-query(xs:QName('Who_Counsels_who:FISCAL_YEAR'), '<=', xs:integer($YearTo))
		) else (
			cts:element-value-query(xs:QName('Who_Counsels_who:FISCAL_YEAR'), xs:string($YearFrom))
		) 
	) else ()
  
	let $BDBS_TRANSACTION_YEAR_QUERY := if (($YearFrom != '') and ($YearTo != '')) then (
		if ($YearFrom != $YearTo) then (
			 cts:element-range-query(xs:QName('bdbs-transaction:YEAR'), '>=', xs:integer($YearFrom))
			,cts:element-range-query(xs:QName('bdbs-transaction:YEAR'), '<=', xs:integer($YearTo))
		) else (
			cts:element-value-query(xs:QName('bdbs-transaction:YEAR'), xs:string($YearFrom))
		) 
	  ) else ()
  
	let $COMPANYPROFILE_LFR_CONDITIONS := (
		 cts:directory-query($config:RD-SURVEY-COMPANYPROFILE_LFR-PATH)
		,cts:element-value-query(xs:QName('COMPANYPROFILE_LFR:FIRM_ID'),$FirmID)
		,if ($REPRESENTATION_TYPE_ID) then cts:element-value-query(xs:QName('COMPANYPROFILE_LFR:REPRESENTATION_TYPE_ID'), $REPRESENTATION_TYPE_ID/REPRESENTATION_TYPE_ID/text()) else ()
		,cts:not-query(cts:element-value-query(xs:QName('COMPANYPROFILE_LFR:FIRM'),'Unknown',('case-insensitive')))
		,cts:not-query(cts:element-value-query(xs:QName('COMPANYPROFILE_LFR:FIRM'),''))
		,cts:or-query((
			 cts:element-value-query(xs:QName('COMPANYPROFILE_LFR:SOURCE'), 'ALM Legal Intelligence', ('case-insensitive'))
			,cts:element-value-query(xs:QName('COMPANYPROFILE_LFR:SOURCE'), 'USPTO', ('case-insensitive'))
		))
		,$COMPANYPROFILE_LFR_YEAR_QUERY
	)
	
	let $COMPANYPROFILE_LFR_NEW_CONDITIONS := (
		cts:directory-query($config:RD-SURVEY-COMPANYPROFILE_LFR_NEW-PATH)
		,cts:element-value-query(xs:QName('COMPANYPROFILE_LFR_NEW:FIRM_ID'),$FirmID)
		,if ($REPRESENTATION_TYPE_ID) then cts:element-value-query(xs:QName('COMPANYPROFILE_LFR_NEW:REPRESENTATION_TYPE_ID'), $REPRESENTATION_TYPE_ID/REPRESENTATION_TYPE_ID/text()) else ()
		,cts:not-query(cts:element-value-query(xs:QName('COMPANYPROFILE_LFR_NEW:FIRM'),'Unknown',('case-insensitive')))
		,cts:not-query(cts:element-value-query(xs:QName('COMPANYPROFILE_LFR_NEW:FIRM'),''))
		,$COMPANYPROFILE_LFR_NEW_YEAR_QUERY
	)

	let $WHO_COUNSELS_WHO_CONDITIONS := (
		 cts:directory-query($config:RD-SURVEY-WHO_COUNSELS_WHO-PATH)
		,cts:element-value-query(xs:QName('Who_Counsels_who:OUTSIDE_COUNSEL_ID'),$FirmID)
		,if ($REPRESENTATION_TYPE_ID) then cts:element-value-query(xs:QName('Who_Counsels_who:REPRESENTATION_TYPE_ID'), $REPRESENTATION_TYPE_ID/REPRESENTATION_TYPE_ID/text()) else ()
	   ,$WHO_COUNSELS_WHO_YEAR_QUERY
	)

	let $BDBS_TRANSACTION_CONDITIONS := (
		 cts:directory-query($config:RD-BDBS_TRANSACTION-PATH)
		,if ($REPRESENTATION_TYPE_ID) then cts:element-value-query(xs:QName('bdbs-transaction:TRANSACTION_TYPE_ID'), $REPRESENTATION_TYPE_ID/REPRESENTATION_TYPE_ID/text()) else ()
		,$BDBS_TRANSACTION_YEAR_QUERY
	)
	
	let $response := (
		
		(: ------------------------------------------------================== 04 ==================--------------------------------------- :)
		let $BDBS_REPRESENTERS := (
			
			let $PARTY_IDs := cts:element-values(xs:QName('bdbs-representer:PARTY_ID'),(),(),
				cts:and-query((
					cts:directory-query($config:RD-BDBS_REPRESENTER-PATH),
					cts:element-value-query(xs:QName('bdbs-representer:ORGANIZATION_ID'),$FirmID),
					cts:not-query(cts:element-value-query(xs:QName('bdbs-representer:PARTY_ID'),''))
				)))
      
			let $TRANSACTION_IDs := cts:element-values(xs:QName('bdbs-transaction:TRANSACTION_ID'),(),(), 
				cts:and-query((
					$BDBS_TRANSACTION_CONDITIONS
				)))
      
			return for $x in cts:element-values(xs:QName('bdbs-party:ORGANIZATION_ID'),(),(),
				cts:and-query((
					cts:directory-query($config:RD-BDBS_PARTY-PATH),
					cts:element-value-query(xs:QName('bdbs-party:PARTY_ID'),($PARTY_IDs ! xs:string(.))),
					cts:element-value-query(xs:QName('bdbs-party:TRANSACTION_ID'),($TRANSACTION_IDs ! xs:string(.))),
					cts:not-query(cts:element-value-query(xs:QName('bdbs-party:ORGANIZATION_ID'),''))
				)))
        
				let $search := cts:search(/bdbs-party,
					cts:and-query((
						cts:directory-query($config:RD-BDBS_PARTY-PATH),
						cts:element-value-query(xs:QName('bdbs-party:PARTY_ID'),($PARTY_IDs ! xs:string(.))),
						cts:element-value-query(xs:QName('bdbs-party:TRANSACTION_ID'),($TRANSACTION_IDs ! xs:string(.))),
						cts:not-query(cts:element-value-query(xs:QName('bdbs-party:ORGANIZATION_ID'),'')),
						cts:element-value-query(xs:QName('bdbs-party:ORGANIZATION_ID'),xs:string($x))
					)))
        
				let $PARTY_TRANSACTION_IDs := fn:distinct-values($search/bdbs-party:TRANSACTION_ID/text()) 
				let $RepresentationTypeIDs := cts:search(/bdbs-transaction,
					cts:and-query((
						cts:directory-query($config:RD-BDBS_TRANSACTION-PATH)
						,cts:element-value-query(xs:QName('bdbs-transaction:TRANSACTION_ID'),$PARTY_TRANSACTION_IDs)
					)))/bdbs-transaction:TRANSACTION_TYPE_ID/text()
				
				let $LEVEL_1s := fn:distinct-values($REPRESENTATION_TYPE_ID[REPRESENTATION_TYPE_ID = $RepresentationTypeIDs]/LEVEL1/text())
				
				(: return xs:string($x) :)
      
				return for $LEVEL_1 in $LEVEL_1s
					return element {'RECORD'} {
						 element {'Company_Name'} {$search[1]/bdbs-party:ORGANIZATION_NAME/text()}
						(:,element {'Company_ID'} {$x}:)
						,element {'LEVEL_1'} {$LEVEL_1}
						,element {'TotalCount'} {fn:count($search/bdbs-party:TRANSACTION_ID[. = $PARTY_TRANSACTION_IDs])}
					}
		)
    
		(: ------------------------------------------------================== 03 ==================--------------------------------------- :)
		let $WHO_COUNSELS_WHO := for $x in cts:element-values(xs:QName('Who_Counsels_who:ORGANIZATION_NAME'), (), (), 
			cts:and-query(($WHO_COUNSELS_WHO_CONDITIONS)))
      
			let $search := cts:search(/WhoCounselsWho,
				cts:and-query((
					cts:element-value-query(xs:QName('Who_Counsels_who:ORGANIZATION_NAME'), $x, ('case-insensitive')) 
					,$WHO_COUNSELS_WHO_CONDITIONS
				)))
      
			let $RepresentationTypeIDs := fn:distinct-values($search/Who_Counsels_who:REPRESENTATION_TYPE_ID/text())
			let $LEVEL_1s := fn:distinct-values($REPRESENTATION_TYPE_ID[REPRESENTATION_TYPE_ID = $RepresentationTypeIDs]/LEVEL1/text())
      
			return for $LEVEL_1 in $LEVEL_1s
				
				let $IDs := $REPRESENTATION_TYPE_ID[LEVEL1 = $LEVEL_1]/REPRESENTATION_TYPE_ID/text()
				
				return element {'RECORD'} {
					element {'Company_Name'} {$x}
					,element {'LEVEL_1'} {$LEVEL_1}
					,element {'TotalCount'} {fn:count($search/Who_Counsels_who:REPRESENTATION_TYPE_ID[. = $IDs])}
				}
      
		(: ------------------------------------------------================== 02 ==================--------------------------------------- :)
		let $COMPANYPROFILE_LFR_NEW := for $x in cts:element-values(xs:QName('COMPANYPROFILE_LFR_NEW:COMPANY_NAME'), (), (), 
			cts:and-query(($COMPANYPROFILE_LFR_NEW_CONDITIONS)))
      
			let $search := cts:search(/COMPANYPROFILE_LFR_NEW,
				cts:and-query((
					cts:element-value-query(xs:QName('COMPANYPROFILE_LFR_NEW:COMPANY_NAME'),$x, ('case-insensitive')) 
					,$COMPANYPROFILE_LFR_NEW_CONDITIONS
				)))
      
			let $RepresentationTypeIDs := fn:distinct-values($search/COMPANYPROFILE_LFR_NEW:REPRESENTATION_TYPE_ID/text())
			let $LEVEL_1s := fn:distinct-values($REPRESENTATION_TYPE_ID[REPRESENTATION_TYPE_ID = $RepresentationTypeIDs]/LEVEL1/text())
      
			return for $LEVEL_1 in $LEVEL_1s
				
				let $IDs := $REPRESENTATION_TYPE_ID[LEVEL1 = $LEVEL_1]/REPRESENTATION_TYPE_ID/text()
				
				return element {'RECORD'} {
					 element {'Company_Name'} {$x}
					,element {'LEVEL_1'} {$LEVEL_1}
					,element {'TotalCount'} {fn:count($search/COMPANYPROFILE_LFR_NEW:REPRESENTATION_TYPE_ID[. = $IDs])}
				}
      
			(: return for $RepresentationTypeID in $RepresentationTypeIDs
				return element {'RECORD'} {
					element {'Company_Name'} {$x}
					,element {'LEVEL_1'} {$REPRESENTATION_TYPE_ID[REPRESENTATION_TYPE_ID = $RepresentationTypeID]/LEVEL1/text()}
					,element {'TotalCount'} {fn:count($search/COMPANYPROFILE_LFR_NEW:REPRESENTATION_TYPE_ID[. = $RepresentationTypeID])}
				} :)
        
		(: ------------------------------------------------================== 01 ==================--------------------------------------- :)
		let $COMPANYPROFILE_LFR := for $x in cts:element-values(xs:QName('COMPANYPROFILE_LFR:COMPANY_NAME'), (), (), 
			cts:and-query(($COMPANYPROFILE_LFR_CONDITIONS)))
      
			let $search := cts:search(/COMPANYPROFILE_LFR,
				cts:and-query((
					cts:element-value-query(xs:QName('COMPANYPROFILE_LFR:COMPANY_NAME'),$x, ('case-insensitive')) 
					,$COMPANYPROFILE_LFR_CONDITIONS
				)))
      
			let $RepresentationTypeIDs := fn:distinct-values($search/COMPANYPROFILE_LFR_NEW:REPRESENTATION_TYPE_ID/text())
			let $LEVEL_1s := fn:distinct-values($REPRESENTATION_TYPE_ID[REPRESENTATION_TYPE_ID = $RepresentationTypeIDs]/LEVEL1/text())
      
			return for $LEVEL_1 in $LEVEL_1s
				
				let $IDs := $REPRESENTATION_TYPE_ID[LEVEL1 = $LEVEL_1]/REPRESENTATION_TYPE_ID/text()
				
				return element {'RECORD'} {
					element {'Company_Name'} {$x}
					,element {'LEVEL_1'} {$LEVEL_1}
					,element {'TotalCount'} {fn:count($search/COMPANYPROFILE_LFR:REPRESENTATION_TYPE_ID[. = $IDs])}
				}
    
		return ($COMPANYPROFILE_LFR ,$COMPANYPROFILE_LFR_NEW ,$WHO_COUNSELS_WHO ,$BDBS_REPRESENTERS)
		(: return ($BDBS_REPRESENTERS) :)
	)
	
	let $response := (
		
		for $res in fn:distinct-values($response/Company_Name/text())
			
			let $IP_Count :=   fn:sum($response[(Company_Name eq $res) and (LEVEL_1 eq 'IP')]/TotalCount)
			let $Transactional_Count :=   fn:sum($response[(Company_Name eq $res) and (LEVEL_1 eq 'Transactional')]/TotalCount)
			let $LITIGATION_COUNT :=   fn:sum($response[(Company_Name eq $res) and (LEVEL_1 eq 'Litigation')]/TotalCount)
			let $TOTAL_COUNT := fn:sum(($IP_Count,$Transactional_Count,$LITIGATION_COUNT))
		
			let $obj := element {'RECORD'} {
				element {'COMPANY_NAME'} {$res}
				,element {'IP_Count'} {$IP_Count}
				,element {'Transactional_Count'} {$Transactional_Count}
				,element {'LITIGATION_COUNT'} {$LITIGATION_COUNT}
				,element {'TOTAL_COUNT'} {$TOTAL_COUNT}
			}
			
			order by  $TOTAL_COUNT descending, $res ascending
			return $obj
	)
	
	let $response := element {'RESULT'} {$response}

	let $custom :=
		let $config := json:config('custom')
		let $_ := map:put( $config, 'whitespace', 'ignore' )
		let $_ := map:put( $config, 'array-element-names', ('RECORD') )
		return $config

	let $response := xdmp:to-json-string(json:transform-to-json($response, $custom)//RECORD)
	
	return $response
};

declare function firm:GetRepresentationTypeIDs($level1, $level2)
{
	let $response-array := json:array()
	
	let $result := if ($level2 ne '') then
			cts:element-values(xs:QName('REPRESENTATION_TYPES:REPRESENTATION_TYPE_ID'),(),(),
				cts:and-query((
					cts:directory-query($config:RD-REPRESENTATION_TYPES-PATH)
					,cts:element-value-query(xs:QName('REPRESENTATION_TYPES:LEVEL_1'),$level1,'case-insensitive')
					,cts:element-value-query(xs:QName('REPRESENTATION_TYPES:LEVEL_2'),$level2,'case-insensitive')
				)))
		else 
			cts:element-values(xs:QName('REPRESENTATION_TYPES:REPRESENTATION_TYPE_ID'),(),(),
				cts:and-query((
					cts:directory-query($config:RD-REPRESENTATION_TYPES-PATH),
					cts:element-value-query(xs:QName('REPRESENTATION_TYPES:LEVEL_1'),$level1)
				)))
  
	return $result
};

declare function firm:GetCompanyLFRSummary($level1, $level2)
{
	let $response-array := json:array()
	
	let $result := if ($level2 ne '') then
			cts:search(/REPRESENTATION_TYPES,
				cts:and-query((
					cts:directory-query($config:RD-REPRESENTATION_TYPES-PATH)
					,cts:element-value-query(xs:QName('REPRESENTATION_TYPES:LEVEL_1'),$level1,'case-insensitive')
					,cts:element-value-query(xs:QName('REPRESENTATION_TYPES:LEVEL_2'),$level2,'case-insensitive')
				)))
		else 
			cts:search(/REPRESENTATION_TYPES,
				cts:and-query((
					cts:directory-query($config:RD-REPRESENTATION_TYPES-PATH),
					cts:element-value-query(xs:QName('REPRESENTATION_TYPES:LEVEL_1'),$level1)
				)))
  
	let $response :=  for $item in $result
		let $response-obj :=json:object()
		let $obj := element {'OBJ'} {
			element {'REPRESENTATION_TYPE_ID'} {$item/REPRESENTATION_TYPES:REPRESENTATION_TYPE_ID/text()}
			,element {'LEVEL1'} {$item/REPRESENTATION_TYPES:LEVEL_1/text()}
			,element {'LEVEL2'} {$item/REPRESENTATION_TYPES:LEVEL_2/text()}
		}
    
		return $obj
  
	return $response
};

declare function firm:GetLateralPartnerPracticeAdd($FirmIDs, $title)
{
	let $FirmIDs := $FirmIDs ! firm:GetREIdByOrgId(.)
	
	let $title_q := if (($title !='') and ($title)) then
			cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:Title'), $title, ('case-insensitive'))
		else ()
	
	let $sDate := xs:date(fn:concat((fn:year-from-date(fn:current-date())-4),'-01-01'))
	let $eDate := xs:date(fn:concat(fn:year-from-date(fn:current-date()),'-12-31'))

	let $practice_areas := cts:element-values(xs:QName('practices_kws:practice_area'))

	let $conditions := (
		 cts:directory-query($config:RD-ALI_RE_LATERALMOVES_DATA-PATH,'infinity')
		,cts:element-range-query(xs:QName('ALI_RE_LateralMoves_Data:date_added'), '>=', $sDate)
		,cts:element-range-query(xs:QName('ALI_RE_LateralMoves_Data:date_added'), '<=', $eDate)
	)

	let $response-arr := json:array()
	
	let $_ := (
  for $FirmID in $FirmIDs
    for $practice_area in $practice_areas
      let $key := fn:concat('*',$practice_area,'*')
      let $search := cts:search(/ALI_RE_LateralMoves_Data,
          cts:and-query((
             $conditions
			,$title_q 
            ,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:company_Id'),$FirmID)
            ,cts:element-word-query(xs:QName('ALI_RE_LateralMoves_Data:practices'), $key, ('wildcarded', 'case-insensitive'))
          )))
      
      let $firm_name := $search[1]/ALI_RE_LateralMoves_Data:Company_Name/text()
      let $AddPercentage := fn:count($search/ALI_RE_LateralMoves_Data:action[. = 'added'])
      let $MinusPercentage := fn:count($search/ALI_RE_LateralMoves_Data:action[. = 'removed'])
      
      let $response-obj := json:object()
      let $_ := (
         map:put($response-obj, 'firm_id', $FirmID)
        ,map:put($response-obj, 'firm_name', $firm_name)
        ,map:put($response-obj, 'Practice_area', $practice_area)
        ,map:put($response-obj, 'AddPercentage', $AddPercentage)
        ,map:put($response-obj, 'MinusPercentage', $MinusPercentage)
      )
      let $_ := json:array-push($response-arr,$response-obj)
      
      return ()
)

return $response-arr
};

declare function firm:GetLawyerMoveStats($FirmIDs, $title)
{
	let $FirmIDs := fn:tokenize($FirmIDs,',')
	
	let $RE_IDs := $FirmIDs ! firm:GetREIdByOrgId(.)
	let $qDate := fn:format-date(xs:date(xdmp:parse-dateTime('[Y01]-[M01]-[D01]',xs:string(fn:current-date() - xs:yearMonthDuration('P2Y')))),'[Y0001]-[M01]-[D01]')

	let $title_q := if (($title !='') and ($title)) then
			cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:Title'), $title, ('case-insensitive'))
		else ()
  
	let $conditions := (
		 cts:directory-query($config:RD-ALI_RE_LATERALMOVES_DATA-PATH,'infinity')
		,cts:element-range-query(xs:QName('ALI_RE_LateralMoves_Data:date_added'), '>=', xs:date($qDate))
		,$title_q
		,cts:not-query(cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:date_added'),'0000-00-00'))
	)

	let $added_q := cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:action'), 'added', ('case-insensitive'))
	let $removed_q := cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:action'), 'removed', ('case-insensitive'))

	let $company-obj := json:object()
	let $response-arr := json:array()

	let $response := (
		
		(: -------------------------------------------------------------- 01: FirmJoined -------------------------------------------------------------- :)
		let $FirmJoined := for $RE_ID in $RE_IDs
			for $x in cts:element-values(xs:QName('ALI_RE_LateralMoves_Data:CompanyId_From'), (), (),
				cts:and-query((
					 $conditions, $added_q
					,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:CompanyId_To'), $RE_ID) 
				)))
      
				let $response-obj := json:object()
		  
				let $search := cts:search(/ALI_RE_LateralMoves_Data,
					cts:and-query((
						 $conditions, $added_q
						,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:CompanyId_To'), $RE_ID) 
						,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:CompanyId_From'), xs:string($x))
						,cts:not-query(cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:CompanyName_From'), ''))
					)))
		  
				let $Name := $search[1]/ALI_RE_LateralMoves_Data:CompanyName_From/text()
		  
				let $_ := (
					 map:put($response-obj,'Name', $Name)
					,map:put($response-obj,'Total', fn:count($search))
					,map:put($response-obj,'Type', 'FirmJoined')
				)
				let $_ := json:array-push($response-arr,$response-obj)
		  
				return ()
      
		(: -------------------------------------------------------------- 02: FirmLeft -------------------------------------------------------------- :)
		let $FirmLeft := for $RE_ID in $RE_IDs
			for $x in cts:element-values(xs:QName('ALI_RE_LateralMoves_Data:CompanyId_To'), (), (), 
				cts:and-query((
					$conditions, $removed_q
					,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:CompanyId_From'), $RE_ID) 
				)))
      
				let $response-obj := json:object()
      
				let $search := cts:search(/ALI_RE_LateralMoves_Data,
					cts:and-query((
						 $conditions, $removed_q
						,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:CompanyId_From'), $RE_ID)
						,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:CompanyId_To'), xs:string($x))
					)))
      
				let $Name := $search[1]/ALI_RE_LateralMoves_Data:CompanyName_To/text()

				let $_ := (
					 map:put($response-obj,'Name', $Name)
					,map:put($response-obj,'Total', fn:count($search))
					,map:put($response-obj,'Type', 'FirmLeft')
				)
				let $_ := json:array-push($response-arr,$response-obj)
      
				return ()
  
		(: -------------------------------------------------------------- 03: CityLeft -------------------------------------------------------------- :)
		let $CityLeft := for $RE_ID in $RE_IDs
			for $x in cts:element-values(xs:QName('ALI_RE_LateralMoves_Data:loc'), (), ('collation=http://marklogic.com/collation//S1/AS/T0020'), 
				cts:and-query((
					$conditions, $removed_q
					,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:CompanyId_From'), $RE_ID)
					,cts:not-query(cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:loc'),''))
				)))
				let $response-obj := json:object()
				let $Total := fn:count(cts:search(/,
					cts:and-query((
						$conditions, $removed_q
						,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:CompanyId_From'), $RE_ID)
						,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:loc'), xs:string($x),('case-insensitive','whitespace-insensitive'))
						,cts:not-query(cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:loc'),''))
					))))
			  
				let $Name := $x
				let $_ := (
					 map:put($response-obj,'Name',$Name)
					,map:put($response-obj,'Total',$Total)
					,map:put($response-obj,'Type','CityLeft')
				)
				let $_ := json:array-push($response-arr,$response-obj)
				return ()
  
		(: -------------------------------------------------------------- 04: CityJoined -------------------------------------------------------------- :)
		let $CityJoined := for $RE_ID in $RE_IDs
			for $x in cts:element-values(xs:QName('ALI_RE_LateralMoves_Data:loc'), (), ('collation=http://marklogic.com/collation//S1/AS/T0020'), cts:and-query((
        $conditions, $added_q
        ,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:CompanyId_To'), $RE_ID) 
		,cts:not-query(cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:loc'),''))
      )))
      let $response-obj := json:object()
      let $Total := fn:count(cts:search(/,
        cts:and-query((
          $conditions, $added_q
          ,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:CompanyId_To'), $RE_ID) 
          ,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:loc'), xs:string($x),('case-insensitive','whitespace-insensitive'))
		  ,cts:not-query(cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:loc'),''))
        ))))
      
      let $Name := $x
      let $_ := (
         map:put($response-obj,'Name',$Name)
        ,map:put($response-obj,'Total',$Total)
        ,map:put($response-obj,'Type','CityJoined')
      )
      let $_ := json:array-push($response-arr,$response-obj)
      return ()
    
		(: -------------------------------------------------------------- 05: PAJoined -------------------------------------------------------------- :)
		let $PAJoined := for $RE_ID in $RE_IDs
    for $x in cts:element-values(xs:QName('practices_kws:practice_area'))
      let $key := fn:concat('*',$x,'*')
      let $PAJoinedCount := fn:count(cts:search(/,
        cts:and-query((
           $conditions
          ,$added_q
          ,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:CompanyId_To'), $RE_ID)
          ,cts:element-word-query(xs:QName('ALI_RE_LateralMoves_Data:practices'), $key, ('wildcarded', 'case-insensitive'))
        ))))
      let $_ := if ($PAJoinedCount >0 ) then (
          let $response-obj := json:object()
          let $_ := (
             map:put($response-obj,'Name', $x)
            ,map:put($response-obj,'Total', $PAJoinedCount)
            ,map:put($response-obj,'Type', 'PAJoined')
          )
          let $_ := json:array-push($response-arr,$response-obj)
          return ()
        )
        else ()
      return ()
    
		(: -------------------------------------------------------------- 06: PALeft -------------------------------------------------------------- :)
		let $PALeft := for $RE_ID in $RE_IDs
    for $x in cts:element-values(xs:QName('practices_kws:practice_area'))
      let $key := fn:concat('*',$x,'*')
      let $PALeftCount := fn:count(cts:search(/,
        cts:and-query((
           $conditions
          ,$removed_q
          ,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:CompanyId_From'), $RE_ID)
          ,cts:element-word-query(xs:QName('ALI_RE_LateralMoves_Data:practices'), $key, ('wildcarded', 'case-insensitive'))
        ))))
      let $_ := if ($PALeftCount >0 ) then (
          let $response-obj := json:object()
          let $_ := (
             map:put($response-obj,'Name', $x)
            ,map:put($response-obj,'Total', $PALeftCount)
            ,map:put($response-obj,'Type', 'PALeft')
          )
          let $_ := json:array-push($response-arr,$response-obj)
          return ()
        )
        else ()
      return ()
  
		(: -------------------------------------------------------------- 07: TotalJoined -------------------------------------------------------------- :)
		let $TotalJoined := for $RE_ID in $RE_IDs
			let $Name := firm:GetCompanyName($RE_ID)
			let $TotalJoinedCount := fn:count(cts:search(/,
			  cts:and-query((
				$conditions,$added_q,
				cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:CompanyId_To'), $RE_ID)
			  ))))
			
			let $_ := if ($TotalJoinedCount>0) then (
				let $response-obj := json:object()
				let $_ := (
				  map:put($response-obj, 'Name', $Name)
				  ,map:put($response-obj, 'Total', $TotalJoinedCount)
				  ,map:put($response-obj, 'Type', 'TotalJoined')
				)
				let $_ := json:array-push($response-arr,$response-obj)
				return ()
			  ) else ()  
			return ()
  
		(: -------------------------------------------------------------- 08: TotalLeft -------------------------------------------------------------- :)
		let $TotalLeft := for $RE_ID in $RE_IDs
    let $Name := firm:GetCompanyName($RE_ID)
    let $TotalLeftCount := fn:count(cts:search(/,
      cts:and-query((
        $conditions,$removed_q,
        cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:CompanyId_From'), $RE_ID)
      ))))
    
    let $_ := if ($TotalLeftCount>0) then (
        let $response-obj := json:object()
        let $_ := (
           map:put($response-obj,'Name',$Name)
          ,map:put($response-obj,'Total',$TotalLeftCount)
          ,map:put($response-obj,'Type','TotalLeft')
        )
        let $_ := json:array-push($response-arr,$response-obj)
        return ()
      ) else ()  
    return ()
    
		return ()
	)

	return ($response-arr)
};

declare function firm:GetCompanyName($company_id)
{
  let $name := if (map:get($company-obj,xs:string($company_id)) !='') then
      map:get($company-obj,xs:string($company_id))
    else (
      let $company := cts:search(/company,
        cts:and-query((
            cts:directory-query($config:RD-COMPANY-PATH,'1')
          ,cts:element-value-query(xs:QName('company:company_id'), xs:string($company_id))
        )))[1]/company:company/text()
      let $_ := map:put($company-obj,xs:string($company_id),$company)
      return $company
    )
  return $name  
};

(: Sunil Chouhan @ 2017-11-23 :)
declare function firm:GetChangesinHeadcountByPractices($OrganisationID)
{
	let $OrganisationID := fn:tokenize($OrganisationID,',')
	let $RE_ID := ($OrganisationID ! firm:GetREIdByOrgId(.))

	let $practice-areas := cts:element-values(xs:QName('practices_kws:practice_area'))

	let $sDate := fn:concat((fn:year-from-date(fn:current-date())-4),'-01-01')
	let $eDate := fn:concat(fn:year-from-date(fn:current-date()),'-12-31')

	let $PreviousYearValue := (fn:year-from-date(fn:current-date())-4)
	let $CurrentYearValue := fn:year-from-date(fn:current-date())

	let $company-data := cts:search(/company,
		cts:and-query((
			cts:directory-query($config:RD-COMPANY-PATH,'1')
			,cts:element-value-query(xs:QName('company:company_id'),$RE_ID)
		)))[1]
		
	let $response := (
		
		for $practice-area in $practice-areas
			
			let $key := fn:concat('*',$practice-area,'*')      
      let $search-result := cts:search(/,
				cts:and-query((					 
					cts:directory-query("/LegalCompass/denormalized-data/ALI_RE_Attorney_Data/")
					,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:firm_id'), $RE_ID)
					,cts:element-word-query(xs:QName('ALI_RE_Attorney_Data:practice_area'), $key, ('wildcarded', 'case-insensitive'))
					,cts:not-query(cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:practice_area'), ''))
				)))
			let $FirmId := $RE_ID
			let $FirmName := $company-data/company:company/text()
			let $PracticeArea := $practice-area
			let $headCount := fn:count($search-result//ALI_RE_Attorney_Data:title[. = ('Partner', 'Associate', 'Other Counsel/Attorney')])
      
      let $people_changes := cts:search(/,
				cts:and-query((
					 cts:directory-query("/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/")
					,cts:element-value-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:firm_id'),$RE_ID)
					,cts:element-word-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:practices'), $key, ('wildcarded', 'case-insensitive'))
					,cts:not-query(cts:element-value-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:last_action_date'), '0000-00-00'))
					,cts:not-query(cts:element-value-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:last_action_date'), ''))
					,cts:element-range-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:last_action_date'), '>=', xs:date($sDate))
					,cts:element-range-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:last_action_date'), '<=', xs:date($eDate))
				)))
         
		let $return-res := if ($people_changes) then (			
			
        let $HeadCountPlus := fn:count($people_changes//TBL_RER_CACHE_ATTORNEY_MOVESCHANGES[(TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:title = ('Partner', 'Associate', 'Other Counsel/Attorney')) and (TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:last_action = 'added')])
				let $HeadCountMinus := fn:count($people_changes//TBL_RER_CACHE_ATTORNEY_MOVESCHANGES [(TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:title = ('Partner', 'Associate', 'Other Counsel/Attorney')) and (TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:last_action = 'removed')])

				let $PreviousYearCount := ($headCount - ($HeadCountPlus - $HeadCountMinus))
				let $ChangeInCount := ($headCount - ($headCount - ($HeadCountPlus - $HeadCountMinus)))
				let $FinalChange := if ($ChangeInCount lt 0) then -1*($ChangeInCount) else $ChangeInCount

				return element {'RECORD'} {
					 element {'FirmId'} {$FirmId}
					,element {'FirmName'} {$FirmName}
					,element {'PracticeArea'} {$PracticeArea}
					,element {'CurrentYearCount'} {$headCount}
					,element {'PreviousYearCount'} {$PreviousYearCount}
					,element {'ChangeInCount'} {$ChangeInCount}
					,element {'HeadCountPlus'} {$HeadCountPlus}
					,element {'HeadCountMinus'} {$HeadCountMinus}
					,element {'FinalChange'} {$FinalChange}
					,element {'PreviousYearValue'} {$PreviousYearValue}
					,element {'CurrentYearValue'} {$CurrentYearValue}
				}
			)
			else ()
    
		order by $headCount descending
    
		return $return-res
  
	)[1 to 10]

	let $response := element {'RESULT'} {$response}
	
	let $custom :=
		let $config := json:config('custom')
		let $_ := map:put( $config, 'whitespace', 'ignore' )
		let $_ := map:put( $config, 'array-element-names', ('RECORD') )
		return $config
	
	let $response := xdmp:to-json-string(json:transform-to-json($response, $custom)//RECORD)	
	return $response
};

declare function firm:GetFinancialMetrices($OrganisationID,$StartYear,$EndYear)
{
	let $date-query := if (fn:not($StartYear) and fn:not($EndYear)) then

			let $all-years := cts:element-values(xs:QName('AMLAW_200:PUBLISHYEAR'),(),('ascending'),
				cts:directory-query($config:RD-SURVEY-AMLAW_200-PATH))

			let $sYear := (fn:max($all-years)-4)
			let $eYear := fn:max($all-years)

			return cts:or-query((
				cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($sYear)),
				cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($eYear))
			))
		else (
			cts:element-range-query(xs:QName('AMLAW_200:PUBLISHYEAR'), '>=', xs:integer($StartYear)),
			cts:element-range-query(xs:QName('AMLAW_200:PUBLISHYEAR'), '<=', xs:integer($EndYear))
		)

	let $survey-data := cts:search(/AMLAW_200:AMLaw200,
		cts:and-query((
				cts:directory-query($config:RD-SURVEY-AMLAW_200-PATH)
				,cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),xs:string($OrganisationID))
				,$date-query
			)),
			(
				cts:index-order(cts:element-reference(xs:QName('AMLAW_200:PUBLISHYEAR')) ,'ascending')
			)
		)

	let $org := cts:search(/organization,
		cts:and-query((
			cts:directory-query($config:DD-ORGANIZATION-PATH)
			,cts:element-value-query(xs:QName('organization:ORGANIZATION_ID'),$OrganisationID)
		)))[1]

	let $ORGANIZATION_NAME := if ($org/organization:ALM_NAME) then $org/organization:ALM_NAME/text() else $org/organization:ORGANIZATION_NAME/text()

	let $response-arr := json:array()
	let $prev-row-obj := json:object()

	let $_ := for $survey in $survey-data

		let $response-obj := json:object()

		let $COST := ( $survey/AMLAW_200:GROSS_REVENUE - $survey/AMLAW_200:NET_OPERATING_INCOME )
		let $PPL := fn:round-half-to-even(($survey/AMLAW_200:NET_OPERATING_INCOME div $survey/AMLAW_200:NUM_OF_LAWYERS ), 2)
		let $CPL := fn:round-half-to-even((($survey/AMLAW_200:GROSS_REVENUE - $survey/AMLAW_200:NET_OPERATING_INCOME ) div $survey/AMLAW_200:NUM_OF_LAWYERS ), 2)
		let $ASSOCIATES := ($survey/AMLAW_200:NUM_OF_LAWYERS - $survey/AMLAW_200:TOTAL_PARTNERS)
		let $PPEQ := fn:round-half-to-even(($survey/AMLAW_200:NET_OPERATING_INCOME div $survey/AMLAW_200:NUM_EQ_PARTNERS ), 2)
		let $REVENUE := $survey/AMLAW_200:GROSS_REVENUE/text()
		let $MARGIN := $survey/AMLAW_200:PROFIT_MARGIN/text()
		let $NUM_EQ_PARTNERS := $survey/AMLAW_200:NUM_EQ_PARTNERS/text()
		let $NUM_NON_EQ_PARTNERS := $survey/AMLAW_200:NUM_NON_EQ_PARTNERS/text()
		let $PROFIT := $survey/AMLAW_200:NET_OPERATING_INCOME/text()
		let $LEVERAGE := $survey/AMLAW_200:LEVERAGE/text()
		let $RPL := $survey/AMLAW_200:RPL/text()
		let $PPP := $survey/AMLAW_200:PPP/text()

		let $REVENUECHANGE := if ((map:get($prev-row-obj,'REVENUE') ne 0) and (map:get($prev-row-obj,'REVENUE') ne '')) then
				fn:round-half-to-even((((math:pow(($REVENUE div map:get($prev-row-obj,'REVENUE')),0.25))-1)*100),2)
			else 0

		let $MARGINCHAGNE := if ((map:get($prev-row-obj,'MARGIN') ne 0) and (map:get($prev-row-obj,'MARGIN') ne 0)) then
				fn:round-half-to-even((((math:pow(($MARGIN div map:get($prev-row-obj,'MARGIN') ), 0.25) )- 1 )* 100 ),2)
			else 0

		let $NUMEQPARTNERSCHAGNE := if ((map:get($prev-row-obj,'NUM_EQ_PARTNERS') ne 0) and (map:get($prev-row-obj,'NUM_EQ_PARTNERS') ne 0)) then
				(:fn:round-half-to-even((((math:pow(($NUM_EQ_PARTNERS div map:get($prev-row-obj,'NUM_EQ_PARTNERS') ), 0.25) )- 1 )* 100)):)
				fn:round-half-to-even((((math:pow(($NUM_EQ_PARTNERS div map:get($prev-row-obj,'NUM_EQ_PARTNERS')), 0.25) )- 1 )* 100 ),2)
			else 0 

		let $NUMNONEQPARTNERSCHANGE := if ((map:get($prev-row-obj,'NUM_NON_EQ_PARTNERS') ne 0) and (map:get($prev-row-obj,'NUM_NON_EQ_PARTNERS') ne 0)) then
				fn:round-half-to-even((((math:pow(($NUM_NON_EQ_PARTNERS div map:get($prev-row-obj,'NUM_NON_EQ_PARTNERS')), 0.25) )- 1 )* 100 ),2)
			else 0 

		let $PROFITCHANGE := if ((map:get($prev-row-obj,'PROFIT') ne 0) and (map:get($prev-row-obj,'PROFIT') ne 0)) then
				fn:round-half-to-even((((math:pow(($PROFIT div map:get($prev-row-obj,'PROFIT') ), 0.25) )- 1 )* 100 ),2)
			else 0

		let $COSTCHANGE := if ((map:get($prev-row-obj,'COST') ne 0) and (map:get($prev-row-obj,'COST') ne 0)) then
				fn:round-half-to-even((((math:pow(($COST div map:get($prev-row-obj,'COST') ), 0.25) )- 1 )* 100 ),2)
			else 0

		let $LEVERAGECHANGE := if ((map:get($prev-row-obj,'LEVERAGE') ne 0) and (map:get($prev-row-obj,'LEVERAGE') ne 0)) then
				fn:round-half-to-even((((math:pow(($LEVERAGE div map:get($prev-row-obj,'LEVERAGE') ), 0.25) )- 1 )* 100 ),2)
			else 0

		let $RPLCHANGE := if ((map:get($prev-row-obj,'RPL') ne 0) and (map:get($prev-row-obj,'RPL') ne 0)) then
				fn:round-half-to-even((((math:pow(($RPL div map:get($prev-row-obj,'RPL') ), 0.25) )- 1 )* 100 ),2)
			else 0

		let $PPLCHANGE := if ((map:get($prev-row-obj,'PPL') ne 0) and (map:get($prev-row-obj,'PPL') ne 0)) then
				fn:round-half-to-even((((math:pow(($PPL div map:get($prev-row-obj,'PPL') ), 0.25) )- 1 )* 100 ),2)
			else 0

		let $PPPCHANGE := if ((map:get($prev-row-obj,'PPP') ne 0) and (map:get($prev-row-obj,'PPP') ne 0)) then
				fn:round-half-to-even((((math:pow(($PPP div map:get($prev-row-obj,'PPP') ), 0.25) )- 1 )* 100 ),2)
			else 0

		let $CPLCHANGE := if ((map:get($prev-row-obj,'CPL') ne 0) and (map:get($prev-row-obj,'CPL') ne 0)) then
				fn:round-half-to-even((((math:pow(($CPL div map:get($prev-row-obj,'CPL') ), 0.25) )- 1 )* 100 ),2)
			else 0

		let $ASSOCIATESCHANGE := if ((map:get($prev-row-obj,'ASSOCIATES') ne 0) and (map:get($prev-row-obj,'ASSOCIATES') ne 0)) then
				fn:round-half-to-even((((math:pow(($ASSOCIATES div map:get($prev-row-obj,'ASSOCIATES') ), 0.25) )- 1 )* 100 ),2)
			else 0

		let $PPEQCHANGE := if ((map:get($prev-row-obj,'PPEQ') ne 0) and (map:get($prev-row-obj,'PPEQ') ne 0)) then
				fn:round-half-to-even((((math:pow(($PPEQ div map:get($prev-row-obj,'PPEQ') ), 0.25) )- 1 )* 100 ),2) 
			else 0

		let $_ := (
			 map:put($response-obj, 'ORGANIZATION_NAME', $ORGANIZATION_NAME)
			,map:put($response-obj, 'ORGANIZATION_ID', $OrganisationID)
			,map:put($response-obj, 'REVENUE', $REVENUE)
			,map:put($response-obj, 'MARGIN', $MARGIN)
			,map:put($response-obj, 'NUM_EQ_PARTNERS', $NUM_EQ_PARTNERS)
			,map:put($response-obj, 'NUM_NON_EQ_PARTNERS', $NUM_NON_EQ_PARTNERS)
			,map:put($response-obj, 'PROFIT', $PROFIT)
			,map:put($response-obj, 'COST', $COST)
			,map:put($response-obj, 'LEVERAGE', $LEVERAGE)
			,map:put($response-obj, 'RPL', $RPL)
			,map:put($response-obj, 'PPL', $PPL)
			,map:put($response-obj, 'PPP', $PPP)
			,map:put($response-obj, 'CPL', $CPL)
			,map:put($response-obj, 'ASSOCIATES', $ASSOCIATES)
			,map:put($response-obj, 'PPEQ', $PPEQ)
			,map:put($response-obj, 'REVENUECHANGE', $REVENUECHANGE )
			,map:put($response-obj, 'MARGINCHANGE', $MARGINCHAGNE)
			,map:put($response-obj, 'NUMEQPARTNERSCHANGE', $NUMEQPARTNERSCHAGNE)
			,map:put($response-obj, 'NUMNONEQPARTNERSCHANGE', $NUMNONEQPARTNERSCHANGE)
			,map:put($response-obj, 'PROFITCHANGE', $PROFITCHANGE)
			,map:put($response-obj, 'COSTCHANGE', $COSTCHANGE)
			,map:put($response-obj, 'LEVERAGECHANGE', $LEVERAGECHANGE)
			,map:put($response-obj, 'RPLCHANGE', $RPLCHANGE)
			,map:put($response-obj, 'PPLCHANGE', $PPLCHANGE)
			,map:put($response-obj, 'PPPCHANGE', $PPPCHANGE)
			,map:put($response-obj, 'CPLCHANGE', $CPLCHANGE)
			,map:put($response-obj, 'ASSOCIATESCHANGE', $ASSOCIATESCHANGE)
			,map:put($response-obj, 'PPEQCHANGE', $PPEQCHANGE)
			,map:put($response-obj, 'PUBLISHYEAR', $survey/AMLAW_200:PUBLISHYEAR/text())
		)

		let $_ := for $key in map:keys($response-obj)
			return map:put($prev-row-obj, $key, map:get($response-obj,$key))

		let $_ := json:array-push($response-arr, $response-obj)
		
		return ()

	return $response-arr
};

declare function firm:GetProfitPerEquityPartnerChanges($OrganisationID,$StartYear,$EndYear)
{
	let $all-years := cts:element-attribute-values(xs:QName('survey:YEAR'),xs:QName('PublishYear'),(),('ascending'),cts:directory-query($config:DD-SURVEY-AMLAW_200-PATH))

	let $org := cts:search(/organization,
		cts:and-query((
			 cts:directory-query($config:DD-ORGANIZATION-PATH)
			,cts:element-value-query(xs:QName('organization:ORGANIZATION_ID'),$OrganisationID)
		)))[1]

	let $years := if (fn:not($StartYear) and fn:not($EndYear)) then
			$all-years[last()-4 to last()]
		else helper:GetDatesBetweenTwoDates(xs:integer($StartYear),xs:integer($EndYear))

	let $response-arr := json:array()

	let $data := for $PUBLISHYEAR in $years

		let $pYear := xs:string(($PUBLISHYEAR - 1))
		let $qYear := xs:string($PUBLISHYEAR)

(: -------------------------------------------------------------- 01 -------------------------------------------------------------- :)
		let $ORGANIZATION_NAME :=  if ($org/organization:ALM_NAME ne '') then $org/organization:ALM_NAME/text() else $org/organization:ORGANIZATION_NAME/text()

		let $RPL := ''
		let $LAGV := ''
		let $CHANGE := ''

		let $RPL := cts:search(//survey:YEAR,
			cts:and-query((
				cts:directory-query($config:DD-SURVEY-AMLAW_200-PATH)
				,cts:element-attribute-value-query(xs:QName('survey:YEAR'),xs:QName('OrganizationID'),$OrganisationID)
				,cts:element-attribute-value-query(xs:QName('survey:YEAR'),xs:QName('PublishYear'),$qYear)
			)))[1]/survey:PPP/text()

		let $LAGV := cts:search(//survey:YEAR,
			cts:and-query((
				cts:directory-query($config:DD-SURVEY-AMLAW_200-PATH)
				,cts:element-attribute-value-query(xs:QName('survey:YEAR'),xs:QName('OrganizationID'),$OrganisationID)
				,cts:element-attribute-value-query(xs:QName('survey:YEAR'),xs:QName('PublishYear'),$pYear)
			)))[1]/survey:PPP/text()

		let $CHANGE := fn:round-half-to-even((((xs:double($RPL) - xs:double($LAGV)) div xs:double($LAGV)) * 100),2)

		let $response-obj := json:object()
		let $_ := (
			map:put($response-obj, 'ORGANIZATION_ID', $OrganisationID),
			map:put($response-obj, 'ORGANIZATION_NAME', $ORGANIZATION_NAME),
			map:put($response-obj, 'CHANGE', $CHANGE),
			map:put($response-obj, 'PUBLISHYEAR', $PUBLISHYEAR)
		)
		let $_ := json:array-push($response-arr,$response-obj)

(: -------------------------------------------------------------- 02 Golobal_100Part -------------------------------------------------------------- :)
		
		let $RPL := ''
		let $LAGV := ''
		let $CHANGE := ''
		
		let $response-obj := json:object()
  
  let $distinctid_global_100  := cts:element-values(xs:QName("Global_100:ORGANIZATION_ID"),(),(),
    cts:and-query((
      cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/")      
      ,cts:element-value-query(xs:QName("Global_100:PUBLISHYEAR"),xs:string($qYear))
      ,cts:not-query(cts:element-value-query(xs:QName("Global_100:RANK_BY_GROSS_REVENUE"),""))
    )))
  
   let $res4 := xs:decimal(avg(cts:search(/,
    cts:and-query((
      cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/") 
      ,cts:element-value-query(xs:QName("Global_100:ORGANIZATION_ID"),($distinctid_global_100 ! xs:string(.)))
      ,cts:element-value-query(xs:QName("Global_100:PUBLISHYEAR"), xs:string($qYear))
    )))//Global_100:PPP/text()))
 
   let $distinctid_global_100  := cts:element-values(xs:QName("Global_100:ORGANIZATION_ID"),(),(),
    cts:and-query((
      cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/")      
      ,cts:element-value-query(xs:QName("Global_100:PUBLISHYEAR"),xs:string($pYear))
      ,cts:not-query(cts:element-value-query(xs:QName("Global_100:RANK_BY_GROSS_REVENUE"),""))
    )))
  
   let $lag4 := xs:integer(avg(cts:search(/,
    cts:and-query((
      cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/") 
      ,cts:element-value-query(xs:QName("Global_100:ORGANIZATION_ID"),($distinctid_global_100 ! xs:string(.)))
      ,cts:element-value-query(xs:QName("Global_100:PUBLISHYEAR"), xs:string($pYear))
    )))//Global_100:PPP/text()))
    
   let $CHANGE := fn:round-half-to-even((xs:double($res4 - $lag4) div  $lag4 ) * 100 , 2)   
   let $response-obj := json:object()
	 let $_ := (
			map:put($response-obj, 'ORGANIZATION_ID', 0),
			map:put($response-obj, 'ORGANIZATION_NAME', 'Global 100'),
			map:put($response-obj, 'CHANGE', $CHANGE),
			map:put($response-obj, 'PUBLISHYEAR', $PUBLISHYEAR)
		)
		let $_ := json:array-push($response-arr,$response-obj)		
    
(: -------------------------------------------------------------- 03 -------------------------------------------------------------- :)
		
	let $distinctid_lt_100  :=cts:element-values(xs:QName('firm-org:OrganizationID'),(),(),
	cts:and-query((
	cts:directory-query('/LegalCompass/denormalized-data/law-firm/survey/')
	,cts:element-range-query(xs:QName('firm-org:AMLAW200_RANK'), '<=',100)
	,cts:element-value-query(xs:QName('firm-org:PUBLISHYEAR'),xs:string($qYear))
	,cts:not-query(cts:element-value-query(xs:QName('firm-org:AMLAW200_RANK'),''))
	)))

  let $res2 := xs:decimal(avg(cts:search(/,
		cts:and-query((
		cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/','1')
		,cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),($distinctid_lt_100 ! xs:string(.)))
		,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'), xs:string($qYear))
		)))//AMLAW_200:PPP/text()))
	let $response-obj := json:object()
		
	let $distinctid_lt_100  :=cts:element-values(xs:QName('firm-org:OrganizationID'),(),(),
		cts:and-query((
		cts:directory-query('/LegalCompass/denormalized-data/law-firm/survey/')
		,cts:element-range-query(xs:QName('firm-org:AMLAW200_RANK'), '<=',100)
		,cts:element-value-query(xs:QName('firm-org:PUBLISHYEAR'),xs:string($pYear))
		,cts:not-query(cts:element-value-query(xs:QName('firm-org:AMLAW200_RANK'),''))
		)))
		
	let $res2-LAG := xs:decimal(avg(cts:search(/,
		cts:and-query((
		cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/','1')
		,cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),($distinctid_lt_100 ! xs:string(.)))
		,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'), xs:string($pYear))
		)))//AMLAW_200:PPP/text()))
		
	let $CHANGE := fn:round-half-to-even((xs:double($res2 - $res2-LAG) div  $res2-LAG ) * 100 , 2)
	
	let $_ := (
			map:put($response-obj,'ORGANIZATION_ID', 0),
		map:put($response-obj,'ORGANIZATION_NAME', 'Am Law 100'),
		map:put($response-obj,'CHANGE', $CHANGE),
		map:put($response-obj,'PUBLISHYEAR',xs:integer($qYear))
		)
	let $_ := json:array-push($response-arr, $response-obj)

(: -------------------------------------------------------------- 04 -------------------------------------------------------------- :)

  let $distinctid_gt_100  :=cts:element-values(xs:QName('firm-org:OrganizationID'),(),(),
	cts:and-query((
	cts:directory-query('/LegalCompass/denormalized-data/law-firm/survey/')
	,cts:element-range-query(xs:QName('firm-org:AMLAW200_RANK'), '>',100)
	,cts:element-value-query(xs:QName('firm-org:PUBLISHYEAR'),xs:string($qYear))
	,cts:not-query(cts:element-value-query(xs:QName('firm-org:AMLAW200_RANK'),''))
	)))

  let $res3 := xs:decimal(avg(cts:search(/,
		cts:and-query((
		cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/','1')
		,cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),($distinctid_gt_100 ! xs:string(.)))
		,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'), xs:string($qYear))
		)))//AMLAW_200:PPP/text()))
	let $response-obj := json:object()
		
	let $distinctid_gt_100  :=cts:element-values(xs:QName('firm-org:OrganizationID'),(),(),
		cts:and-query((
		cts:directory-query('/LegalCompass/denormalized-data/law-firm/survey/')
		,cts:element-range-query(xs:QName('firm-org:AMLAW200_RANK'), '>',100)
		,cts:element-value-query(xs:QName('firm-org:PUBLISHYEAR'),xs:string($pYear))
		,cts:not-query(cts:element-value-query(xs:QName('firm-org:AMLAW200_RANK'),''))
		)))
		
	let $res3-LAG := xs:decimal(avg(cts:search(/,
		cts:and-query((
		cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/','1')
		,cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),($distinctid_gt_100 ! xs:string(.)))
		,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'), xs:string($pYear))
		)))//AMLAW_200:PPP/text()))
		
	let $CHANGE := fn:round-half-to-even((xs:double($res3 - $res3-LAG) div  $res3-LAG ) * 100 , 2)
	
	let $_ := (
			map:put($response-obj,'ORGANIZATION_ID', 0),
		map:put($response-obj,'ORGANIZATION_NAME', '2nd Hundred'),
		map:put($response-obj,'CHANGE', $CHANGE),
		map:put($response-obj,'PUBLISHYEAR',xs:integer($qYear))
		)
	let $_ := json:array-push($response-arr, $response-obj)
  
  return ()
return $response-arr
};

declare function firm:GetLawfirmAvailableData(
	 $callType
	,$firmID
	,$type
)
{
	let $firmId := if($type) then firm:GetREIdByOrgId($firmID) else $firmID
	let $RE_ID := firm:GetREIdByOrgId($firmID)

	let $response-obj := json:object()

	let $_ := (
		map:put($response-obj, 'HasNews', 'false'),
		map:put($response-obj, 'HasClinets', 'false'),
		map:put($response-obj, 'HasContacts', 'false'),
		map:put($response-obj, 'HasFinancials', 'false'),
		map:put($response-obj, 'HasHeadcount', 'false'),
		map:put($response-obj, 'HasOverview', 'false'),
		map:put($response-obj, 'HasLocation', 'false'),
		map:put($response-obj, 'HasPractice', 'false'),
		map:put($response-obj, 'HasIndustries', 'false'),
		map:put($response-obj, 'HasResearch', 'false'),
		map:put($response-obj, 'HasStaffing', 'false'),
		map:put($response-obj, 'HasLateralPartner', 'false')
	)

	let $_ := if($callType = '') then
		let $org := cts:search(/organization,
			cts:and-query((
				cts:directory-query($config:DD-ORGANIZATION-PATH),
				cts:element-value-query(xs:QName('organization:ORGANIZATION_ID'),$firmID)
			)))[1]

		let $firmName := if ($org/organization:ALM_NAME ne '') then $org/organization:ALM_NAME/text() else $org/organization:ORGANIZATION_NAME/text()
		let $fromDate := fn:format-date(xs:date(xdmp:parse-dateTime('[Y0001]-[M01]-[D01]',xs:string(fn:current-date() - xs:yearMonthDuration('P5Y')))),'[Y0001]-[M01]-[D01]')
		let $toDate := fn:format-date(xs:date(xdmp:parse-dateTime('[Y0001]-[M01]-[D01]',xs:string(xs:date(fn:current-date())))),'[Y0001]-[M01]-[D01]')

		let $ProfileNewsCount := firm:GeLawFirmProfileNewsData($RE_ID,$fromDate,$toDate)
		let $_ := if (($ProfileNewsCount)>0) then map:put($response-obj, 'HasNews', 'true') else ()

		let $LocationCount := firm:GetRELawFirmLocationCount($firmID)
		let $_ := if (($LocationCount)>0) then map:put($response-obj, 'HasLocation', 'true') else ()

		let $PracticeareaCount := firm:GetRELawFirmPracticeareaCount($firmID)
		let $_ := if (($PracticeareaCount)>0) then map:put($response-obj, 'HasPractice', 'true') else ()

		let $ClientsNewCount := firm:GetClientsNewCount($firmID,$fromDate,$toDate)
		let $_ := if (($ClientsNewCount)>0) then map:put($response-obj, 'HasClinets', 'true') else ()

		let $ProfileContactsCount := fn:count(xdmp:unquote(fn:string(firm:GetLawfirmProfileContacts($firmID,'',(),'','')))//ORGANIZATION_ID)
		let $ContactsAddedCount := firm:GetLawfirmContactsAddedCount($RE_ID)

		let $_ := if (($ProfileContactsCount)>0) then 
				map:put($response-obj, 'HasContacts', 'true') 
			else (
				let $ContactsAddedCount := firm:GetLawfirmContactsAddedCount($RE_ID)
				let $_ := if ($ContactsAddedCount>0) then map:put($response-obj, 'HasContacts', 'true') else ()
				return ()
			)

		let $_ := if ($ProfileNewsCount > 0) then
			map:put($response-obj, 'HasOverview', 'true')
		else (
			let $ProfileRankings := fn:count(xdmp:unquote(fn:string(firm:GetLawfirmProfileRankings($firmID)))//FirmId)
			return if($ProfileRankings > 0) then 
					map:put($response-obj, 'HasOverview', 'true')
				else (
					let $RevenueHeadCount := fn:count(xdmp:unquote(fn:string(firm:GetLawfirmRevenueHeadCountChart($firmID,'')))//ORGANIZATION_ID)
						return if($RevenueHeadCount > 0) then 
								map:put($response-obj, 'HasOverview', 'true')
							else (
								let $org := cts:search(/organization,
									cts:and-query((
										cts:directory-query($config:DD-ORGANIZATION-PATH),
										cts:element-value-query(xs:QName('organization:ORGANIZATION_ID'),$firmID)
									)))[1]
								return if($org) then map:put($response-obj, 'HasOverview', 'true') else ()
							)
				)
		)

		let $RevenueByYearCount := fn:count(xdmp:unquote(fn:string(firm:GetRevenueByYear($firmID)))//ORGANIZATION_ID)
		let $_ := if (($RevenueByYearCount)>0) then map:put($response-obj, 'HasFinancials', 'true') else ()

		let $HeadCount := fn:count(xdmp:unquote(fn:string(firm:GetTotalHeadCount($firmID,0,0)))//Organization_Id)
		let $_ := if (($RevenueByYearCount)>0) then map:put($response-obj, 'HasStaffing', 'true') else ()

		let $LawfirmReportCount := fn:count(xdmp:unquote(fn:string(firm:GetLawfirmReports($firmID)))//SURVEY_NAME)
		let $_ := if (($RevenueByYearCount)>0) then map:put($response-obj, 'HasResearch', 'true') else ()

		let $IndustryCountbyId := fn:count(xdmp:unquote(fn:string(firm:GetTotalIndustrybyId($firmID)))//Industry)
		let $_ := if (($IndustryCountbyId)>0) then map:put($response-obj, 'HasIndustries', 'true') else ()

		let $LateralPartnerChangesCount := fn:count(xdmp:unquote(fn:string(firm:GetLateralPartnerChanges($firmID,'')))//company_id)
		let $_ := if (($LateralPartnerChangesCount)>0) then map:put($response-obj, 'HasLateralPartner', 'true') else ()

		return ()

	else ()

	return $response-obj
};

declare function firm:GetLawfirmProfileContacts(
	 $firmID
	,$position
	,$FirmLocation 
	,$SortBy
	,$SortDirection
)
{
	let $firmIds := fn:tokenize($firmID,',')
	
	let $CONTACT_TYPE_Q := if ($position ne '') then
			let $positions := fn:tokenize($position,',')
			return cts:element-value-query(xs:QName('organization-contact:CONTACT_TYPE'),$positions,('case-insensitive'))
		else ()
	
	(: Filter By FirmLocation :)
	let $ADDRESS_IDs := if ($FirmLocation != '') then
			firm-comp:GetOrganizationIDByAddress($FirmLocation)
		else ()
	

	let $conditions := (
		 cts:directory-query($config:RD-ORGANIZATION_CONTACT-PATH)
		,cts:element-value-query(xs:QName('organization-contact:ORGANIZATION_ID'), $firmIds)
		,if ($ADDRESS_IDs) then cts:element-value-query(xs:QName('organization-contact:ORGANIZATION_ADDRESS_ID'), ($ADDRESS_IDs ! xs:string(.))) else ()
		,$CONTACT_TYPE_Q
	)
	
	let $order-by-q := if ($SortBy) then (
		)
		else (
			cts:index-order(cts:element-reference(xs:QName('organization-contact:LAST_NAME')) ,'ascending')
		)
	
	let $search := cts:search(/organization-contact, cts:and-query(($conditions)), $order-by-q)
	
	let $response := for $contact in $search

		let $ORGANIZATION_ID := fn:normalize-space($contact/organization-contact:ORGANIZATION_ID/text())
		let $CONTACT_NAME := fn:normalize-space($contact/organization-contact:CONTACT_NAME/text())
		let $CONTACT_TYPE := fn:normalize-space($contact/organization-contact:CONTACT_TYPE/text())
		let $CONTACT_TITLE := fn:normalize-space($contact/organization-contact:CONTACT_TITLE/text())
		let $CONTACT_MAIN_PHONE := fn:normalize-space($contact/organization-contact:CONTACT_MAIN_PHONE/text())
		let $CONTACT_EMAIL := fn:normalize-space($contact/organization-contact:CONTACT_EMAIL/text())
		let $CONTACT_FAX := fn:normalize-space($contact/organization-contact:CONTACT_FAX/text())
		let $FIRST_NAME := fn:normalize-space($contact/organization-contact:FIRST_NAME/text())
		let $MIDDLE_NAME := fn:normalize-space($contact/organization-contact:MIDDLE_NAME/text())
		let $LAST_NAME := fn:normalize-space($contact/organization-contact:LAST_NAME/text())
		let $ADDRESS_ID := fn:normalize-space($contact/organization-contact:ORGANIZATION_ADDRESS_ID/text())

		let $add := cts:search(/organization-address,
			cts:and-query((
				 cts:directory-query($config:RD-ORGANIZATION-ADDRESS-PATH)
				,cts:element-value-query(xs:QName('org-address:ORGANIZATION_ID'),$ORGANIZATION_ID)
				,cts:element-value-query(xs:QName('org-address:ADDRESS_ID'),$ADDRESS_ID)
			)))[1]

		return if ($add) then    

			let $LOCATION := if ($add/org-address:STATE ne '') then (
					if ($add/org-address:CITY) then (
						fn:concat($add/org-address:CITY/text(), fn:concat(', ', $add/org-address:STATE/text()))
					)
					else ()
				)
				else (
					if ($add/org-address:CITY) then (
						fn:concat($add/org-address:CITY/text(), fn:concat(', ', $add/org-address:COUNTRY/text()))
					)
					else ()
				)

			let $order-by := if (fn:upper-case($SortBy) = fn:upper-case('Name')) then
					$CONTACT_NAME
				else if (fn:upper-case($SortBy) = fn:upper-case('Position')) then
					$CONTACT_TYPE
				else if (fn:upper-case($SortBy) = fn:upper-case('Title')) then
					$CONTACT_TITLE
				else if (fn:upper-case($SortBy) = fn:upper-case('Location')) then
					$LOCATION
				else ()

			let $direction := if (fn:upper-case($SortDirection) = 'DESC') then 'descending' else 'ascending'

			order by
				if ($direction ne 'descending') then () else $order-by descending,
				if ($direction ne 'ascending') then () else $order-by ascending

			return element {'RECORD'} {
				 element {'FirmId'} {$ORGANIZATION_ID}
				,element {'Name'} {$CONTACT_NAME}
				,element {'TitleType'} {$CONTACT_TYPE}
				,element {'Title'} {$CONTACT_TITLE}
				,element {'Phone'} {$CONTACT_MAIN_PHONE}
				,element {'Email'} {$CONTACT_EMAIL}
				,element {'CONTACT_FAX'} {$CONTACT_FAX}
				,element {'FIRST_NAME'} {$FIRST_NAME}
				,element {'MIDDLE_NAME'} {$MIDDLE_NAME}
				,element {'LAST_NAME'} {$LAST_NAME}
				,element {'ADDRESS_ID'} {$ADDRESS_ID}
				,element {'LOCATION'} {$LOCATION}
			}

		else ()

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

declare function firm:GetLawfirmContactsAddedCount($firmID)
{
  fn:count(cts:search(/person,
    cts:and-query((
      cts:directory-query($config:RD-PEOPLE_CHANGES-PATH),
      cts:element-value-query(xs:QName('people_changes:action'),('added','removed','updated')),
      cts:element-value-query(xs:QName('people_changes:company'),$firmID)
    ))))
};

declare function firm:GetLateralPartnerChanges($firmID, $title)
{
	let $RE_ID := firm:GetREIdByOrgId($firmID)

	let $sYear := fn:format-date(xs:date(xdmp:parse-dateTime('[Y01]-[M01]-[D01]',xs:string(fn:current-date() - xs:yearMonthDuration('P4Y')))),'[Y0001]')
	let $eYear := fn:format-date(xs:date(xdmp:parse-dateTime('[Y01]-[M01]-[D01]',xs:string(fn:current-date()))),'[Y0001]')
	
	let $years := helper:GetDatesBetweenTwoDates(xs:integer($sYear),xs:integer($eYear))
	
	let $company := fn:doc(fn:concat($config:RD-COMPANY-PATH,$RE_ID,'.xml'))/company/company:company/text()

	let $response-arr := json:array()

	let $title_query := if ($title) then
			cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:Title'),$title,())
		else ()

	let $_ := for $year in $years
		let $sDate := fn:concat($year,'-01','-01')
		let $eDate := fn:concat($year,'-12','-31')

		let $changes := cts:search(/ALI_RE_LateralMoves_Data,
			cts:and-query((
				 cts:directory-query($config:RD-ALI_RE_LATERALMOVES_DATA-PATH,'infinity')
				,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:company_Id'), $RE_ID)
				,cts:not-query(cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:date_added'), ('0000-00-00'),('wildcarded')))
				,cts:not-query(cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:date_added'), ''))
				,cts:not-query(cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:action'), ''))
				,cts:element-range-query(xs:QName('ALI_RE_LateralMoves_Data:date_added'), '>=', xs:date($sDate))
				,cts:element-range-query(xs:QName('ALI_RE_LateralMoves_Data:date_added'), '<=', xs:date($eDate))
				(:,cts:element-query(xs:QName('people_changes:std_title'),cts:and-query(())):)
				,$title_query
			)))

		let $response-obj := json:object()
		let $headCountPlus := fn:count($changes/ALI_RE_LateralMoves_Data:action[. = 'added'])
		let $headCountMinus := fn:count($changes/ALI_RE_LateralMoves_Data:action[. = 'removed'])

		let $_ := (
			map:put($response-obj, 'company_id', $RE_ID),
			map:put($response-obj, 'company_name', $company),
			map:put($response-obj, 'ActionYear', $year),
			map:put($response-obj, 'headCountPlus', $headCountPlus),
			map:put($response-obj, 'headCountMinus', $headCountMinus)
		)

		let $_ := if ($headCountPlus or $headCountMinus) then json:array-push($response-arr,$response-obj) else ()

		return ()

	return $response-arr
};

declare function firm:GetTotalIndustrybyId($firmID)
{
	let $fromYear := (fn:max(cts:element-attribute-values(xs:QName('survey:YEAR'),xs:QName('PublishYear'),(),(), cts:directory-query($config:DD-SURVEY-AMLAW_100-PATH)))-1)
	let $toYear := fn:max(cts:element-attribute-values(xs:QName('survey:YEAR'),xs:QName('PublishYear'),(),(), cts:directory-query($config:DD-SURVEY-AMLAW_100-PATH)))

	(: ---------------------------------- Stored Procedure 1st Part ---------------------------------- :)
	let $PARTY_IDs := cts:element-values(xs:QName('bdbs-representer:PARTY_ID'),(),(),
		cts:and-query((
			cts:directory-query($config:RD-BDBS_REPRESENTER-PATH),
			cts:element-value-query(xs:QName('bdbs-representer:ORGANIZATION_ID'),$firmID),
			cts:not-query(cts:element-value-query(xs:QName('bdbs-representer:PARTY_ID'),''))
		)))

	let $TRANSACTION_IDs := cts:element-values(xs:QName('bdbs-transaction:TRANSACTION_ID'),(),(),
		cts:and-query((
			cts:directory-query($config:RD-BDBS_TRANSACTION-PATH),
			cts:element-range-query(xs:QName('bdbs-transaction:YEAR'),'>=',$fromYear),
			cts:element-range-query(xs:QName('bdbs-transaction:YEAR'),'<=',$toYear)
		)))

	(: let $ORGANIZATION_ID_1 := cts:element-values(xs:QName('bdbs-party:ORGANIZATION_ID'),(),(),
		cts:and-query((
			cts:directory-query($config:RD-BDBS_PARTY-PATH),
			cts:element-value-query(xs:QName('bdbs-party:PARTY_ID'),($PARTY_IDs ! xs:string(.))),
			cts:element-value-query(xs:QName('bdbs-party:TRANSACTION_ID'),($TRANSACTION_IDs ! xs:string(.))),
			cts:not-query(cts:element-value-query(xs:QName('bdbs-party:ORGANIZATION_ID'),''))
		))) :)
		
	let $ORGANIZATION_ID_1 := cts:search(/bdbs-party,
		cts:and-query((
			cts:directory-query($config:RD-BDBS_PARTY-PATH),
			cts:element-value-query(xs:QName('bdbs-party:PARTY_ID'),($PARTY_IDs ! xs:string(.))),
			cts:element-value-query(xs:QName('bdbs-party:TRANSACTION_ID'),($TRANSACTION_IDs ! xs:string(.))),
			cts:not-query(cts:element-value-query(xs:QName('bdbs-party:ORGANIZATION_ID'),''))
		)))/bdbs-party:ORGANIZATION_ID/text()

	(: ---------------------------------- Stored Procedure 2nd Part ---------------------------------- :)
	(: let $ORGANIZATION_ID_2 := cts:element-values(xs:QName('Who_Counsels_who:ORGANIZATION_ID'),(),(),
		cts:and-query((
			cts:directory-query($config:RD-SURVEY-WHO_COUNSELS_WHO-PATH)
			,cts:element-value-query(xs:QName('Who_Counsels_who:OUTSIDE_COUNSEL_ID'),$firmID)
			,cts:element-range-query(xs:QName('Who_Counsels_who:PUBLISHYEAR'), '>=', $fromYear)
			,cts:element-range-query(xs:QName('Who_Counsels_who:PUBLISHYEAR'), '<=', $toYear)
		))) :)
		
	let $ORGANIZATION_ID_2 := cts:search(/WhoCounselsWho, 
		cts:and-query((
			cts:directory-query($config:RD-SURVEY-WHO_COUNSELS_WHO-PATH)
			,cts:element-value-query(xs:QName('Who_Counsels_who:OUTSIDE_COUNSEL_ID'),$firmID)
			,cts:element-range-query(xs:QName('Who_Counsels_who:PUBLISHYEAR'), '>=', $fromYear)
			,cts:element-range-query(xs:QName('Who_Counsels_who:PUBLISHYEAR'), '<=', $toYear)
		)))/Who_Counsels_who:ORGANIZATION_ID/text()

	(: ---------------------------------- Stored Procedure 3rd Part ---------------------------------- :)
	(: let $ORGANIZATION_ID_3 := cts:element-values(xs:QName('COMPANYPROFILE_LFR_NEW:COMPANY_ID'),(),(),
		cts:and-query((
			cts:directory-query($config:RD-SURVEY-COMPANYPROFILE_LFR_NEW-PATH)
			,cts:element-value-query(xs:QName('COMPANYPROFILE_LFR_NEW:FIRM_ID'),$firmID)
			,cts:element-range-query(xs:QName('COMPANYPROFILE_LFR_NEW:YEAR'), '>=', $fromYear)
			,cts:element-range-query(xs:QName('COMPANYPROFILE_LFR_NEW:YEAR'), '<=', $toYear)
		))) :)
		
	let $ORGANIZATION_ID_3 := cts:search(/COMPANYPROFILE_LFR_NEW,
		cts:and-query((
			cts:directory-query($config:RD-SURVEY-COMPANYPROFILE_LFR_NEW-PATH)
			,cts:element-value-query(xs:QName('COMPANYPROFILE_LFR_NEW:FIRM_ID'),$firmID)
			,cts:element-range-query(xs:QName('COMPANYPROFILE_LFR_NEW:YEAR'), '>=', $fromYear)
			,cts:element-range-query(xs:QName('COMPANYPROFILE_LFR_NEW:YEAR'), '<=', $toYear)
		)))/COMPANYPROFILE_LFR_NEW:COMPANY_ID/text()

	(: ---------------------------------- Stored Procedure 3rd Part ---------------------------------- :)
	(: let $ORGANIZATION_ID_4 := cts:element-values(xs:QName('COMPANYPROFILE_LFR:COMPANY_ID'),(),(),
		cts:and-query((
			cts:directory-query($config:RD-SURVEY-COMPANYPROFILE_LFR-PATH)
			,cts:element-value-query(xs:QName('COMPANYPROFILE_LFR:FIRM_ID'),$firmID)
			,cts:element-range-query(xs:QName('COMPANYPROFILE_LFR:YEAR'), '>=', $fromYear)
			,cts:element-range-query(xs:QName('COMPANYPROFILE_LFR:YEAR'), '<=', $toYear)
		))) :)
		
	let $ORGANIZATION_ID_4 := cts:search(/COMPANYPROFILE_LFR,
		cts:and-query((
			cts:directory-query($config:RD-SURVEY-COMPANYPROFILE_LFR-PATH)
			,cts:element-value-query(xs:QName('COMPANYPROFILE_LFR:FIRM_ID'),$firmID)
			,cts:element-range-query(xs:QName('COMPANYPROFILE_LFR:YEAR'), '>=', $fromYear)
			,cts:element-range-query(xs:QName('COMPANYPROFILE_LFR:YEAR'), '<=', $toYear)
		)))/COMPANYPROFILE_LFR:COMPANY_ID/text()

	let $COMPANY_IDs :=(
		 ($ORGANIZATION_ID_1 ! xs:string(.))
		,($ORGANIZATION_ID_2 ! xs:string(.))
		,($ORGANIZATION_ID_3 ! xs:string(.))
		,($ORGANIZATION_ID_4 ! xs:string(.))
	)

	let $search-result := for $x in cts:search(/TOP500,
		cts:and-query((
			cts:directory-query($config:RD-TOP500-PATH),
			cts:element-value-query(xs:QName('TOP500:COMPANY_ID'),$COMPANY_IDs),
			cts:not-query(cts:element-value-query(xs:QName('TOP500:PRIMARY_INDUSTRY'),''))
		)))
		return element {'RECORD'} { 
			element {'PRIMARY_INDUSTRY'} {$x/TOP500:PRIMARY_INDUSTRY/text()},
			element {'COMPANY_ID'} {$x/TOP500:COMPANY_ID/text()}
		}

	let $distinct-values := helper:distinct-node($search-result)

	let $response-arr := json:array()

	let $_ := for $facet in fn:distinct-values($distinct-values/PRIMARY_INDUSTRY/text())
		let $response-obj := json:object()
		
		let $company_id := $distinct-values[PRIMARY_INDUSTRY eq $facet][1]/COMPANY_ID/text()
		let $count := fn:count($COMPANY_IDs[. = $company_id])
		let $total := fn:count($distinct-values[PRIMARY_INDUSTRY = $facet])
		let $total := if ($total = 1) then $count else $total
		
		let $_ := (
			map:put($response-obj ,'Total', $total),
			map:put($response-obj ,'Industry', $facet)
		)
		let $_ := json:array-push($response-arr,$response-obj)
		return()

	return $response-arr
};

declare function firm:GetCostPerLawyer($OrganisationID,$StartYear,$EndYear)
{
	let $distinct-years := cts:element-attribute-values(xs:QName('survey:YEAR'),xs:QName('PublishYear'),(),('ascending'),
		cts:and-query((
			cts:directory-query($config:DD-SURVEY-AMLAW_200-PATH,'1')
		)))                      

	let $organization := cts:search(/organization,
		cts:and-query((
			cts:directory-query($config:DD-ORGANIZATION-PATH),
		cts:element-value-query(xs:QName('organization:ORGANIZATION_ID'),$OrganisationID)
		)))

	let $years := if (fn:not($StartYear) and fn:not($EndYear)) then
			$distinct-years[last()-4 to last()]
		else 
		for $year in $distinct-years
			where ($year ge xs:integer($StartYear) and $year le xs:integer($EndYear))
			return $year

	let $AMLAW_200_URI := fn:concat($config:DD-SURVEY-AMLAW_200-PATH,$OrganisationID,'.xml')
	let $AMLAW_200 := fn:doc($AMLAW_200_URI)//survey:YEAR

	let $response-arr := json:array()

	let $_ := for $year in $years
		let $response-obj := json:object()

		let $AMLAW_200_NODE := $AMLAW_200[@PublishYear = $year]

		let $ORGANIZATION_ID := $organization/organization:ORGANIZATION_ID/text()
		let $ORGANIZATION_NAME := if($organization/organization:ALM_NAME/text()) then 
				$organization/organization:ALM_NAME/text() 
			else $organization/organization:ORGANIZATION_NAME/text()
		let $PUBLISHYEAR := $year
		let $COSTPERLAWYER := $AMLAW_200[1]
		let $COSTPERLAWYER := fn:round((xs:decimal(fn:sum($AMLAW_200_NODE//survey:GROSS_REVENUE/text())) - xs:decimal(fn:sum($AMLAW_200_NODE//survey:NET_OPERATING_INCOME/text()))) div xs:decimal(fn:sum($AMLAW_200_NODE//survey:NUM_OF_LAWYERS/text())))

		let $response-obj := json:object()
		let $_ := (
			map:put($response-obj, 'ORGANIZATION_ID', $ORGANIZATION_ID),
			map:put($response-obj, 'ORGANIZATION_NAME', $ORGANIZATION_NAME),
			map:put($response-obj, 'COSTPERLAWYER', $COSTPERLAWYER),
			map:put($response-obj, 'PUBLISHYEAR', $PUBLISHYEAR)
		)
		let $_ := json:array-push($response-arr,$response-obj)
    
    let $distinctid_lt_100  :=cts:element-values(xs:QName('firm-org:OrganizationID'),(),(),
		cts:and-query((
		cts:directory-query('/LegalCompass/denormalized-data/law-firm/survey/')
		,cts:element-range-query(xs:QName('firm-org:AMLAW200_RANK'), '<=',100)
		,cts:element-value-query(xs:QName('firm-org:PUBLISHYEAR'),xs:string($year))
		,cts:not-query(cts:element-value-query(xs:QName('firm-org:AMLAW200_RANK'),''))
		)))
    
    let $AMLAW_100 :=cts:search(/,
		cts:and-query((
		cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/','1')
		,cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),($distinctid_lt_100 ! xs:string(.)))
		,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'), xs:string($year))
		)))
    
    
		let $COSTPERLAWYER := fn:format-number(((xs:decimal(fn:sum($AMLAW_100//AMLAW_200:GROSS_REVENUE/text())) - xs:decimal(fn:sum($AMLAW_100//AMLAW_200:NET_OPERATING_INCOME/text())))  div xs:decimal(fn:sum($AMLAW_100//AMLAW_200:NUM_OF_LAWYERS/text()))) , '00')

		let $response-obj := json:object()
		let $_ := (
			map:put($response-obj, 'ORGANIZATION_ID', 0),
			map:put($response-obj, 'ORGANIZATION_NAME', 'AM Law 100'),
			map:put($response-obj, 'COSTPERLAWYER', $COSTPERLAWYER),
			map:put($response-obj, 'PUBLISHYEAR', $PUBLISHYEAR)
		)
		let $_ := json:array-push($response-arr,$response-obj)

    let $distinctid_gt_100  :=cts:element-values(xs:QName('firm-org:OrganizationID'),(),(),
		cts:and-query((
		cts:directory-query('/LegalCompass/denormalized-data/law-firm/survey/')
		,cts:element-range-query(xs:QName('firm-org:AMLAW200_RANK'), '>',100)
		,cts:element-value-query(xs:QName('firm-org:PUBLISHYEAR'),xs:string($year))
		,cts:not-query(cts:element-value-query(xs:QName('firm-org:AMLAW200_RANK'),''))
		)))
    
		let $SECOND_100 := cts:search(/,
		cts:and-query((
		cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/','1')
		,cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),($distinctid_gt_100 ! xs:string(.)))
		,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'), xs:string($year))
		)))

		let $COSTPERLAWYER := fn:format-number(((xs:decimal(fn:sum($SECOND_100//AMLAW_200:GROSS_REVENUE/text())) - xs:decimal(fn:sum($SECOND_100//AMLAW_200:NET_OPERATING_INCOME/text())))  div xs:decimal(fn:sum($SECOND_100//AMLAW_200:NUM_OF_LAWYERS/text()))), "00")

		let $response-obj := json:object()
		let $_ := (
			map:put($response-obj, 'ORGANIZATION_ID', 0),
			map:put($response-obj, 'ORGANIZATION_NAME', '2nd Hundred'),
			map:put($response-obj, 'COSTPERLAWYER', $COSTPERLAWYER),
			map:put($response-obj, 'PUBLISHYEAR', $PUBLISHYEAR)
		)
		let $_ := json:array-push($response-arr,$response-obj)

		return ()

	return $response-arr
};

declare function firm:GetLawfirmReports($firmID)
{
	let $S_LISTINGS := for $x in cts:search(/SURVEYLISTING,
		cts:and-query((
			cts:directory-query($config:DD-SURVEY-LISTING-PATH),
			cts:not-query(cts:element-value-query(xs:QName('survey-listing:TABLENAME'),''))
		)))
		return element {'RESULT'} {
			attribute {'xmlns'} {'http://alm.com/LegalCompass/dd/survey-listing'},
			$x/survey-listing:TABLENAME,
			$x/survey-listing:SURVEYLISTINGID,
			$x/survey-listing:NAME
		}

	let $year := fn:max(cts:element-attribute-values(xs:QName('survey:YEAR'), xs:QName('PublishYear'),(),('descending'),cts:directory-query($config:DD-SURVEY-AMLAW_100-PATH)))
	let $response-arr := json:array()

	let $response := for $S_LISTING in $S_LISTINGS

		let $TABLENAME := $S_LISTING/survey-listing:TABLENAME/text()
		let $NAME := $S_LISTING/survey-listing:NAME/text()
		let $SURVEYLISTINGID := $S_LISTING/survey-listing:SURVEYLISTINGID/text()

		let $directory :=  if (fn:upper-case($TABLENAME) = fn:upper-case('ALIST')) then (
				element {'PATH'} {$config:DD-SURVEY-ALIST-PATH}
			)
			else if (fn:upper-case($TABLENAME) = fn:upper-case('AMLAW_200')) then (
				element {'PATH'} {$config:DD-SURVEY-AMLAW_200-PATH}
			)
			else if (fn:upper-case($TABLENAME) = fn:upper-case('Legal_Times_150')) then (
				element {'PATH'} {$config:DD-SURVEY-LEGAL_TIMES_150-PATH}
			)
			else if (fn:upper-case($TABLENAME) = fn:upper-case('Tech_Scorecard')) then (
				element {'PATH'} {$config:DD-SURVEY-TECH_SCORECARD-PATH}
			)
			else if (fn:upper-case($TABLENAME) = fn:upper-case('NY100')) then (
				element {'PATH'} {$config:DD-SURVEY-NY100-PATH}
			)
			else if (fn:upper-case($TABLENAME) = fn:upper-case('Who_Counsels_who')) then (
				element {'PATH'} {$config:DD-SURVEY-WHO_COUNSELS_WHO-PATH}
			)
			else if (fn:upper-case($TABLENAME) = fn:upper-case('DC20')) then (
				element {'PATH'} {$config:DD-SURVEY-DC20-PATH}
			)
			else if (fn:upper-case($TABLENAME) = fn:upper-case('LAWFIRMVALUATIONS')) then (
				element {'PATH'} {$config:DD-SURVEY-LAWFIRMVALUATIONS-PATH}
			)
			else if (fn:upper-case($TABLENAME) = fn:upper-case('Billing_Survey_Florida')) then (
				element {'PATH'} {$config:DD-SURVEY-BILLING_SURVEY_FLORIDA-PATH}
			)
			  else if (fn:upper-case($TABLENAME) = fn:upper-case('Global_100')) then (
				element {'PATH'} {$config:DD-SURVEY-GLOBAL_100-PATH}
			)
			else if (fn:upper-case($TABLENAME) = fn:upper-case('AMLAW_100')) then (
				element {'PATH'} {$config:DD-SURVEY-AMLAW_100-PATH}
			)
			else if (fn:upper-case($TABLENAME) = fn:upper-case('LAWFIRM_MERGERS')) then (
				element {'PATH'} {$config:DD-SURVEY-LAWFIRM_MERGERS-PATH}
			)
			else if (fn:upper-case($TABLENAME) = fn:upper-case('Associate_natl')) then (
				element {'PATH'} {$config:DD-SURVEY-ASSOCIATE_NATL-PATH}
			)
			else if (fn:upper-case($TABLENAME) = fn:upper-case('NLJ_LGBT')) then (
				element {'PATH'} {$config:DD-SURVEY-NLJ_LGBT-PATH}
			)
			else if (fn:upper-case($TABLENAME) = fn:upper-case('NLJ_250')) then (
				element {'PATH'} {$config:DD-SURVEY-NLJ_250-PATH}
			)
			else if (fn:upper-case($TABLENAME) = fn:upper-case('Pro_Bono')) then (
				element {'PATH'} {$config:DD-SURVEY-PRO_BONO-PATH}
			)
			else if (fn:upper-case($TABLENAME) = fn:upper-case('NLJ_Staffing')) then (
				element {'PATH'} {$config:DD-SURVEY-NLJ_STAFFING-PATH}
			)
			else if (fn:upper-case($TABLENAME) = fn:upper-case('Associate_summer_survey')) then (
				element {'PATH'} {$config:DD-SURVEY-ASSOCIATE_SUMMER_SURVEY-PATH}
			)
			else if (fn:upper-case($TABLENAME) = fn:upper-case('Corporate_scorecard')) then (
				element {'PATH'} {$config:DD-SURVEY-CORPORATE_SCORECARD-PATH}
			)
			else if (fn:upper-case($TABLENAME) = fn:upper-case('Diversity_Scorecard')) then (
				element {'PATH'} {$config:DD-SURVEY-DIVERSITY_SCORECARD-PATH}
			)
			else if (fn:upper-case($TABLENAME) = fn:upper-case('TX100')) then (
				element {'PATH'} {$config:DD-SURVEY-TX100-PATH}
			)
			else if (fn:upper-case($TABLENAME) = fn:upper-case('FEMALE_SCORECARD')) then (
				element {'PATH'} {$config:DD-SURVEY-FEMALE_SCORECARD-PATH}
			)
			else if (fn:upper-case($TABLENAME) = fn:upper-case('Lateral_Partner')) then (
				element {'PATH'} {$config:DD-SURVEY-LATERAL_PARTNER-PATH}
			)
			else ()

		let $obj := if ($directory) then (
			let $record := cts:search(//survey:YEAR,
				cts:and-query((
					cts:directory-query($directory),
					cts:element-attribute-value-query(xs:QName('survey:YEAR'), xs:QName('OrganizationID'),$firmID),
					cts:element-attribute-value-query(xs:QName('survey:YEAR'), xs:QName('PublishYear'),xs:string($year))
				)))[1]

			let $node := if ($record) then (
				element {'RECORD'} {
					 element {'Organization_Id'} {xs:string($firmID)}
					,element {'SurveyName'} {fn:upper-case($NAME)}
					,element {'Survey_Id'} {$SURVEYLISTINGID}
				}
			)
			else ()
			return $node
		)
		else ()
		
		order by $NAME ascending
		
		return $obj
	
	let $response := element {'RESULT'} {$response}
	
	let $custom :=
		let $config := json:config('custom')
		let $_ := map:put( $config, 'whitespace', 'ignore' )
		let $_ := map:put( $config, 'array-element-names', ('RECORD') )
		return $config
	
	let $response := xdmp:to-json-string(json:transform-to-json($response, $custom)//RECORD)
	
	return $response
};

declare function firm:GetTotalHeadCount(
	 $OrganisationID as xs:string
	,$StartYear as xs:integer
	,$EndYear as xs:integer
)
{
	let $org := cts:search(/organization,
		cts:and-query((
			cts:directory-query($config:DD-ORGANIZATION-PATH),
			cts:element-value-query(xs:QName('organization:ORGANIZATION_ID'),$OrganisationID)
		)))[1]

	let $response-arr := json:array()

	let $res := if (($StartYear) and ($EndYear)) then (
		let $survey-data := cts:search(//survey:YEAR,
			cts:and-query((
				cts:directory-query($config:DD-SURVEY-NLJ_250-PATH),
				cts:element-attribute-range-query(xs:QName('survey:YEAR'), xs:QName('PublishYear'), '>=', $StartYear),
				cts:element-attribute-range-query(xs:QName('survey:YEAR'), xs:QName('PublishYear'), '<=', $EndYear),
				cts:element-attribute-value-query(xs:QName('survey:YEAR'), xs:QName('OrganizationID'),xs:string($OrganisationID))
			)))

		let $_ := for $item in $survey-data
			let $response-obj := json:object()
			let $ORGANIZATION_NAME := if ($org/organization:ALM_NAME ne '') then $org/organization:ALM_NAME/text() else $org/organization:ORGANIZATION_NAME/text()
			let $_ := (
				map:put($response-obj, 'Organization_Id', $item/@OrganizationID),
				map:put($response-obj, 'Organization_Name', $ORGANIZATION_NAME),
				map:put($response-obj, 'Count', $item/survey:NUM_ATTORNEYS/text()),
				map:put($response-obj, 'TotalCount', $item/survey:NUM_ATTORNEYS/text()),
				map:put($response-obj, 'Publishyear', $item/@PublishYear)
			)
			let $_ := json:array-push($response-arr,$response-obj)
			return $item

		return ()
	)
	else (
		let $year := (fn:max(cts:element-attribute-values(xs:QName('survey:YEAR'), xs:QName('PublishYear'), (), ('descending'), 
			cts:directory-query($config:DD-SURVEY-AMLAW_200-PATH))) - 4)

		let $survey-data := cts:search(//survey:YEAR,
			cts:and-query((
				cts:directory-query($config:DD-SURVEY-NLJ_250-PATH),
				cts:element-attribute-range-query(xs:QName('survey:YEAR'), xs:QName('PublishYear'), '>=', $year),
				cts:element-attribute-value-query(xs:QName('survey:YEAR'), xs:QName('OrganizationID'),xs:string($OrganisationID))
			)))

		let $_ := for $item in $survey-data
			let $response-obj := json:object()
			let $ORGANIZATION_NAME := if ($org/organization:ALM_NAME ne '') then $org/organization:ALM_NAME/text() else $org/organization:ORGANIZATION_NAME/text()
			let $_ := (
				map:put($response-obj, 'Organization_Id', $item/@OrganizationID),
				map:put($response-obj, 'Organization_Name', $ORGANIZATION_NAME),
				map:put($response-obj, 'Count', $item/survey:NUM_ATTORNEYS/text()),
				map:put($response-obj, 'TotalCount', $item/survey:NUM_ATTORNEYS/text()),
				map:put($response-obj, 'Publishyear', $item/@PublishYear)
			)
			let $_ := json:array-push($response-arr,$response-obj)
			return $item

		return ()
	)

	return $response-arr
};

declare function firm:GeLawFirmProfileNewsData($firmID,$fromDate,$toDate)
{
	fn:count(cts:search(/DATA,
		cts:and-query((
			cts:directory-query($config:RD-DATA_TABLE-PATH),
			cts:element-value-query(xs:QName('data:company_id'),$firmID),
			cts:not-query(cts:element-value-query(xs:QName('data:std_date'),'')),
			cts:element-range-query(xs:QName('data:std_date'),'>=',xs:date($fromDate)),
			cts:element-range-query(xs:QName('data:std_date'),'<',xs:date($toDate))
		))))
};

declare function firm:GetClientsNewCount($firmID,$fromDate,$toDate)
{
	let $fromYear := xs:integer(fn:format-date(xs:date($fromDate),'[Y0001]'))
	let $toYear := xs:integer(fn:format-date(xs:date($toDate),'[Y0001]'))

	let $WHO_COUNSELS_WHO := cts:search(/SURVEY/survey:YEAR,
		cts:and-query((
			cts:directory-query($config:DD-SURVEY-WHO_COUNSELS_WHO-PATH),
			cts:element-value-query(xs:QName('survey:OUTSIDE_COUNSEL_ID'),$firmID),
			cts:element-range-query(xs:QName('survey:FISCAL_YEAR'),'>=',$fromYear),
			cts:element-range-query(xs:QName('survey:FISCAL_YEAR'),'<=',$toYear)
		)))/survey:WHOCOUNSELSWHO_SOURCE

	let $PARTY_IDs := cts:search(/bdbs-representer,
		cts:and-query((
			cts:directory-query($config:RD-BDBS_REPRESENTER-PATH),
			cts:element-value-query(xs:QName('bdbs-representer:ORGANIZATION_ID'),$firmID),
			cts:not-query(cts:element-value-query(xs:QName('bdbs-representer:PARTY_ID'),''))
		)))/bdbs-representer:PARTY_ID/text()

	let $TRANSACTION_IDs := cts:search(/bdbs-party,
		cts:and-query((
			cts:directory-query($config:RD-BDBS_PARTY-PATH),
			cts:element-value-query(xs:QName('bdbs-party:PARTY_ID'),$PARTY_IDs),
			cts:not-query(cts:element-value-query(xs:QName('bdbs-party:TRANSACTION_ID'),''))
		)))/bdbs-party:TRANSACTION_ID/text()

	let $TRANSACTION := cts:search(/bdbs-transaction,
		cts:and-query((
			cts:directory-query($config:RD-BDBS_TRANSACTION-PATH),
			cts:element-value-query(xs:QName('bdbs-transaction:TRANSACTION_ID'),$TRANSACTION_IDs),
			cts:element-range-query(xs:QName('bdbs-transaction:YEAR'),'>=',$fromYear),
			cts:element-range-query(xs:QName('bdbs-transaction:YEAR'),'<=',$toYear)
		)))/bdbs-transaction:TRANSACTION_ID

	return fn:count(($TRANSACTION,$WHO_COUNSELS_WHO))
};

declare function firm:GetRELawFirmPracticeareaCount($firmID)
{
  let $RE_ID := firm:GetREIdByOrgId($firmID)

  let $data := element {'RESULT'} {
      for $practice_area in cts:element-values(xs:QName('practices_kws:practice_area'))
        let $key := fn:concat('*',$practice_area,'*')
        let $result := cts:search(/person,
            cts:and-query((
              cts:collection-query($config:RD-PEOPLE-COLLECTION),
              cts:directory-query($config:RD-PEOPLE-PATH),
              cts:element-value-query(xs:QName('rd_person:company'),$RE_ID),
              cts:element-word-query(xs:QName('rd_person:std_practices'),$key,('wildcarded','case-insensitive')),
              cts:not-query(cts:element-value-query(xs:QName('rd_person:std_practices'),''))
            )))[1]

        return if ($result) then element {'RECORD'} { $practice_area } else ()
    }

  return fn:count($data/RECORD)
};

declare function firm:GetRELawFirmLocationCount($firmID)
{
	let $RE_ID := firm:GetREIdByOrgId($firmID)
	
	let $count := if ($RE_ID) then
		
		let $company := fn:doc(fn:concat($config:RD-COMPANY-PATH,$RE_ID,'.xml'))/*
		
		let $std_locs := cts:element-values(xs:QName('dd_person:std_loc'),(),(),
			cts:and-query((
				 cts:directory-query($config:DD-PEOPLE-PATH)
				,cts:element-value-query(xs:QName('dd_person:company'),$RE_ID)
			)))
			
		let $data := element {'RESULT'} {
			
			for $std_loc in $std_locs
				
				let $person := cts:search(/person,
					cts:and-query((
						cts:directory-query($config:DD-PEOPLE-PATH)
						,cts:element-value-query(xs:QName('dd_person:company'),$RE_ID)
						,cts:element-value-query(xs:QName('dd_person:std_loc'),$std_loc)
					)))[1]
				
				let $city := cts:search(/city,
					cts:and-query((
						cts:directory-query($config:RD-CITY-PATH)
						,cts:element-value-query(xs:QName('city:std_loc'),$std_loc,('case-insensitive'))
						,cts:not-query(cts:element-value-query(xs:QName('city:country'),''))
					)))[1]

				return if ($city) then
					element {'RECORD'}{''}
				else ()
        }  

      return fn:count($data/RECORD)

    else 0

	return $count

};

declare function firm:GetLawfirmLocations(
	$firmID as xs:string
)
{
	let $RE_ID := firm:GetREIdByOrgId($firmID)

	let $response-arr := json:array()

	let $_ := if ($RE_ID) then

		let $company := fn:doc(fn:concat($config:RD-COMPANY-PATH,$RE_ID,'.xml'))/*

		let $std_locs := cts:element-values(xs:QName('dd_person:std_loc'),(),(),
			cts:and-query((
				cts:directory-query($config:DD-PEOPLE-PATH),
				cts:element-value-query(xs:QName('dd_person:company'),$RE_ID)
			)))

		let $_ := for $std_loc in $std_locs

			let $person := cts:search(/person,
				cts:and-query((
					cts:directory-query($config:DD-PEOPLE-PATH),
					cts:element-value-query(xs:QName('dd_person:company'),$RE_ID),
					cts:element-value-query(xs:QName('dd_person:std_loc'),$std_loc)
				)))

			let $city := cts:search(/city,
				cts:and-query((
					cts:directory-query($config:RD-CITY-PATH),
					cts:element-value-query(xs:QName('city:std_loc'),$std_loc,('case-insensitive')),
					cts:not-query(cts:element-value-query(xs:QName('city:country'),''))
				)))[1]

			let $_ := if($city) then

				let $response-obj := json:object()

				let $FirmName := $company/company:company/text()
				let $City := $city/city:city/text()
				let $State := $city/city:state/text()
				let $Country := $city/city:country/text()
				let $CountryType := if (fn:lower-case($Country) = 'usa') then 'USA' else 'Other'
				let $NoofAttorneys := fn:count($person/dd_person:std_title[. = ('Partner','Associate','Other Counsel/Attorney')])
				let $NoofPartners := fn:count($person/dd_person:std_title[. = ('Partner')])
				let $EquityPartners := ''
				let $NonEquityPartners := ''
				let $Associates := fn:count($person/dd_person:std_title[. = ('Associate')])
				let $OtherAttorneys := fn:count($person/dd_person:std_title[fn:lower-case(.) = 'other'])

				let $_ := (
					map:put($response-obj, 'FirmName',$FirmName),
					map:put($response-obj, 'BranchOffice',$std_loc),
					map:put($response-obj, 'City',$City),
					map:put($response-obj, 'FirmId',$RE_ID),
					map:put($response-obj, 'State',$State),
					map:put($response-obj, 'Country',$Country),
					map:put($response-obj, 'CountryType',$CountryType),
					map:put($response-obj, 'NoofAttorneys',$NoofAttorneys),
					map:put($response-obj, 'NoofPartners',$NoofPartners),
					map:put($response-obj, 'EquityPartners',$EquityPartners),
					map:put($response-obj, 'NonEquityPartners',$NonEquityPartners),
					map:put($response-obj, 'Associates',$Associates),
					map:put($response-obj, 'OtherAttorneys',$OtherAttorneys)
				)
				let $ _ := json:array-push($response-arr,$response-obj)
				return ()
			else ()

			return ()

		return ()

	else
		let $fiscal_year := fn:max(cts:element-values(xs:QName('organization-branch:FISCAL_YEAR')))

		let $organizations := cts:search(/organization-branch,
			cts:and-query((
				cts:directory-query($config:RD-ORGANIZATION_BRANCH-PATH),
				cts:element-value-query(xs:QName('organization-branch:ORGANIZATION_ID'),$firmID),
				cts:element-value-query(xs:QName('organization-branch:FISCAL_YEAR'),xs:string($fiscal_year))
			)))

		let $_ := for $organization in $organizations
			let $response-obj := json:object()

			let $FirmName := $organization/organization-branch:ORGANIZATION_NAME/text()
			let $BranchOffice := $organization/organization-branch:BRANCH_NAME/text()
			let $City := $organization/organization-branch:CITY/text()
			let $FirmId := $organization/organization-branch:ORGANIZATION_ID /text()
			let $State := $organization/organization-branch:STATE/text()
			let $Country := $organization/organization-branch:COUNTRY/text()
			let $CountryType := if(fn:lower-case($Country) = 'usa') then 'USA' else 'Other'
			let $NoofAttorneys := $organization/organization-branch:NUM_ATTORNEYS/text()
			let $NoofPartners := $organization/organization-branch:TOTAL_PARTNERS/text()
			let $EquityPartners := $organization/organization-branch:EQUITY_PARTNERS/text()
			let $NonEquityPartners := $organization/organization-branch:NON_EQUITY_PARTNERS/text()
			let $Associates := $organization/organization-branch:ASSOCIATES/text()
			let $OtherAttorneys := $organization/organization-branch:OTHER_ATTORNEYS/text()

			let $_ := (
				map:put($response-obj, 'FirmName',$FirmName),
				map:put($response-obj, 'BranchOffice',$BranchOffice),
				map:put($response-obj, 'City',$City),
				map:put($response-obj, 'FirmId',$FirmId),
				map:put($response-obj, 'State',$State),
				map:put($response-obj, 'Country',$Country),
				map:put($response-obj, 'CountryType',$CountryType),
				map:put($response-obj, 'NoofAttorneys',$NoofAttorneys),
				map:put($response-obj, 'NoofPartners',$NoofPartners),
				map:put($response-obj, 'EquityPartners',$EquityPartners),
				map:put($response-obj, 'NonEquityPartners',$NonEquityPartners),
				map:put($response-obj, 'Associates',$Associates),
				map:put($response-obj, 'OtherAttorneys',$OtherAttorneys)
			)

			let $_ := json:array-push($response-arr,$response-obj)
			return ()

		return ()

	return $response-arr
};

declare function firm:GetLawFirmPracticearea(
	$firmID as xs:string
)
{
	let $RE_ID := firm:GetREIdByOrgId($firmID)

	let $response-arr := json:array()
	
	let $response := for $practice_area in cts:element-values(xs:QName('practices_kws:practice_area'))
		
		let $key := fn:concat('*',$practice_area,'*')
		let $result := cts:search(/person,
			cts:and-query((
			cts:collection-query($config:RD-PEOPLE-COLLECTION),
				cts:directory-query($config:RD-PEOPLE-PATH),
				cts:element-value-query(xs:QName('rd_person:company'),$RE_ID),
				cts:element-word-query(xs:QName('rd_person:std_practices'),$key,('wildcarded','case-insensitive')),
				cts:not-query(cts:element-value-query(xs:QName('rd_person:std_practices'),''))
			)))

		let $HeadCount := fn:count($result)
		let $PartnerCount := fn:count($result/rd_person:std_title[fn:contains(.,'Partner')])
		let $AssociateCount := fn:count($result/rd_person:std_title[fn:contains(.,'Associate')])
		let $OtherCounselCount := fn:count($result/rd_person:std_title[fn:contains(.,'Other Counsel/Attorney')])
		let $AdminCount := fn:count($result/rd_person:std_title[fn:contains(.,'Administrative / Support Staff')])
		let $OtherCount := fn:count($result/rd_person:std_title[. = 'Other'])

		let $obj := if ($HeadCount > 0) then 
			element {'RECORD'} {
				element {'Practicearea'} {$practice_area},
				element {'HeadCount'} {$HeadCount},
				element {'PartnerCount'} {$PartnerCount},
				element {'FirmID'} {$RE_ID},
				element {'AssociateCount'} {$AssociateCount},
				element {'OtherCounselCount'} {$OtherCounselCount},
				element {'AdminCount'} {$AdminCount},
				element {'OtherCount'} {0}
			}
		else ()
		
		order by $HeadCount descending, $practice_area descending
		
		return $obj
		
	let $response := element {'RESULT'} {$response}
	
	let $custom :=
		let $config := json:config('custom')
		let $_ := map:put( $config, 'whitespace', 'ignore' )
		let $_ := map:put( $config, 'array-element-names', ('RECORD') )
		return $config
	
	let $response := xdmp:to-json-string(json:transform-to-json($response, $custom)//RECORD)

	return $response
};

declare function firm:GetLawfirmProfileRankings(
	$firmID as xs:string
)
{
	let $conditions := (
		 cts:directory-query($config:DD-ORGANIZATION-SURVEY-PATH)
		,cts:element-value-query(xs:QName('firm-org:OrganizationID'),$firmID)
	)
	let $order-by := cts:index-order(cts:element-reference(xs:QName('firm-org:PUBLISHYEAR')),'descending')
	let $search := cts:search(/SURVEY, cts:and-query(($conditions)),$order-by)[1 to 10]
	
	let $response-arr := json:array()
	let $_ := for $res in $search
		let $response-obj := json:object()
		
		let $Year := $res/firm-org:PUBLISHYEAR/text()
		let $FirmName := fn:normalize-space($res/firm-org:OrganizationName/text())
		let $AMLaw200Rank := $res/firm-org:AMLAW200_RANK/text()
		let $AListRank := $res/firm-org:ALIST_RANK/text()
		let $Global100Rank := $res/firm-org:RANK_BY_GROSS_REVENUE/text()
		let $NLJ500Rank := $res/firm-org:NLJ250_RANK/text()
		let $NoofAttorneys := if ($res/firm-org:NUM_ATTORNEYS/text() != '') then $res/firm-org:NUM_ATTORNEYS/text() else $res/firm-org:NUM_OF_LAWYERS/text()
		let $Revenue := if ($res/firm-org:AMLAW_200_GROSS_REVENUE/text() != '') then $res/firm-org:AMLAW_200_GROSS_REVENUE/text() else $res/firm-org:Global_100_GROSS_REVENUE/text()
		let $IsAddedToCompareList := ''

		let $_ := (
			map:put($response-obj,'TotalCount',''),
			map:put($response-obj,'IsAddedToCompareList',''),
			map:put($response-obj,'FirmName',$FirmName),
			map:put($response-obj,'FirmId',$firmID),
			map:put($response-obj,'Revenue',$Revenue),
			map:put($response-obj,'NoofAttorneys',$NoofAttorneys),
			map:put($response-obj,'Year',$Year),
			map:put($response-obj,'AMLaw200Rank',$AMLaw200Rank),
			map:put($response-obj,'NLJ500Rank',$NLJ500Rank),
			map:put($response-obj,'Global100Rank',$Global100Rank),
			map:put($response-obj,'AListRank',$AListRank)
		)

		let $_ := json:array-push($response-arr, $response-obj)
		return ()
	
	return $response-arr
};

declare function firm:GetLawfirmRevenueHeadCountChart(
	$firmID as xs:string,
	$type as xs:string
)
{
	let $AMLAW_200_DOC := fn:doc(fn:concat($config:DD-SURVEY-AMLAW_200-PATH,$firmID,'.xml'))//survey:YEAR
	let $NLJ_250_DOC := fn:concat($config:DD-SURVEY-NLJ_250-PATH,$firmID,'.xml')
	let $Global_100_DOC := fn:concat($config:DD-SURVEY-GLOBAL_100-PATH,$firmID,'.xml')

	let $response := (for $x in cts:search(//survey:YEAR,
		cts:and-query((
			cts:document-query($NLJ_250_DOC),
			cts:element-attribute-value-query(xs:QName('survey:YEAR'),xs:QName('OrganizationID'),$firmID)
		)))
		order by $x/@PublishYear descending
		return $x
	)[1 to 10]

	let $response := if ($response) then 
			$response
		else (for $x in cts:search(//survey:YEAR,
			cts:and-query((
				cts:document-query($Global_100_DOC),
				cts:element-attribute-value-query(xs:QName('survey:YEAR'),xs:QName('OrganizationID'),$firmID)
			)))
			order by $x/@PublishYear descending
			return $x
		)[1 to 10]

	let $result-arr := json:array()

	let $_ := for $res in $response
		let $result-obj := json:object()
		let $PublishYear := $res/@PublishYear
		let $_ := (
			map:put($result-obj,'ORGANIZATION_ID',$res/@OrganizationID),
			map:put($result-obj,'ORGANIZATION_NAME',$res/@OrganizationName),
			map:put($result-obj,'GROSS_REVENUE',$AMLAW_200_DOC[@PublishYear = $PublishYear]/survey:GROSS_REVENUE/text()),
			map:put($result-obj,'NUM_ATTORNEYS',if($res/survey:NUM_ATTORNEYS/text() ne '') then $res/survey:NUM_ATTORNEYS/text() else $res/survey:NUM_LAWYERS/text()),
			map:put($result-obj,'PUBLISHYEAR',$PublishYear)
		)
		let $_ := json:array-push($result-arr, $result-obj)
		return ()

	return $result-arr
};

declare function firm:GetLawfirmProfileDetail(
	$firmID as xs:string
)
{
	(: let $org := cts:search(/organization,
		cts:and-query((
			cts:directory-query($config:DD-ORGANIZATION-PATH),
			cts:element-value-query(xs:QName('organization:ORGANIZATION_ID'),$firmID)
		)))[1] :)
	
	let $org := cts:search(/organization,
		cts:and-query((
			cts:directory-query($config:RD-ORGANIZATION-PATH),
			cts:element-value-query(xs:QName('rd-organization:ORGANIZATION_ID'),$firmID)
		)))[1]
		
	let $add := cts:search(/organization-address,
		cts:and-query((
			cts:directory-query($config:RD-ORGANIZATION-ADDRESS-PATH),
			cts:element-value-query(xs:QName('org-address:ORGANIZATION_ID'),$firmID),
			cts:element-value-query(xs:QName('org-address:HEADQUARTERS'),'H',('case-insensitive'))
		)))[1]

	
	let $NLJ_250_NODE := doc(fn:concat($config:DD-SURVEY-NLJ_250-PATH,$firmID,'.xml'))/SURVEY/survey:YEAR
	let $NLJ_250_MAX := fn:max($NLJ_250_NODE/@PublishYear)
	let $NLJ_250 := $NLJ_250_NODE[@PublishYear = $NLJ_250_MAX]

	let $AMLAW_200_NODE := doc(fn:concat($config:DD-SURVEY-AMLAW_200-PATH,$firmID,'.xml'))/SURVEY/survey:YEAR
	let $AMLAW_200_MAX := fn:max($AMLAW_200_NODE/@PublishYear)
	let $TotalRevenueYear := fn:max($AMLAW_200_NODE/@FiscalYear)
	let $AMLAW_200 := $AMLAW_200_NODE[@PublishYear = $AMLAW_200_MAX]
	let $AMLAW200_RANK := $AMLAW_200/survey:AMLAW200_RANK/text()

	let $Global_100_NODE := doc(fn:concat($config:DD-SURVEY-GLOBAL_100-PATH,$firmID,'.xml'))/SURVEY/survey:YEAR
	let $Global_100_MAX := fn:max($Global_100_NODE/@PublishYear)
	let $Global_100 := $Global_100_NODE[@PublishYear = $Global_100_MAX]

	let $IsNonAMLawfirm := if ($AMLAW200_RANK) then 'false' else 'true'

	let $LawfirmDetail-obj := json:object()
	let $_ := (
		map:put($LawfirmDetail-obj,'FirmName',if($org/rd-organization:ALM_NAME/text()) then $org/rd-organization:ALM_NAME/text() else $org/rd-organization:ORGANIZATION_NAME/text()),
		map:put($LawfirmDetail-obj,'FirmId',$org/rd-organization:ORGANIZATION_ID/text()),
		map:put($LawfirmDetail-obj,'Address',$add/org-address:ADDRESS1/text()),
		map:put($LawfirmDetail-obj,'Address2',$add/org-address:ADDRESS2/text()),
		map:put($LawfirmDetail-obj,'City',$add/org-address:CITY/text()),
		map:put($LawfirmDetail-obj,'Zip',$add/org-address:ZIP/text()),
		map:put($LawfirmDetail-obj,'State',$add/org-address:STATE/text()),
		map:put($LawfirmDetail-obj,'Phone',$add/org-address:MAIN_PHONE/text()),
		map:put($LawfirmDetail-obj,'Fax',$add/org-address:FAX/text()),
		map:put($LawfirmDetail-obj,'Email',$add/org-address:EMAIL/text()),
		map:put($LawfirmDetail-obj,'Website',if($org/rd-organization:WEBSITE/text()) then fn:normalize-space(fn:replace($org/rd-organization:WEBSITE/text(),'http://','')) else ()),
		map:put($LawfirmDetail-obj,'HeadQuaters',fn:concat($add/org-address:CITY/text(),', ',$add/org-address:STATE/text())),
		map:put($LawfirmDetail-obj,'Country',$add/org-address:COUNTRY/text()),
		map:put($LawfirmDetail-obj,'TotalHeadcount', $NLJ_250/survey:NUM_ATTORNEYS/text()),
		map:put($LawfirmDetail-obj,'TotalOffice', firm:GetRELawFirmLocationCount($firmID)),
		map:put($LawfirmDetail-obj,'EquityPartner', $NLJ_250/survey:EQUITY_PARTNERS/text()),
		map:put($LawfirmDetail-obj,'NonEquityPartner', $NLJ_250/survey:NUM_NE_PARTNERS/text()),
		map:put($LawfirmDetail-obj,'Associate', $NLJ_250/survey:NUM_ASSOCIATES/text()),
		map:put($LawfirmDetail-obj,'GlobalRank', if($Global_100/survey:RANK_BY_GROSS_REVENUE/text() != '') then $Global_100/survey:RANK_BY_GROSS_REVENUE/text() else 0),
		map:put($LawfirmDetail-obj,'TotalRevenue', if($AMLAW_200/survey:GROSS_REVENUE/text()) then $AMLAW_200/survey:GROSS_REVENUE/text() else $Global_100/survey:GROSS_REVENUE/text()),
		map:put($LawfirmDetail-obj,'AdditionalInformation', $org/rd-organization:ADDITIONAL_INFORMATION/text()),
		map:put($LawfirmDetail-obj,'ProfitPerPartner', if($AMLAW_200/survey:PPP/text()) then $AMLAW_200/survey:PPP/text() else $Global_100/survey:PPP/text()),
		map:put($LawfirmDetail-obj,'RevenuePerLawyer', if($AMLAW_200/survey:RPL/text()) then $AMLAW_200/survey:RPL/text() else $Global_100/survey:REVENUE_PER_LAWYER/text()),
		map:put($LawfirmDetail-obj,'DescriptionText', $org/rd-organization:ORGANIZATION_PROFILE/text()),
		map:put($LawfirmDetail-obj,'TotalRevenueYear', $TotalRevenueYear)
	)

	let $return-obj := json:object()
	let $_ := (
		map:put($return-obj,'AmLawYear',$TotalRevenueYear),
		map:put($return-obj,'IsNonAMLawfirm',$IsNonAMLawfirm),
		map:put($return-obj,'LawfirmDetail',$LawfirmDetail-obj)
	)

	return $return-obj
};

declare function firm:GetREIdByOrgId($firmID)
{
	cts:search(/FIRMS_ALI_XREF_RE,
		cts:and-query((
			cts:collection-query($config:RD-FIRMS_ALI_XREF_RE-COLLECTION),
			cts:directory-query($config:RD-FIRMS_ALI_XREF_RE-PATH),
			cts:element-value-query(xs:QName('xref:ALI_ID'),$firmID)
		)))[1]/xref:RE_ID/text()
};

declare function firm:GetALIIdByREId($REId)
{
	cts:search(/FIRMS_ALI_XREF_RE,
		cts:and-query((
			 cts:collection-query($config:RD-FIRMS_ALI_XREF_RE-COLLECTION)
			,cts:directory-query($config:RD-FIRMS_ALI_XREF_RE-PATH)
			,cts:element-value-query(xs:QName('xref:RE_ID'),$REId)
		)))[1]/xref:ALI_ID/text()
};

declare function firm:sp_GetLawFirmStatics_Formattednew1($pageNo, $pageSize, $firmIds)
{
	(:
	let $start := xs:integer(((xs:integer($pageNo)*xs:integer($pageSize))-xs:integer($pageSize))+1)

	let $context := map:map()
	let $_ := map:put($context, 'output-types','application/json')
	let $companies-arr := json:array()

	let $dir-query := cts:directory-query($config:COMPANY-PATH,'1')
	let $firm-id-query := if($firmIds) then
			cts:element-value-query(xs:QName('lcc:company_id'),fn:tokenize($firmIds,','))
		else ()

	let $extract-metadata := 
																	<search:extract-metadata> 
																		<search:qname elem-ns='http://alm.com/LegalCompass/company' elem-name='company_id'/>
																		<search:qname elem-ns='http://alm.com/LegalCompass/company' elem-name='company'/>
																	</search:extract-metadata>

	let $search-options :=
																	<options xmlns='http://marklogic.com/appservices/search'>
																		<additional-query>{ cts:and-query(($dir-query,$firm-id-query)) }</additional-query>
		  {$extract-metadata}
																	</options>

	let $search-result := search:search('',$search-options,$start,$pageSize)



	let $_ := for $entry in $search-result//search:metadata
		let $company-obj := json:object()
		let $company-data := firm:GetLawFirmStatics($entry//lcc:company_id/text())
		let $_ := (
			map:put($company-obj, 'firmID', $entry//lcc:company_id/text()),
			map:put($company-obj, 'firmName', $entry//lcc:company/text()),

			map:put($company-obj, 'result',$company-data),

			map:put($company-obj, 'totalCount', $search-result/@total)
		)
		let $_ := json:array-push($companies-arr, $company-obj)
		return ()

	return $companies-arr
	:)
	'HELLO WORLD'
};

declare function firm:GetLawFirmStatics($firmId)
{
	(: let $firm-id-query := cts:element-value-query(xs:QName('lcc:company_id'),$firmId)

	let $search-options :=
																	<options xmlns='http://marklogic.com/appservices/search'>
																		<additional-query>{ $firm-id-query }</additional-query>
																	</options> :)

	(:let $search-result := search:search('',$search-options,$start,$pageSize):)

	(: return $search-options :)

	'HELLO WORLD'
};

declare function firm:GetRevenueByYear($OrganisationID)
{
	let $distinctYears := fn:distinct-values(cts:search(/,
			cts:directory-query('/LegalCompass/denormalized-data/surveys/AMLAW_200/','1')
        )//survey:YEAR/@PublishYear/string())

	let $distinctYears := for $year in $distinctYears
		order by xs:integer($year) descending
		return $year

	let $organization := fn:doc(fn:concat('/LegalCompass/denormalized-data/organization/',$OrganisationID,'.xml'))
	let $organizationID := $organization//organization:ORGANIZATION_ID/text()
	let $organizationName := $organization//organization:ORGANIZATION_SHORT_NAME/text()
	let $response-arr := json:array()


	let $data := for $year in fn:reverse($distinctYears[1 to 5])
		let $response-obj := json:object()
		let $res := cts:search(/,
				cts:and-query((
					cts:directory-query('/LegalCompass/denormalized-data/surveys/AMLAW_200/','1'),
					cts:element-attribute-value-query(xs:QName('survey:YEAR'),xs:QName('PublishYear'),$year),
					cts:element-attribute-value-query(xs:QName('survey:YEAR'),xs:QName('OrganizationID'),$OrganisationID)
				)))//survey:YEAR[@PublishYear = $year]

		let $_ := (
			map:put($response-obj,'ORGANIZATION_ID',xs:integer($organizationID)),
			map:put($response-obj,'ORGANIZATION_NAME',$organizationName),
			map:put($response-obj,'REVENUE',$res//survey:GROSS_REVENUE/text()),
			map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
		)

		let $_ := json:array-push($response-arr, $response-obj)
		return  ()

	return $response-arr
};

declare function firm:GetProfitMargin($OrganizationID)
{
	let $distinctYears := cts:element-attribute-values(xs:QName('survey:YEAR'),xs:QName('PublishYear'),(),('descending'),
		cts:and-query((
			cts:directory-query('/LegalCompass/denormalized-data/surveys/AMLAW_200/','1')
		)))

	let $organizationName := if((/organization[organization:ORGANIZATION_ID = xs:string($OrganizationID)]/organization:ALM_NAME/text())[1] ne '') then 
			/organization[organization:ORGANIZATION_ID = xs:string($OrganizationID)]/organization:ALM_NAME/text()[1]
		else 
			/organization[organization:ORGANIZATION_ID = xs:string($OrganizationID)]/organization:ORGANIZATION_NAME/text()[1]
    
	let $response-arr := json:array()

	let $data := for $year in fn:reverse($distinctYears[1 to 5])
		
		let $response-obj := json:object()
        let $res := cts:search(/,
            cts:and-query((
				cts:directory-query('/LegalCompass/denormalized-data/surveys/AMLAW_200/','1'),
				cts:element-attribute-value-query(xs:QName('survey:YEAR'),xs:QName('PublishYear'),xs:string($year)),
				cts:element-attribute-value-query(xs:QName('survey:YEAR'),xs:QName('OrganizationID'),$OrganizationID)
            )))//survey:YEAR[@PublishYear = $year]

		let $Margin := (xs:double(fn:format-number((xs:double($res//survey:NET_OPERATING_INCOME/text()) div xs:double($res//survey:GROSS_REVENUE/text())),'.00')) * 100)

		let $_ := (
			map:put($response-obj,'ORGANIZATION_ID',xs:integer($OrganizationID)),
			map:put($response-obj,'ORGANIZATION_NAME',$organizationName),
			map:put($response-obj,'MARGIN', $Margin),
			map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
		)
		let $_ := json:array-push($response-arr, $response-obj)               

		(: ----------------------Global100------------------------- :)
		let $res := cts:search(/Global_100:Global100,
			cts:and-query((	
				 cts:directory-query('/LegalCompass/relational-data/surveys/Global_100/')
				,cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($year))
			)))
      
		let $ppp := ''
		let $NUM_EQUITY_PARTNERS := ''
		let $GROSS_REVENUE := ''
		let $Margin := ''
		let $ppp := fn:sum($res/Global_100:PPP/text())
		let $NUM_EQUITY_PARTNERS := fn:sum($res/Global_100:NUM_EQUITY_PARTNERS/text())
		let $GROSS_REVENUE := fn:sum($res/Global_100:GROSS_REVENUE/text())
		let $Margin := fn:round-half-to-even((xs:double($ppp * $NUM_EQUITY_PARTNERS) div  $GROSS_REVENUE ), 2)
		
		let $response-obj := json:object()
        let $_ := (
			map:put($response-obj,'ORGANIZATION_ID',0),
            map:put($response-obj,'ORGANIZATION_NAME', 'Global 100'),
            map:put($response-obj,'MARGIN', $Margin), 
            map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
		)
		let $_ := json:array-push($response-arr, $response-obj)
		(: -------------------------AM Law 100---------------------- :)
		
		let $res := cts:search(/AMLAW_200:AMLaw200,
			cts:and-query((
				cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/')
				,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year))
				,cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
				,cts:element-range-query(xs:QName('AMLAW_200:AMLAW200_RANK'), '<=',100)
			)))
    
		let $NET_OPERATING_INCOME := 0
		let $GROSS_REVENUE := 0
		let $Margin := 0
		
		let $NET_OPERATING_INCOME := xs:decimal(fn:sum($res/AMLAW_200:NET_OPERATING_INCOME/text()))
		let $GROSS_REVENUE := xs:decimal(fn:sum($res/AMLAW_200:GROSS_REVENUE/text()))
		let $Margin := xs:double(fn:round-half-to-even(($NET_OPERATING_INCOME div $GROSS_REVENUE),2) *100)
	
        let $response-obj := json:object()
        let $_ := (
			map:put($response-obj,'ORGANIZATION_ID',0),
            map:put($response-obj,'ORGANIZATION_NAME', 'AM Law 100'),
            map:put($response-obj,'MARGIN', $Margin),
            map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
		)
		
		let $_ := json:array-push($response-arr, $response-obj) 
		
		(: -------------------------2nd Hundred---------------------- :)

        let $res := cts:search(/AMLAW_200:AMLaw200,
			cts:and-query((
				cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/')
				,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year))
				,cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
				,cts:element-range-query(xs:QName('AMLAW_200:AMLAW200_RANK'), '>',100)
			)))
    
		let $NET_OPERATING_INCOME := 0
		let $GROSS_REVENUE := 0
		let $Margin := 0
		
		let $NET_OPERATING_INCOME := xs:decimal(fn:sum($res/AMLAW_200:NET_OPERATING_INCOME/text()))
		let $GROSS_REVENUE := xs:decimal(fn:sum($res/AMLAW_200:GROSS_REVENUE/text()))
		let $Margin := xs:double(fn:round-half-to-even(($NET_OPERATING_INCOME div $GROSS_REVENUE),2) *100)
		
        let $response-obj := json:object()
        let $_ := (
			map:put($response-obj,'ORGANIZATION_ID',0),
            map:put($response-obj,'ORGANIZATION_NAME', '2nd Hundred'),
            map:put($response-obj,'MARGIN', $Margin), 
            map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
		)
		let $_ := json:array-push($response-arr, $response-obj)

		return  ()

	return $response-arr
};

declare function firm:GetRevenuePerLawyerByYear()
{
	let $request := xdmp:get-request-body()/request

	let $distinctYears := cts:element-attribute-values(xs:QName('survey:YEAR'),xs:QName('PublishYear'),(),('descending'),
							cts:and-query((
								cts:directory-query('/LegalCompass/denormalized-data/surveys/AMLAW_200/','1')
							)))

	let $distinctYears := if($request/StartYear/text() ne '' and $request/EndYear/text() ne '') then
                      for $year in $distinctYears
                      where ($year ge xs:integer($request/StartYear/text()) and EndYear le xs:integer($request/EndYear/text()))
                      return $year
                      else $distinctYears

	let $organization := fn:doc(fn:concat('/LegalCompass/denormalized-data/organization/',$request//OrganisationID,'.xml'))
	let $organizationID := $organization//organization:ORGANIZATION_ID/text()
	let $organizationName := $organization//organization:ORGANIZATION_SHORT_NAME/text()
	let $response-arr := json:array()


	let $data := for $year in fn:reverse($distinctYears[1 to 5])
				let $response-obj := json:object()
				let $res := cts:search(/,
									cts:and-query((
									cts:directory-query('/LegalCompass/denormalized-data/surveys/AMLAW_200/','1'),
									cts:element-attribute-value-query(xs:QName('survey:YEAR'),xs:QName('PublishYear'),xs:string($year)),
									cts:element-attribute-value-query(xs:QName('survey:YEAR'),xs:QName('OrganizationID'),$request//OrganisationID/text())
									)))//survey:YEAR[@PublishYear = $year]
				let $_ := (
								map:put($response-obj,'ORGANIZATION_ID',xs:integer($organizationID)),
							map:put($response-obj,'ORGANIZATION_NAME',$organizationName),
							map:put($response-obj,'REVENUE',$res//survey:RPL/text()),
							map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
								)
				let $_ := json:array-push($response-arr, $response-obj)
				return  ()
	return $response-arr
};

declare function firm:GetProfitLawyer()
{
	let $request := xdmp:get-request-body()/request
	let $distinctYears := cts:element-attribute-values(xs:QName('survey:YEAR'),xs:QName('PublishYear'),(),('descending'),
							cts:and-query((
							cts:directory-query('/LegalCompass/denormalized-data/surveys/AMLAW_200/','1')
										)))

	let $distinctYears := if($request/StartYear/text() ne '' and $request/EndYear/text() ne '') then
						for $year in $distinctYears
						(:where $year >= xs:integer($request/StartYear/text()) and EndYear <= xs:integer($request/EndYear/text()):)
						return $year
						else $distinctYears

	let $organization := fn:doc(fn:concat('/LegalCompass/denormalized-data/organization/',$request//OrganisationID,'.xml'))
	let $organizationID := $organization//organization:ORGANIZATION_ID/text()
	let $organizationName := $organization//organization:ORGANIZATION_SHORT_NAME/text()
	let $response-arr := json:array()


	let $data := for $year in fn:reverse($distinctYears[1 to 5])
				let $response-obj := json:object()
				let $res := cts:search(/,
									cts:and-query((
									cts:directory-query('/LegalCompass/denormalized-data/surveys/AMLAW_200/','1'),
									cts:element-attribute-value-query(xs:QName('survey:YEAR'),xs:QName('PublishYear'),xs:string($year)),
									cts:element-attribute-value-query(xs:QName('survey:YEAR'),xs:QName('OrganizationID'),$request//OrganisationID/text())
									)))//survey:YEAR[@PublishYear = $year]
				let $_ := (
							map:put($response-obj,'ORGANIZATION_ID',xs:integer($organizationID)),
							map:put($response-obj,'ORGANIZATION_NAME',$organizationName),
							map:put($response-obj,'REVENUE',$res//survey:RPL/text()),
							map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
								)
				let $_ := json:array-push($response-arr, $response-obj)
				return  ()
	return $response-arr
};

declare function firm:GetProfitPerEqityPartner()
{
	let $request := xdmp:get-request-body()/request

	let $distinctYears := cts:element-attribute-values(xs:QName('survey:YEAR'),xs:QName('PublishYear'),(),('descending'),
							cts:and-query((
							cts:directory-query('/LegalCompass/denormalized-data/surveys/AMLAW_200/','1')
							)))

	let $distinctYears := if($request/StartYear/text() ne '' and $request/EndYear/text() ne '') then
                      for $year in $distinctYears
                      where ($year ge xs:integer($request/StartYear/text()) and   $year le xs:integer($request/EndYear/text()))
                      return $year
                      else $distinctYears[1 to 5]

	let $organization := fn:doc(fn:concat('/LegalCompass/denormalized-data/organization/',$request//OrganisationID,'.xml'))
	let $organizationID := $organization//organization:ORGANIZATION_ID/text()
	let $organizationName := $organization//organization:ORGANIZATION_SHORT_NAME/text()
	let $response-arr := json:array()

	let $data := for $year in fn:reverse($distinctYears)
				let $response-obj := json:object()
				let $res := cts:search(/,
									cts:and-query((
									cts:directory-query('/LegalCompass/denormalized-data/surveys/AMLAW_200/','1'),
									cts:element-attribute-value-query(xs:QName('survey:YEAR'),xs:QName('PublishYear'),xs:string($year)),
									cts:element-attribute-value-query(xs:QName('survey:YEAR'),xs:QName('OrganizationID'),$request//OrganisationID/text())
									)))//survey:YEAR[@PublishYear = $year]

				let $_ := (
								map:put($response-obj,'ORGANIZATION_ID',xs:integer($organizationID)),
							map:put($response-obj,'ORGANIZATION_NAME',$organizationName),
							map:put($response-obj,'REVENUE', fn:format-number( $res/survey:PPP/text() , '.00')),
							map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
								)
				let $_ := json:array-push($response-arr, $response-obj) 

				let $res :=    cts:search(//survey:YEAR,
											cts:and-query((
											cts:directory-query('/LegalCompass/denormalized-data/surveys/AMLAW_200/','1'),
											cts:not-query(cts:element-value-query(xs:QName('survey:AMLAW200_RANK'),'')),
											cts:element-range-query(xs:QName('survey:AMLAW200_RANK'), '<=',100)
										)))

				let $avg-ppp := fn:format-number( fn:avg($res//survey:PPP/text()) ,'.00')
				let $response-obj := json:object()
				let $_ := (
								map:put($response-obj,'ORGANIZATION_ID',0),
							map:put($response-obj,'ORGANIZATION_NAME', 'AM Law 100'),
							map:put($response-obj,'REVENUE', $avg-ppp),
							map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
								)
				let $_ := json:array-push($response-arr, $response-obj)

				let $res :=  cts:search(//survey:YEAR,
											cts:and-query((
											cts:directory-query('/LegalCompass/denormalized-data/surveys/AMLAW_200/','1'),
											cts:not-query(cts:element-value-query(xs:QName('survey:AMLAW200_RANK'),'')),
											cts:element-range-query(xs:QName('survey:AMLAW200_RANK'), '>', xs:int('100'))
										)))
				let $avg-ppp1 := fn:format-number( fn:avg($res//survey:PPP/text()) ,'.00')
				let $response-obj := json:object()
				let $_ := (
								map:put($response-obj,'ORGANIZATION_ID',0),
							map:put($response-obj,'ORGANIZATION_NAME', '2nd Hundred'),
							map:put($response-obj,'REVENUE', $avg-ppp1), 
							map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
								)
				let $_ := json:array-push($response-arr, $response-obj) 

				return  $res

	return ($response-arr)
};

declare function firm:GetTotalHeadCount()
{
	let $request := xdmp:get-request-body()/request

	let $distinctYears := cts:element-attribute-values(xs:QName('survey:YEAR'),xs:QName('PublishYear'),(),('descending'),
	cts:and-query((
		cts:directory-query('/LegalCompass/denormalized-data/surveys/NLJ_250/','1')
	))
	)

	let $distinctYears := if($request/StartYear/text() ne '' and $request/EndYear/text() ne '') then
						for $year in $distinctYears
						(:where $year >= xs:integer($request/StartYear/text()) and EndYear <= xs:integer($request/EndYear/text()):)
						return $year
						else $distinctYears[1 to 5]

	let $OrganizationID := $request//OrganisationID/text()
	let $organizationName := if((/organization[organization:ORGANIZATION_ID = xs:string($OrganizationID)]/organization:ALM_NAME/text())[1] ne '')then 
		/organization[organization:ORGANIZATION_ID = xs:string($OrganizationID)]/organization:ALM_NAME/text()[1]
	else 
		/organization[organization:ORGANIZATION_ID = xs:string($OrganizationID)]/organization:ORGANIZATION_NAME/text()[1]
	let $response-arr := json:array()


	let $data := for $year in fn:reverse($distinctYears)
				let $response-obj := json:object()
				let $res := cts:search(/,
									cts:and-query((
									cts:directory-query('/LegalCompass/denormalized-data/surveys/NLJ_250/','1'),
									cts:element-attribute-value-query(xs:QName('survey:YEAR'),xs:QName('PublishYear'),xs:string($year)),
									cts:element-attribute-value-query(xs:QName('survey:YEAR'),xs:QName('OrganizationID'),$request//OrganisationID/text())
									)))//survey:YEAR[@PublishYear = $year]
				let $_ := (
								map:put($response-obj,'ORGANIZATION_ID',xs:integer($OrganizationID)),
							map:put($response-obj,'ORGANIZATION_NAME',$organizationName),
							map:put($response-obj,'COUNT',xs:decimal($res//survey:NUM_ATTORNEYS/text())),
							map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
								)
				let $_ := json:array-push($response-arr, $response-obj)
				(:return  ():)
				return  $res
	return $response-arr
	(:return $data:)
};

declare function firm:GetChangesinHeadcountByLocation()
{
	let $request := xdmp:get-request-body()/request
	let $StartYear := $request/StartYear/text()
	let $EndYear := $request/EndYear/text()
	let $OrganisationID := $request/OrganisationID/text()

	let $distinctYears := cts:element-attribute-values(xs:QName('survey:YEAR'),xs:QName('PublishYear'),(),('descending'),
	cts:and-query((
		cts:directory-query($config:DD-SURVEY-NLJ_250-PATH,'1')
	)))

	let $distinctYears := if($StartYear ne '' and $EndYear ne '') then
		for $year in $distinctYears
		where $year ge xs:integer($StartYear) and $year le xs:integer($EndYear)
		return $year
	else $distinctYears[1 to 5]
	
	let $PreviousYearValue := fn:min($distinctYears)
	let $CurrentYearValue := fn:max($distinctYears)

	let $max-data := for $x in cts:search(/organization-branch,
	cts:and-query((
		cts:directory-query($config:RD-ORGANIZATION_BRANCH-PATH,'1'),
		cts:element-value-query(xs:QName('organization-branch:FISCAL_YEAR'),xs:string(fn:max($distinctYears))),
		cts:element-value-query(xs:QName('organization-branch:ORGANIZATION_ID'),$OrganisationID)
	)))
	return element {'organization-branch'} {
		element {'ORGANIZATION_ID'} {$x/organization-branch:ORGANIZATION_ID/text()},
		element {'LOCATION'} {
		if(fn:not($x/organization-branch:STATE/text())) then
			fn:concat($x/organization-branch:CITY/text(),', ',$x/organization-branch:COUNTRY/text())
		else fn:concat($x/organization-branch:CITY/text(),', ',$x/organization-branch:STATE/text())
		},
		element {'NUM_ATTORNEYS'} {$x/organization-branch:NUM_ATTORNEYS/text()},
		element {'PUBLISHYEAR'} {$x/organization-branch:FISCAL_YEAR/text()}
	}

	let $all-data := for $x in cts:search(/organization-branch,
	cts:and-query((
		cts:directory-query($config:RD-ORGANIZATION_BRANCH-PATH,'1'),
		cts:element-value-query(xs:QName('organization-branch:FISCAL_YEAR'),xs:string(fn:max($distinctYears)-4)),
		cts:element-value-query(xs:QName('organization-branch:ORGANIZATION_ID'),$OrganisationID)
	)))
	return element {'organization-branch'} {
		element {'ORGANIZATION_ID'} {$x/organization-branch:ORGANIZATION_ID/text()},
		element {'LOCATION'} {
		if(fn:not($x/organization-branch:STATE/text())) then
			fn:concat($x/organization-branch:CITY/text(),', ',$x/organization-branch:COUNTRY/text())
		else fn:concat($x/organization-branch:CITY/text(),', ',$x/organization-branch:STATE/text())
		},
		element {'NUM_ATTORNEYS'} {$x/organization-branch:NUM_ATTORNEYS/text()},
		element {'PUBLISHYEAR'} {$x/organization-branch:FISCAL_YEAR/text()}
	}

	let $distinc-locations := fn:distinct-values(($max-data,$all-data)/LOCATION/text())

	let $response-arr := json:array()
	let $response := for $location in $distinc-locations

	let $data := if (($max-data/LOCATION[. = $location]) and ($all-data/LOCATION[. = $location])) then
		let $response-obj := json:object()

		let $CUR_NUM_ATTORNEYS := $max-data[LOCATION = $location]/NUM_ATTORNEYS/text()
		let $PRE_NUM_ATTORNEYS := $all-data[LOCATION = $location]/NUM_ATTORNEYS/text()
		let $NetChange := ($CUR_NUM_ATTORNEYS - $PRE_NUM_ATTORNEYS) 
		let $NetChangePos := if(($CUR_NUM_ATTORNEYS - $PRE_NUM_ATTORNEYS) lt 0 )
							then ($CUR_NUM_ATTORNEYS - $PRE_NUM_ATTORNEYS) * -1
							else ($CUR_NUM_ATTORNEYS - $PRE_NUM_ATTORNEYS)
		(:let $_ := (
			map:put($response-obj,'ORGANIZATION_ID',$max-data[LOCATION = $location]/ORGANIZATION_ID/text()),
			map:put($response-obj,'LOCATION',$max-data[LOCATION = $location]/LOCATION/text()),
			map:put($response-obj,'CUR_NUM_ATTORNEYS',$max-data[LOCATION = $location]/NUM_ATTORNEYS/text()),
			map:put($response-obj,'PRE_NUM_ATTORNEYS',$all-data[LOCATION = $location]/NUM_ATTORNEYS/text()),
			map:put($response-obj,'NETCHANGEPOS',$NetChangePos),
			map:put($response-obj,'NETCHANGEPOS',$max-data)
		):)
		let $_ := (
        map:put($response-obj,'Organization_Id',$max-data[LOCATION = $location]/ORGANIZATION_ID/text()),
		map:put($response-obj,'Organization_Name',$max-data[LOCATION = $location]/LOCATION/text()),
        map:put($response-obj,'LOCATION',$max-data[LOCATION = $location]/LOCATION/text()),
        map:put($response-obj,'CUR_NUM_ATTORNEYS',$max-data[LOCATION = $location]/NUM_ATTORNEYS/text()),
        map:put($response-obj,'PRE_NUM_ATTORNEYS',$all-data[LOCATION = $location]/NUM_ATTORNEYS/text()),
        map:put($response-obj,'NETCHANGE',$NetChange),
        map:put($response-obj,'NETCHANGEPOS',$NetChangePos),
		map:put($response-obj,'PreviousYearValue',$PreviousYearValue),
		map:put($response-obj,'CurrentYearValue',$CurrentYearValue)
		)
		let $_ := json:array-push($response-arr,$response-obj)
		return ()
	else ()
	return ()

	return $response-arr
};

declare function firm:GetHeadCountPercentage()
{
	let $request := xdmp:get-request-body()/request

	let $distinctYears := cts:element-attribute-values(xs:QName('survey:YEAR'),xs:QName('PublishYear'),(),('descending'),
	cts:and-query((
		cts:directory-query($config:DD-SURVEY-NLJ_250-PATH,'1')
	)))

	let $distinctYears:=  if( fn:not($request//StartYear/text()))
						then fn:max($distinctYears)
						else $distinctYears

	let $organization := fn:doc(fn:concat('/LegalCompass/denormalized-data/organization/',$request//OrganisationID,'.xml'))
	let $organizationID := $organization//organization:ORGANIZATION_ID/text()
	let $organizationName := $organization//organization:ORGANIZATION_SHORT_NAME/text()
	let $response-arr := json:array()

	let $data := for $year in ($distinctYears)
				let $response-obj := json:object()
				let $res := cts:search(/,
									cts:and-query((
									cts:directory-query($config:DD-SURVEY-NLJ_250-PATH,'1'),
									cts:element-attribute-value-query(xs:QName('survey:YEAR'),xs:QName('PublishYear'),xs:string($year)),
									cts:element-attribute-value-query(xs:QName('survey:YEAR'),xs:QName('OrganizationID'),$request//OrganisationID/text())
									)))//survey:YEAR[@PublishYear = $year]

				let $num_attorneys := $res//survey:NUM_ATTORNEYS/text()
				let $associates := $res//survey:NUM_ASSOCIATES/text() + $res//survey:NUM_OTHER_ATTORNEYS/text()
				let $Associate_Per := fn:format-number(($associates div $num_attorneys)*100 ,'.00')
				let $EquityPartner := $res//survey:EQUITY_PARTNERS/text()
				let $EquityPartner_Per := fn:format-number(($EquityPartner div $num_attorneys)*100 ,'.00')
				let $NonEquityPartner := $res//survey:NUM_NE_PARTNERS/text()
				let $NonEquityPartner_Per := fn:format-number(($NonEquityPartner div $num_attorneys)*100 ,'.00')
				let $_ := (
								map:put($response-obj,'ORGANIZATION_ID',xs:integer($organizationID)),
							map:put($response-obj,'ORGANIZATION_NAME',$organizationName),
							map:put($response-obj,'Associates', $associates),
							map:put($response-obj,'Associate_Per', $Associate_Per),
							map:put($response-obj,'EquityPartner_Per', $EquityPartner_Per),
							map:put($response-obj,'EquityPartner', $EquityPartner),
							map:put($response-obj,'NonEquityPartner', $NonEquityPartner),
							map:put($response-obj,'NonEquityPartner_Per', $NonEquityPartner_Per),
							map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
							)
				let $_ := json:array-push($response-arr, $response-obj)
				return $num_attorneys

	return $response-arr
};

declare function firm:GetFirmStaffingDiversityMetrics()
{
	let $request := xdmp:get-request-body()/request

	let $distinctYears := cts:element-attribute-values(xs:QName('survey:YEAR'),xs:QName('PublishYear'),(),('descending'),
	cts:and-query((
		cts:directory-query($config:DD-SURVEY-AMLAW_200-PATH,'1')
	)))[1 to 5]

	let $response-arr := json:array()
	let $data := for $year in fn:reverse($distinctYears)
				let $response-obj := json:object()
				let $a := cts:search(//survey:YEAR,
									cts:and-query((
									cts:directory-query($config:DD-SURVEY-AMLAW_200-PATH,'1'),
									cts:element-attribute-value-query(xs:QName('survey:YEAR'),xs:QName('PublishYear'),xs:string($year)),
									cts:element-attribute-value-query(xs:QName('survey:YEAR'),xs:QName('OrganizationID'),$request//OrganisationID/text())
									)))
				let $b := cts:search(//survey:YEAR,
									cts:and-query((
									cts:directory-query($config:DD-SURVEY-DIVERSITY_SCORECARD-PATH,'1'),
									cts:element-attribute-value-query(xs:QName('survey:YEAR'),xs:QName('PublishYear'),xs:string($year)),
									cts:element-attribute-value-query(xs:QName('survey:YEAR'),xs:QName('OrganizationID'),$request//OrganisationID/text())
									)))
				let $c := cts:search(//survey:YEAR,
									cts:and-query((
									cts:directory-query($config:DD-SURVEY-FEMALE_SCORECARD-PATH,'1'),
									cts:element-attribute-value-query(xs:QName('survey:YEAR'),xs:QName('PublishYear'),xs:string($year)),
									cts:element-attribute-value-query(xs:QName('survey:YEAR'),xs:QName('OrganizationID'),$request//OrganisationID/text())
									)))
				let $d := cts:search(//survey:YEAR,
									cts:and-query((
									cts:directory-query($config:DD-SURVEY-NLJ_LGBT-PATH,'1'),
									cts:element-attribute-value-query(xs:QName('survey:YEAR'),xs:QName('PublishYear'),xs:string($year)),
									cts:element-attribute-value-query(xs:QName('survey:YEAR'),xs:QName('OrganizationID'),$request//OrganisationID/text())
									)))    
				(:let $PercentageOfLgbtPartners :=   fn:format-number(((($d/survey:TOTAL_LGBT_ATTORNEYS/text()) - ($d/survey:LGBT_PARTNERS/text())) div $d/survey:TOTAL_LGBT_ATTORNEYS/string()) * 100 , '00'):)
				(:let $PercentageOfLgbtPartners :=  (((($d/survey:TOTAL_LGBT_ATTORNEYS/text()) - ($d/survey:LGBT_PARTNERS/text())) div ($d/survey:TOTAL_LGBT_ATTORNEYS/text())) * 100)
				let $PercentageOfLgbtPartners := if($PercentageOfLgbtPartners > 0)
												then xs:decimal(fn:format-number(((($d/survey:TOTAL_LGBT_ATTORNEYS/text()) - ($d/survey:LGBT_PARTNERS/text())) div ($d/survey:TOTAL_LGBT_ATTORNEYS/text())) * 100 , '.00'))
												else ()
				:)
				let $LGBT_PARTNERS := $d/survey:LGBT_PARTNERS/text()
				let $PercentageOfLgbtPartners := if($LGBT_PARTNERS != 0 and $LGBT_PARTNERS ne "")
					then xs:decimal(fn:format-number(((($d/survey:TOTAL_LGBT_ATTORNEYS/text()) - ($d/survey:LGBT_PARTNERS/text())) div ($d/survey:TOTAL_LGBT_ATTORNEYS/text())) * 100 , '.00'))
					else 0
				let $AfricanAmericanAttorneys := $b/survey:AFRICAN_AMERICAN_PARTNERS + $b/survey:AFRICAN_AMERICAN_ASSOCIATES
				let $AsianAmericanAttorneys := $b/survey:ASIAN_AMERICAN_PARTNERS + $b/survey:ASIAN_AMERICAN_ASSOCIATES
				let $HispanicLatinoAttorneys := $b/survey:HISPANIC_ASSOCIATES + $b/survey:HISPANIC_PARTNERS
				let $_ := (
								map:put($response-obj,'ORGANIZATIONID', xs:integer($a/@OrganizationID/string())),
							map:put($response-obj,'ORGANIZATIONNAME', $a/@OrganizationName/string()),
							map:put($response-obj,'PUBLISHYEAR',  xs:integer($a/@PublishYear/string())),
							map:put($response-obj,'FirmDiversityRank',  xs:integer($b/survey:DIVERSITY_RANK/string())),
							map:put($response-obj,'FirmGenderRank',  xs:integer($c/survey:WOMEN_IN_LAW_RANK/string())),
							map:put($response-obj,'FirmLgbtRank',  xs:integer($d/survey:NLJ_LGBT_RANK/string())),
							map:put($response-obj,'USATTORNEYS',  xs:integer($b/survey:US_ATTORNEYS/string())),
							map:put($response-obj,'PercentageOfMinorityAttorneys',  xs:decimal($b/survey:MINORITY_PERCENTAGE/string()) * 100),
							map:put($response-obj,'PercentageOfFemaleAttorneys',  xs:decimal($c/survey:PCT_FEMALE_ATTORNEYS/string()) * 100),
							map:put($response-obj,'PercentageOfLgbtAttorneys',  xs:decimal($d/survey:PERCENT_LGBT_ATTORNEYS/string()) * 100),
							map:put($response-obj,'PercentageOfMinorityPartners',  xs:decimal($b/survey:MINORITY_PERC_PARTNERS/string()) * 100),
							map:put($response-obj,'PercentageOfFemalePartners',  xs:decimal($c/survey:PCT_FEMALE_PARTNERS/string()) * 100),
							map:put($response-obj,'PercentageOfLgbtPartners',  ($PercentageOfLgbtPartners)),
							map:put($response-obj,'AfricanAmericanAttorneys',  xs:decimal($AfricanAmericanAttorneys)),
							map:put($response-obj,'AsianAmericanAttorneys',  xs:decimal($AsianAmericanAttorneys)),
							map:put($response-obj,'HispanicLatinoAttorneys',  xs:decimal($HispanicLatinoAttorneys)),
							map:put($response-obj,'MultiracialOtherMinorityAtt',  xs:decimal($b/survey:TOTAL_MINORITY_ATTORNEYS/text()))
								)
				let $_ := json:array-push($response-arr, $response-obj)              
				return  ()
	return ($response-arr)
};

declare function firm:GetDiversityPartnerPieChart()
{
	let $request := xdmp:get-request-body()/request

	let $distinctYears := max(cts:element-attribute-values(xs:QName('survey:YEAR'),xs:QName('PublishYear'),(),('descending'),
	cts:and-query((
		cts:directory-query($config:DD-SURVEY-DIVERSITY_SCORECARD-PATH,'1')
	))))

	let $response-arr := json:array()
	let $data := for $year in fn:reverse($distinctYears)
				let $response-obj := json:object()
				let $res := cts:search(//survey:YEAR,
									cts:and-query((
									cts:directory-query($config:DD-SURVEY-DIVERSITY_SCORECARD-PATH,'1'),
									cts:element-attribute-value-query(xs:QName('survey:YEAR'),xs:QName('PublishYear'),xs:string($year)),
									cts:element-attribute-value-query(xs:QName('survey:YEAR'),xs:QName('OrganizationID'),$request//OrganisationID/text())
									)))  

				let $AFRICAN_AMERICAN_PARTNERS := xs:integer($res/survey:AFRICAN_AMERICAN_PARTNERS/string())
				let $HISPANIC_PARTNERS := xs:integer($res/survey:HISPANIC_PARTNERS/string())
				let $ASIAN_AMERICAN_PARTNERS := xs:integer($res/survey:ASIAN_AMERICAN_PARTNERS/string())
				let $OTHER_PARTNERS := xs:integer($res/survey:OTHER_PARTNERS/string())
				let $MINORITY_PERC_PARTNERS := xs:decimal($res/survey:MINORITY_PERC_PARTNERS/string())
				let $CAUCASIANPARTNERS := fn:format-number((($ASIAN_AMERICAN_PARTNERS+$AFRICAN_AMERICAN_PARTNERS+$HISPANIC_PARTNERS+$OTHER_PARTNERS) div $MINORITY_PERC_PARTNERS)-($ASIAN_AMERICAN_PARTNERS+$AFRICAN_AMERICAN_PARTNERS+$HISPANIC_PARTNERS+$OTHER_PARTNERS), '00')

				let $_ := (
								map:put($response-obj,'ORGANIZATIONID', xs:integer($res/@OrganizationID/string())),
							map:put($response-obj,'ORGANIZATIONNAME', $res/@OrganizationName/string()),
							map:put($response-obj,'PUBLISHYEAR',  xs:integer($res/@PublishYear/string())),
							map:put($response-obj,'AFRICANAMERICANPARTNERS', $AFRICAN_AMERICAN_PARTNERS),
							map:put($response-obj,'HISPANICPARTNERS', $HISPANIC_PARTNERS),
							map:put($response-obj,'ASIANAMERICANPARTNERS',  $ASIAN_AMERICAN_PARTNERS),
							map:put($response-obj,'OTHERPARTNERS', $OTHER_PARTNERS),
							map:put($response-obj,'CAUCASIANPARTNERS', $CAUCASIANPARTNERS)
							)
				let $_ := json:array-push($response-arr, $response-obj)              
				return ()

	return ($response-arr)
};

declare function firm:GetDiversityGrowth($OrganisationID)
{
	let $distinctYears := (cts:element-values(xs:QName('Diversity_Scorecard:PUBLISHYEAR'),(),('descending'),
		cts:and-query((
			cts:directory-query('/LegalCompass/relational-data/surveys/Diversity_Scorecard/','1')
		))))

	let $response-arr := json:array()
	
	let $data := for $year in fn:reverse($distinctYears[1 to 5])
		let $response-obj := json:object()
		let $res := cts:search(/Diversity_Scorecard:DiversityScorecard,
			cts:and-query((
				 cts:directory-query('/LegalCompass/relational-data/surveys/Diversity_Scorecard/','1')
				,cts:element-value-query(xs:QName('Diversity_Scorecard:PUBLISHYEAR'),xs:string($year))
				,cts:element-value-query(xs:QName('Diversity_Scorecard:ORGANIZATION_ID'),$OrganisationID)
			)))  
		
		let $total_attorneys := $res/Diversity_Scorecard:TOTAL_ATTORNEYS/text()
		let $PerOfMinorityAttorneys := fn:round-half-to-even(($res/Diversity_Scorecard:TOTAL_MINORITY_ATTORNEYS/text() div $total_attorneys) * 100 , 2)
		let $PerOfAfricanAmericanAttorneys := fn:round-half-to-even((($res/Diversity_Scorecard:AFRICAN_AMERICAN_ASSOCIATES/text() + $res/Diversity_Scorecard:AFRICAN_AMERICAN_PARTNERS/text()) div $total_attorneys) * 100 , 2)
		let $PerOfAsianAmericanAttorneys := fn:round-half-to-even((($res/Diversity_Scorecard:ASIAN_AMERICAN_ASSOCIATES/text() + $res/Diversity_Scorecard:ASIAN_AMERICAN_PARTNERS/text()) div $total_attorneys) * 100 , 2)
		let $PerOfHispanicLatinoAttorneys := fn:round-half-to-even((($res/Diversity_Scorecard:HISPANIC_ASSOCIATES/text() + $res/Diversity_Scorecard:HISPANIC_PARTNERS/text()) div $total_attorneys) * 100 , 2)
		let $PerOfMultiracialOtherAttorneys := if(($res/Diversity_Scorecard:OTHER_ATTORNEYS/text() ne '' ))then
				fn:round-half-to-even((($res/Diversity_Scorecard:OTHER_ATTORNEYS/text()) div $total_attorneys) * 100 , 2)
			else ()
			
		(: fn:round-half-to-even(( ( ( $res - map:get($Lag1-obj,'GROSSREVENUE') ) div map:get($Lag1-obj,'GROSSREVENUE') ) * 100 ), 2) :)
		
		
		let $_ := (
			map:put($response-obj,'ORGANIZATIONID', xs:integer($res/Diversity_Scorecard:ORGANIZATION_ID/text())),
			map:put($response-obj,'ORGANIZATIONNAME', ($res/Diversity_Scorecard:ORGANIZATION_NAME/text())),
			map:put($response-obj,'PUBLISHYEAR', xs:integer($res/Diversity_Scorecard:PUBLISHYEAR/text())),
			map:put($response-obj,'PerOfMinorityAttorneys', xs:decimal($PerOfMinorityAttorneys)),
			map:put($response-obj,'PerOfAfricanAmericanAttorneys', xs:decimal($PerOfAfricanAmericanAttorneys)),
			map:put($response-obj,'PerOfAsianAmericanAttorneys', xs:decimal($PerOfAsianAmericanAttorneys)),
			map:put($response-obj,'PerOfHispanicLatinoAttorneys', xs:decimal($PerOfHispanicLatinoAttorneys)),
			map:put($response-obj,'PerOfMultiracialOtherAttorneys',($PerOfMultiracialOtherAttorneys))
		) 
		
		let $_ := json:array-push($response-arr, $response-obj)
		return $PerOfAfricanAmericanAttorneys

	return ($response-arr)
	(: return ($data) :)
};

declare function firm:GetRevenueChanges()
{
	let $request := xdmp:get-request-body()/request
	
	let $distinctYears := cts:element-attribute-values(xs:QName('survey:YEAR'),xs:QName('PublishYear'),(),('descending'),
	cts:and-query((
		cts:directory-query('/LegalCompass/denormalized-data/surveys/AMLAW_200/','1')
	)))

let $distinctYears := if($request/StartYear/text() ne "" and $request/EndYear/text() ne "") then
                      for $year in $distinctYears
                      where $year >= xs:integer($request/StartYear/text()) and   $year lt xs:integer($request/EndYear/text())
                      return $year
                      else $distinctYears[1 to 5]
                      
let $OrganizationID := $request//OrganisationID/text()
let $organizationName := if((/organization[organization:ORGANIZATION_ID = xs:string($OrganizationID)]/organization:ALM_NAME/text())[1] ne '')then 
  /organization[organization:ORGANIZATION_ID = xs:string($OrganizationID)]/organization:ALM_NAME/text()[1]
else 
  /organization[organization:ORGANIZATION_ID = xs:string($OrganizationID)]/organization:ORGANIZATION_NAME/text()[1]
		
	let $response-arr := json:array()
	let $Lag1-obj := json:object()
	
	let $data := for $year in (reverse($distinctYears))
	
	let $response-obj := json:object()
	let $res := cts:search(//survey:YEAR,
		cts:and-query((
		cts:directory-query('/LegalCompass/denormalized-data/surveys/AMLAW_200/','1'),
		cts:element-attribute-value-query(xs:QName('survey:YEAR'),xs:QName('PublishYear'),xs:string($year)),
		cts:element-attribute-value-query(xs:QName('survey:YEAR'),xs:QName('OrganizationID'),$request//OrganisationID/text())
		)))//survey:GROSS_REVENUE/text()
		
	let $gross_revenue := if(fn:exists(map:get($Lag1-obj,'GROSSREVENUE')))then (
		fn:round-half-to-even(( ( ( $res - map:get($Lag1-obj,'GROSSREVENUE') ) div map:get($Lag1-obj,'GROSSREVENUE') ) * 100 ), 2)
		)
	else
	(
	let $GROSS_REVENUE_LGV := cts:search(//survey:YEAR,
		cts:and-query((
		cts:directory-query('/LegalCompass/denormalized-data/surveys/AMLAW_200/','1'),
		cts:element-attribute-value-query(xs:QName('survey:YEAR'),xs:QName('PublishYear'),xs:string($year - 1)),
		cts:element-attribute-value-query(xs:QName('survey:YEAR'),xs:QName('OrganizationID'),$request//OrganisationID/text())
		)))[1]//survey:GROSS_REVENUE/text()
		
	return fn:round-half-to-even(((($res - $GROSS_REVENUE_LGV) div $GROSS_REVENUE_LGV ) * 100 ), 2)
	)
		
	let $_ := (
		map:put($response-obj,'ORGANIZATION_ID',xs:integer($OrganizationID)),
		map:put($response-obj,'ORGANIZATION_NAME',$organizationName),
		map:put($response-obj,'CHANGE', $gross_revenue),
		map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
		)
	let $_ := json:array-push($response-arr, $response-obj)
	let $_ := map:put($Lag1-obj,'CHANGE',$res)
	(:------------Global 100 part------------------:)
    let $response-obj := json:object()
  
	let $distinctid_global_100  := cts:element-values(xs:QName("Global_100:ORGANIZATION_ID"),(),(),
    cts:and-query((
      cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/")      
      ,cts:element-value-query(xs:QName("Global_100:PUBLISHYEAR"),xs:string($year))
      ,cts:not-query(cts:element-value-query(xs:QName("Global_100:RANK_BY_GROSS_REVENUE"),""))
    )))
  
   let $res4 := xs:integer(sum(cts:search(/,
    cts:and-query((
      cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/") 
      ,cts:element-value-query(xs:QName("Global_100:ORGANIZATION_ID"),($distinctid_global_100 ! xs:string(.)))
      ,cts:element-value-query(xs:QName("Global_100:PUBLISHYEAR"), xs:string($year))
    )))//Global_100:GROSS_REVENUE/text()))
    
   let $distinctid_global_100  := cts:element-values(xs:QName("Global_100:ORGANIZATION_ID"),(),(),
    cts:and-query((
      cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/")      
      ,cts:element-value-query(xs:QName("Global_100:PUBLISHYEAR"),xs:string($year - 1))
      ,cts:not-query(cts:element-value-query(xs:QName("Global_100:RANK_BY_GROSS_REVENUE"),""))
    )))
  
   let $lag4 := xs:integer(sum(cts:search(/,
    cts:and-query((
      cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/") 
      ,cts:element-value-query(xs:QName("Global_100:ORGANIZATION_ID"),($distinctid_global_100 ! xs:string(.)))
      ,cts:element-value-query(xs:QName("Global_100:PUBLISHYEAR"), xs:string($year - 1))
    )))//Global_100:GROSS_REVENUE/text()))
    
   let $CHANGE := fn:round-half-to-even((xs:double($res4 - $lag4) div  $lag4 ) * 100 , 2)    
    
   let $_ := (
	    map:put($response-obj,'ORGANIZATION_ID', 0),
      map:put($response-obj,'ORGANIZATION_NAME', 'Global 100'),
      map:put($response-obj,'CHANGE', $CHANGE),
      map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
	  )
    let $_ := json:array-push($response-arr, $response-obj)
	(:----------------------------------------------------------------------------------:)
	
	let $distinctid_lt_100  :=cts:element-values(xs:QName('firm-org:OrganizationID'),(),(),
		cts:and-query((
		cts:directory-query('/LegalCompass/denormalized-data/law-firm/survey/')
		,cts:element-range-query(xs:QName('firm-org:AMLAW200_RANK'), '<=',100)
		,cts:element-value-query(xs:QName('firm-org:PUBLISHYEAR'),xs:string($year))
		,cts:not-query(cts:element-value-query(xs:QName('firm-org:AMLAW200_RANK'),''))
		)))
	let $response-obj := json:object()
	
	let $res2 := xs:integer(sum(cts:search(/,
		cts:and-query((
		cts:directory-query('/LegalCompass/denormalized-data/law-firm/survey/','1')
		,cts:element-value-query(xs:QName('firm-org:OrganizationID'),($distinctid_lt_100 ! xs:string(.)))
		,cts:element-value-query(xs:QName('firm-org:PUBLISHYEAR'), xs:string($year))
		)))//firm-org:AMLAW_200_GROSS_REVENUE/text()))
		
	let $distinctid_lt_100  :=cts:element-values(xs:QName('firm-org:OrganizationID'),(),(),
		cts:and-query((
		cts:directory-query('/LegalCompass/denormalized-data/law-firm/survey/')
		,cts:element-range-query(xs:QName('firm-org:AMLAW200_RANK'), '<=',100)
		,cts:element-value-query(xs:QName('firm-org:PUBLISHYEAR'),xs:string($year - 1))
		,cts:not-query(cts:element-value-query(xs:QName('firm-org:AMLAW200_RANK'),''))
		)))
		
	let $res2-LAG := xs:integer(sum(cts:search(/,
		cts:and-query((
		cts:directory-query('/LegalCompass/denormalized-data/law-firm/survey/','1')
		,cts:element-value-query(xs:QName('firm-org:OrganizationID'),($distinctid_lt_100 ! xs:string(.)))
		,cts:element-value-query(xs:QName('firm-org:PUBLISHYEAR'), xs:string($year - 1))
		)))//firm-org:AMLAW_200_GROSS_REVENUE/text()))
		
	let $CHANGE := fn:round-half-to-even((xs:double($res2 - $res2-LAG) div  $res2-LAG ) * 100 , 2)
	
	let $_ := (
			map:put($response-obj,'ORGANIZATION_ID', 0),
		map:put($response-obj,'ORGANIZATION_NAME', 'Am Law 100'),
		map:put($response-obj,'CHANGE', $CHANGE),
		map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
		)
	let $_ := json:array-push($response-arr, $response-obj)
		
	(:----------------------------------------------------------------:)
	
	let $response-obj := json:object()
	
	let $distinctid_gt_100  :=cts:element-values(xs:QName('firm-org:OrganizationID'),(),(),
		cts:and-query((
		cts:directory-query('/LegalCompass/denormalized-data/law-firm/survey/')
		,cts:element-range-query(xs:QName('firm-org:AMLAW200_RANK'), '>',100)
		,cts:element-value-query(xs:QName('firm-org:PUBLISHYEAR'),xs:string($year))
		,cts:not-query(cts:element-value-query(xs:QName('firm-org:AMLAW200_RANK'),''))
		)))
	
	let $res3 := xs:integer(sum(cts:search(/,
		cts:and-query((
		cts:directory-query('/LegalCompass/denormalized-data/law-firm/survey/','1')
		,cts:element-value-query(xs:QName('firm-org:OrganizationID'),($distinctid_gt_100 ! xs:string(.)))
		,cts:element-value-query(xs:QName('firm-org:PUBLISHYEAR'), xs:string($year))
		)))//firm-org:AMLAW_200_GROSS_REVENUE/text()))
		
		let $distinctid_gt_100  :=cts:element-values(xs:QName('firm-org:OrganizationID'),(),(),
		cts:and-query((
		cts:directory-query('/LegalCompass/denormalized-data/law-firm/survey/')
		,cts:element-range-query(xs:QName('firm-org:AMLAW200_RANK'), '>',100)
		,cts:element-value-query(xs:QName('firm-org:PUBLISHYEAR'),xs:string($year - 1 ))
		,cts:not-query(cts:element-value-query(xs:QName('firm-org:AMLAW200_RANK'),''))
		)))
		
		let $res3-LAG := xs:integer(sum(cts:search(/,
		cts:and-query((
		cts:directory-query('/LegalCompass/denormalized-data/law-firm/survey/','1')
		,cts:element-value-query(xs:QName('firm-org:OrganizationID'),($distinctid_gt_100 ! xs:string(.)))
		,cts:element-value-query(xs:QName('firm-org:PUBLISHYEAR'), xs:string($year - 1))
		)))//firm-org:AMLAW_200_GROSS_REVENUE/text()))
		
		let $CHANGE := fn:round-half-to-even((xs:double($res3 - $res3-LAG) div  $res3-LAG ) * 100 , 2)
		
		let $_ := (
			map:put($response-obj,'ORGANIZATION_ID', 0),
		map:put($response-obj,'ORGANIZATION_NAME', '2nd Hundred'),
		map:put($response-obj,'CHANGE', $CHANGE),
		map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
		)
		let $_ := json:array-push($response-arr, $response-obj)
	  
	return ()
	return ($response-arr)
};

declare function firm:GetRevenuePerLawyerChanges()
{
	let $request := xdmp:get-request-body()/request
	
	let $distinctYears := cts:element-attribute-values(xs:QName('survey:YEAR'),xs:QName('PublishYear'),(),('descending'),
	cts:and-query((
		cts:directory-query('/LegalCompass/denormalized-data/surveys/AMLAW_200/','1')
	)))
let $distinctYears := if($request/StartYear/text() ne "" and $request/EndYear/text() ne "") then
                      for $year in $distinctYears
                      where $year >= xs:integer($request/StartYear/text()) and   $year lt xs:integer($request/EndYear/text())
                      return $year
                      else $distinctYears[1 to 5]	
  
let $OrganizationID := $request//OrganisationID/text()
let $organizationName := if((/organization[organization:ORGANIZATION_ID = xs:string($OrganizationID)]/organization:ALM_NAME/text())[1] ne '')then 
	/organization[organization:ORGANIZATION_ID = xs:string($OrganizationID)]/organization:ALM_NAME/text()[1]
else 
	/organization[organization:ORGANIZATION_ID = xs:string($OrganizationID)]/organization:ORGANIZATION_NAME/text()[1]
		
let $response-arr := json:array()
let $Lag1-obj := json:object()
	
let $data := for $year in (reverse($distinctYears))
	let $response-obj := json:object()
	
	let $res := cts:search(//survey:YEAR,
		cts:and-query((
		cts:directory-query('/LegalCompass/denormalized-data/surveys/AMLAW_200/','1'),
		cts:element-attribute-value-query(xs:QName('survey:YEAR'),xs:QName('PublishYear'),xs:string($year)),
		cts:element-attribute-value-query(xs:QName('survey:YEAR'),xs:QName('OrganizationID'),$request//OrganisationID/text())
		)))//survey:RPL/text()
		
		let $rpl := if(fn:exists(map:get($Lag1-obj,'RPL')))then (
			fn:round-half-to-even(( ( ( $res - map:get($Lag1-obj,'RPL') ) div map:get($Lag1-obj,'RPL') ) * 100 ), 2)
		)
		else (
			let $rpl_LGV := cts:search(//survey:YEAR,
			cts:and-query((
				cts:directory-query('/LegalCompass/denormalized-data/surveys/AMLAW_200/','1'),
				cts:element-attribute-value-query(xs:QName('survey:YEAR'),xs:QName('PublishYear'),xs:string($year - 1)),
				cts:element-attribute-value-query(xs:QName('survey:YEAR'),xs:QName('OrganizationID'),$request//OrganisationID/text())
			)))[1]//survey:RPL/text()
			
			return fn:round-half-to-even(((($res - $rpl_LGV) div $rpl_LGV ) * 100 ), 2)
		)
		
		let $_ := (
			map:put($response-obj,'ORGANIZATION_ID',xs:integer($OrganizationID)),
		map:put($response-obj,'ORGANIZATION_NAME',$organizationName),
		map:put($response-obj,'CHANGE', $rpl),
		map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
		)
	let $_ := json:array-push($response-arr, $response-obj)
	let $_ := map:put($Lag1-obj,'RPL',$res)
	(:------------Global 100 part------------------:)
  let $response-obj := json:object()
  
  let $distinctid_global_100  := cts:element-values(xs:QName("Global_100:ORGANIZATION_ID"),(),(),
    cts:and-query((
      cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/")      
      ,cts:element-value-query(xs:QName("Global_100:PUBLISHYEAR"),xs:string($year))
      ,cts:not-query(cts:element-value-query(xs:QName("Global_100:RANK_BY_GROSS_REVENUE"),""))
    )))
  
  let $res4 := xs:integer(sum(cts:search(/,
    cts:and-query((
      cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/") 
      ,cts:element-value-query(xs:QName("Global_100:ORGANIZATION_ID"),($distinctid_global_100 ! xs:string(.)))
      ,cts:element-value-query(xs:QName("Global_100:PUBLISHYEAR"), xs:string($year))
    )))//Global_100:REVENUE_PER_LAWYER/text()))
    
   let $distinctid_global_100  := cts:element-values(xs:QName("Global_100:ORGANIZATION_ID"),(),(),
    cts:and-query((
      cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/")      
      ,cts:element-value-query(xs:QName("Global_100:PUBLISHYEAR"),xs:string($year - 1))
      ,cts:not-query(cts:element-value-query(xs:QName("Global_100:RANK_BY_GROSS_REVENUE"),""))
    )))
  
   let $lag4 := xs:integer(sum(cts:search(/,
    cts:and-query((
      cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/") 
      ,cts:element-value-query(xs:QName("Global_100:ORGANIZATION_ID"),($distinctid_global_100 ! xs:string(.)))
      ,cts:element-value-query(xs:QName("Global_100:PUBLISHYEAR"), xs:string($year - 1))
    )))//Global_100:REVENUE_PER_LAWYER/text()))
    
   let $CHANGE := fn:round-half-to-even((xs:double($res4 - $lag4) div  $lag4 ) * 100 , 2)    
    
   let $_ := (
	    map:put($response-obj,'ORGANIZATION_ID', 0),
      map:put($response-obj,'ORGANIZATION_NAME', 'Global 100'),
      map:put($response-obj,'CHANGE', $CHANGE),
      map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
	  )
    let $_ := json:array-push($response-arr, $response-obj)
	(:----------------------------------------------------------------------------------:)
	
	let $response-obj := json:object()
	let $distinctid_lt_100  := cts:element-values(xs:QName('firm-org:OrganizationID'),(),(),
		cts:and-query((
		cts:directory-query('/LegalCompass/denormalized-data/law-firm/survey/')
		,cts:element-range-query(xs:QName('firm-org:AMLAW200_RANK'), '<=',100)
		,cts:element-value-query(xs:QName('firm-org:PUBLISHYEAR'),xs:string($year))
		,cts:not-query(cts:element-value-query(xs:QName('firm-org:AMLAW200_RANK'),''))
		)))
		
	let $res2 := sum(cts:search(/,
		cts:and-query((
		cts:directory-query('/LegalCompass/denormalized-data/law-firm/survey/','1')
		,cts:element-value-query(xs:QName('firm-org:OrganizationID'),($distinctid_lt_100 ! xs:string(.)))
		,cts:element-value-query(xs:QName('firm-org:PUBLISHYEAR'), xs:string($year))
		,cts:not-query(cts:element-value-query(xs:QName('firm-org:AMLAW_200_RPL'),''))
		)))//firm-org:AMLAW_200_RPL/text())
		
	let $distinctid_lt_100  :=cts:element-values(xs:QName('firm-org:OrganizationID'),(),(),
		cts:and-query((
		cts:directory-query('/LegalCompass/denormalized-data/law-firm/survey/')
		,cts:element-range-query(xs:QName('firm-org:AMLAW200_RANK'), '<=',100)
		,cts:element-value-query(xs:QName('firm-org:PUBLISHYEAR'),xs:string($year - 1))
		,cts:not-query(cts:element-value-query(xs:QName('firm-org:AMLAW200_RANK'),''))
		)))
		
	let $res2-LAG := sum(cts:search(/,
		cts:and-query((
		cts:directory-query('/LegalCompass/denormalized-data/law-firm/survey/','1')
		,cts:element-value-query(xs:QName('firm-org:OrganizationID'),($distinctid_lt_100 ! xs:string(.)))
		,cts:element-value-query(xs:QName('firm-org:PUBLISHYEAR'), xs:string($year - 1))
		,cts:not-query(cts:element-value-query(xs:QName('firm-org:AMLAW_200_RPL'),''))
		)))//firm-org:AMLAW_200_RPL/text())    
	
	let $CHANGE :=  fn:round-half-to-even((xs:double(($res2 - $res2-LAG) div $res2-LAG)) * 100 ,2)
	
	let $_ := (
			map:put($response-obj,'ORGANIZATION_ID', 0),
		map:put($response-obj,'ORGANIZATION_NAME', 'Am Law 100'),
		map:put($response-obj,'CHANGE', $CHANGE),
		map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
		)
	let $_ := json:array-push($response-arr, $response-obj)  
	
	(:----------------------------------------------------------------:)
	
	let $response-obj := json:object()
	
	let $distinctid_gt_100  := cts:element-values(xs:QName('firm-org:OrganizationID'),(),(),
		cts:and-query((
		cts:directory-query('/LegalCompass/denormalized-data/law-firm/survey/')
		,cts:element-range-query(xs:QName('firm-org:AMLAW200_RANK'), '>',100)
		,cts:element-value-query(xs:QName('firm-org:PUBLISHYEAR'),xs:string($year))
		,cts:not-query(cts:element-value-query(xs:QName('firm-org:AMLAW200_RANK'),''))
		)))
					
	let $res3 := sum(cts:search(/,
		cts:and-query((
		cts:directory-query('/LegalCompass/denormalized-data/law-firm/survey/','1')
		,cts:element-value-query(xs:QName('firm-org:OrganizationID'),($distinctid_gt_100 ! xs:string(.)))
		,cts:element-value-query(xs:QName('firm-org:PUBLISHYEAR'), xs:string($year))
		)))//firm-org:AMLAW_200_RPL/text())
		
		let $distinctid_gt_100  := cts:element-values(xs:QName('firm-org:OrganizationID'),(),(),
		cts:and-query((
		cts:directory-query('/LegalCompass/denormalized-data/law-firm/survey/')
		,cts:element-range-query(xs:QName('firm-org:AMLAW200_RANK'), '>',100)
		,cts:element-value-query(xs:QName('firm-org:PUBLISHYEAR'),xs:string($year - 1))
		,cts:not-query(cts:element-value-query(xs:QName('firm-org:AMLAW200_RANK'),''))
		)))
					
	let $res3-LAG := sum(cts:search(/,
		cts:and-query((
		cts:directory-query('/LegalCompass/denormalized-data/law-firm/survey/','1')
		,cts:element-value-query(xs:QName('firm-org:OrganizationID'),($distinctid_gt_100 ! xs:string(.)))
		,cts:element-value-query(xs:QName('firm-org:PUBLISHYEAR'), xs:string($year - 1))
		)))//firm-org:AMLAW_200_RPL/text())
		
		let $CHANGE :=  fn:round-half-to-even((xs:double(($res3 - $res3-LAG) div $res3-LAG)) * 100 ,2)
		
		let $_ := (
			map:put($response-obj,'ORGANIZATION_ID', 0),
		map:put($response-obj,'ORGANIZATION_NAME', '2nd Hundred'),
		map:put($response-obj,'CHANGE', $CHANGE),
		map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
		)
	let $_ := json:array-push($response-arr, $response-obj)  
	return () 
	return $response-arr
};

declare function firm:GetGrowthTotalHeadCount()
{
	let $request := xdmp:get-request-body()/request

	let $distinctYears := cts:element-attribute-values(xs:QName("survey:YEAR"),xs:QName("PublishYear"),(),("descending"),
  cts:and-query((
    cts:directory-query("/LegalCompass/denormalized-data/surveys/AMLAW_200/","1")
  ))
)
 
let $distinctid_lt_100  := cts:element-values(xs:QName("firm-org:OrganizationID"),(),(),
    cts:and-query((
      cts:directory-query("/LegalCompass/denormalized-data/law-firm/survey/")
      ,cts:element-range-query(xs:QName("firm-org:AMLAW200_RANK"), "<=",100)
      ,cts:element-value-query(xs:QName("firm-org:PUBLISHYEAR"),xs:string(max($distinctYears)))
      ,cts:not-query(cts:element-value-query(xs:QName("firm-org:AMLAW200_RANK"),""))
    )))
    
let $distinctid_gt_100  := cts:element-values(xs:QName("firm-org:OrganizationID"),(),(),
    cts:and-query((
      cts:directory-query("/LegalCompass/denormalized-data/law-firm/survey/")
      ,cts:element-range-query(xs:QName("firm-org:AMLAW200_RANK"), ">",100)
      ,cts:element-value-query(xs:QName("firm-org:PUBLISHYEAR"),xs:string(max($distinctYears)))
      ,cts:not-query(cts:element-value-query(xs:QName("firm-org:AMLAW200_RANK"),""))
    )))             

let $distinctYears := if($request/StartYear/text() ne "" and $request/EndYear/text() ne "") then
                      for $year in $distinctYears
                      where $year ge xs:integer($request/StartYear/text()) and $year le xs:integer($request/EndYear/text())
                      return $year
                      else $distinctYears[1 to 5]
                      
let $OrganizationID := $request//OrganisationID/text()
let $organizationName := if((/organization[organization:ORGANIZATION_ID = xs:string($OrganizationID)]/organization:ALM_NAME/text())[1] ne '')then 
  /organization[organization:ORGANIZATION_ID = xs:string($OrganizationID)]/organization:ALM_NAME/text()[1]
else 
  /organization[organization:ORGANIZATION_ID = xs:string($OrganizationID)]/organization:ORGANIZATION_NAME/text()[1]
let $response-arr := json:array()

let $data := for $year in (reverse($distinctYears))[1 to 5]
  let $response-obj := json:object()  

  let $res := cts:search(//survey:YEAR,
    cts:and-query((
      cts:directory-query("/LegalCompass/denormalized-data/surveys/NLJ_250/","1"),
      cts:element-attribute-value-query(xs:QName("survey:YEAR"),xs:QName("PublishYear"),xs:string($year)),
      cts:element-attribute-value-query(xs:QName("survey:YEAR"),xs:QName("OrganizationID"),$request//OrganisationID/text())
    )))
    
  let $lag-1  := cts:search(//survey:YEAR,
    cts:and-query((
      cts:directory-query("/LegalCompass/denormalized-data/surveys/NLJ_250/","1"),
      cts:element-attribute-value-query(xs:QName("survey:YEAR"),xs:QName("PublishYear"), xs:string( $year - 1)),
      cts:element-attribute-value-query(xs:QName("survey:YEAR"),xs:QName("OrganizationID"),$request//OrganisationID/text())
    )))
  
  let $num_attorneys := $res//survey:NUM_ATTORNEYS/text()
  let $lag_num_attorneys := $lag-1//survey:NUM_ATTORNEYS/text()
  let $change := fn:format-number((($num_attorneys - $lag_num_attorneys) div $lag_num_attorneys ) * 100, ".00")
  
  let $_ := (
	  map:put($response-obj,'ORGANIZATION_ID',xs:integer($OrganizationID)),
    map:put($response-obj,'ORGANIZATION_NAME',$organizationName),
    map:put($response-obj,'CHANGE', $change),
    map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
	)
  let $_ := json:array-push($response-arr, $response-obj)              
      
  (:=============================================================:)
   
  let $res2 := sum(cts:search(/,
    cts:and-query((
      cts:directory-query("/LegalCompass/relational-data/surveys/NLJ_250/")
      ,cts:element-value-query(xs:QName("nlj250:PUBLISHYEAR"),xs:string($year))
      ,cts:element-value-query(xs:QName("nlj250:ORGANIZATION_ID"),($distinctid_lt_100 ! xs:string(.)))
    )))//nlj250:NUM_ATTORNEYS/text())
    
   let $lag2 := sum(cts:search(/,
    cts:and-query((
      cts:directory-query("/LegalCompass/relational-data/surveys/NLJ_250/")
      ,cts:element-value-query(xs:QName("nlj250:PUBLISHYEAR"),xs:string($year - 1))
      ,cts:element-value-query(xs:QName("nlj250:ORGANIZATION_ID"),($distinctid_lt_100 ! xs:string(.)))
    )))//nlj250:NUM_ATTORNEYS/text())
     
  let $change := fn:format-number((($res2 - $lag2) div $lag2 ) * 100 , ".00")
  let $response-obj := json:object()
  
  let $_ := (
	  map:put($response-obj,'ORGANIZATION_ID',0),
    map:put($response-obj,'ORGANIZATION_NAME','Am Law 100'),
    map:put($response-obj,'CHANGE', $change),
    map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
	)
  
  let $_ := json:array-push($response-arr, $response-obj)     

  (:----------------:)
  
    
  let $res3 := sum(cts:search(/,
    cts:and-query((
      cts:directory-query("/LegalCompass/relational-data/surveys/NLJ_250/")
      ,cts:element-value-query(xs:QName("nlj250:PUBLISHYEAR"),xs:string($year))
      ,cts:element-value-query(xs:QName("nlj250:ORGANIZATION_ID"),($distinctid_gt_100 ! xs:string(.)))
    )))//nlj250:NUM_ATTORNEYS/text())
    
   let $lag3 := sum(cts:search(/,
    cts:and-query((
      cts:directory-query("/LegalCompass/relational-data/surveys/NLJ_250/")
      ,cts:element-value-query(xs:QName("nlj250:PUBLISHYEAR"),xs:string($year - 1))
      ,cts:element-value-query(xs:QName("nlj250:ORGANIZATION_ID"),($distinctid_gt_100 ! xs:string(.)))
    )))//nlj250:NUM_ATTORNEYS/text())
   
  let $change := fn:format-number((($res3 - $lag3) div $lag3) * 100 , ".00")
  let $response-obj := json:object()
  let $_ := (
	  map:put($response-obj,'ORGANIZATION_ID',0),
    map:put($response-obj,'ORGANIZATION_NAME','2nd Hundred'),
    map:put($response-obj,'CHANGE', $change),
    map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
	)
  let $_ := json:array-push($response-arr, $response-obj)
  
  return ($response-obj)
return ($response-arr)
};

declare function firm:GetGrowthinAssociateandPartners()
{
	let $request := xdmp:get-request-body()/request

	let $distinctYears := cts:element-attribute-values(xs:QName('survey:YEAR'),xs:QName('PublishYear'),(),('descending'),
	cts:and-query((
		cts:directory-query('/LegalCompass/denormalized-data/surveys/AMLAW_200/','1')
	))
	)
	
	let $distinctYears := if($request/StartYear/text() ne '' and $request/EndYear/text() ne '') then
						for $year in $distinctYears
						where $year ge xs:integer($request/StartYear/text()) and $year le xs:integer($request/EndYear/text())
						return $year
						else $distinctYears[1 to 5]

	let $organization := fn:doc(fn:concat('/LegalCompass/denormalized-data/organization/',$request//OrganisationID,'.xml'))
	let $organizationID := $organization//organization:ORGANIZATION_ID/text()
	let $organizationName := $organization//organization:ORGANIZATION_SHORT_NAME/text()
	let $response-arr := json:array()

	let $data := for $year in (reverse($distinctYears))
				let $response-obj := json:object()
				let $res := cts:search(/,
                                cts:and-query((
                                cts:directory-query("/LegalCompass/relational-data/surveys/NLJ_250/","1"),
                                cts:element-value-query(xs:QName("nlj250:PUBLISHYEAR"),xs:string($year)),
                                cts:element-value-query(xs:QName("nlj250:ORGANIZATION_ID"),$request//OrganisationID/text())
                                )))
                                
             let $lag  := cts:search(/,
                                cts:and-query((
                                cts:directory-query("/LegalCompass/relational-data/surveys/NLJ_250/","1"),
                                cts:element-value-query(xs:QName("nlj250:PUBLISHYEAR"),xs:string($year - 1)),
                                cts:element-value-query(xs:QName("nlj250:ORGANIZATION_ID"),$request//OrganisationID/text())
                                )))   
             let $num_associates := $res//nlj250:NUM_ASSOCIATES/text() 
             let $lag_num_associates := $lag//nlj250:NUM_ASSOCIATES/text() 
             let $AssociateChange := fn:format-number((($num_associates -  $lag_num_associates) div $lag_num_associates)*100, ".00")
             
             let $num_partners := $res//nlj250:NUM_PARTNERS/text()             
             let $lag_num_partners := $lag//nlj250:NUM_PARTNERS/text()
             let $PartnerChange := fn:format-number((($num_partners -  $lag_num_partners) div $lag_num_partners)*100, ".00")

				let $_ := (
								map:put($response-obj,'ORGANIZATION_ID',xs:integer($organizationID)),
							map:put($response-obj,'ORGANIZATION_NAME',$organizationName),
							map:put($response-obj,'AssociateChange', $AssociateChange),
							map:put($response-obj,'PartnerChange', $PartnerChange),
							map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
								)
				let $_ := json:array-push($response-arr, $response-obj)              

				return ($res)
	return ($response-arr)
};

declare function firm:GetGenderBreakdown()
{
	let $request := xdmp:get-request-body()/request

	let $distinctYears := (cts:element-attribute-values(xs:QName('survey:YEAR'),xs:QName('PublishYear'),(),('descending'),
	cts:and-query((
		cts:directory-query($config:DD-SURVEY-FEMALE_SCORECARD-PATH,'1')
	))))
	
	let $response-arr := json:array()
	let $data := for $year in fn:reverse($distinctYears[1 to 5])
				let $response-obj := json:object()
				let $res := cts:search(//survey:YEAR,
									cts:and-query((
									cts:directory-query($config:DD-SURVEY-FEMALE_SCORECARD-PATH,'1'),
									cts:element-attribute-value-query(xs:QName('survey:YEAR'),xs:QName('PublishYear'),xs:string($year)),
									cts:element-attribute-value-query(xs:QName('survey:YEAR'),xs:QName('OrganizationID'),$request//OrganisationID/text())
									)))
				let $FEMALEATTORNEYS := $res/survey:FEMALE_ATTORNEYS/text()
				let $MALEATTORNEYS := $res/survey:TOTAL_ATTORNEYS/text() - $FEMALEATTORNEYS
				let $_ := (
								map:put($response-obj,'ORGANIZATIONID', xs:integer($res/@OrganizationID/string())),
							map:put($response-obj,'ORGANIZATIONNAME', ($res/@OrganizationName/string())),
							map:put($response-obj,'PUBLISHYEAR', xs:integer($res/@PublishYear/string())),
							map:put($response-obj,'FEMALEATTORNEYS', xs:integer($FEMALEATTORNEYS)),
							map:put($response-obj,'MALEATTORNEYS', xs:integer($MALEATTORNEYS))
							)
				let $_ := if ($res) then json:array-push($response-arr, $response-obj) else ()
				return $res
				
	return ($response-arr)
};

declare function firm:GetGrowthInGenderDiversity()
{
	(:
	let $request := xdmp:get-request-body()/request
	
	let $distinctYears := (cts:element-attribute-values(xs:QName('survey:YEAR'),xs:QName('PublishYear'),(),('descending'),
	cts:and-query((
		cts:directory-query($config:DD-SURVEY-FEMALE_SCORECARD-PATH,'1')
	))))
	
	let $response-arr := json:array()
	let $data := for $year in fn:reverse($distinctYears[1 to 5])
				let $response-obj := json:object()
				let $res := cts:search(//survey:YEAR,
									cts:and-query((
									cts:directory-query($config:DD-SURVEY-FEMALE_SCORECARD-PATH,'1'),
									cts:element-attribute-value-query(xs:QName('survey:YEAR'),xs:QName('PublishYear'),xs:string($year)),
									cts:element-attribute-value-query(xs:QName('survey:YEAR'),xs:QName('OrganizationID'),$request//OrganisationID/text())
									)))
				let $FEMALEATTORNEYS := $res/survey:FEMALE_ATTORNEYS/text()
				let $FEMALEPARTNERS := fn:format-number($res/survey:FEMALE_PARTNERS/text() , '00')
				let $FEMALEEQUITYPARTNERS := if( $res/survey:FEMALE_EQUITY_PARTNERS/text() ne '')
												then xs:decimal(fn:format-number($res/survey:FEMALE_EQUITY_PARTNERS/text() , '00'))
												else ''
				let $FEMALENONEQUITYPARTNERS := if( $res/survey:FEMALE_NONEQUITY_PARTNERS/text() ne '')
												then xs:decimal(fn:format-number($res/survey:FEMALE_NONEQUITY_PARTNERS/text() , '00'))
												else '' 
				let $FEMALEASSOCIATES := xs:decimal(fn:format-number($res/survey:FEMALE_ASSOCIATES/text() , '00'))
				let $FEMALEOTHERATTORNEYS := xs:decimal(fn:format-number($res/survey:FEMALE_OTHER_ATTORNEYS/text() , '00'))
				
				let $_ := (
								map:put($response-obj,'ORGANIZATIONID', xs:integer($res/@OrganizationID/string())),
							map:put($response-obj,'ORGANIZATIONNAME', ($res/@OrganizationName/string())),
							map:put($response-obj,'PUBLISHYEAR', xs:integer($res/@PublishYear/string())),
							map:put($response-obj,'FEMALEATTORNEYS', xs:integer($FEMALEATTORNEYS)),
							map:put($response-obj,'FEMALEEQUITYPARTNERS', ($FEMALEEQUITYPARTNERS)),
							map:put($response-obj,'FEMALENONEQUITYPARTNERS', ($FEMALENONEQUITYPARTNERS)),
							map:put($response-obj,'FEMALEASSOCIATES', ($FEMALEASSOCIATES)),
							map:put($response-obj,'FEMALEOTHERATTORNEYS', ($FEMALEOTHERATTORNEYS))
							)
				let $_ := json:array-push($response-arr, $response-obj)              
				return $res
				
	return ($response-arr) 
	:)
	let $request := xdmp:get-request-body()/request
	
	let $distinctYears := (cts:element-values(xs:QName('FEMALE_SCORECARD:PUBLISHYEAR'),(),('descending'),
		cts:and-query((
			cts:directory-query('/LegalCompass/relational-data/surveys/FEMALE_SCORECARD/','1')
		))))
		
	let $response-arr := json:array()
	
	let $data := for $year in fn:reverse($distinctYears[1 to 5])
		
		let $response-obj := json:object()
		let $res := cts:search(/,
			cts:and-query((
				cts:directory-query('/LegalCompass/relational-data/surveys/FEMALE_SCORECARD/','1')
				,cts:element-value-query(xs:QName('FEMALE_SCORECARD:PUBLISHYEAR'),xs:string($year))
				,cts:element-value-query(xs:QName('FEMALE_SCORECARD:ORGANIZATION_ID'),$request//OrganisationID/text())
			)))
		
		let $FEMALEATTORNEYS := $res//FEMALE_SCORECARD:FEMALE_ATTORNEYS/text()
		
		let $FEMALEPARTNERS := fn:format-number($res//FEMALE_SCORECARD:FEMALE_PARTNERS/text() , '00')
		
		let $FEMALEEQUITYPARTNERS := if( $res//FEMALE_SCORECARD:FEMALE_EQUITY_PARTNERS/text() ne '')
				then xs:decimal(fn:format-number($res//FEMALE_SCORECARD:FEMALE_EQUITY_PARTNERS/text() , '00'))
			else 0
		
		let $FEMALENONEQUITYPARTNERS := if( $res//FEMALE_SCORECARD:FEMALE_NONEQUITY_PARTNERS/text() ne '')
				then xs:decimal(fn:format-number($res//FEMALE_SCORECARD:FEMALE_NONEQUITY_PARTNERS/text() , '00'))
			else 0

		let $FEMALEASSOCIATES := try { 
				xs:decimal(fn:format-number($res//FEMALE_SCORECARD:FEMALE_ASSOCIATES/text() , '00'))
			}
			catch($x) { 0 }
				
		let $FEMALEOTHERATTORNEYS := if($res//FEMALE_SCORECARD:FEMALE_OTHER_ATTORNEYS/text() ne '')
				then (fn:format-number($res//FEMALE_SCORECARD:FEMALE_OTHER_ATTORNEYS/text() , '00'))
			else 0
				
		let $_ := (
			map:put($response-obj,'ORGANIZATIONID', xs:integer($res//FEMALE_SCORECARD:ORGANIZATION_ID/text())),
			map:put($response-obj,'ORGANIZATIONNAME', $res//FEMALE_SCORECARD:ORGANIZATION_NAME/text()),
			map:put($response-obj,'PUBLISHYEAR', xs:integer($year)),
			map:put($response-obj,'FEMALEATTORNEYS', xs:integer($FEMALEATTORNEYS)),
			map:put($response-obj,'FEMALEEQUITYPARTNERS', ($FEMALEEQUITYPARTNERS)),
			map:put($response-obj,'FEMALENONEQUITYPARTNERS', ($FEMALENONEQUITYPARTNERS)),
			map:put($response-obj,'FEMALEASSOCIATES', ($FEMALEASSOCIATES)),
			map:put($response-obj,'FEMALEOTHERATTORNEYS', ($FEMALEOTHERATTORNEYS))
		)
		
		let $_ := if ($res) then json:array-push($response-arr, $response-obj) else ()
		
		return $res
				
	return ($response-arr) 
};

declare function firm:GetLeverage()
{
let $request := xdmp:get-request-body()/request
	
let $distinctYears := cts:element-attribute-values(xs:QName('survey:YEAR'),xs:QName('PublishYear'),(),('descending'),
	cts:and-query((
	cts:directory-query('/LegalCompass/denormalized-data/surveys/AMLAW_200/','1')
	)))

let $distinctYears := if($request/StartYear/text() ne '' and $request/EndYear/text() ne '') then
  for $year in $distinctYears
  where $year ge xs:integer($request/StartYear/text()) and $year le xs:integer($request/EndYear/text())
  return $year
  else $distinctYears[1 to 5]
	
let $OrganizationID := $request//OrganisationID/text()
let $OrganizationName := if((/organization[organizations:ORGANIZATION_ID = xs:string($OrganizationID)]/organizations:ALM_NAME/text())[1] ne '')then 
    /organization[organizations:ORGANIZATION_ID = xs:string($OrganizationID)]/organizations:ALM_NAME/text()[1]
  else 
    /organization[organizations:ORGANIZATION_ID = xs:string($OrganizationID)]/organizations:ORGANIZATION_NAME/text()[1]
let $response-arr := json:array()	
	
let $data := for $year in reverse($distinctYears)
(:--------------1st Part-------------:)
  let $response-obj := json:object()
	let $a := cts:search(/,
	  cts:and-query((
		cts:directory-query('/LegalCompass/relational-data/surveys/NLJ_250/','1')
		,cts:element-value-query(xs:QName('nlj250:PUBLISHYEAR'),xs:string($year))
    ,cts:element-value-query(xs:QName('nlj250:ORGANIZATION_ID'),$request//OrganisationID/text())
		)))
    
  let $d := cts:search(/,
	  cts:and-query((
		cts:directory-query('/LegalCompass/relational-data/surveys/Global_100/','1')
		,cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($year))
    ,cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$request//OrganisationID/text())
		)))  
  let $e := cts:search(/,
	  cts:and-query((
		cts:directory-query('/LegalCompass/relational-data/surveys/UK_50/','1')
		,cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string($year))
    ,cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),$request//OrganisationID/text())
		)))
  let $g := cts:search(/,
	  cts:and-query((
		cts:directory-query('/LegalCompass/relational-data/surveys/CHINA_40/','1')
		,cts:element-value-query(xs:QName('CHINA_40:PUBLISHYEAR'),xs:string($year))
    ,cts:element-value-query(xs:QName('CHINA_40:ORGANIZATION_ID'),$request//OrganisationID/text())
		)))  
let $NUM_ATTORNEYS := if(($a//nlj250:NUM_NE_PARTNERS/text() eq "") and ($d//Global_100:NUM_LAWYERS/text() eq ""))
  then 
    if($e//UK_50:NUMBER_OF_LAWYERS/text() eq "")
    then ($g//CHINA_40:FIRMWIDE_LAWYERS/text() - $g//CHINA_40:EQUITY_PARTNERS/text()) div $g//CHINA_40:EQUITY_PARTNERS/text()
    else $e//UK_50:LEVERAGE/text()
  else 
    if($a//nlj250:NUM_NE_PARTNERS/text() eq '')
    then ($d//Global_100:NUM_LAWYERS/text() -  $d//Global_100:NUM_EQUITY_PARTNERS/text())  div $d//Global_100:NUM_EQUITY_PARTNERS/text() 
    else ($a//nlj250:NUM_ASSOCIATES/text()) div ($a//nlj250:NUM_PARTNERS/text() - ($a//nlj250:NUM_NE_PARTNERS/text()))
  
  let $_ := (
		map:put($response-obj,'ORGANIZATION_ID',xs:integer($OrganizationID)),
		map:put($response-obj,'ORGANIZATION_NAME', $OrganizationName),
		map:put($response-obj,'CHANGE', fn:format-number($NUM_ATTORNEYS,".00")),
		map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
		)
  let $_ := json:array-push($response-arr, $response-obj)      
(:--------------2nd Part-------------:)
  let $response-obj := json:object()        
  let $distinctid_lt_100  :=cts:element-values(xs:QName('AMLAW_200:ORGANIZATION_ID'),(),(),
    cts:and-query((
      cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/')
      ,cts:element-range-query(xs:QName('AMLAW_200:AMLAW200_RANK'), '<=',100)
      ,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string(max($distinctYears)))
      ,cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
      )))
           
  let $res := cts:search(/,
		cts:and-query((
		cts:directory-query('/LegalCompass/relational-data/surveys/NLJ_250/','1'),
		cts:element-value-query(xs:QName('nlj250:PUBLISHYEAR'),xs:string($year)),
		cts:element-value-query(xs:QName('nlj250:ORGANIZATION_ID'), ($distinctid_lt_100 ! xs:string(.)))
		)))
  let $aa := ""                
  let $res := for $r in $res
    let $partners := $r//nlj250:NUM_PARTNERS/text()
    let $ne_partners := $r//nlj250:NUM_NE_PARTNERS/text()
    return if($partners ne $ne_partners)
      then $r
      else ()
           
            
  let $num_associates := sum($res//nlj250:NUM_ASSOCIATES/text())
  let $num_partners := sum($res//nlj250:NUM_PARTNERS/text())
  let $num_ne_partners := sum($res//nlj250:NUM_NE_PARTNERS/text())        
  let $NUM_ATTORNEYS := ($num_associates) div ($num_partners - $num_ne_partners)        
  (:      
  let $Lag := cts:search(/,
	  cts:and-query((
		cts:directory-query('/LegalCompass/relational-data/surveys/NLJ_250/','1'),
		cts:element-value-query(xs:QName('nlj250:PUBLISHYEAR'),xs:string($year - 1)),
		cts:element-value-query(xs:QName('nlj250:ORGANIZATION_ID'), ($distinctid_lt_100 ! xs:string(.)))
		)))
    
  let $res := for $l in $Lag
    let $partners := $l//nlj250:NUM_PARTNERS/text()
    let $ne_partners := $l//nlj250:NUM_NE_PARTNERS/text()
      return if($partners ne $ne_partners)
      then 
      ($l//nlj250:NUM_ASSOCIATES/text()) div ($l//nlj250:NUM_PARTNERS/text() - $l//nlj250:NUM_NE_PARTNERS/text())
      else ()            
        
  let $LAG_NUM_ATTORNEYS := sum($res)
  :)
  let $_ := (
		map:put($response-obj,'ORGANIZATION_ID',xs:integer(0)),
		map:put($response-obj,'ORGANIZATION_NAME','Am Law 100'),
		map:put($response-obj,'CHANGE', fn:format-number($NUM_ATTORNEYS,".00")),
		map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
		)
  let $_ := json:array-push($response-arr, $response-obj)  
 
(:--------------3rd Part-------------:)
  let $response-obj := json:object()        
  let $distinctid_gt_100  :=cts:element-values(xs:QName('AMLAW_200:ORGANIZATION_ID'),(),(),
    cts:and-query((
      cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/')
      ,cts:element-range-query(xs:QName('AMLAW_200:AMLAW200_RANK'), '>',100)
      ,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string(max($distinctYears)))
      ,cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
      )))
           
  let $res := cts:search(/,
		cts:and-query((
		cts:directory-query('/LegalCompass/relational-data/surveys/NLJ_250/','1'),
		cts:element-value-query(xs:QName('nlj250:PUBLISHYEAR'),xs:string($year)),
		cts:element-value-query(xs:QName('nlj250:ORGANIZATION_ID'), ($distinctid_gt_100 ! xs:string(.)))
		)))
                  
  let $res := for $r in $res
    let $partners := $r//nlj250:NUM_PARTNERS/text()
    let $ne_partners := $r//nlj250:NUM_NE_PARTNERS/text()
    return if($partners ne $ne_partners)
      then $r
      else ()
           
            
  let $num_associates := sum($res//nlj250:NUM_ASSOCIATES/text())
  let $num_partners := sum($res//nlj250:NUM_PARTNERS/text())
  let $num_ne_partners := sum($res//nlj250:NUM_NE_PARTNERS/text())        
  let $NUM_ATTORNEYS := ($num_associates) div ($num_partners - $num_ne_partners)        
  (:      
  let $Lag := cts:search(/,
	  cts:and-query((
		cts:directory-query('/LegalCompass/relational-data/surveys/NLJ_250/','1'),
		cts:element-value-query(xs:QName('nlj250:PUBLISHYEAR'),xs:string($year - 1)),
		cts:element-value-query(xs:QName('nlj250:ORGANIZATION_ID'), ($distinctid_gt_100 ! xs:string(.)))
		)))
    
  let $res := for $l in $Lag
    let $partners := $l//nlj250:NUM_PARTNERS/text()
    let $ne_partners := $l//nlj250:NUM_NE_PARTNERS/text()
      return if($partners ne $ne_partners)
      then 
      ($l//nlj250:NUM_ASSOCIATES/text()) div ($l//nlj250:NUM_PARTNERS/text() - $l//nlj250:NUM_NE_PARTNERS/text())
      else ()            
        
  let $LAG_NUM_ATTORNEYS := sum($res)
  :)
  let $_ := (
		map:put($response-obj,'ORGANIZATION_ID',xs:integer(0)),
		map:put($response-obj,'ORGANIZATION_NAME','2nd Hundred'),
		map:put($response-obj,'CHANGE', fn:format-number($NUM_ATTORNEYS,".00")),
		map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
		)
  let $_ := json:array-push($response-arr, $response-obj)  
  return ()  
return $response-arr

};

declare function firm:GetChangesinHeadcountByYear()
{
	let $request := xdmp:get-request-body()/request

	let $distinctYears := cts:element-attribute-values(xs:QName('survey:YEAR'),xs:QName('PublishYear'),(),('descending'),
	cts:and-query((
		cts:directory-query('/LegalCompass/denormalized-data/surveys/AMLAW_200/','1')
	))
	)
	let $res := cts:search(//survey:YEAR,
									cts:and-query((
									cts:directory-query('/LegalCompass/denormalized-data/surveys/NLJ_250/','1'),
									cts:element-attribute-value-query(xs:QName('survey:YEAR'),xs:QName('PublishYear'),xs:string(max($distinctYears))),
									cts:element-attribute-value-query(xs:QName('survey:YEAR'),xs:QName('OrganizationID'),$request//OrganisationID/text())
									)))
	
	let $res1 := cts:search(//survey:YEAR,
									cts:and-query((
									cts:directory-query('/LegalCompass/denormalized-data/surveys/NLJ_250/','1'),
									cts:element-attribute-value-query(xs:QName('survey:YEAR'),xs:QName('PublishYear'),xs:string(max($distinctYears) - 4)),
									cts:element-attribute-value-query(xs:QName('survey:YEAR'),xs:QName('OrganizationID'),$request//OrganisationID/text())
									)))
										
	let $organization := fn:doc(fn:concat('/LegalCompass/denormalized-data/organization/',$request//OrganisationID,'.xml'))
	let $organizationID := $organization//organization:ORGANIZATION_ID/text()
	let $organizationName := $organization//organization:ORGANIZATION_SHORT_NAME/text()
	
	let $NUM_ASSOCIATES := $res//survey:NUM_ASSOCIATES/text()
	let $LAG_NUM_ASSOCIATES := $res1//survey:NUM_ASSOCIATES/text()
	let $NUM_NE_PARTNERS := $res//survey:NUM_NE_PARTNERS/text()
	let $LAG_NUM_NE_PARTNERS := $res1//survey:NUM_NE_PARTNERS/text()
	let $EQUITY_PARTNERS := $res//survey:EQUITY_PARTNERS/text()
	let $LAG_EQUITY_PARTNERS := $res1//survey:EQUITY_PARTNERS/text()
	
	let $AssociateChange := fn:format-number(((( $NUM_ASSOCIATES - $LAG_NUM_ASSOCIATES ) div $LAG_NUM_ASSOCIATES ) * 100), '.00')
	let $NonEQPartnerChange := if(($LAG_NUM_NE_PARTNERS > 0) and (($NUM_NE_PARTNERS - $LAG_NUM_NE_PARTNERS lt 0) or ($NUM_NE_PARTNERS - $LAG_NUM_NE_PARTNERS gt 0)))
							then fn:format-number(((( $NUM_NE_PARTNERS - $LAG_NUM_NE_PARTNERS ) div $LAG_NUM_NE_PARTNERS ) * 100), '.00')
							else 100
							
	let $EQPartnerChange := if(($EQUITY_PARTNERS - $LAG_EQUITY_PARTNERS  lt 0) or ($EQUITY_PARTNERS - $LAG_EQUITY_PARTNERS  gt 0))
							then fn:format-number(((( $EQUITY_PARTNERS - $LAG_EQUITY_PARTNERS  ) div $LAG_EQUITY_PARTNERS ) * 100), '.00')
							else 100
													
	let $response-arr := json:array()
	let $response-obj := json:object()
	
	let $_ := (
					map:put($response-obj,'ORGANIZATION_ID',xs:integer($organizationID)),
			map:put($response-obj,'ORGANIZATION_NAME',$organizationName),
			map:put($response-obj,'AssociateChange',xs:decimal($AssociateChange)),
			map:put($response-obj,'NonEQPartnerChange',xs:decimal($NonEQPartnerChange)),
			map:put($response-obj,'EQPartnerChange',xs:decimal($EQPartnerChange)),
			map:put($response-obj,'PUBLISHYEAR',max($distinctYears))           
			)
	let $_ := json:array-push($response-arr, $response-obj)   
	
	return $response-arr
};

declare function firm:GetLawFirmGlobalMapALI()
{
	let $request := xdmp:get-request-body()/request
	
	let $response-obj := json:object()
	let $response-arr := json:array()
	
	let $organization := fn:doc(fn:concat($config:DD-ORGANIZATION-PATH, $request/FirmID/text(),'.xml'))
	let $organizationID := $organization//organization:ORGANIZATION_ID/text()
	let $organizationName := $organization//organization:ORGANIZATION_SHORT_NAME/text()
	
	let $result-data := cts:search(/,
			cts:and-query((
			cts:directory-query($config:RD-ORGANIZATION_BRANCH-PATH,'1'),
		cts:element-range-query(xs:QName('organization-branch:FISCAL_YEAR'), '>=', fn:year-from-dateTime(fn:current-dateTime()) - 10),
		cts:element-value-query(xs:QName('organization-branch:ORGANIZATION_ID'), $request/FirmID/text()),
		cts:element-range-query(xs:QName('organization-branch:FISCAL_YEAR'), '>=', xs:integer($request/FromYear/text() -1 )),
		cts:element-range-query(xs:QName('organization-branch:FISCAL_YEAR'), '<=', xs:integer($request/ToYear/text()))		
		)))
	
	let $data := for $data in $result-data
	let $location := if($data//organization-branch:COUNTRY) then
						fn:concat($data//organization-branch:CITY/text(),', ',$data//organization-branch:STATE/text())
						else
						fn:concat($data//organization-branch:CITY/text(),', ',$data//organization-branch:COUNTRY/text())
	let $FISCAL_YEAR := $data//organization-branch:FISCAL_YEAR/text()                    
	let $levrage := cts:search(//survey:YEAR,
		cts:and-query((
		cts:directory-query('/LegalCompass/denormalized-data/surveys/AMLAW_200/','1'),
		cts:element-attribute-value-query(xs:QName('survey:YEAR'),xs:QName('PublishYear'),$FISCAL_YEAR),
		cts:element-attribute-value-query(xs:QName('survey:YEAR'),xs:QName('OrganizationID'),$request/FirmID/text())
	)))//survey:LEVERAGE/text()
	
	let $city-data := cts:search(/,
		cts:and-query((
		cts:directory-query('/LegalCompass/relational-data/city_detail/'),
		cts:element-value-query(xs:QName('city_detail:STD_LOC'),$location,'exact')
		)))
	
	let $response-obj := json:object()
	let $_ := (
		map:put($response-obj,'FirmId', $organizationID),
		map:put($response-obj,'FirmName', $data//organization-branch:ORGANIZATION_NAME/text()),
		map:put($response-obj,'TotalAttorneys', $data//organization-branch:NUM_ATTORNEYS/text()),
		map:put($response-obj,'Partners', $data//organization-branch:TOTAL_PARTNERS/text()),
		map:put($response-obj,'EquityPartners', $data//organization-branch:EQUITY_PARTNERS/text()),
		map:put($response-obj,'NonEquityPartners', $data//organization-branch:NON_EQUITY_PARTNERS/text()),
		map:put($response-obj,'OtherAttorneys', $data//organization-branch:OTHER_ATTORNEYS/text()),
		map:put($response-obj,'Associates', $data//organization-branch:ASSOCIATES/text()),
		map:put($response-obj,'Location', $location),
		map:put($response-obj,'YEAR', $FISCAL_YEAR),
		map:put($response-obj,'CITY', $data//organization-branch:CITY/text()),
		map:put($response-obj,'STATE', $data//organization-branch:STATE/text()),
		map:put($response-obj,'COUNTRY', $data//organization-branch:COUNTRY/text()),
		map:put($response-obj,'LEVRAGE', $levrage),
		map:put($response-obj,'LATITUDE', $city-data//city_detail:LATITUDE/text()),
		map:put($response-obj,'LONGITUDE', $city-data//city_detail:LONGITUDE/text())
		)
	let $_ := json:array-push($response-arr,$response-obj) 
	return ($data)
	return ($response-arr)
};

declare function firm:GetClients()
{
	
	(:let $firmID := $firmID/text()	
	let $fromYear := xs:integer($fromYear/text())
	let $toYear := xs:integer($toYear/text()) :)
	
	let $request := xdmp:get-request-body()/request
	let $firmID := $request/FirmID/text()
	let $fromYear := xs:integer($request/FromYear/text())
	let $toYear := xs:integer($request/ToYear/text()) 
	let $representationIDs := $request/RepresentationID/text()
	
	let $response-arr := json:array()
	let $response-obj := json:object()

	let $WCW_REPRESENTATION_TYPE_ID-Query := if($representationIDs ne '')then
	cts:element-value-query(xs:QName('Who_Counsels_who:REPRESENTATION_TYPE_ID'),($representationIDs ! xs:string(.)),'exact')
	else ()
	
	let $BDBS_TRANSACTION_TYPE_ID_Query :=  if($representationIDs ne '')then
	cts:element-value-query(xs:QName('bdbs-transaction:TRANSACTION_TYPE_ID'),$representationIDs,'exact')
	else ()
	
	let $LFR_NEW_REPRESENTATION_TYPE_ID_Query := if($representationIDs ne '')then
	cts:element-value-query(xs:QName('COMPANYPROFILE_LFR_NEW:REPRESENTATION_TYPE_ID'),$representationIDs,'exact')
	else ()
	
	let $LFR_REPRESENTATION_TYPE_ID_Query := if($representationIDs ne '')then
	cts:element-value-query(xs:QName('COMPANYPROFILE_LFR:REPRESENTATION_TYPE_ID'),$representationIDs,'exact')
	else ()
	
	let $organization := fn:doc(fn:concat('/LegalCompass/denormalized-data/organization/',$firmID,'.xml'))
	let $organizationID := $organization//organization:ORGANIZATION_ID/text()
	let $organizationName := if ($organization//organization:ALM_NAME/text() != '') then ($organization//organization:ALM_NAME/text()) else fn:normalize-space($organization//organization:ORGANIZATION_NAME/text())
	(:let $organizationName := $organization//organization:ORGANIZATION_SHORT_NAME/text() :)
	
	let $search-result1:= cts:search(/,
	cts:and-query((
	cts:directory-query($config:RD-SURVEY-WHO_COUNSELS_WHO-PATH),
	cts:element-value-query(xs:QName('Who_Counsels_who:OUTSIDE_COUNSEL_ID'),$firmID),
	$WCW_REPRESENTATION_TYPE_ID-Query,
	cts:element-range-query(xs:QName('Who_Counsels_who:FISCAL_YEAR'), '>=', $fromYear),
	cts:element-range-query(xs:QName('Who_Counsels_who:FISCAL_YEAR'), '<=', $toYear)
	)))
	let $data := for $entry in $search-result1
	let $response-obj := json:object()           
	let $_ := (
		map:put($response-obj,'Source',$entry//Who_Counsels_who:WHOCOUNSELSWHO_SOURCE/text()),
		map:put($response-obj,'TypeOfTransaction',$entry//Who_Counsels_who:STD_REPRESENTATION_TYPE/text()),
		map:put($response-obj,'SearchID', 0),
		map:put($response-obj,'Role', ()),
		map:put($response-obj,'Firm', $entry//Who_Counsels_who:ORGANIZATION_NAME/string()),
		map:put($response-obj,'client',$entry//Who_Counsels_who:ORGANIZATION_NAME/string()),
		map:put($response-obj,'Date', xs:integer($entry//Who_Counsels_who:FISCAL_YEAR/text())),
		map:put($response-obj,'Month', ()),
		map:put($response-obj,'Jurisdiction', ()),
		map:put($response-obj,'CaseName', ()),
		map:put($response-obj,'CaseId', ()),
		map:put($response-obj,'PatentNumber', ()),
		map:put($response-obj,'DocketNumber', ()),
		map:put($response-obj,'FirmId', $entry//Who_Counsels_who:OUTSIDE_COUNSEL_ID/string()),
		map:put($response-obj,'Details', if ($entry//Who_Counsels_who:TRANSACTION_NAME/text() != '') then fn:concat('CaseName: ',$entry//Who_Counsels_who:TRANSACTION_NAME/text()) else ()),
		map:put($response-obj,'TypeofCase', ())
		)
	let $_ := json:array-push($response-arr,$response-obj)  
	return ()
	
	(:2nd Part of SP:)
		let $representer-result := cts:search(/,
		cts:and-query((
			cts:directory-query($config:RD-BDBS_REPRESENTER-PATH)
			,cts:element-value-query(xs:QName('bdbs-representer:ORGANIZATION_ID'),($firmID))
		)))
	
	let $party-ids := fn:distinct-values($representer-result//bdbs-representer:PARTY_ID/text())
	
	let $transaction-result := cts:search(/,
		cts:and-query((
		cts:directory-query($config:RD-BDBS_PARTY-PATH)
		,cts:element-value-query(xs:QName('bdbs-party:PARTY_ID'),$party-ids)
		)))
	
	let $transaction-ids := fn:distinct-values($transaction-result//bdbs-party:TRANSACTION_ID/text())
	
	let $search-result := cts:search(/,
	cts:and-query((
	cts:directory-query($config:RD-BDBS_TRANSACTION-PATH)
	,cts:element-value-query(xs:QName('bdbs-transaction:TRANSACTION_ID'),$transaction-ids)
	,$BDBS_TRANSACTION_TYPE_ID_Query
	,cts:element-range-query(xs:QName('bdbs-transaction:YEAR'), '>=', $fromYear)
	,cts:element-range-query(xs:QName('bdbs-transaction:YEAR'), '<=', $toYear)
	)))
	
	let $data := for $entry in $search-result
	let $transaction := for $trn in $transaction-result/bdbs-party[bdbs-party:TRANSACTION_ID eq $entry//bdbs-transaction:TRANSACTION_ID/text()]
		let $role := $representer-result/bdbs-representer[bdbs-representer:PARTY_ID eq $trn//bdbs-party:PARTY_ID]/bdbs-representer:REPRESENTER_ROLE/text()
		let $response-obj := json:object()
		let $NAME := $entry//bdbs-transaction:NAME/text()
		let $_ := (
		map:put($response-obj,'SOURCE','ALM Legal Intelligence - Big Deals/Big Suits'),
		map:put($response-obj,'TypeOfTransaction',$entry//bdbs-transaction:STD_TRANSACTION_TYPE/text()),
		map:put($response-obj,'SearchID', 0),
		map:put($response-obj,'Role', $role),
		map:put($response-obj,'Firm', $organizationName),
		map:put($response-obj,'client', $trn//bdbs-party:ORGANIZATION_NAME/text()),
		map:put($response-obj,'Date',$entry//bdbs-transaction:YEAR/text()),
		map:put($response-obj,'Month',$entry//bdbs-transaction:MONTH/text()),
		map:put($response-obj,'CaseName', $NAME),
		map:put($response-obj,'CaseId', ()),
		map:put($response-obj,'PatentNumber', ()),
		map:put($response-obj,'TypeofCase', ()),
		map:put($response-obj,'DocketNumber', ()),
		map:put($response-obj,'FirmId', ()),
		map:put($response-obj,'Details', fn:concat('CaseName: ',$NAME))
		
		)
		let $_ := json:array-push($response-arr,$response-obj)
		return ()
	return ()
	(:3rd part of SP:)
	
	let $search-result2:= cts:search(/,
		cts:and-query((
		cts:directory-query($config:RD-SURVEY-COMPANYPROFILE_LFR_NEW-PATH),
		cts:element-value-query(xs:QName('COMPANYPROFILE_LFR_NEW:FIRM_ID'),$firmID),
		cts:not-query(cts:element-value-query(xs:QName('COMPANYPROFILE_LFR_NEW:FIRM'),'')),
		$LFR_NEW_REPRESENTATION_TYPE_ID_Query,
		cts:element-range-query(xs:QName('COMPANYPROFILE_LFR_NEW:YEAR'), '>=', $fromYear),
		cts:element-range-query(xs:QName('COMPANYPROFILE_LFR_NEW:YEAR'), '<=', $toYear)
		)))
	let $data := for $entry in $search-result2
	let $response-obj := json:object()           
	let $_ := (
		map:put($response-obj,'Source',$entry//COMPANYPROFILE_LFR_NEW:SOURCE/text()),
		map:put($response-obj,'TypeOfTransaction',$entry//COMPANYPROFILE_LFR_NEW:TYPEOFREPRESENTATION/text()),
		map:put($response-obj,'SearchID', 0),
		map:put($response-obj,'Role', $entry//COMPANYPROFILE_LFR_NEW:ROLE/text()),
		map:put($response-obj,'Firm', $organizationName),
		map:put($response-obj,'client',$entry//COMPANYPROFILE_LFR_NEW:COMPANY_NAME/string()),
		map:put($response-obj,'Date', xs:integer($entry//COMPANYPROFILE_LFR_NEW:YEAR/text())),
		map:put($response-obj,'Month', ()),
		map:put($response-obj,'Jurisdiction', $entry//COMPANYPROFILE_LFR_NEW:JURISDICTION/text()),
		map:put($response-obj,'CaseName', $entry//COMPANYPROFILE_LFR_NEW:CASENAME/text()),
		map:put($response-obj,'CaseId', $entry//COMPANYPROFILE_LFR_NEW:CASEID/text()),
		map:put($response-obj,'PatentNumber', $entry//COMPANYPROFILE_LFR_NEW:PATENTNUMBER/text()),
		map:put($response-obj,'TypeofCase', $entry//COMPANYPROFILE_LFR_NEW:TYPEOFCASE/text()),
		map:put($response-obj,'DocketNumber', $entry//COMPANYPROFILE_LFR_NEW:DOCKETNUMBER/text()),
		map:put($response-obj,'FirmId', $entry//COMPANYPROFILE_LFR_NEW:FIRM_ID/text()),
		map:put($response-obj,'Details', $entry//COMPANYPROFILE_LFR_NEW:DETAILS/text())    
		)
	let $_ := json:array-push($response-arr,$response-obj)  
	return ()
	
	(:4th Part of SP :)
	
	let $search-result3:= cts:search(/,
		cts:and-query((
		cts:directory-query($config:RD-SURVEY-COMPANYPROFILE_LFR-PATH),
		$LFR_REPRESENTATION_TYPE_ID_Query,
		cts:element-value-query(xs:QName('COMPANYPROFILE_LFR:FIRM_ID'),$firmID),
		cts:not-query(cts:element-value-query(xs:QName('COMPANYPROFILE_LFR:FIRM'),'')),
		cts:element-range-query(xs:QName('COMPANYPROFILE_LFR:YEAR'), '>=', $fromYear),
		cts:element-range-query(xs:QName('COMPANYPROFILE_LFR:YEAR'), '<=', $toYear),
		cts:or-query((
			cts:element-value-query(xs:QName('COMPANYPROFILE_LFR:SOURCE'),'ALM Legal Intelligence','exact'),
			cts:element-value-query(xs:QName('COMPANYPROFILE_LFR:SOURCE'),'USPTO','exact')
			))
		)))
	let $data := for $entry in $search-result3
	let $response-obj := json:object()           
	let $_ := (
		map:put($response-obj,'Source',$entry//COMPANYPROFILE_LFR:SOURCE/text()),
		map:put($response-obj,'TypeOfTransaction',$entry//COMPANYPROFILE_LFR:TYPEOFREPRESENTATION/text()),
		map:put($response-obj,'SearchID', 0),
		map:put($response-obj,'Firm', $organizationName),
		map:put($response-obj,'client',$entry//COMPANYPROFILE_LFR:COMPANY_NAME/string()),
		map:put($response-obj,'Date', xs:integer($entry//COMPANYPROFILE_LFR:YEAR/text())),
		map:put($response-obj,'Month', ()),
		map:put($response-obj,'Jurisdiction', $entry//COMPANYPROFILE_LFR:JURISDICTION/text()),
		map:put($response-obj,'CaseName', $entry//COMPANYPROFILE_LFR:CASENAME/text()),
		map:put($response-obj,'CaseId', $entry//COMPANYPROFILE_LFR:CASEID/text()),
		map:put($response-obj,'PatentNumber', $entry//COMPANYPROFILE_LFR:PATENTNUMBER/text()),
		map:put($response-obj,'TypeofCase', $entry//COMPANYPROFILE_LFR:TYPEOFCASE/text()),
		map:put($response-obj,'DocketNumber', $entry//COMPANYPROFILE_LFR:DOCKETNUMBER/text()),
		map:put($response-obj,'FirmId', $entry//COMPANYPROFILE_LFR:FIRM_ID/text()),
		map:put($response-obj,'Details', $entry//COMPANYPROFILE_LFR:DETAILS/text())    
		)
	let $_ := json:array-push($response-arr,$response-obj)  
	return ()
	return $response-arr
};

declare function firm:GetLateralPartnerMoves()
{
	(:let $request := <request><OrganisationID>178</OrganisationID><OrganisationName>Latham &amp; Watkins</OrganisationName><StartYear /><EndYear /><ChangeType>removed</ChangeType><Title>Partner</Title></request> :)
	let $request := xdmp:get-request-body()/request
	let $OrganisationID := $request/OrganisationID
	let $OrganisationID := fn:tokenize($OrganisationID,',')
	let $RE_ID := ($OrganisationID ! firm:GetREIdByOrgId(.))
	let $sortBy := 'date_added'
	let $direction := 'descending'
	
	let $date-query := if (fn:exists($request/fromDate/text()) and fn:exists($request/toDate/text())) then
						cts:and-query((
						cts:element-range-query(xs:QName('ALI_RE_LateralMoves_Data:date_added'), '>=',xs:date($request/fromDate/text())),
						cts:element-range-query(xs:QName('ALI_RE_LateralMoves_Data:date_added'), '<=',xs:date($request/toDate/text()))
						))
						else ()
						
	let $title-query := if (fn:exists($request/Title/text())) then
						cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:Title'),$request/Title/text(),'case-insensitive')
						else ()
						
	let $practiceAreas-query := if (fn:exists($request/practiceAreas/text())) then
						cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:practices'),$request/practiceAreas/text(),('wildcarded', 'case-insensitive'))
						else ()
	
	let $name-query := if (fn:exists($request/name/text())) then
						cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:Attorney_Name'),$request/name/text(),('wildcarded', 'case-insensitive'))
						else ()
						
	
	let $locations := if (fn:exists($request/cities/text()) and fn:exists($request/states/text()) and fn:exists($request/countries/text()) and fn:exists($request/geographicregions/text()) and fn:exists($request/usregions/text())) then
	(cts:element-values(xs:QName('ALI_RE_LateralMoves_Data:std_loc'),(),(),
		cts:and-query((
		cts:directory-query('/LegalCompass/relational-data/city/'),
		cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:city'), $request/cities/text()),
		cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:state'), $request/states/text()),
		cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:country'), $request/countries/text()),
		cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:geographic_region'), $request/geographicregions/text()),
		cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:us_region'), $request/usregions/text())
		))))
	else cts:element-values(xs:QName('ALI_RE_LateralMoves_Data:std_loc'))
						
	let $search-results := cts:search(/,
	cts:and-query((
		cts:directory-query($config:RD-ALI_RE_LATERALMOVES_DATA-PATH,'infinity')
		,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:company_Id'),$RE_ID,('exact'))
		,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:action'),$request/ChangeType/text(),'case-insensitive')
		,$date-query
		,$title-query
		,$practiceAreas-query
		,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:std_loc'),$locations,'case-insensitive')
		,$name-query
	)))
	
	let $Totalcount :=  count($search-results)
	
	let $search-results := for $result in $search-results
		let $order-by :=if (fn:upper-case($sortBy) = fn:upper-case('date_added')) then 
		$result//ALI_RE_LateralMoves_Data:date_added/text()
		else ()  
		order by 
		if ($direction ne 'descending') then () else $order-by descending,
		if ($direction ne 'ascending') then () else $order-by ascending
	return $result
	
	let $response-arr := json:array()
	let $date := for $entry in $search-results
	let $response-obj := json:object()
	let $FROM := if(fn:not($entry//ALI_RE_LateralMoves_Data:CompanyName_From/text() != '') and $entry//ALI_RE_LateralMoves_Data:action/text() = 'removed') then
					$entry//ALI_RE_LateralMoves_Data:Company_Name/text()
					else $entry//ALI_RE_LateralMoves_Data:CompanyName_From/text()
	let $TO := if(($entry//ALI_RE_LateralMoves_Data:CompanyName_To/text() eq '') and $entry//ALI_RE_LateralMoves_Data:action/text() = 'added') then
					$entry//ALI_RE_LateralMoves_Data:Company_Name/text()
					else $entry//ALI_RE_LateralMoves_Data:CompanyName_To/text()
					
	let $From_Id := if(($entry//ALI_RE_LateralMoves_Data:CompanyID_FROM_ALI/text() eq '') and $entry//ALI_RE_LateralMoves_Data:action/text() = 'removed') then
					$entry//ALI_RE_LateralMoves_Data:CompanyID_ALI/text()
					else $entry//ALI_RE_LateralMoves_Data:CompanyID_FROM_ALI/text()
					
	let $To_Id := if(($entry//ALI_RE_LateralMoves_Data:CompanyId_To_ALI/text()) eq '' and $entry//ALI_RE_LateralMoves_Data:action/text() = 'added') then
					$entry//ALI_RE_LateralMoves_Data:CompanyID_ALI/text()
					else $entry//ALI_RE_LateralMoves_Data:CompanyId_To_ALI/text()  
					
	let $last_action := if($entry//ALI_RE_LateralMoves_Data:action/text() = 'removed') then
		'Departed'
		else 'Joined'
	
	let $attorney_link := if($entry//ALI_RE_LateralMoves_Data:action/text() = 'removed') then
		()
		else $entry//ALI_RE_LateralMoves_Data:Attorney_Link/text()
		
	let $Attorney_Email := if($entry//ALI_RE_LateralMoves_Data:action/text() = 'removed') then
		()
		else $entry//ALI_RE_LateralMoves_Data:email/text()
	let $_ := (
		map:put($response-obj,'totalcount', ($Totalcount)),
		map:put($response-obj,'firmId', xs:integer($entry//ALI_RE_LateralMoves_Data:company_Id/text())),
		map:put($response-obj,'attorney_id', xs:integer($entry//ALI_RE_LateralMoves_Data:person_id/text())),
		map:put($response-obj,'firmname', $entry//ALI_RE_LateralMoves_Data:Company_Name/text()),
		map:put($response-obj,'practices', fn:replace($entry//ALI_RE_LateralMoves_Data:practices/text(),';','; ')),
		map:put($response-obj,'education', $entry//ALI_RE_LateralMoves_Data:edu/text()),
		map:put($response-obj,'date_added', $entry//ALI_RE_LateralMoves_Data:date_added/text()),
		map:put($response-obj,'name', $entry//ALI_RE_LateralMoves_Data:Attorney_Name/text()),
		map:put($response-obj,'title', $entry//ALI_RE_LateralMoves_Data:Title/text()),
		map:put($response-obj,'location', $entry//ALI_RE_LateralMoves_Data:Location/text()),
		map:put($response-obj,'From', $FROM),
		map:put($response-obj,'To', $TO),
		map:put($response-obj,'From_Id', $From_Id),
		map:put($response-obj,'To_Id', $To_Id),
		map:put($response-obj,'last_action', $last_action),
		map:put($response-obj,'attorney_link', $attorney_link),
		map:put($response-obj,'biotext', $entry//ALI_RE_LateralMoves_Data:detail_text/text()),
		map:put($response-obj,'Attorney_Email', $Attorney_Email),
		map:put($response-obj,'ali_id', $entry//ALI_RE_LateralMoves_Data:CompanyID_ALI/text()),
		map:put($response-obj,'ALI_Name', $entry//ALI_RE_LateralMoves_Data:CompanyName_ALI/text())
		)
	let $_ := json:array-push($response-arr,$response-obj)  
	return ()
	return $response-arr
};

declare function firm:GetLawFirmProfileNews(
	 $toDate
	,$fromDate
	,$toDate-Time
	,$fromDate-Time
	,$FIRMID
)
{
	let $OrganizationID := $FIRMID
	let $organizationName := if((/organization[organization:ORGANIZATION_ID = xs:string($OrganizationID)]/organization:ALM_NAME/text())[1] ne '')then 
	/organization[organization:ORGANIZATION_ID = xs:string($OrganizationID)]/organization:ALM_NAME/text()[1]
	else 
	/organization[organization:ORGANIZATION_ID = xs:string($OrganizationID)]/organization:ORGANIZATION_NAME/text()[1]
	
	let $response-arr := json:array()
	(:Part 1 of inline Query:)
	let $sortDate := cts:element-values(xs:QName('lfp_news:SORTDATE'),(),('descending'),
		cts:and-query((
			cts:directory-query($config:RD-LAWFIRMPROFILE-NEWS-PATH)
			,cts:element-value-query(xs:QName('lfp_news:FIRMID'), $FIRMID ,('exact'))
			,cts:element-range-query(xs:QName('lfp_news:SORTDATE'), '>=', $fromDate-Time)
			,cts:element-range-query(xs:QName('lfp_news:SORTDATE'), '<=', $toDate-Time)    
		)))
	
	let $date-formatted := for $date in $sortDate
		return fn:format-dateTime(($date), '[Y]-[M01]')
	
	(:let $IDs:= count(fn:distinct-values($search-results/LAWFIRMPROFILE_NEWS/lfp_news:ID)) :)
	let $data := for $date in fn:distinct-values($date-formatted)
		let $dateSearch := cts:search(/,
			cts:and-query((
				 cts:directory-query($config:RD-LAWFIRMPROFILE-NEWS-PATH)
				,cts:element-value-query(xs:QName('lfp_news:FIRMID'),$FIRMID,('exact'))
				,cts:element-range-query(xs:QName('lfp_news:SORTDATE'), '>=', $fromDate-Time)
				,cts:element-range-query(xs:QName('lfp_news:SORTDATE'), '<=',  $toDate-Time) 
				,cts:element-value-query(xs:QName('lfp_news:SORTDATE'),fn:concat($date,'-*'),('wildcarded'))
			)))
	
		let $COUNT := fn:round(count($dateSearch//lfp_news:SORTDATE/text()))
		(:let $COUNT := count($dateSearch):)
		let $min-Date := (:min(xs:dateTime($dateSearch//lfp_news:SORTDATE)) :) min($dateSearch//lfp_news:SORTDATE ! xs:dateTime(.))
	
		let $response-obj := json:object()
		let $_ := (
			map:put($response-obj,'FIRMID',$FIRMID),
			map:put($response-obj,'FIRMNAME', $organizationName),
			map:put($response-obj,'TOTAL',$COUNT),
			map:put($response-obj,'SORTDATE',$min-Date),
			map:put($response-obj,'SOURCE','Total Activity')
			)
		let $_ := json:array-push($response-arr,$response-obj)  
		return ()
	
	(:Part 2 inline Query:)
	(:Used same search -result of part 1:)
	let $search-results := cts:search(/,
		cts:and-query((
			cts:directory-query($config:RD-LAWFIRMPROFILE-NEWS-PATH)
			,cts:element-value-query(xs:QName('lfp_news:FIRMID'),$FIRMID,('exact'))
			,cts:element-range-query(xs:QName('lfp_news:SORTDATE'), '>=', $fromDate-Time)
			,cts:element-range-query(xs:QName('lfp_news:SORTDATE'), '<=', $toDate-Time)
		)))
	
	let $data := for $date in fn:distinct-values($date-formatted)  
		let $SOURCE :=fn:distinct-values($search-results/LAWFIRMPROFILE_NEWS[fn:contains(lfp_news:SORTDATE,$date)]//lfp_news:SOURCE)  
		
		(:Logic for source with 'Firm Site':)  
		let $res := if(fn:contains(fn:string-join($SOURCE,','),'Firm Site')) then  (
				let $count :=  count($search-results/LAWFIRMPROFILE_NEWS[fn:contains(lfp_news:SORTDATE,$date) and lfp_news:SOURCE = 'Firm Site'])  
				(:let $min-Date := min(xs:dateTime($search-results/LAWFIRMPROFILE_NEWS[fn:contains(lfp_news:SORTDATE,$date) and lfp_news:SOURCE = 'Firm Site']//lfp_news:SORTDATE)) :)
				let $min-Date := min(($search-results/LAWFIRMPROFILE_NEWS[fn:contains(lfp_news:SORTDATE,$date) and lfp_news:SOURCE = 'Firm Site']//lfp_news:SORTDATE) ! xs:dateTime(.) )
				let $response-obj := json:object()
				let $_ := (
					map:put($response-obj,'FIRMID',$FIRMID),
					map:put($response-obj,'FIRMNAME', $organizationName),
					map:put($response-obj,'TOTAL',$count),
					map:put($response-obj,'SORTDATE',$min-Date),
					map:put($response-obj,'SOURCE','Firm Site')
				)
				let $_ := json:array-push($response-arr,$response-obj)   
				return ()
				)
			else ()
	
		(:Logic for source not having 'Firm Site':)
		let $res := if(not(fn:contains(fn:string-join($SOURCE,','),'Firm Site')) and not(fn:contains(fn:string-join($SOURCE,','),'ALI'))) then  
			()
			else
			let $count :=  count($search-results/LAWFIRMPROFILE_NEWS[fn:contains(lfp_news:SORTDATE,$date) and lfp_news:SOURCE ne 'Firm Site'])  
			(:let $min-Date := min(xs:dateTime($search-results/LAWFIRMPROFILE_NEWS[fn:contains(lfp_news:SORTDATE,$date) and lfp_news:SOURCE ne 'Firm Site']//lfp_news:SORTDATE)):)
			let $min-Date := min(($search-results/LAWFIRMPROFILE_NEWS[fn:contains(lfp_news:SORTDATE,$date) and lfp_news:SOURCE ne 'Firm Site']//lfp_news:SORTDATE) ! xs:dateTime(.)) 
			let $response-obj := json:object()
			let $_ := (
				map:put($response-obj,'FIRMID',$FIRMID),
				map:put($response-obj,'FIRMNAME', $organizationName),
				map:put($response-obj,'TOTAL',$count),
				map:put($response-obj,'SORTDATE',$min-Date),
				map:put($response-obj,'SOURCE','News Coverage')
			)
			let $_ := if (xs:string($min-Date) != '') then json:array-push($response-arr,$response-obj) else ()
			return () 
		
		return $res 
	
	(:3rd patr of inline query:)
	
	let $maxYears := max(cts:element-attribute-values(xs:QName('survey:YEAR'),xs:QName('PublishYear'),(),('descending'),
	cts:and-query((
		cts:directory-query($config:DD-SURVEY-AMLAW_100-PATH,'1')
	))))
	
	(: let $OrganizationIDs := cts:element-attribute-values(xs:QName('survey:YEAR'),xs:QName('OrganizationID'),(),('descending'),
	cts:and-query((
	cts:directory-query('/LegalCompass/denormalized-data/surveys/AMLAW_100/','1'),
	cts:element-attribute-value-query(xs:QName('survey:YEAR'),xs:QName('PublishYear'),xs:string($maxYears))
	))) :)
	
	let $OrganizationIDs := cts:element-values(xs:QName('amlaw100:ORGANIZATION_ID'),(),(),
	  cts:and-query((
		 cts:directory-query($config:RD-SURVEY-AMLAW_100-PATH)
		,cts:element-value-query(xs:QName('amlaw100:PUBLISHYEAR'),xs:string($maxYears))
	  )))
	
	
	let $sortDate := cts:element-values(xs:QName('lfp_news:SORTDATE'),(),('descending'),
	cts:and-query((
		cts:directory-query($config:RD-LAWFIRMPROFILE-NEWS-PATH)
		,cts:element-value-query(xs:QName('lfp_news:FIRMID'),($OrganizationIDs ! xs:string(.)),('exact'))
		,cts:element-range-query(xs:QName('lfp_news:SORTDATE'), '>=',$fromDate-Time)
		,cts:element-range-query(xs:QName('lfp_news:SORTDATE'), '<=', $toDate-Time) 
	)))
	
	let $date-formatted := for $date in $sortDate
	return fn:format-dateTime(($date), '[Y]-[M01]')
	
	let $data := for $date in fn:distinct-values($date-formatted)
	let $dateSearch := cts:search(/,
		cts:and-query((
		cts:directory-query($config:RD-LAWFIRMPROFILE-NEWS-PATH)
		,cts:element-value-query(xs:QName('lfp_news:FIRMID'),($OrganizationIDs ! xs:string(.)),('exact'))
		,cts:element-range-query(xs:QName('lfp_news:SORTDATE'), '>=', $fromDate-Time)
		,cts:element-range-query(xs:QName('lfp_news:SORTDATE'), '<=', $toDate-Time)
		,cts:element-value-query(xs:QName('lfp_news:SORTDATE'),fn:concat($date,'-*'),('wildcarded'))
		)))
	(:let $COUNT := fn:round(count($dateSearch//lfp_news:SORTDATE/text()) div 100):)
	let $COUNT := fn:round(count($dateSearch//lfp_news:SORTDATE/text()) div 100)
	let $min-Date := (:min(xs:dateTime($dateSearch//lfp_news:SORTDATE)):) min($dateSearch//lfp_news:SORTDATE ! xs:dateTime(.))
	
	let $response-obj := json:object()
	let $_ := (
		map:put($response-obj,'FIRMID', 0),
		map:put($response-obj,'FIRMNAME', 'AM Law 100'),
		map:put($response-obj,'TOTAL',$COUNT),
		map:put($response-obj,'SORTDATE',$min-Date),
		map:put($response-obj,'SOURCE', 'AM Law 100 Average Total Activity')
		)
	let $_ := json:array-push($response-arr,$response-obj)  
	return ()  
	
	return ($response-arr)
};

declare function firm:GetLawfirmContactsAdded()
{
	let $request := xdmp:get-request-body()/request
	let $OrganisationID := $request/firmIds
	let $OrganisationID := fn:tokenize($OrganisationID,',')
	let $RE_ID := ($OrganisationID ! firm:GetREIdByOrgId(.))
	
	let $date-query := if (fn:exists($request/fromDate/text()) and fn:exists($request/toDate/text())) then
						()
						else 
						()
	let $title-query := if (fn:exists($request/titles/text())) then
						cts:element-value-query(xs:QName('people_changes:std_title'),$request/titles/text(),'case-insensitive')
						else
						()
	let $locations := if (fn:exists($request/cities/text()) and fn:exists($request/states/text()) and fn:exists($request/countries/text()) and fn:exists($request/geographicregions/text()) and fn:exists($request/usregions/text())) then
	(cts:element-values(xs:QName('city:std_loc'),(),(),
		cts:and-query((
		cts:directory-query('/LegalCompass/relational-data/city/'),
		cts:element-value-query(xs:QName('city:city'), $request/cities/text()),
		cts:element-value-query(xs:QName('city:state'), $request/states/text()),
		cts:element-value-query(xs:QName('city:country'), $request/countries/text()),
		cts:element-value-query(xs:QName('city:geographic_region'), $request/geographicregions/text()),
		cts:element-value-query(xs:QName('city:us_region'), $request/usregions/text())
		))))
	else cts:element-values(xs:QName('city:std_loc'))
	let $response-arr := json:array()
	
	let $search-results := cts:search(/,
	cts:and-query((
		cts:directory-query($config:RD-PEOPLE_CHANGES-PATH)
		,cts:element-value-query(xs:QName('people_changes:company'),$RE_ID)
		,cts:element-value-query(xs:QName('people_changes:action'),$request/lastAction/text(),'case-insensitive')
		,cts:element-value-query(xs:QName('people_changes:std_loc'),$locations,'case-insensitive') 
		,$date-query
		,$title-query
	)))
	
	let $data := for $result in $search-results
		let $response-obj := json:object()
		let $company_from := if($result//people_changes:company_id_from/text() ne '0' and $result//people_changes:company_id_from/text() ne ' ')then
		doc(fn:concat('/LegalCompass/relational-data/company/',$result//people_changes:company_id_from,'.xml'))//company:company/text()
		else ()
		let $company_to := if($result//people_changes:company_id_to/text() ne '0' and $result//people_changes:company_id_to/text() ne ' ')then
		doc(fn:concat('/LegalCompass/relational-data/company/',$result//people_changes:company_id_to,'.xml'))//company:company/text()
		else ()
		let $_ := (
		map:put($response-obj,'firmId', $result//people_changes:company/text()),
		map:put($response-obj,'date_added', $result//people_changes:date_added/text()),
		map:put($response-obj,'name', $result//people_changes:name/text()),
		map:put($response-obj,'title', $result//people_changes:std_title/text()),
		map:put($response-obj,'location', $result//people_changes:std_loc/text()),
		map:put($response-obj,'from', $company_from),
		map:put($response-obj,'to', $company_to),
		map:put($response-obj,'last_action', $result//people_changes:action/text())
		)
		let $_ := json:array-push($response-arr,$response-obj)
	return ()
	return ($response-arr)
};

declare function firm:GetLawFirmGlobalMapByPractices()
{
	(:let $request :=  <request><FirmID>178</FirmID></request>:)
	let $request := xdmp:get-request-body()/request
	let $RE_ID := firm:GetREIdByOrgId($request/FirmID/text())
	let $response-arr := json:array()
	let $organization := fn:doc(fn:concat('/LegalCompass/denormalized-data/organization/', $request/FirmID/text() ,'.xml'))
	let $ORGANIZATION_NAME := if ($organization//organization:ALM_NAME) then $organization//organization:ALM_NAME/text() else $organization//organization:ORGANIZATION_NAME/text()
	
	let $locations := cts:element-values(xs:QName('rd_person:std_loc'), (), ('collation=http://marklogic.com/collation//S1/AS/T0020'),
	cts:and-query((
		cts:directory-query('/LegalCompass/relational-data/person/')
		,cts:element-value-query(xs:QName('rd_person:std_title'), ('Partner','Associate','Other Counsel/Attorney'), ('case-insensitive'))
		,cts:element-value-query(xs:QName('rd_person:company'), $RE_ID )
		)))
	for $location in $locations
	let $query := cts:and-query((
		cts:directory-query('/LegalCompass/relational-data/person/')      
		,cts:element-value-query(xs:QName('rd_person:company'), $RE_ID )
		,cts:element-value-query(xs:QName('rd_person:std_loc'),$location)
		))
	let $Practice := for $practiceArea in cts:values(cts:element-reference(xs:QName('rd_person:practice_area')), (), (),$query)
	
	let $city := cts:search(/city_detail:city_detail,
				cts:and-query((
				cts:directory-query('/LegalCompass/relational-data/city_detail/')
				,cts:element-value-query(xs:QName('city_detail:STD_LOC'), $location, ('case-insensitive'))
				)))[1]
	let $response-obj := json:object()
	let $_ := (
		map:put($response-obj,'firmid',$request/FirmID/text()),
		map:put($response-obj,'firmLocation', $location),
		map:put($response-obj,'practicearea', $practiceArea),
		map:put($response-obj,'latitude', $city/city_detail:LATITUDE/text()),
		map:put($response-obj,'longitude', $city/city_detail:LONGITUDE/text()),
		map:put($response-obj,'firmName', $ORGANIZATION_NAME),
		map:put($response-obj,'totalcount', xdmp:estimate(cts:search(fn:doc(),$query))),
		map:put($response-obj,'headCount', cts:frequency($practiceArea))
		)
		(:let $_ := json:array-push($response-arr, $response-obj):)
	(:return  $location || ' : ' || $practiceArea  || ' : ' ||$city/city_detail:LATITUDE/text()||' : '||$city/city_detail:LONGITUDE/text()||' : '|| cts:frequency($practiceArea):)
	return $response-obj
	return $Practice 

};

declare function firm:GetOfficeTrendsMap()
{
	let $request := xdmp:get-request-body()/request
	
	let $firmIDs :=fn:tokenize($request/firmIds/text(),',')
	let $practiceAreas := $request/practiceAreas/text()
	let $response-arr := json:array()
	
	(:let $practiceAreas := fn:concat('*',$practiceAreas,'*'):)
	let $practiceAreas := $practiceAreas

for $firmID in $firmIDs
let $RE_ID := firm:GetREIdByOrgId( $firmID )

(:Get Locations :)

let $person-locations := cts:element-values(xs:QName('ALI_RE_Attorney_Data:location'), (), (),
 cts:and-query((
     cts:directory-query('/LegalCompass/denormalized-data/ALI_RE_Attorney_Data/')
    ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:practice_area'),$practiceAreas,('wildcarded'))
    ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:title'), ('Partner','Associate','Other Counsel/Attorney'))
    ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:firm_id'), $RE_ID )
    ,cts:not-query(cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:location'), ('Location not identified','Location Not Available')))
    )))
(:    
let $locations :=  cts:element-values(xs:QName('city_detail:STD_LOC'),(),(),
        cts:and-query((
        cts:directory-query('/LegalCompass/relational-data/city_detail/')
        ,cts:element-value-query(xs:QName('city_detail:STD_LOC'),$person-locations,('case-insensitive'))
       )))

for $location in $locations
:)
for $location in $person-locations
    (:let $query := cts:and-query((
       cts:directory-query('/LegalCompass/denormalized-data/ALI_RE_Attorney_Data/')
      ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:firm_id'), $RE_ID )
      ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:location'),$location,'case-insensitive')
      ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:practices'),$practiceAreas)
      ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:title'), ('Partner','Associate','Other Counsel/Attorney'), ('case-insensitive'))
      ,cts:not-query(cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:status'), ''))
      )):)
    let $query := cts:and-query((
      cts:directory-query('/LegalCompass/denormalized-data/ALI_RE_Attorney_Data/')
      ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:practice_area'), $practiceAreas, ('wildcarded','case-insensitive'))
      ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:location'),$location,'case-insensitive')
      ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:firm_id'), xs:string($RE_ID))
      )) 
    let $headcount := xdmp:estimate(cts:search(/,
      cts:and-query((
      $query
      ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),('case-insensitive'))
     )))) 
      
    let $partnercount := xdmp:estimate(cts:search(/,
      cts:and-query((
      $query
      ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:firm_id'), xs:string($RE_ID))
      ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:title'), ('Partner'))
      ))))
    let $associatecount := xdmp:estimate(cts:search(/,
      cts:and-query((
      $query
      ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:firm_id'), xs:string($RE_ID))
      ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:title'), ('Associate'))
      ))))
    let $othercouselcount := xdmp:estimate(cts:search(/,
      cts:and-query((
      $query
      ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:firm_id'), xs:string($RE_ID))
      ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:title'), ('Other Counsel/Attorney'),'case-insensitive')
      )))) 
    let $admincount := xdmp:estimate(cts:search(/,
      cts:and-query((
      $query
      ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:firm_id'), xs:string($RE_ID))
      ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:title'), ('Administrative / Support Staff'),'case-insensitive')
      )))) 
    let $othercount :=  xdmp:estimate(cts:search(/,
      cts:and-query((
      $query
      ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:firm_id'), xs:string($RE_ID))
      ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:title'), ('Other'),'case-insensitive')
      ))))
      
      let $city-data := cts:search(/,
        cts:and-query((
        cts:directory-query('/LegalCompass/relational-data/city_detail/'),
        (:cts:element-value-query(xs:QName('city_detail:STD_LOC'),$location,('case-insensitive','whitespace-sensitive')):)
		cts:element-value-query(xs:QName('city_detail:STD_LOC'),$location,('case-insensitive','whitespace-sensitive','punctuation-sensitive'))
       )))
	   
    let $A := (cts:search(/,
        cts:and-query((
        $query
        ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney','Administrative / Support Staff','Other'),('case-insensitive'))
       ))))[1]
	   
 let $response-obj := json:object()
      let $_ := (
        map:put($response-obj,'firmid', (xs:string($firmID))),
        map:put($response-obj,'firmlocation', $location),
        map:put($response-obj,'firmname', $A//ALI_RE_Attorney_Data:firm_name/text()),
        map:put($response-obj,'headcount', $headcount),
        map:put($response-obj,'partnercount', $partnercount),
        map:put($response-obj,'associatecount',  $associatecount),
        map:put($response-obj,'othercouselcount', $othercouselcount),
        map:put($response-obj,'admincount', $admincount),
        map:put($response-obj,'othercount', $othercount),
        map:put($response-obj,'practicearea', firm:GetAllPracticeAreas($RE_ID,$location)),
        map:put($response-obj,'LATITUDE', $city-data//city_detail:LATITUDE/text()),
        map:put($response-obj,'LONGITUDE', $city-data//city_detail:LONGITUDE/text())
      )  
return $response-obj

};

declare function firm:GetOfficeTrendsDataAnalysis()
{
let $request := xdmp:get-request-body()/request

let $PracticeAreas := fn:tokenize($request/PracticeAreas/text(),'[|]')
let $Cities := tokenize($request/cities/text(), '~')
let $FirmIds := tokenize($request/firmIds/text(), ',')

let $PracticeArea-Query := if($PracticeAreas != '')then
  cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:practice_area'), $PracticeAreas, ('case-insensitive'))
  else ()

  let $ID-Query := if($FirmIds != '')then
  cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:ALI_ID'), $FirmIds, ('case-insensitive'))
  else ()
  
(:let $query := 
  cts:and-query(((
     cts:directory-query('/LegalCompass/denormalized-data/ALI_RE_Attorney_Data/')
    ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:practice_area'), $PracticeAreas, ('case-insensitive'))
    ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:location'), $Cities)
))) :)
let $query := 
  cts:and-query(((
     cts:directory-query('/LegalCompass/denormalized-data/ALI_RE_Attorney_Data/')
    ,$PracticeArea-Query
	,$ID-Query
    ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:location'), $Cities,('case-insensitive','whitespace-sensitive'))
)))

let $city-data := cts:search(/city_detail:city_detail,
            cts:and-query((
               cts:directory-query('/LegalCompass/relational-data/city_detail/')
              ,cts:element-value-query(xs:QName('city_detail:STD_LOC'), $Cities, ('case-insensitive','whitespace-sensitive'))              
            )))[1] 
          
(:let $search := for $company in cts:values(cts:element-reference(xs:QName('ALI_RE_Attorney_Data:firm_id')), (), (),$query):)
let $search := for $company in fn:distinct-values(cts:search(/ALI_RE_Attorney_Data,
	$query)//ALI_RE_Attorney_Data:firm_id/text())

  
  let $headcount := xdmp:estimate(cts:search(/,
    cts:and-query((
     cts:directory-query('/LegalCompass/denormalized-data/ALI_RE_Attorney_Data/')
    ,$PracticeArea-Query
    ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:location'), $Cities,('case-insensitive','whitespace-sensitive'))
    ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:firm_id'), xs:string($company))
    ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),('case-insensitive'))
    ))))
  let $partnercount := xdmp:estimate(cts:search(/,
    cts:and-query((     
    $query
    ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:firm_id'), xs:string($company))
    ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:title'), ('Partner'),('case-insensitive'))
    ))))
  let $associatecount := xdmp:estimate(cts:search(/,
    cts:and-query((
    $query
    ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:firm_id'), xs:string($company))
    ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:title'), ('Associate'))
    ))))
  let $othercouselcount := xdmp:estimate(cts:search(/,
    cts:and-query((
    $query
    ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:firm_id'), xs:string($company))
    ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:title'), ('Other Counsel/Attorney'),'case-insensitive')
    )))) 
  let $admincount := xdmp:estimate(cts:search(/,
    cts:and-query((
    $query
    ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:firm_id'), xs:string($company))
    ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:title'), ('Administrative / Support Staff'),'case-insensitive')
    )))) 
  let $othercount :=  xdmp:estimate(cts:search(/,
    cts:and-query((
    $query
    ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:firm_id'), xs:string($company))
    ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:title'), ('Other'),'case-insensitive')
    ))))
    
  let $A := (cts:search(/,
    cts:and-query((
     cts:directory-query('/LegalCompass/denormalized-data/ALI_RE_Attorney_Data/')
    ,$PracticeArea-Query
    ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:location'), $Cities, ('case-insensitive','whitespace-sensitive'))
    ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:firm_id'), xs:string($company))
    ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney','Other','Administrative / Support Staff'),('case-insensitive'))
    ))))[1]
	
  let $FIRMID := if($A//ALI_RE_Attorney_Data:ALI_ID/text() ne "")
    then $A//ALI_RE_Attorney_Data:ALI_ID/text()
    else $A//ALI_RE_Attorney_Data:firm_id/text()
	
  let $FirmName := if($A//ALI_RE_Attorney_Data:ALM_NAME/text() ne "")then
    $A//ALI_RE_Attorney_Data:ALM_NAME/text()
    else
    $A//ALI_RE_Attorney_Data:firm_name/text()
	
  let $response-obj := json:object()
  let $_ := (
    map:put($response-obj,'firmid', $FIRMID),
    map:put($response-obj,'firmlocation', $Cities),
    (:map:put($response-obj,'firmname', $A//ALI_RE_Attorney_Data:firm_name/text()),:)
	map:put($response-obj,'firmname', $FirmName),
    map:put($response-obj,'headcount', $headcount),
    map:put($response-obj,'partnercount', $partnercount),
    map:put($response-obj,'associatecount',  $associatecount),
    map:put($response-obj,'othercouselcount', $othercouselcount),
    map:put($response-obj,'admincount', $admincount),
    map:put($response-obj,'othercount', $othercount),
    map:put($response-obj,'practicearea', firm:GetAllPracticeAreas((xs:string($company)),$Cities,$PracticeAreas)),
    map:put($response-obj,'LATITUDE', $city-data//city_detail:LATITUDE/text()),
    map:put($response-obj,'LONGITUDE', $city-data//city_detail:LONGITUDE/text())
  )
  (:return $headcount || ' - ' || (/organization[organization:ORGANIZATION_ID = firm:GetALIIdByREId(xs:string($company))]/organization:ORGANIZATION_NAME/text())[1]:)
  return $response-obj 
return ($search) 

};

declare function firm:GetOfficeTrendsDataAnalysis_Merged()
{
let $request := xdmp:get-request-body()/request	

let $PracticeAreas := fn:tokenize($request/PracticeAreas/text(),'[|]')
let $Cities := tokenize($request/cities/text(), '~')
let $FirmIds := tokenize($request/firmIds/text(), ',')

let $maxYears := fn:max(cts:element-attribute-values(xs:QName("survey:YEAR"),xs:QName("PublishYear"),(),("descending"),
  cts:and-query((
    cts:directory-query("/LegalCompass/denormalized-data/surveys/AMLAW_200/","1")
  ))))
  
let $PracticeArea-Query := if($PracticeAreas != '')then
  cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:practice_area'), $PracticeAreas, ('case-insensitive'))
  else ()
  
let $ID-Query := if($FirmIds != '')then
  cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:ALI_ID'), $FirmIds, ('case-insensitive'))
  else ()
  
let $query := 
  cts:and-query(((
     cts:directory-query('/LegalCompass/denormalized-data/ALI_RE_Attorney_Data/')
    ,$PracticeArea-Query
    ,$ID-Query
    ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:location'), $Cities,('case-insensitive','whitespace-sensitive'))
)))

let $city-data := cts:search(/city_detail:city_detail,
            cts:and-query((
               cts:directory-query('/LegalCompass/relational-data/city_detail/')
              ,cts:element-value-query(xs:QName('city_detail:STD_LOC'), $Cities, ('case-insensitive','whitespace-sensitive'))              
            )))[1] 
            

let $search := for $company in fn:distinct-values(cts:search(/ALI_RE_Attorney_Data,$query)//ALI_RE_Attorney_Data:firm_id/text())
  
  let $headcount := xdmp:estimate(cts:search(/,
    cts:and-query((
     cts:directory-query('/LegalCompass/denormalized-data/ALI_RE_Attorney_Data/')
    ,$PracticeArea-Query
    ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:location'), $Cities,('case-insensitive','whitespace-sensitive'))
    ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:firm_id'), xs:string($company))
    ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),('case-insensitive'))
    ))))
  let $partnercount := xdmp:estimate(cts:search(/,
    cts:and-query((     
    $query
    ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:firm_id'), xs:string($company))
    ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:title'), ('Partner'),('case-insensitive'))
    ))))
  let $associatecount := xdmp:estimate(cts:search(/,
    cts:and-query((
    $query
    ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:firm_id'), xs:string($company))
    ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:title'), ('Associate'))
    ))))
  let $othercouselcount := xdmp:estimate(cts:search(/,
    cts:and-query((
    $query
    ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:firm_id'), xs:string($company))
    ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:title'), ('Other Counsel/Attorney'),'case-insensitive')
    )))) 
  let $admincount := xdmp:estimate(cts:search(/,
    cts:and-query((
    $query
    ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:firm_id'), xs:string($company))
    ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:title'), ('Administrative / Support Staff'),'case-insensitive')
    )))) 
  let $othercount :=  xdmp:estimate(cts:search(/,
    cts:and-query((
    $query
    ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:firm_id'), xs:string($company))
    ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:title'), ('Other'),'case-insensitive')
    ))))
  
  let $A := (cts:search(/,
    cts:and-query((
     cts:directory-query('/LegalCompass/denormalized-data/ALI_RE_Attorney_Data/')
    ,$PracticeArea-Query
    ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:location'), $Cities, ('case-insensitive','whitespace-sensitive'))
    ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:firm_id'), xs:string($company))
    ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney','Other','Administrative / Support Staff'),('case-insensitive'))
    ))))[1]
	
  let $FIRMID := if($A//ALI_RE_Attorney_Data:ALI_ID/text() ne "")
    then $A//ALI_RE_Attorney_Data:ALI_ID/text()
    else $A//ALI_RE_Attorney_Data:firm_id/text()
	
  let $b := cts:search(/Diversity_Scorecard:DiversityScorecard,
    cts:and-query((
    cts:directory-query("/LegalCompass/relational-data/surveys/Diversity_Scorecard/")
    ,cts:element-value-query(xs:QName("Diversity_Scorecard:PUBLISHYEAR"),xs:string($maxYears))
    ,cts:element-value-query(xs:QName("Diversity_Scorecard:ORGANIZATION_ID"),xs:string($FIRMID))
    )))
  let $minorityAttorneys := fn:round($b//Diversity_Scorecard:TOTAL_PARTNERS/text() * $b//Diversity_Scorecard:MINORITY_PERC_PARTNERS/text())
  
  let $c := cts:search(/FEMALE_SCORECARD:FemaleScoreCard,
    cts:and-query((
    cts:directory-query("/LegalCompass/relational-data/surveys/FEMALE_SCORECARD/")
    ,cts:element-value-query(xs:QName("FEMALE_SCORECARD:PUBLISHYEAR"),xs:string($maxYears))
    ,cts:element-value-query(xs:QName("FEMALE_SCORECARD:ORGANIZATION_ID"),xs:string($FIRMID))
    )))
  
  let $d := cts:search(/AMLAW_200:AMLaw200,
    cts:and-query((
    cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/")
    ,cts:element-value-query(xs:QName("AMLAW_200:PUBLISHYEAR"),xs:string($maxYears))
    ,cts:element-value-query(xs:QName("AMLAW_200:ORGANIZATION_ID"),xs:string($FIRMID))
    )))
   let $e := cts:search(/,
    cts:and-query((
      cts:directory-query("/LegalCompass/relational-data/organization-address/","1"),
      cts:element-value-query(xs:QName('org-address:HEADQUARTERS'),'H','case-insensitive'),
      cts:element-value-query(xs:QName('org-address:ORGANIZATION_ID'),xs:string($FIRMID))
    )))[1]
    
  let $headquater := if($e//org-address:STATE/text() ne '') then
    fn:concat($e//org-address:CITY/text(),", ",$e//org-address:STATE/text())    
    else
    fn:concat($e//org-address:CITY/text(),", ",$e//org-address:COUNTRY/text())
	
  let $FirmName := if($A//ALI_RE_Attorney_Data:ALM_NAME/text() ne "")then
    $A//ALI_RE_Attorney_Data:ALM_NAME/text()
    else
    $A//ALI_RE_Attorney_Data:firm_name/text()
  
  let $response-obj := json:object()
  let $_ := (
    map:put($response-obj,'firmid', $FIRMID),
    map:put($response-obj,'firmlocation', $Cities),
    (:map:put($response-obj,'firmname', $A//ALI_RE_Attorney_Data:firm_name/text()),:)
	map:put($response-obj,'firmname', $FirmName),
    map:put($response-obj,'headcount', $headcount),
    map:put($response-obj,'partnercount', $partnercount),
    map:put($response-obj,'associatecount',  $associatecount),
    map:put($response-obj,'othercouselcount', $othercouselcount),
    map:put($response-obj,'admincount', $admincount),
    map:put($response-obj,'othercount', $othercount),
    map:put($response-obj,'practicearea', firm:GetAllPracticeAreas((xs:string($company)),$Cities,$PracticeAreas)),
    map:put($response-obj,'LATITUDE', $city-data//city_detail:LATITUDE/text()),
    map:put($response-obj,'LONGITUDE', $city-data//city_detail:LONGITUDE/text()),
    map:put($response-obj, 'minorityAttorneys', $minorityAttorneys),
    map:put($response-obj, 'femaleAttorneys',$c//FEMALE_SCORECARD:FEMALE_PARTNERS/text()),
    map:put($response-obj, 'leverage', $d//AMLAW_200:LEVERAGE/text()),
    map:put($response-obj, 'headquater', $headquater) 
  )
  (:return $headcount || ' - ' || (/organization[organization:ORGANIZATION_ID = firm:GetALIIdByREId(xs:string($company))]/organization:ORGANIZATION_NAME/text())[1]:)
  return $response-obj
return ($search) 

};


declare function firm:SP_GETOFFICETRENDSURVEYDATA()
{
let $response-arr := json:array()
let $maxYears := fn:max(cts:element-attribute-values(xs:QName("survey:YEAR"),xs:QName("PublishYear"),(),("descending"),
  cts:and-query((
    cts:directory-query("/LegalCompass/denormalized-data/surveys/AMLAW_200/","1")
  ))))

let $organizationaddress_IDs := fn:distinct-values(cts:search(/,
                   cts:and-query((
                     cts:directory-query('/LegalCompass/relational-data/organization-address/')                
                     ,cts:element-value-query(xs:QName('org-address:HEADQUARTERS'),'H','case-insensitive')
                   )))//org-address:ORGANIZATION_ID/text())
                   
let $organizationIDs := cts:element-values(xs:QName("organization:ORGANIZATION_ID"),(),())
let $organizationIDs := ($organizationaddress_IDs,$organizationIDs)

let $AMLAW_200_IDs := cts:element-values(xs:QName("AMLAW_200:ORGANIZATION_ID"),(),("descending"),
  cts:and-query((
    cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/","1")
    ,cts:element-value-query(xs:QName("AMLAW_200:PUBLISHYEAR"),xs:string($maxYears))
    ,cts:element-value-query(xs:QName("AMLAW_200:ORGANIZATION_ID"),($organizationIDs ! xs:string(.)))
  )))

let $DIVERSITY_SCORECARD_IDs := cts:element-values(xs:QName("Diversity_Scorecard:ORGANIZATION_ID"),(),("descending"),
  cts:and-query((
    cts:directory-query("/LegalCompass/relational-data/surveys/Diversity_Scorecard/")
    ,cts:element-value-query(xs:QName("Diversity_Scorecard:PUBLISHYEAR"),xs:string($maxYears))
    ,cts:element-value-query(xs:QName("Diversity_Scorecard:ORGANIZATION_ID"),($organizationIDs ! xs:string(.)))
  )))    

let $FEMALE_SCORECARD_IDs := cts:element-values(xs:QName("FEMALE_SCORECARD:ORGANIZATION_ID"),(),("descending"),
  cts:and-query((
    cts:directory-query("/LegalCompass/relational-data/surveys/FEMALE_SCORECARD/","1")
    ,cts:element-value-query(xs:QName("FEMALE_SCORECARD:PUBLISHYEAR"),xs:string($maxYears))
    ,cts:element-value-query(xs:QName("FEMALE_SCORECARD:ORGANIZATION_ID"),($organizationIDs ! xs:string(.)))
  )))

let $Org_Ids := ($AMLAW_200_IDs,$DIVERSITY_SCORECARD_IDs,$FEMALE_SCORECARD_IDs)
let $data := for $Org_Id in (fn:distinct-values($Org_Ids))

(:
let $Org_Ids := $FEMALE_SCORECARD_IDs
let $data := for $Org_Id in ($Org_Ids)
:)
  let $response-obj := json:object()
  
  let $b := cts:search(/Diversity_Scorecard:DiversityScorecard,
    cts:and-query((
    cts:directory-query("/LegalCompass/relational-data/surveys/Diversity_Scorecard/")
    ,cts:element-value-query(xs:QName("Diversity_Scorecard:PUBLISHYEAR"),xs:string($maxYears))
    ,cts:element-value-query(xs:QName("Diversity_Scorecard:ORGANIZATION_ID"),xs:string($Org_Id))
    )))
  let $c := cts:search(/FEMALE_SCORECARD:FemaleScoreCard,
    cts:and-query((
    cts:directory-query("/LegalCompass/relational-data/surveys/FEMALE_SCORECARD/")
    ,cts:element-value-query(xs:QName("FEMALE_SCORECARD:PUBLISHYEAR"),xs:string($maxYears))
    ,cts:element-value-query(xs:QName("FEMALE_SCORECARD:ORGANIZATION_ID"),xs:string($Org_Id))
    )))
  let $d := cts:search(/AMLAW_200:AMLaw200,
    cts:and-query((
    cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/")
    ,cts:element-value-query(xs:QName("AMLAW_200:PUBLISHYEAR"),xs:string($maxYears))
    ,cts:element-value-query(xs:QName("AMLAW_200:ORGANIZATION_ID"),xs:string($Org_Id))
    )))
   let $e := cts:search(/,
    cts:and-query((
      cts:directory-query("/LegalCompass/relational-data/organization-address/","1"),
      cts:element-value-query(xs:QName('org-address:HEADQUARTERS'),'H','case-insensitive'),
      cts:element-value-query(xs:QName('org-address:ORGANIZATION_ID'),xs:string($Org_Id))
    )))[1]
    
  let $headquater := if($e//org-address:STATE/text() ne '') then
    fn:concat($e//org-address:CITY/text(),", ",$e//org-address:STATE/text())    
    else
    fn:concat($e//org-address:CITY/text(),", ",$e//org-address:COUNTRY/text())

  let $orgName := if((/organization[firm-org:ORGANIZATION_ID = xs:string($Org_Id)]/firm-org:ALM_NAME/text())[1] ne '')then 
      /organization[firm-org:ORGANIZATION_ID = xs:string($Org_Id)]/firm-org:ALM_NAME/text()[1]
    else 
      /organization[firm-org:ORGANIZATION_ID = xs:string($Org_Id)]/firm-org:ORGANIZATION_NAME/text()[1]
      
  let $minorityAttorneys := fn:round($b//Diversity_Scorecard:TOTAL_PARTNERS/text() * $b//Diversity_Scorecard:MINORITY_PERC_PARTNERS/text())
  
  let $_ := (
    map:put($response-obj, 'firmID', $Org_Id),
    map:put($response-obj, 'firmName', $orgName),
    map:put($response-obj, 'minorityAttorneys', $minorityAttorneys),
    map:put($response-obj, 'femaleAttorneys',$c//FEMALE_SCORECARD:FEMALE_PARTNERS/text()),
    map:put($response-obj, 'leverage', $d//AMLAW_200:LEVERAGE/text()),
    map:put($response-obj, 'headquater', $headquater) 
    )
  return  ($response-obj)  
return $data

};

declare function firm:GetAllPracticeAreas($RE_ID,$locations)
{

for $location in $locations
  let $search := fn:string-join(cts:element-values(xs:QName('ALI_RE_Attorney_Data:practice_area'), (), ('ascending'),
    cts:and-query((
    cts:directory-query('/LegalCompass/denormalized-data/ALI_RE_Attorney_Data/')
    ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:firm_id'), $RE_ID )
    ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:location'), $location , ('case-insensitive'))
    ))),',')
    
return $search
};

declare function firm:GetAllPracticeAreas($RE_ID,$locations,$PracticeAreas)
{
	let $PracticeArea-Query := if($PracticeAreas != '')then
  cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:practice_area'), $PracticeAreas, ('case-insensitive'))
  else ()
  
for $location in $locations
  let $search := fn:string-join(cts:element-values(xs:QName('ALI_RE_Attorney_Data:practice_area'), (), ('ascending'),
  cts:and-query((
    cts:directory-query('/LegalCompass/denormalized-data/ALI_RE_Attorney_Data/')
    ,$PracticeArea-Query
    ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:firm_id'), $RE_ID )
    ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:location'), $locations, ('case-insensitive'))
	,cts:not-query(cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:practice_area'), '', ('case-insensitive')))
    ))),',')
    
return $search
};

(:------------- By Shubham --------------:)
declare function firm:GetAdvancedFirmSearchYears()
{
  let $res-array := json:array()
  let $amlaw100year := cts:search(/,
                  cts:and-query((
                       cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_100/')
                       )))//amlaw100:PUBLISHYEAR/text()
                       
  let $amlaw200year := cts:search(/,
                  cts:and-query((
                       cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/')
                       )))//AMLAW_200:PUBLISHYEAR/text()
                       
 let $dc20year := cts:search(/,
                  cts:and-query((
                       cts:directory-query('/LegalCompass/relational-data/surveys/DC20/')
                       )))//dc20:PUBLISHYEAR/text()
                       
 let $global100year := cts:search(/,
                  cts:and-query((
                       cts:directory-query('/LegalCompass/relational-data/surveys/Global_100/')
                       )))//Global_100:PUBLISHYEAR/text()        
                       
 let $legaltimesyear := cts:search(/,
                  cts:and-query((
                       cts:directory-query('/LegalCompass/relational-data/surveys/Legal_Times_150/')
                       )))//legaltimes:PUBLISHYEAR/text()
                       
 let $nlj250year := cts:search(/,
                  cts:and-query((
                       cts:directory-query('/LegalCompass/relational-data/surveys/NLJ_250/')
                       )))//nlj250:PUBLISHYEAR/text()
                       
 let $ny100year := cts:search(/,
                  cts:and-query((
                       cts:directory-query('/LegalCompass/relational-data/surveys/NY100/')
                       )))//ny100:PUBLISHYEAR/text()
                       
 let $alistyear := cts:search(/,
                  cts:and-query((
                       cts:directory-query('/LegalCompass/relational-data/surveys/ALIST/')
                       )))//alist:PUBLISHYEAR/text()
                       
 let $tx100year := cts:search(/,
                  cts:and-query((
                       cts:directory-query('/LegalCompass/relational-data/surveys/TX100/')
                       )))//tx100:PUBLISHYEAR/text()
 let $distinctYear := ($amlaw100year,$amlaw200year,$dc20year,$global100year,$legaltimesyear,$nlj250year,$ny100year,$alistyear,$tx100year)
 let $loopData := for $item in fn:distinct-values($distinctYear)
                  let $res-obj := json:object()
                  let $_ := (map:put($res-obj,'PublishYear',$item))
                  let $_ := json:array-push($res-array,$res-obj)
                  return()
 return $res-array
};

declare function firm:GetReIDByOrgID1($orgID)
{
	let $result := cts:search(/,cts:and-query(((
                   cts:directory-query('/LegalCompass/relational-data/FIRMS_ALI_XREF_RE/'),
                   cts:element-value-query(xs:QName('xref:ALI_ID'),xs:string($orgID))
                   ))))[1]//xref:RE_ID/text()
	return $result			   
};

(:--------------Comparison Tools----------------:)

declare function firm:SP_GETAMLAW200FIRMS()
{
  let $res-array := json:array()
  let $maxYear := cts:search(/,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/')
                      )))//AMLAW_200:PUBLISHYEAR/text()
  let $maxYearGlobal100 := cts:search(/,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/surveys/Global_100/')
                      )))//Global_100:PUBLISHYEAR/text()                    
  let $totalCount :=fn:count(cts:search(/,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
                        cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string(max($maxYear))),
                        cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
                      ))))                   
  let $totalCountGlobal100 :=fn:count(cts:search(/,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/surveys/Global_100/'),
                        cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string(max($maxYear))),
                        cts:not-query(cts:element-value-query(xs:QName('Global_100:RANK_BY_GROSS_REVENUE'),''))
                      ))))                   
                      
 let $result :=cts:search(/,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
                        cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string(max($maxYear))),
                        cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
                      )))
 let $resultGlobal100 :=cts:search(/,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/surveys/Global_100/'),
                        cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string(max($maxYearGlobal100))),
                        cts:not-query(cts:element-value-query(xs:QName('Global_100:RANK_BY_GROSS_REVENUE'),''))
                      )))                    
 let $loopData := for $item in $result
                       let $res-obj := json:object()
                       let $orgName := firm:getOrganizationName($item//AMLAW_200:ORGANIZATION_ID/text())
                       let $searchName := fn:replace(xs:string($orgName), "[^a-zA-Z0-9'']", "")
                       let $_ := (map:put($res-obj,'ID',$item//AMLAW_200:ORGANIZATION_ID/text()),
                                  map:put($res-obj,'Name',$orgName),
                                  map:put($res-obj,'SearchName',$searchName),
                                  map:put($res-obj,'TotalCount',$totalCount))
                       let $_ := json:array-push($res-array,$res-obj)
                       return()
                       
  let $loopData1 := for $item in $resultGlobal100
                       let $res-obj := json:object()
                       let $orgName := firm:getOrganizationName($item//Global_100:ORGANIZATION_ID/text())
                       let $searchName := fn:replace(xs:string($orgName), "[^a-zA-Z0-9'']", "")
                       let $_ := (map:put($res-obj,'ID',$item//Global_100:ORGANIZATION_ID/text()),
                                  map:put($res-obj,'Name',$orgName),
                                  map:put($res-obj,'SearchName',$searchName),
                                  map:put($res-obj,'TotalCount',$totalCountGlobal100))
                       let $_ := json:array-push($res-array,$res-obj)
                       return()
  return $res-array
};

declare function firm:getOrganizationName($orgID)
{
   let $result :=cts:search(/,
                  cts:and-query((
                    cts:directory-query('/LegalCompass/relational-data/organization/'),
                    cts:element-value-query(xs:QName('organizations:ORGANIZATION_ID'),$orgID)
                  )))[1]
   let $orgName := if($result//organizations:ALM_NAME/text() ne '') then $result//organizations:ALM_NAME/text() 
                   else $result//organizations:ORGANIZATION_NAME/text()
  return $orgName
};

declare function firm:SP_GETFIRMREVENUECHANGE($startYear,$endYear,$organizationID)
{
	let $res-array := json:array()
                      
  let $result := cts:search(/,
                  cts:and-query((
                       cts:directory-query("/LegalCompass/relational-data/organization/"),
                       cts:element-value-query(xs:QName('organizations:ORGANIZATION_ID'),fn:tokenize($organizationID,','))
                       )))
  let $loopData := for $item in $result
                       
                       let $amLaw200Year :=  cts:search(/,
                                                cts:and-query((
                                                     cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                     cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                     cts:element-range-query(xs:QName('AMLAW_200:PUBLISHYEAR'),'>=',xs:integer($startYear)),
                                                     cts:element-range-query(xs:QName('AMLAW_200:PUBLISHYEAR'),'<=',xs:integer($endYear))
                                                  )))
                      let $loopData1 := for $item1 in $amLaw200Year
                      
                      let $global100 := cts:search(/,
                                                    cts:and-query((
                                                         cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
                                                         cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                         cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),$item1//AMLAW_200:PUBLISHYEAR/text()))))
                       let $global100preYear := cts:search(/,
                                                    cts:and-query((
                                                         cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
                                                         cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                         cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string(xs:integer($item1//AMLAW_200:PUBLISHYEAR/text())-1)))))
                       let $amLaw200YearPreYear :=  cts:search(/,
                                                cts:and-query((
                                                     cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                     cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                     cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string(xs:integer($item1//AMLAW_200:PUBLISHYEAR/text())-1)))))
                                                  
                       let $grossRevenue := if($item1//AMLAW_200:GROSS_REVENUE/text() ne '') then $item1//AMLAW_200:GROSS_REVENUE/text() else $global100//Global_100:GROSS_REVENUE/text()
                       let $grossRevenuePreYear := if($amLaw200YearPreYear//AMLAW_200:GROSS_REVENUE/text() ne '') then $amLaw200YearPreYear//AMLAW_200:GROSS_REVENUE/text() else $global100preYear//Global_100:GROSS_REVENUE/text()
                       let $res-obj := json:object()
                       let $difference := $grossRevenue - $grossRevenuePreYear
                       let $changes := fn:format-number(xs:float(($difference div $grossRevenuePreYear)*100), '#,##0.00')
                       let $_ := (map:put($res-obj,'ORGANIZATION_ID',$item//organizations:ORGANIZATION_ID/text()),
                                  map:put($res-obj,'ORGANIZATION_NAME',$item//organizations:ORGANIZATION_NAME/text()),
                                  map:put($res-obj,'CHANGE',$changes),
                                  map:put($res-obj,'PUBLISHYEAR',$item1//AMLAW_200:PUBLISHYEAR/text()),
                                  map:put($res-obj,'GROSS_REVENUE',$grossRevenue),
								  map:put($res-obj,'VALUE',$grossRevenue)
                                  )
                       let $_ := json:array-push($res-array,$res-obj) 
                       return ()
                       return()
   (:------------------------ AMLAW200 Union--------------------:)  
   
   let $amlaw200data :=for $i in (xs:integer($startYear) to xs:integer($endYear))
                         let $grossrevenue :=  sum(cts:search(/,
                                                              cts:and-query((
                                                                   cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                                   cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($i))
                                                                )))//AMLAW_200:GROSS_REVENUE/text())
                         let $grossrevenuepreYear :=  sum(cts:search(/,
                                                              cts:and-query((
                                                                   cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                                   cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string(xs:integer($i)-1))
                                                               )))//AMLAW_200:GROSS_REVENUE/text())
                         let $difference := $grossrevenue - $grossrevenuepreYear
                         let $changes := fn:format-number(xs:float(($difference div $grossrevenuepreYear)*100), '#,##0.00')
                         let $res-obj := json:object()
                                     let $_ := (map:put($res-obj,'ORGANIZATION_ID',0),
                                                map:put($res-obj,'ORGANIZATION_NAME','Am Law 200'),
                                                map:put($res-obj,'CHANGE',$changes),
                                                map:put($res-obj,'PUBLISHYEAR',$i),
                                                map:put($res-obj,'GROSS_REVENUE',$grossrevenue),
												map:put($res-obj,'VALUE',$grossrevenue)
                                                )
                        let $_ := json:array-push($res-array,$res-obj) 
                        return()
                        
    (:------------------------ GLOBAL_100 Union--------------------:)  
   
   let $global100data :=for $i in (xs:integer($startYear) to xs:integer($endYear))
                         let $grossrevenue :=  sum(cts:search(/,
                                                              cts:and-query((
                                                                   cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
                                                                   cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($i))
                                                                )))//Global_100:GROSS_REVENUE/text())
                         let $grossrevenuepreYear :=  sum(cts:search(/,
                                                              cts:and-query((
                                                                   cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
                                                                   cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string(xs:integer($i)-1))
                                                                )))//Global_100:GROSS_REVENUE/text())
                         let $difference := $grossrevenue - $grossrevenuepreYear
                         let $changes := fn:format-number(xs:float(($difference div $grossrevenuepreYear)*100), '#,##0.00')
                         let $res-obj := json:object()
                                     let $_ := (map:put($res-obj,'ORGANIZATION_ID',0),
                                                map:put($res-obj,'ORGANIZATION_NAME','Global 100'),
                                                map:put($res-obj,'CHANGE',$changes),
                                                map:put($res-obj,'PUBLISHYEAR',$i),
                                                map:put($res-obj,'GROSS_REVENUE',$grossrevenue),
												map:put($res-obj,'VALUE',$grossrevenue)
                                                )
                        let $_ := json:array-push($res-array,$res-obj) 
                        return()
   return $res-array     
                  

};

declare function firm:SP_GETFIRMRPLCHANGE($startYear,$endYear,$organizationID)
{
  let $res-array := json:array()
                      
  let $result := cts:search(/,
                  cts:and-query((
                       cts:directory-query("/LegalCompass/relational-data/organization/"),
                       cts:element-value-query(xs:QName('organizations:ORGANIZATION_ID'),fn:tokenize($organizationID,','))
                       )))
  let $loopData := for $item in $result
                       
                       let $amLaw200Year :=  cts:search(/,
                                                cts:and-query((
                                                     cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                     cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                     cts:element-range-query(xs:QName('AMLAW_200:PUBLISHYEAR'),'>=',xs:integer($startYear)),
                                                     cts:element-range-query(xs:QName('AMLAW_200:PUBLISHYEAR'),'<=',xs:integer($endYear))
                                                  )))
                      let $loopData1 := for $item1 in $amLaw200Year
                      
                      let $global100 := cts:search(/,
                                                    cts:and-query((
                                                         cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
                                                         cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                         cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),$item1//AMLAW_200:PUBLISHYEAR/text()))))
                       let $global100preYear := cts:search(/,
                                                    cts:and-query((
                                                         cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
                                                         cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                         cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string(xs:integer($item1//AMLAW_200:PUBLISHYEAR/text())-1)))))
                       let $amLaw200YearPreYear :=  cts:search(/,
                                                cts:and-query((
                                                     cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                     cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                     cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string(xs:integer($item1//AMLAW_200:PUBLISHYEAR/text())-1)))))
                                                  
                       let $rpl := if($item1//AMLAW_200:RPL/text() ne '') then $item1//AMLAW_200:RPL/text() else $global100//Global_100:REVENUE_PER_LAWYER/text()
                       let $rplPreYear := if($amLaw200YearPreYear//AMLAW_200:RPL/text() ne '') then $amLaw200YearPreYear//AMLAW_200:RPL/text() else $global100preYear//Global_100:REVENUE_PER_LAWYER/text()
                       let $res-obj := json:object()
                       let $difference := $rpl - $rplPreYear
                       let $changes := fn:format-number(xs:float($difference div $rplPreYear)*100, '#,##0.00')
                       let $_ := (map:put($res-obj,'ORGANIZATION_ID',$item//organizations:ORGANIZATION_ID/text()),
                                  map:put($res-obj,'ORGANIZATION_NAME',$item//organizations:ORGANIZATION_NAME/text()),
                                  map:put($res-obj,'CHANGE',$changes),
                                  map:put($res-obj,'PUBLISHYEAR',$item1//AMLAW_200:PUBLISHYEAR/text()),
                                  map:put($res-obj,'RPL',$rpl),
								  map:put($res-obj,'VALUE',$rpl)
                                  )
                       let $_ := json:array-push($res-array,$res-obj) 
                       return ()
                       return()
					   
   (:------------------------ AMLAW200 Union--------------------:)  
   
   let $amlaw200data :=for $i in (xs:integer($startYear) to xs:integer($endYear))
                         let $rpl :=  sum(cts:search(/,
                                                              cts:and-query((
                                                                   cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                                   cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($i))
                                                                )))//AMLAW_200:RPL/text())
                         let $rplpreYear :=  sum(cts:search(/,
                                                              cts:and-query((
                                                                   cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                                   cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string(xs:integer($i)-1))
                                                               )))//AMLAW_200:RPL/text())
                         let $difference := $rpl - $rplpreYear
                         let $changes := fn:format-number(xs:float($difference div $rplpreYear)*100, '#,##0.00')
                         let $res-obj := json:object()
                                     let $_ := (map:put($res-obj,'ORGANIZATION_ID',0),
                                                map:put($res-obj,'ORGANIZATION_NAME','Am Law 200'),
                                                map:put($res-obj,'CHANGE',$changes),
                                                map:put($res-obj,'PUBLISHYEAR',$i),
                                                map:put($res-obj,'RPL',$rpl),
												map:put($res-obj,'VALUE',$rpl)
                                                )
                        let $_ := json:array-push($res-array,$res-obj) 
                        return()
                        
    (:------------------------ GLOBAL_100 Union--------------------:)  
   
   let $global100data :=for $i in (xs:integer($startYear) to xs:integer($endYear))
                         let $rpl :=  sum(cts:search(/,
                                                              cts:and-query((
                                                                   cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
                                                                   cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($i))
                                                                )))//Global_100:REVENUE_PER_LAWYER/text())
                         let $rplpreYear :=  sum(cts:search(/,
                                                              cts:and-query((
                                                                   cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
                                                                   cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string(xs:integer($i)-1))
                                                                )))//Global_100:REVENUE_PER_LAWYER/text())
                         let $difference := $rpl - $rplpreYear
                         let $changes :=  fn:format-number(xs:float($difference div $rplpreYear)*100, '#,##0.00')
                         let $res-obj := json:object()
                                     let $_ := (map:put($res-obj,'ORGANIZATION_ID',0),
                                                map:put($res-obj,'ORGANIZATION_NAME','Global 100'),
                                                map:put($res-obj,'CHANGE',$changes),
                                                map:put($res-obj,'PUBLISHYEAR',$i),
                                                map:put($res-obj,'RPL',$rpl),
												map:put($res-obj,'VALUE',$rpl)
                                                )
                        let $_ := json:array-push($res-array,$res-obj) 
                        return()
   return $res-array                    

};

declare function firm:SP_FIRMCOSTPERLAWYER($startYear,$endYear,$organizationID)
{
  let $res-array := json:array()
                      
  let $result := cts:search(/,
                  cts:and-query((
                       cts:directory-query("/LegalCompass/relational-data/organization/"),
                       cts:element-value-query(xs:QName('organizations:ORGANIZATION_ID'),fn:tokenize($organizationID,','))
                       )))
  let $loopData := for $item in $result
                       
                       let $amLaw200Year :=  cts:search(/,
                                                cts:and-query((
                                                     cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                     cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                     cts:element-range-query(xs:QName('AMLAW_200:PUBLISHYEAR'),'>=',xs:integer($startYear)),
                                                     cts:element-range-query(xs:QName('AMLAW_200:PUBLISHYEAR'),'<=',xs:integer($endYear))
                                                  )))
                      let $loopData1 := for $item1 in $amLaw200Year
                      
                                                  
                       let $difference := xs:double($item1//AMLAW_200:GROSS_REVENUE/text()) - xs:double($item1//AMLAW_200:NET_OPERATING_INCOME/text())
                       let $cpl :=fn:format-number(xs:float($difference div xs:double($item1//AMLAW_200:NUM_OF_LAWYERS/text())), '#,##0.00') 
                       let $res-obj := json:object()
                      
                       let $_ := (map:put($res-obj,'ORGANIZATION_ID',$item//organizations:ORGANIZATION_ID/text()),
                                  map:put($res-obj,'ORGANIZATION_NAME',$item//organizations:ORGANIZATION_NAME/text()),
                                  map:put($res-obj,'PUBLISHYEAR',$item1//AMLAW_200:PUBLISHYEAR/text()),
                                  map:put($res-obj,'CostPerLawyer',$cpl)
                                  )
                       let $_ := json:array-push($res-array,$res-obj) 
                       return ()
                       return()
   (:------------------------ AMLAW200 Union--------------------:)  
   
   let $amlaw200data :=for $i in (xs:integer($startYear) to xs:integer($endYear))
                        let $grossRevenue :=  sum(cts:search(/,
                                                              cts:and-query((
                                                                   cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                                   cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($i))
                                                                )))//AMLAW_200:GROSS_REVENUE/text())
                        let $netIncome :=  sum(cts:search(/,
                                                              cts:and-query((
                                                                   cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                                   cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($i))
                                                                )))//AMLAW_200:NET_OPERATING_INCOME/text())
                        let $noofLawyers :=  sum(cts:search(/,
                                                              cts:and-query((
                                                                   cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                                   cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($i))
                                                                )))//AMLAW_200:NUM_OF_LAWYERS/text())       
                                                                
                        let $difference := $grossRevenue - $netIncome
                        let $cpl :=fn:format-number(xs:float(( $difference div $noofLawyers)), '#,##0.00')
                        let $res-obj := json:object()
                                     let $_ := (map:put($res-obj,'ORGANIZATION_ID',0),
                                                map:put($res-obj,'ORGANIZATION_NAME','Am Law 200'),
                                                map:put($res-obj,'PUBLISHYEAR',$i),
                                                map:put($res-obj,'CostPerLawyer',$cpl)
                                                )
                        let $_ := json:array-push($res-array,$res-obj) 
                        return()
                        
   
   return $res-array                    

};

declare function firm:SP_FIRMPROFITPERPARTNER($startYear,$endYear,$organizationID)
{
  let $res-array := json:array()
                      
  let $result := cts:search(/,
                  cts:and-query((
                       cts:directory-query("/LegalCompass/relational-data/organization/"),
                       cts:element-value-query(xs:QName('organizations:ORGANIZATION_ID'),fn:tokenize($organizationID,','))
                       )))
  let $loopData := for $item in $result
                       
                       let $amLaw200Year :=  cts:search(/,
                                                cts:and-query((
                                                     cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                     cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                     cts:element-range-query(xs:QName('AMLAW_200:PUBLISHYEAR'),'>=',xs:integer($startYear)),
                                                     cts:element-range-query(xs:QName('AMLAW_200:PUBLISHYEAR'),'<=',xs:integer($endYear))
                                                  )))
                      let $loopData1 := for $item1 in $amLaw200Year
                      
                      let $global100 := cts:search(/,
                                                    cts:and-query((
                                                         cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
                                                         cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                         cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),$item1//AMLAW_200:PUBLISHYEAR/text()))))
                       
                       let $costperlawyer := if($item1//AMLAW_200:PPP/text() ne '') then $item1//AMLAW_200:PPP/text() else $global100//Global_100:PPP/text()
                       let $CPL := fn:format-number(xs:float($costperlawyer), '0.00')
                       let $res-obj := json:object()
                       let $_ := (map:put($res-obj,'ORGANIZATION_ID',$item//organizations:ORGANIZATION_ID/text()),
                                  map:put($res-obj,'ORGANIZATION_NAME',$item//organizations:ORGANIZATION_NAME/text()),
                                  map:put($res-obj,'PUBLISHYEAR',$item1//AMLAW_200:PUBLISHYEAR/text()),
                                  map:put($res-obj,'COSTPERLAWYER',$CPL)
                                  )
                       let $_ := json:array-push($res-array,$res-obj) 
                       return ()
                       return()
   (:------------------------ AMLAW200 Union--------------------:)  
   
   let $amlaw200data :=for $i in (xs:integer($startYear) to xs:integer($endYear))
                         let $result :=  avg(cts:search(/,
                                                              cts:and-query((
                                                                   cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                                   cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($i))
                                                                )))//AMLAW_200:PPP/text())
                         let $CPL := fn:format-number(xs:float($result), '0.00')
                         let $res-obj := json:object()
                                     let $_ := (map:put($res-obj,'ORGANIZATION_ID',0),
                                                map:put($res-obj,'ORGANIZATION_NAME','Am Law 200'),
                                                map:put($res-obj,'PUBLISHYEAR',$i),
                                                map:put($res-obj,'COSTPERLAWYER',$CPL)
                                                )
                        let $_ := json:array-push($res-array,$res-obj) 
                        return()
                        
    (:------------------------ GLOBAL_100 Union--------------------:)  
   
   let $global100data :=for $i in (xs:integer($startYear) to xs:integer($endYear))
                         let $result :=  avg(cts:search(/,
                                                              cts:and-query((
                                                                   cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
                                                                   cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($i))
                                                                )))//Global_100:PPP/text())
                         let $CPL := fn:format-number(xs:float($result), '0.00')
                         let $res-obj := json:object()
                                     let $_ := (map:put($res-obj,'ORGANIZATION_ID',0),
                                                map:put($res-obj,'ORGANIZATION_NAME','Global 100'),
                                                map:put($res-obj,'PUBLISHYEAR',$i),
                                                map:put($res-obj,'COSTPERLAWYER',$CPL)
                                                )
                        let $_ := json:array-push($res-array,$res-obj) 
                        return()
   return $res-array                    

};

declare function firm:SP_FIRMLGBTAttorneys($startYear,$endYear,$organizationID)
{
  let $res-array := json:array()
                      
  let $result := cts:search(/,
                  cts:and-query((
                       cts:directory-query("/LegalCompass/relational-data/organization/"),
                       cts:element-value-query(xs:QName('organizations:ORGANIZATION_ID'),fn:tokenize($organizationID,','))
                       )))
  let $loopData := for $item in $result
                       
                       let $diversitySC := cts:search(/,
                                            cts:and-query((
                                                 cts:directory-query("/LegalCompass/relational-data/surveys/NLJ_LGBT/"),
                                                 cts:element-value-query(xs:QName('nljlgbt:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                 cts:element-range-query(xs:QName('nljlgbt:PUBLISHYEAR'),'>=',xs:integer($startYear)),
                                                 cts:element-range-query(xs:QName('nljlgbt:PUBLISHYEAR'),'<=',xs:integer($endYear))
                                                 )))  
                                                 
                      let $loopData1 := for $item1 in $diversitySC
                           let $res-obj := json:object()
                           let $margin :=fn:format-number(xs:float(xs:double($item1//nljlgbt:PERCENT_LGBT_ATTORNEYS/text()) * 100), '#,##0.00')
                           let $_ := (map:put($res-obj,'ORGANIZATION_ID',$item//organizations:ORGANIZATION_ID/text()),
                                      map:put($res-obj,'ORGANIZATION_NAME',$item//organizations:ORGANIZATION_NAME/text()),
                                      map:put($res-obj,'PUBLISHYEAR',$item1//nljlgbt:PUBLISHYEAR/text()),
                                      map:put($res-obj,'MARGIN',$margin)
                                      )
                           let $_ := json:array-push($res-array,$res-obj) 
                           return ()
                           return ()
                           
   (:------------------------ AMLAW200 Union--------------------:)  
   let $orgIDs := fn:tokenize(firm:getOrganizationIDByAmLaw(),',')
   let $orgIDsByGlobal100 := fn:tokenize(firm:getOrganizationIDByGlobal100(),',')
   let $amlaw200data :=  for $i in (xs:integer($startYear) to xs:integer($endYear))
                         
                         let $result :=avg(cts:search(/,
                                                cts:and-query((
                                                     cts:directory-query("/LegalCompass/relational-data/surveys/NLJ_LGBT/"),
                                                     cts:element-value-query(xs:QName('nljlgbt:ORGANIZATION_ID'),$orgIDs),
                                                     cts:element-value-query(xs:QName('nljlgbt:PUBLISHYEAR'),xs:string($i)),
													 cts:not-query(cts:element-value-query(xs:QName('nljlgbt:PERCENT_LGBT_ATTORNEYS'),('','0')))
                                                     )))//nljlgbt:PERCENT_LGBT_ATTORNEYS/text())
                        let $margin :=fn:format-number(xs:float($result * 100), '#,##0.00')
                        let $res-obj := json:object()
                                     let $_ := (map:put($res-obj,'ORGANIZATION_ID',0),
                                                map:put($res-obj,'ORGANIZATION_NAME','Am Law 200'),
                                                map:put($res-obj,'PUBLISHYEAR',$i),
                                                map:put($res-obj,'MARGIN',$margin)
                                                )
                        let $_ := if($margin ne 'NaN') then json:array-push($res-array,$res-obj) else()
                        return()
    
    (:------------------------ GLOBAL100 Union--------------------:)  
   
   let $global100data :=  for $i in (xs:integer($startYear) to xs:integer($endYear))
                         
                         let $result :=avg(cts:search(/,
                                                cts:and-query((
                                                     cts:directory-query("/LegalCompass/relational-data/surveys/NLJ_LGBT/"),
                                                     cts:element-value-query(xs:QName('nljlgbt:ORGANIZATION_ID'),$orgIDsByGlobal100),
                                                     cts:element-value-query(xs:QName('nljlgbt:PUBLISHYEAR'),xs:string($i)),
													 cts:not-query(cts:element-value-query(xs:QName('nljlgbt:PERCENT_LGBT_ATTORNEYS'),('','0')))
                                                     )))//nljlgbt:PERCENT_LGBT_ATTORNEYS/text())
                        let $margin :=fn:format-number(xs:float($result * 100), '#,##0.00')
                        let $res-obj := json:object()
                                     let $_ := (map:put($res-obj,'ORGANIZATION_ID',0),
                                                map:put($res-obj,'ORGANIZATION_NAME','Global 100'),
                                                map:put($res-obj,'PUBLISHYEAR',$i),
                                                map:put($res-obj,'MARGIN',$margin)
                                                )
                        let $_ := if($margin ne 'NaN') then json:array-push($res-array,$res-obj) else()
                        return()
    
   return $res-array                    

};


declare function firm:SP_FIRMFemaleAttorneys($startYear,$endYear,$organizationID)
{
  let $res-array := json:array()
                      
  let $result := cts:search(/,
                  cts:and-query((
                       cts:directory-query("/LegalCompass/relational-data/organization/"),
                       cts:element-value-query(xs:QName('organizations:ORGANIZATION_ID'),fn:tokenize($organizationID,','))
                       )))
  let $loopData := for $item in $result
                       
                       let $diversitySC := cts:search(/,
                                            cts:and-query((
                                                 cts:directory-query("/LegalCompass/relational-data/surveys/FEMALE_SCORECARD/"),
                                                 cts:element-value-query(xs:QName('FEMALE_SCORECARD:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                 cts:element-range-query(xs:QName('FEMALE_SCORECARD:PUBLISHYEAR'),'>=',xs:integer($startYear)),
                                                 cts:element-range-query(xs:QName('FEMALE_SCORECARD:PUBLISHYEAR'),'<=',xs:integer($endYear))
                                                 )))  
                                                 
                      let $loopData1 := for $item1 in $diversitySC
                           let $res-obj := json:object()
                           let $margin :=fn:format-number(xs:float(xs:double($item1//FEMALE_SCORECARD:PCT_FEMALE_ATTORNEYS/text()) * 100), '#,##0.00')
                           let $_ := (map:put($res-obj,'ORGANIZATION_ID',$item//organizations:ORGANIZATION_ID/text()),
                                      map:put($res-obj,'ORGANIZATION_NAME',$item//organizations:ORGANIZATION_NAME/text()),
                                      map:put($res-obj,'PUBLISHYEAR',$item1//FEMALE_SCORECARD:PUBLISHYEAR/text()),
                                      map:put($res-obj,'MARGIN',$margin)
                                      )
                           let $_ := json:array-push($res-array,$res-obj) 
                           return ()
                           return()
                           
   (:------------------------ AMLAW200 Union--------------------:)  
   let $orgIDs := fn:tokenize(firm:getOrganizationIDByAmLaw(),',')
   let $orgIDsByGlobal100 := fn:tokenize(firm:getOrganizationIDByGlobal100(),',')
   let $amlaw200data :=  for $i in (xs:integer($startYear) to xs:integer($endYear))
                         
                         let $result :=avg(cts:search(/,
                                                cts:and-query((
                                                     cts:directory-query("/LegalCompass/relational-data/surveys/FEMALE_SCORECARD/"),
                                                     cts:element-value-query(xs:QName('FEMALE_SCORECARD:ORGANIZATION_ID'),$orgIDs),
                                                     cts:element-value-query(xs:QName('FEMALE_SCORECARD:PUBLISHYEAR'),xs:string($i))
                                                     )))//FEMALE_SCORECARD:PCT_FEMALE_ATTORNEYS/text())
                        let $margin :=fn:format-number(xs:float($result * 100), '#,##0.00')
                        let $res-obj := json:object()
                                     let $_ := (map:put($res-obj,'ORGANIZATION_ID',0),
                                                map:put($res-obj,'ORGANIZATION_NAME','Am Law 200'),
                                                map:put($res-obj,'PUBLISHYEAR',$i),
                                                map:put($res-obj,'MARGIN',$margin)
                                                )
                        let $_ := json:array-push($res-array,$res-obj) 
                        return()
    
    (:------------------------ GLOBAL100 Union--------------------:)  
   
   let $global100data :=  for $i in (xs:integer($startYear) to xs:integer($endYear))
                         
                         let $result :=avg(cts:search(/,
                                                cts:and-query((
                                                     cts:directory-query("/LegalCompass/relational-data/surveys/FEMALE_SCORECARD/"),
                                                     cts:element-value-query(xs:QName('FEMALE_SCORECARD:ORGANIZATION_ID'),$orgIDsByGlobal100),
                                                     cts:element-value-query(xs:QName('FEMALE_SCORECARD:PUBLISHYEAR'),xs:string($i))
                                                     )))//FEMALE_SCORECARD:PCT_FEMALE_ATTORNEYS/text())
                        let $margin :=fn:format-number(xs:float($result * 100), '#,##0.00')
                        let $res-obj := json:object()
                                     let $_ := (map:put($res-obj,'ORGANIZATION_ID',0),
                                                map:put($res-obj,'ORGANIZATION_NAME','Global 100'),
                                                map:put($res-obj,'PUBLISHYEAR',$i),
                                                map:put($res-obj,'MARGIN',$margin)
                                                )
                        let $_ := json:array-push($res-array,$res-obj) 
                        return()
    
   return $res-array                    

};



declare function firm:getOrganizationIDByAmLaw()
{
  let $maxYear := cts:search(/,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/')
                      )))//AMLAW_200:PUBLISHYEAR/text()
 let $result := fn:string-join(fn:distinct-values(cts:search(/,
                             cts:and-query((
                                 cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                 cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string(max($maxYear)))
                                 )))//AMLAW_200:ORGANIZATION_ID/text()),',')
  return $result                                
};

declare function firm:getOrganizationIDByGlobal100()
{
  let $maxYear := cts:search(/,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/surveys/Global_100/')
                      )))//Global_100:PUBLISHYEAR/text()
                     
 let $result := fn:string-join(fn:distinct-values(cts:search(/,
                             cts:and-query((
                                 cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
                                 cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string(max($maxYear)))
                                 )))//Global_100:ORGANIZATION_ID/text()),',')
  return $result                                
};


declare function firm:SP_GETFIRMLEVERAGE($startYear,$endYear,$organizationID)
{
  let $res-array := json:array()
                      
  let $result := cts:search(/,
                  cts:and-query((
                       cts:directory-query("/LegalCompass/relational-data/organization/"),
                       cts:element-value-query(xs:QName('organizations:ORGANIZATION_ID'),fn:tokenize($organizationID,','))
                       )))
  let $loopData := for $item in $result
                       
                       let $amLaw200Year :=  cts:search(/,
                                                cts:and-query((
                                                     cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                     cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                     cts:element-range-query(xs:QName('AMLAW_200:PUBLISHYEAR'),'>=',xs:integer($startYear)),
                                                     cts:element-range-query(xs:QName('AMLAW_200:PUBLISHYEAR'),'<=',xs:integer($endYear))
                                                  )))
                      let $loopData1 := for $item1 in $amLaw200Year
                      
                       let $amLaw200YearPreYear :=  cts:search(/,
                                                cts:and-query((
                                                     cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                     cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                     cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string(xs:integer($item1//AMLAW_200:PUBLISHYEAR/text())-1)))))
                        let $global100 :=  cts:search(/,
                                                cts:and-query((
                                                     cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
                                                     cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                     cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string(xs:integer($item1//AMLAW_200:PUBLISHYEAR/text()))))))
													 
						let $global100PreYear :=  cts:search(/,
                                                      cts:and-query((
                                                       cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
                                                        cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                     cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string(xs:integer($item1//AMLAW_200:PUBLISHYEAR/text())-1)))))
                       let $leverage :=if($item1//AMLAW_200:LEVERAGE/text() ne '') then xs:double($item1//AMLAW_200:LEVERAGE/text()) else (xs:double($global100//Global_100:NUM_LAWYERS/text()) - xs:double($global100//Global_100:NUM_EQUITY_PARTNERS/text())) div xs:double($global100//Global_100:NUM_EQUITY_PARTNERS/text())
					   
                       let $leveragePreYear := if($amLaw200YearPreYear//AMLAW_200:LEVERAGE/text() ne '') then xs:double($amLaw200YearPreYear//AMLAW_200:LEVERAGE/text()) else (xs:double($global100PreYear//Global_100:NUM_LAWYERS/text()) - xs:double($global100PreYear//Global_100:NUM_EQUITY_PARTNERS/text())) div xs:double($global100PreYear//Global_100:NUM_EQUITY_PARTNERS/text())
					   
                       let $difference := fn:round($leverage) - fn:round($leveragePreYear)
                       let $changes := fn:format-number(xs:float(($difference div $leveragePreYear)*100), '#,##0.00')
                       let $res-obj := json:object()
                      
                       let $_ := (map:put($res-obj,'ORGANIZATION_ID',$item//organizations:ORGANIZATION_ID/text()),
                                  map:put($res-obj,'ORGANIZATION_NAME',$item//organizations:ORGANIZATION_NAME/text()),
                                  map:put($res-obj,'PUBLISHYEAR',$item1//AMLAW_200:PUBLISHYEAR/text()),
                                  map:put($res-obj,'CHANGE',$changes)
                                  )
                       let $_ := json:array-push($res-array,$res-obj) 
                       return ()
                       return()
   (:------------------------ AMLAW200 Union--------------------:)  
   
   let $amlaw200data :=for $i in (xs:integer($startYear) to xs:integer($endYear))
                        let $leverage :=  sum(cts:search(/,
                                                              cts:and-query((
                                                                   cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                                   cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($i))
                                                                )))//AMLAW_200:LEVERAGE/text())
                        let $leveragePreYear :=  sum(cts:search(/,
                                                              cts:and-query((
                                                                   cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                                   cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string(xs:integer($i)-1))
                                                                )))//AMLAW_200:LEVERAGE/text())
                          
                         
                        let $difference := $leverage - $leveragePreYear
                        let $changes := fn:format-number(xs:float(($difference div $leveragePreYear)*100), '#,##0.00')
                        let $res-obj := json:object()
                                     let $_ := (map:put($res-obj,'ORGANIZATION_ID',0),
                                                map:put($res-obj,'ORGANIZATION_NAME','Am Law 200'),
                                                map:put($res-obj,'PUBLISHYEAR',$i),
                                                map:put($res-obj,'CHANGE',$changes)
                                                )
                        let $_ := json:array-push($res-array,$res-obj) 
                        return()
	
	(:------------------------ GLOBAL 100 Union--------------------:)  
   
   let $global100data :=for $i in (xs:integer($startYear) to xs:integer($endYear))
   
                        let $numberOfLawyers :=  sum(cts:search(/,
                                                              cts:and-query((
                                                                   cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
                                                                   cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($i))
                                                                )))//Global_100:NUM_LAWYERS/text())
                        let $nep :=  sum(cts:search(/,
                                                              cts:and-query((
                                                                   cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
                                                                   cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($i))
                                                                )))//Global_100:NUM_EQUITY_PARTNERS/text())
                          
                         let $numberOfLawyersPreYear :=  sum(cts:search(/,
                                                              cts:and-query((
                                                                   cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
                                                                   cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string(xs:integer($i)-1))
                                                                )))//Global_100:NUM_LAWYERS/text())
                        let $nepPreYear :=  sum(cts:search(/,
                                                              cts:and-query((
                                                                   cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
                                                                   cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string(xs:integer($i)-1))
                                                                )))//Global_100:NUM_EQUITY_PARTNERS/text())
                          
						
						let $leverage := ($numberOfLawyers - $nep) div $nep
						let $leveragePreYear := ($numberOfLawyersPreYear - $nepPreYear) div $nepPreYear
						
                        let $margin :=(($leverage - $leveragePreYear) div $leveragePreYear) * 100
                        let $res-obj := json:object()
                                     let $_ := (map:put($res-obj,'ORGANIZATION_ID',0),
                                                map:put($res-obj,'ORGANIZATION_NAME','Global 100'),
                                                map:put($res-obj,'PUBLISHYEAR',$i),
                                                map:put($res-obj,'CHANGE',$margin)
                                                )
                        let $_ := json:array-push($res-array,$res-obj) 
                        return()
                        
   
   return $res-array                    

};

declare function firm:GetFirmProfitMargin($startYear,$endYear,$organizationID)
{
  let $res-array := json:array()
                      
  let $result := cts:search(/,
                  cts:and-query((
                       cts:directory-query("/LegalCompass/relational-data/organization/"),
                       cts:element-value-query(xs:QName('organizations:ORGANIZATION_ID'),fn:tokenize($organizationID,','))
                       )))
  let $loopData := for $item in $result
                       
                       let $amLaw200Year :=  cts:search(/,
                                                cts:and-query((
                                                     cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                     cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                     cts:element-range-query(xs:QName('AMLAW_200:PUBLISHYEAR'),'>=',xs:integer($startYear)),
                                                     cts:element-range-query(xs:QName('AMLAW_200:PUBLISHYEAR'),'<=',xs:integer($endYear))
                                                  )))
                       let $loopData1 := for $item1 in $amLaw200Year
					   
					   let $global100 := cts:search(/,
                                                    cts:and-query((
                                                         cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
                                                         cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                         cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),$item1//AMLAW_200:PUBLISHYEAR/text()))))
                                                  
                       let $margin := if($item1//AMLAW_200:GROSS_REVENUE/text() ne '') then (xs:double($item1//AMLAW_200:NET_OPERATING_INCOME/text()) div xs:double($item1//			        AMLAW_200:GROSS_REVENUE/text())) * 100 
									  else ((xs:double($global100//Global_100:PPP/text()) * xs:double($item1//AMLAW_200:NUM_EQUITY_PARTNERS/text())) div xs:double($global100//Global_100:GROSS_REVENUE/text())) * 100
									  
                       let $margin1 :=fn:round($margin)
                       let $res-obj := json:object()
                      
                       let $_ := (map:put($res-obj,'ORGANIZATION_ID',$item//organizations:ORGANIZATION_ID/text()),
                                  map:put($res-obj,'ORGANIZATION_NAME',$item//organizations:ORGANIZATION_NAME/text()),
                                  map:put($res-obj,'PUBLISHYEAR',$item1//AMLAW_200:PUBLISHYEAR/text()),
                                  map:put($res-obj,'Margin',$margin1)
                                  )
                       let $_ := json:array-push($res-array,$res-obj) 
                       return ()
                       return()
					   
   (:------------------------ AMLAW200 Union--------------------:)  
   
   let $amlaw200data :=for $i in (xs:integer($startYear) to xs:integer($endYear))
                        let $grossRevenue :=  sum(cts:search(/,
                                                              cts:and-query((
                                                                   cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                                   cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($i))
                                                                )))//AMLAW_200:GROSS_REVENUE/text())
                        let $netIncome :=  sum(cts:search(/,
                                                              cts:and-query((
                                                                   cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                                   cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($i))
                                                                )))//AMLAW_200:NET_OPERATING_INCOME/text())
                          
                         
                        let $margin :=fn:round(($netIncome div $grossRevenue)*100)
                        let $res-obj := json:object()
                                     let $_ := (map:put($res-obj,'ORGANIZATION_ID',0),
                                                map:put($res-obj,'ORGANIZATION_NAME','Am Law 200'),
                                                map:put($res-obj,'PUBLISHYEAR',$i),
                                                map:put($res-obj,'Margin',$margin)
                                                )
                        let $_ := json:array-push($res-array,$res-obj) 
                        return()
						
	(:------------------------ GLOBAL 100 Union--------------------:)  
   
   let $global100data :=for $i in (xs:integer($startYear) to xs:integer($endYear))
   
                        let $ppp :=  sum(cts:search(/,
                                                              cts:and-query((
                                                                   cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
                                                                   cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($i))
                                                                )))//Global_100:PPP/text())
                        let $nep :=  sum(cts:search(/,
                                                              cts:and-query((
                                                                   cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
                                                                   cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($i))
                                                                )))//Global_100:NUM_EQUITY_PARTNERS/text())
                          
                         let $grossRevenue :=  sum(cts:search(/,
                                                              cts:and-query((
                                                                   cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
                                                                   cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($i))
                                                                )))//Global_100:GROSS_REVENUE/text())
																
                        let $margin :=fn:round(($ppp * $nep) div $grossRevenue)
                        let $res-obj := json:object()
                                     let $_ := (map:put($res-obj,'ORGANIZATION_ID',0),
                                                map:put($res-obj,'ORGANIZATION_NAME','Global 100'),
                                                map:put($res-obj,'PUBLISHYEAR',$i),
                                                map:put($res-obj,'Margin',$margin)
                                                )
                        let $_ := json:array-push($res-array,$res-obj) 
                        return()
                        
   
   return $res-array                    

};


(:-------------- Graphing ---------------:)

declare function firm:getProfitmargin($organizationIDs,$year)
{
  for $item in fn:tokenize($organizationIDs,',')
  let $data := if(cts:search(/,
                    cts:and-query((
                    cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
                    cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item)
                   ,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year)),
                    cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
                    )))//AMLAW_200:PROFIT_MARGIN/text() ne '') then cts:search(/,
                                    cts:and-query((
                                    cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
                                    cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item)
                                   ,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year)),
                                    cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
                                    )))//AMLAW_200:PROFIT_MARGIN/text() else (((cts:search(/,
                                            cts:and-query((
                                            cts:directory-query('/LegalCompass/relational-data/surveys/Global_100/'),
                                            cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$item),
                                            cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($year)),
                                            cts:not-query(cts:element-value-query(xs:QName('Global_100:RANK_BY_GROSS_REVENUE'),''))
                                            )))//Global_100:PPP/text()) * (cts:search(/,
                                            cts:and-query((
                                            cts:directory-query('/LegalCompass/relational-data/surveys/Global_100/'),
                                            cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$item),
                                            cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($year)),
                                            cts:not-query(cts:element-value-query(xs:QName('Global_100:RANK_BY_GROSS_REVENUE'),''))
                                            )))//Global_100:NUM_EQUITY_PARTNERS/text())) div (cts:search(/,
														cts:and-query((
														cts:directory-query('/LegalCompass/relational-data/surveys/Global_100/'),
														cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$item),
														cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($year)),
														cts:not-query(cts:element-value-query(xs:QName('Global_100:RANK_BY_GROSS_REVENUE'),''))
														)))//Global_100:GROSS_REVENUE/text())) * 100
                                            
                                            return $data
                                            
  };

  declare function firm:getPPP($organizationIDs,$year)
{

  for $item in fn:tokenize($organizationIDs,',')
  let $data := if(cts:search(/,
                    cts:and-query((
                    cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
                    cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item)
                   ,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year))
                    )))[1]//AMLAW_200:PPP/text() ne '') then cts:search(/,
                                    cts:and-query((
                                    cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
                                    cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item)
                                   ,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year))
                                    )))[1]//AMLAW_200:PPP/text() else cts:search(/,
                                            cts:and-query((
                                            cts:directory-query('/LegalCompass/relational-data/surveys/Global_100/'),
                                            cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$item),
                                            cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($year))
                                            )))[1]//Global_100:PPP/text()
                                            
    return $data
                                            
  };
  
declare function firm:getRPL($organizationIDs,$year)
{
  for $item in fn:tokenize($organizationIDs,',')
  let $data := if(cts:search(/,
                    cts:and-query((
                    cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
                    cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item)
                   ,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year)),
					cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
                    )))[1]//AMLAW_200:RPL/text() ne '') then cts:search(/,
                                    cts:and-query((
                                    cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
                                    cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item)
                                   ,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year)),
									cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
                                    )))[1]//AMLAW_200:RPL/text() else cts:search(/,
                                            cts:and-query((
                                            cts:directory-query('/LegalCompass/relational-data/surveys/Global_100/'),
                                            cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$item),
                                            cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($year)),
											cts:not-query(cts:element-value-query(xs:QName('Global_100:RANK_BY_GROSS_REVENUE'),''))
                                            )))[1]//Global_100:REVENUE_PER_LAWYER/text()
                                            
                                            return $data
                                            
  };
  
declare function firm:getCPL($organizationIDs,$year)
{
  for $item in fn:tokenize($organizationIDs,',')
		  let $grossRevenue := if(cts:search(/,
							cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
							cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item)
						   ,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year))(:,
							cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),'')):)
							)))[1]//AMLAW_200:GROSS_REVENUE/text() ne '') then cts:search(/,
											cts:and-query((
											cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
											cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item)
										   ,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year))(:,
											cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),'')):)
											)))[1]//AMLAW_200:GROSS_REVENUE/text() else cts:search(/,
													cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/surveys/Global_100/'),
													cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$item),
													cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($year))(:,
													cts:not-query(cts:element-value-query(xs:QName('Global_100:RANK_BY_GROSS_REVENUE'),'')):)
													)))[1]//Global_100:GROSS_REVENUE/text()
		  let $netIncome := cts:search(/,
								cts:and-query((
								cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
								cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item)
							   ,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year))(:,
								cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),'')):)
								)))[1]//AMLAW_200:NET_OPERATING_INCOME/text() 
								
		   let $noOfLawyers := if(cts:search(/,
									cts:and-query((
									cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
									cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item)
								   ,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year))(:,
									cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),'')):)
									)))[1]//AMLAW_200:NUM_OF_LAWYERS/text() ne '') then cts:search(/,
													cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
													cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item)
												   ,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year))(:,
													cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),'')):)
													)))[1]//AMLAW_200:NUM_OF_LAWYERS/text() else cts:search(/,
															cts:and-query((
															cts:directory-query('/LegalCompass/relational-data/surveys/Global_100/'),
															cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$item),
															cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($year))(:,
															cts:not-query(cts:element-value-query(xs:QName('Global_100:RANK_BY_GROSS_REVENUE'),'')):)
															)))[1]//Global_100:NUM_LAWYERS/text()
		  let $grossRevenue := if($grossRevenue ne '') then $grossRevenue else 0
		  
		  let $noOfLawyers := if($noOfLawyers ne '') then $noOfLawyers else 0
		  (:let $netIncome := if($netIncome ne '') then $netIncome else 0:)
		  let $result := (xs:integer($grossRevenue) - xs:integer($netIncome)) div xs:integer($noOfLawyers)

		  (:if($noOfLawyers ne 0) then (xs:integer($grossRevenue) - xs:integer($netIncome)) div xs:integer($noOfLawyers) else 0:)
		  return $result
                                            
  };
  
  declare function firm:getEquityPartner($organizationIDs,$year)
{
  for $item in fn:tokenize($organizationIDs,',')
		  let $nomOfEquityPartner := if(cts:search(/,
							cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
							cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item)
						   ,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year)),
							cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
							)))[1]//AMLAW_200:NUM_EQ_PARTNERS/text() ne '') then cts:search(/,
											cts:and-query((
											cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
											cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item)
										   ,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year)),
											cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
											)))[1]//AMLAW_200:NUM_EQ_PARTNERS/text() else cts:search(/,
													cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/surveys/Global_100/'),
													cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$item),
													cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($year)),
													cts:not-query(cts:element-value-query(xs:QName('Global_100:RANK_BY_GROSS_REVENUE'),''))
													)))[1]//Global_100:NUM_EQUITY_PARTNERS/text()
													
		  let $totalPartner := cts:search(/,
								cts:and-query((
								cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
								cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item)
							   ,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year)),
								cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
								)))[1]//AMLAW_200:TOTAL_PARTNERS/text() 
								
		   
		  let $equityPartner := (xs:double($nomOfEquityPartner) div xs:double($totalPartner)) * 100
		  return $equityPartner
                                            
  };
  
declare function firm:rplChange5gMed($organizationIDs,$year)
{
  for $item in fn:tokenize($organizationIDs,',')
		  let $global100GrossRevenue := cts:search(/,
                                                  cts:and-query((
                                                     cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
													   cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$item),
                                                       cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($year)),
													   cts:not-query(cts:element-value-query(xs:QName('Global_100:RANK_BY_GROSS_REVENUE'),''))
                                                    )))[1]//Global_100:GROSS_REVENUE/text()
													
		  let $global100GrossRevenuePre5Year := cts:search(/,
                                                  cts:and-query((
                                                       cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
													   cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$item),
                                                       cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($year - 4)),
													   cts:not-query(cts:element-value-query(xs:QName('Global_100:RANK_BY_GROSS_REVENUE'),''))
                                                    )))[1]//Global_100:GROSS_REVENUE/text()    
			
		  (:let $result := (xs:double($global100GrossRevenue) div xs:double($global100GrossRevenuePre5Year)) * 100:)
		  let $result := xs:double(($global100GrossRevenue div $global100GrossRevenuePre5Year))
		  return if ($result) then (math:pow($result,0.20) - 1) * 100 else ()
                                            
  };
  
  declare function firm:rplChange5Med($organizationIDs,$year)
{
  for $item in fn:tokenize($organizationIDs,',')
		  let $amLawGrossRevenue :=cts:search(/,
                                                  cts:and-query((
                                                       cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                       cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year)),
													   cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item),
													   cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
                                                    )))[1]//AMLAW_200:GROSS_REVENUE/text()
													
		  let $amLawGrossRevenuePre5Year := cts:search(/,
                                                  cts:and-query((
                                                       cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                       cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year - 4)),
													   cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item),
													   cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
                                                    )))//AMLAW_200:GROSS_REVENUE/text()
								
		  let $result := xs:double(($amLawGrossRevenue div $amLawGrossRevenuePre5Year))
		  return if ($result) then (math:pow($result,0.20) - 1) * 100 else ()
                                            
  };
 
  declare function firm:rplChange1gMed($organizationIDs,$year)
{
  for $item in fn:tokenize($organizationIDs,',')
		  let $global100GrossRevenue := cts:search(/,
                                                  cts:and-query((
                                                     cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
													   cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$item),
                                                       cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($year)),
													   cts:not-query(cts:element-value-query(xs:QName('Global_100:RANK_BY_GROSS_REVENUE'),''))
                                                    )))[1]//Global_100:GROSS_REVENUE/text()
													
		  let $global100GrossRevenuePre5Year := cts:search(/,
                                                  cts:and-query((
                                                       cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
													   cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$item),
                                                       cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($year - 1)),
													   cts:not-query(cts:element-value-query(xs:QName('Global_100:RANK_BY_GROSS_REVENUE'),''))
                                                    )))[1]//Global_100:GROSS_REVENUE/text()    
			
		  (:let $result := (xs:double($global100GrossRevenue) div xs:double($global100GrossRevenuePre5Year)) * 100:)
		  let $result := xs:double(($global100GrossRevenue div $global100GrossRevenuePre5Year))
		  return if ($result) then (math:pow($result,1) - 1) * 100 else ()
                                            
  };
  
  declare function firm:rplChange1Med($organizationIDs,$year)
{
  for $item in fn:tokenize($organizationIDs,',')
		  let $amLawGrossRevenue :=cts:search(/,
                                                  cts:and-query((
                                                       cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                       cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year)),
													   cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item),
													   cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
                                                    )))[1]//AMLAW_200:GROSS_REVENUE/text()
													
		  let $amLawGrossRevenuePre5Year := cts:search(/,
                                                  cts:and-query((
                                                       cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                       cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year - 1)),
													   cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item),
													   cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
                                                    )))//AMLAW_200:GROSS_REVENUE/text()
								
		  let $result := xs:double(($amLawGrossRevenue div $amLawGrossRevenuePre5Year))
		  return if ($result) then (math:pow($result,1) - 1) * 100 else ()
                                            
  };
  
declare function firm:MedianQuery($column1,$column2)
{
  let $organizationIDs :=(:'2503,4,106,123,78,81,36,38,48,49,56,65,3452,214,151,162,163,172,306,311,321,330,333,336,100,5920,244,269,166,232,247,272,158,165,187,85,174,250,53,152,326,1721,2106,105,15,19,92,208,188,215,264,61,145,5,69,1774,79,20,103,433,486,48980,62,147,182,273,295,299,271,257,203,204,285,183,293,221,227,2205,25,283,207,287,199,111,222,157,141,268,95,237,248,325,115,256,210,144,220,236,1781,52,14,32,35,463,112,21,3294,71,143,1830,11,240,259,167,173,153,308,318,7558,320,329,328,5149,7970,175,235,284,296,512,12,126,193,2598,13,242,1728,88,1823,6421,124,2868,90,102,312,317,50,58,1752,109,113,154,176,3541,213,218,136,186,265,3462,24,200,230,22,118,1738,313,331,499,3,55,307,1,155,8,73,171,291,1673,550,2568,29,43622,37857,39,63,93,99,298,185,206,241,297,179,107,77,267,274,277,178,197,212,279,177,233,216,140,64,280,17,276,57,75,119,290,316,332,1750,327,80,322,267,213,298,29,3452,1760,36,392,2186,2205,284,318,210,39,1721,200,463,4555,312,75,469,105,1781,316,1673,1,1815,283,3541,550,2349,516,6421,2431,1702,8002,65477,3462,6425,1774,50,319,10040,2168,2201,3884,186,2246,520,381,2486,157,1842,2457,512,1744,183,143,7953,331,43622,7975,248,273,20,222,177,3451,223,385,27687,3294,295,176,268,1777,2568,265,292,233,259,1750,266,65,100,162,214,203,24,269,78,307,294,144,123,329,12,61,197,330,287,560,274,79,250,254,22,3,325,7570,172,212,41,264,320,103,277,163,2868,1822,306,313,38,42,48,57,1738,293,2503,92,73,151,93,242,1757,328,154,10489,208,15,221,7970,19,165,279,80,450,69,433,504,8,232,1798,333,49,44683,102,77,235,230,113,141,227,236,178,220,3556,95,2301,145,11,126,55,58,336,353,71,53,171,218,257,290,166,52,4385,499,85,237,4,188,321,215,1823,453,119,299,167,134,247,216,159995,34934,173,239,90,240,204,199,107,1764,326,252,1696,271,297,308,272,153,147,291,332,118,2129,311,136,5920,1830,115,152,256,139992,6103,112,106,25,1752,48980,1833,2107,6154,206,317,296,175,1728,486,244,3523,21,187,179,182,81,193,207,338,438,416,13':)
  
  "1,22,25,30,42,57,78,100,123,151,152,153,167,173,179,227,244,247,269,280,294,310,311,321,325,504,1777,1817,1842,2225,2349,2457,2868,3523,3557,4180,6108,7953,34378,34934,37857,39264,57015,58388,67275,123005,160872,164775,164779,11,13,29,77,113,134,144,147,155,157,207,213,218,222,235,252,271,290,297,299,307,316,327,330,353,450,469,560,1732,1774,1823,2136,2201,3462,6421,7570,10996,53070,160796,164769,164778,2,14,20,21,88,90,95,112,141,177,185,210,211,220,223,250,273,289,298,433,463,1764,1781,1830,2140,2598,32770,34366,34644,34761,37738,43622,53023,63776,160873,164757,164766,164771,4,5,24,32,53,81,85,102,119,143,162,163,183,184,193,215,230,240,283,284,285,296,306,308,326,329,331,416,499,1673,1721,1728,1798,1815,2458,2717,3452,5906,6154,10489,21496,34795,53044,65477,123481,141913,8,17,35,37,38,48,55,61,63,69,75,175,206,212,232,239,242,248,257,264,268,276,279,293,318,328,336,392,453,486,516,550,1684,1702,1750,1757,1760,1833,2106,2129,2186,2205,2301,2483,3294,3451,7975,8002,10040,20039,27633,164773,41,50,52,56,71,80,93,99,101,107,136,140,165,178,188,199,200,214,228,233,241,254,265,266,275,277,291,292,322,333,381,512,1738,2246,3541,3556,4385,4849,6425,27634,27687,34379,34627,34642,53077,95132,119382,139992,141901,163674,164765,3,27,36,49,58,64,105,109,115,124,145,154,158,171,172,176,182,186,195,203,216,221,225,236,259,267,287,319,332,385,520,1696,1739,1744,1752,1822,1862,2107,2164,2168,2187,2243,2254,2955,3884,5149,6103,7558,45666,48980,160874,164767,164768,164772,12,15,19,39,60,62,65,73,79,92,103,106,111,118,126,156,166,174,187,197,204,208,237,256,272,274,295,312,313,317,320,324,338,438,2387,2431,2486,2503,2568,2606,3240,4555,5920,6641,7563,7970,20044,20054,21639,25139,44683,53003,53080,159995,160875,164770"
  
  let $femaleSCID := '123,78,151,311,321,100,244,269,247,152,227,25,325,167,173,153,2868,22,1,37857,179,280,57,330,1774,147,299,271,207,222,157,144,11,235,13,1823,6421,113,213,218,3462,307,155,29,297,77,290,316,327,250,20,433,273,141,95,210,220,1781,14,463,112,21,1830,2598,88,90,43622,298,185,177,4,81,3452,162,163,306,85,53,326,1721,215,5,285,183,283,32,143,240,308,329,284,296,193,1728,102,24,230,331,499,1673,119,38,48,336,232,2106,264,61,69,486,257,293,2205,268,248,35,3294,318,328,175,242,55,8,550,63,206,212,279,17,276,75,1750,56,214,333,165,188,199,52,71,512,50,3541,136,265,200,1738,291,93,99,241,107,277,178,233,140,80,36,49,172,158,105,145,48980,182,203,221,287,115,236,259,7558,5149,124,58,1752,109,154,176,186,3,171,267,216,64,332,2503,106,65,5920,166,272,187,174,15,19,92,208,79,103,62,295,204,111,237,256,320,7970,12,126,312,317,118,313,73,2568,39,274,197'
  
 
  
  let $orgIDs := fn:tokenize($organizationIDs,',')
  let $res-array := json:array()
  
  let $item1 := max(fn:distinct-values(cts:search(/,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/')
                      )))//AMLAW_200:PUBLISHYEAR/text()))
 
  let $maxYearGlobal100 := max(fn:distinct-values(cts:search(/,
                              cts:and-query((
                                cts:directory-query('/LegalCompass/relational-data/surveys/Global_100/')
                              )))//Global_100:PUBLISHYEAR/text()))
                              
  (:let $orgIDs := cts:search(/,
                  cts:and-query((
                       cts:directory-query("/LegalCompass/relational-data/organization/"),
                       cts:element-value-query(xs:QName('organizations:ORGANIZATION_TYPE_ID'),'1')
                       )))//organizations:ORGANIZATION_ID/text():)
                       
  (:let $amLawGrossRevenue :=cts:search(/,
                                                  cts:and-query((
                                                       cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                       cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($item1)),
													   cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$orgIDs)
                                                    )))//AMLAW_200:GROSS_REVENUE/text()
                                                    
  let $amLawGrossRevenuePre5Year := cts:search(/,
                                                  cts:and-query((
                                                       cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                       cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($item1 - 4)),
													   cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$orgIDs)
                                                    )))//AMLAW_200:GROSS_REVENUE/text()   
                                                    
                       let $amLawGrossRevenuePre1Year := cts:search(/,
                                                  cts:and-query((
                                                       cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
													   cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$orgIDs),
                                                       cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($item1 - 1))
                                                    )))//AMLAW_200:GROSS_REVENUE/text()     
                       let $global100GrossRevenue := cts:search(/,
                                                  cts:and-query((
                                                       cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
													   cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$orgIDs),
                                                       cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($maxYearGlobal100))
                                                    )))//Global_100:GROSS_REVENUE/text()
                                                    
                       let $global100GrossRevenuePre5Year := cts:search(/,
                                                  cts:and-query((
                                                       cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
													   cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$orgIDs),
                                                       cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($maxYearGlobal100 - 4))
                                                    )))//Global_100:GROSS_REVENUE/text()    
                                                    
                       let $global100GrossRevenuePre1Year :=cts:search(/,
                                                  cts:and-query((
                                                       cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
													   cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$orgIDs),
                                                       cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($maxYearGlobal100 - 1))
                                                    )))//Global_100:GROSS_REVENUE/text():)
                        
					   let $rplChangeAmLaw := firm:rplChange5Med($organizationIDs,$item1)
					   let $rplChangeGlobal := firm:rplChange5gMed($organizationIDs,$item1)
					   
					   let $rplChange1AmLaw := firm:rplChange1Med($organizationIDs,$item1)
					   let $rplChange1Global := firm:rplChange1gMed($organizationIDs,$item1)
					   
                       let $rplchange5Min :=  min($rplChangeAmLaw) 
                       let $rplchange1Min :=min($rplChange1AmLaw)
					   
                       let $rplchange5gMin :=min($rplChangeGlobal)
                       let $rplchange1gMin :=min($rplChange1Global) 
                       
                       let $rplchange5Max :=max($rplChangeAmLaw)
                       let $rplchange1Max :=max($rplChange1AmLaw)
					   
                       let $rplchange5gMax := max($rplChangeGlobal)
                       let $rplchange1gMax := max($rplChange1Global)

						
                       let $rplchange5Med := math:median($rplChangeAmLaw)
                       let $rplchange1Med :=math:median($rplChange1AmLaw) 
					   
                       let $rplchange5gMed := math:median($rplChangeGlobal) 
					   let $rplchange1gMed :=math:median($rplChange1Global)        
                       
                              
                                     (:-------- Max Year----------:)
                                             let $amLaw200 := cts:search(/,
                                                cts:and-query((
                                                     cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
													 cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$orgIDs),
                                                     cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($item1))
                                                  )))
                                                  
                                             let $diversitySC := cts:search(/,
                                                    cts:and-query((
                                                         cts:directory-query("/LegalCompass/relational-data/surveys/Diversity_Scorecard/"),
														 cts:element-value-query(xs:QName('Diversity_Scorecard:ORGANIZATION_ID'),fn:tokenize($femaleSCID,',')),
                                                         cts:element-value-query(xs:QName('Diversity_Scorecard:PUBLISHYEAR'),xs:string($item1))
                                                         )))  
                                             
                                             let $femaleSC := cts:search(/,
                                                    cts:and-query((
                                                         cts:directory-query("/LegalCompass/relational-data/surveys/FEMALE_SCORECARD/"),
														 cts:element-value-query(xs:QName('FEMALE_SCORECARD:ORGANIZATION_ID'),fn:tokenize($femaleSCID,',')),
                                                         cts:element-value-query(xs:QName('FEMALE_SCORECARD:PUBLISHYEAR'),xs:string($item1))
                                                         )))
                                            
                                            let $nlj_lgbt := cts:search(/,
                                                    cts:and-query((
                                                         cts:directory-query("/LegalCompass/relational-data/surveys/NLJ_LGBT/"),
														 cts:element-value-query(xs:QName('nljlgbt:ORGANIZATION_ID'),fn:tokenize($femaleSCID,',')),
                                                         cts:element-value-query(xs:QName('nljlgbt:PUBLISHYEAR'),xs:string($item1))
                                                         )))
                                                         
                                           let $global100 := cts:search(/,
                                                    cts:and-query((
                                                         cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
														 cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$orgIDs),
                                                         cts:not-query(cts:element-value-query(xs:QName('Global_100:RANK_BY_GROSS_REVENUE'),'')),
                                                         cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($item1))
                                                         )))
                                                         
                                           
                                          let $res-obj := json:object()
                                          (:--------- Max Year ---------------:)
                                          let $rplMed := math:median(firm:getRPL($organizationIDs,xs:string($item1)))
                                          let $rplMin := min(firm:getRPL($organizationIDs,xs:string($item1)))
                                          let $rplMax := max(firm:getRPL($organizationIDs,xs:string($item1)))
										  
                                          let $grossRevenueMin := if($amLaw200//AMLAW_200:GROSS_REVENUE/text() != '') then min($amLaw200//AMLAW_200:GROSS_REVENUE/text()) else min($global100//Global_100:GROSS_REVENUE/text())
                                          let $grossRevenueMax := if($amLaw200//AMLAW_200:GROSS_REVENUE/text() != '') then max($amLaw200//AMLAW_200:GROSS_REVENUE/text()) else max($global100//Global_100:GROSS_REVENUE/text())
										  let $grossRevenueMed := if($amLaw200//AMLAW_200:GROSS_REVENUE/text() != '') then math:median(($amLaw200//AMLAW_200:GROSS_REVENUE/text())) else math:median(($global100//Global_100:GROSS_REVENUE/text()))
										  
                                          let $numOfLawyersMin := if($amLaw200//AMLAW_200:NUM_OF_LAWYERS/text() != '') then min($amLaw200//AMLAW_200:NUM_OF_LAWYERS/text()) else min($global100//Global_100:NUM_LAWYERS/text())
                                          let $numOfLawyersMax := if($amLaw200//AMLAW_200:NUM_OF_LAWYERS/text() != '') then max($amLaw200//AMLAW_200:NUM_OF_LAWYERS/text()) else max($global100//Global_100:NUM_LAWYERS/text())
										  let $numOfLawyersMed := if($amLaw200//AMLAW_200:NUM_OF_LAWYERS/text() != '') then math:median(($amLaw200//AMLAW_200:NUM_OF_LAWYERS/text())) else math:median(($global100//Global_100:NUM_LAWYERS/text()))
										  
                                          let $profitMarginMin := min(firm:getProfitmargin($organizationIDs,xs:string($item1)))
                                                              
                                          let $profitMarginMax := max(firm:getProfitmargin($organizationIDs,xs:string($item1)))
										  
										  let $profitMarginMed := math:median(firm:getProfitmargin($organizationIDs,xs:string($item1)))
															   
                                          let $leverageMin := if($amLaw200//AMLAW_200:LEVERAGE/text() != '') then min($amLaw200//AMLAW_200:LEVERAGE/text()) 
                                                               else ((min($global100//Global_100:NUM_LAWYERS/text()) - min($global100//Global_100:NUM_EQUITY_PARTNERS/text())) div min($global100//Global_100:NUM_EQUITY_PARTNERS/text))
                                          let $leverageMax := if($amLaw200//AMLAW_200:LEVERAGE/text() != '') then max($amLaw200//AMLAW_200:LEVERAGE/text()) 
                                                               else ((max($global100//Global_100:NUM_LAWYERS/text()) - max($global100//Global_100:NUM_EQUITY_PARTNERS/text())) div max($global100//Global_100:NUM_EQUITY_PARTNERS/text))
										  let $leverageMed := if($amLaw200//AMLAW_200:LEVERAGE/text() != '') then math:median(($amLaw200//AMLAW_200:LEVERAGE/text())) 
                                                               else ((math:median(($global100//Global_100:NUM_LAWYERS/text())) - math:median(($global100//Global_100:NUM_EQUITY_PARTNERS/text()))) div math:median(($global100//Global_100:NUM_EQUITY_PARTNERS/text)))				   
															   
                                          let $pppMin := min(firm:getPPP($femaleSCID,xs:string($item1)))
                                          let $pppMax := max(firm:getPPP($femaleSCID,xs:string($item1)))
										  let $pppMed := math:median(firm:getPPP($femaleSCID,xs:string($item1)))
										  
                                          let $numEquityPartnerMin := if($amLaw200//AMLAW_200:NUM_EQ_PARTNERS/text() != '') then min($amLaw200//AMLAW_200:NUM_EQ_PARTNERS/text()) 
                                                                   else min($global100//Global_100:NUM_EQUITY_PARTNERS/text())
                                          let $numEquityPartnerMax := if($amLaw200//AMLAW_200:NUM_EQ_PARTNERS/text() != '') then max($amLaw200//AMLAW_200:NUM_EQ_PARTNERS/text()) 
                                                                   else max($global100//Global_100:NUM_EQUITY_PARTNERS/text())
										  let $numEquityPartnerMed := if($amLaw200//AMLAW_200:NUM_EQ_PARTNERS/text() != '') then math:median(($amLaw200//AMLAW_200:NUM_EQ_PARTNERS/text())) 
                                                                   else math:median(($global100//Global_100:NUM_EQUITY_PARTNERS/text()))
										   
										   
										  
										   
                                          let $cplMin := min(firm:getCPL($femaleSCID,xs:string($item1)))
                                          let $cplMax := max(firm:getCPL($femaleSCID,xs:string($item1)))
										  let $cplMed := math:median(firm:getCPL($femaleSCID,xs:string($item1)))
										  
                                          let $ppp1Min := min($amLaw200//AMLAW_200:NET_OPERATING_INCOME/text()) div min($amLaw200//AMLAW_200:TOTAL_PARTNERS/text())
                                          let $ppp1Max := max($amLaw200//AMLAW_200:NET_OPERATING_INCOME/text()) div max($amLaw200//AMLAW_200:TOTAL_PARTNERS/text())
										  let $ppp1Med := math:median(($amLaw200//AMLAW_200:NET_OPERATING_INCOME/text())) div math:median(($amLaw200//AMLAW_200:TOTAL_PARTNERS/text()))
										  
                                          let $equityPartnerMin := min(firm:getEquityPartner($organizationIDs,xs:string($item1)))
                                          let $equityPartnerMax := max(firm:getEquityPartner($organizationIDs,xs:string($item1)))
										  let $equityPartnerMed := math:median((firm:getEquityPartner($organizationIDs,xs:string($item1))))
										  
                                          let $minorityPerMin := min($diversitySC//Diversity_Scorecard:MINORITY_PERCENTAGE/text()) * 100
                                          let $minorityPerMax := max($diversitySC//Diversity_Scorecard:MINORITY_PERCENTAGE/text()) * 100
										  let $minorityPerMed := math:median(($diversitySC//Diversity_Scorecard:MINORITY_PERCENTAGE/text())) * 100
										  
                                          let $femaleAttorneyMin := min($femaleSC//FEMALE_SCORECARD:PCT_FEMALE_ATTORNEYS/text()) * 100
                                          let $femaleAttorneyMax := max($femaleSC//FEMALE_SCORECARD:PCT_FEMALE_ATTORNEYS/text()) * 100
										  let $femaleAttorneyMed := math:median(($femaleSC//FEMALE_SCORECARD:PCT_FEMALE_ATTORNEYS/text())) * 100
										  
                                          let $lgbtAttorneyMin := min($nlj_lgbt//nljlgbt:PERCENT_LGBT_ATTORNEYS/text()) * 100
                                          let $lgbtAttorneyMax := max($nlj_lgbt//nljlgbt:PERCENT_LGBT_ATTORNEYS/text()) * 100
										  let $lgbtAttorneyMed := math:median(($nlj_lgbt//nljlgbt:PERCENT_LGBT_ATTORNEYS/text())) * 100
										  
                                          let $revenueGrowth1Min := if($amLaw200//AMLAW_200:GROSS_REVENUE/text() != '') then $rplchange1Min else $rplchange1gMin
                                          let $revenueGrowth5Min := if($amLaw200//AMLAW_200:GROSS_REVENUE/text() != '') then $rplchange5Min else $rplchange5gMin
										  
                                          let $revenueGrowth1Max := if($amLaw200//AMLAW_200:GROSS_REVENUE/text() != '') then $rplchange1Max else $rplchange1gMax
                                          let $revenueGrowth5Max := if($amLaw200//AMLAW_200:GROSS_REVENUE/text() != '') then $rplchange5Max else $rplchange5gMax
                                          let $revenueGrowth1Med := if($amLaw200//AMLAW_200:GROSS_REVENUE/text() != '') then $rplchange1Med else $rplchange1gMed
                                          let $revenueGrowth5Med := if($amLaw200//AMLAW_200:GROSS_REVENUE/text() != '') then $rplchange5Med else $rplchange5gMed
                                          
	  let $MAX_VARIABLE1 := if($column1 eq 'Am Law 200 rank') then max($amLaw200//AMLAW_200:AMLAW200_RANK/text()) else
						 if($column1 eq 'Global 100 rank') then max($global100//Global_100:RANK_BY_GROSS_REVENUE/text()) else
						 if($column1 eq 'Revenue Per Lawyer') then $rplMax else
						 if($column1 eq 'Cost Per Lawyer') then $cplMax else
						 if($column1 eq 'Profit Margin') then $profitMarginMax else
						 if($column1 eq '% Turnover') then $profitMarginMax else
						 if($column1 eq 'Leverage') then $leverageMax else
						 if($column1 eq 'Profit Per Partner') then $ppp1Max else
						 if($column1 eq 'Profit Per Equity Partner') then $pppMax else
						 if($column1 eq '% of Equity Partners') then $equityPartnerMax else
						 if($column1 eq '% of Minority Attorneys') then $minorityPerMax else
						 if($column1 eq '% of Female Attorneys') then $femaleAttorneyMax else
						 if($column1 eq '% of LGBT Attorneys') then $lgbtAttorneyMax else
						 if($column1 eq 'Growth in Minority Attorneys') then max($diversitySC//Diversity_Scorecard:TOTAL_MINORITY_ATTORNEYS/text()) else
						 if($column1 eq 'Growth in Female Partners') then max($femaleSC//FEMALE_SCORECARD:FEMALE_PARTNERS/text()) else
						 if($column1 eq 'Revenue Growth (1 year)') then $revenueGrowth1Max else
						 if($column1 eq 'Revenue Growth (5 years)') then $revenueGrowth5Max else $grossRevenueMax
                                          
                                          let $MAX_VARIABLE2 := if($column2 eq 'Am Law 200 rank') then max($amLaw200//AMLAW_200:AMLAW200_RANK/text()) else
                                                             if($column2 eq 'Global 100 rank') then max($global100//Global_100:RANK_BY_GROSS_REVENUE/text()) else
                                                             if($column2 eq 'Revenue Per Lawyer') then $rplMax else
                                                             if($column2 eq 'Cost Per Lawyer') then $cplMax else
                                                             if($column2 eq 'Profit Margin') then $profitMarginMax else
                                                             if($column2 eq '% Turnover') then $profitMarginMax else
                                                             if($column2 eq 'Leverage') then $leverageMax else
                                                             if($column2 eq 'Profit Per Partner') then $ppp1Max else
                                                             if($column2 eq 'Profit Per Equity Partner') then $pppMax else
                                                             if($column2 eq '% of Equity Partners') then $equityPartnerMax else
                                                             if($column2 eq '% of Minority Attorneys') then $minorityPerMax else
                                                             if($column2 eq '% of Female Attorneys') then $femaleAttorneyMax else
                                                             if($column2 eq '% of LGBT Attorneys') then $lgbtAttorneyMax else
                                                             if($column2 eq 'Growth in Minority Attorneys') then max($diversitySC//Diversity_Scorecard:TOTAL_MINORITY_ATTORNEYS/text()) else
                                                             if($column2 eq 'Growth in Female Partners') then max($femaleSC//FEMALE_SCORECARD:FEMALE_PARTNERS/text()) else
                                                             if($column2 eq 'Revenue Growth (1 year)') then $revenueGrowth1Max else
                                                             if($column2 eq 'Revenue Growth (5 years)') then $revenueGrowth5Max else $grossRevenueMax
                                                             
                                          let $MIN_VARIABLE1 := if($column1 eq 'Am Law 200 rank') then min($amLaw200//AMLAW_200:AMLAW200_RANK/text()) else
                                                             if($column1 eq 'Global 100 rank') then min($global100//Global_100:RANK_BY_GROSS_REVENUE/text()) else
                                                             if($column1 eq 'Revenue Per Lawyer') then $rplMin else
                                                             if($column1 eq 'Cost Per Lawyer') then $cplMin else
                                                             if($column1 eq 'Profit Margin') then $profitMarginMin else
                                                             if($column1 eq '% Turnover') then $profitMarginMin else
                                                             if($column1 eq 'Leverage') then $leverageMin else
                                                             if($column1 eq 'Profit Per Partner') then $ppp1Min else
                                                             if($column1 eq 'Profit Per Equity Partner') then $pppMin else
                                                             if($column1 eq '% of Equity Partners') then $equityPartnerMin else
                                                             if($column1 eq '% of Minority Attorneys') then $minorityPerMin else
                                                             if($column1 eq '% of Female Attorneys') then $femaleAttorneyMin else
                                                             if($column1 eq '% of LGBT Attorneys') then $lgbtAttorneyMin else
                                                             if($column1 eq 'Growth in Minority Attorneys') then min($diversitySC//Diversity_Scorecard:TOTAL_MINORITY_ATTORNEYS/text()) else
                                                             if($column1 eq 'Growth in Female Partners') then min($femaleSC//FEMALE_SCORECARD:FEMALE_PARTNERS/text()) else
                                                             if($column1 eq 'Revenue Growth (1 year)') then $revenueGrowth1Min else
                                                             if($column1 eq 'Revenue Growth (5 years)') then $revenueGrowth5Min else $grossRevenueMin
                                          
                                          let $MIN_VARIABLE2 := if($column2 eq 'Am Law 200 rank') then min($amLaw200//AMLAW_200:AMLAW200_RANK/text()) else
                                                             if($column2 eq 'Global 100 rank') then min($global100//Global_100:RANK_BY_GROSS_REVENUE/text()) else
                                                             if($column2 eq 'Revenue Per Lawyer') then $rplMin else
                                                             if($column2 eq 'Cost Per Lawyer') then $cplMin else
                                                             if($column2 eq 'Profit Margin') then $profitMarginMin else
                                                             if($column2 eq '% Turnover') then $profitMarginMin else
                                                             if($column2 eq 'Leverage') then $leverageMin else
                                                             if($column2 eq 'Profit Per Partner') then $ppp1Min else
                                                             if($column2 eq 'Profit Per Equity Partner') then $pppMin else
                                                             if($column2 eq '% of Equity Partners') then $equityPartnerMin else
                                                             if($column2 eq '% of Minority Attorneys') then $minorityPerMin else
                                                             if($column2 eq '% of Female Attorneys') then $femaleAttorneyMin else
                                                             if($column2 eq '% of LGBT Attorneys') then $lgbtAttorneyMin else
                                                             if($column2 eq 'Growth in Minority Attorneys') then min($diversitySC//Diversity_Scorecard:TOTAL_MINORITY_ATTORNEYS/text()) else
                                                             if($column2 eq 'Growth in Female Partners') then min($femaleSC//FEMALE_SCORECARD:FEMALE_PARTNERS/text()) else
                                                             if($column2 eq 'Revenue Growth (1 year)') then $revenueGrowth1Min else
                                                             if($column2 eq 'Revenue Growth (5 years)') then $revenueGrowth5Min else $grossRevenueMax                   
                                         
                                           let $MEDIAN_Variable1 := if($column1 eq 'Am Law 200 rank') then math:median(($amLaw200//AMLAW_200:AMLAW200_RANK/text())) else
                                                             if($column1 eq 'Global 100 rank') then math:median(($global100//Global_100:RANK_BY_GROSS_REVENUE/text())) else
                                                             if($column1 eq 'Revenue Per Lawyer') then $rplMed else
                                                             if($column1 eq 'Cost Per Lawyer') then $cplMed else
                                                             if($column1 eq 'Profit Margin') then $profitMarginMed else
                                                             if($column1 eq '% Turnover') then $profitMarginMed else
                                                             if($column1 eq 'Leverage') then $leverageMed else
                                                             if($column1 eq 'Profit Per Partner') then $ppp1Med else
                                                             if($column1 eq 'Profit Per Equity Partner') then $pppMed else
                                                             if($column1 eq '% of Equity Partners') then $equityPartnerMed else
                                                             if($column1 eq '% of Minority Attorneys') then $minorityPerMed else
                                                             if($column1 eq '% of Female Attorneys') then $femaleAttorneyMed else
                                                             if($column1 eq '% of LGBT Attorneys') then $lgbtAttorneyMed else
                                                             if($column1 eq 'Growth in Minority Attorneys') then math:median(($diversitySC//Diversity_Scorecard:TOTAL_MINORITY_ATTORNEYS/text())) else
                                                             if($column1 eq 'Growth in Female Partners') then math:median(($femaleSC//FEMALE_SCORECARD:FEMALE_PARTNERS/text())) else
                                                             if($column1 eq 'Revenue Growth (1 year)') then $revenueGrowth1Med else
                                                             if($column1 eq 'Revenue Growth (5 years)') then $revenueGrowth5Med else $grossRevenueMed
                                          
                                          let $MEDIAN_Variable2 := if($column2 eq 'Am Law 200 rank') then math:median(($amLaw200//AMLAW_200:AMLAW200_RANK/text())) else
                                                             if($column2 eq 'Global 100 rank') then math:median(($global100//Global_100:RANK_BY_GROSS_REVENUE/text())) else
                                                             if($column2 eq 'Revenue Per Lawyer') then $rplMed else
                                                             if($column2 eq 'Cost Per Lawyer') then $cplMed else
                                                             if($column2 eq 'Profit Margin') then $profitMarginMed else
                                                             if($column2 eq '% Turnover') then $profitMarginMed else
                                                             if($column2 eq 'Leverage') then $leverageMed else
                                                             if($column2 eq 'Profit Per Partner') then $ppp1Med else
                                                             if($column2 eq 'Profit Per Equity Partner') then $pppMed else
                                                             if($column2 eq '% of Equity Partners') then $equityPartnerMed else
                                                             if($column2 eq '% of Minority Attorneys') then $minorityPerMed else
                                                             if($column2 eq '% of Female Attorneys') then $femaleAttorneyMed else
                                                             if($column2 eq '% of LGBT Attorneys') then $lgbtAttorneyMed else
                                                             if($column2 eq 'Growth in Minority Attorneys') then math:median(($diversitySC//Diversity_Scorecard:TOTAL_MINORITY_ATTORNEYS/text())) else
                                                             if($column2 eq 'Growth in Female Partners') then math:median(($femaleSC//FEMALE_SCORECARD:FEMALE_PARTNERS/text())) else
                                                             if($column2 eq 'Revenue Growth (1 year)') then $revenueGrowth1Med else
                                                             if($column2 eq 'Revenue Growth (5 years)') then $revenueGrowth5Med else $grossRevenueMed
                                                             
                                          let $_ := (map:put($res-obj,'PUBLISHYEAR',$item1),
                                                     map:put($res-obj,'Med_VARIABLE1',$MEDIAN_Variable1),
                                                     map:put($res-obj,'Med_VARIABLE2',$MEDIAN_Variable2),
                                                     map:put($res-obj,'Max_VARIABLE1',$MAX_VARIABLE1),
                                                     map:put($res-obj,'Min_VARIABLE1',$MIN_VARIABLE1),
                                                     map:put($res-obj,'Max_VARIABLE2',$MAX_VARIABLE2),
                                                     map:put($res-obj,'Min_VARIABLE2',$MIN_VARIABLE2)
                                                     )
                                       
                                        let $_ := json:array-push($res-array,$res-obj)
  return $res-array
};


declare function firm:CombinedQuery($organizationID,$column1,$column2)
{
  let $res-array := json:array()
  
  let $maxYear := fn:distinct-values(cts:search(/,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/')
                      )))//AMLAW_200:PUBLISHYEAR/text())
 
  let $maxYearGlobal100 := fn:distinct-values(cts:search(/,
                              cts:and-query((
                                cts:directory-query('/LegalCompass/relational-data/surveys/Global_100/')
                              )))//Global_100:PUBLISHYEAR/text())
  
  let $result := cts:search(/,
                  cts:and-query((
                       cts:directory-query("/LegalCompass/relational-data/organization/"),
                       cts:element-value-query(xs:QName('organizations:ORGANIZATION_ID'),fn:tokenize($organizationID,',')),
                       cts:element-value-query(xs:QName('organizations:ORGANIZATION_TYPE_ID'),'1')
                       )))
                       
  let $loopData :=for $item in $result
  
                       let $amLawGrossRevenue := sum(cts:search(/,
                                                  cts:and-query((
                                                       cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                       cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                       cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string(max($maxYear)))
                                                    )))//AMLAW_200:GROSS_REVENUE/text())
                                                    
                       let $amLawGrossRevenuePre5Year := sum(cts:search(/,
                                                  cts:and-query((
                                                       cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                       cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                       cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string(max($maxYear)-4))
                                                    )))//AMLAW_200:GROSS_REVENUE/text())   
                                                    
                       let $amLawGrossRevenuePre1Year := sum(cts:search(/,
                                                  cts:and-query((
                                                       cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                       cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                       cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string(max($maxYear)-1))
                                                    )))//AMLAW_200:GROSS_REVENUE/text())      
                       let $global100GrossRevenue := sum(cts:search(/,
                                                  cts:and-query((
                                                       cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
                                                       cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                       cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string(max($maxYearGlobal100)))
                                                    )))//Global_100:GROSS_REVENUE/text())
                                                    
                       let $global100GrossRevenuePre5Year := sum(cts:search(/,
                                                  cts:and-query((
                                                       cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
                                                       cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                       cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string(max($maxYearGlobal100) - 4))
                                                    )))//Global_100:GROSS_REVENUE/text())    
                                                    
                       let $global100GrossRevenuePre1Year := sum(cts:search(/,
                                                  cts:and-query((
                                                       cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
                                                       cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                       cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string(max($maxYearGlobal100) - 1))
                                                    )))//Global_100:GROSS_REVENUE/text()) 
                                                    
                       let $rplchange5 :=if($amLawGrossRevenuePre5Year ne 0) then firm:rplChange5Med($item//organizations:ORGANIZATION_ID/text(),max($maxYear)) else 0
                       let $rplchange1 :=if($amLawGrossRevenuePre1Year  ne 0) then firm:rplChange1Med($item//organizations:ORGANIZATION_ID/text(),max($maxYear)) else 0
					   
                       let $rplchange5g :=if($global100GrossRevenuePre5Year  ne 0) then firm:rplChange5gMed($item//organizations:ORGANIZATION_ID/text(),max($maxYear)) else 0
                       let $rplchange1g :=if($global100GrossRevenuePre1Year  ne 0) then firm:rplChange1gMed($item//organizations:ORGANIZATION_ID/text(),max($maxYear)) else 0
                       
                       (:------------ Max Year -------------:)
                       let $amLaw200 := cts:search(/,
                                                cts:and-query((
                                                     cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                     cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                     cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string(max($maxYear)))
                                                  )))
                                                  
                                             let $diversitySC := cts:search(/,
                                                    cts:and-query((
                                                         cts:directory-query("/LegalCompass/relational-data/surveys/Diversity_Scorecard/"),
                                                         cts:element-value-query(xs:QName('Diversity_Scorecard:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                         cts:element-value-query(xs:QName('Diversity_Scorecard:PUBLISHYEAR'),xs:string(max($maxYear)))
                                                         )))  
                                             
                                             let $femaleSC := cts:search(/,
                                                    cts:and-query((
                                                         cts:directory-query("/LegalCompass/relational-data/surveys/FEMALE_SCORECARD/"),
                                                         cts:element-value-query(xs:QName('FEMALE_SCORECARD:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                         cts:element-value-query(xs:QName('FEMALE_SCORECARD:PUBLISHYEAR'),xs:string(max($maxYear)))
                                                         )))
                                            
                                            let $nlj_lgbt := cts:search(/,
                                                    cts:and-query((
                                                         cts:directory-query("/LegalCompass/relational-data/surveys/NLJ_LGBT/"),
                                                         cts:element-value-query(xs:QName('nljlgbt:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                         cts:element-value-query(xs:QName('nljlgbt:PUBLISHYEAR'),xs:string(max($maxYear)))
                                                         )))
                                                         
                                           let $global100 := cts:search(/,
                                                    cts:and-query((
                                                         cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
                                                         cts:not-query(cts:element-value-query(xs:QName('Global_100:RANK_BY_GROSS_REVENUE'),'')),
                                                         cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                         cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string(max($maxYear)))
                                                         )))
                                                         
                                          let $res-obj := json:object()
                                          let $rpl := if($amLaw200//AMLAW_200:RPL/text() ne '') then $amLaw200//AMLAW_200:RPL/text() else $global100//Global_100:REVENUE_PER_LAWYER/text()
                                          let $grossRevenue := if($amLaw200//AMLAW_200:GROSS_REVENUE/text() ne '') then $amLaw200//AMLAW_200:GROSS_REVENUE/text() else $global100//Global_100:GROSS_REVENUE/text()
                                          let $numOfLawyers := if($amLaw200//AMLAW_200:NUM_OF_LAWYERS/text() ne '') then $amLaw200//AMLAW_200:NUM_OF_LAWYERS/text() else $global100//Global_100:NUM_LAWYERS/text()
                                          let $profitMargin := if($amLaw200//AMLAW_200:PROFIT_MARGIN/text() ne '') then $amLaw200//AMLAW_200:PROFIT_MARGIN/text() 
                                                               else ((xs:integer($global100//Global_100:PPP/text()) * xs:integer($global100//Global_100:NUM_EQUITY_PARTNERS/text())) div xs:integer($global100//Global_100:GROSS_REVENUE/text)) * 100
                                          let $leverage := if($amLaw200//AMLAW_200:LEVERAGE/text() ne '') then $amLaw200//AMLAW_200:LEVERAGE/text() 
                                                               else ((xs:integer($global100//Global_100:NUM_LAWYERS/text()) - xs:integer($global100//Global_100:NUM_EQUITY_PARTNERS/text())) div xs:integer($global100//Global_100:NUM_EQUITY_PARTNERS/text))
                                          let $ppp := if($amLaw200//AMLAW_200:PPP/text() ne '') then $amLaw200//AMLAW_200:PPP/text() else $global100//Global_100:PPP/text()
                                          let $numEquityPartner := if($amLaw200//AMLAW_200:NUM_EQ_PARTNERS/text() ne '') then $amLaw200//AMLAW_200:NUM_EQ_PARTNERS/text() 
                                                                   else $global100//Global_100:NUM_EQUITY_PARTNERS/text()
                                          (:let $grossRevenue := if($amLaw200//AMLAW_200:GROSS_REVENUE/text() ne '') then $amLaw200//AMLAW_200:GROSS_REVENUE/text() else $global100//Global_100:GROSS_REVENUE/text():)
										  let $netOperationIncome := $amLaw200//AMLAW_200:NET_OPERATING_INCOME/text()
										  let $noofLawyers := if($amLaw200//AMLAW_200:NUM_OF_LAWYERS/text() ne '') then $amLaw200//AMLAW_200:NUM_OF_LAWYERS/text() else $global100//Global_100:NUM_LAWYERS/text()
										  
                                          let $cpl := (xs:integer($grossRevenue) - xs:integer($netOperationIncome)) div xs:integer($noofLawyers)
                                         
                                          let $ppp1 := xs:double($amLaw200//AMLAW_200:NET_OPERATING_INCOME/text()) div xs:double($amLaw200//AMLAW_200:TOTAL_PARTNERS/text())
                                         
                                          let $equityPartner := xs:double($numEquityPartner) div xs:double($amLaw200//AMLAW_200:TOTAL_PARTNERS/text())
                                          let $minorityPer := xs:double($diversitySC//Diversity_Scorecard:MINORITY_PERCENTAGE/text()) * 100
                                         
                                          let $femaleAttorney := xs:double($femaleSC//FEMALE_SCORECARD:PCT_FEMALE_ATTORNEYS/text()) * 100
                                         
                                         
                                          let $lgbtAttorney := xs:double($nlj_lgbt//nljlgbt:PERCENT_LGBT_ATTORNEYS/text()) * 100                         
                                          (:---------- Max Year -1 ------------:)
                                          let $amLaw200Pre := cts:search(/,
                                                cts:and-query((
                                                     cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                     cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                     cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string(max($maxYear) - 1))
                                                  )))
                                                  
                                             let $diversitySCPre := cts:search(/,
                                                    cts:and-query((
                                                         cts:directory-query("/LegalCompass/relational-data/surveys/Diversity_Scorecard/"),
                                                         cts:element-value-query(xs:QName('Diversity_Scorecard:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                         cts:element-value-query(xs:QName('Diversity_Scorecard:PUBLISHYEAR'),xs:string(max($maxYear) - 1))
                                                         )))  
                                             
                                             let $femaleSCPre := cts:search(/,
                                                    cts:and-query((
                                                         cts:directory-query("/LegalCompass/relational-data/surveys/FEMALE_SCORECARD/"),
                                                         cts:element-value-query(xs:QName('FEMALE_SCORECARD:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                         cts:element-value-query(xs:QName('FEMALE_SCORECARD:PUBLISHYEAR'),xs:string(max($maxYear) - 1))
                                                         )))
                                            
                                            let $nlj_lgbtPre := cts:search(/,
                                                    cts:and-query((
                                                         cts:directory-query("/LegalCompass/relational-data/surveys/NLJ_LGBT/"),
                                                         cts:element-value-query(xs:QName('nljlgbt:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                         cts:element-value-query(xs:QName('nljlgbt:PUBLISHYEAR'),xs:string(max($maxYear) -1 ))
                                                         )))
                                                         
                                           let $global100Pre := cts:search(/,
                                                    cts:and-query((
                                                         cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
                                                         cts:not-query(cts:element-value-query(xs:QName('Global_100:RANK_BY_GROSS_REVENUE'),'')),
                                                         cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                         cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string(max($maxYear) -1 ))
                                                         )))
                                                         
                                          let $res-obj := json:object()
                                          let $rplPre := if($amLaw200Pre//AMLAW_200:RPL/text() ne '') then $amLaw200Pre//AMLAW_200:RPL/text() else $global100Pre//Global_100:RANK_BY_GROSS_REVENUE/text()
                                          let $grossRevenuePre := if($amLaw200Pre//AMLAW_200:GROSS_REVENUE/text() ne '') then $amLaw200Pre//AMLAW_200:GROSS_REVENUE/text() else $global100Pre//Global_100:GROSS_REVENUE/text()
                                          let $numOfLawyersPre := if($amLaw200Pre//AMLAW_200:NUM_OF_LAWYERS/text() ne '') then $amLaw200Pre//AMLAW_200:NUM_OF_LAWYERS/text() else $global100Pre//Global_100:NUM_LAWYERS/text()
                                          let $profitMarginPre := if($amLaw200Pre//AMLAW_200:PROFIT_MARGIN/text() ne '') then $amLaw200Pre//AMLAW_200:PROFIT_MARGIN/text() 
                                                               else ((xs:integer($global100Pre//Global_100:PPP/text()) * xs:integer($global100Pre//Global_100:NUM_EQUITY_PARTNERS/text())) div xs:integer($global100Pre//Global_100:GROSS_REVENUE/text)) * 100
                                          let $leveragePre := if($amLaw200Pre//AMLAW_200:LEVERAGE/text() ne '') then $amLaw200Pre//AMLAW_200:LEVERAGE/text() 
                                                               else ((xs:integer($global100Pre//Global_100:NUM_LAWYERS/text()) - xs:integer($global100Pre//Global_100:NUM_EQUITY_PARTNERS/text())) div xs:integer($global100Pre//Global_100:NUM_EQUITY_PARTNERS/text))
                                          let $pppPre := if($amLaw200Pre//AMLAW_200:PPP/text() ne '') then $amLaw200Pre//AMLAW_200:PPP/text() else $global100Pre//Global_100:PPP/text()
                                          let $numEquityPartnerPre := if($amLaw200Pre//AMLAW_200:NUM_EQ_PARTNERS/text() ne '') then $amLaw200Pre//AMLAW_200:NUM_EQ_PARTNERS/text() 
                                                                   else $global100Pre//Global_100:NUM_EQUITY_PARTNERS/text()
																   
										  let $netOperationIncomePre := $amLaw200Pre//AMLAW_200:NET_OPERATING_INCOME/text()
										  let $noofLawyersPre := if($amLaw200Pre//AMLAW_200:NUM_OF_LAWYERS/text() ne '') then $amLaw200Pre//AMLAW_200:NUM_OF_LAWYERS/text() else $global100Pre//Global_100:NUM_LAWYERS/text()
										  
										  
																   
                                           let $cplPre := (xs:integer($grossRevenuePre) - xs:integer($netOperationIncomePre)) div xs:integer($noofLawyersPre)
                                         
                                          let $ppp1Pre := xs:double($amLaw200Pre//AMLAW_200:NET_OPERATING_INCOME/text()) div xs:double($amLaw200Pre//AMLAW_200:TOTAL_PARTNERS/text())
                                         
                                          let $equityPartnerPre := xs:double($numEquityPartnerPre) div xs:double($amLaw200Pre//AMLAW_200:TOTAL_PARTNERS/text())
                                          let $minorityPerPre := xs:double($diversitySCPre//Diversity_Scorecard:MINORITY_PERCENTAGE/text()) * 100
                                         
                                          let $femaleAttorneyPre := xs:double($femaleSCPre//FEMALE_SCORECARD:PCT_FEMALE_ATTORNEYS/text()) * 100
                                         
                                         
                                          let $lgbtAttorneyPre := xs:double($nlj_lgbtPre//nljlgbt:PERCENT_LGBT_ATTORNEYS/text()) * 100    
                                          let $revenueGrowth1 := if($amLaw200//AMLAW_200:GROSS_REVENUE/text() ne '') then $rplchange1 else $rplchange1g
                                          let $revenueGrowth5 := if($amLaw200//AMLAW_200:GROSS_REVENUE/text() ne '') then $rplchange5 else $rplchange5g
                                          let $variable1 := if($column1 eq 'Am Law 200 rank') then $amLaw200//AMLAW_200:AMLAW200_RANK/text() else
                                                             if($column1 eq 'Global 100 rank') then $global100//Global_100:RANK_BY_GROSS_REVENUE/text() else
                                                             if($column1 eq 'Revenue Per Lawyer') then $rpl else
                                                             if($column1 eq 'Cost Per Lawyer') then $cpl else
                                                             if($column1 eq 'Profit Margin') then $profitMargin else
                                                             if($column1 eq '% Turnover') then $profitMargin else
                                                             if($column1 eq 'Leverage') then $leverage else
                                                             if($column1 eq 'Profit Per Partner') then $ppp1 else
                                                             if($column1 eq 'Profit Per Equity Partner') then $ppp else
                                                             if($column1 eq '% of Equity Partners') then ($equityPartner * 100) else
                                                             if($column1 eq '% of Minority Attorneys') then $minorityPer else
                                                             if($column1 eq '% of Female Attorneys') then $femaleAttorney else
                                                             if($column1 eq '% of LGBT Attorneys') then $lgbtAttorney else
                                                             if($column1 eq 'Growth in Minority Attorneys') then $diversitySC//Diversity_Scorecard:TOTAL_MINORITY_ATTORNEYS/text() else
                                                             if($column1 eq 'Growth in Female Partners') then $femaleSC//FEMALE_SCORECARD:FEMALE_PARTNERS/text() else
                                                             if($column1 eq 'Revenue Growth (1 year)') then $revenueGrowth1 else
                                                             if($column1 eq 'Revenue Growth (5 years)') then $revenueGrowth5 else $grossRevenue
                                          
                                          let $variable2 := if($column2 eq 'Am Law 200 rank') then $amLaw200//AMLAW_200:AMLAW200_RANK/text() else
                                                             if($column2 eq 'Global 100 rank') then $global100//Global_100:RANK_BY_GROSS_REVENUE/text() else
                                                             if($column2 eq 'Revenue Per Lawyer') then $rpl else
                                                             if($column2 eq 'Cost Per Lawyer') then $cpl else
                                                             if($column2 eq 'Profit Margin') then $profitMargin else
                                                             if($column2 eq '% Turnover') then $profitMargin else
                                                             if($column2 eq 'Leverage') then $leverage else
                                                             if($column2 eq 'Profit Per Partner') then $ppp1 else
                                                             if($column2 eq 'Profit Per Equity Partner') then $ppp else
                                                             if($column2 eq '% of Equity Partners') then ($equityPartner * 100) else
                                                             if($column2 eq '% of Minority Attorneys') then $minorityPer else
                                                             if($column2 eq '% of Female Attorneys') then $femaleAttorney else
                                                             if($column2 eq '% of LGBT Attorneys') then $lgbtAttorney else
                                                             if($column2 eq 'Growth in Minority Attorneys') then $diversitySC//Diversity_Scorecard:TOTAL_MINORITY_ATTORNEYS/text() else
                                                             if($column2 eq 'Growth in Female Partners') then $femaleSC//FEMALE_SCORECARD:FEMALE_PARTNERS/text() else
                                                             if($column2 eq 'Revenue Growth (1 year)') then $revenueGrowth1 else
                                                             if($column2 eq 'Revenue Growth (5 years)') then $revenueGrowth5 else $grossRevenue
                                                             
                                          let $variablePre1 := if($column1 eq 'Am Law 200 rank') then $amLaw200Pre//AMLAW_200:AMLAW200_RANK/text() else
                                                             if($column1 eq 'Global 100 rank') then $global100Pre//Global_100:RANK_BY_GROSS_REVENUE/text() else
                                                             if($column1 eq 'Revenue Per Lawyer') then $rplPre else
                                                             if($column1 eq 'Cost Per Lawyer') then $cplPre else
                                                             if($column1 eq 'Profit Margin') then $profitMarginPre else
                                                             if($column1 eq '% Turnover') then $profitMarginPre else
                                                             if($column1 eq 'Leverage') then $leveragePre else
                                                             if($column1 eq 'Profit Per Partner') then $ppp1Pre else
                                                             if($column1 eq 'Profit Per Equity Partner') then $pppPre else
                                                             if($column1 eq '% of Equity Partners') then ($equityPartner * 100) else
                                                             if($column1 eq '% of Minority Attorneys') then $minorityPerPre else
                                                             if($column1 eq '% of Female Attorneys') then $femaleAttorneyPre else
                                                             if($column1 eq '% of LGBT Attorneys') then $lgbtAttorneyPre else
                                                             if($column1 eq 'Growth in Minority Attorneys') then $diversitySCPre//Diversity_Scorecard:TOTAL_MINORITY_ATTORNEYS/text() else
                                                             if($column1 eq 'Growth in Female Partners') then $femaleSCPre//FEMALE_SCORECARD:FEMALE_PARTNERS/text() else
                                                             if($column1 eq 'Revenue Growth (1 year)') then $revenueGrowth1 else
                                                             if($column1 eq 'Revenue Growth (5 years)') then $revenueGrowth5 else $grossRevenue
                                          
                                          let $variablePre2 := if($column2 eq 'Am Law 200 rank') then $amLaw200Pre//AMLAW_200:AMLAW200_RANK/text() else
                                                             if($column2 eq 'Global 100 rank') then $global100Pre//Global_100:RANK_BY_GROSS_REVENUE/text() else
                                                             if($column2 eq 'Revenue Per Lawyer') then $rplPre else
                                                             if($column2 eq 'Cost Per Lawyer') then $cplPre else
                                                             if($column2 eq 'Profit Margin') then $profitMarginPre else
                                                             if($column2 eq '% Turnover') then $profitMarginPre else
                                                             if($column2 eq 'Leverage') then $leveragePre else
                                                             if($column2 eq 'Profit Per Partner') then $ppp1Pre else
                                                             if($column2 eq 'Profit Per Equity Partner') then $pppPre else
                                                             if($column2 eq '% of Equity Partners') then ($equityPartner * 100) else
                                                             if($column2 eq '% of Minority Attorneys') then $minorityPerPre else
                                                             if($column2 eq '% of Female Attorneys') then $femaleAttorney else
                                                             if($column2 eq '% of LGBT Attorneys') then $lgbtAttorneyPre else
                                                             if($column2 eq 'Growth in Minority Attorneys') then $diversitySCPre//Diversity_Scorecard:TOTAL_MINORITY_ATTORNEYS/text() else
                                                             if($column2 eq 'Growth in Female Partners') then $femaleSCPre//FEMALE_SCORECARD:FEMALE_PARTNERS/text() else
                                                             if($column2 eq 'Revenue Growth (1 year)') then $revenueGrowth1 else
                                                             if($column2 eq 'Revenue Growth (5 years)') then $revenueGrowth5 else $grossRevenue                   
                                                             
                                          let $variableChanges1 :=if($variablePre1) then fn:format-number(xs:float((xs:double($variable1 - $variablePre1) div xs:double($variablePre1)) * 100) ,'#,##0.00') else()
                                          let $variableChanges2 :=if($variablePre2) then fn:format-number(xs:float((xs:double($variable2 - $variablePre2) div xs:double($variablePre2)) * 100) ,'#,##0.00') else()
                                          
                                          let $_ := (map:put($res-obj,'ORGANIZATION_ID',$item//organizations:ORGANIZATION_ID/text()),
                                                     map:put($res-obj,'ORGANIZATION_NAME',$item//organizations:ORGANIZATION_NAME/text()),
                                                     map:put($res-obj,'VARIABLE_CHANGES1',fn:format-number(xs:double($variableChanges1),'.00')),
                                                     map:put($res-obj,'CUR_VARIABLE1',fn:format-number(xs:double($variable1),'.00')),
                                                     map:put($res-obj,'PRE_VARIABLE1',fn:format-number(xs:double($variablePre1),'.00')),
                                                     map:put($res-obj,'Variable2_Change',$variableChanges2),
                                                     map:put($res-obj,'CUR_VARIABLE2',fn:format-number(xs:double($variable2),'.00')),
                                                     map:put($res-obj,'PRE_VARIABLE2',fn:format-number(xs:double($variablePre2),'.00'))
                                                     )
                                                     
                                        let $_ := json:array-push($res-array,$res-obj)
                                        
                                        return()
  return $res-array
};



(:--------------- Score Card --------------------:)

 declare function firm:SP_GETFIRMPERFORMANCESCORE1($primaryFirmID,$firmID)
{
   let $res-obj := json:object()
  let $maxYear := max(cts:search(/,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/')
                      )))//AMLAW_200:PUBLISHYEAR/text())
                      
  let $result := cts:search(/,
                  cts:and-query((
                       cts:directory-query("/LegalCompass/relational-data/organization/"),
                       cts:element-value-query(xs:QName('organizations:ORGANIZATION_ID'),xs:string($primaryFirmID))
                       )))
                       
  let $loopData := for $item in $result
                       
                       let $amLaw200 :=  cts:search(/,
                                                cts:and-query((
                                                     cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                     cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                     cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($maxYear))
                                                     )))
                       
                       let $amLaw200PreYear :=  cts:search(/,
                                                cts:and-query((
                                                     cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                     cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                     cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($maxYear - 1))
                                                     )))
                       
                       let $nlj250 := cts:search(/,
                                            cts:and-query((
                                                 cts:directory-query("/LegalCompass/relational-data/surveys/NLJ_250/"),
                                                 cts:element-value-query(xs:QName('nlj250:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                 cts:element-value-query(xs:QName('nlj250:PUBLISHYEAR'),xs:string($maxYear))
                                                 )))
                                                 
                       let $nlj_lgbt := cts:search(/,
                                            cts:and-query((
                                                 cts:directory-query("/LegalCompass/relational-data/surveys/NLJ_LGBT/"),
                                                 cts:element-value-query(xs:QName('nljlgbt:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                 cts:element-value-query(xs:QName('nljlgbt:PUBLISHYEAR'),xs:string($maxYear))
                                                 )))                           
                       
                       let $femaleSC := cts:search(/,
                                            cts:and-query((
                                                 cts:directory-query("/LegalCompass/relational-data/surveys/FEMALE_SCORECARD/"),
                                                 cts:element-value-query(xs:QName('FEMALE_SCORECARD:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                 cts:element-value-query(xs:QName('FEMALE_SCORECARD:PUBLISHYEAR'),xs:string($maxYear))
                                                 )))              
                       

                       let $diversitySC := cts:search(/,
                                            cts:and-query((
                                                 cts:directory-query("/LegalCompass/relational-data/surveys/Diversity_Scorecard/"),
                                                 cts:element-value-query(xs:QName('Diversity_Scorecard:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                 cts:element-value-query(xs:QName('Diversity_Scorecard:PUBLISHYEAR'),xs:string($maxYear))
                                                 )))           
                       
                            
                       let $global100 := cts:search(/,
                                                  cts:and-query((
                                                       cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
                                                       cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                       cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($maxYear)))))
                      
                       let $global100PreYear := cts:search(/,
                                                  cts:and-query((
                                                       cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
                                                       cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                       cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($maxYear - 1)))))
                      
                      
                       
                       let $grossRevenue := if($amLaw200//AMLAW_200:GROSS_REVENUE/text() != '') then $amLaw200//AMLAW_200:GROSS_REVENUE/text()
                                            else $global100//Global_100:GROSS_REVENUE/text()
                       
                       let $grossRevenuePreYear := if($amLaw200PreYear//AMLAW_200:GROSS_REVENUE/text() != '') then $amLaw200PreYear//AMLAW_200:GROSS_REVENUE/text()
                                            else $global100PreYear//Global_100:GROSS_REVENUE/text()
                       let $growthFirmValue := ((xs:double($grossRevenue) - xs:double($grossRevenuePreYear)) div xs:double($grossRevenuePreYear)) * 100
                       let $rpl := if($amLaw200//AMLAW_200:RPL/text() != '') then $amLaw200//AMLAW_200:RPL/text()
                                            else $global100//Global_100:REVENUE_PER_LAWYER/text()
                       let $ppp := if($amLaw200//AMLAW_200:PPP/text() != '') then $amLaw200//AMLAW_200:PPP/text()
                                            else $global100//Global_100:PPP/text()     
                       let $eqp := (xs:double($amLaw200//AMLAW_200:NUM_EQ_PARTNERS/text()) div xs:double($amLaw200//AMLAW_200:TOTAL_PARTNERS/text())) * 100
                       let $cpl := (xs:double($amLaw200//AMLAW_200:GROSS_REVENUE/text()) - xs:double($amLaw200//AMLAW_200:NET_OPERATING_INCOME/text())) div xs:double($amLaw200//AMLAW_200:NUM_OF_LAWYERS/text())
                       let $profitMargin := if($amLaw200//AMLAW_200:PROFIT_MARGIN/text() ne '') then $amLaw200//AMLAW_200:PROFIT_MARGIN/text()
                                            else ((xs:double($global100//Global_100:PPP/text()) * xs:double($global100//Global_100:NUM_EQUITY_PARTNERS/text())) div xs:double($global100//Global_100:GROSS_REVENUE/text())) * 100
                       let $profitMarginPreYear := if($amLaw200PreYear//AMLAW_200:PROFIT_MARGIN/text() != '') then $amLaw200PreYear//AMLAW_200:PROFIT_MARGIN/text()
                                            else ((xs:double($global100PreYear//Global_100:PPP/text()) * xs:double($global100PreYear//Global_100:NUM_EQUITY_PARTNERS/text())) div xs:double($global100PreYear//Global_100:GROSS_REVENUE/text())) * 100
                       let $leverage := if($amLaw200//AMLAW_200:LEVERAGE/text() != '') then $amLaw200//AMLAW_200:LEVERAGE/text()
                                            else (xs:double($amLaw200//AMLAW_200:NUM_LAWYERS/text()) - xs:double($amLaw200//AMLAW_200:NUM_EQUITY_PARTNERS/text())) div xs:double($amLaw200//AMLAW_200:NUM_EQUITY_PARTNERS/text())
                       let $minorityPercentage := $diversitySC//Diversity_Scorecard:MINORITY_PERCENTAGE/text()
                       let $femaleAttorneys :=$femaleSC//FEMALE_SCORECARD:PCT_FEMALE_ATTORNEYS/text()
                       let $lgbtAttorneys := $nlj_lgbt//nljlgbt:PERCENT_LGBT_ATTORNEYS/text()   
                       
                       (:-------------------- Data for Non Primary Firms -----------------------:)                     
                       let $amLaw200NonPrimary :=  cts:search(/,
                           cts:and-query((
                           cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                           cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),fn:tokenize($firmID,',')),
                           cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($maxYear))
                           )))
                       
                      let $amLaw200PreYearNonPrimary :=  cts:search(/,
                                                     cts:and-query((
                                                         cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                         cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),fn:tokenize($firmID,',')),
                                                         cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($maxYear - 1))
                                                         )))

                      let $nlj250NonPrimary := cts:search(/,
                                          cts:and-query((
                                            cts:directory-query("/LegalCompass/relational-data/surveys/NLJ_250/"),
                                            cts:element-value-query(xs:QName('nlj250:ORGANIZATION_ID'),fn:tokenize($firmID,',')),
                                            cts:element-value-query(xs:QName('nlj250:PUBLISHYEAR'),xs:string($maxYear))
                                            )))
                                                 
                      let $nlj_lgbtNonPrimary := cts:search(/,
                                            cts:and-query((
                                                cts:directory-query("/LegalCompass/relational-data/surveys/NLJ_LGBT/"),
                                                cts:element-value-query(xs:QName('nljlgbt:ORGANIZATION_ID'),fn:tokenize($firmID,',')),
                                                cts:element-value-query(xs:QName('nljlgbt:PUBLISHYEAR'),xs:string($maxYear))
                                                )))                           

                      let $femaleSCNonPrimary := cts:search(/,
                                            cts:and-query((
                                                cts:directory-query("/LegalCompass/relational-data/surveys/FEMALE_SCORECARD/"),
                                                cts:element-value-query(xs:QName('FEMALE_SCORECARD:ORGANIZATION_ID'),fn:tokenize($firmID,',')),
                                                cts:element-value-query(xs:QName('FEMALE_SCORECARD:PUBLISHYEAR'),xs:string($maxYear))
                                                )))              


                      let $diversitySCNonPrimary := cts:search(/,
                                              cts:and-query((
                                                  cts:directory-query("/LegalCompass/relational-data/surveys/Diversity_Scorecard/"),
                                                  cts:element-value-query(xs:QName('Diversity_Scorecard:ORGANIZATION_ID'),fn:tokenize($firmID,',')),
                                                  cts:element-value-query(xs:QName('Diversity_Scorecard:PUBLISHYEAR'),xs:string($maxYear))
                                                  )))           


                     let $global100NonPrimary := cts:search(/,
                                                cts:and-query((
                                                cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
                                                cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),fn:tokenize($firmID,',')),
                                                cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($maxYear)))))

                     let $global100PreYearNonPrimary := cts:search(/,
                                                  cts:and-query((
                                                    cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
                                                    cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),fn:tokenize($firmID,',')),
                                                    cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($maxYear - 1)))))
                       
                       
                      let $grossRevenueNonPrimary := if($amLaw200NonPrimary//AMLAW_200:GROSS_REVENUE/text() != '') then math:median(($amLaw200NonPrimary//AMLAW_200:GROSS_REVENUE/text()))
                                            else math:median(($global100NonPrimary//Global_100:GROSS_REVENUE/text()))
                       
                       let $grossRevenuePreYearNonPrimary := if($amLaw200PreYearNonPrimary//AMLAW_200:GROSS_REVENUE/text() != '') then math:median(($amLaw200PreYearNonPrimary//AMLAW_200:GROSS_REVENUE/text()))
                                            else math:median(($global100PreYearNonPrimary//Global_100:GROSS_REVENUE/text()))
                       let $growthFirmValueNonPrimary := ((xs:double($grossRevenueNonPrimary) - xs:double($grossRevenuePreYearNonPrimary)) div xs:double($grossRevenuePreYearNonPrimary)) * 100
                       let $rplNonPrimary := if($amLaw200NonPrimary//AMLAW_200:RPL/text() != '') then math:median(($amLaw200NonPrimary//AMLAW_200:RPL/text()))
                                            else math:median(($global100NonPrimary//Global_100:REVENUE_PER_LAWYER/text()))
                       let $pppNonPrimary := if($amLaw200//AMLAW_200:PPP/text() != '') then math:median(($amLaw200NonPrimary//AMLAW_200:PPP/text()))
                                            else math:median(($global100NonPrimary//Global_100:PPP/text()))
                       let $eqpNonPrimary := (math:median(($amLaw200NonPrimary//AMLAW_200:NUM_EQ_PARTNERS/text())) div math:median(($amLaw200NonPrimary//AMLAW_200:TOTAL_PARTNERS/text()))) * 100
                       let $cplNonPrimary := (math:median(($amLaw200NonPrimary//AMLAW_200:GROSS_REVENUE/text())) - math:median(($amLaw200NonPrimary//AMLAW_200:NET_OPERATING_INCOME/text()))) div math:median(($amLaw200NonPrimary//AMLAW_200:NUM_OF_LAWYERS/text()))
                       let $profitMarginNonPrimary := if($amLaw200NonPrimary//AMLAW_200:PROFIT_MARGIN/text() != '') then math:median(($amLaw200NonPrimary//AMLAW_200:PROFIT_MARGIN/text()))
                                            else ((math:median(($global100NonPrimary//Global_100:PPP/text())) * math:median(($global100NonPrimary//Global_100:NUM_EQUITY_PARTNERS/text()))) div math:median(($global100NonPrimary//Global_100:GROSS_REVENUE/text()))) * 100
                       let $profitMarginPreYearNonPrimary := if($amLaw200PreYearNonPrimary//AMLAW_200:PROFIT_MARGIN/text() != '') then math:median(($amLaw200PreYearNonPrimary//AMLAW_200:PROFIT_MARGIN/text()))
                                            else ((math:median(($global100PreYearNonPrimary//Global_100:PPP/text())) * math:median(($global100PreYearNonPrimary//Global_100:NUM_EQUITY_PARTNERS/text()))) div math:median(($global100PreYearNonPrimary//Global_100:GROSS_REVENUE/text()))) * 100
                       let $leverageNonPrimary := if($amLaw200NonPrimary//AMLAW_200:LEVERAGE/text() != '') then math:median(($amLaw200NonPrimary//AMLAW_200:LEVERAGE/text()))
                                            else (math:median(($amLaw200NonPrimary//AMLAW_200:NUM_LAWYERS/text())) - math:median(($amLaw200NonPrimary//AMLAW_200:NUM_EQUITY_PARTNERS/text()))) div math:median(($amLaw200NonPrimary//AMLAW_200:NUM_EQUITY_PARTNERS/text()))
                       let $minorityPercentageNonPrimary := math:median(($diversitySCNonPrimary//Diversity_Scorecard:MINORITY_PERCENTAGE/text()))
                       let $femaleAttorneysNonPrimary :=math:median(($femaleSCNonPrimary//FEMALE_SCORECARD:PCT_FEMALE_ATTORNEYS/text()))
                       let $lgbtAttorneysNonPrimary := if($nlj_lgbtNonPrimary//nljlgbt:PERCENT_LGBT_ATTORNEYS/text() != '') then math:median(($nlj_lgbtNonPrimary//nljlgbt:PERCENT_LGBT_ATTORNEYS/text())) else 0
                       let $diffGrothValue := xs:double($growthFirmValue) - xs:double($growthFirmValueNonPrimary)
                       let $diffRpl := (xs:double($rpl) - xs:double($rplNonPrimary)) div 1000000
                       let $diffCpl := (xs:double($cpl) - xs:double($cplNonPrimary)) div 1000000
                       let $diffProfitMargin := xs:double($profitMargin) - xs:double($profitMarginNonPrimary)
                       let $diffLgbtAttorneys := if($lgbtAttorneys ne '' and $lgbtAttorneysNonPrimary ne 0) then (xs:double($lgbtAttorneys) - xs:double($lgbtAttorneysNonPrimary)) * 100 else 0 (:(xs:double($lgbtAttorneys) - xs:double($lgbtAttorneysNonPrimary)) * 100:)
                       let $diffLeverage := xs:double($leverage) - xs:double($leverageNonPrimary)
                       let $diffFemaleAttorneys := (xs:double($femaleAttorneys) - xs:double($femaleAttorneysNonPrimary)) * 100
                       let $diffMinorityAttorneys := (xs:double($minorityPercentage) - xs:double($minorityPercentageNonPrimary)) * 100
                       let $profitPartner := xs:double($ppp) div 1000000
                       let $percentEquityPartner := $eqp
                       let $medianProfitPerPartner := xs:double($pppNonPrimary) div 1000000
                       let $medianPercentEquityPartner := $eqpNonPrimary
                       let $diffProfitPartner := (xs:double($ppp) - xs:double($pppNonPrimary)) div 1000000
                       let $diffpercentEquityPartner := xs:double($eqp) - xs:double($eqpNonPrimary)
                       
                       
                      
								  
					   let $_ := (map:put($res-obj,'OrganizationID',xs:integer($item//organizations:ORGANIZATION_ID/text())),
                                  map:put($res-obj,'OrganizationName',$item//organizations:ORGANIZATION_NAME/text()),
                                  map:put($res-obj,'publishyear',$maxYear),
                                  map:put($res-obj,'GrowthFirmValue',xs:decimal(fn:format-number($growthFirmValue,".00"))),
                                  map:put($res-obj,'RevenuePerLawyer',fn:round-half-to-even((xs:double($rpl) div 1000000) ,2)),
                                  map:put($res-obj,'CostPerLawyer',fn:format-number(xs:double($cpl) div 1000000,".00")),
                                  map:put($res-obj,'ProfitMargin',fn:format-number($profitMargin,".00")),
                                  map:put($res-obj,'Leverage',fn:format-number($leverage,".0")),
                                  map:put($res-obj,'LGBTAttorneys',if($lgbtAttorneys ne '') then fn:format-number(xs:double($lgbtAttorneys) * 100,".00") else 0),
                                  map:put($res-obj,'FemaleAttorneys',fn:format-number(xs:double($femaleAttorneys) * 100,".00")),
                                  map:put($res-obj,'MinorityAttorneys',fn:format-number(xs:double($minorityPercentage) * 100 ,".00")),
                                  map:put($res-obj,'MedianGrowth',fn:format-number($growthFirmValueNonPrimary,".00")),
                                  map:put($res-obj,'MedianLGBTAttorneys',fn:format-number($lgbtAttorneysNonPrimary * 100,".00")),
                                  map:put($res-obj,'MedianFemaleAttorneys',fn:format-number($femaleAttorneysNonPrimary * 100,".0")),
                                  map:put($res-obj,'MedianMinorityAttorneys',fn:format-number($minorityPercentageNonPrimary * 100,".00")),
                                  map:put($res-obj,'MedianRPL',fn:format-number($rplNonPrimary div 1000000,".00")),
                                  map:put($res-obj,'MedianCPL',fn:format-number($cplNonPrimary div 1000000 ,".00")),
                                  map:put($res-obj,'MedianProfitMargin',fn:format-number($profitMarginNonPrimary,".00")),
                                  map:put($res-obj,'MedianLeverage',fn:format-number($leverageNonPrimary,".00")), 
                                  map:put($res-obj,'DiffGrowthValue',fn:format-number($diffGrothValue,".00")),
                                  map:put($res-obj,'DiffRPL',fn:format-number($diffRpl,".00")),
                                  map:put($res-obj,'DiffCPL',fn:format-number($diffCpl,".00")),
                                  map:put($res-obj,'DiffProfitMargin',fn:format-number($diffProfitMargin,".00")),
                                  map:put($res-obj,'DiffLGBTAttorneys',if($diffLgbtAttorneys != 0) then fn:format-number($diffLgbtAttorneys,".00") else ''),
                                  map:put($res-obj,'DiffLeverage',fn:format-number($diffLeverage,".00")),
                                  map:put($res-obj,'DiffFemaleAttorneys',fn:format-number($diffFemaleAttorneys,".0")),
                                  map:put($res-obj,'DiffMinorityAttorneys',fn:format-number($diffMinorityAttorneys,".00")),
                                  map:put($res-obj,'ProfitPerPartner',fn:format-number($profitPartner,".0")),
                                  map:put($res-obj,'PercentageEquityPartner',fn:format-number($percentEquityPartner,'.0')),
                                  map:put($res-obj,'MedianProfitPerPartner',fn:format-number($medianProfitPerPartner,".00")),
                                  map:put($res-obj,'MedianPercentageEquityPartner',fn:format-number($medianPercentEquityPartner,".00")),
                                  map:put($res-obj,'DiffProfitPerPartner',fn:format-number($diffProfitPartner,".00")),
                                  map:put($res-obj,'DiffPercentageEquityPartner',fn:format-number($diffpercentEquityPartner,".00"))
                                  )			  
                                  
                                 
                                
                 return()                      
   return $res-obj
  
};