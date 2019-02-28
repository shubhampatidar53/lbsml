xquery version '1.0-ml';

module namespace mergertool = 'http://alm.com/mergertool';

import module namespace config = 'http://alm.com/config' at '/common/config.xqy';
import module namespace search = 'http://marklogic.com/appservices/search' at '/MarkLogic/appservices/search/search.xqy';
import module namespace json = 'http://marklogic.com/xdmp/json'  at '/MarkLogic/json/json.xqy';
import module namespace firmnew = 'http://alm.com/firmnew' at '/common/model/firmnew.xqy';

declare namespace organization = 'http://alm.com/LegalCompass/dd/organization';
declare namespace rd-organization = 'http://alm.com/LegalCompass/rd/organization';
declare namespace org-address = 'http://alm.com/LegalCompass/rd/organization-address';
declare namespace survey = 'http://alm.com/LegalCompass/dd/survey';
declare namespace xref = 'http://alm.com/LegalCompass/rd/FIRMS_ALI_XREF_RE';
declare namespace rd_person = 'http://alm.com/LegalCompass/rd/person';
declare namespace dd_person = 'http://alm.com/LegalCompass/dd/person';
declare namespace practices_kws = 'http://alm.com/LegalCompass/rd/practices_kws';
declare namespace city = 'http://alm.com/LegalCompass/rd/city';
declare namespace company = 'http://alm.com/LegalCompass/rd/company';
declare namespace organization-branch = 'http://alm.com/LegalCompass/rd/organization-branch';
declare namespace bdbs-representer = 'http://alm.com/LegalCompass/rd/bdbs-representer';
declare namespace bdbs-party = 'http://alm.com/LegalCompass/rd/bdbs-party';
declare namespace bdbs-transaction = 'http://alm.com/LegalCompass/rd/bdbs-transaction';
declare namespace data = 'http://alm.com/LegalCompass/rd/data';
declare namespace survey-listing = 'http://alm.com/LegalCompass/dd/survey-listing';
declare namespace Who_Counsels_who = 'http://alm.com/LegalCompass/rd/Who_Counsels_who';
declare namespace COMPANYPROFILE_LFR_NEW = 'http://alm.com/LegalCompass/rd/COMPANYPROFILE_LFR_NEW';
declare namespace COMPANYPROFILE_LFR = 'http://alm.com/LegalCompass/rd/COMPANYPROFILE_LFR';
declare namespace TOP500 = 'http://alm.com/LegalCompass/rd/TOP500';
declare namespace people_changes = 'http://alm.com/LegalCompass/rd/people_changes';
declare namespace organization-contact = 'http://alm.com/LegalCompass/rd/organization-contact';
declare namespace org-branch = 'http://alm.com/LegalCompass/rd/organization-branch';
declare namespace city_detail = 'http://alm.com/LegalCompass/rd/city_detail';
declare namespace ALI_RE_LateralMoves_Data = 'http://alm.com/LegalCompass/rd/ALI_RE_LateralMoves_Data';
declare namespace lfp_news = 'http://alm.com/LegalCompass/rd/lawfirmprofile_news';
declare namespace REPRESENTATION_TYPES = 'http://alm.com/LegalCompass/rd/REPRESENTATION_TYPES';

declare namespace organizations = 'http://alm.com/LegalCompass/rd/organization';
declare namespace amlaw100 = 'http://alm.com/LegalCompass/rd/AMLAW_100';
declare namespace Global_100 = 'http://alm.com/LegalCompass/rd/Global_100';
declare namespace nlj250 = 'http://alm.com/LegalCompass/rd/NLJ_250';
declare namespace dc20 = 'http://alm.com/LegalCompass/rd/DC20';
declare namespace legaltimes =  'http://alm.com/LegalCompass/rd/Legal_Times_150';
declare namespace ny100 = 'http://alm.com/LegalCompass/rd/NY100';
declare namespace alist = 'http://alm.com/LegalCompass/rd/ALIST';
declare namespace tx100 = 'http://alm.com/LegalCompass/rd/TX100';
declare namespace nljlgbt = "http://alm.com/LegalCompass/rd/NLJ_LGBT";

declare namespace AMLAW_200 = 'http://alm.com/LegalCompass/rd/AMLAW_200';
declare namespace Diversity_Scorecard = 'http://alm.com/LegalCompass/rd/Diversity_Scorecard';
declare namespace FEMALE_SCORECARD = 'http://alm.com/LegalCompass/rd/FEMALE_SCORECARD';
declare namespace UK_50 = 'http://alm.com/LegalCompass/rd/UK_50';
declare namespace CHINA_40 = 'http://alm.com/LegalCompass/rd/CHINA_40';

declare namespace firm-org = 'http://alm.com/LegalCompass/lawfirm/dd/organization';

declare namespace ALI_RE_Attorney_Data = 'http://alm.com/LegalCompass/dd/ALI_RE_Attorney_Data';
declare namespace TBL_RER_CACHE_ATTORNEY_MOVESCHANGES = 'http://alm.com/LegalCompass/dd/TBL_RER_CACHE_ATTORNEY_MOVESCHANGES';
declare namespace TBL_RER_CACHE_ATTORNEY_DATA = 'http://alm.com/LegalCompass/dd/TBL_RER_CACHE_ATTORNEY_DATA';
declare namespace LawFirm_PracticeArea = "http://alm.com/LegalCompass/rd/LawFirm_PracticeArea";
declare namespace LAWFIRMLOCATIONS = "http://alm.com/LegalCompass/rd/LAWFIRMLOCATIONS";
declare namespace LawFirmMergers ="http://alm.com/LegalCompass/rd/LAWFIRM_MERGERS";

declare namespace tblrer = "http://alm.com/LegalCompass/dd/TBL_RER_CACHE_ATTORNEY_DATA";

declare option xdmp:mapping 'false';

(:-------------------------Financial-------------------------:)

