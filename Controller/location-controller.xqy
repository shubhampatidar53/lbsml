xquery version "1.0-ml";

module namespace location-ctlr = "http://alm.com/controller/location";

import module namespace location = "http://alm.com/location" at "/common/model/location.xqy";

declare namespace util = "http://alm.com/util";

declare option xdmp:mapping "false";

declare function location-ctlr:GetLocations($params as element(util:params))
{
	location:GetLocations()
};