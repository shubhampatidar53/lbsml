xquery version '1.0-ml';

module namespace firm = 'http://alm.com/firm_2';

import module namespace config = 'http://alm.com/config' at '/common/config.xqy';
import module namespace helper = 'http://alm.com/helper' at '/common/model/helper.xqy';
import module namespace search = 'http://marklogic.com/appservices/search' at '/MarkLogic/appservices/search/search.xqy';
import module namespace json = 'http://marklogic.com/xdmp/json'  at '/MarkLogic/json/json.xqy';
import module namespace firm-comp = 'http://alm.com/firm-comparison' at '/common/model/firm-comparison.xqy';
import module namespace firm-statics = 'http://alm.com/firm-statics' at '/common/model/firm-statics.xqy';

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
declare namespace tblrermovechanges = 'http://alm.com/LegalCompass/dd/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES';
declare namespace TBL_RER_CACHE_ATTORNEY_MOVESCHANGES = 'http://alm.com/LegalCompass/dd/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES';


declare namespace tblrer = "http://alm.com/LegalCompass/dd/TBL_RER_CACHE_ATTORNEY_DATA";
declare namespace LawFirm_PracticeArea = "http://alm.com/LegalCompass/rd/LawFirm_PracticeArea";
declare namespace practices = "http://alm.com/LegalCompass/rd/practices_kws";
declare namespace alidata = "http://alm.com/LegalCompass/rd/FIRMS_ALI_XREF_RE";

declare variable $company-obj := json:object();

declare option xdmp:mapping 'false';

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
	let $orderBy := cts:index-order(cts:element-reference(xs:QName('lfp_news:NEWSDATE')) ,'descending')
	let $response := cts:search(/LAWFIRMPROFILE_NEWS, cts:and-query(($conditions)),$orderBy)[1 to 5]
	let $count := count($response)
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



