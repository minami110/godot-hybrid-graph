class_name HybridGraph extends RefCounted
##

##
static func create(template: GDScript, blackboard: Variant) -> HybridGraph:
	assert(template.can_instantiate(), "template is not instantiable.")

	var container = template.new() as HgCompositeState
	assert(container != null, "template is not extended HgCompositeState class")

	return HybridGraph.new(container, blackboard)


var __is_running: bool

var __container: _HgContainerNode
var __current_node: _HgLeafNode
var __next_node: _HgLeafNode


## Do not call this constructor directly.
func _init(container: _HgContainerNode, blackboard: Variant) -> void:
	__container = container
	__container.__on_initialize_core(blackboard, null)
	__current_node = __container.__get_entry_node()

	__is_running = false
	__next_node = null

## Destructor
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		dispose()
		pass


#region Public methods

##
func execute() -> void:
	assert(__container, "HybridGraph is disposed.")

	var is_skipped_on_enter_with_cond := false
	if not __is_running:
		__is_running = true

		if not __update_next_node_with_condition():
			__current_node.__on_enter_core()
		else:
			is_skipped_on_enter_with_cond = true

		if __next_node == null:
			return

	# Next Node が未確定な場合は、条件を確認する
	# 条件が満たされている場合 Next Node が設定される
	if __next_node == null:
		if not __update_next_node_with_condition():
			__current_node.__on_execute_core()


	# Next Node が確定している場合は、ステートの切り替えを行う
	# current_node の execute 内で設定されることもあるのでそのまま見る
	while __next_node != null:
		if not is_skipped_on_enter_with_cond:
			__current_node.__on_exit_core(__next_node)

		# ステートの切り替え
		__current_node = __next_node
		__next_node = null
		is_skipped_on_enter_with_cond = false

		# 次のステートを開始する
		if not __update_next_node_with_condition():
			__current_node.__on_enter_core()
		else:
			is_skipped_on_enter_with_cond = true


##
func send_trigger(trigger: Variant) -> bool:
	assert(__container, "HybridGraph is disposed.")
	assert(__is_running, "HybridGraph is not running.")
	assert(trigger != null, "The trigger is null.")
	assert(trigger is not Callable, "The trigger is Callable.")

	var next_node := __current_node.__try_get_next_node(trigger)
	if next_node != null:
		__next_node = next_node

		return true

	return false


##
func dispose() -> void:
	assert(__container, "HybridGraph is disposed.")

	__is_running = false

	__container.dispose()

	__container = null
	__current_node = null
	__next_node = null

#endregion

func __update_next_node_with_condition() -> bool:
	var next_node := __current_node.__try_get_next_node_with_condition()
	if next_node != null:
		__next_node = next_node
		return true

	return false
