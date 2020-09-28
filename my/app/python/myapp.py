from blessed import Terminal
import sys
import os

os.system('clear')
term = Terminal()
with term.location(0, 0):
    print('Hello world from python!\nPress [ENTER] key to exit')

sys.stdin.read(1)
sys.exit()
