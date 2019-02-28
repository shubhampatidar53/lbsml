xquery version '1.0-ml';

module namespace billpredection = 'http://alm.com/billpredection';

import module namespace config = 'http://alm.com/config' at '/common/config.xqy';
import module namespace helper = 'http://alm.com/helper' at '/common/model/helper.xqy';
import module namespace json = 'http://marklogic.com/xdmp/json'  at '/MarkLogic/json/json.xqy';

declare namespace dd_billpredictions = "http://alm.com/LegalCompass/GLL/dd/billpredictions";
declare namespace bill_currentbill_similarity = "http://alm.com/LegalCompass/GLL/rd/bill_currentbill_similarity";
declare namespace BILLSTATUS = 'http://alm.com/LegalCompass/GLL/rd/BILLSTATUS';

declare option xdmp:mapping 'false';

declare function billpredection:legislationAutoComplete($bill_id)
{
    let $response-array := json:array()
    let $key := fn:concat("*",$bill_id,"*")

    let $searchResults :=  cts:search(//dd_billpredictions:bill_id,
        cts:and-query((
            cts:directory-query('/LegalCompass/GLL/denormalized-data/billpredictions/')
            ,cts:element-word-query(xs:QName("dd_billpredictions:bill_id"),$key,('wildcarded','case-insensitive','punctuation-insensitive','whitespace-insensitive'))
        )))[1 to 15]/text()
    
    let $res := for $search in $searchResults
        let $response-obj := json:object()
        let $_ := (
                    map:put($response-obj,'bill_id',$search)
                    )
        let $_ := json:array-push($response-array , $response-obj)

        return ()
        
    return $response-array 
};

