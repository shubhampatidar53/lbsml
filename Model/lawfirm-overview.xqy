xquery version '1.0-ml';

module namespace lawfirm-overview = 'http://alm.com/lawfirm-overview';

import module namespace config = 'http://alm.com/config' at '/common/config.xqy';
import module namespace helper = 'http://alm.com/helper' at '/common/model/helper.xqy';
import module namespace admin-update-helper = 'http://alm.com/admin-update-helper' at '/common/model/admin-update-helper.xqy';
import module namespace json = 'http://marklogic.com/xdmp/json'  at '/MarkLogic/json/json.xqy';
import module namespace mem = "http://xqdev.com/in-mem-update" at '/MarkLogic/appservices/utils/in-mem-update.xqy';
import module namespace uniq = 'http://marklogic.com/unique' at '/common/UniqueHelper-lib.xqy';

declare namespace organization = 'http://alm.com/LegalCompass/rd/organization';
declare namespace organization-address = 'http://alm.com/LegalCompass/rd/organization-address';

declare namespace LAWFIRM_OVERVIEW = 'http://alm.com/LegalCompass/rd/lawfirm_overview';
declare namespace NLJ_250 = 'http://alm.com/LegalCompass/rd/NLJ_250';
declare namespace AMLAW_200 = 'http://alm.com/LegalCompass/rd/AMLAW_200';
declare namespace GLOBAL_100 = 'http://alm.com/LegalCompass/rd/Global_100';

declare namespace UK_50 = 'http://alm.com/LegalCompass/rd/UK_50';
declare namespace CHINA_40 = 'http://alm.com/LegalCompass/rd/CHINA_40';


declare option xdmp:mapping 'false';


