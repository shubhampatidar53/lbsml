xquery version '1.0-ml';

module namespace news = 'http://alm.com/news';

import module namespace config = 'http://alm.com/config' at '/common/config.xqy';
import module namespace firm = 'http://alm.com/firm' at '/common/model/firm.xqy';
import module namespace json = 'http://marklogic.com/xdmp/json'  at '/MarkLogic/json/json.xqy';

declare namespace data = 'http://alm.com/LegalCompass/rd/data';
declare namespace practices_kws = 'http://alm.com/LegalCompass/rd/practices_kws';
declare namespace ALI_RE_News_Data = 'http://alm.com/LegalCompass/rd/ALI_RE_News_Data';

declare option xdmp:mapping 'false';

declare function news:GetNewsPracticeTrends(
	 $contentTypes
	,$fromDate
	,$toDate
	,$companyID
	,$practiceAreas
	,$Keywords
)
{
	let $companyIDs := if ($companyID != '') then fn:tokenize($companyID,',') else ()
	
	(: Date Range Query :)
	let $date_q := if (($fromDate != '') and ($toDate != '')) then
			let $fromDate := xs:date(fn:tokenize($fromDate,'T')[1])
			let $toDate := xs:date(fn:tokenize($toDate,'T')[1])
			return (
				cts:element-range-query(xs:QName('ALI_RE_News_Data:dateAdded'), '>=', $fromDate)
				,cts:element-range-query(xs:QName('ALI_RE_News_Data:dateAdded'), '<=', $toDate)
				,cts:not-query(cts:element-value-query(xs:QName('ALI_RE_News_Data:dateAdded'), ''))
			)
		else ()
	
	(: Content Type Query :)
	let $content-q := if (($contentTypes != '') and ($contentTypes != 'null')) then
			let $contentTypes := fn:tokenize($contentTypes,'[|]')
			return cts:element-value-query(xs:QName('ALI_RE_News_Data:category'), $contentTypes, ('case-insensitive'))
		else 
			cts:element-value-query(xs:QName('ALI_RE_News_Data:category'), ('News','Pubs','Twitter','Pub'), ('case-insensitive'))	
	
	(: Practice Areas Query :)
	let $practicea-area-q := if (($practiceAreas != '') and ($practiceAreas != 'null')) then
			let $practiceAreas := fn:tokenize($practiceAreas,"[|]")
			(:let $practiceAreas := ($practiceAreas ! fn:concat("*",.,"*")):)
			return cts:element-word-query(xs:QName('ALI_RE_News_Data:practice_area'),$practiceAreas,('wildcarded','case-insensitive'))
		else ()
	
	(: Keyword Query :)
	let $keyword-q := if($Keywords !='') then
			
							if(fn:contains(fn:lower-case($Keywords),'and') and fn:not(fn:contains(fn:lower-case($Keywords),'"'))) then 
								 news:GetAndOperatorQuery($Keywords)
													
							
							else if(fn:contains(fn:lower-case($Keywords),'or') and fn:not(fn:contains(fn:lower-case($Keywords),'"'))) then 
								 news:GetOrOperatorQuery($Keywords)
													
							else if(fn:contains(fn:lower-case($Keywords),'"') and fn:contains(fn:lower-case($Keywords),'" or "')) then 
								 news:GetExactOrOperatorQuery($Keywords)

							else if(fn:contains(fn:lower-case($Keywords),'"') and fn:contains(fn:lower-case($Keywords),' or ')) then 
								 news:GetExactOrOperatorQuery($Keywords)	 
										
							else if(fn:contains(fn:lower-case($Keywords),'"') and fn:contains(fn:lower-case($Keywords),'" and "')) then 
								 news:GetExactAndOperatorQuery($Keywords)

							else if(fn:contains(fn:lower-case($Keywords),'"') and fn:contains(fn:lower-case($Keywords),' and ')) then 
								 news:GetExactAndOperatorQuery($Keywords)	 			
										
							else if(fn:contains(fn:lower-case($Keywords),' or ') and fn:contains(fn:lower-case($Keywords),' and ')) then 
								 news:GetAndOrOperatorQuery($Keywords)
							
							(:else if(fn:contains(fn:lower-case($Keywords),'"') and fn:not(fn:contains(fn:lower-case($Keywords),'" and "')) and fn:not(fn:contains(fn:lower-case($Keywords),'" or "'))) then 
								 news:GetExactAndOperatorQuery($Keywords)	:)
							
							else if(fn:contains($Keywords,',') and fn:not(fn:contains(fn:lower-case($Keywords),'"'))) then 
								   cts:or-query((
									cts:element-word-query(xs:QName('ALI_RE_News_Data:title'),fn:tokenize($Keywords,','),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('ALI_RE_News_Data:description'),fn:tokenize($Keywords,','),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('ALI_RE_News_Data:practice_area'),fn:tokenize($Keywords,','),('wildcarded','case-insensitive'))
								))
								else if(fn:contains($Keywords,' ') and fn:not(fn:contains(fn:lower-case($Keywords),'"'))) then 
								   cts:or-query((
									cts:element-word-query(xs:QName('ALI_RE_News_Data:title'),fn:tokenize($Keywords,' '),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('ALI_RE_News_Data:description'),fn:tokenize($Keywords,' '),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('ALI_RE_News_Data:practice_area'),fn:tokenize($Keywords,' '),('wildcarded','case-insensitive'))
								))
								else cts:or-query((
										cts:element-word-query(xs:QName('ALI_RE_News_Data:title'),fn:concat('*' , fn:replace($Keywords,'"',''),'*'),('wildcarded','case-insensitive')),
										cts:element-word-query(xs:QName('ALI_RE_News_Data:description'),fn:concat('*' , fn:replace($Keywords,'"',''),'*'),('wildcarded','case-insensitive')),
										cts:element-word-query(xs:QName('ALI_RE_News_Data:practice_area'),fn:concat('*' , fn:replace($Keywords,'"',''),'*'),('wildcarded','case-insensitive'))
										))
							
					else ()
	
	
	(:if ($Keywords != '') then
			cts:element-word-query(xs:QName('ALI_RE_News_Data:title'),fn:concat("*",$Keywords,"*") ,('wildcarded','case-insensitive'))
		else () 	:)
		
	let $conditions := (
		 cts:directory-query($config:RD-ALI_RE_News_Data-PATH)
		,$content-q
		,$date_q
		,$practicea-area-q
		,$keyword-q
		(:,cts:element-range-query(xs:QName('ALI_RE_News_Data:companyID'), '>', 0)
		,cts:not-query(cts:element-value-query(xs:QName('ALI_RE_News_Data:companyID'), '')):)
		,if ($companyIDs != '') then cts:element-value-query(xs:QName("ALI_RE_News_Data:companyID"),$companyIDs) else ()
		,cts:not-query(cts:element-value-query(xs:QName('ALI_RE_News_Data:dateAdded'), ('*-00-00*','0/0/*','00/00/*'), ('wildcarded')))
	)

	let $practice_areas := cts:values(cts:element-reference(xs:QName('practices_kws:practice_area')))

	let $Main := for $practice_area in $practice_areas
		let $query := cts:and-query((
			cts:element-word-query(xs:QName('ALI_RE_News_Data:practice_area'),$practice_area,('wildcarded','case-insensitive'))
			,$conditions
		))
	
		let $search := cts:search(/ALI_RE_News_Data, $query)
		let $obj := for $res in $search
			let $dateAdded := $res/ALI_RE_News_Data:dateAdded/text()
			(:let $MonthName := fn:format-date(xs:date($dateAdded),'[MNn] - [Y0001]'):)
			let $MonthName := $res/ALI_RE_News_Data:monthname/text()
			return element {'obj'} {
				element {'dateAdded'} {$res/ALI_RE_News_Data:dateAdded/text()}
				,element {'PracticeArea'} {$practice_area}
				,element {'MonthName'} {$MonthName}
			}
		return $obj

	let $FinalMain := for $practice_area in $practice_areas
		let $search := $Main[PracticeArea eq $practice_area]
		let $EventMonths := fn:distinct-values($search/MonthName/text())
		let $obj := for $MonthName in $EventMonths
			let $node := $search[MonthName eq $MonthName]
			let $Total := fn:count($node)
			return element {'obj'} {
				 element {'dateAdded'} {$node[1]/dateAdded/text()}
				,element {'PracticeArea'} {$practice_area}
				,element {'MonthName'} {$MonthName}
				,element {'Total'} {$Total}
			}
		return $obj


	let $FinalPractice := (
  
		for $practice_area in $practice_areas
    
			let $query := cts:and-query((
				 cts:element-word-query(xs:QName('ALI_RE_News_Data:practice_area'),$practice_area,('wildcarded','case-insensitive'))
				,$conditions
			))
    
			let $TotalCount := xdmp:estimate(cts:search(fn:doc(),$query))
			let $TotalCount_1 := cts:frequency($practice_area)

			let $obj := element {'obj'} {
				 element {'PracticeArea'} {$practice_area}
				,element {'TotalCount'} {$TotalCount}
				(: ,element {'TotalCount_1'} {$TotalCount_1} :)
			}
    
			order by $TotalCount descending
    
		return $obj
    
	)[1 to 5]

	let $response := for $item in $FinalMain
		let $practiceAreas := $item/PracticeArea/text()
  
		let $node := $FinalPractice[PracticeArea eq $practiceAreas]
		let $DateAdded := $item/dateAdded
		order by $DateAdded ascending
		return if ($node) then $item else ()
	
	let $response := element {'RESULT'} {$response}
	
	let $custom :=
		let $config := json:config('custom')
		let $_ := map:put( $config, 'whitespace', 'ignore' )
		let $_ := map:put( $config, 'array-element-names', ('obj') )
		return $config
	
	let $response := xdmp:to-json-string(json:transform-to-json($response, $custom)//obj)
	
	return $response
};

declare function news:GetNewsPracticeTrends1(
	 $contentTypes
	,$fromDate
	,$toDate
	,$companyID
	,$practiceAreas
	,$Keywords
)
{
	let $res-array := json:array()
    let $andQuery := cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/ALI_RE_News_Data/'),
                        cts:element-range-query(xs:QName('ALI_RE_News_Data:dateAdded'),'>=',xs:date($fromDate)),
                        cts:element-range-query(xs:QName('ALI_RE_News_Data:dateAdded'),'<=',xs:date($toDate))
                        ))
    let $result := cts:values(cts:element-reference(xs:QName('practices_kws:practice_area')),(),())
    let $monthName := cts:values(cts:element-reference(xs:QName('ALI_RE_News_Data:monthname')),(),(),$andQuery)
    let $loopData := for $item in $result
                         let $loopData1 := for $item1 in $monthName
                                           let $res-obj := json:object()
                                           let $practiceCount := xdmp:estimate(cts:search(/,
                                                                     cts:and-query((
                                                                       cts:directory-query('/LegalCompass/relational-data/ALI_RE_News_Data/'),
                                                                       cts:element-word-query(xs:QName('ALI_RE_News_Data:practiceAreas'),$item,('wildcarded','case-insensitive')),
                                                                       cts:element-value-query(xs:QName('ALI_RE_News_Data:monthname'),$item1)(:,
                                                                       cts:element-range-query(xs:QName('ALI_RE_News_Data:dateAdded'),'>=',xs:date($fromDate)),
                                                                       cts:element-range-query(xs:QName('ALI_RE_News_Data:dateAdded'),'<=',xs:date($toDate)):)
                                                                     ))))
                                           let $_ := (map:put($res-obj,'PracticeArea',$item),
                                                      map:put($res-obj,'dateAdded',''),                           
                                                      map:put($res-obj,'MonthName',$item1),
                                                      map:put($res-obj,'Total',$practiceCount))
                                           let $_ := json:array-push($res-array,$res-obj)
                                           return()
                                           return()
                         
                         
                      
  return $res-array
};

