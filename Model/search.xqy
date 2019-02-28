xquery version '1.0-ml';

module namespace search = 'http://alm.com/search';

import module namespace config = 'http://alm.com/config' at '/common/config.xqy';
import module namespace firm = 'http://alm.com/firm' at '/common/model/firm.xqy';

declare namespace survey = 'http://alm.com/LegalCompass/dd/survey';
declare namespace organization-dd ='http://alm.com/LegalCompass/dd/organization';
declare namespace organization = 'http://alm.com/LegalCompass/rd/organization';
declare namespace TOP500 = 'http://alm.com/LegalCompass/rd/TOP500';
declare namespace survey-listing = 'http://alm.com/LegalCompass/rd/survey-listing';
declare namespace person = 'http://alm.com/LegalCompass/rd/person';
declare namespace COMPANYPROFILE_DETAILS = 'http://alm.com/LegalCompass/rd/COMPANYPROFILE_DETAILS';
declare namespace FIRMS_ALI_XREF_RE = 'http://alm.com/LegalCompass/rd/FIRMS_ALI_XREF_RE';
declare namespace company = 'http://alm.com/LegalCompass/rd/company';
declare namespace ALI_RE_Attorney_Data =  'http://alm.com/LegalCompass/dd/ALI_RE_Attorney_Data';
declare namespace SAVED_SEARCHES = 'http://alm.com/LegalCompass/rd/SAVED_SEARCHES';

declare option xdmp:mapping 'false';

declare function search:GetNextSavedSearchId()
{
	fn:max(cts:element-values(xs:QName('SAVED_SEARCHES:SEARCHID'),(),('descending'), cts:and-query((
		cts:directory-query($config:RD-SAVED_SEARCHES-PATH)
	))))
};

declare function search:SP_SAVEFAVSEARCH($SearchID)
{
	let $uri := cts:uri-match('*.xml', ('document'), cts:and-query((
		 cts:directory-query($config:RD-SAVED_SEARCHES-PATH)
		,cts:element-value-query(xs:QName('SAVED_SEARCHES:SEARCHID'),$SearchID)
	)))
	
	let $_ := xdmp:node-replace(fn:doc($uri)/SAVED_SEARCHES/SAVED_SEARCHES:ISFAVOURITE, 
		element {fn:QName("http://alm.com/LegalCompass/rd/SAVED_SEARCHES", "ISFAVOURITE")} {'1'}
	)
   
	return $SearchID
};

declare function search:SP_InsertSavedSearches_New(
	 $UserID
	,$PromotionID
	,$SearchType
	,$SearchCriteria
	,$SearchTerm
	,$SearchedFrom
	,$IpAddress
	,$SearchID
)
{
	let $SearchID := if ($SearchID != '' and $SearchID != 0) then $SearchID else search:GetNextSavedSearchId()
	
	let $xml := element {'SAVED_SEARCHES'} {
		attribute {'xmlns'} {'http://alm.com/LegalCompass/rd/SAVED_SEARCHES'}
		,element {'SAVED_SEARCHES:SEARCHID'} {$SearchID}
		,element {'SAVED_SEARCHES:USERID'} {$UserID}
		,element {'SAVED_SEARCHES:PROMOTIONID'} {$PromotionID}
		,element {'SAVED_SEARCHES:CREATEDDATE'} {fn:current-dateTime()}
		,element {'SAVED_SEARCHES:SEARCHTYPE'} {$SearchType}
		,element {'SAVED_SEARCHES:SEARCHCRITERIA'} {$SearchCriteria}
		,element {'SAVED_SEARCHES:SEARCHTERM'} {$SearchTerm}
		,element {'SAVED_SEARCHES:ISFAVOURITE'} {'0'}
		,element {'SAVED_SEARCHES:SEARCHEDFROM'} {$SearchedFrom}
		,element {'SAVED_SEARCHES:IPADDRESS'} {$IpAddress}
	}

	let $nUri := fn:concat($config:RD-SAVED_SEARCHES-PATH,$SearchID,'.xml')

	let $_ := xdmp:document-insert($nUri,$xml)

	return xs:integer($SearchID)
};

declare function search:sp_GetREOrganizerFirms($term)
{
	let $key := fn:concat('*',$term,'*')

	let $RE_IDs := cts:element-values(xs:QName('FIRMS_ALI_XREF_RE:RE_ID'),(),(),cts:directory-query($config:RD-FIRMS_ALI_XREF_RE-PATH))

	let $response-arr := json:array()

	let $_ := (
  
	  for $x in cts:search(/company,
		cts:and-query((
			cts:directory-query($config:RD-COMPANY-PATH)
			,cts:element-word-query(xs:QName("company:area_id"),"1")
			,cts:element-word-query(xs:QName("company:company_type"),"E",('case-insensitive'))
			,cts:element-word-query(xs:QName("company:company"),$key, ('wildcarded','case-insensitive','punctuation-insensitive','whitespace-insensitive'))
			,cts:not-query(cts:element-word-query(xs:QName("company:company_id"),($RE_IDs ! fn:string(.))))
		)))
    
		let $response-obj := json:object()
    
		let $ID := $x/company:company_id/text()
		let $Name := $x/company:company/text()
		let $Type := 'RE FIRM'
		let $Logo := ''
		let $Description := ''
		let $SCOPEID := ''
		let $FirmId := $x/company:company_id/text()
		let $SearchName := $Name
    
		let $_ := (
			 map:put($response-obj,"ID",$ID)
			,map:put($response-obj,"SCOPEID",$SCOPEID)
			,map:put($response-obj,"Name",$Name)
			,map:put($response-obj,"Logo",$Logo)
			,map:put($response-obj,"Type",$Type)
			,map:put($response-obj,"Description",$Description)
			,map:put($response-obj,"FirmID",$ID)
			,map:put($response-obj,"SearchName",$SearchName)
		)
    
		let $_ := json:array-push($response-arr,$response-obj)
    
		return ()
	)

	return $response-arr
};

declare function search:sp_GetREFirms($term)
{
	let $key := fn:concat('*',$term,'*')
	
	let $RE_IDs := cts:element-values(xs:QName('FIRMS_ALI_XREF_RE:RE_ID'),(),(),cts:directory-query($config:RD-FIRMS_ALI_XREF_RE-PATH))
	
	let $response-arr := json:array()

	let $_ := (
  
		for $x in cts:search(/company,
			cts:and-query((
				 cts:directory-query($config:RD-COMPANY-PATH)
				,cts:element-word-query(xs:QName('company:area_id'),'1')
				,cts:element-word-query(xs:QName('company:company_type'),'C',('case-insensitive'))
				,cts:element-word-query(xs:QName('company:company'),$key, ('wildcarded','case-insensitive','punctuation-insensitive','whitespace-insensitive'))
				,cts:not-query(cts:element-word-query(xs:QName('company:company_id'),($RE_IDs ! fn:string(.))))
			)))
    
		let $response-obj := json:object()
    
		let $ID := $x/company:company_id/text()
		let $Name := $x/company:company/text()
		let $Type := 'RE FIRM'
		let $Logo := ''
		let $Description := ''
		let $SCOPEID := ''
		let $FirmId := $x/company:company_id/text()
		let $SearchName := fn:replace($Name,'[^a-zA-Z0-9]','')
    
		let $_ := (
			 map:put($response-obj,'ID',$ID)
			,map:put($response-obj,'SCOPEID',$SCOPEID)
			,map:put($response-obj,'Name',$Name)
			,map:put($response-obj,'Logo',$Logo)
			,map:put($response-obj,'Type',$Type)
			,map:put($response-obj,'Description',$Description)
			,map:put($response-obj,'FirmID',$ID)
			,map:put($response-obj,'SearchName',$SearchName)
		)
    
		let $_ := json:array-push($response-arr,$response-obj)
    
		return ()
	)

	return $response-arr
};

