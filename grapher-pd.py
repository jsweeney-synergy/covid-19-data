#!/usr/bin/env python3

import os
import pandas as pd
import plotly.graph_objects as go
from plotly.subplots import make_subplots

import re
import sys

global Args

class nyt_covid_graph(object):
    def __init__(self):
        '''
        '''
        self.cases_df = None
        self.state_l = None
        self.county_d = None
        self.read_data(fname='us-counties.csv')

    def read_data(self, fname):
        print(f'Reading {fname}')
        self.cases_df = pd.read_csv(fname, parse_dates=True)

    def choose_state(self, state_re=None):
        """
        Interactively ask which state(s) we want to graph the county data for.
        sets self.state_l 
        """
        # get the list of states
        state_l = sorted(self.cases_df.state.unique())

        state_regex = None
        
        if state_re is None:
            for num, state in enumerate(state_l):
                print(f'{num:3d} {state}')

            in_str = input('select the number of the state you want to graph or regex string to match state name: ')

            try:
                state_l = [state_l[int(in_str)]]
            except ValueError:
                state_regex = re.compile(in_str, re.IGNORECASE)
        else:
            state_regex = re.compile(state_re, re.IGNORECASE)

        if state_regex:
            state_l = list(filter(state_regex.search, state_l))

        print(f'Selected {state_l}')
        self.state_l = state_l
        return
                   
    def choose_county(self, county_restr=None):
        """
        To be executed after choose_state which has determined a list of states to analyse.
        Fill in  a dictionary index by state, and the value per state is a list of counties to analyze.
        """
        self.county_d = {}

        for state in self.state_l:
            county_regex = None
            state_df = self.cases_df.loc[self.cases_df['state'] == state]
            county_l = sorted(state_df.county.unique())
            if county_restr is None:
                for num, county in enumerate(county_l):
                    print(f'{num:3d} {county}')

                in_str = input(f'For "{state}" select the number of the county you want to graph or regex string to match the county name: ')

                try:
                    county_l = [county_l[int(in_str)] ]
                except ValueError:
                    county_regex = re.compile(in_str, re.IGNORECASE)
            else:
                county_regex = re.compile(county_restr, re.IGNORECASE)

            if county_regex:
                print(f'county_l={county_l} county_restr={county_restr} county_re={county_regex}')
                county_l = list(filter(county_regex.search, county_l))

            print(f'For state={state} Selected {county_l}')
            self.county_d[state] = county_l

        return

    def draw_graphs(self):
        """
        Graph all the states, counties in the county_c dictionary.
        """
        print(f'Drawing graphs')
        for state in self.county_d:
            print(f'{state:25s} {self.county_d[state]}')
            for county in self.county_d[state]:
                self.draw_graph(state=state, county=county)
        return

    def draw_graph(self, state='Massachusetts', county='Bristol'):
        """
        Graphs a single state and county.
        """
        print(f'Drawing graph for "{state}" county="{county}"')
        county_df = self.cases_df.loc[((self.cases_df['state'] == state) & (self.cases_df['county'] == county)) ].copy()
        #print(county_df.head(10))

        county_df['new cases'] = county_df.cases.diff(periods=1)
        county_df['new cases'] = county_df['new cases'].clip(lower=0)
        
        county_df['7 day ave'] = county_df['new cases'].rolling(7).mean()
        county_df['14 day ave'] = county_df['new cases'].rolling(14).mean()

        #print(county_df)

        fig = make_subplots(specs=[[{"secondary_y": True}]])
    
        # fig.add_trace(go.Scatter(x=county_df['date'], y=county_df['new cases'],
        #                                      mode='lines+markers',
        #                                      name='new cases'),
        #               secondary_y=False)
        fig.add_trace(go.Scatter(x=county_df['date'], y=county_df['7 day ave'],
                                 mode='lines+markers',
                                 name='7 day rolling ave'),
                      secondary_y=True)
        fig.add_trace(go.Scatter(x=county_df['date'], y=county_df['14 day ave'],
                                 mode='lines+markers',
                                 name='14 day rolling ave'),
                      secondary_y=True)
        fig.update_layout(title=f'{county} county {state} covid cases')
        fig.update_xaxes(title_text=f'Date')
        fig.update_yaxes(title_text='new cases', secondary_y=False)
        fig.update_yaxes(title_text='7, 14 day average new cases', secondary_y=True)
        fig.show()

        

class Setup(object):
    def __init__(self):
        self.parse_args()

    def parse_args(self):
        import argparse
        import sys
        global Args
    
        pr = argparse.ArgumentParser(description='Search the NYT covid data for specific state and county data, then graph the new case arrival rate.')
        
        pr.add_argument('--state-regex', '-s',
                        type=str,
                        default=None,
                        help="The regex to use to search the states.  Can match multiple states.")
        pr.add_argument('--county-regex', '-c',
                        type=str,
                        default=None,
                        help="The regex to use to search the copunties of the states chosen  Can match multiple states/counties.")
        pr.add_argument('--debug', '-d',      action='store_true', default=False,
                        help='turn on debug level logging')
    
        try:
            Args = pr.parse_args()
        except SystemExit:
            sys.exit()
        except:
            print('FATAL - unable to parse command line: %s ' % (sys.exc_info()[0]) )
            raise

        return

def main():
    setup = Setup()

    cases = nyt_covid_graph()
    #cases.draw_graph()
    #return 0
    cases.choose_state(state_re= Args.state_regex)
    cases.choose_county(county_restr=Args.county_regex)
    cases.draw_graphs()
    return 0
    
if __name__ == '__main__':
    ret_code = main()
    sys.exit(ret_code)



