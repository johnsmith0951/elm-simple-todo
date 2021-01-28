module Main exposing (..)
-- Input a user name and password. Make sure the password matches.
--
-- Read how it works:
--   https://guide.elm-lang.org/architecture/forms.html
--

import Browser
import Http
import Css exposing (rgb, solid, px, border3)
import Html 
import Html.Attributes exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css, href, src)
import Html.Events exposing (onInput)
import Html.Events exposing (onClick)
import Html.Events exposing (on)
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
  (Model [] "" , getTodos)


-- UPDATE


type Msg
  = AddTodo
  | Change String
  | UpdateTask Int
  | GotTodo (Result Http.Error (List TodoTask))
  | GetTodos


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    GetTodos -> 
      (model, getTodos)
    GotTodo result ->
      case result of
        Ok todoTaskList ->   
          let
            gotTasks = List.take 5 todoTaskList
          in
          ({
            model | tasks = gotTasks
          },
          Cmd.none)
        _ ->
          (model, Cmd.none)
    AddTodo ->
      let 
        -- model.content で新しいタスクを生成する
        -- model.tasks ++ 新しいタスク
        -- newTasks = TodoTask model.content False :: model.tasks
        newId = ( List.length model.tasks) + 1
        newTasks = model.tasks ++ [TodoTask newId model.content New]
      in
      ({ model | tasks = newTasks
      , content = ""}
      , Cmd.none)
    Change changeContent ->
      ({ model | content = changeContent }
      , Cmd.none)
    UpdateTask id ->
      let 
        newTasks = List.map (isDoneChecker id) model.tasks
      in
      ({ model | tasks = newTasks}
      , Cmd.none)

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
        , headers =
            [ Http.header "Accept" "application/json"
            , Http.header "Content-Type" "application/json"
            ]
        , url = "http://0.0.0.0:8000/todos/"
        , expect = Http.expectJson GotTodo todoListDecoder
        , body = Http.emptyBody
        , timeout = Nothing
        , tracker = Nothing
        }

-- createTodos : Cmd Msg
-- createTodos =
--     Http.request
--         { method = "POST"
--         , headers =
--             [ Http.header "Accept" "application/json"
--             , Http.header "Content-Type" "application/json"
--             ]
--         , url = "http://0.0.0.0:8000/todos/"
--         , expect = Http.expectJson GotTodo todoListDecoder
--         , body = body
--         , timeout = Nothing
--         , tracker = Nothing
--         }

isDoneChecker: Int -> TodoTask -> TodoTask
isDoneChecker id task =
  if task.id == id then
    if task.isCompleted == Done 
    then TodoTask id task.name New 
    else TodoTask id task.name Done
  else
    task

-- VIEW

mainColor: String
mainColor = "#FFE68B"

view : Model -> Html Msg
view model =
  div [] [
    viewHeaderWrapper
    , viewMainWrapper model
    ]

-- TODO: 次回までにCSSを別ファイルに抜き出す
viewHeaderWrapper: Html Msg
viewHeaderWrapper = 
  div [][viewTitle]

viewTitle: Html Msg
viewTitle =
  h1[][text "TODOs"]

viewMainWrapper: Model -> Html Msg
viewMainWrapper model = 
  div[][
    input [value model.content, onInput Change] []
    , button [ onClick AddTodo ] [ text "追加する" ]
    , viewTodoList model.tasks
  ]

viewTodoList : List TodoTask -> Html Msg
viewTodoList tasks = 
  tasks 
    |> List.map createTodoEl
    |> ul []


-- JS: tasks.map((t) => t.)
-- Elm: (\t -> t)
createTodoEl todoTask =
  let 
      -- if文でisDoneみて処理を変える
      -- たとえば
      -- doneText = if todoTask.isDone == True then "Done" else "Not done"
      textColor = if todoTask.isCompleted == Done then "green" else "#333"
      buttonText = if todoTask.isCompleted == Done then "undo" else "done"
  in 
  -- 1: Task name
  li [ style "color" textColor] [text ((String.fromInt todoTask.id) ++ " : " ++ todoTask.name),
  button [onClick (UpdateTask todoTask.id)] [text buttonText]]