declare function news:GetNewsPracticeTrends2(
	 $contentType
	,$fromDate
	,$toDate
	,$companyID
	,$practiceAreas
	,$Keywords
	,$twitterContentTypes
)
{
    let $res-array := json:array()
    let $contentTypes := fn:tokenize($contentType,',')
    let $practiceArea := if($practiceAreas ne '') then fn:tokenize($practiceAreas,';') else()
	let $companyIDs := if ($companyID != '') then fn:tokenize($companyID,',') else ()
    let $twitterContentType := fn:tokenize($twitterContentTypes,',')

	let $keyword-q := if($Keywords !='') then
			
							if(fn:contains(fn:lower-case($Keywords),'and') and fn:not(fn:contains(fn:lower-case($Keywords),'"'))) then 
								 news:GetAndOperatorQuery($Keywords)
													
							
							else if(fn:contains(fn:lower-case($Keywords),'or') and fn:not(fn:contains(fn:lower-case($Keywords),'"'))) then 
								 news:GetOrOperatorQuery($Keywords)
													
							else if(fn:contains(fn:lower-case($Keywords),'"') and fn:contains(fn:lower-case($Keywords),'" or "')) then 
								 news:GetExactOrOperatorQuery($Keywords)

							else if(fn:contains(fn:lower-case($Keywords),'"') and fn:contains(fn:lower-case($Keywords),' or ')) then 
								 news:GetExactOrOperatorQuery($Keywords)	 
										
							else if(fn:contains(fn:lower-case($Keywords),'"') and fn:contains(fn:lower-case($Keywords),'" and "')) then 
								 news:GetExactAndOperatorQuery($Keywords)

							else if(fn:contains(fn:lower-case($Keywords),'"') and fn:contains(fn:lower-case($Keywords),' and ')) then 
								 news:GetExactAndOperatorQuery($Keywords)	 			
										
							else if(fn:contains(fn:lower-case($Keywords),' or ') and fn:contains(fn:lower-case($Keywords),' and ')) then 
								 news:GetAndOrOperatorQuery($Keywords)
							
							(:else if(fn:contains(fn:lower-case($Keywords),'"') and fn:not(fn:contains(fn:lower-case($Keywords),'" and "')) and fn:not(fn:contains(fn:lower-case($Keywords),'" or "'))) then 
								 news:GetExactAndOperatorQuery($Keywords)	:)
							
							else if(fn:contains($Keywords,',') and fn:not(fn:contains(fn:lower-case($Keywords),'"'))) then 
								   cts:or-query((
									cts:element-word-query(xs:QName('ALI_RE_News_Data:title'),fn:tokenize($Keywords,','),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('ALI_RE_News_Data:description'),fn:tokenize($Keywords,','),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('ALI_RE_News_Data:practice_area'),fn:tokenize($Keywords,','),('wildcarded','case-insensitive'))
								))
								else if(fn:contains($Keywords,' ') and fn:not(fn:contains(fn:lower-case($Keywords),'"'))) then 
								   cts:or-query((
									cts:element-word-query(xs:QName('ALI_RE_News_Data:title'),fn:tokenize($Keywords,' '),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('ALI_RE_News_Data:description'),fn:tokenize($Keywords,' '),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('ALI_RE_News_Data:practice_area'),fn:tokenize($Keywords,' '),('wildcarded','case-insensitive'))
								))
								else cts:or-query((
										cts:element-word-query(xs:QName('ALI_RE_News_Data:title'),fn:concat('*' , fn:replace($Keywords,'"',''),'*'),('wildcarded','case-insensitive')),
										cts:element-word-query(xs:QName('ALI_RE_News_Data:description'),fn:concat('*' , fn:replace($Keywords,'"',''),'*'),('wildcarded','case-insensitive')),
										cts:element-word-query(xs:QName('ALI_RE_News_Data:practice_area'),fn:concat('*' , fn:replace($Keywords,'"',''),'*'),('wildcarded','case-insensitive'))
										))
							
					else ()

	let $andQuery := cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/ALI_RE_News_Data/'),
						cts:and-query((
							cts:element-range-query(xs:QName('ALI_RE_News_Data:dateAdded'),'>=',xs:date($fromDate)),
							cts:element-range-query(xs:QName('ALI_RE_News_Data:dateAdded'),'<=',xs:date($toDate)))),
                        if($practiceAreas ne '') then cts:element-value-query(xs:QName('ALI_RE_News_Data:practice_area'),$practiceArea,('wildcarded','case-insensitive')) else(),
						if ($companyIDs != '') then cts:element-value-query(xs:QName('ALI_RE_News_Data:companyID'),$companyIDs) else (),
						$keyword-q,
                        if($contentType ne '') then cts:element-value-query(xs:QName('ALI_RE_News_Data:category'),$contentTypes) else ()
						,if($twitterContentTypes ne '') then 
							cts:or-query((
								cts:element-word-query(xs:QName('ALI_RE_News_Data:type'),$twitterContentType[1],('wildcarded','case-insensitive')),
								if($twitterContentType[2] ne '') then cts:element-value-query(xs:QName('ALI_RE_News_Data:type'),$twitterContentType[2],('wildcarded','case-insensitive')) else())) else()
									))
    
