from flask import Blueprint, render_template
from .model import NodeInfo

bp = Blueprint('main', __name__)


@bp.route("/")
def index():
    nodes = NodeInfo.query.order_by(NodeInfo.id)
    return render_template('main/overview.html', nodes=nodes)
