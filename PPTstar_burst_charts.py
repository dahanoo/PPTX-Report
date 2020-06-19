# -*- coding: utf-8 -*-
"""
Created on Wed Mar 28 11:14:12 2018

@author: TAQDJO
"""

import json
import pandas as pd
import numpy as np
import utils as u
import matplotlib.pyplot as plt
import matplotlib as mpl
import matplotlib.cm as cm
import input as i

mpl.rcParams.update(mpl.rcParamsDefault)
# plt.style.use('ggplot')


def fuel_type(fl, color_):
    """doc"""
    i.shared.update({'fuel': fl})
    criteria = list(i.shared.values())

    df = u.run_sql_query(u.full_path('Ann_report_sql', 'offSpecsPeriodic.sql'), i.shared)

    for col in df.columns:
        if df[col].dtype == 'int64' and col[-1] == 'a':
            df = df.drop(col, axis=1)

    df2 = df.sum()
    df3 = df2[df2 != 0]
    df4 = pd.DataFrame(df3)
    df4 = df4.reset_index()
    df4.columns = ['test', 'count']
    df4['count'] = df4['count'].astype(float)

    def truncy(s):
        """doc"""
        if s is not None:
            return s[:len(s)-9]

    df4.test = df4.test.apply(truncy)
    df4['perc'] = ((df4['count'] / df4['count'].sum()) * 100).round(2)
    df4['labels'] = df4.test.str.cat(df4['perc'].astype(str), sep='\n')
    df4 = df4.sort_values(by='count').reset_index(drop=True)
    df4['counts'] = np.arange(1, max(df4.index)+2)

    plt.figure(figsize=(5, 5))
    ax = plt.axes([0.025, 0.025, 1, 1], polar=True)
    theta = df4.test
    theta = np.linspace(0.0, 2*np.pi, len(df4.test), endpoint=False)
    theta3 = np.linspace(0, np.pi)
    radii = df4['count']
    width = np.pi/(len(df4)/2)
    bars = plt.bar(theta, radii, width=width, bottom=0)
    radii2 = 10 * np.arange(0, len(df4), 1)
    for r, bars in zip(radii2, bars):
        bars.set_facecolor(cm.binary(r / (len(df4)*10.)))
        bars.set_alpha(0.8)

    ax.set_ylim(0, max(df4['count']))
    ax.set_yticklabels([])
    ax.set_xlim(0, len(theta3)+0.262)
    ax.spines['polar'].set_visible(False)
    print(criteria)
    if criteria[4] == 1:
        ax.set_title('Global off specification characteristics\nHFO percentage'
                     , color='#282f65', size=12)
    else:
        ax.set_title('Global off specification characteristics\nMGO percentage'
                     , color='#282f65', size=12)
    t = ax.title
    t.set_position([.5, 1.15])

    ax.set_xticklabels(df4['labels'], color=color_, fontsize=8)
    ax.patch.set_facecolor(color_)
    ax.patch.set_alpha(0.25)
    ax.set_xticks(np.pi/180 * np.linspace(-360, -360/len(df4.index), 
                                          len(df4.index)))
    ax.set_theta_offset(360 + len(df4) / 100)
    ax.yaxis.grid(False)
    plt.savefig('plots/PPTOffSpecPerc{}.png'.format(fl)
                , bbox_inches='tight', dpi=200)
    plt.show()


fuel_type(1, '#70378d')
fuel_type(2, '#00ab91')
