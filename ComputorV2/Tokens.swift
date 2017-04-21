//
//  Tokens.swift
//  ComputorV2
//
//  Created by Celine DANNAPPE on 4/26/17.
//  Copyright © 2017 Celine DANNAPPE. All rights reserved.
//

import Foundation

enum Token {
    case Number(Float)
    case LBracket
    case RBracket
    case LParenth
    case RParenth
    case Comma
    case SemiColon
    case Identifier(String)
    case Operator(String)
    case Equal
    case Other(String)
}

func createRegex (pattern :String) -> NSRegularExpression{
        return try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
}

typealias TokenGenerator = (String) -> Token?
let tokenList: [(String, TokenGenerator)] = [
    ("^[ \t\n]", { _ in nil }),
    ("^[a-zA-Z][a-zA-Z0-9]*", { .Identifier($0) }),
    ("^[0-9.]+", { (r: String) in .Number((r as NSString).floatValue) }),
    ("^[+\\*/\\-%]|\\*\\*", {.Operator($0)}),
    ("^\\(", { _ in .LParenth }),
    ("^\\)", { _ in .RParenth }),
    ("^\\[", { _ in .LBracket }),
    ("^\\]", { _ in .RBracket }),
    ("^,", { _ in .Comma }),
    ("^;", { _ in .SemiColon }),
    ("^=", { _ in .Equal }),
]
