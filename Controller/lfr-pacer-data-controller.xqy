xquery version "1.0-ml";

module namespace lfr-pacer-data-ctlr = "http://alm.com/controller/lfr-pacer-data";

import module namespace pacerdata = "http://alm.com/pacerdata" at "/common/model/lfr-pacer-data.xqy";

declare namespace util = "http://alm.com/util";

declare option xdmp:mapping "false";

declare function lfr-pacer-data-ctlr:GetCompanyProfileLFRData($params as element(util:params))
{
    let $request := xdmp:get-request-body()/request
	return pacerdata:GetCompanyProfileLFRData($request)
};

declare function lfr-pacer-data-ctlr:GetCompanyProfileLFRChartData($params as element(util:params))
{
    let $request := xdmp:get-request-body()/request
	return pacerdata:GetCompanyProfileLFRChartData($request)
};

declare function lfr-pacer-data-ctlr:DeleteDataByScopeID($params as element(util:params))
{
    let $scopeID := $params/util:ScopeID/text()
	return pacerdata:DeleteDataByScopeID($scopeID)
};

declare function lfr-pacer-data-ctlr:GetCompanyProfileLFRMaxYear($params as element(util:params))
{
    let $request := $params/util:ScopeID/text()
	return pacerdata:GetCompanyProfileLFRMaxYear($request)
};

declare function lfr-pacer-data-ctlr:GetCompanyProfileLFRDataCount($params as element(util:params))
{
    let $request := xdmp:get-request-body()/request
	return pacerdata:GetCompanyProfileLFRDataCount($request)
};

