xquery version '1.0-ml';

module namespace survey-listing = 'http://alm.com/survey-listing';

import module namespace config = 'http://alm.com/config' at '/common/config.xqy';
import module namespace helper = 'http://alm.com/helper' at '/common/model/helper.xqy';
import module namespace json = 'http://marklogic.com/xdmp/json'  at '/MarkLogic/json/json.xqy';

declare namespace survey = 'http://alm.com/LegalCompass/dd/survey';
declare namespace LC_WATCHLIST = 'http://alm.com/LegalCompass/rd/LC_WATCHLIST';
declare namespace AMLAW_200 = "http://alm.com/LegalCompass/rd/AMLAW_200";
declare namespace amlaw100 = "http://alm.com/LegalCompass/rd/AMLAW_100";

declare namespace AMLAW_100 = 'http://alm.com/LegalCompass/rd/AMLAW_100';
declare namespace global100 = "http://alm.com/LegalCompass/rd/Global_100";
declare namespace nlj250 = "http://alm.com/LegalCompass/rd/NLJ_250";
declare namespace FIRMSALIXREF = 'http://alm.com/LegalCompass/rd/FIRMS_ALI_XREF_RE';
declare namespace SURVEY-LISTING = 'http://alm.com/LegalCompass/rd/survey-listing';

declare option xdmp:mapping 'false';

declare function survey-listing:GetReID($aliIDs)
{
	let $result :=cts:search(/,
				   cts:and-query((
                    cts:directory-query('/LegalCompass/relational-data/FIRMS_ALI_XREF_RE/'),
					cts:element-value-query(xs:QName('FIRMSALIXREF:ALI_ID'),fn:tokenize($aliIDs ,','))
                )))//FIRMSALIXREF:RE_ID/text()
				
	(:let $response-arr := json:array()
  
	let $_ := for $item in $result
		let $response-obj := json:object()
        let $_ := (map:put($response-obj,"",$item))
        let $_ := json:array-push($response-arr,$item)
        return()	:)	
	return json:to-array($result)
};

