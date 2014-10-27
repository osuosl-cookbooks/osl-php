# osl-php


Packages Recipe
===============

Using the packages recipe has a few rules. It will iterate over <code>node['osl-php']['packages']</code>
and any Enumerable objects nested inside. For any String objects it finds, it installs them.

For any Enumerable object found, there are three cases:

1. 0 objects in the Enumerable object are Enumerable.
2. At least one object in the Enumerable object is an Enumerable object,
3. All objects in the Enumerable object are enumerable.

An example for each case is the following:

1. <code>h = ['php5-gd', 'php5-fpm']</code>
2. <code>h = ['php5-gd', {'php5-fpm' => true}]</code>
3. <code>h = [{'php5-gd' => true, 'php5-fpm' => true}]</code>

The cases are solved in the following ways:

1. Include every item in <code>h</code>.
2. Include non-hash items, include all hash keys that have a true value
3. Same as two, with no non-hash items.

The end result will be a list of packages to install. For example, all 3 cases produce the following list:

<code>['php5-gd', 'php5-fpm']</code>

