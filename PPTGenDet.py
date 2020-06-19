# -*- coding: utf-8 -*-
"""
Created on Tue Feb 13 14:12:27 2018

@author: TAQDJO
"""

import seaborn as sns
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib as mpl
import utils as u
import input as ii

mpl.rcParams.update(mpl.rcParamsDefault)
sns.set_style("white")
pd.options.mode.chained_assignment = None
pd.set_option("display.max_rows", 999)
pd.set_option("display.max_columns", 20)

# Grab and clean DF for Sample distribution
df = u.run_sql_query(u.full_path('Ann_report_sql', 'Fleet_general_info.sql'),
                     ii.shared)
df['Names'] = ['Total ships registered on FOBAS program: ',
                  'Total Samples\nSubmitted: ',
                  'Bunker Drip\nSamples: ', 
                  'Fuel Audit\nProgramme: ',
                  '\nOthers: ', 
                  'Sample Bottle Kits Ordered: ',
                  'Average analysis turnaround time (lab): ',
                  'Investigations: ']
df = df.fillna(0)
df['count'] = df['count'].astype(int)
df = df.dropna()

df_plot = df.iloc[1:5]
df_plot = df_plot.sort_values(by='count', ascending=False)
new_labels = df_plot['Names'].tolist()
new_counts = df_plot['count'].tolist()

# Grab DF for Sample status count
df_gar = u.run_sql_query(u.full_path('Ann_report_sql','gar_count_client.sql'), ii.shared)
if len(df_gar) < 3:
    df_gar.loc[len(df_gar)] = ['RED', 0]
df_gar.loc[2, 'OUTCOME'] = 0
df_gar = df_gar.sort_values("OUTCOME").drop('OUTCOME', axis=1)
df_gar = df_gar.reset_index(drop=True)
df_gar = df_gar.iloc[::-1]
new_labels2 = ['GREEN', 'AMBER', 'RED']

new_counts2 = df_gar['count'].tolist()

# DF count status by ship
df_ship_status = u.run_sql_query(u.full_path('Ann_report_sql','gar_count_ship.sql'), ii.shared)


def lower(l):
    return l.title()


df_ship_status['ship'] = df_ship_status['ship'].apply(lower)
df_ship_status['outcome'] = pd.Categorical(df_ship_status['outcome'], ["GREEN", "AMBER", "RED"])
df_ship_status = df_ship_status.sort_values(by=['ship', 'outcome'])
if len(df_ship_status) > 0:
    df_ship_status_piv = pd.pivot_table(df_ship_status, index=["ship"], columns=["outcome"])
    df_ship_status_piv = df_ship_status_piv.fillna(0)
    ax1 = df_ship_status_piv.plot(kind='bar', figsize=(11, 4), color=['#71d54c', '#f6b436', '#ff5050'])
    sns.despine()
    [i.set_linewidth(0.1) for i in ax1.spines.values()]
    ttl = ax1.title
    ttl.set_position([.5, 1.1])
    ax1.legend_.remove()
    ax1.set_ylabel('Samples tested', fontsize=11, labelpad=10, color='#414042')
    plt.savefig('plots/plot status by ship.png', bbox_inches='tight')
else:
    pass

# Grab DF for amber red reasons

df_reasons = u.run_sql_query(u.full_path('Ann_report_sql','offSpecs2.sql'), ii.shared)
df_reason_sum = df_reasons.sum()
df_reason_sum = df_reason_sum[df_reason_sum > 0]
reason_sum = df_reason_sum.reset_index().values.tolist()
lst_red = []
lst_amber = []
for i, j in enumerate(reason_sum):
    if '_r' in reason_sum[i][0]:
        lst_red.append(j)
    else:
        lst_amber.append(j)
list_red = sorted(lst_red)
list_amber = sorted(lst_amber)
red_reasons_c = [item[-1] for item in list_red]
red_reasons_l = [item[0] for item in list_red]
amber_reasons_c = [item[-1] for item in list_amber]
amber_reasons_l = [item[0] for item in list_amber]

df_supplier_reasons = u.run_sql_query(u.full_path('Ann_report_sql','offSpecsPS.sql'), ii.shared)
df_supplier_reason = pd.melt(df_supplier_reasons, id_vars=["port_name", "supplier_name"],
                             var_name="Char", value_name="Value")
df_supplier_reason = df_supplier_reason[df_supplier_reason.Value > 0]
df_supplier_reason_a = df_supplier_reason[df_supplier_reason.Char.str.contains('_a')]
df_supplier_reason_a = df_supplier_reason_a.sort_values(by=['port_name', 'supplier_name'])
df_supplier_reason_r = df_supplier_reason[df_supplier_reason.Char.str.contains('_r')]
df_supplier_reason_r = df_supplier_reason_r.sort_values(by=['port_name', 'supplier_name'])


def plotIt(a, fileName, tick_label_dist, df, tick_labels, ylimvar=20, Vtopcolno=5, Htopcolno=-0.02, x_text_pos=0.05):
    """a is colour cycle
       tick_label_dist is distance of x ticklabels from plot
    """

    def trim_tics(t):
        ticks = []
        for t in tick_labels:
                if t.endswith('_r') or t.endswith('_a'):
                    ticks.append(t[:-2])
                else:
                    ticks.append(t)
        return ticks
    tics = trim_tics(tick_labels)
    fig, ax = plt.subplots(figsize=(8, 4))
    color_cycle = a
    ax.bar(list(range(len(df))), tick_label_dist, color=color_cycle, width=0.3)
    sns.despine()
    [i.set_linewidth(0.1) for i in ax.spines.values()]
    ax.set_ylim(0, max(tick_label_dist) + ylimvar)
    ax.set_ylabel('Samples tested', fontsize=11, labelpad=10, color='#414042')
    ax.tick_params(axis='y', labelsize=10, color='#414042')
    yaxis_dist = len([tick for tick in ax.yaxis.get_major_ticks()])
    for i, j in enumerate(tick_label_dist):
        ax.text(i + x_text_pos, j + Vtopcolno/yaxis_dist, str(j))
        ax.text(i + x_text_pos, (-max(tick_label_dist) / yaxis_dist), tics[i], rotation=90, fontsize=10,
                color='#414042')
    # ax.set_xticklabels(new_labels,rotation=90)
    ya = ax.get_yaxis()
    ya.set_major_locator(mpl.ticker.MaxNLocator(integer=True))
    ax.set_xticks([])
    fig.savefig("plots/"+fileName, bbox_inches='tight', transparent=True, dpi=200)

try:
    plotIt(['#d8c826', '#b588b9', '#6cdbd6', '#f6b436'], 'sample_distribution.png', new_counts, df_plot, new_labels, 50,
           max(new_counts), 0.05, -0.05)
except ValueError:
    pass
try:
    plotIt(['#71d54c', '#f6b436', '#ff5050'], 'sample_statuses.png', new_counts2, df_gar, new_labels2, 20,
           max(new_counts2), 0.05, 0)
except ValueError:
    pass
try:
    plotIt(['#f6b436'], 'sample_status_reason_a.png', amber_reasons_c, amber_reasons_c, amber_reasons_l, 5,
       max(amber_reasons_c), -1, -len(amber_reasons_l)/100)
except ValueError:
    pass

try:
    plotIt(['#ff5050'], 'sample_status_reason_r.png', red_reasons_c, red_reasons_c, red_reasons_l, 1,
           max(red_reasons_c), 0, -0.015)
except ValueError:
    pass

