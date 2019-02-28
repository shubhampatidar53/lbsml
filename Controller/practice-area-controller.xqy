xquery version "1.0-ml";

module namespace practice-area-ctlr = "http://alm.com/controller/practice-area";

import module namespace practice-area = "http://alm.com/practice-area" at "/common/model/practice-area.xqy";

declare namespace util = "http://alm.com/util";

declare option xdmp:mapping "false";

declare function practice-area-ctlr:GetPracticeAreas($params as element(util:params))
{
	practice-area:GetPracticeAreas()
};