declare function firm:sp_GetLawFirmStatics_LawSchool2(
	 $PageNo
	,$PageSize
	,$firmIds
	,$practiceArea
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
	
	let $PracticeAreas := if ($practiceArea != '') then 
			let $key := fn:tokenize($practiceArea,'[|]')
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
		,if ($practiceArea) then cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:practice_area'),$PracticeAreas,('wildcarded', 'case-insensitive')) else ()
		,if ($lawschools != '') then cts:element-word-query(xs:QName('ALI_RE_Attorney_Data:std_school'),$lawschools,('whitespace-insensitive', 'wildcarded', 'case-insensitive')) else ()
		,$firm_id_q
	  )
	
	let $attorney_moveschanges_conditions := (
		 cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
		,if ($location_val != '') then cts:element-value-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:location'),$location_val,('case-insensitive')) else () 
		,cts:not-query(cts:element-value-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:std_school'),''))
		,$date_q
		,if ($practiceArea) then cts:element-value-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:practice_area'),$PracticeAreas,('wildcarded', 'case-insensitive')) else ()
		,if ($lawschools != '') then cts:element-word-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:std_school'),$lawschools,('whitespace-insensitive', 'wildcarded', 'case-insensitive')) else ()
		,$re_id_q
	  )

	let $attorney_search := cts:element-values(xs:QName('ALI_RE_Attorney_Data:std_school'),(),(), cts:and-query(($attorney_conditions)))
	(:let $totalCount := count(cts:element-values(xs:QName('ALI_RE_Attorney_Data:std_school'),(),(), cts:and-query(($attorney_conditions)))):)
									
	let $res-array := json:array()
    let $loopData := for $company in $attorney_search
	let $res-object := json:object()
 
	let $headcount := count(cts:values(cts:element-reference(xs:QName('tblrer:attorney_id')),(),(),cts:and-query((
						cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/')
						,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrer:practices'), $PracticeAreas, ('wildcarded','case-insensitive')) else()
						,if($Cities ne '') then cts:element-value-query(xs:QName('tblrer:location'), $Cities,('wildcarded','case-insensitive')) else()
						,cts:element-value-query(xs:QName('tblrer:std_school'), xs:string($company))
						,cts:element-value-query(xs:QName('tblrer:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
						))))
	
	
 let $headcountplus := count(cts:values(cts:element-reference(xs:QName('tblrermovechanges:moves_changes_id')),(),(),cts:and-query((
    cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
    ,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
    ,if($Cities ne '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $Cities,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('tblrermovechanges:std_school'), xs:string($company))
    ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
    ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'),'added')
    ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
				
 let $headcountminus := count(cts:values(cts:element-reference(xs:QName('tblrermovechanges:moves_changes_id')),(),(),cts:and-query((
      cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
      ,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
      ,if($Cities ne '') then cts:element-value-query(xs:QName('tblrermovechanges:location'), $Cities,('wildcarded','case-insensitive')) else()
      ,cts:element-value-query(xs:QName('tblrermovechanges:std_school'), xs:string($company))
      ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
      ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'),'removed')   
      ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))

 let $partnercount := count(cts:values(cts:element-reference(xs:QName('tblrer:attorney_id')),(),(),cts:and-query((
    cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/'),
    if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrer:practices'),$PracticeAreas,('wildcarded','case-insensitive')) else(),
    if($Cities ne '') then cts:element-word-query(xs:QName('tblrer:location'),$Cities,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('tblrer:std_school'), xs:string($company))
    ,cts:element-value-query(xs:QName('tblrer:title'), ('Partner'))
    ))))
	
	 let $partnercountplus := count(cts:values(cts:element-reference(xs:QName('tblrermovechanges:moves_changes_id')),(),(),cts:and-query((
   cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
      ,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
      ,if($Cities ne '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $Cities,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('tblrermovechanges:std_school'), xs:string($company))
    ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Partner'))
    ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('added'))
    ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
	
				
	let $partnercountplus := count(cts:values(cts:element-reference(xs:QName('tblrermovechanges:moves_changes_id')),(),(),cts:and-query((
   cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
      ,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
      ,if($Cities ne '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $Cities,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('tblrermovechanges:std_school'), xs:string($company))
    ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Partner'))
    ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('added'))
    ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
				
  let $partnercountminus := count(cts:values(cts:element-reference(xs:QName('tblrermovechanges:moves_changes_id')),(),(),cts:and-query((
      cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
      ,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
      ,if($Cities ne '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $Cities,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('tblrermovechanges:std_school'), xs:string($company))
    ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Partner'))
    ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('removed'))
    ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
	
	let $associatecount := count(cts:values(cts:element-reference(xs:QName('tblrer:attorney_id')),(),(),cts:and-query((
    cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/'),
    if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrer:practices'),$PracticeAreas,('wildcarded','case-insensitive')) else(),
    if($Cities ne '') then cts:element-word-query(xs:QName('tblrer:location'),$Cities,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('tblrer:std_school'), xs:string($company))
    ,cts:element-value-query(xs:QName('tblrer:title'), ('Associate'))
    ))))
	
	let $associatecountplus := count(cts:values(cts:element-reference(xs:QName('tblrermovechanges:moves_changes_id')),(),(),cts:and-query((
    cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
      ,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
      ,if($Cities ne '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $Cities,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('tblrermovechanges:std_school'), xs:string($company))
    ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Associate'))
    ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('added'))
    ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
				
    let $associatecountminus :=count(cts:values(cts:element-reference(xs:QName('tblrermovechanges:moves_changes_id')),(),(),cts:and-query((
    cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
      ,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
      ,if($Cities ne '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $Cities,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('tblrermovechanges:std_school'), xs:string($company))
    ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Associate'))
    ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('removed'))
    ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
				
	
	let $othercouselcount := count(cts:values(cts:element-reference(xs:QName('tblrer:attorney_id')),(),(),cts:and-query((
    cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/'),
    if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrer:practices'),$PracticeAreas,('wildcarded','case-insensitive')) else(),
    if($Cities ne '') then cts:element-word-query(xs:QName('tblrer:location'),$Cities,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('tblrer:std_school'), xs:string($company))
    ,cts:element-value-query(xs:QName('tblrer:title'), ('Other Counsel/Attorney'),"case-insensitive")
    )))) 
  let $othercouselcountplus := count(cts:values(cts:element-reference(xs:QName('tblrermovechanges:moves_changes_id')),(),(),cts:and-query((
    cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
      ,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
      ,if($Cities ne '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $Cities,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('tblrermovechanges:std_school'), xs:string($company))
    ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Other Counsel/Attorney'),"case-insensitive")
    ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('added'))
    ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
  let $othercouselcountminus := count(cts:values(cts:element-reference(xs:QName('tblrermovechanges:moves_changes_id')),(),(),cts:and-query((
    cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
      ,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
      ,if($Cities ne '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $Cities,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('tblrermovechanges:std_school'), xs:string($company))
    ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Other Counsel/Attorney'),"case-insensitive")
    ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('removed'))
    ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
  let $admincount := count(cts:values(cts:element-reference(xs:QName('tblrer:attorney_id')),(),(),cts:and-query((
    cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/'),
    if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrer:practices'),$PracticeAreas,('wildcarded','case-insensitive')) else(),
    if($Cities ne '') then cts:element-word-query(xs:QName('tblrer:location'),$Cities,('wildcarded','case-insensitive')) else(),
    cts:element-value-query(xs:QName('tblrer:std_school'), xs:string($company)),
    cts:element-value-query(xs:QName('tblrer:title'), ('Administrative / Support Staff'),"case-insensitive")
    )))) 
     let $admincountplus := count(cts:values(cts:element-reference(xs:QName('tblrermovechanges:moves_changes_id')),(),(),cts:and-query((
    cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
      ,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
      ,if($Cities ne '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $Cities,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('tblrermovechanges:std_school'), xs:string($company))
    ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Administrative / Support Staff'),"case-insensitive")
    ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('added'))
    ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
     let $admincountminus := count(cts:values(cts:element-reference(xs:QName('tblrermovechanges:moves_changes_id')),(),(),cts:and-query((
    cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
      ,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
      ,if($Cities ne '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $Cities,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('tblrermovechanges:std_school'), xs:string($company))
    ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Administrative / Support Staff'),"case-insensitive")
    ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('removed'))
    ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
    
  let $othercount :=  count(cts:values(cts:element-reference(xs:QName('tblrer:attorney_id')),(),(),cts:and-query((
      cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/'),
      if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrer:practices'),$PracticeAreas,('wildcarded','case-insensitive')) else(),
      if($Cities ne '') then cts:element-word-query(xs:QName('tblrer:location'),$Cities,('wildcarded','case-insensitive')) else()
      ,cts:element-value-query(xs:QName('tblrer:std_school'), xs:string($company))
      ,cts:element-value-query(xs:QName('tblrer:title'), ('Other'),"case-insensitive")))))
      
  let $othercountplus :=  count(cts:values(cts:element-reference(xs:QName('tblrermovechanges:moves_changes_id')),(),(),cts:and-query((
   cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
      ,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ('wildcarded','case-insensitive')) else()
      ,if($Cities ne '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $Cities,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('tblrermovechanges:std_school'), xs:string($company))
    ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Other'),"case-insensitive")
    ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('added'))
    ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
    
  let $othercountminus :=  count(cts:values(cts:element-reference(xs:QName('tblrermovechanges:moves_changes_id')),(),(),cts:and-query((
    cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
      ,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
      ,if($Cities ne '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $Cities,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('tblrermovechanges:std_school'), xs:string($company))
    ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Other'),"case-insensitive")
    ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('removed'))
    ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
 
		let $diff := xs:decimal($headcountplus)-xs:decimal($headcountminus)
		 let $div := if($headcount ne 0) then ($diff div xs:decimal($headcount))*xs:double(100) else 0
	
				 let $_ := (map:put($res-object,'School',$company),
                map:put($res-object,'headCount',$headcount),
				map:put($res-object,'headCountPlus',$headcountplus),
				map:put($res-object,'headCountMinus',$headcountminus),
                map:put($res-object,'partnerCount',$partnercount),
				map:put($res-object,'partnerCountPlus',$partnercountplus),
				map:put($res-object,'partnerCountPlus',$partnercountplus),
				map:put($res-object,'partnerCountMinus',$partnercountminus),
                map:put($res-object,'associateCount',$associatecount),
				map:put($res-object,'associateCountPlus',$associatecountplus),
                map:put($res-object,'associateCountMinus',$associatecountminus),
                map:put($res-object,'otherCouselCount',$othercouselcount),
                map:put($res-object,'adminCount',$admincount),
                map:put($res-object,'otherCount',$othercount),
                map:put($res-object,'headCountPlus',$headcountplus),
                map:put($res-object,'headCountMinus',$headcountminus),
                map:put($res-object,'partnerCountPlus',$partnercountplus),
                map:put($res-object,'partnerCountMinus',$partnercountminus),
                map:put($res-object,'associateCountPlus',$associatecountplus),
                map:put($res-object,'associateCountMinus',$associatecountminus),
                map:put($res-object,'otherCouselCountPlus',$othercouselcountplus),
                map:put($res-object,'otherCouselCountMinus',$othercouselcountminus),
                map:put($res-object,'adminCountPlus',$admincountplus),
                map:put($res-object,'adminCountMinus',$admincountminus),
                map:put($res-object,'otherCountPlus',$othercountplus),
                map:put($res-object,'otherCountMinus',$othercountminus),
				map:put($res-object,'Changes',fn:round($div))
				(:map:put($res-object,'totalCount',$totalCount):))
    let $_ := json:array-push($res-array,$res-object)
    return ()
	
	return $res-array
				
  (:
	
  let $partnercountplus := count(cts:values(cts:element-reference(xs:QName('tblrermovechanges:moves_changes_id')),(),(),cts:and-query((
   cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
      ,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
      ,if($Cities ne '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $Cities,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('tblrermovechanges:std_school'), xs:string($company))
    ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Partner'))
    ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('added'))
    ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
				
  let $partnercountminus := count(cts:values(cts:element-reference(xs:QName('tblrermovechanges:moves_changes_id')),(),(),cts:and-query((
      cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
      ,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
      ,if($Cities ne '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $Cities,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('tblrermovechanges:std_school'), xs:string($company))
    ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Partner'))
    ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('removed'))
    ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
				
    
  let $associatecount := count(cts:values(cts:element-reference(xs:QName('tblrer:attorney_id')),(),(),cts:and-query((
    cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/'),
    if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrer:practices'),$PracticeAreas,('wildcarded','case-insensitive')) else(),
    if($Cities ne '') then cts:element-word-query(xs:QName('tblrer:location'),$Cities,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('tblrer:std_school'), xs:string($company))
    ,cts:element-value-query(xs:QName('tblrer:title'), ('Associate'))
    ))))
	
    let $associatecountplus := count(cts:values(cts:element-reference(xs:QName('tblrermovechanges:moves_changes_id')),(),(),cts:and-query((
    cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
      ,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
      ,if($Cities ne '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $Cities,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('tblrermovechanges:std_school'), xs:string($company))
    ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Associate'))
    ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('added'))
    ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
				
    let $associatecountminus :=count(cts:values(cts:element-reference(xs:QName('tblrermovechanges:moves_changes_id')),(),(),cts:and-query((
    cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
      ,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
      ,if($Cities ne '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $Cities,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('tblrermovechanges:std_school'), xs:string($company))
    ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Associate'))
    ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('removed'))
    ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
    
  let $othercouselcount := count(cts:values(cts:element-reference(xs:QName('tblrer:attorney_id')),(),(),cts:and-query((
    cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/'),
    if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrer:practices'),$PracticeAreas,('wildcarded','case-insensitive')) else(),
    if($Cities ne '') then cts:element-word-query(xs:QName('tblrer:location'),$Cities,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('tblrer:std_school'), xs:string($company))
    ,cts:element-value-query(xs:QName('tblrer:title'), ('Other Counsel/Attorney'),"case-insensitive")
    )))) 
  let $othercouselcountplus := count(cts:values(cts:element-reference(xs:QName('tblrermovechanges:moves_changes_id')),(),(),cts:and-query((
    cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
      ,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
      ,if($Cities ne '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $Cities,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('tblrermovechanges:std_school'), xs:string($company))
    ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Other Counsel/Attorney'),"case-insensitive")
    ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('added'))
    ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
  let $othercouselcountminus := count(cts:values(cts:element-reference(xs:QName('tblrermovechanges:moves_changes_id')),(),(),cts:and-query((
    cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
      ,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
      ,if($Cities ne '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $Cities,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('tblrermovechanges:std_school'), xs:string($company))
    ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Other Counsel/Attorney'),"case-insensitive")
    ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('removed'))
    ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
  let $admincount := count(cts:values(cts:element-reference(xs:QName('tblrer:attorney_id')),(),(),cts:and-query((
    cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/'),
    if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrer:practices'),$PracticeAreas,('wildcarded','case-insensitive')) else(),
    if($Cities ne '') then cts:element-word-query(xs:QName('tblrer:location'),$Cities,('wildcarded','case-insensitive')) else(),
    cts:element-value-query(xs:QName('tblrer:std_school'), xs:string($company)),
    cts:element-value-query(xs:QName('tblrer:title'), ('Administrative / Support Staff'),"case-insensitive")
    )))) 
     let $admincountplus := count(cts:values(cts:element-reference(xs:QName('tblrermovechanges:moves_changes_id')),(),(),cts:and-query((
    cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
      ,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
      ,if($Cities ne '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $Cities,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('tblrermovechanges:std_school'), xs:string($company))
    ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Administrative / Support Staff'),"case-insensitive")
    ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('added'))
    ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
     let $admincountminus := count(cts:values(cts:element-reference(xs:QName('tblrermovechanges:moves_changes_id')),(),(),cts:and-query((
    cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
      ,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
      ,if($Cities ne '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $Cities,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('tblrermovechanges:std_school'), xs:string($company))
    ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Administrative / Support Staff'),"case-insensitive")
    ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('removed'))
    ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
    
  let $othercount :=  count(cts:values(cts:element-reference(xs:QName('tblrer:attorney_id')),(),(),cts:and-query((
      cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/'),
      if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrer:practices'),$PracticeAreas,('wildcarded','case-insensitive')) else(),
      if($Cities ne '') then cts:element-word-query(xs:QName('tblrer:location'),$Cities,('wildcarded','case-insensitive')) else()
      ,cts:element-value-query(xs:QName('tblrer:std_school'), xs:string($company))
      ,cts:element-value-query(xs:QName('tblrer:title'), ('Other'),"case-insensitive")))))
      
  let $othercountplus :=  count(cts:values(cts:element-reference(xs:QName('tblrermovechanges:moves_changes_id')),(),(),cts:and-query((
   cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
      ,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ('wildcarded','case-insensitive')) else()
      ,if($Cities ne '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $Cities,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('tblrermovechanges:std_school'), xs:string($company))
    ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Other'),"case-insensitive")
    ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('added'))
    ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
    
  let $othercountminus :=  count(cts:values(cts:element-reference(xs:QName('tblrermovechanges:moves_changes_id')),(),(),cts:and-query((
    cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
      ,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
      ,if($Cities ne '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $Cities,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('tblrermovechanges:std_school'), xs:string($company))
    ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Other'),"case-insensitive")
    ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('removed'))
    ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))

     let $firmDetail := firm-statics:getFIRMS_ALI_XREF_REData($company)  
		let $diff := xs:decimal($headcountplus)-xs:decimal($headcountminus)
		 let $div := if($headcount ne 0) then ($diff div xs:decimal($headcount))*xs:double(100) else 0
     let $firmName := if($firmDetail/alidata:ALM_NAME/text() ne '') then $firmDetail/alidata:ALM_NAME/text() else firm-statics:getFirmName(xs:string($company)):)
    (:let $_ := (map:put($res-object,'School',$company),
                map:put($res-object,'headCount',$headcount),
				map:put($res-object,'headCountPlus',$headcountplus),
                map:put($res-object,'partnerCount',$partnercount),
                map:put($res-object,'associateCount',$associatecount),
                map:put($res-object,'otherCouselCount',$othercouselcount),
                map:put($res-object,'adminCount',$admincount),
                map:put($res-object,'otherCount',$othercount),
                map:put($res-object,'headCountPlus',$headcountplus),
                map:put($res-object,'headCountMinus',$headcountminus),
                map:put($res-object,'partnerCountPlus',$partnercountplus),
                map:put($res-object,'partnerCountMinus',$partnercountminus),
                map:put($res-object,'associateCountPlus',$associatecountplus),
                map:put($res-object,'associateCountMinus',$associatecountminus),
                map:put($res-object,'otherCouselCountPlus',$othercouselcountplus),
                map:put($res-object,'otherCouselCountMinus',$othercouselcountminus),
                map:put($res-object,'adminCountPlus',$admincountplus),
                map:put($res-object,'adminCountMinus',$admincountminus),
                map:put($res-object,'otherCountPlus',$othercountplus),
                map:put($res-object,'otherCountMinus',$othercountminus),
				map:put($res-object,'Changes',fn:round($div)),
				map:put($res-object,'totalCount',$totalCount))
    let $_ := json:array-push($res-array,$res-object)
    return ()
	
	return $res-array:)
  
  
	
	
};


declare function firm:sp_GetLawFirmStatics_LawSchool3(
	 $PageNo
	,$PageSize
	,$firmIds
	,$practiceArea
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
	
	let $start := xs:integer(((xs:integer($PageNo)* xs:integer($PageSize))-xs:integer($PageSize))+1)
	let $end := xs:integer((xs:integer($start) + xs:integer($PageSize)) - 1 )
	
	let $fromDate := fn:tokenize($fromDate,'T')[1]
	let $toDate := fn:tokenize($toDate,'T')[1]

	
		 
		 let $location_val := if(($Cities !='') or ($States !='') or ($Countries != '') or ($GeoGraphicRegions !='') or  ($UsRegions !='')) then
		 cts:values(cts:element-reference(xs:QName('city:std_loc')),(),(),
		 cts:and-query((
			cts:directory-query($config:RD-CITY-PATH)
			 ,if($Cities ne '') then cts:element-value-query(xs:QName('city:city'), fn:tokenize($Cities,','), ('case-insensitive')) else()
			 ,if($States ne '') then cts:element-value-query(xs:QName('city:state'), fn:tokenize($States,','), ('case-insensitive')) else()
			 ,if($Countries ne '') then cts:element-value-query(xs:QName('city:country'), fn:tokenize($Countries,','), ('case-insensitive')) else()
			 ,if($GeoGraphicRegions ne '') then cts:element-value-query(xs:QName('city:geographic_region'), fn:tokenize($GeoGraphicRegions,','), ('case-insensitive')) else()
			 ,if($UsRegions ne '') then cts:element-value-query(xs:QName('city:us_region'), fn:tokenize($UsRegions,','), ('case-insensitive')) else()
		 )))
	  else ()
	  
	  
	let $date_q := if (($fromDate != '') and ($toDate != '')) then (
			 cts:element-range-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:last_action_date'), '>=', xs:date($fromDate))
			,cts:element-range-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:last_action_date'), '<=', xs:date($toDate))
		)
		else ()
	
	let $PracticeAreas := if ($practiceArea != '') then 
			let $key := fn:tokenize($practiceArea,'[|]')
			let $res :=  cts:element-values(xs:QName('practices_kws:practice_area'),(),(), cts:and-query((
					cts:element-word-query(xs:QName('practices_kws:practice_area'),$key, ('wildcarded', 'case-insensitive'))
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
		,if ($location_val != '') then cts:element-word-query(xs:QName('ALI_RE_Attorney_Data:location'),$location_val,('wildcarded','case-insensitive')) else ()
		,cts:not-query(cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:std_school'),''))
		,if ($practiceArea) then cts:element-word-query(xs:QName('ALI_RE_Attorney_Data:practice_area'),$PracticeAreas,('wildcarded', 'case-insensitive')) else ()
		,if ($lawschools != '') then cts:element-word-query(xs:QName('ALI_RE_Attorney_Data:std_school'),$lawschools,('whitespace-insensitive', 'wildcarded', 'case-insensitive')) else ()
		,$firm_id_q
	  )

	(:let $attorney_search := cts:element-values(xs:QName('ALI_RE_Attorney_Data:std_school'),(),(), cts:and-query(($attorney_conditions,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:location'), $location_val,'case-insensitive'),cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))))):)
	
	let $attorney_search := cts:element-values(xs:QName('ALI_RE_Attorney_Data:std_school'),(),(), cts:and-query(($attorney_conditions)))
	
	let $totalCount := count($attorney_search)								
	let $res-array := json:array()
    let $loopData := if($firmSizefrom ne 0 and $firmSizeTo ne 0) then for $company1 in $attorney_search
						 	
							let $headcount := xdmp:estimate(cts:search(/,
												cts:and-query((
													cts:directory-query('/LegalCompass/denormalized-data/ALI_RE_Attorney_Data/'),
													$firm_id_q
													,if($practiceArea ne '') then cts:element-word-query(xs:QName('ALI_RE_Attorney_Data:practice_area'), $PracticeAreas, ('wildcarded','case-insensitive')) else()
													,if($location_val != '') then cts:element-word-query(xs:QName('ALI_RE_Attorney_Data:location'), $location_val,('wildcarded','case-insensitive')) else()
													
													,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:std_school'), xs:string($company1))
													,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'))
													))))
							
							order by $headcount ge $firmSizefrom and $headcount le $firmSizeTo descending
							return $company1
							
					 else for $company1 in $attorney_search
						 	
							let $headcount := xdmp:estimate(cts:search(/,
												cts:and-query((
													cts:directory-query('/LegalCompass/denormalized-data/ALI_RE_Attorney_Data/'),
													$firm_id_q
													,if($practiceArea ne '') then cts:element-word-query(xs:QName('ALI_RE_Attorney_Data:practice_area'), $PracticeAreas, ('wildcarded')) else()
													,if($location_val != '') then cts:element-word-query(xs:QName('ALI_RE_Attorney_Data:location'), $location_val,('wildcarded','case-insensitive')) else()
													
													,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:std_school'), xs:string($company1))
													,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
													))))
									
							order by $headcount descending
							
						
							return $company1		
							
	let $schoolNames := $loopData[$start to $end]						
	(:let $orderBYY := for $result in $loopData
		let $a := xs:integer(fn:tokenize($result,'[|]')[1])
		order by $a descending
		return $result
		
		return $orderBYY [1 to 5]:)
	let $loopData1 := for $company in $schoolNames
	let $res-object := json:object() 
	let $headcount := xdmp:estimate(cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/denormalized-data/ALI_RE_Attorney_Data/'),
							$firm_id_q
							,if($practiceArea ne '') then cts:element-word-query(xs:QName('ALI_RE_Attorney_Data:practices'), $PracticeAreas, ('wildcarded')) else()
							,if($location_val != '') then cts:element-word-query(xs:QName('ALI_RE_Attorney_Data:location'), $location_val,('wildcarded','case-insensitive')) else()
							
							,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:std_school'), xs:string($company))
							,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'))
							)))) 
							
	let $headcountplus := xdmp:estimate(cts:search(/,
    cts:and-query((
    cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
	,$re_id_q
    ,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
    ,if($location_val != '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $location_val,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('tblrermovechanges:std_school'), xs:string($company))
    ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
    ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'),'added')
    ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
	
 let $headcountminus := xdmp:estimate(cts:search(/,
    cts:and-query((
      cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
	  ,$re_id_q
      ,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
      ,if($location_val != '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $location_val,('wildcarded','case-insensitive')) else()
      ,cts:element-value-query(xs:QName('tblrermovechanges:std_school'), xs:string($company))
      ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
      ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'),'removed')   
      ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
				
  let $partnercount := xdmp:estimate(cts:search(/,
    cts:and-query((
    cts:directory-query('/LegalCompass/denormalized-data/ALI_RE_Attorney_Data/'),
	$firm_id_q,
    if($practiceArea ne '') then cts:element-word-query(xs:QName('ALI_RE_Attorney_Data:practices'),$PracticeAreas,('wildcarded')) else(),
    if($location_val != '') then cts:element-word-query(xs:QName('ALI_RE_Attorney_Data:location'),$location_val,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:std_school'), xs:string($company))
    ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:title'), ('Partner'))
    ))))
	
  let $partnercountplus := xdmp:estimate(cts:search(/,
    cts:and-query((
   cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
   ,$re_id_q
      ,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
      ,if($location_val != '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $location_val,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('tblrermovechanges:std_school'), xs:string($company))
    ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Partner'))
    ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('added'))
    ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
				
  let $partnercountminus := xdmp:estimate(cts:search(/,
    cts:and-query((
      cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
	  ,$re_id_q
      ,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
      ,if($location_val != '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $location_val,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('tblrermovechanges:std_school'), xs:string($company))
    ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Partner'))
    ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('removed'))
    ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
				
    
  let $associatecount := xdmp:estimate(cts:search(/,
    cts:and-query((
    cts:directory-query('/LegalCompass/denormalized-data/ALI_RE_Attorney_Data/'),
	$firm_id_q,
    if($practiceArea ne '') then cts:element-word-query(xs:QName('ALI_RE_Attorney_Data:practices'),$PracticeAreas,('wildcarded','case-insensitive')) else(),
    if($location_val != '') then cts:element-word-query(xs:QName('ALI_RE_Attorney_Data:location'),$location_val,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:std_school'), xs:string($company))
    ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:title'), ('Associate'))
    ))))
	
    let $associatecountplus := xdmp:estimate(cts:search(/,
    cts:and-query((
    cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
	,$re_id_q
      ,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
      ,if($location_val != '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $location_val,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('tblrermovechanges:std_school'), xs:string($company))
    ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Associate'))
    ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('added'))
    ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
				
    let $associatecountminus := xdmp:estimate(cts:search(/,
    cts:and-query((
    cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
	,$re_id_q
      ,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
      ,if($location_val != '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $location_val,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('tblrermovechanges:std_school'), xs:string($company))
    ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Associate'))
    ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('removed'))
    ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
    
  let $othercouselcount := xdmp:estimate(cts:search(/,
    cts:and-query((
    cts:directory-query('/LegalCompass/denormalized-data/ALI_RE_Attorney_Data/'),
	$firm_id_q,
    if($practiceArea ne '') then cts:element-word-query(xs:QName('ALI_RE_Attorney_Data:practices'),$PracticeAreas,('wildcarded','case-insensitive')) else(),
    if($location_val != '') then cts:element-word-query(xs:QName('ALI_RE_Attorney_Data:location'),$location_val,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:std_school'), xs:string($company))
    ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:title'), ('Other Counsel/Attorney'),"case-insensitive")
    )))) 
  let $othercouselcountplus := xdmp:estimate(cts:search(/,
    cts:and-query((
    cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
	,$re_id_q
      ,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
      ,if($location_val != '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $location_val,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('tblrermovechanges:std_school'), xs:string($company))
    ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Other Counsel/Attorney'),"case-insensitive")
    ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('added'))
    ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
  let $othercouselcountminus := xdmp:estimate(cts:search(/,
    cts:and-query((
    cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
	,$re_id_q
      ,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
      ,if($location_val != '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $location_val,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('tblrermovechanges:std_school'), xs:string($company))
    ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Other Counsel/Attorney'),"case-insensitive")
    ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('removed'))
    ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
  let $admincount := xdmp:estimate(cts:search(/,
    cts:and-query((
    cts:directory-query('/LegalCompass/denormalized-data/ALI_RE_Attorney_Data/'),
	$firm_id_q,
    if($practiceArea ne '') then cts:element-word-query(xs:QName('ALI_RE_Attorney_Data:practices'),$PracticeAreas,('wildcarded','case-insensitive')) else(),
    if($location_val != '') then cts:element-word-query(xs:QName('ALI_RE_Attorney_Data:location'),$location_val,('wildcarded','case-insensitive')) else(),
    cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:std_school'), xs:string($company)),
    cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:title'), ('Administrative / Support Staff'),"case-insensitive")
    )))) 
     let $admincountplus := xdmp:estimate(cts:search(/,
    cts:and-query((
    cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
	,$re_id_q
      ,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
      ,if($location_val != '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $location_val,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('tblrermovechanges:std_school'), xs:string($company))
    ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Administrative / Support Staff'),"case-insensitive")
    ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('added'))
    ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
     let $admincountminus := xdmp:estimate(cts:search(/,
    cts:and-query((
    cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
	,$re_id_q
      ,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
      ,if($location_val != '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $location_val,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('tblrermovechanges:std_school'), xs:string($company))
    ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Administrative / Support Staff'),"case-insensitive")
    ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('removed'))
    ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
    
  let $othercount :=  xdmp:estimate(cts:search(/,
    cts:and-query((
      cts:directory-query('/LegalCompass/denormalized-data/ALI_RE_Attorney_Data/'),
	  $firm_id_q,
      if($practiceArea ne '') then cts:element-word-query(xs:QName('ALI_RE_Attorney_Data:practices'),$PracticeAreas,('wildcarded','case-insensitive')) else(),
      if($location_val != '') then cts:element-word-query(xs:QName('ALI_RE_Attorney_Data:location'),$location_val,('wildcarded','case-insensitive')) else()
      ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:std_school'), xs:string($company))
      ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:title'), ('Other'),"case-insensitive")))))
      
  let $othercountplus :=  xdmp:estimate(cts:search(/,
    cts:and-query((
   cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
   ,$re_id_q
      ,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ('wildcarded','case-insensitive')) else()
      ,if($location_val != '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $location_val,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('tblrermovechanges:std_school'), xs:string($company))
    ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Other'),"case-insensitive")
    ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('added'))
    ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
    
  let $othercountminus :=  xdmp:estimate(cts:search(/,
    cts:and-query((
    cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
	,$re_id_q
      ,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
      ,if($location_val != '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $location_val,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('tblrermovechanges:std_school'), xs:string($company))
    ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Other'),"case-insensitive")
    ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('removed'))
    ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))

    
		 let $diff := xs:decimal($headcountplus)-xs:decimal($headcountminus)
		 let $div := if($headcount ne 0) then ($diff div xs:decimal($headcount))*xs:double(100) else 0
     
    let $_ := (map:put($res-object,'schoolName',$company),
                map:put($res-object,'headCount',$headcount),
                map:put($res-object,'partnerCount',$partnercount),
                map:put($res-object,'associateCount',$associatecount),
                map:put($res-object,'otherCouselCount',$othercouselcount),
                map:put($res-object,'adminCount',$admincount),
                map:put($res-object,'otherCount',$othercount),
                map:put($res-object,'headCountPlus',$headcountplus),
                map:put($res-object,'headCountMinus',$headcountminus),
                map:put($res-object,'partnerCountPlus',$partnercountplus),
                map:put($res-object,'partnerCountMinus',$partnercountminus),
                map:put($res-object,'associateCountPlus',$associatecountplus),
                map:put($res-object,'associateCountMinus',$associatecountminus),
                map:put($res-object,'otherCouselCountPlus',$othercouselcountplus),
                map:put($res-object,'otherCouselCountMinus',$othercouselcountminus),
                map:put($res-object,'adminCountPlus',$admincountplus),
                map:put($res-object,'adminCountMinus',$admincountminus),
                map:put($res-object,'otherCountPlus',$othercountplus),
                map:put($res-object,'otherCountMinus',$othercountminus),
				map:put($res-object,'Changes',fn:round($div)),
				map:put($res-object,'totalCount',$totalCount),
				map:put($res-object,'loc',$GeoGraphicRegions)
				)
    let $_ := json:array-push($res-array,$res-object)
    return ()
  
  return $res-array
  
		
};

declare function firm:sp_GetLawFirmStatics_LawSchool4(
	 $PageNo
	,$PageSize
	,$firmIds
	,$practiceArea
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
	
	let $direction := if($sortDirection eq 'asc') then 'ascending' else 'descending'
    let $orderBy :=cts:index-order(cts:element-reference(xs:QName('ALI_RE_Attorney_Data:std_school')) ,$direction)
	
	let $fromDate := fn:tokenize($fromDate,'T')[1]
	let $toDate := fn:tokenize($toDate,'T')[1]
	 
		 let $location_val := if(($Cities !='') or ($States !='') or ($Countries != '') or ($GeoGraphicRegions !='') or  ($UsRegions !='')) then
		 cts:values(cts:element-reference(xs:QName('city:std_loc')),(),(),
		 cts:and-query((
			cts:directory-query($config:RD-CITY-PATH)
			 ,if($Cities ne '') then cts:element-value-query(xs:QName('city:city'), $Cities, ('case-insensitive')) else()
			 ,if($States ne '') then cts:element-value-query(xs:QName('city:state'), $States, ('case-insensitive')) else()
			 ,if($Countries ne '') then cts:element-value-query(xs:QName('city:country'), $Countries, ('case-insensitive')) else()
			 ,if($GeoGraphicRegions ne '') then cts:element-value-query(xs:QName('city:geographic_region'), $GeoGraphicRegions, ('case-insensitive')) else()
			 ,if($UsRegions ne '') then cts:element-value-query(xs:QName('city:us_region'), $UsRegions, ('case-insensitive')) else()
		 )))
	  else ()
	  
	  
	let $date_q := if (($fromDate != '') and ($toDate != '')) then (
			 cts:element-range-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:last_action_date'), '>=', xs:date($fromDate))
			,cts:element-range-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:last_action_date'), '<=', xs:date($toDate))
		)
		else ()
	
	let $PracticeAreas := if ($practiceArea != '') then 
			let $key := fn:tokenize($practiceArea,'[|]')
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
		,if ($practiceArea) then cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:practice_area'),$PracticeAreas,('wildcarded', 'case-insensitive')) else ()
		,if ($lawschools != '') then cts:element-word-query(xs:QName('ALI_RE_Attorney_Data:std_school'),$lawschools,('whitespace-insensitive', 'wildcarded', 'case-insensitive')) else ()
		,$firm_id_q
	  )

	
	let $attorney_search := cts:element-values(xs:QName('ALI_RE_Attorney_Data:std_school'),(),($direction), cts:and-query(($attorney_conditions)))
	
	let $schoolCount := 0
	let $stdSchoolName := if($firmSizefrom ne 0 and $firmSizeTo ne 0) then for $company1 in $attorney_search
						 	
							let $headcount := xdmp:estimate(cts:search(/,
												cts:and-query((
													cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/')
													,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrer:practices'), $PracticeAreas, ('wildcarded','case-insensitive')) else()
													,if($location_val != '') then cts:element-value-query(xs:QName('tblrer:location'), $location_val) else()
													
													,cts:element-value-query(xs:QName('tblrer:std_school'), xs:string($company1))
													,cts:element-value-query(xs:QName('tblrer:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
													))))
							let $_ := if($headcount ge $firmSizefrom and $headcount le $firmSizeTo) then (xdmp:set($schoolCount, $schoolCount + 1),$schoolCount) else (xdmp:set($schoolCount, $schoolCount),$schoolCount)
							order by $headcount ge $firmSizefrom and $headcount le $firmSizeTo descending
							return $company1 else()
							
	
	let $res-array := json:array()
	
	let $stdSchool := if($firmSizefrom ne 0 and $firmSizeTo ne 0) then $stdSchoolName else $attorney_search
    let $totalCount := if($firmSizefrom ne 0 and $firmSizeTo ne 0) then $schoolCount else count($stdSchool)
	let $loopData1 := for $company in $stdSchool[$start to $end]
	let $res-object := json:object() 
	let $headcount := xdmp:estimate(cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/')
							,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrer:practices'), $PracticeAreas, ('wildcarded','case-insensitive')) else()
							,if($location_val != '') then cts:element-value-query(xs:QName('tblrer:location'), $location_val) else()
							
							,cts:element-value-query(xs:QName('tblrer:std_school'), xs:string($company))
							,cts:element-value-query(xs:QName('tblrer:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
							))))
							
	let $headcountplus := xdmp:estimate(cts:search(/,
    cts:and-query((
    cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
    ,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
    ,if($location_val != '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $location_val,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('tblrermovechanges:std_school'), xs:string($company))
    ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
    ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'),'added')
    ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
	
 let $headcountminus := xdmp:estimate(cts:search(/,
    cts:and-query((
      cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
      ,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
      ,if($location_val != '') then cts:element-value-query(xs:QName('tblrermovechanges:location'), $location_val,('wildcarded','case-insensitive')) else()
      ,cts:element-value-query(xs:QName('tblrermovechanges:std_school'), xs:string($company))
      ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
      ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'),'removed')   
      ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
				
  let $partnercount := xdmp:estimate(cts:search(/,
    cts:and-query((
    cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/'),
    if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrer:practices'),$PracticeAreas,('wildcarded','case-insensitive')) else(),
    if($location_val != '') then cts:element-word-query(xs:QName('tblrer:location'),$location_val,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('tblrer:std_school'), xs:string($company))
    ,cts:element-value-query(xs:QName('tblrer:title'), ('Partner'))
    ))))
	
  let $partnercountplus := xdmp:estimate(cts:search(/,
    cts:and-query((
   cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
      ,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
      ,if($location_val != '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $location_val,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('tblrermovechanges:std_school'), xs:string($company))
    ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Partner'))
    ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('added'))
    ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
				
  let $partnercountminus := xdmp:estimate(cts:search(/,
    cts:and-query((
      cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
      ,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
      ,if($location_val != '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $location_val,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('tblrermovechanges:std_school'), xs:string($company))
    ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Partner'))
    ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('removed'))
    ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
				
    
  let $associatecount := xdmp:estimate(cts:search(/,
    cts:and-query((
    cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/'),
    if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrer:practices'),$PracticeAreas,('wildcarded','case-insensitive')) else(),
    if($location_val != '') then cts:element-word-query(xs:QName('tblrer:location'),$location_val,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('tblrer:std_school'), xs:string($company))
    ,cts:element-value-query(xs:QName('tblrer:title'), ('Associate'))
    ))))
	
    let $associatecountplus := xdmp:estimate(cts:search(/,
    cts:and-query((
    cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
      ,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
      ,if($location_val != '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $location_val,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('tblrermovechanges:std_school'), xs:string($company))
    ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Associate'))
    ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('added'))
    ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
				
    let $associatecountminus := xdmp:estimate(cts:search(/,
    cts:and-query((
    cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
      ,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
      ,if($location_val != '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $location_val,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('tblrermovechanges:std_school'), xs:string($company))
    ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Associate'))
    ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('removed'))
    ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
    
  let $othercouselcount := xdmp:estimate(cts:search(/,
    cts:and-query((
    cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/'),
    if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrer:practices'),$PracticeAreas,('wildcarded','case-insensitive')) else(),
    if($location_val != '') then cts:element-word-query(xs:QName('tblrer:location'),$location_val,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('tblrer:std_school'), xs:string($company))
    ,cts:element-value-query(xs:QName('tblrer:title'), ('Other Counsel/Attorney'),"case-insensitive")
    )))) 
  let $othercouselcountplus := xdmp:estimate(cts:search(/,
    cts:and-query((
    cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
      ,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
      ,if($location_val != '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $location_val,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('tblrermovechanges:std_school'), xs:string($company))
    ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Other Counsel/Attorney'),"case-insensitive")
    ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('added'))
    ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
  let $othercouselcountminus := xdmp:estimate(cts:search(/,
    cts:and-query((
    cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
      ,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
      ,if($location_val != '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $location_val,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('tblrermovechanges:std_school'), xs:string($company))
    ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Other Counsel/Attorney'),"case-insensitive")
    ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('removed'))
    ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
  let $admincount := xdmp:estimate(cts:search(/,
    cts:and-query((
    cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/'),
    if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrer:practices'),$PracticeAreas,('wildcarded','case-insensitive')) else(),
    if($location_val != '') then cts:element-word-query(xs:QName('tblrer:location'),$location_val,('wildcarded','case-insensitive')) else(),
    cts:element-value-query(xs:QName('tblrer:std_school'), xs:string($company)),
    cts:element-value-query(xs:QName('tblrer:title'), ('Administrative / Support Staff'),"case-insensitive")
    )))) 
     let $admincountplus := xdmp:estimate(cts:search(/,
    cts:and-query((
    cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
      ,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
      ,if($location_val != '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $location_val,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('tblrermovechanges:std_school'), xs:string($company))
    ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Administrative / Support Staff'),"case-insensitive")
    ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('added'))
    ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
     let $admincountminus := xdmp:estimate(cts:search(/,
    cts:and-query((
    cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
      ,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
      ,if($location_val != '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $location_val,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('tblrermovechanges:std_school'), xs:string($company))
    ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Administrative / Support Staff'),"case-insensitive")
    ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('removed'))
    ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
    
  let $othercount :=  xdmp:estimate(cts:search(/,
    cts:and-query((
      cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/'),
      if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrer:practices'),$PracticeAreas,('wildcarded','case-insensitive')) else(),
      if($location_val != '') then cts:element-word-query(xs:QName('tblrer:location'),$location_val,('wildcarded','case-insensitive')) else()
      ,cts:element-value-query(xs:QName('tblrer:std_school'), xs:string($company))
      ,cts:element-value-query(xs:QName('tblrer:title'), ('Other'),"case-insensitive")))))
      
  let $othercountplus :=  xdmp:estimate(cts:search(/,
    cts:and-query((
   cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
      ,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ('wildcarded','case-insensitive')) else()
      ,if($location_val != '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $location_val,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('tblrermovechanges:std_school'), xs:string($company))
    ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Other'),"case-insensitive")
    ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('added'))
    ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
    
  let $othercountminus :=  xdmp:estimate(cts:search(/,
    cts:and-query((
    cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
      ,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
      ,if($location_val != '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $location_val,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('tblrermovechanges:std_school'), xs:string($company))
    ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Other'),"case-insensitive")
    ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('removed'))
    ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))

    
		 let $diff := xs:decimal($headcountplus)-xs:decimal($headcountminus)
		 let $div := if($headcount ne 0) then ($diff div xs:decimal($headcount))*xs:double(100) else 0
     
    let $_ := (map:put($res-object,'schoolName',$company),
                map:put($res-object,'headCount',$headcount),
                map:put($res-object,'partnerCount',$partnercount),
                map:put($res-object,'associateCount',$associatecount),
                map:put($res-object,'otherCouselCount',$othercouselcount),
                map:put($res-object,'adminCount',$admincount),
                map:put($res-object,'otherCount',$othercount),
                map:put($res-object,'headCountPlus',$headcountplus),
                map:put($res-object,'headCountMinus',$headcountminus),
                map:put($res-object,'partnerCountPlus',$partnercountplus),
                map:put($res-object,'partnerCountMinus',$partnercountminus),
                map:put($res-object,'associateCountPlus',$associatecountplus),
                map:put($res-object,'associateCountMinus',$associatecountminus),
                map:put($res-object,'otherCouselCountPlus',$othercouselcountplus),
                map:put($res-object,'otherCouselCountMinus',$othercouselcountminus),
                map:put($res-object,'adminCountPlus',$admincountplus),
                map:put($res-object,'adminCountMinus',$admincountminus),
                map:put($res-object,'otherCountPlus',$othercountplus),
                map:put($res-object,'otherCountMinus',$othercountminus),
				map:put($res-object,'Changes',fn:round($div)),
				map:put($res-object,'totalCount',$totalCount))
    let $_ := json:array-push($res-array,$res-object)
    return ()
  
  return $res-array
		
};

declare function firm:GetReNews1($companyID,$fromDate,$toDate,$PageNo,$PageSize,$sortDirection,$sortBy)
{
  let $start := xs:integer(((xs:integer($PageNo)* xs:integer($PageSize))-xs:integer($PageSize))+1)
  let $end := xs:integer((xs:integer($start) + xs:integer($PageSize)) - 1 )
  
  let $direction := if($sortDirection eq 'asc') then 'ascending' else 'descending'
  (:let $orderBy := cts:index-order(cts:element-reference(xs:QName('data:SortDate')) ,$direction):)
	
  let $res-array := json:array()
  let $result := cts:search(/,
                    cts:and-query((
                      cts:directory-query('/LegalCompass/relational-data/data/'),
                      cts:element-value-query(xs:QName('data:company_id'),$companyID),
                      if($fromDate ne '' and $toDate ne '') then cts:and-query((
					  cts:not-query(cts:element-word-query(xs:QName('data:date_added'),('0/0/0000',''),('wildcarded'))),
                          cts:element-range-query(xs:QName('data:date_added'),'>=',xs:dateTime($fromDate)),
                          cts:element-range-query(xs:QName('data:date_added'),'<=',xs:dateTime($toDate))
                      )) else()
                    )))[xs:integer($start) to xs:integer($end)]
                   
  let $loopData := for $item in $result
                       let $res-obj := json:object()
                       let $dataSource := if($item//data:data_source/text() eq 'RSS') then $item//data:entry_source/text()
                                          else $item//data:data_source/text()
					   let $ds := fn:replace($dataSource,'CompanySite','Firm Site')				  
                       let $_ := (map:put($res-obj,'NewsPublisher',$ds),
                                  map:put($res-obj,'Headline',$item//data:title/text()),
                                  map:put($res-obj,'NewsDate',$item//data:date_added/text()),
                                  map:put($res-obj,'NewsURL',$item//data:link/text()),
                                  map:put($res-obj,'RelatedPractice',$item//data:std_practices/text()),
                                  map:put($res-obj,'Source',$ds),
                                  map:put($res-obj,'Summary',$item//data:descrip/text()),
                                  map:put($res-obj,'Type',$item//data:type/text())
                                  )
                      let $_ :=json:array-push($res-array,$res-obj)            
                      return()
  return $res-array
};