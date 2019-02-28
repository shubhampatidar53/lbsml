xquery version "1.0-ml";

module namespace comp-ctlr = "http://alm.com/controller/compensation-tool";

import module namespace comptool = "http://alm.com/compensationtool" at "/common/model/compensationtool.xqy";

declare namespace util = "http://alm.com/util";

declare option xdmp:mapping "false";

declare function comp-ctlr:GetSatisfactionData($params as element(util:params))
{
	comptool:GetSatisfactionData()
};

declare function comp-ctlr:GetCompensationAndBillingAvg($params as element(util:params))
{
	comptool:GetCompensationAndBillingAvg()
};