let $result := if($practiceArea != '') then $practiceArea else cts:values(cts:element-reference(xs:QName('practices_kws:practice_area')),(),())
	
let $monthIDs := cts:values(cts:element-reference(xs:QName('ALI_RE_News_Data:monthid')),(),(),$andQuery)

let $loopData := for $item in $result
                        
    let $loopData1 := for $item1 in $monthIDs
        let $monthID := if(fn:string-length(xs:string($item1)) eq 1) then fn:concat('0',$item1) else $item1
        let $andQuery1 := cts:and-query((
            cts:directory-query('/LegalCompass/relational-data/ALI_RE_News_Data/'),
            cts:element-range-query(xs:QName('ALI_RE_News_Data:dateAdded'),'>=',xs:date($fromDate)),
            cts:element-range-query(xs:QName('ALI_RE_News_Data:dateAdded'),'<=',xs:date($toDate)),
            cts:element-value-query(xs:QName('ALI_RE_News_Data:monthid'),xs:string($monthID))
			))  
																
        let $monthName :=cts:values(cts:element-reference(xs:QName('ALI_RE_News_Data:monthname')),(),(),$andQuery1)
        for $mName in $monthName
			let $res-obj := json:object()
            let $practiceCount := fn:count(cts:search(/,
                cts:and-query((
                cts:directory-query('/LegalCompass/relational-data/ALI_RE_News_Data/'),
                cts:element-word-query(xs:QName('ALI_RE_News_Data:practiceAreas'),$item,('wildcarded','case-insensitive')),
                cts:and-query((
                cts:element-value-query(xs:QName('ALI_RE_News_Data:monthname'),$mName),
                cts:element-range-query(xs:QName('ALI_RE_News_Data:dateAdded'),'>=',xs:date($fromDate)),
                cts:element-range-query(xs:QName('ALI_RE_News_Data:dateAdded'),'<=',xs:date($toDate)))),			
                if ($companyIDs != '') then cts:element-value-query(xs:QName('ALI_RE_News_Data:companyID'),$companyIDs) else (),
                if($contentTypes != '') then cts:element-value-query(xs:QName('ALI_RE_News_Data:category'),$contentTypes,('wildcarded')) else ()
				,$keyword-q
				))))

            let $_ := 
                (map:put($res-obj,'PracticeArea',$item),
                map:put($res-obj,'dateAdded',''),                           
                map:put($res-obj,'MonthName',$mName),
                map:put($res-obj,'Total',$practiceCount),
                map:put($res-obj,'MonthID',xs:integer($monthID))
				) 
            
                                                        
            let $_ :=if($practiceCount > 0) then  json:array-push($res-array,$res-obj) else()
			
            return ()
        return ()
            
return $res-array 

};


