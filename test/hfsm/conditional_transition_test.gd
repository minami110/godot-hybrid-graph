extends GdUnitTestSuite

class Blackboard:
	var is_trigger_a_to_b := false
	var result := []

	func push_back(value: Variant) -> void:
		result.push_back(value)

class CompositeStateA extends HgCompositeState:
	func _define_transitions():

		# Conditional transition
		add_transition(StateA, StateB, func(): return blackboard.is_trigger_a_to_b)
		return StateA

	func _on_enter():
		blackboard.push_back("P")

	func _on_execute():
		blackboard.push_back("1")

	func _on_exit():
		blackboard.push_back("Q")

	class StateA extends HgState:
		func _on_enter():
			blackboard.push_back("A")

		func _on_execute():
			blackboard.push_back("2")

		func _on_exit():
			blackboard.push_back("X")

	class StateB extends HgState:
		func _on_enter():
			blackboard.push_back("B")

		func _on_execute():
			blackboard.push_back("3")

		func _on_exit():
			blackboard.push_back("Y")


func test_standard_1() -> void:
	var blackboard := Blackboard.new()

	var graph := HybridGraph.create(CompositeStateA, blackboard)

	graph.execute()
	assert_array(blackboard.result).is_equal(["P", "A"])

	blackboard.is_trigger_a_to_b = true
	assert_array(blackboard.result).is_equal(["P", "A"])

	graph.execute()
	assert_array(blackboard.result).is_equal(["P", "A", "X", "B"])
