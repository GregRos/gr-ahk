import argparse
from re import sub
import threading
import time
from spotipy import SpotifyException
from spotify_interface import SpotifyInterface

root_parser = argparse.ArgumentParser(description='spotify automation script')

root_parser.add_argument("id", type=str)

subparsers = root_parser.add_subparsers(title='actions', required=True, dest='command')
backward_track = subparsers.add_parser('previous-track', help='previous track')
reset_track = subparsers.add_parser('restart-track', help='restarts current track', )
forward_track = subparsers.add_parser('next-track', help='next track')
forward_album = subparsers.add_parser('skip-album', help='skip current album')
restart_thing = subparsers.add_parser('restart-thing', help='restarts the current context')

spin = subparsers.add_parser('spin', help='changes context related to current track')
spin.add_argument('what', choices=['album', 'artist'])

repeat = subparsers.add_parser('repeat', help='change replay mode')
repeat.add_argument('mode', choices=['off', 'track', 'context'])

play_pause = subparsers.add_parser('toggle-play', help='toggles play/pause')
heart_parser = subparsers.add_parser('heart')
heart_parser.add_argument('heart_type', choices=['track', 'artist', 'album'])

dump_parser = subparsers.add_parser('dump', help='dump playing state')

seek_parser = subparsers.add_parser('seek', help='seek in current track')
seek_parser.add_argument('seconds', type=int, help='±seconds to seek in track')


class SpotifyAutomator:
    def __init__(self, spotify: SpotifyInterface):
        self._spotify = spotify

    def out(self, input):
        print(input, flush=True)

    def exec_line(self, line: str):
        args = root_parser.parse_args(line.split(" "))
        self._exec_command_and_report(args)

    def _out_job_result(self, cmd_id: str, t: float, err_or_none=None):
        parts = [cmd_id]
        duration = time.time() - t
        parts.append(f'{duration}s')
        if err_or_none is not None:
            parts.append("ERROR")
            parts.append(str(err_or_none))
        else:
            parts.append("SUCCESS")
        self.out(" ".join(parts))

    def _spin_while(self, other: threading.Thread):
        def inner_spin():
            # we need this because of the odd way AHK behaves when executing win32 code...
            while other.is_alive():
                self.out('.')
                time.sleep(0.1)

        threading.Thread(target=inner_spin).start()

    def _exec_command_and_report(self, cmd_args):
        def inner_exec():
            start_time = time.time()
            try:
                self._exec_command(cmd_args)
                self._out_job_result(cmd_args.id, start_time)
            except SpotifyException as err:
                self._out_job_result(cmd_args.id, start_time, f'{err.msg.split("Player command failed:")[1].strip()}')
            except Exception as err:
                self._out_job_result(cmd_args.id, start_time, str(err))

        inner_thread = threading.Thread(target=inner_exec)
        inner_thread.start()
        self._spin_while(inner_thread)

    def _exec_command(self, cmd_args):
        spotify = self._spotify
        match cmd_args.command:
            case 'repeat':
                spotify.set_repeat(cmd_args.mode)
            case 'restart-thing':
                spotify.restart_thing()
            case 'next-track':
                spotify.next_track()
            case 'previous-track':
                spotify.prev_track()
            case 'skip-album':
                spotify.skip_album()
            case 'restart-track':
                spotify.restart_track()
            case 'toggle-play':
                spotify.toggle_pause()
            case 'dump':
                spotify.dump_currently_playing()
            case 'seek':
                spotify.seek_time(cmd_args.seconds * 1000)
            case 'spin':
                match cmd_args.what:
                    case 'artist':
                        spotify.spin_artist()
                    case 'album':
                        spotify.spin_album()
            case 'heart':
                match cmd_args.heart_type:
                    case 'track':
                        spotify.heart_track()
                    case 'artist':
                        spotify.follow_artist()
                    case 'album':
                        spotify.heart_album()
