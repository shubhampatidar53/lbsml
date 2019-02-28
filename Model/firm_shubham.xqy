xquery version '1.0-ml';

module namespace firm = 'http://alm.com/firm_1';

import module namespace config = 'http://alm.com/config' at '/common/config.xqy';
import module namespace helper = 'http://alm.com/helper' at '/common/model/helper.xqy';
import module namespace search = 'http://marklogic.com/appservices/search' at '/MarkLogic/appservices/search/search.xqy';
import module namespace json = 'http://marklogic.com/xdmp/json'  at '/MarkLogic/json/json.xqy';
import module namespace firm-comp = 'http://alm.com/firm-comparison' at '/common/model/firm-comparison.xqy';

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

declare variable $company-obj := json:object();

declare option xdmp:mapping 'false';



declare function firm:SP_GETFIRMRPLCHANGE($startYear,$endYear,$organizationID)
{
  let $res-array := json:array()
                      
  let $result := cts:search(/,
                  cts:and-query((
                       cts:directory-query("/LegalCompass/relational-data/organization/"),
                       cts:element-value-query(xs:QName('organizations:ORGANIZATION_ID'),fn:tokenize($organizationID,','))
                       )))
   let $loopData := for $item in $result
                      let $loopData1 := for $item1 in (xs:integer($startYear) to xs:integer($endYear))
					  
					  let $amLaw200Year :=  cts:search(/,
                                                cts:and-query((
                                                     cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                     cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                     cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($item1))
                                                  )))
                      
                      let $global100 := cts:search(/,
                                                    cts:and-query((
                                                         cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
                                                         cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                         cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($item1)))))
                       let $global100preYear := cts:search(/,
                                                    cts:and-query((
                                                         cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
                                                         cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                         cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string(xs:integer($item1)-1)))))
                       let $amLaw200YearPreYear :=  cts:search(/,
                                                cts:and-query((
                                                     cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                     cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                     cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string(xs:integer($item1)-1)))))
                                                  
                       let $rpl := if($amLaw200Year//AMLAW_200:RPL/text() ne '') then $amLaw200Year//AMLAW_200:RPL/text() else $global100//Global_100:REVENUE_PER_LAWYER/text()
                       let $rplPreYear := if($amLaw200YearPreYear//AMLAW_200:RPL/text() ne '') then $amLaw200YearPreYear//AMLAW_200:RPL/text() else $global100preYear//Global_100:REVENUE_PER_LAWYER/text()
                       let $res-obj := json:object()
                       let $difference := $rpl - $rplPreYear
                       let $changes := fn:format-number(xs:float($difference div $rplPreYear)*100, '#,##0.00')
                       let $_ := (map:put($res-obj,'ORGANIZATION_ID',$item//organizations:ORGANIZATION_ID/text()),
                                  map:put($res-obj,'ORGANIZATION_NAME',$item//organizations:ORGANIZATION_NAME/text()),
                                  map:put($res-obj,'CHANGE',$changes),
                                  map:put($res-obj,'PUBLISHYEAR',$item1),
                                  map:put($res-obj,'RPL',$rpl),
								  map:put($res-obj,'VALUE',$rpl)
                                  )
                       let $_ := json:array-push($res-array,$res-obj) 
                       return ()
                       return()
					   
 
   return $res-array

};
(:-------------- Graphing ---------------:)

 declare function firm:getPPP($organizationIDs,$year)
{
let $orgIDs := '1,3,4,5,8,11,12,13,14,15,17,19,20,21,22,24,25,29,32,35,36,38,39,48,49,50,52,53,55,56,57,58,61,62,63,64,65,69,71,73,75,77,78,79,80,81,85,88,90,92,93,95,99,100,102,103,105,106,107,109,111,112,113,115,118,119,123,124,126,136,140,141,143,144,145,147,151,152,153,154,155,157,158,162,163,165,166,167,171,172,173,174,175,176,177,178,179,182,183,185,186,187,188,193,197,199,200,203,204,206,207,208,210,212,213,214,215,216,218,220,221,222,227,230,232,233,235,236,237,240,241,242,244,247,248,250,256,257,259,264,265,267,268,269,271,272,273,274,276,277,279,280,283,284,285,287,290,291,293,295,296,297,298,299,306,307,308,311,312,313,316,317,318,320,321,325,326,327,328,329,330,331,332,333,336,433,463,486,499,512,550,1673,1721,1728,1738,1750,1752,1774,1781,1823,1830,2106,2205,2503,2568,2598,2868,3294,3452,3462,3541,5149,5920,6421,7558,7970,37857,43622,48980'
  for $item in fn:tokenize($orgIDs,',')
  let $data := if(cts:search(/,
                    cts:and-query((
                    cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
                    cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item)
                   ,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year))
                    )))[1]//AMLAW_200:PPP/text() ne '') then cts:search(/,
                                    cts:and-query((
                                    cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
                                    cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item)
                                   ,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year))
                                    )))[1]//AMLAW_200:PPP/text() else cts:search(/,
                                            cts:and-query((
                                            cts:directory-query('/LegalCompass/relational-data/surveys/Global_100/'),
                                            cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$item),
                                            cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($year))
                                            )))[1]//Global_100:PPP/text()
                                            
    return $data
                                            
  };
  

declare function firm:getRPL($organizationIDs,$year)
{
  for $item in fn:tokenize($organizationIDs,',')
  let $data := if(cts:search(/,
                    cts:and-query((
                    cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
                    cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item)
                   ,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year)),
                    cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
                    )))//AMLAW_200:RPL/text() ne '') then cts:search(/,
                                    cts:and-query((
                                    cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
                                    cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item)
                                   ,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year)),
                                    cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
                                    )))//AMLAW_200:RPL/text() else cts:search(/,
                                            cts:and-query((
                                            cts:directory-query('/LegalCompass/relational-data/surveys/Global_100/'),
                                            cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$item),
                                            cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($year)),
                                            cts:not-query(cts:element-value-query(xs:QName('Global_100:RANK_BY_GROSS_REVENUE'),''))
                                            )))//Global_100:REVENUE_PER_LAWYER/text()
                                            
                                            return $data
                                            
  };
  
declare function firm:getCPL($organizationIDs,$year)
{
  for $item in fn:tokenize($organizationIDs,',')
		  let $grossRevenue := if(cts:search(/,
							cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
							cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item)
						   ,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year)),
							cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
							)))[1]//AMLAW_200:GROSS_REVENUE/text() ne '') then cts:search(/,
											cts:and-query((
											cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
											cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item)
										   ,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year)),
											cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
											)))[1]//AMLAW_200:GROSS_REVENUE/text() else cts:search(/,
													cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/surveys/Global_100/'),
													cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$item),
													cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($year)),
													cts:not-query(cts:element-value-query(xs:QName('Global_100:RANK_BY_GROSS_REVENUE'),''))
													)))[1]//Global_100:GROSS_REVENUE/text()
		  let $netIncome := cts:search(/,
								cts:and-query((
								cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
								cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item)
							   ,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year)),
								cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
								)))[1]//AMLAW_200:NET_OPERATING_INCOME/text() 
								
		   let $noOfLawyers := if(cts:search(/,
									cts:and-query((
									cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
									cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item)
								   ,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year)),
									cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
									)))[1]//AMLAW_200:NUM_OF_LAWYERS/text() ne '') then cts:search(/,
													cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
													cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item)
												   ,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year)),
													cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
													)))[1]//AMLAW_200:NUM_OF_LAWYERS/text() else cts:search(/,
															cts:and-query((
															cts:directory-query('/LegalCompass/relational-data/surveys/Global_100/'),
															cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$item),
															cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($year)),
															cts:not-query(cts:element-value-query(xs:QName('Global_100:RANK_BY_GROSS_REVENUE'),''))
															)))[1]//Global_100:NUM_LAWYERS/text()
		  let $grossRevenue := if($grossRevenue ne '') then $grossRevenue else 0
		  
		  let $noOfLawyers := if($noOfLawyers ne '') then $noOfLawyers else 0
		  (:let $netIncome := if($netIncome ne '') then $netIncome else 0:)
		  let $result := (xs:integer($grossRevenue) - xs:integer($netIncome)) div xs:integer($noOfLawyers)

		  (:if($noOfLawyers ne 0) then (xs:integer($grossRevenue) - xs:integer($netIncome)) div xs:integer($noOfLawyers) else 0:)
		  return $result
                                            
  };
  
  declare function firm:getEquityPartner($organizationIDs,$year)
{
  for $item in fn:tokenize($organizationIDs,',')
		  let $nomOfEquityPartner := if(cts:search(/,
							cts:and-query((
							cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
							cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item)
						   ,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year)),
							cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
							)))[1]//AMLAW_200:NUM_EQ_PARTNERS/text() ne '') then cts:search(/,
											cts:and-query((
											cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
											cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item)
										   ,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year)),
											cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
											)))[1]//AMLAW_200:NUM_EQ_PARTNERS/text() else cts:search(/,
													cts:and-query((
													cts:directory-query('/LegalCompass/relational-data/surveys/Global_100/'),
													cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$item),
													cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($year)),
													cts:not-query(cts:element-value-query(xs:QName('Global_100:RANK_BY_GROSS_REVENUE'),''))
													)))[1]//Global_100:NUM_EQUITY_PARTNERS/text()
													
		  let $totalPartner := cts:search(/,
								cts:and-query((
								cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/'),
								cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item)
							   ,cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year)),
								cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
								)))[1]//AMLAW_200:TOTAL_PARTNERS/text() 
								
		   
		  let $equityPartner := (xs:double($nomOfEquityPartner) div xs:double($totalPartner)) * 100
		  return $equityPartner
                                            
  };
  
  declare function firm:rplTest($organizationIDs,$year)
{
  for $item in fn:tokenize($organizationIDs,',')
		  let $GR :=cts:search(/,
                                                  cts:and-query((
                                                       cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                       cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year)),
													   cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item),
													   cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
                                                    )))[1]//AMLAW_200:GROSS_REVENUE/text()
													
		  let $result := if($GR ne '') then (cts:search(/,
													  cts:and-query((
														   cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
														   cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year)),
														   cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item),
														   cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
														)))[1]//AMLAW_200:GROSS_REVENUE/text() div cts:search(/,
																		  cts:and-query((
																			   cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
																			   cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year - 4)),
																			   cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item),
																			   cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
																			)))[1]//AMLAW_200:GROSS_REVENUE/text())
						else cts:search(/,
									  cts:and-query((
										 cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
										   cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$item),
										   cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($year)),
										   cts:not-query(cts:element-value-query(xs:QName('Global_100:RANK_BY_GROSS_REVENUE'),''))
										)))[1]//Global_100:GROSS_REVENUE/text()	div cts:search(/,
																	  cts:and-query((
																		   cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
																		   cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$item),
																		   cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($year - 4)),
																		   cts:not-query(cts:element-value-query(xs:QName('Global_100:RANK_BY_GROSS_REVENUE'),''))
																		)))[1]//Global_100:GROSS_REVENUE/text() 
																		
		  (:let $result := (xs:double($global100GrossRevenue) div xs:double($global100GrossRevenuePre5Year)) * 100:)
		  
		  return if ($result) then (math:pow($result,0.20) - 1) * 100 else ()
                                            
  };
  
