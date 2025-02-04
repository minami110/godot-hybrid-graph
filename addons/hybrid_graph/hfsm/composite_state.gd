class_name HgCompositeState extends _HgContainerNode

var __is_initialized: bool
var __is_entered: bool
var __blackboard: Variant = null

var __parent: _HgContainerNode
var __initial_state: _HgNode
var __children: Array[_HgNode]

#region Public methods

## Get the blackboard
var blackboard: Variant:
	get:
		return __blackboard

## Add a transition
func add_transition(from: GDScript, to: GDScript, trigger: Variant) -> void:
	assert(__is_initialized == false, "The state is already initialized.")
	assert(trigger != null, "The trigger is null.")

	var prev_state = __get_or_create_state(from)
	var next_state = __get_or_create_state(to)
	prev_state.__connect(trigger, next_state)


## Define state transitions
func _define_transitions() -> GDScript:
	return null

## Called when the state is initialized.
func _on_init() -> void:
	pass

## Called when the state is entered.
func _on_enter() -> void:
	pass

## Called when the state is executed.
func _on_execute() -> void:
	pass

## Called when the state is exited.
func _on_exit() -> void:
	pass

## Called when the state is disposed.
func _on_dispose() -> void:
	pass

#endregion

func __get_or_create_state(template: GDScript) -> _HgNode:
	for child in __children:
		if template.instance_has(child):
			return child

	var new_state = template.new() as _HgNode
	assert(new_state != null, "The template is not extended _HgNode class.")

	new_state.__on_initialize_core(__blackboard, self)
	__children.push_back(new_state)

	return new_state

# region _HgContainerNode implementations

func __has_node(node: _HgNode, recursive := true) -> bool:
	for child in __children:
		if child == node:
			return true

		if not recursive:
			continue

		if child is not _HgContainerNode:
			continue

		if child.__has_node(node, recursive):
			return true

	return false


#endregion

#region _HgNode

func __dispose() -> void:
	for child in __children:
		child.__dispose()

	_on_dispose()

	__parent = null
	__initial_state = null

	# NOTE: read-only なので上書きで参照を消す
	__children = []

	# NOTE: blackboard は on_destroy 内でアクセスされる可能性があるので最後に消す
	__blackboard = null

func __get_entry_node() -> _HgLeafNode:
	assert(__initial_state != null, "The initial state is not set.")
	return __initial_state.__get_entry_node()

func __connect(trigger: Variant, next_node: _HgNode) -> void:
	for child in __children:
		child.__connect(trigger, next_node)

@warning_ignore("unused_parameter")
func __on_initialize_core(in_blackboard: Variant, parent: _HgContainerNode) -> void:
	assert(not __is_initialized, "The state is already initialized.")

	# Setup blackboard and initial state
	__blackboard = in_blackboard
	__parent = parent

	# Define transitions with callbacks
	var initial_state_class := _define_transitions()

	## Set the initial state.
	assert(initial_state_class != null, "The initial state is not set.")
	assert(initial_state_class.can_instantiate(), "template is not instantiable.")

	__initial_state = __get_or_create_state(initial_state_class)

	# Check the initial state
	assert(__initial_state != null, "The initial state is not set.")

	# Initialize the initial state
	_on_init()

	# Make read-only children
	__is_initialized = true
	__children.make_read_only()


func __on_enter_core() -> void:
	# NOTE: 既に Enter されている場合は何もしない, 子のノードが切り替わるたびに呼ばれるので assert は不要
	if __is_entered:
		return

	__is_entered = true

	if __parent != null:
		__parent.__on_enter_core()

	_on_enter()


func __on_execute_core() -> void:
	assert(__is_entered == true, "The state is not entered.")

	if __parent != null:
		__parent.__on_execute_core()

	_on_execute()


func __on_exit_core(next_node: _HgNode) -> void:
	assert(__is_entered == true, "The state is not entered.")

	# NOTE: 次のノードが自分の子孫のノードなら, Container の OnExit は呼ばない
	if __has_node(next_node, true):
		return

	_on_exit()
	if __parent != null:
		__parent.__on_exit_core(next_node)

	__is_entered = false


#endregion
