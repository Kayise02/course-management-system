from . import db
from flask_login import UserMixin
from sqlalchemy.sql import func


class Note(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    data = db.Column(db.String(10000))
    date = db.Column(db.DateTime(timezone=True), default=func.now())
    user_id = db.Column(db.Integer, db.ForeignKey("user.id"))


class User(db.Model, UserMixin):
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(150), unique=True)
    password = db.Column(db.String(256))  # FIX: increased from 150 to fit pbkdf2 hashes
    first_name = db.Column(db.String(150))
    # FIX: Added role column to match the Java/MySQL schema (admin, instructor, student)
    role = db.Column(db.String(20), nullable=False, default="student")
    notes = db.relationship("Note")
