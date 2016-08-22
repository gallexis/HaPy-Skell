{-# LANGUAGE OverloadedStrings #-}

module Hapyskell.Utils.JSON(
    Command(..),
    str_to_json,
    json_to_str
    )
where

import Control.Applicative ((<$>), (<*>))
import Data.Aeson
import qualified Data.ByteString.Lazy.Char8 as BL
import Control.Monad (mzero)

data Command = Command {
      order :: String,
      message :: String
  }
  deriving (Show)

instance FromJSON Command where
  parseJSON (Object o) =
    Command <$> (o .: "order")
    <*> (o .: "message")
  parseJSON _ = mzero

instance ToJSON Command where
  toJSON (Command order message) = object ["order" .= order, "message" .= message]

str_to_json :: String -> Maybe Command
str_to_json str = decode $ BL.pack str

json_to_str :: Command -> String
json_to_str cmd = BL.unpack $ encode cmd
