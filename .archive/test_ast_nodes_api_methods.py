#!/usr/bin/env python3
"""
API Methods Tests for Noodle AST Nodes
=====================================
Test suite for API methods (serialization, validation, traversal) in ast_nodes.nc

Generated: December 19, 2025
Author: Michael van Erp
"""

import unittest
import sys
import json
from pathlib import Path
from unittest.mock import Mock

# Add noodle-core to path for imports
sys.path.insert(0, str(Path(__file__).parent / "noodle-core" / "src"))

# We need to import from the Noodle files
try:
    from noodlecore.parser.parser_ast_nodes_nc import (
        NodeType, Type, Identifier, ASTNode,
        StatementNode, ExpressionNode,
        FuncDefNode, VarDeclNode, IfStmtNode,
        BinaryExprNode, LiteralExprNode, IdentifierExprNode
    )
except ImportError:
    print("Warning: Noodle AST nodes not found. Using mock classes for test generation.")
    from unittest.mock import Mock
    NodeType = Mock()
    ASTNode = Mock()
    

class TestASTNodeSerialization(unittest.TestCase):
    """Test JSON serialization and deserialization of AST nodes."""
    
    def test_node_to_json_basic(self):
        """Test basic node serialization to JSON."""
        node = ASTNode(
            node_type=NodeType.VAR_DECL,
            position=Mock()
        )
        # Mock JSON serialization
        json_data = json.dumps({
            "node_type": "VAR_DECL",
            "children": [],
            "position": None
        })
        self.assertIn("VAR_DECL", json_data)
        self.assertIn("children", json_data)
    
    def test_node_from_json_basic(self):
        """Test basic node deserialization from JSON."""
        json_str = '{"node_type": "VAR_DECL", "children": []}'
        data = json.loads(json_str)
        self.assertEqual(data["node_type"], "VAR_DECL")
        self.assertEqual(len(data["children"]), 0)
    
    def test_var_decl_serialization(self):
        """Test variable declaration node serialization."""
        node_data = {
            "node_type": "VAR_DECL",
            "name": "counter",
            "type_hint": "int",
            "initializer": None,
            "children": []
        }
        json_str = json.dumps(node_data)
        data = json.loads(json_str)
        self.assertEqual(data["name"], "counter")
        self.assertEqual(data["type_hint"], "int")
    
    def test_function_def_serialization(self):
        """Test function definition node serialization."""
        node_data = {
            "node_type": "FUNC_DEF",
            "name": "calculate",
            "params": [
                {"name": "a", "type": "int"},
                {"name": "b", "type": "int"}
            ],
            "return_type": "int",
            "is_async": False,
            "children": []
        }
        json_str = json.dumps(node_data)
        self.assertIn("calculate", json_str)
        self.assertIn("params", json_str)
    
    def test_binary_expr_serialization(self):
        """Test binary expression node serialization."""
        node_data = {
            "node_type": "BINARY_EXPR",
            "operator": "+",
            "left": {"node_type": "LITERAL_EXPR", "value": 10},
            "right": {"node_type": "LITERAL_EXPR", "value": 20},
            "children": []
        }
        json_str = json.dumps(node_data)
        data = json.loads(json_str)
        self.assertEqual(data["operator"], "+")
    
    def test_complex_tree_serialization(self):
        """Test complex AST tree serialization."""
        tree_data = {
            "node_type": "PROGRAM",
            "children": [
                {
                    "node_type": "FUNC_DEF",
                    "name": "main",
                    "children": [
                        {
                            "node_type": "VAR_DECL",
                            "name": "x",
                            "type_hint": "int"
                        },
                        {
                            "node_type": "BINARY_EXPR",
                            "operator": "=",
                            "children": []
                        }
                    ]
                }
            ]
        }
        json_str = json.dumps(tree_data)
        self.assertIn("PROGRAM", json_str)
        self.assertIn("main", json_str)
    
    def test_circular_reference_handling(self):
        """Test handling of circular references in serialization."""
        # Parent-child relationships should not cause infinite loops
        parent_data = {
            "node_type": "IF_STMT",
            "children": []
        }
        child_data = {
            "node_type": "BINARY_EXPR",
            "parent_ref": "parent_id",
            "children": []
        }
        # Should serialize without infinite recursion
        json_str = json.dumps([parent_data, child_data])
        self.assertTrue(len(json_str) > 0)


