extends Flammable

@export var time_between_damage: float = 0.1
@export var damage_unit_amount: float = 1

@onready var particles: GPUParticles3D = $GPUParticles3D

var damage_over_time_enabled = false
var time_since_last_damage = 0
var health: Health
var immunity_enabled = false;


func _ready():
    self.health = Util.get_child_node_of_type(self.get_parent(), Health)


func _process(delta):
    super._process(delta)
    if !self.damage_over_time_enabled || self.immunity_enabled:
        return
    if self.time_since_last_damage >= self.time_between_damage:
        self.health.take_damage(self.damage_unit_amount)
        self.time_since_last_damage = 0
    self.time_since_last_damage += delta


func light():
    self.damage_over_time_enabled = true
    self.particles.emitting = true


func extinguish():
    self.damage_over_time_enabled = false
    self.particles.emitting = false

func un_light():
    self.immunity_enabled = true

func un_extinguish():
    self.immunity_enabled = false
