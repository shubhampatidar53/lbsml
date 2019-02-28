 xquery version '1.0-ml';

module namespace company = 'http://alm.com/company_1';

import module namespace config = 'http://alm.com/config' at '/common/config.xqy';
import module namespace search = 'http://marklogic.com/appservices/search' at '/MarkLogic/appservices/search/search.xqy';

declare namespace util = 'http://alm.com/util';
declare namespace ps = 'http://developer.marklogic.com/2006-09-paginated-search';
(:declare namespace ns = 'http://alm.com/LegalCompass/rd/TOP500';:)
declare namespace companyprofile='http://alm.com/LegalCompass/rd/COMPANYPROFILE_DETAILS';
declare namespace companyprofilecontacts='http://alm.com/LegalCompass/rd/COMPANYPROFILE_CONTACTS';
declare namespace top500 = 'http://alm.com/LegalCompass/rd/TOP500';
declare namespace top500contactdetail ='http://alm.com/LegalCompass/rd/TOP500_CONTACTDETAILS_NEW';
declare namespace companynews='http://alm.com/LegalCompass/rd/companyprofile_news';
declare namespace companycompetitors = 'http://alm.com/LegalCompass/rd/companyprofile_competitors';
declare namespace companysubsdairies = 'http://alm.com/LegalCompass/rd/companyprofile_subsdaries';
declare namespace representationtype= 'http://alm.com/LegalCompass/rd/REPRESENTATION_TYPES';
declare namespace companyprofilelfr = 'http://alm.com/LegalCompass/rd/COMPANYPROFILE_LFR';
declare namespace companyprofiledetails = 'http://alm.com/LegalCompass/rd/COMPANYPROFILE_DETAILS';
declare namespace organizationns = 'http://alm.com/LegalCompass/rd/organization';
declare namespace whoconsolewho = 'http://alm.com/LegalCompass/rd/Who_Counsels_who';
declare namespace companyprofilelfrnew = 'http://alm.com/LegalCompass/rd/COMPANYPROFILE_LFR_NEW';
declare namespace bdbstransaction ='http://alm.com/LegalCompass/rd/bdbs-transaction';
declare namespace bdbsrepresenter = 'http://alm.com/LegalCompass/rd/bdbs-representer';
declare namespace bdbsparty = 'http://alm.com/LegalCompass/rd/bdbs-party';
declare namespace companyreportpath ='http://alm.com/LegalCompass/rd/CompanyProfileReportFiles';


declare function company:IsOverviewExists($scopeID)
{
	  let $searchResult := cts:search(/,
							cts:and-query((
							   cts:directory-query('/LegalCompass/relational-data/COMPANYPROFILE_DETAILS/'),
							   cts:element-value-query(xs:QName('companyprofile:SCOPEID'),$scopeID)
	  )))
	  return $searchResult//companyprofile:COMPANY_ID/text()
};

declare function company:GetFileName($companyID,$format)
{
	  let $searchResult := cts:search(/,
							cts:and-query((
							   cts:directory-query('/LegalCompass/relational-data/CompanyProfileReportFiles/'),
							   cts:element-value-query(xs:QName('companyreportpath:COMPANY_ID'),$companyID),
							   cts:element-value-query(xs:QName('companyreportpath:FORMAT'),$format,('case-insensitive')),
							   cts:element-value-query(xs:QName('companyreportpath:ISGENERATED'),'1')
	  )))
	  
	  return json:to-array($searchResult//companyreportpath:FILE_PATH/text())
};

declare function company:IsCompanyExists($scopeID)
{
	  let $searchResult := cts:search(/,
							cts:and-query((
							   cts:directory-query('/LegalCompass/relational-data/COMPANYPROFILE_DETAILS/'),
							   cts:element-value-query(xs:QName('companyprofiledetails:SCOPEID'),$scopeID)
						    )))[1]//companyprofiledetails:COMPANY_ID/text()
	  for $item in $searchResult
					    let $companyProfileContact := cts:search(/,
							cts:and-query((
							   cts:directory-query('/LegalCompass/relational-data/COMPANYPROFILE_CONTACTS/'),
							   cts:element-value-query(xs:QName('companyprofilecontacts:COMPANY_ID'),$item)
						    )))[1]//companyprofilecontacts:COMPANY_ID/text()	
							
						let $companyProfileLFRID := cts:search(/,
							cts:and-query((
							   cts:directory-query('/LegalCompass/relational-data/COMPANYPROFILE_LFR/'),
							   cts:element-value-query(xs:QName('companyprofilelfr:COMPANY_ID'),$item)
						    )))[1]//companyprofilelfr:COMPANY_ID/text()	
						
						let $companyID := if($companyProfileContact ne '' and $companyProfileLFRID ne '')
										  then $item else()
						
						return $companyID
		
};

declare function company:GetCompanyIdByScopeId($scopeID , $companyName)
{                  
    let $search :=cts:search(/,
      cts:and-query((
        cts:directory-query('/LegalCompass/relational-data/surveys/TOP500/'),
        cts:element-value-query(xs:QName('top500:SCOPEID'),$scopeID)
      )))[1]//top500:COMPANY_ID/text()
	  
	return $search  
};

declare function company:IsLFRExists($scopeID)
{
	  let $searchResult := cts:search(/,
							cts:and-query((
							   cts:directory-query('/LegalCompass/relational-data/COMPANYPROFILE_LFR/'),
							   cts:element-value-query(xs:QName('companyprofilelfr:SCOPEID'),$scopeID)
	  )))[1]
	  return $searchResult//companyprofilelfr:SCOPEID/string()
};

declare function company:IsCompanyExistsForPacer($scopeID)
{
	  let $searchResult := cts:search(/,
							cts:and-query((
							   cts:directory-query('/LegalCompass/relational-data/COMPANYPROFILE_LFR_NEW/'),
							   cts:element-value-query(xs:QName('companyprofilelfrnew:SCOPEID'),$scopeID)
	  )))[1]
	  return $searchResult//companyprofilelfrnew:COMPANY_ID/text()
};

declare function company:GetCompanyDetail($company_Id, $scopeID)
{
  let $response-arr := json:array()
  let $searchResult :=cts:search(/COMPANYPROFILE_DETAILS,
                        cts:and-query((
                           cts:directory-query('/LegalCompass/relational-data/COMPANYPROFILE_DETAILS/'),
                           cts:element-value-query(xs:QName('companyprofile:SCOPEID'),$scopeID)
  )))
  
	let $loopData := for $company in $searchResult
					  let $response-obj := json:object()
					  let $_ :=(map:put($response-obj,'CompanyName',$company/companyprofile:COMPANYNAME/text()),
								map:put($response-obj,'CompanyId',$company/companyprofile:COMPANY_ID/text()),
								map:put($response-obj,'Address',$company/companyprofile:ADDRESS/text()),
								map:put($response-obj,'Address2',$company/companyprofile:ADDRESS2/text()),
								map:put($response-obj,'City',$company/companyprofile:ZIP/text()),
								map:put($response-obj,'Zip',$company/companyprofile:STATE/text()),
								map:put($response-obj,'State',$company/companyprofile:ADDRESS2/text()),
								map:put($response-obj,'Fax',$company/companyprofile:FAX/text()),
								map:put($response-obj,'Phone',$company/companyprofile:PHONE/text()),
								map:put($response-obj,'LastYearsRevenue',$company/companyprofile:LASTYEARSREVENUE/text()),
								
								(:--------pending---------:)
								map:put($response-obj,'RevenueYear',if($company/companyprofile:REVENUEYEAR/text() eq '') then 
								xs:int(fn:year-from-dateTime(xs:dateTime(fn:current-date())))-1 else $company/companyprofile:REVENUEYEAR/text()),
								map:put($response-obj,'Website',$company/companyprofile:WEBSITE/text()),
								map:put($response-obj,'NumberOfEmployees',$company/companyprofile:NUMBEROFEMPLOYEES/text()),
								map:put($response-obj,'Industry',$company/companyprofile:INDUSTRY/text()),
								map:put($response-obj,'Country',$company/companyprofile:COUNTRY/text()),
								map:put($response-obj,'Email',$company/companyprofile:EMAIL/text()),
								map:put($response-obj,'Logo',$company/companyprofile:LOGO/text()),
								map:put($response-obj,'DescriptionText',$company/companyprofile:DESCRIPTIONTEXT/text()),
								map:put($response-obj,'StockSymbol',$company/companyprofile:STOCKSYMBOL/text()),
								map:put($response-obj,'HeadQuaters',$company/companyprofile:HEADQUATERS/text()),
								map:put($response-obj,'InternationalPresence',$company/companyprofile:INTERNATIONALPRESENCE/text()),
								map:put($response-obj,'NoOfStores',$company/companyprofile:NOOFSTORES/text())
								)
					 
					  let $_ := json:array-push($response-arr,$response-obj)
					  return()
      return $response-arr
};

declare function company:IsContactExists($scopeID)
{
  let $searchResult := cts:search(/COMPANYPROFILE_CONTACTS,
                        cts:and-query((
                           cts:directory-query('/LegalCompass/relational-data/COMPANYPROFILE_CONTACTS/'),
                           cts:element-value-query(xs:QName('companyprofilecontacts:SCOPEID'),$scopeID)
  )))[1]
  return $searchResult//companyprofilecontacts:COMPANY_ID/string()
};

declare function company:GetCompanyExecutivesContacts($companyID, $scopeID)
{
  
        let $response-arr := json:array()
        let $searchResult := cts:search(/COMPANYPROFILE_CONTACTS,
                              cts:and-query((
                                 cts:directory-query('/LegalCompass/relational-data/COMPANYPROFILE_CONTACTS/'),
                                 cts:element-value-query(xs:QName('companyprofilecontacts:SCOPEID'),$scopeID),
                                 cts:not-query(cts:element-value-query(xs:QName('companyprofilecontacts:TITLETYPE'), '')),
                                 cts:not-query(cts:element-value-query(xs:QName('companyprofilecontacts:FIRSTNAME'), ''))
        )))

          let $list :=for $companyExecutive in $searchResult
                          let $response-obj := json:object()
                          let $_ :=(map:put($response-obj,'FirstName',$companyExecutive/companyprofilecontacts:FIRSTNAME/text()),
                                    map:put($response-obj,'Education',$companyExecutive/companyprofilecontacts:EDUCATION/text()),
                                    map:put($response-obj,'MiddleName',$companyExecutive/companyprofilecontacts:MIDDLENAME/text()),
                                    map:put($response-obj,'LastName',$companyExecutive/companyprofilecontacts:LASTNAME/text()),
                                    map:put($response-obj,'Title',$companyExecutive/companyprofilecontacts:TITLE/text()),
                                    map:put($response-obj,'Email',$companyExecutive/companyprofilecontacts:EMAIL/text()),
                                    map:put($response-obj,'Phone',$companyExecutive/companyprofilecontacts:PHONE/text()),
                                    map:put($response-obj,'Fax',$companyExecutive/companyprofilecontacts:FAX/text()),
                                    map:put($response-obj,'BioLink',$companyExecutive/companyprofilecontacts:BIOLINK/text()),
                                    map:put($response-obj,'Biography',$companyExecutive/companyprofilecontacts:BIOGRAPHY/text())
                                    )

                          let $_ := json:array-push($response-arr,$response-obj)
                      return ()
          return $response-arr
};

declare function company:GetCompanyDetailByName($companyName , $companyID )
{
    let $response_array := json:array()
    let $maxGCID := company:getMaxGCTop500IDByCompID($companyID)
                   
    let $search :=cts:search(/TOP500,
      cts:and-query((
        cts:directory-query('/LegalCompass/relational-data/surveys/TOP500/'),
        cts:element-value-query(xs:QName('top500:GC_TOP500_ID'),xs:string($maxGCID))
      )))
      
    let $loopData := for $item in $search
      let $response_obj := json:object()
      let $_ := (map:put($response_obj,'Company_name',$item/top500:COMPANY_NAME/text()),
                 map:put($response_obj,'Company_id',$item/top500:COMPANY_ID/text()),
                 map:put($response_obj,'ADDRESS_LINE_1',$item/top500:ADDRESS_LINE_1/text()),
                 map:put($response_obj,'ADDRESS_LINE_2',$item/top500:ADDRESS_LINE_2/text()),
                 map:put($response_obj,'city',$item/top500:CITY/text()),
                 map:put($response_obj,'state',$item/top500:STATE/text()),
                 map:put($response_obj,'zip',$item/top500:ZIP/text()),
                 map:put($response_obj,'telephone',$item/top500:TELEPHONE/text()),
                 map:put($response_obj,'revenue',$item/top500:REVENUE/text()),
                 map:put($response_obj,'url',$item/top500:URL/text()),
                 map:put($response_obj,'NUMBER_OF_EMPLOYEES',$item/top500:NUMBER_OF_EMPLOYEES/text()),
                 map:put($response_obj,'PRIMARY_INDUSTRY',$item/top500:PRIMARY_INDUSTRY/text())
                 )
                 
        let $_ :=json:array-push($response_array,$response_obj)
        return()
      return $response_array
};

declare function company:GetCompanyExecutives($companyName , $companyID)
{
   let $response_array := json:array()
   let $search := cts:search(/TOP500_CONTACTDETAILS_NEW,
						cts:and-query((
						  cts:directory-query('/LegalCompass/relational-data/surveys/TOP500_CONTACTDETAILS_NEW/'),
						  cts:element-value-query(xs:QName('top500contactdetail:ORGANIZATION_ID'),$companyID)
						)))
   
   let $a :=for $item in $search
     let $response_obj :=json:object()
     let $_ :=(map:put($response_obj,'FIRSTNAME',$item/top500contactdetail:FIRSTNAME/text()),
               map:put($response_obj,'MIDDLENAME',$item/top500contactdetail:MIDDLENAME/text()),
               map:put($response_obj,'LASTNAME',$item/top500contactdetail:LASTNAME/text()),
               map:put($response_obj,'TITLE',$item/top500contactdetail:TITLE/text()),
               map:put($response_obj,'TITLETYPE',$item/top500contactdetail:TITLETYPE/text()),
               map:put($response_obj,'Phone',$item/top500contactdetail:PHONE/text()),
			   map:put($response_obj,'Email',$item/top500contactdetail:EMAIL/text()),
               map:put($response_obj,'DISPLAYPRIORITY',$item/top500contactdetail:DISPLAYPRIORITY/text())
               )
   let $_ :=json:array-push($response_array,$response_obj)
   return ()
   return $response_array
};

declare function company:IsNewsExists($companyID)
{
  let $result := cts:search(/COMPANYPROFILE_NEWS,
                    cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/ALI/companyprofile_news/'),
                        cts:element-value-query(xs:QName('companynews:COMPANY_ID'),$companyID)
                    )))[1]
  return $result/companynews:COMPANY_ID/text()
};