declare function mergertool:GetRevenueChanges($request)
{	
	let $distinctYears := cts:element-attribute-values(xs:QName('survey:YEAR'),xs:QName('PublishYear'),(),('descending'),
	cts:and-query((
		cts:directory-query('/LegalCompass/denormalized-data/surveys/AMLAW_200/','1')
	)))

	

	let $distinctYears := if($request/StartYear/text() ne "" and $request/EndYear/text() ne "") then
                      for $year in $distinctYears
                      where $year >= xs:integer($request/StartYear/text()) and   $year lt xs:integer($request/EndYear/text())
                      return $year
                      else $distinctYears[1 to 6]   (: fn:tokenize('2017,2016,2015,2014,2013',','):)
                      
	let $OrganizationIDs := $request//FirmID/text()

	let $uk50ID := cts:search(/,
						cts:and-query((
							cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/")(:,
							cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string($year)):),
							cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),fn:tokenize($OrganizationIDs,','))
							)))[1]//UK_50:ORGANIZATION_ID/text()
		
	let $response-arr := json:array()
	
	let $loopdata := for $OrganizationID in fn:tokenize($OrganizationIDs,',')

								let $amlaw200maxYearData := cts:search(/,
									cts:and-query((
										cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
										cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string(max($distinctYears))),
										cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),xs:string($OrganizationID))
									)))[1]

								let $uk50maxYearData := cts:search(/,
								cts:and-query((
									cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
									cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string(fn:max($distinctYears))),
									cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),xs:string($OrganizationID))
								)))[1]

								let $global100YearData := cts:search(/,
								cts:and-query((
									cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
									cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string(fn:max($distinctYears))),
									cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),xs:string($OrganizationID))
								)))[1]		

								let $maxYearData := if($uk50maxYearData ne '' or $amlaw200maxYearData ne '' or $global100YearData ne '') then 'Y' else ()	

								let $organizationName := if((/organization[organization:ORGANIZATION_ID = xs:string($OrganizationID)]/organization:ALM_NAME/text())[1] ne '')then 
															/organization[organization:ORGANIZATION_ID = xs:string($OrganizationID)]/organization:ALM_NAME/text()[1]
															else 
															/organization[organization:ORGANIZATION_ID = xs:string($OrganizationID)]/organization:ORGANIZATION_NAME/text()[1]
								let $data := for $year in (reverse($distinctYears))
								
													    let $response-obj := json:object()
													
													    let $amlaw200CurrentYear := avg(cts:search(/,
																								cts:and-query((
																									cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
																									cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year)),
																									cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),xs:string($OrganizationID))
																									)))//AMLAW_200:GROSS_REVENUE/text())

														let $amlaw00IDPreYear := avg(cts:search(/,
																	cts:and-query((
																		cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
																		cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string(xs:integer($year) - 1)),
																		cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),xs:string($OrganizationID))
																		)))//AMLAW_200:GROSS_REVENUE/text())

														
														let $global100CurrentYear := avg(cts:search(/,
																								cts:and-query((
																									cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
																									cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($year)),
																									cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),xs:string($OrganizationID))
																									)))//Global_100:GROSS_REVENUE/text())

														let $global100IDPreYear := avg(cts:search(/,
																	cts:and-query((
																		cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
																		cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string(xs:integer($year) - 1)),
																		cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),xs:string($OrganizationID))
																		)))//Global_100:GROSS_REVENUE/text())

														
														let $uk50IDCurrentYear := avg(cts:search(/,
																								cts:and-query((
																									cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
																									cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string($year)),
																									cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),xs:string($OrganizationID))
																									)))//UK_50:GROSS_REVENUE_DOLLAR/text())

													
														let $uk50IDPreYear := avg(cts:search(/,
																								cts:and-query((
																									cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
																									cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string($year -1)),
																									cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),xs:string($OrganizationID))
																									)))//UK_50:GROSS_REVENUE_DOLLAR/text())
														
														let $grossRev := if($amlaw200CurrentYear ne 0) then $amlaw200CurrentYear else
																		if($global100CurrentYear ne 0) then $global100CurrentYear
																		else if($uk50IDCurrentYear) then $uk50IDCurrentYear else -1000
														
														let $grossRevPreviousYear := if($amlaw00IDPreYear ne 0) then $amlaw00IDPreYear else
																		if($global100IDPreYear ne 0) then $global100IDPreYear
																		else if($uk50IDPreYear) then $uk50IDPreYear	 else -1000	
														
														let $resGrossRevenue := if($grossRevPreviousYear ne -1000 and $grossRev ne -1000) then (($grossRev - $grossRevPreviousYear) div $grossRevPreviousYear) * 100 else -1000
														let $isAddMaxYear := if(xs:string($year) ne xs:string(max($distinctYears)) and $resGrossRevenue ne -1000) then 'y' else
																				if($amlaw200CurrentYear ne 0 or $global100CurrentYear ne 0 or $uk50IDCurrentYear ne 0) then 'y' else 'n' 							
																					
															
														let $_ := (
															map:put($response-obj,'ORGANIZATION_ID',xs:integer($OrganizationID)),
															map:put($response-obj,'ORGANIZATION_NAME',$organizationName),
															map:put($response-obj,'CHANGE', fn:round-half-to-even($resGrossRevenue,2)),
															map:put($response-obj,'Revenue', $grossRev),
															map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
															)
														
														let $_ := if(xs:string($year) ne xs:string(max($distinctYears))) then json:array-push($response-arr, $response-obj) else
																		if($maxYearData ne '' and ($amlaw200CurrentYear ne 0 or $global100CurrentYear ne 0 or $uk50IDCurrentYear ne 0))
																			then json:array-push($response-arr,$response-obj) else()
													
														return ()
														return()
    
	
	let $surveyData := for $year in (reverse($distinctYears))

							(:------------Global 200 part------------------:)
							let $response-obj := json:object()
						
							(: let $distinctid_global_100_Current  := cts:element-values(xs:QName("Global_100:ORGANIZATION_ID"),(),(),
										cts:and-query((
										cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/")      
										,cts:element-value-query(xs:QName("Global_100:PUBLISHYEAR"),xs:string($year))
										,cts:not-query(cts:element-value-query(xs:QName("Global_100:RANK_BY_GROSS_REVENUE"),""))
										))) :)
						
							let $res4 := xs:integer(avg(cts:search(/,
										cts:and-query((
										cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/") 
										,cts:element-value-query(xs:QName("Global_100:PUBLISHYEAR"), xs:string($year))
										,cts:not-query(cts:element-value-query(xs:QName("Global_100:RANK_BY_GROSS_REVENUE"),""))
										,cts:element-range-query(xs:QName("Global_100:RANK_BY_GROSS_REVENUE"),"<=",100)
										)))//Global_100:GROSS_REVENUE/text()))
    
							(: let $distinctid_global_100  := cts:element-values(xs:QName("Global_100:ORGANIZATION_ID"),(),(),
										cts:and-query((
										cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/")      
										,cts:element-value-query(xs:QName("Global_100:PUBLISHYEAR"),xs:string(xs:integer($year) - 1))
										,cts:not-query(cts:element-value-query(xs:QName("Global_100:RANK_BY_GROSS_REVENUE"),""))
										)))
							 :)
							let $lag4 := xs:integer(avg(cts:search(/,
										cts:and-query((
										cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/") 
										(: ,cts:element-value-query(xs:QName("Global_100:ORGANIZATION_ID"),($distinctid_global_100 ! xs:string(.))) :)
										,cts:element-value-query(xs:QName("Global_100:PUBLISHYEAR"), xs:string(xs:integer($year) - 1))
										,cts:not-query(cts:element-value-query(xs:QName("Global_100:RANK_BY_GROSS_REVENUE"),""))
										,cts:element-range-query(xs:QName("Global_100:RANK_BY_GROSS_REVENUE"),"<=",100)
										)))//Global_100:GROSS_REVENUE/text()))
    
   							let $CHANGE := if($res4 ne  0 and $lag4 ne 0) then fn:round-half-to-even((xs:double($res4 - $lag4) div  $lag4 ) * 100 , 2) else -1000
    
							let $_ := (
									map:put($response-obj,'ORGANIZATION_ID', 0),
								map:put($response-obj,'ORGANIZATION_NAME', 'Global 100'),
								map:put($response-obj,'CHANGE', $CHANGE),
								map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
								)
								let $_ :=  json:array-push($response-arr, $response-obj)

							(:------------------------------AmLaw100-------------------------------------------:)
	
							
							let $response-obj := json:object()
							
							let $res2 := xs:integer(avg(cts:search(/,
											cts:and-query((
											cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/','1')
											,cts:element-range-query(xs:QName('AMLAW_200:AMLAW200_RANK'), '<=',100)
											,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'), xs:string($year))
											,cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
											)))//AMLAW_200:GROSS_REVENUE/text()))	
		
							
								
							let $res2-LAG := xs:integer(avg(cts:search(/,
												cts:and-query((
												cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/','1')
												,cts:element-range-query(xs:QName('AMLAW_200:AMLAW200_RANK'), '<=',100)
												,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'), xs:string(xs:integer($year) - 1))
												,cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
												)))//AMLAW_200:GROSS_REVENUE/text()))	
								
							let $CHANGE := if($res2 and $res2-LAG) then fn:round-half-to-even((xs:double($res2 - $res2-LAG) div  $res2-LAG ) * 100 , 2) else -1000
	
							let $_ := (
									map:put($response-obj,'ORGANIZATION_ID', 0),
								map:put($response-obj,'ORGANIZATION_NAME', 'Am Law 100'),
								map:put($response-obj,'CHANGE', $CHANGE),
								map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
								)

							let $_ := json:array-push($response-arr, $response-obj) 

							(:------------------------------Am Law 2nd Hundred-------------------------------------------:)
	
						
							let $response-obj := json:object()
							
							let $res2 := xs:integer(avg(cts:search(/,
											cts:and-query((
											cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/','1')
											,cts:element-range-query(xs:QName('AMLAW_200:AMLAW200_RANK'), '>',100)
											,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'), xs:string($year))
											,cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
											)))//AMLAW_200:GROSS_REVENUE/text()))
		
						
							let $res2-LAG := xs:integer(avg(cts:search(/,
											cts:and-query((
											cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/','1')
											,cts:element-range-query(xs:QName('AMLAW_200:AMLAW200_RANK'), '>',100)
											,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'), xs:string($year - 1))
											,cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
											)))//AMLAW_200:GROSS_REVENUE/text()))
								
							let $CHANGE := if($res2 and $res2-LAG) then
										fn:round-half-to-even((xs:double($res2 - $res2-LAG) div  $res2-LAG ) * 100 , 2) else -1000
	
							let $_ := (
									map:put($response-obj,'ORGANIZATION_ID', 0),
								map:put($response-obj,'ORGANIZATION_NAME', 'Am Law 2nd Hundred'),
								map:put($response-obj,'CHANGE', $CHANGE),
								map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
								)

							let $_ := json:array-push($response-arr, $response-obj) 

							(:------------------------UK50------------------------:)
		
							let $response-obj := json:object()

							(: let $distinctid_gt_100_Cur := fn:distinct-values(cts:search(/,
												cts:and-query((
													cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
													cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string($year))
													)))//UK_50:ORGANIZATION_ID/text()) :)

							
							let $res3 := xs:integer(avg(cts:search(/,
												cts:and-query((
												cts:directory-query('/LegalCompass/relational-data/surveys/UK_50/','1')
												,cts:element-range-query(xs:QName('UK_50:UK_50_RANK'),'<=' ,xs:integer(50))
												,cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'), xs:string($year))
												)))//UK_50:GROSS_REVENUE_DOLLAR/text()))
	
							(: let $distinctid_gt_100  :=fn:distinct-values(cts:search(/,
											cts:and-query((
												cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
												cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string(xs:integer($year) - 1))
												)))//UK_50:ORGANIZATION_ID/text()) :)
							
							let $res3-LAG := xs:integer(avg(cts:search(/,
												cts:and-query((
												cts:directory-query('/LegalCompass/relational-data/surveys/UK_50/','1')
												,cts:element-range-query(xs:QName('UK_50:UK_50_RANK'),'<=' ,xs:integer(50))
												,cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'), xs:string(xs:integer($year) -1))
												)))//UK_50:GROSS_REVENUE_DOLLAR/text()))
							
							let $difference := $res3 - $res3-LAG

							let $CHANGE :=if($res3 ne 0 and $res3-LAG ne 0) then fn:round-half-to-even((xs:double($difference) div  $res3-LAG ) * 100 , 2) else -1000
							
							let $_ :=(
								map:put($response-obj,'ORGANIZATION_ID', 0),
								map:put($response-obj,'ORGANIZATION_NAME', 'UK 50'),
								map:put($response-obj,'CHANGE', $CHANGE),
								map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
							)
							let $_ := if($uk50ID ne '') then json:array-push($response-arr, $response-obj) else()	

							return()
	return ($response-arr)
};

declare function mergertool:GetRevenuePerLawyerChanges($request)
{
	let $isGBP := $request/IsDisplayGBP/text()
	let $isDisplayGBP := if($isGBP ne '') then $isGBP else 'false'


	let $distinctYears := cts:element-attribute-values(xs:QName('survey:YEAR'),xs:QName('PublishYear'),(),('descending'),
	cts:and-query((
		cts:directory-query('/LegalCompass/denormalized-data/surveys/AMLAW_200/','1')
	)))
	let $distinctYears := if($request/StartYear/text() ne "" and $request/EndYear/text() ne "") then
                      for $year in $distinctYears
                      where $year >= xs:integer($request/StartYear/text()) and   $year lt xs:integer($request/EndYear/text())
                      return $year
                      else $distinctYears[1 to 6]	 (:fn:tokenize('2017,2016,2015,2014,2013',','):)
  
    let $OrganizationIDs := $request//FirmID/text()
	let $uk50ID := cts:search(/,
											cts:and-query((
												cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/")(:,
												cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string($year)):),
												cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),fn:tokenize($OrganizationIDs,','))
												)))[1]//UK_50:ORGANIZATION_ID/text()

	
	let $response-arr := json:array()
	let $loopdata := for $OrganizationID in fn:tokenize($OrganizationIDs,',')

				let $organizationName := if((/organization[organization:ORGANIZATION_ID = xs:string($OrganizationID)]/organization:ALM_NAME/text())[1] ne '')then 
					/organization[organization:ORGANIZATION_ID = xs:string($OrganizationID)]/organization:ALM_NAME/text()[1]
				else 
					/organization[organization:ORGANIZATION_ID = xs:string($OrganizationID)]/organization:ORGANIZATION_NAME/text()[1]
						
				
				let $Lag1-obj := json:object()

				let $amlaw200maxYearData := cts:search(//survey:YEAR,
							cts:and-query((
								cts:directory-query($config:DD-SURVEY-AMLAW_200-PATH)
								,cts:element-attribute-value-query(xs:QName('survey:YEAR'),xs:QName('OrganizationID'),$OrganizationID)
								,cts:element-attribute-value-query(xs:QName('survey:YEAR'),xs:QName('PublishYear'),xs:string(max($distinctYears)))
							)))[1]
				let $uk50maxYearData := cts:search(/,
								cts:and-query((
									cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
									cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string(fn:max($distinctYears))),
									cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),xs:string($OrganizationID))
								)))[1]		

				let $global100YearData := cts:search(/,
								cts:and-query((
									cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
									cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string(fn:max($distinctYears))),
									cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),xs:string($OrganizationID))
								)))[1]		

								let $maxYearData := if($uk50maxYearData ne '' or $amlaw200maxYearData ne '' or $global100YearData ne '') then 'Y' else ()		
					
				let $data := for $year in (reverse($distinctYears))
							 	let $response-obj := json:object()
	
	
								let $amlaw200CurrentYear :=if(xs:string($isDisplayGBP) ne 'true') then cts:search(/,
																		cts:and-query((
																			cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
																			cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year)),
																			cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),xs:string($OrganizationID))
																			)))[1]//AMLAW_200:RPL/text() else()

								let $amlaw200RevenueCurrentYear :=if(xs:string($isDisplayGBP) ne 'true') then cts:search(/,
																		cts:and-query((
																			cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
																			cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year)),
																			cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),xs:string($OrganizationID))
																			)))[1]//AMLAW_200:GROSS_REVENUE/text() else()											

								let $amlaw200TotalLawyerCurrentYear :=if(xs:string($isDisplayGBP) ne 'true') then cts:search(/,
																		cts:and-query((
																			cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
																			cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year)),
																			cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),xs:string($OrganizationID))
																			)))[1]//AMLAW_200:NUM_OF_LAWYERS/text() else()											

								let $amlaw00IDPreYear :=if(xs:string($isDisplayGBP) ne 'true') then cts:search(/,
											cts:and-query((
												cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
												cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string(xs:integer($year) - 1)),
												cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),xs:string($OrganizationID))
												)))[1]//AMLAW_200:RPL/text() else()

								let $amlaw00RevenuePreYear :=if(xs:string($isDisplayGBP) ne 'true') then cts:search(/,
											cts:and-query((
												cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
												cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string(xs:integer($year) - 1)),
												cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),xs:string($OrganizationID))
												)))[1]//AMLAW_200:GROSS_REVENUE/text() else()				

								let $amlaw00IDTotalLawyerPreYear :=if(xs:string($isDisplayGBP) ne 'true') then cts:search(/,
											cts:and-query((
												cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
												cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string(xs:integer($year) - 1)),
												cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),xs:string($OrganizationID))
												)))[1]//AMLAW_200:NUM_OF_LAWYERS/text() else()	

								let $global100CurrentYear := if(xs:string($isDisplayGBP) ne 'true') then cts:search(/,
																		cts:and-query((
																			cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
																			cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($year)),
																			cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),xs:string($OrganizationID))
																			)))[1]//Global_100:REVENUE_PER_LAWYER/text() else()

								let $global100RevenueCurrentYear := if(xs:string($isDisplayGBP) ne 'true') then cts:search(/,
																		cts:and-query((
																			cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
																			cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($year)),
																			cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),xs:string($OrganizationID))
																			)))[1]//Global_100:GROSS_REVENUE/text() else()

								let $global100TotalLawyersCurrentYear := if(xs:string($isDisplayGBP) ne 'true') then cts:search(/,
																		cts:and-query((
																			cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
																			cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($year)),
																			cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),xs:string($OrganizationID))
																			)))[1]//Global_100:NUM_LAWYERS/text() else()											

								let $global100IDPreYear := if(xs:string($isDisplayGBP) ne 'true') then cts:search(/,
											cts:and-query((
												cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
												cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string(xs:integer($year) - 1)),
												cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),xs:string($OrganizationID))
												)))[1]//Global_100:REVENUE_PER_LAWYER/text() else()

								let $global100RevenuePreYear := if(xs:string($isDisplayGBP) ne 'true') then cts:search(/,
											cts:and-query((
												cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
												cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string(xs:integer($year) - 1)),
												cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),xs:string($OrganizationID))
												)))[1]//Global_100:GROSS_REVENUE/text() else()				

								let $global100IDTotallawyersPreYear := if(xs:string($isDisplayGBP) ne 'true') then cts:search(/,
											cts:and-query((
												cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
												cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string(xs:integer($year) - 1)),
												cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),xs:string($OrganizationID))
												)))[1]//Global_100:NUM_LAWYERS/text() else()
							

								let $uk50IDCurrentYear := if(xs:string($isDisplayGBP) eq 'true') then cts:search(/,
																	cts:and-query((
																		cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
																		cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string($year)),
																		cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),xs:string($OrganizationID))
																		)))[1]//UK_50:RPL_POUND_K/text()

															else cts:search(/,
																			cts:and-query((
																				cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
																				cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string($year)),
																				cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),xs:string($OrganizationID))
																				)))[1]//UK_50:RPL_DOLLAR/text()

								let $uk50RevenueCurrentYear := if(xs:string($isDisplayGBP) eq 'true') then cts:search(/,
																	cts:and-query((
																		cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
																		cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string($year)),
																		cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),xs:string($OrganizationID))
																		)))[1]//UK_50:RPL_POUND_K/text()

															else cts:search(/,
																			cts:and-query((
																				cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
																				cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string($year)),
																				cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),xs:string($OrganizationID))
																				)))[1]//UK_50:RPL_DOLLAR/text()

								let $uk50IDTotalLawyersCurrentYear := cts:search(/,
																			cts:and-query((
																				cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
																				cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string($year)),
																				cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),xs:string($OrganizationID))
																				)))[1]//UK_50:NUMBER_OF_LAWYERS/text()																

								let $uk50IDPreYear := if(xs:string($isDisplayGBP) eq 'true') then cts:search(/,
																cts:and-query((
																	cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
																	cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string(xs:integer($year) - 1)),
																	cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),xs:string($OrganizationID))
																	)))[1]//UK_50:RPL_POUND_K/text()
													else cts:search(/,
																cts:and-query((
																	cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
																	cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string(xs:integer($year) - 1)),
																	cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),xs:string($OrganizationID))
																	)))[1]//UK_50:RPL_DOLLAR/text()

								let $uk50RevenuePreYear := if(xs:string($isDisplayGBP) eq 'true') then cts:search(/,
																cts:and-query((
																	cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
																	cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string(xs:integer($year) - 1)),
																	cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),xs:string($OrganizationID))
																	)))[1]//UK_50:GROSS_REVENUE_POUND_K/text()
													else cts:search(/,
																cts:and-query((
																	cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
																	cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string(xs:integer($year) - 1)),
																	cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),xs:string($OrganizationID))
																	)))[1]//UK_50:GROSS_REVENUE_DOLLAR/text()

								let $uk50IDTotalLawyersPreYear := cts:search(/,
																cts:and-query((
																	cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
																	cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string(xs:integer($year) - 1)),
																	cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),xs:string($OrganizationID))
																	)))[1]//UK_50:NUMBER_OF_LAWYERS/text()									

								let $isAddMaxYear := if(xs:string($year) ne xs:string(max($distinctYears))) then 'y' else
													if($amlaw200CurrentYear ne '' or $global100CurrentYear ne '' or $uk50IDCurrentYear ne '') then 'y' else 'n' 							
								
								let $grossRev := if($amlaw200CurrentYear ne '') then $amlaw200CurrentYear else
												if($global100CurrentYear ne '') then $global100CurrentYear
												else if($uk50IDCurrentYear) then $uk50IDCurrentYear else -1000

								let $totalLawyersCurrentyear := if($amlaw200TotalLawyerCurrentYear ne '') then $amlaw200TotalLawyerCurrentYear else
												if($global100TotalLawyersCurrentYear ne '') then $global100TotalLawyersCurrentYear
												else $uk50IDTotalLawyersCurrentYear				
								
								let $totalLawyersPreyear := if($amlaw00IDTotalLawyerPreYear ne '') then $amlaw00IDTotalLawyerPreYear else
												if($global100IDTotallawyersPreYear ne '') then $global100IDTotallawyersPreYear
												else $uk50IDTotalLawyersPreYear

								let $grossRevPreviousYear := if($amlaw00IDPreYear ne 0) then $amlaw00IDPreYear else
												if($global100IDPreYear ne 0) then $global100IDPreYear
												else if($uk50IDPreYear) then $uk50IDPreYear else -1000

								let $revenuePreYear := if($amlaw00RevenuePreYear ne 0) then $amlaw00RevenuePreYear else
												if($global100RevenuePreYear ne 0) then $global100RevenuePreYear
												else $uk50RevenuePreYear

								let $revenueCurrentYear :=if($amlaw200RevenueCurrentYear ne '') then $amlaw200RevenueCurrentYear else
												if($global100RevenueCurrentYear ne '') then $global100RevenueCurrentYear
												else $uk50RevenueCurrentYear								
								
								let $resGrossRevenue := if(fn:not($amlaw200CurrentYear ne '') and fn:not($global100CurrentYear ne '') and fn:not($uk50IDCurrentYear ne '')) then -1000
													else if($grossRevPreviousYear ne -1000 and $grossRev ne -1000) then (($grossRev - $grossRevPreviousYear) div $grossRevPreviousYear) * 100 
														else -1000

								let $totalLawyers := $totalLawyersCurrentyear (:if(xs:string($totalLawyersCurrentyear) ne '0' and xs:string($totalLawyersPreyear) ne '') then ($totalLawyersCurrentyear - $totalLawyersPreyear) div $totalLawyersPreyear else():)
								let $revenue := $revenueCurrentYear (:if(xs:string($revenuePreYear) ne '0' and xs:string($revenuePreYear) ne '') then ($revenueCurrentYear - $revenuePreYear) div $revenuePreYear else ():)
								let $rpl1 := $resGrossRevenue
									
								let $_ := (
									map:put($response-obj,'ORGANIZATION_ID',xs:integer($OrganizationID)),
									map:put($response-obj,'ORGANIZATION_NAME',$organizationName),
									map:put($response-obj,'CHANGE', fn:round-half-to-even($rpl1,2)),
									map:put($response-obj,'PUBLISHYEAR',xs:integer($year)),
									map:put($response-obj,'TotalLawyers',fn:round-half-to-even($totalLawyers,2)),
									map:put($response-obj,'Revenue',$revenue),
									map:put($response-obj,'grossRev',$grossRev),
									map:put($response-obj,'grossRevPreviousYear',$grossRevPreviousYear)
								)

								let $_ :=if(xs:string($year) ne xs:string(max($distinctYears))) then json:array-push($response-arr,$response-obj) else
												if($maxYearData ne '' and $isAddMaxYear ne 'n') then json:array-push($response-arr,$response-obj) else()

	
								return()
	return () 

	(: combined data calculation :)
	

						
					
				(: let $data := for $year in (reverse($distinctYears))
							 	let $response-obj := json:object()
	
	
								

								let $amlaw200RevenueCurrentYear :=if(xs:string($isDisplayGBP) ne 'true') then cts:search(/,
																		cts:and-query((
																			cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
																			cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year)),
																			cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),fn:tokenize($OrganizationIDs,','))
																			)))//AMLAW_200:GROSS_REVENUE/text() else()											

								let $amlaw200TotalLawyerCurrentYear :=if(xs:string($isDisplayGBP) ne 'true') then cts:search(/,
																		cts:and-query((
																			cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
																			cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year)),
																			cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),fn:tokenize($OrganizationIDs,','))
																			)))//AMLAW_200:NUM_OF_LAWYERS/text() else()											

								

								let $amlaw00RevenuePreYear :=if(xs:string($isDisplayGBP) ne 'true') then cts:search(/,
											cts:and-query((
												cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
												cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string(xs:integer($year) - 1)),
												cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),fn:tokenize($OrganizationIDs,','))
												)))//AMLAW_200:GROSS_REVENUE/text() else()				

								let $amlaw00IDTotalLawyerPreYear :=if(xs:string($isDisplayGBP) ne 'true') then cts:search(/,
											cts:and-query((
												cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
												cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string(xs:integer($year) - 1)),
												cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),fn:tokenize($OrganizationIDs,','))
												)))//AMLAW_200:NUM_OF_LAWYERS/text() else()	

								

								let $global100RevenueCurrentYear := if(xs:string($isDisplayGBP) ne 'true') then cts:search(/,
																		cts:and-query((
																			cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
																			cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($year)),
																			cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),fn:tokenize($OrganizationIDs,','))
																			)))//Global_100:GROSS_REVENUE/text() else()

								let $global100TotalLawyersCurrentYear := if(xs:string($isDisplayGBP) ne 'true') then cts:search(/,
																		cts:and-query((
																			cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
																			cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($year)),
																			cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),fn:tokenize($OrganizationIDs,','))
																			)))//Global_100:NUM_LAWYERS/text() else()											

							

								let $global100RevenuePreYear := if(xs:string($isDisplayGBP) ne 'true') then cts:search(/,
											cts:and-query((
												cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
												cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string(xs:integer($year) - 1)),
												cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),fn:tokenize($OrganizationIDs,','))
												)))//Global_100:GROSS_REVENUE/text() else()				

								let $global100IDTotallawyersPreYear := if(xs:string($isDisplayGBP) ne 'true') then cts:search(/,
											cts:and-query((
												cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
												cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string(xs:integer($year) - 1)),
												cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),fn:tokenize($OrganizationIDs,','))
												)))//Global_100:NUM_LAWYERS/text() else()
							

							
								let $uk50RevenueCurrentYear := if(xs:string($isDisplayGBP) eq 'true') then cts:search(/,
																	cts:and-query((
																		cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
																		cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string($year)),
																		cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),fn:tokenize($OrganizationIDs,','))
																		)))//UK_50:RPL_POUND_K/text()

															else cts:search(/,
																			cts:and-query((
																				cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
																				cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string($year)),
																				cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),fn:tokenize($OrganizationIDs,','))
																				)))//UK_50:RPL_DOLLAR/text()

								let $uk50IDTotalLawyersCurrentYear := cts:search(/,
																			cts:and-query((
																				cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
																				cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string($year)),
																				cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),fn:tokenize($OrganizationIDs,','))
																				)))//UK_50:NUMBER_OF_LAWYERS/text()																

							

								let $uk50RevenuePreYear := if(xs:string($isDisplayGBP) eq 'true') then cts:search(/,
																cts:and-query((
																	cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
																	cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string(xs:integer($year) - 1)),
																	cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),fn:tokenize($OrganizationIDs,','))
																	)))//UK_50:GROSS_REVENUE_POUND_K/text()
													else cts:search(/,
																cts:and-query((
																	cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
																	cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string(xs:integer($year) - 1)),
																	cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),fn:tokenize($OrganizationIDs,','))
																	)))//UK_50:GROSS_REVENUE_DOLLAR/text()

								let $uk50IDTotalLawyersPreYear := cts:search(/,
																cts:and-query((
																	cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
																	cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string(xs:integer($year) - 1)),
																	cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),fn:tokenize($OrganizationIDs,','))
																	)))//UK_50:NUMBER_OF_LAWYERS/text()									

															
								
							

								let $totalLawyersCurrentyear := if($amlaw200TotalLawyerCurrentYear != '') then sum($amlaw200TotalLawyerCurrentYear) else
												if($global100TotalLawyersCurrentYear != '') then sum($global100TotalLawyersCurrentYear)
												else sum($uk50IDTotalLawyersCurrentYear				)
								
								let $totalLawyersPreyear := if($amlaw00IDTotalLawyerPreYear != '') then sum($amlaw00IDTotalLawyerPreYear) else
												if($global100IDTotallawyersPreYear != '') then sum($global100IDTotallawyersPreYear)
												else sum($uk50IDTotalLawyersPreYear)

							

								let $revenuePreYear := if($amlaw00RevenuePreYear) then sum($amlaw00RevenuePreYear) else
												if($global100RevenuePreYear) then sum($global100RevenuePreYear)
												else sum($uk50RevenuePreYear)

								let $revenueCurrentYear :=if($amlaw200RevenueCurrentYear) then sum($amlaw200RevenueCurrentYear) else
												if($global100RevenueCurrentYear) then sum($global100RevenueCurrentYear)
												else sum($uk50RevenueCurrentYear)
								
								
								let $combinedDataCurrentYear := ($revenueCurrentYear div $totalLawyersCurrentyear)
								let $combinedDataPreviousYear := ($revenuePreYear div $totalLawyersPreyear)
								(: let $combinedData := (($combinedDataCurrentYear - $combinedDataPreviousYear) div $combinedDataPreviousYear) * 100 :)
								let $combinedData := (($combinedDataCurrentYear - $combinedDataPreviousYear) div $combinedDataPreviousYear) * 100
								let $isAddMaxYear := if(xs:string($combinedDataCurrentYear) ne '' or xs:string($combinedDataPreviousYear) ne '') then 'y' else 'n' 
									
								let $_ := (
									map:put($response-obj,'ORGANIZATION_ID',0),
									map:put($response-obj,'ORGANIZATION_NAME','Combined1'),
									map:put($response-obj,'CHANGE', fn:round-half-to-even($combinedData,2)),
									map:put($response-obj,'combinedDataCurrentYear', fn:round-half-to-even($combinedDataCurrentYear,2)),
									map:put($response-obj,'combinedDataPreviousYear', fn:round-half-to-even($combinedDataPreviousYear,2)),
									map:put($response-obj,'revenueCurrentYear', fn:round-half-to-even($revenueCurrentYear,2)),
									map:put($response-obj,'totalLawyersCurrentyear', fn:round-half-to-even($totalLawyersCurrentyear,2)),
									map:put($response-obj,'revenuePreYear', fn:round-half-to-even($revenuePreYear,2)),
									map:put($response-obj,'totalLawyersPreyear', fn:round-half-to-even($totalLawyersPreyear,2)),
									map:put($response-obj,'revenuePreYear', fn:round-half-to-even($revenuePreYear,2)),
									map:put($response-obj,'amlaw200RevenueCurrentYear', $amlaw200RevenueCurrentYear),
									map:put($response-obj,'amlaw00RevenuePreYear', $amlaw00RevenuePreYear),
									map:put($response-obj,'totalLawyersPreyear', fn:round-half-to-even($totalLawyersPreyear,2)),
									map:put($response-obj,'PUBLISHYEAR',xs:integer($year))

									
									
								)

								let $_ := if($isAddMaxYear ne '') then json:array-push($response-arr,$response-obj) else()

	
								
	return () :)

	let $surveyData :=  for $year in (reverse($distinctYears))
						(:------------Global 200 part------------------:)
						let $response-obj := json:object()
						
						let $distinctid_global_100_Current  := cts:element-values(xs:QName("Global_100:ORGANIZATION_ID"),(),(),
							cts:and-query((
							cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/")      
							,cts:element-value-query(xs:QName("Global_100:PUBLISHYEAR"),xs:string($year))
							,cts:not-query(cts:element-value-query(xs:QName("Global_100:RANK_BY_GROSS_REVENUE"),""))
							,cts:element-range-query(xs:QName("Global_100:RANK_BY_GROSS_REVENUE"),"<=",100)
							)))
						
						let $res4 := xs:integer(avg(cts:search(/,
							cts:and-query((
							cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/") 
							,cts:element-value-query(xs:QName("Global_100:ORGANIZATION_ID"),($distinctid_global_100_Current ! xs:string(.)))
							,cts:element-value-query(xs:QName("Global_100:PUBLISHYEAR"), xs:string($year))
							,cts:element-range-query(xs:QName("Global_100:RANK_BY_GROSS_REVENUE"),"<=",100)
							)))//Global_100:REVENUE_PER_LAWYER/text()))
							
						let $distinctid_global_100  := cts:element-values(xs:QName("Global_100:ORGANIZATION_ID"),(),(),
							cts:and-query((
							cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/")      
							,cts:element-value-query(xs:QName("Global_100:PUBLISHYEAR"),xs:string(xs:integer($year) - 1))
							,cts:not-query(cts:element-value-query(xs:QName("Global_100:RANK_BY_GROSS_REVENUE"),""))
							,cts:element-range-query(xs:QName("Global_100:RANK_BY_GROSS_REVENUE"),"<=",100)
							)))
  
						let $lag4 := xs:integer(avg(cts:search(/,
							cts:and-query((
							cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/") 
							,cts:element-value-query(xs:QName("Global_100:ORGANIZATION_ID"),($distinctid_global_100 ! xs:string(.)))
							,cts:element-value-query(xs:QName("Global_100:PUBLISHYEAR"), xs:string(xs:integer($year) - 1))
							,cts:element-range-query(xs:QName("Global_100:RANK_BY_GROSS_REVENUE"),"<=",100)
							)))//Global_100:REVENUE_PER_LAWYER/text()))
							
						let $CHANGE :=if(fn:not(count($distinctid_global_100_Current) ne 0) or fn:not(count($distinctid_global_100) ne 0)) then -1000
										else if($res4 ne 0 and $lag4 ne 0) then fn:round-half-to-even((xs:double($res4 - $lag4) div  $lag4 ) * 100 , 2) else 0    
							
						let $_ := (
								map:put($response-obj,'ORGANIZATION_ID', 0),
							map:put($response-obj,'ORGANIZATION_NAME', 'Global 100'),
							map:put($response-obj,'CHANGE', $CHANGE),
							map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
							)
							let $_ :=json:array-push($response-arr, $response-obj)

						(:-------------------------AmLaw100---------------------------------:)
	
						let $response-obj := json:object()
						
							
						let $res2 := xs:integer(avg(cts:search(/,
											cts:and-query((
											cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/','1')
											,cts:element-range-query(xs:QName('AMLAW_200:AMLAW200_RANK'), '<=',100)
											,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'), xs:string($year))
											,cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
											)))//AMLAW_200:RPL/text()))
		
						
		
						let $res2-LAG :=xs:integer(avg(cts:search(/,
											cts:and-query((
											cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/','1')
											,cts:element-range-query(xs:QName('AMLAW_200:AMLAW200_RANK'), '<=',100)
											,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'), xs:string($year - 1))
											,cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
											)))//AMLAW_200:RPL/text()))  
	
						let $CHANGE :=  if($res2 ne 0 and $res2-LAG ne 0) then fn:round-half-to-even((xs:double(($res2 - $res2-LAG) div $res2-LAG)) * 100 ,2) else -1000
	
						let $_ := (
								map:put($response-obj,'ORGANIZATION_ID', 0),
							map:put($response-obj,'ORGANIZATION_NAME', 'Am Law 100'),
							map:put($response-obj,'CHANGE', $CHANGE),
							map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
							)
						let $_ := json:array-push($response-arr, $response-obj)

						(:------------------------------------Am Law 2nd Hundred---------------------------------------:)
	
						let $response-obj := json:object()

							
						let $res2 := xs:integer(avg(cts:search(/,
										cts:and-query((
										cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/','1')
										,cts:element-range-query(xs:QName('AMLAW_200:AMLAW200_RANK'), '>',100)
										,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'), xs:string($year))
										,cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
										)))//AMLAW_200:RPL/text()))
		
						
		
						let $res2-LAG := xs:integer(avg(cts:search(/,
											cts:and-query((
											cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/','1')
											,cts:element-range-query(xs:QName('AMLAW_200:AMLAW200_RANK'), '>',100)
											,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'), xs:string($year - 1))
											,cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
											)))//AMLAW_200:RPL/text()))
	
						let $CHANGE := if($res2 ne 0 and $res2-LAG ne 0) then fn:round-half-to-even((xs:double(($res2 - $res2-LAG) div $res2-LAG)) * 100 ,2) else 0
	
						let $_ := (
								map:put($response-obj,'ORGANIZATION_ID', 0),
							map:put($response-obj,'ORGANIZATION_NAME', 'Am Law 2nd Hundred'),
							map:put($response-obj,'CHANGE', $CHANGE),
							map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
							)
						let $_ := json:array-push($response-arr, $response-obj)

						(:------------------------UK50------------------------:)
							
						let $response-obj := json:object()
						let $distinctid_gt_100_Cur := fn:distinct-values(cts:search(/,
											cts:and-query((
												cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
												cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string($year))
												)))//UK_50:ORGANIZATION_ID/text())

						
						let $res3 := xs:integer(avg(cts:search(/,
												cts:and-query((
												cts:directory-query('/LegalCompass/relational-data/surveys/UK_50/','1')
												,cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),($distinctid_gt_100_Cur ! xs:string(.)))
												,cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'), xs:string($year))
												)))//UK_50:RPL_DOLLAR/text()))
							
						let $distinctid_gt_100  :=fn:distinct-values(cts:search(/,
											cts:and-query((
												cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
												cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string(xs:integer($year) - 1))
												)))//UK_50:ORGANIZATION_ID/text())
		
						let $res3-LAG := xs:integer(avg(cts:search(/,
											cts:and-query((
											cts:directory-query('/LegalCompass/relational-data/surveys/UK_50/','1')
											,cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),($distinctid_gt_100 ! xs:string(.)))
											,cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'), xs:string(xs:integer($year) -1))
											)))//UK_50:RPL_DOLLAR/text()))
		
						let $difference := $res3 - $res3-LAG

						let $CHANGE := if(fn:not($distinctid_gt_100_Cur != '') or fn:not($distinctid_gt_100 != '') ) then -1000
									else if($res3 ne 0 and $res3-LAG ne 0) then fn:round-half-to-even((xs:double($difference) div  $res3-LAG ) * 100 , 2) else 0
						
						let $_ :=(
							map:put($response-obj,'ORGANIZATION_ID', 0),
						map:put($response-obj,'ORGANIZATION_NAME', 'UK 100'),
						map:put($response-obj,'CHANGE', $CHANGE),
						map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
						)

						let $_ := if($uk50ID ne '') then json:array-push($response-arr, $response-obj)
								else()	

						return () 
	return $response-arr
};

declare function mergertool:GetCostPerLawyer($request)
{
	
	let $IsDisplayGBP := 'false'
	let $distinctYears := cts:element-attribute-values(xs:QName('survey:YEAR'),xs:QName('PublishYear'),(),('descending'),
							cts:and-query((
								cts:directory-query('/LegalCompass/denormalized-data/surveys/AMLAW_200/','1')
							)))

	let $distinctYears := if($request/StartYear/text() ne "" and $request/EndYear/text() ne "") then
								for $year in $distinctYears
								where $year >= xs:integer($request/StartYear/text()) and $year lt xs:integer($request/EndYear/text())
								return $year
								else $distinctYears[1 to 6]

	let $OrganizationIDs := $request//FirmID/text()

	let $response-arr := json:array()
	
	let $loopdata := for $OrganisationID in fn:tokenize($OrganizationIDs,',')	                      

						let $organization := cts:search(/organization,
							cts:and-query((
								cts:directory-query($config:DD-ORGANIZATION-PATH),
							cts:element-value-query(xs:QName('organization:ORGANIZATION_ID'),$OrganisationID)
							)))

						let $amlaw200maxYearData := cts:search(/,
									cts:and-query((
										cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
										cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string(max($distinctYears))),
										cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),xs:string($OrganisationID))
									)))[1]

						let $uk50maxYearData := cts:search(/,
								cts:and-query((
									cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
									cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string(fn:max($distinctYears))),
									cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),xs:string($OrganisationID))
								)))[1]		

						let $global100YearData := cts:search(/,
								cts:and-query((
									cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
									cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string(fn:max($distinctYears))),
									cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),xs:string($OrganisationID))
								)))[1]		

								let $maxYearData := if($uk50maxYearData ne '' or $amlaw200maxYearData ne '' or $global100YearData ne '') then 'Y' else ()			

	
						let $ORGANIZATION_NAME := if($organization//organization:ALM_NAME/text()) then 
											$organization//organization:ALM_NAME/text() 
										else $organization//organization:ORGANIZATION_NAME/text()

						let $loopData := for $year in (reverse($distinctYears))
									
									let $AMLAW_200_NODE := cts:search(/,
																cts:and-query((
																	cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
																	cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year)),
																	cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),xs:string($OrganisationID))
																	)))[1]
									
									let $uk50Data :=cts:search(/,
													cts:and-query((
														cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
														cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),xs:string($OrganisationID)),
														cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string($year))
														)))[1]
							
									let $global100Data :=cts:search(/,
																			cts:and-query((
																				cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
																				cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($year)),
																				cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),xs:string($OrganisationID))
																				)))[1]
									
									
									
									let $COSTPERLAWYER := if($AMLAW_200_NODE//AMLAW_200:NUM_OF_LAWYERS/text() ne '') then fn:round((xs:decimal(fn:sum($AMLAW_200_NODE//AMLAW_200:GROSS_REVENUE/text())) - xs:decimal(fn:sum($AMLAW_200_NODE//AMLAW_200:NET_OPERATING_INCOME/text()))) div xs:decimal(fn:sum($AMLAW_200_NODE//AMLAW_200:NUM_OF_LAWYERS/text()))) else 0
									
									let $amlawRevenue := $AMLAW_200_NODE//AMLAW_200:GROSS_REVENUE/text()
									let $amlawNOI := $AMLAW_200_NODE//AMLAW_200:NET_OPERATING_INCOME/text()
									let $amlawNumLawyers := $AMLAW_200_NODE//AMLAW_200:NUM_OF_LAWYERS/text()

									let $cplByUk50 := if($uk50Data//UK_50:NUMBER_OF_LAWYERS/text() ne '') then 
															if(xs:string($IsDisplayGBP) eq 'true') then fn:round-half-to-even((($uk50Data//UK_50:GROSS_REVENUE_POUND_M/text() * 1000000) - (($uk50Data//UK_50:PPP_POUND_K/text() * 1000) * $uk50Data//UK_50:NUMBER_OF_EQ_PARTNERS/text())) div $uk50Data//UK_50:NUMBER_OF_LAWYERS/text() ,2)
															else fn:round-half-to-even(($uk50Data//UK_50:GROSS_REVENUE_DOLLAR/text() - ($uk50Data//UK_50:PPP_DOLLAR/text() * $uk50Data//UK_50:NUMBER_OF_EQ_PARTNERS/text())) div $uk50Data//UK_50:NUMBER_OF_LAWYERS/text() ,2) 
													else()

									let $uk50Revenue := $uk50Data//UK_50:GROSS_REVENUE_DOLLAR/text()
									let $uk50NOI := ($uk50Data//UK_50:PPP_DOLLAR/text() * $uk50Data//UK_50:NUMBER_OF_EQ_PARTNERS/text())
									let $uk50NumLawyers := $uk50Data//UK_50:NUMBER_OF_LAWYERS/text()

									let $cplByGlobal100 := if($global100Data//Global_100:GROSS_REVENUE/text() ne '') then fn:round-half-to-even(($global100Data//Global_100:GROSS_REVENUE/text() - ($global100Data//Global_100:PPP/text() * $global100Data//Global_100:NUM_EQUITY_PARTNERS/text())) div $global100Data//Global_100:NUM_LAWYERS/text(),0) else 0
									let $globalrevenue := $global100Data//Global_100:GROSS_REVENUE/text()
									let $globalNOI := ($global100Data//Global_100:PPP/text() * $global100Data//Global_100:NUM_EQUITY_PARTNERS/text())
									let $globalnumLawyers:= $global100Data//Global_100:NUM_LAWYERS/text()
									
									let $cpl := if(fn:not($AMLAW_200_NODE ne '') and fn:not($global100Data ne '') and fn:not($uk50Data ne '')) then -1000
												else if($COSTPERLAWYER ne 0) then $COSTPERLAWYER else 
													if($cplByGlobal100 ne 0) then $cplByGlobal100
													else if($cplByUk50 ne 0) then $cplByUk50 else 0

									let $revenue := if($amlawRevenue) then $amlawRevenue
													else if($globalrevenue) then $globalrevenue
													else if($uk50Revenue) then $uk50Revenue else()

									let $noi := if($amlawNOI) then $amlawNOI
													else if($globalNOI) then $globalNOI
													else if($uk50NOI) then $uk50NOI else()

									let $numLawyers := 	if($amlawNumLawyers != '') then $amlawNumLawyers
													else if($globalnumLawyers != '') then $globalnumLawyers
													else if($uk50NumLawyers != '') then $uk50NumLawyers else()			

									let $isAddMaxYear := if(xs:string($year) ne xs:string(max($distinctYears))) then 'y' else
														if($cpl ne 0 and $cpl ne 0) then 'y' else 'n'			
									
									let $response-obj := json:object()
									let $_ := (
													map:put($response-obj, 'ORGANIZATION_ID', $OrganisationID),
													map:put($response-obj, 'ORGANIZATION_NAME', $ORGANIZATION_NAME),
													map:put($response-obj, 'COSTPERLAWYER', $cpl),
													map:put($response-obj, 'Revenue', $revenue),
													map:put($response-obj, 'NetOperatingIncome', $noi),
													map:put($response-obj, 'NumOfLawyers', $numLawyers),

													map:put($response-obj, 'PUBLISHYEAR', $year)
							    				)

									let $_ := if(xs:string($year) ne xs:string(max($distinctYears))) then json:array-push($response-arr,$response-obj) else
												if($maxYearData ne '' and $isAddMaxYear ne 'n') then json:array-push($response-arr,$response-obj) else()

									return()

		return()

	let $surveyData := 	for $year in (reverse($distinctYears))

						
							
							let $AMLAW_100 :=fn:avg(cts:search(/,
								cts:and-query((
								cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/','1')
								(: ,cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),($distinctid_lt_100 ! xs:string(.))) :)
								,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'), xs:string($year))
								,cts:element-range-query(xs:QName('AMLAW_200:AMLAW200_RANK'), '<=',100)
								,cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
								)))//AMLAW_200:CPL/text())
    
    
		let $COSTPERLAWYER := $AMLAW_100

		let $response-obj := json:object()
		let $_ := (
			map:put($response-obj, 'ORGANIZATION_ID', 0),
			map:put($response-obj, 'ORGANIZATION_NAME', 'AM Law 100'),
			map:put($response-obj, 'COSTPERLAWYER', fn:round-half-to-even($COSTPERLAWYER,2)),
			map:put($response-obj, 'PUBLISHYEAR', $year)
		)
		let $_ := json:array-push($response-arr,$response-obj)

    	
    
		let $SECOND_100 := fn:avg(cts:search(/,
		cts:and-query((
		cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/','1')
		,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'), xs:string($year))
		,cts:element-range-query(xs:QName('AMLAW_200:AMLAW200_RANK'), '>',100)
		,cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
		)))//AMLAW_200:CPL/text())

		let $COSTPERLAWYER := $SECOND_100

		let $response-obj := json:object()
		let $_ := (
			map:put($response-obj, 'ORGANIZATION_ID', 0),
			map:put($response-obj, 'ORGANIZATION_NAME', 'Am Law 2nd Hundred'),
			map:put($response-obj, 'COSTPERLAWYER', fn:round-half-to-even($COSTPERLAWYER,2)),
			map:put($response-obj, 'PUBLISHYEAR', xs:integer($year))
		)
		let $_ :=json:array-push($response-arr,$response-obj)
		return()

	return $response-arr
};

declare function mergertool:GetProfitMargin($request)
{

	let $IsDisplayGBP := 'false'
	let $distinctYears := cts:element-attribute-values(xs:QName('survey:YEAR'),xs:QName('PublishYear'),(),('descending'),
		cts:and-query((
			cts:directory-query('/LegalCompass/denormalized-data/surveys/AMLAW_200/','1')
		)))

	let $uk50ID := cts:search(/,
						cts:and-query((
							cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/")(:,
							cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string($year)):),
							cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),fn:tokenize($request//FirmID/text(),','))
							)))//UK_50:ORGANIZATION_ID/text()	

	let $response-arr := json:array()
	let $loopData := for $OrganizationID in fn:tokenize($request//FirmID/text(),',')

						let $organizationName := if((/organization[organization:ORGANIZATION_ID = xs:string($OrganizationID)]/organization:ALM_NAME/text())[1] ne '') then 
								/organization[organization:ORGANIZATION_ID = xs:string($OrganizationID)]/organization:ALM_NAME/text()[1]
							else 
								/organization[organization:ORGANIZATION_ID = xs:string($OrganizationID)]/organization:ORGANIZATION_NAME/text()[1]
						
						let $amlaw200maxYearData := cts:search(/,
									cts:and-query((
										cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
										cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string(max($distinctYears))),
										cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),xs:string($OrganizationID))
									)))[1]

						let $uk50maxYearData := cts:search(/,
								cts:and-query((
									cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
									cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string(fn:max($distinctYears))),
									cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),xs:string($OrganizationID))
								)))[1]		

						let $global100YearData := cts:search(/,
								cts:and-query((
									cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
									cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string(fn:max($distinctYears))),
									cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),xs:string($OrganizationID))
								)))[1]		

								let $maxYearData := if($uk50maxYearData ne '' or $amlaw200maxYearData ne '' or $global100YearData ne '') then 'Y' else ()			

						let $data := for $year in fn:reverse($distinctYears[1 to 5])
		
											let $res := if(xs:string($IsDisplayGBP) ne 'true') then cts:search(/,
																cts:and-query((
																	cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
																	cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year)),
																	cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),xs:string($OrganizationID))
																	)))[1] else()

											let $Margin := (xs:double(fn:format-number((xs:double($res//AMLAW_200:NET_OPERATING_INCOME/text()) div xs:double($res//AMLAW_200:GROSS_REVENUE/text())),'.00')) * 100)

											let $global100CurrentYear :=if(xs:string($IsDisplayGBP) ne 'true') then  cts:search(/,
																					cts:and-query((
																						cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
																						cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($year)),
																						cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),xs:string($OrganizationID))
																						)))[1] else()

										

											let $global100Change := if($global100CurrentYear ne '') then (xs:double($global100CurrentYear//Global_100:PPP/text()) * xs:double($global100CurrentYear//Global_100:NUM_EQUITY_PARTNERS/text())) * 100
																		div xs:double($global100CurrentYear//Global_100:GROSS_REVENUE/text()) else ()

											let $global100NOI := if($global100CurrentYear ne '') then (xs:double($global100CurrentYear//Global_100:PPP/text()) * xs:double($global100CurrentYear//Global_100:NUM_EQUITY_PARTNERS/text())) * 100
																	 else ()							

		
											let $uk50IDCurrentYear := cts:search(/,
																					cts:and-query((
																						cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
																						cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string($year)),
																						cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),xs:string($OrganizationID))
																						)))[1]
											let $uk50NOI := if($uk50IDCurrentYear ne '') then (xs:double($uk50IDCurrentYear//UK_50:PPP_DOLLAR/text()) * xs:double($uk50IDCurrentYear//UK_50:NUMBER_OF_EQ_PARTNERS/text())) * 100
																	 else ()											

											let $revenue := if($res//AMLAW_200:GROSS_REVENUE/text()) then $res//AMLAW_200:GROSS_REVENUE/text() else
															if($global100CurrentYear//Global_100:GROSS_REVENUE/text()) then $global100CurrentYear//Global_100:GROSS_REVENUE/text() else
															if($uk50IDCurrentYear//UK_50:GROSS_REVENUE_DOLLAR/text()) then $uk50IDCurrentYear//UK_50:GROSS_REVENUE_DOLLAR/text()	else()										

										    let $noi :=if($res != '') then $res//AMLAW_200:NET_OPERATING_INCOME/text() * 100 else
															if($global100NOI) then $global100NOI else
															if($uk50NOI) then $uk50NOI else()									
											
											
											let $Margin1 :=if(fn:not($res ne '') and fn:not($global100CurrentYear ne '') and fn:not($uk50IDCurrentYear ne '')) then -1000
														else if($Margin ne 0 and xs:string($Margin) ne 'NaN') then $Margin else
																if(xs:string($global100Change) ne '' and xs:string($global100Change) ne '0' and xs:string($global100Change) ne 'NaN') then $global100Change 
																else if($uk50IDCurrentYear ne '') then ($uk50IDCurrentYear//UK_50:PROFIT_MARGIN/text() * 100) else 0

											let $isAddMaxYear := if(xs:string($year) ne xs:string(max($distinctYears))) then 'y' else
																if($Margin1 ne 0 and $Margin1 ne 0) then 'y' else 'n' 							
		
											let $response-obj := json:object()
											let $_ := (
												map:put($response-obj,'ORGANIZATION_ID',xs:integer($OrganizationID)),
												map:put($response-obj,'ORGANIZATION_NAME',$organizationName),
												map:put($response-obj,'MARGIN', $Margin1),
												map:put($response-obj,'PUBLISHYEAR',xs:integer($year)),
												map:put($response-obj,'NetOperatingIncome',$noi),
												map:put($response-obj,'Revenue',$revenue)
											)

											let $_ :=if(xs:string($year) ne xs:string(max($distinctYears))) then json:array-push($response-arr,$response-obj) else
														if($maxYearData ne '' and $isAddMaxYear ne 'n') then json:array-push($response-arr,$response-obj) else()

											return()
		return  ()

		let $surveyData := for $year in fn:reverse($distinctYears[1 to 5])
								(: ----------------------Global100------------------------- :)
								let $res := cts:search(/,
									cts:and-query((	
										cts:directory-query('/LegalCompass/relational-data/surveys/Global_100/')
										,cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($year))
									)))[1]

								let $profitMargin := fn:avg(cts:search(/,
									cts:and-query((	
										cts:directory-query('/LegalCompass/relational-data/surveys/Global_100/')
										,cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($year))
										,cts:not-query(cts:element-value-query(xs:QName("Global_100:RANK_BY_GROSS_REVENUE"),""))
									)))//Global_100:PROFIT_MARGIN/text())
								
								let $Margin :=if(fn:not($res ne '')) then -1000
											else $profitMargin
								
								let $response-obj := json:object()
								let $_ := (
									map:put($response-obj,'ORGANIZATION_ID',0),
									map:put($response-obj,'ORGANIZATION_NAME', 'Global 200'),
									map:put($response-obj,'MARGIN', $Margin), 
									map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
								)
								let $_ :=json:array-push($response-arr, $response-obj)
		
								(: -------------------------AM Law 100---------------------- :)
								
								let $res := fn:avg(cts:search(/,
									cts:and-query((
										cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/')
										,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year))
										,cts:element-range-query(xs:QName('AMLAW_200:AMLAW200_RANK'), '<=',100)
										,cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
									)))//AMLAW_200:PROFIT_MARGIN_AVG/text())

								let $res1 := cts:search(/,
									cts:and-query((
										cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/')
										,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year))
										,cts:element-range-query(xs:QName('AMLAW_200:AMLAW200_RANK'), '<=',100)
										,cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
									)))[1]	
							
								
								let $Margin := if(fn:not($res1 ne '')) then -1000 else fn:round-half-to-even($res *100 ,2)
							
								let $response-obj := json:object()
								let $_ := (
									map:put($response-obj,'ORGANIZATION_ID',0),
									map:put($response-obj,'ORGANIZATION_NAME', 'AM Law 100'),
									map:put($response-obj,'MARGIN', $Margin),
									map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
								)
		
								let $_ := json:array-push($response-arr, $response-obj)

								(: -------------------------Am Law 2nd Hundred---------------------- :)
								
								let $res := fn:avg(cts:search(/,
									cts:and-query((
										cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/')
										,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year))
										,cts:element-range-query(xs:QName('AMLAW_200:AMLAW200_RANK'), '>',100)
										,cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
									)))//AMLAW_200:PROFIT_MARGIN_AVG/text())

								let $res1 := cts:search(/,
									cts:and-query((
										cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/')
										,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year))
										,cts:element-range-query(xs:QName('AMLAW_200:AMLAW200_RANK'), '>',100)
										,cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
									)))[1]
								
								let $Margin := if(fn:not($res1 ne '')) then -1000 else fn:round-half-to-even($res *100 ,2)
							
								let $response-obj := json:object()
								let $_ := (
									map:put($response-obj,'ORGANIZATION_ID',0),
									map:put($response-obj,'ORGANIZATION_NAME', 'Am Law 2nd Hundred'),
									map:put($response-obj,'MARGIN', $Margin),
									map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
								)
		
								let $_ := json:array-push($response-arr, $response-obj)
		
		
		
									(:------------------------UK50------------------------:)
									
								let $response-obj := json:object()
								
								

								let $distinctid_gt_100 := fn:distinct-values(cts:search(/,
													cts:and-query((
														cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
														cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string($year))
														)))//UK_50:ORGANIZATION_ID/text())

								
								let $res3 := if($distinctid_gt_100 != '') then (avg(cts:search(/,
														cts:and-query((
														cts:directory-query('/LegalCompass/relational-data/surveys/UK_50/','1')
														,cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),($distinctid_gt_100 ! xs:string(.)))
														,cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'), xs:string($year))
														)))//UK_50:PROFIT_MARGIN/text()) * 100) else -1000
								
								let $_ :=(
									map:put($response-obj,'ORGANIZATION_ID', 0),
								map:put($response-obj,'ORGANIZATION_NAME', 'UK 100'),
								map:put($response-obj,'MARGIN', fn:round-half-to-even(($res3),2)),
								map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
								)
								let $_ := if($uk50ID != '') then json:array-push($response-arr, $response-obj)
										else()	

								return()


	return $response-arr
};

declare function mergertool:GetProfitPerEquityPartnerChanges($request)
{
	let $distinctYears := cts:element-attribute-values(xs:QName('survey:YEAR'),xs:QName('PublishYear'),(),('ascending'),
								cts:directory-query($config:DD-SURVEY-AMLAW_200-PATH))

	let $uk50ID := cts:search(/,
											cts:and-query((
												cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/")(:,
												cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string($PUBLISHYEAR)):),
												cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),fn:tokenize($request//FirmID/text(),','))
												)))//UK_50:ORGANIZATION_ID/text()							
	
	let $isDisplayGBP := 'false'
	let $response-arr := json:array()
	let $years := 	$distinctYears[last()-5 to last()]
						
						let $yr := for $item in $years
									order by xs:integer($item) descending
									return $item

	let $loopData := for $OrganizationID in fn:tokenize($request//FirmID/text(),',')

						let $organizationName := if((/organization[organization:ORGANIZATION_ID = xs:string($OrganizationID)]/organization:ALM_NAME/text())[1] ne '') then 
								/organization[organization:ORGANIZATION_ID = xs:string($OrganizationID)]/organization:ALM_NAME/text()[1]
							else 
								/organization[organization:ORGANIZATION_ID = xs:string($OrganizationID)]/organization:ORGANIZATION_NAME/text()[1]
						
						let $amlaw200maxYearData := cts:search(/,
									cts:and-query((
										cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
										cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string(max($distinctYears))),
										cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),xs:string($OrganizationID))
									)))[1]
						
						let $uk50maxYearData := cts:search(/,
								cts:and-query((
									cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
									cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string(fn:max($distinctYears))),
									cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),xs:string($OrganizationID))
								)))[1]		

						let $global100YearData := cts:search(/,
								cts:and-query((
									cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
									cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string(fn:max($distinctYears))),
									cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),xs:string($OrganizationID))
								)))[1]		

								let $maxYearData := if($uk50maxYearData ne '' or $amlaw200maxYearData ne '' or $global100YearData ne '') then 'Y' else ()			

						
						let $org := cts:search(/organization,
							cts:and-query((
								cts:directory-query($config:DD-ORGANIZATION-PATH)
								,cts:element-value-query(xs:QName('organization:ORGANIZATION_ID'),$OrganizationID)
							)))[1]

								
						
						

						let $data := for $PUBLISHYEAR in $years

											let $pYear := xs:string((xs:integer($PUBLISHYEAR) - 1))
											let $qYear := xs:string(xs:integer($PUBLISHYEAR))

						(: -------------------------------------------------------------- 01 -------------------------------------------------------------- :)
											
											let $RPL := ''
											let $LAGV := ''
											let $CHANGE := ''

											let $RPL := if(xs:string($isDisplayGBP) ne 'true') then cts:search(/,
																cts:and-query((
																	cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
																	cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($qYear)),
																	cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),xs:string($OrganizationID))
																	)))[1] else()

											let $LAGV := if(xs:string($isDisplayGBP) ne 'true') then cts:search(/,
																cts:and-query((
																	cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
																	cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($pYear)),
																	cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),xs:string($OrganizationID))
																	)))[1] else()

											let $CHANGE := fn:round-half-to-even((((xs:double($RPL//AMLAW_200:PPP/text()) - xs:double($LAGV//AMLAW_200:PPP/text())) div xs:double($LAGV//AMLAW_200:PPP/text())) * 100),2)
											let $amlawNOICurrentYear :=   $RPL//AMLAW_200:NET_OPERATING_INCOME/text()

											let $amlawNOIPreYear := $LAGV//AMLAW_200:NET_OPERATING_INCOME/text() 

											let $amlawNOI := fn:round-half-to-even((((xs:double($amlawNOICurrentYear) - xs:double($amlawNOIPreYear)) div xs:double($amlawNOIPreYear)) * 100),2)

											let $amlawPartnersCurrentYear :=   $RPL//AMLAW_200:NUM_EQ_PARTNERS/text()

											let $amlawPartnersPreYear := $LAGV//AMLAW_200:NUM_EQ_PARTNERS/text() 	

											let $amlawPartners := fn:round-half-to-even((((xs:double($amlawPartnersCurrentYear) - xs:double($amlawPartnersPreYear)) div xs:double($amlawPartnersPreYear)) * 100),2)

											let $global100CurrentYear :=if(xs:string($isDisplayGBP) ne 'true') then cts:search(/,
																					cts:and-query((
																						cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
																						cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($PUBLISHYEAR)),
																						cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),xs:string($OrganizationID))
																						)))[1] else()

											let $global100IDPreYear := if(xs:string($isDisplayGBP) ne 'true') then cts:search(/,
														cts:and-query((
															cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
															cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string(xs:integer($PUBLISHYEAR) - 1)),
															cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),xs:string($OrganizationID))
															)))[1] else()
											
											let $global100NOICurrentYear := if($global100CurrentYear ne '') then (xs:double($global100CurrentYear//Global_100:PPP/text()) * xs:double($global100CurrentYear//Global_100:NUM_EQUITY_PARTNERS/text()))
																	 else ()

											let $global100NOIPreyear := if($global100IDPreYear ne '') then (xs:double($global100IDPreYear//Global_100:PPP/text()) * xs:double($global100IDPreYear//Global_100:NUM_EQUITY_PARTNERS/text())) * 100
																	 else ()

											let $global100PartnersCurrentYear := if($global100CurrentYear ne '') then $global100CurrentYear//Global_100:NUM_EQUITY_PARTNERS/text() else ()

											let $global100PartnersPreyear := if($global100IDPreYear ne '') then $global100IDPreYear//Global_100:NUM_EQUITY_PARTNERS/text() else ()						 						 				

											let $global100Change := if($global100IDPreYear//Global_100:PPP/text() ne 0) then (($global100CurrentYear//Global_100:PPP/text() - $global100IDPreYear//Global_100:PPP/text()) div $global100IDPreYear//Global_100:PPP/text()) * 100 else 0

											let $global100PartnerChange := if($global100PartnersCurrentYear) then (($global100PartnersCurrentYear - $global100PartnersPreyear) div $global100PartnersPreyear) * 100 else 0

											let $global100NOIChange := if($global100NOICurrentYear) then (($global100NOICurrentYear - $global100NOIPreyear) div $global100NOIPreyear) * 100 else 0

											let $uk50CurrentYearData := cts:search(/,
																				cts:and-query((
																					cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
																					cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string($PUBLISHYEAR)),
																					cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),xs:string($OrganizationID))
																					)))[1]

											let $uk50PreYearData := cts:search(/,
																				cts:and-query((
																					cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
																					cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string(xs:integer($PUBLISHYEAR - 1))),
																					cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),xs:string($OrganizationID))
																					)))[1]

											let $uk50NOICurrentYear := if($uk50CurrentYearData ne '') then (xs:double($uk50CurrentYearData//UK_50:PPP_DOLLAR/text()) * xs:double($uk50CurrentYearData//UK_50:NUMBER_OF_EQ_PARTNERS/text()))
																	 else ()

											let $uk50NOIPreYear := if($uk50PreYearData ne '') then (xs:double($uk50PreYearData//UK_50:PPP_DOLLAR/text()) * xs:double($uk50PreYearData//UK_50:NUMBER_OF_EQ_PARTNERS/text()))
																	 else ()

											let $uk50PartnersCurrentYear := if($uk50CurrentYearData ne '') then $uk50CurrentYearData//UK_50:NUMBER_OF_EQ_PARTNERS/text()
																	 else ()

											let $uk50PartnersPreYear := if($uk50PreYearData ne '') then $uk50PreYearData//UK_50:NUMBER_OF_EQ_PARTNERS/text() else ()						 

											let $uk50NOIChange := if($uk50NOIPreYear) then (($uk50NOICurrentYear - $uk50NOIPreYear) div $uk50NOIPreYear) * 100 else 0

											let $uk50PartnerChange := if($uk50PartnersPreYear) then (($uk50PartnersCurrentYear - $uk50PartnersPreYear) div $uk50PartnersPreYear) * 100 else 0

											let $uk50IDCurrentYear := if(xs:string($isDisplayGBP) eq 'true') then $uk50CurrentYearData//UK_50:PPP_POUND_K/text()
																	else $uk50CurrentYearData//UK_50:PPP_DOLLAR/text()
								    
											let $uk50IDPreYear := if(xs:string($isDisplayGBP) eq 'true') then $uk50PreYearData//UK_50:PPP_POUND_K/text()
																else $uk50PreYearData//UK_50:PPP_DOLLAR/text()													

											let $grossRev := if(xs:string($RPL//AMLAW_200:PPP/text()) ne '') then $RPL//AMLAW_200:PPP/text() else
															if(xs:string($global100CurrentYear//Global_100:PPP/text()) ne '') then $global100CurrentYear//Global_100:PPP/text()
															else $uk50IDCurrentYear

											let $grossRevPreviousYear := if(xs:string($LAGV//AMLAW_200:PPP/text()) ne '') then $LAGV//AMLAW_200:PPP/text() else
															if(xs:string($global100IDPreYear//Global_100:PPP/text()) ne '') then $global100IDPreYear//Global_100:PPP/text()
															else $uk50IDPreYear				

											let $noiCurrentYear := if(xs:string($amlawNOICurrentYear) ne '') then $amlawNOICurrentYear else
															if(xs:string($global100NOICurrentYear) ne '') then $global100NOICurrentYear
															else $uk50NOICurrentYear				
											
											let $noiPreviousYear := if(xs:string($amlawNOIPreYear) ne '') then $amlawNOIPreYear else
															if(xs:string($global100NOIPreyear) ne '') then $global100NOIPreyear
															else $uk50NOIPreYear

											let $totalPartnerssCurrentYear := if(xs:string($amlawPartnersCurrentYear) ne '') then $amlawPartnersCurrentYear else
															if(xs:string($global100PartnersCurrentYear) ne '') then $global100PartnersCurrentYear
															else $uk50PartnersCurrentYear				
											
											let $totalPartnersPreviousYear := if(xs:string($amlawPartnersPreYear) ne '') then $amlawPartnersPreYear else
															if($global100PartnersPreyear ne '') then $global100PartnersPreyear
															else $uk50PartnersPreYear									

											
											let $isAddMaxYear := if(xs:string($PUBLISHYEAR) ne xs:string(max($distinctYears))) then 'y' else
																if($RPL ne '' or $global100CurrentYear ne '' or $uk50IDCurrentYear ne '') then 'y' else 'n'

											let $ppp := if(fn:not(xs:string($RPL) ne '') and fn:not($global100CurrentYear ne '') and fn:not($uk50IDCurrentYear ne '')) then -1000
														else if($grossRevPreviousYear ne 0 and $grossRev ne 0) then (($grossRev - $grossRevPreviousYear) div $grossRevPreviousYear) * 100 else -1000

											let $noi := if(xs:string($noiPreviousYear) ne '') then (($noiCurrentYear - $noiPreviousYear) div $noiPreviousYear) * 100 else 0

											let $totalPartners := if(xs:string($totalPartnersPreviousYear)) then (($totalPartnerssCurrentYear - $totalPartnersPreviousYear) div $totalPartnersPreviousYear) * 100 else 0						
											let $pppCurrentYear := $noiCurrentYear div $totalPartnerssCurrentYear
											let $pppPreviousYear := $noiPreviousYear div $totalPartnersPreviousYear
											let $ppp := fn:round-half-to-even((($pppCurrentYear - $pppPreviousYear) div $pppPreviousYear) * 100 ,2)
											let $ppp := if(fn:not(xs:string($RPL) ne '') and fn:not($global100CurrentYear ne '') and fn:not($uk50IDCurrentYear ne '')) then -1000
														else if($grossRevPreviousYear ne 0 and $grossRev ne 0) then (($grossRev - $grossRevPreviousYear) div $grossRevPreviousYear) * 100 else -1000


											let $response-obj := json:object()
											let $_ := (
												map:put($response-obj, 'ORGANIZATION_ID', $OrganizationID),
												map:put($response-obj, 'ORGANIZATION_NAME', $organizationName),
												map:put($response-obj, 'CHANGE', fn:round-half-to-even($ppp,2)),
												map:put($response-obj, 'NetOperatingIncome', fn:round-half-to-even($noiCurrentYear,2)),
												map:put($response-obj, 'TotalPartners', fn:round-half-to-even($totalPartnerssCurrentYear,2)),
												map:put($response-obj, 'PUBLISHYEAR', $PUBLISHYEAR)
											)
											let $_ :=if(xs:string($PUBLISHYEAR) ne xs:string(max($distinctYears))) then json:array-push($response-arr,$response-obj) else
														if($maxYearData ne '' and $isAddMaxYear ne 'n') then json:array-push($response-arr,$response-obj) else()

											return()
  											return ()

	let $surveyData := for $PUBLISHYEAR in $years
						(: --------------------02 Golobal_100Part -------------------- :)
		
	
						let $response-obj := json:object()
					
						let $distinctid_global_100_Current  := cts:element-values(xs:QName("Global_100:ORGANIZATION_ID"),(),(),
									cts:and-query((
									cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/")      
									,cts:element-value-query(xs:QName("Global_100:PUBLISHYEAR"),xs:string($PUBLISHYEAR))
									,cts:not-query(cts:element-value-query(xs:QName("Global_100:RANK_BY_GROSS_REVENUE"),""))
									)))
					
						let $res4 := xs:decimal(avg(cts:search(/,
									cts:and-query((
									cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/") 
									,cts:element-value-query(xs:QName("Global_100:ORGANIZATION_ID"),($distinctid_global_100_Current ! xs:string(.)))
									,cts:element-value-query(xs:QName("Global_100:PUBLISHYEAR"), xs:string($PUBLISHYEAR))
									)))//Global_100:PPP/text()))
					
						let $distinctid_global_100  := cts:element-values(xs:QName("Global_100:ORGANIZATION_ID"),(),(),
									cts:and-query((
									cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/")      
									,cts:element-value-query(xs:QName("Global_100:PUBLISHYEAR"),xs:string($PUBLISHYEAR - 1))
									,cts:not-query(cts:element-value-query(xs:QName("Global_100:RANK_BY_GROSS_REVENUE"),""))
									)))
  
						let $lag4 := xs:integer(avg(cts:search(/,
									cts:and-query((
									cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/") 
									,cts:element-value-query(xs:QName("Global_100:ORGANIZATION_ID"),($distinctid_global_100 ! xs:string(.)))
									,cts:element-value-query(xs:QName("Global_100:PUBLISHYEAR"), xs:string($PUBLISHYEAR - 1))
									)))//Global_100:PPP/text()))
    
						let $CHANGE :=if(fn:not(count($distinctid_global_100_Current) ne 0) or fn:not(count($distinctid_global_100) ne 0)) then -1000
									  else if($res4 ne 0 and $lag4 ne 0) then fn:round-half-to-even((xs:double($res4 - $lag4) div  $lag4 ) * 100 , 2) else 0

						let $response-obj := json:object()
							let $_ := (
									map:put($response-obj, 'ORGANIZATION_ID', 0),
									map:put($response-obj, 'ORGANIZATION_NAME', 'Global 200'),
									map:put($response-obj, 'CHANGE', $CHANGE),
									map:put($response-obj, 'PUBLISHYEAR', xs:integer($PUBLISHYEAR))
								)
								let $_ := json:array-push($response-arr,$response-obj)	
        
						(: ---------------------- 03 ---------------------- :)
		
						

						let $res2 := xs:decimal(avg(cts:search(/,
							cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/','1')
							(: ,cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),($distinctid_lt_100_Current ! xs:string(.))) :)
							,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'), xs:string($PUBLISHYEAR))
							,cts:element-range-query(xs:QName('AMLAW_200:AMLAW200_RANK'), '<=',100)
							,cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
							)))//AMLAW_200:PPP/text()))
						let $response-obj := json:object()
							
							
						let $res2-LAG := xs:decimal(avg(cts:search(/,
							cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/','1')
							(: ,cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),($distinctid_global_100 ! xs:string(.))) :)
							,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'), xs:string($PUBLISHYEAR -1))
							,cts:element-range-query(xs:QName('AMLAW_200:AMLAW200_RANK'), '<=',100)
							,cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
							)))//AMLAW_200:PPP/text()))
		
						let $CHANGE := if($res2 ne 0 and $res2-LAG ne 0) then fn:round-half-to-even((xs:double($res2 - $res2-LAG) div  $res2-LAG ) * 100 , 2) else 0
						
						let $_ := (
								map:put($response-obj,'ORGANIZATION_ID', 0),
							map:put($response-obj,'ORGANIZATION_NAME', 'Am Law 100'),
							map:put($response-obj,'CHANGE', $CHANGE),
							map:put($response-obj,'PUBLISHYEAR',xs:integer($PUBLISHYEAR))
							)
						
						let $_ := json:array-push($response-arr, $response-obj)

						(: ---------------------- 04 ---------------------- :)
		
						

						let $res2 := xs:decimal(avg(cts:search(/,
							cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/','1')
							,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'), xs:string($PUBLISHYEAR))
							,cts:element-range-query(xs:QName('AMLAW_200:AMLAW200_RANK'), '>',100)
							,cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
							)))//AMLAW_200:PPP/text()))
						let $response-obj := json:object()
							
					
							
						let $res2-LAG := xs:decimal(avg(cts:search(/,
							cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/','1')
							,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'), xs:string($PUBLISHYEAR -1))
							,cts:element-range-query(xs:QName('AMLAW_200:AMLAW200_RANK'), '>',100)
							,cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
							)))//AMLAW_200:PPP/text()))
		
						let $CHANGE := if($res2 ne 0 and $res2-LAG ne 0) then fn:round-half-to-even((xs:double($res2 - $res2-LAG) div  $res2-LAG ) * 100 , 2) else 0
						
						let $_ := (
								map:put($response-obj,'ORGANIZATION_ID', 0),
							map:put($response-obj,'ORGANIZATION_NAME', 'Am Law 2nd Hundred'),
							map:put($response-obj,'CHANGE', $CHANGE),
							map:put($response-obj,'PUBLISHYEAR',xs:integer($PUBLISHYEAR))
							)
						
						let $_ := json:array-push($response-arr, $response-obj)

					
						(:------------------------UK50------------------------:)
							
						let $response-obj := json:object()

						let $distinctid_gt_100_Cur := fn:distinct-values(cts:search(/,
							cts:and-query((
								cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
								cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string($PUBLISHYEAR))
								)))//UK_50:ORGANIZATION_ID/text())

	
						let $res3 := avg(cts:search(/,
											cts:and-query((
											cts:directory-query('/LegalCompass/relational-data/surveys/UK_50/','1')
											,cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),($distinctid_gt_100_Cur ! xs:string(.)))
											,cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'), xs:string($PUBLISHYEAR))
											)))//UK_50:PPP_DOLLAR/text())
						
						let $distinctid_gt_100  :=fn:distinct-values(cts:search(/,
										cts:and-query((
											cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
											cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string(xs:integer($PUBLISHYEAR) - 1))
											)))//UK_50:ORGANIZATION_ID/text())
						
						let $res3-LAG := avg(cts:search(/,
											cts:and-query((
											cts:directory-query('/LegalCompass/relational-data/surveys/UK_50/','1')
											,cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),($distinctid_gt_100 ! xs:string(.)))
											,cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'), xs:string(xs:integer($PUBLISHYEAR) -1))
											)))//UK_50:PPP_DOLLAR/text())
		
						let $difference := $res3 - $res3-LAG

						let $CHANGE :=if(fn:not(count($distinctid_gt_100_Cur) ne 0) or fn:not(count($distinctid_gt_100) ne 0)) then -1000
									else if($res3 ne 0 and $res3-LAG ne 0) then fn:round-half-to-even((xs:double($difference) div  $res3-LAG ) * 100 , 2) else 0
						
						let $_ :=(
							map:put($response-obj,'ORGANIZATION_ID', 0),
						map:put($response-obj,'ORGANIZATION_NAME', 'UK 100'),
						map:put($response-obj,'CHANGE', $CHANGE),
						map:put($response-obj,'PUBLISHYEAR',xs:integer($PUBLISHYEAR))
						)
						let $_ :=if($uk50ID != '' ) then json:array-push($response-arr, $response-obj)
								else()	
				
						return ()										  
	return $response-arr
};

declare function mergertool:GetProfitPerEquityPartner($request)
{
	let $isDisplayGBP := $request/IsDisplayGBP/text()
	let $IsDisplayGBP := if($isDisplayGBP ne '') then $isDisplayGBP else 'false'
	let $distinctYears := cts:element-attribute-values(xs:QName('survey:YEAR'),xs:QName('PublishYear'),(),('descending'),
							cts:and-query((
							cts:directory-query('/LegalCompass/denormalized-data/surveys/AMLAW_200/','1')
							)))

	let $distinctYears := if($request/StartYear/text() ne '' and $request/EndYear/text() ne '') then
									for $year in $distinctYears
									where ($year ge xs:integer($request/StartYear/text()) and   $year le xs:integer($request/EndYear/text()))
									return $year
									else $distinctYears[1 to 5]

	let $uk50ID := cts:search(/,
						cts:and-query((
							cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
							cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),fn:tokenize($request/FirmID/text(),','))
							)))//UK_50:ORGANIZATION_ID/text()								

	let $response-arr := json:array()

	let $loopData := for $organizationID in  fn:tokenize($request/FirmID/text(),',')
							let $organization := fn:doc(fn:concat('/LegalCompass/denormalized-data/organization/',$request//OrganisationID,'.xml'))
							
							let $organizationName := if((/organization[organization:ORGANIZATION_ID = xs:string($organizationID)]/organization:ALM_NAME/text())[1] ne '')then 
															/organization[organization:ORGANIZATION_ID = xs:string($organizationID)]/organization:ALM_NAME/text()[1]
															else 
															/organization[organization:ORGANIZATION_ID = xs:string($organizationID)]/organization:ORGANIZATION_NAME/text()[1]

							let $amlaw200maxYearData := cts:search(/,
									cts:and-query((
										cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
										cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string(max($distinctYears))),
										cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),xs:string($organizationID))
									)))[1]

							let $uk50maxYearData := cts:search(/,
										cts:and-query((
											cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
											cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string(fn:max($distinctYears))),
											cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),xs:string($organizationID))
										)))[1]		

							let $global100YearData := cts:search(/,
								cts:and-query((
									cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
									cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string(fn:max($distinctYears))),
									cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),xs:string($organizationID))
								)))[1]		

								let $maxYearData := if($uk50maxYearData ne '' or $amlaw200maxYearData ne '' or $global100YearData ne '') then 'Y' else ()		

							let $data := for $year in fn:reverse($distinctYears)
										let $response-obj := json:object()

										let $amlaw200CurrentYear := if(xs:string($IsDisplayGBP) ne 'true') then  cts:search(/,
																		cts:and-query((
																			cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
																			cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year)),
																			cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),xs:string($organizationID))
																			)))[1] else()

										let $global100CurrentYear := if(xs:string($IsDisplayGBP) ne 'true') then cts:search(/,
																		cts:and-query((
																			cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
																			cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($year)),
																			cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),xs:string($organizationID))
																			)))[1] else()									

										let $global100NOICurrentYear := if($global100CurrentYear ne '') then (xs:double($global100CurrentYear//Global_100:PPP/text()) * xs:double($global100CurrentYear//Global_100:NUM_EQUITY_PARTNERS/text()))
																	 else ()

										let $uk50CurrentYearData := cts:search(/,
																				cts:and-query((
																					cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
																					cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string($year)),
																					cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),xs:string($organizationID))
																					)))[1]

										let $uk50IDCurrentYear :=if(xs:string($isDisplayGBP) eq 'true') then$uk50CurrentYearData//UK_50:PPP_POUND_K/text()
																else $uk50CurrentYearData//UK_50:PPP_DOLLAR/text()		

										let $uk50NOICurrentYear := if($uk50CurrentYearData ne '') then (xs:double($uk50CurrentYearData//UK_50:PPP_DOLLAR/text()) * xs:double($uk50CurrentYearData//UK_50:NUMBER_OF_EQ_PARTNERS/text()))
																	 else ()

										let $ppp := if(fn:not($amlaw200CurrentYear ne '') and fn:not($global100CurrentYear ne '') and fn:not($uk50IDCurrentYear ne '')) then -1000
													else if($amlaw200CurrentYear//AMLAW_200:PPP/text() ne '') then $amlaw200CurrentYear//AMLAW_200:PPP/text() else
														if($global100CurrentYear//Global_100:PPP/text() ne '') then $global100CurrentYear//Global_100:PPP/text() else
														if($uk50IDCurrentYear ne '') then $uk50IDCurrentYear else 0

										let $noi :=if( xs:string($amlaw200CurrentYear//AMLAW_200:NET_OPERATING_INCOME/text()) ne '') then $amlaw200CurrentYear//AMLAW_200:NET_OPERATING_INCOME/text()
											       else if($global100NOICurrentYear) then $global100NOICurrentYear
												   else $uk50NOICurrentYear

										let $amlawPartnersCurrentYear :=   $amlaw200CurrentYear//AMLAW_200:NUM_EQ_PARTNERS/text()
										let $global100PartnersCurrentYear := $global100CurrentYear//Global_100:NUM_EQUITY_PARTNERS/text()

										let $uk50PartnersCurrentYear :=$uk50CurrentYearData//UK_50:NUMBER_OF_EQ_PARTNERS/text()

										let $totalPartnerssCurrentYear := if(xs:string($amlawPartnersCurrentYear) ne '') then $amlawPartnersCurrentYear else
																									if(xs:string($global100PartnersCurrentYear) ne '') then $global100PartnersCurrentYear
																									else $uk50PartnersCurrentYear				

										let $isAddMaxYear := if(xs:string($year) ne xs:string(max($distinctYears))) then 'y' else
													if($amlaw200CurrentYear ne '' or $global100CurrentYear ne '' or $uk50IDCurrentYear ne '') then 'y' else 'n'

										

										let $_ := (
														map:put($response-obj,'ORGANIZATION_ID',xs:integer($organizationID)),
														map:put($response-obj,'ORGANIZATION_NAME',$organizationName),
														map:put($response-obj,'REVENUE',fn:round-half-to-even($ppp,0)),
														map:put($response-obj,'NetOperatingIncome',fn:round-half-to-even($noi,2)),
														map:put($response-obj,'Totalpartners',$totalPartnerssCurrentYear),
														map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
												)

										let $_ := if(xs:string($year) ne xs:string(max($distinctYears))) then json:array-push($response-arr, $response-obj) else
											if($maxYearData ne '' and ($amlaw200CurrentYear ne '' or $global100CurrentYear ne '' or $uk50IDCurrentYear ne ''))
												then json:array-push($response-arr,$response-obj) else()

										return()
				
				return()

	let $surveyData := for $year in fn:reverse($distinctYears)

						(:------ Amlaw100------:)
						let $res :=    avg(cts:search(/,
											cts:and-query((
											cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/','1'),
											cts:element-range-query(xs:QName('AMLAW_200:AMLAW200_RANK'), '<=',100),
											cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),'')),
											cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year))
										)))//AMLAW_200:PPP/text())

						let $res1 :=  cts:search(/,
											cts:and-query((
											cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/','1'),
											cts:element-range-query(xs:QName('AMLAW_200:AMLAW200_RANK'), '<=',100),
											cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),'')),
											cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year))
										)))[1]			

						let $avg-ppp := if(fn:not($res1 ne '')) then -1000 else fn:format-number($res ,'.00')
						let $response-obj := json:object()
						let $_ := (
										map:put($response-obj,'ORGANIZATION_ID',0),
									map:put($response-obj,'ORGANIZATION_NAME', 'AM Law 100'),
									map:put($response-obj,'REVENUE', $avg-ppp),
									map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
										)

				
						let $_ := json:array-push($response-arr, $response-obj)

						(:------ Am Law 2nd Hundred------:)
						let $res :=    avg(cts:search(/,
											cts:and-query((
											cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/','1'),
											cts:element-range-query(xs:QName('AMLAW_200:AMLAW200_RANK'), '>',100),
											cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),'')),
											cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year))
										)))//AMLAW_200:PPP/text())

						let $res1 :=   cts:search(/,
											cts:and-query((
											cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/','1'),
											cts:element-range-query(xs:QName('AMLAW_200:AMLAW200_RANK'), '>',100),
											cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),'')),
											cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year))
										)))[1]			

						let $avg-ppp := if(fn:not($res1 ne '')) then -1000 else fn:format-number($res ,'.00')
						let $response-obj := json:object()
						let $_ := (
										map:put($response-obj,'ORGANIZATION_ID',0),
									map:put($response-obj,'ORGANIZATION_NAME', 'Am Law 2nd Hundred'),
									map:put($response-obj,'REVENUE', $avg-ppp),
									map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
										)
				
						let $_ := json:array-push($response-arr, $response-obj)		

						(:-------Global 200--------:)

						let $g100Data := cts:search(/,
											cts:and-query((
												cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
												cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($year))
												)))[1]

						let $global100AvgPPP := fn:avg(cts:search(/,
														cts:and-query((
															cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
															cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($year))
															)))//Global_100:PPP/text())		

						let $global100AvgPPP :=if(fn:not($g100Data ne '')) then -1000 else $global100AvgPPP
						let $response-obj := json:object()
						let $_ := (
										map:put($response-obj,'ORGANIZATION_ID',0),
									map:put($response-obj,'ORGANIZATION_NAME', 'Global 200'),
									map:put($response-obj,'REVENUE', $global100AvgPPP), 
									map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
										)
						let $_ := json:array-push($response-arr, $response-obj) 

						(:-------UK50--------:)
						let $res := cts:search(/,
										cts:and-query((
											cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
											cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string($year))
											)))[1]

						let $uk50IDAvgPPP :=if(fn:not( $res ne '')) then -1000
											else if(xs:string($isDisplayGBP) eq 'true') then fn:avg(cts:search(/,
																cts:and-query((
																	cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
																	cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string($year))
																	)))//UK_50:PPP_POUND_K/text())
												else fn:avg(cts:search(/,
																cts:and-query((
																	cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
																	cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string($year))
																	)))[1]//UK_50:PPP_DOLLAR/text())		

						let $response-obj := json:object()
						let $_ := (
										map:put($response-obj,'ORGANIZATION_ID',0),
									map:put($response-obj,'ORGANIZATION_NAME', 'UK 100'),
									map:put($response-obj,'REVENUE', $uk50IDAvgPPP), 
									map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
								)

						let $_ := if($uk50ID != '') then json:array-push($response-arr, $response-obj)
								else()	
						return()			

	return ($response-arr)
};

