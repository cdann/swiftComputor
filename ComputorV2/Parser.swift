//
//  Parser.swift
//  ComputorV2
//
//  Created by Celine DANNAPPE on 4/27/17.
//  Copyright © 2017 Celine DANNAPPE. All rights reserved.
//

import Foundation

enum ParseError : Error {
    case UnexpectedToken(unexpected: Token)
}

let precedenceTab: [String : Int] = [
    "+" : 20,
    "-" : 20,
    "*" : 30,
    "/" : 30,
]

/*
func parseComplex(tk:Tokenizer) -> Either<ComplexNode> {
    let nbNode = parseNumber(tk: tk)
    let i = tk.expect(search: Token.I)
    switch (i , nbNode) {
    case let (.Success(_), .Success(nb)):
        let ret = ComplexNode(factor: nb.val)
        return .Success(ret)
    case (.Success(_), .Fail(_)):
        let ret = ComplexNode(factor: 1)
        return .Success(ret)
    case let (.Fail(e), .Fail(_)):
        return .Fail(e)
    }
}

func parseParenth(tk:Tokenizer) -> Either<ValueNode> {
    
    let r = tk.expect(search: Token.LParenth) <+> parseValue(tk: tk)
    let rp = tk.expect(search: Token.RParenth)
    return rp <+> r
}

func parseOperation(tk:Tokenizer) throws -> Either<OperationNode> {
    let lhs = try parseValue(tk: tk)
    while true{
        if (tk.index > 0) {
            guard case let Token.Operator(op) = tk.consume() else {
                throw ParseError.UnexpectedToken(unexpected: Token.Operator(""))
            }
            let rhs = parseValue(tk:tk) <|> parseParenth(tk:tk)
        }
    }
}
*/



class Parser {
    let tk : Tokenizer
    
    init(tkn: Tokenizer) {
        tk = tkn
    }
    
    
    func parseLine() -> Either<LineNode> {
        let  tmp  = parseAssignation()
        print("## \(tmp)")
        return tmp <|> parseComputation()
    }
    
    func parseAssignation() -> Either<LineNode> {
        // funA(x) = 2*x+1
        
        /*
         let (len,lhs) =
         tk.consume(len)
         tk.expect(search: Token.Equal)
         let rhs = parseOperation(tk:tk)
         return (LineNode(lhs:lhs, rhs:rhs))
         */
        
        let startIndex = tk.index
        //lftexpr is either a func either a var in both case we cast the node in ExprNode
        let lftExpr : Either<ExprNode> = (parseFun(justIdentifier: true) >>- ExprNode.self) <|> (parseVariable() >>- ExprNode.self)
        if case let .Fail(err) = lftExpr {
            return tk.adjustIndexAndReturn(startIndex: startIndex, ret: .Fail(err))
        }
        let rghtExpr : Either<ExprNode> = tk.expect(search: .Equal) <+> ((parseOperation() >>- ExprNode.self)) <|> (parseValue() >>- ExprNode.self)
        print("%% \(rghtExpr) ")
        var ret : Either<LineNode>
        switch (lftExpr, rghtExpr) {
        case let (.Success(l), .Success(r)):
            if (!tk.end()) {
                print("Success \(l) \(r)")
                ret = .Fail ("Unexpected token \( tk.consume() ?? .Other("nil")) at the end of the line")
            } else {
                ret = .Success(LineNode(lhs: l, rhs:r))
            }
        case let (_, .Fail(err)):
            ret = Either.Fail(err)
        default:
            ret = .Fail("Unreachable")
        }
        return tk.adjustIndexAndReturn(startIndex: startIndex, ret: ret)
    }
    
    
    func parseComputation() -> Either<LineNode> {
        return .Success(LineNode(lhs: NumberNode(val:23.5), rhs: VarNode(name:"bla")))
    }
    
    func parseFun(justIdentifier:Bool = false)  -> Either<FuncNode> {
        //    print("yop")
        var ret : Either<FuncNode>
        let startIndex = tk.index
        
        let id = parseIdentifier()
        let checkVar = justIdentifier ? {() -> Either<ValueNode> in self.parseVariable() >>- ValueNode.self} : parseValue
        let variable = tk.expect(search: Token.LParenth) <+> checkVar()
        let parenth = tk.expect(search: Token.RParenth)
        if case let .Success(st) = id , case let .Success(v) = variable, case .Success(true) = parenth{
            ret = .Success(FuncNode(name:st, variable: v))
        }
        else if case let .Fail(e) = (id <+> variable){
            ret = .Fail(e)
        }
        else {
            ret = .Fail("Unreachable")
        }
        return tk.adjustIndexAndReturn(startIndex: startIndex, ret: ret)
    }
    
    func parseVariable() -> Either<VarNode> {
        var ret : Either<VarNode>
        let startIndex = tk.index
        
        let id = parseIdentifier()
        switch id {
        case let .Success(node):
            ret = .Success(VarNode(name: node))
        case let .Fail(str):
            ret = .Fail(str)
        }
        return tk.adjustIndexAndReturn(startIndex: startIndex, ret: ret)
    }
    
    func parseIdentifier() -> Either<String> {
        
        let r : Token? = tk.consume()
        var ret : Either<String>
        if let id = r, case let Token.Identifier(st) = id {
            ret = .Success(st)
            //print(ret)
        }
        else if r == nil {
            ret = .Fail("an Identifier is missing")
        }
        else {
            ret = .Fail("Unexpected Token \(r!) while we expect an Identifier")
        }
        return tk.adjustIndexAndReturn(startIndex: tk.index - 1, ret: ret)
    }
    
