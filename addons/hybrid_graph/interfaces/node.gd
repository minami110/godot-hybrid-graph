class_name _HgNode extends RefCounted
## Base class for all nodes in the HybridGraph.

func __on_dispose_core() -> void:
	pass

func __get_entry_node() -> _HgLeafNode:
	return null

@warning_ignore("unused_parameter")
func __connect(trigger: Variant, next_node: _HgNode) -> void:
	pass

@warning_ignore("unused_parameter")
func __on_init_core(blackboard: Variant, parent: _HgContainerNode) -> void:
	pass

func __on_enter_core() -> void:
	pass


func __on_execute_core() -> void:
	pass


@warning_ignore("unused_parameter")
func __on_exit_core(next_node: _HgNode) -> void:
	pass
