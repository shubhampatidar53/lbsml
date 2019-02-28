xquery version '1.0-ml';

module namespace firmnew-ctlr = 'http://alm.com/controller/firmnew';

import module namespace firm = 'http://alm.com/firm' at '/common/model/firm.xqy';
import module namespace firm1 = 'http://alm.com/firm_2' at '/common/model/firm_shubhamp.xqy';
import module namespace firmnew = 'http://alm.com/firmnew' at '/common/model/firmnew.xqy';

declare namespace util = 'http://alm.com/util';

declare option xdmp:mapping 'false';


declare function firmnew-ctlr:GetFirmRankingsAdvance($params as element(util:params))
{
	
	firmnew:GetFirmRankingsAdvance()
};

declare function firmnew-ctlr:GetTop5LawSchools($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	
	let $PageNo := $request/PageNo/text()
	let $PageSize := $request/PageSize/text()
	let $firmIds := $request/firmIds/text()
	let $practiceAreas := $request/practiceAreas/text()
	let $fromDate := $request/fromDate/text()
	let $toDate := $request/toDate/text()
	let $firmSizefrom := xs:integer($request/firmSizefrom/text())
	let $firmSizeTo := xs:integer($request/firmSizeTo/text())
	let $lawschools := $request/lawschools/text()
	let $sortBy := $request/SortBy/text()
	let $sortDirection := $request/SortDirection/text()
	let $lawSchoolID := $request/LawSchoolID/text()

	let $FirmLocation := $request/FirmLocation
	let $Cities := $FirmLocation/Cities/text()
	let $States := $FirmLocation/States/text()
	let $Countries := $FirmLocation/Countries/text()
	let $GeoGraphicRegions := $FirmLocation/GeoRegions/text()
	let $UsRegions := $FirmLocation/UsRegions/text()
	let $isPrimaryPracticeArea := $request/isPrimaryPracticeArea/text()
	
	return firmnew:GetTop5LawSchools(
		 $PageNo
		,$PageSize
		,$firmIds
		,$practiceAreas
		,$fromDate
		,$toDate
		,$firmSizefrom
		,$firmSizeTo
		,$FirmLocation
		,$Cities
		,$States
		,$Countries
		,$GeoGraphicRegions
		,$UsRegions
		,$lawschools
		,$sortBy
		,$sortDirection
		,$lawSchoolID
		,$isPrimaryPracticeArea
	)
};

declare function firmnew-ctlr:GetLawFirmComparisonResult($params as element(util:params))
{
	firmnew:GetLawFirmComparisonResult($params/util:schoolIDs/text())
};

declare function firmnew-ctlr:GetTopFiveFirms($params as element(util:params))
{
	firmnew:GetTopFiveFirms($params/util:schoolIDs/text())
};

declare function firmnew-ctlr:GetTopFiveCities($params as element(util:params))
{
	firmnew:GetTopFiveCities($params/util:schoolIDs/text())
};

declare function firmnew-ctlr:GetTopFivePracticeAreas($params as element(util:params))
{
	firmnew:GetTopFivePracticeAreas($params/util:schoolIDs/text())
};

declare function firmnew-ctlr:GetPracticeAreasByLawSchoolID($params as element(util:params))
{
	firmnew:GetPracticeAreasByLawSchoolID($params/util:schoolIDs/text(),$params/util:sortBy/text(),$params/util:sortDirection/text())
};

declare function firmnew-ctlr:GetCitiesByLawSchoolID($params as element(util:params))
{
	firmnew:GetCitiesByLawSchoolID($params/util:schoolIDs/text(),$params/util:sortBy/text(),$params/util:sortDirection/text())
};

declare function firmnew-ctlr:GetLawFirmPenetration($params as element(util:params))
{
	firmnew:GetLawFirmPenetration($params/util:schoolIDs/text())
};

declare function firmnew-ctlr:GetAmLawPenetration($params as element(util:params))
{
	firmnew:GetAmLawPenetration($params/util:schoolIDs/text())
};

declare function firmnew-ctlr:GetLawSchoolByFirmID($params as element(util:params))
{
	firmnew:GetLawSchoolByFirmID($params/util:firmID/text())
};

declare function firmnew-ctlr:SP_GCCOMANSATION_GLL($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	
	let $FortuneRankFrom := $request/FortuneRankFrom/text()
	let $FortuneRankTo := $request/FortuneRankTo/text()
	let $IndustryName := $request/IndustryName/text()
	let $StateName := $request/StateName/text()
	let $RevenueRangeFrom := $request/RevenueRangeFrom/text()
	let $RevenueRangeTo := $request/RevenueRangeTo/text()
	
	return  json:to-array(firmnew:SP_GCCOMANSATION_GLL($FortuneRankFrom,$FortuneRankTo,$IndustryName,$StateName,$RevenueRangeFrom,$RevenueRangeTo))
};

