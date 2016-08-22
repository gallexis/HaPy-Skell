module Utils.Logging(
    logging
  ) 
where

import System.IO
import System.Posix


logFile = "../haskell-log.txt"

logging :: String -> IO ()
logging str = do
    withFile logFile AppendMode $ \h -> do
        hSetBuffering h (BlockBuffering Nothing)
        hPutStr h $ str ++ "\n"
