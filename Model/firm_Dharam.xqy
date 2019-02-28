xquery version '1.0-ml';

module namespace firm = 'http://alm.com/firm_2';

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





declare function firm:GetLawFirmPracticearea(
	$firmID as xs:string
)
{
	let $RE_ID := firm:GetREIdByOrgId($firmID)

	let $response-arr := json:array()
	
	let $response := for $practice_area in cts:element-values(xs:QName('practices_kws:practice_area'))
		
		let $key := fn:concat('*',$practice_area,'*')
		(:let $result := cts:search(/person,
			cts:and-query((
			cts:collection-query($config:RD-PEOPLE-COLLECTION),
				cts:directory-query($config:RD-PEOPLE-PATH),
				cts:element-value-query(xs:QName('rd_person:company'),$RE_ID),
				cts:element-word-query(xs:QName('rd_person:std_practices'),$key,('wildcarded','case-insensitive')),
				cts:not-query(cts:element-value-query(xs:QName('rd_person:std_practices'),''))
			))):)
		let $additional-query := cts:and-query((
			cts:collection-query($config:RD-PEOPLE-COLLECTION),
				cts:directory-query($config:RD-PEOPLE-PATH),
				cts:element-value-query(xs:QName('rd_person:company'),$RE_ID),
				cts:element-word-query(xs:QName('rd_person:std_practices'),$key,('wildcarded','case-insensitive')),
				cts:not-query(cts:element-value-query(xs:QName('rd_person:std_practices'),''))
        	))	
		
		(:let $additional-queryPartner := cts:and-query((
			cts:collection-query($config:RD-PEOPLE-COLLECTION),
				cts:directory-query($config:RD-PEOPLE-PATH),
				cts:element-value-query(xs:QName('rd_person:company'),$RE_ID),
				cts:element-word-query(xs:QName('rd_person:std_practices'),$key,('wildcarded','case-insensitive')),
				cts:not-query(cts:element-value-query(xs:QName('rd_person:std_practices'),'')),
        cts:element-value-query(xs:QName('rd_person:std_title'),'Partner')
			))
		
		let $additional-queryOther := cts:and-query((
			cts:collection-query($config:RD-PEOPLE-COLLECTION),
				cts:directory-query($config:RD-PEOPLE-PATH),
				cts:element-value-query(xs:QName('rd_person:company'),$RE_ID),
				cts:element-word-query(xs:QName('rd_person:std_practices'),$key,('wildcarded','case-insensitive')),
				cts:not-query(cts:element-value-query(xs:QName('rd_person:std_practices'),'')),
            cts:element-value-query(xs:QName('rd_person:std_title'),'Other')
			))

		let $additional-queryAssociate := cts:and-query((
			cts:collection-query($config:RD-PEOPLE-COLLECTION),
				cts:directory-query($config:RD-PEOPLE-PATH),
				cts:element-value-query(xs:QName('rd_person:company'),$RE_ID),
				cts:element-word-query(xs:QName('rd_person:std_practices'),$key,('wildcarded','case-insensitive')),
				cts:not-query(cts:element-value-query(xs:QName('rd_person:std_practices'),'')),
        cts:element-value-query(xs:QName('rd_person:std_title'),'Associate')
			))
		
		let $additional-queryAdministrative := cts:and-query((
			cts:collection-query($config:RD-PEOPLE-COLLECTION),
				cts:directory-query($config:RD-PEOPLE-PATH),
				cts:element-value-query(xs:QName('rd_person:company'),$RE_ID),
				cts:element-word-query(xs:QName('rd_person:std_practices'),$key,('wildcarded','case-insensitive')),
				cts:not-query(cts:element-value-query(xs:QName('rd_person:std_practices'),'')),
        cts:element-value-query(xs:QName('rd_person:std_title'),'Administrative / Support Staff')
			))
			
		let $additional-queryAssociateOtherC := cts:and-query((
			cts:collection-query($config:RD-PEOPLE-COLLECTION),
				cts:directory-query($config:RD-PEOPLE-PATH),
				cts:element-value-query(xs:QName('rd_person:company'),$RE_ID),
				cts:element-word-query(xs:QName('rd_person:std_practices'),$key,('wildcarded','case-insensitive')),
				cts:not-query(cts:element-value-query(xs:QName('rd_person:std_practices'),'')),
        cts:element-value-query(xs:QName('rd_person:std_title'),'Other Counsel/Attorney')
			))	:)
		

		(:let $HeadCount := count(cts:values(cts:element-reference(xs:QName('rd_person:std_title')), (), (), $additional-queryHC)) 
		let $PartnerCount := count(cts:values(cts:element-reference(xs:QName('rd_person:std_title')), (), (), $additional-queryPartner)) 
		let $AssociateCount := count(cts:values(cts:element-reference(xs:QName('rd_person:std_title')), (), (), $additional-queryAssociate)) 
		let $OtherCounselCount := count(cts:values(cts:element-reference(xs:QName('rd_person:std_title')), (), (), $additional-queryAssociateOtherC)) 
		let $AdminCount := count(cts:values(cts:element-reference(xs:QName('rd_person:std_title')), (), (), $additional-queryAdministrative)) 
		let $OtherCount := count(cts:values(cts:element-reference(xs:QName('rd_person:std_title')), (), (), $additional-queryOther)) :)
		let $PartnerCount := 0
		let $AssociateCount := 0
		let $HeadCount := 0
		let $OtherCounselCount := 0
		let $AdminCount := 0
		let $OtherCount := 0

		let $loopData := for $title in cts:values(cts:element-reference(xs:QName('rd_person:std_title')), (), (), $additional-query)
							 let $_ := if($title eq 'Partner') then xdmp:set($PartnerCount,cts:frequency($title)) else 0
							 let $_ := if($title eq 'Other') then xdmp:set($OtherCount,cts:frequency($title)) else 0
							 let $_ := if($title eq 'Associate') then xdmp:set($AssociateCount,cts:frequency($title)) else 0
							 let $_ := if($title eq 'Administrative / Support Staff') then xdmp:set($AdminCount,cts:frequency($title)) else 0
							 let $_ := if($title eq 'Other Counsel/Attorney') then xdmp:set($OtherCounselCount,cts:frequency($title)) else 0
							 return()
							 
		let $HeadCount := $PartnerCount + $OtherCount + $AssociateCount	+ $AdminCount + $OtherCounselCount
		
		let $obj := if ($HeadCount > 0) then 
			element {'RECORD'} {
				element {'Practicearea'} {$practice_area},
				element {'HeadCount'} {$HeadCount},
				element {'PartnerCount'} {$PartnerCount},
				element {'FirmID'} {$RE_ID},
				element {'AssociateCount'} {$AssociateCount},
				element {'OtherCounselCount'} {$OtherCounselCount},
				element {'AdminCount'} {$AdminCount},
				element {'OtherCount'} {$OtherCount}
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

declare function firm:GetLawFirmPracticearea1(
	$firmID as xs:string
)
{
	let $res-arr := json:array()
	let $RE_ID := firm:GetREIdByOrgId($firmID)

	let $response-arr := json:array()
	
	for $practice_area in cts:element-values(xs:QName('practices_kws:practice_area'))

    let $key := fn:concat('*',$practice_area,'*')
		
		
		let $additional-query := cts:and-query((
			cts:collection-query($config:RD-PEOPLE-COLLECTION),
				cts:directory-query($config:RD-PEOPLE-PATH),
				cts:element-value-query(xs:QName('rd_person:company'),$RE_ID),
				cts:element-word-query(xs:QName('rd_person:std_practices'),$key,('wildcarded','case-insensitive')),
				cts:not-query(cts:element-value-query(xs:QName('rd_person:std_practices'),'')),
				cts:element-value-query(xs:QName('rd_person:std_title'),('Partner','Other','Associate','Administrative / Support Staff','Other Counsel/Attorney'))
			))
		let $PartnerCount := 0
		let $AssociateCount := 0
		let $HeadCount := 0
		let $OtherCounselCount := 0
		let $AdminCount := 0
		let $OtherCount := 0
		let $titleT := ''
		
		
		let $res-obj := json:object()
		let $result := for $item in cts:values(cts:element-reference(xs:QName('rd_person:std_title')), (), (), $additional-query)
					   
					   let $_ := (map:put($res-obj,'Title',$item),
								  map:put($res-obj,'Count',cts:frequency($item)),
								  map:put($res-obj,'Practice',$practice_area))
					   let $_ := json:array-push($res-arr,$res-obj)
				(:let $additional-query := cts:and-query((
						cts:collection-query($config:RD-PEOPLE-COLLECTION),
							cts:directory-query($config:RD-PEOPLE-PATH),
							cts:element-value-query(xs:QName('rd_person:company'),$RE_ID),
							cts:element-word-query(xs:QName('rd_person:std_practices'),$key,('wildcarded','case-insensitive')),
							cts:not-query(cts:element-value-query(xs:QName('rd_person:std_practices'),'')),
							cts:element-value-query(xs:QName('rd_person:std_title'),$item)
						))
				:)
				
				return ()
				return $res-arr			(:($practice_area,'-',cts:frequency($result)):)

		 (:for $title in cts:values(cts:element-reference(xs:QName('rd_person:std_title')), (), (), $additional-query)
				let $obj := if ($HeadCount > 0) then 
				element {'RECORD'} {
				element {'Practicearea'} {$practice_area},
				element {'PartnerCount'} {count($title)},
				element {'FirmID'} {$RE_ID},,
				element {'HeadCount'} {$HeadCount},
				element {'AssociateCount'} {$AssociateCount},
				element {'OtherCounselCount'} {$OtherCounselCount},
				element {'AdminCount'} {$AdminCount},
				element {'OtherCount'} {$OtherCount},
				element {'Title'} {$title}
			}
								return $obj
							 let $_ := if($title eq 'Partner') then xdmp:set($PartnerCount,cts:frequency($title)) else xdmp:set($PartnerCount,0)
							 let $_ := if($title eq 'Other') then xdmp:set($OtherCount,cts:frequency($title)) else xdmp:set($OtherCount,0)
							 let $_ := if($title eq 'Associate') then xdmp:set($AssociateCount,cts:frequency($title)) else xdmp:set($AssociateCount,0)
							 let $_ := if($title eq 'Administrative / Support Staff') then xdmp:set($AdminCount,cts:frequency($title)) else xdmp:set($AdminCount,0)
							 let $_ := if($title eq 'Other Counsel/Attorney') then xdmp:set($OtherCounselCount,cts:frequency($title)) else  xdmp:set($OtherCounselCount,0)
							 let $_ := xdmp:set($titleT,$title)
							 return()
							 
		let $HeadCount := $PartnerCount + $OtherCount + $AssociateCount	+ $AdminCount + $OtherCounselCount
		
		let $obj := if ($HeadCount > 0) then 
			element {'RECORD'} {
				element {'Practicearea'} {$practice_area},
				element {'HeadCount'} {$HeadCount},
				element {'PartnerCount'} {$PartnerCount},
				element {'FirmID'} {$RE_ID},
				element {'AssociateCount'} {$AssociateCount},
				element {'OtherCounselCount'} {$OtherCounselCount},
				element {'AdminCount'} {$AdminCount},
				element {'OtherCount'} {$OtherCount},
				element {'Title'} {$titleT}
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

	return $response:)
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
