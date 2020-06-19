
import pandas as pd
import matplotlib.pyplot as plt
import utils as u
import input as i

df = u.run_sql_query('Ann_report_sql/AlSiGT40Table.sql', i.shared)
df = df.dropna()
df['Al&Si (mg/kg)'] = df['Al&Si (mg/kg)'].astype(int)
df = df[df['Al&Si (mg/kg)'] > 40]
df['Al&Si (mg/kg)'] = df['Al&Si (mg/kg)'].astype(str)
df = df.reset_index(drop=True)


def low(l):
    return l.title()


df['Ship'] = df['Ship'].apply(low)
df['Supplier'] = df['Supplier'].apply(low)

columns = ["Port", "PCounts", "Supplier", "SCounts"]

ports = df['Port'].value_counts()
ports = ports.reset_index(drop=False)

suppliers = df['Supplier'].value_counts()
suppliers = suppliers.reset_index(drop=False)

combined = pd.merge(ports, suppliers, left_index=True, right_index=True)

df2 = df.groupby(['Port', 'Supplier'])['Ship'].count().reset_index()

df4 = df.groupby(['Port'])['Ship'].count().reset_index()
df4['PercS'] = (df4.Ship / df4.Ship.sum()) * 100.
df4['PercS'] = df4['PercS'].round(0)
df4['labels'] = df4.Port.str.cat(df4['PercS'].astype(str), sep=' ')
df3 = df2
df3 = df3.rename(columns={0: 'Port', 1: 'Supplier', 2: 'Counts'})
df3['PercS'] = (df3['Ship'] / df3['Ship'].sum()) * 100.
df3['PercS'] = df3['PercS'].round(2)
df3['labels'] = df3['Supplier'].str.cat(df3['PercS'].astype(str), sep=' ')
df_group_ship = df3.groupby('Port').count()
df_group_port = df3.groupby('Port')['Ship'].sum().reset_index(drop=False)
############################

fig, ax = plt.subplots(figsize=(14, 9))


def layered(param, x, y, cat, col, alpha, sample_count_port):
    """x=count, y=y_axis, col=colour"""
    xticks = []
    xticks2 = []
    pos = 0
    y_ax = y
    x_pos = x
    current_tick = []

    for i, (p, c) in enumerate(zip(x_pos, cat)):
        if param == 1:
            plt.bar(pos + 0.5, y_ax, width=1, lw=4, edgecolor='#d9d9d9',
                    color=col, alpha=alpha)
            current_tick = (pos + p / 2.)
            pos = pos + 1
            xticks2.append(current_tick)
        else:
            plt.bar(pos + (p/2), y_ax, width=p, lw=4, edgecolor='#d9d9d9',
                    color=col, alpha=alpha)
            current_tick = (pos + p / 2.)
            pos = pos + p
            xticks.append(current_tick + 0.1)
    ax.axhline(-1, xmin=0, xmax=1, c="#FFFFFF", linewidth=4, zorder=10)
    ax.axhline(1, xmin=0, xmax=1, c="#FFFFFF", linewidth=4, zorder=10)
    ax.set_yticks([])
    ax.set_xticks([])
    ax.set_xlim(-1, sum(x) + 1)
    ax.tick_params(top="off", left="off", bottom='off')
    ax.spines['right'].set_visible(False)
    ax.spines['top'].set_visible(False)
    ax.spines['left'].set_visible(False)
    ax.spines['bottom'].set_visible(False)
    pos_sup = 0

    for a, b in zip(df3.Ship, df3.Supplier):
        plt.text((pos_sup + 0.5) - 0.1, 0.03, str(b) + " : " + str(a),
                 color='white',
                 fontsize=12, rotation=90,
                 va='bottom')
        pos_sup = pos_sup + 1
    pos_sup = 0

    for a, b, c, in zip(df_group_ship.Ship, df4.Port, sample_count_port):
        plt.text(pos_sup + (a/2) - 0.1, -0.97, str(b) + " : " + str(c),
                 color='white', fontsize=12, rotation=90, va='bottom')
        pos_sup = pos_sup + a

    pos_port = 0
    for a in df_group_ship.Ship:
        ax.axvline(pos_port + a, ymin=0.05, ymax=0.95, c="#00B398",
                   linewidth=4, alpha=0.3, zorder=5)
        pos_port = pos_port + a
    ax.axvline(0, ymin=0.04, ymax=0.96, c="#FFFFFF", linewidth=4,
               zorder=10)
    ax.axvline(len(df3), ymin=0.04, ymax=0.96, c="#FFFFFF", linewidth=4,
               zorder=10)
import matplotlib.patches as mpatches

port_col = mpatches.Patch(color='#00B398', label='Ports')
supp_col = mpatches.Patch(color='#51545b', label='Suppliers')                          
plt.legend(handles=[port_col, supp_col], bbox_to_anchor=(0.96, 0.94), frameon=False)

layered(1, range(len(df3)), 1, df3.Supplier, '#51545b', 0.7, df_group_port.Ship)
layered(2, df_group_ship.Ship, -1, df4.Port, '#00B398', 1, df_group_port.Ship)

plt.savefig("plots/PPTPortSupplier.png", bbox_inches='tight',
            transparent=True, dpi=200)
plt.show()
