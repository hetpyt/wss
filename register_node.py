from meteo import create_app, db
from meteo.model import NodeInfo


def _input(prompt=None, default=None):
    s = input(prompt)
    if not s:
        s = default
    return s


all_required = False
try:
    while not all_required:
        print('register new node (* required fields')
        node_id = _input('node id []:')
        caption = _input('node caption []')
        latitude = _input('node latitude []')
        longitude = _input('node longitude []')
        altitude = _input('node altitude []')
        description = _input('node description []')
        secret = _input('node secret [*]')
        if secret:
            all_required = True
        else:
            print('you must fill all required fields')
except EOFError:
    exit(0)

app = create_app()
with app.app_context():
    ni = NodeInfo(
        id=node_id,
        caption=caption,
        latitude=latitude,
        longitude=longitude,
        altitude=altitude,
        description=description,
        secret=secret
    )
    db.session.add(ni)
    db.session.commit()
