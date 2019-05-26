{-# LANGUAGE TemplateHaskell #-}

module Csvparser
  ( someFunc
  )
where
import Prelude hiding (readFile, lines, writeFile)
import Data.ByteString (ByteString, readFile)
import Data.ByteString.Char8 (lines)
import           Polysemy
import           Polysemy.Input
import           Polysemy.Output
import Data.Function 

data Record = Record ByteString deriving Show

data FileProvider m a where
  OpenFile :: FilePath -> FileProvider m ByteString

makeSem ''FileProvider

data Writer m a where
  WriteFile :: Show a => a -> Writer m ()

makeSem ''Writer

-- Turn input effects into File provider effects
csvInput :: Member FileProvider r => FilePath -> Sem (Input (Maybe Record) ': r) a -> Sem r a
csvInput source m = do
  stream <- openFile source
  runListInput (Record <$> lines stream) m

-- actually use the file provider
localFileProvider :: Member (Lift IO) r => Sem (FileProvider ': r) a -> Sem r a
localFileProvider = interpret $ \case
  OpenFile fp -> sendM $ readFile fp

-- Take output effects and intepret them as writer effects
consoleOutput :: (Show i, Member Writer r) => Sem (Output i ': r) a -> Sem r a
consoleOutput = interpret $ \case
  Output i -> writeFile i

-- Handle writer effects
runWriter :: Show a => Member (Lift IO) r => Sem (Writer ': r) a -> Sem r a
runWriter = interpret $ \case
  WriteFile a -> sendM $ putStrLn $ show a

-- Ingest sets up the initial input and ouput types
-- we need to interpret these somehow.
ingest
  :: (Member (Input (Maybe Record)) r, Member (Output Record) r) => Sem r ()
ingest = input @(Maybe Record) >>= \case
  Nothing     -> pure ()
  Just record -> do
    output @Record record
    -- output ProcessedRecordStat
    ingest

someFunc :: IO ()
someFunc = ingest
           & csvInput "test.csv"
           & localFileProvider
           & consoleOutput
           & runWriter
           & runM

