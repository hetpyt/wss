import sys
sys.path.insert(0, '/path/to/the/application/venv')
sys.path.insert(0, '/path/to/the/application')
from meteo import create_app

application = create_app()
