module HW.Template.Newsletter
  ( newsletterTemplate
  , newsletterActionTemplate
  , newsletterHead
  )
where

import qualified Data.Text
import qualified HW.Template.Base
import qualified HW.Type.BaseUrl
import qualified HW.Type.Date
import qualified HW.Type.Issue
import qualified HW.Type.Number
import qualified HW.Type.Route
import qualified Lucid as H
import qualified Lucid.Base as H

newsletterTemplate :: HW.Type.BaseUrl.BaseUrl -> [HW.Type.Issue.Issue] -> H.Html ()
newsletterTemplate baseUrl issues =
  HW.Template.Base.baseTemplate
      baseUrl
      []
      (newsletterHead baseUrl Nothing)
    $ do
        H.h2_ [H.class_ "f2 mv3 tracked-tight"] "Newsletter"
        H.p_ [H.class_ "lh-copy"] $ do
          "The Haskell Weekly Newsletter covers the Haskell programming langauge. "
          "Each issue features several hand-picked links to interesting content about Haskell from around the web."
        newsletterActionTemplate baseUrl
        H.ul_ [H.class_ "lh-copy"] $ mapM_ (issueTemplate baseUrl) issues

newsletterHead :: HW.Type.BaseUrl.BaseUrl -> Maybe HW.Type.Issue.Issue -> H.Html ()
newsletterHead baseUrl maybeIssue = do
  H.link_
    [ H.href_ $ HW.Type.Route.routeToTextWith
      baseUrl
      HW.Type.Route.RouteNewsletterFeed
    , H.rel_ "alternate"
    , H.type_ "application/atom+xml"
    ]
  case maybeIssue of
    Nothing -> pure ()
    Just issue -> do
      openGraph "image" $ HW.Type.Route.routeToTextWith
        baseUrl
        HW.Type.Route.RoutePodcastLogo
      openGraph "site_name" "Haskell Weekly"
      openGraph "title"
        . mappend "Issue "
        . HW.Type.Number.numberToText
        $ HW.Type.Issue.issueNumber issue
      openGraph "type" "website"
      openGraph "url"
        . HW.Type.Route.routeToTextWith baseUrl
        . HW.Type.Route.RouteIssue
        $ HW.Type.Issue.issueNumber issue
      twitter "card" "summary"
      twitter "site" "@haskellweekly"

openGraph :: Data.Text.Text -> Data.Text.Text -> H.Html ()
openGraph property content =
  H.meta_ [H.content_ content, H.makeAttribute "property" $ "og:" <> property]

twitter :: Data.Text.Text -> Data.Text.Text -> H.Html ()
twitter name content =
  H.meta_ [H.content_ content, H.name_ $ "twitter:" <> name]

newsletterActionTemplate :: HW.Type.BaseUrl.BaseUrl -> H.Html ()
newsletterActionTemplate baseUrl =
  H.div_ [H.class_ "ba b--yellow bg-washed-yellow center mw6 pa3"] $ do
    H.p_ [H.class_ "lh-copy mt0"] $ do
      "Subscribe now! "
      "We'll never send you spam. "
      "You can also follow us "
      H.a_ [H.href_ "https://twitter.com/haskellweekly"] "on Twitter"
      " or with "
      H.a_
        [ H.href_ $ HW.Type.Route.routeToTextWith
            baseUrl
            HW.Type.Route.RouteNewsletterFeed
        ]
        "our feed"
      "."
    H.form_
        [ H.action_
          "https://news.us10.list-manage.com/subscribe/post?u=49a6a2e17b12be2c5c4dcb232&id=ffbbbbd930"
        , H.class_ "flex"
        , H.method_ "post"
        ]
      $ do
          H.div_
              [ H.makeAttribute "aria-hidden" "true"
              , H.class_ "absolute top--2"
              ]
            $ H.input_
                [ H.name_ "b_49a6a2e17b12be2c5c4dcb232_ffbbbbd930"
                , H.tabindex_ "-1"
                , H.type_ "text"
                , H.value_ ""
                ]
          H.input_
            [ H.class_ "ba b--silver input-reset pa3 flex-auto"
            , H.name_ "EMAIL"
            , H.placeholder_ "you@example.com"
            , H.required_ "required"
            , H.type_ "email"
            ]
          H.button_
            [ H.class_
              "b ba b--dark-blue bg-blue input-reset pa3 pointer white"
            , H.type_ "submit"
            ]
            "Subscribe"

issueTemplate :: HW.Type.BaseUrl.BaseUrl -> HW.Type.Issue.Issue -> H.Html ()
issueTemplate baseUrl issue = H.li_ $ do
  H.a_
      [ H.href_
        . HW.Type.Route.routeToTextWith baseUrl
        . HW.Type.Route.RouteIssue
        $ HW.Type.Issue.issueNumber issue
      ]
    $ do
        "Issue "
        H.toHtml
          . HW.Type.Number.numberToText
          $ HW.Type.Issue.issueNumber issue
  " "
  H.span_ [H.class_ "gray"]
    . H.toHtml
    . HW.Type.Date.dateToShortText
    $ HW.Type.Issue.issueDate issue