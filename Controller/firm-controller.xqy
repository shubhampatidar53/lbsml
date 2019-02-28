xquery version '1.0-ml';

module namespace firm-ctlr = 'http://alm.com/controller/firm';

import module namespace firm = 'http://alm.com/firm' at '/common/model/firm.xqy';
import module namespace firm_shubham = 'http://alm.com/firm_2' at '/common/model/firm_shubhamp.xqy';
import module namespace topic = 'http://alm.com/topic' at '/common/model/topic.xqy';
import module namespace firmstatics = 'http://alm.com/firm-statics' at '/common/model/firm-statics.xqy';

declare namespace util = 'http://alm.com/util';

declare option xdmp:mapping 'false';


declare function firm-ctlr:GeLawFirmProfileNews($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	
	let $fromDate := $request/FromDate/text()
	let $toDate := $request/ToDate/text()
	let $ALIFirmId := $request/ALIFirmId/text()
	let $Source := $request/Source/text()
	let $Keywords := $request/Keywords/text()
	let $IsGetFullData := $request/IsGetFullData/text()

	return firm:GeLawFirmProfileNews(
		 $fromDate
		,$toDate
		,$ALIFirmId
		,$Source
		,$Keywords
		,$IsGetFullData
	)
};

declare function firm-ctlr:IsNewsExists($params as element(util:params))
{
	firm:IsNewsExists(
		 firm-ctlr:required($params/util:firmID, 'firmID')
	)
};

declare function firm-ctlr:sp_GetLawFirmStatics_LawSchool1($params as element(util:params))
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

	let $FirmLocation := $request/FirmLocation
	let $Cities := $FirmLocation/Cities/text()
	let $States := $FirmLocation/States/text()
	let $Countries := $FirmLocation/Countries/text()
	let $GeoGraphicRegions := $FirmLocation/GeoRegions/text()
	let $UsRegions := $FirmLocation/UsRegions/text()
	
	return firm:sp_GetLawFirmStatics_LawSchool1(
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
	)
};

declare function firm-ctlr:sp_GetLawFirmStatics_LawSchoolTest($params as element(util:params))
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

	let $FirmLocation := $request/FirmLocation
	let $Cities := $FirmLocation/Cities/text()
	let $States := $FirmLocation/States/text()
	let $Countries := $FirmLocation/Countries/text()
	let $GeoGraphicRegions := $FirmLocation/GeoRegions/text()
	let $UsRegions := $FirmLocation/UsRegions/text()
	
	return firm:sp_GetLawFirmStatics_LawSchoolTest(
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
	)
};

declare function firm-ctlr:GetClientResultChart($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	
	let $FirmID := $request/FirmID/text()
	let $Representations := $request/Representations/text()
	let $YearFrom := $request/YearFrom/text()
	let $YearTo := $request/YearTo/text()
	let $SortBy := $request/SortBy/text()
	let $SortDirection := $request/SortDirection/text()

	return firm:GetClientResultChartPostMerger(
		 $FirmID
		,$Representations
		,$YearFrom
		,$YearTo
	)
};

