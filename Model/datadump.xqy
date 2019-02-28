xquery version '1.0-ml';

module namespace datadump = 'http://alm.com/datadump';

import module namespace config = 'http://alm.com/config' at '/common/config.xqy';
import module namespace search = 'http://marklogic.com/appservices/search' at '/MarkLogic/appservices/search/search.xqy';
import module namespace uniq = 'http://marklogic.com/unique' at '/common/UniqueHelper-lib.xqy';
declare namespace util = 'http://alm.com/util';
declare namespace ps = 'http://developer.marklogic.com/2006-09-paginated-search';

declare namespace tblrer = "http://alm.com/LegalCompass/dd/TBL_RER_CACHE_ATTORNEY_DATA";
declare namespace tblrermovechanges = "http://alm.com/LegalCompass/dd/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES";
declare namespace aliattorneydata = 'http://alm.com/LegalCompass/dd/ALI_RE_Attorney_Data';
declare namespace people = 'http://alm.com/LegalCompass/rd/person';
declare namespace ALI_RE_Event_Data = 'http://alm.com/LegalCompass/dd/ALI_RE_Event_Data';
declare namespace lateralmoves = 'http://alm.com/LegalCompass/rd/ALI_RE_LateralMoves_Data';
declare namespace LAWFIRM_VARIATIONS= 'http://alm.com/LegalCompass/rd/LAWFIRM_VARIATIONS';
declare namespace GETCLIENTS = "http://alm.com/LegalCompass/dd/GETCLIENTS";
declare namespace CompanyVariations = 'http://alm.com/LegalCompass/rd/COMPANY_VARIATIONS';

declare function datadump:DeleteDocuments($dir,$qName,$id)
{
 
 let $ids := fn:tokenize($id,',')
 let $and-query := cts:and-query((
						cts:directory-query($dir),
						cts:not-query(cts:element-value-query(xs:QName($qName),$ids))))
						
 let $result := cts:values(cts:element-reference(xs:QName($qName)),(),(),$and-query)
 
 let $loopData := for $item in $result
				  let $xmlURI := fn:concat($dir,$item,'.xml')
				  let $_ := xdmp:document-delete($xmlURI)
				  return()
 
 return $result
};

declare function datadump:InserPacerData($request)
{
	let $loopData :=for $item in $request
						let $id := uniq:next-sequential-uri('/LegalCompass/denormalized-data/pacerdata/','.xml','pacerdata')
						
						let $uri := fn:concat('/LegalCompass/denormalized-data/pacerdata/',$id,'.xml')
							
						let $update-result := xdmp:document-insert($uri, $item)

						
						return ()
    return()						
		
}; 

declare function datadump:AddFirmID($scopeID)
{

	 let $andQuery := cts:and-query((
                            cts:directory-query('/LegalCompass/denormalized-data/pacerdata/'),
                            cts:element-value-query(xs:QName('ScopeID'),$scopeID)))
                        
     let $doc := (cts:uris("", (),$andQuery))

     let $loopData := for $item in $doc
	 					let $firmName := fn:doc($item)/CompanyLawFirmRepresentation/Firm/text()
						let $aliID := cts:search(/,
										cts:and-query((
											cts:directory-query('/LegalCompass/relational-data/LAWFIRM_VARIATIONS/'),
											cts:element-word-query(xs:QName('LAWFIRM_VARIATIONS:VARIATIONS'),$firmName,('wildcarded','case-insensitive'))
										)))[1]//LAWFIRM_VARIATIONS:ALI_ID/text()
						
						return xdmp:node-insert-child(doc($item)/CompanyLawFirmRepresentation,element{"FirmID"}{$aliID}) 

     return ()		
			
};

