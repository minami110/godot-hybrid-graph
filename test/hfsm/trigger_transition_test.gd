extends GdUnitTestSuite


class CompositeStateA extends HgCompositeState:
	func _define_transitions():
		add_transition(StateA, StateB, &"AtoB")
		add_transition(StateB, StateA, 2)
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
	var blackboard := []

	# StateMachine を生成, 生成時点では何も実行されない
	var graph := HybridGraph.create(CompositeStateA, blackboard)
	assert_array(blackboard).is_equal([])

	# execute を呼び出すと、初期状態に遷移し、StateA の on_enter が呼び出される
	# このさい CompositeState の on_enter も呼び出されている
	graph.execute()
	assert_array(blackboard).is_equal(["P", "A"])

	# AtoB トリガーを送信すると、StateA から StateB に遷移する
	var success := graph.send_trigger("InvalidTrigger")
	assert_bool(success).is_false()
	success = graph.send_trigger("AtoB")
	assert_bool(success).is_true()

	# この時点ではまだ StateB の on_enter は呼び出されていない
	assert_array(blackboard).is_equal(["P", "A"])

	# execute を呼び出すと遷移が発生する
	# StateA の on_exit -> StateB の on_enter が呼び出される
	# このさい CompositeState の on_enter, on_exit は呼び出されない
	graph.execute()
	assert_array(blackboard).is_equal(["P", "A", "X", "B"])

	# 遷移が決定していないときに execute を呼び出すと、
	# Composite -> StateB の順番で on_execute が呼び出される
	graph.execute()
	assert_array(blackboard).is_equal(["P", "A", "X", "B", "1", "3"])

class Invalid1 extends HgCompositeState:
	pass

class Invalid2 extends RefCounted:
	pass

@warning_ignore("unreachable_code")
@warning_ignore("unused_parameter")
func test_abnormal_1(do_skip = true, skip_reason = "GdUnit4 do not support @GDScript.assert") -> void:
	await assert_error(func():
		HybridGraph.create(Invalid1, [])
		).is_runtime_error("The initial state is not set.")

	await assert_error(func(): HybridGraph.create(CompositeStateA.StateA, [])) \
		.is_runtime_error("template is not extended HgCompositeState class")


	await assert_error(func(): HybridGraph.create(Invalid2, [])) \
		.is_runtime_error("template is not extended HgCompositeState class")
