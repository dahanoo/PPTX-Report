# -*- coding: utf-8 -*-
"""
Created on Mon Apr 09 16:17:06 2018

@author: TAQDJO
"""

from matplotlib import pyplot as plt
import matplotlib.patches as patches
import utils as u
import seaborn as sns
import input as i
sns.set_style("dark")
df = u.run_sql_query('Ann_report_sql/AlSiGT40Table.sql', i.shared)
df = df.dropna()
df['Al&Si (mg/kg)'] = df['Al&Si (mg/kg)'].astype(int)
try:
    percentGT40 = ((len(df[df['Al&Si (mg/kg)'] > 40]) / float(len(df))) * 100) * 2
    percentGT30 = ((len(df[df['Al&Si (mg/kg)'] > 30]) / float(len(df))) * 100) * 2
    percentGT15 = ((len(df[df['Al&Si (mg/kg)'] > 15]) / float(len(df))) * 100) * 2
    fig = plt.figure(figsize=(9, 6))
    fig.patch.set_facecolor('#95979a')
    fig.patch.set_alpha(0.3)
    ax = fig.add_subplot(111, aspect='equal')


    def alsiDist(perc, no):
        plt.style.use('ggplot')
        ax.add_patch(
            patches.Rectangle((0, 0),  # (x,y)
                              100, 100, color='#32bba7', zorder=1))
        ax.add_patch(
            patches.Rectangle((0, 0),  # (x,y)
                              percentGT30, percentGT30, color='#66ccbd', zorder=1))
        ax.add_patch(
            patches.Rectangle((0, 0),  # (x,y)
                              perc, perc, color='#b2e5de', zorder=1))
        ax.plot((0, perc), (perc, perc), 'k-', color='#ffffff', zorder=4)
        ax.plot((perc, perc), (perc, 0), 'k-', color='#ffffff', zorder=4)
        if perc == percentGT40:
            ax.text(-40, perc / 2, "AlSi > {} : {}%".format(no, format(perc / 2., '.2f')), color='#00ab91', ha='left')
        elif perc == percentGT30:
            ax.text(-40, (perc + percentGT40) / 2, "AlSi > {} : {}%".format(no, format(perc / 2., '.2f')),
                    color='#00ab91', ha='left')
        elif perc == percentGT15:
            ax.text(-40, (percentGT40 + percentGT15) / 2, "AlSi > {} : {}%".format(no, format(perc / 2., '.2f')),
                    color='#00ab91', ha='left')
    alsiDist(percentGT15, 15)
    alsiDist(percentGT30, 30, )
    alsiDist(percentGT40, 40, )

    ax.set_xlim(0, 100)
    ax.set_ylim(0, 100)
    ax.set_ylabel('')
    ax.set_xlabel('')
    ax.set_xticks([])
    ax.set_yticks([])
    ax.spines['right'].set_visible(False)
    ax.spines['top'].set_visible(False)
    ax.spines['left'].set_visible(False)
    ax.spines['bottom'].set_visible(False)
    # ax.set_title('\nAl + Si Content distribution', color='#282f65', size=18)
    t = ax.title
    t.set_position([.5, 1.1])
    fig.savefig('plots/AlsiDistPPT.png', bbox_inches='tight', transparent=True, dpi=200)
    fig.show()
except Exception:
    pass













