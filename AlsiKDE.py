from matplotlib import pyplot as plt
import utils as u
import seaborn as sns
import input as i

sns.set_style("white")
df = u.run_sql_query('Ann_report_sql/Client_AlSi.sql', i.shared)
df = df.dropna()
fig, ax = plt.subplots(figsize=(7, 7))
sns.distplot(df['Al&Si (mg/kg)'].astype(int), color='#d4c3dc', rug=True)

sns.distplot(df['Al&Si (mg/kg)'].astype(int), rug=True,
             kde_kws={"color": "#284d97", "lw": 1},
             hist_kws={"histtype": "step", "linewidth": 1,
                       "alpha": 1, "color": "#70378d"})
sns.despine(left=True)
ax.set_yticks([])
ax.tick_params(axis='x', colors='#70378d')
ax.set_xlabel('Al&Si (mg/kg)', color='#284d97')
ax.spines['bottom'].set_color('#70378d')
# ax.set_xlim(0, 100)
plt.savefig("plots/dist_plot.jpg", bbox_inches='tight', transparent=True, dpi=200)
plt.show()


