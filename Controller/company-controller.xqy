xquery version "1.0-ml";

module namespace company-ctlr = "http://alm.com/controller/company";

import module namespace company = "http://alm.com/company" at "/common/model/company.xqy";

declare namespace util = "http://alm.com/util";

declare option xdmp:mapping "false";

declare function company-ctlr:IsOverviewExists($params as element(util:params))
{
	company:IsOverviewExists($params/util:scopeID/text())
};

declare function company-ctlr:IsLFRExists($params as element(util:params))
{
	company:IsLFRExists($params/util:scopeID/text())
};

declare function company-ctlr:IsCompanyExistsForPacer($params as element(util:params))
{
	company:IsCompanyExistsForPacer($params/util:scopeID/text())
};


declare function company-ctlr:GetCompanyDetail($params as element(util:params))
{
	company:GetCompanyDetail($params/util:companyID/text() , $params/util:scopeID/text())
};

declare function company-ctlr:IsContactExists($params as element(util:params))
{
	company:IsContactExists($params/util:scopeID/text())
};

declare function company-ctlr:GetCompanyExecutivesContacts($params as element(util:params))
{
	company:GetCompanyExecutivesContacts($params/util:companyID/text(),$params/util:scopeID/text())
};

declare function company-ctlr:GetCompanyDetailByName($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	let $companyName := $request/CompanyName/text()
	let $companyID := $request/CompanyID/text()
	return company:GetCompanyDetailByName($companyName , $companyID )
};

declare function company-ctlr:GetCompanyExecutives($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	let $companyName := $request/CompanyName/text()
	let $companyID := $request/CompanyID/text()
	return company:GetCompanyExecutives($companyName ,$companyID)
};

declare function company-ctlr:IsNewsExists($params as element(util:params))
{
	company:IsNewsExists($params/util:companyID/text())
};

declare function company-ctlr:GetCompanyProfileNews($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	let $CompanyID := $request/CompanyID/text()
	let $FromDate := fn:tokenize($request/FromDate/text(),'T')
	let $ToDate := fn:tokenize($request/ToDate/text(),'T')
	return company:GetCompanyProfileNews($CompanyID ,$FromDate[1], $ToDate[1])
};

declare function company-ctlr:IsCompeExists($params as element(util:params))
{
	company:IsCompeExists($params/util:scopeID/text())
};

declare function company-ctlr:GetCompanyCompetitor($params as element(util:params))
{
	company:GetCompanyCompetitor($params/util:companyID/text(),$params/util:scopeID/text())
};

declare function company-ctlr:GetCompanyProfileCompetitorsDetails($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	let $scopeID := $request/ScopeID/text()
	let $companyID := $request/CompanyID/text()
	let $companyName := $request/CompanyName/text()
	return company:GetCompanyProfileCompetitorsDetails($scopeID,$companyName,$companyID)
};

declare function company-ctlr:IsSubsiExists($params as element(util:params))
{
	company:IsSubsiExists($params/util:scopeID/text())
};

declare function company-ctlr:GetCompanySubsidaries($params as element(util:params))
{
	company:GetCompanySubsidaries($params/util:companyID/text(),$params/util:scopeID/text())
};

declare function company-ctlr:GetCompanyExecutivesEx($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	let $companyName := $request/CompanyName/text()
	let $companyID := $request/CompanyID/text()
	let $titleType := $request/TitleType/text()
	return company:GetCompanyExecutivesEx($companyName,$companyID,$titleType)
};

declare function company-ctlr:GetGeneralCounsel($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	let $companyName := $request/CompanyName/text()
	let $companyID := $request/CompanyID/text()
	let $titleType := $request/TitleType/text()
	return company:GetGeneralCounsel($companyName ,$companyID ,$titleType)
};

declare function company-ctlr:GetCompanyGCContacts($params as element(util:params))
{
	company:GetCompanyGCContacts($params/util:companyID/text(), $params/util:scopeID/text())
};

declare function company-ctlr:GetCompanyLFRSummary($params as element(util:params))
{
	company:GetCompanyLFRSummary($params/util:level1/text(),$params/util:level2/text())
};

declare function company-ctlr:IsCompanyExist($params as element(util:params))
{
	company:IsCompanyExist($params/util:scopeID/text())
};

declare function company-ctlr:GetCompanyLFR($params as element(util:params))
{
	company:GetCompanyLFR($params/util:scopeID/text(),$params/util:representationIDs/text(),$params/util:yearFrom/text(),$params/util:yearTo/text())
};

