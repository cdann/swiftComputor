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

precedencegroup NodeOperatorPrecedence {
    associativity: left
}
//precedencegroup NodeOperatorPrecedence {
//    associativity: left
//}
//infix operator &> : NodeOperatorPrecedence
infix operator <|> : NodeOperatorPrecedence
infix operator <+> : NodeOperatorPrecedence
infix operator >>- : NodeOperatorPrecedence
/*

func &> <T>(value: Option<T>, fc: ((T) -> Option<T>)) -> Option<T>{
    if case let .Success(n) = value{
        return fc(n)
    } else {
        return value
    }
}
*/


func <|> <T>(value: Either<T>, val2: Either<T>) -> Either<T>{
    if case .Fail = value , case .Success = val2 {
        return val2
    } else {
        return value
    }
}

func <+> <T, Q>(value: Either<T>, val2: Either<Q>) -> Either<Q>{
    if case let .Fail(s) = value{
        return .Fail(s)
    } else {
        return val2
    }
}

func >>- <T, Q>(val: Either<T>, type:Q.Type) -> Either<Q>
{
  switch val {
  case let .Success(v):
      return .Success(v as! Q)
  case let .Fail(e):
      return .Fail(e)
  }
}


