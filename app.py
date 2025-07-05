from flask import Flask, request, jsonify, render_template
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime, timedelta
import threading
import time
import os

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///bot_monitor.db'
db = SQLAlchemy(app)

class BotAccount(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    account_name = db.Column(db.String(50), unique=True, nullable=False)
    wealth = db.Column(db.Integer, default=0)
    runtime = db.Column(db.String(20), default="0:00:00")
    status = db.Column(db.String(20), default="Offline")
    health = db.Column(db.Integer, default=0)
    max_health = db.Column(db.Integer, default=0)
    prayer = db.Column(db.Integer, default=0)
    combat_level = db.Column(db.Integer, default=0)
    skill_level = db.Column(db.Integer, default=0)
    is_dead = db.Column(db.String(20), default="False")
    region_x = db.Column(db.Integer, default=0)
    region_y = db.Column(db.Integer, default=0)
    region_id = db.Column(db.Integer, default=0)
    last_update = db.Column(db.DateTime, default=datetime.utcnow)

@app.route('/update', methods=['POST'])
def update():
    account_name = request.form.get('account_name')
    if not account_name:
        return jsonify(error="Missing account name"), 400
    
    account = BotAccount.query.filter_by(account_name=account_name).first()
    
    if not account:
        account = BotAccount(account_name=account_name)
    
    account.wealth = request.form.get('wealth', 0)
    account.runtime = request.form.get('runtime', "0:00:00")
    account.status = request.form.get('status', 'Offline')
    account.health = int(request.form.get('health', 0))
    account.max_health = int(request.form.get('max_health', 0))
    account.prayer = int(request.form.get('prayer', 0))
    account.combat_level = int(request.form.get('combat_level', 0))
    account.skill_level = int(request.form.get('skill_level', 0))
    account.is_dead = request.form.get('is_dead', 'False')
    account.region_x = int(request.form.get('region_x', 0))
    account.region_y = int(request.form.get('region_y', 0))
    account.region_id = int(request.form.get('region_id', 0))
    account.last_update = datetime.utcnow()
    
    db.session.add(account)
    db.session.commit()
    return jsonify(success=True)

@app.route('/')
def dashboard():
    stale_time = datetime.utcnow() - timedelta(minutes=2)
    stale_accounts = BotAccount.query.filter(
        BotAccount.last_update < stale_time,
        BotAccount.status == 'Online'
    ).all()
    
    for account in stale_accounts:
        account.status = 'Stale'
        db.session.add(account)
    
    db.session.commit()
    
    accounts = BotAccount.query.order_by(BotAccount.last_update.desc()).all() or []
    current_time = datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S')
    return render_template('dashboard.html', accounts=accounts, current_time=current_time)

def start_server():
    with app.app_context():
        db.create_all()
    app.run(host='0.0.0.0', port=5000, threaded=True)

if __name__ == '__main__':
    os.makedirs('templates', exist_ok=True)
    server_thread = threading.Thread(target=start_server)
    server_thread.daemon = True
    server_thread.start()
    print("Monitoring server running at http://localhost:5000")
    
    while True:
        time.sleep(1)