declare function search:SP_GETSEARCHDATA($term)
{
	let $key := fn:concat($term)
	let $key := fn:concat("*",$term,"*")
	
	let $response-arr := json:array()
	
	let $_ := (
	
		(:let $_ := for $res in cts:search(/organization:organization,:)
		let $_ := for $res in cts:search(/organization,
			cts:and-query((
				cts:directory-query($config:RD-ORGANIZATION-PATH)
				,cts:element-word-query(xs:QName('organization:ORGANIZATION_NAME'),$key, ('wildcarded','case-insensitive','punctuation-insensitive','whitespace-insensitive'))
				,cts:element-word-query(xs:QName('organization:ORGANIZATION_TYPE_ID'),'1')
			)))[1 to 100]
    
			let $ID := $res/organization:ORGANIZATION_ID/text()
			let $SCOPEID := ''
			let $Name := if ($res/organization:ALM_NAME/text() !='') then $res/organization:ALM_NAME/text() else $res/organization:ORGANIZATION_NAME/text()
			let $Type := 'FIRM'
			let $Description := fn:substring($res/organization:ORGANIZATION_PROFILE/text(),1,200)
			let $SearchName := fn:replace($Name,'[^a-zA-Z0-9]','')
			let $Logo := $res/organization:LOGO/text()
    
			let $response-obj := json:object()
			let $_ := (
				 map:put($response-obj,'ID',$ID)
				,map:put($response-obj,'SCOPEID',$SCOPEID)
				,map:put($response-obj,'Name',$Name)
				,map:put($response-obj,'Logo',$Logo)
				,map:put($response-obj,'Type',$Type)
				,map:put($response-obj,'Description',$Description)
				,map:put($response-obj,'FirmID',$ID)
				,map:put($response-obj,'SearchName',$SearchName)
			)
			let $_ := json:array-push($response-arr,$response-obj)
			return ()
  
		let $_ := for $res in cts:element-values(xs:QName('TOP500:COMPANY_ID'),(),(),
			cts:and-query((
				 cts:directory-query($config:RD-TOP500-PATH)
				 ,cts:element-value-query(xs:QName('TOP500:ISACTIVE'),'1')
				,cts:element-word-query(xs:QName('TOP500:COMPANY_NAME'),fn:concat($term,"*"), ('wildcarded','case-insensitive','punctuation-insensitive','whitespace-insensitive'))
			)))[1 to 100]
      
			let $ALT_Name := cts:search(/TOP500,
				cts:and-query((
					 cts:directory-query($config:RD-TOP500-PATH)
					,cts:element-word-query(xs:QName('TOP500:COMPANY_ID'),xs:string($res), ('wildcarded','case-insensitive','punctuation-insensitive','whitespace-insensitive'))
				)))[1]/TOP500:COMPANY_NAME/text()
      
			let $company := cts:search(/COMPANYPROFILE_DETAILS,
				cts:and-query((
					 cts:directory-query($config:RD-COMPANYPROFILE_DETAILS-PATH)
					,cts:element-word-query(xs:QName('COMPANYPROFILE_DETAILS:COMPANY_ID'),xs:string($res))
				)))[1]
      
			let $ID := xs:string($res)
			let $SCOPEID := $company/COMPANYPROFILE_DETAILS:SCOPEID/text()
			let $Name := if ($company/COMPANYPROFILE_DETAILS:COMPANYNAME/text() !='') then $company/COMPANYPROFILE_DETAILS:COMPANYNAME/text() else $ALT_Name
			let $Logo := $company/COMPANYPROFILE_DETAILS:LOGO/text()
			let $Type := 'COMPANY'
			let $Description := fn:substring($company/COMPANYPROFILE_DETAILS:DESCRIPTIONTEXT/text(),1,200)
			let $SearchName := fn:replace($Name,'[^a-zA-Z0-9]','')
      
			let $response-obj := json:object()
			let $_ := (
				 map:put($response-obj, 'ID', $ID)
				,map:put($response-obj,'SCOPEID',$SCOPEID)
				,map:put($response-obj,'Name',$Name)
				,map:put($response-obj,'Logo',$Logo)
				,map:put($response-obj,'Type',$Type)
				,map:put($response-obj,'Description',$Description)
				,map:put($response-obj,'FirmID',$ID)
				,map:put($response-obj,'SearchName',$SearchName)
			)
			let $_ := json:array-push($response-arr,$response-obj)
      
			return ()
  
		let $_ := for $x in cts:search(/SURVEYLISTING,
			cts:and-query((
				 cts:directory-query($config:RD-SURVEYLISTING-PATH)
				,cts:element-word-query(xs:QName('survey-listing:NAME'),$key, ('wildcarded','case-insensitive','punctuation-insensitive','whitespace-insensitive'))
			)))[1 to 100]
      
			let $ID := $x/survey-listing:SURVEYLISTINGID/text()
			let $Name := $x/survey-listing:NAME/text()
			let $Type := 'SURVEY'
			let $Logo := $x/survey-listing:LOGO/text()
			let $Description := fn:substring($x/survey-listing:Logo/text(), 200)
			let $SCOPEID := ''
			let $SearchName := fn:replace($Name,'[^a-zA-Z0-9]','')
    
			let $response-obj := json:object()
			let $_ := (
				map:put($response-obj, 'ID', $ID)
				,map:put($response-obj,'SCOPEID',$SCOPEID)
				,map:put($response-obj,'Name',$Name)
				,map:put($response-obj,'Logo',$Logo)
				,map:put($response-obj,'Type',$Type)
				,map:put($response-obj,'Description',$Description)
				,map:put($response-obj,'FirmID',$ID)
				,map:put($response-obj,'SearchName',$SearchName)
			)
			let $_ := json:array-push($response-arr,$response-obj)
			return ()

		return ()
	)

	return $response-arr
};

declare function search:sp_GetAttorneyNames($term)
{
	let $key := fn:concat('*',$term,'*')
	let $key2 := fn:tokenize($term,',')
	let $key2 := fn:concat($key2[2] , ', ' , $key2[1])
	
	let $response-arr := json:array()
	let $search := for $res in cts:search(/person,
		cts:and-query((
			cts:directory-query($config:RD-PEOPLE-PATH)
			,cts:element-word-query(xs:QName('person:name'),$key, ('wildcarded','case-insensitive','punctuation-insensitive','whitespace-insensitive'))
		)))[1 to 100]
		
		let $OrgIDByREId := firm:GetALIIdByREId($res/person:company/text())
		
		let $ID := $res/person:person_id/text()
		let $SCOPEID := ''
		let $Name := $res/person:name/text()
		let $Type := 'Attorney'
		let $Description := ''
		let $FirmID := if (($OrgIDByREId!='') and ($OrgIDByREId!='null')) then $OrgIDByREId else 0
		let $SearchName := fn:replace($Name,'[^a-zA-Z0-9 ]','')
		let $Logo := ''
  
		let $response-obj := json:object()
		let $_ := (
			 map:put($response-obj,'ID',$ID)
			,map:put($response-obj,'SCOPEID',$SCOPEID)
			,map:put($response-obj,'Name',$Name)
			,map:put($response-obj,'Type',$Type)
			,map:put($response-obj,'Logo',$Logo)
			,map:put($response-obj,'Description',$Description)
			,map:put($response-obj,'FirmID',$FirmID)
			,map:put($response-obj,'SearchName',$SearchName)
		)
		let $_ := json:array-push($response-arr,$response-obj)
		
		return ()

	return $response-arr
};

declare function search:GetQuickSearchResultsOnTerms($term, $type, $pagename)
{
	
	let $org-term-q := if($term) then 
			cts:element-word-query(xs:QName('organization:ORGANIZATION_NAME'),fn:concat($term,'*'),('wildcarded'))
		else ()
	
	(:
	let $organizations-ids := cts:element-values(xs:QName('organization:ORGANIZATION_ID'),(),(),
        cts:and-query((
          cts:directory-query($config:RD-ORGANIZATION-PATH),
          cts:collection-query($config:RD-ORGANIZATION-COLLECTION),
          cts:element-value-query(xs:QName('organization:ORGANIZATION_TYPE_ID'),'1'),
		  $org-term-q
        )))[1 to 100]
		
	let $top500-ids := cts:element-values(xs:QName('top500:COMPANY_ID'),(),(),
		cts:and-query((
			cts:directory-query($config:RD-TOP500-PATH),
			cts:collection-query($config:RD-TOP500-COLLECTION)
		)))[1 to 100]
		
	let $survey-listing-ids := cts:element-values(xs:QName('survey-listing:SURVEYLISTINGID'),(),(),
		cts:and-query((
			cts:directory-query($config:RD-SURVEYLISTING-PATH),
			cts:collection-query($config:RD-SURVEYLISTING-COLLECTION),
			cts:element-value-query(xs:QName('survey-listing:ISACTIVE'),'1')
		)))[1 to 100]
	:)
	
	let $org-term-q := if($term) then 
			cts:element-word-query(xs:QName('organization:ORGANIZATION_NAME'),fn:concat($term,'*'),('wildcarded'))
		else ()
		
	let $organizations-ids := cts:search(/,
        cts:and-query((
          cts:directory-query($config:RD-ORGANIZATION-PATH),
          cts:collection-query($config:RD-ORGANIZATION-COLLECTION),
          cts:element-value-query(xs:QName('organization:ORGANIZATION_TYPE_ID'),'1'),
		  $org-term-q
        )))[1 to 100]//organization:ORGANIZATION_ID/text()
	
	
	let $top500-term-q := if($term) then 
			cts:element-word-query(xs:QName('TOP500:COMPANY_NAME'),fn:concat($term,'*'),('wildcarded'))
		else ()
		
	let $top500-ids := cts:search(/,
		cts:and-query((
			cts:directory-query($config:RD-TOP500-PATH),
			cts:element-value-query(xs:QName('TOP500:ISACTIVE'),'1'),
			cts:collection-query($config:RD-TOP500-COLLECTION),
			$top500-term-q
		)))[1 to 100]//TOP500:COMPANY_ID/text()
		
	let $survey-listing-ids := cts:element-values(xs:QName('survey-listing:SURVEYLISTINGID'),(),(),
		cts:and-query((
			cts:directory-query($config:RD-SURVEYLISTING-PATH),
			cts:collection-query($config:RD-SURVEYLISTING-COLLECTION),
			cts:element-value-query(xs:QName('survey-listing:ISACTIVE'),'1')
		)))[1 to 100]
		
	(: let $person-ids := cts:element-values(xs:QName('person:person_id'),(),(),
		cts:and-query((
			cts:directory-query($config:RD-PEOPLE-PATH),
			cts:collection-query($config:RD-PEOPLE-COLLECTION)
		))) :)

	return element {'RESULT'} {
		
		let $organizations-data := for $organizations-id in $organizations-ids
			let $doc := fn:doc(fn:concat($config:RD-ORGANIZATION-PATH,$organizations-id,'.xml'))/*
			let $ORGANIZATION_NAME := $doc/organization:ORGANIZATION_NAME/text()
			let $ALM_NAME := $doc/organization:ALM_NAME/text()
			order by $ALM_NAME,$ORGANIZATION_NAME
			return element {'RECORD'} {
				element {'id'} {$organizations-id},
				element {'Name'} { if ($ALM_NAME) then $ALM_NAME else $ORGANIZATION_NAME },
				element {'Type'} {'FIRM'}
			} 
		
		let $top500-data := for $top500-id in $top500-ids
			let $name := cts:search(/TOP500,
				cts:and-query((
					cts:directory-query('/LegalCompass/relational-data/surveys/TOP500/'),
					cts:element-value-query(xs:QName('TOP500:COMPANY_ID'),xs:string($top500-id)),
					cts:not-query(cts:element-value-query(xs:QName('TOP500:COMPANY_NAME'),''))
				)))[1]/TOP500:COMPANY_NAME/text()
			order by $name
			return element {'RECORD'} {
				element {'id'} {$top500-id},
				element {'Name'} {$name},
				element {'Type'} {'COMPANY'} 
			}
			
		let $survey-listing-data := for $survey-listing-id in $survey-listing-ids
			let $doc := fn:doc(fn:concat($config:RD-SURVEYLISTING-PATH,$survey-listing-id,'.xml'))/*
			let $Name := $doc/survey-listing:NAME/text()
			order by $Name
			return element {'RECORD'} {
				element {'id'} {$survey-listing-id},
				element {'Name'} {$Name},
				element {'Type'} {'SURVEY'}
			}
			
		(: let $person-data := for $person-id in $person-ids
			let $doc := fn:doc(fn:concat($config:RD-PEOPLE-PATH,$person-id,'.xml'))/*
			let $Name := $doc/person:name/text()
			order by $Name
			return element {'RECORD'} {
				element {'id'} {$person-id},
				element {'Name'} {$Name},
				element {'Type'} {'Attorney'}
			} :)
		
		return ($organizations-data (:,$top500-data,$survey-listing-data:) )
	}
		
};

declare function search:GetAMLaw200SearchResults()
{
	let $response-arr := json:array()
	let $maxYears := max(cts:element-attribute-values(xs:QName('survey:YEAR'),xs:QName('PublishYear'),(),('descending'),
	cts:and-query((
		cts:directory-query($config:DD-SURVEY-AMLAW_200-PATH,'1')
	))))
	(:count(cts:element-values(xs:QName('organization-dd:ORGANIZATION_ID'),(),('descending'))):)  
	let $result := cts:search(//survey:YEAR,
	cts:and-query((
		cts:element-attribute-value-query(xs:QName('survey:YEAR'),xs:QName('PublishYear'),xs:string($maxYears)),
		cts:directory-query($config:DD-SURVEY-AMLAW_200-PATH,'1')
	)))
	
	let $data := for $entry in $result
	let $response-obj := json:object()
	let $name := $entry/@OrganizationName/string()
	let $_ := (
		map:put($response-obj,'ID', xs:integer($entry/@OrganizationID/string())),
		map:put($response-obj,'NAME', $name),
		map:put($response-obj,'SEARCHNAME', fn:replace($name,'[^a-zA-Z0-9'']',''))
	)
	let $_ := json:array-push($response-arr,$response-obj) 
	return ()
	
	return ($response-arr)
};

declare function search:CACHE_ALI_RE_Attorney_Data()
{
	let $batchSize := 40000

	let $count := xdmp:estimate(cts:search(/,
			cts:and-query((
				cts:directory-query("/LegalCompass/denormalized-data/ALI_RE_Attorney_Data/")
			))))
	
	let $batch := fn:ceiling($count div $batchSize)

	let $res := for $i in 1 to $batch
	let $start :=  if($i ne 1) then (xs:int($i) -1 ) * xs:int($batchSize) else 1
	let $end := xs:int($batchSize)*xs:int($i)
	
	let $results := cts:search(/,
			cts:and-query((
				cts:directory-query("/LegalCompass/denormalized-data/ALI_RE_Attorney_Data/")
			)))[$start to $end]

		let $newcontent := element {"CACHINGDATA"} {
				for $data in $results
			let $Name := $data//ALI_RE_Attorney_Data:attorney_name/text()
			let $Name1 := fn:tokenize($Name,',')
			let $RevertedName := if(fn:contains($Name,',')) then fn:concat(fn:normalize-space($Name1[2]) , ', ' , fn:normalize-space($Name1[1])) else fn:normalize-space($Name1)
			let $RevertedName1 := if(fn:contains($Name,',')) then fn:concat(fn:normalize-space($Name1[2]) , ', ' , fn:normalize-space($Name1[1])) else fn:normalize-space($Name1)
			(:let $SearchName := fn:replace($Name,'[^a-zA-Z0-9 ]',''):)
			(:let $SearchName := fn:replace($Name,'[^a-zA-Z0-9'']',''):)
			let $SearchName := fn:replace(fn:replace($Name,'[^a-zA-Z0-9'']',''),'[,-?!$*#{}/?:~@%<>|+]','')
			let $RevertedName := fn:replace(fn:replace($RevertedName,'[^a-zA-Z0-9'']',''),'[,-?!$*#{}/?:~@%<>|+]','')
			return element {"DATA"}
			{
				element {"ID"} {$data//ALI_RE_Attorney_Data:attorney_id/text()},  
				element {"SCOPEID"} {()},  
				element {"Name"} {$Name},
				element {"RevertedName"} {$RevertedName1},
				element {"Type"} {'Attorney'},
				(: element {"Description"} {''}, :)
				element {"Description"} {fn:substring($data//ALI_RE_Attorney_Data:keywords/text(),1,200)},
				(:element {"FirmID"} {$data//ALI_RE_Attorney_Data:firm_id/text()},:)
				element {"FirmID"} {$data//ALI_RE_Attorney_Data:ALI_ID/text()},
				element {"SearchName"} {$SearchName},
				element {"SearchNameReverse"} {$RevertedName}
			}
		}  
		
	let $uri := fn:concat("/LegalCompass/CACHINGDATA/ALI_RE_Attorney_Data",$i,".xml")
	let $insert := xdmp:document-insert($uri,$newcontent)
	return ()
	
	return "DONE: ALI_RE_Attorney_Data"
  
};

declare function search:CACHE_SP_GETSEARCHDATA()
{
	(:let $Result_ORGANIZATION := cts:search(/organization:organization,:)
	let $Result_ORGANIZATION := cts:search(/organization,
			cts:and-query((
				cts:directory-query($config:RD-ORGANIZATION-PATH)
				,cts:element-word-query(xs:QName('organization:ORGANIZATION_TYPE_ID'),'1')
				,cts:element-value-query(xs:QName('organization:ISACTIVE'),'1')
			)))
			
	let $newcontent_ORGANIZATION := element {"CACHINGDATA"} 
	{
		for $data in $Result_ORGANIZATION
		
		let $ID := $data/organization:ORGANIZATION_ID/text()
		let $SCOPEID := ''
		let $Name := if ($data/organization:ALM_NAME/text() !='') then $data/organization:ALM_NAME/text() else $data/organization:ORGANIZATION_NAME/text()
		let $Type := 'FIRM'
		let $Description := fn:substring($data/organization:ORGANIZATION_PROFILE/text(),1,200)
		(:let $SearchName := fn:replace($Name,'[^a-zA-Z0-9'']','') :)
		let $SearchName := fn:replace(fn:replace($Name,'[^a-zA-Z0-9'']',''),"'","")
		let $Logo := $data/organization:LOGO/text()
			
		return element {"DATA"}
		{
			element {"ID"} {$ID},  
			element {"SCOPEID"} {$SCOPEID},  
			element {"Name"} {$Name},
			element {"Logo"} {$Logo},
			element {"Type"} {$Type},
			element {"Description"} {$Description},
			element {"FirmID"} {$ID},  
			element {"SearchName"} {$SearchName}
		}
	}

	let $insert := xdmp:document-insert("/LegalCompass/CACHINGDATA/ORGANIZATION.xml",$newcontent_ORGANIZATION)
	
	(:TOP500 Part :)	
	let $NewContent_TOP500 := element {"CACHINGDATA"} 
		{for $res in cts:element-values(xs:QName('TOP500:COMPANY_ID'),(),(),
			cts:and-query((
				 cts:directory-query($config:RD-TOP500-PATH),
				 cts:element-value-query(xs:QName('TOP500:ISACTIVE'),'1')
			)))
      
			(:let $ALT_Name := cts:search(/TOP500,
				cts:and-query((
					 cts:directory-query($config:RD-TOP500-PATH)
					,cts:element-word-query(xs:QName('TOP500:COMPANY_ID'),xs:string($res), ('wildcarded','case-insensitive','punctuation-insensitive','whitespace-insensitive'))
				)))[1]/TOP500:COMPANY_NAME/text()
			:)
			let $TOP500_Details := cts:search(/TOP500,
				cts:and-query((
					 cts:directory-query($config:RD-TOP500-PATH)
					 ,cts:element-value-query(xs:QName('TOP500:ISACTIVE'),'1')
					,cts:element-word-query(xs:QName('TOP500:COMPANY_ID'),xs:string($res), ('wildcarded','case-insensitive','punctuation-insensitive','whitespace-insensitive'))
				)))[1]
			let $company := cts:search(/COMPANYPROFILE_DETAILS,
				cts:and-query((
					 cts:directory-query($config:RD-COMPANYPROFILE_DETAILS-PATH)
					,cts:element-word-query(xs:QName('COMPANYPROFILE_DETAILS:COMPANY_ID'),xs:string($res))
				)))[1]
      
			let $ID := xs:string($res)
			let $SCOPEID := $TOP500_Details/TOP500:SCOPEID/text()
			let $Name := if ($company/COMPANYPROFILE_DETAILS:COMPANYNAME/text() !='') then $company/COMPANYPROFILE_DETAILS:COMPANYNAME/text() else $TOP500_Details/TOP500:COMPANY_NAME/text()
			let $Logo := $company/COMPANYPROFILE_DETAILS:LOGO/text()
			let $Type := 'COMPANY'
			let $Description := fn:substring($company/COMPANYPROFILE_DETAILS:DESCRIPTIONTEXT/text(),1,200)
			(:let $SearchName := fn:replace($Name,'[^a-zA-Z0-9'']',''):)
			let $SearchName := fn:replace(fn:replace($Name,'[^a-zA-Z0-9'']',''),"'","")
      
			return element {"DATA"}
		  {
			  element {"ID"} {$ID},  
			  element {"SCOPEID"} {$SCOPEID},  
			  element {"Name"} {$Name},
			  element {"Logo"} {$Logo},
			  element {"Type"} {$Type},
			  element {"Description"} {$Description},
			  element {"FirmID"} {$ID},  
			  element {"SearchName"} {$SearchName}
		  }
		}  
  let $insert := xdmp:document-insert("/LegalCompass/CACHINGDATA/TOP500.xml",$NewContent_TOP500)
  
  (:SURVEYLISTINGPART:)
  let $NewContent_SURVEYLISTING:= element {"CACHINGDATA"} 
  {
	for $x in cts:search(/,
			cts:and-query((
				 cts:directory-query($config:RD-SURVEYLISTING-PATH)		
				,cts:element-value-query(xs:QName("survey-listing:ISACTIVE"),'1',"exact")
			)))
		let $ID := $x//survey-listing:SURVEYLISTINGID/text()
		let $Name := $x//survey-listing:NAME/text()
		let $Type := 'SURVEY'
		let $Logo := $x//survey-listing:LOGO/text()
		let $Description := fn:substring($x//survey-listing:SURVEYDESCRIPTION/text(), 0,200)
		let $SCOPEID := ''	
		(:let $SearchName := fn:replace($Name,'[^a-zA-Z0-9]',''):)
		let $SearchName := fn:replace(fn:replace($Name,'[^a-zA-Z0-9'']',''),"'","")
    
	return element {"DATA"}
	{
        element {"ID"} {$ID},  
        element {"SCOPEID"} {()},  
		element {"Name"} {$Name},
		element {"Logo"} {$Logo},
        element {"Type"} {$Type},
        element {"Description"} {$Description},
        element {"FirmID"} {$ID},
        element {"SearchName"} {$SearchName}
	}
  }
  
  let $insert := xdmp:document-insert("/LegalCompass/CACHINGDATA/SURVEYLISTING.xml",$NewContent_SURVEYLISTING)
  return "DONE"
  
};

declare function search:CACHE_sp_getrefirms()
{
let $RE_IDs := cts:element-values(xs:QName('FIRMS_ALI_XREF_RE:RE_ID'),(),(),cts:directory-query($config:RD-FIRMS_ALI_XREF_RE-PATH))
	
let $newcontent := element {"CACHINGDATA"} 
  {for $x in cts:search(/company,
			cts:and-query((
				cts:directory-query($config:RD-COMPANY-PATH)
				,cts:element-word-query(xs:QName('company:area_id'),'1')
				,cts:element-word-query(xs:QName('company:company_type'),'C',('case-insensitive'))
				,cts:not-query(cts:element-word-query(xs:QName('company:company_id'),($RE_IDs ! fn:string(.))))
			)))
    
		let $ID := $x/company:company_id/text()
		let $Name := $x/company:company/text()
		let $Type := 'RE FIRM'
		let $Logo := ''
		let $Description := ''
		let $SCOPEID := ''
		let $FirmId := $x/company:company_id/text()
		(:let $SearchName := fn:replace($Name,'[^a-zA-Z0-9]',''):)
		let $SearchName := fn:replace(fn:replace($Name,'[^a-zA-Z0-9'']',''),"'","")
    
		return 
    element {"DATA"}
    {
      element {"ID"} {$ID},  
      element {"SCOPEID"} {()},  
      element {"Name"} {$Name},
      element {"logo"} {$Logo},
      element {"Type"} {$Type},
      element {"Description"} {$Description},
      element {"FirmID"} {$ID},
      element {"SearchName"} {$SearchName}
    }
  }

  let $insert := xdmp:document-insert("/LegalCompass/CACHINGDATA/RE_FIRM.xml",$newcontent)
  
  let $newcontent := element {"CACHINGDATA"} 
  {
  for $x in cts:search(/company,
		cts:and-query((
			cts:directory-query($config:RD-COMPANY-PATH)
			,cts:element-word-query(xs:QName("company:area_id"),"1")
			,cts:element-word-query(xs:QName("company:company_type"),"E",('case-insensitive'))
			,cts:not-query(cts:element-word-query(xs:QName("company:company_id"),($RE_IDs ! fn:string(.))))
		)))
    
		let $response-obj := json:object()
    
		let $ID := $x/company:company_id/text()
		let $Name := $x/company:company/text()
		(:let $Type := 'RE FIRM':)
		let $Type := 'RE ORGANIZER'
		let $Logo := ''
		let $Description := ''
		let $SCOPEID := ''
		let $FirmId := $x/company:company_id/text()
		(:let $SearchName := $Name :)
		(:let $SearchName := fn:replace($Name,'[^a-zA-Z0-9]',''):)
		let $SearchName := fn:replace(fn:replace($Name,'[^a-zA-Z0-9'']',''),"'","")
		
		return 
		element {"DATA"}
		{
		element {"ID"} {$ID},  
		element {"SCOPEID"} {()},  
		element {"Name"} {$Name},
		element {"logo"} {$Logo},
		element {"Type"} {$Type},
		element {"Description"} {$Description},
		element {"FirmID"} {$ID},
		element {"SearchName"} {$SearchName}
		}
	}
	
	let $insert := xdmp:document-insert("/LegalCompass/CACHINGDATA/RE_FIRM1.xml",$newcontent)
	(:return count($newcontent//DATA:)
	return "Done"
};

declare function search:GetQuickSearchResults($term,$type,$page)
{	
(:let $term := fn:replace($term,'[^a-zA-Z0-9'']',''):)
let $keyword := $term
let $key2 := fn:tokenize($term,',')
let $key2 := if(fn:contains($term,',')) then fn:concat($key2[2] , ', ' , $key2[1]) else $term

 let $term := fn:replace(fn:replace($term,'[^a-zA-Z0-9'']',''),"'","")
 let $term2 := fn:replace(fn:replace($key2,'[^a-zA-Z0-9'']',''),"'","")
 (: let $key := fn:concat('*',$term,'*') :)
 let $key := fn:concat('*',$term,'*')
 let $key2 := fn:concat('*',$term2,'*')


(:let $type := "FIRM":)

let $andQuery := cts:and-query((
					for $item in fn:tokenize($keyword,' ')
						return cts:element-word-query(xs:QName("RevertedName"),($item),('wildcarded','case-insensitive','punctuation-insensitive','whitespace-insensitive'))
				
				))
let $response-arr := json:array()

return if($type eq "GLOBAL" or $page eq "GLOBAL") then

let $type-query := cts:element-value-query(xs:QName("Type"),"Attorney",('case-insensitive'))


let $result := cts:search(/CACHINGDATA/DATA,
   cts:and-query((
     cts:directory-query('/LegalCompass/CACHINGDATA/'),
	 cts:or-query((
			cts:element-word-query(xs:QName("SearchName"),($key),('wildcarded','case-insensitive','punctuation-insensitive','whitespace-insensitive'))
			,cts:element-word-query(xs:QName("SearchNameReverse"),($key),('wildcarded','case-insensitive','punctuation-insensitive','whitespace-insensitive'))
			,$andQuery
	 ))
	 ,$type-query
   )))[1 to 25]   
   
let $data := for $res in $result
    let $response-obj := json:object()
    
    let $ID := $res//ID/text()
    let $SCOPEID := $res//SCOPEID/text()
    let $Name := $res//Name/text()
    let $Logo := $res//Logo/text()
    let $Type := $res//Type/text()
    let $Description := $res//Description/text()
	let $FirmID := if($res//FirmID/text() ne '' ) then $res//FirmID/text() else 0
    (:let $SearchName := $res//SearchName/text():)
	let $SearchName := fn:replace($res//SearchName/text(),'[^a-zA-Z0-9'']','')
	
    
    let $_ := (
			map:put($response-obj,"ID",$ID)
			,map:put($response-obj,"SCOPEID",$SCOPEID)
			,map:put($response-obj,"Name",$Name)
			,map:put($response-obj,"Logo",$Logo)
			,map:put($response-obj,"Type",$Type)
			,map:put($response-obj,"Description",$Description)
			,map:put($response-obj,"FirmID",$FirmID)
			,map:put($response-obj,"SearchName",$SearchName)
			,map:put($response-obj,"SearchNamereverse",$res//SearchNameReverse/text())
			,map:put($response-obj,"RevertedName",$res//RevertedName/text())
		)
   
   let $_ := json:array-push($response-arr, $response-obj)
   return ()
   
(:Survey Part:)

let $type-query := cts:element-value-query(xs:QName("Type"),("Survey"),('case-insensitive'))
 
let $result := cts:search(/CACHINGDATA/DATA,
   cts:and-query((
     cts:directory-query('/LegalCompass/CACHINGDATA/'),
	 cts:or-query((
     cts:element-word-query(xs:QName("SearchName"),$key,('wildcarded','case-insensitive','punctuation-insensitive','whitespace-insensitive'))
	 ,cts:element-value-query(xs:QName("Name"),$key,('case-insensitive','punctuation-sensitive','whitespace-sensitive','wildcarded'))
	 ))
     ,$type-query
   )))[1 to 25]   
   
let $data := for $res in $result
    let $response-obj := json:object()
    
    let $ID := $res//ID/text()
    let $SCOPEID := $res//SCOPEID/text()
    let $Name := $res//Name/text()
    let $Logo := $res//Logo/text()
    let $Type := $res//Type/text()
    let $Description := $res//Description/text()
    (:let $SearchName := $res//SearchName/text():)
	let $SearchName := fn:replace($res//SearchName/text(),'[^a-zA-Z0-9'']','')
    
    let $_ := (
			map:put($response-obj,"ID",$ID)
			,map:put($response-obj,"SCOPEID",$SCOPEID)
			,map:put($response-obj,"Name",$Name)
			,map:put($response-obj,"Logo",$Logo)
			,map:put($response-obj,"Type",$Type)
			,map:put($response-obj,"Description",$Description)
			,map:put($response-obj,"FirmID",$ID)
			,map:put($response-obj,"SearchName",$SearchName)
		)
   
   let $_ := json:array-push($response-arr, $response-obj)
   return ()
   
  (:COMPANY PART :)
let $type-query := cts:element-value-query(xs:QName("Type"),("FIRM","COMPANY"),('case-insensitive'))
 
let $result := cts:search(/CACHINGDATA/DATA,
   cts:and-query((
     cts:directory-query('/LegalCompass/CACHINGDATA/'),
	 cts:or-query((
     cts:element-word-query(xs:QName("SearchName"),$key,('wildcarded','case-insensitive','punctuation-insensitive','whitespace-insensitive'))
	 ,cts:element-value-query(xs:QName("Name"),$key,('case-insensitive','punctuation-sensitive','whitespace-sensitive','wildcarded'))
	 ))
     ,$type-query
   )))[1 to 50]   
   
let $data := for $res in $result
    let $response-obj := json:object()
    
    let $ID := $res//ID/text()
    let $SCOPEID := $res//SCOPEID/text()
    let $Name := $res//Name/text()
    let $Logo := $res//Logo/text()
    let $Type := $res//Type/text()
    let $Description := $res//Description/text()
    (:let $SearchName := $res//SearchName/text():)
	let $SearchName := fn:replace($res//SearchName/text(),'[^a-zA-Z0-9'']','')
    
    let $_ := (
			map:put($response-obj,"ID",$ID)
			,map:put($response-obj,"SCOPEID",$SCOPEID)
			,map:put($response-obj,"Name",$Name)
			,map:put($response-obj,"Logo",$Logo)
			,map:put($response-obj,"Type",$Type)
			,map:put($response-obj,"Description",$Description)
			,map:put($response-obj,"FirmID",$ID)
			,map:put($response-obj,"SearchName",$SearchName)
		)
   
   let $_ := json:array-push($response-arr, $response-obj)
   return ()
   
return $response-arr

else 
let $type := if($type ne "")
  then fn:tokenize($type,',')
  else ()
  
let $type-query := if($page eq 'EMPLOYMENT') then
	cts:element-value-query(xs:QName("Type"),($type,"RE FIRM"),('case-insensitive'))
	else if($type != "") then
  cts:element-value-query(xs:QName("Type"),$type,('case-insensitive'))
  else ()
(:
let $result := cts:search(/CACHINGDATA/DATA,
   cts:and-query((
     cts:directory-query('/LegalCompass/CACHINGDATA/')
     ,cts:element-word-query(xs:QName("SearchName"),$key,('wildcarded','case-insensitive','punctuation-insensitive','whitespace-insensitive'))
     ,$type-query
   )))[1 to 100]
:)
let $result := cts:search(/CACHINGDATA/DATA,
   cts:and-query((
     cts:directory-query('/LegalCompass/CACHINGDATA/'),
	 cts:or-query((
     cts:element-word-query(xs:QName("SearchName"),$key,('wildcarded','case-insensitive','punctuation-insensitive','whitespace-insensitive'))
	 ,cts:element-word-query(xs:QName("Name"),$key,('wildcarded','case-insensitive','punctuation-insensitive','whitespace-insensitive'))
	 ))
     ,$type-query
   )))[1 to 250]
   
let $data := for $res in $result
    let $response-obj := json:object()
    
    let $ID := $res//ID/text()
    let $SCOPEID := $res//SCOPEID/text()
    let $Name := $res//Name/text()
    let $Logo := $res//Logo/text()
    let $Type := $res//Type/text()
    let $Description := $res//Description/text()
    (:let $SearchName := $res//SearchName/text():)
	let $SearchName := fn:replace($res//SearchName/text(),'[^a-zA-Z0-9'']','')
    
    let $_ := (
			map:put($response-obj,"ID",$ID)
			,map:put($response-obj,"SCOPEID",$SCOPEID)
			,map:put($response-obj,"Name",$Name)
			,map:put($response-obj,"Logo",$Logo)
			,map:put($response-obj,"Type",$Type)
			,map:put($response-obj,"Description",$Description)
			,map:put($response-obj,"FirmID",$ID)
			,map:put($response-obj,"SearchName",$SearchName)
		)
   
   let $_ := json:array-push($response-arr, $response-obj)
   return ()
return $response-arr
};

declare function search:GetQuickSearchResults_All($term,$type)
{	

let $keyword := $term	
let $term := fn:replace($term,'[^a-zA-Z0-9'']','')
let $key := fn:concat('*',$term,'*')
(:let $type := "FIRM":)

let $response-arr := json:array()
return if($type eq "GLOBAL") then

let $type-query := cts:element-value-query(xs:QName("Type"),"Attorney",('case-insensitive'))
(:
let $result := cts:search(/CACHINGDATA/DATA,
   cts:and-query((
     cts:directory-query('/LegalCompass/CACHINGDATA/')
     ,cts:element-word-query(xs:QName("SearchName"),$key,('wildcarded','case-insensitive','punctuation-insensitive','whitespace-insensitive'))
     ,$type-query
   )))[1 to 100]
:)
let $andQuery := cts:and-query((
					for $item in fn:tokenize($keyword,' ')
						return cts:element-word-query(xs:QName("RevertedName"),($item),('wildcarded','case-insensitive','punctuation-insensitive','whitespace-insensitive'))
				
				))

let $result := cts:search(/CACHINGDATA/DATA,
   cts:and-query((
     cts:directory-query('/LegalCompass/CACHINGDATA/'),
	 cts:or-query((
			cts:element-word-query(xs:QName("SearchName"),($key),('wildcarded','case-insensitive','punctuation-insensitive','whitespace-insensitive'))
			,cts:element-word-query(xs:QName("SearchNameReverse"),($key),('wildcarded','case-insensitive','punctuation-insensitive','whitespace-insensitive'))
			,$andQuery
			

     (: cts:element-word-query(xs:QName("SearchName"),$key,('wildcarded','case-insensitive','punctuation-insensitive','whitespace-insensitive'))
	 ,cts:element-word-query(xs:QName("Name"),$key,('wildcarded','case-insensitive','punctuation-insensitive','whitespace-insensitive')) :)
	 ))
     ,$type-query
   )))
   
let $data := for $res in $result
    let $response-obj := json:object()
    
    let $ID := $res//ID/text()
    let $SCOPEID := $res//SCOPEID/text()
    let $Name := $res//Name/text()
    let $Logo := $res//Logo/text()
    let $Type := $res//Type/text()
    let $Description := $res//Description/text()
	let $FirmID := if($res//FirmID/text() ne '' ) then $res//FirmID/text() else 0
    (:let $SearchName := $res//SearchName/text():)
	let $SearchName := fn:replace($res//SearchName/text(),'[^a-zA-Z0-9'']','')
	
    
    let $_ := (
			map:put($response-obj,"ID",$ID)
			,map:put($response-obj,"SCOPEID",$SCOPEID)
			,map:put($response-obj,"Name",$Name)
			,map:put($response-obj,"Logo",$Logo)
			,map:put($response-obj,"Type",$Type)
			,map:put($response-obj,"Description",$Description)
			,map:put($response-obj,"FirmID",$FirmID)
			,map:put($response-obj,"SearchName",$SearchName)
		)
   
   let $_ := json:array-push($response-arr, $response-obj)
   return ()
   
(:Survey Part:)

let $type-query := cts:element-value-query(xs:QName("Type"),("Survey","FIRM","COMPANY"),('case-insensitive'))
(: 
let $result := cts:search(/CACHINGDATA/DATA,
   cts:and-query((
     cts:directory-query('/LegalCompass/CACHINGDATA/')
     ,cts:element-word-query(xs:QName("SearchName"),$key,('wildcarded','case-insensitive','punctuation-insensitive','whitespace-insensitive'))
     ,$type-query
   )))[1 to 200]
:)   
let $result := cts:search(/CACHINGDATA/DATA,
   cts:and-query((
     cts:directory-query('/LegalCompass/CACHINGDATA/'),
	 cts:or-query((
     cts:element-word-query(xs:QName("SearchName"),$key,('wildcarded','case-insensitive','punctuation-insensitive','whitespace-insensitive'))
	 ,cts:element-value-query(xs:QName("Name"),$key,('case-insensitive','punctuation-sensitive','whitespace-sensitive','wildcarded'))
	 ))
     ,$type-query
   )))
   
let $data := for $res in $result
    let $response-obj := json:object()
    
    let $ID := $res//ID/text()
    let $SCOPEID := $res//SCOPEID/text()
    let $Name := $res//Name/text()
    let $Logo := $res//Logo/text()
    let $Type := $res//Type/text()
    let $Description := $res//Description/text()
    (:let $SearchName := $res//SearchName/text():)
	let $SearchName := fn:replace($res//SearchName/text(),'[^a-zA-Z0-9'']','')
    
    let $_ := (
			map:put($response-obj,"ID",$ID)
			,map:put($response-obj,"SCOPEID",$SCOPEID)
			,map:put($response-obj,"Name",$Name)
			,map:put($response-obj,"Logo",$Logo)
			,map:put($response-obj,"Type",$Type)
			,map:put($response-obj,"Description",$Description)
			,map:put($response-obj,"FirmID",$ID)
			,map:put($response-obj,"SearchName",$SearchName)
		)
   
   let $_ := json:array-push($response-arr, $response-obj)
   return ()
   
return $response-arr

else 
let $type := if($type ne "")
  then fn:tokenize($type,',')
  else ()
  
let $type-query := if($type != "") then
  cts:element-value-query(xs:QName("Type"),$type,('case-insensitive'))
  else cts:element-value-query(xs:QName("Type"),('Firm','Company','Attorney','Survey'),('case-insensitive'))
(:
let $result := cts:search(/CACHINGDATA/DATA,
   cts:and-query((
     cts:directory-query('/LegalCompass/CACHINGDATA/')
     ,cts:element-word-query(xs:QName("SearchName"),$key,('wildcarded','case-insensitive','punctuation-insensitive','whitespace-insensitive'))
     ,$type-query
   )))[1 to 100]
:)

let $andQuery := cts:and-query((
					for $item in fn:tokenize($keyword,' ')
						return cts:element-word-query(xs:QName("RevertedName"),($item),('wildcarded','case-insensitive','punctuation-insensitive','whitespace-insensitive'))
				
				))

let $result := cts:search(/CACHINGDATA/DATA,
   cts:and-query((
     cts:directory-query('/LegalCompass/CACHINGDATA/'),

	 cts:or-query((
			cts:element-word-query(xs:QName("SearchName"),($key),('wildcarded','case-insensitive','punctuation-insensitive','whitespace-insensitive'))
			,cts:element-word-query(xs:QName("SearchNameReverse"),($key),('wildcarded','case-insensitive','punctuation-insensitive','whitespace-insensitive'))
			,$andQuery
	 ))
	 (: cts:or-query((
     cts:element-word-query(xs:QName("SearchName"),$key,('wildcarded','case-insensitive','punctuation-insensitive','whitespace-insensitive'))
	 ,cts:element-word-query(xs:QName("Name"),$key,('wildcarded','case-insensitive','punctuation-insensitive','whitespace-insensitive'))
	 )) :)
     ,$type-query
   )))
   
let $data := for $res in $result
    let $response-obj := json:object()
    
    let $ID := $res//ID/text()
    let $SCOPEID := $res//SCOPEID/text()
    let $Name := $res//Name/text()
    let $Logo := $res//Logo/text()
    let $Type := $res//Type/text()
    let $Description := $res//Description/text()
    (:let $SearchName := $res//SearchName/text():)
	let $SearchName := fn:replace($res//SearchName/text(),'[^a-zA-Z0-9'']','')
    
    let $_ := (
			map:put($response-obj,"ID",$ID)
			,map:put($response-obj,"SCOPEID",$SCOPEID)
			,map:put($response-obj,"Name",$Name)
			,map:put($response-obj,"Logo",$Logo)
			,map:put($response-obj,"Type",$Type)
			,map:put($response-obj,"Description",$Description)
			,map:put($response-obj,"FirmID",$ID)
			,map:put($response-obj,"SearchName",$SearchName)
		)
   
   let $_ := json:array-push($response-arr, $response-obj)
   return ()
return $response-arr   
};

declare function search:GetQuickSearchResults_All1($term,$type,$PageSize,$PageNo)
{	
(:let $term := fn:replace($term,'[^a-zA-Z0-9'']',''):)
let $keyword := $term
let $key := fn:concat('*',$term,'*')
(:let $type := "FIRM":)
let $fromRecord := if($PageNo ne '1') then (xs:int($PageNo)-1)*xs:int($PageSize) + 1 else 1
let $toRecord := xs:int($PageSize)*xs:int($PageNo)

let $response-arr := json:array()
return if($type eq "GLOBAL") then   
'No result found'

else 
let $type := if($type ne "")
  then fn:tokenize($type,',')
  else ()
  
let $type-query := if($type != "") then
  cts:element-value-query(xs:QName("Type"),$type,('case-insensitive'))
  else cts:element-value-query(xs:QName("Type"),('Firm','Company','Attorney','Survey'),('case-insensitive'))

let $andQuery := cts:and-query((
					for $item in fn:tokenize($keyword,' ')
						return cts:element-word-query(xs:QName("RevertedName"),($item),('wildcarded','case-insensitive','punctuation-insensitive','whitespace-insensitive'))
				
				))

let $count := count(cts:search(/CACHINGDATA/DATA,
   cts:and-query((
     cts:directory-query('/LegalCompass/CACHINGDATA/'),
	 cts:or-query((
			cts:element-word-query(xs:QName("SearchName"),($key),('wildcarded','case-insensitive','punctuation-insensitive','whitespace-insensitive'))
			,cts:element-word-query(xs:QName("SearchNameReverse"),($key),('wildcarded','case-insensitive','punctuation-insensitive','whitespace-insensitive'))
			,$andQuery
	 ))
     (: ,cts:element-word-query(xs:QName("Name"),$key,('wildcarded','case-insensitive','punctuation-insensitive','whitespace-insensitive'))	    :)
     ,$type-query
   ))))
let $result := cts:search(/CACHINGDATA/DATA,
   cts:and-query((
     cts:directory-query('/LegalCompass/CACHINGDATA/'),
	 (: cts:or-query((
     cts:element-word-query(xs:QName("SearchName"),$key,('wildcarded','case-insensitive','punctuation-insensitive','whitespace-insensitive'))
	 ,cts:element-word-query(xs:QName("Name"),$key,('wildcarded','case-insensitive','punctuation-insensitive','whitespace-insensitive'))
	 )) :)
	  cts:or-query((
			cts:element-word-query(xs:QName("SearchName"),($key),('wildcarded','case-insensitive','punctuation-insensitive','whitespace-insensitive'))
			,cts:element-word-query(xs:QName("SearchNameReverse"),($key),('wildcarded','case-insensitive','punctuation-insensitive','whitespace-insensitive'))
			,$andQuery
	 ))
	 
	 ,$type-query
    )))[xs:integer($fromRecord) to xs:integer($toRecord)]
   
let $data := for $res in $result
    let $response-obj := json:object()
    
    let $ID := $res//ID/text()
    let $SCOPEID := $res//SCOPEID/text()
    let $Name := $res//Name/text()
    let $Logo := $res//Logo/text()
    let $Type := $res//Type/text()
    let $Description := $res//Description/text()
    (:let $SearchName := $res//SearchName/text():)
	let $SearchName := fn:replace($res//SearchName/text(),'[^a-zA-Z0-9'']','')
    
    let $_ := (
			map:put($response-obj,"ID",$ID)
			,map:put($response-obj,"SCOPEID",$SCOPEID)
			,map:put($response-obj,"Name",$Name)
			,map:put($response-obj,"Logo",$Logo)
			,map:put($response-obj,"Type",$Type)
			,map:put($response-obj,"Description",$Description)
			,map:put($response-obj,"FirmID",$ID)
			,map:put($response-obj,"SearchName",$SearchName)
      ,map:put($response-obj,"TotalCount",$count)
		)
   
   let $_ := json:array-push($response-arr, $response-obj)
   return ()
return $response-arr
  
  
};