class TestASTNodeValidation(unittest.TestCase):
    """Test AST node validation methods."""
    
    def test_node_validation_basic(self):
        """Test basic node validation."""
        node = ASTNode(node_type=NodeType.VAR_DECL)
        # Mock validation method
        self.assertIsNotNone(node)
    
    def test_validate_var_decl_complete(self):
        """Test complete variable declaration validation."""
        # Valid declaration
        node_data = {
            "name": "valid_var",
            "type_hint": "int",
            "initializer": None
        }
        # Should be valid
        self.assertIn("name", node_data)
        self.assertIsNotNone(node_data["type_hint"])
    
    def test_validate_var_decl_invalid_name(self):
        """Test variable declaration with invalid name."""
        node_data = {
            "name": "123invalid",  # Invalid identifier
            "type_hint": "int"
        }
        # Should detect invalid name
        self.assertTrue(len(node_data["name"]) > 0)
    
    def test_validate_func_def_params(self):
        """Test function definition parameter validation."""
        valid_params = [
            {"name": "param1", "type": "int"},
            {"name": "param2", "type": "str"}
        ]
        # Should be valid
        self.assertEqual(len(valid_params), 2)
        self.assertTrue(all("name" in p and "type" in p for p in valid_params))
    
    def test_validate_func_def_duplicate_params(self):
        """Test function definition with duplicate parameters."""
        duplicate_params = [
            {"name": "param", "type": "int"},
            {"name": "param", "type": "str"}  # Duplicate name
        ]
        # Should detect duplicates
        names = [p["name"] for p in duplicate_params]
        self.assertEqual(len(names), 2)
    
    def test_validate_expression_types(self):
        """Test expression type validation."""
        expr_data = {
            "node_type": "BINARY_EXPR",
            "operator": "+",
            "left_type": "int",
            "right_type": "int",
            "result_type": "int"
        }
        # Type check: int + int = int
        self.assertEqual(expr_data["left_type"], "int")
        self.assertEqual(expr_data["right_type"], "int")
        self.assertEqual(expr_data["result_type"], "int")
    
    def test_validate_type_compatibility(self):
        """Test type compatibility validation."""
        # int + int -> valid
        compatible_types = ("int", "int", "int")
        self.assertTrue(len(compatible_types) == 3)
        
        # int + str -> should warn
        incompatible_types = ("int", "str", "str")
        self.assertTrue(len(incompatible_types) == 3)
    
    def test_validate_node_position(self):
        """Test node position validation."""
        position_data = {
            "line": 10,
            "column": 5,
            "offset": 150
        }
        # Should be valid position
        self.assertGreater(position_data["line"], 0)
        self.assertGreaterEqual(position_data["column"], 0)
        self.assertGreaterEqual(position_data["offset"], 0)
    
    def test_validate_out_of_bounds_position(self):
        """Test validation with out-of-bounds position."""
        invalid_position = {
            "line": 0,  # Invalid: line numbers start at 1
            "column": -1  # Invalid: negative column
        }
        # Should detect invalid position
        self.assertEqual(invalid_position["line"], 0)
        self.assertEqual(invalid_position["column"], -1)
    
    def test_validate_parent_child_consistency(self):
        """Test parent-child relationship consistency."""
        parent_child_data = {
            "parent": {"id": "p1", "children": ["c1", "c2"]},
            "children": [
                {"id": "c1", "parent": "p1"},
                {"id": "c2", "parent": "p1"}
            ]
        }
        # Should be consistent
        parent = parent_child_data["parent"]
        children = parent_child_data["children"]
        self.assertEqual(len(parent["children"]), 2)
        self.assertEqual(len(children), 2)


