;.globalzp seed
;.globalzp fixed_seed

.global initialize_prng
.global next_gameplay_rand
.global next_run_rand
.global next_floor_rand
.global next_room_rand

.global generate_floor_seed ; from the run seed
.global generate_room_seed  ; from the floor seed