declare function mergertool:GetRevenueByYear($request)
{
	let $isDisplayGBP := 'false'
	let $distinctYears := fn:distinct-values(cts:search(/,
			cts:directory-query('/LegalCompass/denormalized-data/surveys/AMLAW_200/','1')
        )//survey:YEAR/@PublishYear/string())

	let $distinctYears := for $year in $distinctYears
		order by xs:integer($year) descending
		return $year

	let $response-arr := json:array()

	let $loopData := for $OrganisationID in fn:tokenize($request/FirmID/text(),',')
							let $organization := fn:doc(fn:concat('/LegalCompass/denormalized-data/organization/',$OrganisationID,'.xml'))
							let $organizationID := $organization//organization:ORGANIZATION_ID/text()
							let $organizationName := if((/organization[organization:ORGANIZATION_ID = xs:string($OrganisationID)]/organization:ALM_NAME/text())[1] ne '')then 
															/organization[organization:ORGANIZATION_ID = xs:string($OrganisationID)]/organization:ALM_NAME/text()[1]
															else 
															/organization[organization:ORGANIZATION_ID = xs:string($OrganisationID)]/organization:ORGANIZATION_NAME/text()[1]
							

							let $uk50ID := cts:search(/,
												cts:and-query((
													cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
													cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),xs:string($OrganisationID))
													)))//UK_50:ORGANIZATION_ID/text()

							let $data := for $year in fn:reverse($distinctYears[1 to 5])
												let $response-obj := json:object()

												let $res := cts:search(/,
														cts:and-query((
															cts:directory-query('/LegalCompass/denormalized-data/surveys/AMLAW_200/','1'),
															cts:element-attribute-value-query(xs:QName('survey:YEAR'),xs:QName('PublishYear'),($year)),
															cts:element-attribute-value-query(xs:QName('survey:YEAR'),xs:QName('OrganizationID'),$OrganisationID)
														)))//survey:YEAR[@PublishYear = $year]

												let $amlaw200CurrentYear :=if(xs:string($isDisplayGBP) ne 'true') then cts:search(/,
																						cts:and-query((
																							cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
																							cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year)),
																							cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),xs:string($OrganisationID))
																							)))[1]//AMLAW_200:GROSS_REVENUE/text() else()

												let $global100CurrentYear :=if(xs:string($isDisplayGBP) ne 'true') then  cts:search(/,
																						cts:and-query((
																							cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
																							cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($year)),
																							cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),xs:string($OrganisationID))
																							)))[1]//Global_100:GROSS_REVENUE/text() else ()


		
												let $uk50IDCurrentYear :=if($uk50ID != '') then if(xs:string($isDisplayGBP) eq 'true') then (cts:search(/,
																						cts:and-query((
																							cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
																							cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string($year)),
																							cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),xs:string($OrganisationID))
																							)))[1]//UK_50:GROSS_REVENUE_POUND_M/text()) * 1000000
																							else cts:search(/,
																						cts:and-query((
																							cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
																							cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string($year)),
																							cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),xs:string($OrganisationID))
																							)))[1]//UK_50:GROSS_REVENUE_DOLLAR/text() 
																							else ()

												let $rev := if(xs:string($amlaw200CurrentYear) ne '') then $amlaw200CurrentYear else 
																if(xs:string($global100CurrentYear) ne '') then $global100CurrentYear else
																if(xs:string($uk50IDCurrentYear) ne '') then $uk50IDCurrentYear else 0

																

												let $_ := (
													map:put($response-obj,'ORGANIZATION_ID',xs:integer($OrganisationID)),
													map:put($response-obj,'ORGANIZATION_NAME',$organizationName),
													map:put($response-obj,'REVENUE',$rev),
													map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
												)

												let $_ := json:array-push($response-arr, $response-obj)
														

												return()		
		return  ()

	return $response-arr
};

declare function mergertool:GetRevenuePerLawyerByYear($request)
{
	let $IsDisplayGBP := $request/IsDisplayGBP/text()
	let $isDisplayGBP := 'false'
	let $response-arr := json:array()

	let $distinctYears := cts:element-attribute-values(xs:QName('survey:YEAR'),xs:QName('PublishYear'),(),('descending'),
							cts:and-query((
								cts:directory-query('/LegalCompass/denormalized-data/surveys/AMLAW_200/','1')
							)))

	let $distinctYears := if($request/StartYear/text() ne '' and $request/EndYear/text() ne '') then
								for $year in $distinctYears
								where ($year ge xs:integer($request/StartYear/text()) and EndYear le xs:integer($request/EndYear/text()))
								return $year
								else $distinctYears
	let $loopData := for $organizationID in fn:tokenize($request//FirmID/text(),',')

						let $organization := fn:doc(fn:concat('/LegalCompass/denormalized-data/organization/',$organizationID,'.xml'))
						(: let $organizationName := $organization//organization:ORGANIZATION_SHORT_NAME/text() :)
						let $organizationName := if((/organization[organization:ORGANIZATION_ID = xs:string($organizationID)]/organization:ALM_NAME/text())[1] ne '')then 
															/organization[organization:ORGANIZATION_ID = xs:string($organizationID)]/organization:ALM_NAME/text()[1]
															else 
															/organization[organization:ORGANIZATION_ID = xs:string($organizationID)]/organization:ORGANIZATION_NAME/text()[1]
						


						let $data := for $year in fn:reverse($distinctYears[1 to 5])
									     let $response-obj := json:object()

										let $amlaw200CurrentYear := if(xs:string($isDisplayGBP) ne ' true') then sum(cts:search(/,
																		cts:and-query((
																			cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
																			cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year)),
																			cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),xs:string($organizationID))
																			)))//AMLAW_200:RPL/text())	else()	

										let $global100CurrentYear := if(xs:string($isDisplayGBP) ne ' true') then sum(cts:search(/,
																				cts:and-query((
																					cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
																					cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($year)),
																					cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),xs:string($organizationID))
																					)))//Global_100:REVENUE_PER_LAWYER/text()) else()


				
										let $uk50IDCurrentYear :=if(xs:string($isDisplayGBP) eq 'true') then (cts:search(/,
																				cts:and-query((
																					cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
																					cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string($year)),
																					cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),xs:string($organizationID))
																					)))//UK_50:RPL_POUND_K/text() * 1000)
																else cts:search(/,
																				cts:and-query((
																					cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
																					cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string($year)),
																					cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),xs:string($organizationID))
																					)))//UK_50:RPL_DOLLAR/text()	

										let $amlaw200RevenueCurrentYear :=if(xs:string($isDisplayGBP) ne 'true') then cts:search(/,
																		cts:and-query((
																			cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
																			cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year)),
																			cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),xs:string($organizationID))
																			)))[1]//AMLAW_200:GROSS_REVENUE/text() else()											

										let $amlaw200TotalLawyerCurrentYear :=if(xs:string($isDisplayGBP) ne 'true') then cts:search(/,
																				cts:and-query((
																					cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
																					cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year)),
																					cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),xs:string($organizationID))
																					)))[1]//AMLAW_200:NUM_OF_LAWYERS/text() else()

										let $global100RevenueCurrentYear := if(xs:string($isDisplayGBP) ne 'true') then cts:search(/,
																												cts:and-query((
																													cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
																													cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($year)),
																													cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),xs:string($organizationID))
																													)))[1]//Global_100:GROSS_REVENUE/text() else()

										let $global100TotalLawyersCurrentYear := if(xs:string($isDisplayGBP) ne 'true') then cts:search(/,
																				cts:and-query((
																					cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
																					cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($year)),
																					cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),xs:string($organizationID))
																					)))[1]//Global_100:NUM_LAWYERS/text() else()

										let $uk50RevenueCurrentYear := if(xs:string($isDisplayGBP) eq 'true') then cts:search(/,
																											cts:and-query((
																												cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
																												cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string($year)),
																												cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),xs:string($organizationID))
																												)))[1]//UK_50:GROSS_REVENUE_POUND_K/text()

																									else cts:search(/,
																													cts:and-query((
																														cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
																														cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string($year)),
																														cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),xs:string($organizationID))
																														)))[1]//UK_50:RPL_DOLLAR/text()

										let $uk50IDTotalLawyersCurrentYear := cts:search(/,
																					cts:and-query((
																						cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
																						cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string($year)),
																						cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),xs:string($organizationID))
																						)))[1]//UK_50:NUMBER_OF_LAWYERS/text()

										let $rev := if($amlaw200CurrentYear ne 0) then $amlaw200CurrentYear else 
												if($global100CurrentYear ne 0) then $global100CurrentYear else
												if($uk50IDCurrentYear ne 0) then $uk50IDCurrentYear else ''

										let $revenueCurrentYear :=if($amlaw200RevenueCurrentYear ne '') then $amlaw200RevenueCurrentYear else
																		if($global100RevenueCurrentYear ne '') then $global100RevenueCurrentYear
																		else $uk50RevenueCurrentYear


										let $totalLawyersCurrentyear := if($amlaw200TotalLawyerCurrentYear ne '') then $amlaw200TotalLawyerCurrentYear else
																		if($global100TotalLawyersCurrentYear ne '') then $global100TotalLawyersCurrentYear
																		else $uk50IDTotalLawyersCurrentYear		

										let $_ := (
														map:put($response-obj,'ORGANIZATION_ID',xs:integer($organizationID)),
													map:put($response-obj,'ORGANIZATION_NAME',$organizationName),
													map:put($response-obj,'REVENUE',$rev),
													map:put($response-obj,'REVENUECHANGES',$revenueCurrentYear),
													map:put($response-obj,'TotalLawyers',$totalLawyersCurrentyear),
													map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
														)
										let $_ := if(xs:integer(max($distinctYears)) ne xs:integer($year)) then json:array-push($response-arr, $response-obj)
											else if(xs:string($rev) ne '') then json:array-push($response-arr, $response-obj)
											else()
										return()
										return()
	return $response-arr
};