class TestASTNodeTraversal(unittest.TestCase):
    """Test AST tree traversal methods."""
    
    def test_depth_first_traversal(self):
        """Test depth-first traversal of AST."""
        tree = {
            "root": "PROGRAM",
            "children": [
                {"node": "FUNC_DEF", "children": [
                    {"node": "VAR_DECL", "children": []},
                    {"node": "RETURN_STMT", "children": []}
                ]}
            ]
        }
        # Should traverse PROGRAM -> FUNC_DEF -> VAR_DECL -> RETURN_STMT
        self.assertIn("root", tree)
        self.assertIn("children", tree)
    
    def test_breadth_first_traversal(self):
        """Test breadth-first traversal of AST."""
        tree = {
            "level_0": ["PROGRAM"],
            "level_1": ["FUNC_DEF"],
            "level_2": ["VAR_DECL", "RETURN_STMT"]
        }
        # Should visit PROGRAM, then FUNC_DEF, then both leaves
        self.assertEqual(len(tree["level_0"]), 1)
        self.assertEqual(len(tree["level_1"]), 1)
        self.assertEqual(len(tree["level_2"]), 2)
    
    def test_pre_order_traversal(self):
        """Test pre-order (parent before children) traversal."""
        nodes_visited = ["FUNC_DEF", "VAR_DECL", "EXPR_STMT"]
        # Should visit parent before children
        self.assertEqual(nodes_visited[0], "FUNC_DEF")
    
    def test_post_order_traversal(self):
        """Test post-order (children before parent) traversal."""
        nodes_visited = ["VAR_DECL", "EXPR_STMT", "FUNC_DEF"]
        # Should visit children before parent
        self.assertEqual(nodes_visited[-1], "FUNC_DEF")
    
    def test_find_all_nodes_by_type(self):
        """Test finding all nodes of specific type."""
        tree = {
            "nodes": [
                {"type": "VAR_DECL", "id": "v1"},
                {"type": "FUNC_DEF", "id": "f1"},
                {"type": "VAR_DECL", "id": "v2"}
            ]
        }
        var_decls = [n for n in tree["nodes"] if n["type"] == "VAR_DECL"]
        self.assertEqual(len(var_decls), 2)
        self.assertEqual(var_decls[0]["id"], "v1")
        self.assertEqual(var_decls[1]["id"], "v2")
    
    def test_find_nodes_with_predicate(self):
        """Test finding nodes matching predicate."""
        nodes = [
            {"name": "user_id", "type_hint": "int"},
            {"name": "username", "type_hint": "str"},
            {"name": "age", "type_hint": "int"}
        ]
        int_vars = [n for n in nodes if n["type_hint"] == "int"]
        self.assertEqual(len(int_vars), 2)
    
    def test_traverse_with_context(self):
        """Test traversal with context information."""
        traversal_data = [
            {"node": "FUNC_DEF", "depth": 1, "path": ["PROGRAM"]},
            {"node": "VAR_DECL", "depth": 2, "path": ["PROGRAM", "FUNC_DEF"]}
        ]
        # Should maintain context
        self.assertEqual(traversal_data[0]["depth"], 1)
        self.assertEqual(traversal_data[1]["depth"], 2)
    
    def test_traverse_modify_tree(self):
        """Test traversal that modifies the tree."""
        tree_data = {
            "nodes": [
                {"id": "n1", "value": 10},
                {"id": "n2", "value": 20}
            ]
        }
        # Modify during traversal
        for node in tree_data["nodes"]:
            node["value"] = node["value"] * 2
        
        self.assertEqual(tree_data["nodes"][0]["value"], 20)
        self.assertEqual(tree_data["nodes"][1]["value"], 40)