declare function billpredection:SP_BILLPREDICTIONSGET(
    $title
    ,$billId
    ,$predictionFrom
    ,$predictionTo
    ,$passPredictionFrom
    ,$passPredictionTo
    ,$status
    ,$pageNumber
    ,$pageSize
    ,$sortBy
    ,$direction
 )
{
    
    let $keyword := fn:concat("*",$title,"*")
    (:
    let $bill-id := $billId
    let $passPredictionFrom := '' 
    let $passPredictionTo := '' 
    let $predictionFrom := ''
    let $PredictionTo := ''
    let $status := ""
    let $SortBy := 'TITLE'
    let $direction := "ascending"
    :)

    let $direction := if($direction eq "ASC")
        then "ascending"
        else if($direction eq "DSC")
        then "descending"
        else ()

    let $response-array := json:array()

    let $billIdQuery := if($billId ne "")
    then cts:element-value-query(xs:QName("dd_billpredictions:bill_id"),$billId,("exact"))
    else ()
    
    let $passPredictionFromQuery := if($passPredictionFrom ne "")
    then cts:element-range-query(xs:QName('dd_billpredictions:PassPrediction'), '>=', xs:double(xs:double($passPredictionFrom) div 100))
    else ()

    let $passPredictionToQuery := if($passPredictionTo ne "")
    then cts:element-range-query(xs:QName('dd_billpredictions:PassPrediction'), '<=', xs:double(xs:double($passPredictionTo) div 100))
    else ()

    let $predictionFromQuery := if($predictionFrom ne "")
    then cts:element-range-query(xs:QName('dd_billpredictions:Prediction'), '>=', xs:double(xs:double($predictionFrom) div 100))
    else ()

    let $predictionToQuery := if($predictionTo ne "")
    then cts:element-range-query(xs:QName('dd_billpredictions:Prediction'), '<=', xs:double(xs:double($predictionTo) div 100))
    else ()
    
    let $keywordQuery := if($keyword ne "") 
    then cts:or-query((
        cts:element-word-query(xs:QName('dd_billpredictions:Title'),$keyword,('case-insensitive','wildcarded'))
        ,cts:element-word-query(xs:QName('dd_billpredictions:ShortTitle'),$keyword,('case-insensitive','wildcarded'))
        ,cts:element-word-query(xs:QName('dd_billpredictions:Subject'),$keyword,('case-insensitive','wildcarded'))
        ,cts:element-word-query(xs:QName('dd_billpredictions:summary_text'),$keyword,('case-insensitive','wildcarded'))
    ))
    else ()

    let $statusQuery := if($status ne "")
        then cts:element-value-query(xs:QName("dd_billpredictions:status"),$status,('case-insensitive','wildcarded'))
        else ()

    let $orderBy :=if($sortBy eq 'TITLE') then cts:index-order(cts:element-reference(xs:QName('dd_billpredictions:ShortTitle')) ,$direction)
        else if($sortBy eq 'Sponsor') then cts:index-order(cts:element-reference(xs:QName('dd_billpredictions:Sponsor')) ,$direction)
        else if($sortBy eq 'SponsorParty') then cts:index-order(cts:element-reference(xs:QName('dd_billpredictions:SponsorParty')) ,$direction)
        else if($sortBy eq 'Prediction') then cts:index-order(cts:element-reference(xs:QName('dd_billpredictions:Prediction')) ,$direction)
        else if($sortBy eq 'PassPrediction') then cts:index-order(cts:element-reference(xs:QName('dd_billpredictions:PassPrediction')) ,$direction)
        else if($sortBy eq 'Status') then cts:index-order(cts:element-reference(xs:QName('dd_billpredictions:status')) ,$direction)
        else cts:index-order(cts:element-reference(xs:QName('dd_billpredictions:formatted_status_at')) ,"descending")
    
    let $query := cts:and-query((
        $billIdQuery
        ,$passPredictionFromQuery
        ,$passPredictionToQuery
        ,$predictionFromQuery
        ,$predictionToQuery
        ,$keywordQuery
        ,$statusQuery
        ))
    let $fromRecord := if($pageNumber ne '1') then (xs:int($pageNumber)-1) * xs:int($pageSize) + 1 else 1
    let $toRecord := xs:int($pageSize) * xs:int($pageNumber)

    let $Total := if($keyword ne "")
        then count(cts:search(/,
        cts:and-query((
            cts:directory-query('/LegalCompass/GLL/denormalized-data/billpredictions/')
            ,$query
        ))))
        else xdmp:estimate(cts:search(/,
        cts:and-query((
            cts:directory-query('/LegalCompass/GLL/denormalized-data/billpredictions/')
            ,$query
        ))))

    let $bPredictions := cts:search(/,
    cts:and-query((
        cts:directory-query('/LegalCompass/GLL/denormalized-data/billpredictions/')
        ,$query
        )),
        $orderBy)[$fromRecord to $toRecord]    

    let $res := for $bPredction in $bPredictions
        
        let $shortTitle := if($bPredction//dd_billpredictions:ShortTitle/text() eq "NA")
            then $bPredction//dd_billpredictions:Title/text()
            else $bPredction//dd_billpredictions:ShortTitle/text()
        let $currentStatus := cts:search(/,
        cts:and-query((
        cts:directory-query('/LegalCompass/GLL/relational-data/BILLSTATUS/')
        ,cts:element-value-query(xs:QName("BILLSTATUS:CODE"),$bPredction//dd_billpredictions:status/text(),("case-insensitive"))
        )))//BILLSTATUS:CODE/text()

        let $response-obj := json:object()
        
        let $_ := (
            map:put($response-obj,'bill_id',$bPredction//dd_billpredictions:bill_id/text())
            ,map:put($response-obj,'Title',$bPredction//dd_billpredictions:Title/text())
            (: ,map:put($response-obj,'ShortTitle',$bPredction//dd_billpredictions:ShortTitle/text()) :)
            ,map:put($response-obj,'ShortTitle',$shortTitle)
            ,map:put($response-obj,'Prediction',$bPredction//dd_billpredictions:Prediction/text() * 100)
            ,map:put($response-obj,'PassPrediction',$bPredction//dd_billpredictions:PassPrediction/text() * 100)
            ,map:put($response-obj,'CURRENT_STATUS',$currentStatus)
            ,map:put($response-obj,'Subject',$bPredction//dd_billpredictions:Subject/text())
            ,map:put($response-obj,'Chamber',$bPredction//dd_billpredictions:Chamber/text())
            ,map:put($response-obj,'Sponsor',$bPredction//dd_billpredictions:Sponsor/text())
            ,map:put($response-obj,'SponsorParty',$bPredction//dd_billpredictions:SponsorParty/text())
            ,map:put($response-obj,'SponsorState',$bPredction//dd_billpredictions:SponsorState/text())
            ,map:put($response-obj,'Committees',$bPredction//dd_billpredictions:Committees/text())
            ,map:put($response-obj,'Companion',$bPredction//dd_billpredictions:Companion/text())
            ,map:put($response-obj,'BONUS',$bPredction//dd_billpredictions:BONUS/text())
            ,map:put($response-obj,'status',$bPredction//dd_billpredictions:status/text())
            ,map:put($response-obj,'status_at',$bPredction//dd_billpredictions:status_at/text())
            ,map:put($response-obj,'status_atFormatted',$bPredction//dd_billpredictions:status_at/text())
            ,map:put($response-obj,'introduced_at',$bPredction//dd_billpredictions:introduced_at/text())
            ,map:put($response-obj,'all_status',$bPredction//dd_billpredictions:all_status/text())
            ,map:put($response-obj,'Link',$bPredction//dd_billpredictions:Link/text())
            ,map:put($response-obj,'LinkFormatted',fn:replace( fn:replace($bPredction//dd_billpredictions:Link/text(), '<a href="',''),'" target="_blank" class="btn btn-primary">Bill Data</a>',''))            
            ,map:put($response-obj,'summary_text',$bPredction//dd_billpredictions:summary_text/text())
            ,map:put($response-obj,'TotalCount',$Total)
            ,map:put($response-obj,'DIR',$direction)
        )        
        let $_ := json:array-push($response-array , $response-obj)
        return ()

    return $response-array 
};

declare function billpredection:SP_BILLPREDICTIONDETAILSGET($bill_Id)
{
    let $billId := $bill_Id
    let $response-array := json:array()

(:------------------------- PART1 -------------------------:)

let $bPrediction :=  cts:search(/,
  cts:and-query((
    cts:directory-query('/LegalCompass/GLL/denormalized-data/billpredictions/')
    ,cts:element-value-query(xs:QName("dd_billpredictions:bill_id"),$billId,('case-insensitive'))
  )))
  
let $sponsorParty := $bPrediction//dd_billpredictions:SponsorParty/text()
let $status := $bPrediction//dd_billpredictions:status/text()
let $allStatus := $bPrediction//dd_billpredictions:all_status/text()

let $response-obj := json:object()        
let $_ := (
    map:put($response-obj,'bill_id',$bPrediction//dd_billpredictions:bill_id/text())
    ,map:put($response-obj,'status_at',$bPrediction//dd_billpredictions:status_at/text())
    ,map:put($response-obj,'introduced_at',$bPrediction//dd_billpredictions:introduced_at/text())
    ,map:put($response-obj,'status',$status)            
    ,map:put($response-obj,'all_status',$allStatus)
    ,map:put($response-obj,'Sponsor',$bPrediction//dd_billpredictions:Sponsor/text())
    ,map:put($response-obj,'SponsorParty',$sponsorParty)
  )        

let $_ := json:array-push($response-array , $response-obj)


(:------------------------- PART2 -------------------------:)

let $billOtherId := cts:search(/,
  cts:and-query((
  cts:directory-query("/LegalCompass/GLL/relational-data/bill_currentbill_similarity/")
  ,cts:element-value-query(xs:QName("bill_currentbill_similarity:BILL_SELF"),$billId,('case-insensitive'))
  )))//bill_currentbill_similarity:BILL_OTHER/text()
 
let $billOtherIdQuery := if($billOtherId != "")
  then cts:element-value-query(xs:QName("bill_currentbill_similarity:BILL_OTHER"),$billId,('exact'))
  else ()

let $bPredictions1 := cts:search(/,
  cts:and-query((
    cts:directory-query('/LegalCompass/GLL/denormalized-data/billpredictions/')
    (:,cts:element-value-query(xs:QName("dd_billpredictions:bill_id"),$billId,('case-insensitive')) :)
    ,$billOtherIdQuery
    ,cts:element-value-query(xs:QName("dd_billpredictions:SponsorParty"),$sponsorParty,('case-insensitive'))
    ,cts:not-query(cts:element-value-query(xs:QName("dd_billpredictions:status"),'PASSED:BILL',('case-insensitive')))
    ,cts:not-query(cts:element-value-query(xs:QName("dd_billpredictions:status"),$status,('case-insensitive')))
    ,cts:element-value-query(xs:QName("dd_billpredictions:status"),$allStatus,('case-insensitive'))
  )))

let $res2 := if($bPredictions1 != "")
  then
    for $bPrediction in $bPredictions1
    let $response-obj := json:object()        
    let $_ := (
        map:put($response-obj,'bill_id',$bPrediction//dd_billpredictions:bill_id/text())
        ,map:put($response-obj,'status_at',$bPrediction//dd_billpredictions:status_at/text())
        ,map:put($response-obj,'introduced_at',$bPrediction//dd_billpredictions:introduced_at/text())
        ,map:put($response-obj,'status',$bPrediction//dd_billpredictions:status/text())            
        ,map:put($response-obj,'all_status',$bPrediction//dd_billpredictions:all_status/text())
        ,map:put($response-obj,'Sponsor',$bPrediction//dd_billpredictions:Sponsor/text())
        ,map:put($response-obj,'SponsorParty',$bPrediction//dd_billpredictions:SponsorParty/text())
      )       

    let $_ := json:array-push($response-array , $response-obj)
    return ()
  else()

return $response-array

};