declare function company-ctlr:GetCompanyProfileLawFirmRepresentationsDB($params as element(util:params))
{
	company:GetCompanyProfileLawFirmRepresentationsDB($params/util:scopeID/text(),$params/util:representationIDs/text(),$params/util:yearFrom/text(),$params/util:yearTo/text(),$params/util:companyID/text())
};

declare function company-ctlr:GetCompanyLFRSummaryEx($params as element(util:params))
{
	company:GetCompanyLFRSummaryEx($params/util:scopeID,$params/util:yearFrom,$params/util:yearTo,$params/util:RepresentationIDs)
};

declare function company-ctlr:GetAllIndustries($params as element(util:params))
{
	company:GetAllIndustries()
};

declare function company-ctlr:GetDistinctLocation($params as element(util:params))
{
	company:GetDistinctLocation($params/util:usRegion)
};

declare function company-ctlr:GetLevel1level2RepresntationID($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	let $result := fn:string-join(company:GetLevel1level2RepresntationID($request/PracticeAreas/text()),',')
	
	return json:to-array($result) (:fn:string-join(company:GetLevel1level2RepresntationID($request/PracticeAreas/text()),','):)
};


declare function company-ctlr:getDirectoryCount($params as element(util:params))
{         
  let $count := if($params/util:dir/text() ne '') then company:getDirectoryCount($params/util:dir/text()) else 0
  return $count 
};

(:declare function company-ctlr:GetFileName($params as element(util:params))
{
	company:GetFileName($params/util:companyID/text(),$params/util:format/text())
};:)

declare function company-ctlr:GetCompanySearchResult($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	let $companyIDs := $request/CompanyID/text()
	let $companyNames := $request/CompanyName/text()
	let $industries := $request/Industry/text()
	let $locations := $request/Locations/text()
	let $maxNoOfEmployees1 := $request/NoOfEmployees/text()
	let $revenueSize1 := $request/Revenue/text()
	let $representationIDs := $request/Representations/text()
	let $practiceArea := $request/PracticeAreas/text()
	let $pageNo := $request/PageNo/text()
    let $pageSize := $request/PageSize/text()
    let $sortBy := $request/SortBy/text()
    let $sortDirection := $request/SortDirection/text()
	let $CompanyAlphabetValue := $request/CompanyAlphabetValue/text()
	let $georegions := $request/geographicregions/text()
	let $usregions := $request/usregions/text()
	let $cities := $request/cities/text()
	let $state := $request/states/text()
	let $country := $request/countries/text()
	let $firmSearchKey := $request/FirmSearchKeys/text()
	let $MansfieldRuleParticipant := $request/MansfieldRuleParticipant/text()
	let $maxNoOfEmployees := if(fn:contains($maxNoOfEmployees1,'All Sizes') or fn:contains($maxNoOfEmployees1,'Any')) then () else $maxNoOfEmployees1
	let $revenueSize := if(fn:contains($revenueSize1,'All Revenue Amounts') or fn:contains($revenueSize1,'Any')) then () else $revenueSize1
	
    return company:GetCompanySearchResult($companyIDs,$companyNames,$industries,$locations,$maxNoOfEmployees,$revenueSize,$representationIDs,$practiceArea,$pageNo,$pageSize,$sortBy,$sortDirection,$CompanyAlphabetValue,$georegions,$usregions,$cities,$state,$country,$firmSearchKey,$MansfieldRuleParticipant)
	
};
declare function company-ctlr:DeleteRecord($params as element(util:params))
{   
  let $request := xdmp:get-request-body()/request
  let $directoryPath := $request/DirectoryPath/text()
  let $idS := $request/ID/text()
  let $_ := xdmp:document-delete(fn:concat($directoryPath,$idS,'.xml'))
  return "1"
};

declare function company-ctlr:DeleteDirectory($params as element(util:params))
{   
  let $request := xdmp:get-request-body()/request
  let $directoryPath := $request/DirectoryPath/text()
  let $to := $request/To/text()
  
  return company:DeleteDirectory($directoryPath,$to)
};

declare function company-ctlr:GetFileName($params as element(util:params))
{
	company:GetFileName($params/util:companyID/text(),$params/util:format/text())
};

declare function company-ctlr:IsCompanyExists($params as element(util:params))
{
	company:IsCompanyExists($params/util:scopeID/text())
};

