module namespace admin-update-helper = 'http://alm.com/admin-update-helper';
import module namespace config = 'http://alm.com/config' at '/common/config.xqy';
import module namespace json = 'http://marklogic.com/xdmp/json'  at '/MarkLogic/json/json.xqy';

declare namespace survey = 'http://alm.com/LegalCompass/rd/survey-listing';
declare namespace pq-ns = 'http://alm.com/LegalCompass/rd/productqualification';
declare namespace pm-pq-ns = 'http://alm.com/LegalCompass/rd/PromotionProductQualification';
declare namespace participate = 'http://alm.com/LegalCompass/rd/PARTICIPATE';
declare namespace organization = 'http://alm.com/LegalCompass/rd/organization';
declare namespace organization-address = 'http://alm.com/LegalCompass/rd/organization-address';
declare namespace organization-attorney = 'http://alm.com/LegalCompass/rd/organization-attorney';
declare namespace organization-merger = 'http://alm.com/LegalCompass/rd/organization-merger';
declare namespace org-type = 'http://alm.com/LegalCompass/rd/organization-type';
declare namespace org-industry-type = 'http://alm.com/LegalCompass/rd/ORGANIZATION_INDUSTRY_TYPE';
declare namespace SURVEY_TABLES = 'http://alm.com/LegalCompass/rd/SURVEY_TABLES';
declare namespace surveydetails = 'http://alm.com/LegalCompass/rd/surveydetails';
declare namespace sllc-ns = 'http://alm.com/LegalCompass/rd/SURVEYLISTINGLAWCATIDS';
declare namespace PRO_BONO = 'http://alm.com/LegalCompass/rd/Pro_Bono';
declare namespace ASSOCIATE_NATL = 'http://alm.com/LegalCompass/rd/Associate_natl';
declare namespace ASSOCIATE_CITY = 'http://alm.com/LegalCompass/rd/ASSOCIATE_CITY';
declare namespace ASSOCIATE_CLASS_BILLING_SURVEY = 'http://alm.com/LegalCompass/rd/ASSOCIATE_CLASS_BILLING_SURVEY';
declare namespace NY100 = 'http://alm.com/LegalCompass/rd/NY100';
declare namespace BILLING_SURVEY_FLORIDA = 'http://alm.com/LegalCompass/rd/Billing_Survey_Florida';
declare namespace DC20 = 'http://alm.com/LegalCompass/rd/DC20';
declare namespace INHOUSE_TECH_SURVEY = 'http://alm.com/LegalCompass/rd/INHOUSE_TECH_SURVEY';
declare namespace ASSOCIATE_SUMMER_SURVEY = 'http://alm.com/LegalCompass/rd/ASSOCIATE_SUMMER_SURVEY';
declare namespace ASSOCIATE_SUMMER_CITY_SURVEY = 'http://alm.com/LegalCompass/rd/ASSOCIATE_SUMMER_CITY_SURVEY';
declare namespace GENERAL_COUNSEL_SALARY = 'http://alm.com/LegalCompass/rd/GENERAL_COUNSEL_SALARY';
declare namespace FEMALE_SCORECARD = 'http://alm.com/LegalCompass/rd/FEMALE_SCORECARD';
declare namespace TOP500 = 'http://alm.com/LegalCompass/rd/TOP500';
declare namespace LAWFIRM_MERGERS = 'http://alm.com/LegalCompass/rd/LAWFIRM_MERGERS';
declare namespace AMLAW_100 = 'http://alm.com/LegalCompass/rd/AMLAW_100';
declare namespace AMLAW_200 = 'http://alm.com/LegalCompass/rd/AMLAW_200';
declare namespace organization-contact = 'http://alm.com/LegalCompass/rd/organization-contact';
declare namespace ARBITRATION_SCORECARD = 'http://alm.com/LegalCompass/rd/ARBITRATION_SCORECARD';
declare namespace NLJ_BILLING = 'http://alm.com/LegalCompass/rd/NLJ_BILLING';
declare namespace TX100 = 'http://alm.com/LegalCompass/rd/TX100';
declare namespace LAWFIRM_CLOSURES = 'http://alm.com/LegalCompass/rd/LAWFIRM_CLOSURES';
declare namespace organization-branch = 'http://alm.com/LegalCompass/rd/organization-branch';
declare namespace TOPICS = 'http://alm.com/LegalCompass/rd/Topics';
declare namespace ADMINDETAILS = 'http://alm.com/LegalCompass/rd/ADMINDETAILS';
declare namespace ADMINMODULE = 'http://alm.com/LegalCompass/rd/ADMINMODULE';
declare namespace ADMINROLEMODULE = 'http://alm.com/LegalCompass/rd/ADMINROLEMODULE';
declare namespace SURVEY_META = 'http://alm.com/LegalCompass/rd/SURVEY_META';
declare namespace bdbs-bulkupload = 'xmlns="http://alm.com/LegalCompass/rd/bdbs-bulkupload"';
declare namespace survey-tables = 'http://alm.com/LegalCompass/rd/SURVEY_TABLES';
declare namespace DATAVISUALIZATION_NEW = 'http://alm.com/LegalCompass/rd/DATAVISUALIZATION_New';
declare namespace ALIST = "http://alm.com/LegalCompass/rd/ALIST";
declare namespace CORPORATE_SCORECARD = 'http://alm.com/LegalCompass/rd/Corporate_scorecard';
declare namespace DIVERSITY_SCORECARD = 'http://alm.com/LegalCompass/rd/Diversity_Scorecard';
declare namespace GC_CONTACTS = "http://alm.com/LegalCompass/rd/GC_CONTACTS";
declare namespace GLOBAL_100 = 'http://alm.com/LegalCompass/rd/Global_100';
declare namespace GOINGRATE_DETAILS = 'http://alm.com/LegalCompass/rd/GOINGRATE_DETAILS';
declare namespace LAW_SCHOOLS = 'http://alm.com/LegalCompass/rd/LAW_SCHOOLS';
declare namespace LEGAL_TIMES_150 = 'http://alm.com/LegalCompass/rd/Legal_Times_150';
declare namespace NLJ_STAFFING = 'http://alm.com/LegalCompass/rd/NLJ_Staffing';
declare namespace NLJ_LGBT = 'http://alm.com/LegalCompass/rd/NLJ_LGBT';
declare namespace PA100 = 'http://alm.com/LegalCompass/rd/PA100';
declare namespace NJ20 = 'http://alm.com/LegalCompass/rd/pref';
declare namespace GOINGRATE_MASTER= 'http://alm.com/LegalCompass/rd/GOINGRATE_MASTER';
declare namespace LATERAL_PARTNER = 'http://alm.com/LegalCompass/rd/Lateral_Partner';
declare namespace PRESS_RELEASES = 'http://alm.com/LegalCompass/rd/PRESS_RELEASES';
declare namespace NLJ_250 = 'http://alm.com/LegalCompass/rd/NLJ_250';
declare namespace OVERVIEW_STATISTICS = 'http://alm.com/LegalCompass/rd/OVERVIEW_STATISTICS';
declare namespace SURVEY_ORGANIZATIONS = 'http://alm.com/LegalCompass/rd/SURVEY_ORGANIZATIONS';
declare namespace SALARY_SUPPLEMENT = 'http://alm.com/LegalCompass/rd/SALARY_SUPPLEMENT';
declare namespace SURVEY_ARTICLES = 'http://alm.com/LegalCompass/rd/SURVEY_ARTICLES';
declare namespace SURVEY_EVENTS = 'http://alm.com/LegalCompass/rd/SURVEY_EVENTS';
declare namespace TECH_BUY = 'http://alm.com/LegalCompass/rd/TECH_BUY';
declare namespace WHO_COUNSELS_WHO = 'http://alm.com/LegalCompass/rd/Who_Counsels_who';
declare namespace ORGANIZATION_CONTACT = 'http://alm.com/LegalCompass/rd/organization-contact';
declare namespace bdbs_party = 'http://alm.com/LegalCompass/rd/bdbs-party';
declare namespace bdbs_transaction = 'http://alm.com/LegalCompass/rd/bdbs-transaction';
declare namespace bdbs_representer = 'http://alm.com/LegalCompass/rd/bdbs-representer';
declare namespace bdbs_people = 'http://alm.com/LegalCompass/rd/bdbs-people';
declare namespace ORGANIZATION_ADDRESS = 'http://alm.com/LegalCompass/rd/organization-address';
declare namespace TECH_SCORECARD = 'http://alm.com/LegalCompass/rd/Tech_Scorecard';
declare namespace TX25 = 'http://alm.com/LegalCompass/rd/TX251';
declare namespace GCCOMPENSATION = 'http://alm.com/LegalCompass/GLL/rd/GCCompensation';
declare namespace TOP500_CONTACTDETAILS_NEW = 'http://alm.com/LegalCompass/rd/TOP500_CONTACTDETAILS_NEW';
declare namespace PRODUCTS = 'http://alm.com/LegalCompass/rd/PRODUCTS';
declare namespace DATAVISUALIZATION_TOPIC_DETAIL = 'http://alm.com/LegalCompass/rd/DATAVISUALIZATION_TOPIC_DETAIL';

