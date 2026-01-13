# Converted from Python to NoodleCore
# Original file: src

#!/usr/bin/env python3
# """
# Script om parameter-types in visit-methoden van semantic_analyzer.py te corrigeren.
# """

import re

# Lees het bestand
file.open
content = f.read()

# Vervang alle ongeldige typeannotaties voor de parameters van visit-methoden

# Regex om alle visit-methode parameter types te vinden
# pattern = r"def ([a-z_]+_stmt|visit_[a-z_]+)\(self, node: ([A-Za-z0-9_]+)\):"

# Detectie van welke types we moeten gebruiken
type_map = {
#     "IfStmt": "IfStmtNode",
#     "WhileStmt": "WhileStmtNode",
#     "ForStmt": "ForStmtNode",
#     "FuncDef": "FuncDefNode",
#     "Literal": "LiteralExprNode",
#     "AwaitExpr": "AwaitExprNode",
#     "Identifier": "IdentifierExprNode",
#     "BinaryExpr": "BinaryExprNode",
#     "UnaryExpr": "UnaryExprNode",
#     "Call": "CallExprNode",
#     "Assignment": "AssignStmtNode",
#     "TryStmt": "TryStmtNode",
#     "RaiseStmt": "RaiseStmtNode",
#     "ImportStmt": "ImportStmtNode",
#     "PythonCallExpr": "PythonCallExpr",
#     "MatrixMethodCall": "MatrixMethodCall",
# }

# By substitutie van de types
for old_type, new_type in type_map.items()
    content = re.sub(r"\b{}\b(?!\w)".format(re.escape(old_type)), new_type, content)

# Einde van het script:
# Bijvoorbeeld:
# def visit_if_stmt(self, node: IfStmt): -def visit_if_stmt(self, node): IfStmtNode):

# Schrijf het bestand terug
file.open
    f.write(content)

print "Typeannotaties zijn bijgewerkt."
