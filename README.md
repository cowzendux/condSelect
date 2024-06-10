# condSelect

SPSS Python Extension function that randomly selects a fixed number of participants from each level of a condition variable

This is useful when you want to graph trends by condition, but there are too many participants to make sense of the graphs containing all of the participants. The function allows you to limit the data set with a small sample in each condition, enough to allow you to see the trends but not so many that the number of overlapping data points obscures what's going on in the graph.

Observations that are not selected are kept in the data set, but are de-selected so that they are not used in analyses. Running the same function multiple times will select different cases each time. 

This and other SPSS Python Extension functions can be found at http://www.stat-help.com/python.html

## Usage
**condSelect(condvar, selnum)**
* "condvar" is a string containing the name of the condition variable. The condition variable itself can be either a string or numeric variable, and can have any number of levels. This argument is requried.
* "selnum" is a number indicating how many subjects you want to select from each condition.

## Example
**condSelect("cond", 10)**
* This would randomly select 10 subjects from each level of the cond variable.
