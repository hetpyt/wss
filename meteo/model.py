from . import db
from sqlalchemy.sql import func
from datetime import datetime


class NodeInfo(db.Model):
    __tablename__ = 'node_info'

    id = db.Column(db.SmallInteger, primary_key=True)
    latitude = db.Column(db.Float(precision=5))
    longitude = db.Column(db.Float(precision=5))
    altitude = db.Column(db.Float(precision=5))
    caption = db.Column(db.String(length=25))
    description = db.Column(db.Text)
    secret = db.Column(db.String(32), nullable=False)
    # last data
    last_date = db.Column(db.DateTime, nullable=True)
    last_temperature = db.Column(db.Float(precision=5), nullable=True)
    last_humidity = db.Column(db.Float(precision=5), nullable=True)
    last_pressure_qfe = db.Column(db.Float(precision=5), nullable=True)
    last_voltage = db.Column(db.Float(precision=5), nullable=True)
    # meteodata = db.relationship('MeteoData', backref='node', lazy='joined')

    def __repr__(self):
        res = f'node #{self.id}'
        if self.caption:
            res = f'{self.caption} [{res}]'
        return res


class MeteoData(db.Model):
    __tablename__ = 'meteo_data'

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    date = db.Column(db.DateTime, server_default=func.now())
    node_id = db.Column(db.SmallInteger, db.ForeignKey(f'{NodeInfo.__tablename__}.id'), nullable=False)
    temperature = db.Column(db.Float(precision=5), nullable=True)
    humidity = db.Column(db.Float(precision=5), nullable=True)
    pressure_qfe = db.Column(db.Float(precision=5), nullable=True)
    voltage = db.Column(db.Float(precision=5), nullable=True)

    def __repr__(self):
        return f'{self.date}: node={self.node_id}, t={self.temperature}, h={self.humidity}, q={self.pressure_qfe}'

    @classmethod
    def from_json(cls, json_data: dict):
        return cls(
            date=datetime.now(),
            node_id=json_data['node_id'],
            temperature=json_data.get('temp'),
            humidity=json_data.get('humi'),
            pressure_qfe=json_data.get('qfe'),
            voltage=json_data.get('volt')
        )
