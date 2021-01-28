module Main exposing (..)

import Browser
import Http
import Task
import Css exposing (rgb, solid, px, border, padding, backgroundColor)
import Html  exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onClick, on)
import Json.Encode as E
import Json.Decode as D exposing (Decoder, field, bool, string, int)
import Json.Decode exposing (list, succeed)
import Task exposing (succeed)

-- MAIN

main : Program () Model Msg
main =
  Browser.element { init = \_ -> init, subscriptions = subscriptions , update = update, view = view}


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none

-- MODEL

type alias TodoTask =
  {
    id: Int
    , name: String
    , isCompleted: TaskStatus
  }

type TaskStatus
    = New
    | Done

type alias Model =
  { 
    tasks: List TodoTask
    , content: String
  }

init : (Model, Cmd Msg)
init =
  (Model [] "" ,  getTodos)


-- UPDATE


type Msg
  = AddTodo
  -- | UpdateTask Int
  | GotTodos (Result Http.Error (List TodoTask))
  | GotTodo (Result Http.Error (TodoTask))
  | GetTodos
  | ChangeContent String

run : msg -> Cmd msg
run m =
    Task.perform (always m) (Task.succeed ())

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    AddTodo ->
        (model, addTodo model)
    ChangeContent newContent ->
      ({ model | content = newContent }, Cmd.none)
    GetTodos -> 
      (model, getTodos)
    GotTodos result ->
      case result of
        Ok todoTaskList ->   
          let
            gotTasks = List.take (List.length todoTaskList) todoTaskList
          in
          ({ model | tasks = gotTasks }
          , run (ChangeContent "") )
        _ ->
          (model, Cmd.none)
    GotTodo result ->
      case result of
        Ok todoTask ->   
          ({ model | tasks =  model.tasks ++ [todoTask] }
          , run (ChangeContent "") )
        _ ->
          (model, Cmd.none)

-- HELPERS

todoDecoder : Decoder TodoTask
todoDecoder = 
  D.map3 TodoTask
    (field "id" int)
    (field "name" string)
    -- TODO: field指定して直す
    (D.succeed New)

todoListDecoder : Decoder (List TodoTask)
todoListDecoder = 
  D.list todoDecoder

getTodos : Cmd Msg
getTodos =
    Http.request
        { method = "GET"
        , headers = [ Http.header "Content-Type" "application/json" ]
        , url = "http://0.0.0.0:8000/todos/"
        , expect = Http.expectJson GotTodos todoListDecoder
        , body = Http.emptyBody
        , timeout = Nothing
        , tracker = Nothing
        }

addTodo  : Model -> Cmd Msg
addTodo model =
    Http.request
        { method = "POST"
        , headers = []
        , url = "http://0.0.0.0:8000/todos/"
        -- TODO: フロントに追加する処理を書く
        , expect = Http.expectJson GotTodo todoDecoder
        , body = Http.jsonBody <| E.object [("name", E.string model.content)]
        , timeout = Nothing
        , tracker = Nothing
        }

-- View
view : Model ->  Html Msg
view model =
  div [] [
    ul [] (taskListView model.tasks)
    , div [] [
      input [ 
        placeholder "タスク名を入力する"
        , value model.content
        , onInput ChangeContent
      ] []
      , button [ onClick AddTodo ] [ text "追加" ]
    ]
  ]

taskListView : (List TodoTask) -> List (Html Msg)
taskListView tasks = 
  List.map taskView tasks

taskView : TodoTask -> Html msg
taskView task =
  li [] [ text task.name ]