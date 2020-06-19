import matplotlib.pyplot as plt
import pandas as pd
import utils as u
import seaborn as sns
import input as i

df_global_status = u.run_sql_query(u.full_path('Ann_report_sql', 'gar_count_global.sql'), i.shared)
df_client_status = u.run_sql_query(u.full_path('Ann_report_sql', 'gar_count_client.sql'), i.shared)
print(df_global_status)
print(df_client_status)


def title(a_):
    return a_.title()


df_global_status.outcome = df_global_status.outcome.apply(title)
df_client_status.outcome = df_client_status.outcome.apply(title)
df_global_status['outcome'] = pd.Categorical(df_global_status['outcome'], ["Green", "Amber", "Red"])
df_global_status = df_global_status.sort_values(by=['outcome'])
df_client_status['outcome'] = pd.Categorical(df_client_status['outcome'], ["Green", "Amber", "Red"])
df_client_status = df_client_status.sort_values(by=['outcome'])
if len(df_client_status) < 3:
    df_client_status.loc[len(df_client_status)] = ['Red', 0]
try:
    df_global_status['Global'] = (df_global_status['count'] / df_global_status['count'].sum()) * 100
    df_client_status[i.shared['cl'].title()] = (df_client_status['count'] / df_client_status['count'].sum()) * 100
except ZeroDivisionError:
    pass
global_s = df_global_status
combined_s = df_client_status.merge(global_s, on='outcome', how='left')
final = combined_s[['outcome', i.shared['cl'].title(), 'Global']]
final = final.set_index('outcome')
fig = plt.figure(figsize=(10, 5))
ax = final.plot.bar(color=['#00AB91', '#3B8EDE', '#00AB91', '#3B8EDE', '#00AB91', '#3B8EDE'], figsize=(10, 5),
                    edgecolor='white', lw=5, width=0.8)

labels = [i for i in ax.get_yticks()]
ax.set_xlabel('')
ax.set_xticklabels(labels=final.index, size=16)
ax.get_xticklabels()[0].set_color("#5faf30")
ax.get_xticklabels()[1].set_color("#ffcd02")
ax.get_xticklabels()[2].set_color("#e84133")
for a, b in zip(list(range(0, len(final[i.shared['cl'].title()]), 1)), final[i.shared['cl'].title()]):
    plt.text(a-0.3, b+1, str(float(b))[:5]+'%', color='#00AB91', fontsize=12)

for a, b in zip(list(range(0, len(final[i.shared['cl'].title()]), 1)), final['Global']):
    plt.text(a+0.1, b+1, str(float(b))[:5]+'%', color='#3B8EDE', fontsize=12)
ax.set_yticks([])
leg = plt.legend()
leg.get_frame().set_linewidth(0)
sns.despine(left=True, bottom=True)
plt.bbox_inches = 'tight'
plt.savefig('plots/gbl_clt_statuses.jpeg', bbox_inches='tight', dpi=200)
plt.show()
