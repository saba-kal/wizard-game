class_name HealthBar extends ProgressBar

@export var health: Health

@onready var label: Label = $Label


func _ready() -> void:
    if is_instance_valid(self.health):
        self.update_health_bar()
        self.health.damage_taken.connect(self.on_health_changed)
        self.health.healed.connect(self.on_health_changed)


func set_health(new_health: Health) -> void:
    self.health = new_health
    self.update_health_bar()
    self.init_health()


func init_health() -> void:
    self.health.damage_taken.connect(self.on_health_changed)
    self.health.healed.connect(self.on_health_changed)


func on_health_changed(damage: float) -> void:
    self.update_health_bar()


func update_health_bar() -> void:
    self.max_value = self.health.max_health
    self.value = self.health.current_health
    self.label.text = "%d/%d" % [self.health.current_health, self.health.max_health]
