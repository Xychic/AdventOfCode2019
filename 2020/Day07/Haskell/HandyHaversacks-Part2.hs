import System.IO
import Control.Monad
import Data.List
import Data.Char(digitToInt)

printArray:: (Show a, Eq a) => [a] -> String
printArray (x:xs)
    | null xs = show x
    | otherwise = show x ++ "\n" ++ printArray xs

splitStr :: Eq a => [a] -> [a] -> [[a]]
splitStr sub str = split' sub str [] []
    where
    split' _ [] subacc acc = reverse (reverse subacc:acc)
    split' sub str subacc acc
        | sub `isPrefixOf` str = split' sub (drop (length sub) str) [] (reverse subacc:acc)
        | otherwise = split' sub (tail str) (head str:subacc) acc

replaceStr:: (Eq a) => [a] -> [a] -> [a] -> [a]
replaceStr toReplace target sub = replaceStr' (splitStr target toReplace) sub
    where
    replaceStr' (x:xs) sub
        | null xs = x
        | otherwise = x ++ sub ++ replaceStr' xs sub

replaceAllStr:: (Eq a) => [a] -> [([a], [a])] -> [a]
replaceAllStr toReplace [] = toReplace
replaceAllStr toReplace ((a,b):xs) = replaceAllStr (replaceStr toReplace a b) xs

type BagData = ([Char], [(Int, [Char])])
parseLine:: [[Char]] -> BagData
parseLine (a:b:xs)
    | "no other" `isInfixOf` b = (a, [])
    | otherwise = (a, map(\x -> (digitToInt (head x), drop 2 x)) splitBags)
    where 
        splitBags = splitStr ", " (replaceAllStr b [(".",""), (" bags",""), (" bag","")])

getData:: [BagData] -> [Char] -> [(Int, [Char])]
getData ((a,b):xs) target
    | a == target = b
    | otherwise = getData xs target

getTotalBags:: [BagData] -> [Char] -> Int
getTotalBags bagData bagName
    | null subBags = 1
    | otherwise = 1 + sum (map (\(a,b) -> a * getTotalBags bagData b) subBags)
    where
        subBags = getData bagData bagName

main:: IO()
main = do
    handle <- openFile "../input.txt" ReadMode
    contents <- hGetContents handle
    let rows = lines contents
    let parsed = map (parseLine . splitStr " bags contain " ) rows
    print (getTotalBags parsed "shiny gold" - 1)

    hClose handle