    func parseNumber() -> Either<NumberNode> {
        let startIndex = tk.index
        let r = tk.consume()
        guard let nb = r, case let .Number(n) = nb else {
            let ret : Either<NumberNode> = .Fail("Unexpected Token \(r ?? .Other("nil")) while we expect a Number")
            return tk.adjustIndexAndReturn(startIndex: startIndex, ret: ret)
        }
        return .Success(NumberNode(val: n))
    }
    
    /*
     6 + 5 * 2 + 9 / 3
     
     prev : 6 +
     + vs * = * donc current_ope avant prev
        prev = 5 *
        * vs + = * donc prev
            prev (5 * 2) +
            + vs / = / donc current ope avant prev
            -> (9 / 3)
        -> (5 * 2) + (9 / 3)
     -> 6 + (5 * 2) + (9 / 3)
     
     cas 1 : prevOp >= currOp 3 * 4 + 6 >>>>> left = noeud prevExpr prevOp et currExpr. retourne parseFollowingOperation( left, currOp)
     cas 2 : prevOp < currOp 5 + 6 * 7>>>>> right = parseFollowingOperation (currExpr, currOp) retourne noeud prevExpr prevOp right
     let precedenceTab: [String : Int] = [
     "+" : 20,
     "-" : 20,
     "*" : 30,
     "/" : 30,
     ]
     */
    
    func parseOperation(prevExpr:ExprNode? = nil , prevOp: String? = nil) -> Either<OperationNode> {
        let startIndex = tk.index
        let currExpr = (parseValue() >>- ExprNode.self)
        guard case let .Success(curr) = currExpr else {
          return tk.adjustIndexAndReturn(startIndex: startIndex, ret: currExpr >>- OperationNode.self)
        }
        if tk.end() && prevOp != nil {
 let lastNode = OperationNode(ope: prevOp!, lhs: prevExpr!, rhs: curr)
 return tk.adjustIndexAndReturn(startIndex: startIndex, ret: .Success(lastNode))
           /* print("~~~~ \(String(describing: prevExpr)) \(String(describing: prevOp))")
            return .Success(prevExpr) >>- OperationNode.self*/
        }
        let tkop = tk.consume()
        guard let ope = tkop, case let .Operator(op) = ope else {
            return tk.adjustIndexAndReturn(startIndex: startIndex, ret: Either<OperationNode>.Fail("Unexpected Token \(tkop ?? .Other("nil")) while we expect an Operator \(tk.index)"))
        }
        var ret : Either<OperationNode>
        guard let prevE = prevExpr, let prevO = prevOp else {                   // premier passage
            let nextExpr =  (parseOperation(prevExpr: curr, prevOp: op) >>- ExprNode.self) <|> (parseValue() >>- ExprNode.self)
            switch  nextExpr {
            case let .Success(nxt):
                ret = .Success(nxt as! OperationNode)
            case let .Fail(err):
                ret = .Fail(err)
            }
            return tk.adjustIndexAndReturn(startIndex: startIndex, ret: ret)
        }
        if (precedenceTab[prevO]! >= precedenceTab[op]!) {     //priorite a droite
            let lNode = OperationNode(ope: prevO, lhs: prevE, rhs: curr)
            ret = parseOperation(prevExpr: lNode , prevOp: op)
        
        } else {                                               //priorite a gauche
            let rNode = parseOperation(prevExpr: curr, prevOp: op)
            switch rNode{
            case let .Success(r):
                ret = .Success(OperationNode(ope: prevO, lhs: prevE, rhs: r))
            case let .Fail(err):
                ret = .Fail(err)
            }
            
        }
        
        return tk.adjustIndexAndReturn(startIndex: startIndex, ret: ret)
    }
    
    /*func parseOperation() -> Either<OperationNode> {
        print("$$$$$$start parse ope \(tk.index)")
        let startIndex = tk.index
        let lftExpr = (parseValue() >>- ExprNode.self) /*<|> (parseOperation(tk: tk) >>- ExprNode.self)*/
        guard case let .Success(l) = lftExpr else {
            return tk.adjustIndexAndReturn(startIndex: startIndex, ret: lftExpr >>- OperationNode.self)
        }
        let tkop = tk.consume()
        guard let ope = tkop, case let .Operator(op) = ope else {
            return tk.adjustIndexAndReturn(startIndex: startIndex, ret: Either<OperationNode>.Fail("Unexpected Token \(tkop) while we expect an Operator"))
        }
        let rghExpr =  (parseFollowingOperation(prevExpr: l, prevOp: op) >>- ExprNode.self) <|>  (parseValue() >>- ExprNode.self)
        var ret : Either<OperationNode>
        switch  rghExpr {
        case let .Success(r):
            ret = .Success(OperationNode(ope:op, lhs:l, rhs:r))
        case let .Fail(err):
            ret = .Fail(err)
        }
        return tk.adjustIndexAndReturn(startIndex: startIndex, ret: ret)
    }*/
    
    
    func parseValue() -> Either<ValueNode> {
        let startIndex = tk.index
        //print("val id:\(tk.index) tk:")
        
        let ret = /*parseComplex(tk:tk) <|>*/ (parseNumber() >>- ValueNode.self) <|> (parseVariable() >>- ValueNode.self) //<|> (parseFun(tk:tk) >>- ValueNode.self) // <|> parseMatrice\
        
        return tk.adjustIndexAndReturn(startIndex: startIndex, ret: ret)
    }

    
    
 
 
 }
 

