 xquery version "1.0-ml";

module namespace sy = "http://alm.com/Survey";

import module namespace config = "http://alm.com/config" at "/common/config.xqy";
import module namespace search = "http://marklogic.com/appservices/search" at "/MarkLogic/appservices/search/search.xqy";

declare namespace util = "http://alm.com/util";
declare namespace lcs = "http://alm.com/LegalCompass/survey";
declare namespace survey-listing-ns = "http://alm.com/LegalCompass/rd/survey-listing";
declare namespace survey-listing-dd-ns = "http://alm.com/LegalCompass/dd/survey-listing";
declare namespace survey = "http://alm.com/LegalCompass/dd/survey";
declare namespace topic-dd-ns = "http://alm.com/LegalCompass/dd/Topics";
declare namespace DVis-dd-ns = "http://alm.com/LegalCompass/dd/DATAVISUALIZATION";
declare namespace productqualification-rd-ns = "http://alm.com/LegalCompass/rd/productqualification";
declare namespace ppq = "http://alm.com/LegalCompass/rd/PromotionProductQualification";
declare namespace surveydetails-rd-ns = "http://alm.com/LegalCompass/rd/surveydetails";
declare namespace organization ="http://alm.com/LegalCompass/dd/organization";
declare namespace pq = "http://alm.com/LegalCompass/rd/productqualification";
declare namespace topics = "http://alm.com/LegalCompass/dd/Topics";
declare namespace surveydetails = "http://alm.com/LegalCompass/rd/surveydetails";
declare namespace AMLAW_200  = "http://alm.com/LegalCompass/rd/AMLAW_200";
declare namespace organization_rd ="http://alm.com/LegalCompass/rd/organization";
declare namespace AMLAW_100  = "http://alm.com/LegalCompass/rd/AMLAW_100";
declare namespace NLJ_250 = "http://alm.com/LegalCompass/rd/NLJ_250";
declare namespace DATAVISUALIZATION_New = 'http://alm.com/LegalCompass/rd/DATAVISUALIZATION_New';


declare option xdmp:mapping "false";
(:
declare variable $survey-listing-dd-dir as xs:string := "/LegalCompass/denormalized-data/survey-listing/";
declare variable $survey-dd-dir  as xs:string := "/LegalCompass/denormalized-data/surveys/";
$config:RD-ORGANIZATION_BRANCH-COLLECTION

declare variable $survey-listing-dd-dir as xs:string := $config:DD-SURVEY-LISTING-PATH;
declare variable $survey-dd-dir  as xs:string := $config:DD-SURVEY-PATH";
:)

