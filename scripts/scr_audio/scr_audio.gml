function scr_audio_init() {
    global.audio_enabled = !global.qa;
    global.music_track = -1;
    global.music_handle = -1;
    global.intro_scene = 0;
    if (!global.audio_enabled) return;
    audio_master_gain(0.7);
}

function scr_music(_track) {
    if (!global.audio_enabled) return;
    if (global.music_track == _track) return;
    if (global.music_handle != -1) audio_stop_sound(global.music_handle);
    global.music_handle = -1;
    global.music_track = _track;
    if (_track != -1) global.music_handle = audio_play_sound(_track, 0, true);
}

function scr_sfx(_sound, _variation=0, _gain=1) {
    if (!global.audio_enabled) return;
    var _instance = audio_play_sound(_sound, 5, false);
    if (_variation > 0) audio_sound_pitch(_instance, 1 + random_range(-_variation, _variation));
    if (_gain != 1) audio_sound_gain(_instance, _gain, 0);
}

function scr_intro_audio() {
    if (!global.audio_enabled) return;
    var _scene = min(2, global.game_timer div 240);
    if (_scene != global.intro_scene) {
        global.intro_scene = _scene;
        scr_sfx(sfx_intro_whoosh);
    }
    if (global.game_timer == 270) scr_sfx(sfx_intro_artifact, 0, 0.9);
}