declare function mergertool:GetProfitLawyer($request)
{
	let $IsDisplayGBP := $request/IsDisplayGBP/text()
	let $isDisplayGBP := 'false'
	let $organizationIDs := $request/FirmID/text()
	let $distinctYears := cts:element-attribute-values(xs:QName('survey:YEAR'),xs:QName('PublishYear'),(),('descending'),
							cts:and-query((
							cts:directory-query('/LegalCompass/denormalized-data/surveys/AMLAW_200/','1')
							)))

	let $distinctYears := if($request/StartYear/text() ne '' and $request/EndYear/text() ne '') then
						for $year in $distinctYears
						(:where $year >= xs:integer($request/StartYear/text()) and EndYear <= xs:integer($request/EndYear/text()):)
						return $year
						else $distinctYears

	let $response-arr := json:array()

	let $loopData := for $organizationID in fn:tokenize($organizationIDs,',')
						let $organization := fn:doc(fn:concat('/LegalCompass/denormalized-data/organization/',$organizationID,'.xml'))
						let $organizationName := if((/organization[organization:ORGANIZATION_ID = xs:string($organizationID)]/organization:ALM_NAME/text())[1] ne '')then 
															/organization[organization:ORGANIZATION_ID = xs:string($organizationID)]/organization:ALM_NAME/text()[1]
															else 
															/organization[organization:ORGANIZATION_ID = xs:string($organizationID)]/organization:ORGANIZATION_NAME/text()[1]
						

						let $data := for $year in fn:reverse($distinctYears[1 to 5])
									let $response-obj := json:object()
				

									let $amlaw200CurrentYear := if(xs:string($IsDisplayGBP) ne 'true') then cts:search(/,
																	cts:and-query((
																		cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
																		cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year)),
																		cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),xs:string($organizationID))
																		)))[1] else()

									let $global100CurrentYear := if(xs:string($IsDisplayGBP) ne 'true') then cts:search(/,
																	cts:and-query((
																		cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
																		cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($year)),
																		cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),xs:string($organizationID))
																		)))[1] else()											

									let $uk50CurrentYearData := cts:search(/,
												cts:and-query((
													cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
													cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string($year)),
													cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),xs:string($organizationID))
													)))[1]

									let $uk50IDCurrentYear :=if(xs:string($isDisplayGBP) eq 'true') then $uk50CurrentYearData//UK_50:PPP_POUND_K/text()
															else $uk50CurrentYearData//UK_50:PPL_DOLLAR/text()				

									let $amlawNOICurrentYear :=   $amlaw200CurrentYear//AMLAW_200:NET_OPERATING_INCOME/text()
									let $global100NOICurrentYear := if($global100CurrentYear ne '') then (xs:double($global100CurrentYear//Global_100:PPP/text()) * xs:double($global100CurrentYear//Global_100:NUM_EQUITY_PARTNERS/text()))
																	else ()
									let $uk50NOICurrentYear := if($uk50CurrentYearData ne '') then (xs:double($uk50CurrentYearData//UK_50:PPP_DOLLAR/text()) * xs:double($uk50CurrentYearData//UK_50:NUMBER_OF_EQ_PARTNERS/text()))
															   else ()

									let $amlawLawyersCurrentYear :=   $amlaw200CurrentYear//AMLAW_200:NUM_OF_LAWYERS/text()
									let $global100LawyersCurrentYear := if($global100CurrentYear ne '') then $global100CurrentYear//Global_100:NUM_LAWYERS/text() else ()
									let $uk50LawyersCurrentYear := if($uk50CurrentYearData ne '') then $uk50CurrentYearData//UK_50:NUMBER_OF_LAWYERS/text() else ()																	

									let $noi := if(xs:string($amlawNOICurrentYear) ne '') then $amlawNOICurrentYear
												else if(xs:string($global100NOICurrentYear) ne '') then $global100NOICurrentYear
												else $uk50NOICurrentYear

									let $totalLawyers := if(xs:string($amlawLawyersCurrentYear) ne '') then $amlawLawyersCurrentYear
														else if(xs:string($global100LawyersCurrentYear) ne '') then $global100LawyersCurrentYear
														else $uk50LawyersCurrentYear	

									(: let $ppl := if($amlaw200CurrentYear//AMLAW_200:NET_OPERATING_INCOME/text() ne '') then ($amlaw200CurrentYear//AMLAW_200:NET_OPERATING_INCOME/text() div $amlaw200CurrentYear//AMLAW_200:NUM_OF_LAWYERS/text()) else 
												if($global100CurrentYear//Global_100:NUM_LAWYERS/text() ne '') then (($global100CurrentYear//Global_100:PPP/text() * $global100CurrentYear//Global_100:NUM_EQUITY_PARTNERS/text()) div $global100CurrentYear//Global_100:NUM_LAWYERS/text()) else
												if($uk50IDCurrentYear ne '') then $uk50IDCurrentYear else 0 :)

									let $ppl := if($totalLawyers) then fn:round-half-to-even($noi div $totalLawyers , 2) else 0		

									let $_ := (
													map:put($response-obj,'ORGANIZATION_ID',xs:integer($organizationID)),
													map:put($response-obj,'ORGANIZATION_NAME',$organizationName),
													map:put($response-obj,'CHANGE',fn:round-half-to-even($ppl,2)),
													map:put($response-obj,'NetOperatingIncome',fn:round-half-to-even($noi,2)),
													map:put($response-obj,'TotalLawyers',fn:round-half-to-even($totalLawyers)),
													map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
											)
									let $_ := if(xs:integer(max($distinctYears)) ne xs:integer($year)) then json:array-push($response-arr, $response-obj)
										else if($amlaw200CurrentYear ne '' or $global100CurrentYear ne '' or $uk50IDCurrentYear ne '') then json:array-push($response-arr, $response-obj)
										else()
									return  ()
									return()
	return $response-arr
};

(:------------------- STAFFING -----------------:)

declare function mergertool:GetTotalHeadCount($request)
{
	let $distinctYears := cts:element-attribute-values(xs:QName('survey:YEAR'),xs:QName('PublishYear'),(),('descending'),
	cts:and-query((
		cts:directory-query('/LegalCompass/denormalized-data/surveys/NLJ_250/','1')
	))
	)

	let $distinctYears := if($request/StartYear/text() ne '' and $request/EndYear/text() ne '') then
						for $year in $distinctYears
						return $year
						else $distinctYears[1 to 5]

	let $organizationIDs := $request/FirmID/text()
	let $response-arr := json:array()

	let $loopData := for $OrganizationID in fn:tokenize($organizationIDs,',')

							let $organizationName := if((/organization[organization:ORGANIZATION_ID = xs:string($OrganizationID)]/organization:ALM_NAME/text())[1] ne '')then 
								/organization[organization:ORGANIZATION_ID = xs:string($OrganizationID)]/organization:ALM_NAME/text()[1]
							else 
								/organization[organization:ORGANIZATION_ID = xs:string($OrganizationID)]/organization:ORGANIZATION_NAME/text()[1]
							

							let $data := for $year in fn:reverse($distinctYears)
											let $response-obj := json:object()
											let $res := cts:search(/,
															cts:and-query((
															cts:directory-query('/LegalCompass/relational-data/surveys/NLJ_250/','1'),
															cts:element-value-query(xs:QName('nlj250:PUBLISHYEAR'),xs:string($year)),
															cts:element-value-query(xs:QName('nlj250:ORGANIZATION_ID'),$OrganizationID)
															)))[1]			
											
											let $global100Data := cts:search(/,
																	cts:and-query((
																		cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
																		cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string(xs:integer($year))),
																		cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$OrganizationID)
																		)))[1]//Global_100:NUM_LAWYERS/text()

		

											let $uk50Data := cts:search(/,
																			cts:and-query((
																				cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
																				cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string($year)),
																				cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),$OrganizationID)
																				)))[1]//UK_50:NUMBER_OF_LAWYERS/text()
											
											let $numOfAttorney := if($res//nlj250:NUM_ATTORNEYS/text() ne '') then $res//nlj250:NUM_ATTORNEYS/text()
																	else if($global100Data ne '') then $global100Data
																	else $uk50Data
									
											let $_ := (
															map:put($response-obj,'ORGANIZATION_ID',xs:integer($OrganizationID)),
														map:put($response-obj,'ORGANIZATION_NAME',$organizationName),
														map:put($response-obj,'COUNT',$numOfAttorney),
														map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
															)
											(: let $_ := if($res ne '' or $global100Data ne '' or $uk50Data ne '') then json:array-push($response-arr, $response-obj) else() :)
											let $_ := json:array-push($response-arr, $response-obj)
				return()
				return()
	return $response-arr
};

declare function mergertool:GetGrowthTotalHeadCount($request)
{
	let $distinctYears := cts:element-attribute-values(xs:QName("survey:YEAR"),xs:QName("PublishYear"),(),("descending"),
								cts:and-query((
									cts:directory-query("/LegalCompass/denormalized-data/surveys/NLJ_250/","1")
									)))
 

	let $OrganizationIDs := $request//FirmID/text()

	let $distinctYears := if($request/StartYear/text() ne "" and $request/EndYear/text() ne "") then
						for $year in $distinctYears
						where $year ge xs:integer($request/StartYear/text()) and $year le xs:integer($request/EndYear/text())
						return $year
						else $distinctYears[1 to 6]

	let $uk50ID := cts:search(/,
						cts:and-query((
							cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
							cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),fn:tokenize($OrganizationIDs,','))
							)))[1]//UK_50:ORGANIZATION_ID/text()					
                      

	let $response-arr := json:array()

	let $loopData := for $OrganizationID in fn:tokenize($OrganizationIDs,',')
						let $organizationName := if((/organization[organization:ORGANIZATION_ID = xs:string($OrganizationID)]/organization:ALM_NAME/text())[1] ne '')then 
						/organization[organization:ORGANIZATION_ID = xs:string($OrganizationID)]/organization:ALM_NAME/text()[1]
						else 
						/organization[organization:ORGANIZATION_ID = xs:string($OrganizationID)]/organization:ORGANIZATION_NAME/text()[1]

						let $amlaw200maxYearData := cts:search(/,
												cts:and-query((
												cts:directory-query('/LegalCompass/relational-data/surveys/NLJ_250/','1'),
												cts:element-value-query(xs:QName('nlj250:PUBLISHYEAR'),xs:string(max($distinctYears))),
												cts:element-value-query(xs:QName('nlj250:ORGANIZATION_ID'),$OrganizationID)
												)))[1]

						let $uk50maxYearData := cts:search(/,
								cts:and-query((
									cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
									cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string(fn:max($distinctYears))),
									cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),xs:string($OrganizationID))
								)))[1]		

						let $global100YearData := cts:search(/,
								cts:and-query((
									cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
									cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string(fn:max($distinctYears))),
									cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),xs:string($OrganizationID))
								)))[1]		

						let $maxYearData := if($uk50maxYearData ne '' or $amlaw200maxYearData ne '' or $global100YearData ne '') then 'Y' else ()						

						let $data := for $year in (reverse($distinctYears))[1 to 6]
										let $response-obj := json:object()  

										let $res :=cts:search(/,
											cts:and-query((
											cts:directory-query('/LegalCompass/relational-data/surveys/NLJ_250/','1'),
											cts:element-value-query(xs:QName('nlj250:PUBLISHYEAR'),xs:string($year)),
											cts:element-value-query(xs:QName('nlj250:ORGANIZATION_ID'),$OrganizationID)
											)))[1]
											
										let $lag-1  :=cts:search(/,
											cts:and-query((
											cts:directory-query('/LegalCompass/relational-data/surveys/NLJ_250/','1'),
											cts:element-value-query(xs:QName('nlj250:PUBLISHYEAR'),xs:string($year - 1)),
											cts:element-value-query(xs:QName('nlj250:ORGANIZATION_ID'),$OrganizationID)
											)))[1]
											
										let $global100Data :=cts:search(/,
											cts:and-query((
												cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
												cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($year)),
												cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$OrganizationID)
												)))[1]

										let $uk50Data := cts:search(/,
											cts:and-query((
												cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
												cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string($year)),
												cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),$OrganizationID)
												)))[1]
													
										let $global100DataLag := cts:search(/,
											cts:and-query((
												cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
												cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string(xs:integer($year) - 1)),
												cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$OrganizationID)
												)))[1]

										let $uk50DataLag := cts:search(/,
											cts:and-query((
												cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
												cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string($year -1 )),
												cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),$OrganizationID)
												)))[1]		

										let $num_attorneys := if($res//nlj250:NUM_ATTORNEYS/text() ne '') then $res//nlj250:NUM_ATTORNEYS/text() 
																else if($global100Data//Global_100:NUM_LAWYERS/text() ne '') then $global100Data//Global_100:NUM_LAWYERS/text()
																else if($uk50Data//UK_50:NUMBER_OF_LAWYERS/text() ne '') then $uk50Data//UK_50:NUMBER_OF_LAWYERS/text() else 0
																	
										let $lag_num_attorneys := if($lag-1//nlj250:NUM_ATTORNEYS/text() ne '') then $lag-1//nlj250:NUM_ATTORNEYS/text() 
																else if($global100DataLag//Global_100:NUM_LAWYERS/text() ne '') then $global100DataLag//Global_100:NUM_LAWYERS/text()
																else if($uk50DataLag//UK_50:NUMBER_OF_LAWYERS/text() ne '') then $uk50DataLag//UK_50:NUMBER_OF_LAWYERS/text() else 0
						
										let $change :=if($num_attorneys ne 0 and $lag_num_attorneys ne 0) then fn:format-number((($num_attorneys - $lag_num_attorneys) div $lag_num_attorneys ) * 100, ".00") else -1000
										
										
										let $isAddMaxYear := if(xs:string($year) ne xs:string(max($distinctYears))) then 'y' else
																	if($res ne '' or $global100Data ne '' or $uk50Data ne '') then 'y' else 'n' 

										let $_ := (
											map:put($response-obj,'ORGANIZATION_ID',xs:integer($OrganizationID)),
											map:put($response-obj,'ORGANIZATION_NAME',$organizationName),
											map:put($response-obj,'CHANGE', $change),
											map:put($response-obj,'TotalLawyers', $num_attorneys),
											map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
											)
										let $_ := if(xs:string($year) ne xs:string(max($distinctYears))) then json:array-push($response-arr, $response-obj) else
													if($maxYearData ne '' and ($res ne '' or $global100Data ne '' or $uk50Data ne ''))
																then json:array-push($response-arr,$response-obj) else()             
											
										return()
										return ()

	let $surveyData := for $year in (reverse($distinctYears))[1 to 6]
						(:---------- NLJ500---------:)

						let $nljDataCurYear := cts:search(/,
														cts:and-query((
														cts:directory-query('/LegalCompass/relational-data/surveys/NLJ_250/')
														,cts:element-value-query(xs:QName('nlj250:PUBLISHYEAR'),xs:string($year))
														)))[1]

						let $nljDataPreYear := cts:search(/,
														cts:and-query((
														cts:directory-query('/LegalCompass/relational-data/surveys/NLJ_250/')
														,cts:element-value-query(xs:QName('nlj250:PUBLISHYEAR'),xs:string(xs:integer($year)-1))
														)))[1]
						
						let $amlaw200CurrentYear  := fn:avg(cts:search(/,
														cts:and-query((
														cts:directory-query('/LegalCompass/relational-data/surveys/NLJ_250/')
														,cts:element-value-query(xs:QName('nlj250:PUBLISHYEAR'),xs:string($year))
														)))//nlj250:NUM_ATTORNEYS/text())	

						let $amlaw200PreYear  := fn:avg(cts:search(/,
														cts:and-query((
														cts:directory-query('/LegalCompass/relational-data/surveys/NLJ_250/')
														,cts:element-value-query(xs:QName('nlj250:PUBLISHYEAR'),xs:string(xs:integer($year)-1))
														)))//nlj250:NUM_ATTORNEYS/text())								
           
						let $result := if(fn:not($nljDataCurYear ne '') and fn:not($nljDataPreYear ne '')) then -1000 
										else fn:round-half-to-even((($amlaw200CurrentYear - $amlaw200PreYear ) div $amlaw200PreYear) * 100 ,2)

						let $response-obj := json:object()
						
						let $_ := (
							map:put($response-obj,'ORGANIZATION_ID',0),
							map:put($response-obj,'ORGANIZATION_NAME','NLJ 500'),
							map:put($response-obj,'CHANGE',$result),
							map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
							)
						
						let $_ :=json:array-push($response-arr, $response-obj)
						(:------ Amlaw 100-------:)

						let $amlawCurYear := cts:search(/,
														cts:and-query((
														cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/')
														,cts:element-range-query(xs:QName('AMLAW_200:AMLAW200_RANK'), '<=',100)
														,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year))
														,cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
														)))[1]

						let $amlawPreYear := cts:search(/,
														cts:and-query((
														cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/')
														,cts:element-range-query(xs:QName('AMLAW_200:AMLAW200_RANK'), '<=',100)
														,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string(xs:integer($year)-1))
														,cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
														)))[1]
						
						let $amlaw200CurrentYear  := fn:avg(cts:search(/,
														cts:and-query((
														cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/')
														,cts:element-range-query(xs:QName('AMLAW_200:AMLAW200_RANK'), '<=',100)
														,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year))
														,cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
														)))//AMLAW_200:NUM_OF_LAWYERS/text())	

						let $amlaw200PreYear  := fn:avg(cts:search(/,
														cts:and-query((
														cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/')
														,cts:element-range-query(xs:QName('AMLAW_200:AMLAW200_RANK'), '<=',100)
														,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string(xs:integer($year)-1))
														,cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
														)))//AMLAW_200:NUM_OF_LAWYERS/text())								
								
						let $result :=if(fn:not($amlawCurYear ne '') and fn:not($amlaw200PreYear ne '')) then -1000
									  else fn:round-half-to-even((($amlaw200CurrentYear - $amlaw200PreYear ) div $amlaw200PreYear) * 100 ,2)

						let $response-obj := json:object()
  
						let $_ := (
							map:put($response-obj,'ORGANIZATION_ID',0),
							map:put($response-obj,'ORGANIZATION_NAME','Am Law 100'),
							map:put($response-obj,'CHANGE',$result),
							map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
							)
						
						let $_ := json:array-push($response-arr, $response-obj)

						(:-------Am Law 2nd Hundred---------:)

						let $amlawCurYear := cts:search(/,
														cts:and-query((
														cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/')
														,cts:element-range-query(xs:QName('AMLAW_200:AMLAW200_RANK'), '>',100)
														,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year))
														,cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
														)))[1]

						let $amlawPreYear := cts:search(/,
														cts:and-query((
														cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/')
														,cts:element-range-query(xs:QName('AMLAW_200:AMLAW200_RANK'), '>',100)
														,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string(xs:integer($year)-1))
														,cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
														)))[1]

						let $amlaw200CurrentYear  := fn:avg(cts:search(/,
														cts:and-query((
														cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/')
														,cts:element-range-query(xs:QName('AMLAW_200:AMLAW200_RANK'), '>',100)
														,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year))
														,cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
														)))//AMLAW_200:NUM_OF_LAWYERS/text())	

						let $amlaw200PreYear  := fn:avg(cts:search(/,
														cts:and-query((
														cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/')
														,cts:element-range-query(xs:QName('AMLAW_200:AMLAW200_RANK'), '>',100)
														,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string(xs:integer($year)-1))
														,cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
														)))//AMLAW_200:NUM_OF_LAWYERS/text())								
								
						let $result := if(fn:not($amlawCurYear ne '') and fn:not($amlaw200PreYear ne '')) then -1000
									  else fn:round-half-to-even((($amlaw200CurrentYear - $amlaw200PreYear ) div $amlaw200PreYear) * 100 ,2)

						let $response-obj := json:object()
						let $_ := (
							map:put($response-obj,'ORGANIZATION_ID',0),
							map:put($response-obj,'ORGANIZATION_NAME','Am Law 2nd Hundred'),
							map:put($response-obj,'CHANGE', $result),
							map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
							)
						let $_ :=json:array-push($response-arr, $response-obj)
  
						(:-------------------UK50------------------------:)
						let $response-obj := json:object()

						let $distinctid_gt_100_Current := fn:distinct-values(cts:search(/,
												cts:and-query((
													cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
													cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string($year))
													)))//UK_50:ORGANIZATION_ID/text())

	
						let $res3 := xs:integer(avg(cts:search(/,
											cts:and-query((
											cts:directory-query('/LegalCompass/relational-data/surveys/UK_50/','1')
											,cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),($distinctid_gt_100_Current ! xs:string(.)))
											,cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'), xs:string($year))
											)))//UK_50:NUMBER_OF_LAWYERS/text()))
						
						let $distinctid_gt_100  :=fn:distinct-values(cts:search(/,
										cts:and-query((
											cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
											cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string(xs:integer($year) - 1))
											)))//UK_50:ORGANIZATION_ID/text())
		
						let $res3-LAG := xs:integer(avg(cts:search(/,
											cts:and-query((
											cts:directory-query('/LegalCompass/relational-data/surveys/UK_50/','1')
											,cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),($distinctid_gt_100 ! xs:string(.)))
											,cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'), xs:string(xs:integer($year) -1))
											)))//UK_50:NUMBER_OF_LAWYERS/text()))
						
						let $difference := $res3 - $res3-LAG

						let $CHANGE := if(fn:not($distinctid_gt_100_Current != '') or fn:not($distinctid_gt_100 != '')) then -1000
									else if($res3 ne 0 and $res3-LAG ne 0) then fn:round-half-to-even((xs:double($difference) div  $res3-LAG ) * 100 , 2) else 0
						
						let $_ :=(
							map:put($response-obj,'ORGANIZATION_ID', 0),
						map:put($response-obj,'ORGANIZATION_NAME', 'UK 100'),
						map:put($response-obj,'CHANGE', $CHANGE),
						map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
						)
						let $_ := if($uk50ID ne '') then json:array-push($response-arr, $response-obj) else()

						return() 										
	return ($response-arr)
};

