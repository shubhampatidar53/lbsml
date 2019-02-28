xquery version '1.0-ml';

module namespace report = 'http://alm.com/report';

import module namespace config = 'http://alm.com/config' at '/common/config.xqy';
import module namespace helper = 'http://alm.com/helper' at '/common/model/helper.xqy';
import module namespace admin-update-helper = 'http://alm.com/admin-update-helper' at '/common/model/admin-update-helper.xqy';
import module namespace json = 'http://marklogic.com/xdmp/json'  at '/MarkLogic/json/json.xqy';
import module namespace mem = "http://xqdev.com/in-mem-update" at '/MarkLogic/appservices/utils/in-mem-update.xqy';
import module namespace uniq = 'http://marklogic.com/unique' at '/common/UniqueHelper-lib.xqy';

declare namespace PRO_BONO = 'http://alm.com/LegalCompass/rd/Pro_Bono';
declare namespace NLJ_BILLING = 'http://alm.com/LegalCompass/rd/NLJ_BILLING';
declare namespace ASSOCIATE_NATL = 'http://alm.com/LegalCompass/rd/Associate_natl';
declare namespace ASSOCIATE_CLASS_BILLING_SURVEY = 'http://alm.com/LegalCompass/rd/ASSOCIATE_CLASS_BILLING_SURVEY';
declare namespace Diversity_Scorecard = 'http://alm.com/LegalCompass/rd/Diversity_Scorecard';
declare namespace AMLAW_200 = 'http://alm.com/LegalCompass/rd/AMLAW_200';
declare namespace NLJ_250 = 'http://alm.com/LegalCompass/rd/NLJ_250';
declare namespace Global_100 = 'http://alm.com/LegalCompass/rd/Global_100';
declare namespace Lateral_Partner = 'http://alm.com/LegalCompass/rd/Lateral_Partner';
declare namespace organization = 'http://alm.com/LegalCompass/dd/organization';
declare namespace CHINA_40 = 'http://alm.com/LegalCompass/rd/CHINA_40';
declare namespace UK_50 = 'http://alm.com/LegalCompass/rd/UK_50';
declare namespace survey = "http://alm.com/LegalCompass/dd/survey";
declare namespace PARTNER_PROMOTIONS = 'http://alm.com/LegalCompass/rd/PARTNER_PROMOTIONS';
declare namespace LAWFIRM_REPORTFILES_CUSTOM = 'http://alm.com/LegalCompass/rd/LAWFIRM_REPORTFILES_CUSTOM';

declare function report:GenericSurveyTableAdapter($orgID,$FDuration,$namespace,$root,$tableName)
{

let $jsonResult := json:array()
let $amquery := cts:and-query((
                cts:directory-query(concat('/LegalCompass/relational-data/surveys/',$tableName,'/'))
               ,cts:element-value-query(xs:QName(concat($namespace,':ORGANIZATION_ID')),$orgID)    
                ))
              
let $maxPALM200 := fn:max(cts:element-values(xs:QName(concat($namespace,':FISCAL_YEAR')),(),(),$amquery))
let $EXPR1 := (xs:integer($maxPALM200) - xs:integer($FDuration))

let $query :=  cts:and-query((
              cts:directory-query(concat('/LegalCompass/relational-data/surveys/',$tableName,'/'))
             ,cts:element-value-query(xs:QName(concat($namespace,':ORGANIZATION_ID')),$orgID) 
              ,cts:element-range-query(xs:QName(concat($namespace,':FISCAL_YEAR')),'>=',$EXPR1) 
              ))
              
  let $result := cts:search(/,$query)
 	let $element:= for $item in $result
  let $responseItem := json:object()
  let $_ := admin-update-helper:GetJSON($responseItem,$item,$namespace,$root,())
  
       let $_ := json:array-push($jsonResult,$responseItem)
    
		return ()

return $jsonResult
};

