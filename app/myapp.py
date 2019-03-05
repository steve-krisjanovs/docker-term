from blessed import Terminal
import sys

term = Terminal()
with term.location(0, 0):
    print('Hello world!\nPress [ENTER] key to exit')

sys.stdin.read(1)
sys.exit()