declare function survey-listing:GetSurveyOrganizations($tableName, $type)
{
	
	let $response := if ($tableName eq 'Am Law 100') then 
		(
			let $maxYear := fn:max(cts:element-attribute-values(xs:QName('survey:YEAR'), xs:QName('PublishYear'),(),('descending'),
				cts:directory-query($config:DD-SURVEY-AMLAW_100-PATH)))
			
			let $result :=cts:search(/,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_100/'),
                        cts:element-value-query(xs:QName('amlaw100:PUBLISHYEAR'),xs:string(max($maxYear)))
						,cts:not-query(cts:element-value-query(xs:QName('amlaw100:AMLAW100_RANK'),''))
                      )))
			
			return fn:distinct-values($result//amlaw100:ORGANIZATION_ID/text())
        )
		else if ($tableName eq 'Am Law 200') then
		(
		(:cts:values(cts:element-reference(xs:QName('companyprofilelfrnew:COMPANY_ID')), (), (),$query2):)
			let $maxYear := fn:max(cts:search(/,
								cts:and-query((
									cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/')
								)))//AMLAW_200:PUBLISHYEAR/text())
			
			(:fn:max(cts:element-attribute-values(xs:QName('AMLAW_200:AMLAW_200'), xs:QName('PublishYear'),(),('descending'),
				cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'))):)
			
			let $result :=cts:search(/,
				cts:and-query((
                    cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
					cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($maxYear))
					,cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
                )))
			
			(: return fn:distinct-values($result) :)
			return fn:distinct-values($result//AMLAW_200:ORGANIZATION_ID/text())
        )
		else if ($tableName eq 'Global 200') then
		(
			let $maxYear := fn:max(cts:element-attribute-values(xs:QName('survey:YEAR'), xs:QName('PublishYear'),(),('descending'),
				cts:directory-query($config:DD-SURVEY-GLOBAL_100-PATH)))
			
			 let $result :=cts:search(/,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/surveys/Global_100/'),
                        cts:element-value-query(xs:QName('global100:PUBLISHYEAR'),xs:string(max($maxYear)))
						,cts:not-query(cts:element-value-query(xs:QName('global100:RANK_BY_GROSS_REVENUE'),''))
                      )))
			return fn:distinct-values($result//global100:ORGANIZATION_ID/text())
        )
		else if ($tableName eq 'NLJ 500') then
		(
			let $maxYear := fn:max(cts:element-attribute-values(xs:QName('survey:YEAR'), xs:QName('PublishYear'),(),('descending'),
				cts:directory-query($config:DD-SURVEY-NLJ_250-PATH)))
			
			let $result :=cts:search(/,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/surveys/NLJ_250/'),
                        cts:element-value-query(xs:QName('nlj250:PUBLISHYEAR'),xs:string(max($maxYear)))
						,cts:not-query(cts:element-value-query(xs:QName('nlj250:NLJ250_RANK'),''))
                      )))
			return fn:distinct-values($result//nlj250:ORGANIZATION_ID/text())
		)

		else if ($tableName eq 'Am Law 25') then
		(
			let $maxYear := fn:max(cts:search(/,
								cts:and-query((
									cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/')
								)))//AMLAW_200:PUBLISHYEAR/text())
			
			let $result :=cts:search(/,
				cts:and-query((
                    cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
					cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($maxYear)),
					cts:element-range-query(xs:QName('AMLAW_200:AMLAW200_RANK'),'<=',25),
					cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
                )))
			
			return fn:distinct-values($result//AMLAW_200:ORGANIZATION_ID/text())
		)

        else
		(
			(: let $tableName := fn:replace($tableName,"'", "''") :)
			let $result :=cts:search(/LC_WATCHLIST,
				cts:and-query((
					cts:directory-query($config:RD-LC_WATCHLIST-PATH)
					,cts:element-value-query(xs:QName('LC_WATCHLIST:WATCHLIST_NAME'), xs:string($tableName),('case-insensitive'))
					,cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
                )))/LC_WATCHLIST:ORGANIZATION_ID/text()
			
			return fn:distinct-values($result)
		)
	
	let $response-arr := json:array()
  
	let $_ := for $item in $response
		let $response-obj := json:object()
        let $_ := (map:put($response-obj,"",$item))
        let $_ := json:array-push($response-arr,$item)
        return()
	
	return if ($type eq 'JSON') then $response-arr else $response
};

declare function survey-listing:GetSurveyList($ids,$years,$clause)
{
	(:    let $ids := '10000087,49,10000091' :)
    let $nsName := 'SURVEY-LISTING'
	  let $directory := 'survey-listing'

    let $fullDirectoryPath := '/LegalCompass/relational-data/survey-listing/'
    let $filterColumn := 'SURVEYLISTINGID'
    let $filterValue := fn:tokenize($ids,',')

	  let $qName := fn:concat($nsName,':')
    let $filterQuery := if ($ids eq '') then () else cts:element-value-query(xs:QName(concat($qName,$filterColumn)),$filterValue)  
    let $notEmptyTableNameQuery := cts:not-query(cts:element-value-query(xs:QName(concat($qName,'TABLENAME')),''))
    
    let $result := cts:search(/,
  	                  cts:and-query((
    	                cts:directory-query($fullDirectoryPath)
                      , $filterQuery
                      , $notEmptyTableNameQuery)))
   
   let $maxYear := fn:max(cts:search(/,
                         cts:and-query((
                             cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_100/'))))//AMLAW_100:PUBLISHYEAR/text())
   
   let $finalResult := for $i in $result
                    let $tableName := $i//SURVEY-LISTING:TABLENAME/text()
                    let $surveyListID := $i//SURVEY-LISTING:SURVEYLISTINGID/text()
                    let $surveyName := $i//SURVEY-LISTING:NAME/text()
      
                    let $directoryName := $tableName
                    let $directoryPath := fn:concat('/LegalCompass/relational-data/surveys/',$directoryName, '/')
  
                    let $nsName := $directoryName
                    
                    let $tableNameUpper := fn:upper-case($tableName)
                    
                    let $nsName := if ($tableNameUpper eq 'LATERAL_PARTNER') then 'LATERAL_PARTNER'  else $nsName
                    let $nsName := if ($tableNameUpper eq 'LEGAL_TIMES_150') then 'LEGAL_TIMES_150' else $nsName
                    let $nsName := if ($tableNameUpper eq 'TECH_SCORECARD') then 'TECH_SCORECARD' else $nsName
                    let $nsName := if ($tableNameUpper eq 'WHO_COUNSELS_WHO') then 'WHO_COUNSELS_WHO' else $nsName
                    let $nsName := if ($tableNameUpper eq 'BILLING_SURVEY_FLORIDA') then 'BILLING_SURVEY_FLORIDA' else $nsName
                    let $nsName := if ($tableNameUpper eq 'GLOBAL_100') then 'GLOBAL_100' else $nsName
                    let $nsName := if ($tableNameUpper eq 'ASSOCIATE_NATL') then 'ASSOCIATE_NATL' else $nsName
                    let $nsName := if ($tableNameUpper eq 'PRO_BONO') then 'PRO_BONO' else $nsName
                    let $nsName := if ($tableNameUpper eq 'NLJ_STAFFING') then 'NLJ_STAFFING' else $nsName
                    let $nsName := if ($tableNameUpper eq 'ASSOCIATE_SUMMER_SURVEY') then 'ASSOCIATE_SUMMER_SURVEY' else $nsName
                    let $nsName := if ($tableNameUpper eq 'DIVERSITY_SCORECARD') then 'DIVERSITY_SCORECARD' else $nsName
                    let $nsName := if ($tableNameUpper eq 'CORPORATE_SCORECARD') then 'CORPORATE_SCORECARD' else $nsName
                    let $qName := fn:concat($nsName,':')
       
                    let $tempResult := if ($tableName ne '') then cts:search(/,
  	                            cts:and-query((
    	                        	cts:directory-query($directoryPath)
                                	,
									if($years ne '')
										then 
											if($clause eq "In List")
											then cts:element-value-query(xs:QName(concat($qName,'PUBLISHYEAR')), ( fn:tokenize($years,",") ))
											else cts:not-query(cts:element-value-query(xs:QName(concat($qName,'PUBLISHYEAR')), ( fn:tokenize($years,",") )))
										else cts:element-value-query(xs:QName(concat($qName,'PUBLISHYEAR')), xs:string($maxYear)) 
  	                            ))) else ()
                    
                    let $oganizationIdFieldName := 'ORGANIZATION_ID'
                    
                    let $oganizationIdFieldName := if ($tableNameUpper eq 'BILLING_SURVEY_FLORIDA') then 'ORGANIZATIONID' else $oganizationIdFieldName
                    let $oganizationIdFieldName := if ($tableNameUpper eq 'LATERAL_PARTNER') then 'ORGANIZATION_ID_JOINED' else $oganizationIdFieldName
                    
                    let $oganizationIdFieldName := if ($tableNameUpper eq 'LEGAL_TIMES_150') then 'FIRM_ID' else $oganizationIdFieldName
                    let $oganizationIdFieldName := if ($tableNameUpper eq 'ASSOCIATE_NATL') then 'FIRM_ID' else $oganizationIdFieldName
                    let $oganizationIdFieldName := if ($tableNameUpper eq 'ASSOCIATE_SUMMER_SURVEY') then 'FIRM_ID' else $oganizationIdFieldName
                    
                    let $oganizationIdFieldName := if ($tableNameUpper eq 'LAWFIRM_MERGERS') then 'NEW_FIRM_ID  ' else $oganizationIdFieldName
                    
                    let $organizationIdRecord := for $j in $tempResult
                                                 let $organizationId := xdmp:value(concat('$j//*:', $oganizationIdFieldName))/text() 
                                                 let $resObj := json:object()
                    
                                                  let $_ :=  (   
                                                          map:put($resObj,'TABLENAME', $tableName),
                                                          map:put($resObj,'SURVEYLISTINGID', $surveyListID),
                                                          map:put($resObj,'SURVEY_NAME', $surveyName),
                                                          map:put($resObj,'organization_id', $organizationId)
                                                        )
                                                 return $resObj
                   return $organizationIdRecord
  
  return json:to-array($finalResult)
   

};