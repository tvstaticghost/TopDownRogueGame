extends AnimatedSprite2D

@onready var visually_alerted: Node2D = $"../VisuallyAlerted"

func render_alert():
	visually_alerted.adjust_text("alert")
	
func render_chase():
	visually_alerted.adjust_text("chase")
