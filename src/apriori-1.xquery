(:===================================================================================================================:)
(: apriori-1 XQuery Script :)
(: Perform the apriori algorithm using code supplied by researchers and the custom dataset :)
(: Code has been slightly modified to be up to date with XQuery current standard and provide accurate results :)
(:===================================================================================================================:)

(: Imports/Namespaces :)
declare namespace prof="http://basex.org/modules/prof";
declare namespace xs = "http://www.w3.org/2001/XMLSchema";
declare variable $support as xs:string+ external;

(:===================================================================================================================:)
(: join function :)
(:===================================================================================================================:)

declare function local:join($X, $Y) 
{
	let $items := (for $item in $Y
									where every $i in $X satisfies
										$i != $item
									return $item)
	return $X union $items
};

(:===================================================================================================================:)
(: commonItems function :)
(:===================================================================================================================:)

declare function local:commonItems($X, $Y)
{
	for $item in $X
	where some $i in $Y satisfies $i = $item
	return $item
};

(:===================================================================================================================:)
(: removeItems function :)
(:===================================================================================================================:)

declare function local:removeItems($X, $Y)
{
	for $item in $X
	where every $i in $Y satisfies $i != $item
	return $item
};

(:===================================================================================================================:)
(: candidateGen function :)
(:===================================================================================================================:)

declare function local:candidateGen($l) {
	for $freqSet1 in $l
	let $items1 := $freqSet1//items/*
		for $freqSet2 in $l
		let $items2 := $freqSet2//items/*
		where $freqSet2 >> $freqSet1 
		(: Researchers provide this line, but results do not match when used :)
		(: and count($items1)+1 = count($items1 union $items2) :)
			and local:prune(local:join($items1,$items2), $l)
			return 	<items>
								{local:join($items1,$items2)}
							</items>
};

(:===================================================================================================================:)
(: prune function :)
(:===================================================================================================================:)

declare function local:prune($X, $Y)
{
	every $item in $X satisfies
	some $items in $Y//items satisfies
	count(local:commonItems(local:removeItems($X,$item),$items/*))
	= count($X) - 1
};

(:===================================================================================================================:)
(: removeDuplicate function :)
(:===================================================================================================================:)

declare function local:removeDuplicate($C)
{
	for $itemset1 in $C
	let $items1 := $itemset1/*
	let $items :=(for $itemset2 in $C
								let $items2 := $itemset2/*
								where $itemset2>>$itemset1 and
									count($items1) =
									count(local:commonItems($items1, $items2))
								return $items2)
	where count($items) = 0
	return $itemset1
};

(:===================================================================================================================:)
(: getLargeItemsets function :)
(:===================================================================================================================:)

declare function local:getLargeItemsets($C, $minsup, $total, $src)
{
	for $items in $C
	let $trans := (for $tran in $src
								where every $item1 in $items/* satisfies
											some $item2 in $tran/*
											satisfies $item1 = $item2
								return $tran)
	let $sup := (count($trans) * 1.00) div $total
	where $sup >= $minsup
	return	<largeItemset> 
						{$items}
						<support> {$sup} </support>
					</largeItemset>
};

(:===================================================================================================================:)
(: apriori function :)
(:===================================================================================================================:)

declare function local:apriori($l, $L, $minsup, $total, $src)
{
	(: Generate candidate itemsets :)
	let $C := local:removeDuplicate(local:candidateGen($l))

	(: Get large itemsets using the candidates :)
	let $l := local:getLargeItemsets($C, $minsup, $total, $src)

	(: Join previous itemsets and current itemsets together :)
	let $L := $l union $L
	return 	
			(: If no new large itemsets are generated, return, else continue :)
			if (empty($l)) then
				$L
			else
				local:apriori($l, $L, $minsup, $total, $src)
};

(:===================================================================================================================:)
(: Script :)
(:===================================================================================================================:)

(: BaseX time profiler function will track the execution time of the algorithm :)
prof:time(

(: Load xml file and grab all of the 'crimeStats' nodes :)
let $src := doc('../data/master-csv-transformed.xml')//crimeStats

(: Set the minimum support value :)
let $minsup := number($support)

(: Total number of 'crimeStats' nodes :)
let $total := count($src) * 1.00

(: Distinct 'crimeStats' nodes :)
let $C := distinct-values($src/*)

(: Generate the initial itemsets :)
let $l := (for $itemset in $C
			(: Count the occurence of each distinct item in src :)
			let $items := (for $item in $src/* 
				where $itemset = $item 
				return $item)

			(: Determine the support of each distinct item :)
			let $sup := (count($items) * 1.00) div $total

			(: Return a large itemset for each itemset with minimum support :)
			where $sup >= $minsup
			return	<largeItemset> 
								<items> 
									<item>{$itemset}</item> 
								</items> 
								<support> {$sup} </support>	
							</largeItemset>)
let $L := $l
(: Call the recursive apriori algorithm to generate all itemsets :)
return	<largeItemsets>
					{local:apriori($l, $L, $minsup, $total, $src)}
				</largeItemsets>, 
'Execution time of large itemset computation from dataset (apriori version 1): ')