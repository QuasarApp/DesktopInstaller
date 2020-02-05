import os
from pathlib import Path
import sys
import shutil   

location = sys.argv[1]

PWD = os.path.dirname(os.path.realpath(__file__))

Path(location).mkdir(parents=True, exist_ok=True)

shutil.copytree(PWD + "/config", location + "/config")
shutil.copytree(PWD + "/packages", location + "/packages")


