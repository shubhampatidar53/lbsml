xquery version '1.0-ml';

module namespace research = 'http://alm.com/research'; 

import module namespace config = 'http://alm.com/config' at '/common/config.xqy';
import module namespace json = 'http://marklogic.com/xdmp/json'  at '/MarkLogic/json/json.xqy';
declare namespace SAVED_SEARCHES = "http://alm.com/LegalCompass/rd/SAVED_SEARCHES";
declare namespace SAVED_SEARCHTYPE = "http://alm.com/LegalCompass/rd/SAVEDSEARCHTYPE";

(:
STORED PROC IN ORACLE DB: 
SP_GETSAVEDSEARCHES

TABLE PHYSICAL PATH ('SavedSearches'):
/LegalCompass/relational-data/SAVED_SEARCHES/

TABLE PHYSICAL PATH ('SavedSearchType'):
/LegalCompass/relational-data/SAVEDSEARCHTYPE/

AUTHOR: RAVEENDRA SHARMA
:)

declare function research:GetSavedSearches($userId, $pageNo, $pageSize)
{  

  (:let $userId := "1373722":)
 
  (: Favourite and Non download items :)
  
  let $intPageNo := xs:integer($pageNo)
  let $intPageSize := xs:integer($pageSize)
  
  let $pageStart := ($intPageNo - 1) * $intPageSize + 1
  let $pageEnd := $pageStart + $intPageSize - 1
  
  let $savedSearchCondition := (
		cts:and-query((cts:directory-query($config:RD-SAVED_SEARCHES-PATH)
                      ,cts:element-value-query(xs:QName("SAVED_SEARCHES:USERID"),$userId)
                      ,cts:element-value-query(xs:QName("SAVED_SEARCHES:ISFAVOURITE"),"1")
                      ,cts:not-query(cts:element-value-query(xs:QName("SAVED_SEARCHES:SEARCHTYPE"),'Download', "case-insensitive"))
                      ,cts:not-query(cts:element-value-query(xs:QName("SAVED_SEARCHES:SEARCHTYPE"),'print', "case-insensitive"))
                      ,cts:not-query(cts:element-value-query(xs:QName("SAVED_SEARCHES:SEARCHTYPE"),'export', "case-insensitive"))
                      ,cts:not-query(cts:element-value-query(xs:QName("SAVED_SEARCHES:SEARCHTYPE"),'', "case-insensitive"))
                      ,cts:not-query(cts:element-value-query(xs:QName("SAVED_SEARCHES:SEARCHEDFROM"),"12"))
					  ))
	)
		
   let $savedSearchResult := cts:search(/,
                      $savedSearchCondition
					  ,cts:index-order(cts:element-reference(xs:QName("SAVED_SEARCHES:CREATEDDATE")), "descending")
                     
                      )
	
  let $totalSavedSearchCount := xdmp:estimate(cts:search(fn:doc(), cts:and-query(($savedSearchCondition))))	
  
  let $savedSearchFinalResult := (for $x in $savedSearchResult

  let $savedSearch_SearchFrom := $x//SAVED_SEARCHES:SEARCHEDFROM/text()
  let $savedSearch_searchTypeResult := cts:search(/
          ,cts:and-query((cts:directory-query($config:RD-SAVEDSEARCHTYPE-PATH)
          ,cts:element-value-query(xs:QName("SAVED_SEARCHTYPE:SEARCHTYPEID"), $savedSearch_SearchFrom))
                        ))
  
  let $savedSearchFinalResult := element {"RECORD"} {
    element {"SEARCHID"} { $x//SAVED_SEARCHES:SEARCHID/text()}
  , element {"USERID"} {$x//SAVED_SEARCHES:USERID/text()}
  , element {"PROMOTIONID"} {$x//SAVED_SEARCHES:PROMOTIONID/text()}
  , element {"CREATEDDATE"} {$x//SAVED_SEARCHES:CREATEDDATE/text()}
  , element {"SEARCHEDFROM"} {$savedSearch_searchTypeResult//SAVED_SEARCHTYPE:SEARCHTYPENAME/text()}
  , element {"SEARCHCRITERIA"} {$x//SAVED_SEARCHES:SEARCHCRITERIA/text()}
  , element {"SEARCHTERM"} {$x//SAVED_SEARCHES:SEARCHTERM/text()}
  , element {"ISFAVOURITE"} {$x//SAVED_SEARCHES:ISFAVOURITE/text()}
  , element {"SearchType"} {$x//SAVED_SEARCHES:SEARCHTYPE/text()} 
  , element {"TotalSavedSearchCount"} {$totalSavedSearchCount}
  }
    
   return ($savedSearchFinalResult))[$pageStart to $pageEnd] 
  
  (: Top 10 (Newest first) Non Favourite and Non download items:)
  
  let $recentSearchResult := cts:search(/,
                      cts:and-query((cts:directory-query($config:RD-SAVED_SEARCHES-PATH)
                      ,cts:element-value-query(xs:QName("SAVED_SEARCHES:USERID"),$userId)
                      ,cts:element-value-query(xs:QName("SAVED_SEARCHES:ISFAVOURITE"),"0")
                      ,cts:not-query(cts:element-value-query(xs:QName("SAVED_SEARCHES:SEARCHTYPE"),'Download', "case-insensitive"))
                      ,cts:not-query(cts:element-value-query(xs:QName("SAVED_SEARCHES:SEARCHTYPE"),'print', "case-insensitive"))
                      ,cts:not-query(cts:element-value-query(xs:QName("SAVED_SEARCHES:SEARCHTYPE"),'export', "case-insensitive"))
                      ,cts:not-query(cts:element-value-query(xs:QName("SAVED_SEARCHES:SEARCHTYPE"),'', "case-insensitive"))
                      ,cts:not-query(cts:element-value-query(xs:QName("SAVED_SEARCHES:SEARCHEDFROM"),"12"))
                      ))
  				      ,cts:index-order(cts:element-reference(xs:QName("SAVED_SEARCHES:CREATEDDATE")), "descending")
                    
                      )[1 to 10]
  
  let $recentSearchFinalResult := (for $x in $recentSearchResult
    
  let $recentSearch_SearchedFrom := $x//SAVED_SEARCHES:SEARCHEDFROM/text()
  let $recentSearch_searchTypeResult := cts:search(/
          ,cts:and-query((cts:directory-query($config:RD-SAVEDSEARCHTYPE-PATH)
          ,cts:element-value-query(xs:QName("SAVED_SEARCHTYPE:SEARCHTYPEID"), $recentSearch_SearchedFrom))
                        ))
    
  let $recentSearchFinalResult := element {"RECORD"} {
  element {"SEARCHID"} { $x//SAVED_SEARCHES:SEARCHID/text()}
  , element {"USERID"} {$x//SAVED_SEARCHES:USERID/text()}
  , element {"PROMOTIONID"} {$x//SAVED_SEARCHES:PROMOTIONID/text()}
  , element {"CREATEDDATE"} {$x//SAVED_SEARCHES:CREATEDDATE/text()}
  , element {"SEARCHEDFROM"} {$recentSearch_searchTypeResult//SAVED_SEARCHTYPE:SEARCHTYPENAME/text()} 
  , element {"SEARCHCRITERIA"} {$x//SAVED_SEARCHES:SEARCHCRITERIA/text()}
  , element {"SEARCHTERM"} {$x//SAVED_SEARCHES:SEARCHTERM/text()}
  , element {"ISFAVOURITE"} {$x//SAVED_SEARCHES:ISFAVOURITE/text()}
  , element {"SearchType"} {$x//SAVED_SEARCHES:SEARCHTYPE/text()} 
  }
      
  (:order by $x//SAVED_SEARCHES:CREATEDDATE descending :)
    
  return ($recentSearchFinalResult)) (:[1 to 10]:)
   
 (: Non favourite and download items :)
 
  let $documentSearchResult := cts:search(/,
                     cts:and-query((cts:directory-query($config:RD-SAVED_SEARCHES-PATH)
                      ,cts:element-value-query(xs:QName("SAVED_SEARCHES:USERID"),$userId)
                      ,cts:element-value-query(xs:QName("SAVED_SEARCHES:ISFAVOURITE"),"0")
                      ,cts:element-value-query(xs:QName("SAVED_SEARCHES:SEARCHTYPE"),'Download', "case-insensitive") (: Downlaodable :)
                      ,cts:not-query(cts:element-value-query(xs:QName("SAVED_SEARCHES:SEARCHTYPE"),'print', "case-insensitive"))
                      ,cts:not-query(cts:element-value-query(xs:QName("SAVED_SEARCHES:SEARCHTYPE"),'export', "case-insensitive"))
                      ,cts:not-query(cts:element-value-query(xs:QName("SAVED_SEARCHES:SEARCHTYPE"),'', "case-insensitive"))
                      ,cts:not-query(cts:element-value-query(xs:QName("SAVED_SEARCHES:SEARCHEDFROM"),"12"))
                      ))
					  ,cts:index-order(cts:element-reference(xs:QName("SAVED_SEARCHES:CREATEDDATE")), "descending")
                      )[1 to 10]
  
  let $documentSearchFinalResult := (for $x in $documentSearchResult
    
  let $documentSearch_SearchedFromValue := $x//SAVED_SEARCHES:SEARCHEDFROM/text()
  
  let $documentSearch_SearchTypeResult := cts:search(/
          ,cts:and-query((cts:directory-query($config:RD-SAVEDSEARCHTYPE-PATH)
          ,cts:element-value-query(xs:QName("SAVED_SEARCHTYPE:SEARCHTYPEID"), $documentSearch_SearchedFromValue))
                        ))
  
  let $documentSearchFinalResult := element {"RECORD"} {
  element {"SEARCHID"} { $x//SAVED_SEARCHES:SEARCHID/text()}
  , element {"USERID"} {$x//SAVED_SEARCHES:USERID/text()}
  , element {"PROMOTIONID"} {$x//SAVED_SEARCHES:PROMOTIONID/text()}
  , element {"CREATEDDATE"} {$x//SAVED_SEARCHES:CREATEDDATE/text()}
  , element {"SEARCHEDFROM"} {$documentSearch_SearchTypeResult//SAVED_SEARCHTYPE:SEARCHTYPENAME/text()}
  , element {"SEARCHCRITERIA"} {$x//SAVED_SEARCHES:SEARCHCRITERIA/text()}
  , element {"SEARCHTERM"} {$x//SAVED_SEARCHES:SEARCHTERM/text()}
  , element {"ISFAVOURITE"} {$x//SAVED_SEARCHES:ISFAVOURITE/text()}
  , element {"SearchType"} {$x//SAVED_SEARCHES:SEARCHTYPE/text()} 
  }
      
  (: order by $x//SAVED_SEARCHES:CREATEDDATE descending :)
    
  return ($documentSearchFinalResult)) (: [1 to 10]:)
  
  let $finalResult := ($savedSearchFinalResult, $recentSearchFinalResult, $documentSearchFinalResult)  
  
  let $finalResult := (for $x in $finalResult
           order by $x/CREATEDDATE descending 
          return $x)
       
  let $custom :=
		let $config := json:config('custom')
		let $_ := map:put( $config, 'whitespace', 'ignore' )
		let $_ := map:put( $config, 'array-element-names', ('RECORD') )
		return $config
  		
  let $finalResult := xdmp:to-json-string(json:transform-to-json($finalResult, $custom)//RECORD)
  
  return $finalResult
 
 };