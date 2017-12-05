module Utils exposing (..)

import Date exposing (Date)
import Date.Extra.Format as DEF
import Date.Extra.Config as DEC
import Date.Extra.Config.Config_fr_fr as DECFR


dateToStringFr : Date -> String
dateToStringFr date =
    formatFrench
        ("%A %e %B %Y ")
        date


timeToStringFr : Date -> String
timeToStringFr date =
    formatFrench
        ("%-H:%M")
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
