declare namespace prof="http://basex.org/modules/prof";

declare function local:apriori($l, $L, $minsup, $total, $src)
{
	let $C := local:removeDuplicate(local:candidateGen($l))
	let $l := local:getLargeItemsets($C, $minsup, $total, $src)
	let $L := $l union $L
	return 	if (empty($l)) then
				$L
			else
				local:apriori($l, $L, $minsup, $total, $src)
};

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
	return	<largeItemset> {$items}
				<support> {$sup} </support>
			</largeItemset>
};

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

declare function local:commonItems($X, $Y)
{
	for $item in $X
	where some $i in $Y satisfies $i = $item
	return $item
};

declare function local:candidateGen($l) {
	for $freqSet1 in $l
	let $items1 := $freqSet1//items/*
		for $freqSet2 in $l
		let $items2 := $freqSet2//items/*
		where $freqSet2 >> $freqSet1 and
			count($items1)+1 = 
				count($items1 union $items2)
			and local:prune(local:join($items1,$items2), $l)
			return 	<items>
						{local:join($items1,$items2)}
					</items>
};

declare function local:join($X, $Y) 
{
	let $items := (for $item in $Y
					where every $i in $X satisfies
						$i != $item
					return $item)
	return $X union $items
};

declare function local:prune($X, $Y)
{
	every $item in $X satisfies
	some $items in $Y//items satisfies
	count(local:commonItems(local:removeItems($X,$item),$items/*))
	= count($X) - 1
};

declare function local:removeItems($X, $Y)
{
	for $item in $X
	where every $i in $Y satisfies $i != $item
	return $item
};

prof:time(
let $src := doc('../data/transactions.xml')//items
let $minsup := 0.4
let $total := count($src) * 1.00
let $C := distinct-values($src/*)
let $l := (for $itemset in $C
			let $items := (for $item in $src/* 
				where $itemset = $item 
				return $item)
			let $sup := (count($items) * 1.00) div $total
			where $sup >= $minsup
			return  <largeItemset> 
						<items> {$itemset} </items> 
						<support> {$sup} </support>	
					</largeItemset>)
let $L := $l
return	<largeItemsets> 
			{local:apriori($l, $L,$minsup, $total, $src)} 
		</largeItemsets>, 
'Execution time of large itemset computation (apriori version 1): ')