declare function datadump:AddALIIdForClients($firmID)
{

	 let $andQuery := cts:and-query((
                            cts:directory-query('/LegalCompass/denormalized-data/GetClients/'),
                            cts:element-value-query(xs:QName('GETCLIENTS:FIRMID'),$firmID)))
                        
     let $doc := (:(cts:uris("", (),$andQuery)):) '/LegalCompass/denormalized-data/GetClients/10013.xml'

     let $loopData := for $item in $doc
	 					let $firmName := fn:doc($item)//GETCLIENTS:ORGANIZATION_NAME/text()
						let $aliID := cts:search(/,
										cts:and-query((
											cts:directory-query('/LegalCompass/relational-data/COMPANY_VARIATIONS/'),
											cts:element-word-query(xs:QName('CompanyVariations:VARIATIONS'),$firmName,('wildcarded','case-insensitive'))
										)))[1]

					 let $aliID1 := 	$aliID//CompanyVariations:ALI_ID/text()
						let $aliName := $aliID//CompanyVariations:ALI_NAME/text()		
						
					    let $_ := xdmp:node-insert-child(doc($item)//GETCLIENTS,element{"CLIENT_ID"}{$aliID1})
						let $_ := xdmp:node-insert-child(doc($item)//GETCLIENTS,element{"CLIENT_NAME"}{$aliName}) 
						return (:xdmp:node-insert-child(doc($item)//GETCLIENTS,element{"CLIENT_ID"}{$aliID1}):) ()

     return $loopData		
			
};

declare function GetClientData($from,$to)
{
	let $fromY := xs:integer($from)
	let $toY := xs:integer($to)
	let $jsonArray := json:array()
	let $result := cts:search(/,
						cts:and-query((
								cts:directory-query('/LegalCompass/denormalized-data/GetClients_1/'),
								cts:element-range-query(xs:QName('GETCLIENTS:DATE'),'>=',2013),
								cts:element-range-query(xs:QName('GETCLIENTS:DATE'),'<=',2019)
								)))[$fromY to $toY]

	let $loopData := for $item in $result
					 let $jsonObj := json:object()
					 let $_ := (
						 		map:put($jsonObj,'SOURCE',$item//GETCLIENTS:SOURCE/text()),
								 map:put($jsonObj,'TYPEOFTRANSACTION',$item//GETCLIENTS:TYPEOFTRANSACTION/text()),
								 map:put($jsonObj,'SEARCHID',$item//GETCLIENTS:SEARCHID/text()),
								 map:put($jsonObj,'ROLE',$item//GETCLIENTS:ROLE/text()),
								 map:put($jsonObj,'FIRM',$item//GETCLIENTS:FIRM/text()),
								 map:put($jsonObj,'CLIENT',$item//GETCLIENTS:CLIENT/text()),
								 map:put($jsonObj,'DATE',$item//GETCLIENTS:DATE/text()),
								 map:put($jsonObj,'MONTH',$item//GETCLIENTS:MONTH/text()),
								 map:put($jsonObj,'JURISDICTION',$item//GETCLIENTS:JURISDICTION/text()),
								 map:put($jsonObj,'CASENAME',$item//GETCLIENTS:CASENAME/text()),
								 map:put($jsonObj,'CASEID',$item//GETCLIENTS:CASEID/text()),
								 map:put($jsonObj,'PATENTNUMBER',$item//GETCLIENTS:PATENTNUMBER/text()),
								 map:put($jsonObj,'TYPEOFCASE',$item//GETCLIENTS:TYPEOFCASE/text()),
								 map:put($jsonObj,'DOCKETNUMBER',$item//GETCLIENTS:DOCKETNUMBER/text()),
								 map:put($jsonObj,'FIRMID',$item//GETCLIENTS:FIRMID/text()),
								 map:put($jsonObj,'DETAILS',$item//GETCLIENTS:DETAILS/text()),
								 map:put($jsonObj,'REPRESENTATION_TYPE_ID',$item//GETCLIENTS:REPRESENTATION_TYPE_ID/text()),
								 map:put($jsonObj,'ORGANIZATION_NAME',$item//GETCLIENTS:ORGANIZATION_NAME/text()),
								 map:put($jsonObj,'LEVEL_1',$item//GETCLIENTS:LEVEL_1/text()),
								 map:put($jsonObj,'LEVEL_2',$item//GETCLIENTS:LEVEL_2/text()),
								 map:put($jsonObj,'CLIENT_ID',$item//GETCLIENTS:CLIENT_ID/text()),
								 map:put($jsonObj,'CLIENT_NAME',$item//GETCLIENTS:CLIENT_NAME/text())
							   )

					let $_ := json:array-push($jsonArray, $jsonObj)
					return()
					return $jsonArray

};