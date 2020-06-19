# -*- coding: utf-8 -*-
"""
Created on Tue Apr 03 12:54:37 2018

@author: TAQDJO
"""

import json
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib as mpl
import seaborn as sns
import utils as u
import input as i

mpl.rcParams.update(mpl.rcParamsDefault)
pd.options.mode.chained_assignment = None
pd.set_option("display.max_rows", 999)
pd.set_option("display.max_columns", 20)

# get input for queries

criteria = list(i.shared.values())

df = u.run_sql_query(u.full_path('Ann_report_sql', 'loaded_quan_diff.sql'),
                     i.shared)
df2 = df[['ship', 'adv_density', 'TESTED_DEN',
          'bunker_quantity', 'material_type']]
df2 = df2.dropna()
df2['adv_density'] = pd.to_numeric(df2['adv_density'], errors='coerce')
df2['TESTED_DEN'] = pd.to_numeric(df2['TESTED_DEN'], errors='coerce')
df2['bunker_quantity'] = pd.to_numeric(df2['bunker_quantity'], errors='coerce')
df2['quan_diff'] = (df2['TESTED_DEN'] - df2['adv_density']) \
 * df2['bunker_quantity']
df3 = df2[['ship', 'bunker_quantity', 'quan_diff', 'material_type']]
df3['sample'] = 1

# Tidy up supplier text)


def lower_ship(lowers):
    lowers = lowers.title()
    return lowers


df3['ship'] = df3['ship'].apply(lower_ship)

# Create new DF for charting
load = df3.groupby(['ship', 'material_type'], as_index=False).sum()

load['pos'] = load['quan_diff'] >= 0


def fuel_type(d, f):
    loaded = d[d['material_type'] == f]

    loaded = loaded.sort_values(['ship'])
    loaded = loaded.reset_index(drop=True)
    max_val = loaded['bunker_quantity'].max()

    # Plot it
    quan = loaded.sort_values(['ship', 'material_type'], ascending=False)
    sns.set_style('dark', {'axes.linewidth': 0.5, 'axes.edgecolor': '#e50c7c'})
    fig, ax = plt.subplots(figsize=(10, 4))
    ax.bar(range(len(quan)), quan['bunker_quantity'], label='quantity ordered',
           color='#569ad4', alpha=0.75)
    plt.xticks(range(len(quan)), quan['ship'], color='#414042', rotation=90,
               fontname='Source Sans Pro')
    ax2 = ax.twinx()
    ax2.bar(range(len(quan)), quan['quan_diff'], color=quan['pos'].map(
        {True: '#5faf30', False: '#ef7c71'}), alpha=0.5)

    ax.set_xlabel('')
    sns.despine(right=False)
    ax.yaxis.set_ticks_position('left')
    ax2.yaxis.set_ticks_position('right')

    def dp2(decimal):
        decimal = round(float(decimal), 2)
        return decimal
    quan.quan_diff = quan.quan_diff.apply(dp2)

    for a, b in zip(list(range(0, len(quan), 1)), quan.quan_diff):
        plt.text(
            a - 0.22,
            5,
            str(b),
            color='#414042',
            fontsize=9,
            rotation=90,
            va='bottom')
    for a, b in zip(list(range(0, len(quan), 1)), quan.bunker_quantity):
        plt.text(a - 0.23, -80, str(int(b)), color='#e50c7c',
                 fontsize=9, rotation=90, va='bottom')
    for a, b, c in zip(list(range(0, len(quan), 1)),
                       quan['sample'], quan['ship']):
        plt.text(a - 0.25, -95, str(b), color='#d8c826', fontsize=9)
    ship_unique = quan['ship'].unique()
    for a, b in zip(list(range(1, (len(quan.ship)) + 2)), ship_unique):
        plt.text(a - 1.25, -110, str(b), color='#282f65',
                 fontsize=9, rotation=90)
    ax.set_ylabel('Quantity ordered (MT)', color='#569ad4')
    ax2.set_ylabel('Est quan diff (MT)', color='#282f65')
    ax2.set_ylim(-100, 100)
    ax.set_ylim(0, max_val + max_val)
    ax.set_xlim(-1, len(quan))
    ax.tick_params(axis='y', colors='#569ad4')
    plt.xticks([])

    ytick_col = ax2.get_yticks()
    colour_lst = []
    for j in ytick_col:
        k = int(j)
        if k >= 0:
            colour_lst.append('#5faf30')
        else:
            colour_lst.append('#ef7c71')


try:
    fuel_type(load, "HFO")
    plt.savefig(
        'plots/AnalysisQuantityFO.png',
        transparent=True,
        bbox_inches='tight', dpi=200)
except ValueError:
    pass

try:
    fuel_type(load, "MGO")
    plt.savefig(
        'plots/AnalysisQuantityGO.png',
        transparent=True,
        bbox_inches='tight', dpi=200)
except ValueError:
    pass