declare function mergertool:GetHeadCountPercentage($request)
{
	let $distinctYears := cts:element-attribute-values(xs:QName('survey:YEAR'),xs:QName('PublishYear'),(),('descending'),
								cts:and-query((
									cts:directory-query($config:DD-SURVEY-NLJ_250-PATH,'1')
								)))

	let $distinctYears:= fn:max($distinctYears)

	let $organizationIDs := $request//FirmID/text()
	let $response-arr := json:array()

	let $loopData := for $organizationID in fn:tokenize($organizationIDs,',')
						let $organization := fn:doc(fn:concat('/LegalCompass/denormalized-data/organization/',$organizationID,'.xml'))
						let $organizationID := $organization//organization:ORGANIZATION_ID/text()
						let $organizationName := $organization//organization:ORGANIZATION_SHORT_NAME/text()
						
						let $data := for $year in ($distinctYears)
										let $response-obj := json:object()
										let $res := cts:search(/,
														cts:and-query((
														cts:directory-query('/LegalCompass/relational-data/surveys/NLJ_250/','1'),
														cts:element-value-query(xs:QName('nlj250:PUBLISHYEAR'),xs:string($year)),
														cts:element-value-query(xs:QName('nlj250:ORGANIZATION_ID'),$organizationID)
														)))[1]

										let $num_attorneys := if($res//nlj250:NUM_ATTORNEYS/text() ne '') then $res//nlj250:NUM_ATTORNEYS/text() else json:null()
										let $associates := $res//nlj250:NUM_ASSOCIATES/text() + $res//nlj250:NUM_OTHER_ATTORNEYS/text()
										let $Associate_Per := if($num_attorneys ne 0) then fn:format-number(($associates div $num_attorneys)*100 ,'.00') else json:null()
										let $EquityPartner := if($res//nlj250:EQUITY_PARTNERS/text() ne '') then $res//nlj250:EQUITY_PARTNERS/text() else json:null()
										let $EquityPartner_Per := if($num_attorneys ne 0) then fn:format-number(($EquityPartner div $num_attorneys)*100 ,'.00') else json:null()
										let $NonEquityPartner := if($res//nlj250:NUM_NE_PARTNERS/text() ne '') then $res//nlj250:NUM_NE_PARTNERS/text() else json:null()
										let $NonEquityPartner_Per := if($num_attorneys ne 0) then fn:format-number(($NonEquityPartner div $num_attorneys)*100 ,'.00') else json:null()
										let $_ := (
														map:put($response-obj,'ORGANIZATION_ID',xs:integer($organizationID)),
													map:put($response-obj,'ORGANIZATION_NAME',$organizationName),
													map:put($response-obj,'Associate', if(xs:string($associates) ne '') then $associates else json:null()),
													map:put($response-obj,'Associate_Per', $Associate_Per),
													map:put($response-obj,'EquityPartner_Per', $EquityPartner_Per),
													map:put($response-obj,'EquityPartner', $EquityPartner),
													map:put($response-obj,'NonEquityPartner', $NonEquityPartner),
													map:put($response-obj,'NonEquityPartner_Per', $NonEquityPartner_Per),
													map:put($response-obj,'PUBLISHYEAR',xs:integer($year)),
													map:put($response-obj,'TotalLawyers',$num_attorneys)
													)
										let $_ := json:array-push($response-arr, $response-obj)
										return()
										return()

	return $response-arr
};

declare function mergertool:GetGrowthinAssociateandPartners($request)
{
	let $distinctYears := cts:element-attribute-values(xs:QName('survey:YEAR'),xs:QName('PublishYear'),(),('descending'),
	cts:and-query((
		cts:directory-query('/LegalCompass/denormalized-data/surveys/NLJ_250/','1')
	))
	)
	
	let $distinctYears := if($request/StartYear/text() ne '' and $request/EndYear/text() ne '') then
						for $year in $distinctYears
						where $year ge xs:integer($request/StartYear/text()) and $year le xs:integer($request/EndYear/text())
						return $year
						else $distinctYears[1 to 5]

	let $organizationIDs := $request/FirmID/text()
	let $response-arr := json:array()
	
	let $loopData := for $organizationID in fn:tokenize($organizationIDs , ',')

						let $organization := fn:doc(fn:concat('/LegalCompass/denormalized-data/organization/',$organizationID,'.xml'))
						
						let $organizationName := $organization//organization:ORGANIZATION_SHORT_NAME/text()

						let $data := for $year in (reverse($distinctYears))
										let $response-obj := json:object()
										let $res := cts:search(/,
														cts:and-query((
														cts:directory-query("/LegalCompass/relational-data/surveys/NLJ_250/","1"),
														cts:element-value-query(xs:QName("nlj250:PUBLISHYEAR"),xs:string($year)),
														cts:element-value-query(xs:QName("nlj250:ORGANIZATION_ID"),$organizationID)
														)))
														
										let $lag  := cts:search(/,
														cts:and-query((
														cts:directory-query("/LegalCompass/relational-data/surveys/NLJ_250/","1"),
														cts:element-value-query(xs:QName("nlj250:PUBLISHYEAR"),xs:string($year - 1)),
														cts:element-value-query(xs:QName("nlj250:ORGANIZATION_ID"),$organizationID)
														)))
								
										let $num_associates := $res//nlj250:NUM_ASSOCIATES/text() 
										let $lag_num_associates := $lag//nlj250:NUM_ASSOCIATES/text() 
										let $AssociateChange := fn:format-number((($num_associates -  $lag_num_associates) div $lag_num_associates)*100, ".00")
             
										let $num_partners := $res//nlj250:NUM_PARTNERS/text()             
										let $lag_num_partners := $lag//nlj250:NUM_PARTNERS/text()
										let $PartnerChange := fn:format-number((($num_partners -  $lag_num_partners) div $lag_num_partners)*100, ".00")

										let $_ := (
														map:put($response-obj,'ORGANIZATION_ID',xs:integer($organizationID)),
													map:put($response-obj,'ORGANIZATION_NAME',$organizationName),
													map:put($response-obj,'AssociateChange', $AssociateChange),
													map:put($response-obj,'PartnerChange', $PartnerChange),
													map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
														)
										let $_ := if($res ne '' and $lag ne '') then json:array-push($response-arr, $response-obj) else()

										return()
										return()
	return ($response-arr)
};

declare function mergertool:GetLeverage($request)
{	
	let $distinctYears := cts:element-attribute-values(xs:QName('survey:YEAR'),xs:QName('PublishYear'),(),('descending'),
		cts:and-query((
		cts:directory-query('/LegalCompass/denormalized-data/surveys/NLJ_250/','1')
		)))

	let $distinctYears := if($request/StartYear/text() ne '' and $request/EndYear/text() ne '') then
							for $year in $distinctYears
							where $year ge xs:integer($request/StartYear/text()) and $year le xs:integer($request/EndYear/text())
							return $year
							else $distinctYears[1 to 5]


	
	let $OrganizationIDs := $request//FirmID/text()
	let $uk50ID := cts:search(/,
												cts:and-query((
													cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/")(:,
													cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string($year)):),
													cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),fn:tokenize($OrganizationIDs ,','))
													)))//UK_50:ORGANIZATION_ID/text()
	let $response-arr := json:array()

	let $loopData := for $OrganizationID in fn:tokenize($OrganizationIDs ,',')

						let $OrganizationName := if((/organization[organizations:ORGANIZATION_ID = xs:string($OrganizationID)]/organizations:ALM_NAME/text())[1] ne '')then 
							/organization[organizations:ORGANIZATION_ID = xs:string($OrganizationID)]/organizations:ALM_NAME/text()[1]
						else 
							/organization[organizations:ORGANIZATION_ID = xs:string($OrganizationID)]/organizations:ORGANIZATION_NAME/text()[1]


						let $amlaw200maxYearData := cts:search(/,
												cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/surveys/NLJ_250/','1')
													,cts:element-value-query(xs:QName('nlj250:PUBLISHYEAR'),xs:string(max($distinctYears)))
													,cts:element-value-query(xs:QName('nlj250:ORGANIZATION_ID'),$OrganizationID)
													)))[1]

						let $uk50maxYearData := cts:search(/,
								cts:and-query((
									cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
									cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string(fn:max($distinctYears))),
									cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),xs:string($OrganizationID))
								)))[1]		


						let $global100YearData := cts:search(/,
								cts:and-query((
									cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
									cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string(fn:max($distinctYears))),
									cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),xs:string($OrganizationID))
								)))[1]		

						let $maxYearData := if($uk50maxYearData ne '' or $amlaw200maxYearData ne '' or $global100YearData ne '') then 'Y' else ()

						let $data := for $year in reverse($distinctYears)
						
										let $response-obj := json:object()
										let $a := cts:search(/,
											cts:and-query((
												cts:directory-query('/LegalCompass/relational-data/surveys/NLJ_250/','1')
												,cts:element-value-query(xs:QName('nlj250:PUBLISHYEAR'),xs:string($year))
												,cts:element-value-query(xs:QName('nlj250:ORGANIZATION_ID'),$OrganizationID)
												)))
											
										let $d := cts:search(/,
											cts:and-query((
												cts:directory-query('/LegalCompass/relational-data/surveys/Global_100/','1')
												,cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($year))
												,cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$OrganizationID)
												)))  
										let $e := cts:search(/,
											cts:and-query((
												cts:directory-query('/LegalCompass/relational-data/surveys/UK_50/','1')
												,cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string($year))
												,cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),$OrganizationID)
												)))
										let $g := cts:search(/,
											cts:and-query((
												cts:directory-query('/LegalCompass/relational-data/surveys/CHINA_40/','1')
												,cts:element-value-query(xs:QName('CHINA_40:PUBLISHYEAR'),xs:string($year))
												,cts:element-value-query(xs:QName('CHINA_40:ORGANIZATION_ID'),$OrganizationID)
												)))  

										let $amlawData := cts:search(/,
											cts:and-query((
												cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/','1')
												,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year))
												,cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$OrganizationID)
												))) 		

										let $NUM_ATTORNEYS := if(fn:not($a//nlj250:NUM_NE_PARTNERS/text() ne "") and fn:not($d//Global_100:NUM_LAWYERS/text() ne ""))
										then 
											if(fn:not($e//UK_50:NUMBER_OF_LAWYERS/text() ne ""))
											then ($g//CHINA_40:FIRMWIDE_LAWYERS/text() - $g//CHINA_40:EQUITY_PARTNERS/text()) div $g//CHINA_40:EQUITY_PARTNERS/text()
											else $e//UK_50:LEVERAGE/text()
										else 
											if(fn:not($a//nlj250:NUM_NE_PARTNERS/text() ne ''))
											then ($d//Global_100:NUM_LAWYERS/text() -  $d//Global_100:NUM_EQUITY_PARTNERS/text())  div $d//Global_100:NUM_EQUITY_PARTNERS/text() 
											else ($a//nlj250:NUM_ASSOCIATES/text()) div ($a//nlj250:NUM_PARTNERS/text() - ($a//nlj250:NUM_NE_PARTNERS/text()))
										
										let $isAddMaxYear := if(xs:string($year) ne xs:string(max($distinctYears))) then 'y' else
																	if($a ne '' or $d ne '' or $e ne '' or $g ne '') then 'y' else 'n' 

										let $totalLawyer :=	if($amlawData//AMLAW_200:NUM_OF_LAWYERS/text()) then xs:string($amlawData//AMLAW_200:NUM_OF_LAWYERS/text())
															else if($d//Global_100:NUM_LAWYERS/text()) then xs:string($d//Global_100:NUM_LAWYERS/text())
															else if($e//UK_50:NUMBER_OF_LAWYERS/text()) then xs:string($e//UK_50:NUMBER_OF_LAWYERS/text()) else 0

										let $equityPartner := if($amlawData//AMLAW_200:NUM_EQ_PARTNERS/text()) then xs:string($amlawData//AMLAW_200:NUM_EQ_PARTNERS/text())
																else if($d//Global_100:NUM_EQUITY_PARTNERS/text()) then xs:string($d//Global_100:NUM_EQUITY_PARTNERS/text())
																else if($e//UK_50:NUMBER_OF_EQ_PARTNERS/text()) then xs:string($e//UK_50:NUMBER_OF_EQ_PARTNERS/text()) else 0

										 let $lev := if($equityPartner) then (xs:integer($totalLawyer) - xs:integer($equityPartner)) div xs:integer($equityPartner) else 0
										let $_ := (
												map:put($response-obj,'ORGANIZATION_ID',xs:integer($OrganizationID)),
												map:put($response-obj,'ORGANIZATION_NAME', $OrganizationName),
												map:put($response-obj,'CHANGE', fn:round-half-to-even($lev,2)),
												map:put($response-obj,'PUBLISHYEAR',xs:integer($year)),
												map:put($response-obj,'TotalLawyers',$totalLawyer),
												map:put($response-obj,'lev',$lev),
												map:put($response-obj,'NumberOfEquityPartner',$equityPartner)
												)
										let $_ :=if(xs:string($year) ne xs:string(max($distinctYears))) then json:array-push($response-arr, $response-obj) else
													if($maxYearData ne '' and ($a ne '' or $d ne '' or $e ne '' or $g ne ''))
																then json:array-push($response-arr,$response-obj) else()
 
  										return ()  
										return()  

	let $surveyData := for $year in reverse($distinctYears)

							(:--------------2nd Part-------------:)
							let $response-obj := json:object()        
							let $amlaw200CurrentYear  := fn:avg(cts:search(/,
															cts:and-query((
															cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/')
															,cts:element-range-query(xs:QName('AMLAW_200:AMLAW200_RANK'), '<=',100)
															,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year))
															,cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
															)))//AMLAW_200:LEVERAGE/text())	

							let $amlaw200PreYear  := fn:avg(cts:search(/,
															cts:and-query((
															cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/')
															,cts:element-range-query(xs:QName('AMLAW_200:AMLAW200_RANK'), '<=',100)
															,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string(xs:integer($year)-1))
															,cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
															)))//AMLAW_200:LEVERAGE/text())								
									
							let $result := fn:round-half-to-even((($amlaw200CurrentYear - $amlaw200PreYear ) div $amlaw200PreYear) * 100 ,2)
							
							let $_ := (
									map:put($response-obj,'ORGANIZATION_ID',xs:integer(0)),
									map:put($response-obj,'ORGANIZATION_NAME','Am Law 100'),
									map:put($response-obj,'CHANGE', $result),
									map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
									)
							let $_ :=json:array-push($response-arr, $response-obj)

							(:--------------3rd Part-------------:)
							let $response-obj := json:object()        
							let $amlaw200CurrentYear  := fn:avg(cts:search(/,
															cts:and-query((
															cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/')
															,cts:element-range-query(xs:QName('AMLAW_200:AMLAW200_RANK'), '>',100)
															,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year))
															,cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
															)))//AMLAW_200:LEVERAGE/text())	

							let $amlaw200PreYear  := fn:avg(cts:search(/,
															cts:and-query((
															cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/')
															,cts:element-range-query(xs:QName('AMLAW_200:AMLAW200_RANK'), '>',100)
															,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string(xs:integer($year)-1))
															,cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
															)))//AMLAW_200:LEVERAGE/text())								
									
							let $result := fn:round-half-to-even((($amlaw200CurrentYear - $amlaw200PreYear ) div $amlaw200PreYear) * 100 ,2)
							
							let $_ := (
									map:put($response-obj,'ORGANIZATION_ID',xs:integer(0)),
									map:put($response-obj,'ORGANIZATION_NAME','Am Law 2nd Hundred'),
									map:put($response-obj,'CHANGE', $result),
									map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
									)
							let $_ := json:array-push($response-arr, $response-obj)

 
							(:-------UK50---------:)
							let $response-obj := json:object()
							

							let $distinctid_gt_100_Current := fn:distinct-values(cts:search(/,
												cts:and-query((
													cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
													cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string($year))
													)))//UK_50:ORGANIZATION_ID/text())

							
							let $res3 := avg(cts:search(/,
													cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/surveys/UK_50/','1')
													(:,cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),($distinctid_gt_100 ! xs:string(.))):)
													,cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'), xs:string($year))
													)))//UK_50:LEVERAGE/text())
								
							let $distinctid_gt_100  :=fn:distinct-values(cts:search(/,
												cts:and-query((
													cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
													cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string(xs:integer($year) - 1))
													)))//UK_50:ORGANIZATION_ID/text())
								
							let $res3-LAG :=avg(cts:search(/,
													cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/surveys/UK_50/','1')
													(:,cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),($distinctid_gt_100 ! xs:string(.))):)
													,cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'), xs:string(xs:integer($year) -1))
													)))//UK_50:LEVERAGE/text())
								
							let $difference := $res3 - $res3-LAG

							let $CHANGE := if(fn:not($distinctid_gt_100_Current != '') or fn:not($distinctid_gt_100 != '')) then -1000
											else if($res3 ne 0 and $res3-LAG ne 0) then fn:round-half-to-even((xs:double($difference) div  $res3-LAG ) * 100 , 2) else 0
								
							let $_ :=(
									map:put($response-obj,'ORGANIZATION_ID', 0),
								map:put($response-obj,'ORGANIZATION_NAME', 'UK 100'),
								map:put($response-obj,'CHANGE', $CHANGE),
								map:put($response-obj,'distinctid_gt_100_Current', $distinctid_gt_100_Current),
								map:put($response-obj,'distinctid_gt_100', $distinctid_gt_100),
								map:put($response-obj,'PUBLISHYEAR',xs:integer($year))
								)
							let $_ :=if($uk50ID != '') then json:array-push($response-arr, $response-obj) else()
							return ()  									
	return $response-arr

};

declare function mergertool:GetFirmStaffingDiversityMetrics($request)
{
	let $distinctYears := cts:element-attribute-values(xs:QName('survey:YEAR'),xs:QName('PublishYear'),(),('descending'),
							cts:and-query((
								cts:directory-query($config:DD-SURVEY-DIVERSITY_SCORECARD-PATH,'1')
							)))[1 to 5]

	let $organizationIDs := $request/FirmID/text()						
	let $response-arr := json:array()
	let $year := max($distinctYears)

	let $diversityScore := avg(cts:search(/,
								cts:and-query((
								cts:directory-query('/LegalCompass/relational-data/surveys/Diversity_Scorecard/','1'),
								cts:element-value-query(xs:QName('Diversity_Scorecard:PUBLISHYEAR'),xs:string($year)),
								cts:element-value-query(xs:QName('Diversity_Scorecard:ORGANIZATION_ID'),fn:tokenize($organizationIDs,','))
								)))//Diversity_Scorecard:DIVERSITY_SCORE/text())

	let $lgbtPer := avg(cts:search(/,
							cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/surveys/NLJ_LGBT/','1'),
							cts:element-value-query(xs:QName('nljlgbt:PUBLISHYEAR'),xs:string($year)),
							cts:element-value-query(xs:QName('nljlgbt:ORGANIZATION_ID'),fn:tokenize($organizationIDs,','))
							)))//nljlgbt:PERCENT_LGBT_ATTORNEYS/text())

	let $womenInLawScore := avg(cts:search(/,
						cts:and-query((
						cts:directory-query('/LegalCompass/relational-data/surveys/FEMALE_SCORECARD/','1'),
						cts:element-value-query(xs:QName('FEMALE_SCORECARD:PUBLISHYEAR'),xs:string($year)),
						cts:element-value-query(xs:QName('FEMALE_SCORECARD:ORGANIZATION_ID'),fn:tokenize($organizationIDs,','))
						)))//FEMALE_SCORECARD:WOMEN_IN_LAW_SCORE/text())

	let $minPer := cts:search(/,
										cts:and-query((
											cts:directory-query('/LegalCompass/relational-data/surveys/Diversity_Scorecard/','1'),
											cts:element-value-query(xs:QName('Diversity_Scorecard:PUBLISHYEAR'),xs:string($year)),
											cts:element-value-query(xs:QName('Diversity_Scorecard:ORGANIZATION_ID'),fn:tokenize($organizationIDs,','))
										)))

	let $femalePer := cts:search(/,
						cts:and-query((
						cts:directory-query('/LegalCompass/relational-data/surveys/FEMALE_SCORECARD/','1'),
						cts:element-value-query(xs:QName('FEMALE_SCORECARD:PUBLISHYEAR'),xs:string($year)),
						cts:element-value-query(xs:QName('FEMALE_SCORECARD:ORGANIZATION_ID'),fn:tokenize($organizationIDs,','))
						)))

	let $lgbtPercentage := 	cts:search(/,
								cts:and-query((
								cts:directory-query('/LegalCompass/relational-data/surveys/NLJ_LGBT/','1'),
								cts:element-value-query(xs:QName('nljlgbt:PUBLISHYEAR'),xs:string($year)),
								cts:element-value-query(xs:QName('nljlgbt:ORGANIZATION_ID'),fn:tokenize($organizationIDs,','))
								)))	

	 let $combinedMinorityPercentage := if($minPer//Diversity_Scorecard:US_ATTORNEYS/text() != '') then (sum($minPer//Diversity_Scorecard:TOTAL_MINORITY_ATTORNEYS/text()) div sum($minPer//Diversity_Scorecard:US_ATTORNEYS/text())) else 0
	 
	 let $combinedFemalePercentage := if($femalePer//FEMALE_SCORECARD:TOTAL_ATTORNEYS/text() != '') then (sum($femalePer//FEMALE_SCORECARD:FEMALE_ATTORNEYS/text()) div sum($femalePer//FEMALE_SCORECARD:TOTAL_ATTORNEYS/text())) else 0
	 let $combinedLGBTPercentage := if($lgbtPercentage//nljlgbt:LAWYERS_USA/text() != '') then (sum($lgbtPercentage//nljlgbt:TOTAL_LGBT_ATTORNEYS/text()) div sum($lgbtPercentage//nljlgbt:LAWYERS_USA/text())) else 0
	 let $combinedFemalePartnerPercentage := if($femalePer//FEMALE_SCORECARD:TOTAL_PARTNERS/text() != '') then (sum($femalePer//FEMALE_SCORECARD:FEMALE_PARTNERS/text()) div sum($femalePer//FEMALE_SCORECARD:TOTAL_PARTNERS/text())) else 0

	 let $CombinedDiversityRank := if(xs:string($diversityScore) ne '') then mergertool:GetCombinedDiversityrank($diversityScore,$year) else 0 
	 let $combinedLGBTRank := if(xs:string($lgbtPer) ne '') then mergertool:GetCombinedLGBTrank($lgbtPer,$year) else 0 
	 let $combinedGenderRank := if(xs:string($womenInLawScore) ne '') then mergertool:GetCombinedGenderrank($womenInLawScore,$year) else 0 
	 let $loopData := for $organizationID in fn:tokenize($organizationIDs,',')
						
						let $response-obj := json:object()
						let $a := cts:search(/,
											cts:and-query((
											cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/','1'),
											cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year)),
											cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$organizationID)
											)))

						let $b := cts:search(/,
											cts:and-query((
											cts:directory-query('/LegalCompass/relational-data/surveys/Diversity_Scorecard/','1'),
											cts:element-value-query(xs:QName('Diversity_Scorecard:PUBLISHYEAR'),xs:string($year)),
											cts:element-value-query(xs:QName('Diversity_Scorecard:ORGANIZATION_ID'),$organizationID)
											)))

						let $c := cts:search(/,
											cts:and-query((
											cts:directory-query('/LegalCompass/relational-data/surveys/FEMALE_SCORECARD/','1'),
											cts:element-value-query(xs:QName('FEMALE_SCORECARD:PUBLISHYEAR'),xs:string($year)),
											cts:element-value-query(xs:QName('FEMALE_SCORECARD:ORGANIZATION_ID'),$organizationID)
											)))[1]
						let $d := cts:search(/,
											cts:and-query((
											cts:directory-query('/LegalCompass/relational-data/surveys/NLJ_LGBT/','1'),
											cts:element-value-query(xs:QName('nljlgbt:PUBLISHYEAR'),xs:string($year)),
											cts:element-value-query(xs:QName('nljlgbt:ORGANIZATION_ID'),$organizationID)
											)))

						let $nlj250 := cts:search(/,
											cts:and-query((
											cts:directory-query('/LegalCompass/relational-data/surveys/NLJ_250/','1'),
											cts:element-value-query(xs:QName('nlj250:PUBLISHYEAR'),xs:string($year)),
											cts:element-value-query(xs:QName('nlj250:ORGANIZATION_ID'),$organizationID)
											)))

						let $firmName := mergertool:GetOrganizationName($organizationID)										    
				

						let $LGBT_PARTNERS := $d//nljlgbt:LGBT_PARTNERS/text()
				

						let $PercentageOfLgbtPartners := if($LGBT_PARTNERS != 0 and $LGBT_PARTNERS ne "")
							then xs:decimal(fn:format-number(((($d//nljlgbt:LGBT_PARTNERS/text())) div ($nlj250//nlj250:NUM_PARTNERS/text())) * 100 , '.00'))
							else 0	

						let $AfricanAmericanAttorneys := $b//Diversity_Scorecard:AFRICAN_AMERICAN_PARTNERS + $b//Diversity_Scorecard:AFRICAN_AMERICAN_ASSOCIATES

						let $AsianAmericanAttorneys := $b//Diversity_Scorecard:ASIAN_AMERICAN_PARTNERS + $b//Diversity_Scorecard:ASIAN_AMERICAN_ASSOCIATES

						let $HispanicLatinoAttorneys := $b//Diversity_Scorecard:HISPANIC_ASSOCIATES + $b//Diversity_Scorecard:HISPANIC_PARTNERS
						
						let $diversityRank := if($b//Diversity_Scorecard:DIVERSITY_RANK/string() ne '') then $b//Diversity_Scorecard:DIVERSITY_RANK/string() else 0
						let $firmGenderRank := if($c//FEMALE_SCORECARD:WOMEN_IN_LAW_RANK/string() ne '') then $c//FEMALE_SCORECARD:WOMEN_IN_LAW_RANK/string() else 0
						let $firmLGBTRank := if($d//nljlgbt:NLJ_LGBT_RANK/string() ne '') then $d//nljlgbt:NLJ_LGBT_RANK/string() else 0
						let $usAttorneys := if($b//Diversity_Scorecard:US_ATTORNEYS/string() ne '') then $b//Diversity_Scorecard:US_ATTORNEYS/string() else 0
						let $perOfMinorityAttorney := if($b//Diversity_Scorecard:MINORITY_PERCENTAGE/string() ne '') then $b//Diversity_Scorecard:MINORITY_PERCENTAGE/string() else 0
						let $perOfFemaleAttorney := if($c//FEMALE_SCORECARD:PCT_FEMALE_ATTORNEYS/string() ne '') then $c//FEMALE_SCORECARD:PCT_FEMALE_ATTORNEYS/string() else 0
						let $perOfLGBTAttorney := if($d//nljlgbt:PERCENT_LGBT_ATTORNEYS/string() ne '') then $d//nljlgbt:PERCENT_LGBT_ATTORNEYS/string() else 0
						let $perOfMinorityPartner := if($b//Diversity_Scorecard:MINORITY_PERC_PARTNERS/string() ne '') then $b//Diversity_Scorecard:MINORITY_PERC_PARTNERS/string() else 0
						let $perOfFemalePartner := if($c//FEMALE_SCORECARD:PCT_FEMALE_PARTNERS/string() ne '') then $c//FEMALE_SCORECARD:PCT_FEMALE_PARTNERS/string() else 0
						let $multiRacialAttorney := if($b//Diversity_Scorecard:TOTAL_MINORITY_ATTORNEYS/text() ne '') then $b//Diversity_Scorecard:TOTAL_MINORITY_ATTORNEYS/text() else 0
						let $_ := (
									map:put($response-obj,'ORGANIZATIONID', xs:integer($organizationID)),
									map:put($response-obj,'ORGANIZATIONNAME', $firmName),
									map:put($response-obj,'PUBLISHYEAR',  xs:integer($year)),
									map:put($response-obj,'FirmDiversityRank',  xs:integer($diversityRank)),
									map:put($response-obj,'FirmGenderRank',  xs:integer($firmGenderRank)),
									map:put($response-obj,'CombinedFirmDiversityRank',  $CombinedDiversityRank),
									map:put($response-obj,'CombinedFirmLgbtRank',  $combinedLGBTRank),
									map:put($response-obj,'CombinedFirmGenderRank',  $combinedGenderRank),
									map:put($response-obj,'CombinedPercentageOfMinorityAttorneys',  fn:round-half-to-even($combinedMinorityPercentage,2)),
									map:put($response-obj,'CombinedPercentageOfFemaleAttorneys',  fn:round-half-to-even($combinedFemalePercentage,2)),
									map:put($response-obj,'CombinedPercentageOfLgbtAttorneys',  fn:round-half-to-even($combinedLGBTPercentage,2)),
									map:put($response-obj,'CombinedPercentageOfFemalePartners',  fn:round-half-to-even($combinedFemalePartnerPercentage,2)),
									map:put($response-obj,'FirmLgbtRank',  xs:integer($firmLGBTRank)),
									map:put($response-obj,'UsAttorneys',  xs:integer($usAttorneys)),
									map:put($response-obj,'PercentageOfMinorityAttorneys',  xs:decimal($perOfMinorityAttorney) * 100),
									map:put($response-obj,'PercentageOfFemaleAttorneys',  xs:decimal($perOfFemaleAttorney) * 100),
									map:put($response-obj,'PercentageOfLgbtAttorneys',  xs:decimal($perOfLGBTAttorney) * 100),
									map:put($response-obj,'PercentageOfMinorityPartners',  xs:decimal($perOfMinorityPartner) * 100),
									map:put($response-obj,'PercentageOfFemalePartners',  xs:decimal($perOfFemalePartner) * 100),
									map:put($response-obj,'PercentageOfLgbtPartners',  ($PercentageOfLgbtPartners)),
									map:put($response-obj,'AfricanAmericanAttorneys',  if($AfricanAmericanAttorneys) then xs:decimal($AfricanAmericanAttorneys) else 0),
									map:put($response-obj,'AsianAmericanAttorneys',  if($AsianAmericanAttorneys) then xs:decimal($AsianAmericanAttorneys) else 0),
									map:put($response-obj,'HispanicLatinoAttorneys',  if($HispanicLatinoAttorneys) then xs:decimal($HispanicLatinoAttorneys) else 0),
									map:put($response-obj,'MultiracialOtherMinorityAtt', $multiRacialAttorney)
								)
						let $_ := json:array-push($response-arr, $response-obj)
						return()  
	return ($response-arr)
	
};

declare function mergertool:GetFirmStaffingDiversityMetricsPostMerger($request)
{
	let $distinctYears := cts:element-attribute-values(xs:QName('survey:YEAR'),xs:QName('PublishYear'),(),('descending'),
							cts:and-query((
								cts:directory-query($config:DD-SURVEY-DIVERSITY_SCORECARD-PATH,'1')
							)))[1 to 5]

	let $OrganisationID := $request//OrganisationID/text()
	let $checkMergerData := firmnew:GetLawFirmMergerData($OrganisationID)
	let $orgIDs := if($checkMergerData != '') then fn:tokenize(fn:concat(fn:string-join(fn:tokenize($checkMergerData,'[|]'),','),',',$OrganisationID),',') else $OrganisationID	
	
	let $response-arr := json:array()
	let $loopData := for $year in fn:reverse($distinctYears)

						let $diversityScore := avg(cts:search(/,
													cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/surveys/Diversity_Scorecard/','1'),
													cts:element-value-query(xs:QName('Diversity_Scorecard:PUBLISHYEAR'),xs:string($year)),
													cts:element-value-query(xs:QName('Diversity_Scorecard:ORGANIZATION_ID'),$orgIDs)
													)))//Diversity_Scorecard:DIVERSITY_SCORE/text())

						let $lgbtPer := avg(cts:search(/,
												cts:and-query((
												cts:directory-query('/LegalCompass/relational-data/surveys/NLJ_LGBT/','1'),
												cts:element-value-query(xs:QName('nljlgbt:PUBLISHYEAR'),xs:string($year)),
												cts:element-value-query(xs:QName('nljlgbt:ORGANIZATION_ID'),$orgIDs)
												)))//nljlgbt:PERCENT_LGBT_ATTORNEYS/text())

						let $womenInLawScore := avg(cts:search(/,
											cts:and-query((
											cts:directory-query('/LegalCompass/relational-data/surveys/FEMALE_SCORECARD/','1'),
											cts:element-value-query(xs:QName('FEMALE_SCORECARD:PUBLISHYEAR'),xs:string($year)),
											cts:element-value-query(xs:QName('FEMALE_SCORECARD:ORGANIZATION_ID'),$orgIDs)
											)))//FEMALE_SCORECARD:WOMEN_IN_LAW_SCORE/text())

						let $minPer := cts:search(/,
															cts:and-query((
																cts:directory-query('/LegalCompass/relational-data/surveys/Diversity_Scorecard/','1'),
																cts:element-value-query(xs:QName('Diversity_Scorecard:PUBLISHYEAR'),xs:string($year)),
																cts:element-value-query(xs:QName('Diversity_Scorecard:ORGANIZATION_ID'),$orgIDs)
															)))

						let $femalePer := cts:search(/,
											cts:and-query((
											cts:directory-query('/LegalCompass/relational-data/surveys/FEMALE_SCORECARD/','1'),
											cts:element-value-query(xs:QName('FEMALE_SCORECARD:PUBLISHYEAR'),xs:string($year)),
											cts:element-value-query(xs:QName('FEMALE_SCORECARD:ORGANIZATION_ID'),$orgIDs)
											)))

						let $lgbtPercentage := 	cts:search(/,
													cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/surveys/NLJ_LGBT/','1'),
													cts:element-value-query(xs:QName('nljlgbt:PUBLISHYEAR'),xs:string($year)),
													cts:element-value-query(xs:QName('nljlgbt:ORGANIZATION_ID'),$orgIDs)
													)))	

										


						let $combinedMinorityPercentage := if(sum($minPer//Diversity_Scorecard:US_ATTORNEYS/text()) > 0) then (sum($minPer//Diversity_Scorecard:TOTAL_MINORITY_ATTORNEYS/text()) div sum($minPer//Diversity_Scorecard:US_ATTORNEYS/text())) else 0
						
						let $combinedFemalePercentage := if($femalePer//FEMALE_SCORECARD:TOTAL_ATTORNEYS/text() != '') then (sum($femalePer//FEMALE_SCORECARD:FEMALE_ATTORNEYS/text()) div sum($femalePer//FEMALE_SCORECARD:TOTAL_ATTORNEYS/text())) else 0
						let $combinedLGBTPercentage := if($lgbtPercentage//nljlgbt:LAWYERS_USA/text() != '') then (sum($lgbtPercentage//nljlgbt:TOTAL_LGBT_ATTORNEYS/text()) div sum($lgbtPercentage//nljlgbt:LAWYERS_USA/text())) else 0
						let $combinedFemalePartnerPercentage := if($femalePer//FEMALE_SCORECARD:TOTAL_PARTNERS/text() != '') then (sum($femalePer//FEMALE_SCORECARD:FEMALE_PARTNERS/text()) div sum($femalePer//FEMALE_SCORECARD:TOTAL_PARTNERS/text())) else 0

						let $CombinedDiversityRank := if(xs:string($diversityScore) ne '') then mergertool:GetCombinedDiversityrank($diversityScore,$year) else 0 
						let $combinedLGBTRank := if(xs:string($lgbtPer) ne '') then mergertool:GetCombinedLGBTrank($lgbtPer,$year) else 0 
						let $combinedGenderRank := if(xs:string($womenInLawScore) ne '') then mergertool:GetCombinedGenderrank($womenInLawScore,$year) else 0 
	 
											
											let $response-obj := json:object()
											let $a := cts:search(/,
																cts:and-query((
																cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/','1'),
																cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year)),
																cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$orgIDs)
																)))

											let $b := cts:search(/,
																cts:and-query((
																cts:directory-query('/LegalCompass/relational-data/surveys/Diversity_Scorecard/','1'),
																cts:element-value-query(xs:QName('Diversity_Scorecard:PUBLISHYEAR'),xs:string($year)),
																cts:element-value-query(xs:QName('Diversity_Scorecard:ORGANIZATION_ID'),$orgIDs)
																)))

											let $c := cts:search(/,
																cts:and-query((
																cts:directory-query('/LegalCompass/relational-data/surveys/FEMALE_SCORECARD/','1'),
																cts:element-value-query(xs:QName('FEMALE_SCORECARD:PUBLISHYEAR'),xs:string($year)),
																cts:element-value-query(xs:QName('FEMALE_SCORECARD:ORGANIZATION_ID'),$orgIDs)
																)))[1]
											let $d := cts:search(/,
																cts:and-query((
																cts:directory-query('/LegalCompass/relational-data/surveys/NLJ_LGBT/','1'),
																cts:element-value-query(xs:QName('nljlgbt:PUBLISHYEAR'),xs:string($year)),
																cts:element-value-query(xs:QName('nljlgbt:ORGANIZATION_ID'),$orgIDs)
																)))

											let $nlj250 := cts:search(/,
																cts:and-query((
																cts:directory-query('/LegalCompass/relational-data/surveys/NLJ_250/','1'),
																cts:element-value-query(xs:QName('nlj250:PUBLISHYEAR'),xs:string($year)),
																cts:element-value-query(xs:QName('nlj250:ORGANIZATION_ID'),$orgIDs)
																)))

											let $firmName := (:mergertool:GetOrganizationName($orgIDs[1]):) ''
				

											let $LGBT_PARTNERS := sum($d//nljlgbt:LGBT_PARTNERS/text())
									

											let $PercentageOfLgbtPartners := if($nlj250//nlj250:NUM_PARTNERS/text() != "")
												then (sum($d//nljlgbt:LGBT_PARTNERS/text()) div sum($nlj250//nlj250:NUM_PARTNERS/text())) * 100
												else 0	

											let $AfricanAmericanAttorneys := sum($b//Diversity_Scorecard:AFRICAN_AMERICAN_PARTNERS) + sum($b//Diversity_Scorecard:AFRICAN_AMERICAN_ASSOCIATES)

											let $AsianAmericanAttorneys := sum($b//Diversity_Scorecard:ASIAN_AMERICAN_PARTNERS) + sum($b//Diversity_Scorecard:ASIAN_AMERICAN_ASSOCIATES)

											let $HispanicLatinoAttorneys := sum($b//Diversity_Scorecard:HISPANIC_ASSOCIATES) + sum($b//Diversity_Scorecard:HISPANIC_PARTNERS)
						
											
											let $usAttorneys := if($b//Diversity_Scorecard:US_ATTORNEYS/string() != '') then sum($b//Diversity_Scorecard:US_ATTORNEYS/text()) else 0
											
											let $perOfMinorityPartner := if($b//Diversity_Scorecard:MINORITY_PERC_PARTNERS/string() != '') then sum($b//Diversity_Scorecard:MINORITY_PERC_PARTNERS/text()) else 0
											
											let $multiRacialAttorney := if($b//Diversity_Scorecard:TOTAL_MINORITY_ATTORNEYS/text() != '') then sum($b//Diversity_Scorecard:TOTAL_MINORITY_ATTORNEYS/text()) else 0
											let $_ := (
														map:put($response-obj,'ORGANIZATIONID', xs:integer($orgIDs[1])),
														map:put($response-obj,'ORGANIZATIONNAME', $firmName),
														map:put($response-obj,'PUBLISHYEAR',  xs:integer($year)),
														map:put($response-obj,'FirmDiversityRank',  $CombinedDiversityRank),
														map:put($response-obj,'FirmGenderRank',   $combinedGenderRank),
														map:put($response-obj,'FirmLgbtRank',  $combinedLGBTRank),
														map:put($response-obj,'UsAttorneys',  xs:integer($usAttorneys)),
														map:put($response-obj,'PercentageOfMinorityAttorneys',  fn:round-half-to-even($combinedMinorityPercentage,2) * 100),
														map:put($response-obj,'PercentageOfFemaleAttorneys',  fn:round-half-to-even($combinedFemalePercentage,2) * 100),
														map:put($response-obj,'PercentageOfLgbtAttorneys',  fn:round-half-to-even($combinedLGBTPercentage,2)* 100),
														map:put($response-obj,'PercentageOfMinorityPartners',  xs:decimal($perOfMinorityPartner) * 100),
														map:put($response-obj,'PercentageOfFemalePartners',  fn:round-half-to-even($combinedFemalePartnerPercentage,2) * 100),
														map:put($response-obj,'PercentageOfLgbtPartners',  fn:round-half-to-even($PercentageOfLgbtPartners,2)),
														map:put($response-obj,'AfricanAmericanAttorneys',  if($AfricanAmericanAttorneys) then xs:decimal($AfricanAmericanAttorneys) else 0),
														map:put($response-obj,'AsianAmericanAttorneys',  if($AsianAmericanAttorneys) then xs:decimal($AsianAmericanAttorneys) else 0),
														map:put($response-obj,'HispanicLatinoAttorneys',  if($HispanicLatinoAttorneys) then xs:decimal($HispanicLatinoAttorneys) else 0),
														map:put($response-obj,'MultiracialOtherMinorityAtt', $multiRacialAttorney)
													)
											let $_ := if(fn:not($a != '') and fn:not($b != '') and fn:not($c != '') and fn:not($d != '') and fn:not($nlj250 != '')) then ()
													else	json:array-push($response-arr, $response-obj)              
											
											return()
	return ($response-arr)
};

declare function mergertool:GetDiversityPartnerPieChart($request)
{
	let $year := max(cts:element-attribute-values(xs:QName('survey:YEAR'),xs:QName('PublishYear'),(),('descending'),
							cts:and-query((
								cts:directory-query($config:DD-SURVEY-DIVERSITY_SCORECARD-PATH,'1')
							))))

	let $response-arr := json:array()
	let $OrganisationIDs := $request//FirmID/text()

	let $data := for $OrganisationID in fn:tokenize($OrganisationIDs,',')
					let $response-obj := json:object()
					let $res := cts:search(/,
									cts:and-query((
										cts:directory-query('/LegalCompass/relational-data/surveys/Diversity_Scorecard/','1'),
										cts:element-value-query(xs:QName('Diversity_Scorecard:PUBLISHYEAR'),xs:string($year)),
										cts:element-value-query(xs:QName('Diversity_Scorecard:ORGANIZATION_ID'),$OrganisationID)
									)))[1]

					let $AFRICAN_AMERICAN_PARTNERS := if($res//Diversity_Scorecard:AFRICAN_AMERICAN_PARTNERS/string() ne '') then xs:integer($res//Diversity_Scorecard:AFRICAN_AMERICAN_PARTNERS/string()) else 0
					let $HISPANIC_PARTNERS := if($res//Diversity_Scorecard:HISPANIC_PARTNERS/string() ne '') then xs:integer($res//Diversity_Scorecard:HISPANIC_PARTNERS/string()) else 0
					let $ASIAN_AMERICAN_PARTNERS := if($res//Diversity_Scorecard:ASIAN_AMERICAN_PARTNERS/string() ne '') then xs:integer($res//Diversity_Scorecard:ASIAN_AMERICAN_PARTNERS/string()) else 0
					let $OTHER_PARTNERS := if($res//Diversity_Scorecard:OTHER_PARTNERS/string() ne '') then xs:integer($res//Diversity_Scorecard:OTHER_PARTNERS/string()) else 0
					let $MINORITY_PERC_PARTNERS := if($res//Diversity_Scorecard:MINORITY_PERC_PARTNERS/string() ne '') then xs:decimal($res//Diversity_Scorecard:MINORITY_PERC_PARTNERS/string()) else 0
					
					let $CAUCASIANPARTNERS := if($MINORITY_PERC_PARTNERS ne 0) then (($ASIAN_AMERICAN_PARTNERS+$AFRICAN_AMERICAN_PARTNERS+$HISPANIC_PARTNERS+$OTHER_PARTNERS) div $MINORITY_PERC_PARTNERS)-($ASIAN_AMERICAN_PARTNERS+$AFRICAN_AMERICAN_PARTNERS+$HISPANIC_PARTNERS+$OTHER_PARTNERS) else 0

					let $_ := (
									map:put($response-obj,'ORGANIZATIONID', xs:integer($OrganisationID)),
								map:put($response-obj,'ORGANIZATIONNAME', $res//Diversity_Scorecard:ORGANIZATION_NAME/text()),
								map:put($response-obj,'PUBLISHYEAR', xs:integer($year)),
								map:put($response-obj,'AFRICANAMERICANPARTNERS', xs:integer($AFRICAN_AMERICAN_PARTNERS)),
								map:put($response-obj,'HISPANICPARTNERS', xs:integer($HISPANIC_PARTNERS)),
								map:put($response-obj,'ASIANAMERICANPARTNERS',  xs:integer($ASIAN_AMERICAN_PARTNERS)),
								map:put($response-obj,'OTHERPARTNERS', xs:integer($OTHER_PARTNERS)),
								map:put($response-obj,'CAUCASIANPARTNERS', fn:round-half-to-even($CAUCASIANPARTNERS,0))
								)
					let $_ := json:array-push($response-arr, $response-obj)              
					return ()

	return ($response-arr)
};

declare function mergertool:GetDiversityGrowth($request)
{
	let $distinctYears := (cts:element-values(xs:QName('Diversity_Scorecard:PUBLISHYEAR'),(),('descending'),
		cts:and-query((
			cts:directory-query('/LegalCompass/relational-data/surveys/Diversity_Scorecard/','1')
		))))

	let $response-arr := json:array()
	
	let $OrganisationIDs := $request/FirmID/text()

	let $loopData := for $OrganisationID in fn:tokenize($OrganisationIDs,',')
		
							let $data := for $year in fn:reverse($distinctYears[1 to 5])
								let $response-obj := json:object()
								let $res := cts:search(/Diversity_Scorecard:DiversityScorecard,
									cts:and-query((
										cts:directory-query('/LegalCompass/relational-data/surveys/Diversity_Scorecard/','1')
										,cts:element-value-query(xs:QName('Diversity_Scorecard:PUBLISHYEAR'),xs:string($year))
										,cts:element-value-query(xs:QName('Diversity_Scorecard:ORGANIZATION_ID'),$OrganisationID)
									)))  
		
							let $total_attorneys := $res/Diversity_Scorecard:TOTAL_ATTORNEYS/text()
							
							let $PerOfMinorityAttorneys := fn:round-half-to-even(($res//Diversity_Scorecard:MINORITY_PERCENTAGE) * 100 , 2)
							let $PerOfAfricanAmericanAttorneys := fn:round-half-to-even((($res//Diversity_Scorecard:AFRICAN_AMERICAN_ASSOCIATES/text() + $res//Diversity_Scorecard:AFRICAN_AMERICAN_PARTNERS/text()) div $total_attorneys) * 100 , 2)
							let $PerOfAsianAmericanAttorneys := fn:round-half-to-even((($res//Diversity_Scorecard:ASIAN_AMERICAN_ASSOCIATES/text() + $res//Diversity_Scorecard:ASIAN_AMERICAN_PARTNERS/text()) div $total_attorneys) * 100 , 2)
							let $PerOfHispanicLatinoAttorneys := fn:round-half-to-even((($res//Diversity_Scorecard:HISPANIC_ASSOCIATES/text() + $res//Diversity_Scorecard:HISPANIC_PARTNERS/text()) div $total_attorneys) * 100 , 2)
							let $PerOfMultiracialOtherAttorneys := if(($res//Diversity_Scorecard:OTHER_ATTORNEYS/text() ne '' ))then
									fn:round-half-to-even((($res//Diversity_Scorecard:OTHER_ATTORNEYS/text()) div $total_attorneys) * 100 , 2)
								else ()
			
		
							let $_ := (
								map:put($response-obj,'ORGANIZATIONID', xs:integer($OrganisationID)),
								map:put($response-obj,'ORGANIZATIONNAME', ($res//Diversity_Scorecard:ORGANIZATION_NAME/text())),
								map:put($response-obj,'PUBLISHYEAR', xs:integer($res//Diversity_Scorecard:PUBLISHYEAR/text())),
								map:put($response-obj,'PerOfMinorityAttorneys', xs:decimal($PerOfMinorityAttorneys)),
								map:put($response-obj,'PerOfAfricanAmericanAttorneys', xs:decimal($PerOfAfricanAmericanAttorneys)),
								map:put($response-obj,'PerOfAsianAmericanAttorneys', xs:decimal($PerOfAsianAmericanAttorneys)),
								map:put($response-obj,'PerOfHispanicLatinoAttorneys', xs:decimal($PerOfHispanicLatinoAttorneys)),
								map:put($response-obj,'PerOfMultiracialOtherAttorneys',($PerOfMultiracialOtherAttorneys))
							) 
							
							let $_ := if($res ne '') then json:array-push($response-arr, $response-obj) else()
							return ()
					return()		

	return ($response-arr)
};

declare function mergertool:GetGenderBreakdown($request)
{
	let $distinctYears := (cts:element-attribute-values(xs:QName('survey:YEAR'),xs:QName('PublishYear'),(),('descending'),
	cts:and-query((
		cts:directory-query($config:DD-SURVEY-FEMALE_SCORECARD-PATH,'1')
	))))

	let $organizationIDs := $request/FirmID/text()
	
	let $response-arr := json:array()
	let $loopData := for $organizationID in fn:tokenize($organizationIDs,',')

						let $data := for $year in fn:reverse($distinctYears[1 to 5])
									let $response-obj := json:object()
									let $res := cts:search(/,
													cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/surveys/FEMALE_SCORECARD/','1'),
													cts:element-value-query(xs:QName('FEMALE_SCORECARD:PUBLISHYEAR'),xs:string($year)),
													cts:element-value-query(xs:QName('FEMALE_SCORECARD:ORGANIZATION_ID'),$organizationID)
													)))[1]

									let $FEMALEATTORNEYS := $res//FEMALE_SCORECARD:FEMALE_ATTORNEYS/text()
									let $MALEATTORNEYS := $res//FEMALE_SCORECARD:TOTAL_ATTORNEYS/text() - $FEMALEATTORNEYS

									let $_ := (
													map:put($response-obj,'ORGANIZATIONID', xs:integer($organizationID)),
												map:put($response-obj,'ORGANIZATIONNAME', ($res//FEMALE_SCORECARD:ORGANIZATION_NAME/text())),
												map:put($response-obj,'PUBLISHYEAR', xs:integer($year)),
												map:put($response-obj,'FEMALEATTORNEYS', xs:integer($FEMALEATTORNEYS)),
												map:put($response-obj,'MALEATTORNEYS', xs:integer($MALEATTORNEYS))
												)
									let $_ := if ($res) then json:array-push($response-arr, $response-obj) else ()
									return()
									return()
				
	return ($response-arr)
};

declare function mergertool:GetGrowthInGenderDiversity($request)
{
	
	let $distinctYears := (cts:element-values(xs:QName('FEMALE_SCORECARD:PUBLISHYEAR'),(),('descending'),
		cts:and-query((
			cts:directory-query('/LegalCompass/relational-data/surveys/FEMALE_SCORECARD/','1')
		))))
		
	let $response-arr := json:array()
	let $organizationIDs := $request/FirmID/text()
	let $loopData := for $organizationID in fn:tokenize($organizationIDs,',')

							let $data := for $year in fn:reverse($distinctYears[1 to 5])
								
											let $response-obj := json:object()
											let $res := cts:search(/,
												cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/surveys/FEMALE_SCORECARD/','1')
													,cts:element-value-query(xs:QName('FEMALE_SCORECARD:PUBLISHYEAR'),xs:string($year))
													,cts:element-value-query(xs:QName('FEMALE_SCORECARD:ORGANIZATION_ID'),$organizationID)
												)))
											
											let $FEMALEATTORNEYS := $res//FEMALE_SCORECARD:FEMALE_ATTORNEYS/text()
											
											let $FEMALEPARTNERS := fn:format-number($res//FEMALE_SCORECARD:FEMALE_PARTNERS/text() , '00')
											
											let $FEMALEEQUITYPARTNERS := if( $res//FEMALE_SCORECARD:FEMALE_EQUITY_PARTNERS/text() ne '')
													then xs:decimal(fn:format-number($res//FEMALE_SCORECARD:FEMALE_EQUITY_PARTNERS/text() , '00'))
												else 0
											
											let $FEMALENONEQUITYPARTNERS := if( $res//FEMALE_SCORECARD:FEMALE_NONEQUITY_PARTNERS/text() ne '')
													then xs:decimal(fn:format-number($res//FEMALE_SCORECARD:FEMALE_NONEQUITY_PARTNERS/text() , '00'))
												else 0

											let $FEMALEASSOCIATES := try { 
													xs:decimal(fn:format-number($res//FEMALE_SCORECARD:FEMALE_ASSOCIATES/text() , '00'))
												}
												catch($x) { 0 }
													
											let $FEMALEOTHERATTORNEYS := if($res//FEMALE_SCORECARD:FEMALE_OTHER_ATTORNEYS/text() ne '')
													then (fn:format-number($res//FEMALE_SCORECARD:FEMALE_OTHER_ATTORNEYS/text() , '00'))
												else 0
													
											let $_ := (
												map:put($response-obj,'ORGANIZATIONID', xs:integer($organizationID)),
												map:put($response-obj,'ORGANIZATIONNAME', $res//FEMALE_SCORECARD:ORGANIZATION_NAME/text()),
												map:put($response-obj,'PUBLISHYEAR', xs:integer($year)),
												map:put($response-obj,'FEMALEATTORNEYS', xs:integer($FEMALEATTORNEYS)),
												map:put($response-obj,'FEMALEEQUITYPARTNERS', ($FEMALEEQUITYPARTNERS)),
												map:put($response-obj,'FEMALENONEQUITYPARTNERS', ($FEMALENONEQUITYPARTNERS)),
												map:put($response-obj,'FEMALEASSOCIATES', ($FEMALEASSOCIATES)),
												map:put($response-obj,'FEMALEOTHERATTORNEYS', ($FEMALEOTHERATTORNEYS))
											)
											
											let $_ := if ($res) then json:array-push($response-arr, $response-obj) else ()
								
								return()
								return()
				
	return ($response-arr) 
};

(:------------------------- Lateral Partner ---------------------------:)

declare function mergertool:GetLawyerMoveStats($FirmIDs, $title)
{
	let $FirmIDs := fn:tokenize($FirmIDs,',')
	
	let $RE_IDs := $FirmIDs ! mergertool:GetREIdByOrgId(.)
	let $qDate := fn:format-date(xs:date(xdmp:parse-dateTime('[Y01]-[M01]-[D01]',xs:string(fn:current-date() - xs:yearMonthDuration('P2Y')))),'[Y0001]-[M01]-[D01]')

	let $title_q := if (($title !='') and ($title)) then
			cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:Title'), $title, ('case-insensitive'))
		else ()
  
	let $conditions := (
		 cts:directory-query($config:RD-ALI_RE_LATERALMOVES_DATA-PATH,'infinity')
		,cts:element-range-query(xs:QName('ALI_RE_LateralMoves_Data:date_added'), '>=', xs:date($qDate))
		,$title_q
		,cts:not-query(cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:date_added'),('0000-00-00','0/0/0000')))
	)

	let $added_q := cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:action'), 'added', ('case-insensitive'))
	let $removed_q := cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:action'), 'removed', ('case-insensitive'))

	let $company-obj := json:object()
	let $response-arr := json:array()

	let $response := (
		
		(: -------------------------------------------------------------- 01: FirmJoined -------------------------------------------------------------- :)
		let $FirmJoined := for $RE_ID in $RE_IDs
			for $x in cts:element-values(xs:QName('ALI_RE_LateralMoves_Data:CompanyId_From'), (), (),
				cts:and-query((
					 $conditions, $added_q
					,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:CompanyId_To'), $RE_ID) 
					,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:CompanyId_To'), $RE_ID) 
				)))
      
				let $response-obj := json:object()
		  
				let $search := cts:search(/ALI_RE_LateralMoves_Data,
					cts:and-query((
						 $conditions, $added_q
						,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:CompanyId_To'), $RE_ID) 
						,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:CompanyId_From'), xs:string($x))
						,cts:not-query(cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:CompanyId_From'), xs:string($RE_ID)))
						,cts:not-query(cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:CompanyName_From'), ''))
					)))
		  
				let $Name := $search[1]/ALI_RE_LateralMoves_Data:CompanyName_From/text()
		  
				let $_ := (
					 map:put($response-obj,'Name', $Name)
					,map:put($response-obj,'Total', fn:count($search))
					,map:put($response-obj,'Type', 'FirmJoined')
					,map:put($response-obj,'RE_IDs', $RE_IDs)
				)
				let $_ := json:array-push($response-arr,$response-obj)
		  
				return ()
      
		(: -------------------------------------------------------------- 02: FirmLeft -------------------------------------------------------------- :)
		let $FirmLeft := for $RE_ID in $RE_IDs
			for $x in cts:element-values(xs:QName('ALI_RE_LateralMoves_Data:CompanyId_To'), (), (), 
				cts:and-query((
					$conditions, $removed_q
					,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:CompanyId_From'), $RE_ID) 
				)))
      
				let $response-obj := json:object()
      
				let $search := cts:search(/ALI_RE_LateralMoves_Data,
					cts:and-query((
						 $conditions, $removed_q
						,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:CompanyId_From'), $RE_ID)
						,cts:not-query(cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:CompanyId_To'), $RE_ID))
						,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:CompanyId_To'), xs:string($x))
					)))
      
				let $Name := $search[1]/ALI_RE_LateralMoves_Data:CompanyName_To/text()

				let $_ := (
					 map:put($response-obj,'Name', $Name)
					,map:put($response-obj,'Total', fn:count($search))
					,map:put($response-obj,'Type', 'FirmLeft')
				)
				let $_ := json:array-push($response-arr,$response-obj)
      
				return ()
  
		(: -------------------------------------------------------------- 03: CityLeft -------------------------------------------------------------- :)
		let $CityLeft := for $RE_ID in $RE_IDs
			for $x in cts:element-values(xs:QName('ALI_RE_LateralMoves_Data:loc'), (), ('collation=http://marklogic.com/collation//S1/AS/T0020'), 
				cts:and-query((
					$conditions, $removed_q
					,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:CompanyId_From'), $RE_ID)
					,cts:not-query(cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:loc'),''))
				)))
				let $response-obj := json:object()
				let $Total := fn:count(cts:search(/,
					cts:and-query((
						$conditions, $removed_q
						,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:CompanyId_From'), $RE_ID)
						,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:loc'), xs:string($x),('case-insensitive','whitespace-insensitive'))
						,cts:not-query(cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:loc'),''))
					))))
			  
				let $Name := $x
				let $_ := (
					 map:put($response-obj,'Name',$Name)
					,map:put($response-obj,'Total',$Total)
					,map:put($response-obj,'Type','CityLeft')
				)
				let $_ := json:array-push($response-arr,$response-obj)
				return ()
  
		(: -------------------------------------------------------------- 04: CityJoined -------------------------------------------------------------- :)
		let $CityJoined := for $RE_ID in $RE_IDs
			for $x in cts:element-values(xs:QName('ALI_RE_LateralMoves_Data:loc'), (), ('collation=http://marklogic.com/collation//S1/AS/T0020'), cts:and-query((
        $conditions, $added_q
        ,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:CompanyId_To'), $RE_ID) 
		,cts:not-query(cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:loc'),''))
      )))
      let $response-obj := json:object()
      let $Total := fn:count(cts:search(/,
        cts:and-query((
          $conditions, $added_q
          ,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:CompanyId_To'), $RE_ID) 
          ,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:loc'), xs:string($x),('case-insensitive','whitespace-insensitive'))
		  ,cts:not-query(cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:loc'),''))
        ))))
      
      let $Name := $x
      let $_ := (
         map:put($response-obj,'Name',$Name)
        ,map:put($response-obj,'Total',$Total)
        ,map:put($response-obj,'Type','CityJoined')
      )
      let $_ := json:array-push($response-arr,$response-obj)
      return ()
    
		(: -------------------------------------------------------------- 05: PAJoined -------------------------------------------------------------- :)
		let $PAJoined := for $RE_ID in $RE_IDs
    for $x in cts:element-values(xs:QName('practices_kws:practice_area'))
      let $key := fn:concat('*',$x,'*')
      let $PAJoinedCount := fn:count(cts:search(/,
        cts:and-query((
           $conditions
          ,$added_q
          ,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:CompanyId_To'), $RE_ID)
          ,cts:element-word-query(xs:QName('ALI_RE_LateralMoves_Data:practices'), $key, ('wildcarded', 'case-insensitive'))
        ))))
      let $_ := if ($PAJoinedCount >0 ) then (
          let $response-obj := json:object()
          let $_ := (
             map:put($response-obj,'Name', $x)
            ,map:put($response-obj,'Total', $PAJoinedCount)
            ,map:put($response-obj,'Type', 'PAJoined')
          )
          let $_ := json:array-push($response-arr,$response-obj)
          return ()
        )
        else ()
      return ()
    
		(: -------------------------------------------------------------- 06: PALeft -------------------------------------------------------------- :)
		let $PALeft := for $RE_ID in $RE_IDs
    for $x in cts:element-values(xs:QName('practices_kws:practice_area'))
      let $key := fn:concat('*',$x,'*')
      let $PALeftCount := fn:count(cts:search(/,
        cts:and-query((
           $conditions
          ,$removed_q
          ,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:CompanyId_From'), $RE_ID)
          ,cts:element-word-query(xs:QName('ALI_RE_LateralMoves_Data:practices'), $key, ('wildcarded', 'case-insensitive'))
        ))))
      let $_ := if ($PALeftCount >0 ) then (
          let $response-obj := json:object()
          let $_ := (
             map:put($response-obj,'Name', $x)
            ,map:put($response-obj,'Total', $PALeftCount)
            ,map:put($response-obj,'Type', 'PALeft')
          )
          let $_ := json:array-push($response-arr,$response-obj)
          return ()
        )
        else ()
      return ()
  
		(: -------------------------------------------------------------- 07: TotalJoined -------------------------------------------------------------- :)
		let $TotalJoined := for $RE_ID in $RE_IDs
			let $Name := mergertool:GetCompanyName($RE_ID)
			let $TotalJoinedCount := fn:count(cts:search(/,
			  cts:and-query((
				$conditions,$added_q,
				cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:CompanyId_To'), $RE_ID)
			  ))))
			
			let $_ := if ($TotalJoinedCount>0) then (
				let $response-obj := json:object()
				let $_ := (
				  map:put($response-obj, 'Name', $Name)
				  ,map:put($response-obj, 'Total', $TotalJoinedCount)
				  ,map:put($response-obj, 'Type', 'TotalJoined')
				)
				let $_ := json:array-push($response-arr,$response-obj)
				return ()
			  ) else ()  
			return ()
  
		(: -------------------------------------------------------------- 08: TotalLeft -------------------------------------------------------------- :)
		let $TotalLeft := for $RE_ID in $RE_IDs
    let $Name := mergertool:GetCompanyName($RE_ID)
    let $TotalLeftCount := fn:count(cts:search(/,
      cts:and-query((
        $conditions,$removed_q,
        cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:CompanyId_From'), $RE_ID)
      ))))
    
    let $_ := if ($TotalLeftCount>0) then (
        let $response-obj := json:object()
        let $_ := (
           map:put($response-obj,'Name',$Name)
          ,map:put($response-obj,'Total',$TotalLeftCount)
          ,map:put($response-obj,'Type','TotalLeft')
		  ,map:put($response-obj,'reiddd',$RE_IDs)
        )
        let $_ := json:array-push($response-arr,$response-obj)
        return ()
      ) else ()  
    return ()
    
		return ()
	)

	return ($response-arr)
};

declare function mergertool:GetLawyerMoveStatsCombined($FirmIDs, $title)
{
	let $FirmIDs := fn:tokenize($FirmIDs,',')
	
	let $RE_IDs := $FirmIDs ! mergertool:GetREIdByOrgId(.)
	let $qDate := fn:format-date(xs:date(xdmp:parse-dateTime('[Y01]-[M01]-[D01]',xs:string(fn:current-date() - xs:yearMonthDuration('P2Y')))),'[Y0001]-[M01]-[D01]')

	let $title_q := if (($title !='') and ($title)) then
			cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:Title'), $title, ('case-insensitive'))
		else ()
  
	let $conditions := (
		 cts:directory-query($config:RD-ALI_RE_LATERALMOVES_DATA-PATH,'infinity')
		,cts:element-range-query(xs:QName('ALI_RE_LateralMoves_Data:date_added'), '>=', xs:date($qDate))
		,$title_q
		,cts:not-query(cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:date_added'),('0000-00-00','0/0/0000')))
	)

	let $added_q := cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:action'), 'added', ('case-insensitive'))
	let $removed_q := cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:action'), 'removed', ('case-insensitive'))

	let $company-obj := json:object()
	let $response-arr := json:array()

	let $response := (
		
		(: -------------------------------------------------------------- 01: FirmJoined -------------------------------------------------------------- :)
		let $FirmJoined := for $RE_ID in $RE_IDs
			for $x in cts:element-values(xs:QName('ALI_RE_LateralMoves_Data:CompanyId_From'), (), (),
				cts:and-query((
					 $conditions, $added_q
					,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:CompanyId_To'), $RE_ID) 
				)))
      
				let $response-obj := json:object()
		  
				let $search := cts:search(/ALI_RE_LateralMoves_Data,
					cts:and-query((
						 $conditions, $added_q
						,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:CompanyId_To'), $RE_ID) 
						,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:CompanyId_From'), xs:string($x))
						,cts:not-query(cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:CompanyName_From'), ''))
					)))
		  
				let $Name := $search[1]/ALI_RE_LateralMoves_Data:CompanyName_From/text()
		  
				let $_ := (
					 map:put($response-obj,'Name', $Name)
					,map:put($response-obj,'Total', fn:count($search))
					,map:put($response-obj,'Type', 'FirmJoined')
					,map:put($response-obj,'RE_IDs', $RE_IDs)
				)
				let $_ := json:array-push($response-arr,$response-obj)
		  
				return ()
      
		(: -------------------------------------------------------------- 02: FirmLeft -------------------------------------------------------------- :)
		let $FirmLeft := for $RE_ID in $RE_IDs
			for $x in cts:element-values(xs:QName('ALI_RE_LateralMoves_Data:CompanyId_To'), (), (), 
				cts:and-query((
					$conditions, $removed_q
					,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:CompanyId_From'), $RE_ID) 
				)))
      
				let $response-obj := json:object()
      
				let $search := cts:search(/ALI_RE_LateralMoves_Data,
					cts:and-query((
						 $conditions, $removed_q
						,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:CompanyId_From'), $RE_ID)
						,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:CompanyId_To'), xs:string($x))
					)))
      
				let $Name := $search[1]/ALI_RE_LateralMoves_Data:CompanyName_To/text()

				let $_ := (
					 map:put($response-obj,'Name', $Name)
					,map:put($response-obj,'Total', fn:count($search))
					,map:put($response-obj,'Type', 'FirmLeft')
				)
				let $_ := json:array-push($response-arr,$response-obj)
      
				return ()
  
		(: -------------------------------------------------------------- 03: CityLeft -------------------------------------------------------------- :)
		let $CityLeft := for $RE_ID in $RE_IDs
			for $x in cts:element-values(xs:QName('ALI_RE_LateralMoves_Data:loc'), (), ('collation=http://marklogic.com/collation//S1/AS/T0020'), 
				cts:and-query((
					$conditions, $removed_q
					,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:CompanyId_From'), $RE_ID)
					,cts:not-query(cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:loc'),''))
				)))
				let $response-obj := json:object()
				let $Total := fn:count(cts:search(/,
					cts:and-query((
						$conditions, $removed_q
						,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:CompanyId_From'), $RE_ID)
						,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:loc'), xs:string($x),('case-insensitive','whitespace-insensitive'))
						,cts:not-query(cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:loc'),''))
					))))
			  
				let $Name := $x
				let $_ := (
					 map:put($response-obj,'Name',$Name)
					,map:put($response-obj,'Total',$Total)
					,map:put($response-obj,'Type','CityLeft')
				)
				let $_ := json:array-push($response-arr,$response-obj)
				return ()
  
		(: -------------------------------------------------------------- 04: CityJoined -------------------------------------------------------------- :)
		let $CityJoined := for $RE_ID in $RE_IDs
			for $x in cts:element-values(xs:QName('ALI_RE_LateralMoves_Data:loc'), (), ('collation=http://marklogic.com/collation//S1/AS/T0020'), cts:and-query((
        $conditions, $added_q
        ,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:CompanyId_To'), $RE_ID) 
		,cts:not-query(cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:loc'),''))
      )))
      let $response-obj := json:object()
      let $Total := fn:count(cts:search(/,
        cts:and-query((
          $conditions, $added_q
          ,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:CompanyId_To'), $RE_ID) 
          ,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:loc'), xs:string($x),('case-insensitive','whitespace-insensitive'))
		  ,cts:not-query(cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:loc'),''))
        ))))
      
      let $Name := $x
      let $_ := (
         map:put($response-obj,'Name',$Name)
        ,map:put($response-obj,'Total',$Total)
        ,map:put($response-obj,'Type','CityJoined')
      )
      let $_ := json:array-push($response-arr,$response-obj)
      return ()
    
		(: -------------------------------------------------------------- 05: PAJoined -------------------------------------------------------------- :)
		let $PAJoined := for $RE_ID in $RE_IDs
    for $x in cts:element-values(xs:QName('practices_kws:practice_area'))
      let $key := fn:concat('*',$x,'*')
      let $PAJoinedCount := fn:count(cts:search(/,
        cts:and-query((
           $conditions
          ,$added_q
          ,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:CompanyId_To'), $RE_ID)
          ,cts:element-word-query(xs:QName('ALI_RE_LateralMoves_Data:practices'), $key, ('wildcarded', 'case-insensitive'))
        ))))
      let $_ := if ($PAJoinedCount >0 ) then (
          let $response-obj := json:object()
          let $_ := (
             map:put($response-obj,'Name', $x)
            ,map:put($response-obj,'Total', $PAJoinedCount)
            ,map:put($response-obj,'Type', 'PAJoined')
          )
          let $_ := json:array-push($response-arr,$response-obj)
          return ()
        )
        else ()
      return ()
    
		(: -------------------------------------------------------------- 06: PALeft -------------------------------------------------------------- :)
		let $PALeft := for $RE_ID in $RE_IDs
    for $x in cts:element-values(xs:QName('practices_kws:practice_area'))
      let $key := fn:concat('*',$x,'*')
      let $PALeftCount := fn:count(cts:search(/,
        cts:and-query((
           $conditions
          ,$removed_q
          ,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:CompanyId_From'), $RE_ID)
          ,cts:element-word-query(xs:QName('ALI_RE_LateralMoves_Data:practices'), $key, ('wildcarded', 'case-insensitive'))
        ))))
      let $_ := if ($PALeftCount >0 ) then (
          let $response-obj := json:object()
          let $_ := (
             map:put($response-obj,'Name', $x)
            ,map:put($response-obj,'Total', $PALeftCount)
            ,map:put($response-obj,'Type', 'PALeft')
          )
          let $_ := json:array-push($response-arr,$response-obj)
          return ()
        )
        else ()
      return ()
  
		(: -------------------------------------------------------------- 07: TotalJoined -------------------------------------------------------------- :)
		let $TotalJoined := for $RE_ID in $RE_IDs
			let $Name := mergertool:GetCompanyName($RE_ID)
			let $TotalJoinedCount := fn:count(cts:search(/,
			  cts:and-query((
				$conditions,$added_q,
				cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:CompanyId_To'), $RE_ID)
			  ))))
			
			let $_ := if ($TotalJoinedCount>0) then (
				let $response-obj := json:object()
				let $_ := (
				  map:put($response-obj, 'Name', $Name)
				  ,map:put($response-obj, 'Total', $TotalJoinedCount)
				  ,map:put($response-obj, 'Type', 'TotalJoined')
				)
				let $_ := json:array-push($response-arr,$response-obj)
				return ()
			  ) else ()  
			return ()
  
		(: -------------------------------------------------------------- 08: TotalLeft -------------------------------------------------------------- :)
		let $TotalLeft := for $RE_ID in $RE_IDs
    let $Name := mergertool:GetCompanyName($RE_ID)
    let $TotalLeftCount := fn:count(cts:search(/,
      cts:and-query((
        $conditions,$removed_q,
        cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:CompanyId_From'), $RE_ID)
      ))))
    
    let $_ := if ($TotalLeftCount>0) then (
        let $response-obj := json:object()
        let $_ := (
           map:put($response-obj,'Name',$Name)
          ,map:put($response-obj,'Total',$TotalLeftCount)
          ,map:put($response-obj,'Type','TotalLeft')
        )
        let $_ := json:array-push($response-arr,$response-obj)
        return ()
      ) else ()  
    return ()
    
		return ()
	)

	return ($response-arr)
};


declare function mergertool:GetLateralPartnerPracticeAdd($FirmIDs, $title)
{
	let $FirmIDs := fn:tokenize($FirmIDs,',')
	
	let $title_q := if (($title !='') and ($title)) then
			cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:Title'), $title, ('case-insensitive'))
		else ()
	
	let $sDate := xs:date(fn:concat((fn:year-from-date(fn:current-date())-4),'-01-01'))
	let $eDate := xs:date(fn:concat(fn:year-from-date(fn:current-date()),'-12-31'))

	let $practice_areas := cts:element-values(xs:QName('practices_kws:practice_area'))

	let $conditions := (
		 cts:directory-query($config:RD-ALI_RE_LATERALMOVES_DATA-PATH,'infinity')
		,cts:not-query(cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:date_added'),'0/0/0000')) 
		,cts:element-range-query(xs:QName('ALI_RE_LateralMoves_Data:date_added'), '>=', $sDate)
		,cts:element-range-query(xs:QName('ALI_RE_LateralMoves_Data:date_added'), '<=', $eDate)
	)

	let $response-arr := json:array()
	
	let $loopData := for $FirmID in $FirmIDs
    					for $practice_area in $practice_areas
							let $key := fn:concat('*',$practice_area,'*')

							let $search := cts:search(/ALI_RE_LateralMoves_Data,
								cts:and-query((
									$conditions
									,$title_q 
									,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:company_Id'),$FirmID)
									,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:practice_area'), $key, ('case-insensitive'))
								)))[1]

							let $AddPercentage := xdmp:estimate(cts:search(/ALI_RE_LateralMoves_Data,
								cts:and-query((
									$conditions
									,$title_q 
									,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:company_Id'),$FirmID)
									,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:action'),'added')
									,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:practice_area'), $key, ('case-insensitive'))
								))))

							let $MinusPercentage := xdmp:estimate(cts:search(/ALI_RE_LateralMoves_Data,
								cts:and-query((
									$conditions
									,$title_q 
									,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:company_Id'),$FirmID)
									,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:action'),'removed')
									,cts:element-value-query(xs:QName('ALI_RE_LateralMoves_Data:practice_area'), $key, ('case-insensitive'))
								))))	
      
							let $firm_name := $search//ALI_RE_LateralMoves_Data:Company_Name/text()
							
							let $response-obj := json:object()
							let $_ := (
								map:put($response-obj, 'Firm_Id', $FirmID)
								,map:put($response-obj, 'Firm_Name', $firm_name)
								,map:put($response-obj, 'Practice_area', $practice_area)
								,map:put($response-obj, 'AddPercentage', $AddPercentage)
								,map:put($response-obj, 'MinusPercentage', $MinusPercentage)
							)
							let $_ := json:array-push($response-arr,$response-obj)
							
							return ()


	return $response-arr
};

(:-------------------- Overview-------------------------:)

declare function mergertool:GetOfficeTrendsMap($request)
{
	let $firmIDs :=fn:tokenize($request/FirmID/text(),',')
	let $response-arr := json:array()
	
	let $loopData := for $firmID in $firmIDs
						let $RE_ID := mergertool:GetREIdByOrgId( $firmID )

						let $person-locations := cts:element-values(xs:QName('ALI_RE_Attorney_Data:location'), (), (),
						cts:and-query((
							cts:directory-query('/LegalCompass/denormalized-data/ALI_RE_Attorney_Data/')
							,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:title'), ('Partner','Associate','Other Counsel/Attorney'))
							,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:firm_id'), $RE_ID )
							,cts:not-query(cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:location'), ('Location not identified','Location Not Available')))
							)))

						let $locationData := for $location in $person-locations
						
													let $query := cts:and-query((
													cts:directory-query('/LegalCompass/denormalized-data/ALI_RE_Attorney_Data/')
													,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:location'),$location,'case-insensitive')
													,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:firm_id'), xs:string($RE_ID))
													)) 

													let $headcount := xdmp:estimate(cts:search(/,
													cts:and-query((
													$query
													,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),('case-insensitive'))
													)))) 
      
													let $partnercount := xdmp:estimate(cts:search(/,
													cts:and-query((
													$query
													,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:firm_id'), xs:string($RE_ID))
													,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:title'), ('Partner'))
													))))

													let $associatecount := xdmp:estimate(cts:search(/,
													cts:and-query((
													$query
													,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:firm_id'), xs:string($RE_ID))
													,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:title'), ('Associate'))
													))))

													let $othercouselcount := xdmp:estimate(cts:search(/,
													cts:and-query((
													$query
													,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:firm_id'), xs:string($RE_ID))
													,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:title'), ('Other Counsel/Attorney'),'case-insensitive')
													)))) 

													let $city-data := cts:search(/,
														cts:and-query((
														cts:directory-query('/LegalCompass/relational-data/city_detail/'),
														cts:element-value-query(xs:QName('city_detail:STD_LOC'),$location,('case-insensitive','whitespace-sensitive','punctuation-sensitive'))
													)))
	   
													let $A := (cts:search(/,
														cts:and-query((
														$query
														,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney','Administrative / Support Staff','Other'),('case-insensitive'))
													))))[1]
	   
													let $response-obj := json:object()
														let $_ := (
															map:put($response-obj,'firmid', (xs:string($firmID))),
															map:put($response-obj,'firmlocation', $location),
															map:put($response-obj,'firmname', $A//ALI_RE_Attorney_Data:firm_name/text()),
															map:put($response-obj,'headCount', $headcount),
															map:put($response-obj,'partnerCount', $partnercount),
															map:put($response-obj,'associateCount',  $associatecount),
															map:put($response-obj,'otherCount', $othercouselcount),
															map:put($response-obj,'LATITUDE', $city-data//city_detail:LATITUDE/text()),
															map:put($response-obj,'LONGITUDE', $city-data//city_detail:LONGITUDE/text())
														)

													let $_ := json:array-push($response-arr,$response-obj)	  
													return()
													return()
	return $response-arr

};

declare function mergertool:GetOfficeTrendsMapByCity($request)
{
	let $city :=fn:tokenize($request/City/text(),'[|]')
	let $firmID :=$request/FirmID/text()
	let $totalLawyers :=fn:tokenize($request/TotalLawyers/text(),',')
	let $response-arr := json:array()
	let $primaryFirmID := $request/PrimaryFirmId/text()
	let $SecondaryFirmID := $request/SecondaryFirmId/text()


	let $locationData := for $location in (:$city ! fn:string(fn:tokenize(.,',')[1]):) $city
	
								let $query := cts:and-query((
								cts:directory-query('/LegalCompass/denormalized-data/ALI_RE_Attorney_Data/')
								,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:location'),$location,'case-insensitive')
								,if($primaryFirmID ne '-1000' or $primaryFirmID ne '' ) then cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:firm_id'), mergertool:GetREIdByOrgId( $primaryFirmID ) ) else ()
								,if($SecondaryFirmID ne '-1000' or $SecondaryFirmID ne '' ) then cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:firm_id'), mergertool:GetREIdByOrgId( $SecondaryFirmID ) ) else ()
								)) 

								let $headcount := xdmp:estimate(cts:search(/,
								cts:and-query((
								$query
								,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney'),('case-insensitive'))
								)))) 

								let $partnercount := 0

								let $associatecount := 0

								let $othercouselcount := 0

								let $city-data := cts:search(/,
									cts:and-query((
									cts:directory-query('/LegalCompass/relational-data/city_detail/'),
									(: cts:element-value-query(xs:QName('city_detail:STD_LOC'),$location,('case-insensitive','whitespace-sensitive','punctuation-sensitive')) :)
									cts:element-value-query(xs:QName('city_detail:STD_LOC'),$location,('case-insensitive','whitespace-insensitive','punctuation-sensitive'))
								)))

								let $A := (cts:search(/,
									cts:and-query((
									$query
									,cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:title'), ('Partner', 'Associate', 'Other Counsel/Attorney','Administrative / Support Staff','Other'),('case-insensitive'))
								))))[1]

								let $response-obj := json:object()
									let $_ := (
										map:put($response-obj,'firmid', (xs:string($firmID))),
										map:put($response-obj,'firmlocation', $location),
										map:put($response-obj,'firmname', if($A) then $A//ALI_RE_Attorney_Data:firm_name/text() else ''),
										map:put($response-obj,'headCount', $headcount),
										map:put($response-obj,'partnerCount', $partnercount),
										map:put($response-obj,'associateCount',  $associatecount),
										map:put($response-obj,'otherCount', $othercouselcount),
										map:put($response-obj,'LATITUDE', $city-data//city_detail:LATITUDE/text()),
										map:put($response-obj,'LONGITUDE', $city-data//city_detail:LONGITUDE/text())
									)

								let $_ := json:array-push($response-arr,$response-obj)	  
								return()
return $response-arr

};


declare function GetSummaryByCombinedData($request)
{
	let $publishYear := max(cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/')
						)))//AMLAW_200:PUBLISHYEAR/text())

	let $publishYearG := max(cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/surveys/Global_100/')
						)))//Global_100:PUBLISHYEAR/text())					

	let $grossRevenueCombined := xs:decimal($request/CombinedRevenue/text())
	let $grossRevenueA := xs:decimal($request/PrimaryFirmRevenue/text())
	let $grossRevenueB := xs:decimal($request/SecondaryFirmRevenue/text())
	let $rpl := xs:decimal($request/CombinedRevenuePerLawyer/text())
	let $ppp := xs:decimal($request/CombinedProfitPerPartner/text())
	let $cap := xs:decimal($request/CombinedCompensationAverage/text())
	let $ppl := xs:decimal($request/CombinedProfitPerLawyer/text())
	let $primaryFirmID := $request/PrimaryFirmID/text()
	let $secondaryFirmID := $request/SecondaryFirmID/text()

	let $primaryAmlawID := cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
							cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($publishYear)),
							cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$primaryFirmID)
						)))//AMLAW_200:ORGANIZATION_ID/text()

	let $secondaryAmlawID := cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
							cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($publishYear)),
							cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$secondaryFirmID)
						)))//AMLAW_200:ORGANIZATION_ID/text()					

	let $amlawRank :=  max(cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
							cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($publishYear)),
							cts:element-range-query(xs:QName('AMLAW_200:GROSS_REVENUE'),'>',$grossRevenueCombined)
						)))//AMLAW_200:AMLAW200_RANK/text())

    let $global200Rank :=  max(cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/surveys/Global_100/'),
							cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($publishYearG)),
							cts:not-query(cts:element-value-query(xs:QName('Global_100:GROSS_REVENUE'),'')),
							cts:element-range-query(xs:QName('Global_100:GROSS_REVENUE'),'>',$grossRevenueCombined)
						)))//Global_100:RANK_BY_GROSS_REVENUE/text())						

	let $rplRank :=  max(cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
							cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($publishYear)),
							cts:element-range-query(xs:QName('AMLAW_200:RPL'),'>',$rpl)
						)))//AMLAW_200:RANK_BY_RPL/text())

	let $pppRank :=  max(cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
							cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($publishYear)),
							cts:element-range-query(xs:QName('AMLAW_200:PPP'),'>',$ppp)
						)))//AMLAW_200:RANK_BY_PPP/text())

	let $CAPRank :=  max(cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
							cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($publishYear)),
							cts:element-range-query(xs:QName('AMLAW_200:CAP'),'>',$cap)
						)))//AMLAW_200:RANK_BY_CAP/text())

	let $PPLRank :=  max(cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
							cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($publishYear)),
							cts:element-range-query(xs:QName('AMLAW_200:PPL'),'>',$ppl)
						)))//AMLAW_200:RANK_BY_PPL/text())

	let $Firm1Rank :=  max(cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
							cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($publishYear)),
							if(xs:string($primaryFirmID) ne '0') then cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),xs:string($primaryFirmID))
							else cts:element-range-query(xs:QName('AMLAW_200:GROSS_REVENUE') , '>',$grossRevenueA)
						)))//AMLAW_200:AMLAW200_RANK/text())																				

	

	let $Firm2Rank :=  max(cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
							cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($publishYear)),
							if(xs:string($secondaryFirmID) ne '0') then cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),xs:string($secondaryFirmID))
							else cts:element-range-query(xs:QName('AMLAW_200:GROSS_REVENUE') , '>',$grossRevenueB)
						)))//AMLAW_200:AMLAW200_RANK/text())

	let $organization := fn:doc(fn:concat('/LegalCompass/denormalized-data/organization/',$primaryFirmID,'.xml'))
	let $primaryFirmName := if((/organization[organization:ORGANIZATION_ID = xs:string($primaryFirmID)]/organization:ALM_NAME/text())[1] ne '')then 
										/organization[organization:ORGANIZATION_ID = xs:string($primaryFirmID)]/organization:ALM_NAME/text()[1]
										else 
										/organization[organization:ORGANIZATION_ID = xs:string($primaryFirmID)]/organization:ORGANIZATION_NAME/text()[1]

	let $organization := fn:doc(fn:concat('/LegalCompass/denormalized-data/organization/',$secondaryFirmID,'.xml'))
	let $secondaryFirmName :=  if((/organization[organization:ORGANIZATION_ID = xs:string($secondaryFirmID)]/organization:ALM_NAME/text())[1] ne '')then 
										/organization[organization:ORGANIZATION_ID = xs:string($secondaryFirmID)]/organization:ALM_NAME/text()[1]
										else 
										/organization[organization:ORGANIZATION_ID = xs:string($secondaryFirmID)]/organization:ORGANIZATION_NAME/text()[1]

	let $amlawRank1 := if(xs:string($amlawRank) ne '') then $amlawRank else 0
	let $primaryFirmRank := if(xs:string($Firm1Rank) ne '') then $Firm1Rank else 0	
	let $secondaryFirmRank := if(xs:string($Firm2Rank) ne '') then $Firm2Rank else 0
	let $pppRank := if(xs:string($pppRank) ne '') then $pppRank else 0
	let $PPLRank := if(xs:string($PPLRank) ne '') then $PPLRank else 0
	let $CAPRank := if(xs:string($CAPRank) ne '') then $CAPRank else 0
	let $rplRank := if(xs:string($rplRank) ne '') then $rplRank else 0 


	(: let $pRank := if($primaryFirmRank eq $secondaryFirmRank) then 
					if($grossRevenueA gt $grossRevenueB) then $primaryFirmRank else $primaryFirmRank + 1
				  else 	$primaryFirmRank

	let $sRank := if($primaryFirmRank eq $secondaryFirmRank) then 
					if($grossRevenueB gt $grossRevenueA) then $secondaryFirmRank else $secondaryFirmRank + 1	
				  else $secondaryFirmRank :)

	let $global200Rank := if(fn:not(xs:string($global200Rank) ne '')) then 0 else $global200Rank
	let $res-obj := json:object()
	let $_ := (
				   map:put($res-obj,'AMLawRank',if($amlawRank1 eq 200) then 0 else $amlawRank1 + 1),
			   	   map:put($res-obj,'RPLRank',if($rplRank eq 200) then 0 else $rplRank + 1),
				   map:put($res-obj,'PPPRank',if($pppRank eq 200) then 0 else $pppRank + 1),
				   map:put($res-obj,'CAPRank',if($CAPRank eq 200) then 0 else $CAPRank + 1),
				   map:put($res-obj,'PPLRank',if($PPLRank eq 200) then 0 else $PPLRank + 1),
				   map:put($res-obj,'Global200Rank',if(xs:string($global200Rank) eq '100') then 0 else $global200Rank + 1),
				   map:put($res-obj,'PrimaryFirmRank',if($primaryFirmRank ge 200 or fn:not($primaryAmlawID ne '')) then 0 else $primaryFirmRank),
				   map:put($res-obj,'SecondaryFirmRank',if($secondaryFirmRank ge 200 or fn:not($secondaryAmlawID ne '')) then 0 else $secondaryFirmRank),
				   map:put($res-obj,'PrimaryFirmName',$primaryFirmName),
				   map:put($res-obj,'SecondaryFirmName',$secondaryFirmName),
				   map:put($res-obj,'PrimaryFirmID',$primaryFirmID),
				   map:put($res-obj,'SecondaryFirmID',$secondaryFirmID)
				)
	return $res-obj

};

declare function mergertool:GetFirmSummary($request)
{
	let $primaryFirmID := $request/PrimaryFirmID/text()
	let $secondaryFrimID := $request/SecondaryFirmID/text()

	let $summary := if($primaryFirmID != -1000 and $secondaryFrimID ne -1000) then mergertool:GetFirmSummaryByID($request)
					else mergertool:GetFirmSummaryBySingleID($request)

	return $summary				
};

declare function mergertool:GetFirmSummaryBySingleID($request)
{
	let $publishYear := max(cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/')
						)))//AMLAW_200:PUBLISHYEAR/text())

	let $maxYearG100 := max(cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/surveys/Global_100/')
						)))//Global_100:PUBLISHYEAR/text())

	let $maxYearUK50 := max(cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/surveys/UK_50/')
						)))//UK_50:PUBLISHYEAR/text())	

	let $maxYearNLJ500 := max(cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/surveys/NLJ_250/')
						)))//nlj250:PUBLISHYEAR/text())		

	let $manualCity := if($request/PrimaryFirmID/text() ne -1000) then $request/CombinedOfficeInformation/secondaryCityLocation/City/text() else $request/CombinedOfficeInformation/primaryCityLocation/City/text()

	let $primaryFirmID := if($request/PrimaryFirmID/text() ne -1000) then $request/PrimaryFirmID/text() else $request/SecondaryFirmID/text()
	

	let $primaryREID := mergertool:GetREIdByOrgId($primaryFirmID)
	

	let $amlawAndQuery := cts:and-query((
								cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
								cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($publishYear)),
								cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),($primaryFirmID))
							))

	
	let $global100AndQuery := cts:and-query((
									cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
									cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($maxYearG100)),
									cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),($primaryFirmID))
									))

	let $uk50AndQuery := cts:and-query((
								cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
								cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string($maxYearUK50)),
								cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),($primaryFirmID))
								))	

	let $primaryfirmEquityPartner := if(cts:search(/, mergertool:amlawAndQuery($primaryFirmID,$publishYear))[1] ne '') then sum(cts:search(/, mergertool:amlawAndQuery($primaryFirmID,$publishYear))[1]//AMLAW_200:NUM_EQ_PARTNERS/text())
									 else if(cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))[1] ne '') then sum(cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))[1]//Global_100:NUM_EQUITY_PARTNERS/text())
									 else if(cts:search(/, mergertool:uk50AndQuery($primaryFirmID,$maxYearUK50))[1] ne '') then sum(cts:search(/,mergertool:uk50AndQuery($primaryFirmID,$maxYearUK50))[1]//UK_50:NUMBER_OF_EQ_PARTNERS/text()) else()
	
	
	let $secondaryFirmEquityPartner := $request/CombinedEquityPartners/text()
	let $combinedEquityPartners := $primaryfirmEquityPartner + $secondaryFirmEquityPartner

	
	let $primaryFirmTotalPartners := if(cts:search(/, mergertool:amlawAndQuery($primaryFirmID,$publishYear))[1] ne '') then sum(cts:search(/, mergertool:amlawAndQuery($primaryFirmID,$publishYear))[1]//AMLAW_200:TOTAL_PARTNERS/text())
								   else if(cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))[1] ne '') then sum(cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))[1]//Global_100:NUM_PARTNERS/text())
								   else if(cts:search(/, mergertool:uk50AndQuery($primaryFirmID,$maxYearUK50))[1] ne '') then sum(cts:search(/,mergertool:uk50AndQuery($primaryFirmID,$maxYearUK50))[1]//UK_50:TOTAL_PARTNERS/text()) else()
	
	
	let $secondaryFirmTotalPartners := $request/CombinedTotalPartners/text()
	let $combinedTotalPartners := $primaryFirmTotalPartners + $secondaryFirmTotalPartners

	
	let $combinedAssociatesP := sum(cts:search(/,
									cts:and-query((
										cts:directory-query('/LegalCompass/relational-data/surveys/NLJ_250/','1'),
										cts:element-value-query(xs:QName('nlj250:PUBLISHYEAR'),xs:string($maxYearNLJ500)),
										cts:element-value-query(xs:QName('nlj250:ORGANIZATION_ID'),($primaryFirmID))
										)))//nlj250:NUM_ASSOCIATES/text())

	let $combinedAssociatesS := $request/CombinedAssociates/text()

	let $combinedAssociates := $combinedAssociatesP + $combinedAssociatesS

	
	let $combinedOtherLawyersP := sum(cts:search(/,
									cts:and-query((
										cts:directory-query('/LegalCompass/relational-data/surveys/NLJ_250/','1'),
										cts:element-value-query(xs:QName('nlj250:PUBLISHYEAR'),xs:string($maxYearNLJ500)),
										cts:element-value-query(xs:QName('nlj250:ORGANIZATION_ID'),($primaryFirmID))
										)))//nlj250:NUM_OTHER_ATTORNEYS/text())

	let $combinedOtherLawyersS := $request/CombinedOtherLawyers/text()

	let $combinedOtherLawyers := $combinedOtherLawyersP + $combinedOtherLawyersS								

	let $primaryFirmTotalLawyers := if(cts:search(/, mergertool:amlawAndQuery($primaryFirmID,$publishYear))[1] ne '') then sum(cts:search(/, mergertool:amlawAndQuery($primaryFirmID,$publishYear))[1]//AMLAW_200:NUM_OF_LAWYERS/text())
								   else if(cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))[1] ne '') then sum(cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))[1]//Global_100:NUM_LAWYERS/text())
								   else if(cts:search(/, mergertool:uk50AndQuery($primaryFirmID,$maxYearUK50))[1] ne '') then sum(cts:search(/,mergertool:uk50AndQuery($primaryFirmID,$maxYearUK50))[1]//UK_50:NUMBER_OF_LAWYERS/text())
								   else()
	
	let $secondaryFirmTotalLawyers := $request/CombinedTotalLawyers/text()
	let $combinedTotalLawyers := $primaryFirmTotalLawyers + $secondaryFirmTotalLawyers
	
	
	let $primaryFirmRPL := if(cts:search(/, mergertool:amlawAndQuery($primaryFirmID,$publishYear))[1] ne '') then sum(cts:search(/, mergertool:amlawAndQuery($primaryFirmID,$publishYear))[1]//AMLAW_200:RPL/text())
								     else if(cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))[1] ne '') then sum(cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))[1]//Global_100:REVENUE_PER_LAWYER/text())
								     else if(cts:search(/, mergertool:uk50AndQuery($primaryFirmID,$maxYearUK50))[1] ne '') then sum(cts:search(/,mergertool:uk50AndQuery($primaryFirmID,$maxYearUK50))[1]//UK_50:RPL_DOLLAR/text()) else()	
	
	
	
	let $secondaryFirmRPL := $request/CombinedRevenuePerLawyer/text()
	let $combinedRevenuePerLawyer := fn:avg(($primaryFirmRPL , $secondaryFirmRPL))
	
	let $primaryFirmProfitMargin := if(cts:search(/, mergertool:amlawAndQuery($primaryFirmID,$publishYear))[1] ne '') then sum(cts:search(/, mergertool:amlawAndQuery($primaryFirmID,$publishYear))[1]//AMLAW_200:PROFIT_MARGIN/text())
								   else if(cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))[1] ne '') then sum(cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))[1]//Global_100:PROFIT_MARGIN/text())
								   else if(cts:search(/, mergertool:uk50AndQuery($primaryFirmID,$maxYearUK50))[1] ne '') then sum(cts:search(/,mergertool:uk50AndQuery($primaryFirmID,$maxYearUK50))[1]//UK_50:PROFIT_MARGIN/text()) else()

	
	let $secondaryFirmProfitMargin := $request/CombinedProfitMargin/text()
	let $combinedProfitMargin := fn:avg(($primaryFirmProfitMargin , $secondaryFirmProfitMargin))
	
	let $primaryFirmNetOperatingIncome := if(cts:search(/, mergertool:amlawAndQuery($primaryFirmID,$publishYear))[1] ne '') then sum(cts:search(/, mergertool:amlawAndQuery($primaryFirmID,$publishYear))[1]//AMLAW_200:NET_OPERATING_INCOME/text())
								       
									   else if(cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))[1] ne '') then (cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))[1]//Global_100:PPP/text() * cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))[1]//Global_100:NUM_EQUITY_PARTNERS/text())
								       else if(cts:search(/, mergertool:uk50AndQuery($primaryFirmID,$maxYearUK50))[1] ne '') then (cts:search(/, mergertool:uk50AndQuery($primaryFirmID,$maxYearUK50))[1]//UK_50:PPP_DOLLAR/text() * cts:search(/, mergertool:uk50AndQuery($primaryFirmID,$maxYearUK50))[1]//UK_50:NUMBER_OF_EQ_PARTNERS/text())
									   else()

	let $primaryFirmTotalLawyers := if(cts:search(/, mergertool:amlawAndQuery($primaryFirmID,$publishYear))[1] ne '') then sum(cts:search(/, mergertool:amlawAndQuery($primaryFirmID,$publishYear))[1]//AMLAW_200:NUM_OF_LAWYERS/text())
								   else if(cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))[1] ne '') then sum(cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))[1]//Global_100:NUM_LAWYERS/text())
								   else if(cts:search(/, mergertool:uk50AndQuery($primaryFirmID,$maxYearUK50))[1] ne '') then sum(cts:search(/,mergertool:uk50AndQuery($primaryFirmID,$maxYearUK50))[1]//UK_50:NUMBER_OF_LAWYERS/text())
								   else()

	let $secondaryFirmNetOperatingIncome := $request/CombinedNetOperatingIncome/text()
	let $combinedNetOperatingIncome := $primaryFirmNetOperatingIncome + $secondaryFirmNetOperatingIncome
								   
								  
	let $primaryFirmPPL := if(cts:search(/, mergertool:amlawAndQuery($primaryFirmID,$publishYear))[1] ne '') then sum(cts:search(/, mergertool:amlawAndQuery($primaryFirmID,$publishYear))[1]//AMLAW_200:PPL/text())
								   else if(cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))[1] ne '' and cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))[1]//Global_100:NUM_LAWYERS/text() ne '') then fn:round-half-to-even((cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))[1]//Global_100:PPP/text() * cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))[1]//Global_100:NUM_EQUITY_PARTNERS/text()) div cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))[1]//Global_100:NUM_LAWYERS/text(),0) 
								   else if(cts:search(/, mergertool:uk50AndQuery($primaryFirmID,$maxYearUK50))[1] ne '') then sum(cts:search(/,mergertool:uk50AndQuery($primaryFirmID,$maxYearUK50))[1]//UK_50:PPL_DOLLAR/text()) else()

	
	let $secondaryFirmPPL := $request/CombinedProfitPerLawyer/text()
	let $combinedProfitPerLawyer := $primaryFirmPPL + $secondaryFirmPPL
								   
	let $primaryFirmLeverage := if(cts:search(/, mergertool:amlawAndQuery($primaryFirmID,$publishYear))[1] ne '') then sum(cts:search(/, mergertool:amlawAndQuery($primaryFirmID,$publishYear))[1]//AMLAW_200:LEVERAGE/text())
								   else if(cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))[1] ne '' and cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))[1]//Global_100:NUM_EQUITY_PARTNERS/text() ne '')
								   				 then fn:round-half-to-even((cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))[1]//Global_100:NUM_LAWYERS/text() - cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))[1]//Global_100:NUM_EQUITY_PARTNERS/text()) div cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))[1]//Global_100:NUM_EQUITY_PARTNERS/text() ,2)
								   else if(cts:search(/, mergertool:uk50AndQuery($primaryFirmID,$maxYearUK50))[1] ne '') then sum(cts:search(/,mergertool:uk50AndQuery($primaryFirmID,$maxYearUK50))[1]//UK_50:LEVERAGE/text()) else()

	
	let $secondaryFirmLeverage := $request/CombinedLeverage/text()
	let $combinedLeverage := $primaryFirmLeverage + $secondaryFirmLeverage
	
	
	
	
	let $primaryFirmCAP := if(cts:search(/, $amlawAndQuery)[1] ne '') then sum(cts:search(/, $amlawAndQuery)//AMLAW_200:CAP/text())
								   (: else if(cts:search(/, $global100AndQuery)[1] ne '') then sum(cts:search(/, $global100AndQuery)[1]//Global_100:NUM_EQ_PARTNERS/text())
								   else if(cts:search(/, $uk50AndQuery)[1] ne '') then sum(cts:search(/,$uk50AndQuery)[1]//UK_50:LEVERAGE/text())  :)
								   else()

	let $secondaryFirmCAP := $request/CombinedCompensationAverage/text()						   
	
	let $combinedCompensationAverage := $primaryFirmCAP	+ $secondaryFirmCAP						   
	
	let $primaryFirmProfitPerPartner := if(cts:search(/,mergertool:amlawAndQuery($primaryFirmID,$publishYear))[1] ne '') then sum(cts:search(/, mergertool:amlawAndQuery($primaryFirmID,$publishYear))[1]//AMLAW_200:PPP/text())
								   else if(cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))[1] ne '') then sum(cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))[1]//Global_100:PPP/text())
								   else if(cts:search(/, mergertool:uk50AndQuery($primaryFirmID,$maxYearUK50))[1] ne '') then sum(cts:search(/,mergertool:uk50AndQuery($primaryFirmID,$maxYearUK50))[1]//UK_50:PPP_DOLLAR/text()) else()

	
	let $secondaryFirmProfitPerPartner := $request/CombinedProfitPerPartner/text()
	let $combinedProfitPerPartner := $primaryFirmProfitPerPartner + $secondaryFirmProfitPerPartner
								   
	let $revenueamlawAndQueryP := cts:and-query((
										cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
										cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($publishYear)),
										cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$primaryFirmID)
									))

	let $revenueglobal100AndQueryP := cts:and-query((
									cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
									cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($maxYearG100)),
									cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),($primaryFirmID))
									))

	let $revenueuk50AndQueryP := cts:and-query((
								cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
								cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string($maxYearUK50)),
								cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),($primaryFirmID))
								))

																
	
	let $primaryFirmRevenue := if($request/PrimaryFirmID/text() ne -1000) then 
									if(cts:search(/,$revenueamlawAndQueryP)[1]//AMLAW_200:GROSS_REVENUE/text() ne '') then cts:search(/,$revenueamlawAndQueryP)[1]//AMLAW_200:GROSS_REVENUE/text()
									else if(cts:search(/,$revenueglobal100AndQueryP)[1]//*:GROSS_REVENUE/text() ne '') then cts:search(/,$revenueglobal100AndQueryP)[1]//*:GROSS_REVENUE/text()
									else if(cts:search(/,$revenueuk50AndQueryP)[1]//*:GROSS_REVENUE_DOLLAR/text() ne '') then cts:search(/,$revenueuk50AndQueryP)[1]//*:GROSS_REVENUE_DOLLAR/text() else()
								else $request/CombinedRevenue/text()

	let $secondaryFirmRevenue := if($request/SecondaryFirmID/text() ne -1000) then 
									if(cts:search(/,$revenueamlawAndQueryP)[1]//AMLAW_200:GROSS_REVENUE/text() ne '') then cts:search(/,$revenueamlawAndQueryP)[1]//AMLAW_200:GROSS_REVENUE/text()
									else if(cts:search(/,$revenueglobal100AndQueryP)[1]//*:GROSS_REVENUE/text() ne '') then cts:search(/,$revenueglobal100AndQueryP)[1]//*:GROSS_REVENUE/text()
									else if(cts:search(/,$revenueuk50AndQueryP)[1]//*:GROSS_REVENUE_DOLLAR/text() ne '') then cts:search(/,$revenueuk50AndQueryP)[1]//*:GROSS_REVENUE_DOLLAR/text() else()
								else $request/CombinedRevenue/text()

	let $combinedRevenue := $primaryFirmRevenue + $secondaryFirmRevenue

	let $officesTotalAndQueryP := cts:and-query((
										cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/')
										,cts:element-value-query(xs:QName('tblrer:firm_id'), ($primaryREID))
										))


	let $officesTotalAndQuerySFirm := cts:and-query((
										cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/')
										,cts:element-value-query(xs:QName('tblrer:firm_id'), ($primaryREID))
										,cts:element-value-query(xs:QName('tblrer:location'), $manualCity)
										))											

																		

    let $OfficesTotalP := count(fn:distinct-values(cts:values(cts:element-reference(xs:QName('tblrer:location')), (), (),$officesTotalAndQueryP)))
	let $OfficesTotalPFirm := count(fn:distinct-values(cts:values(cts:element-reference(xs:QName('tblrer:location')), (), (),$officesTotalAndQuerySFirm)))

	let $OfficesTotalS := $request/CombinedOffices/text()
	let $OfficesTotalCombined := $OfficesTotalP +  $OfficesTotalS
	let $OfficesTotalCombinedOL := ($OfficesTotalP + $OfficesTotalPFirm) - $OfficesTotalP

		let $overlappedOffices := ($OfficesTotalP + $OfficesTotalS) - $OfficesTotalCombined
	let $combinedRevenue := fn:round-half-to-even($primaryFirmRevenue + $secondaryFirmRevenue,2)
	
	let $combinedRevenuePerLawyer :=($primaryFirmRevenue + $secondaryFirmRevenue) div ($combinedTotalLawyers)
	let $combinedProfitPerEquityPartner := $combinedNetOperatingIncome div $combinedEquityPartners
	let $combinedProfitMargin := ($combinedNetOperatingIncome div ($primaryFirmRevenue + $secondaryFirmRevenue)) * 100
	let $combinedProfitPerLawyer := $combinedNetOperatingIncome div ($combinedTotalLawyers)
	let $combinedLeverage := fn:round-half-to-even((($combinedTotalLawyers - $combinedEquityPartners) div $combinedEquityPartners),2)

	let $res-obj := json:object()

	let $_ := (
				map:put($res-obj,'CombinedEquityPartners',$combinedEquityPartners),
				(: map:put($res-obj,'CombinedTotalPartners',$combinedTotalPartners), :)
				map:put($res-obj,'CombinedTotalPartners',if(xs:string($combinedTotalPartners) ne '') then $combinedTotalPartners else 0),
				map:put($res-obj,'CombinedAssociates',$combinedAssociates),
				map:put($res-obj,'CombinedOtherLawyers',$combinedOtherLawyers),
				map:put($res-obj,'CombinedTotalLawyers',$combinedTotalLawyers),
				map:put($res-obj,'CombinedRevenuePerLawyer',fn:round-half-to-even($combinedRevenuePerLawyer,0)),
				map:put($res-obj,'CombinedRevenue',if(xs:string($combinedRevenue) ne '') then $combinedRevenue else 0),
				map:put($res-obj,'CombinedProfitMargin',if(xs:string($combinedProfitMargin) ne '') then fn:round-half-to-even($combinedProfitMargin,2) else 0),
				map:put($res-obj,'CombinedNetOperatingIncome',if(xs:string($combinedNetOperatingIncome) ne '') then $combinedNetOperatingIncome else 0),
				map:put($res-obj,'CombinedProfitPerLawyer',if(xs:string($combinedProfitPerLawyer) ne '') then fn:round-half-to-even($combinedProfitPerLawyer,0) else 0),
				map:put($res-obj,'CombinedLeverage',$combinedLeverage),
				map:put($res-obj,'CombinedOffices',$OfficesTotalCombined),
				map:put($res-obj,'CombinedOverlappedOffices',$OfficesTotalCombinedOL),
				map:put($res-obj,'CombinedCompensationAverage',if(xs:string($combinedCompensationAverage) ne '') then $combinedCompensationAverage else 0),
				map:put($res-obj,'CombinedProfitPerPartner',if(xs:string($combinedProfitPerEquityPartner) ne '') then fn:round-half-to-even($combinedProfitPerEquityPartner,0) else 0),
				map:put($res-obj,'PrimaryFirmRevenue',xs:double($primaryFirmRevenue)),
				map:put($res-obj,'SecondaryFirmRevenue',$secondaryFirmRevenue),
				map:put($res-obj,'PrimaryFirmID',xs:integer($request/PrimaryFirmID/text())),
				map:put($res-obj,'primaryfirmEquityPartner',xs:integer($primaryfirmEquityPartner)),
				map:put($res-obj,'secondaryfirmEquityPartner',xs:integer($secondaryFirmEquityPartner)),
				map:put($res-obj,'SecondaryFirmID',xs:integer($request/SecondaryFirmID/text())),
				map:put($res-obj,'NOI',$combinedNetOperatingIncome),
				map:put($res-obj,'TL',$manualCity)
				
			  )

	return $res-obj		  
};

declare function mergertool:GetFirmSummaryByID($request)
{
	let $publishYear := max(cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/')
						)))//AMLAW_200:PUBLISHYEAR/text())

	let $maxYearG100 := max(cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/surveys/Global_100/')
						)))//Global_100:PUBLISHYEAR/text())

	let $maxYearUK50 := max(cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/surveys/UK_50/')
						)))//UK_50:PUBLISHYEAR/text())	

	let $maxYearNLJ500 := max(cts:search(/,
						cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/surveys/NLJ_250/')
						)))//nlj250:PUBLISHYEAR/text())	


	let $manualCity := $request/CombinedOfficeInformation/primaryCityLocation/City/text()																			

	let $primaryFirmID := xs:string($request/PrimaryFirmID/text())
	let $secondaryFirmID := xs:string($request/SecondaryFirmID/text())

	let $primaryREID := mergertool:GetREIdByOrgId($primaryFirmID)
	let $secondaryREID := mergertool:GetREIdByOrgId($secondaryFirmID)

	let $amlawAndQuery := cts:and-query((
								cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
								cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($publishYear)),
								cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),($primaryFirmID,$secondaryFirmID))
							))

	
	let $global100AndQuery := cts:and-query((
									cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
									cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($maxYearG100)),
									cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),($primaryFirmID,$secondaryFirmID))
									))

	let $uk50AndQuery := cts:and-query((
								cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
								cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string($maxYearUK50)),
								cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),($primaryFirmID,$secondaryFirmID))
								))	

	let $primaryfirmEquityPartner := if(cts:search(/, mergertool:amlawAndQuery($primaryFirmID,$publishYear))//AMLAW_200:NUM_EQ_PARTNERS/text() ne '') then sum(cts:search(/, mergertool:amlawAndQuery($primaryFirmID,$publishYear))[1]//AMLAW_200:NUM_EQ_PARTNERS/text())
									 else if(cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))[1]//Global_100:NUM_EQUITY_PARTNERS/text() ne '') then sum(cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))[1]//Global_100:NUM_EQUITY_PARTNERS/text())
									 else if(cts:search(/, mergertool:uk50AndQuery($primaryFirmID,$maxYearUK50))[1]//UK_50:NUMBER_OF_EQ_PARTNERS/text() ne '') then sum(cts:search(/,mergertool:uk50AndQuery($primaryFirmID,$maxYearUK50))[1]//UK_50:NUMBER_OF_EQ_PARTNERS/text()) else()
	
	let $secondaryFirmEquityPartner := if(cts:search(/, mergertool:amlawAndQuery($secondaryFirmID,$publishYear))[1]//AMLAW_200:NUM_EQ_PARTNERS/text() ne '') then sum(cts:search(/, mergertool:amlawAndQuery($secondaryFirmID,$publishYear))[1]//AMLAW_200:NUM_EQ_PARTNERS/text())
									 else if(cts:search(/, mergertool:global100AndQuery($secondaryFirmID,$maxYearG100))[1]//Global_100:NUM_EQUITY_PARTNERS/text() ne '') then sum(cts:search(/, mergertool:global100AndQuery($secondaryFirmID,$maxYearG100))[1]//Global_100:NUM_EQUITY_PARTNERS/text())
									 else if(cts:search(/, mergertool:uk50AndQuery($secondaryFirmID,$maxYearUK50))[1]//UK_50:NUMBER_OF_EQ_PARTNERS/text() ne '') then sum(cts:search(/,mergertool:uk50AndQuery($secondaryFirmID,$maxYearUK50))[1]//UK_50:NUMBER_OF_EQ_PARTNERS/text()) else()																									

	let $combinedEquityPartners := $primaryfirmEquityPartner + $secondaryFirmEquityPartner

	
	let $primaryFirmTotalPartners := if(cts:search(/, mergertool:amlawAndQuery($primaryFirmID,$publishYear))//AMLAW_200:TOTAL_PARTNERS/text() != '') then sum(cts:search(/, mergertool:amlawAndQuery($primaryFirmID,$publishYear))//AMLAW_200:TOTAL_PARTNERS/text())
								   else if(cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))//Global_100:NUM_PARTNERS/text() != '') then sum(cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))//Global_100:NUM_PARTNERS/text())
								   else if(cts:search(/, mergertool:uk50AndQuery($primaryFirmID,$maxYearUK50))//UK_50:TOTAL_PARTNERS/text() != '') then sum(cts:search(/,mergertool:uk50AndQuery($primaryFirmID,$maxYearUK50))//UK_50:TOTAL_PARTNERS/text()) else 0
	
	let $secondaryFirmTotalPartners := if(cts:search(/, mergertool:amlawAndQuery($secondaryFirmID,$publishYear))[1]//AMLAW_200:TOTAL_PARTNERS/text() != '') then sum(cts:search(/, mergertool:amlawAndQuery($secondaryFirmID,$publishYear))[1]//AMLAW_200:TOTAL_PARTNERS/text())
								   else if(cts:search(/, mergertool:global100AndQuery($secondaryFirmID,$maxYearG100))//Global_100:NUM_PARTNERS/text() != '') then sum(cts:search(/, mergertool:global100AndQuery($secondaryFirmID,$maxYearG100))[1]//Global_100:NUM_PARTNERS/text())
								   else if(cts:search(/, mergertool:uk50AndQuery($secondaryFirmID,$maxYearUK50))[1]//UK_50:TOTAL_PARTNERS/text() != '') then sum(cts:search(/,mergertool:uk50AndQuery($secondaryFirmID,$maxYearUK50))[1]//UK_50:TOTAL_PARTNERS/text()) else 0
								 
	
	let $combinedTotalPartners := $primaryFirmTotalPartners + $secondaryFirmTotalPartners

	
	let $combinedAssociates := sum(cts:search(/,
									cts:and-query((
										cts:directory-query('/LegalCompass/relational-data/surveys/NLJ_250/','1'),
										cts:element-value-query(xs:QName('nlj250:PUBLISHYEAR'),xs:string($maxYearNLJ500)),
										cts:element-value-query(xs:QName('nlj250:ORGANIZATION_ID'),($primaryFirmID,$secondaryFirmID))
										)))//nlj250:NUM_ASSOCIATES/text())

	
	let $combinedOtherLawyers := sum(cts:search(/,
									cts:and-query((
										cts:directory-query('/LegalCompass/relational-data/surveys/NLJ_250/','1'),
										cts:element-value-query(xs:QName('nlj250:PUBLISHYEAR'),xs:string($maxYearNLJ500)),
										cts:element-value-query(xs:QName('nlj250:ORGANIZATION_ID'),($primaryFirmID,$secondaryFirmID))
										)))//nlj250:NUM_OTHER_ATTORNEYS/text())

	(: let $primaryFirmTotalLawyers := if(cts:search(/, mergertool:amlawAndQuery($primaryFirmID,$publishYear))[1][1]//AMLAW_200:NUM_OF_LAWYERS/text() ne '') then sum(cts:search(/, mergertool:amlawAndQuery($primaryFirmID,$publishYear))[1]//AMLAW_200:NUM_OF_LAWYERS/text())
								   else if(cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))[1]//Global_100:NUM_LAWYERS/text() ne '') then sum(cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))[1]//Global_100:NUM_LAWYERS/text())
								   else if(cts:search(/, mergertool:uk50AndQuery($primaryFirmID,$maxYearUK50))[1]//UK_50:NUMBER_OF_LAWYERS/text() ne '') then sum(cts:search(/,mergertool:uk50AndQuery($primaryFirmID,$maxYearUK50))[1]//UK_50:NUMBER_OF_LAWYERS/text()) else() :)

	let $primaryFirmTotalLawyers := if(cts:search(/, mergertool:amlawAndQuery($primaryFirmID,$publishYear))[1] ne '') then sum(cts:search(/, mergertool:amlawAndQuery($primaryFirmID,$publishYear))[1]//AMLAW_200:NUM_OF_LAWYERS/text())
								   else if(cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))[1] ne '') then sum(cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))[1]//Global_100:NUM_LAWYERS/text())
								   else if(cts:search(/, mergertool:uk50AndQuery($primaryFirmID,$maxYearUK50))[1] ne '') then sum(cts:search(/,mergertool:uk50AndQuery($primaryFirmID,$maxYearUK50))[1]//UK_50:NUMBER_OF_LAWYERS/text())
								   else()
	let $secondaryFirmTotalLawyers := if(cts:search(/, mergertool:amlawAndQuery($secondaryFirmID,$publishYear))[1]//AMLAW_200:NUM_OF_LAWYERS/text() ne '') then sum(cts:search(/, mergertool:amlawAndQuery($secondaryFirmID,$publishYear))[1]//AMLAW_200:NUM_OF_LAWYERS/text())
								   else if(cts:search(/, mergertool:global100AndQuery($secondaryFirmID,$maxYearG100))[1]//Global_100:NUM_LAWYERS/text() ne '') then sum(cts:search(/, mergertool:global100AndQuery($secondaryFirmID,$maxYearG100))[1]//Global_100:NUM_LAWYERS/text())
								   else if(cts:search(/, mergertool:uk50AndQuery($secondaryFirmID,$maxYearUK50))[1]//UK_50:NUMBER_OF_LAWYERS/text() ne '') then sum(cts:search(/,mergertool:uk50AndQuery($secondaryFirmID,$maxYearUK50))[1]//UK_50:NUMBER_OF_LAWYERS/text())
								   else()
	let $combinedTotalLawyers := $primaryFirmTotalLawyers + $secondaryFirmTotalLawyers
	let $combinedTotalLawyers := if($combinedTotalLawyers) then $combinedTotalLawyers else 0
	
	
	let $primaryFirmRPL := if(cts:search(/, mergertool:amlawAndQuery($primaryFirmID,$publishYear))[1]//AMLAW_200:RPL/text() ne '') then sum(cts:search(/, mergertool:amlawAndQuery($primaryFirmID,$publishYear))[1]//AMLAW_200:RPL/text())
								     else if(cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))[1]//Global_100:REVENUE_PER_LAWYER/text() ne '') then sum(cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))[1]//Global_100:REVENUE_PER_LAWYER/text())
								     else if(cts:search(/, mergertool:uk50AndQuery($primaryFirmID,$maxYearUK50))[1]//UK_50:RPL_DOLLAR/text() ne '') then sum(cts:search(/,mergertool:uk50AndQuery($primaryFirmID,$maxYearUK50))[1]//UK_50:RPL_DOLLAR/text()) else()	
	
	
	let $secondaryFirmRPL := if(cts:search(/, mergertool:amlawAndQuery($secondaryFirmID,$publishYear))[1]//AMLAW_200:RPL/text() ne '') then sum(cts:search(/, mergertool:amlawAndQuery($secondaryFirmID,$publishYear))[1]//AMLAW_200:RPL/text())
								     else if(cts:search(/, mergertool:global100AndQuery($secondaryFirmID,$maxYearG100))[1]//Global_100:REVENUE_PER_LAWYER/text() ne '') then sum(cts:search(/, mergertool:global100AndQuery($secondaryFirmID,$maxYearG100))[1]//Global_100:REVENUE_PER_LAWYER/text())
								     else if(cts:search(/, mergertool:uk50AndQuery($secondaryFirmID,$maxYearUK50))[1]//UK_50:RPL_DOLLAR/text() ne '') then sum(cts:search(/,mergertool:uk50AndQuery($secondaryFirmID,$maxYearUK50))[1]//UK_50:RPL_DOLLAR/text()) else()	
	
	let $combinedRevenuePerLawyer := fn:avg(($primaryFirmRPL , $secondaryFirmRPL))
	
	let $primaryFirmProfitMargin := if(cts:search(/, mergertool:amlawAndQuery($primaryFirmID,$publishYear))[1]//AMLAW_200:PROFIT_MARGIN/text() ne '') then sum(cts:search(/, mergertool:amlawAndQuery($primaryFirmID,$publishYear))[1]//AMLAW_200:PROFIT_MARGIN/text())
								   else if(cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))[1]//Global_100:PROFIT_MARGIN/text() ne '') then sum(cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))[1]//Global_100:PROFIT_MARGIN/text())
								   else if(cts:search(/, mergertool:uk50AndQuery($primaryFirmID,$maxYearUK50))[1]//UK_50:PROFIT_MARGIN/text() ne '') then sum(cts:search(/,mergertool:uk50AndQuery($primaryFirmID,$maxYearUK50))[1]//UK_50:PROFIT_MARGIN/text()) else()

	let $secondaryFirmProfitMargin := if(cts:search(/, mergertool:amlawAndQuery($secondaryFirmID,$publishYear))[1]//AMLAW_200:PROFIT_MARGIN/text() ne '') then sum(cts:search(/, mergertool:amlawAndQuery($secondaryFirmID,$publishYear))[1]//AMLAW_200:PROFIT_MARGIN/text())
								   else if(cts:search(/, mergertool:global100AndQuery($secondaryFirmID,$maxYearG100))[1]//Global_100:PROFIT_MARGIN/text() ne '') then sum(cts:search(/, mergertool:global100AndQuery($secondaryFirmID,$maxYearG100))[1]//Global_100:PROFIT_MARGIN/text())
								   else if(cts:search(/, mergertool:uk50AndQuery($secondaryFirmID,$maxYearUK50))[1]//UK_50:PROFIT_MARGIN/text() ne '') then sum(cts:search(/,mergertool:uk50AndQuery($secondaryFirmID,$maxYearUK50))[1]//UK_50:PROFIT_MARGIN/text()) else()

	
	let $combinedProfitMargin := avg(($primaryFirmProfitMargin , $secondaryFirmProfitMargin))
	
	(: let $primaryFirmNetOperatingIncome := if(cts:search(/, mergertool:amlawAndQuery($primaryFirmID,$publishYear))[1]//AMLAW_200:NET_OPERATING_INCOME/text() ne '') then sum(cts:search(/, mergertool:amlawAndQuery($primaryFirmID,$publishYear))[1]//AMLAW_200:NET_OPERATING_INCOME/text())
								       else if(cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))[1] ne '') then (cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))[1]//Global_100:PPP/text() * cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))[1]//Global_100:NUM_EQUITY_PARTNERS/text())
								       else if(cts:search(/, mergertool:uk50AndQuery($primaryFirmID,$maxYearUK50))[1] ne '') then (cts:search(/, mergertool:uk50AndQuery($primaryFirmID,$maxYearUK50))[1]//UK_50:PPP_DOLLAR/text() * cts:search(/, mergertool:uk50AndQuery($primaryFirmID,$maxYearUK50))[1]//UK_50:NUMBER_OF_EQ_PARTNERS/text()) else() :)

	let $primaryFirmNetOperatingIncome := if(cts:search(/, mergertool:amlawAndQuery($primaryFirmID,$publishYear))[1] ne '') then sum(cts:search(/, mergertool:amlawAndQuery($primaryFirmID,$publishYear))[1]//AMLAW_200:NET_OPERATING_INCOME/text())
								       else if(cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))[1] ne '') then (cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))[1]//Global_100:PPP/text() * cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))[1]//Global_100:NUM_EQUITY_PARTNERS/text())
								       else if(cts:search(/, mergertool:uk50AndQuery($primaryFirmID,$maxYearUK50))[1] ne '') then (cts:search(/, mergertool:uk50AndQuery($primaryFirmID,$maxYearUK50))[1]//UK_50:PPP_DOLLAR/text() * cts:search(/, mergertool:uk50AndQuery($primaryFirmID,$maxYearUK50))[1]//UK_50:NUMBER_OF_EQ_PARTNERS/text())
										else()
									   

	let $secondaryFirmNetOperatingIncome := if(cts:search(/, mergertool:amlawAndQuery($secondaryFirmID,$publishYear))[1]//AMLAW_200:NET_OPERATING_INCOME/text() ne '') then sum(cts:search(/, mergertool:amlawAndQuery($secondaryFirmID,$publishYear))[1]//AMLAW_200:NET_OPERATING_INCOME/text())
								       else if(cts:search(/, mergertool:global100AndQuery($secondaryFirmID,$maxYearG100))[1] ne '') then (cts:search(/, mergertool:global100AndQuery($secondaryFirmID,$maxYearG100))[1]//Global_100:PPP/text() * cts:search(/, mergertool:global100AndQuery($secondaryFirmID,$maxYearG100))[1]//Global_100:NUM_EQUITY_PARTNERS/text())
								       else if(cts:search(/, mergertool:uk50AndQuery($secondaryFirmID,$maxYearUK50))[1] ne '') then (cts:search(/, mergertool:uk50AndQuery($secondaryFirmID,$maxYearUK50))[1]//UK_50:PPP_DOLLAR/text() * cts:search(/, mergertool:uk50AndQuery($secondaryFirmID,$maxYearUK50))[1]//UK_50:NUMBER_OF_EQ_PARTNERS/text()) 
									   else()
	
	let $combinedNetOperatingIncome := $primaryFirmNetOperatingIncome + $secondaryFirmNetOperatingIncome
								   
								  
	let $primaryFirmPPL := if(cts:search(/, mergertool:amlawAndQuery($primaryFirmID,$publishYear))[1]//AMLAW_200:PPL/text() ne '') then sum(cts:search(/, mergertool:amlawAndQuery($primaryFirmID,$publishYear))[1]//AMLAW_200:PPL/text())
								   else if(cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))[1] ne '' and cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))[1]//Global_100:NUM_LAWYERS/text() ne '') then fn:round-half-to-even((cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))[1]//Global_100:PPP/text() * cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))[1]//Global_100:NUM_EQUITY_PARTNERS/text()) div cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))[1]//Global_100:NUM_LAWYERS/text(),0) 
								   else if(cts:search(/, mergertool:uk50AndQuery($primaryFirmID,$maxYearUK50))[1]//UK_50:PPL_DOLLAR/text() ne '') then sum(cts:search(/,mergertool:uk50AndQuery($primaryFirmID,$maxYearUK50))[1]//UK_50:PPL_DOLLAR/text()) else()

	let $secondaryFirmRPL := if(cts:search(/, mergertool:amlawAndQuery($secondaryFirmID,$publishYear))[1]//AMLAW_200:PPL/text() ne '') then sum(cts:search(/, mergertool:amlawAndQuery($secondaryFirmID,$publishYear))[1]//AMLAW_200:PPL/text())
								   else if(cts:search(/, mergertool:global100AndQuery($secondaryFirmID,$maxYearG100))[1] ne '' and cts:search(/, mergertool:global100AndQuery($secondaryFirmID,$maxYearG100))[1]//Global_100:NUM_LAWYERS/text() ne '') then fn:round-half-to-even((cts:search(/, mergertool:global100AndQuery($secondaryFirmID,$maxYearG100))[1]//Global_100:PPP/text() * cts:search(/, mergertool:global100AndQuery($secondaryFirmID,$maxYearG100))[1]//Global_100:NUM_EQUITY_PARTNERS/text()) div cts:search(/, mergertool:global100AndQuery($secondaryFirmID,$maxYearG100))[1]//Global_100:NUM_LAWYERS/text(),0) 
								   else if(cts:search(/, mergertool:uk50AndQuery($secondaryFirmID,$maxYearUK50))[1]//UK_50:PPL_DOLLAR/text() ne '') then sum(cts:search(/,mergertool:uk50AndQuery($secondaryFirmID,$maxYearUK50))[1]//UK_50:PPL_DOLLAR/text()) else()

	let $combinedProfitPerLawyer := $primaryFirmPPL + $secondaryFirmRPL
								   
	let $primaryFirmLeverage := if(cts:search(/, mergertool:amlawAndQuery($primaryFirmID,$publishYear))[1]//AMLAW_200:LEVERAGE/text() ne '') then sum(cts:search(/, mergertool:amlawAndQuery($primaryFirmID,$publishYear))[1]//AMLAW_200:LEVERAGE/text())
								   else if(cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))[1] ne '' and cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))[1]//Global_100:NUM_EQUITY_PARTNERS/text() ne '')
								   				 then fn:round-half-to-even((cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))[1]//Global_100:NUM_LAWYERS/text() - cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))[1]//Global_100:NUM_EQUITY_PARTNERS/text()) div cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))[1]//Global_100:NUM_EQUITY_PARTNERS/text() ,2)
								   else if(cts:search(/, mergertool:uk50AndQuery($primaryFirmID,$maxYearUK50))[1] ne '') then sum(cts:search(/,mergertool:uk50AndQuery($primaryFirmID,$maxYearUK50))[1]//UK_50:LEVERAGE/text()) else()

	let $secondaryFirmLeverage := if(cts:search(/, mergertool:amlawAndQuery($secondaryFirmID,$publishYear))[1]//AMLAW_200:LEVERAGE/text() ne '') then sum(cts:search(/, mergertool:amlawAndQuery($secondaryFirmID,$publishYear))[1]//AMLAW_200:LEVERAGE/text())
								   else if(cts:search(/, mergertool:global100AndQuery($secondaryFirmID,$maxYearG100))[1] ne '' and cts:search(/, mergertool:global100AndQuery($secondaryFirmID,$maxYearG100))[1]//Global_100:NUM_EQUITY_PARTNERS/text() ne '')
								   				 then fn:round-half-to-even((cts:search(/, mergertool:global100AndQuery($secondaryFirmID,$maxYearG100))[1]//Global_100:NUM_LAWYERS/text() - cts:search(/, mergertool:global100AndQuery($secondaryFirmID,$maxYearG100))[1]//Global_100:NUM_EQUITY_PARTNERS/text()) div cts:search(/, mergertool:global100AndQuery($secondaryFirmID,$maxYearG100))[1]//Global_100:NUM_EQUITY_PARTNERS/text() ,2)
								   else if(cts:search(/, mergertool:uk50AndQuery($secondaryFirmID,$maxYearUK50))[1] ne '') then sum(cts:search(/,mergertool:uk50AndQuery($secondaryFirmID,$maxYearUK50))[1]//UK_50:LEVERAGE/text()) else()
	
	let $combinedLeverage := $primaryFirmLeverage + $secondaryFirmLeverage
	
	let $primaryFirmCAP := ''
	let $secondaryFirmCAP := ''
	
	let $combinedCompensationAverage := if(cts:search(/, $amlawAndQuery)[1] ne '') then avg(cts:search(/, $amlawAndQuery)//AMLAW_200:CAP/text())
								   else()

	
	
	
	let $primaryFirmProfitPerPartner := if(cts:search(/,mergertool:amlawAndQuery($primaryFirmID,$publishYear))[1] ne '') then sum(cts:search(/, mergertool:amlawAndQuery($primaryFirmID,$publishYear))[1]//AMLAW_200:PPP/text())
								   else if(cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))[1] ne '') then sum(cts:search(/, mergertool:global100AndQuery($primaryFirmID,$maxYearG100))[1]//Global_100:PPP/text())
								   else if(cts:search(/, mergertool:uk50AndQuery($primaryFirmID,$maxYearUK50))[1] ne '') then sum(cts:search(/,mergertool:uk50AndQuery($primaryFirmID,$maxYearUK50))[1]//UK_50:PPP_DOLLAR/text()) else()

	let $secondaryFirmProfitPerPartner := if(cts:search(/,mergertool:amlawAndQuery($secondaryFirmID,$publishYear))[1] ne '') then sum(cts:search(/, mergertool:amlawAndQuery($secondaryFirmID,$publishYear))[1]//AMLAW_200:PPP/text())
								   else if(cts:search(/, mergertool:global100AndQuery($secondaryFirmID,$maxYearG100))[1] ne '') then sum(cts:search(/, mergertool:global100AndQuery($secondaryFirmID,$maxYearG100))[1]//Global_100:PPP/text())
								   else if(cts:search(/, mergertool:uk50AndQuery($secondaryFirmID,$maxYearUK50))[1] ne '') then sum(cts:search(/,mergertool:uk50AndQuery($secondaryFirmID,$maxYearUK50))[1]//UK_50:PPP_DOLLAR/text()) else()
	
	let $combinedProfitPerPartner := $primaryFirmProfitPerPartner + $secondaryFirmProfitPerPartner
								   
	let $revenueamlawAndQueryP := cts:and-query((
										cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
										cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($publishYear)),
										cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$primaryFirmID)
									))

	let $revenueglobal100AndQueryP := cts:and-query((
									cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
									cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($maxYearG100)),
									cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),($primaryFirmID))
									))

	let $revenueuk50AndQueryP := cts:and-query((
								cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
								cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string($maxYearUK50)),
								cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),($primaryFirmID))
								))

	let $revenueamlawAndQueryS := cts:and-query((
										cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
										cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($publishYear)),
										cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$secondaryFirmID)
									))

	let $revenueglobal100AndQueryS := cts:and-query((
									cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
									cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($maxYearG100)),
									cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),($secondaryFirmID))
									))

	let $revenueuk50AndQueryS := cts:and-query((
								cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
								cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string($maxYearUK50)),
								cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),($secondaryFirmID))
								))																					
	
	let $primaryFirmRevenue := if(cts:search(/,$revenueamlawAndQueryP)[1]//AMLAW_200:GROSS_REVENUE/text() ne '') then cts:search(/,$revenueamlawAndQueryP)[1]//AMLAW_200:GROSS_REVENUE/text()
							   else if(cts:search(/,$revenueglobal100AndQueryP)[1]//*:GROSS_REVENUE/text() ne '') then cts:search(/,$revenueglobal100AndQueryP)[1]//*:GROSS_REVENUE/text()
							   else if(cts:search(/,$revenueuk50AndQueryP)[1]//*:GROSS_REVENUE_DOLLAR/text() ne '') then cts:search(/,$revenueuk50AndQueryP)[1]//*:GROSS_REVENUE_DOLLAR/text() else()


	let $secondaryFirmRevenue := if(cts:search(/,$revenueamlawAndQueryS)[1]//AMLAW_200:GROSS_REVENUE/text() ne '') then sum(cts:search(/,$revenueamlawAndQueryS)[1]//AMLAW_200:GROSS_REVENUE/text())
							   else if(cts:search(/,$revenueglobal100AndQueryS)[1]//*:GROSS_REVENUE/text() ne '') then sum(cts:search(/,$revenueglobal100AndQueryS)[1]//*:GROSS_REVENUE/text())
							   else if(cts:search(/,$revenueuk50AndQueryS)[1]//*:GROSS_REVENUE_DOLLAR/text() ne '') then sum(cts:search(/,$revenueuk50AndQueryS)[1]//*:GROSS_REVENUE_DOLLAR/text()) else 0


	let $officesTotalAndQueryP := cts:and-query((
										cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/')
										,cts:element-value-query(xs:QName('tblrer:firm_id'), ($primaryREID))
										,cts:not-query(cts:element-value-query(xs:QName('tblrer:location'), ''))
										))
	let $officesTotalAndQueryS := cts:and-query((
										cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/')
										,cts:element-value-query(xs:QName('tblrer:firm_id'), ($secondaryREID))
										,cts:not-query(cts:element-value-query(xs:QName('tblrer:location'), ''))
										))

								

	let $officesTotalAndQueryCombined := cts:and-query((
										cts:directory-query('/LegalCompass/denormalized-data/TBL_RER_CACHE_ATTORNEY_DATA/')
										,cts:element-value-query(xs:QName('tblrer:firm_id'), ($primaryREID,$secondaryREID))
										,cts:not-query(cts:element-value-query(xs:QName('tblrer:location'), ''))
										))																		
                                          
    let $OfficesTotalP := count(fn:distinct-values(cts:values(cts:element-reference(xs:QName('tblrer:location')), (), (),$officesTotalAndQueryP)))
	let $OfficesTotalS := count(fn:distinct-values(cts:values(cts:element-reference(xs:QName('tblrer:location')), (), (),$officesTotalAndQueryS)))
	let $OfficesTotalCombined := count(fn:distinct-values(cts:values(cts:element-reference(xs:QName('tblrer:location')), (), (),$officesTotalAndQueryCombined)))

		let $overlappedOffices := ($OfficesTotalP + $OfficesTotalS) - $OfficesTotalCombined
	let $combinedRevenue := fn:round-half-to-even($primaryFirmRevenue + $secondaryFirmRevenue,2)
	let $combinedRevenuePerLawyer :=if($combinedTotalLawyers) then ($primaryFirmRevenue + $secondaryFirmRevenue) div ($combinedTotalLawyers) else 0
	let $combinedProfitPerEquityPartner := $combinedNetOperatingIncome div $combinedEquityPartners
	let $combinedProfitMargin := ($combinedNetOperatingIncome div ($primaryFirmRevenue + $secondaryFirmRevenue)) * 100
	let $combinedProfitPerLawyer := $combinedNetOperatingIncome div ($combinedTotalLawyers)
	let $combinedLeverage := fn:round-half-to-even((($combinedTotalLawyers - $combinedEquityPartners) div $combinedEquityPartners),2)

	let $res-obj := json:object()

	let $_ := (
				map:put($res-obj,'CombinedEquityPartners',if($combinedEquityPartners) then $combinedEquityPartners else 0),
				(: map:put($res-obj,'CombinedTotalPartners',$combinedTotalPartners), :)
				map:put($res-obj,'CombinedTotalPartners',if(xs:string($combinedTotalPartners) ne '') then $combinedTotalPartners else 0),
				map:put($res-obj,'CombinedAssociates',$combinedAssociates),
				map:put($res-obj,'CombinedOtherLawyers',$combinedOtherLawyers),
				map:put($res-obj,'CombinedTotalLawyers',$combinedTotalLawyers),
				map:put($res-obj,'CombinedRevenuePerLawyer',if($combinedRevenuePerLawyer) then fn:round-half-to-even($combinedRevenuePerLawyer,0) else 0),
				map:put($res-obj,'CombinedRevenue',if(xs:string($combinedRevenue) ne '') then $combinedRevenue else 0),
				map:put($res-obj,'CombinedProfitMargin',if(xs:string($combinedProfitMargin) ne '') then fn:round-half-to-even($combinedProfitMargin,2) else 0),
				map:put($res-obj,'CombinedNetOperatingIncome',if(xs:string($combinedNetOperatingIncome) ne '') then $combinedNetOperatingIncome else 0),
				map:put($res-obj,'CombinedProfitPerLawyer',if(xs:string($combinedProfitPerLawyer) ne '') then fn:round-half-to-even($combinedProfitPerLawyer,0) else 0),
				map:put($res-obj,'CombinedLeverage',if($combinedLeverage) then $combinedLeverage else 0),
				map:put($res-obj,'CombinedOffices',$OfficesTotalCombined),
				map:put($res-obj,'OfficesTotalP',$OfficesTotalP),
				map:put($res-obj,'OfficesTotalS',$OfficesTotalS),
				map:put($res-obj,'CombinedOverlappedOffices',$overlappedOffices),
				map:put($res-obj,'CombinedCompensationAverage',if(xs:string($combinedCompensationAverage) ne '') then $combinedCompensationAverage else 0),
				map:put($res-obj,'CombinedProfitPerPartner',if(xs:string($combinedProfitPerEquityPartner) ne '') then fn:round-half-to-even($combinedProfitPerEquityPartner	,0) else 0),
				map:put($res-obj,'PrimaryFirmRevenue',xs:double($primaryFirmRevenue)),
				map:put($res-obj,'SecondaryFirmRevenue',$secondaryFirmRevenue),
				map:put($res-obj,'PrimaryFirmID',xs:integer($primaryFirmID)),
				map:put($res-obj,'primaryfirmEquityPartner',if($primaryfirmEquityPartner) then xs:integer($primaryfirmEquityPartner) else 0),
				map:put($res-obj,'secondaryfirmEquityPartner',xs:integer($secondaryFirmEquityPartner)),
				map:put($res-obj,'SecondaryFirmID',xs:integer($secondaryFirmID)),
				map:put($res-obj,'NOI',$combinedNetOperatingIncome),
				map:put($res-obj,'TL',$manualCity),
					map:put($res-obj,'NOI1',$primaryFirmNetOperatingIncome),
				map:put($res-obj,'TL1',$primaryFirmTotalLawyers),
					map:put($res-obj,'NOI2',$secondaryFirmNetOperatingIncome),
				map:put($res-obj,'TL2',$secondaryFirmTotalLawyers)
			  )

	return $res-obj		  
};


 declare function mergertool:GetPracticeareaList($request)
{
	let $firmIDs := $request/FirmID/text()
	let $FirmID := fn:tokenize($firmIDs,',')
	let $response-arr := json:array()

	let $organization := fn:doc(fn:concat('/LegalCompass/denormalized-data/organization/',$FirmID[1],'.xml'))
	let $primaryFirmName := if((/organization[organization:ORGANIZATION_ID = xs:string($FirmID[1])]/organization:ALM_NAME/text())[1] ne '')then 
										/organization[organization:ORGANIZATION_ID = xs:string($FirmID[1])]/organization:ALM_NAME/text()[1]
										else 
										/organization[organization:ORGANIZATION_ID = xs:string($FirmID[1])]/organization:ORGANIZATION_NAME/text()[1]

	let $organization := fn:doc(fn:concat('/LegalCompass/denormalized-data/organization/',$FirmID[2],'.xml'))
	let $secondaryFirmName :=  if((/organization[organization:ORGANIZATION_ID = xs:string($FirmID[2])]/organization:ALM_NAME/text())[1] ne '')then 
										/organization[organization:ORGANIZATION_ID = xs:string($FirmID[2])]/organization:ALM_NAME/text()[1]
										else 
										/organization[organization:ORGANIZATION_ID = xs:string($FirmID[2])]/organization:ORGANIZATION_NAME/text()[1]
	(: let $primaryFirmName :=  cts:search(/,
								cts:and-query((
									cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
									cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),xs:string($FirmID[1]))
								)))[1]//AMLAW_200:ORGANIZATION_NAME/text()

	let $secondaryFirmName :=  cts:search(/,
									cts:and-query((
										cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
										cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),xs:string($FirmID[2]))
									)))[1]//AMLAW_200:ORGANIZATION_NAME/text()			 :)		

	let $primaryID := mergertool:GetREIdByOrgId($FirmID[1])
	let $secondaryID := mergertool:GetREIdByOrgId($FirmID[2])
	let $response := for $practice_area in cts:element-values(xs:QName('practices_kws:practice_area'))

						let $PrimaryFirmHeadCount := xdmp:estimate(cts:search(/,
												cts:and-query((
													cts:directory-query('/LegalCompass/denormalized-data/ALI_RE_Attorney_Data/'),
													cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:RE_ID'),$primaryID),
													cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:practice_area'),$practice_area)
													))))

						let $SecondaryFirmHeadCount := xdmp:estimate(cts:search(/,
												cts:and-query((
													cts:directory-query('/LegalCompass/denormalized-data/ALI_RE_Attorney_Data/'),
													cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:RE_ID'),$secondaryID),
													cts:element-value-query(xs:QName('ALI_RE_Attorney_Data:practice_area'),$practice_area)
													))))

						let $combinedHeadCount := $PrimaryFirmHeadCount + $SecondaryFirmHeadCount							

						let $primaryPracticeAreaPercent := 	if($combinedHeadCount ne 0) then xs:double(($PrimaryFirmHeadCount div $combinedHeadCount)) * 100 else 0
						let $secondaryPracticeAreaPercent := if($combinedHeadCount ne 0) then xs:double(($SecondaryFirmHeadCount div $combinedHeadCount)) * 100 else 0	

						let $res-obj := json:object()
						let $_ := (
									map:put($res-obj,'PracticeArea',$practice_area),
									map:put($res-obj,'PrimaryFirmName',$primaryFirmName),
									map:put($res-obj,'SecondaryFirmName',$secondaryFirmName),
									map:put($res-obj,'PrimaryFirmID',$FirmID[1]),
									map:put($res-obj,'SecondaryFirmID',$FirmID[2]),
									map:put($res-obj,'PrimaryHeadCount',$PrimaryFirmHeadCount),
									map:put($res-obj,'SecondaryHeadCount',$SecondaryFirmHeadCount),
									map:put($res-obj,'CombinedHeadCount',$combinedHeadCount),
									map:put($res-obj,'PrimaryPracticeAreaPercent',fn:round-half-to-even($primaryPracticeAreaPercent,0)),
									map:put($res-obj,'SecondaryPracticeAreaPercent',fn:round-half-to-even($secondaryPracticeAreaPercent,0))
								  )

						let $_ := json:array-push($response-arr,$res-obj)
						return()
	return 	$response-arr	
}; 


(:--------Helper---------:)
declare function mergertool:GetREIdByOrgId($firmID)
{
	cts:search(/FIRMS_ALI_XREF_RE,
		cts:and-query((
			cts:collection-query($config:RD-FIRMS_ALI_XREF_RE-COLLECTION),
			cts:directory-query($config:RD-FIRMS_ALI_XREF_RE-PATH),
			cts:element-value-query(xs:QName('xref:ALI_ID'),$firmID)
		)))[1]/xref:RE_ID/text()
};

declare function mergertool:amlawAndQuery($id,$year)
{
	let $res := cts:and-query((
								cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
								cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year)),
								cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),($id))
							))

	return $res						
};

declare function mergertool:global100AndQuery($id,$year)
{
	let $global100AndQuery := cts:and-query((
									cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
									cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($year)),
									cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),($id))
									))

	return 	$global100AndQuery							
};

declare function mergertool:uk50AndQuery($id,$year)
{
	let $uk50AndQuery := cts:and-query((
								cts:directory-query("/LegalCompass/relational-data/surveys/UK_50/"),
								cts:element-value-query(xs:QName('UK_50:PUBLISHYEAR'),xs:string($year)),
								cts:element-value-query(xs:QName('UK_50:ORGANIZATION_ID'),($id))
								))

	return $uk50AndQuery							
};

declare function mergertool:GetOrganizationName($orgID)
{
	let $organization := fn:doc(fn:concat('/LegalCompass/denormalized-data/organization/',$orgID,'.xml'))
							
	let $organizationName := if((/organization[organization:ORGANIZATION_ID = xs:string($orgID)]/organization:ALM_NAME/text())[1] ne '')then 
									/organization[organization:ORGANIZATION_ID = xs:string($orgID)]/organization:ALM_NAME/text()[1]
									else 
									/organization[organization:ORGANIZATION_ID = xs:string($orgID)]/organization:ORGANIZATION_NAME/text()[1]

	return $organizationName								

};

declare function mergertool:GetCombinedDiversityrank($diversityScore,$year)
{
	let $b := if(xs:string($diversityScore) ne '') then max(cts:search(/,
					cts:and-query((
					cts:directory-query('/LegalCompass/relational-data/surveys/Diversity_Scorecard/','1'),
					cts:element-range-query(xs:QName('Diversity_Scorecard:DIVERSITY_SCORE'),'>',xs:decimal($diversityScore)),
					cts:element-value-query(xs:QName('Diversity_Scorecard:PUBLISHYEAR'),xs:string($year)),
					cts:not-query(cts:element-value-query(xs:QName('Diversity_Scorecard:DIVERSITY_SCORE'),''))
					)))//Diversity_Scorecard:DIVERSITY_RANK/text()) else -1000

	return if(xs:string($b) ne '') then if($b ne -1000) then $b + 1 else 0 else 1
};

declare function mergertool:GetCombinedLGBTrank($lgbtPercentage,$year)
{
	let $b := if(xs:string($lgbtPercentage) ne '') then max(cts:search(/,
							cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/surveys/NLJ_LGBT/','1'),
							cts:element-range-query(xs:QName('nljlgbt:PERCENT_LGBT_ATTORNEYS'),'>',xs:decimal($lgbtPercentage)),
							cts:element-value-query(xs:QName('nljlgbt:PUBLISHYEAR'),xs:string($year)),
							cts:not-query(cts:element-value-query(xs:QName('nljlgbt:PERCENT_LGBT_ATTORNEYS'),''))
							)))//nljlgbt:NLJ_LGBT_RANK/text()) else -1000

	return if(xs:string($b) ne '') then if($b ne -1000) then $b + 1 else 0 else 1
};

declare function mergertool:GetCombinedGenderrank($womenInLawScore,$year)
{
	let $b := if(xs:string($womenInLawScore) ne '') then max(cts:search(/,
						cts:and-query((
						cts:directory-query('/LegalCompass/relational-data/surveys/FEMALE_SCORECARD/','1'),
						cts:element-range-query(xs:QName('FEMALE_SCORECARD:WOMEN_IN_LAW_SCORE'),'>',xs:decimal($womenInLawScore)),
						cts:element-value-query(xs:QName('FEMALE_SCORECARD:PUBLISHYEAR'),xs:string($year)),
						cts:not-query(cts:element-value-query(xs:QName('FEMALE_SCORECARD:ORGANIZATION_ID'),''))
						)))//FEMALE_SCORECARD:WOMEN_IN_LAW_RANK/text()) else -1000

	return if(xs:string($b) ne '') then if($b ne -1000) then $b + 1 else 0 else 1
};


declare function mergertool:GetCompanyName($company_id)
{
      let $company := cts:search(/company,
        cts:and-query((
            cts:directory-query($config:RD-COMPANY-PATH,'1')
          ,cts:element-value-query(xs:QName('company:company_id'), xs:string($company_id))
        )))[1]/company:company/text()
      
	  return $company
   
};