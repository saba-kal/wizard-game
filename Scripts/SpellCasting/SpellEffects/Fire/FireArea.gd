extends Area3D

@export var duration: float = 5
@export var damage_per_second: float = 10
@export var disabled: bool = false

var entered_objects: Array[Dictionary] = []


func _ready() -> void:
    self.body_entered.connect(self.on_body_entered)
    self.body_exited.connect(self.on_body_exited)


func _process(delta: float) -> void:
    if self.disabled:
        return

    for object: Dictionary in self.entered_objects:
        if !is_instance_valid(object["body"]):
            continue

        var status_health: StatusHealth = object.get("status_health")
        var health: Health = object.get("health")
        var flammable: Flammable = object.get("flammable")
        var freezable: Freezable = object.get("freezable")

        if health != null:
            health.take_damage(self.damage_per_second * delta, Health.DamageType.FIRE)
        if freezable != null:
            freezable.unfreeze()
        if status_health != null:
            status_health.take_damage(self.damage_per_second * delta)
            if status_health.get_current_health() <= 0 && flammable != null:
                flammable.start_fire(duration)
        elif flammable != null:
            flammable.start_fire(duration)


func on_body_entered(body: Node3D) -> void:
    var object: Dictionary = {}
    for child: Node in body.get_children():
        if child is Flammable:
            object["flammable"] = child
        if child is Health:
            object["health"] = child
        if child is StatusHealth:
            object["status_health"] = child
        if child is Freezable:
            object["freezable"] = child
    if object.size() > 0:
        object["body"] = body
        self.entered_objects.append(object)


func on_body_exited(body: Node3D) -> void:
    var index: int = -1
    var i: int = 0
    for object: Dictionary in self.entered_objects:
        if object["body"] == body:
            index = i
            break
        i+=1
    if index >= 0:
        self.entered_objects.remove_at(i)
