{-# LANGUAGE OverloadedStrings #-}

module Main where

import JSON_Parser
import System.IO
import Control.Monad
import qualified Data.ByteString.Char8 as B

import Network.Socket hiding (send, sendTo, recv, recvFrom)
import Network.Socket.ByteString

import System.IO
import System.Posix

-- concurrency
import Control.Exception
import Control.Concurrent


type Stream a = MVar (Item a)
data Item a   = Item a (Main.Stream a)

data Channel a = Channel (MVar (Main.Stream a)) (MVar (Main.Stream a))



newChannel :: IO (Channel (Maybe Command))
newChannel = do
  hole  <- newEmptyMVar
  readVar  <- newMVar hole
  writeVar <- newMVar hole
  return (Channel readVar writeVar)

writeChannel :: Channel (Maybe Command) -> (Maybe Command) -> IO ()
writeChannel (Channel _ writeVar) val = do
  newHole <- newEmptyMVar
  oldHole <- takeMVar writeVar
  putMVar oldHole (Item val newHole)
  putMVar writeVar newHole

readChannel :: Channel (Maybe Command) -> IO (Maybe Command)
readChannel (Channel readVar _) = do
  stream <- takeMVar readVar
  Item val tail <- takeMVar stream
  putMVar readVar tail
  return val


loopReceiver :: Channel (Maybe Command) -> IO ()
loopReceiver chan = forever $ do
    cmd <- try (readChannel chan) :: IO (Either SomeException (Maybe Command) )
    case cmd of
        Left ex  -> do
            print ex
            return ()
        Right str -> do
            print "Received "
            return ()






















ext :: Maybe Command -> String
ext Nothing = "error"
ext (Just p) = JSON_Parser.order p ++ " <--> " ++ JSON_Parser.message p

logFile = "haskell-log.txt"

logging :: String -> IO ()
logging str = do
    withFile logFile AppendMode $ \h -> do
        hSetBuffering h (BlockBuffering Nothing)
        hPutStr h $ str ++ "\n"

-- receiver:: (Socket z t)  -> Channel (Maybe Command) -> IO()
receiver chan sock =
    forever $ do
        messageReceived <- recv sock 1024
        let message = str_to_json $ B.unpack messageReceived
        print $ ext message
        -- writeChannel chan message

sender chan sock =
        forever $ do
            cmd <- try (readChannel chan) :: IO (Either SomeException (Maybe Command) )
            case cmd of
                Left ex  -> do
                    print ex
                    return ()
                Right str -> do
                    send sock $ B.pack $ json_to_str $ Command "order" "sync"
                    print "sent "
                    return ()



    --send sock [] $ B.pack $ json_to_str $ Command "order" "sync"


createSocket :: FilePath -> IO Socket
createSocket path = do
  --removeIfExists path
  sock <- socket AF_UNIX Stream defaultProtocol
  connect sock $ SockAddrUnix path
  return sock

main :: IO ()
main = do
    sock <- createSocket "/tmp/test_sock.ipc"
    chan <- newChannel

    forkIO (receiver chan sock)

    send sock $ B.pack $ json_to_str $ Command "order" "sync"





    print "Connecting to python server..."




    -- writeChannel chan p


    --liftIO . logging $  "Received "  ++ (ext p)

    threadDelay 8000000
    print "exit"


