# Hybrid Graph for Godot 4
Godot 4 plugin that describe simple HFSM

### from GitHub
Download the latest .zip file from the [Releases](https://github.com/minami110/godot-hybrid-graph/releases) page of this repository.<br>
After extracting it, copy the `addons/hybrid_graph/` directory into the `addons/` folder of your project.<br>
Launch the editor and enable "Hybrid Graph" from `Project Settings > Plugins`.

## HFSM

### Trigger transition
```gdscript
extends Node

class MyStateMachine extends HgCompositeState:
	func _define_transitions():
		# A -> B
		add_transition(StateA, StateB, "AtoB")
		# B -> A
		add_transition(StateB, StateA, 2)
		# Return the initial state class
		return StateA

	class StateA extends HgState:
		func _on_enter():
			blackboard.push_back("A")

		func _on_exit():
			blackboard.push_back("X")

	class StateB extends HgState:
		func _on_enter():
			blackboard.push_back("B")

		func _on_exit():
			blackboard.push_back("Y")

func _ready() -> void:
	# Create a blackboard
	var blackboard := []

	# Create a state machine
	var graph := HybridGraph.create(MyStateMachine, blackboard)

	# Run the state machine (State: A)
	graph.execute()

	# Trigger the transition (State: B)
	graph.send_trigger("AtoB")
	graph.execute()

	print(blackboard) # ["A", "X", "B"]
```
