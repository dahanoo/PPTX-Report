# -*- coding: utf-8 -*-
"""
Created on Thu Jul 21 14:22:58 2016

@author: TAQDJO
"""

import datetime
from dateutil.relativedelta import relativedelta
def suffix(d):
    return "th" if 11<=d<=13 else {1:"st",2:"nd",3:"rd"}.get(d%10, "th")

def custom_strftime(format, t):
    return t.strftime(format).replace('{S}', str(t.day) + str(suffix(t.day)))

def date_ranges():
    today = datetime.date.today()
    first = today.replace(day=1)
    lastMonth = first - datetime.timedelta(days=1)
    lastMonth2 = first + datetime.timedelta(days=0)
    lastMonthStart = lastMonth2 - relativedelta(months=0)
    MidMonth = first + datetime.timedelta(days=13) - relativedelta(months=0)
    MidMonth2 = first + datetime.timedelta(days=14) - relativedelta(months=1)
    monthEnd =lastMonth2 + relativedelta(months=1)
    
    if MidMonth <= today:
        date_from1 = custom_strftime('{S}', first)
        date_to1 = custom_strftime('{S} %B %Y', MidMonth)
        date_to2 = custom_strftime('{S} %B %Y', MidMonth)        
        date_from = custom_strftime('%Y-%m-%d', first)
        date_to = custom_strftime('%Y-%m-%d', MidMonth) 
        return date_from1, date_to1, date_to2, date_from, date_to
        
    if today < MidMonth:
        date_from1 = custom_strftime('{S}', MidMonth2)
        date_to1 = custom_strftime('{S} %B %Y', lastMonth)
        date_to2 = custom_strftime('{S} %B %Y', lastMonth)
        date_from = custom_strftime('%Y-%m-%d', MidMonth2)
        date_to = custom_strftime('%Y-%m-%d', lastMonth)
        return date_from1, date_to1, date_to2, date_from, date_to

dates = date_ranges()
