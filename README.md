## Introduction

Seimtra is a web application system that creates an application structure with sinatra, sequel, slim. And it still integrates generated function as the ROR.


## Installation

	gem install seimtra

or

	git clone git://github.com/coolesting/seimtra.git


## How to deploy a project with seimtra

	3s init myproject

check the information of the project

	3s info

run the project
	
	thin start

> Note : Whatever you want to do something to this project, undering the root directory of the project is necessary.


## Creating a module

This is a modular structure application that consists of some variety of modules.
It divides difference function into corresponding itself module. 
So, whatever we want to do something, we should create a new module for similar function in corresponding module.


## About the database

Everything database operation is based on Sequel, for more details see the [Sequel](http://sequel.rubyforge.org/documentation.html).

See the db info

	3s db -o
	3s db -o --details

Create a migration record

	3s db create users String:username String:password String:salt -a

The option *-a* will automatic adds the key *primary id*, *changed time*, and *created time*.

Run the migration record

	3s db -r
