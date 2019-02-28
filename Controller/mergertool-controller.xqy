xquery version "1.0-ml";

module namespace mergertool-ctlr = "http://alm.com/controller/mergertool";

import module namespace mergertool = "http://alm.com/mergertool" at "/common/model/mergertool.xqy";

declare namespace util = "http://alm.com/util";

declare option xdmp:mapping "false";

declare function mergertool-ctlr:GetRevenueChanges($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	return mergertool:GetRevenueChanges($request)
};

declare function mergertool-ctlr:GetRevenuePerLawyerChanges($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	return mergertool:GetRevenuePerLawyerChanges($request)
};

declare function mergertool-ctlr:GetCostPerLawyer($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	return mergertool:GetCostPerLawyer($request)
};

declare function mergertool-ctlr:GetProfitMargin($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	return mergertool:GetProfitMargin($request)
};

declare function mergertool-ctlr:GetProfitPerEquityPartnerChanges($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	return mergertool:GetProfitPerEquityPartnerChanges($request)
};

declare function mergertool-ctlr:GetProfitPerEquityPartner($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	return mergertool:GetProfitPerEquityPartner($request)
};

declare function mergertool-ctlr:GetRevenueByYear($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	return mergertool:GetRevenueByYear($request)
};

declare function mergertool-ctlr:GetRevenuePerLawyerByYear($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	return mergertool:GetRevenuePerLawyerByYear($request)
};

declare function mergertool-ctlr:GetProfitLawyer($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	return mergertool:GetProfitLawyer($request)
};

declare function mergertool-ctlr:GetTotalHeadCount($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	return mergertool:GetTotalHeadCount($request)
};

declare function mergertool-ctlr:GetGrowthTotalHeadCount($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	return mergertool:GetGrowthTotalHeadCount($request)
};

declare function mergertool-ctlr:GetHeadCountPercentage($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	return mergertool:GetHeadCountPercentage($request)
};

declare function mergertool-ctlr:GetGrowthinAssociateandPartners($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	return mergertool:GetGrowthinAssociateandPartners($request)
};

declare function mergertool-ctlr:GetLeverage($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	return mergertool:GetLeverage($request)
};

declare function mergertool-ctlr:GetFirmStaffingDiversityMetrics($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	return mergertool:GetFirmStaffingDiversityMetrics($request)
};

declare function mergertool-ctlr:GetDiversityPartnerPieChart($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	return mergertool:GetDiversityPartnerPieChart($request)
};

declare function mergertool-ctlr:GetDiversityGrowth($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	return mergertool:GetDiversityGrowth($request)
};

declare function mergertool-ctlr:GetGenderBreakdown($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	return mergertool:GetGenderBreakdown($request)
};

declare function mergertool-ctlr:GetGrowthInGenderDiversity($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	return mergertool:GetGrowthInGenderDiversity($request)
};

declare function mergertool-ctlr:GetLateralPartnerPracticeAdd($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	let $OrganisationID := $request/FirmID/text()
	let $Title := $request/Title/text()
	
	return mergertool:GetLateralPartnerPracticeAdd(
		 $OrganisationID
		,$Title
	)
};

declare function mergertool-ctlr:GetOfficeTrendsMap($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	return mergertool:GetOfficeTrendsMap($request)
};

declare function mergertool-ctlr:GetOfficeTrendsMapByCity($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	return mergertool:GetOfficeTrendsMapByCity($request)
};

declare function mergertool-ctlr:GetSummaryByCombinedData($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	return mergertool:GetSummaryByCombinedData($request)
};

declare function mergertool-ctlr:GetPracticeareaList($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	return mergertool:GetPracticeareaList($request)
};

declare function mergertool-ctlr:GetFirmSummaryByID($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	return mergertool:GetFirmSummary($request)
};

declare function mergertool-ctlr:GetOrganizationName($params as element(util:params))
{
	let $orgID := $params/util:organizationID/text()
	return json:to-array(mergertool:GetOrganizationName($orgID))
};


declare function mergertool-ctlr:GetLawyerMoveStats($params as element(util:params))
{
	let $request := xdmp:get-request-body()/request
	let $FirmID := $request/FirmID/text()
	let $title := $request/title/text()
	let $FirmIDs := fn:tokenize($FirmID,',')
	return if(count($FirmIDs) gt 1) then mergertool:GetLawyerMoveStatsCombined(
		 $FirmID
		,$title
	) else 
			 mergertool:GetLawyerMoveStats(
		 $FirmID
		,$title
	)
};

