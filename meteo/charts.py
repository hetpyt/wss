from flask import Blueprint, render_template
from markupsafe import escape
from .model import NodeInfo, MeteoData
from datetime import datetime, timedelta
import json

bp = Blueprint('charts', __name__, url_prefix='/charts')


@bp.route("/")
def charts_all():
    td30 = timedelta(30)
    chart_temp = _generate_chart('Temperature', '&deg; С')
    chart_humi = _generate_chart('Humidity', '%')
    chart_qfe = _generate_chart('Pressure', 'hPa')

    for node in NodeInfo.query.order_by(NodeInfo.id):
        node_data = MeteoData.query\
            .filter(MeteoData.node_id == node.id, MeteoData.date >= (datetime.now() - td30))\
            .order_by(MeteoData.date)
        chart_temp['series'].append(_prepare_series(node.caption, node_data, 'temperature'))
        chart_humi['series'].append(_prepare_series(node.caption, node_data, 'humidity'))
        chart_qfe['series'].append(_prepare_series(node.caption, node_data, 'pressure_qfe'))

    return render_template('charts/overview.html',
                           CHART_DATA_TEMP=json.dumps(chart_temp),
                           CHART_DATA_HUMI=json.dumps(chart_humi),
                           CHART_DATA_QFE=json.dumps(chart_qfe)
                           )


@bp.route("/<name>")
def chart_page(name):
    return f'<h1>chart {escape(name)}</h1>'


def _prepare_series(name, data, field):
    result = {
        'name': name,
        'data': []
    }
    for row in data:
        result['data'].append((
            int(row.date.timestamp() * 1000),
            getattr(row, field)
            ))
    return result


def _generate_chart(title, y_title):
    return {
        'time': {
            'timezoneOffset': -3 * 60
        },
        'chart': {
            'type': 'spline'
        },
        'title': {
            'text': title
        },
        'xAxis': {
            'type': 'datetime',
            'dateTimeLabelFormats': {
                'day': '%Y.%m.%d',
                'hour': '%Y.%m.%d %H:%M',
            },
            'title': {
                'text': 'Date'
            }
        },
        'yAxis': {
            'title': {
                'text': y_title
            }
        },
        'tooltip': {
            'dateTimeLabelFormats': {
                'day': '%Y.%m.%d',
                'hour': '%Y.%m.%d %H:%M',
                'minute': '%Y.%m.%d %H:%M',
                'second': '%Y.%m.%d %H:%M:%S',
            },
        },
        'series': [],
        'responsive': {
            'rules': [{
                'condition': {
                    'maxWidth': 500
                },
                'chartOptions': {
                    'plotOptions': {
                        'series': {
                            'marker': {
                                'radius': 2.5
                            }
                        }
                    }
                }
            }]
        }
    }
