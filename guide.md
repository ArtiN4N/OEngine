AUDIO:
    INITIALIZATION:
        IN ```setUpState()```:
        - use ```loadSoundToState()```
        - use ```attachDynamicAudioControlToMusic(handler, ...)``` to make music/alias dynamic
    USE:
        - use ```createNewSoundAlias(handler, tag)``` to create and play new sfx
        - use ```setAudioHandlerMusic(handler, tag, volume)``` to set music track
        - use ```playAudioHandlerMusic(handler)``` to play music track
        - use ```setDyanmicPitchTargetWithSpeed(handler, target, speed)``` to change pitch/speed of music track
        - use ```updateAudioHandler(handler, dt)``` to update audio
SPRITES:
    INITIALIZATION:
        IN ```setUpState()```:
        - use ```loadTextureToState()```
        - create sprite with ```sprite = init_Sprite()```
        - use ```attachSpriteAnimationController(&sprite, outlog)``` to make it animate-able
        - use ```addAnimationToSpriteController(controller, offset in spritesheet, ..., tag name)```
    USE:
        - use ```ChangeSpriteAnimation(controller, tag)``` to change the animation
        - use ```SpriteAnimationUpdate(controller, dt, outlog)``` to update animations
        - use ```drawSprite(sprite, rotation)``` to draw sprite/animations
INPUT:
    USE:
        - use ```addInputCallbackOnKey(handler, key, tag, callback)``` to add a callback to a key press
        - use ```changeTaggedKey(handler, key, tag, callback)``` to change callback by key press
        - create a callback on input with a procedure defined as ```proc(state: ^State, key: rl.KeyboardKey, tag: string)```
        - use ```checkInput(handler, state)``` to check input
        - use ```getInputTypedText(handler)``` to get realtime text input