declare function news:GetNewsFirmTrends(
	 $contentTypes
	,$fromDate
	,$toDate
	,$companyID
	,$practiceAreas
	,$Keywords
	,$twitterContentTypes
)
{
	let $companyIDs := if ($companyID != '') then fn:tokenize($companyID,',') else ()
	
	let $twitterContentType := fn:tokenize($twitterContentTypes,',')

	(: Date Range Query :)
	let $date_q := if (($fromDate != '') and ($toDate != '')) then
			let $fromDate := xs:date(fn:tokenize($fromDate,'T')[1])
			let $toDate := xs:date(fn:tokenize($toDate,'T')[1])
			return (
				cts:element-range-query(xs:QName('ALI_RE_News_Data:dateAdded'), '>=', $fromDate)
				,cts:element-range-query(xs:QName('ALI_RE_News_Data:dateAdded'), '<=', $toDate)
			)
		else ()
	
	(: Content Type Query :)
	let $content-q := if (($contentTypes != '') and ($contentTypes != 'null')) then
			let $contentTypes := fn:tokenize($contentTypes,',')
			return cts:element-value-query(xs:QName('ALI_RE_News_Data:category'), $contentTypes, ('case-insensitive'))
		else 
			cts:element-value-query(xs:QName('ALI_RE_News_Data:category'), ('News','Pubs','Twitter','Pub'), ('case-insensitive'))	
	
	(: Practice Areas Query :)
	let $practicea-area-q := if (($practiceAreas != '') and ($practiceAreas != 'null')) then
			let $practiceAreas := fn:tokenize($practiceAreas,";")
			let $practiceAreas := ($practiceAreas ! fn:concat("*",.,"*"))
			return cts:element-word-query(xs:QName('ALI_RE_News_Data:practice_area'),$practiceAreas,('wildcarded','case-insensitive'))
		else ()
	
	(: Keyword Query :)
	let $keyword-q := if($Keywords !='') then
			
							if(fn:contains(fn:lower-case($Keywords),'and') and fn:not(fn:contains(fn:lower-case($Keywords),'"'))) then 
								 news:GetAndOperatorQuery($Keywords)
													
							
							else if(fn:contains(fn:lower-case($Keywords),'or') and fn:not(fn:contains(fn:lower-case($Keywords),'"'))) then 
								 news:GetOrOperatorQuery($Keywords)
													
							else if(fn:contains(fn:lower-case($Keywords),'"') and fn:contains(fn:lower-case($Keywords),'" or "')) then 
								 news:GetExactOrOperatorQuery($Keywords)

							else if(fn:contains(fn:lower-case($Keywords),'"') and fn:contains(fn:lower-case($Keywords),' or ')) then 
								 news:GetExactOrOperatorQuery($Keywords)	 
										
							else if(fn:contains(fn:lower-case($Keywords),'"') and fn:contains(fn:lower-case($Keywords),'" and "')) then 
								 news:GetExactAndOperatorQuery($Keywords)

							else if(fn:contains(fn:lower-case($Keywords),'"') and fn:contains(fn:lower-case($Keywords),' and ')) then 
								 news:GetExactAndOperatorQuery($Keywords)	 			
										
							else if(fn:contains(fn:lower-case($Keywords),' or ') and fn:contains(fn:lower-case($Keywords),' and ')) then 
								 news:GetAndOrOperatorQuery($Keywords)
							
							(:else if(fn:contains(fn:lower-case($Keywords),'"') and fn:not(fn:contains(fn:lower-case($Keywords),'" and "')) and fn:not(fn:contains(fn:lower-case($Keywords),'" or "'))) then 
								 news:GetExactAndOperatorQuery($Keywords)	:)
							
							else if(fn:contains($Keywords,',') and fn:not(fn:contains(fn:lower-case($Keywords),'"'))) then 
								   cts:or-query((
									cts:element-word-query(xs:QName('ALI_RE_News_Data:title'),fn:tokenize($Keywords,','),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('ALI_RE_News_Data:description'),fn:tokenize($Keywords,','),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('ALI_RE_News_Data:practice_area'),fn:tokenize($Keywords,','),('wildcarded','case-insensitive'))
								))
								else if(fn:contains($Keywords,' ') and fn:not(fn:contains(fn:lower-case($Keywords),'"'))) then 
								   cts:or-query((
									cts:element-word-query(xs:QName('ALI_RE_News_Data:title'),fn:tokenize($Keywords,' '),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('ALI_RE_News_Data:description'),fn:tokenize($Keywords,' '),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('ALI_RE_News_Data:practice_area'),fn:tokenize($Keywords,' '),('wildcarded','case-insensitive'))
								))
								else cts:or-query((
										cts:element-word-query(xs:QName('ALI_RE_News_Data:title'),fn:replace($Keywords,'"',''),('wildcarded','case-insensitive')),
										cts:element-word-query(xs:QName('ALI_RE_News_Data:description'), fn:replace($Keywords,'"',''),('wildcarded','case-insensitive')),
										cts:element-word-query(xs:QName('ALI_RE_News_Data:practice_area'),fn:replace($Keywords,'"',''),('wildcarded','case-insensitive'))
										))
							
					else ()
	
	
	
		
	let $conditions := (
		 cts:directory-query($config:RD-ALI_RE_News_Data-PATH)
		,$content-q
		,$date_q
		,$practicea-area-q
		,$keyword-q
		,cts:element-range-query(xs:QName('ALI_RE_News_Data:companyID'), '>', 0)
		
		,if ($companyIDs != '') then cts:element-value-query(xs:QName("ALI_RE_News_Data:companyID"),$companyIDs) else ()
		,cts:not-query(cts:element-value-query(xs:QName('ALI_RE_News_Data:dateAdded'), ('*-00-00*','0/0/*','00/00/*',''), ('wildcarded')))
		,if($twitterContentTypes ne '') then 
						cts:or-query((
							cts:element-word-query(xs:QName('ALI_RE_News_Data:type'),$twitterContentType[1],('wildcarded','case-insensitive')),
							if($twitterContentType[2] ne '') then cts:element-value-query(xs:QName('ALI_RE_News_Data:type'),$twitterContentType[2],('wildcarded','case-insensitive')) else())) else()
	)
	
	let $search := cts:element-values(xs:QName('ALI_RE_News_Data:re_id'),(),(),cts:and-query(($conditions)))
	
	let $response := (
		for $rec in $search
		  
		  let $FirmId := $rec
		  
		  let $FirmName := cts:search(/ALI_RE_News_Data, cts:and-query((
									cts:directory-query($config:RD-ALI_RE_News_Data-PATH),
									cts:not-query(cts:element-value-query(xs:QName('ALI_RE_News_Data:re_id'),'')),
									cts:element-value-query(xs:QName('ALI_RE_News_Data:re_id'),xs:string($rec))
								)))[1]/ALI_RE_News_Data:company/text()
		  
		  let $Total := xdmp:estimate(cts:search(fn:doc(), cts:and-query((
			  $conditions,
			  cts:element-value-query(xs:QName('ALI_RE_News_Data:re_id'),xs:string($rec)))
			)))
				
		  let $node := element {'RECORD'} {
			 element {'FirmId'} {$FirmId}
			,element {'FirmName'} {$FirmName}
			,element {'Total'} {$Total}
		  }
		  order by xs:integer($Total) descending
		  return $node
	)[1 to 5]
	
	
	let $count := fn:count($response)
	
	let $response := element {'RESULT'} {$response}
	
	let $custom :=
		let $config := json:config('custom')
		let $_ := map:put( $config, 'whitespace', 'ignore' )
		let $_ := map:put( $config, 'array-element-names', ('RECORD') )
		return $config
	
	let $response := if ($count > 1) then 
			xdmp:to-json-string(json:transform-to-json($response, $custom)//RECORD) 
		else json:to-array(json:transform-to-json($response, $custom)//RECORD)
  
	return $response
	
};

declare function news:GetNews_Alert(
	 $pageNo
	,$recordsPerPage
	,$contentTypes
	,$fromDate
	,$toDate
	,$companyID
	,$ALMRankingListName
	,$practiceAreas
	,$Keywords
	,$SortBy
	,$SortDirection
	,$twitterContentTypes
)
{
	let $direction := if (fn:upper-case($SortDirection) = 'DESC') then 'descending' else 'ascending'
	
	let $start := ((($pageNo - 1) * $recordsPerPage) + 1)
	let $end := (($start + $recordsPerPage) - 1 )
	
	let $companyIDs := if ($companyID != '') then fn:tokenize($companyID,',') else ()
	
	let $twitterContentType := fn:tokenize($twitterContentTypes,'[|]')
	
	(: Date Range Query :)
	let $date_q := if (($fromDate != '') and ($toDate != '')) then
			let $fromDate := xs:date(fn:tokenize($fromDate,'T')[1])
			let $toDate := xs:date(fn:tokenize($toDate,'T')[1])
			return (
				cts:element-range-query(xs:QName('ALI_RE_News_Data:dateAdded'), '>=', $fromDate)
				,cts:element-range-query(xs:QName('ALI_RE_News_Data:dateAdded'), '<=', $toDate)
			)
		else ()

	(: Content Type Query :)
	let $content-q := if (($contentTypes != '') and ($contentTypes != 'null')) then
			let $contentTypes := fn:tokenize($contentTypes,'[|]')
			return cts:element-value-query(xs:QName('ALI_RE_News_Data:category'), $contentTypes, ('case-insensitive'))
		else 
			cts:element-value-query(xs:QName('ALI_RE_News_Data:category'), ('News','Pubs','Twitter','Pub'), ('case-insensitive'))
	
	(: Practice Areas Query :)
	let $practicea-area-q := if (($practiceAreas != '') and ($practiceAreas != 'null')) then
			let $practiceAreas := fn:tokenize($practiceAreas,"[|]")
			let $practiceAreas := ($practiceAreas ! fn:concat("*",.,"*"))
			return cts:element-word-query(xs:QName('ALI_RE_News_Data:practice_area'),$practiceAreas,('wildcarded','case-insensitive'))
		else ()

	(: Keyword Query :)
	let $keyword-q := if($Keywords !='') then
			
							if(fn:contains(fn:lower-case($Keywords),'and') and fn:not(fn:contains(fn:lower-case($Keywords),'"'))) then 
								 news:GetAndOperatorQuery($Keywords)
													
							
							else if(fn:contains(fn:lower-case($Keywords),'or') and fn:not(fn:contains(fn:lower-case($Keywords),'"'))) then 
								 news:GetOrOperatorQuery($Keywords)
													
							else if(fn:contains(fn:lower-case($Keywords),'"') and fn:contains(fn:lower-case($Keywords),'" or "')) then 
								 news:GetExactOrOperatorQuery($Keywords)

							else if(fn:contains(fn:lower-case($Keywords),'"') and fn:contains(fn:lower-case($Keywords),' or ')) then 
								 news:GetExactOrOperatorQuery($Keywords)	 
										
							else if(fn:contains(fn:lower-case($Keywords),'"') and fn:contains(fn:lower-case($Keywords),'" and "')) then 
								 news:GetExactAndOperatorQuery($Keywords)

							else if(fn:contains(fn:lower-case($Keywords),'"') and fn:contains(fn:lower-case($Keywords),' and ')) then 
								 news:GetExactAndOperatorQuery($Keywords)	 			
										
							else if(fn:contains(fn:lower-case($Keywords),' or ') and fn:contains(fn:lower-case($Keywords),' and ')) then 
								 news:GetAndOrOperatorQuery($Keywords)
							
							(:else if(fn:contains(fn:lower-case($Keywords),'"') and fn:not(fn:contains(fn:lower-case($Keywords),'" and "')) and fn:not(fn:contains(fn:lower-case($Keywords),'" or "'))) then 
								 news:GetExactAndOperatorQuery($Keywords)	:)
							
							else if(fn:contains($Keywords,',') and fn:not(fn:contains(fn:lower-case($Keywords),'"'))) then 
								   cts:or-query((
									cts:element-word-query(xs:QName('ALI_RE_News_Data:title'),fn:tokenize($Keywords,','),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('ALI_RE_News_Data:description'),fn:tokenize($Keywords,','),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('ALI_RE_News_Data:practice_area'),fn:tokenize($Keywords,','),('wildcarded','case-insensitive'))
								))
								else if(fn:contains($Keywords,' ') and fn:not(fn:contains(fn:lower-case($Keywords),'"'))) then 
								   cts:or-query((
									cts:element-word-query(xs:QName('ALI_RE_News_Data:title'),fn:tokenize($Keywords,' '),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('ALI_RE_News_Data:description'),fn:tokenize($Keywords,' '),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('ALI_RE_News_Data:practice_area'),fn:tokenize($Keywords,' '),('wildcarded','case-insensitive'))
								))
								else cts:or-query((
										cts:element-word-query(xs:QName('ALI_RE_News_Data:title'),fn:concat('*' , fn:replace($Keywords,'"',''),'*'),('wildcarded','case-insensitive')),
										cts:element-word-query(xs:QName('ALI_RE_News_Data:description'),fn:concat('*' , fn:replace($Keywords,'"',''),'*'),('wildcarded','case-insensitive')),
										cts:element-word-query(xs:QName('ALI_RE_News_Data:practice_area'),fn:concat('*' , fn:replace($Keywords,'"',''),'*'),('wildcarded','case-insensitive'))
										))
							
					else ()
	
	
	(:if ($Keywords != '') then
			cts:element-word-query(xs:QName('ALI_RE_News_Data:title'),fn:concat("*",$Keywords,"*") ,('wildcarded','case-insensitive'))
		else () :)

	let $conditions1 := (
		 cts:directory-query($config:RD-ALI_RE_News_Data-PATH)
		,$content-q
		,$date_q
		,$practicea-area-q
		,$keyword-q
		,cts:element-value-query(xs:QName("ALI_RE_News_Data:category"),'Pubs')
		,if ($companyIDs != '') then cts:element-value-query(xs:QName("ALI_RE_News_Data:companyID"),$companyIDs) else ()
		,cts:not-query(cts:element-value-query(xs:QName('ALI_RE_News_Data:dateAdded'), ('*-00-00*','0/0/*','00/00/*'), ('wildcarded')))
		,if($twitterContentTypes ne '') then 
				cts:or-query((
					cts:element-word-query(xs:QName('ALI_RE_News_Data:type'),$twitterContentType[1],('wildcarded','case-insensitive')),
					if($twitterContentType[2] ne '') then cts:element-value-query(xs:QName('ALI_RE_News_Data:type'),$twitterContentType[2],('wildcarded','case-insensitive')) else())) else()
	)

	let $conditions2 := (
		 cts:directory-query($config:RD-ALI_RE_News_Data-PATH)
		,$content-q
		,$date_q
		,$practicea-area-q
		,$keyword-q
		,cts:element-value-query(xs:QName("ALI_RE_News_Data:category"),'News')
		,if ($companyIDs != '') then cts:element-value-query(xs:QName("ALI_RE_News_Data:companyID"),$companyIDs) else ()
		,cts:not-query(cts:element-value-query(xs:QName('ALI_RE_News_Data:dateAdded'), ('*-00-00*','0/0/*','00/00/*'), ('wildcarded')))
		,if($twitterContentTypes ne '') then 
				cts:or-query((
					cts:element-word-query(xs:QName('ALI_RE_News_Data:type'),$twitterContentType[1],('wildcarded','case-insensitive')),
					if($twitterContentType[2] ne '') then cts:element-value-query(xs:QName('ALI_RE_News_Data:type'),$twitterContentType[2],('wildcarded','case-insensitive')) else())) else()
	)

	let $conditions3 := (
		 cts:directory-query($config:RD-ALI_RE_News_Data-PATH)
		,$content-q
		,$date_q
		,$practicea-area-q
		,$keyword-q
		,cts:element-value-query(xs:QName("ALI_RE_News_Data:category"),'Twitter')
		,if ($companyIDs != '') then cts:element-value-query(xs:QName("ALI_RE_News_Data:companyID"),$companyIDs) else ()
		,cts:not-query(cts:element-value-query(xs:QName('ALI_RE_News_Data:dateAdded'), ('*-00-00*','0/0/*','00/00/*'), ('wildcarded')))
		,if($twitterContentTypes ne '') then 
				cts:or-query((
					cts:element-word-query(xs:QName('ALI_RE_News_Data:type'),$twitterContentType[1],('wildcarded','case-insensitive')),
					if($twitterContentType[2] ne '') then cts:element-value-query(xs:QName('ALI_RE_News_Data:type'),$twitterContentType[2],('wildcarded','case-insensitive')) else())) else()
	)
	
	let $order-by := if (fn:upper-case($SortBy) = 'DATEADDED') then (
			cts:index-order(cts:element-reference(xs:QName('ALI_RE_News_Data:dateAdded')) ,$direction)
		)
		else ()

	let $totalcount := fn:count(cts:search(/, cts:and-query(($conditions1))))
	
	let $response1 := (
		
		for $rec in cts:search(/ALI_RE_News_Data, cts:and-query(($conditions1)), $order-by)[1 to 50]
      
			let $category := $rec/ALI_RE_News_Data:category/text()
			let $companyID := $rec/ALI_RE_News_Data:companyID/text()
			let $company := $rec/ALI_RE_News_Data:company/text()
			let $dataSource := $rec/ALI_RE_News_Data:dataSource/text()
			let $dateAdded := $rec/ALI_RE_News_Data:dateAdded/text()
			let $description := fn:normalize-space($rec/ALI_RE_News_Data:description/text())
			let $link := $rec/ALI_RE_News_Data:link/text()
			let $practiceAreas := $rec/ALI_RE_News_Data:practiceAreas/text()
			let $title := $rec/ALI_RE_News_Data:title/text()
					
			let $node := element {"RECORD"} {
				element {"category"} {$category}
				,element {"company"} {$company}
				,element {"companyID"} {$companyID}
				,element {"dataSource"} {$dataSource}
				,element {"dateAdded"} {$dateAdded}
				,element {"description"} {$description}
				,element {"link"} {$link}
				,element {"practiceAreas"} {$practiceAreas}
				,element {"title"} {$title}
				,element {"totalcount"} {$totalcount}
			}
      
			
			order by $dateAdded descending
				
      
      return $node
      
	)

	let $response2 := (
		
		for $rec in cts:search(/ALI_RE_News_Data, cts:and-query(($conditions2)), $order-by)[1 to 50]
      
			let $category := $rec/ALI_RE_News_Data:category/text()
			let $companyID := $rec/ALI_RE_News_Data:companyID/text()
			let $company := $rec/ALI_RE_News_Data:company/text()
			let $dataSource := $rec/ALI_RE_News_Data:dataSource/text()
			let $dateAdded := $rec/ALI_RE_News_Data:dateAdded/text()
			let $description := fn:normalize-space($rec/ALI_RE_News_Data:description/text())
			let $link := $rec/ALI_RE_News_Data:link/text()
			let $practiceAreas := $rec/ALI_RE_News_Data:practiceAreas/text()
			let $title := $rec/ALI_RE_News_Data:title/text()
					
			let $node := element {"RECORD"} {
				element {"category"} {$category}
				,element {"company"} {$company}
				,element {"companyID"} {$companyID}
				,element {"dataSource"} {$dataSource}
				,element {"dateAdded"} {$dateAdded}
				,element {"description"} {$description}
				,element {"link"} {$link}
				,element {"practiceAreas"} {$practiceAreas}
				,element {"title"} {$title}
				,element {"totalcount"} {$totalcount}
			}
      
			
			order by $dateAdded descending
				
      
      return $node
      
	)

	let $response3 := (
		
		for $rec in cts:search(/ALI_RE_News_Data, cts:and-query(($conditions3)), $order-by)[1 to 50]
      
			let $category := $rec/ALI_RE_News_Data:category/text()
			let $companyID := $rec/ALI_RE_News_Data:companyID/text()
			let $company := $rec/ALI_RE_News_Data:company/text()
			let $dataSource := $rec/ALI_RE_News_Data:dataSource/text()
			let $dateAdded := $rec/ALI_RE_News_Data:dateAdded/text()
			let $description := fn:normalize-space($rec/ALI_RE_News_Data:description/text())
			let $link := $rec/ALI_RE_News_Data:link/text()
			let $practiceAreas := $rec/ALI_RE_News_Data:practiceAreas/text()
			let $title := $rec/ALI_RE_News_Data:title/text()
					
			let $node := element {"RECORD"} {
				element {"category"} {$category}
				,element {"company"} {$company}
				,element {"companyID"} {$companyID}
				,element {"dataSource"} {$dataSource}
				,element {"dateAdded"} {$dateAdded}
				,element {"description"} {$description}
				,element {"link"} {$link}
				,element {"practiceAreas"} {$practiceAreas}
				,element {"title"} {$title}
				,element {"totalcount"} {$totalcount}
			}
      
			
			order by $dateAdded descending
				
      
      return $node
      
	)
  
	let $response := element {'RESULT'} {$response1,$response2,$response3}
	
	let $custom :=
		let $config := json:config('custom')
		let $_ := map:put( $config, 'whitespace', 'ignore' )
		let $_ := map:put( $config, 'array-element-names', ('RECORD') )
		return $config
	
	let $response := xdmp:to-json-string(json:transform-to-json($response, $custom)//RECORD)
  
	 return if($response eq 'null') then () else 
	 			 if(fn:contains($response,'[')) then $response else fn:concat('[',$response,']')
	 
	
};

declare function news:GetNews(
	 $pageNo
	,$recordsPerPage
	,$contentTypes
	,$fromDate
	,$toDate
	,$companyID
	,$ALMRankingListName
	,$practiceAreas
	,$Keywords
	,$SortBy
	,$SortDirection
	,$twitterContentTypes
)
{
	let $direction := if (fn:upper-case($SortDirection) = 'DESC') then 'descending' else 'ascending'
	
	let $start := ((($pageNo - 1) * $recordsPerPage) + 1)
	let $end := (($start + $recordsPerPage) - 1 )
	
	let $companyIDs := if ($companyID != '') then fn:tokenize($companyID,',') else ()
	
	let $twitterContentType := fn:tokenize($twitterContentTypes,'[|]')
	
	(: Date Range Query :)
	let $date_q := if (($fromDate != '') and ($toDate != '')) then
			let $fromDate := xs:date(fn:tokenize($fromDate,'T')[1])
			let $toDate := xs:date(fn:tokenize($toDate,'T')[1])
			return (
				cts:element-range-query(xs:QName('ALI_RE_News_Data:dateAdded'), '>=', $fromDate)
				,cts:element-range-query(xs:QName('ALI_RE_News_Data:dateAdded'), '<=', $toDate)
			)
		else ()

	(: Content Type Query :)
	let $content-q := if (($contentTypes != '') and ($contentTypes != 'null')) then
			let $contentTypes := fn:tokenize($contentTypes,'[|]')
			return cts:element-value-query(xs:QName('ALI_RE_News_Data:category'), $contentTypes, ('case-insensitive'))
		else 
			cts:element-value-query(xs:QName('ALI_RE_News_Data:category'), ('News','Pubs','Twitter','Pub'), ('case-insensitive'))
	
	(: Practice Areas Query :)
	let $practicea-area-q := if (($practiceAreas != '') and ($practiceAreas != 'null')) then
			let $practiceAreas := fn:tokenize($practiceAreas,"[|]")
			let $practiceAreas := ($practiceAreas ! fn:concat("*",.,"*"))
			return cts:element-word-query(xs:QName('ALI_RE_News_Data:practice_area'),$practiceAreas,('wildcarded','case-insensitive'))
		else ()

	(: Keyword Query :)
	let $keyword-q := if($Keywords !='') then
			
							if(fn:contains(fn:lower-case($Keywords),'and') and fn:not(fn:contains(fn:lower-case($Keywords),'"'))) then 
								 news:GetAndOperatorQuery($Keywords)
													
							
							else if(fn:contains(fn:lower-case($Keywords),'or') and fn:not(fn:contains(fn:lower-case($Keywords),'"'))) then 
								 news:GetOrOperatorQuery($Keywords)
													
							else if(fn:contains(fn:lower-case($Keywords),'"') and fn:contains(fn:lower-case($Keywords),'" or "')) then 
								 news:GetExactOrOperatorQuery($Keywords)

							else if(fn:contains(fn:lower-case($Keywords),'"') and fn:contains(fn:lower-case($Keywords),' or ')) then 
								 news:GetExactOrOperatorQuery($Keywords)	 
										
							else if(fn:contains(fn:lower-case($Keywords),'"') and fn:contains(fn:lower-case($Keywords),'" and "')) then 
								 news:GetExactAndOperatorQuery($Keywords)

							else if(fn:contains(fn:lower-case($Keywords),'"') and fn:contains(fn:lower-case($Keywords),' and ')) then 
								 news:GetExactAndOperatorQuery($Keywords)	 			
										
							else if(fn:contains(fn:lower-case($Keywords),' or ') and fn:contains(fn:lower-case($Keywords),' and ')) then 
								 news:GetAndOrOperatorQuery($Keywords)
							
							(:else if(fn:contains(fn:lower-case($Keywords),'"') and fn:not(fn:contains(fn:lower-case($Keywords),'" and "')) and fn:not(fn:contains(fn:lower-case($Keywords),'" or "'))) then 
								 news:GetExactAndOperatorQuery($Keywords)	:)
							
							else if(fn:contains($Keywords,',') and fn:not(fn:contains(fn:lower-case($Keywords),'"'))) then 
								   cts:or-query((
									cts:element-word-query(xs:QName('ALI_RE_News_Data:title'),fn:tokenize($Keywords,','),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('ALI_RE_News_Data:description'),fn:tokenize($Keywords,','),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('ALI_RE_News_Data:practice_area'),fn:tokenize($Keywords,','),('wildcarded','case-insensitive'))
								))
								else if(fn:contains($Keywords,' ') and fn:not(fn:contains(fn:lower-case($Keywords),'"'))) then 
								   cts:or-query((
									cts:element-word-query(xs:QName('ALI_RE_News_Data:title'),fn:tokenize($Keywords,' '),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('ALI_RE_News_Data:description'),fn:tokenize($Keywords,' '),('wildcarded','case-insensitive')),
									cts:element-word-query(xs:QName('ALI_RE_News_Data:practice_area'),fn:tokenize($Keywords,' '),('wildcarded','case-insensitive'))
								))
								else cts:or-query((
										cts:element-word-query(xs:QName('ALI_RE_News_Data:title'),fn:concat('*' , fn:replace($Keywords,'"',''),'*'),('wildcarded','case-insensitive')),
										cts:element-word-query(xs:QName('ALI_RE_News_Data:description'),fn:concat('*' , fn:replace($Keywords,'"',''),'*'),('wildcarded','case-insensitive')),
										cts:element-word-query(xs:QName('ALI_RE_News_Data:practice_area'),fn:concat('*' , fn:replace($Keywords,'"',''),'*'),('wildcarded','case-insensitive'))
										))
							
					else ()
	
	
	(:if ($Keywords != '') then
			cts:element-word-query(xs:QName('ALI_RE_News_Data:title'),fn:concat("*",$Keywords,"*") ,('wildcarded','case-insensitive'))
		else () :)

	let $conditions := (
		 cts:directory-query($config:RD-ALI_RE_News_Data-PATH)
		,$content-q
		,$date_q
		,$practicea-area-q
		,$keyword-q
		,if ($companyIDs != '') then cts:element-value-query(xs:QName("ALI_RE_News_Data:companyID"),$companyIDs) else ()
		,cts:not-query(cts:element-value-query(xs:QName('ALI_RE_News_Data:dateAdded'), ('*-00-00*','0/0/*','00/00/*'), ('wildcarded')))
		,if($twitterContentTypes ne '') then 
				cts:or-query((
					cts:element-word-query(xs:QName('ALI_RE_News_Data:type'),$twitterContentType[1],('wildcarded','case-insensitive')),
					if($twitterContentType[2] ne '') then cts:element-value-query(xs:QName('ALI_RE_News_Data:type'),$twitterContentType[2],('wildcarded','case-insensitive')) else())) else()
	)
	
	let $order-by := if (fn:upper-case($SortBy) = 'DATEADDED') then (
			cts:index-order(cts:element-reference(xs:QName('ALI_RE_News_Data:dateAdded')) ,$direction)
		)
		else ()

	let $totalcount := fn:count(cts:search(/, cts:and-query(($conditions))))
	
	let $response := (
		
		for $rec in cts:search(/ALI_RE_News_Data, cts:and-query(($conditions)), $order-by)[xs:integer($start) to xs:integer($end)]
      
			let $category := $rec/ALI_RE_News_Data:category/text()
			let $companyID := $rec/ALI_RE_News_Data:companyID/text()
			let $company := $rec/ALI_RE_News_Data:company/text()
			let $dataSource := $rec/ALI_RE_News_Data:dataSource/text()
			let $dateAdded := $rec/ALI_RE_News_Data:dateAdded/text()
			let $description := fn:normalize-space($rec/ALI_RE_News_Data:description/text())
			let $link := $rec/ALI_RE_News_Data:link/text()
			let $practiceAreas := $rec/ALI_RE_News_Data:practiceAreas/text()
			let $title := $rec/ALI_RE_News_Data:title/text()
					
			let $node := element {"RECORD"} {
				element {"category"} {$category}
				,element {"company"} {$company}
				,element {"companyID"} {$companyID}
				,element {"dataSource"} {$dataSource}
				,element {"dateAdded"} {$dateAdded}
				,element {"description"} {$description}
				,element {"link"} {$link}
				,element {"practiceAreas"} {$practiceAreas}
				,element {"title"} {$title}
				,element {"totalcount"} {$totalcount}
			}
      
			let $order-by := 
				if (fn:upper-case($SortBy) = fn:upper-case('company')) then $company
				else if (fn:upper-case($SortBy) = fn:upper-case('dataSource')) then $dataSource
				else if (fn:upper-case($SortBy) = fn:upper-case('category')) then $category
				else if (fn:upper-case($SortBy) = fn:upper-case('dateAdded')) then $dateAdded
				else if (fn:upper-case($SortBy) = fn:upper-case('title')) then $title
				else if (fn:upper-case($SortBy) = fn:upper-case('practiceAreas')) then $practiceAreas
				else ()
  
			order by 
				if ($direction ne 'descending') then () else if ($order-by = '') then () else $order-by descending
				,if ($direction ne 'ascending') then () else if ($order-by = '') then () else $order-by ascending
      
      return $node
      
	)
  
	let $response := element {'RESULT'} {$response}
	
	let $custom :=
		let $config := json:config('custom')
		let $_ := map:put( $config, 'whitespace', 'ignore' )
		let $_ := map:put( $config, 'array-element-names', ('RECORD') )
		return $config
	
	let $response := xdmp:to-json-string(json:transform-to-json($response, $custom)//RECORD)
  
	 return if($response eq 'null') then () else 
	 			 if(fn:contains($response,'[')) then $response else fn:concat('[',$response,']')
	 
	
};

declare function news:GetNewsGLL(
	 $pageNo
	,$recordsPerPage
	,$contentTypes
	,$fromDate
	,$toDate
	,$companyID
	,$ALMRankingListName
	,$practiceAreas
	,$Keywords
	,$SortBy
	,$SortDirection
)
{
	let $direction := if (fn:upper-case($SortDirection) = 'DESC') then 'descending' else 'ascending'
	
	let $start := ((($pageNo - 1) * $recordsPerPage) + 1)
	let $end := (($start + $recordsPerPage) - 1 )
	
	let $companyIDs := if ($companyID != '') then fn:tokenize($companyID,',') else ()
	
	(: Date Range Query :)
	let $date_q := if (($fromDate != '') and ($toDate != '')) then
			let $fromDate := xs:date(fn:tokenize($fromDate,'T')[1])
			let $toDate := xs:date(fn:tokenize($toDate,'T')[1])
			return (
				cts:element-range-query(xs:QName('ALI_RE_News_Data:dateAdded'), '>=', $fromDate)
				,cts:element-range-query(xs:QName('ALI_RE_News_Data:dateAdded'), '<=', $toDate)
			)
		else ()

	(: Content Type Query :)
	let $content-q := if (($contentTypes != '') and ($contentTypes != 'null')) then
			let $contentTypes := fn:tokenize($contentTypes,'[|]')
			return cts:element-value-query(xs:QName('ALI_RE_News_Data:category'), $contentTypes, ('case-insensitive'))
		else 
			(:cts:element-value-query(xs:QName('ALI_RE_News_Data:category'), ('News','Pubs','Twitter','Pub'), ('case-insensitive')):)
			cts:element-value-query(xs:QName('ALI_RE_News_Data:category'), ('News','Pubs','Pub'), ('case-insensitive'))
	
	(: Practice Areas Query :)
	let $practicea-area-q := if (($practiceAreas != '') and ($practiceAreas != 'null')) then
			let $practiceAreas := fn:tokenize($practiceAreas,"[|]")
			let $practiceAreas := ($practiceAreas ! fn:concat("*",.,"*"))
			return cts:element-word-query(xs:QName('ALI_RE_News_Data:practice_area'),$practiceAreas,('wildcarded','case-insensitive'))
		else ()

	(: Keyword Query :)
	let $keyword-q := if ($Keywords != '') then
			cts:element-word-query(xs:QName('ALI_RE_News_Data:title'),fn:concat("*",$Keywords,"*") ,('wildcarded','case-insensitive'))
		else () 

	let $conditions := (
		 cts:directory-query($config:RD-ALI_RE_News_Data-PATH)
		,$content-q
		,$date_q
		,$practicea-area-q
		,$keyword-q
		,if ($companyIDs != '') then cts:element-value-query(xs:QName("ALI_RE_News_Data:companyID"),$companyIDs) else ()
		,cts:not-query(cts:element-value-query(xs:QName('ALI_RE_News_Data:dateAdded'), ('*-00-00*','0/0/*','00/00/*'), ('wildcarded')))
	)
	
	let $order-by := if (fn:upper-case($SortBy) = 'DATEADDED') then (
			cts:index-order(cts:element-reference(xs:QName('ALI_RE_News_Data:dateAdded')) ,$direction)
		)
		else ()

	let $totalcount := fn:count(cts:search(/, cts:and-query(($conditions))))
	
	let $response := (
		
		for $rec in cts:search(/ALI_RE_News_Data, cts:and-query(($conditions)), $order-by)[xs:integer($start) to xs:integer($end)]
      
			let $category := $rec/ALI_RE_News_Data:category/text()
			let $companyID := $rec/ALI_RE_News_Data:companyID/text()
			let $company := $rec/ALI_RE_News_Data:company/text()
			let $dataSource := $rec/ALI_RE_News_Data:dataSource/text()
			let $dateAdded := $rec/ALI_RE_News_Data:dateAdded/text()
			let $description := fn:normalize-space($rec/ALI_RE_News_Data:description/text())
			let $link := $rec/ALI_RE_News_Data:link/text()
			let $practiceAreas := $rec/ALI_RE_News_Data:practiceAreas/text()
			let $title := $rec/ALI_RE_News_Data:title/text()
					
			let $node := element {"RECORD"} {
				element {"category"} {$category}
				,element {"company"} {$company}
				,element {"companyID"} {$companyID}
				,element {"dataSource"} {$dataSource}
				,element {"dateAdded"} {$dateAdded}
				,element {"description"} {$description}
				,element {"link"} {$link}
				,element {"practiceAreas"} {$practiceAreas}
				,element {"title"} {$title}
				,element {"totalcount"} {$totalcount}
			}
      
			let $order-by := 
				if (fn:upper-case($SortBy) = fn:upper-case('company')) then $company
				else if (fn:upper-case($SortBy) = fn:upper-case('dataSource')) then $dataSource
				else if (fn:upper-case($SortBy) = fn:upper-case('category')) then $category
				else if (fn:upper-case($SortBy) = fn:upper-case('dateAdded')) then $dateAdded
				else if (fn:upper-case($SortBy) = fn:upper-case('title')) then $title
				else if (fn:upper-case($SortBy) = fn:upper-case('practiceAreas')) then $practiceAreas
				else ()
  
			order by 
				if ($direction ne 'descending') then () else if ($order-by = '') then () else $order-by descending
				,if ($direction ne 'ascending') then () else if ($order-by = '') then () else $order-by ascending
      
      return $node
      
	)
  
	let $response := element {'RESULT'} {$response}
	
	let $custom :=
		let $config := json:config('custom')
		let $_ := map:put( $config, 'whitespace', 'ignore' )
		let $_ := map:put( $config, 'array-element-names', ('RECORD') )
		return $config
	
	let $response := xdmp:to-json-string(json:transform-to-json($response, $custom)//RECORD)
  
	return $response
};

(:----------------------------------- Keyword helper function -----------------------------------:)

declare function news:GetAndOperatorQuery($Keywords)
{
	let $query := cts:or-query((
										cts:and-query((
										for $item in fn:tokenize(fn:lower-case($Keywords),' and ')
										
											return 
											
											 cts:element-word-query(xs:QName('ALI_RE_News_Data:title'),$item,('wildcarded','case-insensitive'))
											 
											
										)),
										
										cts:and-query((for $item in fn:tokenize(fn:lower-case($Keywords),' and ')
										
											return 
											
											 cts:element-word-query(xs:QName('ALI_RE_News_Data:description'),$item,('wildcarded','case-insensitive'))
											
											
										)),
										
										cts:and-query((for $item in fn:tokenize(fn:lower-case($Keywords),' and ')
										
											return 
											
											 cts:element-word-query(xs:QName('ALI_RE_News_Data:practice_area'),$item,('wildcarded','case-insensitive'))
										))
										
										))
	return $query									
};

declare function news:GetOrOperatorQuery($Keywords)
{
	let $query := cts:or-query((
										cts:or-query((
										for $item in fn:tokenize(fn:lower-case($Keywords),' or ')
										
											return 
											
											 cts:element-word-query(xs:QName('ALI_RE_News_Data:title'),$item,('wildcarded','case-insensitive'))
											 
											
										)),
										
										cts:or-query((for $item in fn:tokenize(fn:lower-case($Keywords),' or ')
										
											return 
											
											 cts:element-word-query(xs:QName('ALI_RE_News_Data:description'),$item,('wildcarded','case-insensitive'))
											
											
										)),
										
										cts:or-query((for $item in fn:tokenize(fn:lower-case($Keywords),' or ')
										
											return 
											
											 cts:element-word-query(xs:QName('ALI_RE_News_Data:practice_area'),$item,('wildcarded','case-insensitive'))
										))
										
										))
										
	return $query									
};

declare function news:GetExactOrOperatorQuery($Keywords)
{
	let $query := cts:or-query((
										cts:or-query((
										for $item in fn:tokenize(fn:lower-case($Keywords),' or ')
										
											return 
											
											 cts:element-word-query(xs:QName('ALI_RE_News_Data:title'),fn:replace($item,'"',''),('case-insensitive'))
											 
											
										)),
										
										cts:or-query((for $item in fn:tokenize(fn:lower-case($Keywords),' or ')
										
											return 
											
											 cts:element-word-query(xs:QName('ALI_RE_News_Data:description'),fn:replace($item,'"',''),('case-insensitive'))
											
											
										)),
										
										cts:or-query((for $item in fn:tokenize(fn:lower-case($Keywords),' or ')
										
											return 
											
											 cts:element-word-query(xs:QName('ALI_RE_News_Data:practice_area'),fn:replace($item,'"',''),('case-insensitive'))
										))
										
										))
	return $query									
};

declare function news:GetExactAndOperatorQuery($Keywords)
{
	let $query := cts:or-query((
										cts:and-query((
										for $item in fn:tokenize(fn:lower-case($Keywords),' and ')
										
											return 
											
											 cts:element-word-query(xs:QName('ALI_RE_News_Data:title'),fn:replace($item,'"',''),('case-insensitive'))
											 
											
										)),
										
										cts:and-query((for $item in fn:tokenize(fn:lower-case($Keywords),' and ')
										
											return 
											
											 cts:element-word-query(xs:QName('ALI_RE_News_Data:description'),fn:replace($item,'"',''),('case-insensitive'))
											
											
										)),
										
										cts:and-query((for $item in fn:tokenize(fn:lower-case($Keywords),' and ')
										
											return 
											
											 cts:element-word-query(xs:QName('ALI_RE_News_Data:practice_area'),fn:replace($item,'"',''),('case-insensitive'))
										))
										
										))
	return $query									
};

declare function news:GetAndOrOperatorQuery($keyword)
{
	let $key := fn:tokenize($keyword,' or ')
	for $Keywords in $key
		let $query := cts:or-query((
											cts:and-query((
											for $item in fn:tokenize(fn:lower-case($Keywords),' and ')
											
												return 
												
												 cts:element-word-query(xs:QName('ALI_RE_News_Data:title'),fn:replace($item,'"',''),('wildcarded','case-insensitive'))
												 
												
											)),
											
											cts:and-query((for $item in fn:tokenize($Keywords,' and ')
											
												return 
												
												 cts:element-word-query(xs:QName('ALI_RE_News_Data:description'),fn:replace($item,'"',''),('wildcarded','case-insensitive'))
												
												
											)),
											
											cts:and-query((for $item in fn:tokenize($Keywords,' and ')
											
												return 
												
												 cts:element-word-query(xs:QName('ALI_RE_News_Data:practice_area'),fn:replace($item,'"',''),('wildcarded','case-insensitive'))
											))
											
											))
		return $query
		
		
};