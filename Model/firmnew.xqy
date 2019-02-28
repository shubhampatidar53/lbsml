
xquery version "1.0-ml";
module namespace firmnew = "http://alm.com/firmnew";
import module namespace config = 'http://alm.com/config' at '/common/config.xqy';
declare namespace firmDenom = 'http://alm.com/LegalCompass/lawfirm/dd/organization';
declare namespace UK_50 = 'http://alm.com/LegalCompass/rd/UK_50';
declare namespace AMLAW_200 = 'http://alm.com/LegalCompass/rd/AMLAW_200';
declare namespace Global_100 = 'http://alm.com/LegalCompass/rd/Global_100';

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

declare namespace nlj250 = 'http://alm.com/LegalCompass/rd/NLJ_250';
declare namespace dc20 = 'http://alm.com/LegalCompass/rd/DC20';
declare namespace legaltimes =  'http://alm.com/LegalCompass/rd/Legal_Times_150';
declare namespace ny100 = 'http://alm.com/LegalCompass/rd/NY100';
declare namespace alist = 'http://alm.com/LegalCompass/rd/ALIST';
declare namespace tx100 = 'http://alm.com/LegalCompass/rd/TX100';
declare namespace nljlgbt = "http://alm.com/LegalCompass/rd/NLJ_LGBT";


declare namespace Diversity_Scorecard = 'http://alm.com/LegalCompass/rd/Diversity_Scorecard';
declare namespace FEMALE_SCORECARD = 'http://alm.com/LegalCompass/rd/FEMALE_SCORECARD';

declare namespace CHINA_40 = 'http://alm.com/LegalCompass/rd/CHINA_40';

declare namespace firm-org = 'http://alm.com/LegalCompass/lawfirm/dd/organization';

declare namespace ALI_RE_Attorney_Data = 'http://alm.com/LegalCompass/dd/ALI_RE_Attorney_Data';
declare namespace tblrermovechanges = 'http://alm.com/LegalCompass/dd/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES';
declare namespace TBL_RER_CACHE_ATTORNEY_MOVESCHANGES = 'http://alm.com/LegalCompass/dd/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES';


declare namespace tblrer = "http://alm.com/LegalCompass/dd/TBL_RER_CACHE_ATTORNEY_DATA";
declare namespace LawFirm_PracticeArea = "http://alm.com/LegalCompass/rd/LawFirm_PracticeArea";
declare namespace practices = "http://alm.com/LegalCompass/rd/practices_kws";
declare namespace alidata = "http://alm.com/LegalCompass/rd/FIRMS_ALI_XREF_RE";

declare namespace Law_School_Data = "http://alm.com/LegalCompass/rd/Law_School_Data";

declare namespace GCCompensation = 'http://alm.com/LegalCompass/GLL/rd/GCCompensation';
declare namespace GETCLIENTS = 'http://alm.com/LegalCompass/dd/GETCLIENTS';
declare namespace Pro_Bono= 'http://alm.com/LegalCompass/rd/Pro_Bono';
declare namespace LAWFIRM_MERGERS='http://alm.com/LegalCompass/rd/LAWFIRM_MERGERS';
declare namespace TOPICS_EXPORT = 'http://alm.com/LegalCompass/rd/TOPICS_EXPORT';
declare namespace METRO_AREAS = 'http://alm.com/LegalCompass/rd/METRO_AREAS';

declare namespace AMLaw_Volatility = 'http://alm.com/LegalCompass/rd/AMLaw_Volatility';

declare function firmnew:GetFirmRankingsAdvance()
{
	let $result := xdmp:estimate(cts:search(/,
					  cts:and-query((
						cts:directory-query('/LegalCompass/denormalized-data/law-firm/survey/'),
						cts:element-value-query(xs:QName('firmDenom:OrganizationTypeID'),'1'),
						cts:element-range-query(xs:QName('firmDenom:PUBLISHYEAR'),'=',2017)
						))
					))
					
	return $result				
};

declare function firmnew:getUK50Ids($year)
{			
	let $AMLAW200IDs := cts:element-values(xs:QName('AMLAW_200:ORGANIZATION_ID'),(),(),
	cts:and-query((
		(:cts:directory-query(''),:)
		cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),$year)
	)))
	
	let $GLOBAL100IDs := cts:element-values(xs:QName('Global_100:ORGANIZATION_ID'),(),(),
	cts:and-query((
		(:cts:directory-query(''),:)
		cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),$year)
	)))
	
	let $distinct-ids := fn:distinct-values(($AMLAW200IDs,$GLOBAL100IDs))
	
	let $UK50IDS := cts:element-values(xs:QName('UK_50:ORGANIZATION_ID'),(),(),
	cts:and-query((
		(:cts:directory-query(''),:)
		cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),$year)
		,cts:not-query(cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),($distinct-ids ! xs:string(.))))
	)))
	
	return $UK50IDS	
};

declare function firmnew:GetTopFivePracticeAreas($lawSchoolID)
{
	let $practices := cts:element-values(xs:QName('practices:practice_area'),(),())
	
	let $attorney_conditions := (
		 cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
		 cts:element-word-query(xs:QName('Law_School_Data:std_school_id'),fn:tokenize($lawSchoolID,','))
	  )
	
	(:let $attorney_search := cts:element-values(xs:QName('Law_School_Data:city'),(),(), cts:and-query(($attorney_conditions))):)
	
	
	let $res-array := json:array()
    let $loopData := for $practice in $practices
							let $headcount := xdmp:estimate(cts:search(/,
												cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
													,cts:element-value-query(xs:QName('Law_School_Data:std_school_id'), xs:string($lawSchoolID))
													,cts:element-word-query(xs:QName('Law_School_Data:practices'), $practice,('wildcarded','case-insensitive'))
													,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
													))))
							
							order by $headcount descending
							return $practice
							
	
	let $loopData1 := for $practice in $loopData[1 to 5]
	let $res-object := json:object() 
	
	let $headcount := xdmp:estimate(cts:search(/,
												cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
													,cts:element-value-query(xs:QName('Law_School_Data:std_school_id'), xs:string($lawSchoolID))
													,cts:element-word-query(xs:QName('Law_School_Data:practices'), $practice,('wildcarded','case-insensitive'))
													,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
													))))
	
     
    let $_ := (
				map:put($res-object,'Practice',$practice),
                map:put($res-object,'HeadCount',$headcount)
			  )
    let $_ := json:array-push($res-array,$res-object)
    return ()
  
  return $res-array
};

declare function firmnew:GetTopFiveCities($lawSchoolID)
{
	let $attorney_conditions := (
		 cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
		 cts:element-word-query(xs:QName('Law_School_Data:std_school_id'),fn:tokenize($lawSchoolID,',')),
		 cts:not-query(cts:element-value-query(xs:QName('Law_School_Data:std_loc'),''))
	  )

	
	
	let $attorney_search := cts:element-values(xs:QName('Law_School_Data:std_loc'),(),(), cts:and-query(($attorney_conditions)))
	
	
	let $res-array := json:array()
    let $loopData := for $city in $attorney_search
							let $headcount := xdmp:estimate(cts:search(/,
												cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
													,cts:element-value-query(xs:QName('Law_School_Data:std_school_id'), xs:string($lawSchoolID))
													,cts:element-value-query(xs:QName('Law_School_Data:std_loc'), xs:string($city))
													,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
													))))
							
							order by $headcount descending
							return $city
							
	
	let $loopData1 := for $city in $loopData[1 to 5]
	let $res-object := json:object() 
	
	let $headcount := xdmp:estimate(cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
							,cts:element-value-query(xs:QName('Law_School_Data:std_school_id'), xs:string($lawSchoolID))
							,cts:element-value-query(xs:QName('Law_School_Data:std_loc'), xs:string($city))
							,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
							))))
	
     
    let $_ := (map:put($res-object,'City',$city),
                map:put($res-object,'HeadCount',$headcount)
			  )
    let $_ := json:array-push($res-array,$res-object)
    return ()
  
  return $res-array
	
};

declare function firmnew:GetLawFirmComparisonResult($schoolIDs)
{
	let $schoolID := if($schoolIDs) then fn:tokenize($schoolIDs,',') else()
	
	let $attorney_conditions := (
		 cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
		 cts:element-word-query(xs:QName('Law_School_Data:std_school_id'),$schoolID)
	  )

	
	
	let $attorney_search := cts:element-values(xs:QName('Law_School_Data:std_school'),(),(), cts:and-query(($attorney_conditions)))
	
	let $totalCount := count($attorney_search)								
	let $res-array := json:array()
    
	let $loopData1 := for $school in $attorney_search
	let $res-object := json:object() 
	
	let $totalLawyers := xdmp:estimate(cts:search(/,
						  cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
							,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($school))
							,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
							))))
				
	let $partnercount := xdmp:estimate(cts:search(/,
		cts:and-query((
		cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
	    ,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($school))
		,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner'))
		))))
	
 
	
    
    let $associatecount := xdmp:estimate(cts:search(/,
		cts:and-query((
		cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
	    ,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($school))
		,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Associate'))
		))))
	
 
	let $femalecount := xdmp:estimate(cts:search(/,
		cts:and-query((
		cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
	    ,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($school))
		,cts:element-value-query(xs:QName('Law_School_Data:gender'), 'f',('case-insensitive'))
		,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))	
		)))) 
 
  
      
   let $partneramlaw1to25 := xdmp:estimate(cts:search(/,
    cts:and-query((
    cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
	,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($school))
    ,cts:and-query((
		cts:element-range-query(xs:QName('Law_School_Data:amlaw_rank'),'>=',1),
		cts:element-range-query(xs:QName('Law_School_Data:amlaw_rank'),'<=',25)
		))
	,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner'),("case-insensitive"))	
    ))))
	
	let $partneramlaw26to100 := xdmp:estimate(cts:search(/,
    cts:and-query((
    cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
	,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($school))
    ,cts:and-query((
		cts:element-range-query(xs:QName('Law_School_Data:amlaw_rank'),'>=',26),
		cts:element-range-query(xs:QName('Law_School_Data:amlaw_rank'),'<=',100)
		))
	,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner'),("case-insensitive"))	
    ))))
	
	let $partneramlaw101to200 := xdmp:estimate(cts:search(/,
    cts:and-query((
    cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
	,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($school))
    ,cts:and-query((
		cts:element-range-query(xs:QName('Law_School_Data:amlaw_rank'),'>=',101),
		cts:element-range-query(xs:QName('Law_School_Data:amlaw_rank'),'<=',200)
		))
	,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner'),("case-insensitive"))	
    ))))
	
	let $associateamlaw1to25 := xdmp:estimate(cts:search(/,
    cts:and-query((
    cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
	,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($school))
    ,cts:and-query((
		cts:element-range-query(xs:QName('Law_School_Data:amlaw_rank'),'>=',1),
		cts:element-range-query(xs:QName('Law_School_Data:amlaw_rank'),'<=',25)
		))
	,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Associate'),("case-insensitive"))	
    ))))
	
	let $associateamlaw26to100 := xdmp:estimate(cts:search(/,
    cts:and-query((
    cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
	cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($school))
    ,cts:and-query((
		cts:element-range-query(xs:QName('Law_School_Data:amlaw_rank'),'>=',26),
		cts:element-range-query(xs:QName('Law_School_Data:amlaw_rank'),'<=',100)
		))
	,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Associate'),("case-insensitive"))	
    ))))
	
	let $associateamlaw101to200 := xdmp:estimate(cts:search(/,
    cts:and-query((
    cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
	cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($school))
    ,cts:and-query((
		cts:element-range-query(xs:QName('Law_School_Data:amlaw_rank'),'>=',101),
		cts:element-range-query(xs:QName('Law_School_Data:amlaw_rank'),'<=',200)
		))
	,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Associate'),("case-insensitive"))	
    ))))
	
	let $femaleamlaw1to25 := xdmp:estimate(cts:search(/,
    cts:and-query((
    cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
	cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($school))
    ,cts:and-query((
		cts:element-range-query(xs:QName('Law_School_Data:amlaw_rank'),'>=',1),
		cts:element-range-query(xs:QName('Law_School_Data:amlaw_rank'),'<=',25)
		))
	,cts:element-value-query(xs:QName('Law_School_Data:gender'), 'f',('case-insensitive'))
	,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))	
    ))))
	
	let $femaleamlaw26to100 := xdmp:estimate(cts:search(/,
    cts:and-query((
    cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
	cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($school))
    ,cts:and-query((
		cts:element-range-query(xs:QName('Law_School_Data:amlaw_rank'),'>=',26),
		cts:element-range-query(xs:QName('Law_School_Data:amlaw_rank'),'<=',100)
		))
	,cts:element-value-query(xs:QName('Law_School_Data:gender'), 'f',('case-insensitive'))
	,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))	
    ))))
	
	let $femaleamlaw101to200 := xdmp:estimate(cts:search(/,
    cts:and-query((
    cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
	cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($school))
    ,cts:and-query((
		cts:element-range-query(xs:QName('Law_School_Data:amlaw_rank'),'>=',101),
		cts:element-range-query(xs:QName('Law_School_Data:amlaw_rank'),'<=',200)
		))
	,cts:element-value-query(xs:QName('Law_School_Data:gender'), 'f',('case-insensitive'))
	,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))	
    ))))
	
	let $lawyersamlaw1to25 := xdmp:estimate(cts:search(/,
    cts:and-query((
    cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
	cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($school))
    ,cts:and-query((
		cts:element-range-query(xs:QName('Law_School_Data:amlaw_rank'),'>=',1),
		cts:element-range-query(xs:QName('Law_School_Data:amlaw_rank'),'<=',25)
		))
	,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))		
	))))
	
	let $lawyersamlaw26to100 := xdmp:estimate(cts:search(/,
    cts:and-query((
    cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
	cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($school))
    ,cts:and-query((
		cts:element-range-query(xs:QName('Law_School_Data:amlaw_rank'),'>=',26),
		cts:element-range-query(xs:QName('Law_School_Data:amlaw_rank'),'<=',100)
		))
	,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))	
    ))))
	
	let $lawyersamlaw101to200 := xdmp:estimate(cts:search(/,
    cts:and-query((
    cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
	cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($school))
    ,cts:and-query((
		cts:element-range-query(xs:QName('Law_School_Data:amlaw_rank'),'>=',101),
		cts:element-range-query(xs:QName('Law_School_Data:amlaw_rank'),'<=',200)
		))
	,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))		
	))))
	
	let $schoolID := cts:search(/,
								cts:and-query((
								cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
								cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($school))
								)))[1]//Law_School_Data:std_school_id/text()
     
    let $_ := (map:put($res-object,'SchoolName',$school),
                map:put($res-object,'PartnerCount',$partnercount),
			    map:put($res-object,'PartnerAmlaw1To25',$partneramlaw1to25),
                map:put($res-object,'PartnerAmlaw26To100',$partneramlaw26to100),
                map:put($res-object,'PartnerAmlaw101To200',$partneramlaw101to200),
				map:put($res-object,'AssociateCount',$associatecount),
				map:put($res-object,'AssociateAmlaw1To25',$associateamlaw1to25),
				map:put($res-object,'AssociateAmlaw26To100',$associateamlaw26to100),
				map:put($res-object,'AssociateAmlaw101To200',$associateamlaw101to200),
				map:put($res-object,'SchoolID',$schoolID),
				map:put($res-object,'FemaleAttorneys',$femalecount),
				map:put($res-object,'TotalLawyers',$totalLawyers),
				map:put($res-object,'LawyersAmLaw1To25',$lawyersamlaw1to25),
				map:put($res-object,'LawyersAmLaw26To100',$lawyersamlaw26to100),
				map:put($res-object,'LawyersAmLaw101To200',$lawyersamlaw101to200),
				map:put($res-object,'FemaleAmLaw1To25',$femaleamlaw1to25),
				map:put($res-object,'FemaleAmLaw26To100',$femaleamlaw26to100),
				map:put($res-object,'FemaleAmLaw101To200',$femaleamlaw101to200)
				
				)
    let $_ := json:array-push($res-array,$res-object)
    return ()
  
  return $res-array
};

declare function firmnew:GetTopFiveFirms($lawSchoolID)
{
	let $attorney_conditions := (
		 cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
		 cts:element-word-query(xs:QName('Law_School_Data:std_school_id'),fn:tokenize($lawSchoolID,','))
	  )

	
	
	let $attorney_search := cts:element-values(xs:QName('Law_School_Data:firm_id'),(),(), cts:and-query(($attorney_conditions)))
	
	let $res-array := json:array()
    let $loopData := for $firmID in $attorney_search
							let $headcount := xdmp:estimate(cts:search(/,
												cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
													,cts:element-value-query(xs:QName('Law_School_Data:std_school_id'), xs:string($lawSchoolID))
													,cts:element-value-query(xs:QName('Law_School_Data:firm_id'), xs:string($firmID))
													,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
													))))
							
							order by $headcount descending
							return $firmID
							
	
	let $firm := $loopData[1 to 5]
	let $loopData1 := for $firmID in $firm
	let $res-object := json:object() 
	
	let $headcount := xdmp:estimate(cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
							,cts:element-value-query(xs:QName('Law_School_Data:std_school_id'), xs:string($lawSchoolID))
							,cts:element-value-query(xs:QName('Law_School_Data:firm_id'), xs:string($firmID))
							,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
							))))
				
	
	let $firmName := cts:search(/,
								cts:and-query((
								cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
								cts:element-value-query(xs:QName('Law_School_Data:firm_id'), xs:string($firmID))
								)))[1]//Law_School_Data:firm_name/text()
	let $aliID := cts:search(/,
								cts:and-query((
								cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
								cts:element-value-query(xs:QName('Law_School_Data:firm_id'), xs:string($firmID))
								)))[1]//Law_School_Data:ALI_ID/text()							
     
    let $_ := (map:put($res-object,'FirmID',$aliID),
                map:put($res-object,'FirmName',$firmName),
			    map:put($res-object,'HeadCount',$headcount)
				)
    let $_ := json:array-push($res-array,$res-object)
    return ()
  
  return $res-array
	
};

