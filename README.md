# What is the Seimtra ?

Seimtra is a web application system(**WAS**) that supplies a platform to user how easy to setup a website, and the developer how fast to create an application module.

Seimtra consists of the famous applications **sinatra**, **sequel**, **slim** (So, the alias name called **3s**) as the core framework, and thousands of modules in offical repository to be extended your web application. 



# How to install the Seimtra ?

Installing as a gem

	gem install seimtra

or

	git clone git://github.com/coolesting/seimtra.git
	cd seimtra
	gem build seimtra.gemspec
	gem install seimtra --local



# How to deploy a web project with Seimtra ?

	3s init myproject
	cd myproject
	thin start

check the info of the project

	3s info -p

see the current custom info

	3s info -c

see the module info

	3s info admin

see the Seimtra version

	3s version

list the modules

	3s list

> Note : Whatever you want to do something to the project, make sure the Seimtra in your current directory.



# How to extend your web application ?

add a module

	3s add forum



# How easy to create a module ?

This is a modular structure web application that consists of some variety of modules.
It divides difference function into corresponding itself module. 
So, whatever we want to do something, we should create a new module for similar function in corresponding module.

	3s new mymodule


# About the database

Any database operations are based on Sequel, for more details see the [Sequel](http://sequel.rubyforge.org/documentation.html).

see the db info

	3s db -o
	3s db -o --details

create a migration record

	3s db create users String:username String:password String:salt -a

The option *-a* will automatic adds the key *primary id*, *changed time*, and *created time*.

run the migration record

	3s db -r
