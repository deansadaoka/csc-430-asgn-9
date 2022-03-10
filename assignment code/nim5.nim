import sequtils
import std/strformat

# Represents ExprC datatype with numC, idC, appC, lamC, ifC, stringC
type
    ExprTypes = enum
        numC,
        idC,
        appC,
        lamC,
        ifC,
        stringC

    ExprC = ref object of RootObj
        case exp: ExprTypes
        of numC: num: float
        of idC: sym: string
        of appC:
            fn: ExprC
            args: seq[ExprC]
        of lamC:
            params: seq[string]
            body: ExprC
        of ifC: 
            cond: bool
            then, elseArg: ExprC
        of stringC: str: string


# Represents Value datatype with Real, Boolean, String, closV, primV
# Environment and Binding included
type
    ValTypes = enum
        numV,
        boolV,
        strV,
        closV,
        primV

    Value = ref object of RootObj
        case valType: ValTypes
        of numV: num: float
        of boolV: boolArg: bool
        of strV: str: string
        of closV:
            params: seq[string]
            body: ExprC
            env: seq[tuple[name: string, val: Value]]
        of primV: operator: string


# Adds args to env
proc append_env(env: seq[tuple[name: string, val: Value]], params: seq[string], fun_args: seq[Value]): seq[tuple[name: string, val: Value]] = 
    if params.len == 0:
        return env
    elif params.len == 1:
        var tempBind = @[(params[0], fun_args[0])]
        return concat(tempBind, env)
    else:
        var tempBind = @[(params[0], fun_args[0])]
        return concat(tempBind, append_env(env, params[1 .. (params.len - 1)], fun_args[1 .. (fun_args.len - 1)]))


proc interp(exp: ExprC, env: seq[tuple[name: string, val: Value]]) : Value

# primV helper function, finds and evaluates primV operands
proc primV_interp(operator: string, args: seq[ExprC], env: seq[tuple[name: string, val: Value]]) : Value = 
    var arg_one = interp(args[0], env)
    var arg_two = interp(args[1], env)
    if operator == "+" and arg_one.valType == numV and arg_two.valType == numV:
        return Value(valType: numV, num: arg_one.num + arg_two.num)
    elif operator == "-" and arg_one.valType == numV and arg_two.valType == numV:
        return Value(valType: numV, num: arg_one.num - arg_two.num)
    elif operator == "*" and arg_one.valType == numV and arg_two.valType == numV:
        return Value(valType: numV, num: arg_one.num * arg_two.num)
    elif operator == "/" and arg_one.valType == numV and arg_two.valType == numV:
        if arg_two.num == 0:
            echo "primV_interp: TULI5: cannot divide by zero"
        else:
            return Value(valType: numV, num: arg_one.num / arg_two.num)
    elif operator == "<=" and arg_one.valType == numV and arg_two.valType == numV:
        return Value(valType: boolV, boolArg: arg_one.valType <= arg_two.valType)
    elif operator == "equal" and arg_one.valType == numV and arg_two.valType == numV:
        return Value(valType: boolV, boolArg: arg_one.num == arg_two.num)
    else:
        echo "primV_interp: TULI5: incorrect arguments ~e"


# Interprets the given expression, using the list of funs to resolve applications
proc interp(exp: ExprC, env: seq[tuple[name: string, val: Value]]) : Value = 
    case exp.exp
    of numC: 
        return Value(valType: numV, num: exp.num)
    of stringC: 
        return Value(valType: strV, str: exp.str)
    of idC: 
        echo "(lookup id env) or lookup(exp.sym, env)"
    of ifC:
        case exp.cond
        of true:
            return interp(exp.then, env)
        of false:
            return interp(exp.elseArg, env)
        else:
            echo "if condition not a boolean"
    of appC:
        var tempVal = interp(exp.fn, env)
        case tempVal.valType
        of closV:
            var newArgs: seq[Value]
            for i in 0 .. exp.args.len - 1:
                newArgs.add(interp(exp.args[i], env))
            if newArgs.len == tempVal.params.len:
                return interp(tempVal.body, append_env(tempVal.env, tempVal.params, newArgs))
            else:
                echo fmt"TULI5: differing param and arg count {tempVal.params.len} {exp.args.len}"
        of primV:
            return primV_interp(tempVal.operator, exp.args, env)
        else:
                echo "put else shit here"
    of lamC:
        return Value(valType: closV, params: exp.params, body: exp.body, env: env)
    return


# Interp Test Cases
var exp1 = ExprC(exp: stringC, str: "fat")
var env1 = @[("hello", Value(valType: numV, num: 20)), ("world", Value(valType: numV, num: 10))]
var ret1 = interp(exp1, env1)
assert ret1.str == "fat"

var exp2 = ExprC(exp: ifC, cond: false, then: ExprC(exp: stringC, str: "this is true"), elseArg: ExprC(exp: stringC, str: "this is false"))
var ret2 = interp(exp2, env1)
assert ret2.str == "this is false"

