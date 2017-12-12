module Utils exposing (..)

import Date exposing (Date)
import Date.Extra.Format as DEF
import Date.Extra.Config as DEC
import Date.Extra.Config.Config_fr_fr as DECFR
import Char
import Html exposing (Html, i)
import Html.Attributes exposing (..)


dayAndMonth : Date -> String
dayAndMonth date =
    formatFrench
        ("%e %B")
        date


timeToStringFr : Date -> String
timeToStringFr date =
    formatFrench
        ("%-H:%M")
        date


dayOfWeek : Date -> String
dayOfWeek date =
    formatFrench
        ("%A")
        date


dateFromJS : Float -> Date
dateFromJS epoch =
    Date.fromTime (epoch * 1000)


formatFrench : String -> Date -> String
formatFrench format date =
    DEF.format formatConfigFrench format date
        |> String.toLower


formatConfigFrench : DEC.Config
formatConfigFrench =
    DECFR.config


ucfirst : String -> String
ucfirst string =
    case String.uncons string of
        Just ( firstLetter, rest ) ->
            String.cons (Char.toUpper firstLetter) rest

        Nothing ->
            ""


icon : String -> Html a
icon str =
    styledIcon [] str


styledIcon : List ( String, String ) -> String -> Html a
styledIcon styles str =
    i [ class str, attribute "aria-hidden" "true", style styles ] []