declare function lawfirm-overview:GetLawFirmProfileOverview($ids)
{
  
  let $firmIdQuery := cts:element-value-query(xs:QName('LAWFIRM_OVERVIEW:FIRMID'), fn:tokenize($ids,','))

  let $lawFirmOverviewResult := cts:search(/,
  	                              cts:and-query((
    	                            cts:directory-query('/LegalCompass/relational-data/LAWFIRM_OVERVIEW/')
                                  , $firmIdQuery)))
  
  let $jsonResult := json:array()
	  
  let $element:= for $item in $lawFirmOverviewResult
  	              let $responseItem := json:object()
                    
                  let $organization := cts:search(/,
                            cts:and-query((
                            cts:directory-query('/LegalCompass/relational-data/organization/')
                            , cts:element-value-query(xs:QName('organization:ORGANIZATION_ID'), $item//LAWFIRM_OVERVIEW:FIRMID/text()))
                            ))

                  let $almName := $organization//organization:ALM_NAME/text()
                  let $organizationName := $organization//organization:ORGANIZATION_NAME/text()
                  let $organizationName := if ($almName ne '') then $almName else $organizationName
    
		              let $_ := (
			                          map:put($responseItem, 'ADDRESS',$item//LAWFIRM_OVERVIEW:ADDRESS/text())
                                , map:put($responseItem, 'ADDRESS2',$item//LAWFIRM_OVERVIEW:ADDRESS2/text())
                                , map:put($responseItem, 'ASSOCIATE',$item//LAWFIRM_OVERVIEW:ASSOCIATE/text())
                                , map:put($responseItem, 'CITY',$item//LAWFIRM_OVERVIEW:CITY/text())
                                , map:put($responseItem, 'COUNTRY',$item//LAWFIRM_OVERVIEW:COUNTRY/text())
                                , map:put($responseItem, 'DESCRIPTIONTEXT',$item//LAWFIRM_OVERVIEW:DESCRIPTIONTEXT/text())
                                , map:put($responseItem, 'EMAIL',$item//LAWFIRM_OVERVIEW:EMAIL/text())
                                , map:put($responseItem, 'EQUITYPARTNER',$item//LAWFIRM_OVERVIEW:EQUITYPARTNER/text())
                                , map:put($responseItem, 'FAX',$item//LAWFIRM_OVERVIEW:FAX/text())
                                , map:put($responseItem, 'FIRMID',$item//LAWFIRM_OVERVIEW:FIRMID/text())
                                , map:put($responseItem, 'FirmName', $organizationName) 
                                , map:put($responseItem, 'GLOBALRANK',$item//LAWFIRM_OVERVIEW:GLOBALRANK/text())
                                , map:put($responseItem, 'HEADQUATERS',$item//LAWFIRM_OVERVIEW:HEADQUATERS/text())
                                , map:put($responseItem, 'INTERNATIONALPRESENCE',$item//LAWFIRM_OVERVIEW:INTERNATIONALPRESENCE/text())
                                , map:put($responseItem, 'LASTYEARNETINCOME',$item//LAWFIRM_OVERVIEW:LASTYEARNETINCOME/text())
                                , map:put($responseItem, 'LOGO',$item//LAWFIRM_OVERVIEW:LOGO/text())
                                , map:put($responseItem, 'NONEQUITYPARTNER',$item//LAWFIRM_OVERVIEW:NONEQUITYPARTNER/text())
                                , map:put($responseItem, 'PHONE',$item//LAWFIRM_OVERVIEW:PHONE/text())
                                , map:put($responseItem, 'PROFITPERPARTNER',$item//LAWFIRM_OVERVIEW:PROFITPERPARTNER/text())
                                , map:put($responseItem, 'REVENUEPERLAWYER',$item//LAWFIRM_OVERVIEW:REVENUEPERLAWYER/text())
                                , map:put($responseItem, 'STATE',$item//LAWFIRM_OVERVIEW:STATE/text())
                                , map:put($responseItem, 'TOTALHEADCOUNT',$item//LAWFIRM_OVERVIEW:TOTALHEADCOUNT/text())
                                , map:put($responseItem, 'TOTALOFFICE',$item//LAWFIRM_OVERVIEW:TOTALOFFICE/text())
                                , map:put($responseItem, 'TOTALREVENUE',$item//LAWFIRM_OVERVIEW:TOTALREVENUE/text())
                                , map:put($responseItem, 'WEBSITE',$item//LAWFIRM_OVERVIEW:WEBSITE/text())
                                , map:put($responseItem, 'ZIP',$item//LAWFIRM_OVERVIEW:ZIP/text())
                                , map:put($responseItem, 'ID',$item//LAWFIRM_OVERVIEW:ID/text())
                              )
		              let $_ := json:array-push($jsonResult, $responseItem)
		              return ()

	return fn:distinct-values($jsonResult)

};

(:
By Raveendra Sharma 0n 08/13/2018
:)
declare function lawfirm-overview:GetLawfirmProfileOverviewReport($firmId, $headQuarterAddress)
{
  let $organizationResult := cts:search(/,
      cts:and-query((
      cts:directory-query('/LegalCompass/relational-data/organization/')
      , cts:element-value-query(xs:QName('organization:ORGANIZATION_ID'), $firmId) 
  )))[1]


  let $maxPublishYearNLJ250 := xs:string(fn:max(cts:search(/,cts:directory-query('/LegalCompass/relational-data/surveys/NLJ_250/'))//*:PUBLISHYEAR/text()))
  let $maxPublishYearAMLaw200 := xs:string(fn:max(cts:search(/,cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'))//*:PUBLISHYEAR/text()))
  let $maxPublishYearGlobal100 := xs:string(fn:max(cts:search(/,cts:directory-query('/LegalCompass/relational-data/surveys/Global_100/'))//*:PUBLISHYEAR/text()))

  let $nlj250Result := cts:search(/,
                            cts:and-query((
                              cts:directory-query('/LegalCompass/relational-data/surveys/NLJ_250/')
                             ,cts:element-value-query(xs:QName('NLJ_250:ORGANIZATION_ID'), $firmId)
                             ,cts:element-value-query(xs:QName('NLJ_250:PUBLISHYEAR'), $maxPublishYearNLJ250)
                             )))[1]

  let $amlaw200Result := cts:search(/,
                            cts:and-query((
                              cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/')
                             ,cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'), $firmId)
                             ,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'), $maxPublishYearAMLaw200)
                            ,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'), $maxPublishYearNLJ250)
                             )))[1]

  let $global100Result := cts:search(/,
                            cts:and-query((
                              cts:directory-query('/LegalCompass/relational-data/surveys/Global_100/')
                             ,cts:element-value-query(xs:QName('GLOBAL_100:ORGANIZATION_ID'), $firmId)
                             ,cts:element-value-query(xs:QName('GLOBAL_100:PUBLISHYEAR'), $maxPublishYearGlobal100)
                             ,cts:element-value-query(xs:QName('GLOBAL_100:PUBLISHYEAR'), $maxPublishYearAMLaw200)
                             )))[1]


  let $jsonResult := json:array()

  let $organizatinAddress :=  for $item in $organizationResult
 
                           let $almName := $item//organization:ALM_NAME/text()
                           let $organizationName := if ($almName eq '') then $item//organization:ORGANIZATION_NAME/text() else $almName
       
                           let $organizationAddress := cts:search(/,
                                            cts:and-query((
                                            cts:directory-query('/LegalCompass/relational-data/organization-address/')
                                            ,cts:element-value-query(xs:QName('organization-address:ORGANIZATION_ID'), $firmId)
                                            ,if ($headQuarterAddress eq '1') then cts:element-value-query(xs:QName('organization-address:HEADQUARTERS'), 'H') else ()
                                           )))[1]


                          let $city := $organizationAddress//*:CITY/text()
                          let $state := $organizationAddress//organization-address:STATE/text()
                          let $headQuarter := fn:concat($city, ', ', $state)

                          let $numberOfLawyers := if (fn:empty($amlaw200Result)) then '' else $amlaw200Result//AMLAW_200:NUM_OF_LAWYERS/text()
                          let $numberOfLawyers := if ($numberOfLawyers eq '') then $nlj250Result//NLJ_250:NUM_ATTORNEYS/text() else $numberOfLawyers

                          let $equityPartners := $amlaw200Result//*:NUM_EQ_PARTNERS/text()
                          let $equityPartners := if ($equityPartners eq '') then $nlj250Result//*:NUM_EQ_PARTNERS/text() else $equityPartners

                          let $nonEquityPartners := $amlaw200Result//*:NUM_NON_EQ_PARTNERS/text()
                          let $nonEquityPartners := if ($nonEquityPartners eq '') then $nlj250Result//*:NUM_NE_PARTNERS/text() else $nonEquityPartners

                          let $numOfAssociates := $nlj250Result//*:NUM_ASSOCIATES/text()
                          
                          let $webSite := $item//organization:WEBSITE/text()
                          let $webSite := if ($webSite eq '') then  $organizationAddress//organization-address:WEBSITE/text() else $webSite
                          
                          let $almLaw200PublishYearFlag := if ($headQuarterAddress eq '1') 
                                                      then ($amlaw200Result//AMLAW_200:PUBLISHYEAR/text() eq $maxPublishYearAMLaw200) 
                                                      else fn:true()
                          
                          let $responseItem := json:object()  
                          
                          let $_ := if ($almLaw200PublishYearFlag) then  ( 
                                      map:put($responseItem, 'ORGANIZATION_ID',$item//organization:ORGANIZATION_ID/text())
                                    , map:put($responseItem, 'ORGANIZATION_NAME',if ($almName ne '') then $almName else $organizationName)
                                    , map:put($responseItem, 'website',$webSite)
                                    , map:put($responseItem, 'MAIN_PHONE',$organizationAddress//organization-address:MAIN_PHONE/text())
                                    , map:put($responseItem, 'email',$organizationAddress//organization-address:EMAIL/text())
                                    , map:put($responseItem, 'CITY',$organizationAddress//organization-address:CITY/text())
                                    , map:put($responseItem, 'STATE',$organizationAddress//organization-address:STATE/text())
                                    , map:put($responseItem, 'ZIP',$organizationAddress//organization-address:ZIP/text())
                                    , map:put($responseItem, 'ADDRESS1',$organizationAddress//organization-address:ADDRESS1/text())
                                    , map:put($responseItem, 'ADDRESS2',$organizationAddress//organization-address:ADDRESS2/text())
                                    , map:put($responseItem, 'COUNTRY',$organizationAddress//organization-address:COUNTRY/text())
                                    , map:put($responseItem, 'HeadQuater',$headQuarter)
                                    , map:put($responseItem, 'FAX',$organizationAddress//organization-address:FAX/text())
                                    , map:put($responseItem, 'GlobalRank',$global100Result//GLOBAL_100:RANK_BY_GROSS_REVENUE/text())
                                    , map:put($responseItem, 'TotalHeadcount',$numberOfLawyers)
                                    , map:put($responseItem, 'EquityPartner',$numberOfLawyers)
                                    , map:put($responseItem, 'NonEquityPartner',$nonEquityPartners)
                                    , map:put($responseItem, 'Associate',$numOfAssociates)
                                    , map:put($responseItem, 'TotalRevenue',$amlaw200Result//AMLAW_200:GROSS_REVENUE/text())
                                    , map:put($responseItem, 'RevenuePerLawyer',$amlaw200Result//AMLAW_200:RPL/text())
                                    , map:put($responseItem, 'ProfitPerPartner',$amlaw200Result//AMLAW_200:ppp/text())
                                    , map:put($responseItem, 'MansfieldruleStatus',$item//organization:MANSFIELD_RULE_STATUS/text())
                                    ) else ()  

      		                let $_ := if (fn:empty($organizationAddress)) then () else json:array-push($jsonResult, $responseItem)
		                      return ()

  return fn:distinct-values($jsonResult)
  
};

(:
By Raveendra Sharma 0n 08/13/2018
:)
declare function lawfirm-overview:GetLawfirmProfileOverviewWithOfficeCount($firmId, $headQuarterAddress)
{
  let $organizationResult := cts:search(/,
      cts:and-query((
      cts:directory-query('/LegalCompass/relational-data/organization/')
      , cts:element-value-query(xs:QName('organization:ORGANIZATION_ID'), $firmId) 
  )))[1]


  let $maxPublishYearNLJ250 := xs:string(fn:max(cts:search(/,cts:directory-query('/LegalCompass/relational-data/surveys/NLJ_250/'))//*:PUBLISHYEAR/text()))
  let $maxPublishYearAMLaw200 := xs:string(fn:max(cts:search(/,cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'))//*:PUBLISHYEAR/text()))
  let $maxPublishYearGlobal100 := xs:string(fn:max(cts:search(/,cts:directory-query('/LegalCompass/relational-data/surveys/Global_100/'))//*:PUBLISHYEAR/text()))

  let $nlj250Result := cts:search(/,
                            cts:and-query((
                              cts:directory-query('/LegalCompass/relational-data/surveys/NLJ_250/')
                             ,cts:element-value-query(xs:QName('NLJ_250:ORGANIZATION_ID'), $firmId)
                             ,cts:element-value-query(xs:QName('NLJ_250:PUBLISHYEAR'), $maxPublishYearNLJ250)
                             )))[1]

  let $amlaw200Result := cts:search(/,
                            cts:and-query((
                              cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/')
                             ,cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'), $firmId)
                             ,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'), $maxPublishYearAMLaw200)
                             )))[1]

  let $amlawdataPreviousYear :=cts:search(/,
									cts:and-query((
										cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/','1'),
										cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$firmId),
										cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string(xs:integer($maxPublishYearAMLaw200) - 1))
									)))//AMLAW_200:GROSS_REVENUE/text()                           

  let $global100Result := cts:search(/,
                            cts:and-query((
                              cts:directory-query('/LegalCompass/relational-data/surveys/Global_100/')
                             ,cts:element-value-query(xs:QName('GLOBAL_100:ORGANIZATION_ID'), $firmId)
                             ,cts:element-value-query(xs:QName('GLOBAL_100:PUBLISHYEAR'), $maxPublishYearGlobal100)
                             )))[1]

  let $global100dataPreviousYear :=cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/surveys/Global_100/','1'),
							cts:element-value-query(xs:QName('GLOBAL_100:ORGANIZATION_ID'),$firmId),
							cts:element-value-query(xs:QName('GLOBAL_100:PUBLISHYEAR'),xs:string(xs:integer($maxPublishYearGlobal100) - 1))
						)))[1]//GLOBAL_100:GROSS_REVENUE/text()                           

  let $uk50data := cts:search(/,
                          cts:and-query((
                            cts:directory-query('/LegalCompass/relational-data/surveys/UK_50/')
                            ,cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'), $firmId)
                            ,cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'), $maxPublishYearGlobal100)
                            )))[1]                           

  let $uk50dataPreviousYear :=cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/surveys/UK_50/','1'),
							cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),$firmId),
							cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string(xs:integer($maxPublishYearGlobal100) - 1))
						)))[1]//UK_50:GROSS_REVENUE_DOLLAR/text()

  let $china40data := cts:search(/,
                          cts:and-query((
                            cts:directory-query('/LegalCompass/relational-data/surveys/CHINA_40/')
                            ,cts:element-value-query(xs:QName('CHINA_40:ORGANIZATION_ID'), $firmId)
                            ,cts:element-value-query(xs:QName('CHINA_40:PUBLISHYEAR'), $maxPublishYearGlobal100)
                            )))[1]

  let $china40dataPreviousYear :=cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/surveys/CHINA_40/','1'),
							cts:element-value-query(xs:QName('CHINA_40:ORGANIZATION_ID'),$firmId),
							cts:element-value-query(xs:QName('CHINA_40:PUBLISHYEAR'),xs:string(xs:integer($maxPublishYearGlobal100) - 1))
						)))[1]//CHINA_40:GROSS_REVENUE/text()

  let $jsonResult := json:array()

  let $organizatinAddress :=  for $item in $organizationResult
 
                           let $almName := $item//organization:ALM_NAME/text()
                           let $organizationName := if ($almName eq '') then $item//organization:ORGANIZATION_NAME/text() else $almName
       
                           let $organizationAddress := cts:search(/,
                                            cts:and-query((
                                            cts:directory-query('/LegalCompass/relational-data/organization-address/')
                                            ,cts:element-value-query(xs:QName('organization-address:ORGANIZATION_ID'), $firmId)
                                            ,if ($headQuarterAddress eq '1') then cts:element-value-query(xs:QName('organization-address:HEADQUARTERS'), 'H') else ()
                                           )))[1]


                          let $city := $organizationAddress//*:CITY/text()
                          let $state := $organizationAddress//organization-address:STATE/text()
                          let $headQuarter := fn:concat($city, ', ', $state)

                          let $numberOfLawyers := if (fn:empty($amlaw200Result)) then '' else $amlaw200Result//AMLAW_200:NUM_OF_LAWYERS/text()
                          let $numberOfLawyers := if ($numberOfLawyers eq '') then $nlj250Result//NLJ_250:NUM_ATTORNEYS/text() else $numberOfLawyers

                          let $equityPartners := $amlaw200Result//*:NUM_EQ_PARTNERS/text()
                          let $equityPartners := if ($equityPartners eq '') then $nlj250Result//*:NUM_EQ_PARTNERS/text() else $equityPartners

                          let $nonEquityPartners := $amlaw200Result//*:NUM_NON_EQ_PARTNERS/text()
                          let $nonEquityPartners := if ($nonEquityPartners eq '') then $nlj250Result//*:NUM_NE_PARTNERS/text() else $nonEquityPartners

                          let $numOfAssociates := $nlj250Result//NLJ_250:NUM_ASSOCIATES/text()
                          
                          let $webSite := $item//organization:WEBSITE/text()
                          let $webSite := if ($webSite eq '') then  $organizationAddress//organization-address:WEBSITE/text() else $webSite
                          
                          let $almLaw200PublishYearFlag := if ($headQuarterAddress eq '1') 
                                                      then ($amlaw200Result//AMLAW_200:PUBLISHYEAR/text() eq $maxPublishYearAMLaw200) 
                                                      else fn:true()

                          let $profitMargin := if($amlaw200Result//AMLAW_200:PROFIT_MARGIN_AVG/text()) then ($amlaw200Result//AMLAW_200:PROFIT_MARGIN_AVG/text() * 100)
                                              else if($global100Result//GLOBAL_100:PROFIT_MARGIN/text()) then $global100Result//GLOBAL_100:PROFIT_MARGIN/text()
                                              else if($uk50data//UK_50:PROFIT_MARGIN/text()) then $uk50data//UK_50:PROFIT_MARGIN/text()
                                              else $china40data//CHINA_40:PROFIT_MARGIN/text() * 100	

                          let $totalPartners := if($amlaw200Result//AMLAW_200:TOTAL_PARTNERS/text()) then ($amlaw200Result//AMLAW_200:TOTAL_PARTNERS/text() )
                                                else if($global100Result//GLOBAL_100:NUM_PARTNERS/text()) then $global100Result//GLOBAL_100:NUM_PARTNERS/text()
                                                else if($uk50data//UK_50:TOTAL_PARTNERS/text()) then $uk50data//UK_50:TOTAL_PARTNERS/text()
                                                else 0

                          let $ppl := if($amlaw200Result//AMLAW_200:PPL/text()) then ($amlaw200Result//AMLAW_200:PPL/text())
                                      else if($global100Result//GLOBAL_100:NUM_LAWYERS/text()) then (($global100Result//GLOBAL_100:PPP/text() * $global100Result//GLOBAL_100:NUM_EQUITY_PARTNERS/text()) div $global100Result//GLOBAL_100:NUM_LAWYERS/text())
                                      else if($uk50data//UK_50:PPL_DOLLAR/text()) then $uk50data//UK_50:PPL_DOLLAR/text()
                                      else 0 

                          let $rpl := if($amlaw200Result//AMLAW_200:RPL/text()) then ($amlaw200Result//AMLAW_200:RPL/text())
                                      else if($global100Result//GLOBAL_100:REVENUE_PER_LAWYER/text()) then $global100Result//GLOBAL_100:REVENUE_PER_LAWYER/text()
                                      else if($uk50data//UK_50:RPL_DOLLAR/text()) then $uk50data//UK_50:RPL_DOLLAR/text()
                                      else 0

                          let $ppp := if($amlaw200Result//AMLAW_200:PPP/text()) then ($amlaw200Result//AMLAW_200:PPP/text())
                                      else if($global100Result//GLOBAL_100:PPP/text() ne '') then $global100Result//GLOBAL_100:PPP/text()
                                      else if($uk50data//UK_50:PPP_DOLLAR/text()) then $uk50data//UK_50:PPP_DOLLAR/text()
                                      else $china40data//CHINA_40:PROFITS_PER_PARTNER/text()                         

                          let $lawyerPercent := ($global100Result//GLOBAL_100:PERCENTAGE_LAWYERS_IN_COUNTRY/text() * 100)   

                          let $totalRevenue := if($amlaw200Result//AMLAW_200:GROSS_REVENUE/text()) then $amlaw200Result//AMLAW_200:GROSS_REVENUE/text() 
                                              else if($global100Result//GLOBAL_100:GROSS_REVENUE/text()) then $global100Result//GLOBAL_100:GROSS_REVENUE/text()
                                              else if($uk50data//UK_50:GROSS_REVENUE_DOLLAR/text()) then $uk50data//UK_50:GROSS_REVENUE_DOLLAR/text()
                                              else $china40data//CHINA_40:GROSS_REVENUE/text()

                          let $totalRevenuePreYear := if($amlawdataPreviousYear) then $amlawdataPreviousYear 
                                                      else if($global100dataPreviousYear) then $global100dataPreviousYear
                                                      else if($uk50dataPreviousYear) then $uk50dataPreviousYear
                                                      else $china40dataPreviousYear

                          let $totalHeadCount := if($amlaw200Result//AMLAW_200:NUM_OF_LAWYERS/text() ne '') then $amlaw200Result//AMLAW_200:NUM_OF_LAWYERS/text() else 
                                                  if($global100Result//GLOBAL_100:NUM_LAWYERS/text()) then $global100Result//GLOBAL_100:NUM_LAWYERS/text() else
                                                  if($uk50data//UK_50:NUMBER_OF_LAWYERS/text()) then $uk50data//UK_50:NUMBER_OF_LAWYERS/text() else
                                                  if($china40data//CHINA_40:FIRMWIDE_LAWYERS/text()) then $china40data//CHINA_40:FIRMWIDE_LAWYERS/text() else
                                                  if($nlj250Result//*:NUM_ATTORNEYS/text() ne '') then $nlj250Result//*:NUM_ATTORNEYS/text() else 0                            

                          let $equityPartner := if($amlaw200Result//AMLAW_200:NUM_EQ_PARTNERS/text() ne '') then $amlaw200Result//AMLAW_200:NUM_EQ_PARTNERS/text() else 
                                                if($global100Result//GLOBAL_100:NUM_EQUITY_PARTNERS/text()) then $global100Result//GLOBAL_100:NUM_EQUITY_PARTNERS/text() else
                                                if($uk50data//UK_50:NUMBER_OF_EQ_PARTNERS/text()) then $uk50data//UK_50:NUMBER_OF_EQ_PARTNERS/text() else
                                                if($china40data//CHINA_40:NUMBER_OF_EQ_PARTNERS/text()) then $china40data//CHINA_40:NUMBER_OF_EQ_PARTNERS/text() else
                                                if($nlj250Result//*:EQUITY_PARTNERS/text() ne '') then $nlj250Result//*:EQUITY_PARTNERS/text() else 0                        

	let $revenueGrowth := if($totalRevenue) then fn:round-half-to-even((($totalRevenue - $totalRevenuePreYear ) div $totalRevenue) * 100 , 2) else 0
                                    
                                                                
                          let $responseItem := json:object()  
                          
                          let $_ := ( 
                                     map:put($responseItem, 'ORGANIZATION_ID',$item//organization:ORGANIZATION_ID/text())
                                    , map:put($responseItem, 'Organization_Profile',$item//organization:ORGANIZATION_PROFILE/text())
                                    , map:put($responseItem, 'ORGANIZATION_NAME',if ($almName ne '') then $almName else $organizationName)
                                    , map:put($responseItem, 'website',$webSite)
                                    , map:put($responseItem, 'MAIN_PHONE',$organizationAddress//organization-address:MAIN_PHONE/text())
                                    , map:put($responseItem, 'email',$organizationAddress//organization-address:EMAIL/text())
                                    , map:put($responseItem, 'CITY',$organizationAddress//organization-address:CITY/text())
                                    , map:put($responseItem, 'STATE',$organizationAddress//organization-address:STATE/text())
                                    , map:put($responseItem, 'ZIP',$organizationAddress//organization-address:ZIP/text())
                                    , map:put($responseItem, 'ADDRESS1',$organizationAddress//organization-address:ADDRESS1/text())
                                    , map:put($responseItem, 'ADDRESS2',$organizationAddress//organization-address:ADDRESS2/text())
                                    , map:put($responseItem, 'COUNTRY',$organizationAddress//organization-address:COUNTRY/text())
                                    , map:put($responseItem, 'HeadQuater',$headQuarter)
                                    , map:put($responseItem, 'FAX',$organizationAddress//organization-address:FAX/text())
                                    , map:put($responseItem, 'GlobalRank',$global100Result//GLOBAL_100:RANK_BY_GROSS_REVENUE/text())
                                    , map:put($responseItem, 'TotalHeadcount',$totalHeadCount)
                                    , map:put($responseItem, 'EquityPartner',$equityPartner)
                                    , map:put($responseItem, 'NonEquityPartner',$nonEquityPartners)
                                    , map:put($responseItem, 'Associate',$numOfAssociates)
                                    , map:put($responseItem, 'TotalRevenue',$totalRevenue)
                                    , map:put($responseItem, 'RevenuePerLawyer',$rpl)
                                    , map:put($responseItem, 'ProfitPerPartner',$ppp)
                                    , map:put($responseItem, 'MansfieldruleStatus',$item//organization:MANSFIELD_RULE_STATUS/text())
                                    
		                                , map:put($responseItem,'MANSFIELD_RULE_STATUS',$item//organization:MANSFIELD_RULE_STATUS/text())
                                    , map:put($responseItem, 'ProfitMargin', if($profitMargin) then $profitMargin else 0)
                                    , map:put($responseItem, 'TotalPartners', if($totalPartners) then $totalPartners else 0)
                                    , map:put($responseItem, 'ProfitPerLawyer', if($ppl) then $ppl else 0)
                                    , map:put($responseItem, 'LawyerPercentage', if($lawyerPercent) then $lawyerPercent else 0)
                                    , map:put($responseItem, 'RevenueGrowth', if($revenueGrowth) then $revenueGrowth else 0)
                                    )

      		                let $_ := json:array-push($jsonResult, $responseItem)
		                      return ()

  return $jsonResult
  
};
