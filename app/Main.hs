{-# LANGUAGE OverloadedStrings #-}
module Main where

import           Control.Applicative              ((<|>))
import           Control.Monad.Trans              (liftIO)
import           Data.Text                        (Text)
import qualified Data.Text                        as Text
import           Data.Time

import qualified Telegram.Bot.API                 as Telegram
import           Telegram.Bot.Simple
import           Telegram.Bot.Simple.Debug
import           Telegram.Bot.Simple.UpdateParser

data Model = Model
  { todoItems :: [TodoItem]
  } deriving (Show)

type TodoItem = Text

addItem :: TodoItem -> Model -> Model
addItem item model = model
  { todoItems = item : todoItems model }

showItems :: [TodoItem] -> Text
showItems items = Text.unlines items

removeItem
  :: TodoItem -> Model -> Either Text Model
removeItem item model
  | item `notElem` items
      = Left ("No such item: " <> item)
  | otherwise = Right model
      { todoItems = filter (/= item) items }
  where
    items = todoItems model

removeItemByIx :: Int -> Model -> Model
removeItemByIx n model = model
  { todoItems = take (n - 1) items ++ drop n items }
    where
      items = todoItems model

data Action
  = DoNothing
  | AddItem Text
  | ShowItems
  | RemoveItem TodoItem
  | GetTime
  | Start
  deriving (Show)

-- | A help message to show on conversation start with bot.
startMessage :: Text
startMessage = Text.unlines
 [ "Hi there! I am your personal todo bot :)"
 , ""
 , "I can help you keep track of things to do:"
 , ""
 , "- Just type what you need to do an I'll remember it!"
 , "- Use /remove <item> to remove an item"
 , "- Use /show to show all current things to do"
 , ""
 , "So what's the first thing on your to do list? :)"
 ]

-- | A start keyboard with some helpful todo suggestions.
startMessageKeyboard :: Telegram.ReplyKeyboardMarkup
startMessageKeyboard = Telegram.ReplyKeyboardMarkup
  { Telegram.replyKeyboardMarkupKeyboard =
      [ [ "Drink water", "Eat fruit" ]
      , [ "Build a house", "Raise a son", "Plant a tree" ]
      , [ "Spend time with family", "Call parents" ]
      ]
  , Telegram.replyKeyboardMarkupResizeKeyboard = Just True
  , Telegram.replyKeyboardMarkupOneTimeKeyboard = Just True
  , Telegram.replyKeyboardMarkupSelective = Just True
  }

bot :: BotApp Model Action
bot = BotApp
  { botInitialModel = Model []
  , botAction = flip handleUpdate
  , botHandler = handleAction
  , botJobs = []
  }

handleUpdate
  :: Model -> Telegram.Update -> Maybe Action
handleUpdate _model = parseUpdate
   $ ShowItems  <$  command "show"
 <|> RemoveItem <$> command "remove"
 <|> GetTime    <$  command "time"
 <|> Start      <$  command "start"

 <|> AddItem   <$> text

handleAction
  :: Action -> Model -> Eff Action Model
handleAction action model =
  case action of
    DoNothing -> pure model
    AddItem title  -> addItem title model <# do
      replyText "Got it."
      pure DoNothing
    ShowItems -> model <# do
      replyText (showItems (todoItems model))
      pure DoNothing
    GetTime -> model <# do
      now <- liftIO getCurrentTime
      replyText (Text.pack (show now))
      pure DoNothing
    RemoveItem item ->
      case removeItem item model of
        Left err -> model <# do
          replyText err
          pure DoNothing
        Right newModel -> newModel <# do
          replyText "Item removed."
          pure ShowItems
    Start -> model <# do
      reply (toReplyMessage startMessage)
        { replyMessageReplyMarkup = Just
            (Telegram.SomeReplyKeyboardMarkup startMessageKeyboard)
        }
      pure DoNothing

-- | Run bot with a given 'Telegram.Token'.
run :: Telegram.Token -> IO ()
run token = do
  env <- Telegram.defaultTelegramClientEnv token
  startBot_ (traceBotDefault (conversationBot Telegram.updateChatId bot)) env

-- | Run bot using 'Telegram.Token' from @TELEGRAM_BOT_TOKEN@ environment.
main :: IO ()
main = getEnvToken "TELEGRAM_BOT_TOKEN" >>= run
