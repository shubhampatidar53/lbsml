xquery version "1.0-ml";

module namespace survey-ctlr = "http://alm.com/controller/Survey";

import module namespace Survey = "http://alm.com/Survey" at "/common/model/Survey.xqy";

declare namespace util = "http://alm.com/util";

declare option xdmp:mapping "false";

declare function survey-ctlr:getyears($params as element(util:params))
{	
	Survey:GetYears(
	survey-ctlr:required($params/util:surveyId, 'surveyId')
	)
	(:Survey:GetYears($params):)
};

declare function survey-ctlr:GetSurveyDataByYear($params as element(util:params))
{
	(:Survey:GetSurveyDataByYear($params):)
	Survey:GetSurveyDataByYear(
	survey-ctlr:required($params/util:SurveyID, 'SurveyID'),
	survey-ctlr:required($params/util:PublishYear, 'PublishYear')
	)
};

declare function survey-ctlr:GetVisualizationData($params as element(util:params))
{	
	Survey:GetVisualizationData(
	survey-ctlr:required($params/util:SurveyID, 'SurveyID')
	(:,():)
	)
};

declare function survey-ctlr:GetCategoryList($params as element(util:params))
{	
	Survey:GetCategoryList()
};

declare function survey-ctlr:GetRankingData($params as element(util:params))
{	
	Survey:GetRankingData(
	survey-ctlr:required($params/util:Tablename, 'tableName'),
	survey-ctlr:required($params/util:PublishYear, 'PublishYear')
	)
};

declare function survey-ctlr:GetQuickSearchResultsOnTerms($params as element(util:params))
{	
	Survey:GetQuickSearchResultsOnTerms(
	survey-ctlr:required($params/util:term, 'term'),
	survey-ctlr:required($params/util:type, 'type'),
	survey-ctlr:required($params/util:pagename, 'pagename')
	) 
	(:Survey:GetQuickSearchResultsOnTerms() :)
};

declare function survey-ctlr:FilterDataBySearchTerm($params as element(util:params))
{	
	Survey:FilterDataBySearchTerm()
};

declare function survey-ctlr:GetAMLAW100ChartDataDetails($params as element(util:params))
{	
	json:to-array(Survey:GetAMLAW100ChartDataDetails(
	survey-ctlr:required($params/util:SurveyID, 'SurveyID'),
	survey-ctlr:required($params/util:StartYear, 'StartYear'),
	survey-ctlr:required($params/util:EndYear, 'EndYear'),
	survey-ctlr:required($params/util:FirmList, 'FirmList')
	))
};

declare function survey-ctlr:GetAMLaw100Statistics($params as element(util:params))
{	
	json:to-array(Survey:GetAMLaw100Statistics(
	survey-ctlr:required($params/util:SurveyID, 'SurveyID'),
	survey-ctlr:required($params/util:StartYear, 'StartYear'),
	survey-ctlr:required($params/util:EndYear, 'EndYear'),
	survey-ctlr:required($params/util:FirmList, 'FirmList')
	))
};

declare function survey-ctlr:GetAMLaw100StatisticsExport($params as element(util:params))
{	
	json:to-array(Survey:GetAMLaw100StatisticsExport(
	survey-ctlr:required($params/util:SurveyID, 'SurveyID'),
	survey-ctlr:required($params/util:StartYear, 'StartYear'),
	survey-ctlr:required($params/util:EndYear, 'EndYear'),
	survey-ctlr:required($params/util:FirmList, 'FirmList')
	))
};

declare function survey-ctlr:GetNLJChartDataDetails($params as element(util:params))
{	
	Survey:GetNLJChartDataDetails(
	survey-ctlr:required($params/util:FirmList, 'FirmList'),
	survey-ctlr:required($params/util:StartYear, 'StartYear'),
	survey-ctlr:required($params/util:EndYear, 'EndYear'),
	survey-ctlr:required($params/util:Role, 'Role')
	)
};

declare function survey-ctlr:GetNLJStatistics($params as element(util:params))
{	
	json:to-array(Survey:GetNLJStatistics(
	survey-ctlr:required($params/util:FirmList, 'FirmList'),
	survey-ctlr:required($params/util:StartYear, 'StartYear'),
	survey-ctlr:required($params/util:EndYear, 'EndYear'),
	survey-ctlr:required($params/util:Role, 'Role')
	))
};

declare function survey-ctlr:GETSEARCHDATA($params as element(util:params))
{	
	Survey:GETSEARCHDATA()
};

declare function survey-ctlr:GetAllSurveyData_New($params as element(util:params))
{	
	Survey:GetAllSurveyData_New()
};

declare function survey-ctlr:test($params as element(util:params))
{
    let $a := "Hello"
	return survey-ctlr:required($params/util:pageNo, 'pageNo')
	(: firm:sp_GetLawFirmStatics_Formattednew1() :)
};

declare function survey-ctlr:required($value as item()*, $parameter as xs:string) as item()*
{
    if (fn:exists($value)) then
        $value
    else
        fn:error(xs:QName("MISSINGPARAM"), fn:concat("Required param '", $parameter, "' is missing"))
};