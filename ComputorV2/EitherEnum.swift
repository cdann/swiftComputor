//
//  resultOperator.swift
//  ComputorV2
//
//  Created by Celine DANNAPPE on 5/3/17.
//  Copyright © 2017 Celine DANNAPPE. All rights reserved.
//

import Foundation

enum Either<T>{
    case Fail(String)
    case Success(T)
}

precedencegroup EitherOperatorPrecedence {
    associativity: left
}

//infix operator &> : NodeOperatorPrecedence
infix operator <|> : EitherOperatorPrecedence
infix operator <+> : EitherOperatorPrecedence
infix operator >>- : EitherOperatorPrecedence
/*

func &> <T>(value: Option<T>, fc: ((T) -> Option<T>)) -> Option<T>{
    if case let .Success(n) = value{
        return fc(n)
    } else {
        return value
    }
}
*/


// If first value is a success, return the first, else return the second value
func <|> <T>(value: Either<T>, val2: Either<T>) -> Either<T>{
    if case .Fail = value , case .Success = val2 {
        return val2
    } else {
        return value
    }
}

//If one of the values is false returns false, else return the second value
func <+> <T, Q>(value: Either<T>, val2: Either<Q>) -> Either<Q>{
    if case let .Fail(s) = value{
        return .Fail(s)
    } else {
        return val2
    }
}

// Convert val into the type Q to return a Success in the type Q
func >>- <T, Q>(val: Either<T>, type:Q.Type) -> Either<Q>
{
  switch val {
  case let .Success(v):
    if let c = v as? Q {
        return .Success(c)
    }
    else {
        return .Fail("cannot convert \(v) in \(Q.self)")
    }
  case let .Fail(e):
      return .Fail(e)
  }
}


/*func getEitherError <T>(e:Either<T>) -> String
{
    switch e {
    case let .Fail(err):
        return err
    default:
        return ("getEitherError unreachable code")
    }
}*/
