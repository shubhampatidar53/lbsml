 xquery version '1.0-ml';

module namespace attorney = 'http://alm.com/attorney';

import module namespace config = 'http://alm.com/config' at '/common/config.xqy';
import module namespace firm = 'http://alm.com/firm' at '/common/model/firm.xqy';
import module namespace search = 'http://marklogic.com/appservices/search' at '/MarkLogic/appservices/search/search.xqy';

declare namespace html = 'http://www.w3.org/1999/xhtml';
declare namespace cityns = 'http://alm.com/LegalCompass/rd/city';
declare namespace practices = 'http://alm.com/LegalCompass/rd/practices_kws';
declare namespace usergrouptype = 'http://alm.com/LegalCompass/rd/user_group_type';
declare namespace usergroup = 'http://alm.com/LegalCompass/rd/user_groups';
declare namespace user = 'http://alm.com/LegalCompass/rd/users';
declare namespace usergroupcompany = 'http://alm.com/LegalCompass/rd/user_group_companies';
declare namespace company = 'http://alm.com/LegalCompass/rd/company';
declare namespace firmsali = 'http://alm.com/LegalCompass/rd/FIRMS_ALI_XREF_RE';
declare namespace amlaw100 = 'http://alm.com/LegalCompass/rd/AMLAW_100';
declare namespace amlaw200 = 'http://alm.com/LegalCompass/rd/AMLAW_200';
declare namespace global100 = 'http://alm.com/LegalCompass/rd/Global_100';
declare namespace nlj250 = 'http://alm.com/LegalCompass/rd/NLJ_250';
declare namespace lcwatchlist = 'http://alm.com/LegalCompass/rd/LC_WATCHLIST';
declare namespace organizations = 'http://alm.com/LegalCompass/rd/organization';
declare namespace organizationaddress = 'http://alm.com/LegalCompass/rd/organization-address';
declare namespace lateralpartner = 'http://alm.com/LegalCompass/rd/Lateral_Partner';
declare namespace peoplechanges = 'http://alm.com/LegalCompass/rd/people_changes';
declare namespace peopledetail = 'http://alm.com/LegalCompass/rd/person_detail';
declare namespace attorneycases = 'http://alm.com/LegalCompass/rd/ATTORNEYCASES';
declare namespace fimrsali ='http://alm.com/LegalCompass/rd/FIRMS_ALI_XREF_RE';
declare namespace people = 'http://alm.com/LegalCompass/dd/person';
declare namespace peoplerd = 'http://alm.com/LegalCompass/rd/person';
declare namespace lcpd='http://alm.com/LegalCompass/dd/person_detail';
declare namespace lateralmoves = 'http://alm.com/LegalCompass/rd/ALI_RE_LateralMoves_Data';
declare namespace aliattorneydata = 'http://alm.com/LegalCompass/dd/ALI_RE_Attorney_Data';
declare namespace usstates = "http://alm.com/LegalCompass/rd/US_STATE_ABBREVIATION"; 
declare namespace tblrer = "http://alm.com/LegalCompass/dd/TBL_RER_CACHE_ATTORNEY_DATA";
declare namespace tblrermovechanges = "http://alm.com/LegalCompass/dd/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES";
declare namespace companyatt = "http://alm.com/LegalCompass/rd/COMPANY_ATTORNEYS";
declare namespace peopledetailtext = 'http://alm.com/LegalCompass/rd/people_detail_text';
declare namespace alidata = "http://alm.com/LegalCompass/rd/FIRMS_ALI_XREF_RE";
declare namespace ALI_RE_Attorney_Combined = 'http://alm.com/LegalCompass/dd/ALI_RE_Attorney_Combined';
declare namespace US_STATE_ABBREVIATION = 'http://alm.com/LegalCompass/rd/US_STATE_ABBREVIATION';
declare namespace lateral_partner = 'http://alm.com/LegalCompass/lateral_partner';



declare function attorney:GetLocationsRE()
{
  let $response-array := json:array()

  (: let $popleTableCity := cts:values(cts:element-reference(xs:QName('peoplerd:std_loc')),(),(),()) :)

  let $popleTableCity := fn:distinct-values(cts:search(/,
                            cts:and-query((
                               cts:directory-query('/LegalCompass/relational-data/person/')
                        )))//peoplerd:std_loc/text())

   let $result := cts:search(/city,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/city/'),
                        (: cts:element-value-query(xs:QName('cityns:std_loc'),$popleTableCity), :)
                        cts:element-value-query(xs:QName('cityns:std_loc'),$popleTableCity ! fn:string(.),('case-insensitive')),
                        cts:not-query(cts:element-value-query(xs:QName('cityns:geographic_region'),''))
                      )))

 let $loopData := for $item in $result
                      let $response-obj := json:object()
                      let $_ := (
                                 map:put($response-obj,'City',$item/cityns:city/text()),
                                 map:put($response-obj,'State',$item/cityns:state/text()),
                                 map:put($response-obj,'Country',$item/cityns:country/text()),
                                 map:put($response-obj,'GeographicRegion',$item/cityns:geographic_region/text()),
                                 map:put($response-obj,'UsRegion',$item/cityns:us_region/text())
                                 )
                     let $_ := json:array-push($response-array , $response-obj)
                     return ()
                     
return $response-array                 
};

declare function attorney:GetPracticeAreasFromRE()
{
  let $response-array := json:array()
  let $result :=cts:element-values(xs:QName('practices:practice_area'))(:fn:distinct-values(cts:search(/practices_kws,
													cts:and-query((
														cts:directory-query('/LegalCompass/relational-data/practices_kws/')
													)))/practices:practice_area/text()):)
  let $loopData := for $item in $result
                       let $response-obj := json:object()
                       let $_ := (map:put($response-obj,'PracticeareaName',$item))
                       let $_ := json:array-push($response-array , $response-obj)
                       return ()
  return $response-array
};

