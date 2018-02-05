import os

AddOption('--install-dir',
          metavar='DIR',
          default=os.path.expanduser("~/.local/share/nautilus/scripts"),
          help='installation directory')

env = Environment(INSTALL_DIR=GetOption('install_dir'))
# Install all executable files and files with .sh extension
for file in [ f for f in os.listdir('.') \
              if (os.access(f, os.X_OK) and os.path.isfile(f)) or \
                  os.path.splitext(f)[1] == '.sh' ]:
    env.Install('$INSTALL_DIR', file)
env.Alias('install', '$INSTALL_DIR')
