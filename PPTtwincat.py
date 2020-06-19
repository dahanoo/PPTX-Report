import matplotlib.pyplot as plt
import matplotlib as mpl
from itertools import groupby
import pandas as pd
import utils as u
import input as i

mpl.rcParams.update(mpl.rcParamsDefault)
pd.options.mode.chained_assignment = None
criteria = i.shared.values()

df_supplier_reasons = u.run_sql_query(u.full_path('Ann_report_sql',
                                                  'offSpecsPS.sql'), i.shared)
df_supplier_reasons = df_supplier_reasons.drop('port_name', axis=1)
df_supplier_reason = pd.melt(df_supplier_reasons, id_vars=["supplier_name"],
                             var_name="test_name", value_name="t_value")
df_supplier_reason['t_value'] = df_supplier_reason['t_value'].astype(int)
df_supplier_reason = df_supplier_reason[df_supplier_reason.t_value > 0]
df_supplier_reason_a = df_supplier_reason[df_supplier_reason.test_name.str.contains('_a')]
df_supplier_reason_a = df_supplier_reason_a.sort_values(by=['supplier_name'])
df_supplier_reason_r = df_supplier_reason[df_supplier_reason.test_name.str.contains('_r')]
df_supplier_reason_r = df_supplier_reason_r.sort_values(by=['supplier_name'])


def plot_status(status, col, trm, name):
    df = status
    df['test_name'] = df['test_name'].str.replace('_a', '')
    df.t_value = df.t_value.astype(int)

    def titles(ttls):
        return ttls.title()

    df['supplier_name'] = df['supplier_name'].apply(titles)
#    test = df.test_name.unique().tolist()
#    supplier = df.supplier_name.unique().tolist()
#    max_width = df.test_name.value_counts().max()
#    max_str_len = df.supplier_name.map(len).max()
#    sup_name = ' '
    df_plot = status.groupby(['supplier_name', 'test_name', ])['t_value'].sum()
    df_plot = df_plot.reset_index(drop=False)
    df_plot.t_value = df_plot.t_value.astype(int)

    def titles(ttls):
        return ttls.title()

    df_plot['supplier_name'] = df_plot['supplier_name'].apply(titles)
#    test = df_plot.test_name.unique().tolist()
#    supplier = df_plot.supplier_name.unique().tolist()
#    max_width = df_plot.test_name.value_counts().max()
#    max_str_len = df_plot.supplier_name.map(len).max()
#    sup_name = ' '
    df2 = pd.pivot_table(df_plot, index=['test_name', 'supplier_name'],
                         values=['t_value'])

    def add_line(ax, xpos, ypos):
        line = plt.Line2D([xpos, xpos], [ypos + .1, ypos],
                          transform=ax.transAxes, color='#569ad4', lw=0.5)
        line.set_clip_on(False)
        ax.add_line(line)

    def add_line2(ax, xpos, ypos):
        line = plt.Line2D([xpos, xpos], [ypos + -2, ypos], dashes=(10, 10),
                          transform=ax.transAxes, color='#569ad4', lw=0.5, )
        line.set_clip_on(False)
        ax.add_line(line)

    def label_len(my_index, level):
        labels = my_index.get_level_values(level)
        return [(k, sum(1 for i in g)) for k, g in groupby(labels)]

    def label_group_bar_table(ax, df):
        ypos = -.1
        scale = 1. / df2.index.size
        level = 1
        pos = 0
        for label, rpos in label_len(df.index, level):
            lxpos = (pos + .5 * rpos) * scale
            ax.text(lxpos, ypos, label, ha='center', transform=ax.transAxes,
                    rotation=90,
                    color='#569ad4',
                    fontsize=8)
            add_line(ax, pos * scale, ypos)
            pos += rpos
        add_line(ax, pos * scale, ypos)
        ypos -= .1

    def label_group_bar_table2(ax, df):
        ypos = 0
        scale = 1. / df2.index.size
        level = 0
        pos = 0
        for label, rpos in label_len(df.index, level):
            lxpos = (pos + .5 * rpos) * scale
            ax.text(lxpos, ypos - 1.1, label, ha='center',
                    transform=ax.transAxes, rotation=90,
                    color='#95979a', fontweight='bold', fontsize=10)
            if pos * scale > 0:
                add_line2(ax, pos * scale, ypos + 1, )
            pos += rpos
        ypos = 1

    ax = df2.plot(kind='bar', stacked=False, figsize=(11, 2.5), color=col)
    ax.set_xticklabels('')

    ax.set_xlabel('')
    ax.set_facecolor('#569ad4')
    ax.patch.set_alpha(0.25)
    ax.legend_.remove()
    label_group_bar_table(ax, df2)
    label_group_bar_table2(ax, df2)
    ax.spines['bottom'].set_color('#569ad4')
    ax.spines['left'].set_color('#95979a')
    ax.spines['top'].set_color('#ffffff')
    ax.spines['right'].set_color('#ffffff')
    ax.tick_params(axis='y', colors='#569ad4')
    plt.savefig(f"plots/{name}.png", bbox_inches='tight',
                transparent=True, dpi=200)
    plt.show()


try:
    plot_status(df_supplier_reason_a, '#ffcd02', '_a', 'Client_Supplier_amber')
except TypeError:
    pass

try:
    plot_status(df_supplier_reason_r, 'r', '_r', 'Client_Supplier_red')
except TypeError:
    pass
