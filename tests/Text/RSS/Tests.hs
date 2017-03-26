module Text.RSS.Tests where

import Prelude ()
import Prelude.Compat

import Test.Framework (Test, mutuallyExclusive, testGroup)
import Test.Framework.Providers.HUnit (testCase)
import Test.HUnit (Assertion, assertBool)
import Text.RSS.Export.Tests (rssExportTests)
import Text.RSS.Import.Tests (rssImportTests)
import Text.XML

import Text.Feed.Export
import Text.Feed.Import
import Text.RSS.Utils

import Paths_feed

rssTests :: Test
rssTests =
  testGroup
    "Text.RSS"
    [mutuallyExclusive $ testGroup "RSS" [rssExportTests, rssImportTests, testFullRss20Parse]]

testFullRss20Parse :: Test
testFullRss20Parse = testCase "parse a complete rss 2.0 file" testRss20
  where
    testRss20 :: Assertion
    testRss20 = do
      print . (fmap (renderText def)) . elementToDoc . xmlFeed =<<
        parseFeedFromFile =<< getDataFileName "tests/files/rss20.xml"
      assertBool "OK" True