var exp3 = ExprC(exp: appC, 
    fn: ExprC(exp: lamC, params: @["x", "y"], body: ExprC(exp: stringC, str: "three")), 
    args: @[ExprC(exp: stringC, str: "one"), ExprC(exp: stringC, str: "two")])
var ret3 = interp(exp3, env1)
doAssert ret3.str == "three"

var exp4 = primV_interp("+", @[ExprC(exp: numC, num: 420), ExprC(exp: numC, num: 69)], env1)
assert exp4.num == 489

var exp5 = primV_interp("-", @[ExprC(exp: numC, num: 420), ExprC(exp: numC, num: 69)], env1)
assert exp5.num == 351

var exp6 = primV_interp("*", @[ExprC(exp: numC, num: 420), ExprC(exp: numC, num: 69)], env1)
assert exp6.num == 28_980

var exp7 = primV_interp("/", @[ExprC(exp: numC, num: 420), ExprC(exp: numC, num: 5)], env1)
assert exp7.num == 84

var exp8 = primV_interp("equal", @[ExprC(exp: numC, num: 420), ExprC(exp: numC, num: 69)], env1)
assert exp8.boolArg == false

var exp9 = primV_interp("<=", @[ExprC(exp: numC, num: 420), ExprC(exp: numC, num: 69)], env1)
assert exp9.boolArg == true


# ExprC Test Cases
let expr1 = ExprC(exp: numC, num: 10.2)
assert expr1.num == 10.2

let expr2 = ExprC(exp: idC, sym: "hello")
assert expr2.sym == "hello"

let expr3 = ExprC(exp: appC, fn: ExprC(exp: idC, sym: "-"), args: @[ExprC(exp: numC, num: 4), ExprC(exp: numC, num: 2)])
assert expr3.fn.sym == "-"

var expr4 = ExprC(exp: lamC, params: @["hello", "world"], body: ExprC(exp: stringC, str: "hey"))
doAssert expr4.params == @["hello", "world"]

let expr5 = ExprC(exp: ifC, cond: false, then: ExprC(exp: numC, num: 5), elseArg: ExprC(exp: numC, num: 10))
assert expr5.then.num == 5
assert expr5.elseArg.num == 10
assert expr5.cond == false
        
# https://docs.w3cub.com/nim/tut2

# https://nim-lang.org/docs/tut2.html

# https://nim-lang.org/docs/tut1.html#lexical-elements-string-and-character-literals

# https://nim-by-example.github.io/case/

# ;; Interprets the given expression, using the list of funs to resolve applications
# (define (interp [exp : ExprC] [env : Environment]) : Value
#   (match exp
#     [(numC n) n]
#     [(stringC s) s]
#     [(idC id) (lookup id env)]
#     [(ifC i t e) (define cond (interp i env))
#                  (match cond
#                    [(? boolean?) (if cond (interp t env) (interp e env))]
#                    [_ (error 'interp "TULI5: missing condition bool statement ~e" cond)])]
#     [(appC f a) (match (interp f env)
#                 [(closV params body clos-env)
#                  (define eval-args (map (lambda ([x : ExprC]) (interp x env)) a))
#                  (if (equal? (length params) (length eval-args))
#                      (interp body (append-env clos-env params eval-args))
#                      (error 'interp
#                             "TULI5: differing param and arg count ~e ~e"
#                             (length params) (length eval-args)))]
#                 [(primV op) (primV-interp op a env)]
#                 [badf (error 'interp "TULI5: not a valid function ~e" badf)])]
#     [(lamC params body) (closV params body env)]))





# (define (lookup [for : Symbol] [env : Environment]) : Value
#   (match env
#     ['() (error 'lookup "TULI5: name not found ~e" for)]
#     [(cons first rest) (if (equal? for (bind-name first)) (bind-val first)
#            (lookup for rest))]))




# (define extend-env cons)

# ;; Adds args to env
# (define (append-env [env : Environment] [params : (Listof Symbol)]
#                     [fun-args : (Listof Value)]) : (Listof bind)
#   (match params
#     ['() env]
#     [_ (extend-env
#         (bind (first params) (first fun-args))
#         (append-env env (rest params) (rest fun-args)))]))




# ;; primV helper function, finds and evaluates primV operands
# (define (primV-interp [op : Symbol] [args : (Listof ExprC)] [env : Environment]) : Value
#   (define arg-one (interp (first args) env))
#   (define arg-two (interp (second args) env))
#   (match* (op arg-one arg-two)
#     [('+ (? real?) (? real?)) (+ arg-one arg-two)]
#     [('- (? real?) (? real?)) (- arg-one arg-two)]
#     [('* (? real?) (? real?)) (* arg-one arg-two)]
#     [('/ (? real?) (? real?)) (divide arg-one arg-two)]
#     [('<= (? real?) (? real?)) (lessthanequal arg-one arg-two)]
#     [('equal? arg-one arg-two) (primV-equal? arg-one arg-two)]
#     [(_ _ _) (error 'primV-interp "TULI5: incorrect arguments ~e" op)]))