declare function company-ctlr:GetCompanyIdByScopeId($params as element(util:params))
{
	company:GetCompanyIdByScopeId($params/util:scopeID/text() , $params/util:companyName/text())
};

declare function company-ctlr:GetCompanyLFRPacer($params as element(util:params))
{
	company:GetCompanyLFRPacer($params/util:scopeID/text(),$params/util:representationIDs/text(),$params/util:yearFrom/text(),$params/util:yearTo/text(),$params/util:SortBy/text(),$params/util:SortDirection/text(),$params/util:PageNo/text(),$params/util:PageSize/text())
};

declare function company-ctlr:GetDirectoryCountByPID($params as element(util:params))
{ 
  let $directoryPath := $params/util:DirectoryPath/text()
  let $start := $params/util:start/text()
  let $end := $params/util:end/text()
  
  
  return company:GetDirectoryCountByPID($directoryPath,$start,$end)
};

declare function company-ctlr:DeleteNewsDocuments($params as element(util:params))
{ 
  let $request := xdmp:get-request-body()/request
  let $entryID := $request/EntryID/text()
  
  
  return company:DeleteNewsDocuments($entryID)
};

declare function company-ctlr:GetCompanyLFRPacer1($params as element(util:params))
{
	company:GetCompanyLFRPacer1($params/util:scopeID/text(),$params/util:representationIDs/text(),$params/util:yearFrom/text(),$params/util:yearTo/text(),$params/util:SortBy/text(),$params/util:SortDirection/text(),$params/util:PageNo/text(),$params/util:PageSize/text())
};

declare function company-ctlr:GetCompanyLFRPacer2($params as element(util:params))
{
	company:GetCompanyLFRPacer2($params/util:scopeID/text(),$params/util:representationIDs/text(),$params/util:yearFrom/text(),$params/util:yearTo/text(),$params/util:SortBy/text(),$params/util:SortDirection/text(),$params/util:PageNo/text(),$params/util:PageSize/text(),$params/util:Representation/text())
};

declare function company-ctlr:GetCompanyLFRSummaryNew($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	return company:GetCompanyLFRSummaryNew($request/Level1/text(),$request/Level2/text())
};

declare function company-ctlr:GetCompanyProfileLawFirmRepresentationsDB1($params as element(util:params))
{
	company:GetCompanyProfileLawFirmRepresentationsDB1($params/util:scopeID/text(),$params/util:representationIDs/text(),$params/util:yearFrom/text(),$params/util:yearTo/text(),$params/util:companyID/text())
};

declare function company-ctlr:GetCompanySearchIDs($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	let $companyIDs := $request/CompanyID/text()
	let $companyNames := $request/CompanyName/text()
	let $industries := $request/Industry/text()
	let $locations := $request/Locations/text()
	let $maxNoOfEmployees1 := $request/NoOfEmployees/text()
	let $revenueSize1 := $request/Revenue/text()
	let $representationIDs := $request/Representations/text()
	let $practiceArea := $request/PracticeAreas/text()
	let $pageNo := $request/PageNo/text()
    let $pageSize := $request/PageSize/text()
    let $sortBy := $request/SortBy/text()
    let $sortDirection := $request/SortDirection/text()
	let $CompanyAlphabetValue := $request/CompanyAlphabetValue/text()
	let $georegions := $request/geographicregions/text()
	let $usregions := $request/usregions/text()
	let $cities := $request/cities/text()
	let $state := $request/states/text()
	let $country := $request/countries/text()
	let $firmSearchKey := $request/FirmSearchKeys/text()
	let $maxNoOfEmployees := if(fn:contains($maxNoOfEmployees1,'All Sizes') or fn:contains($maxNoOfEmployees1,'Any')) then () else $maxNoOfEmployees1
	let $revenueSize := if(fn:contains($revenueSize1,'All Revenue Amounts') or fn:contains($revenueSize1,'Any')) then () else $revenueSize1
	let $MansfieldRuleParticipant := $request/MansfieldRuleParticipant/text()

    return company:GetCompanySearchIDs($companyIDs,$companyNames,$industries,$locations,$maxNoOfEmployees,$revenueSize,$representationIDs,$practiceArea,$pageNo,$pageSize,$sortBy,$sortDirection,$CompanyAlphabetValue,$georegions,$usregions,$cities,$state,$country,$firmSearchKey,$MansfieldRuleParticipant)
	
};