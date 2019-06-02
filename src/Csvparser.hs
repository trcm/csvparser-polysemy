{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE RankNTypes #-}
module Csvparser
  ( someFunc
  )
where
import           Prelude                 hiding ( readFile
                                                , lines
                                                , writeFile
                                                )
import           Data.ByteString                ( ByteString
                                                , readFile
                                                )
import           Data.ByteString.Char8          ( lines )
import           Polysemy
import           Polysemy.Input
import           Polysemy.Output
import           Polysemy.Error
import           Polysemy.Trace

import           Data.Function

data Record = Record ByteString deriving Show

data FileProvider m a where
  OpenFile :: FilePath -> FileProvider m ByteString

makeSem ''FileProvider

data Writer m a where
  WriteFile :: Show a => a -> Writer m ()

makeSem ''Writer

data RedisProvider m a where
  UpdateRedis :: a -> RedisProvider m ()
  GetRedis :: a -> RedisProvider m a

makeSem ''RedisProvider

-- Turn input effects into File provider effects
csvInput :: (Member FileProvider r) => FilePath -> Sem (Input (Maybe Record) ': r) a -> Sem r a
csvInput source m = do
  stream <- openFile source
  runListInput (Record <$> lines stream) m

-- actually use the file provider
localFileProvider :: Member (Lift IO) r => Sem (FileProvider ': r) a -> Sem r a
localFileProvider = interpret $ \case
  OpenFile fp -> sendM $ readFile fp

-- Take output effects and intepret them as writer effects
transformOutput :: (Show i) => Sem (Output i ': r) a -> Sem (RedisProvider ': (Writer ': r)) a
transformOutput = reinterpret2 $ \case
  Output i -> writeFile i >> updateRedis i

-- Handle writer effects
runWriter :: Show a => Member (Lift IO) r => Sem (Writer ': r) a -> Sem r a
runWriter = interpret $ \case
  WriteFile a -> sendM $ putStrLn $ show a

runRedis :: Member (Lift IO) r => Sem (RedisProvider ': r) a -> Sem r a
runRedis = interpret $ \case
  UpdateRedis a -> sendM $ do
    putStrLn "updating redis"

batch :: forall o r a . Int -> Sem (Output o ': r) a -> Sem (Output [o] ': r) a
batch batchSize m = case batchSize of
  0 -> raise $ runIgnoringOutput m 
  _ -> do
    (leftOver, a) <- runState ([] :: [o]) $ reinterpret2
      (\case
          Output o -> do
            acc <- get
            case length acc of
              n | n == batchSize -> do
                    output acc
                    put [o]
                | otherwise -> put (acc <> [o])
      )
      m
    when (length leftOver > 0) $ output leftOver
    pure a
  

-- Ingest sets up the initial input and ouput types
-- we need to interpret these somehow.
ingest :: (Member (Input (Maybe Record)) r, Member (Output Record) r) => Sem r ()
ingest = input @(Maybe Record) >>= \case
  Nothing     -> pure ()
  Just record -> do
    output @Record record
    ingest

someFunc :: IO ()
someFunc = do
  ingest & csvInput "test.csv" & localFileProvider & transformOutput & runRedis & runWriter & runM
