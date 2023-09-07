class_name HealthBar extends ProgressBar

@export var health: Health

@onready var label: Label = $Label


func _ready():
    self.update_health_bar()
    self.health.damage_taken.connect(self.on_damage_taken)


func on_damage_taken(damage: float):
    self.update_health_bar()


func update_health_bar():
    self.max_value = self.health.max_health
    self.value = self.health.current_health
    self.label.text = str(self.health.current_health) + "/" + str(self.health.max_health)
