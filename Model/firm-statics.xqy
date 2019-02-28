xquery version "1.0-ml";

module namespace firmstatics = "http://alm.com/firm-statics";

import module namespace firm = 'http://alm.com/firm' at '/common/model/firm.xqy';

declare namespace cityns = "http://alm.com/LegalCompass/rd/city";
declare namespace people = "http://alm.com/LegalCompass/rd/person";
declare namespace lcpd="http://alm.com/LegalCompass/dd/person_detail";
declare namespace practices = "http://alm.com/LegalCompass/rd/practices_kws";
declare namespace peoplechanges = "http://alm.com/LegalCompass/rd/people_changes";
declare namespace alidata = "http://alm.com/LegalCompass/rd/FIRMS_ALI_XREF_RE";
declare namespace rd_person = 'http://alm.com/LegalCompass/rd/person';
declare namespace city = 'http://alm.com/LegalCompass/rd/city';
declare namespace city_detail = 'http://alm.com/LegalCompass/rd/city_detail';
declare namespace organization ="http://alm.com/LegalCompass/lawfirm/dd/organization";
declare namespace organizations ="http://alm.com/LegalCompass/rd/organization";
declare namespace tblrer = "http://alm.com/LegalCompass/dd/TBL_RER_CACHE_ATTORNEY_DATA";
declare namespace tblrermovechanges = "http://alm.com/LegalCompass/dd/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES";
declare namespace aliattorneydata = 'http://alm.com/LegalCompass/dd/ALI_RE_Attorney_Data';

declare namespace Global_100 = 'http://alm.com/LegalCompass/rd/Global_100';
declare namespace AMLAW_200 = 'http://alm.com/LegalCompass/rd/AMLAW_200';
declare namespace UK_50 = 'http://alm.com/LegalCompass/rd/UK_50';

import module namespace config = 'http://alm.com/config' at '/common/config.xqy';
import module namespace json = "http://marklogic.com/xdmp/json"  at "/MarkLogic/json/json.xqy";

