function scr_audio_init() {
    global.audio_enabled = !global.qa;
    if (!variable_global_exists("audio_volume")) {
        global.audio_volume = 0.7;
        global.audio_music_on = true;
        global.audio_game_muted = false;
    }
    global.music_track = -1;
    global.music_handle = -1;
    global.intro_scene = 0;
    if (!global.audio_enabled) return;
    scr_audio_apply();
}

function scr_audio_apply() {
    if (!global.audio_enabled) return;
    audio_master_gain(global.audio_game_muted ? 0 : global.audio_volume);
}

function scr_music(_track) {
    if (!global.audio_enabled) return;
    if (_track != global.music_track) {
        if (global.music_handle != -1) audio_stop_sound(global.music_handle);
        global.music_handle = -1;
        global.music_track = _track;
    }
    scr_audio_refresh_music();
}

function scr_audio_refresh_music() {
    if (!global.audio_enabled) return;
    var _play = global.audio_music_on && global.music_track != -1;
    if (_play && global.music_handle == -1) {
        global.music_handle = audio_play_sound(global.music_track, 0, true);
    } else if (!_play && global.music_handle != -1) {
        audio_stop_sound(global.music_handle);
        global.music_handle = -1;
    }
}

function scr_audio_music_toggle() {
    if (!global.audio_enabled) return;
    global.audio_music_on = !global.audio_music_on;
    scr_audio_refresh_music();
}

function scr_audio_volume(_delta) {
    if (!global.audio_enabled) return;
    global.audio_volume = clamp(global.audio_volume + _delta, 0, 1);
    scr_audio_apply();
}

function scr_audio_mute_toggle() {
    if (!global.audio_enabled) return;
    global.audio_game_muted = !global.audio_game_muted;
    scr_audio_apply();
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
