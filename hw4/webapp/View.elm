module View exposing (rootView)

import Html exposing (div, button, text)
import Html.Events exposing (onClick)
import Html.Attributes exposing (id)

import Types exposing (..)

rootView model =
  div []
    [ button [ onClick (PanMap 0.05 0.00) ] [ text "Pan Up" ]
    , button [ onClick (PanMap 0.00 0.05) ] [ text "Pan Right" ]
    , button [ onClick (PanMap 0.00 -0.05) ] [ text "Pan Left" ]
    , button [ onClick (PanMap -0.05 0.00) ] [ text "Pan Down" ]
    , div [id "map" ] []
    ]