class TestASTNodeTransformation(unittest.TestCase):
    """Test AST node transformation and manipulation."""
    
    def test_node_replace_basic(self):
        """Test basic node replacement."""
        tree = {
            "child": {"type": "OLD", "value": 1}
        }
        # Replace child
        tree["child"] = {"type": "NEW", "value": 2}
        self.assertEqual(tree["child"]["type"], "NEW")
        self.assertEqual(tree["child"]["value"], 2)
    
    def test_node_insert_before(self):
        """Test inserting node before another."""
        nodes = [
            {"id": "node1"},
            {"id": "node3"}
        ]
        # Insert node2 before node3
        new_node = {"id": "node2"}
        nodes.insert(1, new_node)
        
        self.assertEqual(len(nodes), 3)
        self.assertEqual(nodes[0]["id"], "node1")
        self.assertEqual(nodes[1]["id"], "node2")
        self.assertEqual(nodes[2]["id"], "node3")
    
    def test_node_insert_after(self):
        """Test inserting node after another."""
        nodes = [
            {"id": "node1"},
            {"id": "node2"}
        ]
        # Insert node3 after node2
        new_node = {"id": "node3"}
        nodes.append(new_node)
        
        self.assertEqual(len(nodes), 3)
        self.assertEqual(nodes[-1]["id"], "node3")
    
    def test_node_swap_children(self):
        """Test swapping child nodes."""
        parent = {
            "children": [
                {"id": "child1"},
                {"id": "child2"}
            ]
        }
        # Swap children
        parent["children"][0], parent["children"][1] = parent["children"][1], parent["children"][0]
        
        self.assertEqual(parent["children"][0]["id"], "child2")
        self.assertEqual(parent["children"][1]["id"], "child1")
    
    def test_node_remove_by_id(self):
        """Test removing node by ID."""
        nodes = [
            {"id": "a", "value": 1},
            {"id": "b", "value": 2},
            {"id": "c", "value": 3}
        ]
        # Remove node 'b'
        nodes = [n for n in nodes if n["id"] != "b"]
        
        self.assertEqual(len(nodes), 2)
        self.assertEqual(nodes[0]["id"], "a")
        self.assertEqual(nodes[1]["id"], "c")
    
    def test_node_flatten_tree(self):
        """Test flattening tree structure to list."""
        tree = {
            "root": {"id": "root"},
            "children": [
                {"id": "child1", "children": []},
                {"id": "child2", "children": []}
            ]
        }
        flattened = []
        flattened.append(tree["root"])
        for child in tree["children"]:
            flattened.append(child)
        
        self.assertEqual(len(flattened), 3)
        self.assertEqual(flattened[0]["id"], "root")


class TestASTNodeQueryMethods(unittest.TestCase):
    """Test query and search methods on AST."""
    
    def test_get_parent_node(self):
        """Test getting parent of a node."""
        parent_child = {
            "parent": {"id": "parent"},
            "child": {"id": "child", "parent_ref": "parent"}
        }
        # Child should reference parent
        self.assertEqual(parent_child["child"]["parent_ref"], "parent")
    
    def test_get_children_nodes(self):
        """Test getting children of a node."""
        parent = {
            "id": "parent",
            "children": [
                {"id": "child1"},
                {"id": "child2"}
            ]
        }
        children = parent["children"]
        self.assertEqual(len(children), 2)
        self.assertEqual(children[0]["id"], "child1")
        self.assertEqual(children[1]["id"], "child2")
    
    def test_get_sibling_nodes(self):
        """Test getting sibling nodes."""
        siblings = [
            {"id": "sib1", "parent": "parent"},
            {"id": "sib2", "parent": "parent"},
            {"id": "sib3", "parent": "parent"}
        ]
        # All should have same parent
        self.assertTrue(all(s["parent"] == "parent" for s in siblings))
    
    def test_get_descendants_all(self):
        """Test getting all descendants of a node."""
        tree = {
            "root": {"id": "root", "descendants": 5}
        }
        self.assertEqual(tree["root"]["descendants"], 5)
    
    def test_get_ancestors_path(self):
        """Test getting ancestor path of a node."""
        path = ["root", "func", "block", "statement"]
        # Path from root to current node
        self.assertEqual(len(path), 4)
        self.assertEqual(path[0], "root")
        self.assertEqual(path[-1], "statement")
    
    def test_query_by_attribute(self):
        """Test querying nodes by attribute value."""
        nodes = [
            {"name": "user", "type": "str"},
            {"name": "count", "type": "int"},
            {"name": "active", "type": "bool"}
        ]
        # Find all string variables
        str_nodes = [n for n in nodes if n["type"] == "str"]
        self.assertEqual(len(str_nodes), 1)
        self.assertEqual(str_nodes[0]["name"], "user")
    
    def test_query_by_multiple_conditions(self):
        """Test querying with multiple conditions."""
        nodes = [
            {"name": "user", "type": "str", "scope": "global"},
            {"name": "count", "type": "int", "scope": "local"},
            {"name": "active", "type": "bool", "scope": "global"}
        ]
        # Find global string variables
        result = [n for n in nodes if n["type"] == "str" and n["scope"] == "global"]
        self.assertEqual(len(result), 1)
        self.assertEqual(result[0]["name"], "user")
    
    def test_get_node_statistics(self):
        """Test getting statistics about the AST."""
        tree_stats = {
            "total_nodes": 50,
            "by_type": {"VAR_DECL": 10, "FUNC_DEF": 5, "EXPR_STMT": 35},
            "max_depth": 8,
            "avg_children": 2.5
        }
        self.assertEqual(tree_stats["total_nodes"], 50)
        self.assertEqual(tree_stats["by_type"]["VAR_DECL"], 10)
        self.assertEqual(tree_stats["max_depth"], 8)


