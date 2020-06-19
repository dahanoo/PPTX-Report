import utils as u
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.font_manager as font_manager
import input as i

shared = i.shared

df = u.run_sql_query(u.full_path("Ann_report_sql", "KPI.sql"), shared)

df = df.dropna()
def ttl(a):
    return a.title()

df.port = df.port.apply(ttl)
df.client = df.client.apply(ttl)
df.collected_sampled = df.collected_sampled.astype('int')
df.received_collected = df.received_collected.astype('int')
df["sampled_to_lab"] = df.collected_sampled + df.received_collected
df_cl_filt = df[df.client.str.contains(shared['cl'], case=False)]
cl_name = df_cl_filt.client.unique()
df_cl = df_cl_filt.groupby('port')['collected_sampled', 'received_collected'].mean().astype('int')
ax = df_cl.plot.bar(figsize=(20, 7), color=['#00AB91', '#3B8EDE'],
                    edgecolor='white', lw=2, width=0.8)
ax.set_ylabel("Days", color='#284d97', fontname='Source Sans Pro')
ax.set_xlabel("Port", color='#284d97', labelpad=10, fontname='Source Sans Pro')
font = font_manager.FontProperties(family='Source Sans Pro', size=12)
leg = ax.legend(prop=font)
leg.get_texts()[0].set_text('Average time from sampling to collection')
leg.get_texts()[1].set_text('Average time from collection to receipt at lab')
leg.get_frame().set_linewidth(0)
plt.setp(leg.get_texts(), color='#284d97')
ax.tick_params(axis='both', colors='#284d97')
ax.spines['right'].set_visible(False)
ax.spines['top'].set_visible(False)
ax.spines['left'].set_visible(False)
ax.spines['bottom'].set_visible(False)
plt.savefig('plots/Client_times.png',
        transparent=True,
        bbox_inches='tight')
plt.show()

gl_ports_lst = df.port.unique().tolist()
df_gl_comp = df[df['port'].isin(gl_ports_lst)]
df_cl_comp = df_cl_filt.groupby('port')["sampled_to_lab"].mean().astype('int').reset_index(drop=False)
df_gl_comp = df_gl_comp.groupby('port')["sampled_to_lab"].mean().astype('int').reset_index(drop=False)
merge_cl_gl = df_cl_comp.merge(df_gl_comp, on='port', how='left')
merge_cl_gl = merge_cl_gl.set_index('port', drop=True)
ax = merge_cl_gl.plot.bar(figsize=(20, 7), color=['#00AB91', '#3B8EDE'], edgecolor='white', lw=2, width=0.8)
ax.set_ylabel("Days", color='#284d97', fontname='Source Sans Pro')
ax.set_xlabel("Port", color='#284d97', labelpad=10, fontname='Source Sans Pro')
font = font_manager.FontProperties(family='Source Sans Pro', size=12)
leg = ax.legend(prop=font)
leg.get_texts()[0].set_text(cl_name[0])
leg.get_texts()[1].set_text('Global')
leg.get_frame().set_linewidth(0)
plt.setp(leg.get_texts(), color='#284d97')
ax.tick_params(axis='both', colors='#284d97')
ax.spines['right'].set_visible(False)
ax.spines['top'].set_visible(False)
ax.spines['left'].set_visible(False)
ax.spines['bottom'].set_visible(False)
plt.savefig('plots/Global_client_times.png',
        transparent=True,
        bbox_inches='tight')
plt.show()