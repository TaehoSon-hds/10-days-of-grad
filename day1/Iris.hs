
import Numeric.LinearAlgebra as LA

-- New weights
newW :: (Int, Int) -> IO (Matrix Double)
newW (nin, nout) = do
    let k = sqrt (1.0 / fromIntegral nin)
    w <- randn nin nout
    return (cmap (k *) w)

-- Transformations
loss :: (Container c e, Num e, Num (c e)) => c e -> c e -> e
loss y tgt = sumElements $ cmap (^ (2::Int)) (y - tgt)

sigmoid :: Matrix Double -> Matrix Double
sigmoid = cmap f
  where
    f x = recip $ 1.0 + exp (-x)

-- Their gradients
sigmoid' :: Matrix Double -> Matrix Double -> Matrix Double
sigmoid' x dY = dY * y * (ones - y)
   where
    y = sigmoid x
    ones = rows y >< cols y $ repeat 1.0

linear' :: (Fractional t, Numeric t) => Matrix t -> Matrix t -> Matrix t
linear' x dy = recip m `LA.scale` (tr' x LA.<> dy)
  where
    m = fromIntegral $ rows x

loss' :: (Container c b, Num b, Num (c b)) => c b -> c b -> c b
loss' y tgt = cmap (* 2) (y - tgt)

-- Building NN
forward :: Matrix Double -> Matrix Double -> [Matrix Double]
forward x w1 = [h, y]
  where
    h = x LA.<> w1
    y = sigmoid h

descend :: Num a => (a -> a) -> Int -> a -> a -> [a]
descend gradF iterN gamma x0 = take iterN (iterate step x0)
  where
    step x = x - gamma * gradF x

grad :: (Matrix Double, Matrix Double) -> Matrix Double -> Matrix Double
grad (x, y) w1 = dW1
  where
    [h, y_pred] = forward x w1
    dE = loss' y_pred y
    dY = sigmoid' h dE
    dW1 = linear' x dY

main :: IO ()
main = do
  dta <- loadMatrix "day1/iris_x.dat"
  tgt <- loadMatrix "day1/iris_y.dat"

  let (nin, nout) = (4, 3)

  w1_rand <- newW (nin, nout)

  let epochs = 500
  let w1 = last $ descend (grad (dta, tgt)) epochs 0.01 w1_rand

      [_, y_pred0] = forward dta w1_rand
      [_, y_pred] = forward dta w1

  putStrLn $ "Initial loss " ++ show (loss y_pred0 tgt)
  putStrLn $ "Loss after training " ++ show (loss y_pred tgt)

  putStrLn "Some predictions by an untrained network:"
  print $ takeRows 5 y_pred0

  putStrLn "Some predictions by a trained network:"
  print $ takeRows 5 y_pred

  putStrLn "Targets"
  print $ takeRows 5 tgt
