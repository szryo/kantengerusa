#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Sep 27 20:20:20 2021

@author: yuta-kim
"""

import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

import threading
import time

import pigpio

gpio_pin0 = 19
gpio_pin1 = 18

pi = pigpio.pi()
pi.set_mode(gpio_pin0, pigpio.OUTPUT)
pi.set_mode(gpio_pin1, pigpio.OUTPUT)

pi.set_servo_pulsewidth(gpio_pin0, 1450)
pi.set_servo_pulsewidth(gpio_pin1, 1450)

# Use the application default credentials
cred = credentials.Certificate('./key.json')
firebase_admin.initialize_app(cred)

db = firestore.client()

users_ref = db.collection(u'test')
# query = users_ref.order_by("time").limit(2)
# docs = query.get()

# for doc in docs:
#     print(f'{doc.id} => {doc.to_dict()}')
# Create an Event for notifying main thread.
callback_done = threading.Event()
l = []

mode = -1
def on_snapshot(col_snapshot, changes, read_time):
    global mode
    print(u'Callback received query snapshot.')
    print(u'Current cities in California:')
    #query = users_ref()#.order_by("time",direction=firestore.Query.DESCENDING).limit(1)
    docs = users_ref.document("move").get().to_dict()#query.get()
    print(docs)
    #for doc in docs:
    #    print(f'{doc.id} => {doc.to_dict()}')
    #    l.append([doc.id,doc.to_dict()])
    #n = float(l[-1][1]["neutral"])
    #h = float(l[-1][1]["happiness"])
    mode = docs["move"]
#    o = sum([float(j) for i,j in l[-1][1].items() if not(i in ["time","neutral","happiness","modeNutral","modeHappyness","modeOthers"])])
#    if mode == -1:
#        mode = 0
#    elif n>0.96:
#        mode = int(l[-1][1]["modeNutral"])
#    elif o > 0.04:
#        mode = int(l[-1][1]["modeOthers"])
#    elif h > 0.04:
#        mode = int(l[-1][1]["modeHappyness"])
#    else:
#        mode = 0
    callback_done.set()

col_query = db.collection(u'test')

# Watch the collection query
query_watch = col_query.on_snapshot(on_snapshot)

for i in range(100000):
    if mode == 0:
        pi.set_servo_pulsewidth(gpio_pin0, 1450)
        pi.set_servo_pulsewidth(gpio_pin1, 1450)
        time.sleep(1)
    elif mode == 1:
        pi.set_servo_pulsewidth(gpio_pin0, 500)
        pi.set_servo_pulsewidth(gpio_pin1, 2000)
        time.sleep(1)
    elif mode == 2:
        pi.set_servo_pulsewidth(gpio_pin0, 500)
        pi.set_servo_pulsewidth(gpio_pin1, 2000)
        time.sleep(0.5)
        pi.set_servo_pulsewidth(gpio_pin0, 1450)
        pi.set_servo_pulsewidth(gpio_pin1, 1450)
        time.sleep(0.5)
    else:
        time.sleep(1)
    print(i)