declare function firmnew:GetTop5LawSchools(
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
	,$lawSchoolID
	,$isPrimaryPracticeArea
)
{
	let $isPrimaryPracticeArea := if($isPrimaryPracticeArea ne '') then $isPrimaryPracticeArea else 'false'
	let $start := xs:integer(((xs:integer($PageNo)* xs:integer($PageSize))-xs:integer($PageSize))+1)
	let $end := xs:integer((xs:integer($start) + xs:integer($PageSize)) - 1 )
	
	let $fromDate := fn:tokenize($fromDate,'T')[1]
	let $toDate := fn:tokenize($toDate,'T')[1]
	
	
		 
		 let $cities := if($Cities !='') then for $item in $Cities
							return fn:replace($item , '-',', ')
		else ()
	
		 
		 let $location_val := if(($Cities !='') or ($States !='') or ($Countries != '') or ($GeoGraphicRegions !='') or  ($UsRegions !='')) then
		 cts:values(cts:element-reference(xs:QName('city:std_loc')),(),(),
		 cts:and-query((
			cts:directory-query($config:RD-CITY-PATH)
			 ,if($Cities != '') then cts:element-value-query(xs:QName('city:city'), $cities, ('case-insensitive')) else()
			 ,if($States != '') then cts:element-value-query(xs:QName('city:state'), fn:tokenize($States,','), ('case-insensitive')) else()
			 ,if($Countries != '') then cts:element-value-query(xs:QName('city:country'), fn:tokenize($Countries,','), ('case-insensitive')) else()
			 ,if($GeoGraphicRegions != '') then cts:element-value-query(xs:QName('city:geographic_region'), $GeoGraphicRegions, ('case-insensitive')) else()
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
					cts:element-value-query(xs:QName('practices_kws:practice_area'),$key, ('wildcarded', 'case-insensitive'))
				)))
			return $res
		else ()
	
	
	let $firm_id_q := if ($firmIds != '') then
			let $firmIds := fn:tokenize($firmIds,',')
			return cts:element-value-query(xs:QName('Law_School_Data:RE_ID'),$firmIds)
		else ()
		
	
		
	let $re_id_q := if ($firmIds != '') then
			let $firmIds := fn:tokenize($firmIds,',')
			return cts:element-value-query(xs:QName('TBL_RER_CACHE_ATTORNEY_MOVESCHANGES:firm_id'),$firmIds)
		else ()
	
	let $attorney_conditions := (
		 cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
		 ,$firm_id_q
		,if ($location_val != '') then cts:element-value-query(xs:QName('Law_School_Data:location'),$location_val,('case-insensitive')) else ()
		(: ,cts:not-query(cts:element-value-query(xs:QName('Law_School_Data:std_school'),('','College of Law'),('case-insensitive'))) :)
		,cts:not-query(cts:element-value-query(xs:QName('Law_School_Data:std_school'),('')))
		,if ($practiceArea != '') then 
				if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-value-query(xs:QName('Law_School_Data:practice_area'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
				else cts:element-value-query(xs:QName('Law_School_Data:primary_practice'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
		 else ()
		,if ($lawschools != '') then cts:element-word-query(xs:QName('Law_School_Data:std_school'),$lawschools,('whitespace-insensitive', 'wildcarded', 'case-insensitive')) else ()
		,if ($lawSchoolID != '') then cts:element-word-query(xs:QName('Law_School_Data:std_school_id'),fn:tokenize($lawSchoolID,',')) else()
	  )

	
	
	let $attorney_search := cts:element-values(xs:QName('Law_School_Data:std_school'),(),(), cts:and-query(($attorney_conditions)))
	
	let $totalCount := count($attorney_search)								
	let $res-array := json:array()
    let $loopData :=if($firmSizefrom ne 0 and $firmSizeTo ne 0) then if($sortBy eq 'schoolName') then if($sortDirection eq 'asc') then  for $school in $attorney_search
							
							order by $school ascending
							return $school
							
							else for $school in $attorney_search
							order by $school descending
							return $school
							
					else if($sortBy eq 'headCount' or $sortBy eq 'lawyer') then if($sortDirection eq 'asc') then  for $school in $attorney_search
							
							let $headcount := xdmp:estimate(cts:search(/,
									cts:and-query((
										cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
										$firm_id_q
										,if ($practiceArea != '') then 
												if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-value-query(xs:QName('Law_School_Data:practice_area'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
												else cts:element-value-query(xs:QName('Law_School_Data:primary_practice'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
										 else ()
										,if($location_val != '') then cts:element-value-query(xs:QName('Law_School_Data:location'), $location_val) else()
										
										,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($school))
										,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
										)))) 

							let $result := if($headcount ne 0) then $headcount else 1000000
							
							order by $result ge $firmSizefrom and $result le $firmSizeTo descending

							return $school
							
							else for $school in $attorney_search
								
							let $headcount := xdmp:estimate(cts:search(/,
									cts:and-query((
										cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
										$firm_id_q
										,if ($practiceArea != '') then 
												if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-value-query(xs:QName('Law_School_Data:practice_area'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
												else cts:element-value-query(xs:QName('Law_School_Data:primary_practice'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
										 else ()
										,if($location_val != '') then cts:element-value-query(xs:QName('Law_School_Data:location'), $location_val) else()
										
										,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($school))
										,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
										)))) 
										
							order by $headcount ge $firmSizefrom and $headcount le $firmSizeTo descending
							return $school
					
					else if($sortBy eq 'partnerCount') then if($sortDirection eq 'asc') then  for $school in $attorney_search
							
							let $headcount := xdmp:estimate(cts:search(/,
									cts:and-query((
										cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
										$firm_id_q
										,if ($practiceArea != '') then 
												if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-value-query(xs:QName('Law_School_Data:practice_area'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
												else cts:element-value-query(xs:QName('Law_School_Data:primary_practice'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
										 else ()
										,if($location_val != '') then cts:element-value-query(xs:QName('Law_School_Data:location'), $location_val) else()
										
										,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($school))
										,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner'),("case-insensitive"))
										)))) 
							
							let $result := if($headcount ne 0) then $headcount else 1000000
							
							order by $result ge $firmSizefrom and $result le $firmSizeTo descending
							return $school
							
							else for $school in $attorney_search
								
							let $headcount := xdmp:estimate(cts:search(/,
									cts:and-query((
										cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
										$firm_id_q
										,if ($practiceArea != '') then 
												if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-value-query(xs:QName('Law_School_Data:practice_area'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
												else cts:element-value-query(xs:QName('Law_School_Data:primary_practice'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
										 else ()
										,if($location_val != '') then cts:element-value-query(xs:QName('Law_School_Data:location'), $location_val) else()
										
										,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($school))
										,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner'),("case-insensitive"))
										)))) 
										
							order by $headcount ge $firmSizefrom and $headcount le $firmSizeTo descending
							return $school
					
					else if($sortBy eq 'associateCount') then if($sortDirection eq 'asc') then  for $school in $attorney_search
							
							let $headcount := xdmp:estimate(cts:search(/,
									cts:and-query((
										cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
										$firm_id_q
										,if ($practiceArea != '') then 
												if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-value-query(xs:QName('Law_School_Data:practice_area'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
												else cts:element-value-query(xs:QName('Law_School_Data:primary_practice'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
										 else ()
										,if($location_val != '') then cts:element-value-query(xs:QName('Law_School_Data:location'), $location_val) else()
										
										,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($school))
										,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Associate'),("case-insensitive"))
										)))) 
							
							let $result := if($headcount ne 0) then $headcount else 1000000
							
							order by $result ge $firmSizefrom and $result le $firmSizeTo descending
							return $school
							
							else for $school in $attorney_search
								
							let $headcount := xdmp:estimate(cts:search(/,
									cts:and-query((
										cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
										$firm_id_q
										,if ($practiceArea != '') then 
												if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-value-query(xs:QName('Law_School_Data:practice_area'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
												else cts:element-value-query(xs:QName('Law_School_Data:primary_practice'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
										 else ()
										,if($location_val != '') then cts:element-value-query(xs:QName('Law_School_Data:location'), $location_val) else()
										
										,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($school))
										,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Associate'),("case-insensitive"))
										)))) 
										
							order by $headcount ge $firmSizefrom and $headcount le $firmSizeTo descending
							return $school
					
					
					else if($sortBy eq 'FemaleCount') then if($sortDirection eq 'asc') then  for $school in $attorney_search
							
							let $headcount := xdmp:estimate(cts:search(/,
									cts:and-query((
										cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
										$firm_id_q
										,if ($practiceArea != '') then 
												if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-value-query(xs:QName('Law_School_Data:practice_area'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
												else cts:element-value-query(xs:QName('Law_School_Data:primary_practice'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
										 else ()
										,if($location_val != '') then cts:element-value-query(xs:QName('Law_School_Data:location'), $location_val) else()
										
										,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($school))
										,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
										,cts:element-value-query(xs:QName('Law_School_Data:gender'), 'f',('case-insensitive'))
										)))) 
							
							let $result := if($headcount ne 0) then $headcount else 1000000
							
							order by $result ge $firmSizefrom and $result le $firmSizeTo descending
							return $school
							
							else for $school in $attorney_search
								
							let $headcount := xdmp:estimate(cts:search(/,
									cts:and-query((
										cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
										$firm_id_q
										,if ($practiceArea != '') then 
												if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-value-query(xs:QName('Law_School_Data:practice_area'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
												else cts:element-value-query(xs:QName('Law_School_Data:primary_practice'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
										 else ()
										,if($location_val != '') then cts:element-value-query(xs:QName('Law_School_Data:location'), $location_val) else()
										
										,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($school))
										,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
										,cts:element-value-query(xs:QName('Law_School_Data:gender'), 'f',('case-insensitive'))
										)))) 
										
							order by $headcount ge $firmSizefrom and $headcount le $firmSizeTo descending
							return $school
						
					else if($sortBy eq 'otherCouselCount') then if($sortDirection eq 'asc') then  for $school in $attorney_search
							
							let $headcount := xdmp:estimate(cts:search(/,
									cts:and-query((
										cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
										$firm_id_q
										,if ($practiceArea != '') then 
												if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-value-query(xs:QName('Law_School_Data:practice_area'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
												else cts:element-value-query(xs:QName('Law_School_Data:primary_practice'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
										 else ()
										,if($location_val != '') then cts:element-value-query(xs:QName('Law_School_Data:location'), $location_val) else()
										
										,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($school))
										,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Other Counsel/Attorney'),("case-insensitive"))
										)))) 
							
							let $result := if($headcount ne 0) then $headcount else 1000000
							
							order by $result ge $firmSizefrom and $result le $firmSizeTo descending
							return $school
							
							else for $school in $attorney_search
								
							let $headcount := xdmp:estimate(cts:search(/,
									cts:and-query((
										cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
										$firm_id_q
										,if ($practiceArea != '') then 
												if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-value-query(xs:QName('Law_School_Data:practice_area'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
												else cts:element-value-query(xs:QName('Law_School_Data:primary_practice'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
										 else ()
										,if($location_val != '') then cts:element-value-query(xs:QName('Law_School_Data:location'), $location_val) else()
										
										,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($school))
										,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Other Counsel/Attorney'),("case-insensitive"))
										)))) 
										
							order by $headcount ge $firmSizefrom and $headcount le $firmSizeTo descending
							return $school	
							
					else if($sortBy eq 'AmlawRankMedian') then if($sortDirection eq 'asc') then  for $school in $attorney_search
							
								let $headcount := fn:avg(cts:search(/,
													cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
													$firm_id_q,
													if ($practiceArea != '') then 
															if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-value-query(xs:QName('Law_School_Data:practice_area'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
															else cts:element-value-query(xs:QName('Law_School_Data:primary_practice'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
													else (),
													if($location_val != '') then cts:element-word-query(xs:QName('Law_School_Data:location'),$location_val,('wildcarded','case-insensitive')) else()
													
													,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($school))
													,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
													,cts:not-query(cts:element-value-query(xs:QName('Law_School_Data:amlaw_rank'),('','0')))
													)))//Law_School_Data:amlaw_rank/text())
							
							let $result := if($headcount ne 0) then $headcount else 1000000
							
							order by $result ge $firmSizefrom and $result le $firmSizeTo descending
							return $school
							
							else for $school in $attorney_search
								
							let $headcount := fn:avg(cts:search(/,
													cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
													$firm_id_q,
													if ($practiceArea != '') then 
															if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-value-query(xs:QName('Law_School_Data:practice_area'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
															else cts:element-value-query(xs:QName('Law_School_Data:primary_practice'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
													else (),
													if($location_val != '') then cts:element-word-query(xs:QName('Law_School_Data:location'),$location_val,('wildcarded','case-insensitive')) else()
													
													,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($school))
													,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
													,cts:not-query(cts:element-value-query(xs:QName('Law_School_Data:amlaw_rank'),('','0')))
													)))//Law_School_Data:amlaw_rank/text())
										
							order by $headcount ge $firmSizefrom and $headcount le $firmSizeTo descending
							return $school		
					
					else for $school in $attorney_search
							
							let $headcount := xdmp:estimate(cts:search(/,
									cts:and-query((
										cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
										$firm_id_q,
										if ($practiceArea != '') then 
															if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-value-query(xs:QName('Law_School_Data:practice_area'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
															else cts:element-value-query(xs:QName('Law_School_Data:primary_practice'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
										else ()
										,if($location_val != '') then cts:element-value-query(xs:QName('Law_School_Data:location'), $location_val) else()
										
										,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($school))
										,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
										,cts:not-query(cts:element-value-query(xs:QName('Law_School_Data:amlaw_rank'),('','0')))
										)))) 
										
							order by $headcount ge $firmSizefrom and $headcount le $firmSizeTo descending
							return $school	
	
		else if($sortBy eq 'schoolName') then if($sortDirection eq 'asc') then  for $school in $attorney_search
							
							order by $school ascending
							return $school
							
							else for $school in $attorney_search
							order by $school descending
							return $school
							
					else if($sortBy eq 'headCount' or $sortBy eq 'lawyer') then if($sortDirection eq 'asc') then  for $school in $attorney_search
							
							let $headcount := xdmp:estimate(cts:search(/,
									cts:and-query((
										cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
										$firm_id_q,
										if ($practiceArea != '') then 
															if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-value-query(xs:QName('Law_School_Data:practice_area'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
															else cts:element-value-query(xs:QName('Law_School_Data:primary_practice'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
													else ()
										,if($location_val != '') then cts:element-value-query(xs:QName('Law_School_Data:location'), $location_val) else()
										
										,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($school))
										,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
										)))) 
							
							let $result := if($headcount ne 0) then $headcount else 1000000

							order by $result ascending
							return $school
							
							else for $school in $attorney_search
								
							let $headcount := xdmp:estimate(cts:search(/,
									cts:and-query((
										cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
										$firm_id_q,
										if ($practiceArea != '') then 
															if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-value-query(xs:QName('Law_School_Data:practice_area'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
															else cts:element-value-query(xs:QName('Law_School_Data:primary_practice'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
													else ()
										,if($location_val != '') then cts:element-value-query(xs:QName('Law_School_Data:location'), $location_val) else()
										
										,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($school))
										,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
										)))) 

							
							order by $headcount descending
							return $school
					
					else if($sortBy eq 'partnerCount') then if($sortDirection eq 'asc') then  for $school in $attorney_search
							
							let $headcount := xdmp:estimate(cts:search(/,
									cts:and-query((
										cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
										$firm_id_q
										,if ($practiceArea != '') then 
															if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-value-query(xs:QName('Law_School_Data:practice_area'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
															else cts:element-value-query(xs:QName('Law_School_Data:primary_practice'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
													else ()
										,if($location_val != '') then cts:element-value-query(xs:QName('Law_School_Data:location'), $location_val) else()
										
										,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($school))
										,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner'),("case-insensitive"))
										)))) 
							
							let $result := if($headcount ne 0) then $headcount else 1000000

							order by $result ascending
							return $school
							
							else for $school in $attorney_search
								
							let $headcount := xdmp:estimate(cts:search(/,
									cts:and-query((
										cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
										$firm_id_q
										,if ($practiceArea != '') then 
															if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-value-query(xs:QName('Law_School_Data:practice_area'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
															else cts:element-value-query(xs:QName('Law_School_Data:primary_practice'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
													else ()
										,if($location_val != '') then cts:element-value-query(xs:QName('Law_School_Data:location'), $location_val) else()
										
										,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($school))
										,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner'),("case-insensitive"))
										)))) 
										
							order by $headcount descending
							return $school
					
					else if($sortBy eq 'associateCount') then if($sortDirection eq 'asc') then  for $school in $attorney_search
							
							let $headcount := xdmp:estimate(cts:search(/,
									cts:and-query((
										cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
										$firm_id_q
										,if ($practiceArea != '') then 
															if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-value-query(xs:QName('Law_School_Data:practice_area'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
															else cts:element-value-query(xs:QName('Law_School_Data:primary_practice'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
													else ()
										,if($location_val != '') then cts:element-value-query(xs:QName('Law_School_Data:location'), $location_val) else()
										
										,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($school))
										,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Associate'),("case-insensitive"))
										)))) 
							
							let $result := if($headcount ne 0) then $headcount else 1000000

							order by $result ascending
							return $school
							
							else for $school in $attorney_search
								
							let $headcount := xdmp:estimate(cts:search(/,
									cts:and-query((
										cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
										$firm_id_q
										,if ($practiceArea != '') then 
															if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-value-query(xs:QName('Law_School_Data:practice_area'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
															else cts:element-value-query(xs:QName('Law_School_Data:primary_practice'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
													else ()
										,if($location_val != '') then cts:element-value-query(xs:QName('Law_School_Data:location'), $location_val) else()
										
										,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($school))
										,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Associate'),("case-insensitive"))
										)))) 
										
							order by $headcount descending
							return $school
					
					
					else if($sortBy eq 'FemaleCount') then if($sortDirection eq 'asc') then  for $school in $attorney_search
							
							let $headcount := xdmp:estimate(cts:search(/,
									cts:and-query((
										cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
										$firm_id_q
										,if ($practiceArea != '') then 
															if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-value-query(xs:QName('Law_School_Data:practice_area'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
															else cts:element-value-query(xs:QName('Law_School_Data:primary_practice'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
													else ()
										,if($location_val != '') then cts:element-value-query(xs:QName('Law_School_Data:location'), $location_val) else()
										
										,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($school))
										,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
										,cts:element-value-query(xs:QName('Law_School_Data:gender'), 'f',('case-insensitive'))
										)))) 
							
							let $result := if($headcount ne 0) then $headcount else 1000000

							order by $result ascending
							return $school
							
							else for $school in $attorney_search
								
							let $headcount := xdmp:estimate(cts:search(/,
									cts:and-query((
										cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
										$firm_id_q
										,if ($practiceArea != '') then 
															if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-value-query(xs:QName('Law_School_Data:practice_area'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
															else cts:element-value-query(xs:QName('Law_School_Data:primary_practice'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
													else ()
										,if($location_val != '') then cts:element-value-query(xs:QName('Law_School_Data:location'), $location_val) else()
										
										,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($school))
										,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
										,cts:element-value-query(xs:QName('Law_School_Data:gender'), 'f',('case-insensitive'))
										)))) 
										
							order by $headcount descending
							return $school
						
					else if($sortBy eq 'otherCouselCount') then if($sortDirection eq 'asc') then  for $school in $attorney_search
							
							let $headcount := xdmp:estimate(cts:search(/,
									cts:and-query((
										cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
										$firm_id_q
										,if ($practiceArea != '') then 
															if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-value-query(xs:QName('Law_School_Data:practice_area'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
															else cts:element-value-query(xs:QName('Law_School_Data:primary_practice'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
													else ()
										,if($location_val != '') then cts:element-value-query(xs:QName('Law_School_Data:location'), $location_val) else()
										
										,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($school))
										,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Other Counsel/Attorney'),("case-insensitive"))
										)))) 
							
							let $result := if($headcount ne 0) then $headcount else 1000000

							order by $result ascending
							return $school
							
							else for $school in $attorney_search
								
							let $headcount := xdmp:estimate(cts:search(/,
									cts:and-query((
										cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
										$firm_id_q
										,if ($practiceArea != '') then 
															if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-value-query(xs:QName('Law_School_Data:practice_area'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
															else cts:element-value-query(xs:QName('Law_School_Data:primary_practice'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
													else ()
										,if($location_val != '') then cts:element-value-query(xs:QName('Law_School_Data:location'), $location_val) else()
										
										,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($school))
										,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Other Counsel/Attorney'),("case-insensitive"))
										)))) 
										
							order by $headcount descending
							return $school	
							
					else if($sortBy eq 'AmlawRankMedian') then if($sortDirection eq 'asc') then  for $school in $attorney_search
							
								let $headcount := fn:avg(cts:search(/,
													cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
													$firm_id_q,
													if ($practiceArea != '') then 
															if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-value-query(xs:QName('Law_School_Data:practice_area'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
															else cts:element-value-query(xs:QName('Law_School_Data:primary_practice'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
													else (),
													if($location_val != '') then cts:element-word-query(xs:QName('Law_School_Data:location'),$location_val,('wildcarded','case-insensitive')) else()
													
													,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($school))
													,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
													,cts:not-query(cts:element-value-query(xs:QName('Law_School_Data:amlaw_rank'),('','0')))
													)))//Law_School_Data:amlaw_rank/text())
							
							let $result := if($headcount ne 0) then $headcount else 1000000

							order by $result ascending
							return $school
							
							else for $school in $attorney_search
								
							let $headcount := fn:avg(cts:search(/,
													cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
													$firm_id_q,
													if ($practiceArea != '') then 
															if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-value-query(xs:QName('Law_School_Data:practice_area'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
															else cts:element-value-query(xs:QName('Law_School_Data:primary_practice'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
													else (),
													if($location_val != '') then cts:element-word-query(xs:QName('Law_School_Data:location'),$location_val,('wildcarded','case-insensitive')) else()
													
													,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($school))
													,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
													,cts:not-query(cts:element-value-query(xs:QName('Law_School_Data:amlaw_rank'),('','0')))
													)))//Law_School_Data:amlaw_rank/text())
										
							order by $headcount descending
							return $school		
					
					else for $school in $attorney_search
							
							let $headcount := xdmp:estimate(cts:search(/,
									cts:and-query((
										cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
										$firm_id_q
										,if ($practiceArea != '') then 
															if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-value-query(xs:QName('Law_School_Data:practice_area'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
															else cts:element-value-query(xs:QName('Law_School_Data:primary_practice'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
													else ()
										,if($location_val != '') then cts:element-value-query(xs:QName('Law_School_Data:location'), $location_val) else()
										
										,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($school))
										,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
										,cts:not-query(cts:element-value-query(xs:QName('Law_School_Data:amlaw_rank'),('','0')))
										)))) 
										
							order by $headcount descending
							return $school	
										
	let $schoolNames := $loopData[$start to $end]	
	
	let $loopData1 := for $company in $schoolNames
	let $res-object := json:object() 
	let $headcount := xdmp:estimate(cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
							$firm_id_q
							,if ($practiceArea != '') then 
															if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-value-query(xs:QName('Law_School_Data:practice_area'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
															else cts:element-value-query(xs:QName('Law_School_Data:primary_practice'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
													else ()
							,if($location_val != '') then cts:element-value-query(xs:QName('Law_School_Data:location'), $location_val) else()
							
							,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($company))
							,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
							)))) 
							
	
	
 
				
  let $partnercount := xdmp:estimate(cts:search(/,
								cts:and-query((
								cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
								$firm_id_q,
								if ($practiceArea != '') then 
															if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-value-query(xs:QName('Law_School_Data:practice_area'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
															else cts:element-value-query(xs:QName('Law_School_Data:primary_practice'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
													else (),
								if($location_val != '') then cts:element-word-query(xs:QName('Law_School_Data:location'),$location_val,('wildcarded','case-insensitive')) else()
								
								,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($company))
								,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner'))
								))))
	
 
	let $admincount := xdmp:estimate(cts:search(/,
								cts:and-query((
								cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
								$firm_id_q,
								if ($practiceArea != '') then 
															if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-value-query(xs:QName('Law_School_Data:practice_area'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
															else cts:element-value-query(xs:QName('Law_School_Data:primary_practice'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
													else (),
								if($location_val != '') then cts:element-word-query(xs:QName('Law_School_Data:location'),$location_val,('wildcarded','case-insensitive')) else()
								
								,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($company)),
								cts:element-value-query(xs:QName('Law_School_Data:title'), ('Administrative / Support Staff'),"case-insensitive")
								)))) 
    
    
  let $othercount :=  xdmp:estimate(cts:search(/,
							cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
							$firm_id_q,
							if ($practiceArea != '') then 
															if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-value-query(xs:QName('Law_School_Data:practice_area'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
															else cts:element-value-query(xs:QName('Law_School_Data:primary_practice'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
													else (),
							if($location_val != '') then cts:element-word-query(xs:QName('Law_School_Data:location'),$location_val,('wildcarded','case-insensitive')) else()
							
							,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($company))
							,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Other'),"case-insensitive")))))			
						
				
    
  let $associatecount := xdmp:estimate(cts:search(/,
								cts:and-query((
								cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
								$firm_id_q,
								if ($practiceArea != '') then 
															if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-value-query(xs:QName('Law_School_Data:practice_area'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
															else cts:element-value-query(xs:QName('Law_School_Data:primary_practice'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
													else (),
								if($location_val != '') then cts:element-word-query(xs:QName('Law_School_Data:location'),$location_val,('wildcarded','case-insensitive')) else()
								
								,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($company))
								,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Associate'))
								))))
	
   
    
  let $othercouselcount := xdmp:estimate(cts:search(/,
									cts:and-query((
									cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
									$firm_id_q,
									if ($practiceArea != '') then 
															if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-value-query(xs:QName('Law_School_Data:practice_area'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
															else cts:element-value-query(xs:QName('Law_School_Data:primary_practice'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
													else (),
									if($location_val != '') then cts:element-word-query(xs:QName('Law_School_Data:location'),$location_val,('wildcarded','case-insensitive')) else()
									
									,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($company))
									,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Other Counsel/Attorney'),"case-insensitive")
									)))) 
	
	let $femalecount := xdmp:estimate(cts:search(/,
									cts:and-query((
									cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
									$firm_id_q,
									if ($practiceArea != '') then 
															if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-value-query(xs:QName('Law_School_Data:practice_area'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
															else cts:element-value-query(xs:QName('Law_School_Data:primary_practice'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
													else (),
									if($location_val != '') then cts:element-word-query(xs:QName('Law_School_Data:location'),$location_val,('wildcarded','case-insensitive')) else()
									
									,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($company))
									,cts:element-value-query(xs:QName('Law_School_Data:gender'), 'F',('case-insensitive'))
									,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))	
									)))) 
 
  
      
   let $amlaw1to25 := xdmp:estimate(cts:search(/,
									cts:and-query((
									cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
									$firm_id_q,
									if ($practiceArea != '') then 
															if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-value-query(xs:QName('Law_School_Data:practice_area'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
															else cts:element-value-query(xs:QName('Law_School_Data:primary_practice'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
													else (),
									if($location_val != '') then cts:element-word-query(xs:QName('Law_School_Data:location'),$location_val,('wildcarded','case-insensitive')) else()
									
									,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($company))
									,cts:and-query((
										cts:element-range-query(xs:QName('Law_School_Data:amlaw_rank'),'>=',1),
										cts:element-range-query(xs:QName('Law_School_Data:amlaw_rank'),'<=',25)
										))
									,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))	
									))))
	
	let $amlaw26to100 := xdmp:estimate(cts:search(/,
								cts:and-query((
								cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
								$firm_id_q,
								if ($practiceArea != '') then 
															if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-value-query(xs:QName('Law_School_Data:practice_area'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
															else cts:element-value-query(xs:QName('Law_School_Data:primary_practice'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
													else (),
								if($location_val != '') then cts:element-word-query(xs:QName('Law_School_Data:location'),$location_val,('wildcarded','case-insensitive')) else()
								
								,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($company))
								,cts:and-query((
									cts:element-range-query(xs:QName('Law_School_Data:amlaw_rank'),'>=',26),
									cts:element-range-query(xs:QName('Law_School_Data:amlaw_rank'),'<=',100)
									))
								,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))	
								))))
	
	let $amlaw101to200 := xdmp:estimate(cts:search(/,
								cts:and-query((
								cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
								$firm_id_q,
								if ($practiceArea != '') then 
															if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-value-query(xs:QName('Law_School_Data:practice_area'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
															else cts:element-value-query(xs:QName('Law_School_Data:primary_practice'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
													else (),
								if($location_val != '') then cts:element-word-query(xs:QName('Law_School_Data:location'),$location_val,('wildcarded','case-insensitive')) else()
								
								,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($company))
								,cts:and-query((
									cts:element-range-query(xs:QName('Law_School_Data:amlaw_rank'),'>=',101),
									cts:element-range-query(xs:QName('Law_School_Data:amlaw_rank'),'<=',200)
									))
								,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))	
								))))
	
	let $amlawrankmedian := fn:avg(cts:search(/,
								cts:and-query((
								cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
								$firm_id_q,
								if ($practiceArea != '') then 
															if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-value-query(xs:QName('Law_School_Data:practice_area'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
															else cts:element-value-query(xs:QName('Law_School_Data:primary_practice'),$PracticeAreas,('wildcarded', 'case-insensitive')) 
													else (),
								if($location_val != '') then cts:element-word-query(xs:QName('Law_School_Data:location'),$location_val,('wildcarded','case-insensitive')) else()
								
								,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($company))
								,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
								,cts:not-query(cts:element-value-query(xs:QName('Law_School_Data:amlaw_rank'),('','0')))
								)))//Law_School_Data:amlaw_rank/text())
	
	
	let $schoolID := cts:search(/,
								cts:and-query((
								cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
								cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($company))
								)))[1]//Law_School_Data:std_school_id/text()
     
    let $_ := (map:put($res-object,'schoolName',$company),
                map:put($res-object,'headCount',if($headcount ne 0) then $headcount else json:null()),
                map:put($res-object,'partnerCount',if($partnercount ne 0) then $partnercount else json:null()),
               
                map:put($res-object,'adminCount',if($admincount ne 0) then $admincount  else json:null()),
                map:put($res-object,'otherCount',if($othercount ne 0) then $othercount  else json:null()),
				 map:put($res-object,'associateCount',if($associatecount ne 0) then $associatecount  else json:null()),
                map:put($res-object,'otherCouselCount',if($othercouselcount ne 0) then $othercouselcount  else json:null() ),
                map:put($res-object,'totalCount',if($totalCount ne 0) then $totalCount  else json:null()),
				map:put($res-object,'AmlawRank1To25',$amlaw1to25),
				map:put($res-object,'AmlawRank26To100',$amlaw26to100),
				map:put($res-object,'AmlawRank101To200',$amlaw101to200),
				map:put($res-object,'SchoolID',$schoolID),
				map:put($res-object,'FemaleCount',if($femalecount ne 0) then $femalecount  else json:null()),
				map:put($res-object,'AmlawRankMedian',if(fn:round($amlawrankmedian) ne 0) then fn:round($amlawrankmedian)  else json:null())
				)
    let $_ := json:array-push($res-array,$res-object)
    return ()
  
  return $res-array
  
		
};

declare function firmnew:GetPracticeAreasByLawSchoolID($lawSchoolID,$sortBy,$sortDirection)
{
	let $practices := cts:element-values(xs:QName('practices:practice_area'),(),())
	
	let $attorney_conditions := (
		 cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
		 cts:element-word-query(xs:QName('Law_School_Data:std_school_id'),fn:tokenize($lawSchoolID,','))
		 ,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
	  )
	
	
	let $res-array := json:array()
    let $loopData := if($sortBy eq 'practiceArea') then if($sortDirection eq 'asc') then  for $practice in $practices
							
							order by $practice ascending
							return $practice
							
							else for $practice in $practices
							
							order by $practice descending
							return $practice
							
					else if($sortBy eq 'headCount') then if($sortDirection eq 'asc') then  for $practice in $practices
							let $headcount := xdmp:estimate(cts:search(/,
												cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
													,cts:element-value-query(xs:QName('Law_School_Data:std_school_id'), xs:string($lawSchoolID))
													,cts:element-word-query(xs:QName('Law_School_Data:practices'), $practice,('wildcarded','case-insensitive'))
													,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
													))))
							
							order by $headcount ascending
							return $practice
							
							else for $practice in $practices
							let $headcount := xdmp:estimate(cts:search(/,
												cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
													,cts:element-value-query(xs:QName('Law_School_Data:std_school_id'), xs:string($lawSchoolID))
													,cts:element-word-query(xs:QName('Law_School_Data:practices'), $practice,('wildcarded','case-insensitive'))
													,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
													))))
							
							order by $headcount descending
							return $practice
					
					else if($sortBy eq 'partnerCount') then if($sortDirection eq 'asc') then  for $practice in $practices
							let $partnerCount := xdmp:estimate(cts:search(/,
												cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
													,cts:element-value-query(xs:QName('Law_School_Data:std_school_id'), xs:string($lawSchoolID))
													,cts:element-word-query(xs:QName('Law_School_Data:practices'), $practice,('wildcarded','case-insensitive'))
													,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner'),("case-insensitive"))
													))))
							
							order by $partnerCount ascending
							return $practice
							
							else for $practice in $practices
							let $partnerCount := xdmp:estimate(cts:search(/,
												cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
													,cts:element-value-query(xs:QName('Law_School_Data:std_school_id'), xs:string($lawSchoolID))
													,cts:element-word-query(xs:QName('Law_School_Data:practices'), $practice,('wildcarded','case-insensitive'))
													,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner'),("case-insensitive"))
													))))
							
							order by $partnerCount descending
							return $practice
							
					else if($sortBy eq 'otherCounselCount') then if($sortDirection eq 'asc') then  for $practice in $practices
							let $otherCounselCount := xdmp:estimate(cts:search(/,
												cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
													,cts:element-value-query(xs:QName('Law_School_Data:std_school_id'), xs:string($lawSchoolID))
													,cts:element-word-query(xs:QName('Law_School_Data:practices'), $practice,('wildcarded','case-insensitive'))
													,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Other Counsel/Attorney'),("case-insensitive"))
													))))
							
							order by $otherCounselCount ascending
							return $practice
							
							else for $practice in $practices
							let $otherCounselCount := xdmp:estimate(cts:search(/,
												cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
													,cts:element-value-query(xs:QName('Law_School_Data:std_school_id'), xs:string($lawSchoolID))
													,cts:element-word-query(xs:QName('Law_School_Data:practices'), $practice,('wildcarded','case-insensitive'))
													,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Other Counsel/Attorney'),("case-insensitive"))
													))))
							
							order by $otherCounselCount descending
							return $practice		
					
					else if($sortBy eq 'associateCount') then if($sortDirection eq 'asc') then  for $practice in $practices
							let $associateCount := xdmp:estimate(cts:search(/,
												cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
													,cts:element-value-query(xs:QName('Law_School_Data:std_school_id'), xs:string($lawSchoolID))
													,cts:element-word-query(xs:QName('Law_School_Data:practices'), $practice,('wildcarded','case-insensitive'))
													,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Associate'),("case-insensitive"))
													))))
							
							order by $associateCount ascending
							return $practice
							
							else for $practice in $practices
							let $associateCount := xdmp:estimate(cts:search(/,
												cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
													,cts:element-value-query(xs:QName('Law_School_Data:std_school_id'), xs:string($lawSchoolID))
													,cts:element-word-query(xs:QName('Law_School_Data:practices'), $practice,('wildcarded','case-insensitive'))
													,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Associate'),("case-insensitive"))
													))))
							
							order by $associateCount descending
							return $practice	
	
					else for $practice in $practices
							let $headcount := xdmp:estimate(cts:search(/,
												cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
													,cts:element-value-query(xs:QName('Law_School_Data:std_school_id'), xs:string($lawSchoolID))
													,cts:element-word-query(xs:QName('Law_School_Data:practices'), $practice,('wildcarded','case-insensitive'))
													,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
													))))
							
							order by $headcount descending
							return $practice
	
	let $loopData1 := for $practice in $loopData
	let $res-object := json:object() 
	
	let $headcount := xdmp:estimate(cts:search(/,
												cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
													,cts:element-value-query(xs:QName('Law_School_Data:std_school_id'), xs:string($lawSchoolID))
													,cts:element-word-query(xs:QName('Law_School_Data:practices'), $practice,('wildcarded','case-insensitive'))
													,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
													))))
													
	let $partnerCount := xdmp:estimate(cts:search(/,
												cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
													,cts:element-value-query(xs:QName('Law_School_Data:std_school_id'), xs:string($lawSchoolID))
													,cts:element-word-query(xs:QName('Law_School_Data:practices'), $practice,('wildcarded','case-insensitive'))
													,cts:element-value-query(xs:QName('Law_School_Data:title'), 'Partner',("case-insensitive"))
													))))
													
	let $associateCount := xdmp:estimate(cts:search(/,
												cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
													,cts:element-value-query(xs:QName('Law_School_Data:std_school_id'), xs:string($lawSchoolID))
													,cts:element-word-query(xs:QName('Law_School_Data:practices'), $practice,('wildcarded','case-insensitive'))
													,cts:element-value-query(xs:QName('Law_School_Data:title'), 'Associate',("case-insensitive"))
													))))

	let $otherCouselCount := xdmp:estimate(cts:search(/,
												cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
													,cts:element-value-query(xs:QName('Law_School_Data:std_school_id'), xs:string($lawSchoolID))
													,cts:element-word-query(xs:QName('Law_School_Data:practices'), $practice,('wildcarded','case-insensitive'))
													,cts:element-value-query(xs:QName('Law_School_Data:title'), 'Other Counsel/Attorney',("case-insensitive"))
													))))												
	
     
    let $_ := (
				map:put($res-object,'Practice',$practice),
                map:put($res-object,'HeadCount',$headcount),
				map:put($res-object,'PartnerCount',$partnerCount),
				map:put($res-object,'AsociateCount',$associateCount),
				map:put($res-object,'OtherCounselCount',$otherCouselCount)
			  )
    let $_ := if($headcount ne 0) then json:array-push($res-array,$res-object) else()
    return ()
  
  return $res-array
};

declare function firmnew:GetCitiesByLawSchoolID($lawSchoolID,$sortBy,$sortDirection)
{

	let $attorney_conditions := (
		 cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
		 cts:element-word-query(xs:QName('Law_School_Data:std_school_id'),fn:tokenize($lawSchoolID,',')),
		 cts:not-query(cts:element-value-query(xs:QName('Law_School_Data:std_loc'),''))
		,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
	  )
	
	let $attorney_search := cts:element-values(xs:QName('Law_School_Data:std_loc'),(),(), cts:and-query(($attorney_conditions)))
	
	let $res-array := json:array()
    let $loopData := if($sortBy eq 'city') then if($sortDirection eq 'asc') then  for $city in $attorney_search
							
							order by $city ascending
							return $city
							
							else for $city in $attorney_search
							
							order by $city descending
							return $city
							
					else if($sortBy eq 'headCount') then if($sortDirection eq 'asc') then  for $city in $attorney_search
							let $headcount := xdmp:estimate(cts:search(/,
												cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
													,cts:element-value-query(xs:QName('Law_School_Data:std_school_id'), xs:string($lawSchoolID))
													,cts:element-value-query(xs:QName('Law_School_Data:std_loc'), xs:string($city))
													,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
													))))
							
							order by $headcount ascending
							return $city
							
							else for $city in $attorney_search
							let $headcount := xdmp:estimate(cts:search(/,
												cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
													,cts:element-value-query(xs:QName('Law_School_Data:std_school_id'), xs:string($lawSchoolID))
													,cts:element-value-query(xs:QName('Law_School_Data:std_loc'), xs:string($city))
													,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
													))))
							
							order by $headcount descending
							return $city
					
					else if($sortBy eq 'partnerCount') then if($sortDirection eq 'asc') then  for $city in $attorney_search
							let $partnerCount := xdmp:estimate(cts:search(/,
												cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
													,cts:element-value-query(xs:QName('Law_School_Data:std_school_id'), xs:string($lawSchoolID))
													,cts:element-value-query(xs:QName('Law_School_Data:std_loc'), xs:string($city))
													,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner'),("case-insensitive"))
													))))
							
							order by $partnerCount ascending
							return $city
							
							else for $city in $attorney_search
							let $partnerCount := xdmp:estimate(cts:search(/,
												cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
													,cts:element-value-query(xs:QName('Law_School_Data:std_school_id'), xs:string($lawSchoolID))
													,cts:element-value-query(xs:QName('Law_School_Data:std_loc'), xs:string($city))
													,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner'),("case-insensitive"))
													))))
							
							order by $partnerCount descending
							return $city
							
					else if($sortBy eq 'otherCounselCount') then if($sortDirection eq 'asc') then  for $city in $attorney_search
							let $otherCounselCount := xdmp:estimate(cts:search(/,
												cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
													,cts:element-value-query(xs:QName('Law_School_Data:std_school_id'), xs:string($lawSchoolID))
													,cts:element-value-query(xs:QName('Law_School_Data:std_loc'), xs:string($city))
													,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Other Counsel/Attorney'),("case-insensitive"))
													))))
							
							order by $otherCounselCount ascending
							return $city
							
							else for $city in $attorney_search
							let $otherCounselCount := xdmp:estimate(cts:search(/,
												cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
													,cts:element-value-query(xs:QName('Law_School_Data:std_school_id'), xs:string($lawSchoolID))
													,cts:element-value-query(xs:QName('Law_School_Data:std_loc'), xs:string($city))
													,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Other Counsel/Attorney'),("case-insensitive"))
													))))
							
							order by $otherCounselCount descending
							return $city		
					
					else if($sortBy eq 'associateCount') then if($sortDirection eq 'asc') then  for $city in $attorney_search
							let $associateCount := xdmp:estimate(cts:search(/,
												cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
													,cts:element-value-query(xs:QName('Law_School_Data:std_school_id'), xs:string($lawSchoolID))
													,cts:element-value-query(xs:QName('Law_School_Data:std_loc'), xs:string($city))
													,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Associate'),("case-insensitive"))
													))))
							
							order by $associateCount ascending
							return $city
							
							else for $city in $attorney_search
							let $associateCount := xdmp:estimate(cts:search(/,
												cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
													,cts:element-value-query(xs:QName('Law_School_Data:std_school_id'), xs:string($lawSchoolID))
													,cts:element-value-query(xs:QName('Law_School_Data:std_loc'), xs:string($city))
													,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Associate'),("case-insensitive"))
													))))
							
							order by $associateCount descending
							return $city	
	
					else for $city in $attorney_search
							let $headcount := xdmp:estimate(cts:search(/,
												cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
													,cts:element-value-query(xs:QName('Law_School_Data:std_school_id'), xs:string($lawSchoolID))
													,cts:element-value-query(xs:QName('Law_School_Data:std_loc'), xs:string($city))
													,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
													))))
							
							order by $headcount descending
							return $city
	
	let $loopData1 := for $city in $loopData
	let $res-object := json:object() 
	
	let $headcount := xdmp:estimate(cts:search(/,
												cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
													,cts:element-value-query(xs:QName('Law_School_Data:std_school_id'), xs:string($lawSchoolID))
													,cts:element-value-query(xs:QName('Law_School_Data:std_loc'), xs:string($city))
													,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
													))))
													
	let $partnerCount := xdmp:estimate(cts:search(/,
												cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
													,cts:element-value-query(xs:QName('Law_School_Data:std_school_id'), xs:string($lawSchoolID))
													,cts:element-value-query(xs:QName('Law_School_Data:std_loc'), xs:string($city))
													,cts:element-value-query(xs:QName('Law_School_Data:title'), 'Partner',("case-insensitive"))
													))))
													
	let $associateCount := xdmp:estimate(cts:search(/,
												cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
													,cts:element-value-query(xs:QName('Law_School_Data:std_school_id'), xs:string($lawSchoolID))
													,cts:element-value-query(xs:QName('Law_School_Data:std_loc'), xs:string($city))
													,cts:element-value-query(xs:QName('Law_School_Data:title'), 'Associate',("case-insensitive"))
													))))

	let $otherCouselCount := xdmp:estimate(cts:search(/,
												cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
													,cts:element-value-query(xs:QName('Law_School_Data:std_school_id'), xs:string($lawSchoolID))
													,cts:element-value-query(xs:QName('Law_School_Data:std_loc'), xs:string($city))
													,cts:element-value-query(xs:QName('Law_School_Data:title'), 'Other Counsel/Attorney',("case-insensitive"))
													))))												
	
     
    let $_ := (
				map:put($res-object,'City',$city),
                map:put($res-object,'HeadCount',$headcount),
				map:put($res-object,'PartnerCount',$partnerCount),
				map:put($res-object,'AsociateCount',$associateCount),
				map:put($res-object,'OtherCounselCount',$otherCouselCount)
			  )
    let $_ := json:array-push($res-array,$res-object)
    return ()
  
  return $res-array
};

declare function firmnew:GetLawFirmPenetration($lawSchoolID)
{
	let $attorney_conditions := (
		 cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
		 cts:element-word-query(xs:QName('Law_School_Data:std_school_id'),fn:tokenize($lawSchoolID,','))
	  )

	
	
	let $attorney_search := cts:element-values(xs:QName('Law_School_Data:firm_id'),(),(), cts:and-query(($attorney_conditions)))
	
	let $res-array := json:array()
    let $loopData := for $firmID in $attorney_search
							let $headcount := xdmp:estimate(cts:search(/,
												cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
													,cts:element-value-query(xs:QName('Law_School_Data:std_school_id'), xs:string($lawSchoolID))
													,cts:element-value-query(xs:QName('Law_School_Data:firm_id'), xs:string($firmID))
													,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
													))))
							
							order by $headcount descending
							return $firmID
							
	
	let $firm := $loopData[1 to 5]
	let $loopData1 := for $firmID in $firm
			let $res-object := json:object() 
			
			let $headCount := xdmp:estimate(cts:search(/,
								cts:and-query((
									cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
									,cts:element-value-query(xs:QName('Law_School_Data:std_school_id'), xs:string($lawSchoolID))
									,cts:element-value-query(xs:QName('Law_School_Data:firm_id'), xs:string($firmID))
									,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
									))))
						
			
			let $partnerCount := xdmp:estimate(cts:search(/,
								cts:and-query((
									cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
									,cts:element-value-query(xs:QName('Law_School_Data:std_school_id'), xs:string($lawSchoolID))
									,cts:element-value-query(xs:QName('Law_School_Data:firm_id'), xs:string($firmID))
									,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner'),("case-insensitive"))
									))))
			
			let $associateCount := xdmp:estimate(cts:search(/,
								cts:and-query((
									cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
									,cts:element-value-query(xs:QName('Law_School_Data:std_school_id'), xs:string($lawSchoolID))
									,cts:element-value-query(xs:QName('Law_School_Data:firm_id'), xs:string($firmID))
									,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Associate'),("case-insensitive"))
									))))
			
			let $femalePartners := xdmp:estimate(cts:search(/,
								cts:and-query((
									cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
									,cts:element-value-query(xs:QName('Law_School_Data:std_school_id'), xs:string($lawSchoolID))
									,cts:element-value-query(xs:QName('Law_School_Data:firm_id'), xs:string($firmID))
									,cts:element-value-query(xs:QName('Law_School_Data:gender'), 'f',('case-insensitive'))
									,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
									))))
			let $practices := cts:element-values(xs:QName('practices_kws:practice_area'))

			let $totalPractiseAreaCount := xdmp:estimate(cts:search(/,
															cts:and-query((
															cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
															,cts:element-value-query(xs:QName('Law_School_Data:std_school_id'), xs:string($lawSchoolID))
															,cts:element-value-query(xs:QName('Law_School_Data:firm_id'), xs:string($firmID))
															,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
															,cts:element-word-query(xs:QName('Law_School_Data:practice_area'), ($practices) ! fn:string(.),('wildcarded',"case-insensitive"))
															))))
			let $loopData2 := for $practice in $practices
								  let $practiseCount := xdmp:estimate(cts:search(/,
															cts:and-query((
															cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
															,cts:element-value-query(xs:QName('Law_School_Data:std_school_id'), xs:string($lawSchoolID))
															,cts:element-value-query(xs:QName('Law_School_Data:firm_id'), xs:string($firmID))
															,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
															,cts:element-word-query(xs:QName('Law_School_Data:practice_area'), $practice,('wildcarded',"case-insensitive"))
															))))
								  let $practicePercent := fn:round-half-to-even(xs:double($practiseCount div $totalPractiseAreaCount) * 100 ,2)
								  
								  return if($practice ne '' and $practicePercent gt 15) then fn:concat($practice) else()

			let $practiceAreaConcentration := fn:string-join($loopData2[1 to 5],';')						
			
			let $firmName := cts:search(/,
										cts:and-query((
										cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
										cts:element-value-query(xs:QName('Law_School_Data:firm_id'), xs:string($firmID))
										)))[1]//Law_School_Data:firm_name/text()
			
			let $femalePercent := fn:round-half-to-even(xs:double(($femalePartners div $headCount)) * 100 ,2)
			let $_ := (map:put($res-object,'FirmID',$firmID),
						map:put($res-object,'FirmName',$firmName),
						map:put($res-object,'HeadCount',$headCount),
						map:put($res-object,'PartnerCount',$partnerCount),
						map:put($res-object,'AssociateCount',$associateCount),
						map:put($res-object,'FemalePercentage',fn:concat($femalePercent,'%')),
						map:put($res-object,'PracticeAreaConcentration',$practiceAreaConcentration)
						)
			let $_ := json:array-push($res-array,$res-object)
			return ()
  
  return $res-array
	
};

declare function firmnew:GetAmLawPenetration($lawSchoolID)
{	  
	let $sizes := '1-25|26-100|101-200'  
	
	let $res-array := json:array()
    let $loopData := for $item in fn:tokenize($sizes,'[|]')
			let $size := fn:tokenize($item,'-')
			let $res-object := json:object() 
			
			let $headCount := xdmp:estimate(cts:search(/,
								cts:and-query((
									cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
									,cts:element-value-query(xs:QName('Law_School_Data:std_school_id'), xs:string($lawSchoolID))
									,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
									,cts:and-query((
										cts:element-range-query(xs:QName('Law_School_Data:amlaw_rank'),'>=',xs:integer($size[1])),
										cts:element-range-query(xs:QName('Law_School_Data:amlaw_rank'),'<=',xs:integer($size[2]))
										))
							))))	
			
			
			let $partnerCount := xdmp:estimate(cts:search(/,
								cts:and-query((
									cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
									,cts:element-value-query(xs:QName('Law_School_Data:std_school_id'), xs:string($lawSchoolID))
									,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner'),("case-insensitive"))
									,cts:and-query((
										cts:element-range-query(xs:QName('Law_School_Data:amlaw_rank'),'>=',xs:integer($size[1])),
										cts:element-range-query(xs:QName('Law_School_Data:amlaw_rank'),'<=',xs:integer($size[2]))
										))
									))))
			
			let $associateCount := xdmp:estimate(cts:search(/,
								cts:and-query((
									cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
									,cts:element-value-query(xs:QName('Law_School_Data:std_school_id'), xs:string($lawSchoolID))
									,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Associate'),("case-insensitive"))
									,cts:and-query((
										cts:element-range-query(xs:QName('Law_School_Data:amlaw_rank'),'>=',xs:integer($size[1])),
										cts:element-range-query(xs:QName('Law_School_Data:amlaw_rank'),'<=',xs:integer($size[2]))
										))
									))))
			
			let $femalePartners := xdmp:estimate(cts:search(/,
								cts:and-query((
									cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
									,cts:element-value-query(xs:QName('Law_School_Data:std_school_id'), xs:string($lawSchoolID))
									,cts:element-value-query(xs:QName('Law_School_Data:gender'), 'f',('case-insensitive'))
									,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
									,cts:and-query((
										cts:element-range-query(xs:QName('Law_School_Data:amlaw_rank'),'>=',xs:integer($size[1])),
										cts:element-range-query(xs:QName('Law_School_Data:amlaw_rank'),'<=',xs:integer($size[2]))
										))
									))))
									
			let $practices := cts:element-values(xs:QName('practices_kws:practice_area'))

			let $totalPractiseAreaCount :=xdmp:estimate(cts:search(/,
											cts:and-query((
												cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
												,cts:element-value-query(xs:QName('Law_School_Data:std_school_id'), xs:string($lawSchoolID))
												,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
												,cts:and-query((
													cts:element-range-query(xs:QName('Law_School_Data:amlaw_rank'),'>=',xs:integer($size[1])),
													cts:element-range-query(xs:QName('Law_School_Data:amlaw_rank'),'<=',xs:integer($size[2]))
													))
												,cts:element-word-query(xs:QName('Law_School_Data:practice_area'), ($practices) ! fn:string(.),('wildcarded',"case-insensitive"))	
											))))	
						
			
			let $loopData2 := for $practice in $practices
								  let $practiseCount := xdmp:estimate(cts:search(/,
															cts:and-query((
																cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
																,cts:element-value-query(xs:QName('Law_School_Data:std_school_id'), xs:string($lawSchoolID))
																,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
																,cts:and-query((
																	cts:element-range-query(xs:QName('Law_School_Data:amlaw_rank'),'>=',xs:integer($size[1])),
																	cts:element-range-query(xs:QName('Law_School_Data:amlaw_rank'),'<=',xs:integer($size[2]))
																	))
																,cts:element-word-query(xs:QName('Law_School_Data:practice_area'), $practice,('wildcarded',"case-insensitive"))	
															))))	
								  let $practicePercent := fn:round-half-to-even(xs:double($practiseCount div $totalPractiseAreaCount) * 100 ,2)
								  
								  return if($practice ne '' and $practicePercent gt 15) then fn:concat($practice) else()

			let $practiceAreaConcentration := fn:string-join($loopData2[1 to 5],';')								
			
			let $columnName :=if($size[2] eq '25') then fn:concat('Am Law ',$size[2]) else fn:concat('Am Law ',$item)
			
			let $femalePercent := fn:round-half-to-even(xs:double(($femalePartners div $headCount)) * 100 ,2)
			let $_ := (
						map:put($res-object,'ColumnName',$columnName),
						map:put($res-object,'HeadCount',$headCount),
						map:put($res-object,'PartnerCount',$partnerCount),
						map:put($res-object,'AssociateCount',$associateCount),
						map:put($res-object,'femalePartners',$femalePartners),
						map:put($res-object,'FemalePercentage',fn:concat($femalePercent,'%')),
						map:put($res-object,'PracticeAreaConcentration',$practiceAreaConcentration)
						)
			let $_ := json:array-push($res-array,$res-object)
			return ()
		  
  return $res-array
	
};

declare function firmnew:GetLawSchoolByFirmID($firmID)
{
	let $res-obj := json:object()
	let $_ := (
				map:put($res-obj,'PartnerLawSchool',firmnew:GetPartnerLawSchoolByFirmID($firmID)),
				map:put($res-obj,'AssociateLawSchool',firmnew:GetAssociateLawSchoolByFirmID($firmID)),
				map:put($res-obj,'LawSchoolList',firmnew:GetLawSchoolList($firmID))
			  )
    return $res-obj			  
};

declare function firmnew:GetPartnerLawSchoolByFirmID($firmID)
{
	let $attorney_conditions := (
		 cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
		 cts:element-word-query(xs:QName('Law_School_Data:ALI_ID'),fn:tokenize($firmID,',')),
		 cts:not-query(cts:element-value-query(xs:QName('Law_School_Data:std_school'),''))
	  )
	
	let $attorney_search := cts:element-values(xs:QName('Law_School_Data:std_school'),(),(), cts:and-query(($attorney_conditions)))
	
	let $res-array := json:array()
    let $loopData := for $school in $attorney_search
							let $headcount := xdmp:estimate(cts:search(/,
												cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
													,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($school))
													,cts:element-value-query(xs:QName('Law_School_Data:ALI_ID'), xs:string($firmID))
													,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner'),("case-insensitive"))
													))))
							
							order by $headcount descending
							return $school
							
	
	 let $loopData1 := for $school in $loopData[1 to 9]
					       let $res-obj := json:object()
						   
						   let $headcount := xdmp:estimate(cts:search(/,
												cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
													,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($school))
													,cts:element-value-query(xs:QName('Law_School_Data:ALI_ID'), xs:string($firmID))
													,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner'),("case-insensitive"))
													))))
													
						   let $_ := (
										map:put($res-obj,'SchoolName',$school),
										map:put($res-obj,'HeadCount',$headcount)
									 )
						   let $_ := json:array-push($res-array,$res-obj)
						   return()

	 let $res-obj1 := json:object()
	 let $remainingSchools := $loopData[10 to count($loopData)]					   
	 let $headcount := xdmp:estimate(cts:search(/,
												cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
													,cts:element-value-query(xs:QName('Law_School_Data:std_school'), $remainingSchools)
													,cts:element-value-query(xs:QName('Law_School_Data:ALI_ID'),xs:string($firmID))
													,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner'),("case-insensitive"))
													))))
													
	 let $_ := (
				map:put($res-obj1,'SchoolName','All Others'),
				map:put($res-obj1,'HeadCount',$headcount)
				)

	 let $_ := json:array-push($res-array,$res-obj1)	   
	return $res-array
	
};

declare function firmnew:GetAssociateLawSchoolByFirmID($firmID)
{
	let $attorney_conditions := (
		 cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
		 cts:element-word-query(xs:QName('Law_School_Data:ALI_ID'),fn:tokenize($firmID,',')),
		 cts:not-query(cts:element-value-query(xs:QName('Law_School_Data:std_school'),''))
	  )

	
	
	let $attorney_search := cts:element-values(xs:QName('Law_School_Data:std_school'),(),(), cts:and-query(($attorney_conditions)))
	
	let $res-array := json:array()
    let $loopData := for $school in $attorney_search
							let $headcount := xdmp:estimate(cts:search(/,
												cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
													,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($school))
													,cts:element-value-query(xs:QName('Law_School_Data:ALI_ID'), xs:string($firmID))
													,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Associate'),("case-insensitive"))
													))))
							
							order by $headcount descending
							return $school
							
	
	 let $loopData1 := for $school in $loopData[1 to 10]
					       let $res-obj := json:object()
						   
						   let $headcount := xdmp:estimate(cts:search(/,
												cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
													,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($school))
													,cts:element-value-query(xs:QName('Law_School_Data:ALI_ID'), xs:string($firmID))
													,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Associate'),("case-insensitive"))
													))))
													
						   let $_ := (
										map:put($res-obj,'SchoolName',$school),
										map:put($res-obj,'HeadCount',$headcount)
									 )
						   let $_ := json:array-push($res-array,$res-obj)
						   return()
	 let $res-obj1 := json:object()
	 let $remainingSchools := $loopData[10 to count($loopData)]					   
	 let $headcount := xdmp:estimate(cts:search(/,
												cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
													,cts:element-value-query(xs:QName('Law_School_Data:std_school'), $remainingSchools)
													,cts:element-value-query(xs:QName('Law_School_Data:ALI_ID'),xs:string($firmID))
													,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Associate'),("case-insensitive"))
													))))
													
	 let $_ := (
				map:put($res-obj1,'SchoolName','All Others'),
				map:put($res-obj1,'HeadCount',$headcount)
				)

	 let $_ := json:array-push($res-array,$res-obj1)	   
	
	return $res-array
	
};

declare function firmnew:GetLawSchoolList($firmID)
{
	let $attorney_conditions := (
		 cts:directory-query('/LegalCompass/relational-data/Law_School_Data/'),
		 cts:element-word-query(xs:QName('Law_School_Data:ALI_ID'),fn:tokenize($firmID,',')),
		 cts:element-word-query(xs:QName('Law_School_Data:title'),('Partner' ,'Associate','Other Counsel/Attorney')),
		 cts:not-query(cts:element-value-query(xs:QName('Law_School_Data:std_school'),''))
	  )

	
	
	let $attorney_search := cts:element-values(xs:QName('Law_School_Data:std_school'),(),(), cts:and-query(($attorney_conditions)))
	
	let $res-array := json:array()
    let $loopData := for $school in $attorney_search
							let $headcount := xdmp:estimate(cts:search(/,
												cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
													,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($school))
													,cts:element-value-query(xs:QName('Law_School_Data:ALI_ID'), xs:string($firmID))
													,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner' ,'Associate','Other Counsel/Attorney'),("case-insensitive"))
													))))
							
							order by $headcount descending
							return $school
							
	 let $practices := cts:element-values(xs:QName('practices_kws:practice_area'))

	 let $loopData1 := for $school in $loopData[1 to 20]
					       let $res-object := json:object()
						   
						   let $headcount := xdmp:estimate(cts:search(/,
												cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
													,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($school))
													,cts:element-value-query(xs:QName('Law_School_Data:ALI_ID'), xs:string($firmID))
													,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner' , 'Associate','Other Counsel/Attorney'),("case-insensitive"))
													))))
							
							let $partnerCount := xdmp:estimate(cts:search(/,
								cts:and-query((
									cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
									,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($school))
									,cts:element-value-query(xs:QName('Law_School_Data:ALI_ID'), xs:string($firmID))
									,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner'),("case-insensitive"))
									))))
			
							let $associateCount := xdmp:estimate(cts:search(/,
												cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
													,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($school))
													,cts:element-value-query(xs:QName('Law_School_Data:ALI_ID'), xs:string($firmID))
													,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Associate'),("case-insensitive"))
													))))
							let $otherCounselCount := xdmp:estimate(cts:search(/,
												cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
													,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($school))
													,cts:element-value-query(xs:QName('Law_School_Data:ALI_ID'), xs:string($firmID))
													,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Other Counsel/Attorney'),("case-insensitive"))
													))))						
							
							let $femalePartners := xdmp:estimate(cts:search(/,
												cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
													,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($school))
													,cts:element-value-query(xs:QName('Law_School_Data:ALI_ID'), xs:string($firmID))
													,cts:element-value-query(xs:QName('Law_School_Data:gender'), 'f',('case-insensitive'))
													,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner', 'Associate','Other Counsel/Attorney'),("case-insensitive"))
													))))
							
							

							let $totalPractiseAreaCount :=xdmp:estimate(cts:search(/,
												cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
													,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($school))
													,cts:element-value-query(xs:QName('Law_School_Data:ALI_ID'), xs:string($firmID))
													,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner' , 'Associate','Other Counsel/Attorney'),("case-insensitive"))
													,cts:element-word-query(xs:QName('Law_School_Data:practice_area'), ($practices) ! fn:string(.),('wildcarded',"case-insensitive"))	
													))))
							
							
							let $loopData2 := for $practice in $practices
												let $practiseCount :=xdmp:estimate(cts:search(/,
												cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/Law_School_Data/')
													,cts:element-value-query(xs:QName('Law_School_Data:std_school'), xs:string($school))
													,cts:element-value-query(xs:QName('Law_School_Data:ALI_ID'), xs:string($firmID))
													,cts:element-value-query(xs:QName('Law_School_Data:title'), ('Partner' , 'Associate','Other Counsel/Attorney'),("case-insensitive"))
													,cts:element-word-query(xs:QName('Law_School_Data:practice_area'), $practice,('wildcarded',"case-insensitive"))	
													))))
												let $practicePercent := if($totalPractiseAreaCount ne 0) then fn:round-half-to-even(xs:double($practiseCount div $totalPractiseAreaCount) * 100 ,2) else 0
												
												return if($practice ne '' and $practicePercent gt 15) then fn:concat($practice) else()

							let $practiceAreaConcentration := fn:string-join($loopData2[1 to 5],';')				

							let $femalePercent := fn:round-half-to-even(xs:double(($femalePartners div $headcount)) * 100 ,2)
							let $_ := (
										map:put($res-object,'SchoolName',$school),
										map:put($res-object,'HeadCount',$headcount),
										map:put($res-object,'PartnerCount',$partnerCount),
										map:put($res-object,'AssociateCount',$associateCount),
										map:put($res-object,'OtherCounselCount',$otherCounselCount),
										map:put($res-object,'femalePartners',$femalePartners),
										map:put($res-object,'FemalePercentage',fn:concat($femalePercent,'%')),
										map:put($res-object,'PracticeAreaConcentration',$practiceAreaConcentration)
										)
							
						   let $_ := json:array-push($res-array,$res-object)
						   return()
	return $res-array
	
};

declare function firmnew:SP_GCCOMANSATION_GLL($FortuneRankFrom,$FortuneRankTo,$IndustryName,$StateName,$RevenueRangeFrom,$RevenueRangeTo )
{
	let $FortuneRankFromQuery := if($FortuneRankFrom ne '')
  then cts:element-range-query(xs:QName("GCCompensation:FORTUNE_RANK"),">=",xs:integer($FortuneRankFrom)) 
  else ()
  
let $FortuneRankToQuery := if($FortuneRankTo ne '')
  then cts:element-range-query(xs:QName("GCCompensation:FORTUNE_RANK"),"<=",xs:integer($FortuneRankTo))
  else ()

let $RevenueRangeFromQuery := if($RevenueRangeFrom ne '')
  then cts:element-range-query(xs:QName("GCCompensation:REVENUE_MILLIONS"),">=",xs:integer(xs:double($RevenueRangeFrom))) 
  else ()
  
let $RevenueRangeToQuery := if($RevenueRangeTo ne '')
  then cts:element-range-query(xs:QName("GCCompensation:REVENUE_MILLIONS"),"<=",xs:integer(xs:double($RevenueRangeTo)))
  else ()
let $IndustryNameQuery := if($IndustryName ne '')
  then cts:element-value-query(xs:QName("GCCompensation:INDUSTRY"), fn:tokenize($IndustryName,";"))
  else ()
  
let $StateNameQuery := if($StateName ne '')
  then cts:element-value-query(xs:QName("GCCompensation:STATE"), fn:tokenize($StateName,","))
  else ()  
  
let $SearchResults := cts:search(/, 
  cts:and-query((
    cts:directory-query("/LegalCompass/GLL/relational-data/GCCompensation/")
    ,cts:and-query((
      $FortuneRankFromQuery
      ,$FortuneRankToQuery
      ,$RevenueRangeFromQuery
      ,$RevenueRangeToQuery
	  ,$IndustryNameQuery
	  ,$StateNameQuery
    )))
  ))

let $response-arr := json:array()

let $res := for $result in $SearchResults

  let $response-obj := json:object()
  
  let $TotalCashPlusStock := $result//GCCompensation:TOTAL_CASH_PLUS_STOCK/text()
  let $StockAwards := $result//GCCompensation:STOCK_AWARDS/text()
  let $OptionAwards := $result//GCCompensation:OPTION_AWARDS/text()
  let $AllOtherCompensation := $result//GCCompensation:ALL_OTHER_COMPENSATION/text()

  let $AllCompensation := fn:sum($TotalCashPlusStock + $StockAwards + $OptionAwards + $AllOtherCompensation )
(:  
  let $_ := (			
	  map:put($response-obj,'GC_ID',$result//GCCompensation:GC_ID/text())
     ,map:put($response-obj,'GC_COMP_RANK_CURRENTYEAR',$result//GCCompensation:GC_COMP_RANK_CURRENTYEAR/text())
     ,map:put($response-obj,'GC_COMP_RANK_PREVIOUSYEAR',$result//GCCompensation:GC_COMP_RANK_PREVIOUSYEAR/text())
     ,map:put($response-obj,'FORTUNE_RANK',$result//GCCompensation:FORTUNE_RANK/text())
     ,map:put($response-obj,'LEGAL_NAME',$result//GCCompensation:LEGAL_NAME/text())
     ,map:put($response-obj,'COMPANY_ID',$result//GCCompensation:COMPANY_ID/text())
     ,map:put($response-obj,'COMPANY',$result//GCCompensation:COMPANY/text())
     ,map:put($response-obj,'CITY',$result//GCCompensation:CITY/text())
     ,map:put($response-obj,'STATE',$result//GCCompensation:CITY/text())
     ,map:put($response-obj,'REVENUE_MILLIONS',$result//GCCompensation:REVENUE_MILLIONS/text())
     ,map:put($response-obj,'INDUSTRY',$result//GCCompensation:INDUSTRY/text())
     ,map:put($response-obj,'SALARY',$result//GCCompensation:SALARY/text())
     ,map:put($response-obj,'BONUS',$result//GCCompensation:BONUS/text())
     ,map:put($response-obj,'NONEQUITY_INCENTIVE',$result//GCCompensation:NONEQUITY_INCENTIVE/text())
     ,map:put($response-obj,'TOTAL_CASH',$result//GCCompensation:TOTAL_CASH/text())
     ,map:put($response-obj,'STOCK_VALUE_ON_VESTING',$result//GCCompensation:STOCK_VALUE_ON_VESTING/text())
     ,map:put($response-obj,'STOCK_ON_EXERCISE',$result//GCCompensation:STOCK_ON_EXERCISE/text())
     ,map:put($response-obj,'OPTION_EXERCISES',$result//GCCompensation:OPTION_EXERCISES/text())
     ,map:put($response-obj,'TOTAL_CASH_PLUS_STOCK',$result//GCCompensation:TOTAL_CASH_PLUS_STOCK/text())
     ,map:put($response-obj,'TOTAL_CASH_NO_VESTING',$result//GCCompensation:TOTAL_CASH_NO_VESTING/text())
     ,map:put($response-obj,'STOCK_AWARDS',$result//GCCompensation:STOCK_AWARDS/text())
     ,map:put($response-obj,'OPTION_AWARDS',$result//GCCompensation:OPTION_AWARDS/text())
     ,map:put($response-obj,'CHANGE_IN_PENSION_VALUE',$result//GCCompensation:CHANGE_IN_PENSION_VALUE/text())
     ,map:put($response-obj,'ALL_OTHER_COMPENSATION',$result//GCCompensation:ALL_OTHER_COMPENSATION/text())
     ,map:put($response-obj,'NOTES',$result//GCCompensation:NOTES/text())
     ,map:put($response-obj,'SOURCE',$result//GCCompensation:SOURCE/text())
     ,map:put($response-obj,'FISCAL_YEAR',$result//GCCompensation:FISCAL_YEAR/text())
     ,map:put($response-obj,'CREATE_DATE',$result//GCCompensation:CREATE_DATE/text())
     ,map:put($response-obj,'CREATED_BY',$result//GCCompensation:CREATED_BY/text())
     ,map:put($response-obj,'LAST_MODIFIED',$result//GCCompensation:LAST_MODIFIED/text())
     ,map:put($response-obj,'LAST_MODIFIED_BY',$result//GCCompensation:LAST_MODIFIED_BY/text())
     ,map:put($response-obj,'IS_INSERTED_OR_MODIFIED',$result//GCCompensation:IS_INSERTED_OR_MODIFIED/text())
     ,map:put($response-obj,'ISUPDATEDTOMARKLOGIC',$result//GCCompensation:ISUPDATEDTOMARKLOGIC/text())
     ,map:put($response-obj,'AllCompensation',$AllCompensation)
     )
:)
	let $_ := (	
		 map:put($response-obj,'SALARY',$result//GCCompensation:SALARY/text())
		,map:put($response-obj,'NONEQUITY_INCENTIVE',$result//GCCompensation:NONEQUITY_INCENTIVE/text())
		,map:put($response-obj,'TOTAL_CASH',$result//GCCompensation:TOTAL_CASH/text())
		,map:put($response-obj,'STOCK_VALUE_ON_VESTING',$result//GCCompensation:STOCK_VALUE_ON_VESTING/text())
		,map:put($response-obj,'TOTAL_CASH_PLUS_STOCK',$TotalCashPlusStock)
		,map:put($response-obj,'STOCK_AWARDS',$StockAwards)
		,map:put($response-obj,'OPTION_AWARDS',$OptionAwards)
		,map:put($response-obj,'ALL_OTHER_COMPENSATION',$AllOtherCompensation)
		,map:put($response-obj,'REVENUE_MILLIONS',$result//GCCompensation:REVENUE_MILLIONS/text())
		,map:put($response-obj,'AllCompensation',$AllCompensation)
     )

	  
  return $response-obj

return $res
};

declare function firmnew:GetClients()
{
	let $request := xdmp:get-request-body()/request
	

	let $OrganisationID := $request/FirmID/text()
	let $checkMergerData := (:firmnew:GetLawFirmMergerData($OrganisationID):) ''

	let $firmID := if($checkMergerData != '') then fn:tokenize(fn:concat(fn:string-join(fn:tokenize($checkMergerData,'[|]'),','),',',$OrganisationID),',') else $OrganisationID
	let $fromYear := xs:integer($request/FromYear/text())
	let $toYear := xs:integer($request/ToYear/text()) 
	let $representationIDs := $request/RepresentationID/text()
	let $PageNo := $request/PageNo/text()
	let $PageSize := $request/PageSize/text()
	let $SortBy := $request/SortBy/text()
	let $sortDirection := $request/SortDirection/text()
	let $sortDir := if(fn:lower-case($sortDirection) eq 'asc') then 'ascending' else 'descending'
	let $representation := $request/Representation/text()

	let $orderBy :=if($SortBy eq 'Source') then cts:index-order(cts:element-reference(xs:QName('GETCLIENTS:SOURCE')) ,$sortDir)
                 else if($SortBy eq 'Client') then cts:index-order(cts:element-reference(xs:QName('GETCLIENTS:CLIENT_NAME')) ,$sortDir)
                       else if($SortBy eq 'TypeOfTransaction') then cts:index-order(cts:element-reference(xs:QName('GETCLIENTS:TYPEOFTRANSACTION')) ,$sortDir)
					   else if($SortBy eq 'Date') then cts:index-order(cts:element-reference(xs:QName('GETCLIENTS:DATE')) ,$sortDir)
                            else cts:index-order(cts:element-reference(xs:QName('GETCLIENTS:DATE')) ,'descending')

	 let $fromRecord := if(xs:string($PageNo) ne '1') then (xs:int($PageNo)-1)*xs:int($PageSize) else 1
 	 let $toRecord := xs:int($PageSize)*xs:int($PageNo)

	let $response-arr := json:array()
	
	let $organization := 0 (:fn:doc(fn:concat('/LegalCompass/denormalized-data/organization/',$firmID,'.xml')):)
	let $organizationID :='' (:$organization//organization:ORGANIZATION_ID/text():)
	let $organizationName :='' (:if ($organization//organization:ALM_NAME/text() != '') then ($organization//organization:ALM_NAME/text()) else fn:normalize-space($organization//organization:ORGANIZATION_NAME/text()):)
	let $totalCount := xdmp:estimate(cts:search(/,
							cts:and-query((
								cts:directory-query('/LegalCompass/denormalized-data/GetClients/'),
								if($firmID ne '') then cts:element-value-query(xs:QName('GETCLIENTS:FIRMID'),$firmID) else(),

								if(xs:string($fromYear) ne '' and xs:string($toYear) ne '') then cts:and-query((
											cts:element-range-query(xs:QName('GETCLIENTS:DATE'),'>=',$fromYear),
											cts:element-range-query(xs:QName('GETCLIENTS:DATE'),'<=',$toYear)
								)) else(),

								if($representation ne '' and $representation ne 'All Types') then  cts:element-value-query(xs:QName('GETCLIENTS:REPRESENTATION_TYPE_ID'),fn:tokenize($representationIDs,',')) else()
							))))

	let $search-result1:= cts:search(/,
							cts:and-query((
								cts:directory-query('/LegalCompass/denormalized-data/GetClients/'),
								if($firmID ne '') then cts:element-value-query(xs:QName('GETCLIENTS:FIRMID'),$firmID) else(),

								if(xs:string($fromYear) ne '' and xs:string($toYear) ne '') then cts:and-query((
											cts:element-range-query(xs:QName('GETCLIENTS:DATE'),'>=',$fromYear),
											cts:element-range-query(xs:QName('GETCLIENTS:DATE'),'<=',$toYear)
								)) else(),

								if($representation ne '' and $representation ne 'All Types') then  cts:element-value-query(xs:QName('GETCLIENTS:REPRESENTATION_TYPE_ID'),fn:tokenize($representationIDs,',')) else()
							)),$orderBy)[$fromRecord to $toRecord]

	let $data := for $entry in $search-result1
						let $response-obj := json:object()           
						let $_ := (
									map:put($response-obj,'Source',$entry//GETCLIENTS:SOURCE/text()),
									map:put($response-obj,'TypeOfTransaction',$entry//GETCLIENTS:TYPEOFTRANSACTION/text()),
									map:put($response-obj,'SearchID',$entry//GETCLIENTS:TYPEOFTRANSACTION/text()),
									map:put($response-obj,'Role', $entry//GETCLIENTS:ROLE/text()),
									map:put($response-obj,'Firm', $entry//GETCLIENTS:FIRM/string()),
									map:put($response-obj,'clientold',$entry//GETCLIENTS:CLIENT/string()),
									map:put($response-obj,'client',$entry//GETCLIENTS:CLIENT_NAME/text()),
									map:put($response-obj,'Date', xs:integer($entry//GETCLIENTS:DATE/text())),
									map:put($response-obj,'Month', $entry//GETCLIENTS:MONTH/text()),
									map:put($response-obj,'Jurisdiction', $entry//GETCLIENTS:JURISDICTION/text()),
									map:put($response-obj,'CaseName', $entry//GETCLIENTS:CASENAME/text()),
									map:put($response-obj,'CaseId',$entry//GETCLIENTS:CASEID/text()),
									map:put($response-obj,'PatentNumber', $entry//GETCLIENTS:PATENTNUMBER/text()),
									map:put($response-obj,'DocketNumber', $entry//GETCLIENTS:DOCKETNUMBER/text()),
									map:put($response-obj,'FirmId', $entry//GETCLIENTS:FIRMID/string()),
									map:put($response-obj,'Details', $entry//GETCLIENTS:DETAILS/text()),
									map:put($response-obj,'TypeofCase', $entry//GETCLIENTS:TYPEOFCASE/text()),
									map:put($response-obj,'RecordCount', $totalCount),
									map:put($response-obj,'representationIDs',$representationIDs),
									map:put($response-obj,'representation',$representation),
									map:put($response-obj,'baseuri',fn:base-uri($entry))
								  )
						let $_ := json:array-push($response-arr,$response-obj)  
						return ()
	
	
	return $response-arr
};

declare function firmnew:GetClientChart($OrganizationID,$fromYear,$toYear,$representationID)
{
	let $checkMergerData := (:firmnew:GetLawFirmMergerData($OrganizationID):) ''
	let $firmID := if($checkMergerData != '') then fn:tokenize(fn:concat(fn:string-join(fn:tokenize($checkMergerData,'[|]'),','),',',$OrganizationID),',') else $OrganizationID	

    let $res-array := json:array()
	let $andQuery := cts:and-query((
							cts:directory-query('/LegalCompass/denormalized-data/GetClients/'),
							cts:element-value-query(xs:QName('GETCLIENTS:FIRMID'),$firmID),
							if($fromYear ne '0' and $toYear ne '0') then cts:and-query((
								cts:element-range-query(xs:QName('GETCLIENTS:DATE'),'>=',xs:integer($fromYear)),
								cts:element-range-query(xs:QName('GETCLIENTS:DATE'),'<=',xs:integer($toYear))
							)) else(),
							if($representationID ne '' and $representationID ne 'All Types') then cts:element-value-query(xs:QName('GETCLIENTS:REPRESENTATION_TYPE_ID'),fn:tokenize($representationID,',')) else()
						))

    let $result := cts:values(cts:element-reference(xs:QName('GETCLIENTS:CLIENT_NAME')), (), (),$andQuery)
	
                    
   let $loopData := for $item in fn:distinct-values($result)
                        let $res-obj := json:object()
                        let $ipCount := xdmp:estimate(cts:search(/,
                                            cts:and-query((
                                              cts:directory-query('/LegalCompass/denormalized-data/GetClients/'),
                                              cts:element-value-query(xs:QName('GETCLIENTS:FIRMID'),$firmID),
                                              cts:element-value-query(xs:QName('GETCLIENTS:CLIENT_NAME'),$item,('exact')),
                                              cts:element-value-query(xs:QName('GETCLIENTS:LEVEL_1'),'IP'),
                                              if($fromYear ne '0' and $toYear ne '0') then cts:and-query((
                                                cts:element-range-query(xs:QName('GETCLIENTS:DATE'),'>=',xs:integer($fromYear)),
                                                cts:element-range-query(xs:QName('GETCLIENTS:DATE'),'<=',xs:integer($toYear))
                                              )) else(),

                                              if($representationID ne '' and $representationID ne 'All Types') then cts:element-value-query(xs:QName('GETCLIENTS:REPRESENTATION_TYPE_ID'),fn:tokenize($representationID,',')) else()

                                            ))))
                                            
                      let $litigationCount := xdmp:estimate(cts:search(/,
                                            cts:and-query((
                                              cts:directory-query('/LegalCompass/denormalized-data/GetClients/'),
                                              cts:element-value-query(xs:QName('GETCLIENTS:FIRMID'),$firmID,('exact')),
                                              cts:element-value-query(xs:QName('GETCLIENTS:CLIENT_NAME'),$item),
                                              cts:element-value-query(xs:QName('GETCLIENTS:LEVEL_1'),'Litigation'),
                                              if($fromYear ne '0' and $toYear ne '0') then cts:and-query((
                                                cts:element-range-query(xs:QName('GETCLIENTS:DATE'),'>=',xs:integer($fromYear)),
                                                cts:element-range-query(xs:QName('GETCLIENTS:DATE'),'<=',xs:integer($toYear))
                                              )) else(),

                                              if($representationID ne '' and $representationID ne 'All Types') then cts:element-value-query(xs:QName('GETCLIENTS:REPRESENTATION_TYPE_ID'),fn:tokenize($representationID,',')) else()

                                            ))))
                    
                    let $transactionCount := xdmp:estimate(cts:search(/,
                                            cts:and-query((
                                              cts:directory-query('/LegalCompass/denormalized-data/GetClients/'),
                                              cts:element-value-query(xs:QName('GETCLIENTS:FIRMID'),$firmID,('exact')),
                                              cts:element-value-query(xs:QName('GETCLIENTS:CLIENT_NAME'),$item),
                                              cts:element-value-query(xs:QName('GETCLIENTS:LEVEL_1'),'Transactional'),
                                              if($fromYear ne '0' and $toYear ne '0') then cts:and-query((
                                                cts:element-range-query(xs:QName('GETCLIENTS:DATE'),'>=',xs:integer($fromYear)),
                                                cts:element-range-query(xs:QName('GETCLIENTS:DATE'),'<=',xs:integer($toYear))
                                              )) else(),

                                              if($representationID ne '' and $representationID ne 'All Types') then cts:element-value-query(xs:QName('GETCLIENTS:REPRESENTATION_TYPE_ID'),fn:tokenize($representationID,',')) else()

                                            ))))
                                            
                   let $totalCount := xdmp:estimate(cts:search(/,
                                            cts:and-query((
                                              cts:directory-query('/LegalCompass/denormalized-data/GetClients/'),
                                              cts:element-value-query(xs:QName('GETCLIENTS:FIRMID'),$firmID),
                                              cts:element-value-query(xs:QName('GETCLIENTS:CLIENT_NAME'),$item,('exact')),
                                              cts:element-value-query(xs:QName('GETCLIENTS:LEVEL_1'),('Litigation','IP','Transactional')),
                                              if($fromYear ne '0' and $toYear ne '0') then cts:and-query((
                                                cts:element-range-query(xs:QName('GETCLIENTS:DATE'),'>=',xs:integer($fromYear)),
                                                cts:element-range-query(xs:QName('GETCLIENTS:DATE'),'<=',xs:integer($toYear))
                                              )) else(),

                                              if($representationID ne '' and $representationID ne 'All Types') then cts:element-value-query(xs:QName('GETCLIENTS:REPRESENTATION_TYPE_ID'),fn:tokenize($representationID,',')) else()

                                            )))  )
                   
                   let $_ := (
                               map:put($res-obj,'Client',$item),
                               map:put($res-obj,'IntellectualProperty',$ipCount),
                               map:put($res-obj,'Litigation',$litigationCount),
                               map:put($res-obj,'Transaction',$transactionCount),
                               map:put($res-obj,'Total',$totalCount)
                             )
                 let $_ := json:array-push($res-array,$res-obj)
                 return()
                                            
                                            
                    
   return $res-array          
};


(: declare function firmnew:GetClients()
{
	let $request := xdmp:get-request-body()/request
	

	let $OrganisationID := $request/FirmID/text()
	let $checkMergerData := (:firmnew:GetLawFirmMergerData($OrganisationID):) ''

	let $firmID := if($checkMergerData != '') then fn:tokenize(fn:concat(fn:string-join(fn:tokenize($checkMergerData,'[|]'),','),',',$OrganisationID),',') else $OrganisationID
	let $fromYear := xs:integer($request/FromYear/text())
	let $toYear := xs:integer($request/ToYear/text()) 
	let $representationIDs := $request/RepresentationID/text()
	let $PageNo := $request/PageNo/text()
	let $PageSize := $request/PageSize/text()
	let $SortBy := $request/SortBy/text()
	let $sortDirection := $request/SortDirection/text()
	let $sortDir := if(fn:lower-case($sortDirection) eq 'asc') then 'ascending' else 'descending'
	let $representation := $request/Representation/text()

	let $orderBy :=if($SortBy eq 'Source') then cts:index-order(cts:element-reference(xs:QName('GETCLIENTS:SOURCE')) ,$sortDir)
                 else if($SortBy eq 'Client') then cts:index-order(cts:element-reference(xs:QName('GETCLIENTS:CLIENT')) ,$sortDir)
                       else if($SortBy eq 'TypeOfTransaction') then cts:index-order(cts:element-reference(xs:QName('GETCLIENTS:TYPEOFTRANSACTION')) ,$sortDir)
					   else if($SortBy eq 'Date') then cts:index-order(cts:element-reference(xs:QName('GETCLIENTS:DATE')) ,$sortDir)
                            else cts:index-order(cts:element-reference(xs:QName('GETCLIENTS:DATE')) ,'descending')

	 let $fromRecord := if(xs:string($PageNo) ne '1') then (xs:int($PageNo)-1)*xs:int($PageSize) else 1
 	 let $toRecord := xs:int($PageSize)*xs:int($PageNo)

	let $response-arr := json:array()
	
	let $organization := 0 (:fn:doc(fn:concat('/LegalCompass/denormalized-data/organization/',$firmID,'.xml')):)
	let $organizationID :='' (:$organization//organization:ORGANIZATION_ID/text():)
	let $organizationName :='' (:if ($organization//organization:ALM_NAME/text() != '') then ($organization//organization:ALM_NAME/text()) else fn:normalize-space($organization//organization:ORGANIZATION_NAME/text()):)
	let $totalCount := xdmp:estimate(cts:search(/,
							cts:and-query((
								cts:directory-query('/LegalCompass/denormalized-data/GetClients/'),
								if($firmID ne '') then cts:element-value-query(xs:QName('GETCLIENTS:FIRMID'),$firmID) else(),

								if(xs:string($fromYear) ne '' and xs:string($toYear) ne '') then cts:and-query((
											cts:element-range-query(xs:QName('GETCLIENTS:DATE'),'>=',$fromYear),
											cts:element-range-query(xs:QName('GETCLIENTS:DATE'),'<=',$toYear)
								)) else(),

								if($representation ne '' and $representation ne 'All Types') then  cts:element-value-query(xs:QName('GETCLIENTS:REPRESENTATION_TYPE_ID'),fn:tokenize($representationIDs,',')) else()
							))))

	let $search-result1:= cts:search(/,
							cts:and-query((
								cts:directory-query('/LegalCompass/denormalized-data/GetClients/'),
								if($firmID ne '') then cts:element-value-query(xs:QName('GETCLIENTS:FIRMID'),$firmID) else(),

								if(xs:string($fromYear) ne '' and xs:string($toYear) ne '') then cts:and-query((
											cts:element-range-query(xs:QName('GETCLIENTS:DATE'),'>=',$fromYear),
											cts:element-range-query(xs:QName('GETCLIENTS:DATE'),'<=',$toYear)
								)) else(),

								if($representation ne '' and $representation ne 'All Types') then  cts:element-value-query(xs:QName('GETCLIENTS:REPRESENTATION_TYPE_ID'),fn:tokenize($representationIDs,',')) else()
							)),$orderBy)[$fromRecord to $toRecord]

	let $data := for $entry in $search-result1
						let $response-obj := json:object()           
						let $_ := (
									map:put($response-obj,'Source',$entry//GETCLIENTS:SOURCE/text()),
									map:put($response-obj,'TypeOfTransaction',$entry//GETCLIENTS:TYPEOFTRANSACTION/text()),
									map:put($response-obj,'SearchID',$entry//GETCLIENTS:TYPEOFTRANSACTION/text()),
									map:put($response-obj,'Role', $entry//GETCLIENTS:ROLE/text()),
									map:put($response-obj,'Firm', $entry//GETCLIENTS:FIRM/string()),
									map:put($response-obj,'client',$entry//GETCLIENTS:CLIENT/string()),
									map:put($response-obj,'Date', xs:integer($entry//GETCLIENTS:DATE/text())),
									map:put($response-obj,'Month', $entry//GETCLIENTS:MONTH/text()),
									map:put($response-obj,'Jurisdiction', $entry//GETCLIENTS:JURISDICTION/text()),
									map:put($response-obj,'CaseName', $entry//GETCLIENTS:CASENAME/text()),
									map:put($response-obj,'CaseId',$entry//GETCLIENTS:CASEID/text()),
									map:put($response-obj,'PatentNumber', $entry//GETCLIENTS:PATENTNUMBER/text()),
									map:put($response-obj,'DocketNumber', $entry//GETCLIENTS:DOCKETNUMBER/text()),
									map:put($response-obj,'FirmId', $entry//GETCLIENTS:FIRMID/string()),
									map:put($response-obj,'Details', $entry//GETCLIENTS:DETAILS/text()),
									map:put($response-obj,'TypeofCase', $entry//GETCLIENTS:TYPEOFCASE/text()),
									map:put($response-obj,'RecordCount', $totalCount),
									map:put($response-obj,'representationIDs',$representationIDs),
									map:put($response-obj,'representation',$representation)
								  )
						let $_ := json:array-push($response-arr,$response-obj)  
						return ()
	
	
	return $response-arr
};

declare function firmnew:GetClientChart($OrganizationID,$fromYear,$toYear,$representationID)
{
	let $checkMergerData := (:firmnew:GetLawFirmMergerData($OrganizationID):) ''
	let $firmID := if($checkMergerData != '') then fn:tokenize(fn:concat(fn:string-join(fn:tokenize($checkMergerData,'[|]'),','),',',$OrganizationID),',') else $OrganizationID	

    let $res-array := json:array()
	let $andQuery := cts:and-query((
							cts:directory-query('/LegalCompass/denormalized-data/GetClients/'),
							cts:element-value-query(xs:QName('GETCLIENTS:FIRMID'),$firmID),
							if($fromYear ne '0' and $toYear ne '0') then cts:and-query((
								cts:element-range-query(xs:QName('GETCLIENTS:DATE'),'>=',xs:integer($fromYear)),
								cts:element-range-query(xs:QName('GETCLIENTS:DATE'),'<=',xs:integer($toYear))
							)) else(),
							if($representationID ne '' and $representationID ne 'All Types') then cts:element-value-query(xs:QName('GETCLIENTS:REPRESENTATION_TYPE_ID'),fn:tokenize($representationID,',')) else()
						))

    let $result := cts:values(cts:element-reference(xs:QName('GETCLIENTS:ORGANIZATION_NAME')), (), (),$andQuery)
	
	
	
	
                    
   let $loopData := for $item in fn:distinct-values($result)
                        let $res-obj := json:object()
                        let $ipCount := xdmp:estimate(cts:search(/,
                                            cts:and-query((
                                              cts:directory-query('/LegalCompass/denormalized-data/GetClients/'),
                                              cts:element-value-query(xs:QName('GETCLIENTS:FIRMID'),$firmID),
                                              cts:element-value-query(xs:QName('GETCLIENTS:ORGANIZATION_NAME'),$item,('exact')),
                                              cts:element-value-query(xs:QName('GETCLIENTS:LEVEL_1'),'IP'),
                                              if($fromYear ne '0' and $toYear ne '0') then cts:and-query((
                                                cts:element-range-query(xs:QName('GETCLIENTS:DATE'),'>=',xs:integer($fromYear)),
                                                cts:element-range-query(xs:QName('GETCLIENTS:DATE'),'<=',xs:integer($toYear))
                                              )) else(),

                                              if($representationID ne '' and $representationID ne 'All Types') then cts:element-value-query(xs:QName('GETCLIENTS:REPRESENTATION_TYPE_ID'),fn:tokenize($representationID,',')) else()

                                            ))))
                                            
                      let $litigationCount := xdmp:estimate(cts:search(/,
                                            cts:and-query((
                                              cts:directory-query('/LegalCompass/denormalized-data/GetClients/'),
                                              cts:element-value-query(xs:QName('GETCLIENTS:FIRMID'),$firmID),
                                              cts:element-value-query(xs:QName('GETCLIENTS:ORGANIZATION_NAME'),$item,('exact')),
                                              cts:element-value-query(xs:QName('GETCLIENTS:LEVEL_1'),'Litigation'),
                                              if($fromYear ne '0' and $toYear ne '0') then cts:and-query((
                                                cts:element-range-query(xs:QName('GETCLIENTS:DATE'),'>=',xs:integer($fromYear)),
                                                cts:element-range-query(xs:QName('GETCLIENTS:DATE'),'<=',xs:integer($toYear))
                                              )) else(),

                                              if($representationID ne '' and $representationID ne 'All Types') then cts:element-value-query(xs:QName('GETCLIENTS:REPRESENTATION_TYPE_ID'),fn:tokenize($representationID,',')) else()

                                            ))))
                    
                    let $transactionCount := xdmp:estimate(cts:search(/,
                                            cts:and-query((
                                              cts:directory-query('/LegalCompass/denormalized-data/GetClients/'),
                                              cts:element-value-query(xs:QName('GETCLIENTS:FIRMID'),$firmID),
                                              cts:element-value-query(xs:QName('GETCLIENTS:ORGANIZATION_NAME'),$item,('exact')),
                                              cts:element-value-query(xs:QName('GETCLIENTS:LEVEL_1'),'Transactional'),
                                              if($fromYear ne '0' and $toYear ne '0') then cts:and-query((
                                                cts:element-range-query(xs:QName('GETCLIENTS:DATE'),'>=',xs:integer($fromYear)),
                                                cts:element-range-query(xs:QName('GETCLIENTS:DATE'),'<=',xs:integer($toYear))
                                              )) else(),

                                              if($representationID ne '' and $representationID ne 'All Types') then cts:element-value-query(xs:QName('GETCLIENTS:REPRESENTATION_TYPE_ID'),fn:tokenize($representationID,',')) else()

                                            ))))
                                            
                   let $totalCount := xdmp:estimate(cts:search(/,
                                            cts:and-query((
                                              cts:directory-query('/LegalCompass/denormalized-data/GetClients/'),
                                              cts:element-value-query(xs:QName('GETCLIENTS:FIRMID'),$firmID),
                                              cts:element-value-query(xs:QName('GETCLIENTS:ORGANIZATION_NAME'),$item,('exact')),
                                              cts:element-value-query(xs:QName('GETCLIENTS:LEVEL_1'),('Litigation','IP','Transactional')),
                                              if($fromYear ne '0' and $toYear ne '0') then cts:and-query((
                                                cts:element-range-query(xs:QName('GETCLIENTS:DATE'),'>=',xs:integer($fromYear)),
                                                cts:element-range-query(xs:QName('GETCLIENTS:DATE'),'<=',xs:integer($toYear))
                                              )) else(),

                                              if($representationID ne '' and $representationID ne 'All Types') then cts:element-value-query(xs:QName('GETCLIENTS:REPRESENTATION_TYPE_ID'),fn:tokenize($representationID,',')) else()

                                            )))  )
                   
                   let $_ := (
                               map:put($res-obj,'Client',$item),
                               map:put($res-obj,'IntellectualProperty',$ipCount),
                               map:put($res-obj,'Litigation',$litigationCount),
                               map:put($res-obj,'Transaction',$transactionCount),
                               map:put($res-obj,'Total',$totalCount),
							   map:put($res-obj,'firmID',$firmID)
                             )
                 let $_ := json:array-push($res-array,$res-obj)
                 return()
                                            
                                            
                    
   return $res-array                 
}; :)

declare function firmnew:GetProBono($firmID)
{
    let $res-array := json:array()
    let $probonoMaxYear := max(cts:search(/,
                              cts:and-query((
                                cts:directory-query('/LegalCompass/relational-data/surveys/Pro_Bono/'),
								cts:element-value-query(xs:QName('Pro_Bono:ORGANIZATION_ID'),$firmID)
                              )))//Pro_Bono:PUBLISHYEAR/text())
    
    let $organizationData := cts:search(/,
                                              cts:and-query((
                                                cts:directory-query('/LegalCompass/relational-data/organization/'),
                                                cts:element-value-query(xs:QName('organizations:ORGANIZATION_ID'),$firmID)
                                              )))[1]
                          
   let $orgName := if($organizationData//organizations:ALM_NAME/text() ne '') then $organizationData//organizations:ALM_NAME/text()
                   else $organizationData//organizations:ORGANIZATION_NAME/text()
    
    let $loopData := for $item in (xs:integer($probonoMaxYear) - 9 to xs:integer($probonoMaxYear))
                          let $res-obj := json:object()
                          let $result := cts:search(/,
                                              cts:and-query((
                                                cts:directory-query('/LegalCompass/relational-data/surveys/Pro_Bono/'),
                                                cts:element-value-query(xs:QName('Pro_Bono:ORGANIZATION_ID'),$firmID),
                                                cts:element-value-query(xs:QName('Pro_Bono:PUBLISHYEAR'),xs:string($item))
                                              )))[1]
                         
                         let $_ := (
                                     map:put($res-obj,'PROBONO_ID',if($result//Pro_Bono:PROBONO_ID/text() ne '') then $result//Pro_Bono:PROBONO_ID/text() else 0),
                                     map:put($res-obj,'FirmId',xs:integer($firmID)),
                                     map:put($res-obj,'FirmName',$orgName),
                                     map:put($res-obj,'AvgHours',if($result//Pro_Bono:PROBONO_RANK/text() ne '') then xs:double($result//Pro_Bono:AVG_HRS_PER_LAWYER/text()) else 0),
                                     map:put($res-obj,'PercentageOfAttorney',if($result//Pro_Bono:PERCENT_LAWYERS_OVER_20_HRS/text() ne '') then xs:double($result//Pro_Bono:PERCENT_LAWYERS_OVER_20_HRS/text()) else 0),
                                     map:put($res-obj,'ProBonoRank',if($result//Pro_Bono:PROBONO_RANK/text() ne '') then xs:integer($result//Pro_Bono:PROBONO_RANK/text()) else 0),
                                     map:put($res-obj,'TotalHours',if( $result//Pro_Bono:TOTAL_HOURS/text() ne '') then xs:integer($result//Pro_Bono:TOTAL_HOURS/text()) else 0),
                                     map:put($res-obj,'PublishYear',xs:integer($item))
                                   )
                       let $_ := json:array-push($res-array,$res-obj)            
                       return()
                                              
   return $res-array                     
};

declare function firmnew:GetFirmAssociateComp($firmID)
{
   let $res-array := json:array()
   let $nljMaxYear := max(cts:search(/,
                         cts:and-query((
                           cts:directory-query('/LegalCompass/relational-data/surveys/NLJ_250/'),
                           cts:element-value-query(xs:QName('nlj250:ORGANIZATION_ID'),$firmID)
                         )))//nlj250:PUBLISHYEAR/text())
                         
    let $organizationData := cts:search(/,
                                              cts:and-query((
                                                cts:directory-query('/LegalCompass/relational-data/organization/'),
                                                cts:element-value-query(xs:QName('organizations:ORGANIZATION_ID'),$firmID)
                                              )))[1]
                          
   let $orgName := if($organizationData//organizations:ALM_NAME/text() ne '') then $organizationData//organizations:ALM_NAME/text()
                   else $organizationData//organizations:ORGANIZATION_NAME/text()                       
  
   let $loopData := for $item in (xs:integer($nljMaxYear) - 9 to xs:integer($nljMaxYear))
                       let $res-obj := json:object()
                       
                       let $result := cts:search(/,
                                         cts:and-query((
                                           cts:directory-query('/LegalCompass/relational-data/surveys/NLJ_250/'),
                                           cts:element-value-query(xs:QName('nlj250:ORGANIZATION_ID'),$firmID),
                                           cts:element-value-query(xs:QName('nlj250:PUBLISHYEAR'),xs:string($item))
                                         )))
                       
                       let $_ := (
                                   map:put($res-obj,'ORGANIZATION_ID',$result//nlj250:ORGANIZATION_ID/text()),
                                   map:put($res-obj,'ORGANIZATION_NAME',$orgName),
                                   map:put($res-obj,'FIRST_YEAR_SALARY',$result//nlj250:FIRST_YEAR_SALARY/text()),
                                   map:put($res-obj,'FIRST_YEAR_SALARY_HIGH',$result//nlj250:FIRST_YEAR_SALARY_HIGH/text()),
                                   map:put($res-obj,'FIRST_YEAR_SALARY_LOW',$result//nlj250:FIRST_YEAR_SALARY_LOW/text()),
                                   map:put($res-obj,'FISCAL_YEAR',$item)
                                 )
                      
                      let $_ := json:array-push($res-array,$res-obj)
                      return()
     
     return $res-array
};

declare function firmnew:GetFirmPartnerComp($firmID)
{
   let $res-array := json:array()
   let $amlawMaxYear := max(cts:search(/,
                         cts:and-query((
                           cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
                           cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$firmID)
                         )))//AMLAW_200:PUBLISHYEAR/text())
                         
    let $organizationData := cts:search(/,
                                              cts:and-query((
                                                cts:directory-query('/LegalCompass/relational-data/organization/'),
                                                cts:element-value-query(xs:QName('organizations:ORGANIZATION_ID'),$firmID)
                                              )))[1]
                          
   let $orgName := if($organizationData//organizations:ALM_NAME/text() ne '') then $organizationData//organizations:ALM_NAME/text()
                   else $organizationData//organizations:ORGANIZATION_NAME/text()                       
  
   let $loopData := for $item in (xs:integer($amlawMaxYear) - 9 to xs:integer($amlawMaxYear))
                       let $res-obj := json:object()
                       
                       let $result := cts:search(/,
                                         cts:and-query((
                                           cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
                                           cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$firmID),
                                           cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($item))
                                         )))
                       
                      let $_ := (
                                   map:put($res-obj,'FirmId',if($result//AMLAW_200:ORGANIZATION_ID/text()) then xs:integer($result//AMLAW_200:ORGANIZATION_ID/text()) else 0),
                                   map:put($res-obj,'FirmName',$orgName),
                                   map:put($res-obj,'CompValue',if($result//AMLAW_200:CAP/text()) then xs:integer($result//AMLAW_200:CAP/text()) else 0),
                                   map:put($res-obj,'PublishYear',$item)
                                 )
                      
                      let $_ := json:array-push($res-array,$res-obj)
                      return()
     
     return $res-array
};


declare function firmnew:IsFirmExistInUK50($firmID)
{
	let $maxYear := fn:max(cts:search(/,
								cts:and-query((
									cts:directory-query('/LegalCompass/relational-data/surveys/UK_50/')
								)))//UK_50:PUBLISHYEAR/text())

	let $result := 	cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/surveys/UK_50/'),
							cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),xs:string($firmID)),
							cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string($maxYear))
						)))[1]

	return fn:boolean($result)									 
};

declare function firmnew:GetLawFirmMergerData($newFirmID)
{
	let $date := fn:format-date(xs:date(xdmp:parse-dateTime('[Y01]-[M01]-[D01]',xs:string(fn:current-date() - xs:yearMonthDuration('P5Y')))),'[Y0001]-[M01]-[D01]')
	let $result := cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/surveys/LAWFIRM_MERGERS/'),
							cts:element-value-query(xs:QName('LAWFIRM_MERGERS:NEW_FIRM_ID'),$newFirmID),
							cts:element-value-query(xs:QName('LAWFIRM_MERGERS:TYPE'),'Merger'),
							cts:element-range-query(xs:QName('LAWFIRM_MERGERS:MERGER_DATE'),'>',xs:date($date))
						)))[1]

	let $primaryFirmID := if($result  != '') then $result//LAWFIRM_MERGERS:PRIMARY_FIRM_ID/text() else()					
	let $secondaryFirmID := if($result  != '') then $result//LAWFIRM_MERGERS:SECONDARY_FIRM_ID/text() else()

	 return if($primaryFirmID != '' and $secondaryFirmID != '') then
	 			if($newFirmID eq $primaryFirmID) then $secondaryFirmID else
				 if($newFirmID eq $secondaryFirmID) then $primaryFirmID else
				  concat($primaryFirmID,'|',$secondaryFirmID) 
		   else() 
};

declare function firmnew:GetLawFirmMergerDataForOverview($newFirmID)
{
	let $date := fn:format-date(xs:date(xdmp:parse-dateTime('[Y01]-[M01]-[D01]',xs:string(fn:current-date() - xs:yearMonthDuration('P10Y')))),'[Y0001]-[M01]-[D01]')
	let $result := cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/surveys/LAWFIRM_MERGERS/'),
							cts:element-value-query(xs:QName('LAWFIRM_MERGERS:NEW_FIRM_ID'),$newFirmID),
							cts:element-value-query(xs:QName('LAWFIRM_MERGERS:TYPE'),'Merger'),
							cts:element-range-query(xs:QName('LAWFIRM_MERGERS:MERGER_DATE'),'>',xs:date($date))
						)))[1]

	let $primaryFirmID := if($result  != '') then $result//LAWFIRM_MERGERS:PRIMARY_FIRM_ID/text() else()					
	let $secondaryFirmID := if($result  != '') then $result//LAWFIRM_MERGERS:SECONDARY_FIRM_ID/text() else()

	 return if($primaryFirmID != '' and $secondaryFirmID != '') then
	 			if($newFirmID eq $primaryFirmID) then $secondaryFirmID else
				 if($newFirmID eq $secondaryFirmID) then $primaryFirmID else
				  concat($primaryFirmID,'|',$secondaryFirmID) 
		   else() 
};

declare function firmnew:GetLawFirmMergerYear($newFirmID)
{
	let $date := fn:format-date(xs:date(xdmp:parse-dateTime('[Y01]-[M01]-[D01]',xs:string(fn:current-date() - xs:yearMonthDuration('P10Y')))),'[Y0001]-[M01]-[D01]')
	let $result := cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/surveys/LAWFIRM_MERGERS/'),
							cts:element-value-query(xs:QName('LAWFIRM_MERGERS:NEW_FIRM_ID'),$newFirmID),
							cts:element-value-query(xs:QName('LAWFIRM_MERGERS:TYPE'),'Merger'),
							cts:element-range-query(xs:QName('LAWFIRM_MERGERS:MERGER_DATE'),'>',xs:date($date))
						)))[1]

	return fn:year-from-date(xs:date($result//LAWFIRM_MERGERS:MERGER_DATE/text()))
};

declare function firmnew:IsFirmMerged($newFirmID)
{
	let $date := fn:format-date(xs:date(xdmp:parse-dateTime('[Y01]-[M01]-[D01]',xs:string(fn:current-date() - xs:yearMonthDuration('P5Y')))),'[Y0001]-[M01]-[D01]')
	let $result := cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/surveys/LAWFIRM_MERGERS/'),
							cts:element-value-query(xs:QName('LAWFIRM_MERGERS:NEW_FIRM_ID'),$newFirmID),
							cts:element-value-query(xs:QName('LAWFIRM_MERGERS:TYPE'),'Merger'),
							cts:element-range-query(xs:QName('LAWFIRM_MERGERS:MERGER_DATE'),'>',xs:date($date))
						)))[1]

	
	return fn:boolean($result)
	
};

declare function firmnew:IsFirmMergedForOverview($newFirmID)
{
	let $date := fn:format-date(xs:date(xdmp:parse-dateTime('[Y01]-[M01]-[D01]',xs:string(fn:current-date() - xs:yearMonthDuration('P10Y')))),'[Y0001]-[M01]-[D01]')
	let $result := cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/surveys/LAWFIRM_MERGERS/'),
							cts:element-value-query(xs:QName('LAWFIRM_MERGERS:NEW_FIRM_ID'),$newFirmID),
							cts:element-value-query(xs:QName('LAWFIRM_MERGERS:TYPE'),'Merger'),
							cts:element-range-query(xs:QName('LAWFIRM_MERGERS:MERGER_DATE'),'>',xs:date($date))
						)))[1]

	
	return fn:boolean($result)
	
};

declare function firmnew:SP_GETFIRMHEADCOUNTPostMerger($firmID)
{
	let $checkMergerData := firmnew:GetLawFirmMergerData($firmID)

	let $data := if($checkMergerData != '') then firmnew:SP_GETFIRMHEADCOUNTPM($firmID) else firmnew:SP_GETFIRMHEADCOUNT($firmID)
	return $data
};

declare function firmnew:SP_GETFIRMHEADCOUNT($firmID)
{
	let $res-array := json:array()
	let $maxYear := max(cts:search(/,
							cts:and-query((
								cts:directory-query('/LegalCompass/relational-data/organization-branch/'),
								cts:element-value-query(xs:QName('organization-branch:ORGANIZATION_ID'),$firmID)
							)))//organization-branch:FISCAL_YEAR)

	let $orgBranch := cts:search(/,
							cts:and-query((
								cts:directory-query('/LegalCompass/relational-data/organization-branch/'),
								cts:element-value-query(xs:QName('organization-branch:ORGANIZATION_ID'),$firmID),
								cts:element-range-query(xs:QName('organization-branch:FISCAL_YEAR'),'>=',xs:integer($maxYear) - 9),
								cts:element-range-query(xs:QName('organization-branch:FISCAL_YEAR'),'<=',xs:integer($maxYear))
							)))

	let $loopData := for $item in $orgBranch
						
						let $res-obj := json:object()
						let $leverage :=cts:search(/,
											cts:and-query((
											cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
											cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item//organization-branch:ORGANIZATION_ID/text()),
											cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($maxYear))
											)))[1]//AMLAW_200:LEVERAGE/text()

						let $organization := cts:search(/,
													cts:and-query((
														cts:directory-query('/LegalCompass/relational-data/organization/'),
														cts:element-value-query(xs:QName('rd-organization:ORGANIZATION_ID'),$firmID)
													)))[1]
						let $orgName := if(fn:not($organization//rd-organization:ALM_NAME/text() ne '')) then $organization//rd-organization:ORGANIZATION_NAME/text()
										else $organization//rd-organization:ALM_NAME/text()

						let $loc := if($item//organization-branch:COUNTRY/text() eq 'USA') then 
										fn:concat($item//organization-branch:CITY/text(),', ',$item//organization-branch:STATE/text())
									else
										fn:concat($item//organization-branch:CITY/text(),', ',$item//organization-branch:COUNTRY/text())	

						let $cityDetail := cts:search(/,
												cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/city_detail/'),
													cts:element-value-query(xs:QName('city_detail:STD_LOC'),$loc)
												)))[1]	

						let $nljData := cts:search(/,
												cts:and-query((
												cts:directory-query('/LegalCompass/relational-data/surveys/NLJ_250/'),
												cts:element-value-query(xs:QName('nlj250:ORGANIZATION_ID'),$firmID)
												)))[1]//nlj250:ORGANIZATION_ID/text()								

						let $_ := (
									map:put($res-obj,'FirmId',$item//organization-branch:ORGANIZATION_ID/text()),
									map:put($res-obj,'FirmName',$orgName),
									map:put($res-obj,'TotalAttorneys',xs:integer($item//organization-branch:NUM_ATTORNEYS/text())),
									map:put($res-obj,'Partners',xs:integer(fn:round-half-to-even($item//organization-branch:TOTAL_PARTNERS/text(),0))),
									map:put($res-obj,'EquityPartners',xs:integer(fn:round-half-to-even($item//organization-branch:EQUITY_PARTNERS/text(),0))),
									map:put($res-obj,'NonEquityPartners',xs:integer(fn:round-half-to-even($item//organization-branch:NON_EQUITY_PARTNERS/text(),0))),
									map:put($res-obj,'OtherAttorneys',xs:integer(fn:round-half-to-even($item//organization-branch:OTHER_ATTORNEYS/text(),0))),
									map:put($res-obj,'Associates',xs:integer(fn:round-half-to-even($item//organization-branch:ASSOCIATES/text(),0))),
									map:put($res-obj,'Location',$loc),
									map:put($res-obj,'Year',xs:integer($item//organization-branch:FISCAL_YEAR/text())),
									map:put($res-obj,'City',$item//organization-branch:CITY/text()),
									map:put($res-obj,'State',$item//organization-branch:STATE/text()),
									map:put($res-obj,'Country',$item//organization-branch:COUNTRY/text()),
									map:put($res-obj,'LEVERAGE',xs:decimal($leverage)),
									map:put($res-obj,'Latitude',$cityDetail//city_detail:LATITUDE/text()),
									map:put($res-obj,'Longitude',$cityDetail//city_detail:LONGITUDE/text())
								)
						let $_ :=if($nljData ne '') then json:array-push($res-array,$res-obj) else()

						return()

	return $res-array								
};

declare function firmnew:SP_GETFIRMHEADCOUNTPM($firmID)
{

	let $checkMergerData := firmnew:GetLawFirmMergerData($firmID)
	let $orgIDs := if($checkMergerData != '') then fn:tokenize(fn:concat(fn:string-join(fn:tokenize($firmID,'[|]'),','),',',$firmID),',') else $firmID

	let $res-array := json:array()
	let $maxYear := max(cts:search(/,
							cts:and-query((
								cts:directory-query('/LegalCompass/relational-data/organization-branch/'),
								cts:element-value-query(xs:QName('organization-branch:ORGANIZATION_ID'),$orgIDs)
							)))//organization-branch:FISCAL_YEAR)

	let $orgBranch := cts:search(/,
							cts:and-query((
								cts:directory-query('/LegalCompass/relational-data/organization-branch/'),
								cts:element-value-query(xs:QName('organization-branch:ORGANIZATION_ID'),$orgIDs),
								cts:element-range-query(xs:QName('organization-branch:FISCAL_YEAR'),'>=',xs:integer($maxYear) - 9),
								cts:element-range-query(xs:QName('organization-branch:FISCAL_YEAR'),'<=',xs:integer($maxYear))
							)))

	let $loopData := for $item in $orgBranch
						
						let $res-obj := json:object()
						let $leverage :=cts:search(/,
											cts:and-query((
											cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
											cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item//organization-branch:ORGANIZATION_ID/text()),
											cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($maxYear))
											)))[1]//AMLAW_200:LEVERAGE/text()

						let $organization := cts:search(/,
													cts:and-query((
														cts:directory-query('/LegalCompass/relational-data/organization/'),
														cts:element-value-query(xs:QName('rd-organization:ORGANIZATION_ID'),$firmID)
													)))[1]
						let $orgName := if(fn:not($organization//rd-organization:ALM_NAME/text() ne '')) then $organization//rd-organization:ORGANIZATION_NAME/text()
										else $organization//rd-organization:ALM_NAME/text()

						let $loc := if($item//organization-branch:COUNTRY/text() eq 'USA') then 
										fn:concat($item//organization-branch:CITY/text(),', ',$item//organization-branch:STATE/text())
									else
										fn:concat($item//organization-branch:CITY/text(),', ',$item//organization-branch:COUNTRY/text())	

						let $cityDetail := cts:search(/,
												cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/city_detail/'),
													cts:element-value-query(xs:QName('city_detail:STD_LOC'),$loc)
												)))[1]	

						let $nljData := cts:search(/,
												cts:and-query((
												cts:directory-query('/LegalCompass/relational-data/surveys/NLJ_250/'),
												cts:element-value-query(xs:QName('nlj250:ORGANIZATION_ID'),$firmID)
												)))[1]//nlj250:ORGANIZATION_ID/text()								

						let $_ := (
									map:put($res-obj,'FirmId',$item//organization-branch:ORGANIZATION_ID/text()),
									map:put($res-obj,'FirmName',$orgName),
									map:put($res-obj,'TotalAttorneys',xs:integer($item//organization-branch:NUM_ATTORNEYS/text())),
									map:put($res-obj,'Partners',xs:integer(fn:round-half-to-even($item//organization-branch:TOTAL_PARTNERS/text(),0))),
									map:put($res-obj,'EquityPartners',xs:integer(fn:round-half-to-even($item//organization-branch:EQUITY_PARTNERS/text(),0))),
									map:put($res-obj,'NonEquityPartners',xs:integer(fn:round-half-to-even($item//organization-branch:NON_EQUITY_PARTNERS/text(),0))),
									map:put($res-obj,'OtherAttorneys',xs:integer(fn:round-half-to-even($item//organization-branch:OTHER_ATTORNEYS/text(),0))),
									map:put($res-obj,'Associates',xs:integer(fn:round-half-to-even($item//organization-branch:ASSOCIATES/text(),0))),
									map:put($res-obj,'Location',$loc),
									map:put($res-obj,'Year',xs:integer($item//organization-branch:FISCAL_YEAR/text())),
									map:put($res-obj,'City',$item//organization-branch:CITY/text()),
									map:put($res-obj,'State',$item//organization-branch:STATE/text()),
									map:put($res-obj,'Country',$item//organization-branch:COUNTRY/text()),
									map:put($res-obj,'LEVERAGE',xs:decimal($leverage)),
									map:put($res-obj,'Latitude',$cityDetail//city_detail:LATITUDE/text()),
									map:put($res-obj,'Longitude',$cityDetail//city_detail:LONGITUDE/text())
								)
						let $_ :=if($nljData ne '') then json:array-push($res-array,$res-obj) else()

						return()

	return $res-array								
};

declare function firmnew:IsSurveyFirm($firmID)
{
	let $amLaw := cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
							cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$firmID)
						)))[1]//AMLAW_200:ORGANIZATION_ID/text()

	let $global100 := cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/surveys/Global_100/'),
							cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$firmID)
						)))[1]//Global_100:ORGANIZATION_ID/text()

	let $uk50 := cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/surveys/UK_50/'),
							cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),$firmID)
						)))[1]//UK_50:ORGANIZATION_ID/text()
	let $result := if($amLaw ne '' or $global100 ne '' or $uk50 ne '') then fn:boolean('true') else fn:boolean('')
	return $result
};

declare function firmnew:GetFirmExportTopicsAndField()
{
	let $topics := cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/TOPICS_EXPORT/')
						)))
	let $res-array := json:array()

	let $topicsList := for $result in $topics
							order by xs:integer($result//TOPICS_EXPORT:GROUP_ID/text()),xs:integer($result//TOPICS_EXPORT:ID/text()) ascending
							return $result

	let $loopData := for $result in $topicsList

						let $res-obj := json:object()
						let $_ := (
									map:put($res-obj,'ID',xs:integer($result//TOPICS_EXPORT:ID/text())),
									map:put($res-obj,'GroupID',xs:integer($result//TOPICS_EXPORT:GROUP_ID/text())),
									map:put($res-obj,'GroupName',$result//TOPICS_EXPORT:GROUP_NAME/text()),
									map:put($res-obj,'FieldName',$result//TOPICS_EXPORT:FIELD_NAME/text()),
									map:put($res-obj,'ENTITYFIELD',$result//TOPICS_EXPORT:ENTITY_FIELD/text()),
									map:put($res-obj,'ExportType',$result//TOPICS_EXPORT:EXPORT_TYPE/text()),
									map:put($res-obj,'IsSelected',if($result//TOPICS_EXPORT:ISSELECTED/text() eq '1') then fn:boolean('true') else fn:boolean('')),
									map:put($res-obj,'FieldType',$result//TOPICS_EXPORT:FIELDTYPE/text())
								)
						let $_ := json:array-push($res-array , $res-obj)	
						let $_ := if($result//TOPICS_EXPORT:FIELD_NAME/text() eq 'Headquarters') then json:array-push($res-array , $res-obj)	 else()
						return()	

	return $res-array
};	

declare function firmnew:SP_GETPRACTICEAREAS()
{
	let $result := fn:distinct-values(cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/REPRESENTATION_TYPES/'),
							cts:not-query(cts:element-value-query(xs:QName('REPRESENTATION_TYPES:LEVEL_2'),''))
						)))//REPRESENTATION_TYPES:LEVEL_1/text())
	let $res-array := json:array()

	let $loopData := for $item in $result
							
							let $result1 := fn:distinct-values(cts:search(/,
												cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/REPRESENTATION_TYPES/'),
													cts:not-query(cts:element-value-query(xs:QName('REPRESENTATION_TYPES:LEVEL_2'),'')),
													cts:element-value-query(xs:QName('REPRESENTATION_TYPES:LEVEL_1'),$item)
													)))//REPRESENTATION_TYPES:LEVEL_2/text())

							let $data := for $item1 in $result1						
											let $res-obj := json:object()
											let $_ := (
													map:put($res-obj,'LEVEL_1',$item),
													map:put($res-obj,'LEVEL_2',$item1)
												)

											let $_ := json:array-push($res-array , $res-obj)	
											return()
											return()

	return $res-array
	
													
};

declare function firmnew:GetMetroAreas()
{
	let $result := fn:distinct-values(cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/METRO_AREAS/')
						)))//METRO_AREAS:METRO_AREA/text())
	let $res-array := json:array()

	let $loopData := for $item in $result
						let $res-obj := json:object()
						let $_ := (map:put($res-obj,'MetroArea',$item))						
						let $_ := json:array-push($res-array,$res-obj)
						return()

	return $res-array					

};

 declare function firmnew:GetFirmSearchYears()
{
	let $amlawYear := fn:distinct-values(cts:search(/,
						cts:or-query((
							cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
							cts:directory-query('/LegalCompass/relational-data/surveys/DC20/'),
							cts:directory-query('/LegalCompass/relational-data/surveys/Global_100/'),
							cts:directory-query('/LegalCompass/relational-data/surveys/Legal_Times_150/'),
							cts:directory-query('/LegalCompass/relational-data/surveys/NLJ_250/'),
							cts:directory-query('/LegalCompass/relational-data/surveys/NY100/'),
							cts:directory-query('/LegalCompass/relational-data/surveys/ALIST/'),
							cts:directory-query('/LegalCompass/relational-data/surveys/TX100/')
						)))//*:PUBLISHYEAR/text())

	(:let $DC20 := fn:distinct-values(cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/surveys/DC20/')
						)))//*:PUBLISHYEAR/text())

	let $GLobal_100 := fn:distinct-values(cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/surveys/Global_100/')
						)))//*:PUBLISHYEAR/text())

	let $Legal_times_150 := fn:distinct-values(cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/surveys/Legal_Times_150/')
						)))//*:PUBLISHYEAR/text())

	let $NLJ_250 := fn:distinct-values(cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/surveys/NLJ_250/')
						)))//*:PUBLISHYEAR/text())

	let $NY100 := fn:distinct-values(cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/surveys/NY100/')
						)))//*:PUBLISHYEAR/text())

	let $AList := fn:distinct-values(cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/surveys/ALIST/')
						)))//*:PUBLISHYEAR/text())	

	let $TX100 := fn:distinct-values(cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/surveys/TX100/')
						)))//*:PUBLISHYEAR/text())	

	let $publishYear := fn:distinct-values(($amlawYear,$DC20,$GLobal_100,$Legal_times_150,$NLJ_250,$NY100,$AList,$TX100))	:)
	let $resArray := json:array()

	let $loopData := for $item in $amlawYear
						let $resObj := json:object()
						let $_ := map:put($resObj,'PublishYear',$item)
						let $_ := json:array-push($resArray,$resObj)
						return()
	return $resArray																																						
}; 

declare function firmnew:GetLawFirmMergerData1($newFirmID)
{
	let $result := cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/surveys/LAWFIRM_MERGERS/'),
							cts:element-value-query(xs:QName('LAWFIRM_MERGERS:NEW_FIRM_ID'),$newFirmID),
							cts:element-value-query(xs:QName('LAWFIRM_MERGERS:TYPE'),'Merger')
						)))[1]

	let $primaryFirmID := if($result  != '') then $result//LAWFIRM_MERGERS:PRIMARY_FIRM_ID/text() else()					
	let $secondaryFirmID := if($result  != '') then $result//LAWFIRM_MERGERS:SECONDARY_FIRM_ID/text() else()
	let $ids :=if($primaryFirmID ne '' and $secondaryFirmID ne '') then concat($primaryFirmID,',',$secondaryFirmID,',',$newFirmID)
				else if(fn:not($primaryFirmID ne '') and fn:not($secondaryFirmID ne '')) then $newFirmID
				else if(fn:not($primaryFirmID ne '')) then concat($secondaryFirmID,',',$newFirmID)
				else if(fn:not($secondaryFirmID ne '')) then concat($primaryFirmID,',',$newFirmID) else()
				
	return $ids
};



declare function firmnew:GetRepresentationData()
{
	let $result := cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/REPRESENTATION_TYPES/')
						)))

	let $resArray := json:array()
	let $loopDara := for $item in $result
						let $resObj := json:object()
						let $_ := (
									map:put($resObj,'RepresenationTypeName',$item//REPRESENTATION_TYPES:REPRESENTATION_TYPE_NAME/text()),
									map:put($resObj,'Level1',$item//REPRESENTATION_TYPES:LEVEL_1/text()),
									map:put($resObj,'Level2',$item//REPRESENTATION_TYPES:LEVEL_2/text()),
									map:put($resObj,'RepresenationTypeID',$item//REPRESENTATION_TYPES:REPRESENTATION_TYPE_ID/text())
									
								  )
						let $_ := json:array-push($resArray,$resObj)		  
						return()

	return $resArray					
};

declare function firmnew:GetLawFirmMergerDataList($newFirmID)
{
	let $result := cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/surveys/LAWFIRM_MERGERS/'),
							cts:element-value-query(xs:QName('LAWFIRM_MERGERS:NEW_FIRM_ID'),$newFirmID),
							cts:element-value-query(xs:QName('LAWFIRM_MERGERS:TYPE'),'Merger')
						)))[1]

	let $resArray := json:array()
	let $resObj := json:object()

	let $_ := (
				map:put($resObj,'PrimaryFirmName',$result//LAWFIRM_MERGERS:PRIMARY_FIRM/text()),
				map:put($resObj,'PrimaryFirmID',$result//LAWFIRM_MERGERS:PRIMARY_FIRM_ID/text()),
		
				map:put($resObj,'SecondaryFirmName',$result//LAWFIRM_MERGERS:SECONDARY_FIRM/text()),
				map:put($resObj,'SecondaryFirmID',$result//LAWFIRM_MERGERS:SECONDARY_FIRM_ID/text()),
			
				map:put($resObj,'NewFirmName',$result//LAWFIRM_MERGERS:NEW_FIRM/text()),
				map:put($resObj,'NewFirmID',$result//LAWFIRM_MERGERS:NEW_FIRM_ID/text())
			 )

	(: let $_ := if($result != '') then json:array-push($resArray,$resObj) else() :)

	return if($result != '') then $resObj else()

	(:let $_ := (
				map:put($resObj,'FirmName',$result//LAWFIRM_MERGERS:PRIMARY_FIRM/text()),
				map:put($resObj,'FirmID',$result//LAWFIRM_MERGERS:PRIMARY_FIRM_ID/text())
			 )


	let $_ := if($result != '') then json:array-push($resArray,$resObj) else()

	let $resObj := json:object()
	let $_ := (
				map:put($resObj,'FirmName',$result//LAWFIRM_MERGERS:SECONDARY_FIRM_ID/text()),
				map:put($resObj,'SecondaryFirmID',$result//LAWFIRM_MERGERS:SECONDARY_FIRM/text())
			 )

	let $_ := if($result != '') then json:array-push($resArray,$resObj) else()

	let $resObj := json:object()
	let $_ := (
				map:put($resObj,'NewFirmName',$result//LAWFIRM_MERGERS:NEW_FIRM/text()),
				map:put($resObj,'NewFirmID',$result//LAWFIRM_MERGERS:NEW_FIRM_ID/text())
			 )

	let $_ := if($result != '') then json:array-push($resArray,$resObj) else():)
};

declare function firmnew:GetFirmList($firmIds)
{
	let $firmIds := fn:tokenize($firmIds,',')

	let $maxYears := fn:max(cts:element-values(xs:QName('AMLAW_200:PUBLISHYEAR'),(),('descending'), cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/')))

	let $response-arr := json:array()

	let $AMLAW_200_IDS := cts:element-values(xs:QName('AMLAW_200:ORGANIZATION_ID'),(),(),
	cts:and-query((
		cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'), xs:string($maxYears))
		,if($firmIds ne '') then cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'), xs:string($firmIds)) else ()
	)))
	
	let $GLOBAL_100_IDS := cts:element-values(xs:QName('Global_100:ORGANIZATION_ID'),(),(),
	cts:and-query((
		cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'), xs:string($maxYears))
		,if($firmIds ne '') then cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'), xs:string($firmIds)) else ()
	)))

	let $UK_50_IDS := cts:element-values(xs:QName('UK_50:ORGANIZATION_ID'),(),(),
	cts:and-query((
		cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'), xs:string($maxYears))
		,if($firmIds ne '') then cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'), xs:string($firmIds)) else ()
	)))
	
	let $IDS := fn:distinct-values(($AMLAW_200_IDS,$GLOBAL_100_IDS,$UK_50_IDS))

	let $ORG_RES := cts:search(/,
	cts:and-query((
		cts:directory-query("/LegalCompass/relational-data/organization/")
		,cts:element-value-query(xs:QName('rd-organization:ORGANIZATION_ID'),$IDS ! xs:string(.))
	)))

	let $Result := for $res in $ORG_RES
		let $orgId := $res//rd-organization:ORGANIZATION_ID/text()
		let $orgName := $res//rd-organization:ORGANIZATION_NAME/text()
		
		let $AMLAW200_RANK:= cts:search(/,
			cts:and-query((
			cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'), xs:string($orgId))
			,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'), xs:string($maxYears))
		)))//AMLAW_200:AMLAW200_RANK/text()
		
		let $RANK_BY_GROSS_REVENUE := cts:search(/,
			cts:and-query((
			cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'), xs:string($orgId))
			,cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'), xs:string($maxYears))
		)))[1]//Global_100:RANK_BY_GROSS_REVENUE/text()
		
		let $UK_50_RANK := cts:search(/,
			cts:and-query((
			cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'), xs:string($orgId))
			,cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'), xs:string($maxYears))
		)))[1]//UK_50:UK_50_RANK/text()
		
		return if($AMLAW200_RANK ne '' or $RANK_BY_GROSS_REVENUE ne '' or $UK_50_RANK ne '')
			then 
			let $response-obj := json:object()
			let $_ := (
			map:put($response-obj,'ORGANIZATION_ID',$orgId)
			,map:put($response-obj,'ORGANIZATION_Name',$orgName)
			,map:put($response-obj,'AMLAW200_RANK',$AMLAW200_RANK)
			,map:put($response-obj,'RANK_BY_GROSS_REVENUE',$RANK_BY_GROSS_REVENUE)
			,map:put($response-obj,'UK_50_RANK',$UK_50_RANK)
			)
			let $_ := json:array-push($response-arr,$response-obj)
			return ()
			else ()
	
	return $response-arr
};

declare function firmnew:GetMergedFirmData($newFirmID)
{
	let $result := cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/surveys/LAWFIRM_MERGERS/'),
							cts:element-value-query(xs:QName('LAWFIRM_MERGERS:NEW_FIRM_ID'),$newFirmID),
							cts:element-value-query(xs:QName('LAWFIRM_MERGERS:TYPE'),'Merger')
						)))[1]

	let $xml := element{'MergedData'}{
						element{'FirmData'}{
							element{'FirmName'}{$result//LAWFIRM_MERGERS:PRIMARY_FIRM/text()},
							element{'FirmID'}{$result//LAWFIRM_MERGERS:PRIMARY_FIRM_ID/text()}
						},
						element{'FirmData'}{
							element{'FirmName'}{$result//LAWFIRM_MERGERS:SECONDARY_FIRM/text()},
							element{'FirmID'}{$result//LAWFIRM_MERGERS:SECONDARY_FIRM_ID/text()}
						},
						element{'FirmData'}{
							element{'FirmName'}{$result//LAWFIRM_MERGERS:NEW_FIRM/text()},
							element{'FirmID'}{$result//LAWFIRM_MERGERS:NEW_FIRM_ID/text()}
						}
	}					
			
	return $xml

};

declare function firmnew:GetClientMaxYear($firmID)
{
    let $andQuery := cts:and-query((
                            cts:directory-query('/LegalCompass/denormalized-data/GetClients/'),
							cts:element-value-query(xs:QName('GETCLIENTS:FIRMID'),$firmID)
                        ))

    let $result := fn:max(cts:search(/,
                        $andQuery
							)//GETCLIENTS:DATE/text())

    
    return $result                
};

declare function firmnew:GetClientsCountExport()
{
	let $request := xdmp:get-request-body()/request
	

	let $OrganisationID := $request/FirmID/text()
	let $checkMergerData := (:firmnew:GetLawFirmMergerData($OrganisationID):) ''

	let $firmID := if($checkMergerData != '') then fn:tokenize(fn:concat(fn:string-join(fn:tokenize($checkMergerData,'[|]'),','),',',$OrganisationID),',') else $OrganisationID
	let $fromYear := xs:integer($request/FromYear/text())
	let $toYear := xs:integer($request/ToYear/text()) 
	let $representationIDs := $request/RepresentationID/text()
	let $PageNo := $request/PageNo/text()
	let $PageSize := $request/PageSize/text()
	let $SortBy := $request/SortBy/text()
	let $sortDirection := $request/SortDirection/text()
	let $sortDir := if(fn:lower-case($sortDirection) eq 'asc') then 'ascending' else 'descending'
	let $representation := $request/Representation/text()

	let $orderBy :=if($SortBy eq 'Source') then cts:index-order(cts:element-reference(xs:QName('GETCLIENTS:SOURCE')) ,$sortDir)
                 else if($SortBy eq 'Client') then cts:index-order(cts:element-reference(xs:QName('GETCLIENTS:CLIENT')) ,$sortDir)
                       else if($SortBy eq 'TypeOfTransaction') then cts:index-order(cts:element-reference(xs:QName('GETCLIENTS:TYPEOFTRANSACTION')) ,$sortDir)
					   else if($SortBy eq 'Date') then cts:index-order(cts:element-reference(xs:QName('GETCLIENTS:DATE')) ,$sortDir)
                            else cts:index-order(cts:element-reference(xs:QName('GETCLIENTS:DATE')) ,'descending')

	 let $fromRecord := if(xs:string($PageNo) ne '1') then (xs:int($PageNo)-1)*xs:int($PageSize) else 1
 	 let $toRecord := xs:int($PageSize)*xs:int($PageNo)

	let $response-arr := json:array()
	
	let $organization := 0 (:fn:doc(fn:concat('/LegalCompass/denormalized-data/organization/',$firmID,'.xml')):)
	let $organizationID :='' (:$organization//organization:ORGANIZATION_ID/text():)
	let $organizationName :='' (:if ($organization//organization:ALM_NAME/text() != '') then ($organization//organization:ALM_NAME/text()) else fn:normalize-space($organization//organization:ORGANIZATION_NAME/text()):)
	let $totalCount := xdmp:estimate(cts:search(/,
							cts:and-query((
								cts:directory-query('/LegalCompass/denormalized-data/GetClients/'),
								if($firmID ne '') then cts:element-value-query(xs:QName('GETCLIENTS:FIRMID'),$firmID) else(),

								if(xs:string($fromYear) ne '' and xs:string($toYear) ne '') then cts:and-query((
											cts:element-range-query(xs:QName('GETCLIENTS:DATE'),'>=',$fromYear),
											cts:element-range-query(xs:QName('GETCLIENTS:DATE'),'<=',$toYear)
								)) else(),

								if($representation ne '' and $representation ne 'All Types') then  cts:element-value-query(xs:QName('GETCLIENTS:REPRESENTATION_TYPE_ID'),fn:tokenize($representationIDs,',')) else()
							))))

	return $totalCount
};

declare function firmnew:GetVolatilityData($firmID)
{
	let $maxYear := fn:max(cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/AMLaw_Volatility/')
						)))//AMLaw_Volatility:Publish_Year/text())

	let $result := cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/AMLaw_Volatility/'),
							cts:element-value-query(xs:QName('AMLaw_Volatility:Organization_ID'),xs:string($firmID)),
							cts:element-value-query(xs:QName('AMLaw_Volatility:Publish_Year'),xs:string($maxYear))
						)))[1]

	let $jsonObj := json:object()

	let $_ := (
					map:put($jsonObj,'OrganizationID',xs:integer($firmID)),
					map:put($jsonObj,'RevenueVolatilityActualScore',if($result//AMLaw_Volatility:Revenue_Volatility_Score/text()) 
																		then fn:round-half-to-even($result//AMLaw_Volatility:Revenue_Volatility_Score/text(),0) else 0),
					map:put($jsonObj,'PPPVolatilityActualScore',if($result//AMLaw_Volatility:PPP__Volatility_Score/text()) then fn:round-half-to-even($result//AMLaw_Volatility:PPP__Volatility_Score/text() , 0) else 0),
					map:put($jsonObj,'PPPRiskIndex',if($result//AMLaw_Volatility:PPP_Risk_Index/text()) then 
														fn:round-half-to-even($result//AMLaw_Volatility:PPP_Risk_Index/text() * 100,0) else 0),
					map:put($jsonObj,'AverageRevenueGrowth5Years',if($result//AMLaw_Volatility:Average_Revenue_Growth_5Years/text()) then 
																		fn:round-half-to-even($result//AMLaw_Volatility:Average_Revenue_Growth_5Years/text() * 100,0) else 0),
					map:put($jsonObj,'LateralDepaturesTotalPartners',if($result//AMLaw_Volatility:Lateral_Depatures_Total_Partners/text()) then 
																			fn:round-half-to-even($result//AMLaw_Volatility:Lateral_Depatures_Total_Partners/text() * 100,0) else 0)
			  )	

	return $jsonObj		  									
};

declare function firmnew:IsMansfieldFirm($firmID)
{
		let $data := cts:search(/,
						cts:and-query((
						cts:directory-query('/LegalCompass/relational-data/organization/')
						,cts:element-value-query(xs:QName('organizations:ORGANIZATION_ID'),$firmID)
						,cts:not-query(cts:element-value-query(xs:QName('organizations:MANSFIELD_RULE_STATUS'),''))
						)))
		return if(count($data)>0) then 'true' else 'false'
};