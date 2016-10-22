port module App exposing (main)

import Html.App
import State
import View
import Types

main : Program Never
main =
    Html.App.program
        { init = State.initialState
        , update = State.update
        , subscriptions = \_ -> Sub.none
        , view = View.rootView
        }