//
//  LineStructs.swift
//  ComputorV2
//
//  Created by Celine DANNAPPE on 4/27/17.
//  Copyright © 2017 Celine DANNAPPE. All rights reserved.
//

import Foundation

/*struct VarAssignation {
    let variable : String
    let value :Float
}

struct OperationNode {
    let op: String
    let lhs:OperationNode
}*/

protocol Node : CustomStringConvertible {}
protocol ExprNode : Node {}
protocol ValueNode : ExprNode {
}

struct ComplexNode : ValueNode {
    let factor : Float
    var description: String {
        return "Complex \(factor)i"
    }
}

struct VarNode : ValueNode {
    let name : String
    var description: String {
        return "Var \(name)"
    }
}

struct FuncNode: ValueNode {
    let name : String
    let variable : ValueNode?
    var description: String {
        return "Func \(name)"
    }
}

struct NumberNode : ValueNode {
    let val : Float
    var description: String {
        return "Number \(val)"
    }
}

struct MatriceNode : ValueNode {
    let tab : [[Float]]
    var description: String {
        return "Matrice \(tab)"
    }
}

struct OperationNode : ExprNode {
    let ope : String
    let lhs : ExprNode
    let rhs : ExprNode
    var description: String {
        return "ope \(lhs) \(ope) \(rhs)"
    }
}

struct LineNode : Node {
    let lhs : ExprNode
    let rhs : ExprNode?
    var description: String {
        return "Line \(lhs) = \(rhs)"
    }
}
