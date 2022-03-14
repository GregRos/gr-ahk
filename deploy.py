from os import chdir, environ
from pathlib import Path
from os import chdir, system
wintools = environ.get("WINTOOLS")
p = Path(rf"{wintools}\Macros\GR-AHK")
chdir(p)
system("git reset --hard HEAD")
system("git clean -f")
system("git pull --ff-only")