declare function report:ASSOCIATE_NATLTableAdapter($orgID,$FDuration)
{

let $jsonResult := json:array()
let $amquery := cts:and-query((
                cts:directory-query('/LegalCompass/relational-data/surveys/Associate_natl/')
               ,cts:element-value-query(xs:QName('ASSOCIATE_NATL:FIRM_ID'),$orgID)    
                ))
              

let $maxPALM200 := fn:max(cts:element-values(xs:QName('ASSOCIATE_NATL:YEAR'),(),(),$amquery))
let $EXPR1 := (xs:integer($maxPALM200) - xs:integer($FDuration))

let $query :=  cts:and-query((
              cts:directory-query('/LegalCompass/relational-data/surveys/Associate_natl/')
             ,cts:element-value-query(xs:QName('ASSOCIATE_NATL:FIRM_ID'),$orgID) 
              ,cts:element-range-query(xs:QName('ASSOCIATE_NATL:YEAR'),'>=',$EXPR1) 
              ))
              
  let $result := cts:search(/,$query)
 	let $element:= for $item in $result
  let $responseItem := json:object()
  let $_ := admin-update-helper:GetJSON($responseItem,$item,'ASSOCIATE_NATL','AssociateNATL',())
  
       let $_ := json:array-push($jsonResult,$responseItem)
    
		return ()

return $jsonResult
};

declare function report:AMLaw200AVGTableAdapter($FYear)
{

let $jsonResult := json:array()

let $maxPALM200 := fn:max(cts:element-values(xs:QName('AMLAW_200:FISCAL_YEAR')))
let $EXPR1 := (xs:integer($maxPALM200) - xs:integer($FYear))

let $query :=  cts:and-query((
              cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/')
              ,cts:element-range-query(xs:QName('AMLAW_200:FISCAL_YEAR'),'>=',$EXPR1) 
              ))
              
 let $fiscalyears := fn:distinct-values(cts:element-values(xs:QName('AMLAW_200:FISCAL_YEAR'),(),(),$query))
 
 	let $result:= for $fYear in $fiscalyears
  let $amquery := cts:and-query((
              cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/')
              ,cts:element-value-query(xs:QName('AMLAW_200:FISCAL_YEAR'),$fYear) 
              ))
  let $am200 := cts:search(/,$amquery)
  let $grossRevenue := $am200//AMLAW_200:GROSS_REVENUE/text()
  let $avgGrossRevenue := xs:integer(fn:round-half-to-even(fn:avg($grossRevenue),0))
  
  let $RPL := $am200//AMLAW_200:RPL/text()
  let $avgRPL := xs:integer(fn:round-half-to-even(fn:avg($RPL),0))
  
  let $ppp :=  $am200//AMLAW_200:PPP/text()
  let $avgppp :=  xs:integer(fn:round-half-to-even(fn:avg($ppp),0))
  
   
  let $netopincome :=  $am200//AMLAW_200:NET_OPERATING_INCOME/text()
  let $avgnetopincome :=  xs:integer(fn:round-half-to-even(fn:avg($netopincome),0))

 
  let $cap :=  $am200//AMLAW_200:CAP/text()
  let $avgcap :=  xs:integer(fn:round-half-to-even(fn:avg($cap),0))

 
  let $numoflawyers :=  $am200//AMLAW_200:NUM_OF_LAWYERS/text()
  let $avgnumoflawyers :=  xs:integer(fn:round-half-to-even(fn:avg($numoflawyers),0))

 
  let $api :=  $am200//AMLAW_200:API/text()
  let $avgapi :=  xs:integer(fn:round-half-to-even(fn:avg($api),0))

  let $responseItem := json:object()
		let $_ := (
            map:put($responseItem,'AVG_GROSSREV',$avgGrossRevenue),
						map:put($responseItem,'AVG_REV_PER_LOWYER',$avgRPL),
						map:put($responseItem,'AVG_PROFIT_PER_PARTNER',$avgppp),
						map:put($responseItem,'AVG_NET_OPT_INCOME',$avgnetopincome),
						map:put($responseItem,'AVG_COMP_AVG',$avgcap),
						map:put($responseItem,'AVG_NUM_LAWYERS',$avgnumoflawyers),
						map:put($responseItem,'AVG_PROFIT_INDEX',$avgapi),
            map:put($responseItem,'YEAR',$fYear)     
						)
            
		let $_ := json:array-push($jsonResult,$responseItem)
		return ()

return $jsonResult
};

