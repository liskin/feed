module Main
  ( main
  ) where

import Prelude.Compat

import Example (exampleTests)
import ImportExport (importExportTests)
import Test.Framework (defaultMain)
import Text.Atom.Tests (atomTests)
import Text.Feed.Util.Tests (feedUtilTests)
import Text.RSS.Tests (rssTests)

main :: IO ()
main = defaultMain [rssTests, atomTests, feedUtilTests, exampleTests, importExportTests]
