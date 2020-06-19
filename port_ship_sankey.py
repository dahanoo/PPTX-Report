# -*- coding: utf-8 -*-

"""
Created on Mon Jun  4 16:23:09 2018

@author: dahan
"""

import matplotlib.pyplot as plt
import matplotlib as mpl
import numpy as np
import utils as u
import seaborn as sns
import sankey
import input as i

mpl.rcParams.update(mpl.rcParamsDefault)
sns.despine(left=True, bottom=True)
sns.set_style("dark")
df = u.run_sql_query(u.full_path('Ann_report_sql', 'port_suppliers_ frequented.sql'), i.shared)

def title(tr):
    return tr.title()


df['ship'] = df['ship'].apply(title)
df['supplier'] = df['supplier'].apply(title)
df = df.sort_values('ship')
port_unique = df.port.unique().tolist()
port_count = df.port.nunique()
supplier_unique = df.supplier.unique().tolist()
supplier_count = df.supplier.nunique()
ship_unique = df.ship.unique().tolist()
ship_count = df.ship.nunique()

uniques = ship_unique + supplier_unique

x = np.linspace(50, 256, num=ship_count) 
y = np.linspace(50, 256, num=supplier_count)
try:
    sankey.sankey(df['ship'], df['supplier'], aspect=10, fontsize=8, figure_name="Sankey_Ship_Supplier")
    plt.savefig('plots/Sankey_Ship_Supp.png', bbox_inches='tight', transparent=True)
except UnboundLocalError:
    pass

try:
    from PIL import Image
    colorImage = Image.open(u.full_path("plots", "Sankey_Ship_Supp.png"))
    # Rotate it by 90 degrees
    transposed = colorImage.transpose(Image.ROTATE_90)
    transposed.save(u.full_path('plots', 'Sankey_Ship_Supplier.png'))
except FileNotFoundError:
    pass