declare function firmstatics:sp_GetLawFirmStaticsPracticeChangesByFirm($cities,$countries,$geoGraphicRegion,$usRegions,$practiceArea,$firmID,$fromDate,$toDate)
{
  let $PracticeAreas := firmstatics:getPracticeAreas($practiceArea)
  let $Cities := if($cities ne '' or $countries ne '' or $geoGraphicRegion ne '' or $usRegions ne '') then 
                    firmstatics:getGtandardLocations($cities,$countries,$geoGraphicRegion,$usRegions,'') else()
  
  let $query := cts:and-query(((
                   cts:directory-query('/LegalCompass/relational-data/person/'),
                   if($practiceArea ne '') then cts:element-value-query(xs:QName('people:std_practices'),$PracticeAreas) else(),
                   if($Cities ne '') then cts:element-value-query(xs:QName('people:std_loc'),$Cities) else(),
                   if($firmID ne '') then cts:element-value-query(xs:QName('people:company'),$firmID) else()
                   )))
  

 let $res-array := json:array()
 let $search := for $company in cts:values(cts:element-reference(xs:QName('rd_person:company')), (), (),$query)
 let $res-object := json:object()
 let $headcount := xdmp:estimate(cts:search(/,
    cts:and-query((
    cts:directory-query('/LegalCompass/relational-data/person/')
    ,if($practiceArea ne '') then cts:element-value-query(xs:QName('rd_person:practice_area'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
    ,if($Cities ne '') then cts:element-value-query(xs:QName('rd_person:std_loc'), $Cities) else()
    ,cts:element-value-query(xs:QName('rd_person:company'), xs:string($company))
    ,cts:element-value-query(xs:QName('rd_person:std_title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
    
    ))))
 let $headcountplus := xdmp:estimate(cts:search(/,
    cts:and-query((
    cts:directory-query('/LegalCompass/relational-data/person/changes/')
    ,if($practiceArea ne '') then cts:element-value-query(xs:QName('peoplechanges:std_practices'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
    ,if($Cities ne '') then cts:element-value-query(xs:QName('peoplechanges:std_loc'), $Cities) else()
    ,cts:element-value-query(xs:QName('peoplechanges:company'), xs:string($company))
    ,cts:element-value-query(xs:QName('peoplechanges:std_title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
    ,cts:element-value-query(xs:QName('peoplechanges:action'),'added')
    ))))
 let $headcountminus := xdmp:estimate(cts:search(/,
    cts:and-query((
    cts:directory-query('/LegalCompass/relational-data/person/changes/')
    ,if($practiceArea ne '') then cts:element-value-query(xs:QName('peoplechanges:std_practices'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
    ,if($Cities ne '') then cts:element-value-query(xs:QName('peoplechanges:std_loc'), $Cities) else()
    ,cts:element-value-query(xs:QName('peoplechanges:company'), xs:string($company))
    ,cts:element-value-query(xs:QName('peoplechanges:std_title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
    ,cts:element-value-query(xs:QName('peoplechanges:action'),'removed')  
    ))))
    
    let $firmDetail := firmstatics:getFIRMS_ALI_XREF_REData($company)  
    let $diff := xs:decimal($headcountplus)-xs:decimal($headcountminus)
    let $div := if($headcount ne 0) then ($diff div xs:decimal($headcount))*xs:double(100) else 0
	let $firmName := if($firmDetail/alidata:RE_FIRMNAME/text() ne '') then $firmDetail/alidata:RE_FIRMNAME/text() else $firmDetail/alidata:ALI_NAME/text()
    let $_ := ( map:put($res-object,'firmID',$firmDetail/alidata:RE_ID/text()),
                map:put($res-object,'firmName',$firmName),
                map:put($res-object,'headCount',$headcount),
               map:put($res-object,'headCountPlus',$headcountplus),
                map:put($res-object,'headCountMinus',$headcountminus),
                map:put($res-object,'changes',fn:round($div)))
    let $_ := json:array-push($res-array,$res-object)
    return ()
  
  return $res-array
};

declare function firmstatics:getFIRMS_ALI_XREF_REData($firmID)
{
   let $result := cts:search(/FIRMS_ALI_XREF_RE,
                     cts:and-query((
                       cts:directory-query('/LegalCompass/relational-data/FIRMS_ALI_XREF_RE/'),
                       cts:element-value-query(xs:QName('alidata:RE_ID'),xs:string($firmID))
                       )))
  return $result
};

declare function firmstatics:getGtandardLocations($cities,$countries,$geoGraphicRegion,$usRegions,$state)
{
  (:
  let $result := cts:search(/,
                     cts:and-query((
                       cts:directory-query('/LegalCompass/relational-data/city/'),
                       if($cities ne '') then cts:element-value-query(xs:QName('cityns:city'),fn:tokenize($cities,',')) else(),
                       if($countries ne '') then cts:element-value-query(xs:QName('cityns:country'),fn:tokenize($countries,',')) else(),
                       if($geoGraphicRegion ne '') then cts:element-value-query(xs:QName('cityns:geographic_region'),fn:tokenize($geoGraphicRegion,',')) else(),
                       if($usRegions ne '') then cts:element-value-query(xs:QName('cityns:us_region'),fn:tokenize($usRegions,',')) else()
                       )))
  return $result//cityns:std_loc/text()
	:)
	 (:let $citiess := for $city in fn:tokenize($cities,',')
	return fn:replace($city,"-",", ")
  let $result := cts:search(/,
                     cts:and-query((
                       cts:directory-query('/LegalCompass/relational-data/city/'),
					   cts:or-query((
                       if($cities ne '') then cts:element-value-query(xs:QName('cityns:std_loc'),$citiess) else(),
                       if($countries ne '') then cts:element-value-query(xs:QName('cityns:country'),fn:tokenize($countries,',')) else(),
                       if($geoGraphicRegion ne '') then cts:element-value-query(xs:QName('cityns:geographic_region'),fn:tokenize($geoGraphicRegion,',')) else(),
                       if($usRegions ne '') then cts:element-value-query(xs:QName('cityns:us_region'),fn:tokenize($usRegions,',')) else()
                       )))))
  return $result//cityns:std_loc/text():)
  
  let $citiess :=if($cities ne '') then  for $city in fn:tokenize($cities,',')
					  return fn:replace($city,"-",", ")
				 else()	  
					  
  let $result := cts:search(/,
                     cts:and-query((
                       cts:directory-query('/LegalCompass/relational-data/city/'),
					   cts:or-query((
                       if($cities ne '') then cts:element-value-query(xs:QName('cityns:std_loc'),$citiess) else(),
                       if($countries ne '') then cts:element-value-query(xs:QName('cityns:country'),fn:tokenize($countries,',')) else(),
                       if($state ne '') then cts:element-value-query(xs:QName('cityns:state'),fn:tokenize($state,',')) else(),
                       if($geoGraphicRegion ne '') then cts:element-value-query(xs:QName('cityns:geographic_region'),fn:tokenize($geoGraphicRegion,',')) else(),
                       if($usRegions ne '') then cts:element-value-query(xs:QName('cityns:us_region'),fn:tokenize($usRegions,',')) else()
                       )))))
  return $result//cityns:std_loc/text()
};

declare function firmstatics:getPracticeAreas($practiceArea)
{
  let $practices := fn:tokenize($practiceArea,'[|]')
  let $result := cts:search(/ ,
                     cts:and-query((
                       cts:directory-query('/LegalCompass/relational-data/practices_kws/'),
                       if($practiceArea ne '') then cts:element-word-query(xs:QName('practices:practice_area'),$practices,('wildcarded')) else()
                     )))
  return fn:distinct-values($result//practices:practice_area/text())
};

declare function firmstatics:sp_GetLawFirmStaticsByPracticenew1($cities,$countries,$geoGraphicRegion,$usRegions,$practiceArea,$firmID,$fromDate,$toDate)
{
  let $PracticeAreas := firmstatics:getPracticeAreas($practiceArea)
  let $Cities := if($cities ne '' or $countries ne '' or $geoGraphicRegion ne '' or $usRegions ne '') then 
                    firmstatics:getGtandardLocations($cities,$countries,$geoGraphicRegion,$usRegions,'') else()
  (:let $firmIDs := if($firmID ne '') then firmstatics:getFIRMS_ALI_XREF_REData1(fn:tokenize($firmID,',')) else():)
  let $query := cts:and-query(((
                   cts:directory-query($config:RD-PEOPLE-PATH),
                   if($practiceArea ne '') then cts:element-value-query(xs:QName('rd_person:std_practices'),$PracticeAreas) else(),
                   if($Cities ne '') then cts:element-value-query(xs:QName('rd_person:std_loc'),$Cities) else(),
                   if($firmID ne '') then cts:element-value-query(xs:QName('rd_person:company'),fn:tokenize($firmID,',')) else()
                   )))
  
 let $totalCount := xdmp:estimate(cts:search(/,$query))
 let $res-array := json:array()
 let $search := for $company in cts:values(cts:element-reference(xs:QName('rd_person:company')), (), (),$query)
 let $res-object := json:object()
 
 let $headcount := xdmp:estimate(cts:search(/,
    cts:and-query((
    cts:directory-query($config:RD-PEOPLE-PATH)
    ,if($practiceArea ne '') then cts:element-value-query(xs:QName('rd_person:practice_area'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
    ,if($Cities ne '') then cts:element-value-query(xs:QName('rd_person:std_loc'), $Cities) else()
    ,cts:element-value-query(xs:QName('rd_person:company'), xs:string($company))
    ,cts:element-value-query(xs:QName('rd_person:std_title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
    ))))
let $headcountplus := xdmp:estimate(cts:search(/,
    cts:and-query((
    cts:directory-query('/LegalCompass/relational-data/person/changes/')
    ,if($practiceArea ne '') then cts:element-value-query(xs:QName('peoplechanges:practice_area'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
    ,if($Cities ne '') then cts:element-value-query(xs:QName('peoplechanges:std_loc'), $Cities) else()
    ,cts:element-value-query(xs:QName('peoplechanges:company'), xs:string($company))
    ,cts:element-value-query(xs:QName('peoplechanges:std_title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
    ,cts:element-value-query(xs:QName('peoplechanges:action'),'added')))))
 let $headcountminus := xdmp:estimate(cts:search(/,
    cts:and-query((
      cts:directory-query('/LegalCompass/relational-data/person/changes/')
      ,if($practiceArea ne '') then cts:element-value-query(xs:QName('peoplechanges:practice_area'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
      ,if($Cities ne '') then cts:element-value-query(xs:QName('peoplechanges:std_loc'), $Cities) else()
      ,cts:element-value-query(xs:QName('peoplechanges:company'), xs:string($company))
      ,cts:element-value-query(xs:QName('peoplechanges:std_title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
      ,cts:element-value-query(xs:QName('peoplechanges:action'),'removed')   
    ))))
  let $partnercount := xdmp:estimate(cts:search(/,
    cts:and-query((
    $query
    ,cts:element-value-query(xs:QName('rd_person:company'), xs:string($company))
    ,cts:element-value-query(xs:QName('rd_person:std_title'), ('Partner'))
    ))))
  let $partnercountplus := xdmp:estimate(cts:search(/,
    cts:and-query((
   cts:directory-query('/LegalCompass/relational-data/person/changes/')
      ,if($practiceArea ne '') then cts:element-value-query(xs:QName('peoplechanges:practice_area'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
      ,if($Cities ne '') then cts:element-value-query(xs:QName('peoplechanges:std_loc'), $Cities) else()
      ,cts:element-value-query(xs:QName('peoplechanges:company'), xs:string($company))
    ,cts:element-value-query(xs:QName('peoplechanges:company'), xs:string($company))
    ,cts:element-value-query(xs:QName('peoplechanges:std_title'), ('Partner'))
    ,cts:element-value-query(xs:QName('peoplechanges:action'), ('added'))
    ))))  
  let $partnercountminus := xdmp:estimate(cts:search(/,
    cts:and-query((
      cts:directory-query('/LegalCompass/relational-data/person/changes/')
      ,if($practiceArea ne '') then cts:element-value-query(xs:QName('peoplechanges:practice_area'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
      ,if($Cities ne '') then cts:element-value-query(xs:QName('peoplechanges:std_loc'), $Cities) else()
    ,cts:element-value-query(xs:QName('peoplechanges:company'), xs:string($company))
    ,cts:element-value-query(xs:QName('peoplechanges:std_title'), ('Partner'))
    ,cts:element-value-query(xs:QName('peoplechanges:action'), ('removed'))
    ))))  
    
  let $associatecount := xdmp:estimate(cts:search(/,
    cts:and-query((
    $query
    ,cts:element-value-query(xs:QName('rd_person:company'), xs:string($company))
    ,cts:element-value-query(xs:QName('rd_person:std_title'), ('Associate'))
    ))))
    let $associatecountplus := xdmp:estimate(cts:search(/,
    cts:and-query((
    cts:directory-query('/LegalCompass/relational-data/person/changes/')
      ,if($practiceArea ne '') then cts:element-value-query(xs:QName('peoplechanges:practice_area'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
      ,if($Cities ne '') then cts:element-value-query(xs:QName('peoplechanges:std_loc'), $Cities) else()
    ,cts:element-value-query(xs:QName('peoplechanges:company'), xs:string($company))
    ,cts:element-value-query(xs:QName('peoplechanges:std_title'), ('Associate'))
    ,cts:element-value-query(xs:QName('peoplechanges:action'), ('added'))
    ))))
    let $associatecountminus := xdmp:estimate(cts:search(/,
    cts:and-query((
    cts:directory-query('/LegalCompass/relational-data/person/changes/')
      ,if($practiceArea ne '') then cts:element-value-query(xs:QName('peoplechanges:practice_area'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
      ,if($Cities ne '') then cts:element-value-query(xs:QName('peoplechanges:std_loc'), $Cities) else()
    ,cts:element-value-query(xs:QName('peoplechanges:company'), xs:string($company))
    ,cts:element-value-query(xs:QName('peoplechanges:std_title'), ('Associate'))
    ,cts:element-value-query(xs:QName('peoplechanges:action'), ('removed'))
    ))))
    
  let $othercouselcount := xdmp:estimate(cts:search(/,
    cts:and-query((
    $query
    ,cts:element-value-query(xs:QName('rd_person:company'), xs:string($company))
    ,cts:element-value-query(xs:QName('rd_person:std_title'), ('Other Counsel/Attorney'),"case-insensitive")
    )))) 
  let $othercouselcountplus := xdmp:estimate(cts:search(/,
    cts:and-query((
    cts:directory-query('/LegalCompass/relational-data/person/changes/')
      ,if($practiceArea ne '') then cts:element-value-query(xs:QName('peoplechanges:practice_area'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
      ,if($Cities ne '') then cts:element-value-query(xs:QName('peoplechanges:std_loc'), $Cities) else()
    ,cts:element-value-query(xs:QName('peoplechanges:company'), xs:string($company))
    ,cts:element-value-query(xs:QName('peoplechanges:std_title'), ('Other Counsel/Attorney'),"case-insensitive")
    ,cts:element-value-query(xs:QName('peoplechanges:action'), ('added'))
    )))) 
  let $othercouselcountminus := xdmp:estimate(cts:search(/,
    cts:and-query((
    cts:directory-query('/LegalCompass/relational-data/person/changes/')
      ,if($practiceArea ne '') then cts:element-value-query(xs:QName('peoplechanges:practice_area'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
      ,if($Cities ne '') then cts:element-value-query(xs:QName('peoplechanges:std_loc'), $Cities) else()
    ,cts:element-value-query(xs:QName('peoplechanges:company'), xs:string($company))
    ,cts:element-value-query(xs:QName('peoplechanges:std_title'), ('Other Counsel/Attorney'),"case-insensitive")
    ,cts:element-value-query(xs:QName('peoplechanges:action'), ('removed'))
    ))))   
  let $admincount := xdmp:estimate(cts:search(/,
    cts:and-query((
    $query
    ,cts:element-value-query(xs:QName('rd_person:company'), xs:string($company))
    ,cts:element-value-query(xs:QName('rd_person:std_title'), ('Administrative / Support Staff'),"case-insensitive")
    )))) 
     let $admincountplus := xdmp:estimate(cts:search(/,
    cts:and-query((
    cts:directory-query('/LegalCompass/relational-data/person/changes/')
      ,if($practiceArea ne '') then cts:element-value-query(xs:QName('peoplechanges:practice_area'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
      ,if($Cities ne '') then cts:element-value-query(xs:QName('peoplechanges:std_loc'), $Cities) else()
    ,cts:element-value-query(xs:QName('peoplechanges:company'), xs:string($company))
    ,cts:element-value-query(xs:QName('peoplechanges:std_title'), ('Administrative / Support Staff'),"case-insensitive")
    ,cts:element-value-query(xs:QName('peoplechanges:action'), ('added'))
    )))) 
     let $admincountminus := xdmp:estimate(cts:search(/,
    cts:and-query((
    cts:directory-query('/LegalCompass/relational-data/person/changes/')
      ,if($practiceArea ne '') then cts:element-value-query(xs:QName('peoplechanges:practice_area'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
      ,if($Cities ne '') then cts:element-value-query(xs:QName('peoplechanges:std_loc'), $Cities) else()
    ,cts:element-value-query(xs:QName('peoplechanges:company'), xs:string($company))
    ,cts:element-value-query(xs:QName('peoplechanges:std_title'), ('Administrative / Support Staff'),"case-insensitive")
    ,cts:element-value-query(xs:QName('peoplechanges:action'), ('removed'))
    )))) 
  let $othercount :=  xdmp:estimate(cts:search(/,
    cts:and-query((
    $query
    ,cts:element-value-query(xs:QName('rd_person:company'), xs:string($company))
    ,cts:element-value-query(xs:QName('rd_person:std_title'), ('Other'),"case-insensitive")))))
  let $othercountplus :=  xdmp:estimate(cts:search(/,
    cts:and-query((
   cts:directory-query('/LegalCompass/relational-data/person/changes/')
      ,if($practiceArea ne '') then cts:element-value-query(xs:QName('peoplechanges:practice_area'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
      ,if($Cities ne '') then cts:element-value-query(xs:QName('peoplechanges:std_loc'), $Cities) else()
    ,cts:element-value-query(xs:QName('peoplechanges:company'), xs:string($company))
    ,cts:element-value-query(xs:QName('peoplechanges:std_title'), ('Other'),"case-insensitive")
    ,cts:element-value-query(xs:QName('peoplechanges:action'), ('added'))))))
  let $othercountminus :=  xdmp:estimate(cts:search(/,
    cts:and-query((
    cts:directory-query('/LegalCompass/relational-data/person/changes/')
      ,if($practiceArea ne '') then cts:element-value-query(xs:QName('peoplechanges:practice_area'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
      ,if($Cities ne '') then cts:element-value-query(xs:QName('peoplechanges:std_loc'), $Cities) else()
    ,cts:element-value-query(xs:QName('peoplechanges:company'), xs:string($company))
    ,cts:element-value-query(xs:QName('peoplechanges:std_title'), ('Other'),"case-insensitive")
    ,cts:element-value-query(xs:QName('peoplechanges:action'), ('removed'))
    ))))
 
 
         let $firmDetail := firmstatics:getFIRMS_ALI_XREF_REData($company)  
		 let $diff := xs:decimal($headcountplus)-xs:decimal($headcountminus)
		 let $div := if($headcount ne 0) then ($diff div xs:decimal($headcount))*xs:double(100) else 0
		 let $firmName := if($firmDetail/alidata:RE_FIRMNAME/text() ne '') then $firmDetail/alidata:RE_FIRMNAME/text() else $firmDetail/alidata:ALI_NAME/text()
    let $_ := (map:put($res-object,'firmID',$firmDetail/alidata:ALI_ID/text()),
                map:put($res-object,'firmName',$firmName),
                map:put($res-object,'LOCATION',''),
                map:put($res-object,'officesTotal',''),
                map:put($res-object,'practicesTotal',''),
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

declare function firmstatics:sp_GetLawFirmStaticsCount3($cities,$countries,$geoGraphicRegion,$usRegions,$practiceArea,$firmID,$fromDate,$toDate,$firmSizefrom,$firmSizeTo)
{
  let $PracticeAreas := firmstatics:getPracticeAreas($practiceArea)
  let $Cities := if($cities ne '' or $countries ne '' or $geoGraphicRegion ne '' or $usRegions ne '') then 
                    firmstatics:getGtandardLocations($cities,$countries,$geoGraphicRegion,$usRegions,'') else()
  let $aliID := fn:string-join(fn:distinct-values(cts:search(/,
									cts:and-query((
										cts:directory-query('/LegalCompass/denormalized-data/ALI_RE_Attorney_Data/'),
										if($firmID ne '') then cts:element-value-query(xs:QName('aliattorneydata:ALI_ID'),fn:tokenize($firmID,',')) else()
										)))//aliattorneydata:ALI_ID/text()),',')	
										
  let $firmIDs := firmstatics:getFIRMS_ALI_XREF_REData2(fn:tokenize($aliID,','))
  let $query := cts:and-query(((
                   cts:directory-query($config:RD-PEOPLE-PATH),
                   if($practiceArea ne '') then cts:element-word-query(xs:QName('rd_person:std_practices'),$PracticeAreas,('wildcarded','case-insensitive')) else(),
                   if($Cities ne '') then cts:element-value-query(xs:QName('rd_person:std_loc'),$Cities) else(),
                   cts:element-value-query(xs:QName('rd_person:company'),$firmIDs)
                   )))
				   
 let $res-array := json:array()
 let $search := for $company in cts:values(cts:element-reference(xs:QName('rd_person:company')), (), (),$query)
 let $res-object := json:object()
		 
 let $headcount := xdmp:estimate(cts:search(/,
    cts:and-query((
    cts:directory-query('/LegalCompass/denormalized-data/ALI_RE_Attorney_Data/')
    ,if($practiceArea ne '') then cts:element-word-query(xs:QName('aliattorneydata:practices'), $PracticeAreas, ('wildcarded','case-insensitive')) else()
    ,if($Cities ne '') then cts:element-word-query(xs:QName('aliattorneydata:location'), $Cities,('wildcarded')) else()
    ,cts:element-value-query(xs:QName('aliattorneydata:firm_id'), xs:string($company))
    ,cts:element-value-query(xs:QName('aliattorneydata:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
    ))))
         

	let $firmDetail := firmstatics:getFIRMS_ALI_XREF_REData($company)
	let $firmName := if($firmDetail/alidata:RE_FIRMNAME/text() ne '') then $firmDetail/alidata:RE_FIRMNAME/text() else $firmDetail/alidata:ALI_NAME/text()
	let $_ := (map:put($res-object,'firmID', $company),
                map:put($res-object,'firmName',$firmName))
    let $_ := if($firmSizefrom ne '0' and $firmSizeTo ne '0') then if($headcount ge xs:integer($firmSizefrom) and $headcount le xs:integer($firmSizeTo)) then json:array-push($res-array,$res-object) else() else json:array-push($res-array,$res-object)
	return()
  return $res-array
};

declare function firmstatics:sp_GetLawFirmStaticsCount3_1($cities,$countries,$geoGraphicRegion,$usRegions,$practiceArea,$firmID,$fromDate,$toDate,$firmSizefrom,$firmSizeTo)
{
  let $PracticeAreas := firmstatics:getPracticeAreas($practiceArea)
  let $Cities := if($cities ne '' or $countries ne '' or $geoGraphicRegion ne '' or $usRegions ne '') then 
                    firmstatics:getGtandardLocations($cities,$countries,$geoGraphicRegion,$usRegions,'') else()
					
  let $aliAttorneyQuery := cts:and-query((
										cts:directory-query('/LegalCompass/denormalized-data/ALI_RE_Attorney_Data/'),
										 if($practiceArea ne '') then cts:element-word-query(xs:QName('aliattorneydata:practices'),$PracticeAreas,('wildcarded','case-insensitive')) else(),
										 if($Cities ne '') then cts:element-value-query(xs:QName('aliattorneydata:location'),$Cities) else(),
										 if($firmID ne '') then cts:element-value-query(xs:QName('aliattorneydata:ALI_ID'),fn:tokenize($firmID,',')) else()
										))		
										
  (:let $aliID :=cts:values(cts:element-reference(xs:QName('aliattorneydata:ALI_ID')), (), (),$aliAttorneyQuery)
 
										
  let $firmIDs := firmstatics:getFIRMS_ALI_XREF_REData2($aliID):)
 
				   
 let $res-array := json:array()
 let $search := for $company in cts:values(cts:element-reference(xs:QName('aliattorneydata:ALI_ID')), (), (),$aliAttorneyQuery)
		 let $res-object := json:object()
				 
		 let $headcount := xdmp:estimate(cts:search(/,
			cts:and-query((
			cts:directory-query('/LegalCompass/denormalized-data/ALI_RE_Attorney_Data/')
			,if($practiceArea ne '') then cts:element-word-query(xs:QName('aliattorneydata:practices'), $PracticeAreas, ('wildcarded','case-insensitive')) else()
			,if($Cities ne '') then cts:element-word-query(xs:QName('aliattorneydata:location'), $Cities,('wildcarded')) else()
			,cts:element-value-query(xs:QName('aliattorneydata:ALI_ID'), xs:string($company))
			,cts:element-value-query(xs:QName('aliattorneydata:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
			))))

			let $firmName := if(cts:search(/,
								cts:and-query((
								cts:directory-query('/LegalCompass/denormalized-data/ALI_RE_Attorney_Data/')
								,cts:element-value-query(xs:QName('aliattorneydata:ALI_ID'), xs:string($company))
								)))//aliattorneydata:ALM_NAME/text() ne '') then cts:search(/,
																					cts:and-query((
																					cts:directory-query('/LegalCompass/denormalized-data/ALI_RE_Attorney_Data/')
																					,cts:element-value-query(xs:QName('aliattorneydata:ALI_ID'), xs:string($company))
																					)))[1]//aliattorneydata:ALM_NAME/text()
																			  else cts:search(/,
																						cts:and-query((
																						cts:directory-query('/LegalCompass/denormalized-data/ALI_RE_Attorney_Data/')
																						,cts:element-value-query(xs:QName('aliattorneydata:ALI_ID'), xs:string($company))
																						)))[1]//aliattorneydata:firm_name/text()	
			
			let $firmID := cts:search(/,
								cts:and-query((
								cts:directory-query('/LegalCompass/denormalized-data/ALI_RE_Attorney_Data/')
								,cts:element-value-query(xs:QName('aliattorneydata:ALI_ID'),xs:string($company))
								)))[1]//aliattorneydata:firm_id/text()
								
			let $_ := (map:put($res-object,'firmID', $firmID),
						map:put($res-object,'firmName',$firmName))
			let $_ := if($firmSizefrom ne '0' and $firmSizeTo ne '0') then if($headcount ge xs:integer($firmSizefrom) and $headcount le xs:integer($firmSizeTo)) then json:array-push($res-array,$res-object) else() else json:array-push($res-array,$res-object)
			return()
  return $res-array
};

declare function firmstatics:getFIRMS_ALI_XREF_REData1($aliID)
{
   let $result := cts:search(/FIRMS_ALI_XREF_RE,
                     cts:and-query((
                       cts:directory-query('/LegalCompass/relational-data/FIRMS_ALI_XREF_RE/'),
                       cts:element-value-query(xs:QName('alidata:ALI_ID'),xs:string($aliID))
                       )))/alidata:RE_ID/text()
  return $result
};

declare function firmstatics:getFIRMS_ALI_XREF_REData2($aliID)
{
   let $aliIDs := ($aliID) ! fn:string(.)
   let $result := cts:search(/,
                     cts:and-query((
                       cts:directory-query('/LegalCompass/relational-data/FIRMS_ALI_XREF_RE/'),
                       cts:element-value-query(xs:QName('alidata:ALI_ID'),$aliIDs)
                       )))//alidata:RE_ID/text()
   return $result
};

declare function firmstatics:getFIRMS_ALI_XREF_REData3($aliID)
{
   let $aliIDs := ($aliID) ! fn:string(.)
   let $result := cts:values(cts:element-reference(xs:QName("alidata:RE_ID")),(),(),
	cts:and-query((
	cts:directory-query('/LegalCompass/relational-data/FIRMS_ALI_XREF_RE/')
	,cts:element-value-query(xs:QName('alidata:RE_ID'),$aliIDs)
	))
	)
   return $result
};


(:declare function firmstatics:getFIRMS_ALI_XREF_REData($firmID)
{
   let $result := cts:search(/FIRMS_ALI_XREF_RE,
                     cts:and-query((
                       cts:directory-query('/LegalCompass/relational-data/FIRMS_ALI_XREF_RE/'),
                       cts:element-value-query(xs:QName('alidata:RE_ID'),xs:string($firmID))
                       )))
  return $result
};:)

(:declare function firmstatics:getGtandardLocations($cities,$countries,$geoGraphicRegion,$usRegions)
{
  let $result := cts:search(/,
                     cts:and-query((
                       cts:directory-query('/LegalCompass/relational-data/city/'),
                       if($cities ne '') then cts:element-value-query(xs:QName('cityns:city'),$cities) else(),
                       if($countries ne '') then cts:element-value-query(xs:QName('cityns:country'),$countries) else(),
                       if($geoGraphicRegion ne '') then cts:element-value-query(xs:QName('cityns:geographic_region'),$geoGraphicRegion) else(),
                       if($usRegions ne '') then cts:element-value-query(xs:QName('cityns:us_region'),$usRegions) else()
                       )))
  return fn:string-join($result//cityns:std_loc/text(),',')
};

declare function firmstatics:getPracticeAreas($practiceArea)
{
  let $practices := fn:tokenize($practiceArea,'[|]')
 let $result := cts:search(/practices_kws ,
                     cts:and-query((
                       cts:directory-query('/LegalCompass/relational-data/practices_kws/'),
                       if($practiceArea ne '') then cts:element-value-query('practices:practice_area',fn:concat('*',$practices,'*'),("wildcarded")) else()
                     )))
  return fn:string-join($result/practices:practice_area/text(),',')
};
:)

declare function firmstatics:sp_GetLawFirmStaticsCount3_2($cities,$countries,$geoGraphicRegion,$usRegions,$practiceArea,$firmID,$fromDate,$toDate,$firmSizefrom,$firmSizeTo,$state)
{
  (:let $PracticeAreas := if($practiceArea ne '') then firmstatics:getPracticeAreas($practiceArea) else ()
  let $Cities := if($cities ne '' or $countries ne '' or $geoGraphicRegion ne '' or $usRegions ne '') then 
                    firmstatics:getGtandardLocations($cities,$countries,$geoGraphicRegion,$usRegions) else()
					
  let $aliAttorneyQuery := cts:and-query((
										cts:directory-query('/LegalCompass/denormalized-data/ALI_RE_Attorney_Data/'),
										 if($PracticeAreas ne '') then cts:element-value-query(xs:QName('aliattorneydata:practice_area'),$PracticeAreas,('wildcarded','case-insensitive')) else(),
										 
										 if($Cities ne '') then cts:element-value-query(xs:QName('aliattorneydata:location'),$Cities) else(),
										 if($firmID ne '') then cts:element-value-query(xs:QName('aliattorneydata:ALI_ID'),fn:tokenize($firmID,',')) else()
										))
 let $aliIDs := if($PracticeAreas ne '' or $Cities ne '' or $firmID ne '') then fn:distinct-values(cts:search(/, 
																							$aliAttorneyQuery
																							)//aliattorneydata:ALI_ID/text())
				else cts:values(cts:element-reference(xs:QName('aliattorneydata:ALI_ID')), (), (),$aliAttorneyQuery)				   
 for $company in $aliIDs 
		
		 let $headcount := xdmp:estimate(cts:search(/,
			cts:and-query((
			cts:directory-query('/LegalCompass/denormalized-data/ALI_RE_Attorney_Data/')
			,if($practiceArea ne '') then cts:element-word-query(xs:QName('aliattorneydata:practices'), $PracticeAreas, ('wildcarded','case-insensitive')) else()
			,if($Cities ne '') then cts:element-word-query(xs:QName('aliattorneydata:location'), $Cities,('wildcarded')) else()
			,cts:element-value-query(xs:QName('aliattorneydata:ALI_ID'), xs:string($company))
			,cts:element-value-query(xs:QName('aliattorneydata:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
			))))
			
			let $aliIDS := if($headcount ge xs:integer($firmSizefrom) and $headcount le xs:integer($firmSizeTo)) then $company else()
			return $aliIDS:)
			
			
	let $PracticeAreas := if($practiceArea ne '') then firmstatics:getPracticeAreas($practiceArea) else()
  let $Cities := if($cities ne '' or $countries ne '' or $geoGraphicRegion ne '' or $usRegions ne '' or $state ne '') then 
                    firmstatics:getGtandardLocations($cities,$countries,$geoGraphicRegion,$usRegions,$state) else()
  
  let $attorneyQuery := cts:and-query((
										cts:directory-query('/LegalCompass/denormalized-data/ALI_RE_Attorney_Data/'),
										 if($PracticeAreas ne '') then cts:element-word-query(xs:QName('aliattorneydata:practice_area'),$PracticeAreas,('wildcarded','case-insensitive')) else(),
										 
										 if($Cities ne '') then cts:element-value-query(xs:QName('aliattorneydata:location'),$Cities,"exact") else(),
										 if($firmID ne '') then cts:element-value-query(xs:QName('aliattorneydata:ALI_ID'),fn:tokenize($firmID,',')) else()
										))
										
  let $aliIDs := if($PracticeAreas ne '' or $Cities ne '' or $firmID ne '') then fn:distinct-values(cts:search(/, 
																							$attorneyQuery
																							)//aliattorneydata:ALI_ID/text())
				else cts:values(cts:element-reference(xs:QName('aliattorneydata:ALI_ID')), (), (),$attorneyQuery)																		
					

  
  let $reIDs := firmstatics:getFIRMS_ALI_XREF_REData2($aliIDs) ! fn:string(.)
 
  			   
  let $firmIDS := cts:values(cts:element-reference(xs:QName('tblrer:firm_id')), (), (), cts:and-query((
							   cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/'),
							   if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrer:practices'),$PracticeAreas,('wildcarded','case-insensitive')) else(),
							   if($Cities ne '') then cts:element-word-query(xs:QName('tblrer:location'),$Cities,'wildcarded') else(),
							   cts:element-value-query(xs:QName('tblrer:firm_id'),$reIDs)
							   )))

		
  let $firmIDS := for $firmID in $firmIDS
		let $res := cts:search(/,
		cts:and-query((
			cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/')
			,cts:element-value-query(xs:QName('tblrer:firm_id'),($firmID ! xs:string(.)))
			,cts:not-query(cts:element-value-query(xs:QName('tblrer:firm_name'),''))
			)))[1]
	order by $res//tblrer:firm_name/text() ascending
	return $res//tblrer:firm_id/text()
  
  let $totalCount := count($reIDs)
 
 let $res-array := json:array()
 for $company in $firmIDS
 
				 let $res-object := json:object()
				 
				 let $headcount := xdmp:estimate(cts:search(/,
					cts:and-query((
					cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/')
					,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrer:practices'), $PracticeAreas, ('wildcarded','case-insensitive')) else()
					,if($Cities ne '') then cts:element-value-query(xs:QName('tblrer:location'), $Cities,('wildcarded','case-insensitive')) else()
					,cts:element-value-query(xs:QName('tblrer:firm_id'), xs:string($company))
					,cts:element-value-query(xs:QName('tblrer:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
					))))
				
				 let $idS := if($headcount ge xs:integer($firmSizefrom) and $headcount le xs:integer($firmSizeTo)) then $company else()
			return $idS
};


declare function firmstatics:sp_GetLawFirmStaticsByPracticenew2($cities,$countries,$geoGraphicRegion,$usRegions,$practiceArea,$firmID,$fromDate,$toDate,$PageNo,$PageSize,$firmSizefrom,$firmSizeTo,$state,$isPrimaryPracticeArea,$isHeadquarter)
{

  let $PracticeAreas := if($practiceArea ne '') then firmstatics:getPracticeAreas($practiceArea) else()
  let $Cities := if($cities ne '' or $countries ne '' or $geoGraphicRegion ne '' or $usRegions ne '' or $state ne '') then 
                    firmstatics:getGtandardLocations($cities,$countries,$geoGraphicRegion,$usRegions,$state) else()
  
  let $attorneyQuery := cts:and-query((
										cts:directory-query('/LegalCompass/denormalized-data/ALI_RE_Attorney_Data/'),
										 if($PracticeAreas ne '') then 
                        if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('aliattorneydata:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                        else cts:element-word-query(xs:QName('aliattorneydata:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                     else(),
										 
										 if($Cities ne '') then cts:element-value-query(xs:QName('aliattorneydata:location'),$Cities,"exact") else(),
										 if($firmID ne '') then cts:element-value-query(xs:QName('aliattorneydata:ALI_ID'),fn:tokenize($firmID,',')) else()
										))
										
  let $aliIDs :=  cts:values(cts:element-reference(xs:QName('aliattorneydata:ALI_ID')), (), (),$attorneyQuery)	
  
  let $reIDs := firmstatics:getFIRMS_ALI_XREF_REData2($aliIDs) ! fn:string(.)
  
  let $fromRecord := if($PageNo ne '1') then (xs:int($PageNo)-1) * xs:int($PageSize) + 1 else 1
  let $toRecord := xs:int($PageSize) * xs:int($PageNo)
  
  let $orderBy :=cts:index-order(cts:element-reference(xs:QName('tblrer:firm_name')) ,'ascending')
  			   
  let $firmIDS := cts:values(cts:element-reference(xs:QName('tblrer:firm_id')), (), (), cts:and-query((
							   cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/'),
							  if($PracticeAreas ne '') then 
                                                          if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('tblrer:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                          else cts:element-word-query(xs:QName('tblrer:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                      else(),
							   if($Cities ne '') then if(xs:string($isHeadquarter) eq 'true') then cts:and-query((
                                cts:element-word-query(xs:QName('tblrer:location'),$Cities,'wildcarded'),
                                cts:element-value-query(xs:QName('tblrer:HQ'),'Y','case-insensitive'))) else cts:element-word-query(xs:QName('tblrer:location'),$Cities,'wildcarded')
                 else(),
							   cts:element-value-query(xs:QName('tblrer:firm_id'),$reIDs)
							   )))

	let $idss := 	if($firmSizefrom gt 0 and $firmSizeTo gt 0) then 
                      for $item in $firmIDS
                       let $headcount := xdmp:estimate(cts:search(/,
                                            cts:and-query((
                                                      cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/'),
                                                      if($PracticeAreas ne '') then 
                                                          if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('tblrer:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                          else cts:element-word-query(xs:QName('tblrer:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                      else(),
                                                      if($Cities ne '') then if(xs:string($isHeadquarter) eq 'true') then cts:and-query((
                                                                      cts:element-word-query(xs:QName('tblrer:location'),$Cities,'wildcarded'),
                                                                      cts:element-value-query(xs:QName('tblrer:HQ'),'Y','case-insensitive'))) else cts:element-word-query(xs:QName('tblrer:location'),$Cities,'wildcarded')
                                                      else()
                                                      ,cts:element-value-query(xs:QName('tblrer:firm_id'), xs:string($item))
                                                      ,cts:element-value-query(xs:QName('tblrer:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'))
                                                      ))))
                                            
                       return if($headcount ge xs:integer($firmSizefrom) and $headcount le xs:integer($firmSizeTo)) then $item else 1001020
			                
                else  $firmIDS                           

  let $firmIDS1 := for $firmID in $idss
                      let $res := cts:search(/,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/')
                        ,cts:element-value-query(xs:QName('tblrer:firm_id'),($firmID ! xs:string(.)))
                        ,cts:not-query(cts:element-value-query(xs:QName('tblrer:firm_name'),''))
                        )))[1]
                    order by $res//tblrer:firm_name/text() ascending
                    return if(xs:string($firmID) ne '1001020') then $firmID else()
  
  let $totalCount := count($firmIDS1)
 
  let $res-array := json:array()
  let $loopData := for $company in $firmIDS1[xs:int($fromRecord) to xs:int($toRecord)]
 
                          let $res-object := json:object()
                          
                          let $officesTotalAndQuery := cts:and-query((
                                                            cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/')
                                                            ,cts:element-value-query(xs:QName('tblrer:firm_id'), xs:string($company)),
                                                           if($Cities ne '') then if(xs:string($isHeadquarter) eq 'true') then cts:and-query((
                                                                      cts:element-word-query(xs:QName('tblrer:location'),$Cities,'wildcarded'),
                                                                      cts:element-value-query(xs:QName('tblrer:HQ'),'Y','case-insensitive'))) else cts:element-word-query(xs:QName('tblrer:location'),$Cities,'wildcarded')
                                                            else()
                                                            ,if($PracticeAreas ne '') then 
                                                                if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('tblrer:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                                else cts:element-word-query(xs:QName('tblrer:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                            else()
                                                            ))
                                          
                          let $officesTotal := count(cts:values(cts:element-reference(xs:QName('tblrer:location')), (), (),$officesTotalAndQuery))
                          
                          let $prcttl := if($practiceArea ne '') then 
                                            fn:tokenize($practiceArea ,'[|]')
                                         else cts:values(cts:element-reference(xs:QName('tblrer:practices')), (), (),cts:and-query((
                                                cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/')
                                                ,cts:element-value-query(xs:QName('tblrer:firm_id'), xs:string($company))
                                               ,if($Cities ne '') then if(xs:string($isHeadquarter) eq 'true') then cts:and-query((
                                                                      cts:element-word-query(xs:QName('tblrer:location'),$Cities,'wildcarded'),
                                                                      cts:element-value-query(xs:QName('tblrer:HQ'),'Y','case-insensitive'))) else cts:element-word-query(xs:QName('tblrer:location'),$Cities,'wildcarded')
                                                      else()
                                                ,if($PracticeAreas ne '') then 
                                                          if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('tblrer:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                          else cts:element-word-query(xs:QName('tblrer:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                      else()
                                                )))
                          
                          

                          let $KWS_PracticeArea := cts:element-values(xs:QName('practices:practice_area'))
                          
                          let $temp := for $prac in fn:distinct-values(cts:search(/,
                                              cts:and-query((
                                              cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/'),
                                              if($PracticeAreas ne '') then 
                                                          if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('tblrer:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                          else cts:element-word-query(xs:QName('tblrer:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                      else()
                                              ,if($Cities ne '') then if(xs:string($isHeadquarter) eq 'true') then cts:and-query((
                                                                      cts:element-word-query(xs:QName('tblrer:location'),$Cities,'wildcarded'),
                                                                      cts:element-value-query(xs:QName('tblrer:HQ'),'Y','case-insensitive'))) else cts:element-word-query(xs:QName('tblrer:location'),$Cities,'wildcarded')
                                                      else()
                                              ,cts:element-value-query(xs:QName('tblrer:firm_id'), xs:string($company))    
                                              )))//tblrer:practice_area/text())    
                                              where if($practiceArea ne '') 
                                                then $prac eq fn:tokenize($practiceArea,'[|]') 
                                                else ($prac eq $KWS_PracticeArea)
                                              return $prac 

                              let $headcount := xdmp:estimate(cts:search(/,
                                                       cts:and-query((
                                                      cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/'),
                                                      if($PracticeAreas ne '') then 
                                                          if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('tblrer:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                          else cts:element-word-query(xs:QName('tblrer:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                      else()
                                                      ,if($Cities ne '') then if(xs:string($isHeadquarter) eq 'true') then cts:and-query((
                                                                      cts:element-word-query(xs:QName('tblrer:location'),$Cities,'wildcarded'),
                                                                      cts:element-value-query(xs:QName('tblrer:HQ'),'Y','case-insensitive'))) else cts:element-word-query(xs:QName('tblrer:location'),$Cities,'wildcarded')
                                                      else()
                                                      ,cts:element-value-query(xs:QName('tblrer:firm_id'), xs:string($company))
                                                      ,cts:element-value-query(xs:QName('tblrer:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'))
                                                      ))))
                                                      
                                                    
                             let $headcountplus := xdmp:estimate(cts:search(/,
                                                      cts:and-query((
                                                      cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/'),
                                                      cts:not-query(cts:element-value-query(xs:QName('tblrermovechanges:last_action_date'),'0/0/0000')),
                                                      if($PracticeAreas ne '') then 
                                                          if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('tblrermovechanges:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                          else cts:element-word-query(xs:QName('tblrermovechanges:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                      else()
                                                      ,if($Cities ne '') then if(xs:string($isHeadquarter) eq 'true') then cts:and-query((
                                                                      cts:element-word-query(xs:QName('tblrermovechanges:location'),$Cities,'wildcarded'),
                                                                      cts:element-value-query(xs:QName('tblrermovechanges:HQ'),'Y','case-insensitive'))) else cts:element-word-query(xs:QName('tblrermovechanges:location'),$Cities,'wildcarded')
                                                      else()
                                                      ,cts:element-value-query(xs:QName('tblrermovechanges:firm_id'), xs:string($company))
                                                      ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
                                                      ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'),'added')
                                                      ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                                                                  cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                                                                  cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
                                                    
                            let $headcountminus := xdmp:estimate(cts:search(/,
                                                      cts:and-query((
                                                      cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/'),
                                                      cts:not-query(cts:element-value-query(xs:QName('tblrermovechanges:last_action_date'),'0/0/0000')),
                                                      if($PracticeAreas ne '') then 
                                                          if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('tblrermovechanges:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                          else cts:element-word-query(xs:QName('tblrermovechanges:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                      else()
                                                      ,if($Cities ne '') then if(xs:string($isHeadquarter) eq 'true') then cts:and-query((
                                                                      cts:element-word-query(xs:QName('tblrermovechanges:location'),$Cities,'wildcarded'),
                                                                      cts:element-value-query(xs:QName('tblrermovechanges:HQ'),'Y','case-insensitive'))) else cts:element-word-query(xs:QName('tblrermovechanges:location'),$Cities,'wildcarded')
                                                      else()
                                                      ,cts:element-value-query(xs:QName('tblrermovechanges:firm_id'), xs:string($company))
                                                      ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
                                                      ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'),'removed')  
                                                    ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                                                        cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                                                        cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate))
                                                    ))  else()
                                                      ))))	
                                  
                            let $partnercount := xdmp:estimate(cts:search(/,
                                                      cts:and-query((
                                                      cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/'),
                                                      if($PracticeAreas ne '') then 
                                                          if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('tblrer:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                          else cts:element-word-query(xs:QName('tblrer:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                      else()
                                                      ,if($Cities ne '') then if(xs:string($isHeadquarter) eq 'true') then cts:and-query((
                                                                      cts:element-word-query(xs:QName('tblrer:location'),$Cities,'wildcarded'),
                                                                      cts:element-value-query(xs:QName('tblrer:HQ'),'Y','case-insensitive'))) else cts:element-word-query(xs:QName('tblrer:location'),$Cities,'wildcarded')
                                                      else()
                                                      ,cts:element-value-query(xs:QName('tblrer:firm_id'), xs:string($company))
                                                      ,cts:element-value-query(xs:QName('tblrer:title'), ('Partner'))
                                                      ))))
                            
                            let $partnercountplus := xdmp:estimate(cts:search(/,
                                                          cts:and-query((
                                                          cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/'),
                                                          cts:not-query(cts:element-value-query(xs:QName('tblrermovechanges:last_action_date'),'0/0/0000'))
                                                          ,if($PracticeAreas ne '') then 
                                                            if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('tblrermovechanges:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                            else cts:element-word-query(xs:QName('tblrermovechanges:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                          else()
                                                          ,if($Cities ne '') then if(xs:string($isHeadquarter) eq 'true') then cts:and-query((
                                                                      cts:element-word-query(xs:QName('tblrermovechanges:location'),$Cities,'wildcarded'),
                                                                      cts:element-value-query(xs:QName('tblrermovechanges:HQ'),'Y','case-insensitive'))) else cts:element-word-query(xs:QName('tblrermovechanges:location'),$Cities,'wildcarded')
                                                      else()
                                                          ,cts:element-value-query(xs:QName('tblrermovechanges:firm_id'), xs:string($company))
                                                          ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Partner'))
                                                          ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('added'))
                                                          ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                                                                      cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                                                                      cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
                                  
                            let $partnercountminus := xdmp:estimate(cts:search(/,
                                                          cts:and-query((
                                                          cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/'),
                                                          cts:not-query(cts:element-value-query(xs:QName('tblrermovechanges:last_action_date'),'0/0/0000'))
                                                          ,if($PracticeAreas ne '') then 
                                                              if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('tblrermovechanges:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                              else cts:element-word-query(xs:QName('tblrermovechanges:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                          else()
                                                          ,if($Cities ne '') then if(xs:string($isHeadquarter) eq 'true') then cts:and-query((
                                                                      cts:element-word-query(xs:QName('tblrermovechanges:location'),$Cities,'wildcarded'),
                                                                      cts:element-value-query(xs:QName('tblrermovechanges:HQ'),'Y','case-insensitive'))) else cts:element-word-query(xs:QName('tblrermovechanges:location'),$Cities,'wildcarded')
                                                      else()
                                                          ,cts:element-value-query(xs:QName('tblrermovechanges:firm_id'), xs:string($company))
                                                          ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Partner'))
                                                          ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('removed'))
                                                          ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                                                                      cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                                                                      cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
                                  
                              
                            let $associatecount := xdmp:estimate(cts:search(/,
                                                        cts:and-query((
                                                        cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/'),
                                                        
                                                        if($PracticeAreas ne '') then 
                                                          if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('tblrer:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                          else cts:element-word-query(xs:QName('tblrer:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                        else()
                                                        ,if($Cities ne '') then if(xs:string($isHeadquarter) eq 'true') then cts:and-query((
                                                                      cts:element-word-query(xs:QName('tblrer:location'),$Cities,'wildcarded'),
                                                                      cts:element-value-query(xs:QName('tblrer:HQ'),'Y','case-insensitive'))) else cts:element-word-query(xs:QName('tblrer:location'),$Cities,'wildcarded')
                                                      else()
                                                        ,cts:element-value-query(xs:QName('tblrer:firm_id'), xs:string($company))
                                                        ,cts:element-value-query(xs:QName('tblrer:title'), ('Associate'))
                                                        ))))
                            
                              let $associatecountplus := xdmp:estimate(cts:search(/,
                                                              cts:and-query((
                                                              cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/'),
                                                              cts:not-query(cts:element-value-query(xs:QName('tblrermovechanges:last_action_date'),'0/0/0000'))
                                                              ,if($PracticeAreas ne '') then 
                                                                    if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('tblrermovechanges:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                                    else cts:element-word-query(xs:QName('tblrermovechanges:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                                else()
                                                              ,if($Cities ne '') then if(xs:string($isHeadquarter) eq 'true') then cts:and-query((
                                                                      cts:element-word-query(xs:QName('tblrermovechanges:location'),$Cities,'wildcarded'),
                                                                      cts:element-value-query(xs:QName('tblrermovechanges:HQ'),'Y','case-insensitive'))) else cts:element-word-query(xs:QName('tblrermovechanges:location'),$Cities,'wildcarded')
                                                      else()
                                                              ,cts:element-value-query(xs:QName('tblrermovechanges:firm_id'), xs:string($company))
                                                              ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Associate'))
                                                              ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('added'))
                                                              ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                                                                          cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                                                                          cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
                                  
                              let $associatecountminus := xdmp:estimate(cts:search(/,
                                                                cts:and-query((
                                                                cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/'),
                                                                cts:not-query(cts:element-value-query(xs:QName('tblrermovechanges:last_action_date'),'0/0/0000'))
                                                                ,if($PracticeAreas ne '') then 
                                                                      if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('tblrermovechanges:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                                      else cts:element-word-query(xs:QName('tblrermovechanges:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                                  else()
                                                                ,if($Cities ne '') then if(xs:string($isHeadquarter) eq 'true') then cts:and-query((
                                                                      cts:element-word-query(xs:QName('tblrermovechanges:location'),$Cities,'wildcarded'),
                                                                      cts:element-value-query(xs:QName('tblrermovechanges:HQ'),'Y','case-insensitive'))) else cts:element-word-query(xs:QName('tblrermovechanges:location'),$Cities,'wildcarded')
                                                      else()
                                                                ,cts:element-value-query(xs:QName('tblrermovechanges:firm_id'), xs:string($company))
                                                                ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Associate'))
                                                                ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('removed'))
                                                                ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                                                                            cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                                                                            cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
                              
                            let $othercouselcount := xdmp:estimate(cts:search(/,
                                                          cts:and-query((
                                                          cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/'),
                                                          if($PracticeAreas ne '') then 
                                                              if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('tblrer:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                              else cts:element-word-query(xs:QName('tblrer:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                          else()
                                                          ,if($Cities ne '') then if(xs:string($isHeadquarter) eq 'true') then cts:and-query((
                                                                      cts:element-word-query(xs:QName('tblrer:location'),$Cities,'wildcarded'),
                                                                      cts:element-value-query(xs:QName('tblrer:HQ'),'Y','case-insensitive'))) else cts:element-word-query(xs:QName('tblrer:location'),$Cities,'wildcarded')
                                                      else()
                                                          ,cts:element-value-query(xs:QName('tblrer:firm_id'), xs:string($company))
                                                          ,cts:element-value-query(xs:QName('tblrer:title'), ('Other Counsel/Attorney'),"case-insensitive")
                                                          )))) 

                            let $othercouselcountplus := xdmp:estimate(cts:search(/,
                                                              cts:and-query((
                                                              cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/'),
                                                              cts:not-query(cts:element-value-query(xs:QName('tblrermovechanges:last_action_date'),'0/0/0000'))
                                                              ,if($PracticeAreas ne '') then 
                                                                    if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('tblrermovechanges:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                                    else cts:element-word-query(xs:QName('tblrermovechanges:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                                else()
                                                              ,if($Cities ne '') then if(xs:string($isHeadquarter) eq 'true') then cts:and-query((
                                                                      cts:element-word-query(xs:QName('tblrermovechanges:location'),$Cities,'wildcarded'),
                                                                      cts:element-value-query(xs:QName('tblrermovechanges:HQ'),'Y','case-insensitive'))) else cts:element-word-query(xs:QName('tblrermovechanges:location'),$Cities,'wildcarded')
                                                      else()
                                                              ,cts:element-value-query(xs:QName('tblrermovechanges:firm_id'), xs:string($company))
                                                              ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Other Counsel/Attorney'),"case-insensitive")
                                                              ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('added'))
                                                              ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                                                                          cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                                                                          cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))

                            let $othercouselcountminus := xdmp:estimate(cts:search(/,
                                                              cts:and-query((
                                                              cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/'),
                                                              cts:not-query(cts:element-value-query(xs:QName('tblrermovechanges:last_action_date'),'0/0/0000'))
                                                              ,if($PracticeAreas ne '') then 
                                                                    if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('tblrermovechanges:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                                    else cts:element-word-query(xs:QName('tblrermovechanges:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                                else()
                                                              ,if($Cities ne '') then if(xs:string($isHeadquarter) eq 'true') then cts:and-query((
                                                                      cts:element-word-query(xs:QName('tblrermovechanges:location'),$Cities,'wildcarded'),
                                                                      cts:element-value-query(xs:QName('tblrermovechanges:HQ'),'Y','case-insensitive'))) else cts:element-word-query(xs:QName('tblrermovechanges:location'),$Cities,'wildcarded')
                                                      else()
                                                              ,cts:element-value-query(xs:QName('tblrermovechanges:firm_id'), xs:string($company))
                                                              ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Other Counsel/Attorney'),"case-insensitive")
                                                              ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('removed'))
                                                              ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                                                                          cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                                                                          cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
                            let $admincount := xdmp:estimate(cts:search(/,
                                                    cts:and-query((
                                                    cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/'),
                                                    if($PracticeAreas ne '') then 
                                                          if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('tblrer:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                          else cts:element-word-query(xs:QName('tblrer:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                      else()
                                                    ,if($Cities ne '') then if(xs:string($isHeadquarter) eq 'true') then cts:and-query((
                                                                      cts:element-word-query(xs:QName('tblrer:location'),$Cities,'wildcarded'),
                                                                      cts:element-value-query(xs:QName('tblrer:HQ'),'Y','case-insensitive'))) else cts:element-word-query(xs:QName('tblrer:location'),$Cities,'wildcarded')
                                                      else(),
                                                    cts:element-value-query(xs:QName('tblrer:firm_id'), xs:string($company)),
                                                    cts:element-value-query(xs:QName('tblrer:title'), ('Administrative / Support Staff'),"case-insensitive")
                                                    )))) 

                              let $admincountplus := xdmp:estimate(cts:search(/,
                                                          cts:and-query((
                                                          cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/'),
                                                          cts:not-query(cts:element-value-query(xs:QName('tblrermovechanges:last_action_date'),'0/0/0000'))
                                                          ,if($PracticeAreas ne '') then 
                                                                if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('tblrermovechanges:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                                else cts:element-word-query(xs:QName('tblrermovechanges:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                            else()
                                                          ,if($Cities ne '') then if(xs:string($isHeadquarter) eq 'true') then cts:and-query((
                                                                      cts:element-word-query(xs:QName('tblrermovechanges:location'),$Cities,'wildcarded'),
                                                                      cts:element-value-query(xs:QName('tblrermovechanges:HQ'),'Y','case-insensitive'))) else cts:element-word-query(xs:QName('tblrermovechanges:location'),$Cities,'wildcarded')
                                                      else()
                                                          ,cts:element-value-query(xs:QName('tblrermovechanges:firm_id'), xs:string($company))
                                                          ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Administrative / Support Staff'),"case-insensitive")
                                                          ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('added'))
                                                          ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                                                                      cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                                                                      cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))

                              let $admincountminus := xdmp:estimate(cts:search(/,
                                                            cts:and-query((
                                                            cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/'),
                                                            cts:not-query(cts:element-value-query(xs:QName('tblrermovechanges:last_action_date'),'0/0/0000'))
                                                            ,if($PracticeAreas ne '') then 
                                                                  if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('tblrermovechanges:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                                  else cts:element-word-query(xs:QName('tblrermovechanges:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                              else()
                                                            ,if($Cities ne '') then if(xs:string($isHeadquarter) eq 'true') then cts:and-query((
                                                                      cts:element-word-query(xs:QName('tblrermovechanges:location'),$Cities,'wildcarded'),
                                                                      cts:element-value-query(xs:QName('tblrermovechanges:HQ'),'Y','case-insensitive'))) else cts:element-word-query(xs:QName('tblrermovechanges:location'),$Cities,'wildcarded')
                                                            else()
                                                            ,cts:element-value-query(xs:QName('tblrermovechanges:firm_id'), xs:string($company))
                                                            ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Administrative / Support Staff'),"case-insensitive")
                                                            ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('removed'))
                                                            ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                                                                        cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                                                                        cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
                              
                            let $othercount :=  xdmp:estimate(cts:search(/,
                                                    cts:and-query((
                                                    cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/'),
                                                    if($PracticeAreas ne '') then 
                                                          if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('tblrer:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                          else cts:element-word-query(xs:QName('tblrer:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                      else()
                                                    ,if($Cities ne '') then if(xs:string($isHeadquarter) eq 'true') then cts:and-query((
                                                                      cts:element-word-query(xs:QName('tblrer:location'),$Cities,'wildcarded'),
                                                                      cts:element-value-query(xs:QName('tblrer:HQ'),'Y','case-insensitive'))) else cts:element-word-query(xs:QName('tblrer:location'),$Cities,'wildcarded')
                                                      else()
                                                    ,cts:element-value-query(xs:QName('tblrer:firm_id'), xs:string($company))
                                                    ,cts:element-value-query(xs:QName('tblrer:title'), ('Other'),"case-insensitive")))))
                                
                            let $othercountplus :=  xdmp:estimate(cts:search(/,
                                                          cts:and-query((
                                                          cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/'),
                                                          cts:not-query(cts:element-value-query(xs:QName('tblrermovechanges:last_action_date'),'0/0/0000'))
                                                          ,if($PracticeAreas ne '') then 
                                                                if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('tblrermovechanges:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                                else cts:element-word-query(xs:QName('tblrermovechanges:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                            else()
                                                          ,if($Cities ne '') then if(xs:string($isHeadquarter) eq 'true') then cts:and-query((
                                                                      cts:element-word-query(xs:QName('tblrermovechanges:location'),$Cities,'wildcarded'),
                                                                      cts:element-value-query(xs:QName('tblrermovechanges:HQ'),'Y','case-insensitive'))) else cts:element-word-query(xs:QName('tblrermovechanges:location'),$Cities,'wildcarded')
                                                      else()
                                                          ,cts:element-value-query(xs:QName('tblrermovechanges:firm_id'), xs:string($company))
                                                          ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Other'),"case-insensitive")
                                                          ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('added'))
                                                          ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                                                                      cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                                                                      cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
                              
                            let $othercountminus :=  xdmp:estimate(cts:search(/,
                                                          cts:and-query((
                                                          cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/'),
                                                          cts:not-query(cts:element-value-query(xs:QName('tblrermovechanges:last_action_date'),'0/0/0000'))
                                                          ,if($PracticeAreas ne '') then 
                                                                if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('tblrermovechanges:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                                else cts:element-word-query(xs:QName('tblrermovechanges:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                            else()
                                                          ,if($Cities ne '') then if(xs:string($isHeadquarter) eq 'true') then cts:and-query((
                                                                      cts:element-word-query(xs:QName('tblrermovechanges:location'),$Cities,'wildcarded'),
                                                                      cts:element-value-query(xs:QName('tblrermovechanges:HQ'),'Y','case-insensitive'))) else cts:element-word-query(xs:QName('tblrermovechanges:location'),$Cities,'wildcarded')
                                                      else()
                                                          ,cts:element-value-query(xs:QName('tblrermovechanges:firm_id'), xs:string($company))
                                                          ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Other'),"case-insensitive")
                                                          ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('removed'))
                                                          ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                                                                      cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                                                                      cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))

                              let $firmDetail := firmstatics:getFIRMS_ALI_XREF_REData($company)
                              let $diff := xs:decimal($headcountplus) - xs:decimal($headcountminus)
                              let $div := if($headcount ne 0) then ($diff div xs:decimal($headcount))*xs:double(100) else 0
                              let $firmName := if($firmDetail/alidata:ALM_NAME/text() ne '') then $firmDetail/alidata:ALM_NAME/text() else firmstatics:getFirmName(xs:string($company))
                              let $_ := (map:put($res-object,'firmID',$firmDetail/alidata:ALI_ID/text()),
                                          map:put($res-object,'firmName',$firmName),
                                          map:put($res-object,'LOCATION',''),
                                          map:put($res-object,'officesTotal',$officesTotal),
                                          map:put($res-object,'practicesTotal',count($temp)),
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
                                          map:put($res-object,'totalCount',$totalCount)
                                        )
                                  
                              let $_ := json:array-push($res-array,$res-object)
                              return ()
  
  return $res-array
};

(: declare function firmstatics:sp_GetLawFirmStaticsByPracticenew2($cities,$countries,$geoGraphicRegion,$usRegions,$practiceArea,$firmID,$fromDate,$toDate,$PageNo,$PageSize,$firmSizefrom,$firmSizeTo,$state,$isPrimaryPracticeArea)
{
  let $PracticeAreas := if($practiceArea ne '') then firmstatics:getPracticeAreas($practiceArea) else()
  let $Cities := if($cities ne '' or $countries ne '' or $geoGraphicRegion ne '' or $usRegions ne '' or $state ne '') then 
                    firmstatics:getGtandardLocations($cities,$countries,$geoGraphicRegion,$usRegions,$state) else()
  
  let $attorneyQuery := cts:and-query((
										cts:directory-query('/LegalCompass/denormalized-data/ALI_RE_Attorney_Data/'),
										 if($PracticeAreas ne '') then 
                        if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('aliattorneydata:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                        else cts:element-word-query(xs:QName('aliattorneydata:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                     else(),
										 
										 if($Cities ne '') then cts:element-value-query(xs:QName('aliattorneydata:location'),$Cities,"exact") else(),
										 if($firmID ne '') then cts:element-value-query(xs:QName('aliattorneydata:ALI_ID'),fn:tokenize($firmID,',')) else()
										))
										
  let $aliIDs :=  cts:values(cts:element-reference(xs:QName('aliattorneydata:ALI_ID')), (), (),$attorneyQuery)	
  
  let $reIDs := firmstatics:getFIRMS_ALI_XREF_REData2($aliIDs) ! fn:string(.)
  
  let $fromRecord := if($PageNo ne '1') then (xs:int($PageNo)-1) * xs:int($PageSize) + 1 else 1
  let $toRecord := xs:int($PageSize) * xs:int($PageNo)
  
  let $orderBy :=cts:index-order(cts:element-reference(xs:QName('tblrer:firm_name')) ,'ascending')
  			   
  let $firmIDS := cts:values(cts:element-reference(xs:QName('tblrer:firm_id')), (), (), cts:and-query((
							   cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/'),
							  if($PracticeAreas ne '') then 
                                                          if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('tblrer:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                          else cts:element-word-query(xs:QName('tblrer:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                      else(),
							   if($Cities ne '') then cts:element-word-query(xs:QName('tblrer:location'),$Cities,'wildcarded') else(),
							   cts:element-value-query(xs:QName('tblrer:firm_id'),$reIDs)
							   )))

	let $idss := 	if($firmSizefrom gt 0 and $firmSizeTo gt 0) then 
                      for $item in $firmIDS
                       let $headcount := xdmp:estimate(cts:search(/,
                                            cts:and-query((
                                                      cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/'),
                                                      if($PracticeAreas ne '') then 
                                                          if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('tblrer:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                          else cts:element-word-query(xs:QName('tblrer:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                      else(),
                                                      if($Cities ne '') then cts:element-word-query(xs:QName('tblrer:location'),$Cities,('wildcarded','case-insensitive')) else()
                                                      ,cts:element-value-query(xs:QName('tblrer:firm_id'), xs:string($item))
                                                      ,cts:element-value-query(xs:QName('tblrer:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'))
                                                      ))))
                                            
                       return if($headcount ge xs:integer($firmSizefrom) and $headcount le xs:integer($firmSizeTo)) then $item else 1001020
			                
                else  $firmIDS                           

  let $firmIDS1 := for $firmID in $idss
                      let $res := cts:search(/,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/')
                        ,cts:element-value-query(xs:QName('tblrer:firm_id'),($firmID ! xs:string(.)))
                        ,cts:not-query(cts:element-value-query(xs:QName('tblrer:firm_name'),''))
                        )))[1]
                    order by $res//tblrer:firm_name/text() ascending
                    return if(xs:string($firmID) ne '1001020') then $firmID else()
  
  let $totalCount := count($firmIDS1)
 
  let $res-array := json:array()
  let $loopData := for $company in $firmIDS1[xs:int($fromRecord) to xs:int($toRecord)]
 
                          let $res-object := json:object()
                          
                          let $officesTotalAndQuery := cts:and-query((
                                                            cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/')
                                                            ,cts:element-value-query(xs:QName('tblrer:firm_id'), xs:string($company))
                                                            ,if($Cities ne '') then cts:element-value-query(xs:QName('tblrer:location'), $Cities,'wildcarded') else()
                                                            ,if($PracticeAreas ne '') then 
                                                                if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('tblrer:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                                else cts:element-word-query(xs:QName('tblrer:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                            else()
                                                            ))
                                          
                          let $officesTotal := count(cts:values(cts:element-reference(xs:QName('tblrer:location')), (), (),$officesTotalAndQuery))
                          
                          let $prcttl := if($practiceArea ne '') then 
                                            fn:tokenize($practiceArea ,'[|]')
                                         else cts:values(cts:element-reference(xs:QName('tblrer:practices')), (), (),cts:and-query((
                                                cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/')
                                                ,cts:element-value-query(xs:QName('tblrer:firm_id'), xs:string($company))
                                                ,if($Cities ne '') then cts:element-value-query(xs:QName('tblrer:location'), $Cities,'wildcarded') else()
                                                ,if($PracticeAreas ne '') then 
                                                          if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('tblrer:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                          else cts:element-word-query(xs:QName('tblrer:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                      else()
                                                )))
                          
                          

                          let $KWS_PracticeArea := cts:element-values(xs:QName('practices:practice_area'))
                          
                          let $temp := for $prac in fn:distinct-values(cts:search(/,
                                              cts:and-query((
                                              cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/'),
                                              if($PracticeAreas ne '') then 
                                                          if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('tblrer:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                          else cts:element-word-query(xs:QName('tblrer:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                      else()
                                              ,if($Cities ne '') then cts:element-value-query(xs:QName('tblrer:location'),$Cities) else()
                                              ,cts:element-value-query(xs:QName('tblrer:firm_id'), xs:string($company))    
                                              )))//tblrer:practice_area/text())    
                                              where if($practiceArea ne '') 
                                                then $prac eq fn:tokenize($practiceArea,'[|]') 
                                                else ($prac eq $KWS_PracticeArea)
                                              return $prac 

                              let $headcount := xdmp:estimate(cts:search(/,
                                                       cts:and-query((
                                                      cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/'),
                                                      if($PracticeAreas ne '') then 
                                                          if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('tblrer:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                          else cts:element-word-query(xs:QName('tblrer:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                      else(),
                                                      if($Cities ne '') then cts:element-word-query(xs:QName('tblrer:location'),$Cities,('wildcarded','case-insensitive')) else()
                                                      ,cts:element-value-query(xs:QName('tblrer:firm_id'), xs:string($company))
                                                      ,cts:element-value-query(xs:QName('tblrer:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'))
                                                      ))))
                                                      
                                                    
                             let $headcountplus := xdmp:estimate(cts:search(/,
                                                      cts:and-query((
                                                      cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/'),
                                                      if($PracticeAreas ne '') then 
                                                          if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('tblrermovechanges:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                          else cts:element-word-query(xs:QName('tblrermovechanges:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                      else()
                                                      ,if($Cities ne '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $Cities,('wildcarded','case-insensitive')) else()
                                                      ,cts:element-value-query(xs:QName('tblrermovechanges:firm_id'), xs:string($company))
                                                      ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
                                                      ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'),'added')
                                                      ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                                                                  cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                                                                  cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
                                                    
                            let $headcountminus := xdmp:estimate(cts:search(/,
                                                      cts:and-query((
                                                      cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/'),
                                                      if($PracticeAreas ne '') then 
                                                          if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('tblrermovechanges:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                          else cts:element-word-query(xs:QName('tblrermovechanges:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                      else()
                                                      ,if($Cities ne '') then cts:element-value-query(xs:QName('tblrermovechanges:location'), $Cities) else()
                                                      ,cts:element-value-query(xs:QName('tblrermovechanges:firm_id'), xs:string($company))
                                                      ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
                                                      ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'),'removed')  
                                                    ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                                                        cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                                                        cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate))
                                                    ))  else()
                                                      ))))	
                                  
                            let $partnercount := xdmp:estimate(cts:search(/,
                                                      cts:and-query((
                                                      cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/'),
                                                      if($PracticeAreas ne '') then 
                                                          if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('tblrer:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                          else cts:element-word-query(xs:QName('tblrer:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                      else(),
                                                      if($Cities ne '') then cts:element-word-query(xs:QName('tblrer:location'),$Cities,('wildcarded','case-insensitive')) else()
                                                      ,cts:element-value-query(xs:QName('tblrer:firm_id'), xs:string($company))
                                                      ,cts:element-value-query(xs:QName('tblrer:title'), ('Partner'))
                                                      ))))
                            
                            let $partnercountplus := xdmp:estimate(cts:search(/,
                                                          cts:and-query((
                                                          cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
                                                          ,if($PracticeAreas ne '') then 
                                                            if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('tblrermovechanges:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                            else cts:element-word-query(xs:QName('tblrermovechanges:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                          else()
                                                          ,if($Cities ne '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $Cities,('wildcarded','case-insensitive')) else()
                                                          ,cts:element-value-query(xs:QName('tblrermovechanges:firm_id'), xs:string($company))
                                                          ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Partner'))
                                                          ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('added'))
                                                          ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                                                                      cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                                                                      cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
                                  
                            let $partnercountminus := xdmp:estimate(cts:search(/,
                                                          cts:and-query((
                                                          cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
                                                          ,if($PracticeAreas ne '') then 
                                                              if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('tblrermovechanges:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                              else cts:element-word-query(xs:QName('tblrermovechanges:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                          else()
                                                          ,if($Cities ne '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $Cities,('wildcarded','case-insensitive')) else()
                                                          ,cts:element-value-query(xs:QName('tblrermovechanges:firm_id'), xs:string($company))
                                                          ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Partner'))
                                                          ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('removed'))
                                                          ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                                                                      cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                                                                      cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
                                  
                              
                            let $associatecount := xdmp:estimate(cts:search(/,
                                                        cts:and-query((
                                                        cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/'),
                                                        if($PracticeAreas ne '') then 
                                                          if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('tblrer:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                          else cts:element-word-query(xs:QName('tblrer:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                        else(),
                                                        if($Cities ne '') then cts:element-word-query(xs:QName('tblrer:location'),$Cities,('wildcarded','case-insensitive')) else()
                                                        ,cts:element-value-query(xs:QName('tblrer:firm_id'), xs:string($company))
                                                        ,cts:element-value-query(xs:QName('tblrer:title'), ('Associate'))
                                                        ))))
                            
                              let $associatecountplus := xdmp:estimate(cts:search(/,
                                                              cts:and-query((
                                                              cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
                                                              ,if($PracticeAreas ne '') then 
                                                                    if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('tblrermovechanges:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                                    else cts:element-word-query(xs:QName('tblrermovechanges:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                                else()
                                                              ,if($Cities ne '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $Cities,('wildcarded','case-insensitive')) else()
                                                              ,cts:element-value-query(xs:QName('tblrermovechanges:firm_id'), xs:string($company))
                                                              ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Associate'))
                                                              ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('added'))
                                                              ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                                                                          cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                                                                          cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
                                  
                              let $associatecountminus := xdmp:estimate(cts:search(/,
                                                                cts:and-query((
                                                                cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
                                                                ,if($PracticeAreas ne '') then 
                                                                      if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('tblrermovechanges:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                                      else cts:element-word-query(xs:QName('tblrermovechanges:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                                  else()
                                                                ,if($Cities ne '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $Cities,('wildcarded','case-insensitive')) else()
                                                                ,cts:element-value-query(xs:QName('tblrermovechanges:firm_id'), xs:string($company))
                                                                ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Associate'))
                                                                ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('removed'))
                                                                ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                                                                            cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                                                                            cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
                              
                            let $othercouselcount := xdmp:estimate(cts:search(/,
                                                          cts:and-query((
                                                          cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/'),
                                                          if($PracticeAreas ne '') then 
                                                              if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('tblrer:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                              else cts:element-word-query(xs:QName('tblrer:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                          else(),
                                                          if($Cities ne '') then cts:element-word-query(xs:QName('tblrer:location'),$Cities,('wildcarded','case-insensitive')) else()
                                                          ,cts:element-value-query(xs:QName('tblrer:firm_id'), xs:string($company))
                                                          ,cts:element-value-query(xs:QName('tblrer:title'), ('Other Counsel/Attorney'),"case-insensitive")
                                                          )))) 

                            let $othercouselcountplus := xdmp:estimate(cts:search(/,
                                                              cts:and-query((
                                                              cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
                                                              ,if($PracticeAreas ne '') then 
                                                                    if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('tblrermovechanges:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                                    else cts:element-word-query(xs:QName('tblrermovechanges:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                                else()
                                                              ,if($Cities ne '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $Cities,('wildcarded','case-insensitive')) else()
                                                              ,cts:element-value-query(xs:QName('tblrermovechanges:firm_id'), xs:string($company))
                                                              ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Other Counsel/Attorney'),"case-insensitive")
                                                              ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('added'))
                                                              ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                                                                          cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                                                                          cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))

                            let $othercouselcountminus := xdmp:estimate(cts:search(/,
                                                              cts:and-query((
                                                              cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
                                                              ,if($PracticeAreas ne '') then 
                                                                    if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('tblrermovechanges:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                                    else cts:element-word-query(xs:QName('tblrermovechanges:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                                else()
                                                              ,if($Cities ne '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $Cities,('wildcarded','case-insensitive')) else()
                                                              ,cts:element-value-query(xs:QName('tblrermovechanges:firm_id'), xs:string($company))
                                                              ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Other Counsel/Attorney'),"case-insensitive")
                                                              ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('removed'))
                                                              ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                                                                          cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                                                                          cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
                            let $admincount := xdmp:estimate(cts:search(/,
                                                    cts:and-query((
                                                    cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/'),
                                                    if($PracticeAreas ne '') then 
                                                          if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('tblrer:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                          else cts:element-word-query(xs:QName('tblrer:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                      else(),
                                                    if($Cities ne '') then cts:element-word-query(xs:QName('tblrer:location'),$Cities,('wildcarded','case-insensitive')) else(),
                                                    cts:element-value-query(xs:QName('tblrer:firm_id'), xs:string($company)),
                                                    cts:element-value-query(xs:QName('tblrer:title'), ('Administrative / Support Staff'),"case-insensitive")
                                                    )))) 

                              let $admincountplus := xdmp:estimate(cts:search(/,
                                                          cts:and-query((
                                                          cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
                                                          ,if($PracticeAreas ne '') then 
                                                                if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('tblrermovechanges:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                                else cts:element-word-query(xs:QName('tblrermovechanges:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                            else(),
                                                          if($Cities ne '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $Cities,('wildcarded','case-insensitive')) else()
                                                          ,cts:element-value-query(xs:QName('tblrermovechanges:firm_id'), xs:string($company))
                                                          ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Administrative / Support Staff'),"case-insensitive")
                                                          ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('added'))
                                                          ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                                                                      cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                                                                      cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))

                              let $admincountminus := xdmp:estimate(cts:search(/,
                                                            cts:and-query((
                                                            cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
                                                            ,if($PracticeAreas ne '') then 
                                                                  if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('tblrermovechanges:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                                  else cts:element-word-query(xs:QName('tblrermovechanges:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                              else()
                                                            ,if($Cities ne '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $Cities,('wildcarded','case-insensitive')) else()
                                                            ,cts:element-value-query(xs:QName('tblrermovechanges:firm_id'), xs:string($company))
                                                            ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Administrative / Support Staff'),"case-insensitive")
                                                            ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('removed'))
                                                            ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                                                                        cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                                                                        cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
                              
                            let $othercount :=  xdmp:estimate(cts:search(/,
                                                    cts:and-query((
                                                    cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/'),
                                                    if($PracticeAreas ne '') then 
                                                          if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('tblrer:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                          else cts:element-word-query(xs:QName('tblrer:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                      else(),
                                                    if($Cities ne '') then cts:element-word-query(xs:QName('tblrer:location'),$Cities,('wildcarded','case-insensitive')) else()
                                                    ,cts:element-value-query(xs:QName('tblrer:firm_id'), xs:string($company))
                                                    ,cts:element-value-query(xs:QName('tblrer:title'), ('Other'),"case-insensitive")))))
                                
                            let $othercountplus :=  xdmp:estimate(cts:search(/,
                                                          cts:and-query((
                                                          cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
                                                          ,if($PracticeAreas ne '') then 
                                                                if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('tblrermovechanges:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                                else cts:element-word-query(xs:QName('tblrermovechanges:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                            else()
                                                          ,if($Cities ne '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $Cities,('wildcarded','case-insensitive')) else()
                                                          ,cts:element-value-query(xs:QName('tblrermovechanges:firm_id'), xs:string($company))
                                                          ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Other'),"case-insensitive")
                                                          ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('added'))
                                                          ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                                                                      cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                                                                      cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
                              
                            let $othercountminus :=  xdmp:estimate(cts:search(/,
                                                          cts:and-query((
                                                          cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
                                                          ,if($PracticeAreas ne '') then 
                                                                if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('tblrermovechanges:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                                else cts:element-word-query(xs:QName('tblrermovechanges:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                            else()
                                                          ,if($Cities ne '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $Cities,('wildcarded','case-insensitive')) else()
                                                          ,cts:element-value-query(xs:QName('tblrermovechanges:firm_id'), xs:string($company))
                                                          ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Other'),"case-insensitive")
                                                          ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'), ('removed'))
                                                          ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                                                                      cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                                                                      cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))

                              let $firmDetail := firmstatics:getFIRMS_ALI_XREF_REData($company)  
                              let $diff := xs:decimal($headcountplus) - xs:decimal($headcountminus)
                              let $div := if($headcount ne 0) then ($diff div xs:decimal($headcount))*xs:double(100) else 0
                              let $firmName := if($firmDetail/alidata:ALM_NAME/text() ne '') then $firmDetail/alidata:ALM_NAME/text() else firmstatics:getFirmName(xs:string($company))
                              let $_ := (map:put($res-object,'firmID',$firmDetail/alidata:ALI_ID/text()),
                                          map:put($res-object,'firmName',$firmName),
                                          map:put($res-object,'LOCATION',''),
                                          map:put($res-object,'officesTotal',$officesTotal),
                                          map:put($res-object,'practicesTotal',count($temp)),
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
                                  map:put($res-object,'totalCount',$totalCount)(:,
                                  map:put($res-object,'firmSizefrom',count($reIDs)),
                                   map:put($res-object,'firmSizeTo',$firmIDS1),
                                    map:put($res-object,'idss',$idss),
                                    map:put($res-object,'cid',$company):)
                                  )
                                  
                              let $_ := json:array-push($res-array,$res-object)
                              return ()
  
  return $res-array
}; :)


declare function firmstatics:sp_GetLawFirmStaticsPracticeChangesByFirm1($cities,$countries,$geoGraphicRegion,$usRegions,$practiceArea,$firmID,$fromDate,$toDate,$firmSizefrom,$firmSizeTo)
{
  let $PracticeAreas := if($practiceArea ne '') then firmstatics:getPracticeAreas($practiceArea) else()
  let $Cities := if($cities ne '' or $countries ne '' or $geoGraphicRegion ne '' or $usRegions ne '') then 
                    firmstatics:getGtandardLocations($cities,$countries,$geoGraphicRegion,$usRegions,'') else()
  
  let $attorneyQuery := cts:and-query((
										cts:directory-query('/LegalCompass/denormalized-data/ALI_RE_Attorney_Data/'),
										 if($PracticeAreas ne '') then cts:element-word-query(xs:QName('aliattorneydata:practice_area'),$PracticeAreas,('wildcarded','case-insensitive')) else(),
										 
										 if($Cities ne '') then cts:element-value-query(xs:QName('aliattorneydata:location'),$Cities,"exact") else(),
										 if($firmID ne '') then cts:element-value-query(xs:QName('aliattorneydata:firm_id'),fn:tokenize($firmID,',')) else()
										))
										
  let $aliIDs := if($PracticeAreas ne '' or $Cities ne '' or $firmID ne '') then fn:distinct-values(cts:search(/, 
																							$attorneyQuery
																							)//aliattorneydata:ALI_ID/text())
				else cts:values(cts:element-reference(xs:QName('aliattorneydata:ALI_ID')), (), (),$attorneyQuery)																		
					

  
  let $reIDs := firmstatics:getFIRMS_ALI_XREF_REData2($aliIDs) ! fn:string(.)
  
  
  let $orderBy :=cts:index-order(cts:element-reference(xs:QName('tblrer:firm_name')) ,'ascending')
  			   
  let $firmIDS := cts:values(cts:element-reference(xs:QName('tblrer:firm_id')), (), (), cts:and-query((
							   cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/'),
							   if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrer:practices'),$PracticeAreas,('wildcarded','case-insensitive')) else(),
							   if($Cities ne '') then cts:element-word-query(xs:QName('tblrer:location'),$Cities,'wildcarded') else(),
							   cts:element-value-query(xs:QName('tblrer:firm_id'),$reIDs)
							   )))

		
  let $firmIDS := if($firmSizefrom ne '0' and $firmSizeTo ne '0') then firmstatics:sp_GetLawFirmStaticsCount3_2($cities,$countries,$geoGraphicRegion,$usRegions,$practiceArea,$firmID,$fromDate,$toDate,$firmSizefrom,$firmSizeTo,'') else for $firmID in $firmIDS
		let $res := cts:search(/,
		cts:and-query((
			cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/')
			,cts:element-value-query(xs:QName('tblrer:firm_id'),($firmID ! xs:string(.)))
			,cts:not-query(cts:element-value-query(xs:QName('tblrer:firm_name'),''))
			)))[1]
	order by $res//tblrer:firm_name/text() ascending
	return $res//tblrer:firm_id/text()
  
  let $totalCount := count($firmIDS)
 
 let $res-array := json:array()
 let $loopData := for $company in $firmIDS
 
				  let $res-object := json:object()
				 
				  let $headcount := xdmp:estimate(cts:search(/,
					cts:and-query((
					cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/')
					,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrer:practices'), $PracticeAreas, ('wildcarded','case-insensitive')) else()
					,if($Cities ne '') then cts:element-value-query(xs:QName('tblrer:location'), $Cities,('wildcarded','case-insensitive')) else()
					,cts:element-value-query(xs:QName('tblrer:firm_id'), xs:string($company))
					,cts:element-value-query(xs:QName('tblrer:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
					))))
					
				  let $headcountplus := xdmp:estimate(cts:search(/,
					cts:and-query((
					cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
					,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
					,if($Cities ne '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $Cities,('wildcarded','case-insensitive')) else()
					,cts:element-value-query(xs:QName('tblrermovechanges:firm_id'), xs:string($company))
					,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
					,cts:element-value-query(xs:QName('tblrermovechanges:last_action'),'added')
					,if($fromDate ne '' and $toDate ne '') then cts:and-query((
								cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
								cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
								
				 let $headcountminus := xdmp:estimate(cts:search(/,
					cts:and-query((
					  cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
					  ,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
					  ,if($Cities ne '') then cts:element-value-query(xs:QName('tblrermovechanges:location'), $Cities,('wildcarded','case-insensitive')) else()
					  ,cts:element-value-query(xs:QName('tblrermovechanges:firm_id'), xs:string($company))
					  ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
					  ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'),'removed')   
					  ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
								cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
								cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
					(:let $firmDetail := firmstatics:getFIRMS_ALI_XREF_REData($company)  :)
					let $diff := xs:decimal($headcountplus) - xs:decimal($headcountminus)
					
					let $firmName := cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/')
							,cts:element-value-query(xs:QName('tblrer:firm_id'), xs:string($company))
							,cts:not-query(cts:element-value-query(xs:QName('tblrer:firm_name'), ''))
						))
					)[1]//tblrer:firm_name/text()
					
					let $div := if($headcount ne 0) then ($diff div xs:decimal($headcount)) * xs:double(100) else 0
					let $_ := ( map:put($res-object,'firmID',$company),
								(:map:put($res-object,'firmName',firmstatics:getFirmName(xs:string($company))),:)
								map:put($res-object,'firmName',$firmName),
								map:put($res-object,'headCount',$headcount),
								map:put($res-object,'headCountPlus',$headcountplus),
								map:put($res-object,'headCountMinus',$headcountminus),
								map:put($res-object,'changes',fn:round($div)),
								map:put($res-object,'TotalCount',$totalCount))
					
					 let $_ := json:array-push($res-array,$res-object)
					 return ()
  
  return $res-array
};


(: declare function firmstatics:sp_GetLawFirmStaticsPracticeChangesByFirm1($cities,$countries,$geoGraphicRegion,$usRegions,$practiceArea,$firmID,$fromDate,$toDate,$firmSizefrom,$firmSizeTo) :)
(: { :)
  (: let $PracticeAreas := firmstatics:getPracticeAreas($practiceArea) :)
  (: let $Cities := if($cities ne '' or $countries ne '' or $geoGraphicRegion ne '' or $usRegions ne '') then  :)
                    (: firmstatics:getGtandardLocations($cities,$countries,$geoGraphicRegion,$usRegions) else(cts:element-values(xs:QName("cityns:std_loc"))) :)
					
  (: let $orderBy :=cts:index-order(cts:element-reference(xs:QName('tblrer:firm_name')) ,'ascending') :)
  (: let $query := cts:and-query(( :)
                   (: cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/'), :)
                   (: (:if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrer:practices'),$PracticeAreas, ("wildcarded","case-insensitive")) else(),:) :)
				   (: if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrer:practice_area'),$PracticeAreas, ("wildcarded","case-insensitive")) else(), :)
                   (: (:if($Cities ne '') then cts:element-value-query(xs:QName('tblrer:location'),$Cities, ('case-insensitive','whitespace-sensitive')) else(),:) :)
				   (: if($Cities ne '') then cts:element-value-query(xs:QName('tblrer:location'),$Cities,("case-insensitive")) else(), :)
                   (: if($firmID ne '') then cts:element-value-query(xs:QName('tblrer:firm_id'),fn:tokenize($firmID,',')) else(), :)
				   (: cts:not-query(cts:element-value-query(xs:QName('tblrer:location'), 'Location Not Available', "case-insensitive")) :)
                   (: )) :)
  
 (: let $totalCount := (:fn:count(cts:values(cts:element-reference(xs:QName('tblrer:firm_id')), (), (),$query)):)0 :)
 (: let $res-array := json:array() :)
 (: let $search := for $company in cts:values(cts:element-reference(xs:QName('tblrer:firm_id')), (), (),$query) :)
 (: let $res-object := json:object() :)
 
 (: let $headcount := xdmp:estimate(cts:search(/, :)
    (: cts:and-query(( :)
    (: cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/') :)
    (: (:,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrer:practices'), $PracticeAreas, ("wildcarded","case-insensitive")) else():) :)
	(: ,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrer:practice_area'), $PracticeAreas, ("wildcarded","case-insensitive")) else() :)
    (: (: ,if($Cities ne '') then cts:element-value-query(xs:QName('tblrer:location'), $Cities) else() :) :)
	(: ,if($Cities ne '') then cts:element-value-query(xs:QName('tblrer:location'), $Cities,("case-insensitive")) else() :)
    (: ,cts:element-value-query(xs:QName('tblrer:firm_id'), xs:string($company)) :)
    (: ,cts:element-value-query(xs:QName('tblrer:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive")) :)
    (: )))) :)
	
 (: let $headcountplus := xdmp:estimate(cts:search(/, :)
    (: cts:and-query(( :)
    (: cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/') :)
    (: (:,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ("wildcarded","case-insensitive")) else() :)
	(: ,if($Cities ne '') then cts:element-value-query(xs:QName('tblrermovechanges:location'), $Cities) else():) :)
	(: ,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ("wildcarded","case-insensitive")) else() :)
    (: ,if($Cities ne '') then cts:element-value-query(xs:QName('tblrermovechanges:location'), $Cities) else() :)
    (: ,cts:element-value-query(xs:QName('tblrermovechanges:firm_id'), xs:string($company)) :)
    (: ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive")) :)
    (: ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'),'added') :)
	(: ,if($fromDate ne '' and $toDate ne '') then cts:and-query(( :)
			(: cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)), :)
			(: cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)) :)
	(: ))  else() :)
    (: )))) :)
 (: let $headcountminus := xdmp:estimate(cts:search(/, :)
    (: cts:and-query(( :)
    (: cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/') :)
    (: (:,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ("wildcarded","case-insensitive")) else() :)
    (: ,if($Cities ne '') then cts:element-value-query(xs:QName('tblrermovechanges:location'), $Cities) else():) :)
	(: ,if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ("wildcarded","case-insensitive")) else() :)
    (: ,if($Cities ne '') then cts:element-value-query(xs:QName('tblrermovechanges:location'), $Cities) else() :)
    (: ,cts:element-value-query(xs:QName('tblrermovechanges:firm_id'), xs:string($company)) :)
    (: ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive")) :)
    (: ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'),'removed')   :)
	(: ,if($fromDate ne '' and $toDate ne '') then cts:and-query(( :)
			(: cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)), :)
			(: cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)) :)
	(: ))  else() :)
    (: )))) :)
    
    (: (:let $firmDetail := firmstatics:getFIRMS_ALI_XREF_REData($company)  :) :)
    (: let $diff := xs:decimal($headcountplus) - xs:decimal($headcountminus) :)
	
	(: let $firmName := cts:search(/, :)
		(: cts:and-query(( :)
			(: cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/') :)
			(: ,cts:element-value-query(xs:QName('tblrer:firm_id'), xs:string($company)) :)
			(: ,cts:not-query(cts:element-value-query(xs:QName('tblrer:firm_name'), '')) :)
		(: )) :)
	(: )[1]//tblrer:firm_name/text() :)
	
    (: let $div := if($headcount ne 0) then ($diff div xs:decimal($headcount)) * xs:double(100) else 0 :)
    (: let $_ := ( map:put($res-object,'firmID',$company), :)
                (: (:map:put($res-object,'firmName',firmstatics:getFirmName(xs:string($company))),:) :)
				(: map:put($res-object,'firmName',$firmName), :)
                (: map:put($res-object,'headCount',$headcount), :)
                (: map:put($res-object,'headCountPlus',$headcountplus), :)
                (: map:put($res-object,'headCountMinus',$headcountminus), :)
                (: map:put($res-object,'changes',fn:round($div)), :)
                (: map:put($res-object,'TotalCount',$totalCount)) :)
    (: (:let $_ := json:array-push($res-array,$res-object):) :)
	
	 (: let $_ := if($firmSizefrom ne '0' and $firmSizeTo ne '0') then if($headcount ge xs:integer($firmSizefrom) and $headcount le xs:integer($firmSizeTo)) then json:array-push($res-array,$res-object) else() else json:array-push($res-array,$res-object) :)
    (: return () :)
  
  (: return $res-array :)
(: }; :)

declare function firmstatics:sp_GetLawFirmStaticsChangesByFirm1($cities,$countries,$geoGraphicRegion,$usRegions,$practiceArea,$firmID,$fromDate,$toDate,$firmSizefrom,$firmSizeTo)
{
	 let $PracticeAreas := if($practiceArea ne '') then firmstatics:getPracticeAreas($practiceArea) else()
  let $Cities := if($cities ne '' or $countries ne '' or $geoGraphicRegion ne '' or $usRegions ne '') then 
                    firmstatics:getGtandardLocations($cities,$countries,$geoGraphicRegion,$usRegions,'') else()
  
  let $attorneyQuery := cts:and-query((
										cts:directory-query('/LegalCompass/denormalized-data/ALI_RE_Attorney_Data/'),
										 if($PracticeAreas ne '') then cts:element-word-query(xs:QName('aliattorneydata:practice_area'),$PracticeAreas,('wildcarded','case-insensitive')) else(),
										 
										 if($Cities ne '') then cts:element-value-query(xs:QName('aliattorneydata:location'),$Cities,"exact") else(),
										 if($firmID ne '') then cts:element-value-query(xs:QName('aliattorneydata:firm_id'),fn:tokenize($firmID,',')) else()
										))
										
  let $aliIDs := if($PracticeAreas ne '' or $Cities ne '' or $firmID ne '') then fn:distinct-values(cts:search(/, 
																							$attorneyQuery
																							)//aliattorneydata:ALI_ID/text())
				else cts:values(cts:element-reference(xs:QName('aliattorneydata:ALI_ID')), (), (),$attorneyQuery)																		
					

  
  let $reIDs := firmstatics:getFIRMS_ALI_XREF_REData2($aliIDs) ! fn:string(.)
  
   
  let $orderBy :=cts:index-order(cts:element-reference(xs:QName('tblrer:firm_name')) ,'ascending')
  			   
  let $firmIDS := cts:values(cts:element-reference(xs:QName('tblrer:firm_id')), (), (), cts:and-query((
							   cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/'),
							   if($practiceArea ne '') then cts:element-word-query(xs:QName('tblrer:practices'),$PracticeAreas,('wildcarded','case-insensitive')) else(),
							   if($Cities ne '') then cts:element-word-query(xs:QName('tblrer:location'),$Cities,'wildcarded') else(),
							   cts:element-value-query(xs:QName('tblrer:firm_id'),$reIDs)
							   )))

	 
  let $firmIDS := if($firmSizefrom ne '0' and $firmSizeTo ne '0') then firmstatics:sp_GetLawFirmStaticsCount3_2($cities,$countries,$geoGraphicRegion,$usRegions,$practiceArea,$firmID,$fromDate,$toDate,$firmSizefrom,$firmSizeTo,'') else for $firmID in $firmIDS
		let $res := cts:search(/,
		cts:and-query((
			cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/')
			,cts:element-value-query(xs:QName('tblrer:firm_id'),($firmID ! xs:string(.)))
			,cts:not-query(cts:element-value-query(xs:QName('tblrer:firm_name'),''))
			)))[1]
	order by $res//tblrer:firm_name/text() ascending
	return $res//tblrer:firm_id/text()
 
   let $totalCount := count($firmIDS)
 
 let $res-array := json:array()
let $loopData := for $company in $firmIDS
	
 let $res-object := json:object()




  let $headcount := xdmp:estimate(cts:search(/,
    cts:and-query((
    cts:directory-query('/LegalCompass/denormalized-data/ALI_RE_Attorney_Data/')
    ,if($practiceArea ne '') then cts:element-value-query(xs:QName('aliattorneydata:practice_area'),$PracticeAreas, ("case-insensitive")) else()
    ,if($Cities ne '') then cts:element-value-query(xs:QName('aliattorneydata:location'), $Cities) else()
    ,cts:element-value-query(xs:QName('aliattorneydata:firm_id'), xs:string($company))
    ,cts:element-value-query(xs:QName('aliattorneydata:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
    ))))
	
 let $headcountplus := xdmp:estimate(cts:search(/,
    cts:and-query((
    cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
    ,if($practiceArea ne '') then cts:element-value-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ("case-insensitive")) else()
    ,if($Cities ne '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $Cities,('wildcarded','case-insensitive')) else()
    ,cts:element-value-query(xs:QName('tblrermovechanges:firm_id'), xs:string($company))
    ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
    ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'),'added')
    ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
	
  let $headcountminus := xdmp:estimate(cts:search(/,
    cts:and-query((
    cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
    ,if($practiceArea ne '') then cts:element-value-query(xs:QName('tblrermovechanges:practice_area'), $PracticeAreas, ("case-insensitive")) else()
    ,if($Cities ne '') then cts:element-value-query(xs:QName('tblrermovechanges:location'), $Cities) else()
    ,cts:element-value-query(xs:QName('tblrermovechanges:firm_id'), xs:string($company))
    ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
    ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'),'removed')  
	,if($fromDate ne '' and $toDate ne '') then cts:and-query((
			cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
			cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate))
	))  else()
    )))) 
	
	
 
    let $diff := xs:decimal($headcountplus) - xs:decimal($headcountminus)
    let $div := if($headcount ne 0) then ($diff div xs:decimal($headcount)) * xs:double(100) else 0
    let $diff := xs:decimal($headcountplus) - xs:decimal($headcountminus)
		 let $div := if($headcount ne 0) then ($diff div xs:decimal($headcount))*xs:double(100) else 0
    let $_ := ( map:put($res-object,'firmID',$company),
                map:put($res-object,'firmName',firmstatics:getFirmName(xs:string($company))),
				map:put($res-object,'headCount',$headcount),
                map:put($res-object,'headCountPlus',$headcountplus),
                map:put($res-object,'headCountMinus',$headcountminus),
                map:put($res-object,'changes',fn:round($div)),
                map:put($res-object,'TotalCount',$totalCount))
    
	
	 let $_ := json:array-push($res-array,$res-object)
    return ()
  
  return $res-array 

};


declare function firmstatics:getFirmName($firmID)
{
	let $firm := cts:search(/,
                     cts:and-query((
                       cts:directory-query('/LegalCompass/relational-data/FIRMS_ALI_XREF_RE/'),
                       cts:element-value-query(xs:QName('alidata:RE_ID'),$firmID)
                       )))[1]//alidata:ALM_NAME/text()
	
  let $firmName := cts:search(/, 
					cts:and-query((
                       cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/'),
                       cts:element-value-query(xs:QName('tblrer:firm_id'),$firmID)
                       )))[1]//tblrer:firm_name/text()
					   
  let $firmName1 := if($firm ne '') then $firm else $firmName					   
 return $firmName1
};

declare function firmstatics:sp_GetLawFirmStaticsPracticeChangesByFirm2($cities,$countries,$geoGraphicRegion,$usRegions,$practiceArea,$firmID,$fromDate,$toDate,$firmSizefrom,$firmSizeTo)
{
  let $PracticeAreas := if($practiceArea != '') then firmstatics:getPracticeAreas($practiceArea) else()
  let $Cities := if($cities ne '' or $countries ne '' or $geoGraphicRegion ne '' or $usRegions ne '') then 
                    firmstatics:getGtandardLocations($cities,$countries,$geoGraphicRegion,$usRegions,'') else()
					
  let $orderBy :=cts:index-order(cts:element-reference(xs:QName('tblrer:firm_name')) ,'ascending')
  let $query := cts:and-query((
                   cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/'),
                   if($practiceArea ne '') then cts:element-value-query(xs:QName('tblrer:practices'),$PracticeAreas) else(),
                   if($Cities ne '') then cts:element-value-query(xs:QName('tblrer:location'),$Cities) else(),
                   if($firmID ne '') then cts:element-value-query(xs:QName('tblrer:firm_id'),fn:tokenize($firmID,',')) else()
                   ))
  
 let $totalCount := (:fn:count(cts:values(cts:element-reference(xs:QName('tblrer:firm_id')), (), (),$query)):)0
 let $res-array := json:array()
 let $search := for $company in cts:values(cts:element-reference(xs:QName('tblrer:firm_id')), (), (),$query)
					 let $res-object := json:object()
					 
					 let $headcount := xdmp:estimate(cts:search(/,
										cts:and-query((
											cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/')
											,if($practiceArea ne '') then cts:element-value-query(xs:QName('tblrer:practices'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
											,if($Cities ne '') then cts:element-value-query(xs:QName('tblrer:location'), $Cities) else()
											,cts:element-value-query(xs:QName('tblrer:firm_id'), xs:string($company))
											,cts:element-value-query(xs:QName('tblrer:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
											))))
						
					 let $headcountplus := xdmp:estimate(cts:search(/,
											cts:and-query((
												cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
												,if($practiceArea ne '') then cts:element-value-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
												,if($Cities ne '') then cts:element-value-query(xs:QName('tblrermovechanges:location'), $Cities) else()
												,cts:element-value-query(xs:QName('tblrermovechanges:firm_id'), xs:string($company))
												,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
												,cts:element-value-query(xs:QName('tblrermovechanges:last_action'),'added')
												,if($fromDate ne '' and $toDate ne '') then cts:and-query((
														cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
														cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate))
												))  else()
												))))
						
					 let $headcountminus := xdmp:estimate(cts:search(/,
											  cts:and-query((
												cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
												,if($practiceArea ne '') then cts:element-value-query(xs:QName('tblrermovechanges:practices'), $PracticeAreas, ("wildcarded","case-insensitive")) else()
												,if($Cities ne '') then cts:element-value-query(xs:QName('tblrermovechanges:location'), $Cities) else()
												,cts:element-value-query(xs:QName('tblrermovechanges:firm_id'), xs:string($company))
												,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
												,cts:element-value-query(xs:QName('tblrermovechanges:last_action'),'removed')  
												,if($fromDate ne '' and $toDate ne '') then cts:and-query((
														cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
														cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate))
												))  else()
												))))
						
						
						let $diff := xs:decimal($headcountplus) - xs:decimal($headcountminus)
						let $div := if($headcount ne 0) then ($diff div xs:decimal($headcount)) * xs:double(100) else 0
						
						let $_ := ( map:put($res-object,'firmID',$company),
									map:put($res-object,'firmName',firmstatics:getFirmName(xs:string($company))),
									map:put($res-object,'headCount',$headcount),
									map:put($res-object,'headCountPlus',$headcountplus),
									map:put($res-object,'headCountMinus',$headcountminus),
									map:put($res-object,'changes',fn:round($div)),
									map:put($res-object,'TotalCount',$totalCount))
						
						 let $_ := if($firmSizefrom ne '0' and $firmSizeTo ne '0') then if($headcount ge xs:integer($firmSizefrom) and $headcount le xs:integer($firmSizeTo)) then json:array-push($res-array,$res-object) else() else json:array-push($res-array,$res-object)
						return ()
  
  return $res-array
 
};

declare function firmstatics:sp_GetLawFirmStaticsChart($cities,$countries,$geoGraphicRegion,$usRegions,$practiceArea,$firmID,$fromDate,$toDate,$PageNo,$PageSize,$firmSizefrom,$firmSizeTo,$state,$isPrimaryPracticeArea,$isHeadquarter)
{
  let $PracticeAreas := if($practiceArea ne '') then firmstatics:getPracticeAreas($practiceArea) else()
  let $Cities := if($cities ne '' or $countries ne '' or $geoGraphicRegion ne '' or $usRegions ne '' or $state ne '') then 
                    firmstatics:getGtandardLocations($cities,$countries,$geoGraphicRegion,$usRegions,$state) else()
  
  let $attorneyQuery := cts:and-query((
										cts:directory-query('/LegalCompass/denormalized-data/ALI_RE_Attorney_Data/'),
										 if($PracticeAreas ne '') then 
                          if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('aliattorneydata:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                          else cts:element-word-query(xs:QName('aliattorneydata:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                      else(),
										 if($Cities ne '') then cts:element-value-query(xs:QName('aliattorneydata:location'),$Cities,"exact") else(),
										 if($firmID ne '') then cts:element-value-query(xs:QName('aliattorneydata:ALI_ID'),fn:tokenize($firmID,',')) else()
										))
										
  let $aliIDs := cts:values(cts:element-reference(xs:QName('aliattorneydata:ALI_ID')), (), (),$attorneyQuery)	

  let $amlaw200Year := max(cts:search(/,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/')
                      ))
                    )//AMLAW_200:PUBLISHYEAR/text())

  let $amlaw200ID := cts:search(/,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
                        cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$aliIDs ! xs:string(.)),
                        cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($amlaw200Year)),
                        cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
                      ))
                    )//AMLAW_200:ORGANIZATION_ID/text()

  let $global100Year := max(cts:search(/,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/surveys/Global_100/')
                      ))
                    )//Global_100:PUBLISHYEAR/text())
  
  let $global100ID := cts:search(/,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/surveys/Global_100/'),
                        cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$aliIDs ! xs:string(.)),
                        cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($global100Year)),
                        cts:not-query(cts:element-value-query(xs:QName('Global_100:RANK_BY_GROSS_REVENUE'),''))
                      ))
                    )//Global_100:ORGANIZATION_ID/text()

  
  let $uk50Year := max(cts:search(/,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/surveys/UK_50/')
                      ))
                    )//UK_50:PUBLISHYEAR/text())
  
  let $uk50ID := cts:search(/,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/surveys/UK_50/'),
                        cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),$aliIDs ! xs:string(.)),
                         cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string($uk50Year)),
                         cts:not-query(cts:element-value-query(xs:QName('UK_50:UK_50_RANK'),''))
                      ))
                    )//UK_50:ORGANIZATION_ID/text()

  let $distinctAliID := fn:distinct-values(($amlaw200ID,$global100ID,$uk50ID))
  
  let $reIDs := firmstatics:getFIRMS_ALI_XREF_REData2($distinctAliID) ! fn:string(.)
  
  let $fromRecord := if($PageNo ne '1') then (xs:int($PageNo)-1) * xs:int($PageSize) + 1 else 1
  let $toRecord := xs:int($PageSize) * xs:int($PageNo)
  
  let $orderBy :=cts:index-order(cts:element-reference(xs:QName('tblrer:firm_name')) ,'ascending')
  			   
  let $firmIDS := cts:values(cts:element-reference(xs:QName('tblrer:firm_id')), (), (), cts:and-query((
							   cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/'),
							   if($PracticeAreas ne '') then 
                          if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('tblrer:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                          else cts:element-word-query(xs:QName('tblrer:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                      else(),
							   if($Cities ne '') then cts:element-word-query(xs:QName('tblrer:location'),$Cities,'wildcarded') else(),
							   cts:element-value-query(xs:QName('tblrer:firm_id'),$reIDs)
							   )))

	let $idss := 	if($firmSizefrom ne '0' and $firmSizeTo ne '0') then 
                      for $item in $firmIDS
                       let $headcount := xdmp:estimate(cts:search(/,
                                            cts:and-query((
                                                cts:directory-query('/LegalCompass/denormalized-data/ALI_RE_Attorney_Data/')
                                                ,if($PracticeAreas ne '') then 
                                                      if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('aliattorneydata:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                      else cts:element-word-query(xs:QName('aliattorneydata:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                  else()
                                                ,if($Cities ne '') then cts:element-value-query(xs:QName('aliattorneydata:location'), $Cities) else()
                                                ,cts:element-value-query(xs:QName('aliattorneydata:firm_id'), xs:string($item))
                                                ,cts:element-value-query(xs:QName('aliattorneydata:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
                                                ))))
                       let $idS := if($headcount ge xs:integer($firmSizefrom) and $headcount le xs:integer($firmSizeTo)) then $item else()
			                 return $idS
                else  $firmIDS                           

    let $firmIDS := for $firmID in $idss

		let $res := cts:search(/,
                    cts:and-query((
                      cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/')
                      ,cts:element-value-query(xs:QName('tblrer:firm_id'),($firmID ! xs:string(.)))
                      ,cts:not-query(cts:element-value-query(xs:QName('tblrer:firm_name'),''))
                      )))[1]
                  order by $res//tblrer:firm_name/text() ascending
                  return $res//tblrer:firm_id/text()
  
  let $totalCount := count($firmIDS)
 
  let $res-array := json:array()
  let $loopData := for $company in $firmIDS
 
                            let $res-object := json:object()

                            let $headcount := xdmp:estimate(cts:search(/,
                                                       cts:and-query((
                                                      cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/'),
                                                      if($PracticeAreas ne '') then 
                                                          if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('tblrer:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                          else cts:element-word-query(xs:QName('tblrer:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                      else(),
                                                      if($Cities ne '') then cts:element-word-query(xs:QName('tblrer:location'),$Cities,('wildcarded','case-insensitive')) else()
                                                      ,cts:element-value-query(xs:QName('tblrer:firm_id'), xs:string($company))
                                                      ,cts:element-value-query(xs:QName('tblrer:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'))
                                                      ))))
                                                      
                                                    
                             (: let $headcountplus := xdmp:estimate(cts:search(/,
                                                      cts:and-query((
                                                      cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
                                                      ,if($PracticeAreas ne '') then 
                                                            if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('tblrermovechanges:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                            else cts:element-word-query(xs:QName('tblrermovechanges:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                        else()
                                                      ,if($Cities ne '') then cts:element-word-query(xs:QName('tblrermovechanges:location'), $Cities,('wildcarded','case-insensitive')) else()
                                                      ,cts:element-value-query(xs:QName('tblrermovechanges:firm_id'), xs:string($company))
                                                      ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
                                                      ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'),'added')
                                                      ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                                                                  cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                                                                  cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
                                                    
                            let $headcountminus := xdmp:estimate(cts:search(/,
                                                      cts:and-query((
                                                      cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/')
                                                      ,if($PracticeAreas ne '') then 
                                                          if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('tblrermovechanges:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                          else cts:element-word-query(xs:QName('tblrermovechanges:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                      else()
                                                      ,if($Cities ne '') then cts:element-value-query(xs:QName('tblrermovechanges:location'), $Cities) else()
                                                      ,cts:element-value-query(xs:QName('tblrermovechanges:firm_id'), xs:string($company))
                                                      ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
                                                      ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'),'removed')  
                                                    ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                                                        cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                                                        cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate))
                                                    ))  else()
                                                      ))))	 :)
                                  
                            
                              let $headcountplus := xdmp:estimate(cts:search(/,
                                                      cts:and-query((
                                                      cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/'),
                                                      cts:not-query(cts:element-value-query(xs:QName('tblrermovechanges:last_action_date'),'0/0/0000')),
                                                      if($PracticeAreas ne '') then 
                                                          if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('tblrermovechanges:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                          else cts:element-word-query(xs:QName('tblrermovechanges:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                      else()
                                                      ,if($Cities ne '') then if(xs:string($isHeadquarter) eq 'true') then cts:and-query((
                                                                      cts:element-word-query(xs:QName('tblrermovechanges:location'),$Cities,'wildcarded'),
                                                                      cts:element-value-query(xs:QName('tblrermovechanges:HQ'),'Y','case-insensitive'))) else cts:element-word-query(xs:QName('tblrermovechanges:location'),$Cities,'wildcarded')
                                                      else()
                                                      ,cts:element-value-query(xs:QName('tblrermovechanges:firm_id'), xs:string($company))
                                                      ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
                                                      ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'),'added')
                                                      ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                                                                  cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                                                                  cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate)))) else()))))
                                                    
                            let $headcountminus := xdmp:estimate(cts:search(/,
                                                      cts:and-query((
                                                      cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/'),
                                                      cts:not-query(cts:element-value-query(xs:QName('tblrermovechanges:last_action_date'),'0/0/0000')),
                                                      if($PracticeAreas ne '') then 
                                                          if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('tblrermovechanges:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                          else cts:element-word-query(xs:QName('tblrermovechanges:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                      else()
                                                      ,if($Cities ne '') then if(xs:string($isHeadquarter) eq 'true') then cts:and-query((
                                                                      cts:element-word-query(xs:QName('tblrermovechanges:location'),$Cities,'wildcarded'),
                                                                      cts:element-value-query(xs:QName('tblrermovechanges:HQ'),'Y','case-insensitive'))) else cts:element-word-query(xs:QName('tblrermovechanges:location'),$Cities,'wildcarded')
                                                      else()
                                                      ,cts:element-value-query(xs:QName('tblrermovechanges:firm_id'), xs:string($company))
                                                      ,cts:element-value-query(xs:QName('tblrermovechanges:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),("case-insensitive"))
                                                      ,cts:element-value-query(xs:QName('tblrermovechanges:last_action'),'removed')  
                                                    ,if($fromDate ne '' and $toDate ne '') then cts:and-query((
                                                        cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'>=',xs:date($fromDate)),
                                                        cts:element-range-query(xs:QName('tblrermovechanges:last_action_date'),'<=',xs:date($toDate))
                                                    ))  else()
                                                      ))))	 

                                                      
                              let $firmDetail := firmstatics:getFIRMS_ALI_XREF_REData($company)  
                              let $diff := xs:decimal($headcountplus) - xs:decimal($headcountminus)
                              let $div := if($headcount ne 0) then ($diff div xs:decimal($headcount))*xs:double(100) else 0
                              let $firmName := if($firmDetail/alidata:ALM_NAME/text() ne '') then $firmDetail/alidata:ALM_NAME/text() else firmstatics:getFirmName(xs:string($company))
                              let $_ := ( map:put($res-object,'firmID',$company),
                                          map:put($res-object,'firmName',firmstatics:getFirmName(xs:string($company))),
                                          map:put($res-object,'headCount',$headcount),
                                          map:put($res-object,'headCountPlus',$headcountplus),
                                          map:put($res-object,'headCountMinus',$headcountminus),
                                          map:put($res-object,'firmDetail',$firmDetail),
                                          map:put($res-object,'changes',fn:round($div)))
                                          
                                  
                              let $_ := json:array-push($res-array,$res-object)
                              return ()
  
  return $res-array
};

declare function firmstatics:GetLawFirmStaticsFirmID($cities,$countries,$geoGraphicRegion,$usRegions,$practiceArea,$firmID,$fromDate,$toDate,$PageNo,$PageSize,$firmSizefrom,$firmSizeTo,$state,$isPrimaryPracticeArea,$isHeadquarter)
{

  let $PracticeAreas := if($practiceArea ne '') then firmstatics:getPracticeAreas($practiceArea) else()
  let $Cities := if($cities ne '' or $countries ne '' or $geoGraphicRegion ne '' or $usRegions ne '' or $state ne '') then 
                    firmstatics:getGtandardLocations($cities,$countries,$geoGraphicRegion,$usRegions,$state) else()
  
  let $attorneyQuery := cts:and-query((
										cts:directory-query('/LegalCompass/denormalized-data/ALI_RE_Attorney_Data/'),
										 if($PracticeAreas ne '') then 
                        if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('aliattorneydata:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                        else cts:element-word-query(xs:QName('aliattorneydata:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                     else(),
										 
										 if($Cities ne '') then cts:element-value-query(xs:QName('aliattorneydata:location'),$Cities,"exact") else(),
										 if($firmID ne '') then cts:element-value-query(xs:QName('aliattorneydata:ALI_ID'),fn:tokenize($firmID,',')) else()
										))
										
  let $aliIDs :=  cts:values(cts:element-reference(xs:QName('aliattorneydata:ALI_ID')), (), (),$attorneyQuery)	
  
  let $reIDs := firmstatics:getFIRMS_ALI_XREF_REData2($aliIDs) ! fn:string(.)
  
  let $fromRecord := if($PageNo ne '1') then (xs:int($PageNo)-1) * xs:int($PageSize) + 1 else 1
  let $toRecord := xs:int($PageSize) * xs:int($PageNo)
  
  let $orderBy :=cts:index-order(cts:element-reference(xs:QName('tblrer:firm_name')) ,'ascending')
  			   
  let $firmIDS := cts:values(cts:element-reference(xs:QName('tblrer:firm_id')), (), (), cts:and-query((
							   cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/'),
							  if($PracticeAreas ne '') then 
                                                          if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('tblrer:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                          else cts:element-word-query(xs:QName('tblrer:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                      else(),
							   if($Cities ne '') then if(xs:string($isHeadquarter) eq 'true') then cts:and-query((
                                cts:element-word-query(xs:QName('tblrer:location'),$Cities,'wildcarded'),
                                cts:element-value-query(xs:QName('tblrer:HQ'),'Y','case-insensitive'))) else cts:element-word-query(xs:QName('tblrer:location'),$Cities,'wildcarded')
                 else(),
							   cts:element-value-query(xs:QName('tblrer:firm_id'),$reIDs)
							   )))

	let $idss := 	if($firmSizefrom gt 0 and $firmSizeTo gt 0) then 
                      for $item in $firmIDS
                       let $headcount := xdmp:estimate(cts:search(/,
                                            cts:and-query((
                                                      cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/'),
                                                      if($PracticeAreas ne '') then 
                                                          if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('tblrer:practices'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                          else cts:element-word-query(xs:QName('tblrer:primary_practice'),fn:tokenize($practiceArea,'[|]'),('wildcarded','case-insensitive')) 
                                                      else(),
                                                      if($Cities ne '') then if(xs:string($isHeadquarter) eq 'true') then cts:and-query((
                                                                      cts:element-word-query(xs:QName('tblrer:location'),$Cities,'wildcarded'),
                                                                      cts:element-value-query(xs:QName('tblrer:HQ'),'Y','case-insensitive'))) else cts:element-word-query(xs:QName('tblrer:location'),$Cities,'wildcarded')
                                                      else()
                                                      ,cts:element-value-query(xs:QName('tblrer:firm_id'), xs:string($item))
                                                      ,cts:element-value-query(xs:QName('tblrer:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'))
                                                      ))))
                                            
                       return if($headcount ge xs:integer($firmSizefrom) and $headcount le xs:integer($firmSizeTo)) then $item else 1001020
			                
                else  $firmIDS                           

  let $firmIDS1 := for $firmID in $idss
                      let $res := cts:search(/,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/')
                        ,cts:element-value-query(xs:QName('tblrer:firm_id'),($firmID ! xs:string(.)))
                        ,cts:not-query(cts:element-value-query(xs:QName('tblrer:firm_name'),''))
                        )))[1]
                    order by $res//tblrer:firm_name/text() ascending
                    return if(xs:string($firmID) ne '1001020') then $firmID else()
 
  let $loopData := for $company in $firmIDS1

                          let $res-object := json:object()

                          let $firmDetail := firmstatics:getFIRMS_ALI_XREF_REData($company)   
                              let $_ := (
                                            map:put($res-object,'firmID',$firmDetail/alidata:ALI_ID/text())
                                        )
                              return $res-object
  
  return json:to-array($loopData)
};
