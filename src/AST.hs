{-# OPTIONS -fglasgow-exts #-}

{-
    Abstract syntax tree.

    Tall ships and tall kings
    Three times three.
    What brought they from the foundered land
    Over the flowing sea?
    Seven stars and seven stones
    And one white tree.
-}

module AST where
import Internals

import Context

type Ident = String

instance Show (a -> b) where
    show f = "sub { ... }"

class Context n where
    vCast :: Val -> n
    vCast (VRef v)      = vCast v
    vCast (VPair _ v)   = vCast v
    vCast (VArray (MkArray v))    = vCast $ VList v
    vCast v             = doCast v
    castV :: n -> Val
    castV v = error $ "cannot cast into Val"
    doCast :: Val -> n
    doCast v = error $ "cannot cast from Val: " ++ (show v)
    fmapVal :: (n -> n) -> Val -> Val
    fmapVal f = castV . f . vCast

instance Context (Val, Val) where
    castV (x, y)        = VPair x y
    vCast (VPair x y)   = (x, y)
    vCast (VRef v)      = vCast v
    vCast v             = case vCast v of
        [x, y]  -> (x, y)
        other   -> error $ "cannot cast into (Val, Val): " ++ (show v)

instance Context VHash where
    castV = VHash
    vCast x = MkHash $ listToFM (map vCast $ vCast x) 

instance Context VSub where
    castV = VSub
    doCast (VSub b) = b

instance Context VBool where
    castV = VBool
    doCast (VJunc j l) = juncToBool j l
    doCast (VBool b)   = b
    doCast VUndef      = False
    doCast (VStr "")   = False
    doCast (VStr "0")  = False
    doCast (VInt 0)    = False
    doCast (VRat 0)    = False
    doCast (VNum 0)    = False
    doCast (VList [])  = False
    doCast _           = True

juncToBool :: JuncType -> Set Val -> Bool
juncToBool JAny     = (True `elementOf`) . mapSet vCast
juncToBool JAll     = not . (False `elementOf`) . mapSet vCast
juncToBool JNone    = not . (True `elementOf`) . mapSet vCast
juncToBool JOne     = (1 ==) . length . filter vCast . setToList

instance Context VInt where
    castV = VInt
    doCast (VInt i)     = i
    doCast (VStr s)
        | ((n, _):_) <- reads s = n
        | otherwise             = 0
    doCast x            = round (vCast x :: VNum)

instance Context VRat where
    castV = VRat
    doCast (VInt i)     = i % 1
    doCast (VRat r)     = r
    doCast x            = approxRational (vCast x :: VNum) 1

instance Context VNum where
    castV = VNum
    doCast VUndef       = 0
    doCast (VBool b)    = if b then 1 else 0
    doCast (VInt i)     = fromIntegral i
    doCast (VRat r)     = realToFrac r
    doCast (VNum n)     = n
    doCast (VStr s)
        | ((n, _):_) <- reads s = n
        | otherwise             = 0
    doCast (VList l)    = fromIntegral $ length l
    doCast x            = error $ "cannot cast: " ++ (show x)

instance Context VComplex where
    castV = VComplex
    doCast x            = (vCast x :: VNum) :+ 0

instance Context VStr where
    castV = VStr
    vCast VUndef        = ""
    vCast (VStr s)      = s
    vCast (VBool b)     = if b then "1" else "0"
    vCast (VInt i)      = show i
    vCast (VRat r)      = showNum $ realToFrac r
    vCast (VNum n)      = showNum n
    vCast (VList l)     = unwords $ map vCast l
    vCast (VRef v)      = vCast v
    vCast (VPair k v)   = vCast k ++ "\t" ++ vCast v ++ "\n"
    vCast x             = error $ "cannot cast: " ++ (show x)

showNum x
    | (i, ".0") <- break (== '.') str
    = i -- strip the trailing ".0"
    | otherwise = str
    where
    str = show x 

instance Context VArray where
    castV = VArray
    vCast x = MkArray (vCast x) 

instance Context VJunc where
    castV = VJunc JAny
    vCast x = mkSet (vCast x)

instance Context VList where
    castV = VList
    vCast (VList l)     = l
    vCast (VPair k v)   = [k, v]
    vCast (VRef v)      = vCast v
    vCast v             = [v]

instance Context (Maybe a) where
    vCast VUndef        = Nothing
    vCast _             = Just undefined

instance Context Int   where doCast = intCast
instance Context Word  where doCast = intCast
instance Context Word8 where doCast = intCast
instance Context [Word8] where doCast = map (toEnum . ord) . vCast

type VScalar = Val
type VJunc = Set Val

instance Context VScalar where
    vCast = id
    castV = id

strRangeInf s = (s:strRangeInf (strInc s))

strRange s1 s2
    | s1 == s2              = [s2]
    | length s1 > length s2 = []
    | otherwise             = (s1:strRange (strInc s1) s2)

strInc []       = "1"
strInc "z"      = "aa"
strInc "Z"      = "AA"
strInc "9"      = "10"
strInc str
    | x == 'z'  = strInc xs ++ "a"
    | x == 'Z'  = strInc xs ++ "A"
    | x == '9'  = strInc xs ++ "0"
    | otherwise = xs ++ [charInc x]
    where
    x   = last str
    xs  = init str

charInc x   = chr $ 1 + ord x

intCast x   = fromIntegral (vCast x :: VInt)

type VBool = Bool
type VInt  = Integer
type VRat  = Rational
type VNum  = Double
type VComplex = Complex VNum
type VStr  = String
type VList = [Val]
newtype VArray = MkArray [Val] deriving (Show, Eq, Ord)
newtype VHash  = MkHash (FiniteMap Val Val) deriving (Show, Eq, Ord)

instance (Show a, Show b) => Show (FiniteMap a b) where
    show fm = show (fmToList fm)

data Val
    = VUndef
    | VBool     VBool
    | VInt      VInt
    | VRat      VRat
    | VNum      VNum
    | VComplex  VComplex
    | VStr      VStr
    | VList     VList
    | VArray    VArray
    | VHash     VHash
    | VRef      Val
    | VPair     Val Val
    | VSub      VSub
    | VBlock    Exp
    | VJunc     JuncType VJunc
    | VError    VStr Exp
    deriving (Show, Eq, Ord)

data SubType = SubMethod | SubRoutine | SubBlock
    deriving (Show, Eq, Ord)

data Param = Param
    { isInvocant    :: Bool
    , isSlurpy      :: Bool
    , isOptional    :: Bool
    , isNamed       :: Bool
    , paramName     :: String
    , paramContext  :: Cxt
    , paramDefault  :: Exp
    }
    deriving (Show, Eq, Ord)

type Params = [Param]

data VSub = Sub
    { isMulti       :: Bool
    , subType       :: SubType
    , subAssoc      :: String
    , subParams     :: Params
    , subReturns    :: Cxt
    , subFun        :: Exp
    }
    deriving (Show, Eq, Ord)

data Trait
    = TScalar   Val
    | TArray    Val
    | THash     Val

data JuncType = JAll | JAny | JOne | JNone
    deriving (Show, Eq, Ord)

instance Eq ([Val] -> Val)
instance Ord ([Val] -> Val)
instance (Ord a) => Ord (Set a)
instance (Show a) => Show (Set a) where
    show x = show $ setToList x
instance Ord VComplex where {- ... -}
instance (Ord a, Ord b) => Ord (FiniteMap a b)

type Var = String

data Exp
    = App String [Exp] [Exp]
    | Syn String [Exp]
    | Prim ([Val] -> Val)
    | Val Val
    | Var Var SourcePos
    | Parens Exp
    | NonTerm SourcePos
    deriving (Show, Eq, Ord)

extractExp :: Exp -> ([Exp], [String]) -> ([Exp], [String])
extractExp exp (exps, vs) = (exp':exps, vs')
    where
    (exp', vs') = extract (exp, vs)

extract :: (Exp, [String]) -> (Exp, [String])
extract ((App n invs args), vs) = (App n invs' args', vs'')
    where
    (invs', vs')  = foldr extractExp ([], vs) invs
    (args', vs'') = foldr extractExp ([], vs') args
extract ((Syn n exps), vs) = (Syn n exps', vs')
    where
    (exps', vs') = foldr extractExp ([], vs) exps
extract ((Var name pos), vs)
    | (sigil:'^':identifer) <- name
    , name' <- (sigil : identifer)
    = (Var name' pos, insert name' vs)
    | name == "$_"
    = (Var name pos, insert name vs)
    | otherwise
    = (Var name pos, vs)
extract ((Parens exp), vs) = ((Parens exp'), vs')
    where
    (exp', vs') = extract (exp, vs)
extract other = other

cxtOf '*' '$'   = "List"
cxtOf '*' '@'   = "List"
cxtOf _   _     = "Scalar"

buildParam cxt sigil name exp = Param
    { isInvocant    = False
    , isSlurpy      = (sigil == "*")
    , isOptional    = (sigil ==) `any` ["?", "+"]
    , isNamed       = (null sigil || head sigil /= '+')
    , paramName     = name
    , paramContext  = if null cxt then defaultCxt else cxt
    , paramDefault  = exp
    }
    where
    sig = if null sigil then ' ' else head sigil
    defaultCxt = cxtOf sig (head name) 

defaultArrayParam   = buildParam "" "*" "@_" (Val VUndef)
defaultHashParam    = buildParam "" "*" "%_" (Val VUndef)
defaultScalarParam  = buildParam "" "*" "$_" (Val VUndef)
