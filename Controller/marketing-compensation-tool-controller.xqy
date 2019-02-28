xquery version "1.0-ml";

module namespace comp-ctlr = "http://alm.com/controller/marketing-compensation-tool";

 import module namespace comptool = "http://alm.com/marketing-compensation-tool" at "/common/model/marketing-compensation-tool.xqy"; 

declare namespace util = "http://alm.com/util";

declare option xdmp:mapping "false";

declare function comp-ctlr:GetMCompensationAndBillingAvg($params as element(util:params))
{
	comptool:GetMCompensationAndBillingAvg()
};

declare function comp-ctlr:GetMSatisfactionData($params as element(util:params))
{
	comptool:GetMSatisfactionData()
};

declare function comp-ctlr:GetDepartmentFirmModelAvg($params as element(util:params))
{
	comptool:GetDepartmentFirmModelAvg()
};

declare function comp-ctlr:GetDirectManagers($params as element(util:params))
{
	comptool:GetDirectManagers()
};

declare function comp-ctlr:GetWeeklyHours($params as element(util:params))
{
	comptool:GetWeeklyHours()
};

(: declare function comp-ctlr:GetSatisfactionData($params as element(util:params))
{
	comptool:GetSatisfactionData()
};

declare function comp-ctlr:GetCompensationAndBillingAvg($params as element(util:params))
{
	comptool:GetCompensationAndBillingAvg()
}; :)