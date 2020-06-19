# -*- coding: utf-8 -*-
"""
Created on Wed Mar 09 09:40:50 2016

@author: TAQDJO
"""

import json
import utils as u

date_from = input("Date from: ")
date_to = input("Date to: ")
client_name = input("Enter client name: ")
user = input("Your first name: ")
shared = {"df": date_from, "dt": date_to, "cl": client_name, "u": user}
fp = open("shared.json", "w")
json.dump(shared, fp)
fp.close()
df = u.run_sql_query(full_path("Ann_report_sql", "Fleet_general_info.sql"), shared)
df.to_csv('plots/genInf.csv')

