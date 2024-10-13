class_name PlayerController extends CharacterBody3D

enum State {
    MOVING,
    AIMING_BALLISTA,
    ENGAGING_DIALOGUE
}

@onready var player_movement: PlayerMovement = $PlayerMovement
@onready var player_mana: PlayerMana = $Mana
@onready var spell_factory: SpellFactory = $SpellFactory
@onready var third_person_camera: ThirdPersonCamera = $ThirdPersonCamera

var current_state: State = State.MOVING
var nearby_ballista: Ballista
var nearby_quest: Quest


func _ready() -> void:
    SignalBus.player_entered_ballista_region.connect(self.on_ballista_area_entered)
    SignalBus.player_exited_ballista_region.connect(self.on_ballista_area_exited)
    SignalBus.player_entered_quest_giver_area.connect(self.on_player_entered_quest_giver_area)
    SignalBus.player_exited_quest_giver_area.connect(self.on_player_exited_quest_giver_area)


func _process(delta: float) -> void:
    match self.current_state:
        State.MOVING:
            self.player_movement.input_direction = Input.get_vector(
                "move_left", "move_right", "move_forward", "move_backward")
            self.player_mana.set_regen_active(Input.is_action_pressed("regen_mana"))
            self.third_person_camera.set_aim_mode_enabled(Input.is_action_pressed("aim"))

            if Input.is_action_just_pressed("interact"):
                if self.nearby_quest != null:
                    self.nearby_quest.interact()
                elif self.nearby_ballista != null:
                    self.current_state = State.AIMING_BALLISTA
                    self.nearby_ballista.change_state(Ballista.State.AIMING)
        State.AIMING_BALLISTA:
            if Input.is_action_just_pressed("interact"):
                self.current_state = State.MOVING
                self.nearby_ballista.change_state(Ballista.State.UNMANNED)


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