declare function firm:rplTest1($organizationIDs,$year)
{
  for $item in fn:tokenize($organizationIDs,',')
		  let $GR :=cts:search(/,
                                                  cts:and-query((
                                                       cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                       cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year)),
													   cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item),
													   cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
                                                    )))//AMLAW_200:GROSS_REVENUE/text()
													
		  let $result := if($GR ne '') then (cts:search(/,
													  cts:and-query((
														   cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
														   cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year)),
														   cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item),
														   cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
														)))[1]//AMLAW_200:GROSS_REVENUE/text() div cts:search(/,
																		  cts:and-query((
																			   cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
																			   cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year - 1)),
																			   cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item),
																			   cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
																			)))[1]//AMLAW_200:GROSS_REVENUE/text())
						else (cts:search(/,
									  cts:and-query((
										 cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
										   cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$item),
										   cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($year)),
										   cts:not-query(cts:element-value-query(xs:QName('Global_100:RANK_BY_GROSS_REVENUE'),''))
										)))[1]//Global_100:GROSS_REVENUE/text()	div cts:search(/,
																	  cts:and-query((
																		   cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
																		   cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$item),
																		   cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($year - 1)),
																		   cts:not-query(cts:element-value-query(xs:QName('Global_100:RANK_BY_GROSS_REVENUE'),''))
																		)))[1]//Global_100:GROSS_REVENUE/text())
																		
		  (:let $result := (xs:double($global100GrossRevenue) div xs:double($global100GrossRevenuePre5Year)) * 100:)
		  
		  return if ($result) then (math:pow($result,0.20) - 1) * 100 else ()
                                            
  };
  
declare function firm:rplChange5gMed($organizationIDs,$year)
{
  for $item in fn:tokenize($organizationIDs,',')
		  let $global100GrossRevenue := cts:search(/,
                                                  cts:and-query((
                                                     cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
													   cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$item),
                                                       cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($year)),
													   cts:not-query(cts:element-value-query(xs:QName('Global_100:RANK_BY_GROSS_REVENUE'),''))
                                                    )))[1]//Global_100:GROSS_REVENUE/text()
													
		  let $global100GrossRevenuePre5Year := cts:search(/,
                                                  cts:and-query((
                                                       cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
													   cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$item),
                                                       cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($year - 4)),
													   cts:not-query(cts:element-value-query(xs:QName('Global_100:RANK_BY_GROSS_REVENUE'),''))
                                                    )))[1]//Global_100:GROSS_REVENUE/text()    
			
		  (:let $result := (xs:double($global100GrossRevenue) div xs:double($global100GrossRevenuePre5Year)) * 100:)
		  let $result := xs:double(($global100GrossRevenue div $global100GrossRevenuePre5Year))
		  return if ($result) then (math:pow($result,0.20) - 1) * 100 else ()
                                            
  };
  
  declare function firm:rplChange5Med($organizationIDs,$year)
{
  for $item in fn:tokenize($organizationIDs,',')
		  let $amLawGrossRevenue :=cts:search(/,
                                                  cts:and-query((
                                                       cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                       cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year)),
													   cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item),
													   cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
                                                    )))[1]//AMLAW_200:GROSS_REVENUE/text()
													
		  let $amLawGrossRevenuePre5Year := cts:search(/,
                                                  cts:and-query((
                                                       cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                       cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year - 4)),
													   cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item),
													   cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
                                                    )))//AMLAW_200:GROSS_REVENUE/text()
								
		  let $result := xs:double(($amLawGrossRevenue div $amLawGrossRevenuePre5Year))
		  return if ($result) then (math:pow($result,0.20) - 1) * 100 else ()
                                            
  };
  
declare function firm:rplChange1gMed($organizationIDs,$year)
{
  for $item in fn:tokenize($organizationIDs,',')
		  let $global100GrossRevenue := cts:search(/,
                                                  cts:and-query((
                                                     cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
													   cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$item),
                                                       cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($year)),
													   cts:not-query(cts:element-value-query(xs:QName('Global_100:RANK_BY_GROSS_REVENUE'),''))
                                                    )))[1]//Global_100:GROSS_REVENUE/text()
													
		  let $global100GrossRevenuePre5Year := cts:search(/,
                                                  cts:and-query((
                                                       cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
													   cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$item),
                                                       cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($year - 1)),
													   cts:not-query(cts:element-value-query(xs:QName('Global_100:RANK_BY_GROSS_REVENUE'),''))
                                                    )))[1]//Global_100:GROSS_REVENUE/text()    
			
		  (:let $result := (xs:double($global100GrossRevenue) div xs:double($global100GrossRevenuePre5Year)) * 100:)
		  let $result := xs:double(($global100GrossRevenue div $global100GrossRevenuePre5Year))
		  return if ($result) then (math:pow($result,0.20) - 1) * 100 else ()
                                            
  };
  
  declare function firm:rplChange1Med($organizationIDs,$year)
{
  for $item in fn:tokenize($organizationIDs,',')
		  let $amLawGrossRevenue :=cts:search(/,
                                                  cts:and-query((
                                                       cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                       cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year)),
													   cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item),
													   cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
                                                    )))[1]//AMLAW_200:GROSS_REVENUE/text()
													
		  let $amLawGrossRevenuePre5Year := cts:search(/,
                                                  cts:and-query((
                                                       cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                       cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($year - 1)),
													   cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item),
													   cts:not-query(cts:element-value-query(xs:QName('AMLAW_200:AMLAW200_RANK'),''))
                                                    )))//AMLAW_200:GROSS_REVENUE/text()
								
		  let $result := xs:double(($amLawGrossRevenue div $amLawGrossRevenuePre5Year))
		  return if ($result) then (math:pow($result,0.20) - 1) * 100 else ()
                                            
  };
  
 
  
  
