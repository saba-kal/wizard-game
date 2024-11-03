class_name PlayerController extends CharacterBody3D

enum State {
    MOVING,
    AIMING_BALLISTA,
    ENGAGING_DIALOGUE,
    SITTING_INSIDE_CANNON,
    FLYING,
    DISABLED
}

@onready var player_movement: PlayerMovement = $PlayerMovement
@onready var player_mana: PlayerMana = $Mana
@onready var spell_factory: SpellFactory = $SpellFactory
@onready var third_person_camera: ThirdPersonCamera = $ThirdPersonCamera
@onready var player_flying: PlayerFlying = $PlayerFlying

var current_state: State = State.MOVING
var nearby_ballista: Ballista
var nearby_quest: Quest
var nearby_cannon: Cannon


func _ready() -> void:
    SignalBus.player_entered_ballista_region.connect(self.on_ballista_area_entered)
    SignalBus.player_exited_ballista_region.connect(self.on_ballista_area_exited)
    SignalBus.player_entered_quest_giver_area.connect(self.on_player_entered_quest_giver_area)
    SignalBus.player_exited_quest_giver_area.connect(self.on_player_exited_quest_giver_area)
    SignalBus.player_disabled.connect(self.set_player_disabled)
    SignalBus.player_entered_cannon.connect(self.on_player_entered_cannon)
    SignalBus.superman_mode_changed.connect(self.on_superman_mode_changed)


func _process(delta: float) -> void:
    var input_direction: Vector2 = Input.get_vector(
        "move_left", "move_right", "move_forward", "move_backward");
    self.player_movement.input_direction = Vector2.ZERO
    match self.current_state:
        State.MOVING:
            self.player_movement.input_direction = input_direction
            self.player_mana.set_regen_active(Input.is_action_pressed("regen_mana"))
            self.third_person_camera.set_aim_mode_enabled(Input.is_action_pressed("aim"))

            if Input.is_action_just_pressed("interact"):
                if self.nearby_quest != null:
                    if  not self.nearby_quest.interact():
                        self.current_state = State.ENGAGING_DIALOGUE
                elif self.nearby_ballista != null:
                    self.current_state = State.AIMING_BALLISTA
                    self.nearby_ballista.change_state(Ballista.State.AIMING)
        State.AIMING_BALLISTA:
            if Input.is_action_just_pressed("interact"):
                self.current_state = State.MOVING
                self.nearby_ballista.change_state(Ballista.State.UNMANNED)
        State.ENGAGING_DIALOGUE:
            if self.nearby_quest != null:
                if Input.is_action_just_pressed("interact"):
                    if self.nearby_quest.interact():
                        self.current_state = State.MOVING
            else:
                self.current_state = State.MOVING
        State.SITTING_INSIDE_CANNON:
            if Input.is_action_just_pressed("jump"):
                self.current_state = State.MOVING
                self.player_movement.set_disabled(false)
                if self.nearby_cannon != null:
                    self.nearby_cannon.remove_player_from_cannon()
        State.FLYING:
            var direction_3d: Vector3 = Vector3(input_direction.x, 0, input_direction.y)
            if Input.is_action_pressed("jump"):
                direction_3d.y += 1
            if Input.is_action_pressed("regen_mana"):
                direction_3d.y -= 1
            self.player_flying.set_flight_direction(direction_3d)


func _physics_process(delta: float) -> void:
    match self.current_state:
        State.MOVING:
            if Input.is_action_just_pressed("jump"):
                self.player_movement.trigger_jump()


func _unhandled_input(event) -> void:
    if !event.is_action("cast_spell") || !event.is_pressed():
        return

    match self.current_state:
        State.MOVING:
            self.spell_factory.cast_spell()
        State.AIMING_BALLISTA:
            if self.nearby_ballista != null:
                self.nearby_ballista.fire()


func on_ballista_area_entered(ballista: Ballista) -> void:
    self.nearby_ballista = ballista


func on_ballista_area_exited(ballista: Ballista) -> void:
    self.nearby_ballista = null
    if self.current_state == State.AIMING_BALLISTA:
        self.current_state = State.MOVING


func on_player_entered_quest_giver_area(quest: Quest) -> void:
    self.nearby_quest = quest


func on_player_exited_quest_giver_area(quest: Quest) -> void:
    self.nearby_quest = null


func on_player_entered_cannon(cannon: Cannon) -> void:
    self.nearby_cannon = cannon
    self.current_state = State.SITTING_INSIDE_CANNON
    self.player_movement.set_disabled(true)


func set_player_disabled(is_disabled: bool) -> void:
    if self.current_state == State.FLYING:
        return
    if is_disabled:
        self.current_state = State.DISABLED
        self.player_movement.set_disabled(true)
    else:
        self.current_state = State.MOVING
        self.player_movement.set_disabled(false)


func on_superman_mode_changed(is_superman_mode_enabled: bool) -> void:
    if is_superman_mode_enabled:
        self.current_state = State.FLYING
        self.player_movement.set_disabled(true)
        self.player_flying.set_enabled(true)
    else:
        self.current_state = State.MOVING
        self.player_movement.set_disabled(false)
        self.player_flying.set_enabled(false)
