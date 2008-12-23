
module Base where

import Default
import Util

processBase = do
    depends "temp/base/base.cabal" [] $ do
        system_ "darcs get --partial --repo-name=temp/base http://darcs.haskell.org/ghc-6.10/packages/base --tag=\"base 4.0.0.0\""

    basePatchup
    haddock "base"

    (res1,res2) <- liftM splitGHC $ readTextBase $ "temp/base/hoogle.txt"
    let prefix = basePrefix ++ ["@depends ghc"]
    writeFile "result/base.txt" $ unlines $ replaceTextBasePrefix prefix res1
    writeFile "result/ghc.txt" $ unlines $ ghcPrefix ++ res2


basePatchup = do
    -- FIX THE CABAL FILE
    fixupCabal "base" $ \x -> [x | not $ "ghc.prim" `isSubstrOf` map toLower x]

    -- INCLUDE FILE
    copyFile "Config.h" "temp/base/include/HsBaseConfig.h"


splitGHC :: [String] -> ([String],[String])
splitGHC = f True
    where
        f pile xs | null b = add pile xs ([], [])
                  | otherwise = add pile2 (a++[b1]) $ f pile2 bs
            where
                pile2 = if not $ "module " `isPrefixOf` b1 then pile
                        else not $ "module GHC." `isPrefixOf` b1
                b1:bs = b
                (a,b) = span isComment xs

        add left xs (a,b) = if left then (xs++a,b) else (a,xs++b)
        isComment x = x == "--" || "-- " `isPrefixOf` x


ghcPrefix :: [String]
ghcPrefix =
    ["-- Hoogle documentation, generated by Hoogle"
    ,"-- The GHC.* modules of the base library"
    ,"-- See Hoogle, http://www.haskell.org/hoogle/"
    ,""
    ,"-- | GHC modules that are part of the base library"
    ] ++ basePrefix ++ [""]

basePrefix :: [String]
basePrefix =
    ["@package base"
    ,"@version 4.0.0.0"
    ,"@haddock http://haskell.org/ghc/docs/latest/html/libraries/base/"
    ,"@hackage http://haskell.org/ghc/docs/latest/html/libraries/"
    ]