declare function firm:MedianQuery($column1,$column2)
{
  let $organizationIDs :=(:'2503,4,106,123,78,81,36,38,48,49,56,65,3452,214,151,162,163,172,306,311,321,330,333,336,100,5920,244,269,166,232,247,272,158,165,187,85,174,250,53,152,326,1721,2106,105,15,19,92,208,188,215,264,61,145,5,69,1774,79,20,103,433,486,48980,62,147,182,273,295,299,271,257,203,204,285,183,293,221,227,2205,25,283,207,287,199,111,222,157,141,268,95,237,248,325,115,256,210,144,220,236,1781,52,14,32,35,463,112,21,3294,71,143,1830,11,240,259,167,173,153,308,318,7558,320,329,328,5149,7970,175,235,284,296,512,12,126,193,2598,13,242,1728,88,1823,6421,124,2868,90,102,312,317,50,58,1752,109,113,154,176,3541,213,218,136,186,265,3462,24,200,230,22,118,1738,313,331,499,3,55,307,1,155,8,73,171,291,1673,550,2568,29,43622,37857,39,63,93,99,298,185,206,241,297,179,107,77,267,274,277,178,197,212,279,177,233,216,140,64,280,17,276,57,75,119,290,316,332,1750,327,80,322,267,213,298,29,3452,1760,36,392,2186,2205,284,318,210,39,1721,200,463,4555,312,75,469,105,1781,316,1673,1,1815,283,3541,550,2349,516,6421,2431,1702,8002,65477,3462,6425,1774,50,319,10040,2168,2201,3884,186,2246,520,381,2486,157,1842,2457,512,1744,183,143,7953,331,43622,7975,248,273,20,222,177,3451,223,385,27687,3294,295,176,268,1777,2568,265,292,233,259,1750,266,65,100,162,214,203,24,269,78,307,294,144,123,329,12,61,197,330,287,560,274,79,250,254,22,3,325,7570,172,212,41,264,320,103,277,163,2868,1822,306,313,38,42,48,57,1738,293,2503,92,73,151,93,242,1757,328,154,10489,208,15,221,7970,19,165,279,80,450,69,433,504,8,232,1798,333,49,44683,102,77,235,230,113,141,227,236,178,220,3556,95,2301,145,11,126,55,58,336,353,71,53,171,218,257,290,166,52,4385,499,85,237,4,188,321,215,1823,453,119,299,167,134,247,216,159995,34934,173,239,90,240,204,199,107,1764,326,252,1696,271,297,308,272,153,147,291,332,118,2129,311,136,5920,1830,115,152,256,139992,6103,112,106,25,1752,48980,1833,2107,6154,206,317,296,175,1728,486,244,3523,21,187,179,182,81,193,207,338,438,416,13':)
  
  "1,22,25,30,42,57,78,100,123,151,152,153,167,173,179,227,244,247,269,280,294,310,311,321,325,504,1777,1817,1842,2225,2349,2457,2868,3523,3557,4180,6108,7953,34378,34934,37857,39264,57015,58388,67275,123005,160872,164775,164779,11,13,29,77,113,134,144,147,155,157,207,213,218,222,235,252,271,290,297,299,307,316,327,330,353,450,469,560,1732,1774,1823,2136,2201,3462,6421,7570,10996,53070,160796,164769,164778,2,14,20,21,88,90,95,112,141,177,185,210,211,220,223,250,273,289,298,433,463,1764,1781,1830,2140,2598,32770,34366,34644,34761,37738,43622,53023,63776,160873,164757,164766,164771,4,5,24,32,53,81,85,102,119,143,162,163,183,184,193,215,230,240,283,284,285,296,306,308,326,329,331,416,499,1673,1721,1728,1798,1815,2458,2717,3452,5906,6154,10489,21496,34795,53044,65477,123481,141913,8,17,35,37,38,48,55,61,63,69,75,175,206,212,232,239,242,248,257,264,268,276,279,293,318,328,336,392,453,486,516,550,1684,1702,1750,1757,1760,1833,2106,2129,2186,2205,2301,2483,3294,3451,7975,8002,10040,20039,27633,164773,41,50,52,56,71,80,93,99,101,107,136,140,165,178,188,199,200,214,228,233,241,254,265,266,275,277,291,292,322,333,381,512,1738,2246,3541,3556,4385,4849,6425,27634,27687,34379,34627,34642,53077,95132,119382,139992,141901,163674,164765,3,27,36,49,58,64,105,109,115,124,145,154,158,171,172,176,182,186,195,203,216,221,225,236,259,267,287,319,332,385,520,1696,1739,1744,1752,1822,1862,2107,2164,2168,2187,2243,2254,2955,3884,5149,6103,7558,45666,48980,160874,164767,164768,164772,12,15,19,39,60,62,65,73,79,92,103,106,111,118,126,156,166,174,187,197,204,208,237,256,272,274,295,312,313,317,320,324,338,438,2387,2431,2486,2503,2568,2606,3240,4555,5920,6641,7563,7970,20044,20054,21639,25139,44683,53003,53080,159995,160875,164770"
  
 
  
  let $orgIDs := fn:tokenize($organizationIDs,',')
  let $res-array := json:array()
  
  let $item1 := max(fn:distinct-values(cts:search(/,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/')
                      )))//AMLAW_200:PUBLISHYEAR/text()))
 
  let $maxYearGlobal100 := max(fn:distinct-values(cts:search(/,
                              cts:and-query((
                                cts:directory-query('/LegalCompass/relational-data/surveys/Global_100/')
                              )))//Global_100:PUBLISHYEAR/text()))
                              
 
                       
  let $amLawGrossRevenue :=cts:search(/,
                                                  cts:and-query((
                                                       cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                       cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($item1)),
													   cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$orgIDs)
                                                    )))//AMLAW_200:GROSS_REVENUE/text()
                                                    
  let $amLawGrossRevenuePre5Year := cts:search(/,
                                                  cts:and-query((
                                                       cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                       cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($item1 - 4)),
													   cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$orgIDs)
                                                    )))//AMLAW_200:GROSS_REVENUE/text()   
                                                    
                       let $amLawGrossRevenuePre1Year := cts:search(/,
                                                  cts:and-query((
                                                       cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
													   cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$orgIDs),
                                                       cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($item1 - 1))
                                                    )))//AMLAW_200:GROSS_REVENUE/text()     
                       let $global100GrossRevenue := cts:search(/,
                                                  cts:and-query((
                                                       cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
													   cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$orgIDs),
                                                       cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($maxYearGlobal100))
                                                    )))//Global_100:GROSS_REVENUE/text()
                                                    
                       let $global100GrossRevenuePre5Year := cts:search(/,
                                                  cts:and-query((
                                                       cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
													   cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$orgIDs),
                                                       cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($maxYearGlobal100 - 4))
                                                    )))//Global_100:GROSS_REVENUE/text()    
                                                    
                       let $global100GrossRevenuePre1Year :=cts:search(/,
                                                  cts:and-query((
                                                       cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
													   cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$orgIDs),
                                                       cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($maxYearGlobal100 - 1))
                                                    )))//Global_100:GROSS_REVENUE/text()
                        
					   let $rplChangeAmLaw := firm:rplChange5Med($organizationIDs,$item1)
					   let $rplChangeGlobal := firm:rplChange5gMed($organizationIDs,$maxYearGlobal100)
					   
					   let $rplChange1AmLaw := firm:rplChange1Med($organizationIDs,$item1)
					   let $rplChange1Global := firm:rplChange1gMed($organizationIDs,$maxYearGlobal100)
					   
                       let $rplchange5Min := if($amLawGrossRevenuePre5Year != 0) then min($rplChangeAmLaw) else 0
                       let $rplchange1Min :=if($amLawGrossRevenuePre1Year  != 0) then min($rplChange1AmLaw) else 0
					   
                       let $rplchange5gMin :=if($global100GrossRevenuePre5Year  != 0) then min($rplChangeGlobal) else 0
                       let $rplchange1gMin :=if($global100GrossRevenuePre1Year  != 0) then  min($rplChange1Global) else 0
                       
                       let $rplchange5Max :=max($rplChangeAmLaw)
                       let $rplchange1Max :=max($rplChange1AmLaw)
					   
                       let $rplchange5gMax := max($rplChangeGlobal)
                       let $rplchange1gMax := max($rplChange1Global)

						
                       let $rplchange5Med :=math:median($rplChangeAmLaw) 
                       let $rplchange1Med := math:median($rplChange1AmLaw) 
					   
                       let $rplchange5gMed :=math:median($rplChangeGlobal)
					   let $rplchange1gMed :=math:median($rplChange1Global)         
                       
                              
                                     (:-------- Max Year----------:)
                                             let $amLaw200 := cts:search(/,
                                                cts:and-query((
                                                     cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
													 cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$orgIDs),
                                                     cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($item1))
                                                  )))
                                                  
                                             let $diversitySC := cts:search(/,
                                                    cts:and-query((
                                                         cts:directory-query("/LegalCompass/relational-data/surveys/Diversity_Scorecard/"),
														 cts:element-value-query(xs:QName('Diversity_Scorecard:ORGANIZATION_ID'),$orgIDs),
                                                         cts:element-value-query(xs:QName('Diversity_Scorecard:PUBLISHYEAR'),xs:string($item1))
                                                         )))  
                                             
                                             let $femaleSC := cts:search(/,
                                                    cts:and-query((
                                                         cts:directory-query("/LegalCompass/relational-data/surveys/FEMALE_SCORECARD/"),
														 cts:element-value-query(xs:QName('FEMALE_SCORECARD:ORGANIZATION_ID'),$orgIDs),
                                                         cts:element-value-query(xs:QName('FEMALE_SCORECARD:PUBLISHYEAR'),xs:string($item1))
                                                         )))
                                            
                                            let $nlj_lgbt := cts:search(/,
                                                    cts:and-query((
                                                         cts:directory-query("/LegalCompass/relational-data/surveys/NLJ_LGBT/"),
														 cts:element-value-query(xs:QName('nljlgbt:ORGANIZATION_ID'),$orgIDs),
                                                         cts:element-value-query(xs:QName('nljlgbt:PUBLISHYEAR'),xs:string($item1))
                                                         )))
                                                         
                                           let $global100 := cts:search(/,
                                                    cts:and-query((
                                                         cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
														 cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$orgIDs),
                                                         cts:not-query(cts:element-value-query(xs:QName('Global_100:RANK_BY_GROSS_REVENUE'),'')),
                                                         cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($item1))
                                                         )))
                                                         
                                           
                                          let $res-obj := json:object()
                                          (:--------- Max Year ---------------:)
                                          let $rplMed := math:median(firm:getRPL($organizationIDs,xs:string($item1)))
                                          let $rplMin := min(firm:getRPL($organizationIDs,xs:string($item1)))
                                          let $rplMax := max(firm:getRPL($organizationIDs,xs:string($item1)))
										  
                                          let $grossRevenueMin := if($amLaw200//AMLAW_200:GROSS_REVENUE/text() != '') then min($amLaw200//AMLAW_200:GROSS_REVENUE/text()) else min($global100//Global_100:GROSS_REVENUE/text())
                                          let $grossRevenueMax := if($amLaw200//AMLAW_200:GROSS_REVENUE/text() != '') then max($amLaw200//AMLAW_200:GROSS_REVENUE/text()) else max($global100//Global_100:GROSS_REVENUE/text())
										  let $grossRevenueMed := if($amLaw200//AMLAW_200:GROSS_REVENUE/text() != '') then math:median(($amLaw200//AMLAW_200:GROSS_REVENUE/text())) else math:median(($global100//Global_100:GROSS_REVENUE/text()))
										  
                                          let $numOfLawyersMin := if($amLaw200//AMLAW_200:NUM_OF_LAWYERS/text() != '') then min($amLaw200//AMLAW_200:NUM_OF_LAWYERS/text()) else min($global100//Global_100:NUM_LAWYERS/text())
                                          let $numOfLawyersMax := if($amLaw200//AMLAW_200:NUM_OF_LAWYERS/text() != '') then max($amLaw200//AMLAW_200:NUM_OF_LAWYERS/text()) else max($global100//Global_100:NUM_LAWYERS/text())
										  let $numOfLawyersMed := if($amLaw200//AMLAW_200:NUM_OF_LAWYERS/text() != '') then math:median(($amLaw200//AMLAW_200:NUM_OF_LAWYERS/text())) else math:median(($global100//Global_100:NUM_LAWYERS/text()))
										  
                                          let $profitMarginMin := if($amLaw200//AMLAW_200:PROFIT_MARGIN/text() != '') then min($amLaw200//AMLAW_200:PROFIT_MARGIN/text()) 
                                                               else ((min($global100//Global_100:PPP/text()) * min($global100//Global_100:NUM_EQUITY_PARTNERS/text())) div min($global100//Global_100:GROSS_REVENUE/text)) * 100
                                          let $profitMarginMax := if($amLaw200//AMLAW_200:PROFIT_MARGIN/text() != '') then max($amLaw200//AMLAW_200:PROFIT_MARGIN/text())
                                                               else ((max($global100//Global_100:PPP/text()) * max($global100//Global_100:NUM_EQUITY_PARTNERS/text())) div max($global100//Global_100:GROSS_REVENUE/text)) * 100
										  let $profitMarginMed := if($amLaw200//AMLAW_200:PROFIT_MARGIN/text() != '') then math:median(($amLaw200//AMLAW_200:PROFIT_MARGIN/text()))
                                                               else ((math:median(($global100//Global_100:PPP/text())) * math:median(($global100//Global_100:NUM_EQUITY_PARTNERS/text()))) div math:median(($global100//Global_100:GROSS_REVENUE/text))) * 100
															   
                                          let $leverageMin := if($amLaw200//AMLAW_200:LEVERAGE/text() != '') then min($amLaw200//AMLAW_200:LEVERAGE/text()) 
                                                               else ((min($global100//Global_100:NUM_LAWYERS/text()) - min($global100//Global_100:NUM_EQUITY_PARTNERS/text())) div min($global100//Global_100:NUM_EQUITY_PARTNERS/text))
                                          let $leverageMax := if($amLaw200//AMLAW_200:LEVERAGE/text() != '') then max($amLaw200//AMLAW_200:LEVERAGE/text()) 
                                                               else ((max($global100//Global_100:NUM_LAWYERS/text()) - max($global100//Global_100:NUM_EQUITY_PARTNERS/text())) div max($global100//Global_100:NUM_EQUITY_PARTNERS/text))
										  let $leverageMed := if($amLaw200//AMLAW_200:LEVERAGE/text() != '') then math:median(($amLaw200//AMLAW_200:LEVERAGE/text())) 
                                                               else ((math:median(($global100//Global_100:NUM_LAWYERS/text())) - math:median(($global100//Global_100:NUM_EQUITY_PARTNERS/text()))) div math:median(($global100//Global_100:NUM_EQUITY_PARTNERS/text)))				   
															   
                                          let $pppMin := if($amLaw200//AMLAW_200:PPP/text() != '') then min($amLaw200//AMLAW_200:PPP/text()) else min($global100//Global_100:PPP/text())
                                          let $pppMax := if($amLaw200//AMLAW_200:PPP/text() != '') then max($amLaw200//AMLAW_200:PPP/text()) else max($global100//Global_100:PPP/text())
										  let $pppMed := if($amLaw200//AMLAW_200:PPP/text() != '') then math:median(($amLaw200//AMLAW_200:PPP/text())) else math:median(($global100//Global_100:PPP/text()))
										  
                                          let $numEquityPartnerMin := if($amLaw200//AMLAW_200:NUM_EQ_PARTNERS/text() != '') then min($amLaw200//AMLAW_200:NUM_EQ_PARTNERS/text()) 
                                                                   else min($global100//Global_100:NUM_EQUITY_PARTNERS/text())
                                          let $numEquityPartnerMax := if($amLaw200//AMLAW_200:NUM_EQ_PARTNERS/text() != '') then max($amLaw200//AMLAW_200:NUM_EQ_PARTNERS/text()) 
                                                                   else max($global100//Global_100:NUM_EQUITY_PARTNERS/text())
										  let $numEquityPartnerMed := if($amLaw200//AMLAW_200:NUM_EQ_PARTNERS/text() != '') then math:median(($amLaw200//AMLAW_200:NUM_EQ_PARTNERS/text())) 
                                                                   else math:median(($global100//Global_100:NUM_EQUITY_PARTNERS/text()))
										   
										   
										  
										   
                                          let $cplMin := min(firm:getCPL($organizationIDs,xs:string($item1)))
                                          let $cplMax := max(firm:getCPL($organizationIDs,xs:string($item1)))
										  let $cplMed := math:median(firm:getCPL($organizationIDs,xs:string($item1)))
										  
                                          let $ppp1Min := min($amLaw200//AMLAW_200:NET_OPERATING_INCOME/text()) div min($amLaw200//AMLAW_200:TOTAL_PARTNERS/text())
                                          let $ppp1Max := max($amLaw200//AMLAW_200:NET_OPERATING_INCOME/text()) div max($amLaw200//AMLAW_200:TOTAL_PARTNERS/text())
										  let $ppp1Med := math:median(($amLaw200//AMLAW_200:NET_OPERATING_INCOME/text())) div math:median(($amLaw200//AMLAW_200:TOTAL_PARTNERS/text()))
										  
                                          let $equityPartnerMin := min(firm:getEquityPartner($organizationIDs,xs:string($item1)))
                                          let $equityPartnerMax := max(firm:getEquityPartner($organizationIDs,xs:string($item1)))
										  let $equityPartnerMed := math:median((firm:getEquityPartner($organizationIDs,xs:string($item1))))
										  
                                          let $minorityPerMin := min($diversitySC//Diversity_Scorecard:MINORITY_PERCENTAGE/text()) * 100
                                          let $minorityPerMax := max($diversitySC//Diversity_Scorecard:MINORITY_PERCENTAGE/text()) * 100
										  let $minorityPerMed := math:median(($diversitySC//Diversity_Scorecard:MINORITY_PERCENTAGE/text())) * 100
										  
                                          let $femaleAttorneyMin := min($femaleSC//FEMALE_SCORECARD:PCT_FEMALE_ATTORNEYS/text()) * 100
                                          let $femaleAttorneyMax := max($femaleSC//FEMALE_SCORECARD:PCT_FEMALE_ATTORNEYS/text()) * 100
										  let $femaleAttorneyMed := math:median(($femaleSC//FEMALE_SCORECARD:PCT_FEMALE_ATTORNEYS/text())) * 100
										  
                                          let $lgbtAttorneyMin := min($nlj_lgbt//nljlgbt:PERCENT_LGBT_ATTORNEYS/text()) * 100
                                          let $lgbtAttorneyMax := max($nlj_lgbt//nljlgbt:PERCENT_LGBT_ATTORNEYS/text()) * 100
										  let $lgbtAttorneyMed := math:median(($nlj_lgbt//nljlgbt:PERCENT_LGBT_ATTORNEYS/text())) * 100
										  
                                          let $revenueGrowth1Min := min(firm:rplTest1($organizationIDs,$item1))
                                          let $revenueGrowth5Min := min(firm:rplTest($organizationIDs,$item1))
										  
                                          let $revenueGrowth1Max := max(firm:rplTest1($organizationIDs,$item1))
                                          let $revenueGrowth5Max := max(firm:rplTest($organizationIDs,$item1))
										  
                                          let $revenueGrowth1Med := math:median(firm:rplTest1($organizationIDs,$item1))
                                          let $revenueGrowth5Med := math:median(firm:rplTest($organizationIDs,$item1))
                                          
	  let $MAX_VARIABLE1 := if($column1 eq 'Am Law 200 rank') then max($amLaw200//AMLAW_200:AMLAW200_RANK/text()) else
						 if($column1 eq 'Global 100 rank') then max($global100//Global_100:RANK_BY_GROSS_REVENUE/text()) else
						 if($column1 eq 'Revenue Per Lawyer') then $rplMax else
						 if($column1 eq 'Cost Per Lawyer') then $cplMax else
						 if($column1 eq 'Profit Margin') then $profitMarginMax else
						 if($column1 eq '% Turnover') then $profitMarginMax else
						 if($column1 eq 'Leverage') then $leverageMax else
						 if($column1 eq 'Profit Per Partner') then $ppp1Max else
						 if($column1 eq 'Profit Per Equity Partner') then $pppMax else
						 if($column1 eq '% of Equity Partners') then $equityPartnerMax else
						 if($column1 eq '% of Minority Attorneys') then $minorityPerMax else
						 if($column1 eq '% of Female Attorneys') then $femaleAttorneyMax else
						 if($column1 eq '% of LGBT Attorneys') then $lgbtAttorneyMax else
						 if($column1 eq 'Growth in Minority Attorneys') then max($diversitySC//Diversity_Scorecard:TOTAL_MINORITY_ATTORNEYS/text()) else
						 if($column1 eq 'Growth in Female Partners') then max($femaleSC//FEMALE_SCORECARD:FEMALE_PARTNERS/text()) else
						 if($column1 eq 'Revenue Growth (1 year)') then $revenueGrowth1Max else
						 if($column1 eq 'Revenue Growth (5 years)') then $revenueGrowth5Max else $grossRevenueMax
                                          
                                          let $MAX_VARIABLE2 := if($column2 eq 'Am Law 200 rank') then max($amLaw200//AMLAW_200:AMLAW200_RANK/text()) else
                                                             if($column2 eq 'Global 100 rank') then max($global100//Global_100:RANK_BY_GROSS_REVENUE/text()) else
                                                             if($column2 eq 'Revenue Per Lawyer') then $rplMax else
                                                             if($column2 eq 'Cost Per Lawyer') then $cplMax else
                                                             if($column2 eq 'Profit Margin') then $profitMarginMax else
                                                             if($column2 eq '% Turnover') then $profitMarginMax else
                                                             if($column2 eq 'Leverage') then $leverageMax else
                                                             if($column2 eq 'Profit Per Partner') then $ppp1Max else
                                                             if($column2 eq 'Profit Per Equity Partner') then $pppMax else
                                                             if($column2 eq '% of Equity Partners') then $equityPartnerMax else
                                                             if($column2 eq '% of Minority Attorneys') then $minorityPerMax else
                                                             if($column2 eq '% of Female Attorneys') then $femaleAttorneyMax else
                                                             if($column2 eq '% of LGBT Attorneys') then $lgbtAttorneyMax else
                                                             if($column2 eq 'Growth in Minority Attorneys') then max($diversitySC//Diversity_Scorecard:TOTAL_MINORITY_ATTORNEYS/text()) else
                                                             if($column2 eq 'Growth in Female Partners') then max($femaleSC//FEMALE_SCORECARD:FEMALE_PARTNERS/text()) else
                                                             if($column2 eq 'Revenue Growth (1 year)') then $revenueGrowth1Max else
                                                             if($column2 eq 'Revenue Growth (5 years)') then $revenueGrowth5Max else $grossRevenueMax
                                                             
                                          let $MIN_VARIABLE1 := if($column1 eq 'Am Law 200 rank') then min($amLaw200//AMLAW_200:AMLAW200_RANK/text()) else
                                                             if($column1 eq 'Global 100 rank') then min($global100//Global_100:RANK_BY_GROSS_REVENUE/text()) else
                                                             if($column1 eq 'Revenue Per Lawyer') then $rplMin else
                                                             if($column1 eq 'Cost Per Lawyer') then $cplMin else
                                                             if($column1 eq 'Profit Margin') then $profitMarginMin else
                                                             if($column1 eq '% Turnover') then $profitMarginMin else
                                                             if($column1 eq 'Leverage') then $leverageMin else
                                                             if($column1 eq 'Profit Per Partner') then $ppp1Min else
                                                             if($column1 eq 'Profit Per Equity Partner') then $pppMin else
                                                             if($column1 eq '% of Equity Partners') then $equityPartnerMin else
                                                             if($column1 eq '% of Minority Attorneys') then $minorityPerMin else
                                                             if($column1 eq '% of Female Attorneys') then $femaleAttorneyMin else
                                                             if($column1 eq '% of LGBT Attorneys') then $lgbtAttorneyMin else
                                                             if($column1 eq 'Growth in Minority Attorneys') then min($diversitySC//Diversity_Scorecard:TOTAL_MINORITY_ATTORNEYS/text()) else
                                                             if($column1 eq 'Growth in Female Partners') then min($femaleSC//FEMALE_SCORECARD:FEMALE_PARTNERS/text()) else
                                                             if($column1 eq 'Revenue Growth (1 year)') then $revenueGrowth1Min else
                                                             if($column1 eq 'Revenue Growth (5 years)') then $revenueGrowth5Min else $grossRevenueMin
                                          
                                          let $MIN_VARIABLE2 := if($column2 eq 'Am Law 200 rank') then min($amLaw200//AMLAW_200:AMLAW200_RANK/text()) else
                                                             if($column2 eq 'Global 100 rank') then min($global100//Global_100:RANK_BY_GROSS_REVENUE/text()) else
                                                             if($column2 eq 'Revenue Per Lawyer') then $rplMin else
                                                             if($column2 eq 'Cost Per Lawyer') then $cplMin else
                                                             if($column2 eq 'Profit Margin') then $profitMarginMin else
                                                             if($column2 eq '% Turnover') then $profitMarginMin else
                                                             if($column2 eq 'Leverage') then $leverageMin else
                                                             if($column2 eq 'Profit Per Partner') then $ppp1Min else
                                                             if($column2 eq 'Profit Per Equity Partner') then $pppMin else
                                                             if($column2 eq '% of Equity Partners') then $equityPartnerMin else
                                                             if($column2 eq '% of Minority Attorneys') then $minorityPerMin else
                                                             if($column2 eq '% of Female Attorneys') then $femaleAttorneyMin else
                                                             if($column2 eq '% of LGBT Attorneys') then $lgbtAttorneyMin else
                                                             if($column2 eq 'Growth in Minority Attorneys') then min($diversitySC//Diversity_Scorecard:TOTAL_MINORITY_ATTORNEYS/text()) else
                                                             if($column2 eq 'Growth in Female Partners') then min($femaleSC//FEMALE_SCORECARD:FEMALE_PARTNERS/text()) else
                                                             if($column2 eq 'Revenue Growth (1 year)') then $revenueGrowth1Min else
                                                             if($column2 eq 'Revenue Growth (5 years)') then $revenueGrowth5Min else $grossRevenueMax                   
                                         
                                           let $MEDIAN_Variable1 := if($column1 eq 'Am Law 200 rank') then math:median(($amLaw200//AMLAW_200:AMLAW200_RANK/text())) else
                                                             if($column1 eq 'Global 100 rank') then math:median(($global100//Global_100:RANK_BY_GROSS_REVENUE/text())) else
                                                             if($column1 eq 'Revenue Per Lawyer') then $rplMed else
                                                             if($column1 eq 'Cost Per Lawyer') then $cplMed else
                                                             if($column1 eq 'Profit Margin') then $profitMarginMed else
                                                             if($column1 eq '% Turnover') then $profitMarginMed else
                                                             if($column1 eq 'Leverage') then $leverageMed else
                                                             if($column1 eq 'Profit Per Partner') then $ppp1Med else
                                                             if($column1 eq 'Profit Per Equity Partner') then $pppMed else
                                                             if($column1 eq '% of Equity Partners') then $equityPartnerMed else
                                                             if($column1 eq '% of Minority Attorneys') then $minorityPerMed else
                                                             if($column1 eq '% of Female Attorneys') then $femaleAttorneyMed else
                                                             if($column1 eq '% of LGBT Attorneys') then $lgbtAttorneyMed else
                                                             if($column1 eq 'Growth in Minority Attorneys') then math:median(($diversitySC//Diversity_Scorecard:TOTAL_MINORITY_ATTORNEYS/text())) else
                                                             if($column1 eq 'Growth in Female Partners') then math:median(($femaleSC//FEMALE_SCORECARD:FEMALE_PARTNERS/text())) else
                                                             if($column1 eq 'Revenue Growth (1 year)') then $revenueGrowth1Med else
                                                             if($column1 eq 'Revenue Growth (5 years)') then $revenueGrowth5Med else $grossRevenueMed
                                          
                                          let $MEDIAN_Variable2 := if($column2 eq 'Am Law 200 rank') then math:median(($amLaw200//AMLAW_200:AMLAW200_RANK/text())) else
                                                             if($column2 eq 'Global 100 rank') then math:median(($global100//Global_100:RANK_BY_GROSS_REVENUE/text())) else
                                                             if($column2 eq 'Revenue Per Lawyer') then $rplMed else
                                                             if($column2 eq 'Cost Per Lawyer') then $cplMed else
                                                             if($column2 eq 'Profit Margin') then $profitMarginMed else
                                                             if($column2 eq '% Turnover') then $profitMarginMed else
                                                             if($column2 eq 'Leverage') then $leverageMed else
                                                             if($column2 eq 'Profit Per Partner') then $ppp1Med else
                                                             if($column2 eq 'Profit Per Equity Partner') then $pppMed else
                                                             if($column2 eq '% of Equity Partners') then $equityPartnerMed else
                                                             if($column2 eq '% of Minority Attorneys') then $minorityPerMed else
                                                             if($column2 eq '% of Female Attorneys') then $femaleAttorneyMed else
                                                             if($column2 eq '% of LGBT Attorneys') then $lgbtAttorneyMed else
                                                             if($column2 eq 'Growth in Minority Attorneys') then math:median(($diversitySC//Diversity_Scorecard:TOTAL_MINORITY_ATTORNEYS/text())) else
                                                             if($column2 eq 'Growth in Female Partners') then math:median(($femaleSC//FEMALE_SCORECARD:FEMALE_PARTNERS/text())) else
                                                             if($column2 eq 'Revenue Growth (1 year)') then $revenueGrowth1Med else
                                                             if($column2 eq 'Revenue Growth (5 years)') then $revenueGrowth5Med else $grossRevenueMed
                                                             
                                          let $_ := (map:put($res-obj,'PUBLISHYEAR',$item1),
                                                     map:put($res-obj,'Med_VARIABLE1',$MEDIAN_Variable1),
                                                     map:put($res-obj,'Med_VARIABLE2',$MEDIAN_Variable2),
                                                     map:put($res-obj,'Max_VARIABLE1',$MAX_VARIABLE1),
                                                     map:put($res-obj,'Min_VARIABLE1',$MIN_VARIABLE1),
                                                     map:put($res-obj,'Max_VARIABLE2',$MAX_VARIABLE2),
                                                     map:put($res-obj,'Min_VARIABLE2',$MIN_VARIABLE2)
                                                     )
                                       
                                        let $_ := json:array-push($res-array,$res-obj)
  return $res-array
};

declare function firm:CombinedQuery($organizationID,$column1,$column2)
{
  let $res-array := json:array()
  
  let $maxYear := fn:distinct-values(cts:search(/,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/')
                      )))//AMLAW_200:PUBLISHYEAR/text())
 
  let $maxYearGlobal100 := fn:distinct-values(cts:search(/,
                              cts:and-query((
                                cts:directory-query('/LegalCompass/relational-data/surveys/Global_100/')
                              )))//Global_100:PUBLISHYEAR/text())
  
  let $result := cts:search(/,
                  cts:and-query((
                       cts:directory-query("/LegalCompass/relational-data/organization/"),
                       cts:element-value-query(xs:QName('organizations:ORGANIZATION_ID'),fn:tokenize($organizationID,',')),
                       cts:element-value-query(xs:QName('organizations:ORGANIZATION_TYPE_ID'),'1')
                       )))
                       
  let $loopData :=for $item in $result
  
                       let $amLawGrossRevenue := sum(cts:search(/,
                                                  cts:and-query((
                                                       cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                       cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                       cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string(max($maxYear)))
                                                    )))//AMLAW_200:GROSS_REVENUE/text())
                                                    
                       let $amLawGrossRevenuePre5Year := sum(cts:search(/,
                                                  cts:and-query((
                                                       cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                       cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                       cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string(max($maxYear)-4))
                                                    )))//AMLAW_200:GROSS_REVENUE/text())   
                                                    
                       let $amLawGrossRevenuePre1Year := sum(cts:search(/,
                                                  cts:and-query((
                                                       cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                       cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                       cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string(max($maxYear)-1))
                                                    )))//AMLAW_200:GROSS_REVENUE/text())      
                       let $global100GrossRevenue := sum(cts:search(/,
                                                  cts:and-query((
                                                       cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
                                                       cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                       cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string(max($maxYearGlobal100)))
                                                    )))//Global_100:GROSS_REVENUE/text())
                                                    
                       let $global100GrossRevenuePre5Year := sum(cts:search(/,
                                                  cts:and-query((
                                                       cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
                                                       cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                       cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string(max($maxYearGlobal100) - 4))
                                                    )))//Global_100:GROSS_REVENUE/text())    
                                                    
                       let $global100GrossRevenuePre1Year := sum(cts:search(/,
                                                  cts:and-query((
                                                       cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
                                                       cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                       cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string(max($maxYearGlobal100) - 1))
                                                    )))//Global_100:GROSS_REVENUE/text()) 
                                                    
                       let $rplchange5 :=if($amLawGrossRevenuePre5Year ne 0) then firm:rplChange5Med($item//organizations:ORGANIZATION_ID/text(),max($maxYear)) else 0
                       let $rplchange1 :=if($amLawGrossRevenuePre1Year  ne 0) then firm:rplChange1Med($item//organizations:ORGANIZATION_ID/text(),max($maxYear)) else 0
					   
                       let $rplchange5g :=if($global100GrossRevenuePre5Year  ne 0) then firm:rplChange5gMed($item//organizations:ORGANIZATION_ID/text(),max($maxYear)) else 0
                       let $rplchange1g :=if($global100GrossRevenuePre1Year  ne 0) then firm:rplChange1gMed($item//organizations:ORGANIZATION_ID/text(),max($maxYear)) else 0
                       
                       (:------------ Max Year -------------:)
                       let $amLaw200 := cts:search(/,
                                                cts:and-query((
                                                     cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                     cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                     cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string(max($maxYear)))
                                                  )))
                                                  
                                             let $diversitySC := cts:search(/,
                                                    cts:and-query((
                                                         cts:directory-query("/LegalCompass/relational-data/surveys/Diversity_Scorecard/"),
                                                         cts:element-value-query(xs:QName('Diversity_Scorecard:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                         cts:element-value-query(xs:QName('Diversity_Scorecard:PUBLISHYEAR'),xs:string(max($maxYear)))
                                                         )))  
                                             
                                             let $femaleSC := cts:search(/,
                                                    cts:and-query((
                                                         cts:directory-query("/LegalCompass/relational-data/surveys/FEMALE_SCORECARD/"),
                                                         cts:element-value-query(xs:QName('FEMALE_SCORECARD:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                         cts:element-value-query(xs:QName('FEMALE_SCORECARD:PUBLISHYEAR'),xs:string(max($maxYear)))
                                                         )))
                                            
                                            let $nlj_lgbt := cts:search(/,
                                                    cts:and-query((
                                                         cts:directory-query("/LegalCompass/relational-data/surveys/NLJ_LGBT/"),
                                                         cts:element-value-query(xs:QName('nljlgbt:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                         cts:element-value-query(xs:QName('nljlgbt:PUBLISHYEAR'),xs:string(max($maxYear)))
                                                         )))
                                                         
                                           let $global100 := cts:search(/,
                                                    cts:and-query((
                                                         cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
                                                         cts:not-query(cts:element-value-query(xs:QName('Global_100:RANK_BY_GROSS_REVENUE'),'')),
                                                         cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                         cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string(max($maxYear)))
                                                         )))
                                                         
                                          let $res-obj := json:object()
                                          let $rpl := if($amLaw200//AMLAW_200:RPL/text() ne '') then $amLaw200//AMLAW_200:RPL/text() else $global100//Global_100:REVENUE_PER_LAWYER/text()
                                          let $grossRevenue := if($amLaw200//AMLAW_200:GROSS_REVENUE/text() ne '') then $amLaw200//AMLAW_200:GROSS_REVENUE/text() else $global100//Global_100:GROSS_REVENUE/text()
                                          let $numOfLawyers := if($amLaw200//AMLAW_200:NUM_OF_LAWYERS/text() ne '') then $amLaw200//AMLAW_200:NUM_OF_LAWYERS/text() else $global100//Global_100:NUM_LAWYERS/text()
                                          let $profitMargin := if($amLaw200//AMLAW_200:PROFIT_MARGIN/text() ne '') then $amLaw200//AMLAW_200:PROFIT_MARGIN/text() 
                                                               else ((xs:integer($global100//Global_100:PPP/text()) * xs:integer($global100//Global_100:NUM_EQUITY_PARTNERS/text())) div xs:integer($global100//Global_100:GROSS_REVENUE/text)) * 100
                                          let $leverage := if($amLaw200//AMLAW_200:LEVERAGE/text() ne '') then $amLaw200//AMLAW_200:LEVERAGE/text() 
                                                               else ((xs:integer($global100//Global_100:NUM_LAWYERS/text()) - xs:integer($global100//Global_100:NUM_EQUITY_PARTNERS/text())) div xs:integer($global100//Global_100:NUM_EQUITY_PARTNERS/text))
                                          let $ppp := if($amLaw200//AMLAW_200:PPP/text() ne '') then $amLaw200//AMLAW_200:PPP/text() else $global100//Global_100:PPP/text()
                                          let $numEquityPartner := if($amLaw200//AMLAW_200:NUM_EQ_PARTNERS/text() ne '') then $amLaw200//AMLAW_200:NUM_EQ_PARTNERS/text() 
                                                                   else $global100//Global_100:NUM_EQUITY_PARTNERS/text()
                                          (:let $grossRevenue := if($amLaw200//AMLAW_200:GROSS_REVENUE/text() ne '') then $amLaw200//AMLAW_200:GROSS_REVENUE/text() else $global100//Global_100:GROSS_REVENUE/text():)
										  let $netOperationIncome := $amLaw200//AMLAW_200:NET_OPERATING_INCOME/text()
										  let $noofLawyers := if($amLaw200//AMLAW_200:NUM_OF_LAWYERS/text() ne '') then $amLaw200//AMLAW_200:NUM_OF_LAWYERS/text() else $global100//Global_100:NUM_LAWYERS/text()
										  
                                          let $cpl := (xs:integer($grossRevenue) - xs:integer($netOperationIncome)) div xs:integer($noofLawyers)
                                         
                                          let $ppp1 := xs:double($amLaw200//AMLAW_200:NET_OPERATING_INCOME/text()) div xs:double($amLaw200//AMLAW_200:TOTAL_PARTNERS/text())
                                         
                                          let $equityPartner := xs:double($numEquityPartner) div xs:double($amLaw200//AMLAW_200:TOTAL_PARTNERS/text())
                                          let $minorityPer := xs:double($diversitySC//Diversity_Scorecard:MINORITY_PERCENTAGE/text()) * 100
                                         
                                          let $femaleAttorney := xs:double($femaleSC//FEMALE_SCORECARD:PCT_FEMALE_ATTORNEYS/text()) * 100
                                         
                                         
                                          let $lgbtAttorney := xs:double($nlj_lgbt//nljlgbt:PERCENT_LGBT_ATTORNEYS/text()) * 100                         
                                          (:---------- Max Year -1 ------------:)
                                          let $amLaw200Pre := cts:search(/,
                                                cts:and-query((
                                                     cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                     cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                     cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string(max($maxYear) - 1))
                                                  )))
                                                  
                                             let $diversitySCPre := cts:search(/,
                                                    cts:and-query((
                                                         cts:directory-query("/LegalCompass/relational-data/surveys/Diversity_Scorecard/"),
                                                         cts:element-value-query(xs:QName('Diversity_Scorecard:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                         cts:element-value-query(xs:QName('Diversity_Scorecard:PUBLISHYEAR'),xs:string(max($maxYear) - 1))
                                                         )))  
                                             
                                             let $femaleSCPre := cts:search(/,
                                                    cts:and-query((
                                                         cts:directory-query("/LegalCompass/relational-data/surveys/FEMALE_SCORECARD/"),
                                                         cts:element-value-query(xs:QName('FEMALE_SCORECARD:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                         cts:element-value-query(xs:QName('FEMALE_SCORECARD:PUBLISHYEAR'),xs:string(max($maxYear) - 1))
                                                         )))
                                            
                                            let $nlj_lgbtPre := cts:search(/,
                                                    cts:and-query((
                                                         cts:directory-query("/LegalCompass/relational-data/surveys/NLJ_LGBT/"),
                                                         cts:element-value-query(xs:QName('nljlgbt:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                         cts:element-value-query(xs:QName('nljlgbt:PUBLISHYEAR'),xs:string(max($maxYear) -1 ))
                                                         )))
                                                         
                                           let $global100Pre := cts:search(/,
                                                    cts:and-query((
                                                         cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
                                                         cts:not-query(cts:element-value-query(xs:QName('Global_100:RANK_BY_GROSS_REVENUE'),'')),
                                                         cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                         cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string(max($maxYear) -1 ))
                                                         )))
                                                         
                                          let $res-obj := json:object()
                                          let $rplPre := if($amLaw200Pre//AMLAW_200:RPL/text() ne '') then $amLaw200Pre//AMLAW_200:RPL/text() else $global100Pre//Global_100:RANK_BY_GROSS_REVENUE/text()
                                          let $grossRevenuePre := if($amLaw200Pre//AMLAW_200:GROSS_REVENUE/text() ne '') then $amLaw200Pre//AMLAW_200:GROSS_REVENUE/text() else $global100Pre//Global_100:GROSS_REVENUE/text()
                                          let $numOfLawyersPre := if($amLaw200Pre//AMLAW_200:NUM_OF_LAWYERS/text() ne '') then $amLaw200Pre//AMLAW_200:NUM_OF_LAWYERS/text() else $global100Pre//Global_100:NUM_LAWYERS/text()
                                          let $profitMarginPre := if($amLaw200Pre//AMLAW_200:PROFIT_MARGIN/text() ne '') then $amLaw200Pre//AMLAW_200:PROFIT_MARGIN/text() 
                                                               else ((xs:integer($global100Pre//Global_100:PPP/text()) * xs:integer($global100Pre//Global_100:NUM_EQUITY_PARTNERS/text())) div xs:integer($global100Pre//Global_100:GROSS_REVENUE/text)) * 100
                                          let $leveragePre := if($amLaw200Pre//AMLAW_200:LEVERAGE/text() ne '') then $amLaw200Pre//AMLAW_200:LEVERAGE/text() 
                                                               else ((xs:integer($global100Pre//Global_100:NUM_LAWYERS/text()) - xs:integer($global100Pre//Global_100:NUM_EQUITY_PARTNERS/text())) div xs:integer($global100Pre//Global_100:NUM_EQUITY_PARTNERS/text))
                                          let $pppPre := if($amLaw200Pre//AMLAW_200:PPP/text() ne '') then $amLaw200Pre//AMLAW_200:PPP/text() else $global100Pre//Global_100:PPP/text()
                                          let $numEquityPartnerPre := if($amLaw200Pre//AMLAW_200:NUM_EQ_PARTNERS/text() ne '') then $amLaw200Pre//AMLAW_200:NUM_EQ_PARTNERS/text() 
                                                                   else $global100Pre//Global_100:NUM_EQUITY_PARTNERS/text()
																   
										  let $netOperationIncomePre := $amLaw200Pre//AMLAW_200:NET_OPERATING_INCOME/text()
										  let $noofLawyersPre := if($amLaw200Pre//AMLAW_200:NUM_OF_LAWYERS/text() ne '') then $amLaw200Pre//AMLAW_200:NUM_OF_LAWYERS/text() else $global100Pre//Global_100:NUM_LAWYERS/text()
										  
										  
																   
                                           let $cplPre := (xs:integer($grossRevenuePre) - xs:integer($netOperationIncomePre)) div xs:integer($noofLawyersPre)
                                         
                                          let $ppp1Pre := xs:double($amLaw200Pre//AMLAW_200:NET_OPERATING_INCOME/text()) div xs:double($amLaw200Pre//AMLAW_200:TOTAL_PARTNERS/text())
                                         
                                          let $equityPartnerPre := xs:double($numEquityPartnerPre) div xs:double($amLaw200Pre//AMLAW_200:TOTAL_PARTNERS/text())
                                          let $minorityPerPre := xs:double($diversitySCPre//Diversity_Scorecard:MINORITY_PERCENTAGE/text()) * 100
                                         
                                          let $femaleAttorneyPre := xs:double($femaleSCPre//FEMALE_SCORECARD:PCT_FEMALE_ATTORNEYS/text()) * 100
                                         
                                         
                                          let $lgbtAttorneyPre := xs:double($nlj_lgbtPre//nljlgbt:PERCENT_LGBT_ATTORNEYS/text()) * 100    
                                          let $revenueGrowth1 := if($amLaw200//AMLAW_200:GROSS_REVENUE/text() ne '') then $rplchange1 else $rplchange1g
                                          let $revenueGrowth5 := if($amLaw200//AMLAW_200:GROSS_REVENUE/text() ne '') then $rplchange5 else $rplchange5g
                                          let $variable1 := if($column1 eq 'Am Law 200 rank') then $amLaw200//AMLAW_200:AMLAW200_RANK/text() else
                                                             if($column1 eq 'Global 100 rank') then $global100//Global_100:RANK_BY_GROSS_REVENUE/text() else
                                                             if($column1 eq 'Revenue Per Lawyer') then $rpl else
                                                             if($column1 eq 'Cost Per Lawyer') then $cpl else
                                                             if($column1 eq 'Profit Margin') then $profitMargin else
                                                             if($column1 eq '% Turnover') then $profitMargin else
                                                             if($column1 eq 'Leverage') then $leverage else
                                                             if($column1 eq 'Profit Per Partner') then $ppp1 else
                                                             if($column1 eq 'Profit Per Equity Partner') then $ppp else
                                                             if($column1 eq '% of Equity Partners') then $equityPartner else
                                                             if($column1 eq '% of Minority Attorneys') then $minorityPer else
                                                             if($column1 eq '% of Female Attorneys') then $femaleAttorney else
                                                             if($column1 eq '% of LGBT Attorneys') then $lgbtAttorney else
                                                             if($column1 eq 'Growth in Minority Attorneys') then $diversitySC//Diversity_Scorecard:TOTAL_MINORITY_ATTORNEYS/text() else
                                                             if($column1 eq 'Growth in Female Partners') then $femaleSC//FEMALE_SCORECARD:FEMALE_PARTNERS/text() else
                                                             if($column1 eq 'Revenue Growth (1 year)') then $revenueGrowth1 else
                                                             if($column1 eq 'Revenue Growth (5 years)') then $revenueGrowth5 else $grossRevenue
                                          
                                          let $variable2 := if($column2 eq 'Am Law 200 rank') then $amLaw200//AMLAW_200:AMLAW200_RANK/text() else
                                                             if($column2 eq 'Global 100 rank') then $global100//Global_100:RANK_BY_GROSS_REVENUE/text() else
                                                             if($column2 eq 'Revenue Per Lawyer') then $rpl else
                                                             if($column2 eq 'Cost Per Lawyer') then $cpl else
                                                             if($column2 eq 'Profit Margin') then $profitMargin else
                                                             if($column2 eq '% Turnover') then $profitMargin else
                                                             if($column2 eq 'Leverage') then $leverage else
                                                             if($column2 eq 'Profit Per Partner') then $ppp1 else
                                                             if($column2 eq 'Profit Per Equity Partner') then $ppp else
                                                             if($column2 eq '% of Equity Partners') then $equityPartner else
                                                             if($column2 eq '% of Minority Attorneys') then $minorityPer else
                                                             if($column2 eq '% of Female Attorneys') then $femaleAttorney else
                                                             if($column2 eq '% of LGBT Attorneys') then $lgbtAttorney else
                                                             if($column2 eq 'Growth in Minority Attorneys') then $diversitySC//Diversity_Scorecard:TOTAL_MINORITY_ATTORNEYS/text() else
                                                             if($column2 eq 'Growth in Female Partners') then $femaleSC//FEMALE_SCORECARD:FEMALE_PARTNERS/text() else
                                                             if($column2 eq 'Revenue Growth (1 year)') then $revenueGrowth1 else
                                                             if($column2 eq 'Revenue Growth (5 years)') then $revenueGrowth5 else $grossRevenue
                                                             
                                          let $variablePre1 := if($column1 eq 'Am Law 200 rank') then $amLaw200Pre//AMLAW_200:AMLAW200_RANK/text() else
                                                             if($column1 eq 'Global 100 rank') then $global100Pre//Global_100:RANK_BY_GROSS_REVENUE/text() else
                                                             if($column1 eq 'Revenue Per Lawyer') then $rplPre else
                                                             if($column1 eq 'Cost Per Lawyer') then $cplPre else
                                                             if($column1 eq 'Profit Margin') then $profitMarginPre else
                                                             if($column1 eq '% Turnover') then $profitMarginPre else
                                                             if($column1 eq 'Leverage') then $leveragePre else
                                                             if($column1 eq 'Profit Per Partner') then $ppp1Pre else
                                                             if($column1 eq 'Profit Per Equity Partner') then $pppPre else
                                                             if($column1 eq '% of Equity Partners') then $equityPartnerPre else
                                                             if($column1 eq '% of Minority Attorneys') then $minorityPerPre else
                                                             if($column1 eq '% of Female Attorneys') then $femaleAttorneyPre else
                                                             if($column1 eq '% of LGBT Attorneys') then $lgbtAttorneyPre else
                                                             if($column1 eq 'Growth in Minority Attorneys') then $diversitySCPre//Diversity_Scorecard:TOTAL_MINORITY_ATTORNEYS/text() else
                                                             if($column1 eq 'Growth in Female Partners') then $femaleSCPre//FEMALE_SCORECARD:FEMALE_PARTNERS/text() else
                                                             if($column1 eq 'Revenue Growth (1 year)') then $revenueGrowth1 else
                                                             if($column1 eq 'Revenue Growth (5 years)') then $revenueGrowth5 else $grossRevenue
                                          
                                          let $variablePre2 := if($column2 eq 'Am Law 200 rank') then $amLaw200Pre//AMLAW_200:AMLAW200_RANK/text() else
                                                             if($column2 eq 'Global 100 rank') then $global100Pre//Global_100:RANK_BY_GROSS_REVENUE/text() else
                                                             if($column2 eq 'Revenue Per Lawyer') then $rplPre else
                                                             if($column2 eq 'Cost Per Lawyer') then $cplPre else
                                                             if($column2 eq 'Profit Margin') then $profitMarginPre else
                                                             if($column2 eq '% Turnover') then $profitMarginPre else
                                                             if($column2 eq 'Leverage') then $leveragePre else
                                                             if($column2 eq 'Profit Per Partner') then $ppp1Pre else
                                                             if($column2 eq 'Profit Per Equity Partner') then $pppPre else
                                                             if($column2 eq '% of Equity Partners') then $equityPartnerPre else
                                                             if($column2 eq '% of Minority Attorneys') then $minorityPerPre else
                                                             if($column2 eq '% of Female Attorneys') then $femaleAttorney else
                                                             if($column2 eq '% of LGBT Attorneys') then $lgbtAttorneyPre else
                                                             if($column2 eq 'Growth in Minority Attorneys') then $diversitySCPre//Diversity_Scorecard:TOTAL_MINORITY_ATTORNEYS/text() else
                                                             if($column2 eq 'Growth in Female Partners') then $femaleSCPre//FEMALE_SCORECARD:FEMALE_PARTNERS/text() else
                                                             if($column2 eq 'Revenue Growth (1 year)') then $revenueGrowth1 else
                                                             if($column2 eq 'Revenue Growth (5 years)') then $revenueGrowth5 else $grossRevenue                   
                                                             
                                          let $variableChanges1 :=if($variablePre1) then fn:format-number(xs:float((($variable1 - $variablePre1) div $variablePre1) * 100) ,'#,##0.00') else()
                                          let $variableChanges2 :=if($variablePre2) then fn:format-number(xs:float((($variable2 - $variablePre2) div $variablePre2) * 100) ,'#,##0.00') else()
                                          
                                          let $_ := (map:put($res-obj,'ORGANIZATION_ID',$item//organizations:ORGANIZATION_ID/text()),
                                                     map:put($res-obj,'ORGANIZATION_NAME',$item//organizations:ORGANIZATION_NAME/text()),
                                                     map:put($res-obj,'VARIABLE_CHANGES1',fn:format-number(xs:double($variableChanges1),'.00')),
                                                     map:put($res-obj,'CUR_VARIABLE1',fn:format-number(xs:double($variable1) * 100,'.00')),
                                                     map:put($res-obj,'PRE_VARIABLE1',fn:format-number(xs:double($variablePre1) * 100,'.00')),
                                                     map:put($res-obj,'Variable2_Change',fn:format-number(xs:double($variableChanges2),'.00')),
                                                     map:put($res-obj,'CUR_VARIABLE2',fn:format-number(xs:double($variable2),'.00')),
                                                     map:put($res-obj,'PRE_VARIABLE2',fn:format-number(xs:double($variablePre2),'.00'))
                                                     )
                                                     
                                        let $_ := json:array-push($res-array,$res-obj)
                                        
                                        return()
  return $res-array
};


(:--------------- Score Card --------------------:)

 declare function firm:SP_GETFIRMPERFORMANCESCORE1($primaryFirmID,$firmID)
{
   let $res-obj := json:object()
  let $maxYear := max(cts:search(/,
                      cts:and-query((
                        cts:directory-query('/LegalCompass/relational-data/surveys/AMLAW_200/')
                      )))//AMLAW_200:PUBLISHYEAR/text())
                      
  let $result := cts:search(/,
                  cts:and-query((
                       cts:directory-query("/LegalCompass/relational-data/organization/"),
                       cts:element-value-query(xs:QName('organizations:ORGANIZATION_ID'),xs:string($primaryFirmID))
                       )))
                       
  let $loopData := for $item in $result
                       
                       let $amLaw200 :=  cts:search(/,
                                                cts:and-query((
                                                     cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                     cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                     cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($maxYear))
                                                     )))
                       
                       let $amLaw200PreYear :=  cts:search(/,
                                                cts:and-query((
                                                     cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                     cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                     cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($maxYear - 1))
                                                     )))
                       
                       let $nlj250 := cts:search(/,
                                            cts:and-query((
                                                 cts:directory-query("/LegalCompass/relational-data/surveys/NLJ_250/"),
                                                 cts:element-value-query(xs:QName('nlj250:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                 cts:element-value-query(xs:QName('nlj250:PUBLISHYEAR'),xs:string($maxYear))
                                                 )))
                                                 
                       let $nlj_lgbt := cts:search(/,
                                            cts:and-query((
                                                 cts:directory-query("/LegalCompass/relational-data/surveys/NLJ_LGBT/"),
                                                 cts:element-value-query(xs:QName('nljlgbt:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                 cts:element-value-query(xs:QName('nljlgbt:PUBLISHYEAR'),xs:string($maxYear))
                                                 )))                           
                       
                       let $femaleSC := cts:search(/,
                                            cts:and-query((
                                                 cts:directory-query("/LegalCompass/relational-data/surveys/FEMALE_SCORECARD/"),
                                                 cts:element-value-query(xs:QName('FEMALE_SCORECARD:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                 cts:element-value-query(xs:QName('FEMALE_SCORECARD:PUBLISHYEAR'),xs:string($maxYear))
                                                 )))              
                       

                       let $diversitySC := cts:search(/,
                                            cts:and-query((
                                                 cts:directory-query("/LegalCompass/relational-data/surveys/Diversity_Scorecard/"),
                                                 cts:element-value-query(xs:QName('Diversity_Scorecard:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                 cts:element-value-query(xs:QName('Diversity_Scorecard:PUBLISHYEAR'),xs:string($maxYear))
                                                 )))           
                       
                            
                       let $global100 := cts:search(/,
                                                  cts:and-query((
                                                       cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
                                                       cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                       cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($maxYear)))))
                      
                       let $global100PreYear := cts:search(/,
                                                  cts:and-query((
                                                       cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
                                                       cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),$item//organizations:ORGANIZATION_ID/text()),
                                                       cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($maxYear - 1)))))
                      
                      
                       
                       let $grossRevenue := if($amLaw200//AMLAW_200:GROSS_REVENUE/text() != '') then $amLaw200//AMLAW_200:GROSS_REVENUE/text()
                                            else $global100//Global_100:GROSS_REVENUE/text()
                       
                       let $grossRevenuePreYear := if($amLaw200PreYear//AMLAW_200:GROSS_REVENUE/text() != '') then $amLaw200PreYear//AMLAW_200:GROSS_REVENUE/text()
                                            else $global100PreYear//Global_100:GROSS_REVENUE/text()
                       let $growthFirmValue := ((xs:double($grossRevenue) - xs:double($grossRevenuePreYear)) div xs:double($grossRevenuePreYear)) * 100
                       let $rpl := if($amLaw200//AMLAW_200:RPL/text() != '') then $amLaw200//AMLAW_200:RPL/text()
                                            else $global100//Global_100:REVENUE_PER_LAWYER/text()
                       let $ppp := if($amLaw200//AMLAW_200:PPP/text() != '') then $amLaw200//AMLAW_200:PPP/text()
                                            else $global100//Global_100:PPP/text()     
                       let $eqp := (xs:double($amLaw200//AMLAW_200:NUM_EQ_PARTNERS/text()) div xs:double($amLaw200//AMLAW_200:TOTAL_PARTNERS/text())) * 100
                       let $cpl := (xs:double($amLaw200//AMLAW_200:GROSS_REVENUE/text()) - xs:double($amLaw200//AMLAW_200:NET_OPERATING_INCOME/text())) div xs:double($amLaw200//AMLAW_200:NUM_OF_LAWYERS/text())
                       let $profitMargin := if($amLaw200//AMLAW_200:PROFIT_MARGIN/text() ne '') then $amLaw200//AMLAW_200:PROFIT_MARGIN/text()
                                            else ((xs:double($global100//Global_100:PPP/text()) * xs:double($global100//Global_100:NUM_EQUITY_PARTNERS/text())) div xs:double($global100//Global_100:GROSS_REVENUE/text())) * 100
                       let $profitMarginPreYear := if($amLaw200PreYear//AMLAW_200:PROFIT_MARGIN/text() != '') then $amLaw200PreYear//AMLAW_200:PROFIT_MARGIN/text()
                                            else ((xs:double($global100PreYear//Global_100:PPP/text()) * xs:double($global100PreYear//Global_100:NUM_EQUITY_PARTNERS/text())) div xs:double($global100PreYear//Global_100:GROSS_REVENUE/text())) * 100
                       let $leverage := if($amLaw200//AMLAW_200:LEVERAGE/text() != '') then $amLaw200//AMLAW_200:LEVERAGE/text()
                                            else (xs:double($amLaw200//AMLAW_200:NUM_LAWYERS/text()) - xs:double($amLaw200//AMLAW_200:NUM_EQUITY_PARTNERS/text())) div xs:double($amLaw200//AMLAW_200:NUM_EQUITY_PARTNERS/text())
                       let $minorityPercentage := $diversitySC//Diversity_Scorecard:MINORITY_PERCENTAGE/text()
                       let $femaleAttorneys :=$femaleSC//FEMALE_SCORECARD:PCT_FEMALE_ATTORNEYS/text()
                       let $lgbtAttorneys := $nlj_lgbt//nljlgbt:PERCENT_LGBT_ATTORNEYS/text()   
                       
                       (:-------------------- Data for Non Primary Firms -----------------------:)                     
                       let $amLaw200NonPrimary :=  cts:search(/,
                           cts:and-query((
                           cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                           cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),fn:tokenize($firmID,',')),
                           cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($maxYear))
                           )))
                       
                      let $amLaw200PreYearNonPrimary :=  cts:search(/,
                                                     cts:and-query((
                                                         cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/"),
                                                         cts:element-value-query(xs:QName('AMLAW_200:ORGANIZATION_ID'),fn:tokenize($firmID,',')),
                                                         cts:element-value-query(xs:QName('AMLAW_200:PUBLISHYEAR'),xs:string($maxYear - 1))
                                                         )))

                      let $nlj250NonPrimary := cts:search(/,
                                          cts:and-query((
                                            cts:directory-query("/LegalCompass/relational-data/surveys/NLJ_250/"),
                                            cts:element-value-query(xs:QName('nlj250:ORGANIZATION_ID'),fn:tokenize($firmID,',')),
                                            cts:element-value-query(xs:QName('nlj250:PUBLISHYEAR'),xs:string($maxYear))
                                            )))
                                                 
                      let $nlj_lgbtNonPrimary := cts:search(/,
                                            cts:and-query((
                                                cts:directory-query("/LegalCompass/relational-data/surveys/NLJ_LGBT/"),
                                                cts:element-value-query(xs:QName('nljlgbt:ORGANIZATION_ID'),fn:tokenize($firmID,',')),
                                                cts:element-value-query(xs:QName('nljlgbt:PUBLISHYEAR'),xs:string($maxYear))
                                                )))                           

                      let $femaleSCNonPrimary := cts:search(/,
                                            cts:and-query((
                                                cts:directory-query("/LegalCompass/relational-data/surveys/FEMALE_SCORECARD/"),
                                                cts:element-value-query(xs:QName('FEMALE_SCORECARD:ORGANIZATION_ID'),fn:tokenize($firmID,',')),
                                                cts:element-value-query(xs:QName('FEMALE_SCORECARD:PUBLISHYEAR'),xs:string($maxYear))
                                                )))              


                      let $diversitySCNonPrimary := cts:search(/,
                                              cts:and-query((
                                                  cts:directory-query("/LegalCompass/relational-data/surveys/Diversity_Scorecard/"),
                                                  cts:element-value-query(xs:QName('Diversity_Scorecard:ORGANIZATION_ID'),fn:tokenize($firmID,',')),
                                                  cts:element-value-query(xs:QName('Diversity_Scorecard:PUBLISHYEAR'),xs:string($maxYear))
                                                  )))           


                     let $global100NonPrimary := cts:search(/,
                                                cts:and-query((
                                                cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
                                                cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),fn:tokenize($firmID,',')),
                                                cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($maxYear)))))

                     let $global100PreYearNonPrimary := cts:search(/,
                                                  cts:and-query((
                                                    cts:directory-query("/LegalCompass/relational-data/surveys/Global_100/"),
                                                    cts:element-value-query(xs:QName('Global_100:ORGANIZATION_ID'),fn:tokenize($firmID,',')),
                                                    cts:element-value-query(xs:QName('Global_100:PUBLISHYEAR'),xs:string($maxYear - 1)))))
                       
                       
                      let $grossRevenueNonPrimary := if($amLaw200NonPrimary//AMLAW_200:GROSS_REVENUE/text() != '') then math:median(($amLaw200NonPrimary//AMLAW_200:GROSS_REVENUE/text()))
                                            else math:median(($global100NonPrimary//Global_100:GROSS_REVENUE/text()))
                       
                       let $grossRevenuePreYearNonPrimary := if($amLaw200PreYearNonPrimary//AMLAW_200:GROSS_REVENUE/text() != '') then math:median(($amLaw200PreYearNonPrimary//AMLAW_200:GROSS_REVENUE/text()))
                                            else math:median(($global100PreYearNonPrimary//Global_100:GROSS_REVENUE/text()))
                       let $growthFirmValueNonPrimary := ((xs:double($grossRevenueNonPrimary) - xs:double($grossRevenuePreYearNonPrimary)) div xs:double($grossRevenuePreYearNonPrimary)) * 100
                       let $rplNonPrimary := if($amLaw200NonPrimary//AMLAW_200:RPL/text() != '') then math:median(($amLaw200NonPrimary//AMLAW_200:RPL/text()))
                                            else math:median(($global100NonPrimary//Global_100:REVENUE_PER_LAWYER/text()))
                       let $pppNonPrimary := if($amLaw200//AMLAW_200:PPP/text() != '') then math:median(($amLaw200NonPrimary//AMLAW_200:PPP/text()))
                                            else math:median(($global100NonPrimary//Global_100:PPP/text()))
                       let $eqpNonPrimary := (math:median(($amLaw200NonPrimary//AMLAW_200:NUM_EQ_PARTNERS/text())) div math:median(($amLaw200NonPrimary//AMLAW_200:TOTAL_PARTNERS/text()))) * 100
                       let $cplNonPrimary := (math:median(($amLaw200NonPrimary//AMLAW_200:GROSS_REVENUE/text())) - math:median(($amLaw200NonPrimary//AMLAW_200:NET_OPERATING_INCOME/text()))) div math:median(($amLaw200NonPrimary//AMLAW_200:NUM_OF_LAWYERS/text()))
                       let $profitMarginNonPrimary := if($amLaw200NonPrimary//AMLAW_200:PROFIT_MARGIN/text() != '') then math:median(($amLaw200NonPrimary//AMLAW_200:PROFIT_MARGIN/text()))
                                            else ((math:median(($global100NonPrimary//Global_100:PPP/text())) * math:median(($global100NonPrimary//Global_100:NUM_EQUITY_PARTNERS/text()))) div math:median(($global100NonPrimary//Global_100:GROSS_REVENUE/text()))) * 100
                       let $profitMarginPreYearNonPrimary := if($amLaw200PreYearNonPrimary//AMLAW_200:PROFIT_MARGIN/text() != '') then math:median(($amLaw200PreYearNonPrimary//AMLAW_200:PROFIT_MARGIN/text()))
                                            else ((math:median(($global100PreYearNonPrimary//Global_100:PPP/text())) * math:median(($global100PreYearNonPrimary//Global_100:NUM_EQUITY_PARTNERS/text()))) div math:median(($global100PreYearNonPrimary//Global_100:GROSS_REVENUE/text()))) * 100
                       let $leverageNonPrimary := if($amLaw200NonPrimary//AMLAW_200:LEVERAGE/text() != '') then math:median(($amLaw200NonPrimary//AMLAW_200:LEVERAGE/text()))
                                            else (math:median(($amLaw200NonPrimary//AMLAW_200:NUM_LAWYERS/text())) - math:median(($amLaw200NonPrimary//AMLAW_200:NUM_EQUITY_PARTNERS/text()))) div math:median(($amLaw200NonPrimary//AMLAW_200:NUM_EQUITY_PARTNERS/text()))
                       let $minorityPercentageNonPrimary := math:median(($diversitySCNonPrimary//Diversity_Scorecard:MINORITY_PERCENTAGE/text()))
                       let $femaleAttorneysNonPrimary :=math:median(($femaleSCNonPrimary//FEMALE_SCORECARD:PCT_FEMALE_ATTORNEYS/text()))
                       let $lgbtAttorneysNonPrimary := if($nlj_lgbtNonPrimary//nljlgbt:PERCENT_LGBT_ATTORNEYS/text() != '') then math:median(($nlj_lgbtNonPrimary//nljlgbt:PERCENT_LGBT_ATTORNEYS/text())) else 0
                       let $diffGrothValue := xs:double($growthFirmValue) - xs:double($growthFirmValueNonPrimary)
                       let $diffRpl := (xs:double($rpl) - xs:double($rplNonPrimary)) div 1000000
                       let $diffCpl := (xs:double($cpl) - xs:double($cplNonPrimary)) div 1000000
                       let $diffProfitMargin := xs:double($profitMargin) - xs:double($profitMarginNonPrimary)
                       let $diffLgbtAttorneys := if($lgbtAttorneys ne '' and $lgbtAttorneysNonPrimary ne 0) then (xs:double($lgbtAttorneys) - xs:double($lgbtAttorneysNonPrimary)) * 100 else 0 (:(xs:double($lgbtAttorneys) - xs:double($lgbtAttorneysNonPrimary)) * 100:)
                       let $diffLeverage := xs:double($leverage) - xs:double($leverageNonPrimary)
                       let $diffFemaleAttorneys := (xs:double($femaleAttorneys) - xs:double($femaleAttorneysNonPrimary)) * 100
                       let $diffMinorityAttorneys := (xs:double($minorityPercentage) - xs:double($minorityPercentageNonPrimary)) * 100
                       let $profitPartner := xs:double($ppp) div 1000000
                       let $percentEquityPartner := $eqp
                       let $medianProfitPerPartner := xs:double($pppNonPrimary) div 1000000
                       let $medianPercentEquityPartner := $eqpNonPrimary
                       let $diffProfitPartner := (xs:double($ppp) - xs:double($pppNonPrimary)) div 1000000
                       let $diffpercentEquityPartner := xs:double($eqp) - xs:double($eqpNonPrimary)
                       
                       
                      
								  
					   let $_ := (map:put($res-obj,'OrganizationID',xs:integer($item//organizations:ORGANIZATION_ID/text())),
                                  map:put($res-obj,'OrganizationName',$item//organizations:ORGANIZATION_NAME/text()),
                                  map:put($res-obj,'publishyear',$maxYear),
                                  map:put($res-obj,'GrowthFirmValue',xs:decimal(fn:format-number($growthFirmValue,".00"))),
                                  map:put($res-obj,'RevenuePerLawyer',fn:round-half-to-even((xs:double($rpl) div 1000000) ,2)),
                                  map:put($res-obj,'CostPerLawyer',fn:format-number(xs:double($cpl) div 1000000,".00")),
                                  map:put($res-obj,'ProfitMargin',fn:format-number($profitMargin,".00")),
                                  map:put($res-obj,'Leverage',fn:format-number($leverage,".0")),
                                  map:put($res-obj,'LGBTAttorneys',if($lgbtAttorneys ne '') then fn:format-number(xs:double($lgbtAttorneys) * 100,".00") else 0),
                                  map:put($res-obj,'FemaleAttorneys',fn:format-number(xs:double($femaleAttorneys) * 100,".00")),
                                  map:put($res-obj,'MinorityAttorneys',fn:format-number(xs:double($minorityPercentage) * 100 ,".00")),
                                  map:put($res-obj,'MedianGrowth',fn:format-number($growthFirmValueNonPrimary,".00")),
                                  map:put($res-obj,'MedianLGBTAttorneys',fn:format-number($lgbtAttorneysNonPrimary * 100,".00")),
                                  map:put($res-obj,'MedianFemaleAttorneys',fn:format-number($femaleAttorneysNonPrimary * 100,".0")),
                                  map:put($res-obj,'MedianMinorityAttorneys',fn:format-number($minorityPercentageNonPrimary * 100,".00")),
                                  map:put($res-obj,'MedianRPL',fn:format-number($rplNonPrimary div 1000000,".00")),
                                  map:put($res-obj,'MedianCPL',fn:format-number($cplNonPrimary div 1000000 ,".00")),
                                  map:put($res-obj,'MedianProfitMargin',fn:format-number($profitMarginNonPrimary,".00")),
                                  map:put($res-obj,'MedianLeverage',fn:format-number($leverageNonPrimary,".00")), 
                                  map:put($res-obj,'DiffGrowthValue',fn:format-number($diffGrothValue,".00")),
                                  map:put($res-obj,'DiffRPL',fn:format-number($diffRpl,".00")),
                                  map:put($res-obj,'DiffCPL',fn:format-number($diffCpl,".00")),
                                  map:put($res-obj,'DiffProfitMargin',fn:format-number($diffProfitMargin,".00")),
                                  map:put($res-obj,'DiffLGBTAttorneys',if($diffLgbtAttorneys != 0) then fn:format-number($diffLgbtAttorneys,".00") else ''),
                                  map:put($res-obj,'DiffLeverage',fn:format-number($diffLeverage,".00")),
                                  map:put($res-obj,'DiffFemaleAttorneys',fn:format-number($diffFemaleAttorneys,".0")),
                                  map:put($res-obj,'DiffMinorityAttorneys',fn:format-number($diffMinorityAttorneys,".00")),
                                  map:put($res-obj,'ProfitPerPartner',fn:format-number($profitPartner,".0")),
                                  map:put($res-obj,'PercentageEquityPartner',fn:format-number($percentEquityPartner,'.0')),
                                  map:put($res-obj,'MedianProfitPerPartner',fn:format-number($medianProfitPerPartner,".00")),
                                  map:put($res-obj,'MedianPercentageEquityPartner',fn:format-number($medianPercentEquityPartner,".00")),
                                  map:put($res-obj,'DiffProfitPerPartner',fn:format-number($diffProfitPartner,".00")),
                                  map:put($res-obj,'DiffPercentageEquityPartner',fn:format-number($diffpercentEquityPartner,".00"))
                                  )			  
                                  
                                 
                                
                 return()                      
   return $res-obj
  
};