declare function firm-ctlr:GetLateralPartnerPracticeAdd($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	let $OrganisationID := $request/OrganisationID/text()
	let $Title := $request/Title/text()
	let $Interval := if($request//Interval/text() ne '') then if(xs:integer($request//Interval/text()) gt 5) then $request//Interval/text() else 5 else ''

	return firm:GetLateralPartnerPracticeAddPostMerger(
		 $OrganisationID
		,$Title
		,$Interval
	)
};

declare function firm-ctlr:GetLawyerMoveStats($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	let $FirmID := $request/FirmID/text()
	let $title := $request/title/text()
	let $Interval := if($request//Interval/text() ne '') then if(xs:integer($request//Interval/text()) gt 5) then $request//Interval/text() else 5 else ''
	return firm:GetLawyerMoveStatsPostMerger(
		 $FirmID
		,$title
		,$Interval
	)
};

declare function firm-ctlr:GetREIdByOrgId($params as element(util:params))
{
	firm:GetREIdByOrgId(
		firm-ctlr:required($params/util:firmId, 'firmId')
	)
};

declare function firm-ctlr:GetChangesinHeadcountByPractices($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	let $OrganisationID := $request/OrganisationID/text()
	
	return firm:GetChangesinHeadcountByPractices($OrganisationID)
};

declare function firm-ctlr:GetLateralPartnerChanges($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	let $OrganisationID := $request/OrganisationID/text()
	let $Title := $request/Title/text()
	let $Interval := if($request//Interval/text() ne '') then if(xs:integer($request//Interval/text()) gt 5) then $request//Interval/text() else 5 else ''

	return firm:GetLateralPartnerChangesPostMerger($OrganisationID,$Title,$Interval)
};

declare function firm-ctlr:GetLawfirmProfileContacts($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	let $firmIds := $request/FirmID/text()
	let $SortBy := $request/SortBy/text()
	let $SortDirection := $request/SortDirection/text()
	let $position := $request/contacttype/text()
	let $FirmLocation := $request/FirmLocation

	return firm:GetLawfirmProfileContacts(
		 $firmIds
		,$position
		,$FirmLocation
		,$SortBy
		,$SortDirection
	)
};

declare function firm-ctlr:GetFinancialMetrices($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	let $OrganisationID := $request/OrganisationID/text()
	let $StartYear := if ($request/StartYear/text()) then xs:integer($request/StartYear/text()) else 0
	let $EndYear := if ($request/EndYear/text()) then xs:integer($request/EndYear/text()) else 0
	let $IsDisplayGBP := $request/IsDisplayGBP/text()
	return firm:GetFinancialMetricesPostMerger($OrganisationID,$StartYear,$EndYear,$IsDisplayGBP)
};

declare function firm-ctlr:GetProfitPerEquityPartnerChanges($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	let $OrganisationID := $request/OrganisationID/text()
	let $StartYear := if ($request/StartYear/text()) then xs:integer($request/StartYear/text()) else 0
	let $EndYear := if ($request/EndYear/text()) then xs:integer($request/EndYear/text()) else 0
	let $isDisplayGBP := $request/IsDisplayGBP/text()
	let $Interval := $request//Interval/text()

	return firm:GetProfitPerEquityPartnerChangesPostMerger($OrganisationID,$StartYear,$EndYear,$isDisplayGBP,$Interval)
};

declare function firm-ctlr:GetLawfirmProfileTabsDetail($params as element(util:params))
{
	firm:GetLawfirmAvailableData(
		 firm-ctlr:required($params/util:callType, 'callType')
		,firm-ctlr:required($params/util:firmID, 'firmID')
		,firm-ctlr:required($params/util:type, 'type')
	)
};

declare function firm-ctlr:GetCostPerLawyer($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	let $OrganisationID := $request/OrganisationID/text()
	let $OrganisationName := $request/OrganisationName/text()
	let $StartYear := if ($request/StartYear/text()) then xs:integer($request/StartYear/text()) else 0
	let $EndYear := if ($request/EndYear/text()) then xs:integer($request/EndYear/text()) else 0
	let $ChangeType := $request/ChangeType/text()
	let $Title := $request/Title/text()
	let $IsDisplayGBP := $request/IsDisplayGBP/text()
	let $Interval := $request//Interval/text()

	return firm:GetCostPerLawyerPostMerger($OrganisationID,$StartYear,$EndYear,$IsDisplayGBP,$Interval)
};

declare function firm-ctlr:GetCostPerLawyerByYear($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	let $OrganisationID := $request/OrganisationID/text()
	let $OrganisationName := $request/OrganisationName/text()
	let $StartYear := if ($request/StartYear/text()) then xs:integer($request/StartYear/text()) else 0
	let $EndYear := if ($request/EndYear/text()) then xs:integer($request/EndYear/text()) else 0
	let $ChangeType := $request/ChangeType/text()
	let $Title := $request/Title/text()
	let $IsDisplayGBP := $request/IsDisplayGBP/text()
	let $Interval := $request//Interval/text()

	return firm:GetCostPerLawyerByYearPostMerger($OrganisationID,$StartYear,$EndYear,$IsDisplayGBP,$Interval)
};



declare function firm-ctlr:GetCostPerLawyerChange($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	let $OrganisationID := $request/OrganisationID/text()
	let $OrganisationName := $request/OrganisationName/text()
	let $StartYear := if ($request/StartYear/text()) then xs:integer($request/StartYear/text()) else 0
	let $EndYear := if ($request/EndYear/text()) then xs:integer($request/EndYear/text()) else 0
	let $ChangeType := $request/ChangeType/text()
	let $Title := $request/Title/text()
	let $IsDisplayGBP := $request/IsDisplayGBP/text()
	let $Interval := $request//Interval/text()

	return firm:GetCostPerLawyer($OrganisationID,$StartYear,$EndYear,$IsDisplayGBP,$Interval)
};

declare function firm-ctlr:GetLawfirmLocations($params as element(util:params))
{
	firm:GetLawfirmLocations(
		firm-ctlr:required($params/util:firmID, 'firmID')
	)
};

declare function firm-ctlr:GetLawFirmPracticearea($params as element(util:params))
{
	firm:GetLawFirmPracticeareaPostMerger(
		firm-ctlr:required($params/util:firmID, 'firmID')
	)
};

declare function firm-ctlr:GetLawfirmProfileRankings($params as element(util:params))
{
	firm:GetLawfirmProfileRankingsPostMerger(
		firm-ctlr:required($params/util:firmId, 'firmId')
	)
};

declare function firm-ctlr:GetLawfirmProfileDetail($params as element(util:params))
{
	(:firm:GetLawfirmProfileDetail(
		firm-ctlr:required($params/util:firmID/text(), 'firmID')
	):)
	
	firm:GetLawfirmProfileDetail($params/util:callType/text(),$params/util:firmID/text(),$params/util:type/text())
	
};

declare function firm-ctlr:GetLawfirmRevenueHeadCountChart($params as element(util:params))
{
	firm:GetLawfirmRevenueHeadCountChartPostMerger(
		 firm-ctlr:required($params/util:firmId, 'firmId')
		,firm-ctlr:required($params/util:type, 'type')
	)
};

(: declare function firm-ctlr:sp_GetLawFirmStatics_Formattednew1($params as element(util:params))
{
	firm:sp_GetLawFirmStatics_Formattednew1(
		 firm-ctlr:required($params/util:pageNo, 'pageNo')
		,firm-ctlr:required($params/util:recordsPerPage, 'recordsPerPage')
		,firm-ctlr:required($params/util:firmIds, 'firmIds')
	)
}; :)

declare function firm-ctlr:GetRevenueByYear($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	let $OrganisationID := $request//OrganisationID/text()
	let $IsDisplayGBP := $request//IsDisplayGBP/text()
	let $Interval := $request//Interval/text()

	return firm:GetRevenueByYearPostMerger($OrganisationID,$IsDisplayGBP,$Interval)
};

declare function firm-ctlr:GetProfitMargin($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	let $OrganisationID := $request/OrganisationID/text()
	let $IsDisplayGBP := $request/IsDisplayGBP/text()
	let $Interval := $request//Interval/text()
	return firm:GetProfitMarginPostMerger($OrganisationID,$IsDisplayGBP,$Interval)
};

declare function firm-ctlr:GetRevenuePerLawyerByYear($params as element(util:params))
{
	firm:GetRevenuePerLawyerByYearPostMerger()
};

declare function firm-ctlr:GetProfitLawyer($params as element(util:params))
{
	firm:GetProfitLawyerPostMerger()
};

declare function firm-ctlr:GetProfitPerEqityPartner($params as element(util:params))
{
	
	 firm:GetProfitPerEqityPartnerPostMerger()
};

declare function firm-ctlr:GetProfitLawyerChanges($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	return firm:GetProfitLawyerPostMerger()
};

declare function firm-ctlr:GetTotalHeadCount($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	return firm:GetTotalHeadCountPostMerger($request)
};

declare function firm-ctlr:GetChangesinHeadcountByLocation($params as element(util:params))
{
	firm:GetChangesinHeadcountByLocationPostMerger()
};

declare function firm-ctlr:GetHeadCountPercentage($params as element(util:params))
{
	firm:GetHeadCountPercentagePostMerger()
};

declare function firm-ctlr:GetFirmStaffingDiversityMetrics($params as element(util:params))
{
	firm:GetFirmStaffingDiversityMetricsPostMerger()
};

declare function firm-ctlr:GetDiversityPartnerPieChart($params as element(util:params))
{
	firm:GetDiversityPartnerPieChartPostMerger()
};

declare function firm-ctlr:GetDiversityGrowth($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	let $OrganisationID := $request/OrganisationID/text()
	let $Interval := if($request//Interval/text() ne '') then if(xs:integer($request//Interval/text()) gt 5) then $request//Interval/text() else 5 else ''
	return firm:GetDiversityGrowthPostMerger($OrganisationID,$Interval)
};

declare function firm-ctlr:GetRevenueChanges($params as element(util:params))
{
	firm:GetRevenueChangesPostMerger()
};

declare function firm-ctlr:GetRevenuePerLawyerChanges($params as element(util:params))
{
	firm:GetRevenuePerLawyerChangesPostMerger()
};

declare function firm-ctlr:GetGrowthTotalHeadCount($params as element(util:params))
{
	firm:GetGrowthTotalHeadCountPostMerger()
};

declare function firm-ctlr:GetGrowthinAssociateandPartners($params as element(util:params))
{
	firm:GetGrowthinAssociateandPartnersPostMerger()
};

declare function firm-ctlr:GetGenderBreakdown($params as element(util:params))
{
	firm:GetGenderBreakdownPostMerger()
};

declare function firm-ctlr:GetGrowthInGenderDiversity($params as element(util:params))
{
	firm:GetGrowthInGenderDiversityPostMerger()
};

declare function firm-ctlr:GetLeverage($params as element(util:params))
{
	firm:GetLeveragePostMerger()
};

declare function firm-ctlr:GetChangesinHeadcountByYear($params as element(util:params))
{
	firm:GetChangesinHeadcountByYearPostMerger()
};

declare function firm-ctlr:GetLawFirmGlobalMapALI($params as element(util:params))
{
	firm:GetLawFirmGlobalMapALI()
};

declare function firm-ctlr:GetTotalIndustrybyId($params as element(util:params))
{
	(:let $request := xdmp:get-request-body()/request
	let $OrganisationID := $request/OrganisationID/text():)
	
	firm:GetTotalIndustrybyId(
	firm-ctlr:required($params/util:organization_id, 'organization_id')
	)
	
};

declare function firm-ctlr:GetFirmReports($params as element(util:params))
{
	firm:GetLawfirmReports(
		 firm-ctlr:required($params/util:organization_id, 'organization_id')
	)
};

declare function firm-ctlr:GetClients($params as element(util:params))
{
	(:firm:GetClients(
		 firm-ctlr:required($params/util:firmID, 'firmID'),
		 firm-ctlr:required($params/util:fromYear, 'fromYear'),
		 firm-ctlr:required($params/util:toYear, 'toYear')
	):)
	firm:GetClients()
};

declare function firm-ctlr:GetLateralPartnerMoves($params as element(util:params))
{
	firm:GetLateralPartnerMovesPostMerger()
};

declare function firm-ctlr:GetLawfirmContactsAdded($params as element(util:params))
{
	firm:GetLawfirmContactsAdded()
};

declare function firm-ctlr:GetOfficeTrendsMap($params as element(util:params))
{
	json:to-array(firm:GetOfficeTrendsMap())
};	

declare function firm-ctlr:GetOfficeTrendsDataAnalysis($params as element(util:params))
{
	json:to-array(firm:GetOfficeTrendsDataAnalysis())
};	

declare function firm-ctlr:GetOfficeTrendsDataAnalysis_Merged($params as element(util:params))
{
	json:to-array(firm:GetOfficeTrendsDataAnalysis_Merged())
};	


declare function firm-ctlr:SP_GETOFFICETRENDSURVEYDATA($params as element(util:params))
{
	json:to-array(firm:SP_GETOFFICETRENDSURVEYDATA())
};	

declare function firm-ctlr:GetLawFirmProfileNews($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	
	let $toDate := $request/ToDate/text()
	let $fromDate := $request/FromDate/text()

	 let $toDate := if(count(fn:tokenize($toDate,'T')) > 1) then $toDate 
					else fn:concat($toDate,'T00:00:00')

	let $fromDate := if(count(fn:tokenize($fromDate,'T')) > 1) then $fromDate 
					else fn:concat($fromDate,'T00:00:00')
	(:let $toDate-Time := fn:tokenize($toDate,'T')[1]
	let $fromDate-Time := fn:tokenize($fromDate,'T')[1]:)

	let $toDate-Time := xs:dateTime($toDate)
	let $fromDate-Time := xs:dateTime($fromDate)
	let $FIRMID := $request/ALIFirmId/text() (: '295':)
	let $Source := $request/Source/text() (: '295':)
	
	return firm:GetLawFirmProfileNews(
		 $toDate
		,$fromDate
		,$toDate-Time
		,$fromDate-Time
		,$FIRMID
		,$Source
	)
};

declare function firm-ctlr:GetLawFirmGlobalMapByPractices($params as element(util:params))
{
	json:to-array(firm:GetLawFirmGlobalMapByPractices())
};

declare function firm-ctlr:GetALIIdByREId($params as element(util:params))
{
	firm:GetALIIdByREId(
		 firm-ctlr:required($params/util:FirmID, 'REId')
	)
};

declare function firm-ctlr:required($value as item()*, $parameter as xs:string) as item()*
{
    if (fn:exists($value)) then
        $value
    else
        fn:error(xs:QName('MISSINGPARAM'), fn:concat('Required param '', $parameter, '' is missing'))
};

declare function firm-ctlr:sp_GetLawFirmStaticsPracticeChangesByFirm($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	let $cities := $request/cities/text()
	let $countries := $request/countries/text()
	let $geoGraphicRegion := $request/geographicregions/text()
	let $usRegions := $request/usregions/text()
	let $practiceArea := $request/practiceAreas/text()
	let $firmID := $request/firmIds/text()
	let $fromDate := $request/fromDate/text()
	let $toDate := $request/toDate/text()
	
	return firmstatics:sp_GetLawFirmStaticsPracticeChangesByFirm($cities,$countries,$geoGraphicRegion,$usRegions,$practiceArea,$firmID,$fromDate,$toDate)
	
};

declare function firm-ctlr:sp_GetLawFirmStaticsChangesByFirm1($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	let $cities := $request/cities/text()
	let $countries := $request/countries/text()
	let $geoGraphicRegion := $request/geographicregions/text()
	let $usRegions := $request/usregions/text()
	let $practiceArea := $request/practiceAreas/text()
	let $firmID := $request/firmIds/text()
	let $fromDate := fn:tokenize($request/fromDate/text(),'T')[1]
	let $toDate := fn:tokenize($request/toDate/text(),'T')[1]
	let $firmSizefrom := $request/firmSizefrom/text()
	let $firmSizeTo := $request/firmSizeTo/text()
	
	return firmstatics:sp_GetLawFirmStaticsChangesByFirm1($cities,$countries,$geoGraphicRegion,$usRegions,$practiceArea,$firmID,$fromDate,$toDate,$firmSizefrom,$firmSizeTo)
	
};

declare function firm-ctlr:sp_GetLawFirmStaticsByPracticenew1($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	let $cities := $request/cities/text()
	let $countries := $request/countries/text()
	let $geoGraphicRegion := $request/geographicregions/text()
	let $usRegions := $request/usregions/text()
	let $practiceArea := $request/practiceAreas/text()
	let $firmID := $request/firmIds/text()
	let $fromDate := $request/fromDate/text()
	let $toDate := $request/toDate/text()

	return firmstatics:sp_GetLawFirmStaticsByPracticenew1($cities,$countries,$geoGraphicRegion,$usRegions,$practiceArea,$firmID,$fromDate,$toDate)
	
};

declare function firm-ctlr:GetAdvancedFirmSearchYears($params as element(util:params))
{
	firm:GetAdvancedFirmSearchYears()
};

declare function firm-ctlr:GetTopicAndFields($params as element(util:params))
{
	json:to-array(topic:GetTopicAndFields())
};

declare function firm-ctlr:sp_GetLawFirmStaticsByPracticenew2($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	let $cities := $request/cities/text()
	let $firmLocation := $request/FirmLocation
	let $state := $firmLocation/States/text()
	let $countries := $request/countries/text()
	let $geoGraphicRegion := $request/geographicregions/text()
	let $usRegions := $request/usregions/text()
	let $practiceArea := $request/practiceAreas/text()
	let $firmID := $request/firmIds/text()
	let $fromDate := fn:tokenize($request/fromDate/text(),'T')[1]
	let $toDate := fn:tokenize($request/toDate/text(),'T')[1]
	let $pageNo := $request/PageNo/text()
    let $pageSize := $request/PageSize/text()
	let $firmSizefrom := $request/firmSizefrom/text()
	let $firmSizeTo := $request/firmSizeTo/text()
	let $isHeadquarter := $request/isHeadquarter/text()
	let $isPrimaryPracticeArea := $request/isPrimaryPracticeArea/text()
	let $state := fn:string-join($state,',')
	

	return firmstatics:sp_GetLawFirmStaticsByPracticenew2($cities,$countries,$geoGraphicRegion,$usRegions,$practiceArea,$firmID,$fromDate,$toDate,$pageNo,$pageSize,$firmSizefrom,$firmSizeTo,$state,$isPrimaryPracticeArea,$isHeadquarter)
	
};

declare function firm-ctlr:sp_GetLawFirmStaticsCount3($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	let $cities := $request/cities/text()
	let $countries := $request/countries/text()
	let $geoGraphicRegion := $request/geographicregions/text()
	let $usRegions := $request/usregions/text()
	let $practiceArea := $request/practiceAreas/text()
	let $firmID := $request/firmIds/text()
	let $fromDate := fn:tokenize($request/fromDate/text(),'T')[1]
	let $toDate := fn:tokenize($request/toDate/text(),'T')[1]
	let $firmSizefrom := $request/firmSizefrom/text()
	let $firmSizeTo := $request/firmSizeTo/text()

	return firmstatics:sp_GetLawFirmStaticsCount3_1($cities,$countries,$geoGraphicRegion,$usRegions,$practiceArea,$firmID,$fromDate,$toDate,$firmSizefrom,$firmSizeTo)
	
};

declare function firm-ctlr:sp_GetLawFirmStaticsCount3_1($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	let $cities := $request/cities/text()
	let $countries := $request/countries/text()
	let $geoGraphicRegion := $request/geographicregions/text()
	let $usRegions := $request/usregions/text()
	let $practiceArea := $request/practiceAreas/text()
	let $firmID := $request/firmIds/text()
	let $fromDate := fn:tokenize($request/fromDate/text(),'T')[1]
	let $toDate := fn:tokenize($request/toDate/text(),'T')[1]
	let $firmSizefrom := $request/firmSizefrom/text()
	let $firmSizeTo := $request/firmSizeTo/text()

	return firmstatics:sp_GetLawFirmStaticsCount3_1($cities,$countries,$geoGraphicRegion,$usRegions,$practiceArea,$firmID,$fromDate,$toDate,$firmSizefrom,$firmSizeTo)
	
};


declare function firm-ctlr:sp_GetLawFirmStaticsPracticeChangesByFirm1($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	let $cities := $request/cities/text()
	let $countries := $request/countries/text()
	let $geoGraphicRegion := $request/geographicregions/text()
	let $usRegions := $request/usregions/text()
	let $practiceArea := $request/practiceAreas/text()
	let $firmID := $request/firmIds/text()
	let $fromDate := fn:tokenize($request/fromDate/text(),'T')[1]
	let $toDate := fn:tokenize($request/toDate/text(),'T')[1]
	let $firmSizefrom := $request/firmSizefrom/text()
	let $firmSizeTo := $request/firmSizeTo/text()
	
	return firmstatics:sp_GetLawFirmStaticsPracticeChangesByFirm1($cities,$countries,$geoGraphicRegion,$usRegions,$practiceArea,$firmID,$fromDate,$toDate,$firmSizefrom,$firmSizeTo)
	
};

declare function firm-ctlr:GetREIdByOrgId3($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	return firm:GetREIdByOrgId3($request/AliID/text())
};

declare function firm-ctlr:GetReIDByOrgID1($params as element(util:params))
{
	firm:GetReIDByOrgID1($params/util:OrgID)
};

declare function firm-ctlr:SP_GETAMLAW200FIRMS($params as element(util:params))
{
	firm:SP_GETAMLAW200FIRMS()
};

declare function firm-ctlr:SP_GETFIRMREVENUECHANGE($params as element(util:params))
{
	firm:SP_GETFIRMREVENUECHANGE($params/util:startYear/text(),$params/util:endYear/text(),$params/util:organizationID/text())
};

declare function firm-ctlr:SP_GETFIRMRPLCHANGE($params as element(util:params))
{
	firm:SP_GETFIRMRPLCHANGE($params/util:startYear/text(),$params/util:endYear/text(),$params/util:organizationID/text())
};

declare function firm-ctlr:SP_FIRMCOSTPERLAWYER($params as element(util:params))
{
	firm:SP_FIRMCOSTPERLAWYER($params/util:startYear/text(),$params/util:endYear/text(),$params/util:organizationID/text())
};

declare function firm-ctlr:SP_FIRMPROFITPERPARTNER($params as element(util:params))
{
	firm:SP_FIRMPROFITPERPARTNER($params/util:startYear/text(),$params/util:endYear/text(),$params/util:organizationID/text())
};

declare function firm-ctlr:SP_FIRMLGBTAttorneys($params as element(util:params))
{
	firm:SP_FIRMLGBTAttorneys($params/util:startYear/text(),$params/util:endYear/text(),$params/util:organizationID/text())
};

declare function firm-ctlr:SP_FIRMFemaleAttorneys($params as element(util:params))
{
	firm:SP_FIRMFemaleAttorneys($params/util:startYear/text(),$params/util:endYear/text(),$params/util:organizationID/text())
};

declare function firm-ctlr:SP_GETFIRMLEVERAGE($params as element(util:params))
{
	firm:SP_GETFIRMLEVERAGE($params/util:startYear/text(),$params/util:endYear/text(),$params/util:organizationID/text())
};

declare function firm-ctlr:GetFirmProfitMargin($params as element(util:params))
{
	firm:GetFirmProfitMargin($params/util:startYear/text(),$params/util:endYear/text(),$params/util:organizationID/text())
};

declare function firm-ctlr:IsAnalysis($params as element(util:params))
{
	firm:IsAnalysis($params/util:firmID/text())
};

declare function firm-ctlr:MedianQuery($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	let $column1 := $request/VariableX/text()
	let $column2 := $request/VariableY/text()
	return firm:MedianQuery($column1,$column2)
};

declare function firm-ctlr:CombinedQuery($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	let $organizationIDs := $request/CombinedFirmIDs/text()
	let $column1 := $request/VariableX/text()
	let $column2 := $request/VariableY/text()
	return firm:CombinedQuery($organizationIDs,$column1,$column2)
};

declare function firm-ctlr:SP_GETFIRMPERFORMANCESCORE1($params as element(util:params))
{
	firm:SP_GETFIRMPERFORMANCESCORE1($params/util:primaryFirmID/text(),$params/util:firmID/text(),$params/util:watchlistname/text())
};

declare function firm-ctlr:GetPracticeAreaFromLawFirm($params as element(util:params))
{
	firm:GetPracticeAreaFromLawFirm($params/util:firmID/text())
};

declare function firm-ctlr:GetOrganizations($params as element(util:params))
{
	firm:GetOrganizations($params/util:OrgID)
};

declare function firm-ctlr:sp_GetLawyerCountByStatePractice($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	
	let $state := $request/states/text()
	let $cities := $request/cities/text()
	let $gRegions := $request/geographicregions/text()
	let $uRegions := $request/usregions/text()
	let $practiseAreas := $request/practiceAreas/text()
	let $firmIDs := $request/FirmIds/text()
	let $fromDate := fn:tokenize($request/FromDate/text(),'T')[1]
	let $toDate := fn:tokenize($request/ToDate/text(),'T')[1]
	let $title := $request/Titles/text()
	let $changeType := $request/changeType/text()
	
	return firm:sp_GetLawyerCountByStatePractice($state,$cities,$gRegions,$uRegions,$practiseAreas,$firmIDs,$fromDate,$toDate,$title,$changeType)
};

declare function firm-ctlr:GetReNews($params as element(util:params))
{
	firm:GetReNews($params/util:companyID/text(),fn:tokenize($params/util:fromDate/text(),'T')[1],fn:tokenize($params/util:toDate/text(),'T')[1])
};

declare function firm-ctlr:sp_GetLawFirmStatics_LawSchool2($params as element(util:params))
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

	let $FirmLocation := $request/FirmLocation
	let $Cities := $FirmLocation/Cities/text()
	let $States := $FirmLocation/States/text()
	let $Countries := $FirmLocation/Countries/text()
	let $GeoGraphicRegions := $FirmLocation/GeoRegions/text()
	let $UsRegions := $FirmLocation/UsRegions/text()
	
	return firm_shubham:sp_GetLawFirmStatics_LawSchool2(
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
	)
};

declare function firm-ctlr:sp_GetLawFirmStatics_LawSchool3($params as element(util:params))
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

	let $FirmLocation := $request/FirmLocation
	let $Cities := $FirmLocation/Cities/text()
	let $States := $FirmLocation/States/text()
	let $Countries := $FirmLocation/Countries/text()
	let $GeoGraphicRegions := $FirmLocation/GeoRegions/text()
	let $UsRegions := $FirmLocation/UsRegions/text()
	
	return firm_shubham:sp_GetLawFirmStatics_LawSchool3(
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
	)
};

declare function firm-ctlr:sp_GetLawFirmStatics_LawSchool4($params as element(util:params))
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

	let $FirmLocation := $request/FirmLocation
	let $Cities := $FirmLocation/Cities/text()
	let $States := $FirmLocation/States/text()
	let $Countries := $FirmLocation/Countries/text()
	let $GeoGraphicRegions := $FirmLocation/GeoRegions/text()
	let $UsRegions := $FirmLocation/UsRegions/text()
	
	return firm_shubham:sp_GetLawFirmStatics_LawSchool4(
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
	)
};

declare function firm-ctlr:sp_GetLawFirmStaticsPracticeChangesByFirm2($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	let $cities := $request/cities/text()
	let $countries := $request/countries/text()
	let $geoGraphicRegion := $request/geographicregions/text()
	let $usRegions := $request/usregions/text()
	let $practiceArea := $request/practiceAreas/text()
	let $firmID := $request/firmIds/text()
	let $fromDate := fn:tokenize($request/fromDate/text(),'T')[1]
	let $toDate := fn:tokenize($request/toDate/text(),'T')[1]
	let $firmSizefrom := $request/firmSizefrom/text()
	let $firmSizeTo := $request/firmSizeTo/text()
	
	return firmstatics:sp_GetLawFirmStaticsPracticeChangesByFirm2($cities,$countries,$geoGraphicRegion,$usRegions,$practiceArea,$firmID,$fromDate,$toDate,$firmSizefrom,$firmSizeTo)
	
};

declare function firm-ctlr:GetReNews1($params as element(util:params))
{
	firm_shubham:GetReNews1($params/util:companyID/text(),$params/util:fromDate/text(),$params/util:toDate/text(),$params/util:PageNo/text(),$params/util:PageSize/text(),$params/util:sortDirection/text(),$params/util:sortBy/text())
};

declare function firm-ctlr:GetLawfirmLocations1($params as element(util:params))
{
	firm:GetLawfirmLocations1PostMerger($params/util:firmID/text())
};

declare function firm-ctlr:sp_GetLawFirmStaticsChart($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	let $cities := $request/cities/text()
	let $countries := $request/countries/text()
	let $geoGraphicRegion := $request/geographicregions/text()
	let $usRegions := $request/usregions/text()
	let $practiceArea := $request/practiceAreas/text()
	let $firmID := $request/firmIds/text()
	let $fromDate := fn:tokenize($request/fromDate/text(),'T')[1]
	let $toDate := fn:tokenize($request/toDate/text(),'T')[1]
	let $pageNo := $request/PageNo/text()
    let $pageSize := $request/PageSize/text()
	let $firmSizefrom := $request/firmSizefrom/text()
	let $firmSizeTo := $request/firmSizeTo/text()
	let $firmLocation := $request/FirmLocation
	let $state := $firmLocation/States/text()
	let $isPrimaryPracticeArea := $request/isPrimaryPracticeArea/text()
	let $state := fn:string-join($state,',')
	let $isHeadquarter := $request/isHeadquarter/text()
	return firmstatics:sp_GetLawFirmStaticsChart($cities,$countries,$geoGraphicRegion,$usRegions,$practiceArea,$firmID,$fromDate,$toDate,$pageNo,$pageSize,$firmSizefrom,$firmSizeTo,$state,$isPrimaryPracticeArea,$isHeadquarter)
	
};

declare function firm-ctlr:SP_FIRMRPLBYYEAR($params as element(util:params))
{
	firm:SP_FIRMRPLBYYEAR($params/util:startYear/text(),$params/util:endYear/text(),$params/util:organizationID/text())
};

declare function firm-ctlr:GetFIRMMinorityAttorneys($params as element(util:params))
{
	firm:GetFIRMMinorityAttorneys($params/util:startYear/text(),$params/util:endYear/text(),$params/util:organizationID/text())
};

declare function firm-ctlr:GetOfficeTrendsFirmID($params as element(util:params))
{
	json:to-array(firm:GetOfficeTrendsFirmID())
};	

declare function firm-ctlr:GetLawFirmStaticsFirmID($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	let $cities := $request/cities/text()
	let $firmLocation := $request/FirmLocation
	let $state := $firmLocation/States/text()
	let $countries := $request/countries/text()
	let $geoGraphicRegion := $request/geographicregions/text()
	let $usRegions := $request/usregions/text()
	let $practiceArea := $request/practiceAreas/text()
	let $firmID := $request/firmIds/text()
	let $fromDate := fn:tokenize($request/fromDate/text(),'T')[1]
	let $toDate := fn:tokenize($request/toDate/text(),'T')[1]
	let $pageNo := $request/PageNo/text()
    let $pageSize := $request/PageSize/text()
	let $firmSizefrom := $request/firmSizefrom/text()
	let $firmSizeTo := $request/firmSizeTo/text()
	let $isHeadquarter := $request/isHeadquarter/text()
	let $isPrimaryPracticeArea := $request/isPrimaryPracticeArea/text()
	let $state := fn:string-join($state,',')
	

	return firmstatics:GetLawFirmStaticsFirmID($cities,$countries,$geoGraphicRegion,$usRegions,$practiceArea,$firmID,$fromDate,$toDate,$pageNo,$pageSize,$firmSizefrom,$firmSizeTo,$state,$isPrimaryPracticeArea,$isHeadquarter)
	
};