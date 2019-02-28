module namespace report-ctlr = 'http://alm.com/controller/report';

import module namespace report= 'http://alm.com/report' at '/common/model/report.xqy';

declare namespace util = 'http://alm.com/util';

declare function report-ctlr:GenericSurveyTableAdapter($params as element(util:params))
{
    let $orgID := $params/util:orgID/text() 
    let $FDuration := $params/util:FDuration/text() 
    let $namespace := $params/util:Namespace/text() 
    let $root := $params/util:root/text() 
    let $tableName := $params/util:tableName/text() 
  
	return report:GenericSurveyTableAdapter($orgID,$FDuration,$namespace,$root,$tableName)
};

declare function report-ctlr:ASSOCIATE_NATLTableAdapter($params as element(util:params))
{
    let $orgID := $params/util:orgID/text() 
    let $FDuration := $params/util:FDuration/text() 
	return report:ASSOCIATE_NATLTableAdapter($orgID,$FDuration)
};

declare function report-ctlr:AMLaw200AVGTableAdapter($params as element(util:params))
{
    let $FYear := $params/util:FYear/text() 
	return report:AMLaw200AVGTableAdapter($FYear)
};

declare function report-ctlr:NLJ250AVGTableAdapter($params as element(util:params))
{
    let $FYear := $params/util:FYear/text() 
	return report:NLJ250AVGTableAdapter($FYear)
};

declare function report-ctlr:GLOBAL100AVGTableAdapter($params as element(util:params))
{
    let $FYear := $params/util:FYear/text() 
	return report:GLOBAL100AVGTableAdapter($FYear)
};
declare function report-ctlr:LATERAL_PARTNERTableAdapter($params as element(util:params))
{
    let $orgID := $params/util:orgID/text() 
    let $FYear := $params/util:FYear/text() 
	return report:LATERAL_PARTNERTableAdapter($orgID,$FYear)
};
declare function report-ctlr:GetLawfirmRevenueHeadcountCusReport($params as element(util:params))
{
    let $startYear := $params/util:startYear/text() 
    let $endYear := $params/util:endYear/text() 
    let $organizationIds := $params/util:organizationIds/text() 
	return report:GetLawfirmRevenueHeadcountCusReport($startYear,$endYear,$organizationIds)
};
declare function report-ctlr:PARTNER_PROMOTIONSTableAdapter($params as element(util:params))
{
    let $orgID := $params/util:orgID/text() 
    let $FYear := $params/util:FYear/text() 
	return report:PARTNER_PROMOTIONSTableAdapter($orgID,$FYear)
};

declare function report-ctlr:GetLFRFileNameCustom($params as element(util:params))
{
    let $orgID := $params/util:orgID/text() 
    let $format := $params/util:Format/text() 
    let $strTabs := $params/util:strTabs/text() 
    let $years := $params/util:Years/text() 
	return report:GetLFRFileNameCustom($orgID,$format,$strTabs,$years)
};