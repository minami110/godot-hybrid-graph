extends GdUnitTestSuite


class MyStateMachine extends HgCompositeState:
	func _define_transitions():
		# A -> B
		add_transition(StateA, StateB, "AtoB")
		# B -> A
		add_transition(StateB, StateA, 2)
		# Return the initial state class
		return StateA

	func _on_dispose():
		blackboard.push_back(0)

	class StateA extends HgState:
		func _on_dispose():
			blackboard.push_back(1)

	class StateB extends HgState:
		func _on_dispose():
			blackboard.push_back(2)


func test_standard_1() -> void:
	var result := []
	var graph := HybridGraph.create(MyStateMachine, result)

	graph.execute()
	graph.dispose()
	assert_array(result).is_equal([1, 2, 0])