declare function company:GetCompanyProfileNews($companyID ,$fromDate, $toDate)
{
  let $response-array :=json:array() 
  let $result :=    cts:search(/,
                          cts:and-query((
                              cts:directory-query('/LegalCompass/relational-data/ALI/companyprofile_news/'),
                              cts:element-value-query(xs:QName('companynews:COMPANY_ID'),$companyID),
                              if($fromDate ne '' and $toDate ne '') then cts:and-query((
									cts:element-range-query(xs:QName('companynews:NEWSDATE'),'>=',xs:date($fromDate)),
									cts:element-range-query(xs:QName('companynews:NEWSDATE'),'<=',xs:date($toDate)))) else()
									)))
                         
                 
  let $loopData := for $item in $result
                        let $response-obj :=json:object()
                        let $_ :=(map:put($response-obj,'Headline',$item//companynews:HEADLINE/text()),
                                  map:put($response-obj,'NewsURL',$item//companynews:NEWSURL/text()),
                                  map:put($response-obj,'Summary',$item//companynews:SUMMARY/text()),
                                  map:put($response-obj,'NewsPublisher',$item//companynews:NEWSPUBLISHER/text()),
                                  map:put($response-obj,'NewsDate',$item//companynews:NEWSDATE/text()))
                        let $_ := json:array-push($response-array,$response-obj)
                   return()
                   
  return $response-array
};

declare function company:IsCompeExists($scopeID)
{
  let $result := cts:search(/COMPANYPROFILE_COMPETITORS,
                    cts:and-query((
                      cts:directory-query('/LegalCompass/relational-data/ALI/companyprofile_competitors/'),
                      cts:element-value-query(xs:QName('companycompetitors:SCOPEID'),$scopeID))
                    ))[1]
  return fn:count($result)
};

declare function company:GetCompanyCompetitor($companyID,$scopeID)
{
  let $response-array :=json:array()
  let $orderBy := cts:index-order(cts:element-reference(xs:QName('companycompetitors:COMPANYNAME')) ,'ascending')
  let $result := cts:search(/COMPANYPROFILE_COMPETITORS,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/ALI/companyprofile_competitors/'),
                        cts:element-value-query(xs:QName('companycompetitors:SCOPEID'),$scopeID))
                      ),$orderBy)
  let $loopData := for $item in $result
                      let $response-obj := json:object()
                      let $_ := (map:put($response-obj,'CompanyName',$item/companycompetitors:COMPANYNAME/text()),
                                 map:put($response-obj,'CompanyScopeID',$item/companycompetitors:COMPANYSCOPEID/text()),
                                 map:put($response-obj,'CompanyID',$item/companycompetitors:COMPANY_ID_CMP/text())
                                 )
                      let $_ := json:array-push($response-array,$response-obj)
                      return ()
  return $response-array
};

declare function company:GetCompanyProfileCompetitorsDetails($scopeID,$companyName,$companyID)
{
  let $response-array :=json:array()
  let $result := if($scopeID ne '') then cts:search(/TOP500,
					  cts:and-query((
						cts:directory-query('/LegalCompass/relational-data/surveys/TOP500/'),
						cts:element-value-query(xs:QName('top500:SCOPEID'),$scopeID)))) 
				 else if($companyID ne '') then cts:search(/TOP500,
					  cts:and-query((
						cts:directory-query('/LegalCompass/relational-data/surveys/TOP500/'),
						cts:element-value-query(xs:QName('top500:COMPANY_ID'),$companyID)))) else() 
					
                      
   let $primaryIndustry :=$result/top500:PRIMARY_INDUSTRY/text()
   let $result1:=cts:search(/TOP500,
                    cts:and-query((
                      cts:directory-query('/LegalCompass/relational-data/surveys/TOP500/'),
                      cts:element-value-query(xs:QName('top500:PRIMARY_INDUSTRY'),$primaryIndustry),
					  cts:not-query(cts:element-value-query(xs:QName('top500:COMPANY_ID'),xs:string($companyID))))
                    ))
   let $loopData:= for $item in $result1
                       let $response-obj := json:object()
                       let $_ := (map:put($response-obj,'CompanyScopeID',$item/top500:SCOPEID/text()),
                                  map:put($response-obj,'CompanyName',$item/top500:COMPANY_NAME/text()),
                                  map:put($response-obj,'CompanyID',$item/top500:COMPANY_ID/text())
                                 )
                      let $_ :=json:array-push($response-array,$response-obj)
                      return ()
  return $response-array
   
};

declare function company:IsSubsiExists($scopeID)
{
    let $result :=cts:search(/,
                    cts:and-query((
                      cts:directory-query('/LegalCompass/relational-data/ALI/companyprofile_subsdaries/'),
                      cts:element-value-query(xs:QName('companysubsdairies:SCOPEID'),$scopeID)
                    )))[1]
    return fn:count($result)
};

declare function company:GetCompanySubsidaries($companyID,$scopeID)
{
  let $response-array :=json:array()
  let $result :=cts:search(/COMPANYPROFILE_SUBSDARIES,
                    cts:and-query((
                      cts:directory-query('/LegalCompass/relational-data/ALI/companyprofile_subsdaries/'),
                      cts:element-value-query(xs:QName('companysubsdairies:SCOPEID'),$scopeID))
                    ))
                    
  let $loopData := for $item in $result
                       let $response-obj := json:object()
                       let $_ := (map:put($response-obj,'Subsidiaryname',$item/companysubsdairies:SUBSIDIARYNAME/text()))
                       let $_ := json:array-push($response-array,$response-obj)
                       return()
                       
  return $response-array
};

declare function company:GetCompanyExecutivesEx($companyName ,$companyID ,$titleType)
{
   let $response_array := json:array()
   let $search := cts:search(/TOP500_CONTACTDETAILS_NEW,
                                                cts:and-query((
                                                  cts:directory-query('/LegalCompass/relational-data/surveys/TOP500_CONTACTDETAILS_NEW/'),
                                                  if($companyName ne '') then cts:element-value-query(xs:QName('top500contactdetail:COMPANYNAME'),$companyName) else(),
												  if($companyID ne '') then cts:element-value-query(xs:QName('top500contactdetail:ORGANIZATION_ID'),$companyID) else(),
                                                  cts:not-query(cts:element-word-query(xs:QName('top500contactdetail:TITLE'),'counsel',('wildcarded','case-insensitive')))
                                                )))
                
   
   let $a :=for $item in $search
     let $response_obj :=json:object()
     let $_ :=(map:put($response_obj,'FIRSTNAME',$item/top500contactdetail:FIRSTNAME/text()),
               map:put($response_obj,'MIDDLENAME',$item/top500contactdetail:MIDDLENAME/text()),
               map:put($response_obj,'NICKNAME',$item/top500contactdetail:NICKNAME/text()),
               map:put($response_obj,'LASTNAME',$item/top500contactdetail:LASTNAME/text()),
               map:put($response_obj,'TITLE',$item/top500contactdetail:TITLE/text()),
               map:put($response_obj,'Email',$item/top500contactdetail:EMAIL/text()),
               map:put($response_obj,'Phone',$item/top500contactdetail:PHONE/text()),
               map:put($response_obj,'Fax',$item/top500contactdetail:FAX/text()),
               map:put($response_obj,'Education',$item/top500contactdetail:EDUCATION/text()),
               map:put($response_obj,'CompanyName',$item/top500contactdetail:COMPANYNAME/text()),
               map:put($response_obj,'TitleType',$item/top500contactdetail:TITLETYPE/text())
               )
   let $_ :=json:array-push($response_array,$response_obj)
   return ()
   return $response_array
};

declare function company:GetGeneralCounsel($companyName ,$companyID ,$titleType)
{
   let $response_array := json:array()
   let $search :=if($companyName ne '') then cts:search(/TOP500_CONTACTDETAILS_NEW,
                                                cts:and-query((
                                                  cts:directory-query('/LegalCompass/relational-data/surveys/TOP500_CONTACTDETAILS_NEW/'),
                                                  cts:element-value-query(xs:QName('top500contactdetail:COMPANYNAME'),$companyName),
                                                  cts:element-word-query(xs:QName('top500contactdetail:TITLE'),'counsel',('wildcarded','case-insensitive','whitespace-insensitive'))
                                                )))
                 else if($companyID ne '') then cts:search(/TOP500_CONTACTDETAILS_NEW,
                                                cts:and-query((
                                                  cts:directory-query('/LegalCompass/relational-data/surveys/TOP500_CONTACTDETAILS_NEW/'),
                                                  cts:element-value-query(xs:QName('top500contactdetail:ORGANIZATION_ID'),$companyID),
                                                  cts:element-word-query(xs:QName('top500contactdetail:TITLE'),'counsel',('wildcarded','case-insensitive','whitespace-insensitive'))
                                                ))) else()
   
   let $a :=for $item in $search
     let $response_obj :=json:object()
     let $_ :=(map:put($response_obj,'FIRSTNAME',$item/top500contactdetail:FIRSTNAME/text()),
               map:put($response_obj,'MIDDLENAME',$item/top500contactdetail:MIDDLENAME/text()),
               map:put($response_obj,'NICKNAME',$item/top500contactdetail:NICKNAME/text()),
               map:put($response_obj,'LASTNAME',$item/top500contactdetail:LASTNAME/text()),
               map:put($response_obj,'TITLE',$item/top500contactdetail:TITLE/text()),
               map:put($response_obj,'Email',$item/top500contactdetail:EMAIL/text()),
               map:put($response_obj,'Phone',$item/top500contactdetail:PHONE/text()),
               map:put($response_obj,'Fax',$item/top500contactdetail:FAX/text()),
               map:put($response_obj,'Education',$item/top500contactdetail:EDUCATION/text()),
               map:put($response_obj,'CompanyName',$item/top500contactdetail:COMPANYNAME/text()),
               map:put($response_obj,'TitleType',$item/top500contactdetail:TITLETYPE/text())
               )
   let $_ :=json:array-push($response_array,$response_obj)
   return ()
   return $response_array
};

declare function company:GetCompanyGCContacts($companyID, $scopeID)
{
  
        let $response-arr := json:array()
        let $searchResult := cts:search(/COMPANYPROFILE_CONTACTS,
                              cts:and-query((
                                 cts:directory-query('/LegalCompass/relational-data/COMPANYPROFILE_CONTACTS/'),
                                 cts:element-value-query(xs:QName('companyprofilecontacts:SCOPEID'),$scopeID),
                                 cts:element-value-query(xs:QName('companyprofilecontacts:TITLETYPE'), 'GC'),
                                 cts:not-query(cts:element-value-query(xs:QName('companyprofilecontacts:FIRSTNAME'), ''))
        )))

          let $list :=for $companyExecutive in $searchResult
                          let $response-obj := json:object()
                          let $_ :=(map:put($response-obj,'FirstName',$companyExecutive/companyprofilecontacts:FIRSTNAME/text()),
                                    map:put($response-obj,'Education',$companyExecutive/companyprofilecontacts:EDUCATION/text()),
                                    map:put($response-obj,'MiddleName',$companyExecutive/companyprofilecontacts:MIDDLENAME/text()),
                                    map:put($response-obj,'LastName',$companyExecutive/companyprofilecontacts:LASTNAME/text()),
                                    map:put($response-obj,'Title',$companyExecutive/companyprofilecontacts:TITLE/text()),
                                    map:put($response-obj,'Email',$companyExecutive/companyprofilecontacts:EMAIL/text()),
                                    map:put($response-obj,'Phone',$companyExecutive/companyprofilecontacts:PHONE/text()),
                                    map:put($response-obj,'Fax',$companyExecutive/companyprofilecontacts:FAX/text()),
                                    map:put($response-obj,'BioLink',$companyExecutive/companyprofilecontacts:BIOLINK/text()),
                                    map:put($response-obj,'Biography',$companyExecutive/companyprofilecontacts:BIOGRAPHY/text())
                                    )

                          let $_ := json:array-push($response-arr,$response-obj)
                      return ()
          return $response-arr
};

declare function company:IsCompanyExist($scopeID)
{
    let $result := cts:search(/COMPANYPROFILE_DETAILS,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/COMPANYPROFILE_DETAILS/'),
                        cts:element-value-query(xs:QName('companyprofiledetails:SCOPEID'),$scopeID)
                      )))
	return fn:count($result)
};

declare function company:GetCompanyLFRSummary($level1,$level2)
{
    let $response-array := json:array()
  let $result := if($level2 ne '') then
                     cts:search(/REPRESENTATION_TYPES,
                     cts:and-query((
                         cts:directory-query('/LegalCompass/relational-data/REPRESENTATION_TYPES/'),
                         cts:element-value-query(xs:QName('representationtype:LEVEL_1'),$level1,'case-insensitive'),
                         cts:element-value-query(xs:QName('representationtype:LEVEL_2'),$level2,'case-insensitive')
                         )))
                         
                 else cts:search(/REPRESENTATION_TYPES,
                         cts:and-query((
                             cts:directory-query('/LegalCompass/relational-data/REPRESENTATION_TYPES/'),
                             cts:element-value-query(xs:QName('representationtype:LEVEL_1'),$level1)
                             )))
                             
 let $loopData :=  for $item in $result
                       let $response-obj :=json:object()
                       
                       let $_ := (map:put($response-obj,'REPRESENTATION_TYPE_ID',$item/representationtype:REPRESENTATION_TYPE_ID/text()),
                                  map:put($response-obj,'LEVEL1',$item/representationtype:LEVEL_1/text()),
                                  map:put($response-obj,'LEVEL2',$item/representationtype:LEVEL_2/text()))
                                  
                       let $_ := json:array-push($response-array,$response-obj)
                       return ($response-obj)
  
  return $response-array
};

declare function company:GetCompanyLFR($scopeID,$representationIDs,$yearFrom,$yearTo)
{
  let $response-array :=json:array()
  let $result := if($representationIDs ne '') 
                      then if($yearFrom ne '' and $yearTo ne '') 
                            then cts:search(/COMPANYPROFILE_LFR,
                                     cts:and-query((
                                           cts:directory-query('/LegalCompass/relational-data/COMPANYPROFILE_LFR/'),
                                           cts:element-value-query(xs:QName('companyprofilelfr:REPRESENTATION_TYPE_ID'),$representationIDs),
                                           cts:element-range-query(xs:QName('companyprofilelfr:YEAR'),'>=',xs:int($yearFrom)),
                                           cts:element-range-query(xs:QName('companyprofilelfr:YEAR'),'<=',xs:int($yearTo)),
                                           cts:element-value-query(xs:QName('companyprofilelfr:SCOPEID'),$scopeID)
                                           ))) else cts:search(/COMPANYPROFILE_LFR,
                                                         cts:and-query((
                                                               cts:directory-query('/LegalCompass/relational-data/COMPANYPROFILE_LFR/'),
                                                               cts:element-value-query(xs:QName('companyprofilelfr:REPRESENTATION_TYPE_ID'),$representationIDs),
                                                               cts:element-value-query(xs:QName('companyprofilelfr:SCOPEID'),$scopeID)
                                                               )))
                else if ($yearFrom ne '' and $yearTo ne '')
                            then cts:search(/COMPANYPROFILE_LFR,
                                  cts:and-query((
                                    cts:directory-query('/LegalCompass/relational-data/COMPANYPROFILE_LFR/'),
                                    cts:element-range-query(xs:QName('companyprofilelfr:YEAR'),'>=',xs:int($yearFrom)),
                                    cts:element-range-query(xs:QName('companyprofilelfr:YEAR'),'<=',xs:int($yearTo)),
                                    cts:not-query(cts:element-value-query(xs:QName('companyprofilelfr:YEAR'),'between Harris and The Bank of New York Mellon Trust Company',('case-insensitive'))),
                                    cts:element-value-query(xs:QName('companyprofilelfr:SCOPEID'),$scopeID)
                                  )))
                      else cts:search(/COMPANYPROFILE_LFR,
                                  cts:and-query((
                                  cts:directory-query('/LegalCompass/relational-data/COMPANYPROFILE_LFR/'),
                                  cts:element-value-query(xs:QName('companyprofilelfr:SCOPEID'),$scopeID)
                                  )))
  let $loopData := for $item in $result
                      let $response-obj := json:object()
                      let $_ := (map:put($response-obj,'Jurisdiction',$item/companyprofilelfr:JURISDICTION/text()),
                                 map:put($response-obj,'Firm',company:GetOrganizationName($item/companyprofilelfr:FIRM_ID/text())),
                                 map:put($response-obj,'Year',$item/companyprofilelfr:YEAR/text()),
                                 map:put($response-obj,'Role',$item/companyprofilelfr:ROLE/text()),
                                 map:put($response-obj,'value',$item/companyprofilelfr:VALUE/text()),
                                 map:put($response-obj,'Details',$item/companyprofilelfr:DETAILS/text()),
                                 map:put($response-obj,'Source',$item/companyprofilelfr:SOURCE/text()),
                                 map:put($response-obj,'CaseName',$item/companyprofilelfr:CASENAME/text()),
                                 map:put($response-obj,'TypeofCase',$item/companyprofilelfr:TYPEOFCASE/text()),
                                 map:put($response-obj,'DocketNumber',$item/companyprofilelfr:DOCKETNUMBER/text()),
                                 map:put($response-obj,'PatentNumber',$item/companyprofilelfr:PATENTNUMBER/text()),
                                 map:put($response-obj,'SortDate',$item/companyprofilelfr:SORTDATE/text()),
                                 map:put($response-obj,'TypeOfRepresentation',$item/companyprofilelfr:TYPEOFREPRESENTATION/text()),
                                 map:put($response-obj,'FirmId',$item/companyprofilelfr:COMPANY_ID/text())
                                 )
                      let $_ := json:array-push($response-array,$response-obj)
                      return()
  return $response-array
};

declare function company:GetCompanyProfileLawFirmRepresentationsDB($scopeID,$representationIDs,$yearFrom,$yearTo,$companyID)
{
    let $response-array := json:array()
    let $result := cts:search(/,
                                         cts:and-query((
                                               cts:directory-query('/LegalCompass/relational-data/surveys/Who_Counsels_who/'),
											   if($companyID ne '') then cts:element-value-query(xs:QName('whoconsolewho:ORGANIZATION_ID'),fn:tokenize($companyID,',')) else (),
                                               if($representationIDs ne '') then cts:element-value-query(xs:QName('whoconsolewho:REPRESENTATION_TYPE_ID'),fn:tokenize($representationIDs,',')) else (),
                                               if($yearFrom ne '' and $yearTo ne '') then cts:and-query((cts:element-range-query(xs:QName('whoconsolewho:FISCAL_YEAR'),'>=' ,xs:int($yearFrom)),
															  cts:element-range-query(xs:QName('whoconsolewho:FISCAL_YEAR'),'<=',xs:int($yearTo)))) else()
                                              
                                               )))
	
               
      let $loopData := for $item in $result
                           let $response-obj := json:object()
                           let $_ := (map:put($response-obj,'LAWFIRM',$item//whoconsolewho:OUTSIDE_COUNSEL_NAME/text()),
                                      map:put($response-obj,'LAWFIRMID',$item//whoconsolewho:OUTSIDE_COUNSEL_ID/text()),
                                      map:put($response-obj,'REPRESENTATION_TYPE',$item//whoconsolewho:STD_REPRESENTATION_TYPE/text()),
                                      map:put($response-obj,'Jurisdiction',''),
                                      map:put($response-obj,'PUBLICATIONYEAR',$item//whoconsolewho:PUBLICATIONYEAR/text()),
                                      map:put($response-obj,'PARTY_ROLE',''),
                                      map:put($response-obj,'VALUE',''),
                                      map:put($response-obj,'Details',''),
                                      map:put($response-obj,'SOURCE',$item//whoconsolewho:WHOCOUNSELSWHO_SOURCE/text()),
                                      map:put($response-obj,'PUBLICATIONYEAR',$item//whoconsolewho:FISCAL_YEAR/text()),
                                      map:put($response-obj,'PublicationMonth','')
                                      )
                            let $_ :=json:array-push($response-array,$response-obj)
                            return()
    
                            (:---------- UNION PART -------------:)
     
    let $transactionID := cts:search(/,
                                         cts:and-query((
                                               cts:directory-query('/LegalCompass/relational-data/bdbs-party/'),
                                               if($companyID ne '') then cts:element-value-query(xs:QName('bdbsparty:ORGANIZATION_ID'),$companyID) else()
                                               )))//bdbsparty:TRANSACTION_ID/text()
    let $partyID := cts:search(/,
                                         cts:and-query((
                                               cts:directory-query('/LegalCompass/relational-data/bdbs-party/'),
                                               if($companyID ne '') then cts:element-value-query(xs:QName('bdbsparty:ORGANIZATION_ID'),$companyID) else()
                                               )))//bdbsparty:PARTY_ID/text()                                              
   
    let $bdbsrepresentors1 := cts:search(/,
                                         cts:and-query((
                                               cts:directory-query('/LegalCompass/relational-data/bdbs-representer/'),
                                               cts:element-value-query(xs:QName('bdbsrepresenter:PARTY_ID'), $partyID)
                                               )))                                              
                                               
    let $loopData1 := for $item in $bdbsrepresentors1
                        let $res-obj := json:object()
                        
                        let $bdbsparty := cts:search(/,
                                           cts:and-query((
                                               cts:directory-query('/LegalCompass/relational-data/bdbs-party/'),
                                               cts:element-value-query(xs:QName('bdbsparty:PARTY_ID'),$item//bdbsrepresenter:PARTY_ID/text())
                                               )))     
                                                                   
                        let $bdbs-transaction := cts:search(/,
                                         cts:and-query((
                                               cts:directory-query('/LegalCompass/relational-data/bdbs-transaction/'),
                                               cts:element-value-query(xs:QName('bdbstransaction:TRANSACTION_ID'),$bdbsparty//bdbsparty:TRANSACTION_ID/text()),
                                               if($yearFrom ne '' and $yearTo ne '') then cts:and-query((
                                                           cts:element-range-query(xs:QName('bdbstransaction:YEAR'),'>=',xs:integer($yearFrom)),
                                                           cts:element-range-query(xs:QName('bdbstransaction:YEAR'),'<=',xs:integer($yearTo))))
                                               else(),
											   if($representationIDs ne '') then cts:element-value-query(xs:QName('bdbstransaction:TRANSACTION_TYPE_ID'),fn:tokenize($representationIDs,',')) else()
                                               )))
											   
                       let $orgName := if($bdbs-transaction//bdbstransaction:NAME/text() ne '') then fn:concat('CaseName: ',$bdbs-transaction//bdbstransaction:NAME/text())
                                       else()
                       let $_ := (map:put($res-obj,'LAWFIRM',$item//bdbsrepresenter:ORGANIZATION_NAME/text()),
                                  map:put($res-obj,'LAWFIRMID',$item//bdbsrepresenter:ORGANIZATION_ID/text()),
                                  map:put($res-obj,'REPRESENTATION_TYPE',$bdbs-transaction//bdbstransaction:STD_TRANSACTION_TYPE/text()),
                                  map:put($res-obj,'PUBLICATIONYEAR',$bdbs-transaction//bdbstransaction:YEAR/text()),
                                  map:put($res-obj,'PARTY_ROLE',$bdbsparty//bdbsparty:PARTY_ROLE/text()),
                                  map:put($res-obj,'VALUE',$bdbs-transaction//bdbstransaction:VALUE/text()),
                                  map:put($res-obj,'Details',$orgName),
                                  map:put($res-obj,'SOURCE','ALM Legal Intelligence - Big Deals/Big Suits'),
                                  map:put($res-obj,'PublicationMonth',$bdbs-transaction//bdbstransaction:MONTH/text()),
                                  map:put($res-obj,'PUBLICATIONYEAR',$bdbs-transaction//bdbstransaction:YEAR/text()))
                      let $_ := if($bdbs-transaction//bdbstransaction:YEAR/text() ne '' or $bdbs-transaction//bdbstransaction:YEAR/text() ne '0') then json:array-push($response-array,$res-obj) else()
                      return()
  
  return $response-array
};

declare function company:GetUnionData($companyID,$startYear,$endYear)
{
    let $res-array := json:array()
    let $transactionID := cts:search(/,
                                         cts:and-query((
                                               cts:directory-query('/LegalCompass/relational-data/bdbs-party/'),
                                               if($companyID ne '') then cts:element-value-query(xs:QName('bdbsparty:ORGANIZATION_ID'),$companyID) else()
                                               )))//bdbsparty:TRANSACTION_ID/text()
    let $partyID := cts:search(/,
                                         cts:and-query((
                                               cts:directory-query('/LegalCompass/relational-data/bdbs-party/'),
                                               if($companyID ne '') then cts:element-value-query(xs:QName('bdbsparty:ORGANIZATION_ID'),$companyID) else()
                                               )))//bdbsparty:PARTY_ID/text()                                              
   
    let $bdbsrepresentors1 := cts:search(/,
                                         cts:and-query((
                                               cts:directory-query('/LegalCompass/relational-data/bdbs-representer/'),
                                               cts:element-value-query(xs:QName('bdbsrepresenter:PARTY_ID'), $partyID)
                                               )))                                              
                                               
    let $loopData := for $item in $bdbsrepresentors1
                        let $res-obj := json:object()
                        
                        let $bdbsparty := cts:search(/,
                                           cts:and-query((
                                               cts:directory-query('/LegalCompass/relational-data/bdbs-party/'),
                                               cts:element-value-query(xs:QName('bdbsparty:PARTY_ID'),$item//bdbsrepresenter:PARTY_ID/text())
                                               )))     
                                                                   
                        let $bdbs-transaction := cts:search(/,
                                         cts:and-query((
                                               cts:directory-query('/LegalCompass/relational-data/bdbs-transaction/'),
                                               cts:element-value-query(xs:QName('bdbstransaction:TRANSACTION_ID'),$bdbsparty//bdbsparty:TRANSACTION_ID/text()),
                                               if($startYear ne '' and $endYear ne '') then cts:and-query((
                                                           cts:element-range-query(xs:QName('bdbstransaction:YEAR'),'>=',xs:integer($startYear)),
                                                           cts:element-range-query(xs:QName('bdbstransaction:YEAR'),'<=',xs:integer($endYear))))
                                               else()
                                               ))) 
                       let $orgName := if($bdbs-transaction//bdbstransaction:NAME/text() ne '') then fn:concat('CaseName: ',$bdbs-transaction//bdbstransaction:NAME/text())
                                       else()
                       let $_ := (map:put($res-obj,'LAWFIRM',$item//bdbsrepresenter:ORGANIZATION_NAME/text()),
                                  map:put($res-obj,'LAWFIRMID',$item//bdbsrepresenter:ORGANIZATION_ID/text()),
                                  map:put($res-obj,'REPRESENTATION_TYPE',$bdbs-transaction//bdbstransaction:STD_TRANSACTION_TYPE/text()),
                                  map:put($res-obj,'PUBLICATIONYEAR',$bdbs-transaction//bdbstransaction:YEAR/text()),
                                  map:put($res-obj,'PARTY_ROLE',$bdbsparty//bdbsparty:PARTY_ROLE/text()),
                                  map:put($res-obj,'VALUE',$bdbs-transaction//bdbstransaction:VALUE/text()),
                                  map:put($res-obj,'Details',$orgName),
                                  map:put($res-obj,'SOURCE','ALM Legal Intelligence - Big Deals/Big Suits'),
                                  map:put($res-obj,'PublicationMonth',$bdbs-transaction//bdbstransaction:MONTH/text()),
                                  map:put($res-obj,'PUBLICATIONYEAR',$bdbs-transaction//bdbstransaction:YEAR/text()))
                      let $_ := json:array-push($res-array,$res-obj)   
                      return()
    return $res-array
   }; 

(:declare function company:GetUnionData($scopeID,$representationIDs,$yearFrom,$yearTo,$companyID)
{
  let $result := cts:search(/bdbs-transaction,
                                         cts:and-query((
                                               cts:directory-query('/LegalCompass/relational-data/bdbs-party/'),
                                               if($representationIDs ne '') then cts:element-value-query(xs:QName('bdbstransaction:TRANSACTION_TYPE_ID'),fn:tokenize($representationIDs,',')) else(),
                                               if($yearFrom ne '' and $yearTo ne '') then cts:and-query((cts:element-range-query(xs:QName('bdbstransaction:YEAR'),'>=',xs:int($yearFrom)),
															  cts:element-range-query(xs:QName('bdbstransaction:YEAR'),'<=',xs:int($yearTo)))) else(),
                                               if($companyID ne '') then cts:element-value-query(xs:QName('bdbstransaction:ORGANIZATION_ID'),$companyID) else()
                                               )))

  (:if($companyID ne '') then 
                        if($representationIDs ne '') 
                          then if($yearFrom ne '' and $yearTo ne '') 
                                then cts:search(/bdbs-transaction,
                                         cts:and-query((
                                               cts:directory-query('/LegalCompass/relational-data/bdbs-party/'),
                                               cts:element-value-query(xs:QName('bdbstransaction:TRANSACTION_TYPE_ID'),$representationIDs),
                                               cts:element-range-query(xs:QName('bdbstransaction:YEAR'),'>=',xs:int($yearFrom)),
                                               cts:element-range-query(xs:QName('bdbstransaction:YEAR'),'<=',xs:int($yearTo)),
                                               cts:element-value-query(xs:QName('bdbstransaction:ORGANIZATION_ID'),$companyID)
                                               ))) else cts:search(/COMPANYPROFILE_LFR,
                                                             cts:and-query((
                                                                   cts:directory-query('/LegalCompass/relational-data/bdbs-party/'),
                                                                   cts:element-value-query(xs:QName('bdbstransaction:TRANSACTION_TYPE_ID'),$representationIDs),
                                                                   cts:element-value-query(xs:QName('bdbstransaction:ORGANIZATION_ID'),$companyID)
                                                                   )))
                      else if ($yearFrom ne '' and $yearTo ne '')
                                then cts:search(/bdbs-transaction,
                                         cts:and-query((
                                               cts:directory-query('/LegalCompass/relational-data/bdbs-party/'),
                                               cts:element-range-query(xs:QName('bdbstransaction:YEAR'),'>=',xs:int($yearFrom)),
                                               cts:element-range-query(xs:QName('bdbstransaction:YEAR'),'<=',xs:int($yearTo)),
                                               cts:element-value-query(xs:QName('bdbstransaction:ORGANIZATION_ID'),$companyID)
                                               )))
                          else cts:search(/bdbs-transaction,
                                      cts:and-query((
                                      cts:directory-query('/LegalCompass/relational-data/bdbs-party/'),
                                      cts:element-value-query(xs:QName('bdbstransaction:ORGANIZATION_ID'),$companyID)
                                      )))
            else if($representationIDs ne '') 
                          then if($yearFrom ne '' and $yearTo ne '') 
                                then cts:search(/,
                                         cts:and-query((
                                               cts:directory-query('/LegalCompass/relational-data/bdbs-party/'),
                                               cts:element-value-query(xs:QName('bdbstransaction:TRANSACTION_TYPE_ID'),$representationIDs),
                                               cts:element-range-query(xs:QName('bdbstransaction:YEAR'),'>=',xs:int($yearFrom)),
                                               cts:element-range-query(xs:QName('bdbstransaction:YEAR'),'<=',xs:int($yearTo)),
                                               cts:element-value-query(xs:QName('bdbstransaction:ORGANIZATION_ID'),company:GetCompanyID($scopeID))
                                               ))) else cts:search(/COMPANYPROFILE_LFR,
                                                             cts:and-query((
                                                                   cts:directory-query('/LegalCompass/relational-data/bdbs-party/'),
                                                                   cts:element-value-query(xs:QName('bdbstransaction:TRANSACTION_TYPE_ID'),$representationIDs),
                                                                   cts:element-value-query(xs:QName('bdbstransaction:ORGANIZATION_ID'),company:GetCompanyID($scopeID))
                                                                   )))
                      else if ($yearFrom ne '' and $yearTo ne '')
                                then cts:search(/bdbs-transaction,
                                      cts:and-query((
                                        cts:directory-query('/LegalCompass/relational-data/bdbs-party/'),
                                        cts:element-range-query(xs:QName('bdbstransaction:YEAR'),'>=',xs:int($yearFrom)),
                                        cts:element-range-query(xs:QName('bdbstransaction:YEAR'),'<=',xs:int($yearTo)),
                                        cts:not-query(cts:element-value-query(xs:QName('bdbstransaction:YEAR'),'between Harris and The Bank of New York Mellon Trust Company',('case-insensitive'))),
                                        cts:element-value-query(xs:QName('bdbsparty:ORGANIZATION_ID'),company:GetCompanyID($scopeID))
                                      )))
                          else cts:search(/bdbs-transaction,
                                      cts:and-query((
                                      cts:directory-query('/LegalCompass/relational-data/bdbs-party/'),
                                      cts:element-value-query(xs:QName('bdbsparty:ORGANIZATION_ID'),company:GetCompanyID($scopeID))
                                      ))):)
                                      
    return $result

};:)

declare function company:GetCompanyID($scopeID as xs:string)
{
   let $result := cts:search(/TOP500,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/surveys/TOP500/'),
                        cts:element-value-query(xs:QName('top500:SCOPEID'),$scopeID)
                      )))[1]
  return $result//top500:COMPANY_ID/text()
};

declare function company:GetOrganization($partyID as xs:string)
{
   let $result := cts:search(/bdbs-representer,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/bdbs-representer/'),
                        cts:element-value-query(xs:QName('bdbsrepresenter:PARTY_ID'),$partyID)
                      )))[1]
  return $result
};

declare function company:GetPartyRole($transactionID as xs:string)
{
   let $result := cts:search(/,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/bdbs-party/'),
                        cts:element-value-query(xs:QName('bdbsparty:TRANSACTION_ID'),$transactionID)
                      )))[1]
  return $result
};

declare function company:GetCompanyLFRSummaryEx($scopeID,$yearFrom,$yearTo)
{
  let $response-array := json:array() 
  let $result :=cts:search(/COMPANYPROFILE_LFR,
                  cts:and-query((
                      cts:directory-query('/LegalCompass/relational-data/COMPANYPROFILE_LFR/'),
                      cts:element-value-query(xs:QName('companyprofilelfr:SCOPEID'),$scopeID),
                      cts:not-query(cts:element-value-query(xs:QName('companyprofilelfr:FIRM'),'')),
                      cts:not-query(cts:element-value-query(xs:QName('companyprofilelfr:FIRM_ID'),'0')),
                      if($yearFrom ne '0' and $yearTo ne '0') then cts:and-query((
                          cts:element-range-query(xs:QName('companyprofilelfr:YEAR'),'>=',xs:int($yearFrom)),
                          cts:element-range-query(xs:QName('companyprofilelfr:YEAR'),'<=',xs:int($yearTo)))) else()
                  )))//companyprofilelfr:FIRM_ID/text()

  let $firmIDsArray :='' 
  let $loopData := for $item in fn:distinct-values($result)
                           let $response-obj :=json:object()
						   let $reID :=fn:string-join(fn:distinct-values(cts:search(/COMPANYPROFILE_LFR,
											  cts:and-query((
												  cts:directory-query('/LegalCompass/relational-data/COMPANYPROFILE_LFR/'),
												  cts:element-value-query(xs:QName('companyprofilelfr:SCOPEID'),$scopeID),
												  cts:not-query(cts:element-value-query(xs:QName('companyprofilelfr:FIRM'),'')),
												  cts:not-query(cts:element-value-query(xs:QName('companyprofilelfr:REPRESENTATION_TYPE_ID'),'')),
												  cts:element-value-query(xs:QName('companyprofilelfr:FIRM_ID'),$item),
												  if($yearFrom ne '0' and $yearTo ne '0') then cts:and-query((cts:element-range-query(xs:QName('companyprofilelfr:YEAR'),'>=',xs:int($yearFrom)),
												  cts:element-range-query(xs:QName('companyprofilelfr:YEAR'),'<=',xs:int($yearTo)))) else ())))/companyprofilelfr:REPRESENTATION_TYPE_ID/text()),',')
                           (:let $reIDs := fn:tokenize(company:getRepresentationIDs($item,$yearFrom,$yearTo),','):)
                        let $ipReID := 	company:getRID('IP',$reID)	
					    let $trReID := 	company:getRID('Transactional',$reID)
						let $ltReID := 	company:getRID('Litigation',$reID)
                           (:let $reIDs := fn:tokenize(company:getRepresentationIDs($item,$yearFrom,$yearTo),','):)
                          
                       let $organizationName := company:GetOrganizationName($item)
                       let $level_1 :=company:getLevelFromRepresentation($item)
                       let $ipCount :=company:GetLevelCount($scopeID,$ipReID,$yearFrom,$yearTo,$item)
                       let $transactionCount := company:GetLevelCount($scopeID,$trReID,$yearFrom,$yearTo,$item)
                       let $litigation := company:GetLevelCount($scopeID,$ltReID,$yearFrom,$yearTo,$item)
                       let $totalCount :=company:GetLevelCount($scopeID,$reID,$yearFrom,$yearTo,$item)
                           let $_ := (map:put($response-obj,'LawFirm',$organizationName),
                                  map:put($response-obj,'FirmId',$item),
                                  map:put($response-obj,'Level_1',$level_1),
                                  map:put($response-obj,'IntellectualProperty',$ipCount),
                                  map:put($response-obj,'Transaction',$transactionCount),
                                  map:put($response-obj,'Litigation',$litigation),
                                  map:put($response-obj,'Total',$totalCount),
								  map:put($response-obj,'REID',$reID))

                          let $_ :=json:array-push($response-array , $response-obj)
                          return()
                      (:------------------ UNION ----------------------:)
                      
                      return company:GetCompanyLFRNewSummary($scopeID,$yearFrom,$yearTo,$response-array)
                      
    
};

declare function company:GetCompanyLFRNewSummary($scopeID,$yearFrom,$yearTo,$resJson)
{
  (:let $response-array := json:array() :)
  let $result := if($yearFrom ne '0' and $yearTo ne '0') then
                        cts:search(/COMPANYPROFILE_LFR_NEW,
                                 cts:and-query((
                                     cts:directory-query('/LegalCompass/relational-data/COMPANYPROFILE_LFR_NEW/'),
                                     cts:element-value-query(xs:QName('companyprofilelfrnew:SCOPEID'),$scopeID),
                                     cts:not-query(cts:element-value-query(xs:QName('companyprofilelfrnew:FIRM'),'')),
                                     cts:not-query(cts:element-value-query(xs:QName('companyprofilelfrnew:FIRM_ID'),'0')),
                                     cts:element-range-query(xs:QName('companyprofilelfrnew:YEAR'),'>=',xs:int($yearFrom)),
                                     cts:element-range-query(xs:QName('companyprofilelfrnew:YEAR'),'<=',xs:int($yearTo))
                                     )))
                  else cts:search(/COMPANYPROFILE_LFR_NEW,
                                 cts:and-query((
                                     cts:directory-query('/LegalCompass/relational-data/COMPANYPROFILE_LFR_NEW/'),
                                     cts:element-value-query(xs:QName('companyprofilelfrnew:SCOPEID'),$scopeID),
                                     cts:not-query(cts:element-value-query(xs:QName('companyprofilelfrnew:FIRM'),'')),
                                     cts:not-query(cts:element-value-query(xs:QName('companyprofilelfrnew:FIRM_ID'),'0'))
                                     )))                  

  let $loopData := for $item in fn:distinct-values($result/companyprofilelfrnew:FIRM_ID/text())
                       let $response-obj :=json:object()
                       let $reID := fn:string-join(fn:distinct-values(cts:search(/COMPANYPROFILE_LFR_NEW,
											  cts:and-query((
												  cts:directory-query('/LegalCompass/relational-data/COMPANYPROFILE_LFR_NEW/'),
												  cts:element-value-query(xs:QName('companyprofilelfrnew:SCOPEID'),$scopeID),
												  cts:not-query(cts:element-value-query(xs:QName('companyprofilelfrnew:FIRM'),'')),
												  cts:not-query(cts:element-value-query(xs:QName('companyprofilelfrnew:REPRESENTATION_TYPE_ID'),'')),
												  cts:element-value-query(xs:QName('companyprofilelfrnew:FIRM_ID'),$item),
												  if($yearFrom ne '0' and $yearTo ne '0') then cts:and-query((cts:element-range-query(xs:QName('companyprofilelfrnew:YEAR'),'>=',xs:int($yearFrom)),
												  cts:element-range-query(xs:QName('companyprofilelfrnew:YEAR'),'<=',xs:int($yearTo)))) else ())))/companyprofilelfrnew:REPRESENTATION_TYPE_ID/text()),',')
						let $ipReID := 	company:getRID('IP',$reID)	
					    let $trReID := 	company:getRID('Transactional',$reID)
						let $ltReID := 	company:getRID('Litigation',$reID)
                          
                       let $organizationName := company:GetOrganizationName($item)
                       let $level_1 :=company:getLevelFromRepresentation($item)
                       let $ipCount := company:GetLevelCountNew($scopeID,$ipReID,$yearFrom,$yearTo,$item)
                       let $transactionCount :=company:GetLevelCountNew($scopeID,$trReID,$yearFrom,$yearTo,$item)
                       let $litigation :=company:GetLevelCountNew($scopeID,$ltReID,$yearFrom,$yearTo,$item)
                       let $totalCount :=company:GetLevelCountNew($scopeID,$reID,$yearFrom,$yearTo,$item)
                       let $_ := (map:put($response-obj,'LawFirm',$organizationName),
                                  map:put($response-obj,'FirmId',$item),
                                  map:put($response-obj,'Level_1',$level_1),
                                  map:put($response-obj,'IntellectualProperty',$ipCount),
                                  map:put($response-obj,'Transaction',$transactionCount),
                                  map:put($response-obj,'Litigation',$litigation),
                                  map:put($response-obj,'Total',$totalCount),
								  map:put($response-obj,'REID',$reID))
                      let $_ :=json:array-push($resJson , $response-obj)
                      return()
   return $resJson
};

declare function company:GetOrganizationName($firmID as xs:string)
{
   let $result := cts:search(/,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/organization/'),
                        cts:element-value-query(xs:QName('organizationns:ORGANIZATION_ID'),$firmID)
                      )))[1]
  let $orgName := if($result//organizationns:ALM_NAME/text() ne '') then 
                          $result//organizationns:ALM_NAME/text() 
                  else $result//organizationns:ORGANIZATION_NAME/text()
                          
  return $orgName
};

declare function company:getLevelFromRepresentation($represtationID)
{
     let $result := cts:search(/REPRESENTATION_TYPES,
                      cts:and-query((
                         cts:directory-query('/LegalCompass/relational-data/REPRESENTATION_TYPES/'),
                         cts:element-value-query(xs:QName('representationtype:REPRESENTATION_TYPE_ID'),$represtationID)
                         )))[1]
    return $result/representationtype:LEVEL_1/text()               
};


declare function company:getRepresentationIDs($firmID,$yearFrom,$yearTo)
{
     let $result := cts:search(/COMPANYPROFILE_LFR,
                      cts:and-query((
                         cts:directory-query('/LegalCompass/relational-data/COMPANYPROFILE_LFR/'),
                         cts:element-value-query(xs:QName('companyprofilelfr:FIRM_ID'),$firmID),
                         cts:element-range-query(xs:QName('companyprofilelfr:YEAR'),'>=',xs:int($yearFrom)),
                         cts:element-range-query(xs:QName('companyprofilelfr:YEAR'),'<=',xs:int($yearTo))
                         )))
    return fn:string-join(fn:distinct-values($result/companyprofilelfr:REPRESENTATION_TYPE_ID/text()),',')
};

declare function company:getRID($levelType,$representationID)
{
  let $reIDs := fn:tokenize($representationID,',')
  let $result :=  cts:search(/REPRESENTATION_TYPES,
                          cts:and-query((
                             cts:directory-query('/LegalCompass/relational-data/REPRESENTATION_TYPES/'),
                             cts:element-value-query(xs:QName('representationtype:REPRESENTATION_TYPE_ID'),$reIDs),
                             cts:element-value-query(xs:QName('representationtype:LEVEL_1'),$levelType)
                             )))
  
  return fn:string-join($result/representationtype:REPRESENTATION_TYPE_ID/text(),',')
};

declare function company:GetLevelCount($scopeID,$reIDs,$yearFrom,$yearTo,$firmID)
{
	let $reID := fn:tokenize($reIDs,',')
	let $count := fn:count(cts:search(/COMPANYPROFILE_LFR,
											  cts:and-query((
												  cts:directory-query('/LegalCompass/relational-data/COMPANYPROFILE_LFR/'),
												  cts:element-value-query(xs:QName('companyprofilelfr:SCOPEID'),$scopeID),
												  cts:not-query(cts:element-value-query(xs:QName('companyprofilelfr:FIRM'),'')),
												  cts:not-query(cts:element-value-query(xs:QName('companyprofilelfr:REPRESENTATION_TYPE_ID'),'')),
												  cts:element-value-query(xs:QName('companyprofilelfr:REPRESENTATION_TYPE_ID'),$reID),
												  cts:element-value-query(xs:QName('companyprofilelfr:FIRM_ID'),$firmID),
												  if($yearFrom ne '0' and $yearTo ne '0') then cts:and-query((cts:element-range-query(xs:QName('companyprofilelfr:YEAR'),'>=',xs:int($yearFrom)),
												  cts:element-range-query(xs:QName('companyprofilelfr:YEAR'),'<=',xs:int($yearTo)))) else ())))/companyprofilelfr:REPRESENTATION_TYPE_ID/text())
	return $count
};

declare function company:GetLevelCountNew($scopeID,$reIDs,$yearFrom,$yearTo,$firmID)
{
	let $reID := fn:tokenize($reIDs,',')
	let $count := fn:count(cts:search(/COMPANYPROFILE_LFR_NEW,
											  cts:and-query((
												  cts:directory-query('/LegalCompass/relational-data/COMPANYPROFILE_LFR_NEW/'),
												  cts:element-value-query(xs:QName('companyprofilelfrnew:SCOPEID'),$scopeID),
												  cts:not-query(cts:element-value-query(xs:QName('companyprofilelfrnew:FIRM'),'')),
												  cts:not-query(cts:element-value-query(xs:QName('companyprofilelfrnew:REPRESENTATION_TYPE_ID'),'')),
												  cts:element-value-query(xs:QName('companyprofilelfrnew:REPRESENTATION_TYPE_ID'),$reID),
												  cts:element-value-query(xs:QName('companyprofilelfrnew:FIRM_ID'),$firmID),
												  if($yearFrom ne '0' and $yearTo ne '0') then cts:and-query((cts:element-range-query(xs:QName('companyprofilelfrnew:YEAR'),'>=',xs:int($yearFrom)),
												  cts:element-range-query(xs:QName('companyprofilelfrnew:YEAR'),'<=',xs:int($yearTo)))) else ())))/companyprofilelfrnew:REPRESENTATION_TYPE_ID/text())
	return $count
};

declare function company:getLevelCount($levelType,$representationID)
{
  let $reIDs := fn:tokenize($representationID,',')
  let $result := if($levelType ne 'IP' and $levelType ne 'Transactional' and $levelType ne 'Litigation' ) then
                      cts:search(/REPRESENTATION_TYPES,
                          cts:and-query((
                             cts:directory-query('/LegalCompass/relational-data/REPRESENTATION_TYPES/'),
                             cts:element-value-query(xs:QName('representationtype:REPRESENTATION_TYPE_ID'),$reIDs)
                             )))
                  else  cts:search(/REPRESENTATION_TYPES,
                          cts:and-query((
                             cts:directory-query('/LegalCompass/relational-data/REPRESENTATION_TYPES/'),
                             cts:element-value-query(xs:QName('representationtype:REPRESENTATION_TYPE_ID'),$reIDs),
                             cts:element-value-query(xs:QName('representationtype:LEVEL_1'),$levelType)
                             )))
  
  return fn:count($result/representationtype:LEVEL_1/text())
};

declare function company:GetAllIndustries()
{
  let $res-array :=json:array()
  let $result := cts:search(/TOP500,
    cts:and-query((
      cts:directory-query('/LegalCompass/relational-data/surveys/TOP500/')
    )))
  
  let $loopResult := for $item in fn:distinct-values($result/top500:PRIMARY_INDUSTRY/text())
                        let $res-obj := json:object()
                        let $_ := (map:put($res-obj,'IndustryName',$item))
                        let $_ := json:array-push($res-array,$res-obj)
                        return()
  return $res-array

};

declare function company:GetDistinctLocation($usRegion)
{
  let $response-array := json:array() 
  let $result := cts:search(/TOP500,
                    cts:and-query((
                      cts:directory-query('/LegalCompass/relational-data/surveys/TOP500/'),
                      cts:element-value-query(xs:QName('top500:US_REGIONS'),$usRegion,'case-insensitive')
                    )))
  let $loopData := for $item in distinct-values($result/top500:LOCATION/text())
                        let $res-obj := json:object()
                        let $_ := (map:put($res-obj,'Location',$item))
                        let $_ := json:array-push($response-array,$res-obj)
                        return()
      
  return $response-array
};

declare function company:GetCompanySearchResult($companyIDs,$companyNames,$industries,$locations,$maxNoOfEmployees,$revenueSize,$representationID,$practiceArea,$PageNo,$PageSize,$SortBy,$SortDirection)
{
  (:------------------------------- Max Year----------------------------------:)
  
  (:let $maxYear := fn:distinct-values(cts:search(/TOP500,
                                      cts:and-query((
                                        cts:directory-query('/LegalCompass/relational-data/surveys/TOP500/')
                                      )))/top500:YEAR/text()):)
	(:----Page Configuration----:)								  
	
  let $fromRecord := if($PageNo ne '1') then (xs:int($PageNo)-1)*xs:int($PageSize) else 1
  let $toRecord := xs:int($PageSize)*xs:int($PageNo)
  let $direction := if($SortDirection eq 'asc') then 'ascending' else 'descending'
  
  let $orderBy :=if($SortBy eq 'Headquaters') then cts:index-order(cts:element-reference(xs:QName('top500:LOCATION')) ,$direction)
                 else if($SortBy eq 'RevenueLastYear') then cts:index-order(cts:element-reference(xs:QName('top500:REVENUE')) ,$direction)
                       else if($SortBy eq 'NoOfEmployees') then cts:index-order(cts:element-reference(xs:QName('top500:NUMBER_OF_EMPLOYEES')) ,$direction)
                             else if($SortBy eq 'PrimaryIndustry') then cts:index-order(cts:element-reference(xs:QName('top500:PRIMARY_INDUSTRY')) ,$direction)
                                  else if($SortBy eq 'NoOfGC') then cts:index-order(cts:element-reference(xs:QName('top500:NUMBER_OF_GC')) ,$direction)
                                        else cts:index-order(cts:element-reference(xs:QName('top500:COMPANY_NAME')) ,'ascending')
   let $representationIDs := if($practiceArea ne '') then company:GetLevel1level2RepresntationID($practiceArea) else ()
   
   let $response-array := json:array()
   let $companyID := fn:tokenize($companyIDs,',')
   let $companyName := fn:tokenize($companyNames,',')
   let $industry := fn:tokenize($industries,',')
   let $location := fn:tokenize($locations,',')
   
   let $maxNoOfEmployee :=if($maxNoOfEmployees ne '1500+') then  fn:tokenize($maxNoOfEmployees,'-') else()
   let $lgEmpSize :=$maxNoOfEmployee[2]
   let $smEmpSize :=$maxNoOfEmployee[1]
   let $fixRevenue := '1000'
   let $revenue := if($revenueSize ne '1000+') then fn:tokenize($revenueSize,'-') else()
   let $lgRevenue := $revenue[2]
   let $smRevenue := $revenue[1]
   
   let $transactionID := if($representationIDs ne '') then company:getTransactionID($representationIDs) else()
   
   let $allCompanyID :=if($practiceArea ne '') then company:getCompIDs($representationIDs, fn:string-join($transactionID,',')) 
                       else ()
					   
	let $totalCount := xdmp:estimate(cts:search(/TOP500,
						cts:and-query((
						cts:directory-query('/LegalCompass/relational-data/surveys/TOP500/'),
						cts:element-value-query(xs:QName('top500:YEAR'),xs:string(fn:max(cts:element-values(xs:QName('top500:YEAR'))))),
						if($companyID ne '') then cts:element-value-query(xs:QName('top500:COMPANY_ID'),$companyID) else(),
						if($industry ne '') then cts:element-word-query(xs:QName('top500:PRIMARY_INDUSTRY'),$industry,('wildcarded')) else(),
						if($location ne '') then cts:element-value-query(xs:QName('top500:HEADQUARTERS'),$location) else(),
						if($maxNoOfEmployees ne '-' and $maxNoOfEmployees ne 'Any') then 
							 if ($maxNoOfEmployees eq '1500+') then 
								 (cts:and-query((cts:not-query(cts:element-value-query(xs:QName('top500:NUMBER_OF_EMPLOYEES'),''))
								  ,cts:element-range-query(xs:QName('top500:NUMBER_OF_EMPLOYEES'),'>', 1500),
								  cts:element-value-query(xs:QName('top500:YEAR'),xs:string(fn:max(cts:element-values(xs:QName('top500:YEAR')))))
								  )))
							 else  
								  (cts:and-query((cts:not-query(cts:element-value-query(xs:QName('top500:NUMBER_OF_EMPLOYEES'),'')),
								   cts:element-range-query(xs:QName('top500:NUMBER_OF_EMPLOYEES'), '>',xs:decimal($smEmpSize)),
								   cts:element-range-query(xs:QName('top500:NUMBER_OF_EMPLOYEES'), '<',xs:decimal($lgEmpSize)),
								  cts:element-value-query(xs:QName('top500:YEAR'),xs:string(fn:max(cts:element-values(xs:QName('top500:YEAR')))))
								   
								   )))
						else(),
						if($revenueSize ne '-' and $revenueSize ne 'any' and $revenueSize ne 'all revenue amounts') then
							   if($revenueSize eq '1000+') then 
								   cts:and-query((cts:not-query(cts:element-value-query(xs:QName('top500:REVENUE'),'')),
									 cts:element-range-query(xs:QName('top500:REVENUE'), '>',xs:double($fixRevenue)),
									cts:element-value-query(xs:QName('top500:YEAR'),xs:string(fn:max(cts:element-values(xs:QName('top500:YEAR')))))))
							  else 
								  cts:and-query((cts:not-query(cts:element-value-query(xs:QName('top500:REVENUE'),'')),
									 cts:element-range-query(xs:QName('top500:REVENUE'), '>',xs:decimal($smRevenue)),
									 cts:element-range-query(xs:QName('top500:REVENUE'),'<',xs:decimal($lgRevenue)),
									cts:element-value-query(xs:QName('top500:YEAR'),xs:string(fn:max(cts:element-values(xs:QName('top500:YEAR')))))))
						else(),
						if($practiceArea ne '') then 
							  cts:element-value-query(xs:QName('top500:COMPANY_ID'),($allCompanyID) ! xs:string(.))
						else()
					  ))))
	
	let $result := cts:search(/TOP500,
					cts:and-query((
						cts:directory-query('/LegalCompass/relational-data/surveys/TOP500/'),
						cts:element-value-query(xs:QName('top500:YEAR'),xs:string(fn:max(cts:element-values(xs:QName('top500:YEAR'))))),
						if($companyID ne '') then cts:element-value-query(xs:QName('top500:COMPANY_ID'),$companyID) else(),
						if($industry ne '') then cts:element-word-query(xs:QName('top500:PRIMARY_INDUSTRY'),$industry,('wildcarded')) else(),
						if($location ne '') then cts:element-value-query(xs:QName('top500:HEADQUARTERS'),$location) else(),
						if($maxNoOfEmployees ne '-' and $maxNoOfEmployees ne 'Any') then 
							 if ($maxNoOfEmployees eq '1500+') then 
								 (cts:and-query((cts:not-query(cts:element-value-query(xs:QName('top500:NUMBER_OF_EMPLOYEES'),''))
								  ,cts:element-range-query(xs:QName('top500:NUMBER_OF_EMPLOYEES'),'>', 1500),
								  cts:element-value-query(xs:QName('top500:YEAR'),xs:string(fn:max(cts:element-values(xs:QName('top500:YEAR')))))
								  )))
							 else  
								  (cts:and-query((cts:not-query(cts:element-value-query(xs:QName('top500:NUMBER_OF_EMPLOYEES'),'')),
								   cts:element-range-query(xs:QName('top500:NUMBER_OF_EMPLOYEES'), '>',xs:decimal($smEmpSize)),
								   cts:element-range-query(xs:QName('top500:NUMBER_OF_EMPLOYEES'), '<',xs:decimal($lgEmpSize)),
								  cts:element-value-query(xs:QName('top500:YEAR'),xs:string(fn:max(cts:element-values(xs:QName('top500:YEAR')))))
								   
								   )))
						else(),
						if($revenueSize ne '-' and $revenueSize ne 'any' and $revenueSize ne 'all revenue amounts') then
							   if($revenueSize eq '1000+') then 
								   cts:and-query((cts:not-query(cts:element-value-query(xs:QName('top500:REVENUE'),'')),
									 cts:element-range-query(xs:QName('top500:REVENUE'), '>',xs:double($fixRevenue)),
									cts:element-value-query(xs:QName('top500:YEAR'),xs:string(fn:max(cts:element-values(xs:QName('top500:YEAR')))))))
							  else 
								  cts:and-query((cts:not-query(cts:element-value-query(xs:QName('top500:REVENUE'),'')),
									 cts:element-range-query(xs:QName('top500:REVENUE'), '>',xs:decimal($smRevenue)),
									 cts:element-range-query(xs:QName('top500:REVENUE'),'<',xs:decimal($lgRevenue)),
									cts:element-value-query(xs:QName('top500:YEAR'),xs:string(fn:max(cts:element-values(xs:QName('top500:YEAR')))))))
						else(),
						if($practiceArea ne '') then 
							  cts:element-value-query(xs:QName('top500:COMPANY_ID'),($allCompanyID) ! xs:string(.))
						else()
					  )),($orderBy))[xs:int($fromRecord) to xs:int($toRecord)]
					  
	let $loopData1 := for $item1 in $result
					   let $response-obj := json:object()
					   let $revenue := if($item1/top500:REVENUE/text() ne '') then $item1/top500:REVENUE/text() else ''
					   let $_ :=(map:put($response-obj,'CompanyName',$item1/top500:COMPANY_NAME/text()),
								 map:put($response-obj,'Website',$item1/top500:URL/text()),
								 map:put($response-obj,'PrimaryIndustry',if($item1/top500:PRIMARY_INDUSTRY/text() ne '') then $item1/top500:PRIMARY_INDUSTRY/text() else '--'),
								 map:put($response-obj,'Headquaters',if($item1/top500:LOCATION/text() ne '') then $item1/top500:LOCATION/text() else '--'),
								 map:put($response-obj,'CompanyID',$item1/top500:COMPANY_ID/text()),
								 map:put($response-obj,'City',if($item1/top500:CITY/text() ne '') then $item1/top500:CITY/text() else '--'),
								 map:put($response-obj,'State',if($item1/top500:STATE/text() ne '') then $item1/top500:STATE/text() else '--'),
								 map:put($response-obj,'Country',if($item1/top500:COUNTRY/text() ne '') then $item1/top500:COUNTRY/text() else '--'),
								 map:put($response-obj,'GeographicRegion',if($item1/top500:GEOGRAPHIC_REGION/text() ne '') then $item1/top500:GEOGRAPHIC_REGION/text() else '--'),
								 map:put($response-obj,'USRegion',if($item1/top500:US_REGIONS/text() ne '') then $item1/top500:US_REGIONS/text() else '--'),
								 map:put($response-obj,'RevenueLastYear',$revenue),
								 map:put($response-obj,'NoOfEmployees',$item1/top500:NUMBER_OF_EMPLOYEES/text()),
								 map:put($response-obj,'NoOfGC',$item1/top500:NUMBER_OF_GC/text()),
								 map:put($response-obj,'ScopeID',$item1/top500:SCOPEID/text()),
								 map:put($response-obj,'totalCount',$totalCount)
								 )
								 
					   let $_ := json:array-push($response-array,$response-obj) 
					   return ()
   return $response-array
};

declare function company:getTransactionID($representationID)
{
 (:let $rID := fn:tokenize($representationID,','):)
  let $result := cts:search(/bdbs-transaction,
                    cts:and-query((
                    cts:directory-query('/LegalCompass/relational-data/bdbs-transaction/'),
                    cts:element-value-query(xs:QName('bdbstransaction:TRANSACTION_TYPE_ID'),$representationID)
                    )))/bdbstransaction:TRANSACTION_ID/text()
  
  return $result
};

declare function company:getCompIDs($representationID, $transactionID)
{
  (:let $reID := fn:tokenize($representationID,','):)
  let $tID := fn:tokenize($transactionID,',')
  let $query2 := cts:and-query((
					  cts:directory-query('/LegalCompass/relational-data/COMPANYPROFILE_LFR_NEW/'),
					  cts:element-value-query(xs:QName('companyprofilelfrnew:REPRESENTATION_TYPE_ID'),$representationID),
					  cts:not-query(cts:element-value-query(xs:QName('companyprofilelfrnew:COMPANY_ID'),('','0')))
					  ))
  
  let $data2 := cts:values(cts:element-reference(xs:QName('companyprofilelfrnew:COMPANY_ID')), (), (),$query2)
  
  let $query3 := cts:and-query((
				  cts:directory-query('/LegalCompass/relational-data/COMPANYPROFILE_LFR/'),
				  cts:element-value-query(xs:QName('companyprofilelfr:REPRESENTATION_TYPE_ID'),$representationID),
				  cts:not-query(cts:element-value-query(xs:QName('companyprofilelfr:COMPANY_ID'),('','0')))
				 ))
  let $data3:= cts:values(cts:element-reference(xs:QName('companyprofilelfr:COMPANY_ID')), (), (),$query3)
 
  let $query4 :=  cts:and-query((
					  cts:directory-query('/LegalCompass/relational-data/bdbs-party/'),
					  cts:element-value-query(xs:QName('bdbsparty:TRANSACTION_ID'),$tID),
					  cts:not-query(cts:element-value-query(xs:QName('bdbsparty:ORGANIZATION_ID'),('','0')))
				  ))
  let $data4 := cts:values(cts:element-reference(xs:QName('bdbsparty:ORGANIZATION_ID')), (), (),$query4) 
  
  let $query1 := cts:and-query((
                  cts:directory-query('/LegalCompass/relational-data/surveys/Who_Counsels_who/'),
                  cts:element-value-query(xs:QName('whoconsolewho:REPRESENTATION_TYPE_ID'),$representationID),
                  cts:not-query(cts:element-value-query(xs:QName('whoconsolewho:ORGANIZATION_ID'),('','0')))
                  ))
  
 let $data1 := cts:values(cts:element-reference(xs:QName('whoconsolewho:ORGANIZATION_ID')), (), (),$query1)
  
  (:let $data1 := cts:search(/,
                  cts:and-query((
                  cts:directory-query('/LegalCompass/relational-data/surveys/Who_Counsels_who/'),
                  cts:element-value-query(xs:QName('whoconsolewho:REPRESENTATION_TYPE_ID'),$reID),
                  cts:not-query(cts:element-value-query(xs:QName('whoconsolewho:ORGANIZATION_ID'),('','0')))
                  )))//whoconsolewho:ORGANIZATION_ID/text():)

return ($data1,$data2,$data3,$data4)
};

declare function company:GetRepresentationIDbyLevel($level1,$level2)
{
  let $response-array := json:array()
  let $result := cts:search(/REPRESENTATION_TYPES,
                     cts:and-query((
                         cts:directory-query('/LegalCompass/relational-data/REPRESENTATION_TYPES/'),
                         cts:element-value-query(xs:QName('representationtype:LEVEL_1'),$level1,'case-insensitive'),
                         if($level2 ne '') then cts:element-value-query(xs:QName('representationtype:LEVEL_2'),$level2,'case-insensitive') else()
                         )))/representationtype:REPRESENTATION_TYPE_ID/text()
               
  return $result

};

declare function company:GetLevel1level2RepresntationID($representations)
{
	let $res-array := json:array()
	let $d := fn:tokenize($representations,';')
	let $level1 := ''
	let $level2 := ''
	let $rID1 := ''
	for $item in $d
		let $level := fn:tokenize($item,',')
		
		let $result := cts:search(/REPRESENTATION_TYPES,
						cts:and-query((
                         cts:directory-query('/LegalCompass/relational-data/REPRESENTATION_TYPES/'),
                         cts:element-value-query(xs:QName('representationtype:LEVEL_1'),$level[2],'case-insensitive'),
                         if($level[1] ne '') then cts:element-value-query(xs:QName('representationtype:LEVEL_2'),$level[1],'case-insensitive') else()
                         )))/representationtype:REPRESENTATION_TYPE_ID/text()
               
		return $result
		
};

(:----------------- Helper Methods -----------------:)

declare function company:getMaxGCTop500ID($companyName as xs:string)
{
 let $search :=cts:search(/TOP500,
      cts:and-query((
         cts:directory-query('/LegalCompass/relational-data/surveys/TOP500/')
        ,cts:element-value-query(xs:QName('top500:COMPANY_NAME'),$companyName,('case-insensitive'))
      )))
  
  return fn:max(xs:double($search/top500:GC_TOP500_ID/text()))
};

declare function company:getMaxGCTop500IDByCompID($companyID as xs:string)
{
   let $search :=cts:search(/TOP500,
      cts:and-query((
         cts:directory-query('/LegalCompass/relational-data/surveys/TOP500/')
        ,cts:element-value-query(xs:QName('top500:COMPANY_ID'),$companyID)
      )))
  
  return fn:max(xs:double($search/top500:GC_TOP500_ID/text()))
};

(:declare function company:GetOrganizationName($firmID as xs:string)
{
   let $result := cts:search(/,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/organization/'),
                        cts:element-value-query(xs:QName('organizationns:ORGANIZATION_ID'),$firmID)
                      )))[1]
					  
   let $orgName := if($result//organizationns:ORGANIZATION_NAME/text()) then 
                          $result//organizationns:ORGANIZATION_NAME/text() 
                   else $result//organizationns:ALM_NAME/text()
				   
  return $orgName
};:)

declare function company:GetDirectoryCount()
{
let $res-array := json:array()
(:let $qDate:= xs:dateTime(xs:date(fn:current-date()) - xs:dayTimeDuration('P3D'),xs:time('00:00:00-05:00')):)
let $res := cts:uri-match('*',('document'))(:,
  cts:and-query((
     cts:properties-query(cts:element-range-query(xs:QName('prop:last-modified'), '>=', $qDate))
  )))[1]:)
  
  let $data := for $x in $res
  return fn:concat(fn:string-join(fn:tokenize($x,'/')[position() lt last()],'/'),'/')
  
let $dirs := fn:distinct-values($data)
let $loopData := for $item in $dirs
                 let $res-obj := json:object()
                 
                 let $count := count(cts:search(/,
                   cts:and-query((
                   cts:directory-query($item)
                   ))))
                 let $_ := (map:put($res-obj,'DirectoryName',$item),
                            map:put($res-obj,'DataCount',$count))  
                 let $_ := json:array-push($res-array,$res-obj)   
                 return()
return $res-array
};

declare function company:DeleteDirectory($directoryPath,$to)
{
  xdmp:document-delete(cts:uri-match('*.xml',('document'),cts:directory-query($directoryPath,'infinity')))
};

declare function company:getDirectoryCount($directory)
{         
  let $count :=xdmp:estimate(cts:search(/,cts:directory-query($directory,'infinity')))

  (:xdmp:estimate(cts:uri-match("*.xml", ("document"), cts:directory-query($directory))):)
  return $count 
};


