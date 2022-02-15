from flask import Blueprint, request, jsonify
from .model import NodeInfo, MeteoData
from . import db


bp = Blueprint('api', __name__, url_prefix='/api')


@bp.route('/post', methods=['POST'])
def post_data():
    message = 'unknown error'
    data = request.get_json(force=True, silent=True, cache=False)
    if data is not None:
        if isinstance(data, dict):
            node_id = data.get('node_id')
            if node_id is not None:
                node_info = NodeInfo.query.get(node_id)
                if node_info is not None:
                    # TODO check node's secret
                    if node_info.secret == data.get('secret'):
                        check_and_store(data)
                        return jsonify(result='OK')
                    else:
                        message = 'not auth'
                else:
                    message = 'node not registered'
            else:
                message = 'no node id'
        else:
            message = 'not dict'
    return jsonify(result='FAIL', message=message)


def check_and_store(data):
    md = MeteoData.from_json(data)
    NodeInfo.query.filter(NodeInfo.id == md.node_id).update({
        'last_date': md.date,
        'last_temperature': md.temperature,
        'last_humidity': md.humidity,
        'last_pressure_qfe': md.pressure_qfe,
        'last_voltage': md.voltage,
    })
    db.session.add(md)
    db.session.commit()

