xquery version '1.0-ml';

module namespace pacerdata = 'http://alm.com/pacerdata';

import module namespace config = 'http://alm.com/config' at '/common/config.xqy';
import module namespace search = 'http://marklogic.com/appservices/search' at '/MarkLogic/appservices/search/search.xqy';
declare namespace REPRESENTATION_TYPES= 'http://alm.com/LegalCompass/rd/REPRESENTATION_TYPES';
declare namespace util = 'http://alm.com/util';

declare function pacerdata:GetCompanyProfileLFRData($request)
{
    let $scopeID := $request/ScopeID/text()
    let $startYear := $request/YearFrom/text()
    let $endYear := $request/YearTo/text()
    let $typeOfRepresentation := $request/Representations/text()
    let $PageNo := $request/PageNo/text()
    let $PageSize := $request/PageSize/text()
    let $rep := fn:tokenize($typeOfRepresentation,'[|]')

    let $litigationTOR := $request/LitigationTypeOfRepresentation/text()
    let $ipTOR := $request/IPTypeOfRepresentation/text()
    let $transTOR := $request/TransactionalTypeOfRepresentation/text()

    let $sortBy := $request/SortBy/text()
    let $sortDirection := if($request/SortDirection/text() eq 'ASC') then 'ascending' else 'descending'
    let $fromRecord := if($PageNo ne '1') then (xs:int($PageNo)-1)*xs:int($PageSize) else 1
    let $toRecord := xs:int($PageSize)*xs:int($PageNo)

    let $orderBy :=if($sortBy eq 'Firm') then cts:index-order(cts:element-reference(xs:QName('Firm')) ,$sortDirection) 
                   else if($sortBy eq 'TypeOfRepresentation') then cts:index-order(cts:element-reference(xs:QName('TypeOfRepresentation')) ,$sortDirection) 
                   else if($sortBy eq 'Year') then cts:index-order(cts:element-reference(xs:QName('SortDate')) ,$sortDirection) 
                   else if($sortBy eq 'Source') then cts:index-order(cts:element-reference(xs:QName('Source')) ,$sortDirection) 
                   else cts:index-order(cts:element-reference(xs:QName('SortDate')) ,'descending')
    let $resArray := json:array()

    let $emptyRepresentationName := cts:search(/,
                                        cts:and-query((
                                            cts:directory-query('/LegalCompass/relational-data/REPRESENTATION_TYPES/'),
                                            cts:element-value-query(xs:QName('REPRESENTATION_TYPES:LEVEL_2'),'')
                                        )))//REPRESENTATION_TYPES:REPRESENTATION_TYPE_NAME/text()

    let $andQuery := cts:and-query((
                            cts:directory-query('/LegalCompass/denormalized-data/pacerdata/'),
                            cts:element-value-query(xs:QName('ScopeID'),xs:string($scopeID)),
                            cts:not-query(cts:element-value-query(xs:QName('Year'),'')),
                            cts:not-query(cts:element-value-query(xs:QName('Firm'),'')),
                            (:cts:element-value-query(xs:QName('Firm'),'Bradley Arant Boult Cummings LLP'),:)
                            cts:not-query(cts:element-value-query(xs:QName('TypeOfRepresentation'),$emptyRepresentationName)),
                            cts:or-query((
                                cts:element-value-query(xs:QName('TypeOfRepresentation'),fn:tokenize($litigationTOR,'[|]')),
                                cts:element-value-query(xs:QName('TypeOfRepresentation'),fn:tokenize($ipTOR,'[|]')),
                                cts:element-value-query(xs:QName('TypeOfRepresentation'),fn:tokenize($transTOR,'[|]'))
                            )),
                            if($startYear ne '') then cts:element-range-query(xs:QName('Year'),'>=',xs:integer($startYear)) else(),
                            if($endYear ne '') then cts:element-range-query(xs:QName('Year'),'<=',xs:integer($endYear)) else()
                        ))

    let $result := cts:search(/,
                        $andQuery , $orderBy
                        )[xs:integer($fromRecord) to xs:integer($toRecord)]

    let $recordCount := xdmp:estimate(cts:search(/,
                        $andQuery
                        ))            

   

    let $loopData := for $item in $result
                        let $resObj := json:object() 
                        let $firmID := $item//FirmID/text()
                        let $sortDate := fn:format-date(xs:date($item//SortDate/text()),"[M01]/[D01]/[Y0001]")
                        let $_ := (
                                    map:put($resObj,'Firm',$item//Firm/text()),
                                    map:put($resObj,'TypeOfRepresentation',$item//TypeOfRepresentation/text()),
                                    map:put($resObj,'Year',$item//Year/text()),
                                    map:put($resObj,'Details',$item//Details/text()),
                                    map:put($resObj,'Source',$item//Source/text()),
                                    map:put($resObj,'TotalCount',$recordCount),
                                    map:put($resObj,'RecordCount',$recordCount),
                                    map:put($resObj,'DocketNumber',$item//DocketNumber/text()),
                                    map:put($resObj,'CaseId',$item//CaseID/text()),
                                     map:put($resObj,'FirmId',$firmID[1]),
                                     map:put($resObj,'CaseDate',$sortDate)
                                  )    

                        let $_ := json:array-push($resArray,$resObj)
                        return()
    return $resArray                
};

(: declare function pacerdata:GetCompanyProfileLFRChartData($request)
{
    let $scopeID := $request/ScopeID/text()
    let $startYear := $request/YearFrom/text()
    let $endYear := $request/YearTo/text()
    let $typeOfRepresentation := $request/Representations/text()
    let $firmName := ''
    let $resArray := json:array()

    let $emptyRepresentationName := cts:search(/,
                                        cts:and-query((
                                            cts:directory-query('/LegalCompass/relational-data/REPRESENTATION_TYPES/'),
                                            cts:element-value-query(xs:QName('REPRESENTATION_TYPES:LEVEL_2'),'')
                                        )))//REPRESENTATION_TYPES:REPRESENTATION_TYPE_NAME/text()

    let $andQuery := cts:and-query((
                            cts:directory-query('/LegalCompass/denormalized-data/pacerdata/'),
                            cts:element-value-query(xs:QName('ScopeID'),xs:string($scopeID)),
                            cts:not-query(cts:element-value-query(xs:QName('Year'),'')),
                            cts:not-query(cts:element-value-query(xs:QName('Firm'),'')),
                            if($firmName ne '') then cts:element-value-query(xs:QName('Firm'),'') else (),
                            cts:not-query(cts:element-value-query(xs:QName('TypeOfRepresentation'),$emptyRepresentationName)),
                            if($typeOfRepresentation ne 'All Types' and $typeOfRepresentation ne '') then cts:element-word-query(xs:QName('TypeOfRepresentation'),fn:tokenize($typeOfRepresentation,'[|]'),('wildcarded','case-insensitive')) else(),
                            if($startYear ne '') then cts:element-range-query(xs:QName('Year'),'>=',xs:integer($startYear)) else(),
                            if($endYear ne '') then cts:element-range-query(xs:QName('Year'),'<=',xs:integer($endYear)) else()
                        ))

    let $loopData := for $item in cts:values(cts:element-reference(xs:QName('Firm')), (), (),$andQuery)

                        let $firmName := $item
                        
                        let $andQuery1 := cts:and-query((
                            cts:directory-query('/LegalCompass/denormalized-data/pacerdata/'),
                            cts:element-value-query(xs:QName('ScopeID'),xs:string($scopeID)),
                            cts:not-query(cts:element-value-query(xs:QName('Year'),'')),
                            cts:not-query(cts:element-value-query(xs:QName('Firm'),'')),
                            if($firmName ne '') then cts:element-value-query(xs:QName('Firm'),'') else (),
                            cts:not-query(cts:element-value-query(xs:QName('TypeOfRepresentation'),$emptyRepresentationName)),
                            if($typeOfRepresentation ne 'All Types' and $typeOfRepresentation ne '') then cts:element-word-query(xs:QName('TypeOfRepresentation'),fn:tokenize($typeOfRepresentation,'[|]'),('wildcarded','case-insensitive')) else(),
                            if($startYear ne '') then cts:element-range-query(xs:QName('Year'),'>=',xs:integer($startYear)) else(),
                            if($endYear ne '') then cts:element-range-query(xs:QName('Year'),'<=',xs:integer($endYear)) else()
                        ))

                        let $typeOfRepresentation := for $item1 in cts:values(cts:element-reference(xs:QName('TypeOfRepresentation')), (), (),$andQuery1)
                                                        let $resObj := json:object()
                                                        let $_ := (
                                                                    map:put($resObj,'Firm',$item),
                                                                    map:put($resObj,'TypeOfRepresentation',$item1),
                                                                    map:put($resObj,'TotalCount',cts:frequency($item1))
                                                                  ) 
                                                        let $_ := json:array-push($resArray, $resObj)
                                                        return()
                        return()                                             
    
    return $resArray

}; :)

(: declare function pacerdata:GetCompanyProfileLFRChartData($request)
{
    let $scopeID := $request/ScopeID/text()
    let $startYear := $request/YearFrom/text()
    let $endYear := $request/YearTo/text()
    let $typeOfRepresentation := $request/Representations/text()
    let $firmName := ''
    let $litigationTOR := $request/LitigationTypeOfRepresentation/text()
    let $ipTOR := $request/IPTypeOfRepresentation/text()
    let $transTOR := $request/TransactionalTypeOfRepresentation/text()
    let $resArray := json:array()

    let $emptyRepresentationName := cts:search(/,
                                        cts:and-query((
                                            cts:directory-query('/LegalCompass/relational-data/REPRESENTATION_TYPES/'),
                                            cts:element-value-query(xs:QName('REPRESENTATION_TYPES:LEVEL_2'),'')
                                        )))//REPRESENTATION_TYPES:REPRESENTATION_TYPE_NAME/text()

    let $andQuery := cts:and-query((
                            cts:directory-query('/LegalCompass/denormalized-data/pacerdata/'),
                            cts:element-value-query(xs:QName('ScopeID'),xs:string($scopeID)),
                            cts:not-query(cts:element-value-query(xs:QName('Year'),'')),
                            cts:not-query(cts:element-value-query(xs:QName('Firm'),'')),
                            if($firmName ne '') then cts:element-value-query(xs:QName('Firm'),$firmName) else (),
                            cts:not-query(cts:element-value-query(xs:QName('TypeOfRepresentation'),$emptyRepresentationName)),
                            if($typeOfRepresentation ne 'All Types' and $typeOfRepresentation ne '') then cts:element-word-query(xs:QName('TypeOfRepresentation'),fn:tokenize($typeOfRepresentation,'[|]'),('wildcarded','case-insensitive')) else(),
                            if($startYear ne '') then cts:element-range-query(xs:QName('Year'),'>=',xs:integer($startYear)) else(),
                            if($endYear ne '') then cts:element-range-query(xs:QName('Year'),'<=',xs:integer($endYear)) else()
                        ))

    

    let $loopData := for $item in cts:values(cts:element-reference(xs:QName('Firm')), (), (),$andQuery)
                        let $firmName := $item

                        let $typeOfRepresentation := $request/LitigationTypeOfRepresentation/text()
                        let $litigationCount := count(cts:values(cts:element-reference(xs:QName('TypeOfRepresentation')), (), (),$andQuery))

                        let $typeOfRepresentation := $request/IPTypeOfRepresentation/text()
                        let $ipCount := count(cts:values(cts:element-reference(xs:QName('TypeOfRepresentation')), (), (),$andQuery))
                         
                        let $typeOfRepresentation := $request/TransactionalTypeOfRepresentation/text()
                        let $transactionalCount := count(cts:values(cts:element-reference(xs:QName('TypeOfRepresentation')), (), (),$andQuery))
  
                        let $resObj := json:object()
                        let $_ := (
                                    map:put($resObj,'Firm',$item),
                                    map:put($resObj,'Litigation',$litigationCount),
                                    map:put($resObj,'IP',$ipCount),
                                    map:put($resObj,'Transactional',$transactionalCount)
                                  ) 
                        let $_ := json:array-push($resArray, $resObj)
                        
                        return()                                             
    
    return $resArray

}; :)

declare function pacerdata:GetCompanyProfileLFRChartData($request)
{
    let $scopeID := $request/ScopeID/text()
    let $startYear := $request/YearFrom/text()
    let $endYear := $request/YearTo/text()
    let $typeOfRepresentation := $request/Representations/text()
    let $firmName := ''
    let $resArray := json:array()

    let $litigationTOR := $request/LitigationTypeOfRepresentation/text()
    let $ipTOR := $request/IPTypeOfRepresentation/text()
    let $transTOR := $request/TransactionalTypeOfRepresentation/text()

    let $emptyRepresentationName := cts:search(/,
                                        cts:and-query((
                                            cts:directory-query('/LegalCompass/relational-data/REPRESENTATION_TYPES/'),
                                            cts:element-value-query(xs:QName('REPRESENTATION_TYPES:LEVEL_2'),'')
                                        )))//REPRESENTATION_TYPES:REPRESENTATION_TYPE_NAME/text()

    let $andQuery := cts:and-query((
                            cts:directory-query('/LegalCompass/denormalized-data/pacerdata/'),
                            cts:element-value-query(xs:QName('ScopeID'),xs:string($scopeID)),
                            cts:not-query(cts:element-value-query(xs:QName('Year'),'')),
                            cts:not-query(cts:element-value-query(xs:QName('Firm'),'')),
                            if($firmName ne '') then cts:element-value-query(xs:QName('Firm'),$firmName,('exact')) else (),
                            cts:not-query(cts:element-value-query(xs:QName('TypeOfRepresentation'),$emptyRepresentationName)),
                            if($typeOfRepresentation ne 'All Types' and $typeOfRepresentation ne '') then cts:element-value-query(xs:QName('TypeOfRepresentation'),fn:tokenize($typeOfRepresentation,'[|]')) else(),
                            if($startYear ne '') then cts:element-range-query(xs:QName('Year'),'>=',xs:integer($startYear)) else(),
                            if($endYear ne '') then cts:element-range-query(xs:QName('Year'),'<=',xs:integer($endYear)) else()
                        ))

    
    
    let $loopData := for $item in cts:values(cts:element-reference(xs:QName('Firm')), (), (),$andQuery)

                        let $ipTorndQuery := cts:and-query((
                            cts:directory-query('/LegalCompass/denormalized-data/pacerdata/'),
                            cts:element-value-query(xs:QName('ScopeID'),xs:string($scopeID)),
                            cts:not-query(cts:element-value-query(xs:QName('Year'),'')),
                            cts:element-value-query(xs:QName('Firm'),$item,('exact')),
                            cts:not-query(cts:element-value-query(xs:QName('TypeOfRepresentation'),$emptyRepresentationName)),
                            cts:element-value-query(xs:QName('TypeOfRepresentation'),fn:tokenize($ipTOR,'[|]')),
                            if($startYear ne '') then cts:element-range-query(xs:QName('Year'),'>=',xs:integer($startYear)) else(),
                            if($endYear ne '') then cts:element-range-query(xs:QName('Year'),'<=',xs:integer($endYear)) else()
                        )) 

                        let $litigationTorndQuery := cts:and-query((
                            cts:directory-query('/LegalCompass/denormalized-data/pacerdata/'),
                            cts:element-value-query(xs:QName('ScopeID'),xs:string($scopeID)),
                            cts:not-query(cts:element-value-query(xs:QName('Year'),'')),
                            cts:not-query(cts:element-value-query(xs:QName('Firm'),'')),
                            cts:element-value-query(xs:QName('Firm'),$item,('exact')),
                            cts:not-query(cts:element-value-query(xs:QName('TypeOfRepresentation'),$emptyRepresentationName)),
                            cts:element-value-query(xs:QName('TypeOfRepresentation'),fn:tokenize($litigationTOR,'[|]')),
                            if($startYear ne '') then cts:element-range-query(xs:QName('Year'),'>=',xs:integer($startYear)) else(),
                            if($endYear ne '') then cts:element-range-query(xs:QName('Year'),'<=',xs:integer($endYear)) else()
                        ))                                        

                        let $transactionalTorndQuery := cts:and-query((
                            cts:directory-query('/LegalCompass/denormalized-data/pacerdata/'),
                            cts:element-value-query(xs:QName('ScopeID'),xs:string($scopeID)),
                            cts:not-query(cts:element-value-query(xs:QName('Year'),'')),
                            cts:not-query(cts:element-value-query(xs:QName('Firm'),'')),
                            cts:element-value-query(xs:QName('Firm'),$item,('exact')),
                            cts:not-query(cts:element-value-query(xs:QName('TypeOfRepresentation'),$emptyRepresentationName)),
                            cts:element-value-query(xs:QName('TypeOfRepresentation'),fn:tokenize($transTOR,'[|]')),
                            if($startYear ne '') then cts:element-range-query(xs:QName('Year'),'>=',xs:integer($startYear)) else(),
                            if($endYear ne '') then cts:element-range-query(xs:QName('Year'),'<=',xs:integer($endYear)) else()
                        )) 

                        let $firmName := $item
                        (: let $ipCount := fn:count(fn:distinct-values(cts:search(/, $ipTorndQuery)//Details/text()))
                        let $litigationCount := fn:count(fn:distinct-values(cts:search(/, $litigationTorndQuery)//Details/text()))
                        let $transactionalCount := fn:count(fn:distinct-values(cts:search(/, $transactionalTorndQuery)//Details/text())) :)

                        let $ipCount := xdmp:estimate(cts:search(/, $ipTorndQuery))
                        let $litigationCount := xdmp:estimate(cts:search(/, $litigationTorndQuery))
                        let $transactionalCount := xdmp:estimate(cts:search(/, $transactionalTorndQuery))
                        let $total := $ipCount + $litigationCount + $transactionalCount

                        let $firmID := cts:search(/,
                                            cts:and-query((
                                                cts:directory-query('/LegalCompass/denormalized-data/pacerdata/'),
                                                cts:element-value-query(xs:QName('ScopeID'),xs:string($scopeID)),
                                                cts:not-query(cts:element-value-query(xs:QName('Year'),'')),
                                                cts:not-query(cts:element-value-query(xs:QName('Firm'),'')),
                                                cts:element-word-query(xs:QName('Firm'),$item,('wildcarded')
                                        ))))[1]//FirmID/text()

                        let $resObj := json:object()
                        let $_ := (
                                    map:put($resObj,'LawFirm',$firmName),
                                    map:put($resObj,'IntellectualProperty',$ipCount),
                                    map:put($resObj,'Litigation',$litigationCount),
                                    map:put($resObj,'Transaction',$transactionalCount),
                                    map:put($resObj,'Total',$total),
                                    map:put($resObj,'FirmId',if($firmID) then $firmID[1] else 0)
                                    ) 
                        let $_ := json:array-push($resArray, $resObj)
                        return()                                             
    
    return $resArray

};


declare function pacerdata:DeleteDataByScopeID($scopeID)
{
     let $andQuery := cts:and-query((
                            cts:directory-query('/LegalCompass/denormalized-data/pacerdata/'),
                            cts:element-value-query(xs:QName('ScopeID'),$scopeID)))
                        
     let $docCount := count(cts:uris("", (),$andQuery))
     let $range := if($docCount > 20000) then  fn:round-half-to-even($docCount div 20000,0) else 0

     let $loopData := for $item in (1 to $range + 1)
                        return xdmp:document-delete(cts:uris("", (),$andQuery)[1 to (xs:integer($item) * 20000)])

     return()                   


};

 (: declare function pacerdata:GetCompanyProfileLFRData($request)
{
    let $scopeID := $request/ScopeID/text()
    let $startYear := $request/YearFrom/text()
    let $endYear := $request/YearTo/text()
    let $typeOfRepresentation := $request/Representations/text()
    let $PageNo := $request/PageNo/text()
    let $PageSize := $request/PageSize/text()
    let $rep := fn:tokenize($typeOfRepresentation,'[|]')

    let $litigationTOR := $request/LitigationTypeOfRepresentation/text()
    let $ipTOR := $request/IPTypeOfRepresentation/text()
    let $transTOR := $request/TransactionalTypeOfRepresentation/text()

    let $sortBy := $request/SortBy/text()
    let $sortDirection := if($request/SortDirection/text() eq 'ASC') then 'ascending' else 'descending'
    let $fromRecord := if($PageNo ne '1') then (xs:int($PageNo)-1)*xs:int($PageSize) else 1
    let $toRecord := xs:int($PageSize)*xs:int($PageNo)

    let $orderBy :=if($sortBy eq 'Firm') then cts:index-order(cts:element-reference(xs:QName('Firm')) ,$sortDirection) 
                   else if($sortBy eq 'TypeOfRepresentation') then cts:index-order(cts:element-reference(xs:QName('TypeOfRepresentation')) ,$sortDirection) 
                   else if($sortBy eq 'Year') then cts:index-order(cts:element-reference(xs:QName('Year')) ,$sortDirection) 
                   else if($sortBy eq 'Source') then cts:index-order(cts:element-reference(xs:QName('Source')) ,$sortDirection) 
                   else cts:index-order(cts:element-reference(xs:QName('Year')) ,'descending')
    let $resArray := json:array()

    let $emptyRepresentationName := cts:search(/,
                                        cts:and-query((
                                            cts:directory-query('/LegalCompass/relational-data/REPRESENTATION_TYPES/'),
                                            cts:element-value-query(xs:QName('REPRESENTATION_TYPES:LEVEL_2'),'')
                                        )))//REPRESENTATION_TYPES:REPRESENTATION_TYPE_NAME/text()

    let $andQuery := cts:and-query((
                            cts:directory-query('/LegalCompass/denormalized-data/pacerdata/'),
                            cts:element-value-query(xs:QName('ScopeID'),xs:string($scopeID)),
                            cts:not-query(cts:element-value-query(xs:QName('Year'),'')),
                            cts:not-query(cts:element-value-query(xs:QName('Firm'),'')),
                            (:cts:element-value-query(xs:QName('Firm'),'Bradley Arant Boult Cummings LLP'),:)
                            cts:not-query(cts:element-value-query(xs:QName('TypeOfRepresentation'),$emptyRepresentationName)),
                            cts:or-query((
                                cts:element-value-query(xs:QName('TypeOfRepresentation'),fn:tokenize($litigationTOR,'[|]')),
                                cts:element-value-query(xs:QName('TypeOfRepresentation'),fn:tokenize($ipTOR,'[|]')),
                                cts:element-value-query(xs:QName('TypeOfRepresentation'),fn:tokenize($transTOR,'[|]'))
                            )),
                            if($startYear ne '') then cts:element-range-query(xs:QName('Year'),'>=',xs:integer($startYear)) else(),
                            if($endYear ne '') then cts:element-range-query(xs:QName('Year'),'<=',xs:integer($endYear)) else()
                        ))

    let $result := fn:distinct-values(cts:search(/,
                        $andQuery , $orderBy
                        )//CaseID/text())[xs:integer($fromRecord) to xs:integer($toRecord)]

    let $resutl := for $item in                     

    let $recordCount := fn:count(fn:distinct-values(cts:search(/,
                        $andQuery
                        )//Details/text()))            

   

    let $loopData := for $detail in $result
                        let $resObj := json:object() 

                        let $andQuery1 := cts:and-query((
                            cts:directory-query('/LegalCompass/denormalized-data/pacerdata/'),
                            cts:element-value-query(xs:QName('ScopeID'),xs:string($scopeID)),
                            cts:element-value-query(xs:QName('Details'),$detail),
                            cts:not-query(cts:element-value-query(xs:QName('Year'),'')),
                            cts:not-query(cts:element-value-query(xs:QName('Firm'),'')),
                            cts:not-query(cts:element-value-query(xs:QName('TypeOfRepresentation'),$emptyRepresentationName)),
                            cts:or-query((
                                cts:element-value-query(xs:QName('TypeOfRepresentation'),fn:tokenize($litigationTOR,'[|]')),
                                cts:element-value-query(xs:QName('TypeOfRepresentation'),fn:tokenize($ipTOR,'[|]')),
                                cts:element-value-query(xs:QName('TypeOfRepresentation'),fn:tokenize($transTOR,'[|]'))
                            )),
                            if($startYear ne '') then cts:element-range-query(xs:QName('Year'),'>=',xs:integer($startYear)) else(),
                            if($endYear ne '') then cts:element-range-query(xs:QName('Year'),'<=',xs:integer($endYear)) else()
                        ))

                        let $item := cts:search(/, $andQuery1)[1]

                        let $_ := (
                                    map:put($resObj,'Firm',$item//Firm/text()),
                                    map:put($resObj,'TypeOfRepresentation',$item//TypeOfRepresentation/text()),
                                    map:put($resObj,'Year',$item//Year/text()),
                                    map:put($resObj,'Details',$detail),
                                    map:put($resObj,'Source',$item//Source/text()),
                                    map:put($resObj,'TotalCount',$recordCount),
                                    map:put($resObj,'RecordCount',$recordCount)
                                  )    

                        let $_ := json:array-push($resArray,$resObj)
                        return()
    return $resArray                
};  :)

declare function pacerdata:GetCompanyProfileLFRMaxYear($scopeID)
{
    let $andQuery := cts:and-query((
                            cts:directory-query('/LegalCompass/denormalized-data/pacerdata/'),
                            cts:element-value-query(xs:QName('ScopeID'),xs:string($scopeID)),
                            cts:not-query(cts:element-value-query(xs:QName('Year'),'')),
                            cts:not-query(cts:element-value-query(xs:QName('Firm'),''))
                        ))

    let $result := fn:max(cts:search(/,
                        $andQuery
                        )//Year/text())

    
    return $result                
};

declare function pacerdata:GetCompanyProfileLFRDataCount($request)
{
    let $scopeID := $request/ScopeID/text()
    let $startYear := $request/YearFrom/text()
    let $endYear := $request/YearTo/text()
    let $typeOfRepresentation := $request/Representations/text()
    let $PageNo := $request/PageNo/text()
    let $PageSize := $request/PageSize/text()
    let $rep := fn:tokenize($typeOfRepresentation,'[|]')

    let $litigationTOR := $request/LitigationTypeOfRepresentation/text()
    let $ipTOR := $request/IPTypeOfRepresentation/text()
    let $transTOR := $request/TransactionalTypeOfRepresentation/text()

    let $sortBy := $request/SortBy/text()
    let $sortDirection := if($request/SortDirection/text() eq 'ASC') then 'ascending' else 'descending'
    let $fromRecord := if($PageNo ne '1') then (xs:int($PageNo)-1)*xs:int($PageSize) else 1
    let $toRecord := xs:int($PageSize)*xs:int($PageNo)

    let $orderBy :=if($sortBy eq 'Firm') then cts:index-order(cts:element-reference(xs:QName('Firm')) ,$sortDirection) 
                   else if($sortBy eq 'TypeOfRepresentation') then cts:index-order(cts:element-reference(xs:QName('TypeOfRepresentation')) ,$sortDirection) 
                   else if($sortBy eq 'Year') then cts:index-order(cts:element-reference(xs:QName('Year')) ,$sortDirection) 
                   else if($sortBy eq 'Source') then cts:index-order(cts:element-reference(xs:QName('Source')) ,$sortDirection) 
                   else cts:index-order(cts:element-reference(xs:QName('Year')) ,'descending')
    let $resArray := json:array()

    let $emptyRepresentationName := cts:search(/,
                                        cts:and-query((
                                            cts:directory-query('/LegalCompass/relational-data/REPRESENTATION_TYPES/'),
                                            cts:element-value-query(xs:QName('REPRESENTATION_TYPES:LEVEL_2'),'')
                                        )))//REPRESENTATION_TYPES:REPRESENTATION_TYPE_NAME/text()

    let $andQuery := cts:and-query((
                            cts:directory-query('/LegalCompass/denormalized-data/pacerdata/'),
                            cts:element-value-query(xs:QName('ScopeID'),xs:string($scopeID)),
                            cts:not-query(cts:element-value-query(xs:QName('Year'),'')),
                            cts:not-query(cts:element-value-query(xs:QName('Firm'),'')),
                            (:cts:element-value-query(xs:QName('Firm'),'Bradley Arant Boult Cummings LLP'),:)
                            cts:not-query(cts:element-value-query(xs:QName('TypeOfRepresentation'),$emptyRepresentationName)),
                            cts:or-query((
                                cts:element-value-query(xs:QName('TypeOfRepresentation'),fn:tokenize($litigationTOR,'[|]')),
                                cts:element-value-query(xs:QName('TypeOfRepresentation'),fn:tokenize($ipTOR,'[|]')),
                                cts:element-value-query(xs:QName('TypeOfRepresentation'),fn:tokenize($transTOR,'[|]'))
                            )),
                            if($startYear ne '') then cts:element-range-query(xs:QName('Year'),'>=',xs:integer($startYear)) else(),
                            if($endYear ne '') then cts:element-range-query(xs:QName('Year'),'<=',xs:integer($endYear)) else()
                        ))

    return xdmp:estimate(cts:search(/,$andQuery))                    

};    