declare function sy:GetYears(
	$surveyId
)
{
	let $context := map:map()
	let $_ := map:put($context, "output-types","application/json")
	let $surveyyear-arr := json:array()	

	let $search-result := fn:distinct-values(cts:search(/,
									cts:and-query((
									cts:directory-query($config:DD-SURVEY-LISTING-PATH),									
									cts:element-value-query(xs:QName("survey-listing-dd-ns:SURVEYLISTINGID"),$surveyId, "exact")
									))
									)//survey-listing-dd-ns:SurveyListingFile//survey-listing-dd-ns:FISCAL_YEAR)

	let $search-result := for $sr in $search-result
							order by xs:integer($sr) descending
							return $sr

	let $_ := for $entry in $search-result
	let $surveyyear-obj := json:object()
	let $_ := (
			map:put($surveyyear-obj, "FiscalYear", $entry),
			map:put($surveyyear-obj, "PublishYear", $entry)
		)		
		let $_ := json:array-push($surveyyear-arr, $surveyyear-obj)		
		return ()

	return $surveyyear-arr
};

declare function sy:GetSurveyDataByYear(
$SurveyID,
$PublishYear
)
{
	let $context := map:map()
	let $_ := map:put($context, "output-types","application/json")
	let $surveydata-arr := json:array()
	let $SurveyListingFile-arr := json:array()	

	let $search-result := cts:search(/,
									cts:and-query((
									cts:directory-query($config:DD-SURVEY-LISTING-PATH,'1'),									
									cts:element-value-query(xs:QName("survey-listing-dd-ns:SURVEYLISTINGID"),$SurveyID/text(), "exact")
									))
									)

	let $years-arr := sy:GetYears($SurveyID/text())

	let $SurveyListingFile-result := $search-result//survey-listing-dd-ns:SurveyListingFiles/survey-listing-dd-ns:SurveyListingFile[survey-listing-dd-ns:FISCAL_YEAR eq $PublishYear/text()]

		let $_ := for $entry in $SurveyListingFile-result
		let $SurveyListingFile-obj := json:object()
		let $_ := (
			map:put($SurveyListingFile-obj,"SURVEYLISTINGFILEID", xs:integer($entry//survey-listing-dd-ns:SURVEYLISTINGFILEID/text())),
			map:put($SurveyListingFile-obj,"SURVEYLISTINGID", xs:integer($SurveyID/text())),
			map:put($SurveyListingFile-obj,"SURVEYNAME", $entry//survey-listing-dd-ns:SURVEYNAME/text()),
			(:map:put($SurveyListingFile-obj,"SURVEYFILENAME", fn:concat("http://stage.almlegalintel.com/SurveyFiles/\",$entry//survey-listing-dd-ns:SURVEYFILENAME/text())),:)
			map:put($SurveyListingFile-obj,"SURVEYFILENAME", fn:concat("http://lrservices.almlegalintel.com/SurveyFiles/",$entry//survey-listing-dd-ns:SURVEYFILENAME/text())),
			(: map:put($SurveyListingFile-obj,"SURVEYFILENAME", fn:concat("http://stage.lrservices.almlegalintel.com/SurveyFiles/",$entry//survey-listing-dd-ns:SURVEYFILENAME/text())), :)
			map:put($SurveyListingFile-obj,"FORMAT", $entry//survey-listing-dd-ns:FORMAT/text()),
			map:put($SurveyListingFile-obj,"FISCALYEAR", $entry//survey-listing-dd-ns:FISCAL_YEAR/text()),
			map:put($SurveyListingFile-obj,"IsFileAvailable", 0)
		)		
		let $_ := json:array-push($SurveyListingFile-arr, $SurveyListingFile-obj)		
		return ()

	(:SurveyRanking Data Part:)
	let $surveyranking-arr := json:array()	
	let $tableName := if($search-result//survey-listing-dd-ns:TABLENAME/text() ne "Who_Counsels_who" and $search-result//survey-listing-dd-ns:TABLENAME/text() ne "LAWFIRM_MERGERS" and $search-result//survey-listing-dd-ns:TABLENAME/text() ne "Lateral_Partner" and $search-result//survey-listing-dd-ns:TABLENAME/text() ne "Billing_Survey_Florida" and $search-result//survey-listing-dd-ns:TABLENAME/text() ne "DC20" and $search-result//survey-listing-dd-ns:TABLENAME/text() ne "NLJ_Staffing")then
						$search-result//survey-listing-dd-ns:TABLENAME/text()
						else ""
	let $survey-directory := fn:concat("/LegalCompass/denormalized-data/surveys/",$tableName,"/")
	let $SurveyRankings-Data :=  if($tableName ne "")then 
	
								let $ranking-results := cts:search(/,
                                  cts:and-query((
                                  cts:directory-query($survey-directory,"1"),
                                  (:cts:element-value-query(xs:QName("survey:FISCAL_YEAR"),$PublishYear/text()):)
								  cts:element-attribute-value-query(xs:QName("survey:YEAR"),xs:QName("PublishYear"),$PublishYear/text())
								  )
                                  ))
								  
								let $result := for $res in $ranking-results
              let $surveyranking-obj := json:object()
              (:let $OrganizationID := $res//SURVEY/@OrganizationID/string()
              let $OrganizationName := doc(fn:concat("/LegalCompass/denormalized-data/organization/",$OrganizationID,".xml"))//organization:ORGANIZATION_NAME/text():)
              (: let $Ranking := $res//survey:YEAR[survey:FISCAL_YEAR  eq $PublishYear/text()] :)
			  let $Ranking := $res//survey:YEAR[@PublishYear  eq $PublishYear/text()]
			  let $Ranking := $Ranking[1]
			  
			   let $_RANK := doc("/LegalCompass/denormalized-data/SURVEYRANKINGTABLE.xml")//SURVEYRANKINGTABLE[TABLENAME eq $tableName and ENTITYNAME eq "Rank"]//COLUMNNAME/text()
              let $_Column1 := doc("/LegalCompass/denormalized-data/SURVEYRANKINGTABLE.xml")//SURVEYRANKINGTABLE[TABLENAME eq $tableName and ENTITYNAME eq "Column1"]//COLUMNNAME/text()
              let $_Column2 := doc("/LegalCompass/denormalized-data/SURVEYRANKINGTABLE.xml")//SURVEYRANKINGTABLE[TABLENAME eq $tableName and ENTITYNAME eq "Column2"]//COLUMNNAME/text()
			  
			  let $_Column3 := 
			  if( fn:exists(doc("/LegalCompass/denormalized-data/SURVEYRANKINGTABLE.xml")//SURVEYRANKINGTABLE[TABLENAME eq $tableName and ENTITYNAME eq "Column3"]//COLUMNNAME/text()))
				then doc("/LegalCompass/denormalized-data/SURVEYRANKINGTABLE.xml")//SURVEYRANKINGTABLE[TABLENAME eq $tableName and ENTITYNAME eq "Column3"]//COLUMNNAME/text()
				else ()
			  let $_Column4 :=
			if( fn:exists(doc("/LegalCompass/denormalized-data/SURVEYRANKINGTABLE.xml")//SURVEYRANKINGTABLE[TABLENAME eq $tableName and ENTITYNAME eq "Column4"]//COLUMNNAME/text()))
							then doc("/LegalCompass/denormalized-data/SURVEYRANKINGTABLE.xml")//SURVEYRANKINGTABLE[TABLENAME eq $tableName and ENTITYNAME eq "Column4"]//COLUMNNAME/text()
							else ()
			let $_Column5 := if( fn:exists(doc("/LegalCompass/denormalized-data/SURVEYRANKINGTABLE.xml")//SURVEYRANKINGTABLE[TABLENAME eq $tableName and ENTITYNAME eq "Column5"]//COLUMNNAME/text()))
							then doc("/LegalCompass/denormalized-data/SURVEYRANKINGTABLE.xml")//SURVEYRANKINGTABLE[TABLENAME eq $tableName and ENTITYNAME eq "Column5"]//COLUMNNAME/text()
							else ()
			let $_Column6 := 
			if( fn:exists(doc("/LegalCompass/denormalized-data/SURVEYRANKINGTABLE.xml")//SURVEYRANKINGTABLE[TABLENAME eq $tableName and ENTITYNAME eq "Column6"]//COLUMNNAME/text()))
							then doc("/LegalCompass/denormalized-data/SURVEYRANKINGTABLE.xml")//SURVEYRANKINGTABLE[TABLENAME eq $tableName and ENTITYNAME eq "Column6"]//COLUMNNAME/text()
							else ()
			let $_Column7 := 
			if( fn:exists(doc("/LegalCompass/denormalized-data/SURVEYRANKINGTABLE.xml")//SURVEYRANKINGTABLE[TABLENAME eq $tableName and ENTITYNAME eq "Column7"]//COLUMNNAME/text()))
							then doc("/LegalCompass/denormalized-data/SURVEYRANKINGTABLE.xml")//SURVEYRANKINGTABLE[TABLENAME eq $tableName and ENTITYNAME eq "Column7"]//COLUMNNAME/text()
							else ()
			let $_Column8 := 
			if( fn:exists(doc("/LegalCompass/denormalized-data/SURVEYRANKINGTABLE.xml")//SURVEYRANKINGTABLE[TABLENAME eq $tableName and ENTITYNAME eq "Column8"]//COLUMNNAME/text()))
							then doc("/LegalCompass/denormalized-data/SURVEYRANKINGTABLE.xml")//SURVEYRANKINGTABLE[TABLENAME eq $tableName and ENTITYNAME eq "Column8"]//COLUMNNAME/text()
							else ()
			let $_Column9 := if( fn:exists(doc("/LegalCompass/denormalized-data/SURVEYRANKINGTABLE.xml")//SURVEYRANKINGTABLE[TABLENAME eq $tableName and ENTITYNAME eq "Column9"]//COLUMNNAME/text()))
							then doc("/LegalCompass/denormalized-data/SURVEYRANKINGTABLE.xml")//SURVEYRANKINGTABLE[TABLENAME eq $tableName and ENTITYNAME eq "Column9"]//COLUMNNAME/text()
							else ()
			let $_Column10 := 
			if( fn:exists(doc("/LegalCompass/denormalized-data/SURVEYRANKINGTABLE.xml")//SURVEYRANKINGTABLE[TABLENAME eq $tableName and ENTITYNAME eq "Column10"]//COLUMNNAME/text()))
							then doc("/LegalCompass/denormalized-data/SURVEYRANKINGTABLE.xml")//SURVEYRANKINGTABLE[TABLENAME eq $tableName and ENTITYNAME eq "Column10"]//COLUMNNAME/text()
							else ()
							
            let $_Column1_Value := 	if ($tableName eq "Diversity_Scorecard" or $tableName eq "NLJ_LGBT" or $tableName eq "FEMALE_SCORECARD")
									then cts:search(//survey:YEAR,
													cts:and-query((
													cts:directory-query("/LegalCompass/denormalized-data/surveys/AMLAW_200/","1"),
													(:cts:element-value-query(xs:QName("survey:FISCAL_YEAR"),$PublishYear/text()):)
																	cts:element-attribute-value-query(xs:QName("survey:YEAR"),xs:QName("PublishYear"), $PublishYear/text()),
													cts:element-attribute-value-query(xs:QName("survey:YEAR"),xs:QName("OrganizationID"), $Ranking/@OrganizationID/string())
													)))//survey:AMLAW200_RANK/text()
									else if(fn:exists($_Column1))
									then $Ranking/xdmp:value(fn:concat("survey:",$_Column1))/text()
									else ""
			(:let $_Column2_Value := if(fn:exists($_Column2))
									then $Ranking/xdmp:value(fn:concat("survey:",$_Column2))/text()
									else "" :)
			
			let $_Column2_Value := if ($tableName eq "Diversity_Scorecard" or $tableName eq "NLJ_LGBT" or $tableName eq "FEMALE_SCORECARD")
									then cts:search(//survey:YEAR,
													cts:and-query((
													cts:directory-query("/LegalCompass/denormalized-data/surveys/AMLAW_200/","1"),
													(:cts:element-value-query(xs:QName("survey:FISCAL_YEAR"),$PublishYear/text()):)
																	cts:element-attribute-value-query(xs:QName("survey:YEAR"),xs:QName("PublishYear"), $PublishYear/text()),
													cts:element-attribute-value-query(xs:QName("survey:YEAR"),xs:QName("OrganizationID"), $Ranking/@OrganizationID/string())
													)))//survey:AMLAW200_RANK/text()
									else if(fn:exists($_Column2))
									then $Ranking/xdmp:value(fn:concat("survey:",$_Column2))/text()
									else ""
				
									
			let $_Column3_Value := if(fn:exists($_Column3))
									then $Ranking/xdmp:value(fn:concat("survey:",$_Column3))/text()
									else "" 
			let $_Column4_Value := if ($tableName eq "Diversity_Scorecard")
									then ($Ranking/survey:MINORITY_PERCENTAGE/text() * 100)
									else if(fn:exists($_Column4))
									then $Ranking/xdmp:value(fn:concat("survey:",$_Column4))/text()
									else ""
			let $_Column5_Value := if ($tableName eq "Diversity_Scorecard")
									then $Ranking/survey:ASIAN_AMERICAN_PARTNERS/text() + $Ranking/survey:ASIAN_AMERICAN_ASSOCIATES/text()
									else if ($tableName eq "FEMALE_SCORECARD")
									then $Ranking/survey:PCT_FEMALE_ATTORNEYS * 100
									else if ($tableName eq "NLJ_LGBT")
									then $Ranking/survey:PERCENT_LGBT_ATTORNEYS * 100
									else if(fn:exists($_Column5))
												then $Ranking/xdmp:value(fn:concat("survey:",$_Column5))/text()
												else ""       
			let $_Column6_Value := if ($tableName eq "Diversity_Scorecard")
									then $Ranking/survey:AFRICAN_AMERICAN_PARTNERS/text() + $Ranking/survey:AFRICAN_AMERICAN_ASSOCIATES/text()
									else if(fn:exists($_Column6))
												then $Ranking/xdmp:value(fn:concat("survey:",$_Column6))/text()
												else ""           
			let $_Column7_Value := if ($tableName eq "Diversity_Scorecard")
									then $Ranking/survey:HISPANIC_ASSOCIATES/text() + $Ranking/survey:HISPANIC_PARTNERS/text()
									else if ($tableName eq "FEMALE_SCORECARD")
									then $Ranking/survey:PCT_FEMALE_PARTNERS * 100
									else if(fn:exists($_Column7))
												then $Ranking/xdmp:value(fn:concat("survey:",$_Column7))/text()
												else ""           
			let $_Column8_Value :=  if ($tableName eq "Diversity_Scorecard")
									then $Ranking/survey:OTHER_PARTNERS/text() + $Ranking/survey:OTHER_NONPARTNERS/text()
									else if(fn:exists($_Column8))
												then $Ranking/xdmp:value(fn:concat("survey:",$_Column8))/text()
												else ""           
			let $_Column9_Value := if ($tableName eq "FEMALE_SCORECARD")
									then $Ranking/survey:PCT_FEMALE_EQUITY_PARTNERS/text()*100
									else if(fn:exists($_Column9))
												then $Ranking/xdmp:value(fn:concat("survey:",$_Column9))/text()
												else ""                             
			let $_Column10_Value := if(fn:exists($_Column10))
												then $Ranking/xdmp:value(fn:concat("survey:",$_Column10))/text()
												else ""   									
			(:let $_Column1_Value := if ($tableName eq "Diversity_Scorecard" or $tableName eq "NLJ_LGBT" or $tableName eq "FEMALE_SCORECARD")
									then cts:search(//survey:YEAR,
													cts:and-query((
													cts:directory-query("/LegalCompass/denormalized-data/surveys/AMLAW_200/","1"),
													(:cts:element-value-query(xs:QName("survey:FISCAL_YEAR"),$PublishYear/text()):)
																	cts:element-attribute-value-query(xs:QName("survey:YEAR"),xs:QName("PublishYear"), $PublishYear/text()),
													cts:element-attribute-value-query(xs:QName("survey:YEAR"),xs:QName("OrganizationID"), $Ranking/@OrganizationID/string())
													)))//survey:AMLAW200_RANK/text()
									else $_Column1_Value	:)			
			let $_NAME := doc("/LegalCompass/denormalized-data/SURVEYRANKINGTABLE.xml")//SURVEYRANKINGTABLE[TABLENAME eq $tableName and ENTITYNAME eq "Name"]//COLUMNNAME/text()
			let $NAME := if($tableName eq 'AMLAW_200' or $tableName eq 'NY100')
			then $Ranking/xdmp:value(fn:concat("survey:",fn:upper-case($_NAME)))/text()
			else if($Ranking/xdmp:value(fn:concat("survey:",$_NAME))/text() ne "")then
							$Ranking/xdmp:value(fn:concat("survey:",$_NAME))/text()
							else "" 
            let $RANK := if($Ranking/xdmp:value(fn:concat("survey:",$_RANK))/text() ne "")then
							$Ranking/xdmp:value(fn:concat("survey:",$_RANK))/text()
							else "0"
             
              let $_ := (
                        (:map:put($surveyranking-obj, "Name", $Ranking/@OrganizationName/string()),:)
						map:put($surveyranking-obj, "Name", $NAME),
			            map:put($surveyranking-obj, "Rank", xs:integer($RANK) ),
                        map:put($surveyranking-obj, "Column1", $_Column1_Value),
                        map:put($surveyranking-obj, "Column2", $_Column2_Value),
                        map:put($surveyranking-obj, "Column3", $_Column3_Value),
                        map:put($surveyranking-obj, "Column4", $_Column4_Value),
                        map:put($surveyranking-obj, "Column5", $_Column5_Value),
                        map:put($surveyranking-obj, "Column6", $_Column6_Value),
                        map:put($surveyranking-obj, "Column7", $_Column7_Value),
                        map:put($surveyranking-obj, "Column8", $_Column8_Value),
                        map:put($surveyranking-obj, "Column9", $_Column9_Value),
                        map:put($surveyranking-obj, "Column10", $_Column10_Value),
                        map:put($surveyranking-obj, "Column11", ""),
                        map:put($surveyranking-obj, "Column12", ""),
                        map:put($surveyranking-obj, "Column13", ""),
                        map:put($surveyranking-obj, "DisplayName", ""),
                        map:put($surveyranking-obj, "ID", $Ranking/@OrganizationID/string()),
                        map:put($surveyranking-obj, "CreatedBy", ""),
                        map:put($surveyranking-obj, "CreatedDate", ""),
                        map:put($surveyranking-obj, "ModifiedBy", ""),
                        map:put($surveyranking-obj, "ModifiedDate", ""),
                        map:put($surveyranking-obj, "Active", xs:integer("0")),
                        map:put($surveyranking-obj, "UserEmail", "")			                  
		                    )	
						let $_ := json:array-push($surveyranking-arr, $surveyranking-obj)
						return ()
					return ()
								
				else()
				
    let $productqualification := cts:search(/,cts:and-query((
                          cts:directory-query(("/LegalCompass/relational-data/productqualification/"),"1")
                          ,cts:element-value-query(xs:QName('productqualification-rd-ns:PRODUCTID'),$SurveyID, "exact"),
                          cts:element-value-query(xs:QName('productqualification-rd-ns:QUALIFICATIONVALUE'),$PublishYear, "exact")
                          )))  
	let $surveydetails := cts:search(/,cts:and-query((
                          cts:directory-query(("/LegalCompass/relational-data/surveydetails/"),"1")
                          ,cts:element-value-query(xs:QName('surveydetails-rd-ns:SURVEYID'),"46", "exact"),
                          cts:element-value-query(xs:QName('surveydetails-rd-ns:PUBLISHYEAR'),"2017", "exact")
                          ))) 
	
	let $Data := for $entry in $search-result
	let $Category := fn:string-join(cts:search(/,
		cts:and-query((
		cts:element-value-query(xs:QName("topic-dd-ns:SURVEYLISTINGID"),$entry//survey-listing-dd-ns:SURVEYLISTINGID/text())
	)))//topic-dd-ns:TOPIC_NAME/text()," /</br>")
	
	let $samplePath := if(fn:exists($entry//survey-listing-dd-ns:SAMPLE/text()))then 
						(: fn:concat("http://stage.lrservices.almlegalintel.com/Samples/\",$entry//survey-listing-dd-ns:SAMPLE/text()) :)
						fn:concat("http://lrservices.almlegalintel.com/Samples/\",$entry//survey-listing-dd-ns:SAMPLE/text()) 
						else ()
	let $LOGO := cts:search(/,
		cts:and-query((
		cts:element-value-query(xs:QName("surveydetails:SURVEYID"),$SurveyID),
		cts:element-value-query(xs:QName("surveydetails:PUBLISHYEAR"),$PublishYear)
		)))//surveydetails:LOGO/text()					
	let $surveydata-obj := json:object()
	let $_ := (
			map:put($surveydata-obj, "Logo",''),
			map:put($surveydata-obj, "SURVEYLISTINGID", $entry//xs:integer(survey-listing-dd-ns:SURVEYLISTINGID/text())),
			map:put($surveydata-obj, "TABLENAME", $entry//survey-listing-dd-ns:TABLENAME/text()),
			map:put($surveydata-obj, "ListPrice", 0),
			map:put($surveydata-obj, "IsPopular", $entry//xs:integer(survey-listing-dd-ns:ISPOPULAR/text())),
			map:put($surveydata-obj, "DescriptionImage", $entry//survey-listing-dd-ns:IMAGE_DESCRIPTION/text()),
			map:put($surveydata-obj, "VideoScript", $entry//survey-listing-dd-ns:LBS_VIDEO_SCRIPT/text()),
			map:put($surveydata-obj, "LandingUrl", ""),
			(:map:put($surveydata-obj, "LOGO", $entry/SURVEYLISTING/survey-listing-dd-ns:LOGO/text()),:)
			map:put($surveydata-obj, "LOGO", $LOGO),
			(:map:put($surveydata-obj, "LOGO", $surveydetails//surveydetails-rd-ns:LOGO/text()),	:)		
			map:put($surveydata-obj, "PRODUCTTYPE", xs:integer($entry//survey-listing-dd-ns:PRODUCTTYPE/text())),
			map:put($surveydata-obj, "SOURCE", $entry//survey-listing-dd-ns:SOURCE/text()),
			map:put($surveydata-obj, "CATEGORY", $Category),
			map:put($surveydata-obj, "LBSCategory",''),
			map:put($surveydata-obj, "PRICE", fn:concat('$',fn:format-number($productqualification//productqualification-rd-ns:PRODUCTPRICE/text(), "#,##0.00"))),
			map:put($surveydata-obj, "NAME", $entry//survey-listing-dd-ns:NAME/text()),
			(:map:put($surveydata-obj, "DESCRIPTION", $entry//survey-listing-dd-ns:SURVEYDESCRIPTION/text()),:)
			map:put($surveydata-obj, "DESCRIPTION", fn:replace($entry//survey-listing-dd-ns:SURVEYDESCRIPTION/text(),"''","'")),
			map:put($surveydata-obj, "OVERVIEW", $entry//survey-listing-dd-ns:SURVEYOVERVIEW/text()),
			(:map:put($surveydata-obj, "METHODOLOGY", $entry//survey-listing-dd-ns:SURVEYMETHODOLOGY/text()),:)
			map:put($surveydata-obj, "METHODOLOGY", fn:replace($entry//survey-listing-dd-ns:SURVEYMETHODOLOGY/text(),"''","'")),
			map:put($surveydata-obj, "SampleFile", $samplePath),
			map:put($surveydata-obj, "LastModified", $entry//survey-listing-dd-ns:LASTMODIFIED/text()),
			map:put($surveydata-obj, "LastModifiedDate", fn:format-date(xs:date(xdmp:parse-dateTime("[Y0001]-[M01]-[D01]",$entry//survey-listing-dd-ns:LASTMODIFIED/text())),"[M01]/[D01]/[Y0001]")),
			map:put($surveydata-obj, "SurveyYears",  $years-arr),
			map:put($surveydata-obj, "SurveyFileName", $SurveyListingFile-arr),
			map:put($surveydata-obj, "SurveyArticle", ''),
			(:map:put($surveydata-obj, "DataVisualization", sy:GetVisualizationData($SurveyID/text(),())),:)
			map:put($surveydata-obj, "DataVisualization", sy:GetVisualizationData($SurveyID/text())),
			map:put($surveydata-obj, "RelatedSurveys", ''),
			map:put($surveydata-obj, "SurveyRankings", $surveyranking-arr),
			map:put($surveydata-obj, "IsProductAvailable", ''),
			map:put($surveydata-obj, "IsSurveyFileAvailable", ''),
			map:put($surveydata-obj, "LawcatalogID", $entry//survey-listing-dd-ns:LAWCATPRODUCTID/text()),
			map:put($surveydata-obj, "LawCatalogPrice", $entry//survey-listing-dd-ns:PRICE/text()),
			map:put($surveydata-obj, "SurveyChartFileURL", $entry//survey-listing-dd-ns:SURVEYCHART/text()),
			map:put($surveydata-obj, "IsAnalystReport", xs:integer($entry//survey-listing-dd-ns:ISANALYSTREPORT/text()))
		)		
		(:let $_ := json:array-push($surveydata-arr, $surveydata-obj)	:)	
		return $surveydata-obj

	(:return sy:GetVisualizationData($SurveyID/text(),())	:)
	return $Data  
	(:return $tableName :)
	(:return sy:GetVisualizationData("1"):)
};

declare function sy:GetVisualizationData($surveyId as xs:string,$size as xs:integer?)
{
	let $DataVisualization-arr := json:array()
	let $context := map:map()
	let $_ := map:put($context, "output-types","application/json")
	
	let $topic-id :=cts:search(/,
           cts:and-query((
           cts:directory-query("/LegalCompass/denormalized-data/Topics/","1"),
           cts:element-value-query(xs:QName("topic-dd-ns:SURVEYLISTINGID"),$surveyId))
           ))//topic-dd-ns:TOPIC_ID/text()
           
	let $visualizations :=for $vi in  cts:search(/,
           cts:and-query((
           cts:directory-query("/LegalCompass/denormalized-data/DATAVISUALIZATION/","1"),
           cts:element-value-query(xs:QName("DVis-dd-ns:TOPICID"),$topic-id))
           ))
           order by xs:date($vi//DVis-dd-ns:VISUALDATEUPLOADED/text()) descending
           return $vi 
		   (:
    let $visualizations := if (fn:exists($size))then 
							for $visualization in $visualizations[1 to 3]
								return $visualization
							else	
							for $visualization in $visualizations
							return $visualization :)
	
	let $_ := for $visualization in $visualizations[1 to 5]
	let $popular := if($visualization//DVis-dd-ns:ISPOPULAR/text() ne "")
					then $visualization//DVis-dd-ns:ISPOPULAR/text()
					else "0"
	let $DataVisualization-obj := json:object()
	let $_ := (
			map:put($DataVisualization-obj, "Visualurl", $visualization//DVis-dd-ns:VISUALURL/text()),
			map:put($DataVisualization-obj, "Visualimage", $visualization//DVis-dd-ns:VISUALIMAGE/text()),
			map:put($DataVisualization-obj, "Popular", xs:integer($popular)),
			map:put($DataVisualization-obj, "Active", 0),
			map:put($DataVisualization-obj, "Visualdateuploaded", $visualization//DVis-dd-ns:VISUALDATEUPLOADED/text()),
			map:put($DataVisualization-obj, "Visualdescription", $visualization//DVis-dd-ns:VISUALDESCRIPTION/text()),
			map:put($DataVisualization-obj, "Visualname", $visualization//DVis-dd-ns:VISUALNAME/text()),
			map:put($DataVisualization-obj, "Visualid", $visualization//DVis-dd-ns:VISUALID/text())
			)
			let $_ := json:array-push($DataVisualization-arr, $DataVisualization-obj)		
			return ()
    return $DataVisualization-arr
};

declare function sy:GetVisualizationData($surveyId as xs:string)
{
	let $DataVisualization-arr := json:array()
	let $context := map:map()
	let $_ := map:put($context, "output-types","application/json")
	
	let $visualizations :=for $vi in cts:search(/,
           cts:and-query((
           cts:directory-query("/LegalCompass/relational-data/DATAVISUALIZATION_New/","1")
           ,cts:element-value-query(xs:QName("DATAVISUALIZATION_New:SURVEYLISTINGID"),$surveyId)
           ,cts:element-value-query(xs:QName("DATAVISUALIZATION_New:ISACTIVE"),'1')
           )))
           order by xs:date($vi//DATAVISUALIZATION_New:VISUALDATEUPLOADED/text()) descending
           return $vi 
  
	let $_ := for $visualization in $visualizations
  let $DataVisualization-obj := json:object()
	let $_ := (
      map:put($DataVisualization-obj, "Visualid", $visualization//DATAVISUALIZATION_New:VISUALID/text()),
      map:put($DataVisualization-obj, "Visualname", $visualization//DATAVISUALIZATION_New:VISUALNAME/text()),
      map:put($DataVisualization-obj, "Visualimage", $visualization//DATAVISUALIZATION_New:VISUALIMAGE/text()),
      map:put($DataVisualization-obj, "Visualdateuploaded", $visualization//DATAVISUALIZATION_New:VISUALDATEUPLOADED/text()),
			map:put($DataVisualization-obj, "Visualurl", $visualization//DATAVISUALIZATION_New:VISUALURL/text())
      )
			let $_ := json:array-push($DataVisualization-arr, $DataVisualization-obj)		
			return ()

return $DataVisualization-arr
};

declare function sy:GetQuickSearchResultsOnTerms(
	$term,
	$type,
	$pagename
)
{	
	let $search-data := 
	 cts:search(/,
          cts:and-query((
          cts:directory-query(("/LegalCompass/relational-data/survey-listing/"),"1"),          cts:element-word-query(xs:QName('survey-listing-ns:NAME'),fn:concat("*",$term,"*"),("wildcarded","punctuation-insensitive","case-insensitive","whitespace-insensitive"))             
          (:cts:element-value-query(xs:QName("lcs:NAME"),"*ali*",("wildcarded","punctuation-insensitive","case-insensitive","whitespace-insensitive")):)
          (:cts:element-range-query(xs:QName("lcs:NAME"), "=","ALi",("collation=http://marklogic.com/collation/en/S4/T00BB/AS"))
          :)
			)))
	
	let $context := map:map()
	let $_ := map:put($context, "output-types","application/json")
	let $GetQuickSearchResultsData-arr := json:array()
	
	let $_ := for $data in $search-data
	let $GetQuickSearchResultsData-obj := json:object()
	let $_ := (
			map:put($GetQuickSearchResultsData-obj, "id", $data//survey-listing-ns:SURVEYLISTINGID/text()),
			map:put($GetQuickSearchResultsData-obj, "label", $data//survey-listing-ns:NAME/text()),
			map:put($GetQuickSearchResultsData-obj, "category", "SURVEY"),
			map:put($GetQuickSearchResultsData-obj, "scopeID", ""),
			map:put($GetQuickSearchResultsData-obj, "firmID", $data//survey-listing-ns:SURVEYLISTINGID/text())
			)
			let $_ := json:array-push($GetQuickSearchResultsData-arr, $GetQuickSearchResultsData-obj)		
			return ()
	
	return $GetQuickSearchResultsData-arr
	(:return ($term,$type,$pagename) :)
};

declare function sy:GetRankingData(
	
	$tableName,
	$PublishYear
)
{	
let $SURVEYRANKINGTABLE_DOC := doc("/LegalCompass/denormalized-data/SURVEYRANKINGTABLE.xml")
let $SURVEYRANKINGTABLE := $SURVEYRANKINGTABLE_DOC//SURVEYRANKINGTABLE[TABLENAME eq $tableName]

let $DISPLAYNAME:= fn:string-join(for $Table in $SURVEYRANKINGTABLE
                    order by xs:integer($Table/DISPLAYORDER)
                    return $Table/DISPLAYNAME/text() , ",")
                    
let $surveyranking-arr := json:array()	
let $tableName := if($tableName ne "Who_Counsels_who" and $tableName ne "LAWFIRM_MERGERS" and $tableName ne "Lateral_Partner")then
						        $tableName
						        else ""
let $survey-directory := fn:concat("/LegalCompass/denormalized-data/surveys/",$tableName,"/")
let $SurveyRankings-Data :=  if($tableName ne "")then
                    let $ranking-results := cts:search(/,
                                                        cts:and-query((
                                                        cts:directory-query($survey-directory,"1"),
                                                        cts:element-attribute-value-query(xs:QName("survey:YEAR"),xs:QName("PublishYear"),$PublishYear)
								                                       )))
								    let $_RANK := $SURVEYRANKINGTABLE_DOC//SURVEYRANKINGTABLE[TABLENAME eq $tableName and ENTITYNAME eq "Rank"]//COLUMNNAME/text()
								    let $result := for $res in $ranking-results
                    let $surveyranking-obj := json:object()
                    let $Ranking := $res//survey:YEAR[@PublishYear  eq $PublishYear]
			              let $Ranking := for $a in $Ranking[1]
                                    return $a
			              
                    let $_Column1 := $SURVEYRANKINGTABLE_DOC//SURVEYRANKINGTABLE[TABLENAME eq $tableName and ENTITYNAME eq "Column1"]//COLUMNNAME/text()
                    let $_Column2 := $SURVEYRANKINGTABLE_DOC//SURVEYRANKINGTABLE[TABLENAME eq $tableName and ENTITYNAME eq "Column2"]//COLUMNNAME/text()
			  
                    let $_Column3 := 
                    if( fn:exists($SURVEYRANKINGTABLE_DOC//SURVEYRANKINGTABLE[TABLENAME eq $tableName and ENTITYNAME eq "Column3"]//COLUMNNAME/text()))
                    then $SURVEYRANKINGTABLE_DOC//SURVEYRANKINGTABLE[TABLENAME eq $tableName and ENTITYNAME eq "Column3"]//COLUMNNAME/text()
                    else ()
                    let $_Column4 :=
                    if( fn:exists($SURVEYRANKINGTABLE_DOC//SURVEYRANKINGTABLE[TABLENAME eq $tableName and ENTITYNAME eq "Column4"]//COLUMNNAME/text()))
                          then $SURVEYRANKINGTABLE_DOC//SURVEYRANKINGTABLE[TABLENAME eq $tableName and ENTITYNAME eq "Column4"]//COLUMNNAME/text()
                          else ()
                    let $_Column5 := if( fn:exists($SURVEYRANKINGTABLE_DOC//SURVEYRANKINGTABLE[TABLENAME eq $tableName and ENTITYNAME eq "Column5"]//COLUMNNAME/text()))
                          then $SURVEYRANKINGTABLE_DOC//SURVEYRANKINGTABLE[TABLENAME eq $tableName and ENTITYNAME eq "Column5"]//COLUMNNAME/text()
                          else ()
                    let $_Column6 := 
                    if( fn:exists($SURVEYRANKINGTABLE_DOC//SURVEYRANKINGTABLE[TABLENAME eq $tableName and ENTITYNAME eq "Column6"]//COLUMNNAME/text()))
                          then $SURVEYRANKINGTABLE_DOC//SURVEYRANKINGTABLE[TABLENAME eq $tableName and ENTITYNAME eq "Column6"]//COLUMNNAME/text()
                          else ()
                    let $_Column7 := 
                    if( fn:exists($SURVEYRANKINGTABLE_DOC//SURVEYRANKINGTABLE[TABLENAME eq $tableName and ENTITYNAME eq "Column7"]//COLUMNNAME/text()))
                          then $SURVEYRANKINGTABLE_DOC//SURVEYRANKINGTABLE[TABLENAME eq $tableName and ENTITYNAME eq "Column7"]//COLUMNNAME/text()
                          else ()
                    let $_Column8 := 
                    if( fn:exists($SURVEYRANKINGTABLE_DOC//SURVEYRANKINGTABLE[TABLENAME eq $tableName and ENTITYNAME eq "Column8"]//COLUMNNAME/text()))
                          then $SURVEYRANKINGTABLE_DOC//SURVEYRANKINGTABLE[TABLENAME eq $tableName and ENTITYNAME eq "Column8"]//COLUMNNAME/text()
                          else ()
                    let $_Column9 := if( fn:exists($SURVEYRANKINGTABLE_DOC//SURVEYRANKINGTABLE[TABLENAME eq $tableName and ENTITYNAME eq "Column9"]//COLUMNNAME/text()))
                          then $SURVEYRANKINGTABLE_DOC//SURVEYRANKINGTABLE[TABLENAME eq $tableName and ENTITYNAME eq "Column9"]//COLUMNNAME/text()
                          else ()
                    let $_Column10 := 
                    if( fn:exists($SURVEYRANKINGTABLE_DOC//SURVEYRANKINGTABLE[TABLENAME eq $tableName and ENTITYNAME eq "Column10"]//COLUMNNAME/text()))
                          then $SURVEYRANKINGTABLE_DOC//SURVEYRANKINGTABLE[TABLENAME eq $tableName and ENTITYNAME eq "Column10"]//COLUMNNAME/text()
                          else ()

                    let $_Column1_Value := 	if ($tableName eq "Diversity_Scorecard" or $tableName eq "NLJ_LGBT" or $tableName eq "FEMALE_SCORECARD")
                              then cts:search(//survey:YEAR,
                                      cts:and-query((
                                      cts:directory-query("/LegalCompass/denormalized-data/surveys/AMLAW_200/","1"),
                                      (:cts:element-value-query(xs:QName("survey:FISCAL_YEAR"),$PublishYear/text()):)
                                              cts:element-attribute-value-query(xs:QName("survey:YEAR"),xs:QName("PublishYear"), $PublishYear/text()),
                                      cts:element-attribute-value-query(xs:QName("survey:YEAR"),xs:QName("OrganizationID"), $Ranking/@OrganizationID/string())
                                      )))//survey:AMLAW200_RANK/text()
                              else if(fn:exists($_Column1))
                              then $Ranking/xdmp:value(fn:concat("survey:",$_Column1))/text()
                              else ""
                    (:let $_Column2_Value := "" :)
					let $_Column2_Value := if ($tableName eq "Diversity_Scorecard" or $tableName eq "NLJ_LGBT" or $tableName eq "FEMALE_SCORECARD")
									then cts:search(//survey:YEAR,
													cts:and-query((
													cts:directory-query("/LegalCompass/denormalized-data/surveys/NLJ_250/","1"),
													(:cts:element-value-query(xs:QName("survey:FISCAL_YEAR"),$PublishYear/text()):)
																	cts:element-attribute-value-query(xs:QName("survey:YEAR"),xs:QName("PublishYear"), $PublishYear/text()),
													cts:element-attribute-value-query(xs:QName("survey:YEAR"),xs:QName("OrganizationID"), $Ranking/@OrganizationID/string())
													)))//survey:NLJ250_RANK/text()
									else if(fn:exists($_Column2))
									then $Ranking/xdmp:value(fn:concat("survey:",$_Column2))/text()
									else ""				

                    let $_Column3_Value := if(fn:exists($_Column3))
                              then $Ranking/xdmp:value(fn:concat("survey:",$_Column3))/text()
                              else "" 
                    let $_Column4_Value := if ($tableName eq "Diversity_Scorecard")
                              then ($Ranking/survey:MINORITY_PERCENTAGE/text() * 100)
                              else if(fn:exists($_Column4))
                              then $Ranking/xdmp:value(fn:concat("survey:",$_Column4))/text()
                              else ""
                    let $_Column5_Value := if ($tableName eq "Diversity_Scorecard")
                              then $Ranking/survey:ASIAN_AMERICAN_PARTNERS/text() + $Ranking/survey:ASIAN_AMERICAN_ASSOCIATES/text()
                              else if ($tableName eq "FEMALE_SCORECARD")
                              then $Ranking/survey:PCT_FEMALE_ATTORNEYS * 100
                              else if ($tableName eq "NLJ_LGBT")
                              then $Ranking/survey:PERCENT_LGBT_ATTORNEYS * 100
                              else if(fn:exists($_Column5))
                                    then $Ranking/xdmp:value(fn:concat("survey:",$_Column5))/text()
                                    else ""       
                    let $_Column6_Value := if ($tableName eq "Diversity_Scorecard")
                              then $Ranking/survey:AFRICAN_AMERICAN_PARTNERS/text() + $Ranking/survey:AFRICAN_AMERICAN_ASSOCIATES/text()
                              else if(fn:exists($_Column6))
                                    then $Ranking/xdmp:value(fn:concat("survey:",$_Column6))/text()
                                    else ""           
                    let $_Column7_Value := if ($tableName eq "Diversity_Scorecard")
                              then $Ranking/survey:HISPANIC_ASSOCIATES/text() + $Ranking/survey:HISPANIC_PARTNERS/text()
                              else if ($tableName eq "FEMALE_SCORECARD")
                              then $Ranking/survey:PCT_FEMALE_PARTNERS * 100
                              else if(fn:exists($_Column7))
                                    then $Ranking/xdmp:value(fn:concat("survey:",$_Column7))/text()
                                    else ""           
                    let $_Column8_Value :=  if ($tableName eq "Diversity_Scorecard")
                              then $Ranking/survey:OTHER_PARTNERS/text() + $Ranking/survey:OTHER_NONPARTNERS/text()
                              else if(fn:exists($_Column8))
                                    then $Ranking/xdmp:value(fn:concat("survey:",$_Column8))/text()
                                    else ""           
                    let $_Column9_Value := if ($tableName eq "FEMALE_SCORECARD")
									then $Ranking/survey:PCT_FEMALE_EQUITY_PARTNERS/text()*100
									else if(fn:exists($_Column9))
												then $Ranking/xdmp:value(fn:concat("survey:",$_Column9))/text()
												else ""                                
                    let $_Column10_Value := if(fn:exists($_Column10))
                                    then $Ranking/xdmp:value(fn:concat("survey:",$_Column10))/text()
                                    else ""   									
			
                    let $RANK := if($Ranking/xdmp:value(fn:concat("survey:",$_RANK))/text() ne "")then
                                  $Ranking/xdmp:value(fn:concat("survey:",$_RANK))/text()
                                 else "0"
					let $_NAME := doc("/LegalCompass/denormalized-data/SURVEYRANKINGTABLE.xml")//SURVEYRANKINGTABLE[TABLENAME eq $tableName and ENTITYNAME eq "Name"]//COLUMNNAME/text()
					
					let $NAME := if($Ranking/xdmp:value(fn:concat("survey:",$_NAME))/text() ne "")then
								$Ranking/xdmp:value(fn:concat("survey:",$_NAME))/text()
								else $Ranking/@OrganizationName/string()
								
                            let $_ := (
                                      (:map:put($surveyranking-obj, "Name", $Ranking/@OrganizationName/string()),:)
									  map:put($surveyranking-obj, "Name", $NAME),
                                map:put($surveyranking-obj, "Rank", xs:integer($RANK) ),
                                      map:put($surveyranking-obj, "Column1", $_Column1_Value),
                                      map:put($surveyranking-obj, "Column2", $_Column2_Value),
                                      map:put($surveyranking-obj, "Column3", $_Column3_Value),
                                      map:put($surveyranking-obj, "Column4", $_Column4_Value),
                                      map:put($surveyranking-obj, "Column5", $_Column5_Value),
                                      map:put($surveyranking-obj, "Column6", $_Column6_Value),
                                      map:put($surveyranking-obj, "Column7", $_Column7_Value),
                                      map:put($surveyranking-obj, "Column8", $_Column8_Value),
                                      map:put($surveyranking-obj, "Column9", $_Column9_Value),
                                      map:put($surveyranking-obj, "Column10", $_Column10_Value),
                                      map:put($surveyranking-obj, "Column11", ""),
                                      map:put($surveyranking-obj, "Column12", ""),
                                      map:put($surveyranking-obj, "Column13", ""),
                                      map:put($surveyranking-obj, "DisplayName", ""),
                                      map:put($surveyranking-obj, "ID", $Ranking/@OrganizationID/string()),
                                      map:put($surveyranking-obj, "CreatedBy", ""),
                                      map:put($surveyranking-obj, "CreatedDate", ""),
                                      map:put($surveyranking-obj, "ModifiedBy", ""),
                                      map:put($surveyranking-obj, "ModifiedDate", ""),
                                      map:put($surveyranking-obj, "Active", xs:integer("0")),
                                      map:put($surveyranking-obj, "UserEmail", "")			                  
                                      )	
                          let $_ := json:array-push($surveyranking-arr, $surveyranking-obj)
                          return ($Ranking)
                        return ($result)
                else()
                
(:return $SurveyRankings-Data:) 
let $surveyranking-obj := json:object()
let $_ := (
            map:put($surveyranking-obj, "DisplayName", $DISPLAYNAME),
            map:put($surveyranking-obj, "ListOfSurveyRanking", $surveyranking-arr )
            )
return ($surveyranking-obj)
};

declare function sy:FilterDataBySearchTerm()
{	

let $request := xdmp:get-request-body()/request
let $companies-arr := json:array()	

let $search-result_name := cts:search(/,
          cts:and-query((
          cts:directory-query(("/LegalCompass/relational-data/survey-listing/"),"1")
		      ,cts:element-value-query(xs:QName('survey-listing-ns:ISACTIVE'),"1", "exact")
		      ,cts:element-value-query(xs:QName('survey-listing-ns:PRODUCTTYPE'),"1", "exact")          
          ,cts:element-value-query(xs:QName("survey-listing-ns:NAME"),$request/searchText/text(),("case-insensitive","whitespace-insensitive"))          
          )))
          
let $search-result := if(fn:lower-case($search-result_name//survey-listing-ns:NAME/text()) eq fn:lower-case($request/searchText/text()))
  then $search-result_name  
else
  (
  let $PRODUCTQUALIFICATIONIDs :=(fn:distinct-values(cts:search(/,
                      cts:and-query((
                      cts:directory-query("/LegalCompass/relational-data/PromotionProductQualification/"),
                      cts:element-value-query(xs:QName('ppq:PROMOID'),"246000", "exact")            
                      )))//ppq:PRODUCTQUALIFICATIONID/text()))

  let $PRODUCTIDs := fn:distinct-values(cts:search(/,
                      cts:and-query((
                      cts:directory-query("/LegalCompass/relational-data/productqualification/"),
                      cts:element-value-query(xs:QName('pq:PRODUCTQUALIFICATIONID'),$PRODUCTQUALIFICATIONIDs, "exact")            
                      )))//pq:PRODUCTID/text())
  return cts:search(/,
          cts:and-query((
          cts:directory-query(("/LegalCompass/relational-data/survey-listing/"),"1")
          ,cts:element-value-query(xs:QName('survey-listing-ns:SURVEYLISTINGID'),$PRODUCTIDs, "exact")
		      ,cts:element-value-query(xs:QName('survey-listing-ns:ISACTIVE'),"1", "exact")
          ,cts:or-query((
            cts:element-word-query(xs:QName("survey-listing-ns:NAME"),fn:concat("*",$request/searchText/text(),"*"),("wildcarded","case-insensitive","whitespace-insensitive"))
           ,cts:element-word-query(xs:QName("survey-listing-ns:SURVEYOVERVIEW"),fn:concat("*",$request/searchText/text(),"*"),("wildcarded","case-insensitive","whitespace-insensitive")) 
           ,cts:element-word-query(xs:QName("survey-listing-ns:SURVEYDESCRIPTION"),fn:concat("*",$request/searchText/text(),"*"),("wildcarded","case-insensitive","whitespace-insensitive"))
           ,cts:element-word-query(xs:QName("survey-listing-ns:SURVEYMETHODOLOGY"),fn:concat("*",$request/searchText/text(),"*"),("wildcarded","case-insensitive","whitespace-insensitive"))
           ))
          )))
   )         
let $search-result := for $result in $search-result
	let $name := $result//survey-listing-ns:NAME/text()
	let $type := if(fn:lower-case($name) eq fn:lower-case($request/searchText/text()))
    then 'Name'
    else if(fn:contains(fn:lower-case($name),fn:lower-case($request/searchText/text())))
    then 'NameMatch'
    else 'OtherMatch'
	let $last-modified := xs:dateTime($result//survey-listing-ns:LASTMODIFIED/text())
	order by $type,$name,$last-modified descending
  return $result		  
  
let $_ := for $entry in $search-result
      let $company-obj := json:object()	

      let $formatted_date := 
      if($entry//survey-listing-ns:LASTMODIFIED/text() ne "") then 
      xs:dateTime($entry//survey-listing-ns:LASTMODIFIED)
      else ""

      let $ISPOPULAR := if($entry//survey-listing-ns:ISPOPULAR/text() ne "")
      then $entry//survey-listing-ns:ISPOPULAR/text()
      else "0"

      let $description := if($entry//survey-listing-ns:SURVEYOVERVIEW/text() ne '')then
      $entry//survey-listing-ns:SURVEYOVERVIEW/text()
      else if ($entry//survey-listing-ns:SURVEYDESCRIPTION/text() ne '')then
      $entry//survey-listing-ns:SURVEYDESCRIPTION/text() 
      else 
      $entry//survey-listing-ns:SURVEYDESCRIPTION/text()

      let $LOGO := $entry//survey-listing-ns:LOGO/text()
      let $LOGO := if($LOGO eq "") then 
    cts:search(/,
      cts:and-query((
      cts:element-value-query(xs:QName("surveydetails-rd-ns:SURVEYID"),($entry//lcs:SURVEYLISTINGID /text()))
      (:,cts:element-value-query(xs:QName("surveydetails:PUBLISHYEAR"),$year):)
      )))//surveydetails-rd-ns:LOGO/text()		
    else $entry//survey-listing-ns:LOGO/text()

    let $LOGO := if($LOGO eq "") then 
    cts:search(/,
      cts:and-query((
      cts:element-value-query(xs:QName("surveydetails-rd-ns:SURVEYID"),($entry//lcs:SURVEYLISTINGID /text()))
      (:,cts:element-value-query(xs:QName("surveydetails:PUBLISHYEAR"),$year):)
      )))//surveydetails-rd-ns:LOGO/text()		
    else $entry//survey-listing-ns:LOGO/text()

  let $_ := (
      map:put($company-obj, "CATEGORY", $entry//survey-listing-ns:CATEGORY/text()),
      map:put($company-obj, "ALLTOPICS", $entry//survey-listing-ns:ALLTOPICS/text()),		
      (:map:put($company-obj, "DESCRIPTION", fn:replace($description,'<.+?>','')),:)	
	  map:put($company-obj, "DESCRIPTION", fn:replace($description,"''","'")),	
      map:put($company-obj, "IsAnalystReport",xs:integer($entry//survey-listing-ns:ISANALYSTREPORT/text())),
      map:put($company-obj, "IsPopular" , xs:integer($ISPOPULAR)),
      map:put($company-obj, "LOGO", $LOGO), 
      map:put($company-obj, "LastModified" ,$formatted_date),
      map:put($company-obj, "LastModifiedDate",$formatted_date),
      map:put($company-obj, "NAME",$entry//survey-listing-ns:NAME/text()),
      (:map:put($company-obj, "SURVEYOVERVIEW",$entry//survey-listing-ns:SURVEYOVERVIEW/text()),:)
	  map:put($company-obj, "OVERVIEW",$description), 
      map:put($company-obj, "PRICE", $entry//survey-listing-ns:PRICE /text()),
      map:put($company-obj, "PRODUCTTYPE", $entry//survey-listing-ns:PRODUCTTYPE /text()),
      map:put($company-obj, "SOURCE", $entry//survey-listing-ns:SOURCE /text()),
      map:put($company-obj, "SURVEYLISTINGID", xs:integer($entry//survey-listing-ns:SURVEYLISTINGID /text())),
      map:put($company-obj, "TABLENAME", $entry//survey-listing-ns:TABLENAME /text()),
      map:put($company-obj, "VideoScript", $entry//survey-listing-ns:LBS_VIDEO_SCRIPT/text())
    )
    let $_ := json:array-push($companies-arr, $company-obj)
    return ()

return $companies-arr

};

declare function sy:GETSEARCHDATA()
{

let $sl-arr := json:array()
let $sl := (cts:search(/,
          cts:and-query((
              cts:directory-query(("/LegalCompass/denormalized-data/survey-listing/"),"1"),
              cts:element-value-query(xs:QName('survey-listing-dd-ns:ISACTIVE'),"1", "exact"),
              cts:element-value-query(xs:QName('survey-listing-dd-ns:PRODUCTTYPE'),"1", "exact")              
              ))))
let $res := for $entry in $sl
            let $sl-obj := json:object()
            let $SURVEYLISTINGID := xs:integer($entry//survey-listing-dd-ns:SURVEYLISTINGID/text())
            let $SURVEYDESCRIPTION := $entry/SURVEYLISTING/survey-listing-dd-ns:SURVEYDESCRIPTION/text()
            let $NAME := $entry/SURVEYLISTING/survey-listing-dd-ns:NAME/text()
            let $_ := (
                  map:put($sl-obj, "ID", $SURVEYLISTINGID),
                  map:put($sl-obj, "NAME", $NAME),
                  map:put($sl-obj, "TYPE", 'SURVEY'),
                  map:put($sl-obj, "LOGO", $entry/SURVEYLISTING/survey-listing-dd-ns:LOGO/text()),                  
                  map:put($sl-obj, "Description", $SURVEYDESCRIPTION),
                  map:put($sl-obj, "SCOPEID", ()),
                  map:put($sl-obj, "SearchName", fn:replace($NAME,'[^a-zA-Z0-9'']',''))
                )
                let $_ := json:array-push($sl-arr, $sl-obj)
                return ()

return $sl-arr

};

declare function sy:GetAMLAW100ChartDataDetails(

$SurveyID,
$StartYear,
$EndYear,
$FirmList

)
{
	let $StartYear := xs:integer($StartYear/text())
	let $EndYear := xs:integer($EndYear/text())
	let $surveyId := $SurveyID/text()
	let $firmIds := $FirmList
	
		return if($surveyId eq 3) then
	(let $OrganizationIDs := if($firmIds eq '') 
	then
		cts:search(//survey:YEAR,
		cts:and-query((
		cts:directory-query("/LegalCompass/denormalized-data/surveys/AMLAW_200/")
		,cts:element-attribute-value-query(xs:QName("survey:YEAR"),xs:QName("PublishYear"), xs:string($EndYear))
		,cts:element-range-query(xs:QName("survey:AMLAW200_RANK"),"<=",10)
		,cts:not-query(cts:element-value-query(xs:QName("survey:AMLAW200_RANK"),''))
		)))//@OrganizationID/string()
	else 
		fn:tokenize($firmIds,',')
  let $OrganizationIDs := for $id in $OrganizationIDs
                        let $name := /organization[organization:ORGANIZATION_ID = (xs:string($id))]/organization:ORGANIZATION_NAME/text()[1]
                        order by $name[1]
                        return  $id    
	
	for $OrganizationID in $OrganizationIDs
	let $cData := cts:search(//survey:YEAR,
	cts:and-query((
		cts:directory-query("/LegalCompass/denormalized-data/surveys/AMLAW_200/")
		,cts:element-attribute-range-query(xs:QName("survey:YEAR"),xs:QName("PublishYear"),">=", $StartYear )
		,cts:element-attribute-range-query(xs:QName("survey:YEAR"),xs:QName("PublishYear"),"<=", $EndYear)
		,cts:element-attribute-value-query(xs:QName("survey:YEAR"),xs:QName("OrganizationID"), $OrganizationID)    
		)))
	(: let $orgName := (/organization[organization:ORGANIZATION_ID = xs:string($OrganizationID)]/organization:ORGANIZATION_NAME/text())[1] :)

	let $orgName := if((/organization[organization_rd:ORGANIZATION_ID = xs:string($OrganizationID)]/organization_rd:ALM_NAME/text())[1] ne '')then 
			/organization[organization_rd:ORGANIZATION_ID = xs:string($OrganizationID)]/organization_rd:ALM_NAME/text()[1]
		else 
			/organization[organization_rd:ORGANIZATION_ID = xs:string($OrganizationID)]/organization_rd:ORGANIZATION_NAME/text()[1]
			
	for $year in $StartYear to $EndYear  
	let $result := cts:search(//survey:YEAR,
	cts:and-query((
		cts:directory-query("/LegalCompass/denormalized-data/surveys/AMLAW_200/")
		,cts:element-attribute-range-query(xs:QName("survey:YEAR"),xs:QName("PublishYear"),"=", $year)
		,cts:element-attribute-value-query(xs:QName("survey:YEAR"),xs:QName("OrganizationID"), $OrganizationID)    
		)))  
		return if ($result) then
      let $respone-obj := json:object() 
	  (: let $orgName := if((/organization_rd:organization[organization_rd:ORGANIZATION_ID = xs:string($OrganizationID)]/organization_rd:ALM_NAME/text())[1] ne '')then  
			/organization_rd:organization[organization_rd:ORGANIZATION_ID = xs:string($OrganizationID)]/organization_rd:ALM_NAME/text()[1]
		else 
			/organization_rd:organization[organization_rd:ORGANIZATION_ID = xs:string($OrganizationID)]/organization_rd:ORGANIZATION_NAME/text()[1]:)
      let $_ := (
	  (:
      map:put($respone-obj,"ORGANIZATION_NAME", $orgName[1]),
      map:put($respone-obj,"ORGANIZATION_ID", $OrganizationID),
      map:put($respone-obj,"gross_revenue", $result//survey:GROSS_REVENUE/string()),
      map:put($respone-obj,"publishyear", $year),
      map:put($respone-obj,"amlaw100_rank", $result//@PublishYear/string()),
      map:put($respone-obj,"average", fn:round(fn:avg($cData//survey:GROSS_REVENUE/text())))
	  :)
	  
	  map:put($respone-obj,"FirmName", $orgName[1]),
      map:put($respone-obj,"FirmId", $OrganizationID),
      map:put($respone-obj,"GrossRevenue", $result//survey:GROSS_REVENUE/string()),
      map:put($respone-obj,"PublishYear", $year),
      map:put($respone-obj,"Rank", $result//@PublishYear/string()),
      map:put($respone-obj,"AvgGrossRevenue", fn:round(fn:avg($cData//survey:GROSS_REVENUE/text())))
	  
      ) 
      return $respone-obj
      else ())
	else (
	let $OrganizationIDs := if($firmIds eq '') 
	then
		cts:search(//survey:YEAR,
		cts:and-query((
		cts:directory-query("/LegalCompass/denormalized-data/surveys/AMLAW_100/")
		,cts:element-attribute-value-query(xs:QName("survey:YEAR"),xs:QName("PublishYear"), xs:string($EndYear))
		,cts:element-range-query(xs:QName("survey:AMLAW100_RANK"),"<=",10)
		)))//@OrganizationID/string()
	else 
		fn:tokenize($firmIds,',')
	let $OrganizationIDs := for $id in $OrganizationIDs
                        let $name := /organization[organization:ORGANIZATION_ID = (xs:string($id))]/organization:ORGANIZATION_NAME/text()[1]
                        order by $name[1]
                        return  $id
                        
	for $OrganizationID in $OrganizationIDs
	let $cData := cts:search(//survey:YEAR,
	cts:and-query((
		cts:directory-query("/LegalCompass/denormalized-data/surveys/AMLAW_100/")
		,cts:element-attribute-range-query(xs:QName("survey:YEAR"),xs:QName("PublishYear"),">=", $StartYear )
		,cts:element-attribute-range-query(xs:QName("survey:YEAR"),xs:QName("PublishYear"),"<=", $EndYear)
		,cts:element-attribute-value-query(xs:QName("survey:YEAR"),xs:QName("OrganizationID"), $OrganizationID)    
		)))
	
	for $year in $StartYear to $EndYear  
    let $result := cts:search(//survey:YEAR,
      cts:and-query((
        cts:directory-query("/LegalCompass/denormalized-data/surveys/AMLAW_100/")
        ,cts:element-attribute-range-query(xs:QName("survey:YEAR"),xs:QName("PublishYear"),"=", $year)
        ,cts:element-attribute-value-query(xs:QName("survey:YEAR"),xs:QName("OrganizationID"), $OrganizationID)    
      )))  
      
      return if ($result) then
      let $respone-obj := json:object() 
	  (:
	  let $orgName := (/organization[organization:ORGANIZATION_ID = xs:string($OrganizationID)]/organization:ORGANIZATION_NAME/text())[1]
	  :)
	  (:let $orgName := if((/organization_rd:organization[organization_rd:ORGANIZATION_ID = xs:string($OrganizationID)]/organization_rd:ALM_NAME/text())[1] ne '')then 
			/organization_rd:organization[organization_rd:ORGANIZATION_ID = xs:string($OrganizationID)]/organization_rd:ALM_NAME/text()[1]
		else 
			/organization_rd:organization[organization_rd:ORGANIZATION_ID = xs:string($OrganizationID)]/organization_rd:ORGANIZATION_NAME/text()[1]:)
      let $orgName := if((/organization[organization_rd:ORGANIZATION_ID = xs:string($OrganizationID)]/organization_rd:ALM_NAME/text())[1] ne '')then 
			/organization[organization_rd:ORGANIZATION_ID = xs:string($OrganizationID)]/organization_rd:ALM_NAME/text()[1]
		else 
			/organization[organization_rd:ORGANIZATION_ID = xs:string($OrganizationID)]/organization_rd:ORGANIZATION_NAME/text()[1]
	  let $_ := (
	  (:
      map:put($respone-obj,"ORGANIZATION_NAME", $orgName[1]),
      map:put($respone-obj,"ORGANIZATION_ID", $OrganizationID),
      map:put($respone-obj,"gross_revenue", $result//survey:GROSS_REVENUE/string()),
      map:put($respone-obj,"publishyear", $year),
      map:put($respone-obj,"amlaw100_rank", $result//@PublishYear/string()),
      map:put($respone-obj,"average", fn:round(fn:avg($cData//survey:GROSS_REVENUE/text())))
	  :)
	  
	  map:put($respone-obj,"FirmName", $orgName[1]),
      map:put($respone-obj,"FirmId", $OrganizationID),
      map:put($respone-obj,"GrossRevenue", $result//survey:GROSS_REVENUE/string()),
      map:put($respone-obj,"PublishYear", $year),
      map:put($respone-obj,"Rank", $result//@PublishYear/string()),
      map:put($respone-obj,"AvgGrossRevenue", fn:round(fn:avg($cData//survey:GROSS_REVENUE/text())))
	  
      ) 
      return $respone-obj
      else ())
};

declare function sy:GetAMLaw100Statistics(

$SurveyID,
$StartYear,
$EndYear,
$FirmList

)
{
	let $StartYear := xs:integer($StartYear/text())
	let $EndYear := xs:integer($EndYear/text())
	let $surveyId := $SurveyID/text()
	let $firmIds := $FirmList
	
	return if($surveyId = 3) then 
	let $OrganizationIDs := if($firmIds eq '') then 
	cts:element-values(xs:QName("AMLAW_200:ORGANIZATION_ID"),(),(),
  cts:and-query((
		cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/")
		,cts:element-value-query(xs:QName("AMLAW_200:PUBLISHYEAR"), xs:string($EndYear))
		)))
	else 
	fn:tokenize($firmIds,',')
	
	
	for $OrganizationID in $OrganizationIDs
	let $EndYearResult := cts:search(/,
	cts:and-query((
		cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/")
		,cts:element-value-query(xs:QName("AMLAW_200:PUBLISHYEAR"), xs:string($EndYear))
		,cts:element-value-query(xs:QName("AMLAW_200:ORGANIZATION_ID"), ($OrganizationID ! xs:string(.)))
		)))    
	let $StartYearResult := cts:search(/,
	cts:and-query((
		cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/")
		,cts:element-value-query(xs:QName("AMLAW_200:PUBLISHYEAR"), xs:string($StartYear))
		,cts:element-value-query(xs:QName("AMLAW_200:ORGANIZATION_ID"), ($OrganizationID ! xs:string(.)))
		)))
	
	let $response-obj := json:object()
	let $endYearRank := $EndYearResult//AMLAW_200:AMLAW200_RANK/text()
	let $startYearRank := $StartYearResult//AMLAW_200:AMLAW200_RANK/text()
	(:let $change := if($startYearRank eq '')
		then $endYearRank
		else  $startYearRank - $endYearRank
	:)
	let $change := if($startYearRank ne '')
		then $startYearRank - $endYearRank
		else $endYearRank

	(:let $orgName := (/organization[organization:ORGANIZATION_ID = xs:string($OrganizationID)]/organization:ORGANIZATION_NAME/text())[1] :)
	(: let $orgName := if((/organization_rd:organization[organization_rd:ORGANIZATION_ID = xs:string($OrganizationID)]/organization_rd:ALM_NAME/text())[1] ne '')then 
			/organization_rd:organization[organization_rd:ORGANIZATION_ID = xs:string($OrganizationID)]/organization_rd:ALM_NAME/text()[1]
		else 
			/organization_rd:organization[organization_rd:ORGANIZATION_ID = xs:string($OrganizationID)]/organization_rd:ORGANIZATION_NAME/text()[1] :)

	let $orgName := if((/organization[organization_rd:ORGANIZATION_ID = xs:string($OrganizationID)]/organization_rd:ALM_NAME/text())[1] ne '')then 
			/organization[organization_rd:ORGANIZATION_ID = xs:string($OrganizationID)]/organization_rd:ALM_NAME/text()[1]
		else 
			/organization[organization_rd:ORGANIZATION_ID = xs:string($OrganizationID)]/organization_rd:ORGANIZATION_NAME/text()[1]

	let $_ := 
	(
	map:put($response-obj,"ORGANIZATION_NAME",$orgName[1]),
	map:put($response-obj,"organization_id",$EndYearResult//AMLAW_200:ORGANIZATION_ID/string()),
	map:put($response-obj,"gross_revenue",$EndYearResult//AMLAW_200:GROSS_REVENUE/text()),
	map:put($response-obj,"EndingYear_Rank", $endYearRank),
	map:put($response-obj,"StartingYear_Rank",$startYearRank),
	map:put($response-obj,"Change",$change),
	map:put($response-obj,"Location",$EndYearResult//AMLAW_200:LOCATION/text()),
	map:put($response-obj,"RevenuePerLawyer",$EndYearResult//AMLAW_200:RPL/text()),
	map:put($response-obj,"RankByRevenuePerLawyer",$EndYearResult//AMLAW_200:RANK_BY_RPL/text()),
	map:put($response-obj,"ProfitPerPartner",$EndYearResult//AMLAW_200:PPP/text()),
	map:put($response-obj,"RankByProfitPerPartner",$EndYearResult//AMLAW_200:RANK_BY_PPP/text())
	)
		
	return $response-obj
	else(
	let $OrganizationIDs := if($firmIds eq '') then 
	cts:search(//survey:YEAR,
	cts:and-query((
		cts:directory-query("/LegalCompass/denormalized-data/surveys/AMLAW_200/")
		,cts:element-attribute-value-query(xs:QName("survey:YEAR"),xs:QName("PublishYear"), '2017')
		(:,cts:element-range-query(xs:QName("survey:AMLAW200_RANK"),"<=",10):)
		)))//@OrganizationID/string()
	else 
	fn:tokenize($firmIds,',')
	
	(:return count($OrganizationIDs) :)
	for $OrganizationID in $OrganizationIDs
	let $EndYearResult := cts:search(//survey:YEAR,
	cts:and-query((
		cts:directory-query("/LegalCompass/denormalized-data/surveys/AMLAW_100/")
		,cts:element-attribute-value-query(xs:QName("survey:YEAR"),xs:QName("PublishYear"), xs:string($EndYear))
		,cts:element-attribute-value-query(xs:QName("survey:YEAR"),xs:QName("OrganizationID"), $OrganizationID)
		)))    
	let $StartYearResult := cts:search(//survey:YEAR,
	cts:and-query((
		cts:directory-query("/LegalCompass/denormalized-data/surveys/AMLAW_100/")
		,cts:element-attribute-value-query(xs:QName("survey:YEAR"),xs:QName("PublishYear"), xs:string($StartYear))
		,cts:element-attribute-value-query(xs:QName("survey:YEAR"),xs:QName("OrganizationID"), $OrganizationID)
		)))
	
	let $response-obj := json:object()
	let $endYearRank := $EndYearResult//survey:AMLAW100_RANK/text()
	let $startYearRank := $StartYearResult//survey:AMLAW100_RANK/text()
	(:let $change := if($startYearRank eq '')
		then $endYearRank
		else  $startYearRank - $endYearRank
	:)
	let $change := if($startYearRank ne '')
		then $startYearRank - $endYearRank
		else $endYearRank

	(:
	let $orgName := (/organization[organization:ORGANIZATION_ID = xs:string($OrganizationID)]/organization:ORGANIZATION_NAME/text())[1]
	:)
	(: let $orgName := if((/organization_rd:organization[organization:ORGANIZATION_ID = xs:string($OrganizationID)]/organization:ALM_NAME/text())[1] ne '') then 
			/organization_rd:organization[organization:ORGANIZATION_ID = xs:string($OrganizationID)]/organization:ALM_NAME/text()[1]
		else 
			/organization_rd:organization[organization:ORGANIZATION_ID = xs:string($OrganizationID)]/organization:ORGANIZATION_NAME/text()[1]			 :)
	let $orgName := if((/organization[organization_rd:ORGANIZATION_ID = xs:string($OrganizationID)]/organization_rd:ALM_NAME/text())[1] ne '')then 
			/organization[organization_rd:ORGANIZATION_ID = xs:string($OrganizationID)]/organization_rd:ALM_NAME/text()[1]
		else 
			/organization[organization_rd:ORGANIZATION_ID = xs:string($OrganizationID)]/organization_rd:ORGANIZATION_NAME/text()[1]
	let $_ := 
	(
	map:put($response-obj,"ORGANIZATION_NAME",$orgName[1]),
	map:put($response-obj,"organization_id",$EndYearResult//@OrganizationID/string()),
	map:put($response-obj,"gross_revenue",$EndYearResult//survey:GROSS_REVENUE/text()),
	map:put($response-obj,"EndingYear_Rank", $endYearRank),
	map:put($response-obj,"StartingYear_Rank",$startYearRank),
	map:put($response-obj,"Change",$change),
	map:put($response-obj,"Location",$EndYearResult//survey:LOCATION/text()),
	map:put($response-obj,"RevenuePerLawyer",$EndYearResult//survey:RPL/text()),
	map:put($response-obj,"RankByRevenuePerLawyer",$EndYearResult//survey:RANK_BY_RPL/text()),
	map:put($response-obj,"ProfitPerPartner",$EndYearResult//survey:PPP/text()),
	map:put($response-obj,"RankByProfitPerPartner",$EndYearResult//survey:RANK_BY_PPP/text())
	)    
	return $response-obj
	)
};

declare function sy:GetAMLaw100StatisticsExport(

$SurveyID,
$StartYear,
$EndYear,
$FirmList

)
{
	let $StartYear := xs:integer($StartYear/text())
	let $EndYear := xs:integer($EndYear/text())
	let $surveyId := $SurveyID/text()
	let $firmIds := $FirmList
	
		return if($surveyId = 3) then 
	let $OrganizationIDs := if($firmIds eq '') then 
	cts:element-values(xs:QName("AMLAW_200:ORGANIZATION_ID"),(),(),
	cts:and-query((
		cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/")
		,cts:element-range-query(xs:QName('AMLAW_200:PUBLISHYEAR'), '<=',$EndYear)
		,cts:element-range-query(xs:QName('AMLAW_200:PUBLISHYEAR'), '>=',$StartYear)
		)))
	else 
	fn:tokenize($firmIds,',')
	
	
	for $OrganizationID in $OrganizationIDs	  
	let $StartYearResult := cts:search(/,
	cts:and-query((
		cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/")
		,cts:element-value-query(xs:QName("AMLAW_200:PUBLISHYEAR"), xs:string($StartYear))
		,cts:element-value-query(xs:QName("AMLAW_200:ORGANIZATION_ID"), ($OrganizationID ! xs:string(.)))
		)))
    
  for $year in $StartYear to $EndYear 
	let $EndYearResult := cts:search(/,
	cts:and-query((
		cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_200/")
		,cts:element-value-query(xs:QName("AMLAW_200:PUBLISHYEAR"), xs:string($year))
		,cts:element-value-query(xs:QName("AMLAW_200:ORGANIZATION_ID"), ($OrganizationID ! xs:string(.)))
		)))  
    
	let $response-obj := json:object()
	let $endYearRank := $EndYearResult//AMLAW_200:AMLAW200_RANK/text()
	let $startYearRank := $StartYearResult//AMLAW_200:AMLAW200_RANK/text()
	(:let $change := if($startYearRank eq '')
		then $endYearRank
		else  $startYearRank - $endYearRank
	:)
	let $change := if($startYearRank ne '')
		then $startYearRank - $endYearRank
		else $endYearRank
	let $orgName := if((/organization[organization_rd:ORGANIZATION_ID = xs:string($OrganizationID)]/organization_rd:ALM_NAME/text())[1] ne '')then 
			/organization[organization_rd:ORGANIZATION_ID = xs:string($OrganizationID)]/organization_rd:ALM_NAME/text()[1]
		else 
			/organization[organization_rd:ORGANIZATION_ID = xs:string($OrganizationID)]/organization_rd:ORGANIZATION_NAME/text()[1]
	let $_ := 
	(
	map:put($response-obj,"ORGANIZATION_NAME",$orgName[1]),
	map:put($response-obj,"organization_id",$EndYearResult//AMLAW_200:ORGANIZATION_ID/string()),
	map:put($response-obj,"gross_revenue",$EndYearResult//AMLAW_200:GROSS_REVENUE/text()),
	map:put($response-obj,"EndingYear_Rank", $endYearRank),
	map:put($response-obj,"PublishYear", $year),
	map:put($response-obj,"StartingYear_Rank",$startYearRank),
	map:put($response-obj,"Change",$change),
	map:put($response-obj,"Location",$EndYearResult//AMLAW_200:LOCATION/text()),
	map:put($response-obj,"RevenuePerLawyer",$EndYearResult//AMLAW_200:RPL/text()),
	map:put($response-obj,"RankByRevenuePerLawyer",$EndYearResult//AMLAW_200:RANK_BY_RPL/text()),
	map:put($response-obj,"ProfitPerPartner",$EndYearResult//AMLAW_200:PPP/text()),
	map:put($response-obj,"RankByProfitPerPartner",$EndYearResult//AMLAW_200:RANK_BY_PPP/text())
	)
		
	return $response-obj
		else(
	let $OrganizationIDs := if($firmIds eq '') then 
	cts:element-values(xs:QName("AMLAW_100:ORGANIZATION_ID"),(),(),
	cts:and-query((
		cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_100/")
		,cts:element-range-query(xs:QName('AMLAW_100:PUBLISHYEAR'), '<=',$EndYear)
		,cts:element-range-query(xs:QName('AMLAW_100:PUBLISHYEAR'), '>=',$StartYear)
		)))
	else 
	fn:tokenize($firmIds,',')
	
	for $OrganizationID in $OrganizationIDs
  let $StartYearResult := cts:search(/,
	cts:and-query((
		cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_100/")
		,cts:element-value-query(xs:QName("AMLAW_100:PUBLISHYEAR"), xs:string($StartYear))
		,cts:element-value-query(xs:QName("AMLAW_100:ORGANIZATION_ID"), ($OrganizationID ! xs:string(.)))
		)))
  for $year in $StartYear to $EndYear 
	let $EndYearResult := cts:search(/,
	cts:and-query((
		cts:directory-query("/LegalCompass/relational-data/surveys/AMLAW_100/")
		,cts:element-value-query(xs:QName("AMLAW_100:PUBLISHYEAR"), xs:string($year))
		,cts:element-value-query(xs:QName("AMLAW_100:ORGANIZATION_ID"), ($OrganizationID ! xs:string(.)))
		)))    
	
	
	let $response-obj := json:object()
	let $endYearRank := $EndYearResult//AMLAW_100:AMLAW100_RANK/text()
	let $startYearRank := $StartYearResult//AMLAW_100:AMLAW100_RANK/text()
	(:let $change := if($startYearRank eq '')
		then $endYearRank
		else  $startYearRank - $endYearRank
	:)
	let $change := if($startYearRank ne '')
		then $startYearRank - $endYearRank
		else $endYearRank
	let $orgName := if((/organization[organization:ORGANIZATION_ID = xs:string($OrganizationID)]/organization:ALM_NAME/text())[1] ne '')then 
			/organization[organization:ORGANIZATION_ID = xs:string($OrganizationID)]/organization:ALM_NAME/text()[1]
		else 
			/organization[organization:ORGANIZATION_ID = xs:string($OrganizationID)]/organization:ORGANIZATION_NAME/text()[1]			
	let $_ := 
	(
	map:put($response-obj,"ORGANIZATION_NAME",$orgName[1]),
	map:put($response-obj,"organization_id",$EndYearResult//AMLAW_100:ORGANIZATION_ID/text()),
	map:put($response-obj,"gross_revenue",$EndYearResult//AMLAW_100:GROSS_REVENUE/text()),
	map:put($response-obj,"EndingYear_Rank", $endYearRank),
	map:put($response-obj,"PublishYear", $year),
	map:put($response-obj,"StartingYear_Rank",$startYearRank),
	map:put($response-obj,"Change",$change),
	map:put($response-obj,"Location",$EndYearResult//AMLAW_100:LOCATION/text()),
	map:put($response-obj,"RevenuePerLawyer",$EndYearResult//AMLAW_100:RPL/text()),
	map:put($response-obj,"RankByRevenuePerLawyer",$EndYearResult//AMLAW_100:RANK_BY_RPL/text()),
	map:put($response-obj,"ProfitPerPartner",$EndYearResult//AMLAW_100:PPP/text()),
	map:put($response-obj,"RankByProfitPerPartner",$EndYearResult//AMLAW_100:RANK_BY_PPP/text())
	)    
	return $response-obj
	)
};

declare function sy:GetCategoryList()
{
	let $response-arr := json:array()
	let $PRODUCTQUALIFICATIONIDs :=(fn:distinct-values(cts:search(/,
						cts:and-query((
						cts:directory-query("/LegalCompass/relational-data/PromotionProductQualification/"),
						cts:element-value-query(xs:QName('ppq:PROMOID'),"246000", "exact")            
						)))//ppq:PRODUCTQUALIFICATIONID/text()))
	
	let $PRODUCTIDs := fn:distinct-values(cts:search(/,
						cts:and-query((
						cts:directory-query("/LegalCompass/relational-data/productqualification/"),
						cts:element-value-query(xs:QName('productqualification-rd-ns:PRODUCTQUALIFICATIONID'),$PRODUCTQUALIFICATIONIDs, "exact")            
						)))//productqualification-rd-ns:PRODUCTID/text())
	
	let $LBS_TOPICs := cts:element-values(xs:QName("topic-dd-ns:LBS_TOPIC"),(),(),
			cts:and-query((
			cts:directory-query("/LegalCompass/denormalized-data/Topics/")
		,cts:element-value-query(xs:QName("topic-dd-ns:SURVEYLISTINGID"),$PRODUCTIDs)
			)))
	
	let $topic-obj := for $topic in $LBS_TOPICs
	let $response-obj := json:object()
	let $_ := (
	map:put($response-obj,"CategoryName",$topic),
	map:put($response-obj,"CategoryId",0)
	)   
	let $_ := json:array-push($response-arr, $response-obj)          
	return $response-obj 
return $response-arr

};

declare function sy:GetAllSurveyData_New()
{
let $request := xdmp:get-request-body()/request
let $Type := $request/type/text()
let $Category := $request/category/text()
let $directory := "/LegalCompass/relational-data/survey-listing/"

let $CategoryQuery := if($Category ne '') then 
	let $surveyIDs := fn:distinct-values(cts:search(/,
		cts:and-query((
		cts:directory-query("/LegalCompass/denormalized-data/Topics/"),
		cts:element-value-query(xs:QName("topic-dd-ns:LBS_TOPIC"),fn:concat("*",$Category,"*"),("punctuation-insensitive","case-insensitive","wildcarded","whitespace-insensitive"))
		)))//topic-dd-ns:SURVEYLISTINGID/text())
	return cts:element-value-query(xs:QName('survey-listing-ns:SURVEYLISTINGID'),$surveyIDs,"exact")
	else ()
(:-----------------:)

let $context := map:map()
let $_ := map:put($context, "output-types","application/json")
let $companies-arr := json:array()

let $PRODUCTQUALIFICATIONIDs :=(fn:distinct-values(cts:search(/,
                      cts:and-query((
                      cts:directory-query("/LegalCompass/relational-data/PromotionProductQualification/"),
                      cts:element-value-query(xs:QName('ppq:PROMOID'),"246000", "exact")            
                      )))//ppq:PRODUCTQUALIFICATIONID/text()))

let $PRODUCTIDs := fn:distinct-values(cts:search(/,
                      cts:and-query((
                      cts:directory-query("/LegalCompass/relational-data/productqualification/"),
                      cts:element-value-query(xs:QName('pq:PRODUCTQUALIFICATIONID'),$PRODUCTQUALIFICATIONIDs, "exact")            
                      )))//pq:PRODUCTID/text())

let $dir-query := cts:directory-query(($directory),"1")

let $IsPopularQuery := if($request/isPopular/text() eq 1) then 
						cts:element-value-query(xs:QName('survey-listing-ns:ISPOPULAR'),"1", "exact")
						else ()
            
let $isActive-query := cts:element-value-query(xs:QName('survey-listing-ns:ISACTIVE'),"1", "exact")

let $PRODUCTTYPE := cts:element-value-query(xs:QName('survey-listing-ns:PRODUCTTYPE'),"1", "exact")

let $Product-query :=cts:element-value-query(xs:QName('survey-listing-ns:SURVEYLISTINGID'),$PRODUCTIDs, "exact") 

let $search-result :=	
            if(fn:lower-case($Type) eq "recent")then
						let $res := for $content in cts:search(/,cts:and-query(($dir-query,$isActive-query,$Product-query)))
									let $topics :=  fn:string-join(cts:element-values(xs:QName("topics:TOPIC_NAME"),(),(),
									cts:and-query((
									cts:directory-query('/LegalCompass/denormalized-data/Topics/')
									,cts:element-value-query(xs:QName("topics:SURVEYLISTINGID"),$content//survey-listing-ns:SURVEYLISTINGID/text())
									))),' /</br>')
									
									let $last-modified := xs:dateTime($content//survey-listing-ns:LASTMODIFIED/text())
									let $NAME := $content//survey-listing-ns:NAME/text()
									(:let $category := $content//survey-listing-ns:CATEGORY/text():)
									order by $last-modified descending 
									return $content					
						return $res[1 to 15]
					else (
						let $res := for $content in 
						cts:search(/,cts:and-query(($dir-query,$isActive-query,$PRODUCTTYPE,$Product-query,$CategoryQuery,$IsPopularQuery)))
									let $last-modified := xs:dateTime($content//survey-listing-ns:LASTMODIFIED/text())
									let $NAME := $content//survey-listing-ns:NAME/text()										
									order by $last-modified descending
									return $content
							return $res)		

let $_ := for $entry in $search-result
	let $company-obj := json:object()	
	
	let $formatted_date := 
	if($entry//survey-listing-ns:LASTMODIFIED/text() ne "") then 
	xs:dateTime($entry//survey-listing-ns:LASTMODIFIED)
	else ""
	
	let $ISPOPULAR := if($entry//survey-listing-ns:ISPOPULAR/text() ne "")
	then $entry//survey-listing-ns:ISPOPULAR/text()
	else "0"
	
	let $description := if($entry//survey-listing-ns:SURVEYOVERVIEW/text() ne '')then
		$entry//survey-listing-ns:SURVEYOVERVIEW/text()
		else if ($entry//survey-listing-ns:SURVEYDESCRIPTION/text() ne '')then
		$entry//survey-listing-ns:SURVEYDESCRIPTION/text() 
		else 
		$entry//survey-listing-ns:SURVEYDESCRIPTION/text()
		
	let $description:= if(fn:lower-case($Type) eq "recent")then
			(:$description:)
			$entry//survey-listing-ns:DISPLAYDESCRIPTION/text()
		else
			fn:replace($description,'<.+?>','')	
			
	let $LOGO := if(fn:lower-case($Type) eq "recent")then
	(:let $year := xs:string(fn:max(fn:distinct-values(cts:search(/,
									cts:and-query((
									cts:directory-query("/LegalCompass/denormalized-data/survey-listing/"),									
									cts:element-value-query(xs:QName("survey-listing-dd-ns:SURVEYLISTINGID"),($entry//survey-listing-ns:SURVEYLISTINGID/text()), "exact")
									))
									)//survey-listing-dd-ns:SurveyListingFile//survey-listing-dd-ns:FISCAL_YEAR))):)
	let $year := fn:max(cts:search(/,
                      cts:and-query((
                      cts:directory-query("/LegalCompass/relational-data/productqualification/"),
                      cts:element-value-query(xs:QName('pq:PRODUCTQUALIFICATIONID'),$PRODUCTQUALIFICATIONIDs, "exact"),
                      cts:element-value-query(xs:QName('pq:PRODUCTID'),$entry//survey-listing-ns:SURVEYLISTINGID/text(), "exact")
                      )))//pq:QUALIFICATIONVALUE/text())									
		return cts:search(/,
		cts:and-query((
		cts:element-value-query(xs:QName("surveydetails:SURVEYID"),($entry//survey-listing-ns:SURVEYLISTINGID /text())),
		cts:element-value-query(xs:QName("surveydetails:PUBLISHYEAR"),xs:string($year))
		)))//surveydetails:LOGO/text()
	else $entry//survey-listing-ns:LOGO/text()
	
	(:let $LOGO := if($LOGO eq "") then 
	cts:search(/,
		cts:and-query((
		cts:element-value-query(xs:QName("surveydetails:SURVEYID"),($entry//survey-listing-ns:SURVEYLISTINGID /text()))
		,cts:element-value-query(xs:QName("surveydetails:PUBLISHYEAR"),$year)
		)))//surveydetails:LOGO/text()		
	else $entry//survey-listing-ns:LOGO/text():)
	
	(:let $LOGO := if($entry//survey-listing-ns:SURVEYLISTINGID /text() eq "70") then "270x227_red[1].jpg"	
		else $LOGO:)
	
	let $_ := (
		map:put($company-obj, "CATEGORY", $entry//survey-listing-ns:CATEGORY/text()),
		map:put($company-obj, "ALLTOPICS", $entry//survey-listing-ns:ALLTOPICS/text()),
		(:map:put($company-obj, "DESCRIPTION",$entry//survey-listing-ns:SURVEYDESCRIPTION/text()),:)
		(:map:put($company-obj, "SURVEYDESCRIPTION", $description),:)
		(:map:put($company-obj, "SURVEYDESCRIPTION", fn:replace($description,'<.+?>','')),:)
		map:put($company-obj, "SURVEYDESCRIPTION", $description),
		map:put($company-obj, "IsAnalystReport",xs:integer($entry//survey-listing-ns:ISANALYSTREPORT/text())),
		map:put($company-obj, "IsPopular" , xs:integer($ISPOPULAR)),
		(:map:put($company-obj, "LOGO", $entry//survey-listing-ns:LOGO/text()),:)
		map:put($company-obj, "LOGO", $LOGO), 
		map:put($company-obj, "LastModified" ,$formatted_date),
		map:put($company-obj, "LastModifiedDate",$formatted_date),
		map:put($company-obj, "NAME",$entry//survey-listing-ns:NAME/text()),
		map:put($company-obj, "SURVEYOVERVIEW",$entry//survey-listing-ns:SURVEYOVERVIEW/text()),
		map:put($company-obj, "PRICE", $entry//survey-listing-ns:PRICE /text()),
		map:put($company-obj, "PRODUCTTYPE", $entry//survey-listing-ns:PRODUCTTYPE /text()),
		map:put($company-obj, "SOURCE", $entry//survey-listing-ns:SOURCE /text()),
		map:put($company-obj, "SURVEYLISTINGID", xs:integer($entry//survey-listing-ns:SURVEYLISTINGID /text())),
		map:put($company-obj, "TABLENAME", $entry//survey-listing-ns:TABLENAME /text()),
		map:put($company-obj, "VideoScript", $entry//survey-listing-ns:LBS_VIDEO_SCRIPT/text())
	)
	let $_ := json:array-push($companies-arr, $company-obj)
	return ()

return $companies-arr     

};

declare function sy:GetNLJChartDataDetails(
$FirmList,
$StartYear,
$EndYear,
$Role

)
{
	let $StartYear := xs:integer($StartYear)
	let $EndYear := xs:integer($EndYear)
	let $firmIds := $FirmList
	let $role := 
		if($Role eq "Attorneys")
			then "NUM_ATTORNEYS"
		else if ($Role eq "Total Partners")
			then "NUM_PARTNERS"
		else if ($Role eq "Equity Partners")
			then "Equity Partners"
		else if($Role eq "Non-Equity Partners")
			then "NUM_NE_PARTNERS"
		else if ($Role eq "Associates")
			then "NUM_ASSOCIATES"
		else if ($Role eq "Other Attorneys")
			then "NUM_OTHER_ATTORNEYS"
		else "NUM_ATTORNEYS"
	
	let $response-arr := json:array()
let $OrganizationIDs := if($firmIds eq '') then 
	cts:element-values(xs:QName("NLJ_250:ORGANIZATION_ID"),(),(),
	cts:and-query((
		cts:directory-query("/LegalCompass/relational-data/surveys/NLJ_250/")
		,cts:element-range-query(xs:QName('NLJ_250:PUBLISHYEAR'), '=',$EndYear)
		,cts:element-range-query(xs:QName('NLJ_250:NLJ250_RANK'), '<=',10)
		)))
	else 
	fn:tokenize($firmIds,',')
let $data := for $year in $StartYear to $EndYear(:for $OrganizationID in $OrganizationIDs  :)  
  (:Inner for start:)
  let $average_res := cts:search(/,
	  cts:and-query((
  		cts:directory-query("/LegalCompass/relational-data/surveys/NLJ_250/")
      ,cts:element-range-query(xs:QName('NLJ_250:PUBLISHYEAR'), '=',$year)     
  		,cts:element-value-query(xs:QName("NLJ_250:ORGANIZATION_ID"), ($OrganizationIDs ! xs:string(.)))
		)))
  for $OrganizationID in $OrganizationIDs  (:for $year in 2012 to 2017:) 
  (:
  let $average := avg(cts:search(/,
	  cts:and-query((
  		cts:directory-query("/LegalCompass/relational-data/surveys/NLJ_250/")
      ,cts:element-range-query(xs:QName('NLJ_250:PUBLISHYEAR'), '=',$year)     
  		,cts:element-value-query(xs:QName("NLJ_250:ORGANIZATION_ID"), ($OrganizationIDs ! xs:string(.)))
		)))//xdmp:value(fn:concat("NLJ_250:",$role))/text())
  :)
  let $average := if($role eq "Equity Partners")
    then  (:(avg($average_res//NLJ_250:NUM_PARTNERS/text()) - avg($average_res//NLJ_250:NUM_NE_PARTNERS/text())):) 5
    else avg($average_res//xdmp:value(fn:concat("NLJ_250:",$role))/text())
    
  let $result :=  cts:search(/,
	  cts:and-query((
  		cts:directory-query("/LegalCompass/relational-data/surveys/NLJ_250/")
  		,cts:element-value-query(xs:QName("NLJ_250:PUBLISHYEAR"), xs:string($year))
  		,cts:element-value-query(xs:QName("NLJ_250:ORGANIZATION_ID"), ($OrganizationID ! xs:string(.)))
		)))
  (:inner for end :)
  return if ($result) then
      let $respone-obj := json:object() 
	  let $orgName := if((/organization[organization_rd:ORGANIZATION_ID = xs:string($OrganizationID)]/organization_rd:ALM_NAME/text())[1] ne '')then 
			/organization[organization_rd:ORGANIZATION_ID = xs:string($OrganizationID)]/organization_rd:ALM_NAME/text()[1]
		else 
			/organization[organization_rd:ORGANIZATION_ID = xs:string($OrganizationID)]/organization_rd:ORGANIZATION_NAME/text()[1]
      
    let $count := if($role eq "Equity Partners")
      then  (($result//NLJ_250:NUM_PARTNERS/text()) - ($result//NLJ_250:NUM_NE_PARTNERS/text()))
      else ($result//xdmp:value(fn:concat("NLJ_250:",$role))/text())
      
      let $_ := (
	  map:put($respone-obj,"ORGANIZATION_NAME", $orgName[1]),
	  map:put($respone-obj,"organization_id", $OrganizationID),
      (:map:put($respone-obj,"COUNT", $result//NLJ_250:NUM_ATTORNEYS/string()),:)
      map:put($respone-obj,"COUNT", $count),
      map:put($respone-obj,"PublishYear", $year),
      map:put($respone-obj,"NLJ250_RANK", $result//NLJ_250:NLJ250_RANK/string()),
      map:put($respone-obj,"AVERAGE", fn:format-number($average,"00")),
      map:put($respone-obj,"NUM_ATTORNEYS", $result//NLJ_250:NUM_ATTORNEYS/string()),
      map:put($respone-obj,"NUM_PARTNERS", $result//NLJ_250:NUM_PARTNERS/string()),
      map:put($respone-obj,"NUM_NE_PARTNERS", $result//NLJ_250:NUM_NE_PARTNERS/string()),
      map:put($respone-obj,"NUM_OTHER_ATTORNEYS", $result//NLJ_250:NUM_OTHER_ATTORNEYS/string()),
      map:put($respone-obj,"EQUITY_PARTNERS", $result//NLJ_250:EQUITY_PARTNERS/string()),
      map:put($respone-obj,"NUM_ASSOCIATES", $result//NLJ_250:NUM_ASSOCIATES/string())
      ) 
  
  let $_ := json:array-push($response-arr, $respone-obj)  
  return ()
  else ()
  
let $data1 :=  for $year in $StartYear to $EndYear
  let $respone-obj := json:object()
  let $average_res := cts:search(/,
	  cts:and-query((
  		cts:directory-query("/LegalCompass/relational-data/surveys/NLJ_250/")
      ,cts:element-range-query(xs:QName('NLJ_250:PUBLISHYEAR'), '=',$year)     
  		,cts:element-value-query(xs:QName("NLJ_250:ORGANIZATION_ID"), ($OrganizationIDs ! xs:string(.)))
	)))
  let $Avg_Count := if($role eq "Equity Partners")
    then  (avg($average_res//NLJ_250:NUM_PARTNERS/text()) - avg($average_res//NLJ_250:NUM_NE_PARTNERS/text()))
    else avg($average_res//xdmp:value(fn:concat("NLJ_250:",$role))/text())
    
  let $_ := (
	    map:put($respone-obj,"ORGANIZATION_NAME", 'Average'),
      map:put($respone-obj,"organization_id", 0),
      map:put($respone-obj,"COUNT", fn:format-number($Avg_Count,"00")),
      map:put($respone-obj,"PublishYear", $year),
      map:put($respone-obj,"NLJ250_RANK", 0),
      map:put($respone-obj,"AVERAGE", fn:format-number($Avg_Count,"00")),
      map:put($respone-obj,"NUM_ATTORNEYS", fn:format-number(avg($average_res//NLJ_250:NUM_ATTORNEYS/text()),"00")),
      map:put($respone-obj,"NUM_PARTNERS", fn:format-number(avg($average_res//NLJ_250:NUM_PARTNERS/text()),"00")),      
      map:put($respone-obj,"NUM_NE_PARTNERS", fn:format-number(avg($average_res//NLJ_250:NUM_NE_PARTNERS/text()),"00")),      
      map:put($respone-obj,"NUM_OTHER_ATTORNEYS", fn:format-number(avg($average_res//NLJ_250:NUM_OTHER_ATTORNEYS/text()),"00")),
      map:put($respone-obj,"EQUITY_PARTNERS", fn:format-number(avg($average_res//NLJ_250:NUM_PARTNERS/text()) - avg($average_res//NLJ_250:NUM_NE_PARTNERS/text()),"00")),
      map:put($respone-obj,"NUM_ASSOCIATES", fn:format-number(avg($average_res//NLJ_250:NUM_ASSOCIATES/text()),"00"))      
      )
  let $_ := json:array-push($response-arr, $respone-obj) 
  return ()
  
return ($response-arr)

};

declare function sy:GetNLJStatistics(
$FirmList,
$StartYear,
$EndYear,
$Role
)
{
let $StartYear := xs:integer($StartYear)
let $EndYear := xs:integer($EndYear)
let $firmIds := $FirmList
let $role := ""

let $OrganizationIDs := if($firmIds eq '') then 
	cts:element-values(xs:QName("NLJ_250:ORGANIZATION_ID"),(),(),
	cts:and-query((
		cts:directory-query("/LegalCompass/relational-data/surveys/NLJ_250/")
		,cts:element-range-query(xs:QName('NLJ_250:PUBLISHYEAR'), '=',($EndYear))
    ,cts:not-query(cts:element-value-query(xs:QName("NLJ_250:NLJ250_RANK"), ""))
		)))
	else 
	fn:tokenize($firmIds,',')
let $orderBy1 :=cts:index-order(cts:element-reference(xs:QName("NLJ_250:NLJ250_RANK")),'ascending')

let $OrganizationIDs := for $org in cts:search(/,
  cts:and-query((
		cts:directory-query("/LegalCompass/relational-data/surveys/NLJ_250/")
		,cts:element-range-query(xs:QName('NLJ_250:PUBLISHYEAR'), '=',($EndYear))
    ,cts:element-value-query(xs:QName('NLJ_250:ORGANIZATION_ID'), ($OrganizationIDs ! xs:string(.)))
    ,cts:not-query(cts:element-value-query(xs:QName("NLJ_250:ORGANIZATION_ID"), ""))
		)),$orderBy1
    )
   return $org//NLJ_250:ORGANIZATION_ID

	for $OrganizationID in $OrganizationIDs
	let $StartYearResult := cts:search(/,
	cts:and-query((
		cts:directory-query("/LegalCompass/relational-data/surveys/NLJ_250/")
		,cts:element-value-query(xs:QName("NLJ_250:PUBLISHYEAR"), xs:string($StartYear))
		,cts:element-value-query(xs:QName("NLJ_250:ORGANIZATION_ID"), ($OrganizationID ! xs:string(.)))
		)))
   
	let $EndYearResult := cts:search(/,
	cts:and-query((
		cts:directory-query("/LegalCompass/relational-data/surveys/NLJ_250/")
		,cts:element-value-query(xs:QName("NLJ_250:PUBLISHYEAR"), xs:string($EndYear))
		,cts:element-value-query(xs:QName("NLJ_250:ORGANIZATION_ID"), ($OrganizationID ! xs:string(.)))    
		)))
    
	let $response-obj := json:object()
	let $endYearRank := $EndYearResult[1]//NLJ_250:NLJ250_RANK/text()
	let $startYearRank := $StartYearResult[1]//NLJ_250:NLJ250_RANK/text()	
	let $change := if($startYearRank ne '')
		then $startYearRank - $endYearRank
		else $endYearRank
	let $orgName := if((/organization[organization_rd:ORGANIZATION_ID = xs:string($OrganizationID)]/organization_rd:ALM_NAME/text())[1] ne '')then 
			/organization[organization_rd:ORGANIZATION_ID = xs:string($OrganizationID)]/organization_rd:ALM_NAME/text()[1]
		else 
			/organization[organization_rd:ORGANIZATION_ID = xs:string($OrganizationID)]/organization_rd:ORGANIZATION_NAME/text()[1]
  let $NUM_PARTNERS := $EndYearResult//NLJ_250:NUM_PARTNERS/text()
  let $NUM_NE_PARTNERS := $EndYearResult//NLJ_250:NUM_NE_PARTNERS/text()
  let $EQUITY_PARTNERS := $NUM_PARTNERS - $NUM_NE_PARTNERS
	let $_ := 
	(
	map:put($response-obj,"ORGANIZATION_NAME",$orgName[1]),
	map:put($response-obj,"organization_id",$EndYearResult//NLJ_250:ORGANIZATION_ID/string()),
	map:put($response-obj,"NUM_ATTORNEYS",$EndYearResult//NLJ_250:NUM_ATTORNEYS/text()),
	map:put($response-obj,"EndingYear_Rank", $endYearRank),	
	map:put($response-obj,"StartingYear_Rank",$startYearRank),
	map:put($response-obj,"Change",$change),
	map:put($response-obj,"NUM_PARTNERS",$NUM_PARTNERS),
	map:put($response-obj,"NUM_NE_PARTNERS",$NUM_NE_PARTNERS),
  map:put($response-obj,"EQUITY_PARTNERS", $EQUITY_PARTNERS),
	map:put($response-obj,"NUM_ASSOCIATES",$EndYearResult//NLJ_250:NUM_ASSOCIATES/text()),
  map:put($response-obj,"NUM_OTHER_ATTORNEYS",$EndYearResult//NLJ_250:NUM_OTHER_ATTORNEYS/text())
	)
  
return $response-obj

};