declare function attorney:sp_GetWatchListFirms($watchlistID,$userEmail)
{
let $response-array := json:array()
let $userData := cts:search(/,
  cts:and-query((
    cts:directory-query('/LegalCompass/relational-data/users/'),
    cts:element-value-query(xs:QName('user:email'),$userEmail)
  )))
                       
          
(: let $userGroupData := attorney:getUserGroupData1($userData//user:id/text(),$watchlistID) :)
		  
let $userGroupData := cts:search(/,
  cts:and-query((
  cts:directory-query('/LegalCompass/relational-data/user_groups/'),
  cts:element-value-query(xs:QName('usergroup:id'),$userData//user:id/text()),
  cts:element-value-query(xs:QName('usergroup:group_id'),$watchlistID)
  )))
		  
		  
let $userGroupTypeData := cts:search(/,
  cts:and-query((
    cts:directory-query('/LegalCompass/relational-data/user_group_type/')
    ,cts:element-value-query(xs:QName('usergrouptype:user_Id'),$userData//user:id/text())
    ,cts:element-value-query(xs:QName('usergrouptype:group_Id'),$userGroupData//usergroup:group_id/text())
  )))
  
(:attorney:getUserGroupTypeData($userGroupData//usergroup:group_id/text() ,$userData//user:id/text())  :)
          
(:START: replacing with search with root node. Modified by Raveendra:)
(: let $userGroupCompanyData :=attorney:getUserGroupCompanyData($userGroupData/usergroup:group_id/text() ,$userData/user:id/text()) :)
		  
let $userGroupCompanyData := cts:search(/,
  cts:and-query((
    cts:directory-query('/LegalCompass/relational-data/user_group_companies/'),
    cts:element-value-query(xs:QName('usergroupcompany:group_id'),$userGroupData//usergroup:group_id/text()),
    cts:element-value-query(xs:QName('usergroupcompany:id'),$userData//user:id/text())
    )))
(:END: replacing with search with root node. Modified by Raveendra:)		  
		  
		  
let $loopData := for $item in $userGroupCompanyData
  let $response-obj := json:object()
  let $companyData :=attorney:getCompanyData($item//usergroupcompany:company_id/text())
  let $getFIRMSALIData := attorney:getFIRMS_ALI_XREF_RE($item//usergroupcompany:company_id/text())
 		
  let $aliFirmID := if(fn:not($getFIRMSALIData/firmsali:ALI_ID/text() ne 'null') or ($userGroupTypeData//usergrouptype:group_type eq 2))
    then $item//usergroupcompany:company_id/text()
    else $getFIRMSALIData/firmsali:ALI_ID/text()
  
  let $firmName := if(($getFIRMSALIData/firmsali:ALI_NAME eq '') or ($getFIRMSALIData/firmsali:ALI_NAME eq 'null'))
    then 
      if(($getFIRMSALIData/firmsali:ALI_NAME eq '') and ($userGroupTypeData/usergrouptype:group_type eq "1"))
        then $companyData/company:company/text()
      else
        if(($userGroupTypeData/usergrouptype:group_type eq "1"))
          then $getFIRMSALIData/firmsali:ALI_NAME
          else 'NULL'
     else $getFIRMSALIData/firmsali:ALI_NAME
  
  let $FIRMNAME := if(firm:getOrganizationName($aliFirmID) ne '' or firm:getOrganizationName($aliFirmID) ne 'null')
    then firm:getOrganizationName($aliFirmID)
  else $firmName/text()  
  
  return if ($FIRMNAME ne 'null' or $FIRMNAME ne '') then
  let $_ := 
    (
    map:put($response-obj,'REFirmID',$item//usergroupcompany:company_id/text()),
    map:put($response-obj,'ALIFirmID',$aliFirmID),
    map:put($response-obj,'FirmName', $FIRMNAME),
    map:put($response-obj,'GroupType', $userGroupTypeData//usergrouptype:group_type/text()),
	map:put($response-obj,'Type', $userGroupTypeData//usergrouptype:group_type/text())
    )
    let $_ := json:array-push($response-array , $response-obj)
    return ()
   else ()
return $response-array
};

declare function attorney:getUserGroupData1($id,$groupID)
{
  let $result := cts:search(/user_groups,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/user_groups/'),
                        cts:element-value-query(xs:QName('usergroup:id'),$id),
						cts:element-value-query(xs:QName('usergroup:group_id'),$groupID)
                      )))
   return $result
};

declare function attorney:GetFirmDefaultWatchList($userEmail)
{
  let $response-array := json:array()
  let $userData := cts:search(/users,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/users/'),
                        cts:element-value-query(xs:QName('user:email'),$userEmail)
                      )))
  let $listCount := fn:count($userData)
  let $loopData := for $item in $userData
                       let $response-obj := json:object()
                       let $userGroupData := attorney:getUserGroupData($item/user:id/text())
                       let $userGroupTypeData := attorney:getUserGroupTypeData($userGroupData/usergroup:group_id/text() ,$item/user:id/text())
                       let $flagDefault := if($userGroupData/usergroup:flg_default/text() eq 'Y') then 1 else 0
                       let $_ := (map:put($response-obj,'USERWATCHLISTDETAILSID',0),
                                  map:put($response-obj,'WatchlistID',$userGroupData/usergroup:group_id/text()),
                                  map:put($response-obj,'WatchlistName',$userGroupData/usergroup:group_name/text()),
                                  map:put($response-obj,'Firms',''),
                                  map:put($response-obj,'UserID',$item/user:id/text()),
                                  map:put($response-obj,'UserEmail',$item/user:email/text()),
                                  map:put($response-obj,'IsDefault',$flagDefault),
                                  map:put($response-obj,'WatchlistType', $userGroupTypeData/usergrouptype:group_type/text()),
                                  map:put($response-obj,'ListCount', $listCount)
                                  )
                       let $_ := json:array-push($response-array , $response-obj)
                       return ()
   return $response-array 
};

declare function attorney:getUserGroupData($id)
{
  let $result := cts:search(/user_groups,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/user_groups/'),
                        cts:element-value-query(xs:QName('usergroup:id'),$id),
                        cts:element-value-query(xs:QName('usergroup:flg_default'),'Y')
                      )))
   return $result
};

declare function attorney:getUserGroupTypeData($groupID , $userId)
{
    let $result := cts:search(/user_group_type,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/user_group_type/'),
                        cts:element-value-query(xs:QName('usergrouptype:user_Id'),$userId),
                        cts:element-value-query(xs:QName('usergrouptype:group_Id'),$groupID)
                      )))
                       return $result
};

declare function attorney:getUserGroupCompanyData($groupID , $id)
{
    let $result := cts:search(/user_group_companies,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/user_group_companies/'),
                        cts:element-value-query(xs:QName('usergroupcompany:group_id'),$groupID),
                        cts:element-value-query(xs:QName('usergroupcompany:id'),$id)
                      )))
   return $result
};

declare function attorney:getCompanyData($companyID)
{
  let $result := cts:search(/company,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/company/'),
                        cts:element-value-query(xs:QName('company:company_id'),$companyID)
                      )))[1 to 10]
  return $result
};

declare function attorney:getFIRMS_ALI_XREF_RE($companyID)
{
  let $result := cts:search(/FIRMS_ALI_XREF_RE,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/FIRMS_ALI_XREF_RE/'),
                        cts:element-value-query(xs:QName('firmsali:RE_ID'),$companyID)
                      )))
  return $result
};

declare function attorney:getUsStates($admissions)
{
   let $a :=  cts:search(/,
                             cts:and-query((
                                   cts:directory-query('/LegalCompass/denormalized-data/US_STATE_ABBREVIATION/'),
                                   cts:element-value-query(xs:QName('usstates:Abbreviation'),fn:tokenize($admissions,';'))
                               )))//usstates:US_State/text()
  return $a
};

declare function attorney:sp_GetAttorneys1($cities,$countries,$geoGraphicRegion,$usRegions,$title,$firm,$practiceArea,$fromYear,$toYear,$searchKeyword,$attorneyName,$lawSchoolName,$PageNo,$PageSize,$SortBy,$SortDirection,$admissions)
{
   let $admission := if($admissions ne '') then attorney:getUsStates($admissions) else()
   let $stdLocation :=if($cities ne '' or $countries ne '' or $geoGraphicRegion ne '' or $usRegions ne '') then attorney:getStandardLocations($cities,$countries,$geoGraphicRegion,$usRegions) else ()
   let $result := attorney:getAttorneyData($stdLocation,$title,$firm,$practiceArea ,$fromYear,$toYear,$searchKeyword,$attorneyName,$lawSchoolName,$PageNo,$PageSize,$SortBy,$SortDirection,$admission)
   return $result
};

declare function attorney:getStandardLocations($cities,$countries,$geoGraphicRegion,$usRegions)
{
  let $result := cts:search(/,
                     cts:and-query((
                       cts:directory-query('/LegalCompass/relational-data/city/'),
                       if($cities ne '') then cts:element-value-query(xs:QName('cityns:city'),fn:tokenize($cities,',')) else(),
                       if($countries ne '') then cts:element-value-query(xs:QName('cityns:country'),fn:tokenize($countries,',')) else(),
                       if($geoGraphicRegion ne '') then cts:element-value-query(xs:QName('cityns:geographic_region'),fn:tokenize($geoGraphicRegion,',')) else(),
                       if($usRegions ne '') then cts:element-value-query(xs:QName('cityns:us_region'),fn:tokenize($usRegions,',')) else()
                       )))
  return fn:string-join($result//cityns:std_loc/text(),'|')
};

declare function attorney:getAttorneyData($stdLocation,$title,$firm,$practiceArea ,$fromYear,$toYear,$searchKeyword,$attorneyName,$lawSchoolName,$PageNo,$PageSize,$SortBy,$SortDirection,$admission)
{
  let $res-array :=json:array()
  let $res-array :=json:array()
  (:---------------Tokenize---------------:)
  let $stdLocations :=if($stdLocation ne '') then fn:tokenize($stdLocation,'[|]') else()
  let $titles := if($title ne '') then fn:tokenize($title,',') else()
  let $firms := if($firm ne '') then fn:tokenize($firm,',') else()
  let $practiceAreas := if($practiceArea ne '') then fn:tokenize($practiceArea , '[|]') else()
  let $lawSchoolNames :=if($lawSchoolName ne '') then fn:tokenize($lawSchoolName , ',') else()
  let $attName := if($attorneyName ne '') then fn:concat('*',$attorneyName,'*') else()
  (:--------------END---------------------:)
  
  (:-------------PageSize Declaration----------:)
  let $fromRecord := if($PageNo ne '1') then (xs:int($PageNo)-1)*xs:int($PageSize) else 1
  let $toRecord := xs:int($PageSize)*xs:int($PageNo)
  let $direction := if($SortDirection eq 'asc') then 'ascending' else 'descending'
  let $orderBy1 :=cts:index-order(cts:element-reference(xs:QName('aliattorneydata:attorney_name')) ,$direction)
  let $orderBy :=if($SortBy eq 'AttorneyName') then cts:index-order(cts:element-reference(xs:QName('aliattorneydata:attorney_name')) ,$direction)
                 else if($SortBy eq 'FirmName') then cts:index-order(cts:element-reference(xs:QName('aliattorneydata:firm_name')) ,$direction)
                       else if($SortBy eq 'FirmLink') then cts:index-order(cts:element-reference(xs:QName('aliattorneydata:attorney_link')) ,$direction)
                             else if($SortBy eq 'Title') then cts:index-order(cts:element-reference(xs:QName('aliattorneydata:title')) ,$direction)
                                  else if($SortBy eq 'Location') then cts:index-order(cts:element-reference(xs:QName('aliattorneydata:location')) ,$direction)
                                        else cts:index-order(cts:element-reference(xs:QName('companyatt:FIRMNAME')) ,$direction)
  
  (:xdmp:estimate giving wrong result, so replacing with fn:count:)
  let $totalCount := xdmp:estimate(cts:search(/,
                     cts:and-query((
                       cts:or-query((
                       cts:directory-query('/LegalCompass/denormalized-data/ALI_RE_Attorney_Data/'),
                       cts:directory-query('/LegalCompass/relational-data/COMPANY-ATTORNEYS/')
                       )),
                       if($stdLocation ne '') then cts:or-query((cts:element-value-query(xs:QName('aliattorneydata:location'),$stdLocations),
											cts:element-value-query(xs:QName('companyatt:LOCATION'),$stdLocations))) else (),
					   (:if($stdLocation ne '') then cts:element-value-query(xs:QName('aliattorneydata:location'),$stdLocations) else(),:)
											
                       if($title ne '') then cts:or-query((cts:element-word-query(xs:QName('aliattorneydata:title'),$titles,('wildcarded')),
											 cts:element-word-query(xs:QName('companyatt:TITLE'),$titles,('wildcarded')))) else(),
											 
						if($practiceArea ne '') then cts:element-word-query(xs:QName('aliattorneydata:practices'),$practiceAreas,('wildcarded')) else(),					 
					   (:if($practiceArea ne '') then cts:or-query((cts:element-word-query(xs:QName('aliattorneydata:practices'),$practiceAreas,('wildcarded')),
													cts:element-word-query(xs:QName('companyatt:PRACTICES'),$practiceAreas,('wildcarded')))) else(),:)
                       if($firm ne '') then  cts:or-query((cts:element-value-query(xs:QName('aliattorneydata:ALI_ID'),$firms),
											 cts:element-value-query(xs:QName('companyatt:FIRMID'),$firms))) else(),
                       if($fromYear ne '' and $toYear ne '') then cts:or-query((
								  cts:and-query((
                                  cts:element-range-query(xs:QName('aliattorneydata:searchable_graduation_year'),'>=',xs:decimal($fromYear)),
                                  cts:element-range-query(xs:QName('aliattorneydata:searchable_graduation_year'),'<=',xs:decimal($toYear)),
                                  cts:not-query(cts:element-value-query(xs:QName('aliattorneydata:searchable_graduation_year'),''))))))
								 else(),
                       if($searchKeyword ne '') then cts:or-query((cts:element-word-query(xs:QName('aliattorneydata:keywords'),$searchKeyword,("wildcarded","case-insensitive")),
												cts:element-word-query(xs:QName('companyatt:KEYWORDS'),$searchKeyword,("wildcarded","case-insensitive")))) else(),
                       if($attorneyName ne '') then cts:or-query((cts:element-word-query(xs:QName('aliattorneydata:attorney_name'),$attorneyName,('wildcarded','case-insensitive')),
													cts:element-word-query(xs:QName('companyatt:ATTORNEY_NAME'),$attorneyName,('wildcarded','case-insensitive'))))else(),
                       if($lawSchoolName ne '') then cts:or-query((cts:element-word-query(xs:QName('aliattorneydata:education'),$lawSchoolName,('wildcarded','case-insensitive')),
													 cts:element-word-query(xs:QName('companyatt:EDUCATION'),$lawSchoolName,('wildcarded','case-insensitive'))))else(),
                       if($attorneyName ne '') then cts:not-query(cts:element-value-query(xs:QName('aliattorneydata:attorney_name'),'')) else(),
					   if($admission ne '') then  cts:or-query((cts:element-word-query(xs:QName('aliattorneydata:admission'),$admission,("wildcarded","case-insensitive")),
																cts:element-word-query(xs:QName('aliattorneydata:Addmission'),$admission,("wildcarded","case-insensitive")))) else()
                       ))))
  let $result := cts:search(/,
                    cts:and-query((
                       cts:or-query((
                       cts:directory-query('/LegalCompass/denormalized-data/ALI_RE_Attorney_Data/'),
                       cts:directory-query('/LegalCompass/relational-data/COMPANY-ATTORNEYS/')
                       )),
                       if($stdLocation ne '') then cts:or-query((cts:element-value-query(xs:QName('aliattorneydata:location'),$stdLocations),
											cts:element-value-query(xs:QName('companyatt:LOCATION'),$stdLocations))) else (),
                       if($title ne '') then cts:or-query((cts:element-value-query(xs:QName('aliattorneydata:title'),$titles),
											 cts:element-value-query(xs:QName('companyatt:TITLE'),$titles))) else(),
					   if($practiceArea ne '') then cts:or-query((cts:element-word-query(xs:QName('aliattorneydata:practices'),$practiceAreas,('wildcarded')),
													cts:element-word-query(xs:QName('companyatt:PRACTICES'),$practiceAreas,('wildcarded')))) else(),
                       if($firm ne '') then  cts:or-query((cts:element-value-query(xs:QName('aliattorneydata:ALI_ID'),$firms),
											 cts:element-value-query(xs:QName('companyatt:FIRMID'),$firms))) else(),
                       if($fromYear ne '' and $toYear ne '') then cts:and-query((
								
                                  cts:element-range-query(xs:QName('aliattorneydata:searchable_graduation_year'),'>=',xs:integer($fromYear)),
                                  cts:element-range-query(xs:QName('aliattorneydata:searchable_graduation_year'),'<=',xs:integer($toYear)),
                                  cts:not-query(cts:element-value-query(xs:QName('aliattorneydata:searchable_graduation_year'),''))))
								 else(),
                       if($searchKeyword ne '') then cts:or-query((cts:element-word-query(xs:QName('aliattorneydata:keywords'),$searchKeyword,("wildcarded","case-insensitive")),
												cts:element-word-query(xs:QName('companyatt:KEYWORDS'),$searchKeyword,("wildcarded","case-insensitive")))) else(),
                       if($attorneyName ne '') then cts:or-query((cts:element-word-query(xs:QName('aliattorneydata:attorney_name'),$attName,("wildcarded","case-insensitive")),
													cts:element-word-query(xs:QName('companyatt:ATTORNEY_NAME'),$attName,("wildcarded","case-insensitive"))))else(),
                       if($lawSchoolName ne '') then cts:or-query((cts:element-word-query(xs:QName('aliattorneydata:education'),$lawSchoolName,('wildcarded','case-insensitive')),
													 cts:element-word-query(xs:QName('companyatt:EDUCATION'),$lawSchoolName,('wildcarded','case-insensitive'))))else(),
                       if($attorneyName ne '') then cts:not-query(cts:element-value-query(xs:QName('aliattorneydata:attorney_name'),'')) else(),
					   if($admission ne '') then  cts:or-query((cts:element-word-query(xs:QName('aliattorneydata:admission'),$admission,("wildcarded","case-insensitive")),
																cts:element-word-query(xs:QName('aliattorneydata:Addmission'),$admission,("wildcarded","case-insensitive"))))else()
                       )),$orderBy)[xs:int($fromRecord) to xs:int($toRecord)]
                       
  let $loopData := for $item in $result
                       let $res-obj := json:object()
					   let $firmName := if($item//aliattorneydata:ALM_NAME/text() ne '' ) then $item//aliattorneydata:ALM_NAME/text() else $item//aliattorneydata:firm_name/text()
                       let $_ := (map:put($res-obj,'AttorneyName',if($item//aliattorneydata:attorney_name/text() ne '') then $item//aliattorneydata:attorney_name/text() else 											 $item//companyatt:ATTORNEY_NAME/text()),
								  map:put($res-obj,'ID',if($item//aliattorneydata:attorney_id/text() ne '') then $item//aliattorneydata:attorney_id/text() else 
															0 ),
                                  map:put($res-obj,'AttorneyProfileLink',if($item//aliattorneydata:attorney_link/text() ne '') then $item//aliattorneydata:attorney_link/text() else
															$item//companyatt:ATTORNEYPROFILELINK/text()),
                                  map:put($res-obj,'FirmID',if($item//aliattorneydata:ALI_ID/text() ne '') then $item//aliattorneydata:ALI_ID/text() else
																$item//companyatt:FIRMID/text()),
                                  map:put($res-obj,'FirmName',if($firmName ne '' ) then $firmName else $item//companyatt:FIRMNAME/text()),
                                  map:put($res-obj,'FirmLink',$item//aliattorneydata:firm_link/text()),
                                  map:put($res-obj,'Title',if($item//aliattorneydata:title/text() ne '') then $item//aliattorneydata:title/text() else
															  $item//companyatt:TITLE/text()),
                                  map:put($res-obj,'Location',if($item//aliattorneydata:location/text() ne '') then $item//aliattorneydata:location/text() else 
																$item//companyatt:LOCATION/text()),
                                  map:put($res-obj,'Practices',if($item//aliattorneydata:practices/text() ne '') then $item//aliattorneydata:practices/text() else	
																  $item//companyatt:PRACTICES/text()),
                                  map:put($res-obj,'Education',if($item//aliattorneydata:education/text() ne '') then $item//aliattorneydata:education/text() else
																$item//companyatt:EDUCATION/text()),
                                  map:put($res-obj,'Addmission',if($item//aliattorneydata:admission/text() ne '') then $item//aliattorneydata:admission/text() else
																$item//companyatt:ADDMISSION/text()),
                                  map:put($res-obj,'Keywords',if($item//aliattorneydata:keywords/text() ne '') then $item//aliattorneydata:keywords/text() else
																$item//companyatt:KEYWORDS/text()),
                                  map:put($res-obj,'PhoneNo',if($item//aliattorneydata:PhoneNo/text() ne '') then $item//aliattorneydata:PhoneNo/text() else 
																$item//companyatt:PHONENO/text()),
                                  map:put($res-obj,'Email',if($item//aliattorneydata:Email/text() ne '') then $item//aliattorneydata:Email/text() else
																$item//companyatt:EMAIL/text()),
                                  map:put($res-obj,'TotalCount',$totalCount)
                                   )
                      let $_ := json:array-push($res-array,$res-obj)
                      return()
   return $res-array

};

declare function attorney:GetLawfirmProfileOverview($orgID)
{
  let $res-array :=json:array()
  let $result :=cts:search(/,
                  cts:and-query((
                    cts:directory-query('/LegalCompass/relational-data/organization/'),
                    cts:element-value-query(xs:QName('organizations:ORGANIZATION_ID'),$orgID)
                  )))[1 to 10]
 
  let $loopData := for $item in $result
                       let $amlaw200Data := attorney:AMLaw200($orgID)
                       let $global100Data := attorney:Global100($orgID)
                       let $nlj250Data :=attorney:NLJ250($orgID)
                       let $organizationAddress := attorney:getOrganizationAddress($orgID)
                       
                       let $orgName := if($item//organizations:ALM_NAME/text() ne '') then $item//organizations:ALM_NAME/text()
                                       else $item//organizations:ORGANIZATION_NAME/text()
                       let $website := if($item//organizations:WEBSITE/text() ne '') then $item//organizations:WEBSITE/text()
                                       else $organizationAddress//organizationaddress:WEBSITE/text()
                       let $headQuarter :=fn:concat(fn:concat($organizationAddress//organizationaddress:CITY/text(),''),$organizationAddress//organizationaddress:STATE/text())
                       let $totalRevenue :=if($amlaw200Data//amlaw200:GROSS_REVENUE/text() ne '') then $amlaw200Data//amlaw200:GROSS_REVENUE/text()
                                           else $global100Data//global100:GROSS_REVENUE/text()
                       let $revenueperlawyer := if($amlaw200Data//amlaw200:RPL/text() ne '') then $amlaw200Data//amlaw200:RPL/text()
                                                else $global100Data//global100:REVENUE_PER_LAWYER/text()
                       let $profileP := if($amlaw200Data//amlaw200:PPP/text() ne '') then $amlaw200Data//amlaw200:PPP/text()
                                                else $global100Data//global100:PPP/text()
                       
                       let $totalHeadCount := if($amlaw200Data//amlaw200:NUM_OF_LAWYERS/text() ne '') then $amlaw200Data//amlaw200:NUM_OF_LAWYERS/text()
                                                else $nlj250Data//nlj250:NUM_ATTORNEYS/text()

                       let $equityPartner := if($amlaw200Data//amlaw200:NUM_EQ_PARTNERS/text() ne '') then $amlaw200Data//amlaw200:NUM_EQ_PARTNERSPPP/text()
                                                else $nlj250Data//nlj250:EQUITY_PARTNERS/text()

                       let $nonEquityPartner := if($amlaw200Data//amlaw200:NUM_NON_EQ_PARTNERS/text() ne '') then $amlaw200Data//amlaw200:NUM_NON_EQ_PARTNERS/text()
                                                else $nlj250Data//nlj250:NUM_NE_PARTNERS/text()

                       let $res-obj := json:object()
                       let $_ := (map:put($res-obj,'ORGANIZATION_NAME',$orgName),
                                  map:put($res-obj,'ORGANIZATION_ID',$item//organizations:ORGANIZATION_ID/text()),
                                  map:put($res-obj,'ADDITIONAL_INFORMATION',$item//organizations:ADDITIONAL_INFORMATION/text()),
                                  map:put($res-obj,'website',$website),
                                  map:put($res-obj,'TotalRevenueYear',$amlaw200Data//amlaw200:PUBLISHYEAR/text()),
                                  map:put($res-obj,'MAIN_PHONE',$organizationAddress//organizationaddress:MAIN_PHONE/text()),
                                  map:put($res-obj,'email',$organizationAddress//organizationaddress:EMAIL/text()),
                                  map:put($res-obj,'CITY',$organizationAddress//organizationaddress:CITY/text()),
                                  map:put($res-obj,'STATE',$organizationAddress//organizationaddress:STATE/text()),
                                  map:put($res-obj,'ZIP',$organizationAddress//organizationaddress:ZIP/text()),
                                  map:put($res-obj,'ADDRESS1',$organizationAddress//organizationaddress:ADDRESS1/text()),
                                  map:put($res-obj,'ADDRESS2',$organizationAddress//organizationaddress:ADDRESS2/text()),
                                  map:put($res-obj,'COUNTRY',$organizationAddress//organizationaddress:COUNTRY/text()),
                                  map:put($res-obj,'HeadQuater',$headQuarter),
                                  map:put($res-obj,'FAX',$organizationAddress//organizationaddress:FAX/text()),
                                  map:put($res-obj,'GlobalRank',$global100Data//global100:RANK_BY_GROSS_REVENUE/text()),
                                  map:put($res-obj,'TotalHeadcount',$totalHeadCount),
                                  map:put($res-obj,'EquityPartner',$equityPartner),
                                  map:put($res-obj,'NonEquityPartner',$nonEquityPartner),
                                  map:put($res-obj,'Associate',$nlj250Data//nlj250:NUM_ASSOCIATES/text()),
                                  map:put($res-obj,'TotalRevenue',$totalRevenue),
                                  map:put($res-obj,'RevenuePerLawyer',$revenueperlawyer),
                                  map:put($res-obj,'ProfitPerPartner',$profileP),
                                  map:put($res-obj,'OrgAddress',$organizationAddress),
                                  map:put($res-obj,'Organization_Profile',$item//organizations:ORGANIZATION_PROFILE/text()),
                                  map:put($res-obj,'MansfieldruleStatus',$item//organizations:MANSFIELD_RULE_STATUS/text()),
                                  map:put($res-obj,'MANSFIELD_RULE_STATUS',$item//organizations:MANSFIELD_RULE_STATUS/text())
                                 )
                       let $_ := json:array-push($res-array,$res-obj)
                       return()
  return $res-array
  
};

declare function attorney:GetLawfirmProfileOverview1($orgID)
{
  let $res-array :=json:array()
  let $result :=cts:search(/,
                  cts:and-query((
                    cts:directory-query('/LegalCompass/relational-data/organization/'),
                    cts:element-value-query(xs:QName('organizations:ORGANIZATION_ID'),$orgID)
                  )))
 
  let $loopData := for $item in $result
                       let $amlaw200Data := attorney:AMLaw200($orgID)
                       let $global100Data := attorney:Global100($orgID)
                       let $nlj250Data :=attorney:NLJ250($orgID)
                       
                       let $orgName := if($item//organizations:ALM_NAME/text() ne '') then $item//organizations:ALM_NAME/text()
                                       else $item//organizations:ORGANIZATION_NAME/text()
                       
                       let $totalRevenue :=if($amlaw200Data//amlaw200:GROSS_REVENUE/text() ne '') then $amlaw200Data//amlaw200:GROSS_REVENUE/text()
                                           else $global100Data//global100:GROSS_REVENUE/text()
                       let $revenueperlawyer := if($amlaw200Data//amlaw200:RPL/text() ne '') then $amlaw200Data//amlaw200:RPL/text()
                                                else $global100Data//global100:REVENUE_PER_LAWYER/text()
                       let $profileP := if($amlaw200Data//amlaw200:PPP/text() ne '') then $amlaw200Data//amlaw200:PPP/text()
                                                else $global100Data//global100:PPP/text()
                       
                       let $res-obj := json:object()
                       let $_ := (map:put($res-obj,'ORGANIZATION_NAME',$orgName),
                                  map:put($res-obj,'ORGANIZATION_ID',$item//organizations:ORGANIZATION_ID/text()),
                                  map:put($res-obj,'Organization_Profile',$item//organizations:ORGANIZATION_PROFILE/text()),
                                  map:put($res-obj,'ADDITIONAL_INFORMATION',$item//organizations:ADDITIONAL_INFORMATION/text()),
                                  map:put($res-obj,'website',$item//organizations:WEBSITE/text()),
                                  map:put($res-obj,'TotalRevenueYear',$amlaw200Data//amlaw200:PUBLISHYEAR/text()),
                                  map:put($res-obj,'HeadQuater',$item//organizations:HEADQUARTERS/text()),
                                  map:put($res-obj,'GlobalRank',$global100Data//global100:RANK_BY_GROSS_REVENUE/text()),
                                  map:put($res-obj,'TotalHeadcount',$nlj250Data//nlj250:NUM_ATTORNEYS/text()),
                                  map:put($res-obj,'EquityPartner',$nlj250Data//nlj250:EQUITY_PARTNERS/text()),
                                  map:put($res-obj,'NonEquityPartner',$nlj250Data//nlj250:NUM_NE_PARTNERS/text()),
                                  map:put($res-obj,'Associate',$nlj250Data//nlj250:NUM_ASSOCIATES/text()),
                                  map:put($res-obj,'TotalRevenue',$totalRevenue),
                                  map:put($res-obj,'RevenuePerLawyer',$revenueperlawyer),
                                  map:put($res-obj,'ProfitPerPartner',$profileP),
                                  map:put($res-obj,'MansfieldruleStatus',$item//organizations:MANSFIELD_RULE_STATUS/text()),
                                  map:put($res-obj,'MANSFIELD_RULE_STATUS',$item//organizations:MANSFIELD_RULE_STATUS/text())
                                 )
                       let $_ := json:array-push($res-array,$res-obj)
                       return()
  return $res-array
  
};

declare function attorney:IsNonAMLawFirm($orgID)
{
  let $maxYear := cts:search(/,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/')
                      )))//amlaw200:PUBLISHYEAR
                      
  let $result :=cts:search(/,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
                        cts:element-value-query(xs:QName('amlaw200:PUBLISHYEAR'),xs:string(max($maxYear))),
                        cts:element-value-query(xs:QName('amlaw200:ORGANIZATION_ID'),$orgID),
						cts:element-value-query(xs:QName('amlaw200:AMLAW200_RANK'),'')
                      )))[1]
  return $result//amlaw200:ORGANIZATION_ID/text()
};

declare function attorney:GetREIDByOrgID($orgID)
{
  let $result := cts:search(/,
                   cts:and-query((
                     cts:directory-query('/LegalCompass/relational-data/FIRMS_ALI_XREF_RE/'),
                     cts:element-value-query(xs:QName('fimrsali:ALI_ID'),$orgID)
                   )))[1]//fimrsali:RE_ID/text()
  return $result
};

declare function attorney:sp_GetAttorneyDetail($attorneyID,$orgID)
{
  let $res-array := json:array()
  let $result :=cts:search(/,
                  cts:and-query((
                    cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/'),
                    cts:element-value-query(xs:QName('tblrer:attorney_id'),$attorneyID),
                    cts:element-value-query(xs:QName('tblrer:firm_id'),$orgID)
                    
                  )))
   let $loopData := for $item in $result
                        let $res-object := json:object()
                        let $peopleData := cts:search(/,
                                                cts:and-query((
                                                  cts:directory-query('/LegalCompass/denormalized-data/person/'),
                                                  cts:element-value-query(xs:QName('people:person_id'),$item//tblrer:attorney_id/text()),
                                                  cts:element-value-query(xs:QName('tblrer:firm_id'),$orgID)
                                                )))
                        let $_ :=(map:put($res-object,'AttorneyID',$item//tblrer:attorney_id/text()),
                                  map:put($res-object,'AttorneyName',$item//tblrer:attorney_name/text()),
                                  map:put($res-object,'AttorneyURL',$item//tblrer:attorney_link/text()),
                                  map:put($res-object,'AttorneyTitle',$item//tblrer:title/text()),
                                  map:put($res-object,'AttorneyLocation',$item//tblrer:location/text()),
                                  map:put($res-object,'AttorneyPhone',fn:tokenize($item//tblrer:contactinfo/text(),';')[1]),
                                  map:put($res-object,'AttorneyEmail',fn:tokenize($item//tblrer:contactinfo/text(),';')[2]),
                                  map:put($res-object,'AttorneyDescription',$item//tblrer:keywords/text()))
                       let $_ := json:array-push($res-array,$res-object)
                       return()
   return $res-array
};

declare function attorney:getOrganizationAddress($orgID)
{
  let $result :=cts:search(/,
                    cts:and-query((
                      cts:directory-query('/LegalCompass/relational-data/organization-address/'),
                      cts:element-value-query(xs:QName('organizationaddress:ORGANIZATION_ID'),$orgID),
                      cts:element-value-query(xs:QName('organizationaddress:HEADQUARTERS'),'H','case-insensitive')
                    )))[1]
  return $result
  
};

declare function attorney:AMLaw200($orgID)
{
  let $maxYear := cts:search(/,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/')
                      )))//amlaw200:PUBLISHYEAR
                      
  let $result :=cts:search(/,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
                        cts:element-value-query(xs:QName('amlaw200:PUBLISHYEAR'),xs:string(max($maxYear))),
                        cts:element-value-query(xs:QName('amlaw200:ORGANIZATION_ID'),$orgID)
                      )))[1]
  return $result
};

declare function attorney:Global100($orgID)
{
  let $maxYear := cts:search(/,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/surveys/Global_100/')
                      )))//global100:PUBLISHYEAR
                      
  let $result :=cts:search(/,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/surveys/Global_100/'),
                        cts:element-value-query(xs:QName('global100:PUBLISHYEAR'),xs:string(max($maxYear))),
                        cts:element-value-query(xs:QName('global100:ORGANIZATION_ID'),$orgID)
                      )))[1]
  return $result
};

declare function attorney:NLJ250($orgID)
{
  let $maxYear := cts:search(/,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/surveys/NLJ_250/')
                      )))//nlj250:PUBLISHYEAR
                      
  let $result :=cts:search(/,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/surveys/NLJ_250/'),
                        cts:element-value-query(xs:QName('nlj250:PUBLISHYEAR'),xs:string(max($maxYear))),
                        cts:element-value-query(xs:QName('nlj250:ORGANIZATION_ID'),$orgID)
                      )))[1]
  return $result
};

declare function attorney:GetTimelineEventsFromALI($name)
{
    let $res-array := json:array()
    let $result := cts:search(/,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/surveys/Lateral_Partner/'),
                        cts:element-value-query(xs:QName('lateralpartner:FIRST_NAME'),fn:concat('*',$name,'*'),'wildcarded'),
                        cts:element-value-query(xs:QName('lateralpartner:MIDDLE_NAME'),fn:concat('*',$name,'*'),'wildcarded'),
                        cts:element-value-query(xs:QName('lateralpartner:LAST_NAME'),fn:concat('*',$name,'*'),'wildcarded')
                      )))
                      
   let $loopData := for $item in $result
                        let $res-object := json:object()
                        let $_ :=(map:put($res-object,'Year',$item//lateralpartner:FISCAL_YEAR/text()),
                                  map:put($res-object,'Organisation',$item//lateralpartner:ORGANIZATION_NAME_JOINED/text()),
                                  map:put($res-object,'Title',$item//lateralpartner:POSITION_JOINED/text()))
                       let $_ := json:array-push($res-array,$res-object)
                       return()
  return $result
};

declare function attorney:GetTimelineEventsFromRE($attorneyID)
{
  let $res-array := json:array()
  let $maxDate :=cts:search(/,
                  cts:and-query((
                    cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/'),
					cts:element-value-query(xs:QName('tblrermovechanges:attorney_id'),$attorneyID)
                  )))
				  
  let $dates :=$maxDate//tblrermovechanges:last_action_date
  let $maxDate1 := max(for $date in $dates  return xs:date($date))
  
  let $result :=cts:search(/,
                  cts:and-query((
                    cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES/'),
					cts:element-value-query(xs:QName('tblrermovechanges:attorney_id'),$attorneyID),
					cts:element-value-query(xs:QName('tblrermovechanges:last_action_date'), xs:string($maxDate1))
                  )))
   let $loopData := for $item in $result
                        let $res-object := json:object()
                        let $_ :=(map:put($res-object,'Year',fn:year-from-date(xs:date($item//tblrermovechanges:last_action_date/text()))),
                                  map:put($res-object,'Organisation',$item//tblrermovechanges:firm_name/text()),
                                  map:put($res-object,'Title',$item//tblrermovechanges:title/text()))
                       let $_ := json:array-push($res-array,$res-object)
                       return()
   return $res-array
};

declare function attorney:GetTimelineEvents2FromRE($attorneyID)
{
  let $result :=cts:search(/,
                  cts:and-query((
                    cts:directory-query('/LegalCompass/relational-data/people_detail_text/'),
                    cts:element-value-query(xs:QName('peopledetailtext:person_id'),$attorneyID)
                  )))
 let $eductaion := fn:concat(fn:concat(fn:concat(fn:concat($result//peopledetailtext:school/text(),','),fn:concat($result//peopledetailtext:degree/text(),',')),$result//peopledetailtext:year/text()),';')
 let $res-object := json:object()
 let $_ :=(map:put($res-object,'Education',$eductaion))
                     
 return $res-object             
};

declare function attorney:GetRecentClients($name,$email,$phone)
{
  let $names := fn:tokenize($name,' ')
  let $res-array := json:array()
  let $result :=cts:search(/,
                  cts:and-query((
                    cts:directory-query('/LegalCompass/relational-data/ATTORNEYCASES/'),
                    cts:element-value-query(xs:QName('attorneycases:COUNSEL_EMAIL'),$email,'case-insensitive'),
                    cts:not-query(cts:element-value-query(xs:QName('attorneycases:COUNSEL_NAME'),'')),
                    if($name ne '') then cts:element-word-query(xs:QName('attorneycases:COUNSEL_NAME'),$names,("wildcarded","case-insensitive")) else()
                  )))
   let $loopData := for $item in $result
                        let $res-object := json:object()
                        let $_ :=(map:put($res-object,'ClientName',$item//attorneycases:PARTY_NAME/text()),
                                  map:put($res-object,'LastEngagment',$item//attorneycases:CASEFILEDATE/text()),
                                  map:put($res-object,'MatterHandled',$item//attorneycases:CASE_NAME/text()),
                                  map:put($res-object,'Source','Pacer'))
                       let $_ := json:array-push($res-array,$res-object)
                       return()
   return $res-array
};

declare function attorney:GetPractiseConcentration($name,$email,$phone)
{
  let $names := fn:tokenize($name,' ')
  let $res-array := json:array()
  let $totalCount := xdmp:estimate(cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/ATTORNEYCASES/'),
							cts:element-value-query(xs:QName('attorneycases:COUNSEL_EMAIL'),$email,'case-insensitive'),
							cts:not-query(cts:element-value-query(xs:QName('attorneycases:COUNSEL_NAME'),'')),
							if($name ne '') then cts:element-word-query(xs:QName('attorneycases:COUNSEL_NAME'),$names,("wildcarded","case-insensitive")) else()
						  ))))
  let $representations :=fn:distinct-values(cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/ATTORNEYCASES/'),
							cts:element-value-query(xs:QName('attorneycases:COUNSEL_EMAIL'),$email,'case-insensitive'),
							cts:not-query(cts:element-value-query(xs:QName('attorneycases:COUNSEL_NAME'),'')),
							if($name ne '') then cts:element-word-query(xs:QName('attorneycases:COUNSEL_NAME'),$names,("wildcarded","case-insensitive")) else()
						  )))//attorneycases:TYPE_OF_REPRESENTATIONS/text())
  
   let $loopData := for $item in $representations
					    let $totalCount :=xdmp:estimate(cts:search(/,
												cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/ATTORNEYCASES/'),
													cts:element-value-query(xs:QName('attorneycases:COUNSEL_EMAIL'),$email,'case-insensitive'),
													cts:not-query(cts:element-value-query(xs:QName('attorneycases:COUNSEL_NAME'),'')),
													if($name ne '') then cts:element-word-query(xs:QName('attorneycases:COUNSEL_NAME'),$names,("wildcarded","case-insensitive")) else(),
													cts:element-value-query(xs:QName('attorneycases:TYPE_OF_REPRESENTATIONS'),$item)
												  ))))
                        let $res-object := json:object()
                        let $_ :=(map:put($res-object,'TypeOfRepresentations',$item),
                                  map:put($res-object,'Count',$totalCount))
                       let $_ := json:array-push($res-array,$res-object)
                       return()
   return $res-array
};

(:declare function attorney:GetSurveyOrganizations($tableName)
{
  let $response-array := json:array()
  let $result := if($tableName eq 'Am Law 100') then attorney:AMLaw100()
                 else if($tableName eq 'Am Law 200') then attorney:AMLaw200()
                       else if($tableName eq 'Global 100') then attorney:Global100()
                            else if($tableName eq 'NLJ 500') then attorney:NLJ250()
                                 else attorney:LCWatchList($tableName)
  let $loopData := for $item in $result
                       let $res-obj := json:object()
                       let $_ := (map:put($res-obj,'',$item))
                       let $_ := json:array-push($response-array,$item)
                       return()
  return $response-array 
};

declare function attorney:AMLaw100()
{
  let $maxYear := cts:search(/,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_100/')
                      )))//amlaw100:PUBLISHYEAR
                      
  let $result :=cts:search(/,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_100/'),
                        cts:element-value-query(xs:QName('amlaw100:PUBLISHYEAR'),xs:string(max($maxYear)))
                      )))
  return fn:distinct-values($result//amlaw100:ORGANIZATION_ID/text())
};

declare function attorney:AMLaw200()
{
  let $maxYear := cts:search(/,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/')
                      )))//amlaw200:PUBLISHYEAR
                      
  let $result :=cts:search(/,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
                        cts:element-value-query(xs:QName('amlaw200:PUBLISHYEAR'),xs:string(max($maxYear)))
                      )))
  return fn:distinct-values($result//amlaw200:ORGANIZATION_ID/text())
};

declare function attorney:Global100()
{
  let $maxYear := cts:search(/,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/surveys/Global_100/')
                      )))//global100:PUBLISHYEAR
                      
  let $result :=cts:search(/,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/surveys/Global_100/'),
                        cts:element-value-query(xs:QName('global100:PUBLISHYEAR'),xs:string(max($maxYear)))
                      )))
  return fn:distinct-values($result//global100:ORGANIZATION_ID/text())
};

declare function attorney:NLJ250()
{
  let $maxYear := cts:search(/,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/surveys/NLJ_250/')
                      )))//nlj250:PUBLISHYEAR
                      
  let $result :=cts:search(/,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/surveys/NLJ_250/'),
                        cts:element-value-query(xs:QName('nlj250:PUBLISHYEAR'),xs:string(max($maxYear)))
                      )))
  return fn:distinct-values($result//nlj250:ORGANIZATION_ID/text())
};

declare function attorney:LCWatchList($tableName)
{
  let $result :=cts:search(/,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/LC_WATCHLIST/'),
                        cts:element-value-query(xs:QName('lcwatchlist:WATCHLIST_NAME'),xs:string($tableName),'case-insenitive')
                         )))
  return $result 
};
:)

declare function attorney:sp_GetREFirmContactsAddedNew2(
	 $firmID
	,$lastAction
	,$fromDate
	,$toDate
	,$title
	,$practiceAreas
	,$attorneyName
	,$lawSchoolNames
	,$city
	,$state
	,$country
	,$geographicRegion
	,$usRegion
	,$sortBy
	,$sortDirection
	,$pageNo
	,$pageSize
  ,$genderType
  ,$isPrimaryPracticeArea
  ,$Keywords
)

{
  let $res-array := json:array()
  let $fromRecord := if($pageNo ne '1') then (xs:int($pageNo)-1)*xs:int($pageSize) else 1
  let $toRecord := xs:int($pageSize)*xs:int($pageNo)
  let $direction := if($sortDirection eq 'asc') then 'ascending' else 'descending'
  let $lawSchoolNm := fn:tokenize($lawSchoolNames,'[|]')

  let $isPrimaryPracticeArea := if($isPrimaryPracticeArea ne '') then $isPrimaryPracticeArea else 'false'
  
  let $gender := if(fn:contains($genderType,';')) then ('M','F','Male','Female') else if($genderType eq 'Male') then ('M','Male') else ('F','Female')

  let $firmIDs := if($firmID ne '') then fn:tokenize($firmID,',') else()
  let $action := if($lastAction ne '') then fn:tokenize($lastAction,',') else()
  let $titles := if($title ne '') then fn:tokenize($title,',') else()
  let $cities := if($city !='') then for $item in fn:tokenize($city,',')
							return fn:replace($item , '-',', ')
		else ()
  let $states := if($state ne '') then fn:tokenize($state,',') else()
  let $countries := if($country ne '') then fn:tokenize($country,',') else()
  let $geographicRegions := if($geographicRegion ne '') then fn:tokenize($geographicRegion,',') else()
  let $usRegions := if($usRegion != '') then 'USA' else()
  let $practiceArea := if($practiceAreas ne '') then fn:tokenize($practiceAreas,'[|]') else()
  (: let $attorneyName := if($attorneyName ne '') then fn:replace($attorneyName,'[+]|[*]','') else():)
  let $attorneyName := if($attorneyName ne '') then fn:replace($attorneyName,'[+]','') else()
  let $attorneyName := if($attorneyName ne '') then fn:replace($attorneyName,'[*]','') else()
  let $attName := if($attorneyName ne '') then fn:replace($attorneyName,',',' ') else()
  

  let $attCount := if($attName != '') then count($attName) else 0                  
  
  
  let $orderBy := if($sortBy eq 'FirmName') then cts:index-order(cts:element-reference(xs:QName('lateralmoves:Company_Name')) ,$direction)
                  else if($sortBy eq 'Action') then cts:index-order(cts:element-reference(xs:QName('lateralmoves:action')) ,$direction)
                       else if($sortBy eq 'Date') then cts:index-order(cts:element-reference(xs:QName('lateralmoves:date_added')) ,$direction)
                            else if($sortBy eq 'Name') then cts:index-order(cts:element-reference(xs:QName('lateralmoves:Attorney_Name')) ,$direction)
                                 else if($sortBy eq 'Title') then cts:index-order(cts:element-reference(xs:QName('lateralmoves:Title')) ,$direction)
                                      else if($sortBy eq 'PracticeArea') then cts:index-order(cts:element-reference(xs:QName('lateralmoves:practices')) ,$direction)
                                           else if($sortBy eq 'Location') then cts:index-order(cts:element-reference(xs:QName('lateralmoves:Location')) ,$direction)
                                              else if($sortBy eq 'PreTitle') then cts:index-order(cts:element-reference(xs:QName('lateralmoves:PreTitle')) ,$direction)
                                                else()

  let $keyword_q := if($Keywords !='') then
			
							if(fn:contains(fn:lower-case($Keywords),'and') and fn:not(fn:contains(fn:lower-case($Keywords),'"'))) then 
								 attorney:GetAndOperatorQueryLateral($Keywords)
													
							
							else if(fn:contains(fn:lower-case($Keywords),'or') and fn:not(fn:contains(fn:lower-case($Keywords),'"'))) then 
								 attorney:GetOrOperatorQueryLateral($Keywords)
													
							else if(fn:contains(fn:lower-case($Keywords),'"') and fn:contains(fn:lower-case($Keywords),'" or "')) then 
								 attorney:GetExactOrOperatorQueryLateral($Keywords)

              else if(fn:contains(fn:lower-case($Keywords),'"') and fn:contains(fn:lower-case($Keywords),' or ')) then 
								 attorney:GetExactOrOperatorQueryLateral($Keywords)   
										
							else if(fn:contains(fn:lower-case($Keywords),'"') and fn:contains(fn:lower-case($Keywords),'" and "')) then 
								 attorney:GetExactAndOperatorQueryLateral($Keywords)

              	else if(fn:contains(fn:lower-case($Keywords),'"') and fn:contains(fn:lower-case($Keywords),' and ')) then 
								 attorney:GetExactAndOperatorQueryLateral($Keywords)   			
										
							else if(fn:contains(fn:lower-case($Keywords),' or ') and fn:contains(fn:lower-case($Keywords),' and ')) then 
								 attorney:GetAndOrOperatorQueryLateral($Keywords)
							
							(:else if(fn:contains(fn:lower-case($Keywords),'"') and fn:not(fn:contains(fn:lower-case($Keywords),'" and "')) and fn:not(fn:contains(fn:lower-case($Keywords),'" or "'))) then 
								 event:GetExactAndOperatorQuery($Keywords)	:)
							
							else if(fn:contains($Keywords,',') and fn:not(fn:contains(fn:lower-case($Keywords),'"'))) then 
								   cts:or-query((
									cts:element-word-query(xs:QName('lateralmoves:edu'),fn:tokenize($Keywords,','),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('lateralmoves:detail_text'),fn:tokenize($Keywords,','),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('lateralmoves:practice_area'),fn:tokenize($Keywords,','),('wildcarded','case-insensitive'))
								))

								else if(fn:contains($Keywords,' ') and fn:not(fn:contains(fn:lower-case($Keywords),'"'))) then 
								   cts:or-query((
										cts:element-word-query(xs:QName('lateralmoves:edu'),fn:tokenize($Keywords,','),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('lateralmoves:detail_text'),fn:tokenize($Keywords,','),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('lateralmoves:practice_area'),fn:tokenize($Keywords,','),('wildcarded','case-insensitive'))
								))
								else cts:or-query((
											cts:element-word-query(xs:QName('lateralmoves:edu'),fn:concat('*' , fn:replace($Keywords,'"',''),'*'),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('lateralmoves:detail_text'),fn:concat('*' , fn:replace($Keywords,'"',''),'*'),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('lateralmoves:practice_area'),fn:concat('*' , fn:replace($Keywords,'"',''),'*'),('wildcarded','case-insensitive'))
										))
							
					else ()                                              
                                              
	
	let $totalCount := if($attorneyName ne '' or fn:contains($Keywords,'-') or fn:contains($Keywords,"'") or fn:contains($Keywords,"&amp;")) then
		count(cts:search(/,
             cts:and-query((
                  cts:directory-query('/LegalCompass/relational-data/ALI_RE_LateralMoves_Data/'),
                  cts:not-query(cts:element-value-query(xs:QName('lateralmoves:PreTitle'),'Administrative / Support Staff')),
                  if($firmID ne '') then cts:or-query((
                          cts:element-value-query(xs:QName('lateralmoves:company_Id'),$firmIDs) ,
                          cts:and-query((
                            cts:element-value-query(xs:QName('lateralmoves:CompanyId_From'),$firmIDs),
                            cts:element-value-query(xs:QName('lateralmoves:action'),'removed')
                            )),
                          cts:and-query((	
                          cts:element-value-query(xs:QName('lateralmoves:CompanyId_To'),$firmIDs),
                          cts:element-value-query(xs:QName('lateralmoves:action'),'added')
                          ))
                          )) else(),
                  if($lastAction ne '') then cts:element-value-query(xs:QName('lateralmoves:action'),$action) 
                  else cts:element-value-query(xs:QName('lateralmoves:action'),('added','removed','updated')),
                  if($fromDate ne '' and $toDate ne '') then cts:and-query((
                          cts:not-query(cts:element-value-query(xs:QName('lateralmoves:date_added'),('0/0/0000',''))),
                                                            cts:element-range-query(xs:QName('lateralmoves:date_added'),'>=',xs:date($fromDate)),
                                                            cts:element-range-query(xs:QName('lateralmoves:date_added'),'<=',xs:date($toDate)))) else(),
                  if($titles ne '') then cts:element-value-query(xs:QName('lateralmoves:Title'),$titles) else(),
                  if($practiceAreas ne '') then if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('lateralmoves:practices'),$practiceArea,("wildcarded","case-sensitive"))
                                                else cts:element-word-query(xs:QName('lateralmoves:primary_practice'),$practiceArea,("wildcarded","case-sensitive"))
                  else(),
                  
                  if($attCount gt 0) then cts:and-query((
                                        for $item in fn:tokenize($attName,' ')
                                            return cts:element-word-query(xs:QName('lateralmoves:Attorney_Name'),fn:concat('*' , fn:normalize-space($item) ,'*') ,("wildcarded",'case-insensitive'))
                  )) else(), 
                  
                  $keyword_q,
                  
                  if($lawSchoolNames ne '') then cts:element-word-query(xs:QName('lateralmoves:edu'),$lawSchoolNm ,('wildcarded','case-sensitive')) else(),
                 if($city != '' or $state ne '' or $country ne '' or $usRegion ne '' or $geographicRegion ne '') then cts:or-query((
                              if($city != '') then cts:element-value-query(xs:QName('lateralmoves:std_loc'),$cities) else(),
                              if($state ne '') then cts:element-value-query(xs:QName('lateralmoves:state'),$states) else(),
                              if($country ne '') then cts:element-value-query(xs:QName('lateralmoves:country'),$countries) else(),
                              if($usRegion ne '') then cts:element-value-query(xs:QName('lateralmoves:country'),$usRegions) else(),
                              if($geographicRegion ne '') then cts:element-value-query(xs:QName('lateralmoves:geographic_region'),$geographicRegions) else())) else(),
                  if($genderType ne '') then cts:element-value-query(xs:QName('lateralmoves:gender'),$gender,('case-insensitive')) else(),
                  cts:or-query((
                      cts:not-query(cts:element-value-query(xs:QName('lateralmoves:CompanyId_From'),'')),
                      cts:not-query(cts:element-value-query(xs:QName('lateralmoves:CompanyId_To'),''))
                  ))
                  ))))

	else fn:count(cts:search(/,
                                    cts:and-query((
                                        cts:directory-query('/LegalCompass/relational-data/ALI_RE_LateralMoves_Data/'),
										 cts:not-query(cts:element-value-query(xs:QName('lateralmoves:PreTitle'),'Administrative / Support Staff')),
                                         if($firmID ne '') then cts:or-query((
												cts:element-value-query(xs:QName('lateralmoves:company_Id'),$firmIDs) ,
												cts:and-query((
													cts:element-value-query(xs:QName('lateralmoves:CompanyId_From'),$firmIDs),
													cts:element-value-query(xs:QName('lateralmoves:action'),'removed')
													)),
												cts:and-query((	
												cts:element-value-query(xs:QName('lateralmoves:CompanyId_To'),$firmIDs),
												cts:element-value-query(xs:QName('lateralmoves:action'),'added')
												))
												)) else(),
                                         if($lastAction ne '') then cts:element-value-query(xs:QName('lateralmoves:action'),$action) 
										 else cts:element-value-query(xs:QName('lateralmoves:action'),('added','removed','updated')),
                                         if($fromDate ne '' and $toDate ne '') then cts:and-query((
														 cts:not-query(cts:element-value-query(xs:QName('lateralmoves:date_added'),('0/0/0000',''))),
                                                               cts:element-range-query(xs:QName('lateralmoves:date_added'),'>=',xs:date($fromDate)),
                                                               cts:element-range-query(xs:QName('lateralmoves:date_added'),'<=',xs:date($toDate)))) else(),
                      if($titles ne '') then cts:element-value-query(xs:QName('lateralmoves:Title'),$titles) else(),
                      if($practiceAreas ne '') then if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('lateralmoves:practices'),$practiceArea,("wildcarded","case-sensitive"))
                                                else cts:element-word-query(xs:QName('lateralmoves:primary_practice'),$practiceArea,("wildcarded","case-sensitive"))
                      else(),
                     	if($attCount gt 0) then cts:and-query((
                                               for $item in fn:tokenize($attName,' ')
                                                             return cts:element-word-query(xs:QName('lateralmoves:Attorney_Name'),fn:concat('*' , fn:normalize-space($item) ,'*') ,("wildcarded",'case-insensitive'))
                     )) else(), 

                      cts:or-query((
                      cts:not-query(cts:element-value-query(xs:QName('lateralmoves:CompanyId_From'),'')),
                      cts:not-query(cts:element-value-query(xs:QName('lateralmoves:CompanyId_To'),''))
                       )),

                     $keyword_q,
										 (: if($attorneyName ne '') then cts:element-word-query(xs:QName('lateralmoves:Attorney_Name'),$attName ,("wildcarded",'case-insensitive')) else(), :)
                                         if($lawSchoolNames ne '') then cts:element-word-query(xs:QName('lateralmoves:edu'),$lawSchoolNm ,('wildcarded',"case-sensitive")) else(),
                                         (:if($city ne '') then cts:element-value-query(xs:QName('lateralmoves:city'),$cities) else(),:)
										 (:if($city ne '') then cts:element-value-query(xs:QName('lateralmoves:std_loc'),$cities) else(),:)
										 if($city != '' or $state ne '' or $country ne '' or $usRegion ne '' or $geographicRegion ne '') then cts:or-query((
                              if($city != '') then cts:element-value-query(xs:QName('lateralmoves:std_loc'),$cities) else(),
                              if($state ne '') then cts:element-value-query(xs:QName('lateralmoves:state'),$states) else(),
                              if($country ne '') then cts:element-value-query(xs:QName('lateralmoves:country'),$countries) else(),
                              if($usRegion ne '') then cts:element-value-query(xs:QName('lateralmoves:country'),$usRegions) else(),
                              if($geographicRegion ne '') then cts:element-value-query(xs:QName('lateralmoves:geographic_region'),$geographicRegions) else())) else(),
                              if($genderType ne '') then cts:element-value-query(xs:QName('lateralmoves:gender'),$gender,('case-insensitive')) else()
                  ))))
               
	
	let $result := cts:search(/,
                  cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/ALI_RE_LateralMoves_Data/'),
						cts:not-query(cts:element-value-query(xs:QName('lateralmoves:PreTitle'),'Administrative / Support Staff')),
                          if($firmID ne '') then cts:or-query((
												cts:element-value-query(xs:QName('lateralmoves:company_Id'),$firmIDs) ,
												cts:and-query((
													cts:element-value-query(xs:QName('lateralmoves:CompanyId_From'),$firmIDs),
													cts:element-value-query(xs:QName('lateralmoves:action'),'removed')
													)),
												cts:and-query((	
												cts:element-value-query(xs:QName('lateralmoves:CompanyId_To'),$firmIDs),
												cts:element-value-query(xs:QName('lateralmoves:action'),'added')
												))
												)) else(),
                          if($lastAction ne '') then cts:element-value-query(xs:QName('lateralmoves:action'),$action)
						  else cts:element-value-query(xs:QName('lateralmoves:action'),('added','removed','updated')),
                         if($fromDate ne '' and $toDate ne '') then cts:and-query((
										 cts:not-query(cts:element-value-query(xs:QName('lateralmoves:date_added'),('0/0/0000',''))),
                                               cts:element-range-query(xs:QName('lateralmoves:date_added'),'>=',xs:date($fromDate)),
                                               cts:element-range-query(xs:QName('lateralmoves:date_added'),'<=',xs:date($toDate)))) else(),
                         if($titles ne '') then cts:element-value-query(xs:QName('lateralmoves:Title'),$titles) else(),
                         if($practiceAreas ne '') then if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('lateralmoves:practices'),$practiceArea,("wildcarded","case-sensitive"))
                                                else cts:element-word-query(xs:QName('lateralmoves:primary_practice'),$practiceArea,("wildcarded","case-sensitive"))
                         else(),
                         $keyword_q,
              	 if($attCount gt 0) then cts:and-query((
                                                for $item in fn:tokenize($attName,' ')
                                                             return cts:element-word-query(xs:QName('lateralmoves:Attorney_Name'),fn:concat('*' , fn:normalize-space($item) ,'*') ,("wildcarded",'case-insensitive'))
                     )) else(), 
						 
                         if($lawSchoolNames ne '') then cts:element-word-query(xs:QName('lateralmoves:edu'),$lawSchoolNm ,('wildcarded',"case-sensitive")) else(),
             
                         
						              if($city != '' or $state ne '' or $country ne '' or $usRegion ne '' or $geographicRegion ne '') then cts:or-query((
                              if($city != '') then cts:element-value-query(xs:QName('lateralmoves:std_loc'),$cities) else(),
                              if($state ne '') then cts:element-value-query(xs:QName('lateralmoves:state'),$states) else(),
                              if($country ne '') then cts:element-value-query(xs:QName('lateralmoves:country'),$countries) else(),
                              if($usRegion ne '') then cts:element-value-query(xs:QName('lateralmoves:country'),$usRegions) else(),
                              if($geographicRegion ne '') then cts:element-value-query(xs:QName('lateralmoves:geographic_region'),$geographicRegions) else())) else(),
                         if($genderType ne '') then cts:element-value-query(xs:QName('lateralmoves:gender'),$gender,('case-insensitive')) else(),
                          cts:or-query((
                      cts:not-query(cts:element-value-query(xs:QName('lateralmoves:CompanyId_From'),'')),
                      cts:not-query(cts:element-value-query(xs:QName('lateralmoves:CompanyId_To'),''))
                       ))
                         )),$orderBy)[$fromRecord to $toRecord]
  
  let $loopData := for $item in $result
                       let $res-object := json:object()
                     
									 
						let $from  := if(fn:not($item//lateralmoves:Company_Name/text() ne '') and  $item//lateralmoves:action/text() eq 'removed')
										then if(fn:not(attorney:GetFirmName_FIRMS_ALI_XREF_RE($item//lateralmoves:company_Id/text()) ne ''))
												then $item//lateralmoves:Company_Name/text() 
												else attorney:GetFirmName_FIRMS_ALI_XREF_RE($item//lateralmoves:company_Id/text())

											else if(fn:not(attorney:GetFirmName_FIRMS_ALI_XREF_RE($item//lateralmoves:company_Id/text()) ne ''))
												then $item//lateralmoves:CompanyName_From/text()
											else attorney:GetFirmName_FIRMS_ALI_XREF_RE($item//lateralmoves:CompanyId_From/text())
    
						let $to := if(fn:not($item//lateralmoves:Company_Name/text() ne '') and  $item//lateralmoves:action/text() eq 'added')
										then if(fn:not(attorney:GetFirmName_FIRMS_ALI_XREF_RE($item//lateralmoves:company_Id/text()) ne ''))
												then $item//lateralmoves:Company_Name/text() 
												else attorney:GetFirmName_FIRMS_ALI_XREF_RE($item//lateralmoves:company_Id/text())
										else if(fn:not(attorney:GetFirmName_FIRMS_ALI_XREF_RE($item//lateralmoves:company_Id/text()) ne ''))
												then $item//lateralmoves:CompanyName_To/text()
										else attorney:GetFirmName_FIRMS_ALI_XREF_RE($item//lateralmoves:CompanyId_To/text())
                       
                       let $fromID := if($item//lateralmoves:CompanyID_FROM_ALI/text() ne '') then $item//lateralmoves:CompanyID_FROM_ALI/text()
									   else if($item//lateralmoves:action/text() eq 'removed') then $item//lateralmoves:CompanyID_ALI/text() else $item//lateralmoves:CompanyID_FROM_ALI/text()
									   
					   let $toID := if($item//lateralmoves:CompanyId_To_ALI/text() ne '') then $item//lateralmoves:CompanyId_To_ALI/text()
									   else if($item//lateralmoves:action/text() eq 'added') then $item//lateralmoves:CompanyID_ALI/text() else $item//lateralmoves:CompanyId_To_ALI/text()			   
                       
                       (: let $lstAction :=  if($item//lateralmoves:action/text() eq 'removed') then 'Moved' else if($item//lateralmoves:action/text() eq 'added') then 'Moved' 
                                          else if($item//lateralmoves:action/text() eq 'updated') then 'Promotion' else() :)

                      let $lstAction := if($item//lateralmoves:action/text() eq 'removed') then 'Departed' 
                                       else if($item//lateralmoves:action/text() eq 'added') then 'Joined' else if($item//lateralmoves:action/text() eq 'updated') then 'Promotion' else()                    
                                          
                      let $attorneyLink := if($item//lateralmoves:action/text() ne 'removed') then $item//lateralmoves:Attorney_Link/text() else ''                
                      let $attorneyEmail := if($item//lateralmoves:action/text() ne 'removed') then $item//lateralmoves:email/text() else ''                
                       (: let $title := cts:highlight($item//lateralmoves:Title, "Partner", $cts:text) :)
                       
                       let $latestAttorneyID := if($lstAction eq 'Departed') then attorney:GetLatestPesonID($item//lateralmoves:person_id/text()) else $item//lateralmoves:person_id/text()

                       let $compID :=  cts:search(/,
                                          cts:and-query((
                                            cts:directory-query('/LegalCompass/relational-data/lateral_partner/'),
                                            cts:element-value-query(xs:QName('lateral_partner:person_id_from'),$item//lateralmoves:person_id/text())
                                          )))[1]//lateral_partner:company_id/text()

                       let $latestCompanyID := cts:search(/,
                                                  cts:and-query((
                                                    cts:directory-query('/LegalCompass/relational-data/FIRMS_ALI_XREF_RE/'),
                                                    cts:element-value-query(xs:QName('firmsali:RE_ID'),$compID)
                                                  )))[1]//firmsali:ALI_ID/text()

                       let $compID := if($lstAction ne 'Departed') then $item//lateralmoves:company_Id/text()
                                      else if($latestCompanyID) then $latestCompanyID else $item//lateralmoves:company_Id/text() 
                       let $aliID := if($lstAction ne 'Departed') then $item//lateralmoves:CompanyID_ALI/text()
                                     else if($latestCompanyID) then $latestCompanyID else $item//lateralmoves:CompanyID_ALI/text()
                       let $_ := (
                                  map:put($res-object,'firmId',$compID),
                                  map:put($res-object,'firmId11',$item//lateralmoves:company_Id/text()),
                                  map:put($res-object,'attorney_id',if($latestAttorneyID) then $latestAttorneyID else $item//lateralmoves:person_id/text()),
                                  map:put($res-object,'firmname',$item//lateralmoves:Company_Name/text()),
                                  map:put($res-object,'practices',$item//lateralmoves:practices/text()),
                                  map:put($res-object,'education',$item//lateralmoves:edu/text()),
                                  map:put($res-object,'date_added',$item//lateralmoves:date_added/text()),
                                  map:put($res-object,'name',$item//lateralmoves:Attorney_Name/text()),
                                  map:put($res-object,'title',$item//lateralmoves:Title/text()),
                                  map:put($res-object,'pretitle',$item//lateralmoves:PreTitle/text()),
                                  map:put($res-object,'location',$item//lateralmoves:Location/text()),
                                  map:put($res-object,'From',$from),
                                  map:put($res-object,'To',$to),
                                  map:put($res-object,'From_Id',$fromID),
                                  map:put($res-object,'To_Id',$toID),
                                  map:put($res-object,'last_action',$lstAction),
                                  map:put($res-object,'attorney_link',$attorneyLink),
                                  map:put($res-object,'biotext',$item//lateralmoves:detail_text/text()),
                                  map:put($res-object,'Attorney_Email',$attorneyEmail),
                                  (: map:put($res-object,'ali_id',$item//lateralmoves:CompanyID_ALI/text()), :)
                                  map:put($res-object,'ali_id',$aliID),
                                  map:put($res-object,'ALI_Name',$item//lateralmoves:CompanyName_ALI/text()),
								                  map:put($res-object,'TotalCount',$totalCount),
                                  map:put($res-object,'Gender',$item//lateralmoves:gender/text()),
                                  map:put($res-object,'PrimaryPracticeArea',$item//lateralmoves:primary_practice/text()),
                                  map:put($res-object,'PhoneNo',$item//lateralmoves:Phone/text()),
                                  map:put($res-object,'GraduationYear',$item//lateralmoves:Graduation_Year/text())
                                 )
                      let $_ := json:array-push($res-array,$res-object)      
                       return()
 return $res-array
};



declare function attorney:GetLatestPesonID($pID)
{
  let $result := cts:search(/,
                    cts:and-query((
                      cts:directory-query('/LegalCompass/relational-data/lateral_partner/'),
                      cts:element-value-query(xs:QName('lateral_partner:person_id_from'),xs:string($pID))
                    )))[1]//lateral_partner:person_id/text()

  return $result                  
};

declare function attorney:GetFirmName_FIRMS_ALI_XREF_RE($firmId)
{
	let $result := cts:search(/FIRMS_ALI_XREF_RE,
                     cts:and-query((
                       cts:directory-query('/LegalCompass/relational-data/FIRMS_ALI_XREF_RE/'),
                       cts:element-value-query(xs:QName('alidata:RE_ID'),xs:string($firmId))
                       )))
  return $result//alidata:ALM_NAME/text()

};
declare function attorney:sp_GetLawyerMoves($firmID,$fromDate,$toDate,$title,$practiceAreas)
{
let $res-array := json:array()
 
  
  let $firmIDs := if($firmID ne '') then fn:tokenize($firmID,',') else()
  let $titles := if($title ne '') then fn:tokenize($title,',') else()
  let $practiceArea := if($practiceAreas ne '') then fn:tokenize($practiceAreas,'[|]') else()
  
  let $orderBy := cts:index-order(cts:element-reference(xs:QName('lateralmoves:date_added')) ,'descending')
  
  let $result := cts:search(/ALI_RE_LateralMoves_Data,
                  cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/ALI_RE_LateralMoves_Data/','1'),
                        cts:element-value-query(xs:QName('lateralmoves:CompanyId_From'),$firmIDs),
                        cts:element-value-query(xs:QName('lateralmoves:action'),'removed'),
                        if($fromDate ne '' and $toDate ne '') then cts:and-query((
								cts:not-query(cts:element-value-query(xs:QName('lateralmoves:date_added'),'0/0/0000')),
                                cts:element-range-query(xs:QName('lateralmoves:date_added'),'>=',xs:date($fromDate)),
                                cts:element-range-query(xs:QName('lateralmoves:date_added'),'<=',xs:date($toDate)))) else(),
                        if($titles ne '') then cts:element-value-query(xs:QName('lateralmoves:Title'),$titles) else(),
                        (: if($practiceAreas ne '') then cts:element-value-query(xs:QName('lateralmoves:practices'),$practiceArea,'case-insensitive') else() :)
                        if($practiceAreas ne '') then cts:element-word-query(xs:QName('lateralmoves:practices'),$practiceArea,'case-insensitive') else()
                        )),$orderBy)
  let $result1 := cts:search(/ALI_RE_LateralMoves_Data,
                  cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/ALI_RE_LateralMoves_Data/','1'),
                        cts:element-value-query(xs:QName('lateralmoves:CompanyId_To'),$firmIDs),
                        cts:element-value-query(xs:QName('lateralmoves:action'),'added'),
                        if($fromDate ne '' and $toDate ne '') then cts:and-query((
															   cts:not-query(cts:element-value-query(xs:QName('lateralmoves:date_added'),'0/0/0000')),
                                                               cts:element-range-query(xs:QName('lateralmoves:date_added'),'>=',xs:date($fromDate)),
                                                               cts:element-range-query(xs:QName('lateralmoves:date_added'),'<=',xs:date($toDate)))) else(),
                                         if($titles ne '') then cts:element-value-query(xs:QName('lateralmoves:Title'),$titles) else(),
                                         (: if($practiceAreas ne '') then cts:element-value-query(xs:QName('lateralmoves:practices'),$practiceArea,'case-insensitive') else() :)
                                         if($practiceAreas ne '') then cts:element-word-query(xs:QName('lateralmoves:practices'),$practiceArea,'case-insensitive') else()
                                         )),$orderBy)
  let $loopData := for $item in $result
                        let $res-object := json:object()
						let $cIDFrom := $item/lateralmoves:CompanyId_From/text()
						let $cIDTo := $item/lateralmoves:CompanyId_To/text()
					    let $xrefCompNameFrom := cts:search(/,
												  cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/FIRMS_ALI_XREF_RE/'),
													cts:element-value-query(xs:QName('firmsali:RE_ID'),$cIDFrom)
												  )))//firmsali:ALM_NAME/text()

						let $compNameFrom := if($xrefCompNameFrom ne '') then $xrefCompNameFrom else $item/lateralmoves:CompanyName_From/text()

						let $xrefCompNameTo := cts:search(/,
												  cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/FIRMS_ALI_XREF_RE/'),
													cts:element-value-query(xs:QName('firmsali:RE_ID'),$cIDTo
												  ))))//firmsali:ALM_NAME/text()
												  
						let $compNameTo := if($xrefCompNameTo ne '') then $xrefCompNameTo else $item/lateralmoves:CompanyName_To/text()
						
                        let $from := if($item/lateralmoves:action/text() eq 'removed') then if($item/lateralmoves:CompanyName_From/text() ne '') then
                                       $item/lateralmoves:CompanyName_From/text() else $item/lateralmoves:Company_Name/text() else $item/lateralmoves:Company_Name/text()
                       let $to := if($item/lateralmoves:action/text() eq 'added') then if($item/lateralmoves:CompanyName_To/text() ne '') then
                                       $item/lateralmoves:CompanyName_To/text() else $item/lateralmoves:Company_Name/text() else $item/lateralmoves:Company_Name/text()
                       let $fromID := if($item/lateralmoves:action/text() eq 'removed') then
                                       if( $item/lateralmoves:CompanyID_FROM_ALI/text() ne '') then $item/lateralmoves:CompanyID_FROM_ALI/text() 
                                       else $item/lateralmoves:CompanyID_ALI/text() else $item/lateralmoves:CompanyID_ALI/text()
                       let $toID := if($item/lateralmoves:action/text() eq 'added') then 
                                       if($item/lateralmoves:CompanyId_To_ALI/text() ne '') then $item/lateralmoves:CompanyId_To_ALI/text() else $item/lateralmoves:CompanyID_ALI/text() else $item/lateralmoves:CompanyID_ALI/text()
                       let $lstAction := if($item/lateralmoves:action/text() ne 'removed') then 'Joined' else 'Departed'                
                       let $attorneyLink := if($item/lateralmoves:action/text() ne 'removed') then $item/lateralmoves:Attorney_Link/text() else ''                
                       let $attorneyEmail := if($item/lateralmoves:action/text() ne 'removed') then $item/lateralmoves:email/text() else ''                
                       let $_ := (map:put($res-object,'firmId',$item/lateralmoves:company_Id/text()),
                                  map:put($res-object,'AttorneyID',$item/lateralmoves:person_id/text()),
                                  map:put($res-object,'firmname',$item/lateralmoves:Company_Name/text()),
                                  map:put($res-object,'AttorneyPracticeArea',$item/lateralmoves:practices/text()),
                                  map:put($res-object,'Phone',$item/lateralmoves:Phone/text()),
                                  map:put($res-object,'date_added',$item/lateralmoves:date_added/text()),
                                  map:put($res-object,'AttorneyName',$item/lateralmoves:Attorney_Name/text()),
                                  map:put($res-object,'AttorneyTitle',$item/lateralmoves:Title/text()),
                                  map:put($res-object,'AttorneyLocation',$item/lateralmoves:Location/text()),
                                  map:put($res-object,'FirmNameFrom',$compNameFrom),
                                  map:put($res-object,'FirmNameTo',$compNameTo),
                                  map:put($res-object,'FirmIDFrom',$item/lateralmoves:CompanyId_From/text()),
                                  map:put($res-object,'FirmIDTo',$item/lateralmoves:CompanyId_To/text()),
                                  map:put($res-object,'Action',$item/lateralmoves:action/text()),
                                  map:put($res-object,'AttorneyURL',$attorneyLink),
                                  map:put($res-object,'LastName',$item/lateralmoves:lastname/text()),
                                  map:put($res-object,'MiddleName',$item/lateralmoves:middle_name/text()),
                                  map:put($res-object,'firstname',$item/lateralmoves:firstname/text()),
                                  map:put($res-object,'AttorneyDescription','')
                                 )
                      let $_ := json:array-push($res-array,$res-object)      
                       return()
 let $loopData1 := for $item in $result1
						let $cIDFrom := $item/lateralmoves:CompanyId_From/text()
						let $cIDTo := $item/lateralmoves:CompanyId_To/text()
						
					    let $xrefCompNameFrom := cts:search(/FIRMS_ALI_XREF_RE,
												  cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/FIRMS_ALI_XREF_RE/'),
													cts:element-value-query(xs:QName('firmsali:RE_ID'),$cIDFrom)
												  )))//firmsali:ALM_NAME/text()
						let $compNameFrom := if($xrefCompNameFrom ne '') then $xrefCompNameFrom else $item/lateralmoves:CompanyName_From/text()

						let $xrefCompNameTo := cts:search(/FIRMS_ALI_XREF_RE,
												  cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/FIRMS_ALI_XREF_RE/'),
													cts:element-value-query(xs:QName('firmsali:RE_ID'),$cIDTo)
													)))//firmsali:ALM_NAME/text()
												  
						let $compNameTo := if($xrefCompNameTo ne '') then $xrefCompNameTo else $item/lateralmoves:CompanyName_To/text()
						
                       let $res-object := json:object()
                        let $from := if($item/lateralmoves:action/text() eq 'removed') then if($item/lateralmoves:CompanyName_From/text() ne '') then
                                       $item/lateralmoves:CompanyName_From/text() else $item/lateralmoves:Company_Name/text() else $item/lateralmoves:Company_Name/text()
                       let $to := if($item/lateralmoves:action/text() eq 'added') then if($item/lateralmoves:CompanyName_To/text() ne '') then
                                       $item/lateralmoves:CompanyName_To/text() else $item/lateralmoves:Company_Name/text() else $item/lateralmoves:Company_Name/text()
                       let $fromID := if($item/lateralmoves:action/text() eq 'removed') then
                                       if( $item/lateralmoves:CompanyID_FROM_ALI/text() ne '') then $item/lateralmoves:CompanyID_FROM_ALI/text() 
                                       else $item/lateralmoves:CompanyID_ALI/text() else $item/lateralmoves:CompanyID_ALI/text()
                       let $toID := if($item/lateralmoves:action/text() eq 'added') then 
                                       if($item/lateralmoves:CompanyId_To_ALI/text() ne '') then $item/lateralmoves:CompanyId_To_ALI/text() else $item/lateralmoves:CompanyID_ALI/text() else $item/lateralmoves:CompanyID_ALI/text()
                       let $lstAction := if($item/lateralmoves:action/text() ne 'removed') then 'Joined' else 'Departed'                
                       let $attorneyLink := if($item/lateralmoves:action/text() ne 'removed') then $item/lateralmoves:Attorney_Link/text() else ''                
                       let $attorneyEmail := if($item/lateralmoves:action/text() ne 'removed') then $item/lateralmoves:email/text() else ''                
                       let $_ := (map:put($res-object,'firmId',$item/lateralmoves:company_Id/text()),
                                  map:put($res-object,'AttorneyID',$item/lateralmoves:person_id/text()),
                                  map:put($res-object,'firmname',$item/lateralmoves:Company_Name/text()),
                                  map:put($res-object,'AttorneyPracticeArea',$item/lateralmoves:practices/text()),
                                  map:put($res-object,'Phone',$item/lateralmoves:Phone/text()),
                                  map:put($res-object,'date_added',$item/lateralmoves:date_added/text()),
                                  map:put($res-object,'AttorneyName',$item/lateralmoves:Attorney_Name/text()),
                                  map:put($res-object,'AttorneyTitle',$item/lateralmoves:Title/text()),
                                  map:put($res-object,'AttorneyLocation',$item/lateralmoves:Location/text()),
                                  map:put($res-object,'FirmNameFrom',$compNameFrom),
                                  map:put($res-object,'FirmNameTo',$compNameTo),
                                  map:put($res-object,'FirmIDFrom',$item/lateralmoves:CompanyId_From/text()),
                                  map:put($res-object,'FirmIDTo',$item/lateralmoves:CompanyId_To/text()),
                                  map:put($res-object,'Action',$item/lateralmoves:action/text()),
                                  map:put($res-object,'AttorneyURL',$attorneyLink),
                                  map:put($res-object,'LastName',$item/lateralmoves:lastname/text()),
                                  map:put($res-object,'MiddleName',$item/lateralmoves:middle_name/text()),
                                  map:put($res-object,'firstname',$item/lateralmoves:firstname/text()),
                                  map:put($res-object,'AttorneyDescription','')
                                  
                                  
                                 )
                      let $_ := json:array-push($res-array,$res-object)      
                       return()
 return $res-array
};

declare function attorney:GetAttorneysAdvanceSearchMLQueryCount(
  $query
  ,$cities
  ,$states
  ,$countries
  ,$geoGraphicRegion
  ,$usRegions
  ,$keywords
  ,$firms
  ,$sortBy
  ,$sortDirection
  ,$filterValue
  ,$practiceAreas
  ,$attorneyName
  )
{
  let $res-object := json:object()
  let $Keywords := $keywords
  let $locationQuery := if($cities ne '' or $states ne '' or $countries ne '' or $geoGraphicRegion ne '' or $usRegions ne '') 
    then 
    cts:or-query((
      (: if($cities ne '') then cts:element-value-query(xs:QName('ALI_RE_Attorney_Combined:city'),fn:tokenize($cities,',')) else(), :)
      if($cities ne '') then 
      (: then cts:element-value-query(xs:QName('ALI_RE_Attorney_Combined:city'),fn:tokenize($cities,',')) else(), :)
        let $Cities := $cities ! fn:tokenize(.,';')
        for $c in $Cities
          return 
            if(count(fn:tokenize($c,'[,]')) > 1) then
            let $city := fn:tokenize($c,'[,]')[1]
            let $state := fn:tokenize($c,'[,]')[2]
        
              return 
                if(fn:string-length($state) eq 2) 
                then 
                  cts:and-query((
                  cts:element-value-query(xs:QName('ALI_RE_Attorney_Combined:city'), $city, ('case-insensitive'))
                  ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Combined:state'), $state, ('case-insensitive'))
                  ))
                else
                  cts:and-query((
                  cts:element-value-query(xs:QName('ALI_RE_Attorney_Combined:city'), $city, ('case-insensitive'))
                  ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Combined:country'), $state, ('case-insensitive'))
                  ))
              
            else
              cts:element-value-query(xs:QName('ALI_RE_Attorney_Combined:city'), $Cities, ('case-insensitive'))
        else (),
      if($countries ne '') then cts:element-value-query(xs:QName('ALI_RE_Attorney_Combined:country'),fn:tokenize($countries,',')) else(),
      if($states ne '') then cts:element-value-query(xs:QName('ALI_RE_Attorney_Combined:state'),fn:tokenize($states,',')) else(),
      if($geoGraphicRegion ne '') then cts:element-value-query(xs:QName('ALI_RE_Attorney_Combined:geographic_region'),fn:tokenize($geoGraphicRegion,',')) else(),
      if($usRegions ne '') then cts:element-value-query(xs:QName('ALI_RE_Attorney_Combined:us_region'),fn:tokenize($usRegions,',')) else()
    ))
    else ()

let $keywordQuery := if($Keywords !='') then
			
							if(fn:contains(fn:lower-case($Keywords),' and ') and fn:not(fn:contains(fn:lower-case($Keywords),'"'))) then 
								 attorney:GetAndOperatorQuery($Keywords)
													
							
							else if(fn:contains(fn:lower-case($Keywords),' or ') and fn:not(fn:contains(fn:lower-case($Keywords),'"'))) then 
								 attorney:GetOrOperatorQuery($Keywords)
													
							else if(fn:contains(fn:lower-case($Keywords),'"') and fn:contains(fn:lower-case($Keywords),'" or "')) then 
								 attorney:GetExactOrOperatorQuery($Keywords)

              else if(fn:contains(fn:lower-case($Keywords),'"') and fn:contains(fn:lower-case($Keywords),' or ')) then 
								 attorney:GetExactOrOperatorQuery($Keywords)	    
										
							else if(fn:contains(fn:lower-case($Keywords),'"') and fn:contains(fn:lower-case($Keywords),'" and "')) then 
								 attorney:GetExactAndOperatorQuery($Keywords)

              else if(fn:contains(fn:lower-case($Keywords),'"') and fn:contains(fn:lower-case($Keywords),' and ')) then 
								 attorney:GetExactAndOperatorQuery($Keywords)   			
										
							else if(fn:contains(fn:lower-case($Keywords),' or ') and fn:contains(fn:lower-case($Keywords),' and ')) then 
								 attorney:GetAndOrOperatorQuery($Keywords)
							
							else if(fn:contains($Keywords,',') and fn:not(fn:contains(fn:lower-case($Keywords),'"'))) then 
								   cts:or-query((
									cts:element-word-query(xs:QName('ALI_RE_Attorney_Combined:Keywords'),fn:tokenize($Keywords,','),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('ALI_RE_Attorney_Combined:education'),fn:tokenize($Keywords,','),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('ALI_RE_Attorney_Combined:practices'),fn:tokenize($Keywords,','),('wildcarded','case-insensitive'))
								))
								else if(fn:contains($Keywords,' ') and fn:not(fn:contains(fn:lower-case($Keywords),'"'))) then 
								   cts:or-query((
									cts:element-word-query(xs:QName('ALI_RE_Attorney_Combined:Keywords'),fn:tokenize($Keywords,' '),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('ALI_RE_Attorney_Combined:education'),fn:tokenize($Keywords,' '),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('ALI_RE_Attorney_Combined:practices'),fn:tokenize($Keywords,' '),('wildcarded','case-insensitive'))
								)) 
								else cts:or-query((
										cts:element-word-query(xs:QName('ALI_RE_Attorney_Combined:Keywords'),fn:concat('*',fn:replace($Keywords,'"',''),'*'),('wildcarded','case-insensitive'))
										(: cts:element-word-query(xs:QName('ALI_RE_Attorney_Combined:education'),fn:concat('*',fn:replace($Keywords,'"',''),'*'),('wildcarded','case-insensitive')),
										cts:element-word-query(xs:QName('ALI_RE_Attorney_Combined:practices'),fn:concat('*',fn:replace($Keywords,'"',''),'*'),('wildcarded','case-insensitive')) :)
										))
							
					else ()    

   let $attName := fn:replace($attorneyName,'[^a-zA-Z0-9'']','')
  let $attorneyNameAndQuery := cts:and-query((
					for $item in fn:tokenize($attorneyName,' ')
						return cts:element-word-query(xs:QName("ALI_RE_Attorney_Combined:AttorneyName"),$item,('wildcarded','case-insensitive','punctuation-insensitive','whitespace-insensitive'))
				
				))
  
  let $attorneyNameQuery := cts:or-query((
                              cts:element-word-query(xs:QName("ALI_RE_Attorney_Combined:AttorneyName"),($attorneyName),('wildcarded','case-insensitive','punctuation-insensitive','whitespace-insensitive')),
                              cts:element-word-query(xs:QName("ALI_RE_Attorney_Combined:AttorneyNamereverted"),($attorneyName),('wildcarded','case-insensitive','punctuation-insensitive','whitespace-insensitive'))
                              ,cts:element-word-query(xs:QName("ALI_RE_Attorney_Combined:AttorneyNamereverted1"),($attName),('wildcarded','case-insensitive','punctuation-insensitive','whitespace-insensitive'))
                              ,$attorneyNameAndQuery
  ))           

  let $TotalCount := if(fn:contains(xs:string($query),"cts:element-word-query") or $Keywords !='')
    then count(cts:search(/,
      cts:and-query((
      cts:directory-query('/LegalCompass/relational-data/ALI_RE_Attorney_Combined/')
      ,if($query ne '') then xdmp:value($query) else ()
      ,if($practiceAreas ne '') then cts:element-value-query(xs:QName('ALI_RE_Attorney_Combined:practice_area'),fn:tokenize($practiceAreas,'[|]')) else ()
      ,cts:and-query(($locationQuery))
      ,$keywordQuery
      ,if($attorneyName) then $attorneyNameQuery else()
      ))
    ))
    else xdmp:estimate(cts:search(/,
      cts:and-query((
      cts:directory-query('/LegalCompass/relational-data/ALI_RE_Attorney_Combined/')
      ,if($query ne '') then xdmp:value($query) else ()
      ,if($practiceAreas ne '') then cts:element-value-query(xs:QName('ALI_RE_Attorney_Combined:practice_area'),fn:tokenize($practiceAreas,'[|]')) else ()
      ,cts:and-query(($locationQuery))
      ,if($attorneyName) then $attorneyNameQuery else()
      ))
    ))

  let $_ := (map:put($res-object,'TotalCount',$TotalCount),
  map:put($res-object,'TEST',$practiceAreas))

  return fn:concat('[',$res-object,']') 
};

(:-----------------------------------------------------:)

declare function attorney:GetAttorneysAdvanceSearchSqlQuery(
  $pageNo
  ,$pageSize
  ,$query
  ,$cities
  ,$states
  ,$countries
  ,$geoGraphicRegion
  ,$usRegions
  ,$keywords
  ,$firms
  ,$sortBy
  ,$sortDirection
  ,$practiceAreas
  ,$attorneyName
  )
{
  let $response-arr := json:array()

  let $Keywords := $keywords

  let $fromRecord := if($pageNo ne '1') then (xs:int($pageNo)-1)*xs:int($pageSize) else 1
  let $toRecord := xs:int($pageSize)*xs:int($pageNo)
  
  let $locationQuery := if($cities ne '' or $states ne '' or $countries ne '' or $geoGraphicRegion ne '' or $usRegions ne '') 
    then 
    cts:or-query((
      if($cities ne '') then 
      (: then cts:element-value-query(xs:QName('ALI_RE_Attorney_Combined:city'),fn:tokenize($cities,',')) else(), :)
        let $Cities := $cities ! fn:tokenize(.,';')
        for $c in $Cities
          return 
            if(count(fn:tokenize($c,'[,]')) > 1) then
            let $city := fn:tokenize($c,'[,]')[1]
            let $state := fn:tokenize($c,'[,]')[2]
        
              return 
                if(fn:string-length($state) eq 2) 
                then 
                  cts:and-query((
                  cts:element-value-query(xs:QName('ALI_RE_Attorney_Combined:city'), $city, ('case-insensitive'))
                  ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Combined:state'), $state, ('case-insensitive'))
                  ))
                else
                  cts:and-query((
                  cts:element-value-query(xs:QName('ALI_RE_Attorney_Combined:city'), $city, ('case-insensitive'))
                  ,cts:element-value-query(xs:QName('ALI_RE_Attorney_Combined:country'), $state, ('case-insensitive'))
                  ))
              
            else
              cts:element-value-query(xs:QName('ALI_RE_Attorney_Combined:city'), $Cities, ('case-insensitive'))
        else (),      

      if($countries ne '') then cts:element-value-query(xs:QName('ALI_RE_Attorney_Combined:country'),fn:tokenize($countries,',')) else(),
      if($states ne '') then cts:element-value-query(xs:QName('ALI_RE_Attorney_Combined:state'),fn:tokenize($states,',')) else(),
      if($geoGraphicRegion ne '') then cts:element-value-query(xs:QName('ALI_RE_Attorney_Combined:geographic_region'),fn:tokenize($geoGraphicRegion,',')) else(),
      if($usRegions ne '') then cts:element-value-query(xs:QName('ALI_RE_Attorney_Combined:us_region'),fn:tokenize($usRegions,',')) else()
    ))
    else ()

  let $keywordQuery := if($Keywords !='') then
			
							if(fn:contains(fn:lower-case($Keywords),'and') and fn:not(fn:contains(fn:lower-case($Keywords),'"'))) then 
								 attorney:GetAndOperatorQuery($Keywords)
													
							
							else if(fn:contains(fn:lower-case($Keywords),'or') and fn:not(fn:contains(fn:lower-case($Keywords),'"'))) then 
								 attorney:GetOrOperatorQuery($Keywords)
													
							else if(fn:contains(fn:lower-case($Keywords),'"') and fn:contains(fn:lower-case($Keywords),'" or "')) then 
								 attorney:GetExactOrOperatorQuery($Keywords)

              else if(fn:contains(fn:lower-case($Keywords),'"') and fn:contains(fn:lower-case($Keywords),' or ')) then 
								 attorney:GetExactOrOperatorQuery($Keywords)	    
										
							else if(fn:contains(fn:lower-case($Keywords),'"') and fn:contains(fn:lower-case($Keywords),'" and "')) then 
								 attorney:GetExactAndOperatorQuery($Keywords)

              else if(fn:contains(fn:lower-case($Keywords),'"') and fn:contains(fn:lower-case($Keywords),' and ')) then 
								 attorney:GetExactAndOperatorQuery($Keywords)   			
										
							else if(fn:contains(fn:lower-case($Keywords),' or ') and fn:contains(fn:lower-case($Keywords),' and ')) then 
								 attorney:GetAndOrOperatorQuery($Keywords)
							
							else if(fn:contains($Keywords,',') and fn:not(fn:contains(fn:lower-case($Keywords),'"'))) then 
								   cts:or-query((
									cts:element-word-query(xs:QName('ALI_RE_Attorney_Combined:Keywords'),fn:tokenize($Keywords,','),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('ALI_RE_Attorney_Combined:education'),fn:tokenize($Keywords,','),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('ALI_RE_Attorney_Combined:practices'),fn:tokenize($Keywords,','),('wildcarded','case-insensitive'))
								))
								else if(fn:contains($Keywords,' ') and fn:not(fn:contains(fn:lower-case($Keywords),'"'))) then 
								   cts:or-query((
									cts:element-word-query(xs:QName('ALI_RE_Attorney_Combined:Keywords'),fn:tokenize($Keywords,' '),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('ALI_RE_Attorney_Combined:education'),fn:tokenize($Keywords,' '),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('ALI_RE_Attorney_Combined:practices'),fn:tokenize($Keywords,' '),('wildcarded','case-insensitive'))
								))
								else cts:or-query((
										cts:element-word-query(xs:QName('ALI_RE_Attorney_Combined:Keywords'), fn:concat('*' , fn:replace($Keywords,'"',''),'*'),('wildcarded','case-insensitive')),
										cts:element-word-query(xs:QName('ALI_RE_Attorney_Combined:education'),fn:concat('*' , fn:replace($Keywords,'"',''),'*'),('wildcarded','case-insensitive')),
										cts:element-word-query(xs:QName('ALI_RE_Attorney_Combined:practices'),fn:concat('*' , fn:replace($Keywords,'"',''),'*'),('wildcarded','case-insensitive'))
										))
							
					else ()    
  let $direction := if($sortDirection eq 'asc') then 'ascending' else 'descending'
  let $orderBy :=if($sortBy eq 'AttorneyName') then cts:index-order(cts:element-reference(xs:QName('ALI_RE_Attorney_Combined:AttorneyName')) ,$direction)
                  else if($sortBy eq 'FirmName') then cts:index-order(cts:element-reference(xs:QName('ALI_RE_Attorney_Combined:Firm_Name')) ,$direction)                  
                  else if($sortBy eq 'Title') then cts:index-order(cts:element-reference(xs:QName('ALI_RE_Attorney_Combined:title')) ,$direction)
                  else if($sortBy eq 'Location') then cts:index-order(cts:element-reference(xs:QName('ALI_RE_Attorney_Combined:location')) ,$direction)
                  else (
                    cts:index-order(cts:element-reference(xs:QName('ALI_RE_Attorney_Combined:Firm_Name')) ,$direction)
                    ,cts:index-order(cts:element-reference(xs:QName('ALI_RE_Attorney_Combined:AttorneyName')) ,$direction)                      
                  )

  let $attName := fn:replace($attorneyName,'[^a-zA-Z0-9'']','')
  let $attorneyNameAndQuery := cts:and-query((
					for $item in fn:tokenize($attorneyName,' ')
						return cts:element-word-query(xs:QName("ALI_RE_Attorney_Combined:AttorneyName"),$item,('wildcarded','case-insensitive','punctuation-insensitive','whitespace-insensitive'))
				
				))
  
  let $attorneyNameQuery := cts:or-query((
                              cts:element-word-query(xs:QName("ALI_RE_Attorney_Combined:AttorneyName"),($attorneyName),('wildcarded','case-insensitive','punctuation-insensitive','whitespace-insensitive')),
                              cts:element-value-query(xs:QName("ALI_RE_Attorney_Combined:AttorneyNamereverted"),($attorneyName),('wildcarded','case-insensitive','punctuation-insensitive','whitespace-insensitive'))
                              ,cts:element-value-query(xs:QName("ALI_RE_Attorney_Combined:AttorneyNamereverted1"),($attName),('wildcarded','case-insensitive','punctuation-insensitive','whitespace-insensitive'))
                               ,$attorneyNameAndQuery
  ))                

  let $results := cts:search(/,
    cts:and-query((
      cts:directory-query('/LegalCompass/relational-data/ALI_RE_Attorney_Combined/')
      ,if($query ne '') then xdmp:value($query) else ()
      ,cts:and-query(($locationQuery))
      ,$keywordQuery
      ,if($attorneyName) then $attorneyNameQuery else ()
      ,if($practiceAreas ne '') then cts:element-value-query(xs:QName('ALI_RE_Attorney_Combined:practice_area'),fn:tokenize($practiceAreas,'[|]')) else ()
      )),
      $orderBy
    )[$fromRecord to $toRecord]

  for $res in $results
    let $response-obj := json:object()

    let $firmId := if($res//ALI_RE_Attorney_Combined:RecordType/text() eq 'FIRM')
      then $res//ALI_RE_Attorney_Combined:ali_id/text()
      else $res//ALI_RE_Attorney_Combined:FirmID/text()
    
    let $firmName := if($res//ALI_RE_Attorney_Combined:FirmName/text() eq '')
      then $res//ALI_RE_Attorney_Combined:firm_name/text()
      else $res//ALI_RE_Attorney_Combined:FirmName/text()
    let $_ := (
      map:put($response-obj ,'ID', $res//ALI_RE_Attorney_Combined:ID/text())
      ,map:put($response-obj ,'AttorneyName', $res//ALI_RE_Attorney_Combined:AttorneyName/text())
      ,map:put($response-obj ,'AttorneyProfileLink', $res//ALI_RE_Attorney_Combined:AttorneyProfileLink/text())
      ,map:put($response-obj ,'FirmID', $firmId)
      ,map:put($response-obj ,'FirmName', $firmName)
      ,map:put($response-obj ,'FirmLink', $res//ALI_RE_Attorney_Combined:FirmLink/text())
      ,map:put($response-obj ,'Title', $res//ALI_RE_Attorney_Combined:title/text())
      ,map:put($response-obj ,'Location', $res//ALI_RE_Attorney_Combined:location/text())
      ,map:put($response-obj ,'Practices', $res//ALI_RE_Attorney_Combined:practices/text())
      ,map:put($response-obj ,'Education', $res//ALI_RE_Attorney_Combined:education/text())
      ,map:put($response-obj ,'Addmission', $res//ALI_RE_Attorney_Combined:addmission/text())
      ,map:put($response-obj ,'Keywords', $res//ALI_RE_Attorney_Combined:Keywords/text())
      ,map:put($response-obj ,'PhoneNo', $res//ALI_RE_Attorney_Combined:PhoneNo/text())
      ,map:put($response-obj ,'Email', $res//ALI_RE_Attorney_Combined:Email/text())
      ,map:put($response-obj ,'Scopeid', $res//ALI_RE_Attorney_Combined:Scopeid/text())
      ,map:put($response-obj ,'City', $res//ALI_RE_Attorney_Combined:City/text())
      ,map:put($response-obj ,'State', $res//ALI_RE_Attorney_Combined:State/text())
      ,map:put($response-obj ,'Country', $res//ALI_RE_Attorney_Combined:Country/text())
      ,map:put($response-obj ,'Geographic_Region', $res//ALI_RE_Attorney_Combined:Geographic_Region/text())
      ,map:put($response-obj ,'Graduation_year', $res//ALI_RE_Attorney_Combined:Graduation_year/text())
      ,map:put($response-obj ,'ALI_ID', $res//ALI_RE_Attorney_Combined:ali_id/text())
      ,map:put($response-obj ,'RecordType', $res//ALI_RE_Attorney_Combined:RecordType/text())
      ,map:put($response-obj ,'US_Region', $res//ALI_RE_Attorney_Combined:US_Region/text())
      ,map:put($response-obj ,'Metro_Area', $res//ALI_RE_Attorney_Combined:METRO_AREA/text())
      ,map:put($response-obj ,'AMLaw_Rank', $res//ALI_RE_Attorney_Combined:AMLaw_Rank/text())
      ,map:put($response-obj ,'std_school', $res//ALI_RE_Attorney_Combined:std_school/text())
      ,map:put($response-obj ,'gender', $res//ALI_RE_Attorney_Combined:gender/text())
      ,map:put($response-obj ,'nlj_rank', $res//ALI_RE_Attorney_Combined:nlj_rank/text())
      ,map:put($response-obj ,'primary_practice', $res//ALI_RE_Attorney_Combined:primary_practice/text())
      ,map:put($response-obj ,'school', $res//ALI_RE_Attorney_Combined:school/text())
      ,map:put($response-obj ,'FirmSize', $res//ALI_RE_Attorney_Combined:FirmSize/text())
      ,map:put($response-obj ,'GC_TITLE', $res//ALI_RE_Attorney_Combined:GC_TITLE/text())
      ,map:put($response-obj ,'TEST', fn:string($cities))
    )

    return $response-obj   
};

declare function attorney:GetAttorneysAdvanceSearchMLQueryFirmList(
  $pageNo
  ,$pageSize
  ,$query
  ,$cities
  ,$states
  ,$countries
  ,$geoGraphicRegion
  ,$usRegions
  ,$keywords
  ,$firms
  ,$sortBy
  ,$sortDirection
  ,$practiceAreas
  )
{
  let $response-arr := json:array()

  let $Keywords := $keywords
  
  let $locationQuery := if($cities ne '' or $states ne '' or $countries ne '' or $geoGraphicRegion ne '' or $usRegions ne '') 
    then 
    cts:or-query((
      if($cities ne '') then cts:element-value-query(xs:QName('ALI_RE_Attorney_Combined:city'),fn:tokenize($cities,',')) else(),
      if($states ne '') then cts:element-value-query(xs:QName('ALI_RE_Attorney_Combined:state'),fn:tokenize($states,',')) else(),
      if($countries ne '') then cts:element-value-query(xs:QName('ALI_RE_Attorney_Combined:country'),fn:tokenize($countries,',')) else(),
      if($geoGraphicRegion ne '') then cts:element-value-query(xs:QName('ALI_RE_Attorney_Combined:geographic_region'),fn:tokenize($geoGraphicRegion,',')) else(),
      if($usRegions ne '') then cts:element-value-query(xs:QName('ALI_RE_Attorney_Combined:us_region'),fn:tokenize($usRegions,',')) else()
    ))
    else ()

  let $keywordQuery := if($Keywords !='') then
			
							if(fn:contains(fn:lower-case($Keywords),'and') and fn:not(fn:contains(fn:lower-case($Keywords),'"'))) then 
								 attorney:GetAndOperatorQuery($Keywords)
													
							
							else if(fn:contains(fn:lower-case($Keywords),'or') and fn:not(fn:contains(fn:lower-case($Keywords),'"'))) then 
								 attorney:GetOrOperatorQuery($Keywords)
													
							else if(fn:contains(fn:lower-case($Keywords),'"') and fn:contains(fn:lower-case($Keywords),'" or "')) then 
								 attorney:GetExactOrOperatorQuery($Keywords)

              else if(fn:contains(fn:lower-case($Keywords),'"') and fn:contains(fn:lower-case($Keywords),' or ')) then 
								 attorney:GetExactOrOperatorQuery($Keywords)	    
										
							else if(fn:contains(fn:lower-case($Keywords),'"') and fn:contains(fn:lower-case($Keywords),'" and "')) then 
								 attorney:GetExactAndOperatorQuery($Keywords)

              else if(fn:contains(fn:lower-case($Keywords),'"') and fn:contains(fn:lower-case($Keywords),' and ')) then 
								 attorney:GetExactAndOperatorQuery($Keywords)   			
										
							else if(fn:contains(fn:lower-case($Keywords),' or ') and fn:contains(fn:lower-case($Keywords),' and ')) then 
								 attorney:GetAndOrOperatorQuery($Keywords)
							
							else if(fn:contains($Keywords,',') and fn:not(fn:contains(fn:lower-case($Keywords),'"'))) then 
								   cts:or-query((
									cts:element-word-query(xs:QName('ALI_RE_Attorney_Combined:Keywords'),fn:tokenize($Keywords,','),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('ALI_RE_Attorney_Combined:education'),fn:tokenize($Keywords,','),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('ALI_RE_Attorney_Combined:practices'),fn:tokenize($Keywords,','),('wildcarded','case-insensitive'))
								))
								else if(fn:contains($Keywords,' ') and fn:not(fn:contains(fn:lower-case($Keywords),'"'))) then 
								   cts:or-query((
									cts:element-word-query(xs:QName('ALI_RE_Attorney_Combined:Keywords'),fn:tokenize($Keywords,' '),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('ALI_RE_Attorney_Combined:education'),fn:tokenize($Keywords,' '),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('ALI_RE_Attorney_Combined:practices'),fn:tokenize($Keywords,' '),('wildcarded','case-insensitive'))
								))
								else cts:or-query((
										cts:element-word-query(xs:QName('ALI_RE_Attorney_Combined:Keywords'),fn:replace($Keywords,'"',''),('wildcarded','case-insensitive')),
										cts:element-word-query(xs:QName('ALI_RE_Attorney_Combined:education'),fn:replace($Keywords,'"',''),('wildcarded','case-insensitive')),
										cts:element-word-query(xs:QName('ALI_RE_Attorney_Combined:practices'),fn:replace($Keywords,'"',''),('wildcarded','case-insensitive'))
										))
							
					else ()    
  
  let $results := cts:element-values(xs:QName('ALI_RE_Attorney_Combined:ali_id'),(),(),
    cts:and-query((
      cts:directory-query('/LegalCompass/relational-data/ALI_RE_Attorney_Combined/')
      ,if($query ne '') then xdmp:value($query) else ()
      ,cts:and-query(($locationQuery))
      ,$keywordQuery
      ,if($practiceAreas ne '') then cts:element-value-query(xs:QName('ALI_RE_Attorney_Combined:practice_area'),fn:tokenize($practiceAreas,'[|]')) else ()
      ))
    ) 

  for $res in $results
    let $response-obj := json:object()

    let $_ := (
      map:put($response-obj ,'AliID', $res)
      )

    return $response-obj

};

declare function attorney:GetAndOperatorQuery($Keywords)
{
	let $query := cts:or-query((
										cts:and-query((
										for $item in fn:tokenize(fn:lower-case($Keywords),' and ')
										
											return 
											
											 cts:element-word-query(xs:QName('ALI_RE_Attorney_Combined:Keywords'),$item,('wildcarded','case-insensitive'))
											 
											
										)),
										
										cts:and-query((for $item in fn:tokenize(fn:lower-case($Keywords),' and ')
										
											return 
											
											 cts:element-word-query(xs:QName('ALI_RE_Attorney_Combined:education'),$item,('wildcarded','case-insensitive'))
											
											
										)),
										
										cts:and-query((for $item in fn:tokenize(fn:lower-case($Keywords),' and ')
										
											return 
											
											 cts:element-word-query(xs:QName('ALI_RE_Attorney_Combined:practices'),$item,('wildcarded','case-insensitive'))
										))
										
										))
	return $query									
};

declare function attorney:GetOrOperatorQuery($Keywords)
{
	let $query := cts:or-query((
										cts:or-query((
										for $item in fn:tokenize(fn:lower-case($Keywords),' or ')
										
											return 
											
											 cts:element-word-query(xs:QName('ALI_RE_Attorney_Combined:Keywords'),fn:concat('*',$item,'*'),('wildcarded','case-insensitive'))
											 
											
										)),
										
										cts:or-query((for $item in fn:tokenize(fn:lower-case($Keywords),' or ')
										
											return 
											
											 cts:element-word-query(xs:QName('ALI_RE_Attorney_Combined:education'),fn:concat('*',$item,'*'),('wildcarded','case-insensitive'))
											
											
										)),
										
										cts:or-query((for $item in fn:tokenize(fn:lower-case($Keywords),' or ')
										
											return 
											
											 cts:element-word-query(xs:QName('ALI_RE_Attorney_Combined:practices'),fn:concat('*',$item,'*'),('wildcarded','case-insensitive'))
										))
										
										))
										
	return $query									
};

declare function attorney:GetExactOrOperatorQuery($Keywords)
{
	let $query := cts:or-query((
										cts:or-query((
										for $item in fn:tokenize(fn:lower-case($Keywords),' or ')
										
											return 
											
											 cts:element-word-query(xs:QName('ALI_RE_Attorney_Combined:Keywords'),fn:replace($item,'"',''),('case-insensitive'))
											 
											
										)),
										
										cts:or-query((for $item in fn:tokenize(fn:lower-case($Keywords),' or ')
										
											return 
											
											 cts:element-word-query(xs:QName('ALI_RE_Attorney_Combined:education'),fn:replace($item,'"',''),('case-insensitive'))
											
											
										)),
										
										cts:or-query((for $item in fn:tokenize(fn:lower-case($Keywords),' or ')
										
											return 
											
											 cts:element-word-query(xs:QName('ALI_RE_Attorney_Combined:practices'),fn:replace($item,'"',''),('case-insensitive'))
										))
										
										))
	return $query									
};

declare function attorney:GetExactAndOperatorQuery($Keywords)
{
	let $query := cts:or-query((
										cts:and-query((
										for $item in fn:tokenize(fn:lower-case($Keywords),' and ')
										
											return 
											
											 cts:element-word-query(xs:QName('ALI_RE_Attorney_Combined:Keywords'),fn:replace($item,'"',''),('case-insensitive'))
											 
											
										)),
										
										cts:and-query((for $item in fn:tokenize(fn:lower-case($Keywords),' and ')
										
											return 
											
											 cts:element-word-query(xs:QName('ALI_RE_Attorney_Combined:education'),fn:replace($item,'"',''),('case-insensitive'))
											
											
										)),
										
										cts:and-query((for $item in fn:tokenize(fn:lower-case($Keywords),' and ')
										
											return 
											
											 cts:element-word-query(xs:QName('ALI_RE_Attorney_Combined:practices'),fn:replace($item,'"',''),('case-insensitive'))
										))
										
										))
	return $query									
};

declare function attorney:GetAndOrOperatorQuery($keyword)
{
	let $key := fn:tokenize($keyword,' or ')
	for $Keywords in $key
		let $query := cts:or-query((
											cts:and-query((
											for $item in fn:tokenize(fn:lower-case($Keywords),' and ')
											
												return 
												
												 cts:element-word-query(xs:QName('ALI_RE_Attorney_Combined:Keywords'),fn:concat('*' , fn:replace($item,'"','') , '*'),('wildcarded','case-insensitive'))
												 
												
											)),
											
											cts:and-query((for $item in fn:tokenize(fn:lower-case($Keywords),' and ')
											
												return 
												
												 cts:element-word-query(xs:QName('ALI_RE_Attorney_Combined:education'),fn:concat('*' , fn:replace($item,'"','') , '*'),('wildcarded','case-insensitive'))
												
												
											)),
											
											cts:and-query((for $item in fn:tokenize(fn:lower-case($Keywords),' and ')
											
												return 
												
												 cts:element-word-query(xs:QName('ALI_RE_Attorney_Combined:practices'),fn:concat('*' , fn:replace($item,'"','') , '*'),('wildcarded','case-insensitive'))
											))
											
											))
		return $query
		
		
};

(:----------------------------------- Keyword helper function -----------------------------------:)

 declare function attorney:GetAndOperatorQueryLateral($Keywords)
{
	let $query := cts:or-query((
										cts:and-query((
										for $item in fn:tokenize(fn:lower-case($Keywords),' and ')
										
											return 
											
											 cts:element-word-query(xs:QName('lateralmoves:edu'),$item,('wildcarded','case-insensitive'))
											 
											
										)),
										
										cts:and-query((for $item in fn:tokenize(fn:lower-case($Keywords),' and ')
										
											return 
											
											 cts:element-word-query(xs:QName('lateralmoves:detail_text'),$item,('wildcarded','case-insensitive'))
											
											
										)),
										
										cts:and-query((for $item in fn:tokenize(fn:lower-case($Keywords),' and ')
										
											return 
											
											 cts:element-word-query(xs:QName('lateralmoves:practice_area'),$item,('wildcarded','case-insensitive'))
										))
										
										))
	return $query									
};

declare function attorney:GetOrOperatorQueryLateral($Keywords)
{
	let $query := cts:or-query((
										cts:or-query((
										for $item in fn:tokenize(fn:lower-case($Keywords),' or ')
										
											return 
											
											 cts:element-word-query(xs:QName('lateralmoves:edu'),fn:concat('*',$item,'*'),('wildcarded','case-insensitive'))
											 
											
										)),
										
										cts:or-query((for $item in fn:tokenize(fn:lower-case($Keywords),' or ')
										
											return 
											
											 cts:element-word-query(xs:QName('lateralmoves:detail_text'),fn:concat('*',$item,'*'),('wildcarded','case-insensitive'))
											
											
										)),
										
										cts:or-query((for $item in fn:tokenize(fn:lower-case($Keywords),' or ')
										
											return 
											
											 cts:element-word-query(xs:QName('lateralmoves:practice_area'),fn:concat('*',$item,'*'),('wildcarded','case-insensitive'))
										))
										
										))
										
	return $query									
};

declare function attorney:GetExactOrOperatorQueryLateral($Keywords)
{
	let $query := cts:or-query((
										cts:or-query((
										for $item in fn:tokenize(fn:lower-case($Keywords),' or ')
										
											return 
											
											 cts:element-word-query(xs:QName('lateralmoves:edu'),fn:replace($item,'"',''),('case-insensitive'))
											 
											
										)),
										
										cts:or-query((for $item in fn:tokenize(fn:lower-case($Keywords),' or ')
										
											return 
											
											 cts:element-word-query(xs:QName('lateralmoves:detail_text'),fn:replace($item,'"',''),('case-insensitive'))
											
											
										)),
										
										cts:or-query((for $item in fn:tokenize(fn:lower-case($Keywords),' or ')
										
											return 
											
											 cts:element-word-query(xs:QName('lateralmoves:practice_area'),fn:replace($item,'"',''),('case-insensitive'))
										))
										
										))
	return $query									
};

declare function attorney:GetExactAndOperatorQueryLateral($Keywords)
{
	let $query := cts:or-query((
										cts:and-query((
										for $item in fn:tokenize(fn:lower-case($Keywords),' and ')
										
											return 
											
											 cts:element-word-query(xs:QName('lateralmoves:edu'),fn:replace($item,'"',''),('case-insensitive'))
											 
											
										)),
										
										cts:and-query((for $item in fn:tokenize(fn:lower-case($Keywords),' and ')
										
											return 
											
											 cts:element-word-query(xs:QName('lateralmoves:detail_text'),fn:replace($item,'"',''),('case-insensitive'))
											
											
										)),
										
										cts:and-query((for $item in fn:tokenize(fn:lower-case($Keywords),' and ')
										
											return 
											
											 cts:element-word-query(xs:QName('lateralmoves:practice_area'),fn:replace($item,'"',''),('case-insensitive'))
										))
										
										))
	return $query									
};

declare function attorney:GetAndOrOperatorQueryLateral($keyword)
{
	let $key := fn:tokenize($keyword,' or ')
	for $Keywords in $key
		let $query := cts:or-query((
											cts:and-query((
											for $item in fn:tokenize(fn:lower-case($Keywords),' and ')
											
												return 
												
												 cts:element-word-query(xs:QName('lateralmoves:edu'),fn:concat('*' , fn:replace($item,'"','') , '*'),('wildcarded','case-insensitive'))
												 
												
											)),
											
											cts:and-query((for $item in fn:tokenize(fn:lower-case($Keywords),' and ')
											
												return 
												
												 cts:element-word-query(xs:QName('lateralmoves:detail_text'),fn:concat('*' , fn:replace($item,'"','') , '*'),('wildcarded','case-insensitive'))
												
												
											)),
											
											cts:and-query((for $item in fn:tokenize(fn:lower-case($Keywords),' and ')
											
												return 
												
												 cts:element-word-query(xs:QName('lateralmoves:practice_area'),fn:concat('*' , fn:replace($item,'"','') , '*'),('wildcarded','case-insensitive'))
											))
											
											))
		return $query
		
		
};

declare function attorney:GetLawyerMovesFirmID(
	 $firmID
	,$lastAction
	,$fromDate
	,$toDate
	,$title
	,$practiceAreas
	,$attorneyName
	,$lawSchoolNames
	,$city
	,$state
	,$country
	,$geographicRegion
	,$usRegion
	,$sortBy
	,$sortDirection
	,$pageNo
	,$pageSize
  ,$genderType
  ,$isPrimaryPracticeArea
  ,$Keywords
)

{
  let $res-array := json:array()
  let $fromRecord := if($pageNo ne '1') then (xs:int($pageNo)-1)*xs:int($pageSize) else 1
  let $toRecord := xs:int($pageSize)*xs:int($pageNo)
  let $direction := if($sortDirection eq 'asc') then 'ascending' else 'descending'
  let $lawSchoolNm := fn:tokenize($lawSchoolNames,'[|]')

  let $isPrimaryPracticeArea := if($isPrimaryPracticeArea ne '') then $isPrimaryPracticeArea else 'false'
  
  let $gender := if(fn:contains($genderType,';')) then ('M','F','Male','Female') else if($genderType eq 'Male') then ('M','Male') else ('F','Female')

  let $firmIDs := if($firmID ne '') then fn:tokenize($firmID,',') else()
  let $action := if($lastAction ne '') then fn:tokenize($lastAction,',') else()
  let $titles := if($title ne '') then fn:tokenize($title,',') else()
  let $cities := if($city !='') then for $item in fn:tokenize($city,',')
							return fn:replace($item , '-',', ')
		else ()
  let $states := if($state ne '') then fn:tokenize($state,',') else()
  let $countries := if($country ne '') then fn:tokenize($country,',') else()
  let $geographicRegions := if($geographicRegion ne '') then fn:tokenize($geographicRegion,',') else()
  let $usRegions := if($usRegion != '') then 'USA' else()
  let $practiceArea := if($practiceAreas ne '') then fn:tokenize($practiceAreas,'[|]') else()
  (: let $attorneyName := if($attorneyName ne '') then fn:replace($attorneyName,'[+]|[*]','') else():)
  let $attorneyName := if($attorneyName ne '') then fn:replace($attorneyName,'[+]','') else()
  let $attorneyName := if($attorneyName ne '') then fn:replace($attorneyName,'[*]','') else()
  let $attName := if($attorneyName ne '') then fn:replace($attorneyName,',',' ') else()
  

  let $attCount := if($attName != '') then count($attName) else 0                  
  
  
  let $orderBy := if($sortBy eq 'FirmName') then cts:index-order(cts:element-reference(xs:QName('lateralmoves:Company_Name')) ,$direction)
                  else if($sortBy eq 'Action') then cts:index-order(cts:element-reference(xs:QName('lateralmoves:action')) ,$direction)
                       else if($sortBy eq 'Date') then cts:index-order(cts:element-reference(xs:QName('lateralmoves:date_added')) ,$direction)
                            else if($sortBy eq 'Name') then cts:index-order(cts:element-reference(xs:QName('lateralmoves:Attorney_Name')) ,$direction)
                                 else if($sortBy eq 'Title') then cts:index-order(cts:element-reference(xs:QName('lateralmoves:Title')) ,$direction)
                                      else if($sortBy eq 'PracticeArea') then cts:index-order(cts:element-reference(xs:QName('lateralmoves:practices')) ,$direction)
                                           else if($sortBy eq 'Location') then cts:index-order(cts:element-reference(xs:QName('lateralmoves:Location')) ,$direction)
                                              else if($sortBy eq 'PreTitle') then cts:index-order(cts:element-reference(xs:QName('lateralmoves:PreTitle')) ,$direction)
                                                else()

  let $keyword_q := if($Keywords !='') then
			
							if(fn:contains(fn:lower-case($Keywords),'and') and fn:not(fn:contains(fn:lower-case($Keywords),'"'))) then 
								 attorney:GetAndOperatorQueryLateral($Keywords)
													
							
							else if(fn:contains(fn:lower-case($Keywords),'or') and fn:not(fn:contains(fn:lower-case($Keywords),'"'))) then 
								 attorney:GetOrOperatorQueryLateral($Keywords)
													
							else if(fn:contains(fn:lower-case($Keywords),'"') and fn:contains(fn:lower-case($Keywords),'" or "')) then 
								 attorney:GetExactOrOperatorQueryLateral($Keywords)

              else if(fn:contains(fn:lower-case($Keywords),'"') and fn:contains(fn:lower-case($Keywords),' or ')) then 
								 attorney:GetExactOrOperatorQueryLateral($Keywords)   
										
							else if(fn:contains(fn:lower-case($Keywords),'"') and fn:contains(fn:lower-case($Keywords),'" and "')) then 
								 attorney:GetExactAndOperatorQueryLateral($Keywords)

              	else if(fn:contains(fn:lower-case($Keywords),'"') and fn:contains(fn:lower-case($Keywords),' and ')) then 
								 attorney:GetExactAndOperatorQueryLateral($Keywords)   			
										
							else if(fn:contains(fn:lower-case($Keywords),' or ') and fn:contains(fn:lower-case($Keywords),' and ')) then 
								 attorney:GetAndOrOperatorQueryLateral($Keywords)
							
							(:else if(fn:contains(fn:lower-case($Keywords),'"') and fn:not(fn:contains(fn:lower-case($Keywords),'" and "')) and fn:not(fn:contains(fn:lower-case($Keywords),'" or "'))) then 
								 event:GetExactAndOperatorQuery($Keywords)	:)
							
							else if(fn:contains($Keywords,',') and fn:not(fn:contains(fn:lower-case($Keywords),'"'))) then 
								   cts:or-query((
									cts:element-word-query(xs:QName('lateralmoves:edu'),fn:tokenize($Keywords,','),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('lateralmoves:detail_text'),fn:tokenize($Keywords,','),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('lateralmoves:practice_area'),fn:tokenize($Keywords,','),('wildcarded','case-insensitive'))
								))

								else if(fn:contains($Keywords,' ') and fn:not(fn:contains(fn:lower-case($Keywords),'"'))) then 
								   cts:or-query((
										cts:element-word-query(xs:QName('lateralmoves:edu'),fn:tokenize($Keywords,','),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('lateralmoves:detail_text'),fn:tokenize($Keywords,','),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('lateralmoves:practice_area'),fn:tokenize($Keywords,','),('wildcarded','case-insensitive'))
								))
								else cts:or-query((
											cts:element-word-query(xs:QName('lateralmoves:edu'),fn:concat('*' , fn:replace($Keywords,'"',''),'*'),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('lateralmoves:detail_text'),fn:concat('*' , fn:replace($Keywords,'"',''),'*'),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('lateralmoves:practice_area'),fn:concat('*' , fn:replace($Keywords,'"',''),'*'),('wildcarded','case-insensitive'))
										))
							
					else ()                                              
                                              
	
	
  let $andQuery := cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/ALI_RE_LateralMoves_Data/'),
						cts:not-query(cts:element-value-query(xs:QName('lateralmoves:PreTitle'),'Administrative / Support Staff')),
                          if($firmID ne '') then cts:or-query((
												cts:element-value-query(xs:QName('lateralmoves:company_Id'),$firmIDs) ,
												cts:and-query((
													cts:element-value-query(xs:QName('lateralmoves:CompanyId_From'),$firmIDs),
													cts:element-value-query(xs:QName('lateralmoves:action'),'removed')
													)),
												cts:and-query((	
												cts:element-value-query(xs:QName('lateralmoves:CompanyId_To'),$firmIDs),
												cts:element-value-query(xs:QName('lateralmoves:action'),'added')
												))
												)) else(),
                          if($lastAction ne '') then cts:element-value-query(xs:QName('lateralmoves:action'),$action)
						  else cts:element-value-query(xs:QName('lateralmoves:action'),('added','removed','updated')),
                         if($fromDate ne '' and $toDate ne '') then cts:and-query((
										 cts:not-query(cts:element-value-query(xs:QName('lateralmoves:date_added'),('0/0/0000',''))),
                                               cts:element-range-query(xs:QName('lateralmoves:date_added'),'>=',xs:date($fromDate)),
                                               cts:element-range-query(xs:QName('lateralmoves:date_added'),'<=',xs:date($toDate)))) else(),
                         if($titles ne '') then cts:element-value-query(xs:QName('lateralmoves:Title'),$titles) else(),
                         if($practiceAreas ne '') then if(xs:string($isPrimaryPracticeArea) ne 'true') then cts:element-word-query(xs:QName('lateralmoves:practices'),$practiceArea,("wildcarded","case-sensitive"))
                                                else cts:element-word-query(xs:QName('lateralmoves:primary_practice'),$practiceArea,("wildcarded","case-sensitive"))
                         else(),
                         $keyword_q,
              	 if($attCount gt 0) then cts:and-query((
                                                for $item in fn:tokenize($attName,' ')
                                                             return cts:element-word-query(xs:QName('lateralmoves:Attorney_Name'),fn:concat('*' , fn:normalize-space($item) ,'*') ,("wildcarded",'case-insensitive'))
                     )) else(), 
						 
                         if($lawSchoolNames ne '') then cts:element-word-query(xs:QName('lateralmoves:edu'),$lawSchoolNm ,('wildcarded',"case-sensitive")) else(),
             
                         
						              if($city != '' or $state ne '' or $country ne '' or $usRegion ne '' or $geographicRegion ne '') then cts:or-query((
                              if($city != '') then cts:element-value-query(xs:QName('lateralmoves:std_loc'),$cities) else(),
                              if($state ne '') then cts:element-value-query(xs:QName('lateralmoves:state'),$states) else(),
                              if($country ne '') then cts:element-value-query(xs:QName('lateralmoves:country'),$countries) else(),
                              if($usRegion ne '') then cts:element-value-query(xs:QName('lateralmoves:country'),$usRegions) else(),
                              if($geographicRegion ne '') then cts:element-value-query(xs:QName('lateralmoves:geographic_region'),$geographicRegions) else())) else(),
                         if($genderType ne '') then cts:element-value-query(xs:QName('lateralmoves:gender'),$gender,('case-insensitive')) else(),
                          cts:or-query((
                      cts:not-query(cts:element-value-query(xs:QName('lateralmoves:CompanyId_From'),'')),
                      cts:not-query(cts:element-value-query(xs:QName('lateralmoves:CompanyId_To'),''))
                       ))
                         ))
	
	
  let $search-obj := json:array()
  
  let $res := cts:values(cts:element-reference(xs:QName('lateralmoves:CompanyID_ALI')),(),(),$andQuery)
  let $loopData := for $item in $res
                      let $resObj := json:object()
                      let $_ := map:put($resObj , 'firmID' , $item)
                      let $_ := json:array-push($search-obj, $resObj)
                      return ()

  let $resObj := json:object()
  let $_ := map:put($resObj , 'selectedFirms' , $search-obj)
 return $search-obj
};