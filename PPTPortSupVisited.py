# -*- coding: utf-8 -*-

"""
Created on Thu Nov 16 11:37:07 2017

@author: TAQDJO
"""
import json
import pandas as pd
import seaborn as sns
import utils as u
import matplotlib.pyplot as plt
import matplotlib as mpl
import input as i

mpl.rcParams.update(mpl.rcParamsDefault)
sns.despine(left=True, bottom=True)
sns.set_style("dark")
df_Ps = u.run_sql_query(u.full_path('Ann_report_sql','port_suppliers_ frequented.sql'), i.shared)


def PortSupPlot(fld, clr, ttl):
    """builodw charts
    fld = field
    clr = colour
    ttl = title
    """
    UpCase = fld.title()
    df = u.run_sql_query(u.full_path('Ann_report_sql', '{} frequented.sql'.format(fld)), i.shared)

    def title(tr):
        return tr.title()
    df[fld] = df[fld].apply(title)
    df['combined'] = pd.concat([df['{} with count GT 10'.format(fld)].dropna(), 
    df['{} with count LT 10'.format(fld)].dropna()]).reindex_like(df)
    df = df.sort_values(['combined'], ascending=1)
    df = df.drop(['{} with count GT 10'.format(fld), '{} with count LT 10'.format(fld)], axis=1)
    df = df.sort_values(by='combined', ascending=False)
    df = df.set_index(fld, drop=True)
    fig, ax = plt.subplots(figsize=(10, 3))
    df[:20].plot(kind='bar', color=clr, ax=ax, legend=False, alpha=0.75)
    ax.spines['bottom'].set_color(clr)
    ax.spines['left'].set_color(clr)
    ax.spines['top'].set_color('#ffffff')
    ax.spines['right'].set_color('#ffffff')
    ax.spines['left'].set_lw(0.5)
    ax.spines['bottom'].set_lw(0.5)
    ax.tick_params(axis='y', colors='#282f65', labelsize=10)
    ax.tick_params(axis='x', colors='#282f65', labelsize=10)
    ax.set_ylabel(ttl, color='#282f65')
    ax.set_xlabel('')
    plt.savefig('plots/{} Visited.png'.format(UpCase), bbox_inches='tight', transparent=True)
    #plt.show()

try:
    PortSupPlot('port', '#00ab91', 'No of Visits')
except TypeError:
    pass

try:
    PortSupPlot('supplier', '#70378d', 'No of Bunkerings')
except TypeError:
    pass
