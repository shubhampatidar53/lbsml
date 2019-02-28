xquery version '1.0-ml';

module namespace lawfirm-overview-ctlr = 'http://alm.com/controller/lawfirm-overview';

import module namespace lawfirm-overview = 'http://alm.com/lawfirm-overview' at '/common/model/lawfirm-overview.xqy';

declare namespace util = 'http://alm.com/util';
declare namespace organization = 'http://alm.com/LegalCompass/rd/organization';

declare option xdmp:mapping 'false';


declare function lawfirm-overview-ctlr:GetLawFirmProfileOverview($params as element(util:params))
{
	let $ids := $params/util:ids/text()
	return lawfirm-overview:GetLawFirmProfileOverview($ids) 	
};

declare function lawfirm-overview-ctlr:GetLawfirmProfileOverviewReport($params as element(util:params))
{
	let $firmId := $params/util:firmId/text()
	let $headQuarterAddress := $params/util:headQuarterAddress/text()
	return lawfirm-overview:GetLawfirmProfileOverviewReport($firmId, $headQuarterAddress) 	
};

declare function lawfirm-overview-ctlr:GetLawfirmProfileOverviewWithOfficeCount($params as element(util:params))
{
		let $firmId := $params/util:firmId/text()
		let $headQuarterAddress := $params/util:headQuarterAddress/text()
		return lawfirm-overview:GetLawfirmProfileOverviewWithOfficeCount($firmId, $headQuarterAddress) 	

};