declare function report:NLJ250AVGTableAdapter($FYear)
{

let $jsonResult := json:array()

let $maxPALM200 := fn:max(cts:element-values(xs:QName('NLJ_250:FISCAL_YEAR')))
let $EXPR1 := (xs:integer($maxPALM200) - xs:integer($FYear))

let $query :=  cts:and-query((
              cts:directory-query('/LegalCompass/relational-data/surveys/NLJ_250/')
              ,cts:element-range-query(xs:QName('NLJ_250:FISCAL_YEAR'),'>=',$EXPR1) 
              ))
              
 let $fiscalyears := fn:distinct-values(cts:element-values(xs:QName('NLJ_250:FISCAL_YEAR'),(),(),$query))
 
 	let $result:= for $fYear in $fiscalyears
  let $nljquery := cts:and-query((
              cts:directory-query('/LegalCompass/relational-data/surveys/NLJ_250/')
              ,cts:element-value-query(xs:QName('NLJ_250:FISCAL_YEAR'),$fYear) 
              ))
  let $NLJ250 := cts:search(/,$nljquery)
  let $fysalary := $NLJ250//NLJ_250:FIRST_YEAR_SALARY/text()
  let $avgfysalary := xs:integer(fn:round-half-to-even(fn:avg($fysalary),0))
  
  let $numAttroneys := $NLJ250//NLJ_250:NUM_ATTORNEYS/text()
  let $avgnumAttroneys:= xs:integer(fn:round-half-to-even(fn:avg($numAttroneys),0))
  
  let $numPartners :=  $NLJ250//NLJ_250:NUM_PARTNERS/text()
  let $avgnumPartners :=  xs:integer(fn:round-half-to-even(fn:avg($numPartners),0))
  
   
  let $numAssociates :=  $NLJ250//NLJ_250:NUM_ASSOCIATES/text()
  let $avgnumAssociates :=  xs:integer(fn:round-half-to-even(fn:avg($numAssociates),0))

  let $responseItem := json:object()
		let $_ := (
            map:put($responseItem,'AVG_START_SAL',$avgfysalary),
						map:put($responseItem,'AVG_TOTAL_ATTORNEYS',$avgnumAttroneys),
						map:put($responseItem,'AVG_TOTAL_PARTNERS',$avgnumPartners),
						map:put($responseItem,'AVG_TOTAL_ASSOCIATES',$avgnumAssociates),
            map:put($responseItem,'YEAR',$fYear)     
						)
            
		let $_ := json:array-push($jsonResult,$responseItem)
		return ()

return $jsonResult
};

