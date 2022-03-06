import json
import time
from os import path

import spotipy
from spotipy import SpotifyOAuth, Spotify
from benedict import benedict
from typing import Callable, Any, Literal, TypeAlias

scopes = [
    'user-library-read',
    'user-read-playback-state',
    'user-modify-playback-state',
    'user-library-modify',
    'user-follow-modify',
    'user-read-currently-playing',
    # 'user-read-recently-played',
    # 'user-follow-read',
    # 'user-top-read',
    # 'user-read-playback-position',
    # 'playlist-read-private',
    # 'playlist-read-collaborative',
    # 'playlist-modify-private',
    # 'app-remote-control'
]


def get_artist(now_playing: benedict):
    x = now_playing.get('item.artists[0].id', None)
    return x


def get_album(now_playing: benedict):
    return now_playing.get('item.album.id', None)


def is_different_artists(now_playing1: benedict, now_playing2: benedict):
    return get_artist(now_playing1) != get_artist(now_playing2)


def is_different_albums(now_p1: benedict, now_p2: benedict):
    return get_album(now_p1) != get_album(now_p2)


def is_different_tracks(now_p1: benedict, now_p2: benedict):
    return get_track(now_p1) != get_track(now_p2)


def get_position(now_p: benedict):
    return now_p.get('progress_ms')


def get_track(now_p: benedict):
    return now_p.get('item.id', None)


MusicType: TypeAlias = Literal['album', 'artist', 'all', 'track']


def pick_dif_function(what: MusicType):
    match what:
        case 'album':
            return is_different_albums
        case 'artist':
            return is_different_artists
        case 'track':
            return is_different_tracks
        case 'all':
            return lambda x, y: False
        case _:
            raise Exception(f'Expected {what} to be a valid start type')


def is_muted(obj: benedict):
    if obj.get('device.volume_percent') != 0:
        return False
    if not path.isfile('./vol.txt'):
        return False
    return True


default_max = 30

backtrack_before = 10 * 1000


class SpotifyInterface:
    _spotify: Spotify

    def __init__(self):
        start = time.time()
        self._spotify = spotipy.Spotify(auth_manager=SpotifyOAuth(
            client_id='8c466d1e3ee34a0d9cb654f7b9b58ff7',
            client_secret='3b27fd3d6562405181db485a980d3de7',
            scope=",".join(scopes),
            redirect_uri='http://localhost:12000'
        ))
        self._spotify._session.trust_env = False

    def _get_current_track(self):
        return benedict(self._spotify.currently_playing())

    def _get_current(self):
        return benedict(self._spotify.current_playback())

    def seek_time(self, mod: int) -> None:
        current = self._get_current()
        progress = current.get("progress_ms", None)
        if progress is None:
            return
        new_progress = max(0, progress + mod)
        self._spotify.seek_track(new_progress)

    def _skim_while(self, op: Callable[[], Any], max_ops=default_max):
        prev_ts = 0
        for i in range(max_ops):
            op()
            time.sleep(0.25)
            playback = self._get_current()
            cur_ts = playback.get('timestamp')
            if prev_ts == cur_ts:
                time.sleep(0.25)
                playback = self._get_current()
            prev_ts = cur_ts
            yield [playback, i]
            if playback.get('actions.disallows.skipping_prev', False):
                return

    def restart_track(self):
        self._spotify.seek_track(0)

    def prev_track(self):
        self._spotify.previous_track()

    def next_track(self):
        self._spotify.next_track()

    def toggle_pause(self):
        current = self._get_current()
        if current.get('is_playing'):
            self._spotify.pause_playback()
        else:
            self._spotify.start_playback()

    def restart_thing(self):
        initial = self._get_current()
        old_repeat = initial.get('repeat_state')
        if old_repeat != 'off':
            self._spotify.repeat('off')
        for [current, count] in self._skim_while(lambda: self._spotify.previous_track()):
            pass
        if old_repeat != 'off':
            self._spotify.repeat(old_repeat)

    def set_repeat(self, mode):
        self._spotify.repeat(mode)

    def skip_album(self):
        initial = self._get_current()
        old_repeat = initial.get('repeat_state')
        if old_repeat != 'off':
            self._spotify.repeat('off')

        for [current, count] in self._skim_while(lambda: self._spotify.next_track()):
            if is_different_albums(initial, current):
                break

        if old_repeat != 'off':
            self._spotify.repeat('off')

    def heart_track(self):
        current = self._get_current()
        track = get_track(current)
        self._spotify.current_user_saved_tracks_add([track])

    def heart_album(self):
        current = self._get_current()
        album = get_album(current)
        self._spotify.current_user_saved_albums_add([album])

    def follow_artist(self):
        current = self._get_current()
        artist = get_artist(current)
        self._spotify.user_follow_artists([artist])

    def dump_currently_playing(self):
        print(json.dumps(self._get_current()))

    def spin_album(self):
        playback = self._get_current()
        album_uri = playback.get('item.album.uri')
        self._spotify.start_playback(context_uri=album_uri, offset={
            'position': 1
        })

    def spin_artist(self):
        playback = self._get_current()
        artist_uri = playback.get('item.artists[0].uri')
        self._spotify.start_playback(context_uri=artist_uri)
