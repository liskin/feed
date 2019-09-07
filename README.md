# Feed

[![feed](https://img.shields.io/hackage/v/feed.svg)](http://hackage.haskell.org/package/feed)
[![Build Status](https://travis-ci.org/bergmark/feed.svg?branch=master)](https://travis-ci.org/bergmark/feed)

## Goal

Interfacing with *RSS* (v 0.9x, 2.x, 1.0) + *Atom* feeds.

- Parsers
- Pretty Printers
- Querying

To help working with the multiple feed formats we've ended up with
this set of modules providing parsers, pretty printers and some utility
code for querying and just generally working with a concrete
representation of feeds in Haskell.

For basic reading and editing of feeds, consult the documentation of
the Text.Feed.* hierarchy.

## Usage

Building an Atom feed is similar to building an RSS feed, but we'll
arbitrarily pick Atom here:

We'd like to generate the XML for a minimal working example.
Constructing our base `Feed` can use the smart constructor called `nullFeed`:

*This is a pattern the library maintains for smart constructors. If you want the
minimum viable 'X', use the 'nullX' constructor.*


```haskell
{-# LANGUAGE OverloadedStrings #-}

module Main where

import Prelude.Compat hiding (take)

import Data.Text
import Data.XML.Types as XML
import qualified Data.Text.Lazy as Lazy
import qualified Text.Atom.Feed as Atom
import qualified Text.Atom.Feed.Export as Export (textFeed)

myFeed :: Atom.Feed
myFeed = Atom.nullFeed
    "http://example.com/atom.xml"       -- ^ id
    (Atom.TextString "Example Website") -- ^ title
    "2017-08-01"                        -- ^ last updated
```

Now we can export the feed to `Text`.

```haskell
renderFeed :: Atom.Feed -> Maybe Lazy.Text
renderFeed = Export.textFeed
```

```
> renderFeed myFeed
<?xml version="1.0" encoding="UTF-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <title xmlns:ns="http://www.w3.org/2005/Atom" ns:type="text">Example Website</title>
  <id>http://example.com/atom.xml</id>
  <updated>2017-08-01</updated>
</feed>
```

The `TextContent` sum type allows us to specify which type of text we're providing.

```haskell
data TextContent
  = TextString Text
  | HTMLString Text
  | XHTMLString XML.Element
  deriving (Show)
```

A feed isn't very useful without some content though, so we'll need to build up an `Entry`.

```haskell
data Post
  = Post
  { _postedOn :: Text
  , _url :: Text
  , _content :: Text
  }

examplePosts :: [Post]
examplePosts =
  [ Post "2000-02-02T18:30:00Z" "http://example.com/2" "Bar."
  , Post "2000-01-01T18:30:00Z" "http://example.com/1" "Foo."
  ]
```

Our `Post` data type will need to be converted into an `Entry` in order to use it in the top level `Feed`. The required fields for an entry are an url "id" from which an entry's presence can be validated, a title for the entry, and a posting date. In this example we'll also add authors, link, and the entries actual content, since we have all of this available in the `Post` provided.

```haskell
toEntry :: Post -> Atom.Entry
toEntry (Post date url content) =
  (Atom.nullEntry
     url -- The ID field. Must be a link to validate.
     (Atom.TextString (take 20 content)) -- Title
     date)
  { Atom.entryAuthors = [Atom.nullPerson {Atom.personName = "J. Smith"}]
  , Atom.entryLinks = [Atom.nullLink url]
  , Atom.entryContent = Just (Atom.HTMLContent content)
  }
```

From the base feed we created earlier, we can add further details (`Link` and `Entry` content) as well as map our `toEntry` function over the posts we'd like to include in the feed.

```haskell
feed :: Atom.Feed
feed =
  myFeed { Atom.feedEntries = fmap toEntry examplePosts
         , Atom.feedLinks = [Atom.nullLink "http://example.com/"]
         }
```

```
> renderFeed feed
<?xml version="1.0" encoding="UTF-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <title xmlns:ns="http://www.w3.org/2005/Atom" ns:type="text">Example Website</title>
  <id>http://example.com/atom.xml</id>
  <updated>2017-08-01</updated>
  <link xmlns:ns="http://www.w3.org/2005/Atom" ns:href="http://example.com/"/>
  <entry>
    <id>http://example.com/2</id>
    <title xmlns:ns="http://www.w3.org/2005/Atom" ns:type="text">Bar.</title>
    <updated>2000-02-02T18:30:00Z</updated>
    <author>
      <name>J. Smith</name>
    </author>
    <content xmlns:ns="http://www.w3.org/2005/Atom" ns:type="html">Bar.</content>
    <link xmlns:ns="http://www.w3.org/2005/Atom" ns:href="http://example.com/2"/>
  </entry>
  <entry>
    <id>http://example.com/1</id>
    <title xmlns:ns="http://www.w3.org/2005/Atom" ns:type="text">Foo.</title>
    <updated>2000-01-01T18:30:00Z</updated>
    <author>
      <name>J. Smith</name>
    </author>
    <content xmlns:ns="http://www.w3.org/2005/Atom" ns:type="html">Foo.</content>
    <link xmlns:ns="http://www.w3.org/2005/Atom" ns:href="http://example.com/1"/>
  </entry>
</feed>
```
See [here](https://github.com/bergmark/feed/blob/master/tests/Example/CreateAtom.hs) for this content as an uninterrupted running example.

```haskell
-- Dummy main needed to compile this file with markdown-unlit
main :: IO ()
main = return ()
```
