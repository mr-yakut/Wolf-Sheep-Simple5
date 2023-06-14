breed [sheep a-sheep]
breed [wolves wolf]

turtles-own [energy]
patches-own [grass-amount]


;; this procedures sets up the model
to setup
  clear-all
  ask patches [
    ;; give grass to the patches, color it shades of green
    set grass-amount random-float 10.0
    recolor-grass ;; change the world green
  ]
  
  ;; create the initial sheep
  create-sheep number-of-sheep [
    setxy random-xcor random-ycor
    set color white
    set shape "sheep"
    set energy 100  ;; set the initial energy to 100
  ]
  
  ;; create the initial wolves
  create-wolves number-of-wolves [
    setxy random-xcor random-ycor
    set color brown
    set shape "wolf"
    set size 2 ;; increase their size so they are a little easier to see
    set energy 100  ;; set the initial energy to 100
  ]
  
  reset-ticks
end

;; make the model run

to go
  if not any? turtles [   ;; now check for any turtles, that is both wolves and sheep
    stop
  ]
  
  ask turtles [  ;; ask both wolves and sheep
    ; Call the movement procedure depending on the type of movement
    ifelse breed = sheep [
      ifelse (movement-type-sheeps = "random-movement") [
        random-movement
      ] [
        intelligent-movement
      ]
    ] [
      ifelse (movement-type-wolfs = "random-movement") [
        random-movement
      ] [
        intelligent-movement
      ]
    ]
    
    check-if-dead  ;; check to see if agent should die
    eat            ;; sheep eat grass, wolves eat sheep
    reproduce
  ]
  
  regrow-grass ;; regrow the grass
  tick
  my-update-plots  ;; plot the population counts
end
 



  ; Random rotation
to random-movement
  wiggle
  
  ; Moving forward
  move
end


; Intelligent movement codes
to intelligent-movement
  if breed = sheep [
    let closest-wolf min-one-of wolves in-radius perception-range [
      distance myself
    ]
    
    if closest-wolf != nobody [
      face closest-wolf ; Turn in the direction of the nearest wolf
      lt 180 ; Reverse the turn to face the opposite direction to where the wolf is
    ]
    
    move
  ]
  
  if breed = wolves [
    let closest-sheep min-one-of sheep in-radius perception-range [
      distance myself
    ]
    
    if closest-sheep != nobody [
      face closest-sheep ; Turn towards the nearest cove
    ]
    
    move
  ]
end




to eat
  ifelse breed = sheep
  [eat-grass]
  [eat-sheep]
end

;; sheep procedure, sheep eat grass
to eat-grass
  ;; check to make sure there is grass here
  if ( grass-amount >= energy-gain-from-grass ) [
    ;; increment the sheep's energy
    set energy energy + energy-gain-from-grass
    ;; decrement the grass
    set grass-amount grass-amount - energy-gain-from-grass
    recolor-grass
  ]
end



;; wolf procedure, wolves eat sheep
to eat-sheep
  if any? sheep-here [  ;; if there are sheep here then eat one
    let target one-of sheep-here
    ask target [
      die
    ]
    ;; increase the energy by the parameter setting
    set energy energy + energy-gain-from-sheep
  ]
  
  ;; Check if the wolf's energy exceeds the split threshold
  if breed = wolves and energy > (2 * 100) [
    ;; Split the wolf into two offspring with half the energy
    hatch 1 [
      set energy (energy / 2)
      set color brown
      set shape "wolf"
      set size 2
    ]
  ]
end





;; turtle procedure (both wolves and sheep); check to see if this turtle has enough energy to reproduce
to reproduce
  if energy > 200 [
    set energy energy - 100  ;; reproduction transfers energy
    hatch 10 [ set energy 100 ] ;; to the new agent
  ]
end


;; turtle procedure, both wolves and sheep
to check-if-dead
 if energy < 0 [
    die
  ]
end

;; recolor the grass to indicate how much has been eaten
to recolor-grass
;;  set pcolor scale-color green grass 0 20
set pcolor scale-color green (10 - grass-amount) -10 20
end

;; regrow the grass
to regrow-grass
  ask patches [
    ; Regrowth of grass
    set grass-amount grass-amount + grass-regrowth-rate
    
    ; Control grass quantity limits
    if grass-amount > 10.0 [
      set grass-amount 10.0
    ]
    
    recolor-grass
  ]
end




;; turtle procedure, the agent moves which costs it energy
to move
  forward 1
  set energy energy - movement-cost ;; reduce the energy by the cost of movement
end

;; turtle procedure, the agent changes its heading
to wiggle
  ;; turn right then left, so the average is straight ahead
  rt random 90
  lt random 90
end




;; update the plots
to my-update-plots
  set-current-plot-pen "sheep"
  plot count sheep

  set-current-plot-pen "wolves"
  plot count wolves * 10 ;; scaling factor so plot looks nice
  
  let average-lifetime 0
  let total-lifetime 0
  ask sheep [
    set total-lifetime total-lifetime + ticks
  ]
  ifelse count sheep > 0 [
    set average-lifetime total-lifetime / count sheep
  ] [
    set average-lifetime 0
  ]
  set-current-plot-pen "average-sheep-lifetime"
  plot average-lifetime

  ;set-current-plot-pen "grass"
  ;plot sum [ grass-amount ] of patches / 50 ;; scaling factor so plot looks nice
end




to interface-setup
  clear-all
  set perception-range 1
end

to interface-go
  setup
  go
end

to update
  set perception-range 1
end