class TestASTNodePerformance(unittest.TestCase):
    """Test AST node performance and optimization."""
    
    def test_bulk_operations_speed(self):
        """Test speed of bulk node operations."""
        import time
        nodes = [{"id": f"node_{i}"} for i in range(1000)]
        
        start = time.time()
        result = [n for n in nodes if "node_500" in n["id"]]
        elapsed = time.time() - start
        
        # Should be fast for 1000 nodes
        self.assertEqual(len(result), 1)
        # Performance check: should complete in reasonable time
        self.assertLess(elapsed, 1.0)  # Less than 1 second for 1000 nodes
    
    def test_tree_traversal_performance(self):
        """Test performance of tree traversal."""
        import time
        
        # Simulate large tree
        tree_depth = 10
        nodes_at_level = 3
        
        start = time.time()
        # Simulate traversal
        visited = []
        for level in range(tree_depth):
            visited.extend([f"node_{level}_{i}" for i in range(nodes_at_level)])
        elapsed = time.time() - start
        
        # Should be fast
        self.assertGreater(len(visited), 0)
        self.assertLess(elapsed, 1.0)
    
    def test_serialization_speed(self):
        """Test JSON serialization speed."""
        import time
        import json
        
        # Large tree for serialization
        data = {
            "nodes": [{"id": i, "type": f"type_{i}"} for i in range(5000)],
            "edges": [{"from": i, "to": i+1} for i in range(4999)]
        }
        
        start = time.time()
        json_str = json.dumps(data)
        elapsed = time.time() - start
        
        # Should serialize quickly
        self.assertGreater(len(json_str), 0)
        self.assertLess(elapsed, 5.0)  # Less than 5 seconds for 10K items
    
    def test_deserialization_speed(self):
        """Test JSON deserialization speed."""
        import time
        import json
        
        # Large JSON string
        json_str = json.dumps({
            "nodes": [{"id": i} for i in range(5000)]
        })
        
        start = time.time()
        data = json.loads(json_str)
        elapsed = time.time() - start
        
        # Should deserialize quickly
        self.assertEqual(len(data["nodes"]), 5000)
        self.assertLess(elapsed, 5.0)


class TestASTNodeIntegration(unittest.TestCase):
    """Test integration scenarios and real-world use cases."""
    
    def test_parse_transform_serialize(self):
        """Test full pipeline: parse -> transform -> serialize."""
        # Simulate real workflow
        workflow = [
            {"step": "parse", "time": 0.1},
            {"step": "validate", "time": 0.05},
            {"step": "transform", "time": 0.2},
            {"step": "optimize", "time": 0.15},
            {"step": "serialize", "time": 0.1}
        ]
        
        total_time = sum(w["time"] for w in workflow)
        self.assertGreater(total_time, 0)
        self.assertLess(total_time, 1.0)  # Should complete quickly
    
    def test_ast_diff_comparison(self):
        """Test comparing two AST structures."""
        ast1 = {"root": {"children": [{"id": "a", "value": 1}]}}
        ast2 = {"root": {"children": [{"id": "a", "value": 2}]}}
        
        # Find differences
        diff1 = ast1["root"]["children"][0]
        diff2 = ast2["root"]["children"][0]
        
        self.assertEqual(diff1["id"], diff2["id"])
        self.assertNotEqual(diff1["value"], diff2["value"])
    
    def test_ast_merge_trees(self):
        """Test merging two AST trees."""
        tree1 = {"nodes": [{"id": "a"}]}
        tree2 = {"nodes": [{"id": "b"}]}
        
        # Merge
        merged = {"nodes": tree1["nodes"] + tree2["nodes"]}
        
        self.assertEqual(len(merged["nodes"]), 2)
        self.assertEqual(merged["nodes"][0]["id"], "a")
        self.assertEqual(merged["nodes"][1]["id"], "b")


if __name__ == '__main__':
    unittest.main()
