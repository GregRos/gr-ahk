import argparse
import sys
import time
import logging
import threading
from spotify_interface import SpotifyInterface
from automator import SpotifyAutomator

logging.disable(100)


cli_parser = argparse.ArgumentParser(description='spotify automation script')

if __name__ == '__main__':
    args = cli_parser.parse_args()
    repl = SpotifyAutomator(SpotifyInterface())
    repl.out("Spotify Automator Online!")
    for line in sys.stdin:
        line = line.rstrip()
        repl.exec_line(line)