declare function firmnew-ctlr:GetClients($params as element(util:params))
{
	firmnew:GetClients()
};

declare function firmnew-ctlr:GetClientChart($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	
	let $FirmID := $request/FirmID/text()
	let $Representations := $request/Representations/text()
	let $YearFrom := $request/YearFrom/text()
	let $YearTo := $request/YearTo/text()
	let $SortBy := $request/SortBy/text()
	let $SortDirection := $request/SortDirection/text()

	return firmnew:GetClientChart(
		 $FirmID
		,$YearFrom
		,$YearTo
		,$Representations
	)
};

declare function firmnew-ctlr:GetProBono($params as element(util:params))
{
	firmnew:GetProBono($params/util:firmID/text())
};

declare function firmnew-ctlr:GetFirmAssociateComp($params as element(util:params))
{
	firmnew:GetFirmAssociateComp($params/util:firmID/text())
};

declare function firmnew-ctlr:GetFirmPartnerComp($params as element(util:params))
{
	firmnew:GetFirmPartnerComp($params/util:firmID/text())
};

declare function firmnew-ctlr:IsFirmExistInUK50($params as element(util:params))
{
	firmnew:IsFirmExistInUK50($params/util:firmID/text())
};

declare function firmnew-ctlr:GetLawFirmMergerData($params as element(util:params))
{
	xs:string(firmnew:GetLawFirmMergerData($params/util:firmID/text()))
};

declare function firmnew-ctlr:GetScoreCardGrossRevenue($params as element(util:params))
{
	firm:GetScoreCardGrossRevenue($params/util:orgID/text(),'')
};

declare function firmnew-ctlr:IsFirmMerged($params as element(util:params))
{
	firmnew:IsFirmMerged($params/util:firmID/text())
};

declare function firmnew-ctlr:SP_GETFIRMHEADCOUNT($params as element(util:params))
{
	firmnew:SP_GETFIRMHEADCOUNTPostMerger($params/util:firmID/text())
};

declare function firmnew-ctlr:IsSurveyFirm($params as element(util:params))
{
	firmnew:IsSurveyFirm($params/util:firmID/text())
};

declare function firmnew-ctlr:GetFirmExportTopicsAndField($params as element(util:params))
{
	firmnew:GetFirmExportTopicsAndField()
};

declare function firmnew-ctlr:SP_GETPRACTICEAREAS($params as element(util:params))
{
	firmnew:SP_GETPRACTICEAREAS()
};

declare function firmnew-ctlr:GetMetroAreas($params as element(util:params))
{
	firmnew:GetMetroAreas()
};

declare function firmnew-ctlr:GetLawFirmMergerData1($params as element(util:params))
{
	json:to-array(firmnew:GetLawFirmMergerData1($params/util:firmID/text()))
};

declare function firmnew-ctlr:GetRepresentationData($params as element(util:params))
{
	firmnew:GetRepresentationData()
};

declare function firmnew-ctlr:GetFirmSearchYears($params as element(util:params))
{
	firmnew:GetFirmSearchYears()
};

declare function firmnew-ctlr:GetFirmList($params as element(util:params))
{
	firmnew:GetFirmList($params/util:firmIds/text())
};

declare function firmnew-ctlr:GetLawFirmMergerDataList($params as element(util:params))
{
	firmnew:GetLawFirmMergerDataList($params/util:firmID/text())
};

declare function firmnew-ctlr:IsFirmMergedForOverview($params as element(util:params))
{
	firmnew:IsFirmMergedForOverview($params/util:firmID/text())
};

declare function firmnew-ctlr:GetMergedFirmData($params as element(util:params))
{
	firmnew:GetMergedFirmData($params/util:firmID/text())
};

declare function firmnew-ctlr:GetLawFirmMergerDataForOverview($params as element(util:params))
{
	xs:string(firmnew:GetLawFirmMergerDataForOverview($params/util:firmID/text()))
};

declare function firmnew-ctlr:GetClientMaxYear($params as element(util:params))
{
	let $FirmID := $params/util:firmID/text()

	return firmnew:GetClientMaxYear(
		 $FirmID
	)
};

declare function firmnew-ctlr:GetClientsCountExport($params as element(util:params))
{
	firmnew:GetClientsCountExport()
};

declare function firmnew-ctlr:GetVolatilityData($params as element(util:params))
{
	let $FirmID := $params/util:firmID/text()

	return firmnew:GetVolatilityData($FirmID)
};

declare function firmnew-ctlr:IsMansfieldFirm($params as element(util:params))
{
	firmnew:IsMansfieldFirm($params/util:firmID/text())
};