declare namespace survey-listing = 'http://alm.com/LegalCompass/rd/survey-listing';
declare namespace SurveyListingFiles = 'http://alm.com/LegalCompass/rd/SurveyListingFiles';
declare namespace SURVEY_TOPICS = 'http://alm.com/LegalCompass/rd/SURVEY_TOPICS';
declare namespace ORGANIZATIONS = 'http://alm.com/LegalCompass/rd/organization';
declare namespace BDBS_TRANSACTIONS = 'http://alm.com/LegalCompass/rd/bdbs-transaction';
declare namespace Diversity_Scorecard = 'http://alm.com/LegalCompass/rd/Diversity_Scorecard';
declare namespace Global_100 = 'http://alm.com/LegalCompass/rd/Global_100';
declare namespace LAWFIRM_REPORTFILES_CUSTOM = 'http://alm.com/LegalCompass/rd/LAWFIRM_REPORTFILES_CUSTOM';
declare namespace SURVEYLISTINGFILES  = 'http://alm.com/LegalCompass/rd/SurveyListingFiles';

declare option xdmp:mapping 'false';

declare function admin-update-helper:Update($request,$uri,$namespace)
{
  let $doc := fn:doc($uri)
  for $name in $request//*/name()
    let $_:= xdmp:node-replace(xdmp:value(concat('$doc//*/',$namespace,':',$name))/text(),text{xdmp:value(concat('$request/',$namespace,':',$name))/text()})  
  return $uri 
};

