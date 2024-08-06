; these enemy lists are all ported from the action53 build
; we only kept the challenge room arrangements, and frankly these aren't especially
; threatening even to novice players, so we need to rework them

;    ######  ##     ##    ###    ##       ##       ######## ##    ##  ######   ######## 
;   ##    ## ##     ##   ## ##   ##       ##       ##       ###   ## ##    ##  ##       
;   ##       ##     ##  ##   ##  ##       ##       ##       ####  ## ##        ##       
;   ##       ######### ##     ## ##       ##       ######   ## ## ## ##   #### ######   
;   ##       ##     ## ######### ##       ##       ##       ##  #### ##    ##  ##       
;   ##    ## ##     ## ##     ## ##       ##       ##       ##   ### ##    ##  ##       
;    ######  ##     ## ##     ## ######## ######## ######## ##    ##  ######   ######## 

sl_slime_pit:
        .byte 3 ; list length
        .addr enemy_slime_basic
        .byte 2
        .addr enemy_slime_intermediate
        .byte 6
        .addr enemy_slime_advanced
        .byte 4

sl_scary_scary_spiders:
        .byte 3 ; list length
        .addr enemy_spider_basic
        .byte 2
        .addr enemy_spider_intermediate
        .byte 4
        .addr enemy_mole_basic
        .byte 4

sl_rockin_flock:
        .byte 7 ; list length
        .addr enemy_zombie_intermediate     
        .byte 4
        .addr enemy_birb_basic_left         
        .byte 1
        .addr enemy_birb_basic_right        
        .byte 1
        .addr enemy_birb_intermediate_left  
        .byte 2
        .addr enemy_birb_intermediate_right 
        .byte 2
        .addr enemy_birb_advanced_left      
        .byte 1
        .addr enemy_birb_advanced_right     
        .byte 1

sl_aaaaaahhh_spiders:
        .byte 4 ; list length
        .addr enemy_slime_intermediate  
        .byte 2
        .addr enemy_spider_basic        
        .byte 4
        .addr enemy_spider_intermediate 
        .byte 5
        .addr enemy_spider_advanced     
        .byte 3

sl_mr_whiskers:
        .byte 4 ; list length
        .addr enemy_mole_basic              
        .byte 6
        .addr enemy_mole_advanced           
        .byte 4
        .addr enemy_birb_intermediate_left  
        .byte 1
        .addr enemy_birb_intermediate_right 
        .byte 1

sl_reinforcements:
        .byte 7 ; list length
        .addr enemy_zombie_advanced     
        .byte 6
        .addr enemy_zombie_intermediate 
        .byte 2
        .addr enemy_zombie_basic        
        .byte 2
        .addr enemy_spider_advanced     
        .byte 4
        .addr enemy_spider_intermediate 
        .byte 2
        .addr enemy_spider_basic        
        .byte 1
        .addr enemy_slime_advanced      
        .byte 2

sl_family_reunion:
        .byte 14 ; list length
        .addr enemy_slime_basic            
        .byte 1
        .addr enemy_slime_intermediate     
        .byte 1
        .addr enemy_slime_advanced         
        .byte 2
        .addr enemy_zombie_basic           
        .byte 1
        .addr enemy_zombie_intermediate    
        .byte 1
        .addr enemy_zombie_advanced        
        .byte 3
        .addr enemy_spider_basic           
        .byte 1
        .addr enemy_spider_intermediate    
        .byte 1
        .addr enemy_spider_advanced        
        .byte 2
        .addr enemy_mole_basic             
        .byte 1
        .addr enemy_mole_advanced          
        .byte 2
        .addr enemy_birb_basic_left        
        .byte 1
        .addr enemy_birb_intermediate_left 
        .byte 1
        .addr enemy_birb_advanced_left     
        .byte 2
