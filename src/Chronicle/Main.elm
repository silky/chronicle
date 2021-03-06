import Task         exposing (Task, andThen, mapError)
import Signal       exposing (Signal)
import Signal
import List
import Debug exposing (log)
import String

import Http
import Html exposing (Html)

import Chronicle.Model as Model
import Chronicle.Model exposing (Model)
import Chronicle.View as View
import Chronicle.Controller as Controller
import Chronicle.Controller exposing (actions, update)
import Chronicle.Database as Database


main : Signal Html
main =
  Signal.map (View.view actions.address) model

model' : Signal (Model, Maybe Controller.Request)
model' =
  let
    f a (m, _) = update (logAction "[ACTION] " a) m
  in
  Signal.foldp f (Model.initialModel, Nothing) actions.signal

model : Signal Model
model =
  Signal.map fst model'

request : Signal Controller.Request
request =
  Signal.map snd model'
  |> Signal.filterMap (\x -> x) Controller.initialRequest

runAndSend : Signal.Mailbox Controller.Action -> Controller.Request -> Task Http.Error ()
runAndSend mailbox r =
  withErrorLogging
  <| Controller.run (log "[REQUEST]" r)
       `andThen` (logAction "[FORWARD ACTION]" >> Signal.send mailbox.address)

withErrorLogging : Task x a -> Task x a
withErrorLogging task =
  mapError (log "[TASK ERROR]") task

port requestPort : Signal (Task Http.Error ())
port requestPort =
  Signal.map (runAndSend Controller.actions) request

logAction : String -> Controller.Action -> Controller.Action
logAction s a =
  let
    -- Don't dump entire JSON to console. Limit its length.
    limit s = case String.length s > 40 of
                True  -> String.left 40 s ++ " ..."
                False -> s
    _       = log s <| limit <| toString a
  in
    a
