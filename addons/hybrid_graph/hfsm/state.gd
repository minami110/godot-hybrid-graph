class_name HgState extends _HgLeafNode

var __blackboard: Variant = null

## Transition table with trigger.
## Key: trigger (Variant)
## Value: next state (_HgLeafNode)
var __transition_table_with_trigger := {}

## Transition table with callable.
## Key: next state (_HgLeafNode)
## Value: callable (Callable)
var __transition_table_with_callable := {}

var __parent: _HgContainerNode

#region Public methods

## Get the blackboard.
var blackboard: Variant:
	get:
		return __blackboard

func _on_initialize() -> void:
	pass

func _on_enter() -> void:
	pass

func _on_execute() -> void:
	pass

func _on_exit() -> void:
	pass

func _on_destroy() -> void:
	pass

#endregion

#region _HgLeafNode implementations

@warning_ignore("unused_parameter")
func __try_get_next_node(trigger: Variant) -> _HgLeafNode:
	if __transition_table_with_trigger.has(trigger):
		return __transition_table_with_trigger[trigger]

	return null


@warning_ignore("unused_parameter")
func __try_get_next_node_with_condition() -> _HgLeafNode:
	for entry in __transition_table_with_callable:
		var condition: Callable = __transition_table_with_callable[entry]
		if condition.call():
			return entry

	return null

#endregion

#region _HgNode implementations

func __get_entry_node() -> _HgLeafNode:
	return self

@warning_ignore("unused_parameter")
func __connect(trigger: Variant, next_node: _HgNode) -> void:
	# Transition with condition
	if trigger is Callable:
		assert(trigger.get_argument_count() == 0, "Callable must not have any arguments.")

		# 次のノードをキーとして辞書を更新する
		var entry_node = next_node.__get_entry_node()
		assert(__transition_table_with_callable.has(entry_node) == false, "The node is already connected: %s" % next_node)

		__transition_table_with_callable[next_node] = trigger
		return

	# Transition with normal (variant) trigger
	assert(__transition_table_with_trigger.has(trigger) == false, "The trigger is already connected: %s" % trigger)
	__transition_table_with_trigger[trigger] = next_node

func __on_initialize_core(in_blackboard: Variant, parent: _HgContainerNode) -> void:
	__blackboard = in_blackboard
	__parent = parent
	_on_initialize()

func __on_enter_core() -> void:
	if __parent != null:
		__parent.__on_enter_core()
	_on_enter()


func __on_execute_core() -> void:
	if __parent != null:
		__parent.__on_execute_core()
	_on_execute()


@warning_ignore("unused_parameter")
func __on_exit_core(next_node: _HgNode) -> void:
	_on_exit()
	if __parent != null:
		__parent.__on_exit_core(next_node)

#endregion