declare function report:GLOBAL100AVGTableAdapter($FYear)
{

let $jsonResult := json:array()

let $maxPALM200 := fn:max(cts:element-values(xs:QName('Global_100:FISCAL_YEAR')))
let $EXPR1 := (xs:integer($maxPALM200) - xs:integer($FYear))

let $query :=  cts:and-query((
              cts:directory-query('/LegalCompass/relational-data/surveys/Global_100/')
              ,cts:element-range-query(xs:QName('Global_100:FISCAL_YEAR'),'>=',$EXPR1) 
              ))
              
 let $fiscalyears := fn:distinct-values(cts:element-values(xs:QName('Global_100:FISCAL_YEAR'),(),(),$query))
 
 	let $result:= for $fYear in $fiscalyears
  let $gbquery := cts:and-query((
              cts:directory-query('/LegalCompass/relational-data/surveys/Global_100/')
              ,cts:element-value-query(xs:QName('Global_100:FISCAL_YEAR'),xs:string($fYear)) 
              ))
  let $GB100 := cts:search(/,$gbquery)
  let $grossRevenue := $GB100//Global_100:GROSS_REVENUE/text()
  let $avgGrossRevenue := xs:integer(fn:round-half-to-even(fn:avg($grossRevenue),0))
  
  let $RevperLaw := $GB100//Global_100:REVENUE_PER_LAWYER/text()
  let $avgRevperLaw:= xs:integer(fn:round-half-to-even(fn:avg($RevperLaw),0))
  
  let $numlawyers :=  $GB100//Global_100:NUM_LAWYERS/text()
  let $avgnumlawyers :=  xs:integer(fn:round-half-to-even(fn:avg($numlawyers),0))
  
   
  let $lohc :=  $GB100//Global_100:LAWYERS_OUTSIDE_HOME_COUNTRY/text()
  let $avglohc:=  xs:integer(fn:round-half-to-even(fn:avg($lohc),0))
  
   let $ncwo :=  $GB100//Global_100:NUM_COUNTRIES_WITH_OFFICES/text()
  let $avgncwo :=  xs:integer(fn:round-half-to-even(fn:avg($ncwo),0))


  let $responseItem := json:object()
		let $_ := (
            map:put($responseItem,'AVG_Gross_REV',$avgGrossRevenue),
						map:put($responseItem,'AVG_PER_LOWYER',$avgRevperLaw),
						map:put($responseItem,'AVG_NUM_LAWYERS',$avgnumlawyers),
						map:put($responseItem,'AVG_NUM_OUTSIDE_HOME_COUNTRY',$avglohc),
            map:put($responseItem,'AVG_NUM_COUNTRIES_WITH_OFFICES',$avgncwo),          
            map:put($responseItem,'YEAR',$fYear)     
						)
            
		let $_ := json:array-push($jsonResult,$responseItem)
		return ()

return $jsonResult
};
declare function report:LATERAL_PARTNERTableAdapter($orgID,$FYear)
{

let $jsonResult := json:array()
let $lquery := cts:and-query((
              cts:directory-query('/LegalCompass/relational-data/surveys/Lateral_Partner/')
              ,cts:element-value-query(xs:QName('Lateral_Partner:ORGANIZATION_ID_JOINED'),$orgID)              
              ))
              
let $maxPALM200 := fn:max(cts:element-values(xs:QName('Lateral_Partner:FISCAL_YEAR'),(),(), $lquery))
let $EXPR1 := (xs:integer($maxPALM200) - xs:integer($FYear))

let $query :=  cts:and-query((
              cts:directory-query('/LegalCompass/relational-data/surveys/Lateral_Partner/')
              ,cts:element-value-query(xs:QName('Lateral_Partner:ORGANIZATION_ID_JOINED'),$orgID)
              ,cts:element-range-query(xs:QName('Lateral_Partner:FISCAL_YEAR'),'>=',$EXPR1) 
              ))
              
  let $LatPartners := cts:search(/,$query)
 
 	let $result:= for $item in $LatPartners
  let $responseItem := json:object()
		let $_ := (
            map:put($responseItem,'LATERALPARTNER_ID',$item//Lateral_Partner:LATERALPARTNER_ID/text()),
						map:put($responseItem,'FISCAL_YEAR',$item//Lateral_Partner:FISCAL_YEAR/text()),
						map:put($responseItem,'FIRST_NAME',$item//Lateral_Partner:FIRST_NAME/text()),
						map:put($responseItem,'MIDDLE_NAME',$item//Lateral_Partner:MIDDLE_NAME/text()),
            map:put($responseItem,'LAST_NAME',$item//Lateral_Partner:LAST_NAME/text()),          
            map:put($responseItem,'SUFFIX',$item//Lateral_Partner:SUFFIX/text()),
            map:put($responseItem,'PRACTICE_AREA',$item//Lateral_Partner:PRACTICE_AREA/text()),   
            map:put($responseItem,'ORGANIZATION_ID_LEFT',$item//Lateral_Partner:ORGANIZATION_ID_LEFT/text()),   
            map:put($responseItem,'ORGANIZATION_NAME_LEFT',$item//Lateral_Partner:ORGANIZATION_NAME_LEFT/text()),   
            map:put($responseItem,'ORGANIZATION_LOCATION_LEFT',$item//Lateral_Partner:ORGANIZATION_LOCATION_LEFT/text()),   
            map:put($responseItem,'ORGANIZATION_ID_JOINED',$item//Lateral_Partner:ORGANIZATION_ID_JOINED/text()),  
            map:put($responseItem,'ORGANIZATION_NAME_JOINED',$item//Lateral_Partner:ORGANIZATION_NAME_JOINED/text()),   
            map:put($responseItem,'ORGANIZATION_LOCATION_JOINED',$item//Lateral_Partner:ORGANIZATION_LOCATION_JOINED/text()),
            map:put($responseItem,'LATERALPARTNER_SOURCE',$item//Lateral_Partner:LATERALPARTNER_SOURCE/text()),
            map:put($responseItem,'LATERALPARTNER_NOTES',$item//Lateral_Partner:LATERALPARTNER_NOTES/text()),       
            map:put($responseItem,'LATERALPARTNER_ALIAS',$item//Lateral_Partner:LATERALPARTNER_ALIAS/text()),
            map:put($responseItem,'CREATE_DATE',$item//Lateral_Partner:CREATE_DATE/text()),
            map:put($responseItem,'CREATED_BY',$item//Lateral_Partner:CREATED_BY/text()),
            map:put($responseItem,'LAST_MODIFIED',$item//Lateral_Partner:LAST_MODIFIED/text()),
            map:put($responseItem,'LAST_MODIFIED_BY',$item//Lateral_Partner:LAST_MODIFIED_BY/text()),
            map:put($responseItem,'LOCKED_BY_USER_ID',$item//Lateral_Partner:LOCKED_BY_USER_ID/text()),
            map:put($responseItem,'LOCKED_DATE_TIME',$item//Lateral_Partner:LOCKED_DATE_TIME/text()),
            map:put($responseItem,'LOCKED_BY_MACHINE_NAME',$item//Lateral_Partner:LOCKED_BY_MACHINE_NAME/text()),
            map:put($responseItem,'LOCKED_BY_PROCESS',$item//Lateral_Partner:LOCKED_BY_PROCESS/text()),
            map:put($responseItem,'MOVE_MONTH',$item//Lateral_Partner:MOVE_MONTH/text()),
            map:put($responseItem,'POSITION_LEFT',$item//Lateral_Partner:POSITION_LEFT/text()),
            map:put($responseItem,'POSITION_JOINED',$item//Lateral_Partner:POSITION_JOINED/text())
               
						)
            
		let $_ := json:array-push($jsonResult,$responseItem)
		return ()

return $jsonResult
};
declare function report:GetLawfirmRevenueHeadcountCusReport($startYear,$endYear,$organizationIds)
{
let $jsonResult := json:array()

(:let $startYear := '2014'
let $endYear := '2018'
let $organizationIds := '178' :)

let $maxAMPY := fn:max(cts:element-values(xs:QName('AMLAW_200:PUBLISHYEAR')))
let $inputorgId := fn:tokenize($organizationIds,',') 
 
let $amDquery := cts:and-query((
                                               cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
                                               cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$inputorgId,'exact'),
                                               cts:element-range-query(xs:QName("AMLAW_200:PUBLISHYEAR"), ">=", xs:integer($startYear)),
                                               cts:element-range-query(xs:QName("AMLAW_200:PUBLISHYEAR"), "<=",  xs:integer($endYear))              
                                               ))                 

let $distinctAmPy := xs:string(fn:distinct-values(cts:element-values(xs:QName('AMLAW_200:PUBLISHYEAR'),(),(),$amDquery)))
                  
   let $orgquery := cts:and-query((
                               cts:directory-query('/LegalCompass/denormalized-data/organization/'),
                               cts:element-value-query(xs:QName('organization:ORGANIZATION_ID'),$inputorgId,'exact'),
                               cts:element-value-query(xs:QName('organization:ORGANIZATION_TYPE_ID'),'1','exact')            
                             ))
                          
  let $organizations := cts:search(/,$orgquery)
  let $orgids :=  $organizations//organization:ORGANIZATION_ID/text()
  let $jsresult := for $oitem in $organizations
                   let $OrgName := if(not(empty($oitem//organization:ALM_NAME/text())))
                                 then $oitem//organization:ALM_NAME/text()
                                 else $oitem//organization:ORGANIZATION_NAME/text()
               
                   let $PYloopresult := for $yearitem in $distinctAmPy
                                        let $orgid := $oitem//organization:ORGANIZATION_ID/text()       
                                        let $orgaSurvey := $oitem//organization:SURVEYS
              
                           
                                       let $AMLUri := for $sitem in $orgaSurvey//SURVEY                                            
                                       let $surveyuri := $sitem//@uri  
                                                        where $sitem//@name eq 'AMLAW_200'
                                       return $surveyuri
               
                                       let $AMLdoc := doc($AMLUri)
                                       let $AMobj := for $ritem in $AMLdoc//survey:YEAR
                                                      where  $ritem//@PublishYear eq $yearitem
                                                      return $ritem
                                       let $AMLAW200_RANK := $AMobj//survey:AMLAW200_RANK/text()
                                       let $AMPublishyear :=  $AMobj//@PublishYear
                                       let $AMGROSS_REVENUE :=  $AMobj[1]//survey:GROSS_REVENUE/text()
                                       let $AMPPP :=  $AMobj//survey:PPP/text()
                                       let $AMNUM_OF_LAWYERS :=  $AMobj//survey:NUM_OF_LAWYERS/text()
                               
                                       let $NSurvey := for $sitem in $organizations//SURVEY                                            
                                       let $surveyuri := $sitem//@uri  
                                                         where $sitem//@name eq 'NLJ_250'
                                                         return $surveyuri
               
                                       let $Ndoc := doc($NSurvey)
                                       let $NLJobj := for $ritem in $Ndoc//survey:YEAR
                                                      where  $ritem//@PublishYear eq $yearitem
                                                      return $ritem
                                       let $NLJ250_RANK := $NLJobj//survey:NLJ250_RANK/text()
                                       let $NLJNUM_ATTORNEYS := $NLJobj//survey:NUM_ATTORNEYS/text()
                                       
                                       let $GSurvey := for $sitem in $organizations//SURVEY                                            
                                                        let $surveyuri := $sitem//@uri  
                                                        where $sitem//@name eq 'Global_100'
                                                        return $surveyuri
                                       let $Gdoc := doc($GSurvey)             
                                       let $GBobj := for $ritem in $Gdoc//survey:YEAR
                                                      where  $ritem//@PublishYear eq (xs:integer($yearitem) -1 )
                                                      return $ritem
                            
                                       let $GbRANK_BY_GROSS_REVENUE := $GBobj[1]//survey:RANK_BY_GROSS_REVENUE/text()   
                                       let $GbNUM_LAWYERS := $GBobj//survey:NUM_LAWYERS/text()    
                                       let $GbPPP := $GBobj//survey:PPP/text()      
                                       let $GBpublishYear := $GBobj//@PublishYear
                                       let $GbGROSS_REVENUE := $GBobj[1]//survey:GROSS_REVENUE/text()
                                       let $ASurvey := for $sitem in $organizations//SURVEY                                            
                                                        let $surveyuri := $sitem//@uri  
                                                        where $sitem//@name eq 'ALIST'
                                                        return $surveyuri
                                       let $Adoc := doc($ASurvey)             
                                       let $Alistobj := for $ritem in $Adoc//survey:YEAR
                                                      where  $ritem//@PublishYear eq (xs:integer($yearitem) - 1)
                                                      return $ritem
                                       let $AListRank := $Alistobj//survey:ALIST_RANK/text()
                                       let $Ukquery := cts:and-query((
                                                       cts:directory-query('/LegalCompass/relational-data/organization/surveys/UK_50/'),
                                                       cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),$orgid,'exact'),
                                                       cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string((xs:integer($yearitem) -1 )),'exact')            
                                                       ))
                                       let $UKobj := cts:search(/,$Ukquery)
                                       let $UkNUMBER_OF_LAWYERS := $UKobj//UK_50:NUMBER_OF_LAWYERS/text()
                                       let $UkPy := $UKobj//UK_50:PUBLISHYEAR/text()
                                       let $UkGROSS_REVENUE := $UKobj[1]//UK_50:GROSS_REVENUE/text()
                                       let $Ukppp := $UKobj//UK_50:PPP_DOLLAR/text()
                                       
                                       let $Chquery := cts:and-query((
                                                       cts:directory-query('/LegalCompass/relational-data/organization/surveys/CHINA_40/'),
                                                       cts:element-value-query(xs:QName('CHINA_40:ORGANIZATION_ID'),$orgid,'exact'),
                                                       cts:element-value-query(xs:QName('CHINA_40:PUBLISHYEAR'),xs:string((xs:integer($yearitem) -1 )),'exact')            
                                                       ))
                                       let $Chobj := cts:search(/,$Chquery)
                                       let $ChPublishYear := $Chobj//CHINA_40:PUBLISHYEAR/text()
                                       let $ChGROSS_REVENUE := $Chobj//CHINA_40:GROSS_REVENUE/text()
                                       let $ChPROFITS_PER_PARTNER := $Chobj//CHINA_40:PROFITS_PER_PARTNER/text()
                                       let $ChFIRMWIDE_LAWYERS := $Chobj//CHINA_40:FIRMWIDE_LAWYERS/text()
                                       let $Chppp := $Chobj//CHINA_40:PROFITS_PER_PARTNER/text()
                                       
                             let $PublishYear := if((empty($AMPublishyear) or ($AMPublishyear eq '')) and (empty($GBpublishYear) or ($GBpublishYear eq '')))
                                                 then if(empty($UkPy) or $UkPy eq '') then $ChPublishYear else $UkPy
                                                 else if((empty($AMPublishyear) or ($AMPublishyear eq ''))) then $GBpublishYear else if(empty($AMPublishyear) or ($AMPublishyear eq '')) 
                                                 then $maxAMPY else $AMPublishyear
                             
                             (: let $GROSS_REVENUE := if((empty($AMGROSS_REVENUE) or ($AMGROSS_REVENUE eq '')) and (empty($GbGROSS_REVENUE) or ($GbGROSS_REVENUE eq '')))
                                                 then if(empty($UkGROSS_REVENUE) or $UkGROSS_REVENUE eq '') then $ChGROSS_REVENUE else $UkGROSS_REVENUE
                                                 else  if(empty($AMGROSS_REVENUE) or ($AMGROSS_REVENUE eq '')) then $GbGROSS_REVENUE  
                                                 else $AMGROSS_REVENUE :)

                            let $GROSS_REVENUE := if($AMGROSS_REVENUE) then $AMGROSS_REVENUE
                                                  else if($GbGROSS_REVENUE) then $GbGROSS_REVENUE
                                                  else if($UkGROSS_REVENUE) then $UkGROSS_REVENUE
                                                  else 0
                                                 
                                             
                             let $PPP := if((empty($AMPPP) or ($AMPPP eq '')) and (empty($GbPPP) or ($GbPPP eq '')))
                                                 then if(empty($Ukppp) or $Ukppp eq '') then $Chppp else $Ukppp
                                                 else  if(empty($AMPPP) or ($AMPPP eq '')) then $GbPPP  
                                                 else $AMPPP
                             
                             let $NoofAttorneys := if((empty($NLJNUM_ATTORNEYS) or ($NLJNUM_ATTORNEYS eq '')) and (empty($AMNUM_OF_LAWYERS) or ($AMNUM_OF_LAWYERS eq '')))
                                                 then if(empty($UkNUMBER_OF_LAWYERS) or $UkNUMBER_OF_LAWYERS eq '') then $ChFIRMWIDE_LAWYERS else $UkNUMBER_OF_LAWYERS
                                                 else  if(empty($NLJNUM_ATTORNEYS) or ($NLJNUM_ATTORNEYS eq '')) then $GbNUM_LAWYERS  
                                                 else  if(empty($AMNUM_OF_LAWYERS) or ($AMNUM_OF_LAWYERS eq '')) then $NLJNUM_ATTORNEYS else $AMNUM_OF_LAWYERS
                             
                             let $responseItem := json:object()  
                              let $_ := (
                            	            map:put($responseItem, 'FirmId',$oitem//organization:ORGANIZATION_ID/text()),
                                          map:put($responseItem, 'FirmName',$OrgName),
                                          map:put($responseItem, 'FirmId',$oitem//organization:ORGANIZATION_ID/text()),
                                          map:put($responseItem, 'PublishYear',$PublishYear[1]),
                                          map:put($responseItem, 'GrossRevenue',$GROSS_REVENUE),
                                          map:put($responseItem, 'AMLaw200Rank',$AMLAW200_RANK),
                                          map:put($responseItem, 'NLJ500Rank',$NLJ250_RANK),
                                          map:put($responseItem, 'AListRank',$AListRank ),  
                                          map:put($responseItem, 'Global100Rank',$GbRANK_BY_GROSS_REVENUE),
                                          map:put($responseItem, 'HeadCount',$NoofAttorneys)
                                       
                                         )
                              let $_ := json:array-push($jsonResult,$responseItem)           
                              return ()
                              return ()
                              (: let $jsonResult := json:to-array($jsresult)   :)
                              
return $jsonResult

};
declare function report:PARTNER_PROMOTIONSTableAdapter($orgID,$FYear)
{
let $jsonResult := json:array()
let $lquery := cts:and-query((
              cts:directory-query('/LegalCompass/relational-data/PARTNER_PROMOTIONS/')
              ,cts:element-value-query(xs:QName('PARTNER_PROMOTIONS:ORGANIZATION_ID'),$orgID)              
              ))
              
let $maxPALM200 := fn:max(cts:element-values(xs:QName('PARTNER_PROMOTIONS:FISCAL_YEAR'),(),(), $lquery))


let $EXPR1 := (xs:integer($maxPALM200) - xs:integer($FYear))

let $query :=  cts:and-query((
              cts:directory-query('/LegalCompass/relational-data/PARTNER_PROMOTIONS/')
              ,cts:element-value-query(xs:QName('PARTNER_PROMOTIONS:ORGANIZATION_ID'),$orgID)
              ,cts:element-range-query(xs:QName('PARTNER_PROMOTIONS:FISCAL_YEAR'),'>=',$EXPR1) 
              ))
              

  let $LatPartners := cts:search(/,$query)
  
 	let $result:= for $item in $LatPartners
  let $responseItem := json:object()
		let $_ := (
            map:put($responseItem,'PROMOTION_ID',$item//PARTNER_PROMOTIONS:PROMOTION_ID/text()),
						map:put($responseItem,'ORGANIZATION_ID',$item//PARTNER_PROMOTIONS:ORGANIZATION_ID/text()),
						map:put($responseItem,'ORGANIZATION_NAME',$item//PARTNER_PROMOTIONS:ORGANIZATION_NAME/text()),
						map:put($responseItem,'ANNOUNCED_MONTH',$item//PARTNER_PROMOTIONS:ANNOUNCED_MONTH/text()),
            map:put($responseItem,'FISCAL_YEAR',$item//PARTNER_PROMOTIONS:FISCAL_YEAR/text()),          
            map:put($responseItem,'MOVE_MONTH',$item//PARTNER_PROMOTIONS:MOVE_MONTH/text()),
             map:put($responseItem,'FIRST_NAME',$item//PARTNER_PROMOTIONS:FIRST_NAME/text()),           
           map:put($responseItem,'MIDDLE_NAME',$item//PARTNER_PROMOTIONS:MIDDLE_NAME/text()),   
           map:put($responseItem,'LAST_NAME',$item//PARTNER_PROMOTIONS:LAST_NAME/text()),   
           map:put($responseItem,'GENDER',$item//PARTNER_PROMOTIONS:GENDER/text()),      
            map:put($responseItem,'PRACTICE_AREA',$item//PARTNER_PROMOTIONS:PRACTICE_AREA/text()),   
            map:put($responseItem,'FIRM_LOCATION_FROM',$item//PARTNER_PROMOTIONS:FIRM_LOCATION_FROM/text()),   
            map:put($responseItem,'POSITION_FROM',$item//PARTNER_PROMOTIONS:POSITION_FROM/text()),   
            map:put($responseItem,'POSITION_TO',$item//PARTNER_PROMOTIONS:POSITION_TO/text()),  
            map:put($responseItem,'FIRM_LOCATION_TO',$item//PARTNER_PROMOTIONS:FIRM_LOCATION_TO/text()),
              map:put($responseItem,'SOURCE',$item//PARTNER_PROMOTIONS:SOURCE/text())          
					
						)
            
		let $_ := json:array-push($jsonResult,$responseItem)
		return ()

return $jsonResult
};

declare function report:GetLFRFileNameCustom($orgID,$format,$strTabs,$years)
{
let $format := fn:lower-case(fn:normalize-space($format))
let $jsonResult := json:array()
let $query := cts:and-query((
              cts:directory-query('/LegalCompass/relational-data/LAWFIRM_REPORTFILES_CUSTOM/')
              ,cts:element-value-query(xs:QName('LAWFIRM_REPORTFILES_CUSTOM:ORGANIZATION_ID'),$orgID)
              ,cts:element-value-query(xs:QName('LAWFIRM_REPORTFILES_CUSTOM:FORMAT'),$format)              
               ,cts:element-value-query(xs:QName('LAWFIRM_REPORTFILES_CUSTOM:ISGENERATE'),'1')              
              ,cts:element-value-query(xs:QName('LAWFIRM_REPORTFILES_CUSTOM:TAB'),$strTabs)          
              ,cts:element-value-query(xs:QName('LAWFIRM_REPORTFILES_CUSTOM:YEARS'),$years)              
          
              ))
              
  let $LatPartners := cts:search(/,$query)
  let $result:= for $item in $LatPartners
  let $responseItem := json:object()
  let $_ := admin-update-helper:GetJSON($responseItem,$item,'LAWFIRM_REPORTFILES_CUSTOM','LAWFIRM_REPORTFILES_CUSTOM',())
  
       let $_ := json:array-push($jsonResult,$responseItem)
       return ()


return $jsonResult
};