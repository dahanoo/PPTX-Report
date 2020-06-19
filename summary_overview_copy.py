# -*- coding: utf-8 -*-
"""
Created on Wed Jan 23 13:06:38 2019

@author: Danny
"""

import utils as u
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import matplotlib.font_manager as font_manager
import pandas as pd
from math import pi
pd.options.mode.chained_assignment = None
pd.set_option("display.max_rows", 999)
pd.set_option("display.max_columns", 20)
date_from = '2018-01-01'
date_to = '2018-12-31'
user = 'naeem'
client = "TSAKOS SHIPPING"
shared = {"df": date_from, "dt": date_to, "cl": client, "u": user}
df = u.run_sql_query(u.full_path("Ann_report_sql", "spider_plot.sql"), shared)
df = df.drop_duplicates(subset='id', keep='last').reset_index(drop=True)

df['TSP_Result'] = df['TSP_Result'].replace('> 25 mins', '0.3')


def clients_global_summary():
    vc = []
    dc = []
    df2 = df[~((df.id.duplicated(keep=False)) &
               (df.BDN == 'no'))].reset_index(drop=True)
    perc_red = 100 - (len(df2[df2['overall_lr_outcome'] == 'RED']) / len(df2)) * 100
    df_bdn = df2.groupby('BDN').count().reset_index(drop=False)
    df_bdn = df_bdn[['BDN', 'id']].T
    perc_bdn = (df_bdn.iloc[1, 1] / (df_bdn.iloc[1, 0] + df_bdn.iloc[1, 1])) * 100
    sample_count_hfo = len(df2[df2['material_type'] == 'HFO'])
    sample_count_lsfo = len(df2[df2['sulphur_level'] == 'LOW'])
    sul = len(df2[(df2['sulphur_level'] == 'LOW') &
                  (df2['Sulphur_Result'].astype(float) <= 0.11)])
    perc_sul = (sul / sample_count_lsfo) * 100
    alsi = len(df2[(df2['material_type'] == 'HFO') &
                   (df2['AlSi_Result'].astype(int) <= 40)])
    perc_alsi = (alsi / sample_count_hfo) * 100
    df2['TSP_Result'] = df2['TSP_Result'].fillna(0)
    tsp = len(df2[(df2['material_type'] == 'HFO') &
                  (df2['TSP_Result'].astype(float) <= 0.1)])
    perc_tsp = (tsp / sample_count_hfo) * 100
    limits = {'RMA10': {'vis': 10.44, 'den': 0.9209},
              'RMB30': {'vis': 31.31, 'den': 0.9609},
              'RMD80': {'vis': 83.49, 'den': 0.9759},
              'RME180': {'vis': 187.9, 'den': 0.9919},
              'RMF180': {'vis': 396.6, 'den': 0.9919},
              'RMG380': {'vis': 396.6, 'den': 0.9919},
              'RMG500': {'vis': 521.8, 'den': 0.9919},
              'RMH380': {'vis': 730.6, 'den': 0.9919},
              'RMH500': {'vis': 521.8, 'den': 0.9919},
              'RMH700': {'vis': 730.6, 'den': 0.9919},
              'RMK380': {'vis': 396.6, 'den': 0.1019},
              'RMK500': {'vis': 521.8, 'den': 0.1019},
              'RMK700': {'vis': 730.6, 'den': 0.1019},
              }
    df2 = df2[(df2['adv_density'] != 'N/S') | (df2['adv_density'] != 'N/A')]
    df3 = df2[["adv_density", "TESTED_DEN", "advised grade", 'material_type']].reset_index(drop=True)
    len_den = len(df2[df2['material_type'] == 'HFO'])
    for l in limits:
        den = df3[(df3['advised grade'] == l) & (df3['TESTED_DEN'].astype(float) <= limits[l]['den']) & (df3['material_type'] == 'HFO')] 
        dc.append(den['TESTED_DEN'].tolist())
    if len(dc) > 0:
        d = len([item for sublist in dc for item in sublist])
        perc_d = (d / len_den) * 100
    df2 = df2[df2['adv_vis'] != 'N/S']
    df2 = df2[df2['advised grade'].str.contains('R') == True]
    df4 = df2[["adv_vis", "V50_Result", "advised grade"]].reset_index(drop=True)
    for l in limits:
        vis = df4[(df4['advised grade'] == l) & (df4['V50_Result'].astype(float) <= limits[l]['vis'])]
        vc.append(vis['V50_Result'].tolist())
    if len(vc) > 0:
        v = len([item for sublist in vc for item in sublist])
        perc_v = (v / len(df4) ) * 100
    else:
        perc_v = 100
    return perc_sul, perc_alsi, perc_tsp, perc_d, perc_v, perc_bdn, perc_red


