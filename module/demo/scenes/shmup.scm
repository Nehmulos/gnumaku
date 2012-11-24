(define-module (demo scenes shmup)
  #:export (make-shmup-scene))
(use-modules (srfi srfi-9) (gnumaku core) (gnumaku director) (gnumaku scene) (gnumaku keycodes)
             (gnumaku coroutine) (gnumaku level) (gnumaku primitives) (gnumaku player) (gnumaku enemy)
             (gnumaku layer) (demo enemies) (demo levels demo))

(define field-width 480)
(define field-height 560)
(define player #f)
(define debug-mode #f)
(define bullet-sheet #f)
(define player-sheet #f)
(define enemy-sheet  #f)
(define background-image #f)
(define background #f)
(define font #f)
(define current-level #f)

(define (load-assets)
  (set! player-sheet (make-sprite-sheet "data/images/player.png" 32 48 0 0))
  (set! enemy-sheet (make-sprite-sheet "data/images/girl.png" 64 64 0 0))
  (set! bullet-sheet (make-sprite-sheet "data/images/bullets.png" 32 32 0 0))
  (set! background-image (load-image "data/images/background.png")))

(define (load-level)
  (let ((level (make-level field-width field-height demo-level player (load-image "data/images/space.png"))))
    (set-bullet-system-sprite-sheet! (level-enemy-bullet-system level) bullet-sheet)
    (set-bullet-system-sprite-sheet! (level-player-bullet-system level) bullet-sheet)
    (set-layer-position! (level-layer level) 20 20)
    level))

(define (init-player)
   (set! player (make-player (sprite-sheet-tile player-sheet 0) 3 10 350))
   (set-player-bounds! player (make-rect 0 0 field-width field-height))
   (set-player-shot! player player-shot-1)
   (set-player-position! player (/ field-width 2) (- field-height 32)))

(define (player-shot-1 player)
  (coroutine
   (when (player-shooting? player)
     (let ((x (player-x player))
	   (y (player-y player))
	   (speed 800)
           (bullets (player-bullet-system player)))
       (emit-bullet bullets (- x 16) y speed 268 0 0 'small-diamond)
       (emit-bullet bullets x (- y 20) speed 270 0 0 'small-green)
       (emit-bullet bullets (+ x 16) y speed 272 0 0 'small-diamond))
     (player-wait player 3)
     (player-shot-1 player))))

(define (add-test-enemy)
  (level-add-enemy! current-level (make-enemy-1 (random field-width) (random 150)
                                                (sprite-sheet-tile enemy-sheet 0))))

(define (on-start)
  (display "started")
  (newline)
  (load-assets)
  (set! background (make-sprite background-image))
  (init-player)
  (set! current-level (load-level))
  (run-level current-level))

(define (on-stop)
  (display "stopped")
  (newline))

(define (on-pause)
  (display "paused")
  (newline))

(define (on-resume)
  (display "resumed")
  (newline))

(define (on-update dt)
  (update-level! current-level dt))

(define (on-draw)
  (draw-sprite background)
  (draw-layer (level-layer current-level)))

(define (on-key-pressed key)
  (when (eq? key (keycode 'up))
    (player-move-up! player #t))
  (when (eq? key (keycode 'down))
    (player-move-down! player #t))
  (when (eq? key (keycode 'left))
    (player-move-left! player #t))
  (when (eq? key (keycode 'right))
    (player-move-right! player #t))
   (when (eq? key (keycode 'z))
     (set-player-shooting! player #t)))

(define (on-key-released key)
  (when (eq? key (keycode 'escape))
    (director-pop-scene))
   (when (eq? key (keycode 'up))
     (player-move-up! player #f))
   (when (eq? key (keycode 'down))
     (player-move-down! player #f))
   (when (eq? key (keycode 'left))
     (player-move-left! player #f))
   (when (eq? key (keycode 'right))
     (player-move-right! player #f))
   (when (eq? key (keycode 'z))
     (set-player-shooting! player #f))
   (when (eq? key (keycode 'w))
     (level-clear-enemies! current-level))
   (when (eq? key (keycode 'q))
     (add-test-enemy)))

(define (make-shmup-scene)
  ;; Make scene and bind events
  (let ((scene (make-scene)))
    (scene-on-start-hook scene on-start)
    (scene-on-stop-hook scene on-stop)
    (scene-on-pause-hook scene on-pause)
    (scene-on-resume-hook scene on-resume)
    (scene-on-update-hook scene on-update)
    (scene-on-draw-hook scene on-draw)
    (scene-on-key-pressed-hook scene on-key-pressed)
    (scene-on-key-released-hook scene on-key-released)
    scene))