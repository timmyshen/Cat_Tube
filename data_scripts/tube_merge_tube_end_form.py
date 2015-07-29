
# coding: utf-8

# In[ ]:

get_ipython().magic(u'pylab inline')
import pandas as pd


# In[ ]:

tube = pd.read_csv('../competition_data/tube.csv')
tube_end_form = pd.read_csv('../competition_data/tube_end_form.csv')


# In[ ]:

# print tube.head()


# In[ ]:

# tube_end_form.head()


# In[ ]:

tube_end_form = tube_end_form.append({'end_form_id' : 'NONE', 'forming' : 'No'} , ignore_index=True)


# In[ ]:

tube_end_form_a = tube_end_form.copy()
tube_end_form_a.columns = ['ef_id_a', 'forming_a']
tube_end_form_x = tube_end_form.copy()
tube_end_form_x.columns = ['ef_id_x', 'forming_x']


# In[ ]:

tube_merge_end_form = pd.merge(tube, tube_end_form_a, how='left', left_on='end_a', right_on='ef_id_a')
tube_merge_end_form = pd.merge(tube_merge_end_form, tube_end_form_x, how='left', left_on='end_x', right_on='ef_id_x')
tube_merge_end_form.drop(['ef_id_a', 'ef_id_x'], axis=1, inplace=True)
# tube_merge_end_form.tail(10)


# In[ ]:

tube_merge_end_form.to_csv('tube_merge_end_form.csv', index=False)