def clients_summary(cl):
    d = 0
    v = 0
    vc = []
    dc = []
    df2 = df[~((df.id.duplicated(keep=False)) &
               (df.BDN == 'no'))].reset_index(drop=True)    
    df2 = df2[df2.clients == cl]
    perc_red = 100 - (len(df2[df2['overall_lr_outcome'] == 'RED']) / len(df2)) * 100
    df_bdn = df2.groupby('BDN').count().reset_index(drop=False)
    df_bdn = df_bdn[['BDN', 'id']].T
    perc_bdn = (df_bdn.iloc[1, 1] / (df_bdn.iloc[1, 0] + df_bdn.iloc[1, 1])) * 100
    sample_count_hfo = len(df2[df2['material_type'] == 'HFO'])
    sample_count_lsfo = len(df2[df2['sulphur_level'] == 'LOW'])
    sul = len(df2[(df2['sulphur_level'] == 'LOW') &
                  (df2['Sulphur_Result'].astype(float) <= 0.11)])
    perc_sul = (sul / sample_count_lsfo) * 100
    alsi = len(df2[(df2['material_type'] == 'HFO') &
                   (df2['AlSi_Result'].astype(int) <= 40)])

    perc_alsi = (alsi / sample_count_hfo) * 100
    df2['TSP_Result'] = df2['TSP_Result'].fillna(0)
    tsp = len(df2[(df2['material_type'] == 'HFO') &
                  (df2['TSP_Result'].astype(float) <= 0.1)])
    perc_tsp = (tsp / sample_count_hfo) * 100
    limits = {'RMA10': {'vis': 10.44, 'den': 0.9209},
              'RMB30': {'vis': 31.31, 'den': 0.9609},
              'RMD80': {'vis': 83.49, 'den': 0.9759},
              'RME180': {'vis': 187.9, 'den': 0.9919},
              'RMF180': {'vis': 396.6, 'den': 0.9919},
              'RMG380': {'vis': 396.6, 'den': 0.9919},
              'RMG500': {'vis': 521.8, 'den': 0.9919},
              'RMH380': {'vis': 730.6, 'den': 0.9919},
              'RMH500': {'vis': 521.8, 'den': 0.9919},
              'RMH700': {'vis': 730.6, 'den': 0.9919},
              'RMK380': {'vis': 396.6, 'den': 0.1019},
              'RMK500': {'vis': 521.8, 'den': 0.1019},
              'RMK700': {'vis': 730.6, 'den': 0.1019},
              }
    df2 = df2[(df2['adv_density'] != 'N/S') | (df2['adv_density'] != 'N/A')]
    df3 = df2[["adv_density", "TESTED_DEN", "advised grade", 'material_type']].reset_index(drop=True)
    len_den = len(df2[df2['material_type'] == 'HFO'])
    for l in limits:
        den = df3[(df3['advised grade'] == l) & (df3['TESTED_DEN'].astype(float) <= limits[l]['den']) & (df3['material_type'] == 'HFO')] 
        dc.append(den['TESTED_DEN'].tolist())
    if len(dc) > 0:
        d = len([item for sublist in dc for item in sublist])
        perc_d = (d / len_den) * 100
    df2 = df2[df2['adv_vis'] != 'N/S']
    df2 = df2[df2['advised grade'].str.contains('R') == True]
    df4 = df2[["adv_vis", "V50_Result", "advised grade"]].reset_index(drop=True)
    for l in limits:
        vis = df4[(df4['advised grade'] == l) & (df4['V50_Result'].astype(float) <= limits[l]['vis'])]
        vc.append(vis['V50_Result'].tolist())
    if len(vc) > 0:
        v = len([item for sublist in vc for item in sublist])
        perc_v = (v / len(df4) ) * 100
    else:
        perc_v = 100
    return perc_sul, perc_alsi, perc_tsp, perc_d, perc_v, perc_bdn, perc_red


global_stats = clients_global_summary()
client_stats = clients_summary(client)

print(global_stats, '\n', client_stats)

###############################################

df = pd.DataFrame({
    'group': ['Global', client],
    'Not RED reports\n': [global_stats[6], client_stats[6]],
    'Al & Si < 40 mg/kg': [global_stats[1], client_stats[1]],
    'S < 0.11 % m/m': [global_stats[0], client_stats[0]],
    'Within spec density': [global_stats[3], client_stats[3]],
    'Within spec viscosity': [global_stats[4], client_stats[4]],
    'Within spec total sediment': [global_stats[2], client_stats[2]],
    'BDNs with sample': [global_stats[5],	client_stats[5]]})


categories = list(df)[1:]
N = len(categories)

angles = [n / float(N) * 2 * pi for n in range(N)]
angles += angles[:1]
plt.figure(figsize=(10, 10))
ax = plt.subplot(111, polar=True,)

ax.set_theta_offset(pi / 2)
ax.set_theta_direction(-1)

plt.xticks(angles[:-1], categories, color='#414042',
           fontname='DejaVu Sans', size=16, )

ax.set_rlabel_position(0)
plt.yticks([60, 70, 80, 90, 100], ["60", "70", "80", "90", "100"],
           color='#414042', size=16, fontname='DejaVu Sans')
plt.ylim(60, 100)

values = df.loc[0].drop('group').values.flatten().tolist()
values += values[:1]
ax.plot(angles, values, linewidth=1, linestyle='solid', label="Global")
ax.fill(angles, values, '#3B8EDE', alpha=0.1)
ax.yaxis.set_visible(True)
values = df.loc[1].drop('group').values.flatten().tolist()
values += values[:1]
ax.plot(angles, values, linewidth=1, linestyle='solid', label="Client")
ax.fill(angles, values, 'orange', alpha=0.1)
ax.set_frame_on(True)
font = font_manager.FontProperties(family='DejaVu Sans',
                                   weight='normal',
                                   style='normal', size=16)

client_leg_patch = mpatches.Patch(color='#3B8EDE', label='Global')
global_leg_patch = mpatches.Patch(color='orange', label=client)
leg = plt.legend(handles=[client_leg_patch, global_leg_patch],
                 loc='upper left', bbox_to_anchor=(-0.1, 1.05), prop=font)

leg.get_frame().set_linewidth(0)
plt.savefig('plots/ppt_spider.jpg', bbox_inches='tight', transparent=False)
#plt.show()