declare function admin-update-helper:Update1($request,$uri,$namespace)
{  
  (:let $doc := fn:doc($uri)
  for $name in $request//*/element()/name()
    let $_:= xdmp:node-replace(xdmp:value(concat('$doc//*/',$namespace,':',$name)),xdmp:value(concat('$request//',$namespace,':',$name)))  
  return $uri:)

  let $doc := fn:doc($uri)
  for $name in $request//*/name()
    let $_:= xdmp:node-replace(xdmp:value(concat('$doc//*/',$namespace,':',$name)),xdmp:value(concat('$request//',$namespace,':',$name)))  
  return $uri

};

declare function admin-update-helper:Update2($request,$uri,$namespace)
{  
   let $doc := fn:doc($uri)
  for $name in $request//*/element()/name()
    let $_:= xdmp:node-replace(xdmp:value(concat('$doc//*/',$namespace,':',$name)),xdmp:value(concat('$request//',$namespace,':',$name)))  
  return $uri
};

(:
Developed by Raveendra Sharma on 01/08/2018
:)
declare function admin-update-helper:UpdateR($request,$uri,$nsName, $excludeColumns)
{
  let $doc := fn:doc($uri)  
  let $elements := fn:distinct-values($request/*/fn:node-name(.))
  
  let $_ := for $name in $elements
    let $_:= xdmp:node-replace(xdmp:value(concat('$doc//*/',$nsName,':',$name)),xdmp:value(concat('$request//',$nsName,':',$name))) 
		return $_
  
  return $_  
};

declare function admin-update-helper:TestUpdate($uri,$namespace,$element,$newvalue)
{
  let $doc := doc($uri)
  let $newValueNode := element { fn:QName($namespace, $element) } {xs:string($newvalue)}
  return xdmp:node-replace(xdmp:value(concat('$doc//',$namespace,':',$element)),$newValueNode)
  (:return xdmp:value(concat('$doc//',$namespace,':',$element)):)
  (:return xdmp:node-replace(xdmp:value(concat('$doc//',$namespace,':',$element))//text(),text{$new}):) 
  (:xdmp:node-replace(concat($doc,"//",$namespace,':',$element)/text()):)
};

declare function admin-update-helper:GetJSON($responseItem,$item,$namespace,$root,$alias-xml)
{
	let $responseItem := if (empty($responseItem)) then json:object() else $responseItem
	let $_:= for $name in $item//*/name()
  let $_ := 
    if (not($name=$root)) then
     map:put($responseItem, GetAlias($name,$alias-xml), xdmp:value(concat('$item//',$namespace,':',$name))/text())
    else ()
  return $responseItem
	return $responseItem
};


declare function admin-update-helper:GetJSONForSelectedNodes($responseItem,$item,$namespace,$root,$selectedNodes,$alias-xml)
{
	let $responseItem := if (empty($responseItem)) then json:object() else $responseItem
	let $_:= for $name in $selectedNodes
  let $_ := 
    if (not ($name=$root)) then
     map:put($responseItem, GetAliasOnly($name,$alias-xml), xdmp:value(concat('$item//',$namespace,':',$name))/text())
    else ()
  return $responseItem
	return $responseItem
};



declare function admin-update-helper:GetAlias($name,$alias-xml)
{
  let $alias-name:= 
    if(empty($alias-xml)) then 
      $name
    else (xdmp:value(concat('$alias-xml/',$name))/text() )

  let $result:= 
    if (empty($alias-name)) then
      $name 
    else ($alias-name)

  return $result

};


declare function admin-update-helper:GetAliasOnly($name,$alias-xml)
{
  let $alias-name:= 
    if(empty($alias-xml)) then 
      $name
    else (xdmp:value(concat('$alias-xml/',$name))/text() )

  let $result:= 
    if (empty($alias-name)) then
      $name 
    else ($alias-name)

  return $result

};


(:declare function admin-update-helper:GetSurveyDataByYear($tableName,$columnName,$fiscalYear)
{
    let $concatTableName := if($tableName eq 'INHOUSE_TECH_SURVEY') then
                                xs:string(fn:concat('/LegalCompass/relational-data/',xs:string($tableName),'/'))
                                else
                                xs:string(fn:concat('/LegalCompass/relational-data/surveys/',xs:string($tableName),'/'))
  
    let $uri := cts:uri-match($concatTableName,'case-insensitive')
    
    (:let $ctsDirQuery := cts:directory-query($uri):)
    
    let $elementValQueryCond := xs:string(fn:concat(fn:upper-case($tableName),':',xs:string(fn:upper-case($columnName))))
    
    let $data := cts:search(/,
                        cts:and-query((
                        cts:directory-query($uri),                        
                        if($fiscalYear ne '') then cts:element-value-query(xs:QName($elementValQueryCond),$fiscalYear) else()
                        )))
(: let $jsonResult := json:array()
      let $loopData := for $items in $data
              let $responseItem := json:object()
              let $a := local:GetJSON($responseItem,$items,xs:string(fn:upper-case($tableName)),'AssociateNATL',())
              let $b := json:array-push($jsonResult, $responseItem)
           return()
  return json:array-size($jsonResult):)
  return $data
};:)

declare function admin-update-helper:GetSurveyDataByYear($tableName,$columnName,$fiscalYear)
{
    let $elementValQueryTypeCond := if($tableName eq 'ARBITRATION_SCORECARD') 
                                    then 
                                      cts:element-value-query(xs:QName('ARBITRATION_SCORECARD:TYPE'),'contract') 
                                    else if($tableName eq 'ARBITRATION_SCORECARD_TREATY')
                                    then 
                                      cts:element-value-query(xs:QName('ARBITRATION_SCORECARD:TYPE'),'treaty') 
                                    else ()

    let $realtableName := if($tableName eq 'ARBITRATION_SCORECARD_TREATY') 
                                    then 'ARBITRATION_SCORECARD'
                                    else $tableName

    let $concatTableName := if($realtableName eq 'INHOUSE_TECH_SURVEY') then
                                xs:string(fn:concat('/LegalCompass/relational-data/',xs:string($realtableName),'/'))
                                else
                                xs:string(fn:concat('/LegalCompass/relational-data/surveys/',xs:string($realtableName),'/'))
  
    let $uri := cts:uri-match($concatTableName,'case-insensitive')
    
    (:let $ctsDirQuery := cts:directory-query($uri):)
    
    let $elementValQueryCond := xs:string(fn:concat(fn:upper-case($realtableName),':',xs:string(fn:upper-case($columnName))))
    

    let $data := cts:search(/,
                        cts:and-query((
                        cts:directory-query($uri),                        
                        if($fiscalYear ne '') then cts:element-value-query(xs:QName($elementValQueryCond),$fiscalYear) else(),
                        $elementValQueryTypeCond
                        )))
  return $data
};

declare function admin-update-helper:GetSurveyMaxYear($survey,$columnName)
{
  let $result := fn:max(cts:element-values(xs:QName(concat(xdmp:value('$survey'),':',$columnName))))
  return $result

};

declare function admin-update-helper:GetJSONNewWithoutRootNode($responseItem,$item,$namespace,$root,$alias-xml)
{
	let $responseItem := if (empty($responseItem)) then json:object() else $responseItem
	let $_:= for $name in $item//*/element()/name()
  let $_ := 
    if (not ($name=$root)) then
     map:put($responseItem, GetAlias($name,$alias-xml), xdmp:value(concat('$item//',$namespace,':',$name))/text())
    else ()
  return $responseItem
	return $responseItem
};

declare function admin-update-helper:UpdateEmptyNode($request,$uri,$namespace,$nsuri)
{
  let $doc := fn:doc($uri)
  let $_ := for $name in $request//*/name() 
  let $_ := if(empty(xdmp:value(concat('$doc//*/',$namespace,':',$name))/text()))
       then 
         xdmp:node-replace(xdmp:value(concat('$doc//*/',$namespace,':',$name)),xdmp:value(fn:concat('<',$name,' ','xmlns="',$nsuri,'"','>',xdmp:value(concat('$request/',$namespace,':',$name))/text(),'</',$name,'>')))
       else  
       xdmp:node-replace(xdmp:value(concat('$doc//*/',$namespace,':',$name)),xdmp:value(concat('$request//',$namespace,':',$name)))         
  return ()
  return $uri

};

